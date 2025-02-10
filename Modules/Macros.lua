-- Conditionally modify macros
-- Applications:
-- 1. Mounts: G-99 Breakneck, Undermine. Change the icon, summon the car.

local _, addon = ...
local L = addon.L;
local API = addon.API;

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
            return nil
        end,
    };
end


local EL = CreateFrame("Frame");

EL.macroIndexMin = 1;
EL.macroIndexMax = 138;


function EL:CheckSupportedMacros()
    self:UnregisterAllEvents();
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
        local anyChange, newState, payload;
        local name, icon, body;
        local commandData;
        local prefix;

        for command, list in pairs(commands) do
            newState = PlumberMacros[command].conditionFunc();
            if newState ~= PlumberMacros[command].currentState then
                anyChange = true;
                if not inCombat then
                    PlumberMacros[command].currentState = newState;
                    commandData = PlumberMacros[command]
                    if newState then
                        payload = commandData.trueReturn;
                    else
                        payload = commandData.falseReturn;
                    end

                    for _, index in ipairs(list) do
                        name, icon, body = GetMacroInfo(index);
                        if payload.icon then
                            icon = payload.icon;
                            if icon == 0 then
                                icon = 134400;
                            end
                        end

                        if commandData.type == ModifyType.Add then
                            prefix = "#plumber:"..command;
                            body = gsub(body, ".+##", "");
                            body = gsub(body, prefix, "");
                            while find(body, "^\n") do
                                body = gsub(body, "^\n", "");
                            end
                            if newState then
                                body = prefix.."\n/cast G-99 Breakneck\n##\n"..body;
                            else
                                body = prefix.."\n"..body;
                            end
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
        self:CheckSupportedMacros();
        self:UpdateMacros();
        self:UnregisterEvent(event);
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:CheckQueue();
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
                        if actionType == "macro" then
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
    
    function MacroInterpreter.drawer(tooltip, body)
        for line in string.gmatch(body, "#(/[^\n]+)") do
            local processed = false;
            local usable = false;
            local text;
            local spellID = match(line, "/cast%s+spell:(%d+)");
            if spellID then
                processed = true;
                text = C_Spell.GetSpellName(tonumber(spellID));
                if IsPlayerSpell(spellID) then
                    usable = true;
                end
            end

            if not processed then
                local spellName = match(line, "/cast%s+(.+)");
                if spellName then
                    text = spellName;
                    if C_Spell.GetSpellInfo(spellName) ~= nil then
                        usable = true;
                    end
                end
            end

            if text then
                if usable then
                    tooltip:AddLine(text, 1, 0.82, 0);
                else
                    tooltip:AddLine(text, 1, 0.282, 0);
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
    local focus = API.GetMouseFocus();
    if focus and focus.bindingAction and focus.action then
        local actionType, id, subType = GetActionInfo(focus.action);
        if actionType == "macro" then
            local body = GetMacroBody(id);
            if body and find(body, "#plumber:drawer") then

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