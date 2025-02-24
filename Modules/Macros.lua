-- Conditionally modify macros
-- Make a Plumber Macro by adding #plumber:[command] to the top of the macro body
-- Implementations:
-- 1. plumber:drawer        Create a custom SpellFlyout by adding # to your regular macro. E.g. #/use:Dalaran Hearthsone
-- 2. plumber:drive         Added to your regular mount macro. Summon G-99 Breakneck in Undermine. Change the icon.


local _, addon = ...
local L = addon.L;
local API = addon.API;
local CallbackRegistry = addon.CallbackRegistry;
--local SpellFlyout = addon.SpellFlyout;  --Unused, Insecure
local SecureSpellFlyout = addon.SecureSpellFlyout;

local find = string.find;
local match = string.match;
local gsub = string.gsub;
local format = string.format;
local tinsert = table.insert;
local ipairs = ipairs;
local strlenutf8 = strlenutf8;
local InCombatLockdown = InCombatLockdown;
local GetMacroBody = GetMacroBody;
local GetMacroInfo = GetMacroInfo;
local EditMacro = EditMacro;
local GetActiveAbilities = C_ZoneAbility and C_ZoneAbility.GetActiveAbilities or API.Nop;
local GetMountInfoByID = C_MountJournal and C_MountJournal.GetMountInfoByID or API.Nop;
local FindSpellOverrideByID = FindSpellOverrideByID;
local GetActionInfo = GetActionInfo;
local GetCursorInfo = GetCursorInfo;
local CreateFrame = CreateFrame;

local DoesItemReallyExist = API.DoesItemReallyExist;
local GetItemIDForItemInfo = C_Item.GetItemIDForItemInfo;
local GetItemNameByID = C_Item.GetItemNameByID;
local GetItemIconByID = C_Item.GetItemIconByID;
local RequestLoadItemDataByID = C_Item.RequestLoadItemDataByID;
local RequestLoadSpellData = C_Spell.RequestLoadSpellData;
local GetSpellName = C_Spell.GetSpellName;
local GetSpellTexture = C_Spell.GetSpellTexture;
local GetSpellInfo = C_Spell.GetSpellInfo;
local IsPlayerSpell = IsPlayerSpell;
local CanPlayerPerformAction = API.CanPlayerPerformAction;
local GetItemCraftingQuality = API.GetItemCraftingQuality;


local MacroInterpreter = {};    --Add info to tooltip
local EditorUI = {};            --Attach to MacroFrame once it loaded
local EditorSetup = {};         --Setup the editor when viewing supported Plumber Macro

local ModifyType = {
    None = 0,
    Add = 1,
    Overwrite = 2,
};

local SlashCmd = {};
--SlashCmd.DrawerMacro = API.GetSlashSubcommand("DrawerMacro");


local function AddExtraLineToMacroBody(extraLine, body)
    extraLine = "\n\n"..extraLine;
    local numRequired = strlenutf8(extraLine) + 2;
    local numTotal = strlenutf8(body);
    if numTotal + numRequired >= 255 then
        local pattern = "$";
        local n = 0;
        while n < numRequired do
            n = n + 1;
            pattern = "."..pattern;
        end
        body = gsub(body, pattern, extraLine);
    else
        body = body..extraLine;
    end
    return body
end

local PlumberMacros = {};
do
    PlumberMacros["drive"] = {
        name = L["PlumberMacro Drive"],
        type = ModifyType.Add,
        spellID = 460013,

        events = {
            "SPELLS_CHANGED",
        },

        conditionFunc = function()
            if API.GetPlayerMap() == 2346 then
                return true
            end
            local abilities = GetActiveAbilities();
            if abilities then
                for i, ability in ipairs(abilities) do
                    if ability.spellID and FindSpellOverrideByID(ability.spellID) == 460013 then
                        return true
                    end
                end
            end
            return false
        end,

        addFunc = function()
            local spellName = (GetSpellName(PlumberMacros["drive"].spellID)) or "G-99 Breakneck";
            return "/cast spell:460013\n/cast [noswimming] "..spellName
            --The first /cast doesn't get executed but it's necessary to make GetActionInfo() return the macroIndex instead of spellID
        end,

        trueReturn = {
            icon = 1408996,
        },

        falseReturn = {
            icon = 0,
        },
    };

    PlumberMacros["drawer"] = {
        name = L["PlumberMacro Drawer"],
        type = ModifyType.None,

        conditionFunc = function ()
            return true
        end,
    };
end


local EL = CreateFrame("Frame");

EL.macroIndexMin = 1;
EL.macroIndexMax = 138;


