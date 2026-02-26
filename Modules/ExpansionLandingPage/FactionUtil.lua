local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;

local FactionUtil = {};
addon.FactionUtil = FactionUtil;


local GetFactionDataByID = C_Reputation.GetFactionDataByID;


local OverrideFactionInfo = {
    --rewardQuestID: find ParagonFactionID in https://wago.tools/db2/Faction then https://wago.tools/db2/ParagonReputation

    ---- MID ----
    [2710] = {  --Silvermoon Court
        barColor = {206/255, 164/255, 56/255},
        rewardQuestID = 0,
    },

    [2711] = {  --Magisters
        barColor = {155/255, 173/255, 204/255},
        rewardQuestID = 0,
    },

    [2712] = {  --Blood Knights
        barColor = {206/255, 159/255, 159/255},
        rewardQuestID = 0,
    },

    [2713] = {  --Farstriders
        barColor = {145/255, 181/255, 128/255},
        rewardQuestID = 0,
    },

    [2714] = {  --Shades of the Row
        barColor = {206/255, 164/255, 56/255},
        rewardQuestID = 0,
    },

    [2696] = {  --Amani
        barColor = {206/255, 162/255, 123/255},
        rewardQuestID = 0,
    },

    [2704] = {  --Hara'ti
        barColor = {254/255, 132/255, 97/255},
        rewardQuestID = 0,
    },

    [2699] = {  --Singularity
        barColor = {159/255, 169/255, 222/255},
        rewardQuestID = 0,
    },

    [2764] = {  --Prey S1
        barColor = {246/255, 138/255, 162/255},
    },

    [2742] = {  --Delves S1
        barColor = {215/255, 160/255, 65/255},
    },

    [2744] = {  --Valeera Sanguinar
        barColor = {242/255, 141/255, 152/255},
    },


    ---- TWW ----
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


do  --Layout MID
    local MajorFactionLayout = {
        [1] = {
            {factionID = 2764},     --Prey S1
            {factionID = 2742,      --Delves S1
                subFactions = {
                    {factionID = 2744, creatureDisplayID = 26365, playerCompanionID = 2},     --Valeera Sanguinar. Get playerCompanionID from C_MajorFactions.GetMajorFactionData(C_DelvesUI.GetDelvesFactionForSeason())
                },
            },
        },

        [2] = {
            {factionID = 2696},     --Amani Tribe
            {factionID = 2699},     --The Singularity
            {factionID = 2704},     --Hara'ti
            {factionID = 2710,      --Silvermoon Court
                subFactions = { --See weekly quest https://www.wowhead.com/beta/quest=91629/high-esteem
                    {factionID = 2711, creatureDisplayID = 69626},     --Magisters Esara Verrinde
                    {factionID = 2712, creatureDisplayID = 113966},     --Blood Knights Knight-Lord Dranarus
                    {factionID = 2713, creatureDisplayID = 140633},     --Farstriders Captain Helios
                    {factionID = 2714, creatureDisplayID = 140691},     --Shades of the Row Darkdealer Thelis
                },
            },
        },
    };

    LandingPageUtil.AddExpansionData(12, "factionLayout", MajorFactionLayout);

    if addon.IsToCVersionEqualOrNewerThan(120000) then  --For PTR

    end
end


do  --Layout TWW
    local MajorFactionLayout = {
        --[row] = {},
        [1] = {
            {factionID = 2736},     --Manaforge Vandals
            {factionID = 2658},     --The K'aresh Trust
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

    FactionUtil.ActiveFactionLayout = MajorFactionLayout;
    LandingPageUtil.AddExpansionData(11, "factionLayout", MajorFactionLayout);
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

function FactionUtil:GetFactionsWithRewardPending(viewedExpansionOnly)
    local tbl;
    local IsOnQuest = C_QuestLog.IsOnQuest;

    if viewedExpansionOnly then
        if self.ActiveFactionLayout then
            local questID;
            for row, rowInfo in ipairs(self.ActiveFactionLayout) do
                for _, factionInfo in ipairs(rowInfo) do
                    if OverrideFactionInfo[factionInfo.factionID] then
                        questID = OverrideFactionInfo[factionInfo.factionID].rewardQuestID;
                        if questID and IsOnQuest(questID) then
                            if not tbl then
                                tbl = {};
                            end
                            table.insert(tbl, factionInfo.factionID);
                        end
                    end
                end
            end
        end
    else
        for questID, factionID in pairs(RewardQuestXFaction) do
            if IsOnQuest(questID) then
                if not tbl then
                    tbl = {};
                end
                table.insert(tbl, factionID);
            end
        end
    end

    return tbl
end

function FactionUtil:IsAnyParagonRewardPending(viewedExpansionOnly)
    return self:GetFactionsWithRewardPending(viewedExpansionOnly) ~= nil
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
