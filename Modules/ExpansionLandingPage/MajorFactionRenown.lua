local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;

local GetRenownLevels = C_MajorFactions.GetRenownRewardsForLevel;
local GetRenownRewardsForLevel = C_MajorFactions.GetRenownRewardsForLevel;

local function SetMajorFaction(factionID)
    local renownLevelsInfo = GetRenownLevels(factionID);
    for i, levelInfo in ipairs(renownLevelsInfo) do
        levelInfo.rewardInfo = GetRenownRewardsForLevel(factionID, i);
    end
    local maxLevel = renownLevelsInfo[#renownLevelsInfo].level;
end

