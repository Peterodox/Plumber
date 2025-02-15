-- Conditionally modify macros
-- Make a Plumber Macro by adding #plumber:[command] to the top of the macro body
-- Implementations:
-- 1. plumber:drawer        Create a custom SpellFlyout by adding # to your regular macro. E.g. #/use:Dalaran Hearthsone
-- 2. plumber:drive         Added to your regular mount macro. Summon G-99 Breakneck in Undermine. Change the icon.


local _, addon = ...
local L = addon.L;
local API = addon.API;
local SpellFlyout = addon.SpellFlyout;

local find = string.find;
local match = string.match;
local gsub = string.gsub;
local tinsert = table.insert;
local ipairs = ipairs;
local InCombatLockdown = InCombatLockdown;
local GetMacroBody = GetMacroBody;
local GetMacroInfo = GetMacroInfo;
local EditMacro = EditMacro;
local GetActiveAbilities = C_ZoneAbility.GetActiveAbilities;
local FindSpellOverrideByID = FindSpellOverrideByID;
local GetActionInfo = GetActionInfo;

local MacroInterpreter = {};   --Add info to tooltip

local ModifyType = {
    None = 0,
    Add = 1,
    Overwrite = 2,
};

local SlashCmd = {};
SlashCmd.DrawerMacro = API.GetSlashSubcommand("DrawerMacro");


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
            local spellName = (C_Spell.GetSpellName(PlumberMacros["drive"].spellID)) or "G-99 Breakneck";
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

        initFunc = function(body)
            if not find(body, SlashCmd.DrawerMacro) then
                local extraLine = "\n"..SlashCmd.DrawerMacro;
                local numRequired = strlenutf8(extraLine) + 1;
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
            end
            return body
        end,
    };
end


local EL = CreateFrame("Frame");

EL.macroIndexMin = 1;
EL.macroIndexMax = 138;


function EL:CheckSupportedMacros()
    self:UnregisterAllEvents();
    if not EL.macroFrameHooked then
        self:RegisterEvent("UPDATE_MACROS");
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
    end
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
            C_Spell.RequestLoadSpellData(commandData.spellID);
        end
        if commandData.itemID then
            C_Item.RequestLoadItemDataByID(commandData.itemID);
        end
    end
end

function EL:ListenEvents(state)
    if state then
        self:RegisterEvent("PLAYER_ENTERING_WORLD");
        self:RegisterEvent("UPDATE_MACROS");
    else
        self:UnregisterAllEvents();
    end
end
EL:ListenEvents(true);

function EL:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent(event);
        self:LoadSpellAndItem();
        self:RequestUpdateMacros(0.5);
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:CheckQueue();
    elseif event == "UPDATE_MACROS" then
        --self:RequestUpdateMacros();   --this event fires when selecting any macro, without changing its content, so we update our macro after MarcoFrame is closed
        if not self.macroFrameHooked then
            if MacroFrame then
                self.macroFrameHooked = true;
                self:UnregisterEvent(event);
                MacroFrame:HookScript("OnHide", function()
                    self:RequestUpdateMacros();
                end);
                if MacroSaveButton then
                    MacroSaveButton:HookScript("OnClick", function()
                        self:RequestUpdateMacros();
                    end);
                end
            end
        end
    elseif self.macroEvents and self.macroEvents[event] then
        self:UpdateMacroByEvent(event);
    end
end
EL:SetScript("OnEvent", EL.OnEvent);


