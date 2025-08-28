-- Conditionally modify macros
-- Make a Plumber Macro by adding #plumber:[command] to the top of the macro body
-- Implementations:
-- 1. plumber:drawer        Create a custom SpellFlyout by adding # to your regular macro. E.g. #/use:Dalaran Hearthsone
-- 2. plumber:drive         Added to your regular mount macro. Summon G-99 Breakneck in Undermine. Change the icon.


-- User Settings
local HIDE_UNUSABLE = false;        --Hide unusable spells
local UPDATE_FREQUENTLY = false;    --Update drawers when BAG_UPDATE_DELAYED, SPELLS_CHANGED
------------------

local _, addon = ...
local L = addon.L;
local API = addon.API;
local CallbackRegistry = addon.CallbackRegistry;
--local SpellFlyout = addon.SpellFlyout;  --Unused, Insecure
local SecureSpellFlyout = addon.SecureSpellFlyout;
local GetDBValue = addon.GetDBValue;

local find = string.find;
local match = string.match;
local gmatch = string.gmatch;
local gsub = string.gsub;
local format = string.format;
local tinsert = table.insert;
local pairs = pairs;
local ipairs = ipairs;
local strlenutf8 = strlenutf8;
local InCombatLockdown = InCombatLockdown;
local GetMacroBody = GetMacroBody;
local GetMacroInfo = GetMacroInfo;
local GetMacroIndexByName = GetMacroIndexByName;
local EditMacro = EditMacro;
local GetNumMacros = GetNumMacros;
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
local CanPlayerPerformAction = API.CanPlayerPerformAction;
local GetItemCraftingQuality = API.GetItemCraftingQuality;


local MacroInterpreter = {};    --Add info to tooltip
local EditorUI = {};            --Attach to MacroFrame once it loaded
local EditorSetup = {};         --Setup the editor when viewing supported Plumber Macro
local DrawerUpdator = CreateFrame("Frame");     --Optional. Update button states when bag, spell change. (Flagged dirty after certain events, update all drawers unpon mouse over Action Button or entering combat)


local ModifyType = {
    None = 0,
    Add = 1,
    Overwrite = 2,
};

local SlashCmd = {};
--SlashCmd.DrawerMacro = API.GetSlashSubcommand("DrawerMacro");


local function AddExtraLineToMacroBody(extraLine, body)
    extraLine = "\n\n"..extraLine;
    local numRequired = strlenutf8(extraLine) + 3;
    local numTotal = strlenutf8(body);
    local overflow;
    if numTotal + numRequired >= 255 then
        overflow = true;
        local pattern = "$";
        local n = 0;
        while n < numRequired do
            n = n + 1;
            pattern = "."..pattern;
        end
        body = gsub(body, pattern, extraLine);
    else
        overflow = false;
        body = body..extraLine;
    end
    return body, overflow
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
            local uiMapID = API.GetPlayerMap();
            if uiMapID == 2346 or uiMapID == 2374 or uiMapID == 2406 or uiMapID == 2407 or uiMapID == 2408 or uiMapID == 2409 or uiMapID == 2411 or uiMapID == 2428 then
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
            --return "/cast spell:460013\n/cast [noswimming] "..spellName
            return "/cast "..spellName
            --The first /cast doesn't get executed but it's necessary to make GetActionInfo() return the macroIndex instead of spellID
            --when applying [noswimming], the game will think the ZoneAbility isn't on the ActionBar and display the ZoneAbilityFrame
        end,

        trueReturn = {
            icon = 1408996,
        },

        falseReturn = {
            icon = 0,
            bestIconFunc = function(body)
                if find(body, "C_MountJournal.SummonByID(0)", 1, true) then
                    return 413588
                end
            end
        },
    };

    PlumberMacros["drawer"] = {
        name = L["PlumberMacro Drawer"],
        type = ModifyType.None,
        --alwaysUpdate = true,

        conditionFunc = function ()
            return true
        end,
    };
end

local IsMacroSpell = {};


local EL = CreateFrame("Frame");
EL.macroIndexMin1 = 1;
EL.macroIndexMax1 = MAX_ACCOUNT_MACROS or 120;
EL.macroIndexMin2 = EL.macroIndexMax1 + 1;
EL.macroIndexMax2 = EL.macroIndexMin2 + (MAX_CHARACTER_MACROS or 30);
EL.macroEvents = {};


function EL:CheckSupportedMacros()
    self:UnregisterAllEvents();

    if not self.isInitialized then
        self:RegisterEvent("PLAYER_ENTERING_WORLD");
    end

    for command, commandData in pairs(PlumberMacros) do
        commandData.currentState = nil;
    end

    self.macroEvents = {};
    self.activeCommands = {};
    MacroInterpreter.macroCommand = {};

    local body;
    local command;
    local n = 0;
    local numAccountMacros, numCharacterMacros = GetNumMacros();

    for i = 1, 2 do
        local fromIndex, toIndex;
        if i == 1 then
            fromIndex = self.macroIndexMin1;
            toIndex = fromIndex + numAccountMacros - 1;
        else
            fromIndex = self.macroIndexMin2;
            toIndex = fromIndex + numCharacterMacros - 1;
        end

        if toIndex >= fromIndex then
            for index = fromIndex, toIndex do
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

    DrawerUpdator:SetEnabled(self.activeCommands["drawer"] ~= nil);
