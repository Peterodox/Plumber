local _, addon = ...

--[[
    Quest Indicator for Nameplates
    Shows a quest icon on nameplates for units that are quest targets
    
    Credits: Quest function adapted from TPTP (Threat Plates)
--]]

local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;
local GetNamePlates = C_NamePlate.GetNamePlates;
local IsInInstance = IsInInstance;
local UnitGUID = UnitGUID;
local UnitName = UnitName;


--Quest Objective Parser by Locale
local QUEST_OBJECTIVE_PARSER_LEFT = function(text)
    local current, goal, objective_name = string.match(text, "^(%d+)/(%d+)( .*)$")
    return objective_name, current, goal
end

local QUEST_OBJECTIVE_PARSER_RIGHT = function(text)
    return string.match(text, "^(.*: )(%d+)/(%d+)$")
end

local PARSER_QUEST_OBJECTIVE_BACKUP = function(text)
    local current, goal, objective_name = string.match(text, "^(%d+)/(%d+)( .*)$")

    if not objective_name then
        objective_name, current, goal = string.match(text, "^(.*: )(%d+)/(%d+)$")
    end

    return objective_name, current, goal
end

local STANDARD_QUEST_OBJECTIVE_PARSER = {
    -- x/y Objective
    enUS = QUEST_OBJECTIVE_PARSER_LEFT,
    esMX = QUEST_OBJECTIVE_PARSER_LEFT,
    ptBR = QUEST_OBJECTIVE_PARSER_LEFT,
    itIT = QUEST_OBJECTIVE_PARSER_LEFT,
    koKR = QUEST_OBJECTIVE_PARSER_LEFT,
    zhTW = QUEST_OBJECTIVE_PARSER_LEFT,
    zhCN = QUEST_OBJECTIVE_PARSER_LEFT,

    -- Objective: x/y
    deDE = QUEST_OBJECTIVE_PARSER_RIGHT,
    frFR = QUEST_OBJECTIVE_PARSER_RIGHT,
    esES = QUEST_OBJECTIVE_PARSER_RIGHT,
    ruRU = QUEST_OBJECTIVE_PARSER_RIGHT
}

local QuestObjectiveParser = STANDARD_QUEST_OBJECTIVE_PARSER[GetLocale()] or PARSER_QUEST_OBJECTIVE_BACKUP


--Tooltip for reading quest data
local TooltipFrame = CreateFrame("GameTooltip", "PlumberQuestIndicator_Tooltip", nil, "GameTooltipTemplate")
local PlayerName = UnitName("player")


local function IsQuestUnit(unit)
    if not unit then
        return false
    end

    local unitGUID = UnitGUID(unit)
    if not unitGUID then
        return false
    end

    local quest_title
    local quest_player = true

    -- Read quest information from tooltip
    TooltipFrame:SetOwner(WorldFrame, "ANCHOR_NONE")
    TooltipFrame:SetHyperlink("unit:" .. unitGUID)

    for i = 3, TooltipFrame:NumLines() do
        local line = _G["PlumberQuestIndicator_TooltipTextLeft" .. i]
        if not line then break end
        
        local text = line:GetText()
        if not text then break end
        
        local text_r, text_g, text_b = line:GetTextColor()

        if text_r > 0.99 and text_g > 0.81 and text_b == 0 then
            -- A line with this color is either the quest title or a player name
            if quest_title then
                quest_player = (text == PlayerName)
            else
                quest_title = text
            end
        elseif quest_title and quest_player then
            local objective_name, current, goal
            local objective_type = nil

            quest_title = false

            -- Check if area / progress quest
            if string.find(text, "%%") then
                objective_name, current, goal = string.match(text, "^(.*) %(?(%d+)%%%)?$")
                objective_type = "area"
            else
                -- Standard x/y type quest
                objective_name, current, goal = QuestObjectiveParser(text)
            end

            if objective_name then
                current = tonumber(current)

                if objective_type then
                    goal = 100
                else
                    goal = tonumber(goal)
                end

                if current and goal then
                    if (current ~= goal) then
                        return true
                    end
                else
                    return false
                end
            end
        end
    end

    return false
end


local function UpdateQuestIndicator(unitFrame)
    if not unitFrame or not unitFrame.unit then
        return
    end

    -- Initialize quest indicator if it doesn't exist
    if not unitFrame.PlumberQuestIndicator then
        unitFrame.PlumberQuestIndicator = unitFrame:CreateTexture(nil, "OVERLAY")
        unitFrame.PlumberQuestIndicator:SetAtlas("smallquestbang")
        unitFrame.PlumberQuestIndicator:SetSize(22, 22)
    end

    -- Anchor to healthBar if it exists, otherwise to frame
    local anchorFrame = unitFrame.healthBar or unitFrame.health or unitFrame
    unitFrame.PlumberQuestIndicator:ClearAllPoints()
    unitFrame.PlumberQuestIndicator:SetPoint("CENTER", anchorFrame, "RIGHT", 8, 0)

    if not IsInInstance() and IsQuestUnit(unitFrame.unit) then
        unitFrame.PlumberQuestIndicator:Show()
    else
        unitFrame.PlumberQuestIndicator:Hide()
    end
end


local function UpdateAllNameplates()
    local nameplates = GetNamePlates()
    for _, nameplate in ipairs(nameplates) do
        if nameplate.UnitFrame then
            UpdateQuestIndicator(nameplate.UnitFrame)
        end
    end
end


local function HideAllIndicators()
    local nameplates = GetNamePlates()
    for _, nameplate in ipairs(nameplates) do
        if nameplate.UnitFrame and nameplate.UnitFrame.PlumberQuestIndicator then
            nameplate.UnitFrame.PlumberQuestIndicator:Hide()
        end
    end
end


local EL = CreateFrame("Frame")


function EL:OnEvent(event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local unit = ...
        local nameplate = GetNamePlateForUnit(unit)
        if nameplate and nameplate.UnitFrame then
            UpdateQuestIndicator(nameplate.UnitFrame)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if self.enabled then
            UpdateAllNameplates()
        end
    elseif event == "UNIT_QUEST_LOG_CHANGED" then
        if self.enabled and not IsInInstance() then
            UpdateAllNameplates()
        end
    end
end


function EL:EnableModule(state)
    if state then
        self.enabled = true
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
        self:SetScript("OnEvent", self.OnEvent)
        UpdateAllNameplates()
    elseif self.enabled then
        self.enabled = nil
        self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        self:UnregisterEvent("UNIT_QUEST_LOG_CHANGED")
        self:SetScript("OnEvent", nil)
        HideAllIndicators()
    end
end


do
    local moduleData = {
        name = addon.L["ModuleName NameplateQuestIndicator"],
        dbKey = "NameplateQuestIndicator",
        description = addon.L["ModuleDescription NameplateQuestIndicator"],
        toggleFunc = function(state)
            EL:EnableModule(state)
        end,
        categoryID = 2,     -- NPC Interaction
        uiOrder = 11,
        moduleAddedTime = 1737504000,   -- January 22, 2025
        categoryKeys = {
            "UnitFrame",
        },
    }

    addon.ControlCenter:AddModule(moduleData)
end
