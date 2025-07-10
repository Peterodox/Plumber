local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;

local FactionUtil = {};
addon.FactionUtil = FactionUtil;


local GetFactionDataByID = C_Reputation.GetFactionDataByID;


local OverrideFactionInfo = {
    --rewardQuestID: find ParagonFactionID in https://wago.tools/db2/Faction then https://wago.tools/db2/ParagonReputation

    [2570] = {  --Hallowfall Arathi
        barColor = {244/255, 186/255, 130/255},
        rewardQuestID = 79218,
    },

    [2590] = {  --Council of Dornogal
        barColor = {56/255, 184/255, 255/255},
        rewardQuestID = 79219,
    },

    [2594] = {  --The Assembly of the Deeps
        barColor = {254/255, 137/255, 97/255},
        rewardQuestID = 79220,
    },

    [2600] = {  --The Severed Threads
        barColor = {251/255, 137/255, 119/255},
        rewardQuestID = 79196,
    },

        [2601] = {  --The Weaver 
            rewardQuestID = 83738,
        },

        [2605] = {  --The General
            rewardQuestID = 83739,
        },

        [2607] = {  --The Vizier 
            rewardQuestID = 83740,
        },

    [2653] = {  --The Cartels of Undermine
        barColor = {252/255, 138/255, 103/255},
        rewardQuestID = 85805,
    },

        [2669] = {  --Darkfuse Solutions
            rewardQuestID = 85808,
        },

        [2673] = {  --Bilgewater Cartel
            rewardQuestID = 85806,
        },

        [2677] = {  --Steamwheedle Cartel
            rewardQuestID = 85809,
        },

        [2675] = {  --Blackwater Cartel 
            rewardQuestID = 85807,
        },

        [2671] = {  --Venture Co.
            rewardQuestID = 85810,
        },

    [2685] = {  --Gallagio Loyalty Rewards Club
        barColor = {163/255, 178/255, 104/255},
        rewardQuestID = 85471,
    },

    [2688] = {  --Flame's Radiance
        barColor = {178/255, 171/255, 135/255},
        rewardQuestID = 89515,
    },

    [2658] = {  --The K'aresh Trust
        barColor = {173/255, 152/255, 255/255},
        rewardQuestID = 85109,
    },

    [2736] = {  --Manaforge Vandals
        barColor = {197/255, 142/255, 255/255},
        --rewardQuestID = 85109,
    },
};

local MajorFactionLayout = {
    --[row] = {},
    [1] = {
        {factionID = 2688},     --Flame's Radiance
    },

    [2] = {
        {factionID = 2685},     --Gallagio Loyalty Rewards Club
        {factionID = 2653,      --Cartels of Undermine
            subFactions = {
                {factionID = 2669, iconFileID = 6439629, criteria = function() return C_QuestLog.IsQuestFlaggedCompletedOnAccount(86961) end}, --Darkfuse Solutions unlocked after completed "Diversified Investments"
                {factionID = 2673, iconFileID = 6439627},     --Bilgewater Cartel
                {factionID = 2677, iconFileID = 6439630},     --Steamwheedle Cartel
                {factionID = 2675, iconFileID = 6439628},     --Blackwater Cartel
                {factionID = 2671, iconFileID = 6439631},     --Venture Co.
            },
        },
    },

    [3] = {
        {factionID = 2590},     --Council of Dornogal
        {factionID = 2594},     --The Assembly of the Deeps
        {factionID = 2570},     --Hallowfall Arathi
        {factionID = 2600,      --Severed Threads
            subFactions = {
                {factionID = 2601, creatureDisplayID = 116208},     --Weaver
                {factionID = 2605, creatureDisplayID = 114775},     --General Anub'azal
                {factionID = 2607, creatureDisplayID = 114268},     --Vizier
            },
        },
    },
};
FactionUtil.MajorFactionLayout = MajorFactionLayout;


if addon.IsToCVersionEqualOrNewerThan(110200) then  --debug
    table.insert(MajorFactionLayout[1], 1, {factionID = 2658});     --The K'aresh Trust
    table.insert(MajorFactionLayout[1], 1, {factionID = 2736});     --Manaforge Vandals
end


local RewardQuestXFaction = {};
for factionID, v in pairs(OverrideFactionInfo) do
    if v.rewardQuestID then
        RewardQuestXFaction[v.rewardQuestID] = factionID;
    end
end


function FactionUtil:GetProgressBarColor(factionID, subFactionID)
    local color;

    if OverrideFactionInfo[factionID] and OverrideFactionInfo[factionID].barColor then
        color = OverrideFactionInfo[factionID].barColor
    elseif subFactionID and OverrideFactionInfo[subFactionID] and OverrideFactionInfo[subFactionID].barColor then
        color = OverrideFactionInfo[subFactionID].barColor
    end

    if color then
        return color[1], color[2], color[3]
    else
        return 0.8, 0.8, 0.8
    end
end

function FactionUtil:IsFactionWatched(factionID)
    local factionData = GetFactionDataByID(factionID);
    return factionData and factionData.isWatched
end

function FactionUtil:GetFactionsWithRewardPending()
    local tbl;
    local IsOnQuest = C_QuestLog.IsOnQuest;

    for questID, factionID in pairs(RewardQuestXFaction) do
        if IsOnQuest(questID) then
            if not tbl then
                tbl = {};
            end
            table.insert(tbl, factionID);
        end
    end

    return tbl
end

function FactionUtil:IsAnyParagonRewardPending()
    return self:GetFactionsWithRewardPending() ~= nil
end

function FactionUtil:GetParagonRewardQuestFaction(questID)
    return questID and RewardQuestXFaction[questID] or nil
end

function FactionUtil:IsParagonRewardQuest(questID)
    return self:GetParagonRewardQuestFaction(questID) ~= nil
end

function FactionUtil:GetFactionName(factionID)
    if not (OverrideFactionInfo[factionID] and OverrideFactionInfo[factionID].name) then
        local factionData = GetFactionDataByID(factionID);
        if factionData then
            if not OverrideFactionInfo[factionID] then
                OverrideFactionInfo[factionID] = {};
            end
            OverrideFactionInfo[factionID].name = factionData.name;
        end
    end
    return OverrideFactionInfo[factionID].name
end