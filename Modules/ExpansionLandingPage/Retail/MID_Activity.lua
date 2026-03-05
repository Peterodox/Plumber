local _, addon = ...
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;
local ActivityUtil = addon.ActivityUtil;


local ActivityData = {  --Constant
    --questClassification: 5 is recurring

    --[[
    {isHeader = true, name = "Delves", localizedName = DELVES_LABEL, categoryID = 10000,
        entries = {
            {name = "The Key to Success", questID = 84370, isWeeklyQuest = true, accountwide = true},
            {name = "Delver\'s Bounty", itemID = 233071, flagQuest = 86371, icon = 1064187, conditions = ActivityUtil.Conditions.DelversBounty},

            {name = "Coffer Keys", label = L["Restored Coffer Key"], questClassification = 5, tooltipSetter = ActivityUtil.TooltipFuncs.WeeklyRestoredCofferKey, icon = 4622270, useItemIcon = true,
                children = ActivityUtil.CreateChildrenFromQuestList(addon.WeeklyRewardsConstant.CofferKeyFlags),
            },

            {name = "Coffer Key Shards", label = L["Coffer Key Shard"], questClassification = 5, tooltipSetter = ActivityUtil.TooltipFuncs.WeeklyCofferKeyShard, icon = 133016, useItemIcon = true,
                children = ActivityUtil.CreateChildrenFromQuestList(addon.WeeklyRewardsConstant.CofferKeyShardFlags),
            },
        }
    },
    --]]

    {isHeader = true, name = "Silvermoon Court", factionID = 2710, categoryID = 2710, uiMapID = 2395,
        entries = {
            {name = "Fortify the Runestones: Magisters", questID = 90573, isWeeklyQuest = true, uiMapID = 2395, sortToTop = true},
            {name = "Fortify the Runestones: Blood Knights", questID = 90574, isWeeklyQuest = true, uiMapID = 2395, sortToTop = true},
            {name = "Fortify the Runestones: Farstriders", questID = 90575, isWeeklyQuest = true, uiMapID = 2395, sortToTop = true},
            {name = "Fortify the Runestones: Shades of the Row", questID = 90576, isWeeklyQuest = true, uiMapID = 2395, sortToTop = true},
            --{name = "Weekly Delve", localizedName = L["Bountiful Delve"], isDelveReputation = true, flagQuest = 83317, accountwide = true},
        },
        questLines = {
            5841,
        },
    },
};

LandingPageUtil.AddExpansionData(12, "activity", ActivityData);


local DynamicQuestMaps = {
    [2393] = "map2393",     --Silvermoon
    [2395] = 2710,
};
LandingPageUtil.AddExpansionData(12, "activityQuestMap", DynamicQuestMaps);