function EL:CheckSupportedMacros()
    self:UnregisterAllEvents();

    for command, commandData in pairs(PlumberMacros) do
        commandData.currentState = nil;
    end

    self.macroEvents = {};
    self.activeCommands = {};
    MacroInterpreter.macroCommand = {};

    local body;
    local command;
    local n = 0;

    for index = self.macroIndexMin, self.macroIndexMax do
        body = GetMacroBody(index);
        if body then
            command = match(body, "#plumber:(%w+)");
            if command and PlumberMacros[command] then
                n = n + 1;

                if not self.activeCommands[command] then
                    self.activeCommands[command] = {};
                end
                tinsert(self.activeCommands[command], index);

                if PlumberMacros[command].events then
                    for _, event in ipairs(PlumberMacros[command].events) do
                        if not self.macroEvents[event] then
                            self.macroEvents[event] = {};
                        end
                        tinsert(self.macroEvents[event], {
                            index = index,
                            command = command,
                        });
                    end
                end

                MacroInterpreter.macroCommand[index] = command;
            end
        end
    end

    self.anySupported = n > 0;

    if self.anySupported then
        --print("Plumber Macro Found:", n);
        MacroInterpreter:Init();
        for event in pairs(self.macroEvents) do
            self:RegisterEvent(event);
        end
    end
end

function EL:UpdateMacroByEvent(event)
    local commands = {};

    for _, info in ipairs(self.macroEvents[event]) do
        if not commands[info.command] then
            commands[info.command] = {};
        end
        tinsert(commands[info.command], info.index);
    end

    self:UpdateMacros(commands);
end

function EL:UpdateMacros(commands)
    if self.anySupported then
        commands = commands or self.activeCommands;

        local inCombat = InCombatLockdown();
        local anyChange, newState, returns;
        local name, icon, body;
        local commandData;
        local prefix;

        for command, list in pairs(commands) do
            newState = PlumberMacros[command].conditionFunc();
            if newState ~= PlumberMacros[command].currentState then
                anyChange = true;
                if not inCombat then
                    PlumberMacros[command].currentState = newState;
                    commandData = PlumberMacros[command];
                    returns = nil;
                    if newState then
                        returns = commandData.trueReturn;
                    else
                        returns = commandData.falseReturn;
                    end

                    for _, index in ipairs(list) do
                        name, icon, body = GetMacroInfo(index);
                        if returns and returns.icon then
                            icon = returns.icon;
                            if icon == 0 then
                                icon = 134400;
                            end
                        end

                        if commandData.type == ModifyType.Add and commandData.addFunc then
                            prefix = "#plumber:"..command;
                            body = gsub(body, ".+##", "");
                            body = gsub(body, prefix, "");
                            while find(body, "^\n") do
                                body = gsub(body, "^\n", "");
                            end
                            if newState then
                                local extraLine = commandData.addFunc();
                                body = prefix.."\n"..extraLine.."\n##\n"..body;
                            else
                                body = prefix.."\n"..body;
                            end
                        end

                        if commandData.initFunc then
                            body = commandData.initFunc(body);
                        end
                        EditMacro(index, name, icon, body);
                    end
                end
            end
        end

        if anyChange and inCombat then
            self:RegisterEvent("PLAYER_REGEN_ENABLED");
        end

        self:UpdateDrawers();
    end
end


local DrawerUpdateFlag = {
    Combat = 0,
    Started = 1,
    Success = 2,
};

function EL:UpdateDrawers()
    if InCombatLockdown() then
        self.drawerUpdateFlag = DrawerUpdateFlag.Combat;
        return
    end
    self.drawerUpdateFlag = DrawerUpdateFlag.Started;

    SecureSpellFlyout:ReleaseClickHandlers();
    local drawers = self.activeCommands and self.activeCommands["drawer"];
    if drawers and #drawers > 0 then
        local name, icon, body, drawerInfo;
        local handlerName;
        local checkUsability = true;
        local ignoreUnsable = true;
        for _, macroIndex in ipairs(drawers) do
            name, icon, body = GetMacroInfo(macroIndex);
            drawerInfo = MacroInterpreter:GetDrawerInfo(body, checkUsability, ignoreUnsable);
            if drawerInfo then
                handlerName = SecureSpellFlyout:AddActionsAndGetHandler(drawerInfo);
                if handlerName then
                    body = gsub(body, "/plmr 1", "");   --Legacy. Remove it in future update
                    body = SecureSpellFlyout:RemoveClickHandlerFromMacro(body);
                    local extraLine = "/click "..handlerName;
                    body = AddExtraLineToMacroBody(extraLine, body);
                    EditMacro(macroIndex, name, icon, body);
                end
            end
        end
    end

    self.drawerUpdateFlag = DrawerUpdateFlag.Success;
end

function EL:CheckQueue()
    if InCombatLockdown() then return end;
    self:UnregisterEvent("PLAYER_REGEN_ENABLED");
    self:UpdateMacros();
end

