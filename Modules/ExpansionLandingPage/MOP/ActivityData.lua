--https://warcraft.wiki.gg/wiki/Mists_of_Pandaria_daily_quests

local _, addon = ...
local API = addon.API;
local L = addon.L;


local ActivityUtil = {};
addon.ActivityUtil = ActivityUtil;

ActivityUtil.hideCompleted = false;
ActivityUtil.collapsedHeader = {};


local ipairs = ipairs;
local tsort = table.sort;

local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted;
local IsOnQuest = C_QuestLog.IsOnQuest;
local GetFactionInfoByID = GetFactionInfoByID;


local DAILY_QUEST = "QuestNormal";


local function ShownIfOnQuest(questID)
    return questID and IsOnQuest(questID)
end


local Dailies_Tillers = {
    --Completing 1 quest flags 5 quests as completed
    31672, 31942, 31673, 31941, 31670, 31669, 31674, 31675, 31943, 31671,
    32642, 32643, 32647, 32648, 32645, 32646, 32649, 32650, 32942, 32943, 32653, 32657, 32658, 32659,
    30337, 30335, 30334, 30336, 30333,
    30318, 30322, 30324, 30319, 30326, 30323, 30317, 30321, 30325, 30327,
    30471, 30474, 30473, 30475, 30479, 30477, 30478, 30476, 30472, 30470,
    30329, 30332, 30331, 30328, 30330,
};

local ActivityData = {  --Constant

    {isHeader = true, name = "The Tillers", factionID = 1272, uiMapID = 376,
        entries = {
            --{name = "Debug Quest", questID = 49738, atlas = DAILY_QUEST},
        }
    },
};

do  --Assign ID
    for k, v in ipairs(ActivityData) do
        v.headerIndex = k;
    end
end

local function InsertQuestsFromPool(headerIndex, quests)
    local uiMapID = ActivityData[headerIndex].uiMapID;
    local entries = {};
    local n = 0;

    for _, questID in ipairs(quests) do
        n = n + 1;
        entries[n] = {
            questID = questID,
            atlas = DAILY_QUEST,
            shownIfOnQuest = true,
            uiMapID = uiMapID,
        };
    end

    ActivityData[headerIndex].entries = entries;
end
InsertQuestsFromPool(1, Dailies_Tillers);


local function GetQuestPoolProgress(quests)
    local completed = 0;
    local active = 0;
    for _, questID in ipairs(quests) do
        if IsQuestFlaggedCompleted(questID) then
            completed = completed + 1;
        elseif IsOnQuest(questID) then
            active = active + 1;
        end
    end
    print("completed:", completed, "in progress:", active);
end