end

function EL:RequestUpdateMacroByEvent(event)
    if not self.eventQueue then
        self.eventQueue = {};
    end
    self.t = -0.5;
    self.eventQueue[event] = true;
    if self:GetScript("OnUpdate") == nil then
        self:SetScript("OnUpdate", self.OnUpdate_UpdateMacroByEvent);
    end
end

function EL:OnUpdate_UpdateMacroByEvent(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0 then
        self.t = nil;
        self:SetScript("OnUpdate", nil);
        if self.eventQueue then
            local events = {};
            local n = 0;
            for event in pairs(self.eventQueue) do
                n = n + 1;
                events[n] = event;
            end
            self.eventQueue = nil;

            for _, event in ipairs(events) do
                if self.macroEvents[event] then
                    self:UpdateMacroByEvent(event);
                end
            end
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

local function GetBestDefaultIcon(body)
    if body then
        if find(body, "C_MountJournal.SummonByID(0)") then
            return 413588
        end
    end
end

function EL:UpdateMacros(commands)
    if self.anySupported then
        commands = commands or self.activeCommands;

        local inCombat = InCombatLockdown();
        local anyChange, newState, returns;
        local name, icon, body, anyEdit;
        local commandData;
        local prefix;

        local updateList = false;

        for command, list in pairs(commands) do
            commandData = PlumberMacros[command];
            newState = commandData.conditionFunc();
            if commandData.alwaysUpdate or newState ~= commandData.currentState then
                anyChange = true;
                if not inCombat then
                    commandData.currentState = newState;
                    returns = nil;
                    if newState then
                        returns = commandData.trueReturn;
                    else
                        returns = commandData.falseReturn;
                    end

                    for _, index in ipairs(list) do
                        name, icon, body = GetMacroInfo(index);

                        if command == match(body, "#plumber:(%w+)") then
                            anyEdit = false;

                            if returns and returns.icon then
                                if returns.icon ~= icon then
                                    anyEdit = true;
                                end
                                icon = returns.icon;
                                if icon == 0 then
                                    if returns.bestIconFunc then
                                        icon = returns.bestIconFunc(body);
                                    end
                                    icon = icon or 134400;
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
                                anyEdit = true;
                            end

                            if commandData.writeFunc then
                                local _body, _icon = commandData.writeFunc(body);
                                if _body then
                                    body = _body;
                                end
                                if _icon then
                                    icon = _icon;
                                end
                                anyEdit = true;
                            end

                            if anyEdit then
                                EditMacro(index, name, icon, body);
                            end
                        else
                            --This is when the body doesn't match our last cache
                            --Possibly due to macros update without using MacroFrame (using other macro addons)
                            updateList = true;
                        end
                    end
                end
            end
        end

        if anyChange and inCombat then
            self:RegisterEvent("PLAYER_REGEN_ENABLED");
        end

        if updateList then
            self:CheckSupportedMacros();
        end
    end
end


local DrawerUpdateFlag = {
    Combat = 0,
    Started = 1,
    Success = 2,
};
EL.drawerUpdateFlag = DrawerUpdateFlag.Combat;

function EL:InitializeDrawerInfo()
    self:CheckSupportedMacros();
    local drawers = self.activeCommands and self.activeCommands["drawer"];
    if drawers and #drawers > 0 then
        local name, icon, body;
        for _, macroIndex in ipairs(drawers) do
            name, icon, body = GetMacroInfo(macroIndex);
            MacroInterpreter:GetDrawerInfo(body);
        end
    end
end

function EL:UpdateDrawers()
    if InCombatLockdown() then
        self.drawerUpdateFlag = DrawerUpdateFlag.Combat;
        return
    end
    self.drawerUpdateFlag = DrawerUpdateFlag.Started;

    SecureSpellFlyout:ReleaseClickHandlers();
    local drawers = self.activeCommands and self.activeCommands["drawer"];
    if drawers and #drawers > 0 then
        local name, icon, body, drawerInfo, overflow, anyOverflow, anyChange;
        local handlerName;
        local checkUsability = true;
        local hideUnusable = HIDE_UNUSABLE;
        local alwaysShowConsumables = not UPDATE_FREQUENTLY;

        for _, macroIndex in ipairs(drawers) do
            name, icon, body = GetMacroInfo(macroIndex);
            drawerInfo = MacroInterpreter:GetDrawerInfo(body, checkUsability, hideUnusable, alwaysShowConsumables);
            if drawerInfo then
                handlerName = SecureSpellFlyout:AddActionsAndGetHandler(drawerInfo);
                if handlerName then
                    body, anyChange = SecureSpellFlyout:RemoveClickHandlerFromMacro(body);
                    local extraLine = "/click "..handlerName;
                    body, overflow = AddExtraLineToMacroBody(extraLine, body);
                    EditMacro(macroIndex, name, icon, body);
                    if overflow then
                        anyOverflow = true;
                    end
                end
            end
        end

        if anyOverflow then
            self:UpdateDrawers();
        end
    end

    self.drawerUpdateFlag = DrawerUpdateFlag.Success;
end

function EL:UpdateMacrosAndDrawers()
    if InCombatLockdown() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED");
        return
    end
    self:UnregisterEvent("PLAYER_REGEN_ENABLED");
    self:UpdateMacros();
end

function EL:OnUpdate_UpdateMacros(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0 then
        self.t = nil;
        self:SetScript("OnUpdate", nil);

        if self.macroCheckPending then
            self.macroCheckPending = nil;
            self:CheckSupportedMacros();
        end

        if self.macroUpdatePending then
            self.macroUpdatePending = nil;
            self:UpdateMacros();
        end

        if self.drawerUpdatePending then
            self.drawerUpdatePending = nil;
            DrawerUpdator:RequestUpdate(0);
        end
    end
end

function EL:RequestUpdateMacros(delay)
    delay = delay and -delay or 0;
    self.t = delay;
    self.macroCheckPending = true;
    self.macroUpdatePending = true;
    self.drawerUpdatePending = true;
    self:SetScript("OnUpdate", self.OnUpdate_UpdateMacros);
end

function EL:RequestCheckMacros(delay)
    delay = delay and -delay or 0;
    self.t = delay;
    self.macroCheckPending = true;
    self:SetScript("OnUpdate", self.OnUpdate_UpdateMacros);
end

function EL:LoadSpellAndItem()
    for _, commandData in pairs(PlumberMacros) do
        if commandData.spellID then
            RequestLoadSpellData(commandData.spellID);
            IsMacroSpell[commandData.spellID] = true;
        end
        if commandData.itemID then
            RequestLoadItemDataByID(commandData.itemID);
        end
    end
end


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

    function EditorUI:SearchInEditBoxForSupportedCommand(forceUpdate)
        if forceUpdate then
            self.args = {};
        end
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

    function EditorUI:GetCurrentMacroIndex()
        local selectedMacroIndex = MacroFrame:GetSelectedIndex();
        local actualIndex = MacroFrame:GetMacroDataIndex(selectedMacroIndex);
        return actualIndex
    end

    function EditorUI:SaveMacroBody(body)
        if not InCombatLockdown() then
            EditorUI.SourceEditBox:SetText(body);
            --MacroFrame:SaveMacro();
            EditMacro(self:GetCurrentMacroIndex(), nil, nil, body);
            EL:RequestUpdateMacros(0.0);
        end
    end

    function EditorUI:SetMacroIcon(icon)
        if not InCombatLockdown() then
            EditMacro(self:GetCurrentMacroIndex(), nil, icon);
            EL:RequestUpdateMacros(0.0);
        end
    end
end


local function CreateEditorUI(parent)
    if not parent then return end;

    local f = CreateFrame("Frame", nil, parent);
    API.Mixin(f, EditorUI);
    EditorUI = f;
    f:OnLoad();

    local ef = API.CreateNewSliceFrame(f, "RoughWideFrame");
    f.ExtraFrame = ef;
    ef:Hide();
    ef:SetScript("OnHide", function()
        ef:Hide();
        ef:UnregisterAllEvents();
    end);
    ef:SetScript("OnShow", function()
        ef:UpdatePixel();
    end);
    local offsetY = -4;
    ef:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, offsetY);
    ef:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, offsetY);
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
    f.MouseBlocker:Hide();

    f:SetFrameHeight(72);
    f:RequestSearchInEditBox();
