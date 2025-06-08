local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;


local tsort = table.sort;


local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted;
local IsQuestFlaggedCompletedOnAccount = C_QuestLog.IsQuestFlaggedCompletedOnAccount;


local DELVES_BOUNTIFUL = "delves-bountiful";
local DAILY_QUEST = "quest-recurring-available";   --"questlog-questtypeicon-daily";
local WEEKLY_QUEST = "questlog-questtypeicon-weekly";


local IsOnQuest = C_QuestLog.IsOnQuest;

local function ShownIfOnQuest(questID)
    return questID and IsOnQuest(questID)
end


local ActivityData = {
    {isHeader = true, name = "Council of Dornogal", factionID = 2590,
        entries = {
            {name = "Theater Troupe", questID = 83240, atlas = WEEKLY_QUEST},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], atlas = DELVES_BOUNTIFUL, flagQuest = 83317, accountwide = true},
            {name = "Debug Quest", questID = 49738, atlas = DAILY_QUEST},
        }
    },

    {isHeader = true, name = "The Assembly of the Deeps", factionID = 2594,
        entries = {
            {name = "Rollin\' Down in the Deeps", questID = 82946, atlas = WEEKLY_QUEST},
            {name = "Gearing Up for Trouble", questID = 83333, atlas = WEEKLY_QUEST}, --Awakening the Machine
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], atlas = DELVES_BOUNTIFUL, flagQuest = 83318, accountwide = true},
        }
    },

    {isHeader = true, name = "Hallowfall Arathi", factionID = 2570,
        entries = {
            {name = "Speading the Light", questID = 76586, atlas = WEEKLY_QUEST},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], atlas = DELVES_BOUNTIFUL, flagQuest = 83320, accountwide = true},
        }
    },

    {isHeader = true, name = "The Severed Threads", factionID = 2600,
        entries = {
            {name = "Forge a Pact", questID = 80592, atlas = WEEKLY_QUEST},
            {name = "Blade of the General", questID = 80671, atlas = WEEKLY_QUEST, factionID = 2605, shownIfOnQuest = true},
            {name = "Hand of the Vizier", questID = 80672, atlas = WEEKLY_QUEST, factionID = 2607, shownIfOnQuest = true},
            {name = "Eyes of the Weaver", questID = 80670, atlas = WEEKLY_QUEST, factionID = 2601, shownIfOnQuest = true},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], atlas = DELVES_BOUNTIFUL, flagQuest = 83319, accountwide = true},
        }
    },

    {isHeader = true, name = "The Cartels of Undermine", factionID = 2653,
        entries = {
            {name = "Many Jobs, Handle It!", questID = 85869, atlas = WEEKLY_QUEST},
            {name = "Urge to Surge", questID = 86775, atlas = WEEKLY_QUEST},
            {name = "Reduce, Reuse, Resell", questID = 85879, atlas = WEEKLY_QUEST},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], atlas = DELVES_BOUNTIFUL, flagQuest = 87407, accountwide = true},
        }
    },

    {isHeader = true, name = "Flame\'s Radiance", factionID = 2688,
        entries = {
            {name = "The Flame Burns Eternal", questID = 91173, atlas = WEEKLY_QUEST},
            {name = "Sureki Incursion: The Eastern Assault", questID = 87480, atlas = DAILY_QUEST, shownIfOnQuest = true},
            {name = "Sureki Incursion: Southern Swarm", questID = 87477, atlas = DAILY_QUEST, shownIfOnQuest = true},
            {name = "Sureki Incursion: Hold the Wall", questID = 87475, atlas = DAILY_QUEST, shownIfOnQuest = true},
            {name = "Radiant Incursion: Rak-Zakaz", questID = 88945, atlas = DAILY_QUEST, shownIfOnQuest = true},
            {name = "Radiant Incursion: Sureki\'s End", questID = 88916, atlas = DAILY_QUEST, shownIfOnQuest = true},
            {name = "Radiant Incursion: Toxins and Pheromones", questID = 88711, atlas = DAILY_QUEST, shownIfOnQuest = true},
        }
    },

    {isHeader = true, name = "Delves", localizedName = DELVES_LABEL,
        entries = {
            {name = "The Key to Success", questID = 84370, atlas = WEEKLY_QUEST, accountwide = true},
            {name = "Delver\'s Bounty", itemID = 233071, flagQuest = 86371, icon = 1064187},
        }
    },
};

addon.ActivityData = ActivityData;


local DataList = {};
do
    local n = 0;

    for _, category in ipairs(ActivityData) do
        n = n + 1;
        category.dataIndex = n;
        DataList[n] = category;
        for _, entry in ipairs(category.entries) do
            n = n + 1;
            entry.dataIndex = n;
            DataList[n] = entry;
        end
    end
end

function LandingPageUtil.GetActivityData(dataIndex)
    return DataList[dataIndex]
end

function LandingPageUtil.GetActivityName(dataIndex)
    --2nd arg: isLocalized
    local v = DataList[dataIndex];
    if v then
        if v.localizedName then
            return v.localizedName, true
        end

        if v.questID then
            local name = API.GetQuestName(v.questID);
            if name and name ~= "" then
                v.localizedName = name;
                return name, true
            end
        end

        if v.isHeader and v.factionID then
            local data = C_Reputation.GetFactionDataByID(v.factionID);
            if data and data.name then
                v.localizedName = data.name;
                return data.name, true
            end
        end

        if v.itemID then
            local name = C_Item.GetItemNameByID(v.itemID);
            if name then
                v.localizedName = name;
                return name, true
            end
        end

        return v.name, false
    end
end


local function StoreLocalizedName(dataIndex, key, id, localizedName)
    local v = DataList[dataIndex];
    if v and id and v[key] == id and localizedName and localizedName ~= "" then
        v.localizedName = localizedName;
    end
end

function LandingPageUtil.StoreQuestActivityName(dataIndex, questID, localizedName)
    StoreLocalizedName(dataIndex, "questID", questID, localizedName);
end

function LandingPageUtil.StoreItemActivityName(dataIndex, itemID, localizedName)
    StoreLocalizedName(dataIndex, "itemID", itemID, localizedName);
end

function LandingPageUtil.ShouldShowActivity(data)
    if data.shownIfOnQuest then
        return ShownIfOnQuest(data.questID)
    end

    return true
end


local SortFuncs = {};
do
    function SortFuncs.IncompleteFirst(a, b)
        if a.completed ~= b.completed then
            return b.completed
        end

        return a.dataIndex < b.dataIndex
    end
end


function LandingPageUtil.GetSortedActivity()
    local tbl = {};
    local n = 0;
    local flagQuest;

    for _, category in ipairs(ActivityData) do
        n = n + 1;
        tbl[n] = category;

        for _, entry in ipairs(category.entries) do
            flagQuest = entry.flagQuest or entry.questID;
            if flagQuest then
                if entry.accountwide then
                    entry.completed = IsQuestFlaggedCompletedOnAccount(flagQuest);
                else
                    entry.completed = IsQuestFlaggedCompleted(flagQuest);
                end
            else
                entry.completed = false;
            end
        end

        tsort(category.entries, SortFuncs.IncompleteFirst);

        for _, entry in ipairs(category.entries) do
            n = n + 1;
            tbl[n] = entry;
        end
    end

    return tbl
end