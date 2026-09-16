local _, addon = ...
local L = addon.L;
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;


local ipairs = ipairs;
local EJ_SelectInstance = EJ_SelectInstance;
local EJ_SelectEncounter = EJ_SelectEncounter;
local EJ_IsValidInstanceDifficulty = EJ_IsValidInstanceDifficulty;
local EJ_GetInstanceInfo = EJ_GetInstanceInfo;
local EJ_SetDifficulty = EJ_SetDifficulty;
local EJ_GetEncounterInfoByIndex = EJ_GetEncounterInfoByIndex;
local IsLegacyDifficulty = IsLegacyDifficulty;


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

local function IsValidDifficulty(difficultyID)
	return difficultyID and EJ_IsValidInstanceDifficulty(difficultyID) and C_EncounterJournal.InstanceHasDifficultyID(difficultyID);
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
		DifficultyUtil.ID.RaidWorld,
		DifficultyUtil.ID.PrimaryRaidLFR,
		DifficultyUtil.ID.PrimaryRaidNormal,
		DifficultyUtil.ID.PrimaryRaidHeroic,
		DifficultyUtil.ID.PrimaryRaidMythic,
		DifficultyUtil.ID.RaidTimewalker,
		DifficultyUtil.ID.Raid40,
	};

	local VALID_DIFFUICULTY_OPEN_WORLD = {
		DifficultyUtil.ID.DungeonNormal,
		DifficultyUtil.ID.DungeonHeroic,
		DifficultyUtil.ID.DungeonMythic,
		DifficultyUtil.ID.Raid10Normal,
		DifficultyUtil.ID.Raid10Heroic,
		DifficultyUtil.ID.Raid25Normal,
		DifficultyUtil.ID.Raid25Heroic,
		DifficultyUtil.ID.RaidWorld,
		DifficultyUtil.ID.PrimaryRaidNormal,
		DifficultyUtil.ID.PrimaryRaidHeroic,
		DifficultyUtil.ID.PrimaryRaidMythic,
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
		if size and difficultyID ~= DifficultyUtil.ID.RaidWorld then
			return string.format(ENCOUNTER_JOURNAL_DIFF_TEXT, size, name);
		else
			return name;
		end
	end
	API.GetRaidDifficultyString = GetEJDifficultyString;

	---Get a list of valid difficulties for an instance
	---@param difficultyPool table The difficulties to iterate
	---@param journalInstanceID number journalInstanceID
	---@param encounterID number? If not nil, return the valid difficulties for a specific encounter
	---@param showAllDifficulties boolean? If true, Show an "All Difficulties" as an entry.
	local function GetValidDifficulties(difficultyPool, journalInstanceID, encounterID, showAllDifficulties)
		-- A derivative of "EncounterJournal_SetupDifficultyDropdown"
		-- Interface/AddOns/Blizzard_EncounterJournal/Mainline/Blizzard_EncounterJournal.lua

		SelectInstanceAndEncounter(journalInstanceID, encounterID);

		local n = 0;
		local difficulties = {};

		local function AddDifficulty(difficultyID)
			n = n + 1;
			difficulties[n] = {
				difficultyID = difficultyID,
				text = GetEJDifficultyString(difficultyID),
				isLegacy = IsLegacyDifficulty(difficultyID),
			};
		end

		local difficultiesOverridden = {};
		for index, difficultyID in ipairs(difficultyPool) do
			if EJ_IsValidInstanceDifficulty(difficultyID) then
				local baseDifficultyID = C_EncounterJournal.GetBaseDifficultyID(difficultyID);
				if (baseDifficultyID ~= difficultyID) and EJ_IsValidInstanceDifficulty(baseDifficultyID) then
					-- This difficulty has a base so we will skip it in the loop below regardless.
					difficultiesOverridden[difficultyID] = true;

					if C_EncounterJournal.InstanceHasDifficultyID(difficultyID) then
						AddDifficulty(difficultyID);
						difficultiesOverridden[baseDifficultyID] = true;
					end
				end
			end
		end

		-- Add all regular difficulties that didn't have a base or were not the base of one already overridden.
		for index, difficultyID in ipairs(difficultyPool) do
			if EJ_IsValidInstanceDifficulty(difficultyID) and not difficultiesOverridden[difficultyID] then
				AddDifficulty(difficultyID);
			end
		end

		if n > 0 then
			if showAllDifficulties then
				AddDifficulty(ALL_DIFFICULTY_ID);
			end
		end

		return difficulties;
	end

	local function GetValidDifficultiesForEncounter(instanceID, encounterID, showAllDifficulties)
		return GetValidDifficulties(EJ_DIFFICULTIES, instanceID, encounterID, showAllDifficulties)
	end
	API.GetValidDifficultiesForEncounter = GetValidDifficultiesForEncounter;

	local function GetValidDifficultiesForInstance(instanceID, showAllDifficulties)
		return GetValidDifficulties(EJ_DIFFICULTIES, instanceID, nil, showAllDifficulties)
	end
	API.GetValidDifficultiesForInstance = GetValidDifficultiesForInstance;

	function API.GetInstanceInfoForSelector(journalInstanceID)
		--For Instance Difficulty Selector
		local tbl = {};

		local instanceName, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, shouldDisplayDifficulty, mapID, covenantID, isRaid = EJ_GetInstanceInfo(journalInstanceID);
		tbl.name = instanceName;
		tbl.isRaid = isRaid;
		tbl.instanceID = mapID;

		tbl.difficulties = GetValidDifficulties(VALID_DIFFUICULTY_OPEN_WORLD, journalInstanceID);

		for _, v in ipairs(tbl.difficulties) do
			if v.isLegacy then
				tbl.isLegacyRaid = true;
				break;
			end
		end

		return tbl;
	end

	function API.GetInstanceEncounters(journalInstanceID, difficultyID)
		EJ_SetDifficulty(difficultyID);

		local encounters = {};
		local i = 1;
		local bossName, description, journalEncounterID, _, _, _, dungeonEncounterID = EJ_GetEncounterInfoByIndex(i, journalInstanceID);    --No dungeonEncounterID in Classic

		while journalEncounterID do
			if not dungeonEncounterID then
				dungeonEncounterID = LandingPageUtil.GetDungeonEncounteID(journalEncounterID);
			end

			encounters[i] = {
				name = bossName,
				id = journalEncounterID,
				dungeonEncounterID = dungeonEncounterID,
				difficultyID = difficultyID,
			};
			i = i + 1;
			bossName, description, journalEncounterID, _, _, _, dungeonEncounterID = EJ_GetEncounterInfoByIndex(i, journalInstanceID);
		end

		return encounters
	end

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