function EL:OnUpdate_UpdateMacros(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0 then
        self.t = nil;
        self:SetScript("OnUpdate", nil);
        self:CheckSupportedMacros();
        self:UpdateMacros();
    end
end

function EL:RequestUpdateMacros(delay)
    delay = delay and -delay or 0;
    self.t = delay;
    self:SetScript("OnUpdate", self.OnUpdate_UpdateMacros);
end

function EL:LoadSpellAndItem()
    for _, commandData in pairs(PlumberMacros) do
        if commandData.spellID then
            RequestLoadSpellData(commandData.spellID);
        end
        if commandData.itemID then
            RequestLoadItemDataByID(commandData.itemID);
        end
    end
end

function EL:ListenEvents(state)
    if state then
        self:RegisterEvent("PLAYER_ENTERING_WORLD");
    else
        self:UnregisterAllEvents();
    end
end
EL:ListenEvents(true);


do  --EditorUI  --MacroForge
    function EditorUI:OnLoad()
        self.OnLoad = nil;

        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);

        self.args = {};
        self.objectPools = {};

        if self.SourceEditBox then
            self.SourceEditBox:HookScript("OnEditFocusGained", EditorUI.OnEditFocusGained);
            self.SourceEditBox:HookScript("OnEditFocusLost", EditorUI.OnEditFocusLost);
            self.SourceEditBox:HookScript("OnTextChanged", EditorUI.OnTextChanged);
        end
    end

    function EditorUI:OnShow()
        self.args = {};
        if self.ExtraFrame then
            self.ExtraFrame:UpdatePixel();
        end
        self:RequestSearchInEditBox();
    end

    function EditorUI:OnHide()
        EL:RequestUpdateMacros();
        self.isEditing = nil;
        self.t = 0;
        self:SetScript("OnUpdate", nil);
        self:SetScript("OnEvent", nil);
        self:HideUI();
        self:ReleaseElements();
    end

    function EditorUI.OnEditFocusGained(editBox)
        EditorUI.isEditing = true;
        EditorUI:RequestSearchInEditBox();
    end

    function EditorUI.OnEditFocusLost(editBox)
        EditorUI.isEditing = nil;
    end

    function EditorUI.OnTextChanged(editBox, userInput)
        if userInput then
            EditorUI:RequestSearchInEditBox(0.5);
        else
            EditorUI:RequestSearchInEditBox();
        end
    end

    function EditorUI:RequestSearchInEditBox(delay)
        delay = delay or 0.016;
        self.t = -delay;
        self:SetScript("OnUpdate", EditorUI.OnUpdate_EditBox);
    end

    function EditorUI:OnUpdate_EditBox(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            self:SearchInEditBoxForSupportedCommand();
        end
    end

    function EditorUI:HideUI()
        self.args = {};
        if self.ExtraFrame then
            self.ExtraFrame:Hide();
        end
        if self.MouseBlocker then
            self.MouseBlocker:Hide();
        end
    end

    function EditorUI:TriggerMouseBlocker()
        if self.MouseBlocker then
            self.MouseBlocker:Show();
            C_Timer.After(0, function()
            self.MouseBlocker:Hide();
            end)
        end
    end

    function EditorUI:SearchInEditBoxForSupportedCommand()
        local body = self.SourceEditBox:GetText();
        local command = match(body, "#plumber:(%w+)");
        if command and PlumberMacros[command] and self.ExtraFrame and PlumberMacros[command].editorSetupFunc then
            self.ExtraFrame:Show();
            PlumberMacros[command].editorSetupFunc(body);
        else
            self:HideUI();
        end
    end

    function EditorUI:SetFrameHeight(height)
        if self.ExtraFrame then
            self.ExtraFrame:SetHeight(height);
        end
    end

    function EditorUI:DisplayNote(text)
        self.Note:SetText(text);
    end

    function EditorUI:HighlightIconButton(iconButton, colorIndex)
        if self.HighlightFrame then
            self.HighlightFrame:Hide();
            self.HighlightFrame:ClearAllPoints();
        end
        if iconButton then
            self.HighlightFrame:SetParent(iconButton);
            self.HighlightFrame:SetPoint("TOPLEFT", iconButton.Border, "TOPLEFT", 0, 0);
            self.HighlightFrame:SetPoint("BOTTOMRIGHT", iconButton.Border, "BOTTOMRIGHT", 0, 0);
            self.HighlightFrame:Show();
            self.HighlightFrame:SetFrameLevel(iconButton:GetFrameLevel() + 1);

            if colorIndex == 1 then --Green
                self.HighlightFrame.Texture:SetTexCoord(416/512, 488/512, 0, 72/512);
            elseif colorIndex == 2 then --Red
                self.HighlightFrame.Texture:SetTexCoord(416/512, 488/512, 72/512, 144/512);
            else --Yellow
                self.HighlightFrame.Texture:SetTexCoord(344/512, 416/512, 0, 72/512);
            end
        end
    end

    function EditorUI:RaiseIconButtonLevel(iconButton)
        if self.objectPools.iconButtonPool then
            local baseFrameLevel = self.ExtraFrame:GetFrameLevel() + 1;
            for i, object in ipairs(self.objectPools.iconButtonPool.objects) do
                if object == iconButton then
                    object:SetFrameLevel(baseFrameLevel + 20);
                else
                    object:SetFrameLevel(baseFrameLevel + i);
                end
            end
        end
    end

    function EditorUI:ReleaseElements()
        self:DisplayNote(nil);
        self:HighlightIconButton(nil);

        if self.objectPools then
            for _, pool in pairs(self.objectPools) do
                pool:ReleaseAll();
            end
        end

        if self.ReorderController then
            self.ReorderController:Stop();
        end

        if self.otherElements then
            for _, object in ipairs(self.otherElements) do
                object:Hide();
                object:ClearAllPoints();
            end
        end
    end

    function EditorUI:AddRemovableElements(object)
        if not self.otherElements then
            self.otherElements = {};
        end
        tinsert(self.otherElements, object);
    end

    function EditorUI:SaveMacroBody(body)
        EditorUI.SourceEditBox:SetText(body);
        if not InCombatLockdown() then
            --MacroFrame:SaveMacro();
            local selectedMacroIndex = MacroFrame:GetSelectedIndex();
            local actualIndex = MacroFrame:GetMacroDataIndex(selectedMacroIndex);
            EditMacro(actualIndex, nil, nil, body);
        end
        EL:RequestUpdateMacros(0.0);
    end
end


if MacroFrame_LoadUI then
    --UPDATE_MACROS fires when selecting any macro, without changing its content, so we update our macro after MarcoFrame is closed
    hooksecurefunc("MacroFrame_LoadUI", function()
        if not EditorUI.macroFrameHooked then
            if MacroFrame then
                EditorUI.macroFrameHooked = true;

                if MacroSaveButton then
                    MacroSaveButton:HookScript("OnClick", function()
                        EL:RequestUpdateMacros();
                    end);
                end

                if MacroFrameText and MacroFrameText:IsObjectType("EditBox") then
                    EditorUI.SourceEditBox = MacroFrameText;
                end

                local f = CreateFrame("Frame", nil, MacroFrame);
                API.Mixin(f, EditorUI);
                EditorUI = f;
                f:OnLoad();

                local ef = API.CreateNewSliceFrame(f, "RoughWideFrame");
                f.ExtraFrame = ef;
                ef:Hide();
                ef:SetScript("OnHide", function()
                    ef:UnregisterAllEvents();
                end);
                local offsetY = -4;
                ef:SetPoint("TOPLEFT", MacroFrame, "BOTTOMLEFT", 0, offsetY);
                ef:SetPoint("TOPRIGHT", MacroFrame, "BOTTOMRIGHT", 0, offsetY);
                ef:EnableMouse(true);
                ef:SetFrameStrata("HIGH");

                f.Note = ef:CreateFontString(nil, "OVERLAY", "GameFontNormal");
                f.Note:SetJustifyH("CENTER");
                f.Note:SetTextColor(0.8, 0.8, 0.8);
                f.Note:SetPoint("LEFT", ef, "LEFT", 16, 0);
                f.Note:SetPoint("RIGHT", ef, "RIGHT", -16, 0);
                f.Note:SetSpacing(2);

                f.HighlightFrame = CreateFrame("Frame", nil, ef);
                f.HighlightFrame.Texture = f.HighlightFrame:CreateTexture(nil, "OVERLAY");
                f.HighlightFrame.Texture:SetAllPoints(true);
                f.HighlightFrame:Hide();

                f.MouseBlocker = CreateFrame("Frame", nil, ef);
                f.MouseBlocker:SetAllPoints(true);
                f.MouseBlocker:SetFrameLevel(128);
                f.MouseBlocker:SetFixedFrameLevel(true);
                f.MouseBlocker:EnableMouse(true);

                f:SetFrameHeight(72);
                f:RequestSearchInEditBox();
            end
        end
    end);
end


function EL:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent(event);
        self:LoadSpellAndItem();
        self:RequestUpdateMacros(0.5);
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:CheckQueue();
    elseif self.macroEvents and self.macroEvents[event] then
        self:UpdateMacroByEvent(event);
    end
end
EL:SetScript("OnEvent", EL.OnEvent);


do  --MacroInterpreter
    MacroInterpreter.macroCommand = {};

    local MacroHandlers = {
        ["(/randomfavoritepet)"] = "SetRandomFavoritePet",
        ["(/randompet)"] = "SetRandomPet",
        ["/summonpet%s+(.+)"] = "SetSummonPet",
        ["/sp%s+(.+)"] = "SetSummonPet",
        ["(/dismisspet)"] = "SetDismissPet",
        ["/emote%s+(.+)"] = "SetCustomEmote",
        ["/e%s+(.+)"] = "SetCustomEmote",
    };

    function MacroInterpreter:Init()
        self.Init = function() end;

        local tooltipDataType = Enum.TooltipDataType and Enum.TooltipDataType.Macro;
        if tooltipDataType and TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
            local function Callback(tooltip)
                local tooltipData = tooltip.infoList and tooltip.infoList[1] and tooltip.infoList[1].tooltipData;
                if tooltipData and tooltipData.type == tooltipDataType then
                    local action = tooltip.infoList[1].getterArgs[1];
                    if action then
                        local actionType, id, subType = GetActionInfo(action);
                        if actionType == "macro" and subType == "" then
                            self:TooltipSetMacro(tooltip, id);
                        end
                    end
                end
            end
            TooltipDataProcessor.AddTooltipPostCall(tooltipDataType, Callback);
        else
            print("Plumber AddOn Alert: WoW\'s TooltipDataProcessor methods changed.")
        end
    end

    function MacroInterpreter:GetDrawerInfo(body, checkUsability, ignoreUnsable)
        local tbl;
        local n = 0;
        local processed, usable;
        local name, icon, actionType, id, macroText, craftingQuality;

        for line in string.gmatch(body, "#(/[^\n]+)") do
            processed = false;
            usable = false;
            actionType = nil;
            id = nil;
            icon = nil;
            macroText = nil;

            if not processed then
                local mountID = match(line, "/use%s+mount:(%d+)");
                if not mountID then
                    mountID = match(line, "/cast%s+mount:(%d+)");
                end
                if mountID then
                    processed = true;
                    actionType = "mount";
                    id = tonumber(mountID);
                end
            end

            if not processed then
                id = match(line, "/cast%s+spell:(%d+)");
                id = tonumber(id);
                if id then
                    processed = true;
                    actionType = "spell";
                    name = GetSpellName(tonumber(id));
                end
            end

            if not processed then
                name = match(line, "/cast%s+(.+)");
                if name then
                    processed = true;
                    actionType = "spell";
                end
            end

            if not processed then
                id = match(line, "/use%s+item:(%d+)");
                id = tonumber(id);
                if id then
                    processed = true;
                    actionType = "item";
                end
            end

            if not processed then
                name = match(line, "/use%s+(.+)");
                if name then
                    processed = true;
                    actionType = "item";
                end
            end

            if not processed then   --generic macro command match
                local arg;
                for pattern, handler in pairs(MacroHandlers) do
                    arg = match(line, pattern);
                    if arg then
                        id = arg;
                        actionType = handler;
                        icon = 136243;  --trade_engineering
                        processed = true;
                        break
                    end
                end
            end

            if actionType then
                if actionType == "spell" then
                    if (not id) and name then
                        local spellInfo = GetSpellInfo(name);
                        if spellInfo then
                            usable = true;
                            id = spellInfo.spellID;
                            icon = spellInfo.iconID;
                        end
                    end
                    if id and (not icon) then
                        icon = GetSpellTexture(id) or 134400;
                    end
                    if id and IsPlayerSpell(id) then
                        usable = true;
                    end
                    if name then
                        macroText = "/cast "..name;
                    end
                elseif actionType == "item" then
                    if (not id) and name then
                        id = GetItemIDForItemInfo(name);
                    end
                    if id and DoesItemReallyExist(id) then
                        name = GetItemNameByID(id);
                        icon = GetItemIconByID(id);
                        usable = true;
                        macroText = format("/use \"item:%d\"", id);
                        craftingQuality = GetItemCraftingQuality(id);
                        if name and craftingQuality then
                            name = format("%s T%s", name, craftingQuality);
                            --name = format("%s|A:Professions-ChatIcon-Quality-Tier%s:0:0|a", name, craftingQuality);
                            --local markup = CreateAtlasMarkupWithAtlasSize("Professions-ChatIcon-Quality-Tier"..craftingQuality, 0, 0, nil, nil, nil, 0.5)
                            --name = name..markup
                        end
                    end
                elseif actionType == "mount" then
                    local  _name, _spellID, _icon, _isActive, _isUsable, _sourceType, _isFavorite, _isFactionSpecific, _faction, _shouldHideOnChar, _isCollected = GetMountInfoByID(id);
                    icon = _icon;
                    usable = _isCollected;
                    name = _name;
                    macroText = _name and gsub(line, "mount:%d+", _name) or line;
                    actionType = "spell";
                    id = _spellID;
                else
                    name = line;
                    macroText = line;
                    usable = true;
                end

                if checkUsability and id then
                    if not CanPlayerPerformAction(actionType, id) then
                        --id = nil;
                        usable = false;
                    end
                end

                if ignoreUnsable and not usable then
                    id = nil;
                end

                if id and id ~= 0 then
                    if not tbl then
                        tbl = {};
                    end

                    n = n + 1;
                    tbl[n] = {
                        tooltipLineText = name,
                        icon = icon,
                        actionType = actionType,
                        id = id,
                        usable = usable,
                        macroText = macroText,
                        rawMacroText = line,
                    };
                end
            end
        end

        return tbl
    end

    function MacroInterpreter.drawer(tooltip, body)
        local drawerInfo = MacroInterpreter:GetDrawerInfo(body, true);
        if drawerInfo then
            if EL.drawerUpdateFlag == DrawerUpdateFlag.Combat then
                tooltip:AddLine(L["PlumberMacro DrawerFlag Combat"], 1, 0.1, 0.1, true);
            elseif EL.drawerUpdateFlag == DrawerUpdateFlag.Started then
                tooltip:AddLine(L["PlumberMacro DrawerFlag Stuck"], 1, 0.1, 0.1, true);
            end

            for _, info in ipairs(drawerInfo) do
                if info.tooltipLineText then
                    if info.usable then
                        tooltip:AddLine(info.tooltipLineText, 1, 0.82, 0);
                    else
                        tooltip:AddLine(info.tooltipLineText, 0.6, 0.6, 0.6);
                    end
                end
            end
        end
    end

    function MacroInterpreter:TooltipSetMacro(tooltip, macroIndex)
        local command = self.macroCommand[macroIndex];
        if command and PlumberMacros[command] then
            tooltip:AddLine(PlumberMacros[command].name, 0, 0.8, 1);
            if self[command] then
                local body = GetMacroBody(macroIndex);
                self[command](tooltip, body);
            end

            tooltip:Show();
        end
    end
end


do  --Editor Setup
    EditorSetup.itemButtonSize = 32;
    EditorSetup.itemButtonGap = 4;

    function EditorSetup.CreateIconButtonPool()
        if not EditorUI.objectPools.iconButtonPool then
            EditorUI.objectPools.iconButtonPool = {};

            local file = "Interface/AddOns/Plumber/Art/Frame/MacroForge.png";

            local IconButtonMixin = {};

            local Placeholder = CreateFrame("Frame", nil, EditorUI.ExtraFrame);
            Placeholder:Hide();
            Placeholder:SetSize(32, 32);
            Placeholder.Border = Placeholder:CreateTexture(nil, "OVERLAY");
            Placeholder.Border:SetPoint("CENTER", Placeholder, "CENTER", 0, 0);
            Placeholder.Border:SetTexCoord(272/512, 344/512, 72/512, 144/512);
            Placeholder.Border:SetTexture(file);
            Placeholder.Icon = Placeholder:CreateTexture(nil, "OVERLAY");
            EditorUI:AddRemovableElements(Placeholder);
            API.DisableSharpening(Placeholder.Border);

            local ReorderController = API.CreateDragReorderController(EditorUI.ExtraFrame);
            EditorUI.ReorderController = ReorderController;

            ReorderController:SetOnDragStartCallback(function()
                ReorderController:SetObjects(EditorUI.objectPools.iconButtonPool:GetActiveObjects());
                EditorUI:HighlightIconButton(ReorderController:GetDraggedObject(), 1);
                Placeholder:Show();
                ReorderController:SetPlaceholder(Placeholder);
            end);

            ReorderController:SetOnDragEndCallback(function(draggedObject, delete)
                Placeholder:Hide();

                local body = "#plumber:drawer";
                for _, object in ipairs(ReorderController.objects) do
                    if delete and object == draggedObject then
                        
                    else
                        body = body.."\n#"..object.rawMacroText;
                    end
                end
                EditorUI:SaveMacroBody(body);
            end);

            ReorderController:SetBoundary(EditorUI.ExtraFrame);

            ReorderController:SetInBoundaryCallback(function()
                EditorUI:HighlightIconButton(ReorderController:GetDraggedObject(), 1);
                Placeholder.Border:SetTexCoord(272/512, 344/512, 72/512, 144/512);
            end);

            ReorderController:SetOutBoundaryCallback(function()
                EditorUI:HighlightIconButton(ReorderController:GetDraggedObject(), 2);
                Placeholder.Border:SetTexCoord(344/512, 416/512, 72/512, 144/512);
            end);

            function IconButtonMixin:SetEffectiveSize(w)
                self:SetSize(w, w);
                self.Border:SetSize(w*72/64, w*72/64);
                self.Icon:SetSize(w*60/64, w*60/64);
            end

            IconButtonMixin.SetEffectiveSize(Placeholder, EditorSetup.itemButtonSize);

            local hl = EditorUI.HighlightFrame.Texture;
            hl:SetTexture(file);
            hl:SetTexCoord(344/512, 416/512, 0, 72/512);
            API.DisableSharpening(hl);

            function IconButtonMixin:OnEnter()
                if ReorderController:IsDraggingObject() then
                    return
                end

                EditorUI:HighlightIconButton(self);
                if self:ShowTooltip() then
                    local tooltip = GameTooltip;
                    if self.tooltipMethod then
                        tooltip:AddLine(" ");
                    end
                    tooltip:AddLine("<"..L["Drag To Reorder"]..">", 0.1, 1, 0.1, true);
                    tooltip:Show();

                    if self:IsDataCached() then
                        self.UpdateTooltip = nil;
                    else
                        self.UpdateTooltip = self.OnEnter;
                    end
                end
            end

            function IconButtonMixin:OnLeave()
                GameTooltip:Hide();
                if ReorderController:IsDraggingObject() then
                    return
                end
                EditorUI:HighlightIconButton(nil);
            end

            function IconButtonMixin:OnMouseDown(mouseButton)
                if mouseButton == "LeftButton" then
                    ReorderController:SetDraggedObject(self);
                    ReorderController:PreDragStart();
                    EditorUI:RaiseIconButtonLevel(self);
                    GameTooltip:Hide();
                end
            end

            function IconButtonMixin:OnMouseUp()
                if ReorderController:IsDraggingObject() then
                    EditorUI:TriggerMouseBlocker();
                end
                ReorderController:OnMouseUp();
            end

            function IconButtonMixin:OnLoad()
                self:SetScript("OnEnter", self.OnEnter);
                self:SetScript("OnLeave", self.OnLeave);
                self:SetScript("OnMouseDown", self.OnMouseDown);
                self:SetScript("OnMouseUp", self.OnMouseUp);
            end

            function IconButtonMixin:OnRemoved()
               self:ClearAction();
            end

            SecureSpellFlyout:PopulateButtonMixin(IconButtonMixin);

            local function CreateObject()
                local f = CreateFrame("Button", nil, EditorSetup.IconButtonContainer, "PlumberSmallIconButtonTemplate");

                f.Border:SetTexture(file);
                f.Border:SetTexCoord(272/512, 344/512, 0, 72/512);
                API.DisableSharpening(f.Border);

                API.Mixin(f, IconButtonMixin);
                f:OnLoad();
                f:SetEffectiveSize(EditorSetup.itemButtonSize);

                return f
            end
            EditorUI.objectPools.iconButtonPool = API.CreateObjectPool(CreateObject);
        end
        return EditorUI.objectPools.iconButtonPool
    end

    local SupportedCursorInfo = {
        item = {
            command = "/use",
            argGetter = function(itemID, itemLink)
                local name = GetItemNameByID(itemID);
                return name, "item:"..itemID
            end
        },

        spell = {
            command = "/cast",
            argGetter = function(spellIndex, bookType, spellID, baseSpellID)
                local name = GetSpellName(spellID);
                return name, "spell:"..spellID
            end
        },

        battlepet = {
            command = "/sp",
            argGetter = function(petGUID)
                local speciesID, customName, level, xp, maxXp, displayID, favorite, name = C_PetJournal.GetPetInfoByPetID(petGUID);
                return name, "pet:"..speciesID
            end
        },

        mount = {
            command = "/use",
            argGetter = function(mountID, mountIndex)
                local name = GetMountInfoByID(mountID);
                return name, "mount:"..mountID
            end
        },
    };

    local function Checkbox_CloseAfterClick_OnClick(self)
        local state = self:GetChecked();
        addon.SetDBValue("SpellFlyout_CloseAfterClick", state);
        EL:RequestUpdateMacros(0.0);
    end

    function EditorSetup.DrawerOnEvent(self, event, ...)
        if event == "CURSOR_CHANGED" then
            local infoType, arg1, arg2, arg3, arg4 = GetCursorInfo();

            if infoType then
                EditorSetup.ReceptorFrame:Show();
                EditorSetup.IconButtonContainer:Hide();
                EditorUI.Note:Hide();
                local receptor = EditorSetup.ReceptorFrame;
                local info = SupportedCursorInfo[infoType];
                if info and (arg1 ~= nil) then
                    receptor.PlusSign:Show();
                    receptor.Instruction:Hide();
                    local name, commandArg = info.argGetter(arg1, arg2, arg3, arg4);
                    local newCommand = format("#%s %s", info.command, commandArg);

                    local function Receptor_OnEnter(self)
                        receptor.PlusSign:Hide();
                        receptor.Instruction:Show();
                        receptor.Instruction:SetText(format(L["Drawer Add Action Format"], "["..name.."]"));
                        receptor.Instruction:SetTextColor(1, 0.82, 0);
                        receptor.newCommand = newCommand;
                    end

                    local function Receptor_OnLeave(self)
                        receptor.PlusSign:Show();
                        receptor.Instruction:Hide();
                        receptor.newCommand = nil;
                    end

                    local function Receptor_OnClick(self, button)
                        if button == "RightButton" then
                            if not InCombatLockdown() then
                                ClearCursor();
                            end
                            return
                        end

                        local body = EditorUI.SourceEditBox:GetText();
                        body = body.."\n"..newCommand;
                        EditorUI:SaveMacroBody(body);
                        if not InCombatLockdown() then
                            ClearCursor();
                        end
                    end

                    local function Receptor_OnReceiveDrag(self)
                        Receptor_OnClick(self, "LeftButton");
                    end

                    receptor:SetScript("OnEnter", Receptor_OnEnter);
                    receptor:SetScript("OnLeave", Receptor_OnLeave);
                    receptor:SetScript("OnClick", Receptor_OnClick);
                    receptor:SetScript("OnReceiveDrag", Receptor_OnReceiveDrag);

                    if receptor:IsMouseMotionFocus() then
                        Receptor_OnEnter(receptor);
                    else
                        Receptor_OnLeave(receptor);
                    end
                else
                    receptor.PlusSign:Hide();
                    receptor.Instruction:Show();
                    receptor.Instruction:SetText(format(L["Unsupported Action Type Format"], infoType));
                    receptor.Instruction:SetTextColor(0.6, 0.6, 0.6);
                    receptor:SetScript("OnEnter", nil);
                    receptor:SetScript("OnLeave", nil);
                    receptor:SetScript("OnClick", nil);
                    receptor:SetScript("OnReceiveDrag", nil);
                end
            else
                EditorSetup.ReceptorFrame:Hide();
                EditorSetup.IconButtonContainer:Show();
                EditorUI.Note:Show();
            end
        end
    end

    function EditorSetup.DrawerRecepetor()
        --drag and drop an item/spell to add it to the drawer
        if not EditorSetup.IconButtonContainer then
            local f = CreateFrame("Frame", nil, EditorUI.ExtraFrame);
            EditorSetup.IconButtonContainer = f;
            f:SetHeight(72);
            f:SetPoint("TOPLEFT", EditorUI.ExtraFrame, "TOPLEFT", 0, 0);
            f:SetPoint("TOPRIGHT", EditorUI.ExtraFrame, "TOPRIGHT", 0, 0);
        end

        if not EditorSetup.ReceptorFrame then
            local f = CreateFrame("Button", nil, EditorUI.ExtraFrame);
            EditorSetup.ReceptorFrame = f;
            f:SetAllPoints(true);
            f:RegisterForClicks("LeftButtonUp", "RightButtonUp");

            local PlusSign = f:CreateTexture(nil, "OVERLAY");
            f.PlusSign = PlusSign;
            PlusSign:SetSize(32, 32);
            PlusSign:SetPoint("CENTER", f, "CENTER", 0, 0);
            PlusSign:SetTexture("Interface/AddOns/Plumber/Art/Frame/MacroForge.png");
            PlusSign:SetTexCoord(0/512, 64/512, 72/512, 136/512)

            local Instruction = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            f.Instruction = Instruction;
            Instruction:Hide();
            Instruction:SetJustifyH("CENTER");
            Instruction:SetPoint("LEFT", f, "LEFT", 16, 0);
            Instruction:SetPoint("RIGHT", f, "RIGHT", -16, 0);
            Instruction:SetSpacing(2);
        end
    end

    function EditorSetup.Drawer(body)
        EditorSetup.DrawerRecepetor();
        EditorSetup.ReceptorFrame:Hide();
        EditorSetup.IconButtonContainer:Show();

        local drawerInfo = MacroInterpreter:GetDrawerInfo(body);
        if drawerInfo and #drawerInfo > 0 then
            local refresh = false;

            if EditorUI.args.type ~= "drawer" then
                EditorUI.args.type = "drawer";
                refresh = true;
            else
                if EditorUI.args.drawerInfo then
                    if #EditorUI.args.drawerInfo == #drawerInfo then
                        for i, info in ipairs(EditorUI.args.drawerInfo) do
                            if (info.actionType ~= drawerInfo[i].actionType) or (info.id ~= drawerInfo[i].id) then
                                refresh = true;
                                break
                            end
                        end
                    else
                        refresh = true;
                    end
                else
                    refresh = true;
                end
            end

            if refresh then
                EditorUI:ReleaseElements();
                local parent = MacroFrame;
                local container = EditorSetup.IconButtonContainer;
                local pool = EditorSetup.CreateIconButtonPool();
                local size = EditorSetup.itemButtonSize;
                local gap = EditorSetup.itemButtonGap;
                local frameWidth = parent:GetWidth();
                local span = #drawerInfo * (size + gap) - gap;
                local requiredWidth = span + 48;
                if requiredWidth > frameWidth then
                    frameWidth = requiredWidth;
                end
                local fromX = 0.5*(frameWidth - span);
                local button;
                local baseFrameLevel = container:GetFrameLevel();

                for i, info in ipairs(drawerInfo) do
                    button = pool:Acquire();
                    button.index = i;
                    button:SetFrameLevel(baseFrameLevel + i);
                    button:Show();
                    button:SetAction(info);
                    button:SetPoint("LEFT", container, "LEFT", fromX + (size + gap) * (i - 1), 0);
                end

                EditorUI.ExtraFrame:ClearAllPoints();
                EditorUI.ExtraFrame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -4);
                EditorUI.ExtraFrame:SetWidth(frameWidth);

                EditorUI.ReorderController:SetAnchorInfo(container, "LEFT", fromX, 0, EditorSetup.itemButtonGap, 0);
            end
        else
            EditorUI:ReleaseElements();
            EditorUI:DisplayNote(L["Drag And Drop Item Here"]);
        end
        EditorUI.args.drawerInfo = drawerInfo;
        EditorUI.ExtraFrame:RegisterEvent("CURSOR_CHANGED");
        EditorUI.ExtraFrame:SetScript("OnEvent", EditorSetup.DrawerOnEvent);
    end
    PlumberMacros["drawer"].editorSetupFunc = EditorSetup.Drawer;
end