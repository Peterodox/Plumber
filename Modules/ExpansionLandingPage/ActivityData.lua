local _, addon = ...
local API = addon.API;
local L = addon.L;


local ActivityUtil = {};
addon.ActivityUtil = ActivityUtil;


local ipairs = ipairs;
local tsort = table.sort;


local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted;
local IsQuestFlaggedCompletedOnAccount = C_QuestLog.IsQuestFlaggedCompletedOnAccount;
local GetQuestClassification = C_QuestInfoSystem.GetQuestClassification;
local IsOnQuest = C_QuestLog.IsOnQuest;
local GetQuestLineInfo = C_QuestLine.GetQuestLineInfo;


local DELVES_BOUNTIFUL = "delves-bountiful";
local DAILY_QUEST = "quest-recurring-available";   --"questlog-questtypeicon-daily";
local WEEKLY_QUEST = "questlog-questtypeicon-weekly";


local function ShownIfOnQuest(questID)
    return questID and IsOnQuest(questID)
end


local SortedActivity;
local MapQuestData;     --Show quests available on certain maps. The quest markers need to be visible on the world map

local ActivityData = {  --Constant

    {isHeader = true, name = "Council of Dornogal", factionID = 2590,
        entries = {
            {name = "Theater Troupe", questID = 83240, atlas = WEEKLY_QUEST},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], atlas = DELVES_BOUNTIFUL, flagQuest = 83317, accountwide = true},
            --{name = "Debug Quest", questID = 49738, atlas = DAILY_QUEST},
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

local function IndexData(n, data)
    for _, category in ipairs(data) do
        n = n + 1;
        category.dataIndex = n;
        DataList[n] = category;
        for _, entry in ipairs(category.entries) do
            n = n + 1;
            entry.dataIndex = n;
            DataList[n] = entry;
        end
    end
    return n
end


local SortFuncs = {};
do
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


local ShownQuestClassification = {
    [Enum.QuestClassification.Recurring] = true,
    [Enum.QuestClassification.Meta] = true,
    [Enum.QuestClassification.Calling] = true,
};

local QuestIconAtlas =
{
	[Enum.QuestClassification.Normal] = 	"QuestNormal",
	[Enum.QuestClassification.Questline] = 	"QuestNormal",
	[Enum.QuestClassification.Recurring] =	DAILY_QUEST,
	[Enum.QuestClassification.Meta] = 		"quest-wrapper-available",
	[Enum.QuestClassification.Calling] = 	"Quest-DailyCampaign-Available",
	[Enum.QuestClassification.Campaign] = 	"Quest-Campaign-Available",
	[Enum.QuestClassification.Legendary] =	"UI-QuestPoiLegendary-QuestBang",
	[Enum.QuestClassification.Important] =	"importantavailablequesticon",
};

local function InitQuestData(info)
    local questClassification = info.questClassification or GetQuestClassification(info.questID);
    info.questClassification = questClassification;

    if not info.atlas then
        info.atlas = questClassification and QuestIconAtlas[questClassification] or "QuestNormal";
    end
end


local DynamicQuestDataProvider = {};
do  --Dynamic Quests are acquired using Game API, instead of using a pre-determined table
    DynamicQuestDataProvider.collapsedMap = {};

    local MapMetaQuestLines = {
        [2339] = {  --Dornogal
            5572,   --Worldsoul: Weekly Meata
        },
    }

    function DynamicQuestDataProvider:Reset()
        self.addedQuests = {};
        self.questsByMap = {};
    end

    function DynamicQuestDataProvider:SetMapCollapsed(uiMapID, isCollapsed)
        self.collapsedMap[uiMapID] = isCollapsed;
    end

    function DynamicQuestDataProvider:AddQuestsFromTable(uiMapID, tbl)
        if not tbl then return end;

        local n = self.questsByMap[uiMapID] and #self.questsByMap[uiMapID] or 0;
        local mapID, questID;

        for _, v in ipairs(tbl) do
            questID = v.questID;
            if questID and not self.addedQuests[questID] then
                mapID = v.startMapID or v.mapID;
                if (not v.isHidden) and mapID and mapID == uiMapID then
                    InitQuestData(v);
                    if ShownQuestClassification[v.questClassification] then
                        self.addedQuests[questID] = true;
                        n = n + 1;
                        if not self.questsByMap[uiMapID] then
                            self.questsByMap[uiMapID] = {};
                        end
                        v.isDynamicQuest = true;
                        self.questsByMap[uiMapID][n] = v;
                    end
                end
            end
        end
    end

    function DynamicQuestDataProvider:AddQuestsFromMap(uiMapID)
        C_QuestLine.RequestQuestLinesForMap(uiMapID);

        self.questsByMap[uiMapID] = nil;

        self:AddQuestsFromTable(uiMapID, C_QuestLine.GetAvailableQuestLines(uiMapID));
        self:AddQuestsFromTable(uiMapID, C_TaskQuest.GetQuestsOnMap(uiMapID));

        if MapMetaQuestLines[uiMapID] then
            for _, questLineID in ipairs(MapMetaQuestLines[uiMapID]) do
                self:AddQuestsFromQuestLine(questLineID, uiMapID);
            end
        end

        if self.questsByMap[uiMapID] then
            table.sort(self.questsByMap[uiMapID], SortFuncs.ClassificationThenQuestID);
            local mapName = C_Map.GetMapInfo(uiMapID).name;
            local category = {
                isHeader = true,
                name = mapName,
                entries = self.questsByMap[uiMapID],
                isDynamicQuest = true,
                questMapID = uiMapID,
                isCollapsed = self.collapsedMap[uiMapID] == true,
            };
            if not MapQuestData then
                MapQuestData = {};
            end
            table.insert(MapQuestData, category);
        end
    end

    function DynamicQuestDataProvider:AddQuestsFromQuestLine(questLineID, uiMapID)
        local questIDs = C_QuestLine.GetQuestLineQuests(questLineID);   --Dornogal meta
        if questIDs then
            local n = self.questsByMap[uiMapID] and #self.questsByMap[uiMapID] or 0;
            for _, questID in ipairs(questIDs) do
                if not self.addedQuests[questID] then
                    local questLineInfo = GetQuestLineInfo(questID);
                    if questLineInfo and ShownIfOnQuest(questID) then
                        --print(questLineInfo.questID, questLineInfo.questName, questLineInfo.isHidden)
                        InitQuestData(questLineInfo);
                        if ShownQuestClassification[questLineInfo.questClassification] then
                            self.addedQuests[questID] = true;
                            n = n + 1;
                            if not self.questsByMap[uiMapID] then
                                self.questsByMap[uiMapID] = {};
                            end
                            questLineInfo.isDynamicQuest = true;
                            self.questsByMap[uiMapID][n] = questLineInfo;
                        end
                    end
                end
            end
        end
    end
end


local function BuildDataList()
    DataList = {};
    local n = 0;

    MapQuestData = nil;

    DynamicQuestDataProvider:Reset();
    DynamicQuestDataProvider:AddQuestsFromMap(2339);     --Dornogal

    if MapQuestData then
        n = IndexData(n, MapQuestData);
    end

    n = IndexData(n, ActivityData);
end
BuildDataList();


function ActivityUtil.GetActivityData(dataIndex)
    return DataList[dataIndex]
end

function ActivityUtil.GetActivityName(dataIndex)
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

function ActivityUtil.StoreQuestActivityName(dataIndex, questID, localizedName)
    StoreLocalizedName(dataIndex, "questID", questID, localizedName);
end

function ActivityUtil.StoreItemActivityName(dataIndex, itemID, localizedName)
    StoreLocalizedName(dataIndex, "itemID", itemID, localizedName);
end

function ActivityUtil.ShouldShowActivity(data)
    if data.shownIfOnQuest then
        return ShownIfOnQuest(data.questID)
    end

    return true
end


function ActivityUtil.GetSortedActivity()
    BuildDataList();

    local tbl = {};
    local n = 0;
    local flagQuest;

    if MapQuestData then
        for _, category in ipairs(MapQuestData) do
            n = n + 1;
            tbl[n] = category;

            for _, entry in ipairs(category.entries) do
                flagQuest = entry.questID;
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
    end

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

    SortedActivity = tbl

    return tbl
end

function ActivityUtil.ToggleCollapsed(dataIndex)
    local v = SortedActivity and SortedActivity[dataIndex];
    if v and v.isHeader then
        v.isCollapsed = not v.isCollapsed;
        if v.isDynamicQuest and v.questMapID then
            --print(dataIndex, v.localizedName or v.name, v.questMapID, v.isCollapsed);
            DynamicQuestDataProvider:SetMapCollapsed(v.questMapID, v.isCollapsed);
        end
    end
end


--[[
function Debug_YeetQuests(uiMapID)
    uiMapID = uiMapID or C_Map.GetBestMapForUnit("player");

    local function PrintMetaQuests(quests)
        for index, questLineInfo in ipairs(quests) do
            if questLineInfo.isMeta or true then
                if not questLineInfo.questName then
                    questLineInfo.questName = API.GetQuestName(questLineInfo.questID);
                end
                print(index, questLineInfo.questName, questLineInfo.questLineID)
            end
        end
    end

    PrintMetaQuests(C_QuestLine.GetAvailableQuestLines(uiMapID));
    PrintMetaQuests(C_TaskQuest.GetQuestsOnMap(uiMapID));
end

function Debug_YeetActiveQuestLineQuests()
    local questIDs = C_QuestLine.GetQuestLineQuests(5572);   --Dornogal meta
    for _, questID in ipairs(questIDs) do
        local questLineInfo = C_QuestLine.GetQuestLineInfo(questID);
        if questLineInfo then
            print(questLineInfo.questID, questLineInfo.questName, questLineInfo.isHidden)
        end
    end
end
--]]

--Debug Event Listener
--[[
do
    local EL = CreateFrame("Frame");

    local DynamicEvents = {
        "QUEST_LOG_UPDATE",
        "QUEST_REMOVED",
        "QUEST_ACCEPTED",
        "QUEST_TURNED_IN",
        "QUESTLINE_UPDATE",
        "TASK_PROGRESS_UPDATE",
    };
    API.RegisterFrameForEvents(EL, DynamicEvents);

    EL:SetScript("OnEvent", function(self, event, ...)
        print(event, ...)
    end)
end
--]]