end

local function RequestUpdateMacros()
    EL:RequestUpdateMacros();
end

local function CreateEditorUI_Blizzard()
    if MacroSaveButton then
        MacroSaveButton:HookScript("OnClick", RequestUpdateMacros);
    end

    if MacroFrameText and MacroFrameText:IsObjectType("EditBox") then
        EditorUI.SourceEditBox = MacroFrameText;
    end

    if DeleteMacro then
        hooksecurefunc("DeleteMacro", RequestUpdateMacros);
    end

    local frame = MacroFrame;
    if frame then
        CreateEditorUI(frame);

        --We can't use this because of securecall("MacroFrame_SaveMacro") in SECURE_ACTIONS.action
        --Interface/AddOns/Blizzard_FrameXML/Mainline/SecureTemplates.lua
        --[[
            if frame.SaveMacro then
                hooksecurefunc(frame, "SaveMacro", RequestUpdateMacros);
            end
        --]]

        if frame.SelectMacro then
            hooksecurefunc(frame, "SelectMacro", function()
                EL:RequestCheckMacros();
            end);
        end
    end
end

local function CreateEditorUI_MacroToolkit()
    --Note: MacroToolkit causes a breif fps drop when formatting our drawer commands with or without Plumber enabled.

    local SaveButton = MacroToolkitSave;
    if SaveButton then
        SaveButton:HookScript("OnClick", function()
            EL:RequestUpdateMacros();
        end);
    end

    if MacroToolkitText and MacroToolkitText:IsObjectType("EditBox") then
        EditorUI.SourceEditBox = MacroToolkitText;
    end

    EditorUI.macroFrameHooked = true;

    if MacroToolkitFrame then
        CreateEditorUI(MacroToolkitFrame);

        local pauseUpdate;

        local function UpdateMacroTooltipFrame()
            if not pauseUpdate then
                pauseUpdate = true;
                C_Timer.After(0.03, function()
                    pauseUpdate = nil;
                    if not InCombatLockdown() then
                        securecall(MacroToolkit.MacroFrameUpdate, MacroToolkit);
                    end
                end);
            end
        end

        function EditorUI:GetCurrentMacroIndex()
            return MacroToolkitFrame.selectedMacro
        end

        function EditorUI:SaveMacroBody(body)
            if not InCombatLockdown() then
                EditorUI.SourceEditBox:SetText(body);
                EditMacro(self:GetCurrentMacroIndex(), nil, nil, body);
                SaveButton:Click("LeftButton");
                EL:RequestUpdateMacros(0.0);
                UpdateMacroTooltipFrame();
            end
        end

        function EditorUI:SetMacroIcon(icon)
            if not InCombatLockdown() then
                EditMacro(self:GetCurrentMacroIndex(), nil, icon);
                SaveButton:Click("LeftButton");
                EL:RequestUpdateMacros(0.0);
                UpdateMacroTooltipFrame();
            end
        end
    end