local function GetQuestGroupTotal(quests)
    print("total:", #quests)
    return #quests
end


--[[
local EL = CreateFrame("Frame");
EL:RegisterEvent("QUEST_ACCEPTED");
EL:RegisterEvent("QUEST_TURNED_IN");
EL:RegisterEvent("PLAYER_ENTERING_WORLD");
EL:SetScript("OnEvent", function(self, event, ...)
    if event == "QUEST_ACCEPTED" or event == "QUEST_TURNED_IN" then
        GetQuestPoolProgress(Dailies_Tillers);
    elseif event == "PLAYER_ENTERING_WORLD" then
        GetQuestPoolProgress(Dailies_Tillers);
        GetQuestGroupTotal(Dailies_Tillers);
    end
end);
--]]



local SortFuncs = {};
do
    function SortFuncs.DataIndex(a, b)
        return a.dataIndex < b.dataIndex
    end

    function SortFuncs.IncompleteFirst(a, b)
        if a.completed ~= b.completed then
            return b.completed
        end

        return a.dataIndex < b.dataIndex
    end

    function SortFuncs.ClassificationThenQuestID(a, b)
        if a.questClassification and b.questClassification then
            if a.questClassification ~= b.questClassification then
                return a.questClassification < b.questClassification
            end
        else
            return a.questClassification ~= nil
        end

        return a.questID > b.questID
    end
end



function ActivityUtil.GetActivityData(dataIndex)
    if SortedActivity then
        return SortedActivity[dataIndex]
    end
end


local QuestNames = {};
local ItemNames = {};


function ActivityUtil.GetActivityName(dataIndex)
    --2nd arg: isLocalized
    local v = SortedActivity[dataIndex];
    if v then
        if v.localizedName then
            return v.localizedName, true
        end

        if v.questID then
            local name = QuestNames[v.questID] or API.GetQuestName(v.questID);
            if name and name ~= "" then
                v.localizedName = name;
                return name, true
            end
        end

        if v.isHeader and v.factionID then
            local name = GetFactionInfoByID(v.factionID);
            if name then
                v.localizedName = name;
                return name, true
            end
        end

        if v.itemID then
            local name = ItemNames[v.itemID] or C_Item.GetItemNameByID(v.itemID);
            if name then
                v.localizedName = name;
                return name, true
            end
        end

        return v.name, false
    end
end


function ActivityUtil.StoreQuestActivityName(questID, localizedName)
    if questID and localizedName and localizedName ~= "" then
        QuestNames[questID] = localizedName;
    end
end

function ActivityUtil.StoreItemActivityName(itemID, localizedName)
    if itemID and localizedName and localizedName ~= "" then
        ItemNames[itemID] = localizedName;
    end
end

function ActivityUtil.ShouldShowActivity(data)
    if data.shownIfOnQuest then
        return ShownIfOnQuest(data.questID)
    end

    return true
end


do
    local function IndexData(activityData)
        local n = 0;
        for _, category in ipairs(activityData) do
            n = n + 1;
            category.dataIndex = n;
            for _, entry in ipairs(category.entries) do
                n = n + 1;
                entry.dataIndex = n;
            end
        end
    end

    local function FlattenData(activityData, n, outputTbl, numCompleted)
        if not activityData then return n, 0 end;

        IndexData(activityData);

        local hideCompleted = ActivityUtil.hideCompleted;
        numCompleted = numCompleted or 0

        for _, category in ipairs(activityData) do
            local anyIncomplted;
            local numEntries = 0;
            local entries = {};
            local flagQuest;
            local showActivity;

            for _, entry in ipairs(category.entries) do
                flagQuest = entry.flagQuest or entry.questID;
                showActivity = true;

                if entry.questID then
                    
                end

                if flagQuest then
                    entry.completed = IsQuestFlaggedCompleted(flagQuest);
                elseif entry.conditions then
                    if entry.conditions.ShouldShowActivity then
                        showActivity = entry.conditions.ShouldShowActivity();
                    end
                    if entry.conditions.IsActivityCompleted then
                        entry.completed = entry.conditions.IsActivityCompleted();
                    end
                else
                    entry.completed = false;
                end

                if entry.shownIfOnQuest then
                    if hideCompleted then
                        if not entry.isOnQuest then
                            showActivity = false;
                        end
                    else
                        if not (entry.completed or entry.isOnQuest) then
                            showActivity = false
                        end
                    end
                end

                if entry.completed then
                    numCompleted = numCompleted + 1;
                elseif showActivity then
                    anyIncomplted = true;
                end

                if showActivity then
                    if hideCompleted then
                        if entry.isHeader or (not entry.completed) then
                            numEntries = numEntries + 1;
                            entries[numEntries] = entry;
                        end
                    else
                        numEntries = numEntries + 1;
                        entries[numEntries] = entry;
                    end
                end
            end

            if hideCompleted then
                if anyIncomplted then
                    n = n + 1;
                    outputTbl[n] = category;
                    if numEntries > 0 then
                        tsort(entries, SortFuncs.DataIndex);
                        for _, entry in ipairs(entries) do
                            n = n + 1;
                            outputTbl[n] = entry;
                        end
                    end
                end
            else
                if true then
                    n = n + 1;
                    outputTbl[n] = category;
                    if numEntries > 0 then
                        tsort(entries, SortFuncs.IncompleteFirst);
                        for _, entry in ipairs(entries) do
                            n = n + 1;
                            outputTbl[n] = entry;
                        end
                    end
                end
            end
        end

        return n, numCompleted
    end

    function ActivityUtil.GetSortedActivity()
        local tbl = {};
        local n = 0;
        local numCompleted = 0;

        for _, category in ipairs(ActivityData) do
            category.isCollapsed = ActivityUtil.collapsedHeader[category.headerIndex];
        end

        n, numCompleted = FlattenData(ActivityData, n, tbl, numCompleted);

        for k, v in ipairs(tbl) do
            v.dataIndex = k;
        end

        SortedActivity = tbl

        return tbl, numCompleted
    end

    function ActivityUtil.UpdateAndGetProgress(dataIndex)
        local entry = SortedActivity and SortedActivity[dataIndex];
        if entry then
            local flagQuest = entry.flagQuest or entry.questID;
            if flagQuest then
                entry.completed = IsQuestFlaggedCompleted(flagQuest);
            else
                entry.completed = false;
            end
            return entry.completed
        end
    end

    function ActivityUtil.ToggleCollapsed(dataIndex)
        local v = SortedActivity and SortedActivity[dataIndex];
        if v and v.isHeader then
            v.isCollapsed = not v.isCollapsed;

            if v.headerIndex then
                ActivityUtil.collapsedHeader[v.headerIndex] = not ActivityUtil.collapsedHeader[v.headerIndex];
            end

            --print(dataIndex, v.localizedName or v.name, v.isDynamicQuest, v.questMapID, v.isCollapsed);

            return v.isCollapsed
        end
    end

    function ActivityUtil.SetHideCompleted(state)
        ActivityUtil.hideCompleted = state;
    end
    addon.CallbackRegistry:RegisterSettingCallback("LandingPage_Activity_HideCompleted", ActivityUtil.SetHideCompleted);
end