do  --MacroInterpreter
    MacroInterpreter.macroCommand = {};

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

    function MacroInterpreter:GetDrawerInfo(body)
        local tbl;
        local n = 0;
        local processed, usable;
        local name, icon, actionType, id, macroText;

        for line in string.gmatch(body, "#(/[^\n]+)") do
            processed = false;
            usable = false;
            actionType = nil;
            id = nil;
            icon = nil;
            macroText = nil;

            if not processed then
                id = match(line, "/cast%s+spell:(%d+)");
                id = tonumber(id);
                if id then
                    processed = true;
                    actionType = "spell";
                    name = C_Spell.GetSpellName(tonumber(id));
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

            if actionType then
                if actionType == "spell" then
                    if (not id) and name then
                        local spellInfo = C_Spell.GetSpellInfo(name);
                        if spellInfo then
                            usable = true;
                            id = spellInfo.spellID;
                            icon = spellInfo.iconID;
                        end
                    end
                    if not icon then
                        icon = C_Spell.GetSpellTexture(id);
                    end
                    if id and IsPlayerSpell(id) then
                        usable = true;
                    end
                    if name then
                        macroText = "/cast "..name;
                    end
                elseif actionType == "item" then
                    if (not id) and name then
                        id = C_Item.GetItemIDForItemInfo(name);
                    end
                    if id and API.DoesItemReallyExist(id) then
                        name = C_Item.GetItemNameByID(id);
                        icon = C_Item.GetItemIconByID(id);
                        usable = true;
                    end
                    if name then
                        macroText = "/use "..name;
                    end
                end

                if id then
                    if not tbl then
                        tbl = {};
                    end
                    n = n + 1;
                    tbl[n] = {
                        text = name,
                        icon = icon,
                        actionType = actionType,
                        id = id,
                        usable = usable,
                        macroText = macroText,
                    };
                end
            end
        end

        return tbl
    end

    function MacroInterpreter.drawer(tooltip, body)
        local drawerInfo = MacroInterpreter:GetDrawerInfo(body);
        if drawerInfo then
            if InCombatLockdown() then
                tooltip:AddLine(L["PlumberMacro Error Combat"], 1, 0.1, 0.1);
            end

            for _, info in ipairs(drawerInfo) do
                if info.text then
                    if info.usable then
                        tooltip:AddLine(info.text, 1, 0.82, 0);
                    else
                        tooltip:AddLine(info.text, 0.6, 0.6, 0.6);
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


local function SlashFunc_DrawerMacro()
    --if InCombatLockdown() then return end;

    local focus = API.GetMouseFocus();
    if focus and focus.bindingAction and focus.action and type(focus.action) == "number" then
        local actionType, id, subType = GetActionInfo(focus.action);
        if actionType == "macro" then
            local body = GetMacroBody(id);
            if body and find(body, "#plumber:drawer") then
                if SpellFlyout.flyoutID == id then
                    SpellFlyout:Hide();
                    return
                end

                local drawerInfo = MacroInterpreter:GetDrawerInfo(body);
                SpellFlyout.flyoutID = id;
                SpellFlyout:SetActions(drawerInfo);
                SpellFlyout:SetOwner(focus);
                SpellFlyout:SetScale(focus:GetParent():GetScale());
                SpellFlyout:ClearAllPoints();

                local direction = focus.bar and focus.bar.flyoutDirection or "UP";
                if direction == "LEFT" then
                    local _, y = focus:GetCenter();
                    local left = focus:GetLeft();
                    SpellFlyout:SetPoint("RIGHT", UIParent, "BOTTOMLEFT", left - 4, y);
                    SpellFlyout:SetArrowDirection("right");
                elseif direction == "RIGHT" then
                    local _, y = focus:GetCenter();
                    local right = focus:GetRight();
                    SpellFlyout:SetPoint("LEFT", UIParent, "BOTTOMLEFT", right + 4, y);
                    SpellFlyout:SetArrowDirection("left");
                elseif direction == "DOWN" then
                    local top = focus:GetBottom();
                    local left = focus:GetLeft();
                    SpellFlyout:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left - 2, top - 4);
                    SpellFlyout:SetArrowDirection("up");
                else --UP
                    local top = focus:GetTop();
                    local left = focus:GetLeft();
                    SpellFlyout:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left - 2, top + 4);
                    SpellFlyout:SetArrowDirection("down");
                end

                SpellFlyout:Show();

                --[[
                if drawerInfo then
                    for _, info in ipairs(drawerInfo) do
                        print(string.format("|T%s:16:16|t %s", info.icon, info.text));
                    end
                end
                --]]
            end
        end
    end
end
API.AddSlashSubcommand("DrawerMacro", SlashFunc_DrawerMacro);

--[[
    GetActionText(actionSlot)   for Macros

    --ActionBarButton
    /dump GetMouseFoci()[1].buttonType
    /dump GetMouseFoci()[1]:GetAttribute("flyoutDirection")
    /dump GetMouseFoci()[1].action
--]]