end


if MacroFrame_LoadUI then
    --UPDATE_MACROS fires when selecting any macro, without changing its content, so we update our macro after MarcoFrame is closed
    hooksecurefunc("MacroFrame_LoadUI", function()
        if not EditorUI.macroFrameHooked then
            if MacroFrame then
                EditorUI.macroFrameHooked = true;
                CreateEditorUI_Blizzard();
            end
        end
    end);
end


function EL:OnEvent(event, ...)
    --print(event, GetTimePreciseSec())
    if event == "PLAYER_ENTERING_WORLD" then
        self.isInitialized = true;
        self:UnregisterEvent(event);
        self:LoadSpellAndItem();
        self:RequestUpdateMacros(0.5);
        DrawerUpdator:RequestUpdate(0.7);

        if C_AddOns.IsAddOnLoaded("MacroToolkit") then
            CreateEditorUI_MacroToolkit();
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:UpdateMacrosAndDrawers();
    elseif event == "UPDATE_MACROS" then
        --UPDATE_MACROS usually fires twice before PLAYER_ENTERING_WORLD
        self:UnregisterEvent(event);
        self:InitializeDrawerInfo();
    elseif self.macroEvents and self.macroEvents[event] then
        self:RequestUpdateMacroByEvent(event);
    end
end
EL:SetScript("OnEvent", EL.OnEvent);
EL:RegisterEvent("UPDATE_MACROS");
EL:RegisterEvent("PLAYER_ENTERING_WORLD");



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
                        --print(actionType, id, subType)
                        if actionType == "macro" then
                            if subType == "" then

                            elseif subType == "spell" and IsMacroSpell[id] then
                                local macroName = tooltipData.lines and tooltipData.lines[1]and tooltipData.lines[1].leftText;
                                id = macroName and GetMacroIndexByName(macroName);
                            else
                                return
                            end

                            if id then
                                self:TooltipSetMacro(tooltip, id);
                            end
                        end
                    end
                end
            end
            TooltipDataProcessor.AddTooltipPostCall(tooltipDataType, Callback);
        else
            print("Plumber AddOn Alert: WoW\'s TooltipDataProcessor methods changed.")
        end
    end

    function MacroInterpreter:GetDrawerInfo(body, checkUsability, hideUnusable, alwaysShowConsumables)
        if not body then return end;
        if not find(body, "#plumber:drawer") then return end;

        local tbl;
        local n = 0;
        local processed, usable;
        local name, icon, actionType, id, macroText, craftingQuality, tempID;
        local canPerform, isConsumable;

        for line in gmatch(body, "#(/[^\n]+)") do
            processed = false;
            usable = nil;
            name = nil;
            icon = nil;
            actionType = nil;
            id = nil;
            macroText = nil;
            tempID = nil;

            if not processed then
                tempID = match(line, "/use%s+mount:(%d+)");
                if not tempID then
                    tempID = match(line, "/cast%s+mount:(%d+)");
                end
                if tempID then
                    processed = true;
                    actionType = "mount";
                    id = tonumber(tempID);
                end
            end

            if not processed then
                tempID = match(line, "/sp%s+pet:(%d+)");
                if tempID then
                    processed = true;
                    actionType = "SetSummonPet";
                    id = tonumber(tempID);
                    name, usable = API.GetPetNameAndUsability(id, true);
                    id = name;
                    if name then
                        macroText = "/sp "..name;
                    end
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

            if not processed then
                local professionIndex = match(line, "/prof(%d)");
                if professionIndex then
                    processed = true;
                    professionIndex = tonumber(professionIndex);
                    if professionIndex == 1 or professionIndex == 2 then
                        local info = API.GetProfessionSpellInfo(professionIndex);
                        if info then
                            icon = info.texture;
                            name = info.name;
                            id = info.spellID;
                            actionType = "profession";
                            macroText = format("/run PlumberGlobals.OpenProfessionFrame(%s)", professionIndex);
                            usable = true;
                        else
                            icon = 134400;
                            name = professionIndex == 1 and L["Drawer Add Profession1"] or L["Drawer Add Profession2"];
                            id = -1;
                            actionType = "profession";
                            macroText = "";
                            usable = false;
                        end
                    end
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
                    if id and CanPlayerPerformAction(actionType, id) then
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
                    if id == 0 then --RandomFavoriteMount
                        local _spellID = 150544;
                        name = L["Random Favorite Mount"];
                        icon = GetSpellTexture(_spellID);
                        macroText = "/run C_MountJournal.SummonByID(0)";
                        id = _spellID;
                    else
                        local  _name, _spellID, _icon, _isActive, _isUsable, _sourceType, _isFavorite, _isFactionSpecific, _faction, _shouldHideOnChar, _isCollected = GetMountInfoByID(id);
                        icon = _icon;
                        usable = _isCollected;
                        name = _name;
                        macroText = _name and gsub(line, "mount:%d+", _name) or line;
                        actionType = "spell";
                        id = _spellID;
                    end
                elseif actionType == "profession" then
                    
                else
                    name = name or line;
                    macroText = macroText or line;
                    usable = true;
                end

                if checkUsability and id and (usable == nil) then
                    canPerform, isConsumable = CanPlayerPerformAction(actionType, id);
                    if canPerform then
                        usable = true;
                    elseif isConsumable and alwaysShowConsumables then
                        usable = true;
                    end
                end

                if hideUnusable and not usable then
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

        return tbl or {}
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
    EditorSetup.iconButtonContainerHeight = 72;

    function EditorSetup.AcquireIconButton()
        if not EditorUI.objectPools.iconButtonPool then
            EditorUI.objectPools.iconButtonPool = {};

            local file = "Interface/AddOns/Plumber/Art/Frame/MacroForge.png";

            local IconButtonMixin = {};

            local Placeholder = CreateFrame("Frame", nil, EditorSetup.IconButtonContainer);
            Placeholder:Hide();
            Placeholder:SetSize(32, 32);
            Placeholder.Border = Placeholder:CreateTexture(nil, "OVERLAY");
            Placeholder.Border:SetPoint("CENTER", Placeholder, "CENTER", 0, 0);
            Placeholder.Border:SetTexCoord(272/512, 344/512, 72/512, 144/512);
            Placeholder.Border:SetTexture(file);
            Placeholder.Icon = Placeholder:CreateTexture(nil, "OVERLAY");
            EditorUI:AddRemovableElements(Placeholder);
            API.DisableSharpening(Placeholder.Border);

            local ReorderController = API.CreateDragReorderController(EditorSetup.IconButtonContainer);
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
                if self.IconOverlay then
                    self.IconOverlay:SetSize(w * 36/64, w * 36/64);
                end
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

                    if InCombatLockdown() then
                        tooltip:AddLine(L["PlumberMacro Error EditMacroInCombat"], 1, 0.1, 0.1, true);
                    else
                        tooltip:AddLine("<"..L["Click To Set Macro Icon"]..">", 0.1, 1, 0.1, true);
                        tooltip:AddLine("<"..L["Drag To Reorder"]..">", 0.1, 1, 0.1, true);
                    end

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
                    if InCombatLockdown() then return end;

                    GameTooltip:Hide();

                    if IsControlKeyDown() then
                        EditorUI:SetMacroIcon(self.Icon:GetTexture());
                        return
                    end

                    ReorderController:SetDraggedObject(self);
                    ReorderController:PreDragStart();
                    EditorUI:RaiseIconButtonLevel(self);
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
                local f = CreateFrame("Button", nil, EditorSetup.IconButtonFrame, "PlumberSmallIconButtonTemplate");

                f.Border:SetTexture(file);
                f.Border:SetTexCoord(272/512, 344/512, 0, 72/512);
                API.DisableSharpening(f.Border);

                f.IconOverlay = f:CreateTexture(nil, "OVERLAY");
                f.IconOverlay:SetPoint("BOTTOMRIGHT", f, "CENTER", 0 ,0);
                f.IconOverlay:Hide();
                f.IconOverlay:SetTexture("Interface/AddOns/Plumber/Art/Frame/SpellFlyout");

                API.Mixin(f, IconButtonMixin);
                f:OnLoad();
                f:SetEffectiveSize(EditorSetup.itemButtonSize);

                return f
            end
            EditorUI.objectPools.iconButtonPool = API.CreateObjectPool(CreateObject);
        end
        return EditorUI.objectPools.iconButtonPool:Acquire();
    end

    function EditorSetup.AcquireCheckbox()
        if not EditorUI.objectPools.checkboxPool then
            local function CreateCheckbox()
                return addon.CreateCheckbox(EditorUI.ExtraFrame);
            end
            EditorUI.objectPools.checkboxPool = API.CreateObjectPool(CreateCheckbox);
        end
        return EditorUI.objectPools.checkboxPool:Acquire();
    end

    local SupportedCursorInfo = {
        item = {
            command = "/use",
            argGetter = function(itemID, itemLink)
                local name = GetItemNameByID(itemID);
                return name, (itemID and "item:"..itemID) or nil
            end,
        },

        spell = {
            command = "/cast",
            argGetter = function(spellIndex, bookType, spellID, baseSpellID)
                local name = GetSpellName(spellID);
                local info;
                for i = 1, 2 do
                    info = API.GetProfessionSpellInfo(i);
                    if info and (spellID == info.spellID or baseSpellID == info.spellID) then
                        if i == 1 then
                            return L["Drawer Add Profession1"], nil, "/prof1"
                        else
                            return L["Drawer Add Profession2"], nil, "/prof2"
                        end
                    end
                end
                return name, (spellID and "spell:"..spellID) or nil
            end,
        },

        battlepet = {
            command = "/sp",
            argGetter = function(petGUID)
                local speciesID, customName, level, xp, maxXp, displayID, favorite, speciesName = C_PetJournal.GetPetInfoByPetID(petGUID);
                return speciesName, (speciesID and "pet:"..speciesID) or nil
            end,
        },

        mount = {
            command = "/use",
            argGetter = function(mountID, mountIndex)
                if mountID > 9999 then
                    --the exact id for RandomFavoriteMount is (2^28 - 1)
                    local name = GetSpellName(150544);
                    return name, "mount:0"
                end
                local name = GetMountInfoByID(mountID);
                return name, (mountID and "mount:"..mountID) or nil
            end,
        },


        --Classic
        --GetCompanionInfo seems to be broken
        --[[
        companion = {
            command = "/use",
            argGetter = function(index, companionType)
                if companionType == "MOUNT" then
                    local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID = C_MountJournal.GetDisplayedMountInfo(index);
                    return name, (mountID and "mount:"..mountID) or nil
                elseif companionType == "CRITTER" then
                    local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName = C_PetJournal.GetPetInfoByIndex(index);
                    return speciesName, (speciesID and "pet:"..speciesID) or nil
                end
            end,
        },
        --]]
    };

    function EditorSetup.DrawerOnEvent(self, event, ...)
        if event == "CURSOR_CHANGED" then
            local infoType, arg1, arg2, arg3, arg4 = GetCursorInfo();

            if infoType then
                EditorSetup.ReceptorFrame:Show();
                EditorSetup.IconButtonFrame:Hide();
                EditorUI.Note:Hide();
                local receptor = EditorSetup.ReceptorFrame;
                local info = SupportedCursorInfo[infoType];
                local inCombat = InCombatLockdown();

                if (not inCombat) and info and (arg1 ~= nil) then
                    receptor.PlusSign:Show();
                    receptor.Instruction:Hide();
                    local name, commandArg, overrideCommand = info.argGetter(arg1, arg2, arg3, arg4);
                    local newCommand;
                    if overrideCommand then
                        newCommand = "#"..overrideCommand;
                    else
                        newCommand = commandArg and format("#%s %s", info.command, commandArg) or nil;
                    end
                    name = name or "Unknown";

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

                        if newCommand then
                            local body = EditorUI.SourceEditBox:GetText();
                            body = body.."\n"..newCommand;
                            EditorUI:SaveMacroBody(body);
                        end

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
                    if inCombat then
                        receptor.Instruction:SetText(L["PlumberMacro Error EditMacroInCombat"]);
                        receptor.Instruction:SetTextColor(1, 0.1, 0.1);
                    else
                        receptor.Instruction:SetText(format(L["Unsupported Action Type Format"], infoType));
                        receptor.Instruction:SetTextColor(0.6, 0.6, 0.6);
                    end
                    receptor:SetScript("OnEnter", nil);
                    receptor:SetScript("OnLeave", nil);
                    receptor:SetScript("OnClick", nil);
                    receptor:SetScript("OnReceiveDrag", nil);
                end
            else
                EditorSetup.ReceptorFrame:Hide();
                EditorSetup.IconButtonFrame:Show();
                EditorUI.Note:Show();
            end
        end
    end

    function EditorSetup.DrawerInitFrames()
        if not EditorSetup.IconButtonContainer then
            local MainFrame = EditorUI.ExtraFrame;

            local IconButtonContainer = CreateFrame("Frame", nil, MainFrame);
            EditorSetup.IconButtonContainer = IconButtonContainer;
            IconButtonContainer:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 0, 0);
            IconButtonContainer:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", 0, 0);
            IconButtonContainer:SetHeight(EditorSetup.iconButtonContainerHeight);

            if not EditorSetup.IconButtonFrame then
                local f = CreateFrame("Frame", nil, IconButtonContainer);
                EditorSetup.IconButtonFrame = f;
                f:SetPoint("TOPLEFT", IconButtonContainer, "TOPLEFT", 0, 0);
                f:SetPoint("BOTTOMRIGHT", IconButtonContainer, "BOTTOMRIGHT", 0, 0);
            end

            if not EditorSetup.ReceptorFrame then
                local f = CreateFrame("Button", nil, IconButtonContainer);
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
    end

    EditorSetup.drawerOptions = {
        {label = L["Drawer Option CloseAfterClick"], dbKey = "SpellFlyout_CloseAfterClick", tooltip = L["Drawer Option CloseAfterClick Tooltip"], tooltip2 = L["Drawer Option Global Tooltip"]},
        {label = L["Drawer Option SingleRow"], dbKey = "SpellFlyout_SingleRow", tooltip = L["Drawer Option SingleRow Tooltip"], tooltip2 = L["Drawer Option Global Tooltip"]},
        {label = L["Drawer Option Hide Unusable"], dbKey = "SpellFlyout_HideUnusable", tooltip = L["Drawer Option Hide Unusable Tooltip"],
            tooltip2 = function()
                if GetDBValue("SpellFlyout_UpdateFrequently") then
                    return L["Drawer Option Global Tooltip"]
                else
                    return L["Drawer Option Hide Unusable Tooltip 2"].."\n\n"..L["Drawer Option Global Tooltip"]
                end
            end,
            onClickFunc = function()
                local forceUpdate = true;
                EditorUI:SearchInEditBoxForSupportedCommand(forceUpdate);
            end,
        },
        {label = L["Drawer Option Update Frequently"], dbKey = "SpellFlyout_UpdateFrequently", tooltip = L["Drawer Option Update Frequently Tooltip"], tooltip2 = L["Drawer Option Global Tooltip"], requiredDBValues = { SpellFlyout_HideUnusable = true }},
    };

    function EditorSetup.Drawer(body)
        EditorSetup.DrawerInitFrames();
        EditorSetup.ReceptorFrame:Hide();
        EditorSetup.IconButtonFrame:Show();

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
                local parent = EditorUI:GetParent();
                local container = EditorSetup.IconButtonFrame;
                local size = EditorSetup.itemButtonSize;
                local gap = EditorSetup.itemButtonGap;
                local frameWidth = 338; --parent:GetWidth()
                local span = #drawerInfo * (size + gap) - gap;
                local requiredWidth = span + 48;
                if requiredWidth > frameWidth then
                    frameWidth = requiredWidth;
                end
                local fromX = 0.5*(frameWidth - span);
                local button;
                local baseFrameLevel = container:GetFrameLevel();

                for i, info in ipairs(drawerInfo) do
                    button = EditorSetup.AcquireIconButton();
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

                local visualOffsetY = 4;
                local padding = 8;
                local checkboxBaseOffsetX = 24;
                local extraHeight = padding - visualOffsetY;
                local checkbox;
                local valid;
                for _, info in ipairs(EditorSetup.drawerOptions) do
                    valid = true;
                    if info.requiredDBValues then
                        for dbKey, value in pairs(info.requiredDBValues) do
                            if GetDBValue(dbKey) ~= value then
                                valid = false;
                                break
                            end
                        end
                        fromX = checkboxBaseOffsetX + 20;
                    else
                        fromX = checkboxBaseOffsetX;
                    end

                    if valid then
                        checkbox = EditorSetup.AcquireCheckbox();
                        checkbox:SetData(info);
                        checkbox:SetChecked(GetDBValue(checkbox.dbKey));
                        checkbox:SetPoint("TOPLEFT", EditorSetup.IconButtonFrame, "BOTTOMLEFT", fromX, -extraHeight);
                        extraHeight = extraHeight + checkbox:GetHeight();
                    end
                end
                extraHeight = extraHeight + padding + visualOffsetY;
                EditorUI.ExtraFrame:SetHeight(EditorSetup.iconButtonContainerHeight + extraHeight);

                local Divider = EditorUI.Divider;
                if not Divider then
                    Divider = EditorUI.ExtraFrame:CreateTexture(nil, "OVERLAY");
                    EditorUI.Divider = Divider;
                    EditorUI:AddRemovableElements(Divider);
                    Divider:SetHeight(2);
                    Divider:SetVertexColor(1, 1, 1, 0.4);
                    Divider:SetTexture("Interface/AddOns/Plumber/Art/Frame/MacroForge.png");
                    Divider:SetTexCoord(64/512, 264/512, 72/512, 76/512)
                end
                Divider:SetPoint("CENTER", EditorUI.ExtraFrame, "TOP", 0, -EditorSetup.iconButtonContainerHeight + visualOffsetY);
                Divider:SetWidth(frameWidth - 24);
                Divider:Show();
            end
        else
            EditorUI:ReleaseElements();
            EditorUI:DisplayNote(L["Drag And Drop Item Here"]);
            EditorUI.ExtraFrame:SetHeight(EditorSetup.iconButtonContainerHeight);
        end
        EditorUI.args.drawerInfo = drawerInfo;
        EditorUI.ExtraFrame:RegisterEvent("CURSOR_CHANGED");
        EditorUI.ExtraFrame:SetScript("OnEvent", EditorSetup.DrawerOnEvent);
    end
    PlumberMacros["drawer"].editorSetupFunc = EditorSetup.Drawer;
