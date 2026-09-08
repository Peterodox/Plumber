local _, addon = ...


local RaidCheck = {};
addon.RaidCheck = RaidCheck;


local DataProvider = {};
RaidCheck.DataProvider = DataProvider;


local GetDungeonDifficultyID = GetDungeonDifficultyID;
local GetRaidDifficultyID = GetRaidDifficultyID;
local GetLegacyRaidDifficultyID = GetLegacyRaidDifficultyID;


function DataProvider:GetDungeonDifficultyID()
	return GetDungeonDifficultyID()
end

function DataProvider:GetRaidDifficultyID()
	return GetRaidDifficultyID(), GetLegacyRaidDifficultyID()
end

-- Some difficulty can only be selected via Blizzard's DifficultyPicker
-- Such as "World" for Lair "The Tidebound Grotto"
function DataProvider:IsDiffultySelectable(difficultyID)
	return difficultyID and difficultyID ~= 250; -- DifficultyUtil.ID.RaidWorld
end
