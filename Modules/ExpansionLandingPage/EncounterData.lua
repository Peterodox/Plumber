local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;


local ipairs = ipairs;
local IsEncounterComplete = C_RaidLocks.IsEncounterComplete;


local EncounterData = {
    --[journalEncounterID] = {}

    --Liberation of Undermine
    [2639] = {icon = 6392628, achv = {41229, 41208}},      --Vexie and the Geargrinders
    [2640] = {icon = 6253176, achv = {41230, 41554, 41694, 41695}},      --Cauldron of Carnage
    [2641] = {icon = 6392625, achv = {41231, 41338}},      --Rik Reverb
    [2642] = {icon = 6392627, achv = {41232, 41596}},      --Stix Bunkjunker
    [2653] = {icon = 6392626, achv = {41233, 41711}},      --Sprocketmonger Lockenstock (Should be 2643, right Blizzard?)
    [2644] = {icon = 6392624, achv = {41234, 41119, 41120, 41121, 41122}},      --The One-Armed Bandit
    [2645] = {icon = 6392623, achv = {41235, 41337, 41211}},      --Mug'Zee, Heads of Security
    [2646] = {icon = 6392621, achv = {41228, 41236, 41347}},      --Chrome King Gallywix

    --Nerub-ar Palace
    [2599] = {icon = 5779389, achv = {40238, 40255}},      --Sikran, Captain of the Sureki
    [2601] = {icon = 5779388, achv = {40241, 40264}},      --Nexus-Princess Ky'veza
    [2602] = {icon = 5779391, achv = {40243, 40266}},      --Queen Ansurek
    [2607] = {icon = 5779390, achv = {40236, 40261}},      --Ulgrax the Devourer
    [2608] = {icon = 5779387, achv = {40242, 40730}},      --The Silken Court
    [2609] = {icon = 5661707, achv = {40239, 40262}},      --Rasha'nan
    [2611] = {icon = 5779386, achv = {40237, 40260}},      --The Bloodbound Horror
    [2612] = {icon = 5688871, achv = {40240, 40263}},      --Broodtwister Ovi'nax
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

function LandingPageUtil.GetEncounterAchievements(journalEncounterID)
    if EncounterData[journalEncounterID] then
        return EncounterData[journalEncounterID].achv
    end
end


function LandingPageUtil.GetEncounterProgress(dungeonAreaMapID, journalEncounterID)
    local progress = {};

    for i, difficultyID in ipairs(Difficulties) do
        progress[i] = IsEncounterComplete(dungeonAreaMapID, journalEncounterID, difficultyID);
        if i == 1 then
            if journalEncounterID >= 2639 then    --debug
                progress[i] = true;
            end
        end
    end

    return progress
end