end


do  --DrawerUpdator
    local UpdateEvents_Constant = {
        ["ACTIVE_TALENT_GROUP_CHANGED"] = true,
        ["NEW_TOY_ADDED"] = true,
        ["NEW_PET_ADDED"] = true,
        ["NEW_MOUNT_ADDED"] = true,
        ["SKILL_LINES_CHANGED"] = true,
    };

    local UpdateEvents_Lazy = {
        ["SPELLS_CHANGED"] = true,
        ["BAG_UPDATE_DELAYED"] = true,
        ["TRAIT_CONFIG_UPDATED"] = true,
    };

    function DrawerUpdator:SetEnabled(state)
        self.enabled = state;
        if state then
            for event in pairs(UpdateEvents_Constant) do
                self:RegisterEvent(event);
            end
            self:SetScript("OnEvent", self.OnEvent);

            if UPDATE_FREQUENTLY then
                self:EnableAdditionalChecks(true);
            else
                self:EnableAdditionalChecks(false);
            end
        else
            for event in pairs(UpdateEvents_Constant) do
                self:UnregisterEvent(event);
            end
            self:EnableAdditionalChecks(false);
        end
    end

    function DrawerUpdator:EnableAdditionalChecks(state)
        if not self.enabled then return end;

        if state then
            for event in pairs(UpdateEvents_Lazy) do
                self:RegisterEvent(event);
            end
        else
            for event in pairs(UpdateEvents_Lazy) do
                self:UnregisterEvent(event);
            end
        end
    end

    function DrawerUpdator:OnEvent(event, ...)
        if UpdateEvents_Constant[event] then
            if not self.drawerDirty then
                self.drawerDirty = true;
                self:RequestUpdate();
            end
        elseif UpdateEvents_Lazy[event] then
            if not self.drawerDirty then
                self.drawerDirty = true;
                self:RequestUpdate();
            end
        elseif event == "PLAYER_REGEN_ENABLED" then
            self:UnregisterEvent(event);
            if self.drawerDirty then
                self:UpdateDrawers();
            end
        end
    end

    function DrawerUpdator:RequestUpdate(delay)
        self.drawerDirty = true;
        delay = delay or 0.2;
        self.t = -delay;
        if InCombatLockdown() then
            self:SetScript("OnUpdate", nil);
            self:RegisterEvent("PLAYER_REGEN_ENABLED");
        else
            self:SetScript("OnUpdate", self.OnUpdate);
        end
    end

    function DrawerUpdator:UpdateIfDirty()
        if self.drawerDirty then
            if not InCombatLockdown() then
                self:UpdateDrawers();
            end
        end
    end

    function DrawerUpdator:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            if InCombatLockdown() then
                self:RequestUpdate();
            else
                self:UpdateDrawers();
            end
        end
    end

    function DrawerUpdator:UpdateDrawers()
        self.drawerDirty = false;
        EL:UpdateDrawers();
        SecureSpellFlyout:Close();
        --print("DRAWER UPDATED")
    end
