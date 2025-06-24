local _, addon = ...
local L = addon.L;
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;


local ipairs = ipairs;
local EJ_SelectInstance = EJ_SelectInstance;
local EJ_SelectEncounter = EJ_SelectEncounter;
local EJ_IsValidInstanceDifficulty = EJ_IsValidInstanceDifficulty;


local EL = CreateFrame("Frame");

function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0 then
        self.t = nil;
        self:SetScript("OnUpdate", nil);
        if self.callback then
            self.callback();
            self.callback = nil;
        end
    end
end


local function NullifyEJEvents()
    --Pause default EncounterJournal updating
    local f = EncounterJournal;
    if f then
        f:UnregisterEvent("EJ_LOOT_DATA_RECIEVED");
        f:UnregisterEvent("EJ_DIFFICULTY_UPDATE");

        EL.callback = function()
            f:RegisterEvent("EJ_LOOT_DATA_RECIEVED");
            f:RegisterEvent("EJ_DIFFICULTY_UPDATE");
        end;

        EL.t = 0;
        EL:SetScript("OnUpdate", EL.OnUpdate);
    end
end

local function SelectInstanceAndEncounter(journalInstanceID, journalEncounterID)
    NullifyEJEvents();
    EJ_SelectInstance(journalInstanceID);
    if journalEncounterID then
        EJ_SelectEncounter(journalEncounterID);
    end
end
API.SelectInstanceAndEncounter = SelectInstanceAndEncounter;


do  --Derivative of Blizzard_EncounterJournal.lua
    local DifficultyUtil = DifficultyUtil;

    local EJ_DIFFICULTIES = {
        DifficultyUtil.ID.DungeonNormal,
        DifficultyUtil.ID.DungeonHeroic,
        DifficultyUtil.ID.DungeonMythic,
        DifficultyUtil.ID.DungeonChallenge,
        DifficultyUtil.ID.DungeonTimewalker,
        DifficultyUtil.ID.RaidLFR,
        DifficultyUtil.ID.Raid10Normal,
        DifficultyUtil.ID.Raid10Heroic,
        DifficultyUtil.ID.Raid25Normal,
        DifficultyUtil.ID.Raid25Heroic,
        DifficultyUtil.ID.PrimaryRaidLFR,
        DifficultyUtil.ID.PrimaryRaidNormal,
        DifficultyUtil.ID.PrimaryRaidHeroic,
        DifficultyUtil.ID.PrimaryRaidMythic,
        DifficultyUtil.ID.RaidTimewalker,
        DifficultyUtil.ID.Raid40,
    };

    local ALL_DIFFICULTY_ID = -1;   --If so, track all available difficulties


    local function GetEJDifficultySize(difficultyID)
        if difficultyID ~= DifficultyUtil.ID.RaidTimewalker and not DifficultyUtil.IsPrimaryRaid(difficultyID) then
            return DifficultyUtil.GetMaxPlayers(difficultyID);
        end
        return nil;
    end

    local function GetEJDifficultyString(difficultyID)
        if difficultyID == ALL_DIFFICULTY_ID then
            return L["All Difficulties"];
        end

        local name = DifficultyUtil.GetDifficultyName(difficultyID);
        local size = GetEJDifficultySize(difficultyID);
        if size then
            return string.format(ENCOUNTER_JOURNAL_DIFF_TEXT, size, name);
        else
            return name;
        end
    end
    API.GetRaidDifficultyString = GetEJDifficultyString;


    local function GetValidDifficulties(instanceID, encounterID, showAllDifficulties)
        local n = 0;
        local tbl = {};
        SelectInstanceAndEncounter(instanceID, encounterID);

        for index, difficultyID in ipairs(EJ_DIFFICULTIES) do
            if EJ_IsValidInstanceDifficulty(difficultyID) then
                local text = GetEJDifficultyString(difficultyID);
                n = n + 1;
                tbl[n] = {
                    difficultyID = difficultyID,
                    text = text,
                };
            end
        end

        if n > 0 then
            if showAllDifficulties then
                n = n + 1;
                tbl[n] = {
                    difficultyID = ALL_DIFFICULTY_ID;
                    text = GetEJDifficultyString(ALL_DIFFICULTY_ID);
                }
            end
            return tbl
        end
    end

    local function GetValidDifficultiesForEncounter(instanceID, encounterID, showAllDifficulties)
        return GetValidDifficulties(instanceID, encounterID, showAllDifficulties)
    end
    API.GetValidDifficultiesForEncounter = GetValidDifficultiesForEncounter;

    local function GetValidDifficultiesForInstance(instanceID, showAllDifficulties)
        return GetValidDifficulties(instanceID, nil, showAllDifficulties)
    end
    API.GetValidDifficultiesForInstance = GetValidDifficultiesForInstance;


    local function IsDifficultyValidForEncounter(instanceID, encounterID, difficultyID)
        local difficulties = instanceID and GetValidDifficultiesForEncounter(instanceID, encounterID);
        local valid, bestDifficultyID;
        if difficulties then
            if difficultyID == ALL_DIFFICULTY_ID then
                valid = true;
                bestDifficultyID = ALL_DIFFICULTY_ID;
            else
                if difficultyID then
                    for k, v in ipairs(difficulties) do
                        if v.difficultyID == difficultyID then
                            valid = true;
                            bestDifficultyID = difficultyID;
                            break;
                        end
                    end
                end
                if not bestDifficultyID then
                    bestDifficultyID = difficulties[#difficulties].difficultyID;
                end
            end
        end
        return valid, bestDifficultyID
    end
    API.IsDifficultyValidForEncounter = IsDifficultyValidForEncounter;

    local function IsDifficultyValidForInstance(instanceID, difficultyID)
        local difficulties = instanceID and GetValidDifficultiesForInstance(instanceID);
        local valid, bestDifficultyID;
        if difficulties then
            if difficultyID == ALL_DIFFICULTY_ID then
                valid = true;
                bestDifficultyID = ALL_DIFFICULTY_ID;
            else
                if difficultyID then
                    for k, v in ipairs(difficulties) do
                        if v.difficultyID == difficultyID then
                            valid = true;
                            bestDifficultyID = difficultyID;
                            break;
                        end
                    end
                end
                if not bestDifficultyID then
                    bestDifficultyID = difficulties[#difficulties].difficultyID;
                end
            end
        end
        return valid, bestDifficultyID
    end
    API.IsDifficultyValidForInstance = IsDifficultyValidForInstance;
end