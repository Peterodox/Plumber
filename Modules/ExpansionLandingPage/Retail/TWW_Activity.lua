local _, addon = ...
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;
local ActivityUtil = addon.ActivityUtil;


local ActivityData = {  --Constant
    --questClassification: 5 is recurring

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

    {isHeader = true, name = "K\'aresh", factionID = 2658, categoryID = 2658, uiMapID = 2371, --areaID = 15792 (Oasis)
        entries = {
            {name = "More Than Just a Phase", questID = 91093, isWeeklyQuest = true, uiMapID = 2371},
            {name = "Ecological Succession", questID = 85460, isWeeklyQuest = true, uiMapID = 2371},
            {name = "Anima Reclamation Program", questID = 85459, isWeeklyQuest = true, uiMapID = 2371},
            {name = "Food Run", questID = 85461, isWeeklyQuest = true, uiMapID = 2371},
            {name = "A Reel Problem", questID = 90545, isWeeklyQuest = true, uiMapID = 2371},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], isDelveReputation = true, flagQuest = 91453, accountwide = true},

            --{name = "Eliminate Grubber", questID = 90126, isWeeklyQuest = true, uiMapID = 2371, conditions = ActivityUtil.Conditions.KareshWarrant},   --one-time?

            --the following don't reward rep
            {name = "Funny Buzzness", questID = 89195, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Leafing Things on the Ground", questID = 89221, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Bu-zzz", questID = 89209, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Shake your Bee-hind", questID = 89194, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Who You Gonna Call?", questID = 88980, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Royal Photographer", questID = 89212, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Ray-ket Ball, Redux", questID = 89056, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Ridge Racer", questID = 85481, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Follow-up Appointment", questID = 89238, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Shutterbug", questID = 89254, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Dream-Dream-Dream-Dream-Dreameringeding!", questID = 89240, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Ray-cing for the Future", questID = 89065, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Nesting Upkeep", questID = 88981, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Not as Cute When They Are Bigger and Angrier", questID = 89297, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Pee-Yew de Foxy", questID = 89057, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Dry Cleaning", questID = 89198, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Flights of Fancy", questID = 89213, shownIfOnQuest = true, uiMapID = 2371},
            {name = "A Challenge for Dominance", questID = 85462, shownIfOnQuest = true, uiMapID = 2371},
            {name = "A Hard Day's Work", questID = 89192, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Ray Ranching", questID = 89197, shownIfOnQuest = true, uiMapID = 2371},
            {name = "Sizing Them Up", questID = 85710, shownIfOnQuest = true, uiMapID = 2371},

            --Devourer Attack
            {name = "Devourer Attack", label = L["Devourer Attack"], uiMapID = 2371, questClassification = 5, tooltipSetter = ActivityUtil.TooltipFuncs.DevouredEnergyPod, addChildrenToTooltip = true,
                children = {
                    --Sorted by location: North-South
                    {name = "Devourer Attack: The Oasis", questID = 84993, uiMapID = 2371},
                    {name = "Devourer Attack: Eco-dome: Primus", questID = 86447, uiMapID = 2371},
                    {name = "Devourer Attack: Atrium", questID = 86464, uiMapID = 2371},
                    {name = "Devourer Attack: Tazavesh", questID = 86465, uiMapID = 2371},
                },
            },

            --{name = "Making a Deposit", questID = 85722, shownIfOnQuest = true, uiMapID = 2371},
            --{name = "Making a Deposit", questID = 89061, shownIfOnQuest = true, uiMapID = 2371},
            --{name = "Making a Deposit", questID = 89062, shownIfOnQuest = true, uiMapID = 2371},
            --{name = "Making a Deposit", questID = 89063, shownIfOnQuest = true, uiMapID = 2371},
        }
    },

    {isHeader = true, name = "Council of Dornogal", factionID = 2590, categoryID = 2590, uiMapID = 2248,
        entries = {
            {name = "The Theater Troupe", questID = 83240, isWeeklyQuest = true, uiMapID = 2248},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], isDelveReputation = true, flagQuest = 83317, accountwide = true},
        }
    },

    {isHeader = true, name = "The Assembly of the Deeps", factionID = 2594, categoryID = 2594, uiMapID = 2214,
        entries = {
            {name = "Rollin\' Down in the Deeps", questID = 82946, isWeeklyQuest = true, uiMapID = 2214},
            {name = "Gearing Up for Trouble", questID = 83333, isWeeklyQuest = true, uiMapID = 2214}, --Awakening the Machine
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], isDelveReputation = true, flagQuest = 83318, accountwide = true},
        }
    },

    {isHeader = true, name = "Hallowfall Arathi", factionID = 2570, categoryID = 2570, uiMapID = 2215,
        entries = {
            {name = "Speading the Light", questID = 76586, isWeeklyQuest = true, uiMapID = 2215},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], isDelveReputation = true, flagQuest = 83320, accountwide = true},
        }
    },

    {isHeader = true, name = "The Severed Threads", factionID = 2600, categoryID = 2560, uiMapID = 2255,
        entries = {
            {name = "Forge a Pact", questID = 80592, isWeeklyQuest = true, uiMapID = 2255},
            {name = "Blade of the General", questID = 80671, isWeeklyQuest = true, factionID = 2605, shownIfOnQuest = true, uiMapID = 2255},
            {name = "Hand of the Vizier", questID = 80672, isWeeklyQuest = true, factionID = 2607, shownIfOnQuest = true, uiMapID = 2255},
            {name = "Eyes of the Weaver", questID = 80670, isWeeklyQuest = true, factionID = 2601, shownIfOnQuest = true, uiMapID = 2255},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], isDelveReputation = true, flagQuest = 83319, accountwide = true},
        }
    },

    {isHeader = true, name = "The Cartels of Undermine", factionID = 2653, categoryID = 2553, uiMapID = 2346,
        entries = {
            {name = "Many Jobs, Handle It!", questID = 85869, isWeeklyQuest = true, uiMapID = 2346},
            {name = "Urge to Surge", questID = 86775, isWeeklyQuest = true, uiMapID = 2346},
            {name = "Reduce, Reuse, Resell", questID = 85879, isWeeklyQuest = true, uiMapID = 2346},
            {name = "Completed C.H.E.T.T. List", itemID = 235053, localizedName = L["Completed CHETT List"], conditions = ActivityUtil.Conditions.ItemReadyToTurnInWhenLooted_ItemName,   --The incompleted and completed items have the same itemID, needs checking count by name
                icon = 134391, tooltip = L["Ready To Turn In Tooltip"], uiMapID = 2346},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], isDelveReputation = true, flagQuest = 87407, accountwide = true},
        }
    },

    {isHeader = true, name = "Flame\'s Radiance", factionID = 2688, categoryID = 2688, uiMapID = 2215,
        entries = {
            {name = "The Flame Burns Eternal", questID = 91173, isWeeklyQuest = true, uiMapID = 2215},
            {name = "Sureki Incursion: The Eastern Assault", questID = 87480, isDailyQuest = true, shownIfOnQuest = true, uiMapID = 2215},
            {name = "Sureki Incursion: Southern Swarm", questID = 87477, isDailyQuest = true, shownIfOnQuest = true, uiMapID = 2215},
            {name = "Sureki Incursion: Hold the Wall", questID = 87475, isDailyQuest = true, shownIfOnQuest = true, uiMapID = 2215},
            {name = "Radiant Incursion: Rak-Zakaz", questID = 88945, isDailyQuest = true, shownIfOnQuest = true, uiMapID = 2215},
            {name = "Radiant Incursion: Sureki\'s End", questID = 88916, isDailyQuest = true, shownIfOnQuest = true, uiMapID = 2255},
            {name = "Radiant Incursion: Toxins and Pheromones", questID = 88711, isDailyQuest = true, shownIfOnQuest = true, uiMapID = 2255},
        }
    },
};

LandingPageUtil.AddExpansionData(11, "activity", ActivityData);


local DynamicQuestMaps = {
    [2339] = "map2339",     --Dornogal
};
LandingPageUtil.AddExpansionData(11, "activityQuestMap", DynamicQuestMaps);