end


do  --Settings Registry
    local function UpdateAfterSettingsChanged()
        EL:RequestUpdateMacros(0.0);
    end

    CallbackRegistry:RegisterSettingCallback("SpellFlyout_CloseAfterClick", function(state, userInput)
        if userInput then
            UpdateAfterSettingsChanged();
        end
    end);

    CallbackRegistry:RegisterSettingCallback("SpellFlyout_SingleRow", function(state, userInput)
        if userInput then
            UpdateAfterSettingsChanged();
        end
    end);

    CallbackRegistry:RegisterSettingCallback("SpellFlyout_HideUnusable", function(state, userInput)
        HIDE_UNUSABLE = state;
        if userInput then
            UpdateAfterSettingsChanged();
        end
    end);

    CallbackRegistry:RegisterSettingCallback("SpellFlyout_UpdateFrequently", function(state, userInput)
        UPDATE_FREQUENTLY = state;
        DrawerUpdator:EnableAdditionalChecks(state);
        if userInput then
            UpdateAfterSettingsChanged();
        end
    end);
end


do  --For other modules like Legion Remix
    local function AddPlumberMacro(commandInfo)
        local command = commandInfo.command;
        local type = commandInfo.modifyType and ModifyType[commandInfo.modifyType];
        if not PlumberMacros[command] then
            PlumberMacros[command] = commandInfo;
        end
    end
    addon.AddPlumberMacro = AddPlumberMacro;
end