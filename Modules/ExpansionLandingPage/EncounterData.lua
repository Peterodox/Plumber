local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;


local ipairs = ipairs;
local IsEncounterComplete = C_RaidLocks.IsEncounterComplete;


local EncounterData = {
    --[journalEncounterID] = {}

    --Liberation of Undermine
    [2639] = {icon = 6392628},      --Vexie and the Geargrinders
    [2640] = {icon = 6253176},      --Cauldron of Carnage
    [2641] = {icon = 6392625},      --Rik Reverb
    [2642] = {icon = 6392627},      --Stix Bunkjunker
    [2653] = {icon = 6392626},      --Sprocketmonger Lockenstock (Should be 2643, right Blizzard?)
    [2644] = {icon = 6392624},      --The One-Armed Bandit
    [2645] = {icon = 6392623},      --Mug'Zee, Heads of Security
    [2646] = {icon = 6392621},      --Chrome King Gallywix

    --Nerub-ar Palace
    [2599] = {icon = 5779389},      --Sikran, Captain of the Sureki
    [2601] = {icon = 5779388},      --Nexus-Princess Ky'veza
    [2602] = {icon = 5779391},      --Queen Ansurek
    [2607] = {icon = 5779390},      --Ulgrax the Devourer
    [2608] = {icon = 5779387},      --The Silken Court
    [2609] = {icon = 5661707},      --Rasha'nan
    [2611] = {icon = 5779386},      --The Bloodbound Horror
    [2612] = {icon = 5688871},      --Broodtwister Ovi'nax
};


local Difficulties = {
    DifficultyUtil.ID.PrimaryRaidLFR,
	DifficultyUtil.ID.PrimaryRaidNormal,
	DifficultyUtil.ID.PrimaryRaidHeroic,
	DifficultyUtil.ID.PrimaryRaidMythic,
};


function LandingPageUtil.GetEncounterIcon(journalEncounterID)
    if EncounterData[journalEncounterID] then
        return EncounterData[journalEncounterID].icon
    end
end


function LandingPageUtil.GetEncounterProgress(dungeonAreaMapID, journalEncounterID)
    local progress = {};

    for i, difficultyID in ipairs(Difficulties) do
        progress[i] = IsEncounterComplete(dungeonAreaMapID, journalEncounterID, difficultyID);
    end

    return progress
end