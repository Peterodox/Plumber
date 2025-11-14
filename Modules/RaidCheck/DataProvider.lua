local _, addon = ...
local API = addon.API;


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