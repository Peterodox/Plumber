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
local IsQuestFlaggedCompletedOnAccount = C_QuestLog.IsQuestFlaggedCompletedOnAccount;
local GetQuestClassification = C_QuestInfoSystem.GetQuestClassification;
local IsOnQuest = C_QuestLog.IsOnQuest;
local GetQuestLineInfo = C_QuestLine.GetQuestLineInfo;


local DELVES_BOUNTIFUL = "delves-bountiful";
local DAILY_QUEST = "quest-recurring-available";    --questlog-questtypeicon-daily;
local WEEKLY_QUEST = "quest-wrapper-available";     --questlog-questtypeicon-weekly";


local function ShownIfOnQuest(questID)
    return questID and IsOnQuest(questID)
end


local SortedActivity;
local MapQuestData;     --Show quests available on certain maps. The quest markers need to be visible on the world map

local DELVES_REP_TOOLTIP = L["Bountiful Delves Rep Tooltip"];

local ActivityData = {  --Constant

    {isHeader = true, name = "Council of Dornogal", factionID = 2590, uiMapID = 2248,
        entries = {
            {name = "Theater Troupe", questID = 83240, atlas = WEEKLY_QUEST, uiMapID = 2248},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], atlas = DELVES_BOUNTIFUL, flagQuest = 83317, accountwide = true, tooltip = DELVES_REP_TOOLTIP},
            --{name = "Debug Quest", questID = 49738, atlas = DAILY_QUEST},
        }
    },

    {isHeader = true, name = "The Assembly of the Deeps", factionID = 2594, uiMapID = 2214,
        entries = {
            {name = "Rollin\' Down in the Deeps", questID = 82946, atlas = WEEKLY_QUEST, uiMapID = 2214},
            {name = "Gearing Up for Trouble", questID = 83333, atlas = WEEKLY_QUEST, uiMapID = 2214}, --Awakening the Machine
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], atlas = DELVES_BOUNTIFUL, flagQuest = 83318, accountwide = true, tooltip = DELVES_REP_TOOLTIP},
        }
    },

    {isHeader = true, name = "Hallowfall Arathi", factionID = 2570, uiMapID = 2215,
        entries = {
            {name = "Speading the Light", questID = 76586, atlas = WEEKLY_QUEST, uiMapID = 2215},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], atlas = DELVES_BOUNTIFUL, flagQuest = 83320, accountwide = true, tooltip = DELVES_REP_TOOLTIP},
        }
    },

    {isHeader = true, name = "The Severed Threads", factionID = 2600, uiMapID = 2255,
        entries = {
            {name = "Forge a Pact", questID = 80592, atlas = WEEKLY_QUEST, uiMapID = 2255},
            {name = "Blade of the General", questID = 80671, atlas = WEEKLY_QUEST, factionID = 2605, shownIfOnQuest = true, uiMapID = 2255},
            {name = "Hand of the Vizier", questID = 80672, atlas = WEEKLY_QUEST, factionID = 2607, shownIfOnQuest = true, uiMapID = 2255},
            {name = "Eyes of the Weaver", questID = 80670, atlas = WEEKLY_QUEST, factionID = 2601, shownIfOnQuest = true, uiMapID = 2255},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], atlas = DELVES_BOUNTIFUL, flagQuest = 83319, accountwide = true, tooltip = DELVES_REP_TOOLTIP},
        }
    },

    {isHeader = true, name = "The Cartels of Undermine", factionID = 2653, uiMapID = 2346,
        entries = {
            {name = "Many Jobs, Handle It!", questID = 85869, atlas = WEEKLY_QUEST, uiMapID = 2346},
            {name = "Urge to Surge", questID = 86775, atlas = WEEKLY_QUEST, uiMapID = 2346},
            {name = "Reduce, Reuse, Resell", questID = 85879, atlas = WEEKLY_QUEST, uiMapID = 2346},
            {name = "Weekly Delve", localizedName = L["Bountiful Delve"], atlas = DELVES_BOUNTIFUL, flagQuest = 87407, accountwide = true, tooltip = DELVES_REP_TOOLTIP},
        }
    },

    {isHeader = true, name = "Flame\'s Radiance", factionID = 2688, uiMapID = 2215,
        entries = {
            {name = "The Flame Burns Eternal", questID = 91173, atlas = WEEKLY_QUEST},
            {name = "Sureki Incursion: The Eastern Assault", questID = 87480, atlas = DAILY_QUEST, shownIfOnQuest = true, uiMapID = 2215},
            {name = "Sureki Incursion: Southern Swarm", questID = 87477, atlas = DAILY_QUEST, shownIfOnQuest = true, uiMapID = 2215},
            {name = "Sureki Incursion: Hold the Wall", questID = 87475, atlas = DAILY_QUEST, shownIfOnQuest = true, uiMapID = 2215},
            {name = "Radiant Incursion: Rak-Zakaz", questID = 88945, atlas = DAILY_QUEST, shownIfOnQuest = true, uiMapID = 2215},
            {name = "Radiant Incursion: Sureki\'s End", questID = 88916, atlas = DAILY_QUEST, shownIfOnQuest = true, uiMapID = 2255},
            {name = "Radiant Incursion: Toxins and Pheromones", questID = 88711, atlas = DAILY_QUEST, shownIfOnQuest = true, uiMapID = 2255},
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

do  --Assign ID
    for k, v in ipairs(ActivityData) do
        v.headerIndex = k;
    end
end


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


local ShownQuestClassification = {
    --Show these types of quests
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

local InProgressQuestIconFile = {
	[Enum.QuestClassification.Normal] = 	"Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressRed.png",
	[Enum.QuestClassification.Questline] = 	"Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png",
	[Enum.QuestClassification.Recurring] =	"Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png",
	[Enum.QuestClassification.Meta] = 		"Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png",
};

local function InitQuestData(info)
    local questClassification = info.questClassification or GetQuestClassification(info.questID);
    info.questClassification = questClassification;

    info.isOnQuest = IsOnQuest(info.questID);

    if info.isOnQuest then
        --print(API.GetQuestName(info.questID), info.questID, questClassification);
        info.icon = questClassification and InProgressQuestIconFile[questClassification];
    end

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
    };

    local MapQuests = {
        [2339] = {  --Dornogal
            {name = "Sparks of War: Azj-Khahet", questID = 81796, shownIfOnQuest = true},
            {name = "Sparks of War: Isle of Dorn", questID = 81793, shownIfOnQuest = true},
            {name = "Sparks of War: The Ringing Deeps", questID = 81794, shownIfOnQuest = true},
            {name = "Sparks of War: Hallowfall", questID = 81795, shownIfOnQuest = true},
            {name = "Sparks of War: Undermine", questID = 86853, shownIfOnQuest = true},
        },
    };

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

        if MapQuests[uiMapID] then
            local n;
            local valid;

            if self.questsByMap[uiMapID] then
                n = #self.questsByMap[uiMapID];
            else
                self.questsByMap[uiMapID] = {};
                n = 0;
            end

            for _, entry in ipairs(MapQuests[uiMapID]) do
                valid = false;
                if entry.shownIfOnQuest then
                    if ShownIfOnQuest(entry.questID) then
                        valid = true;
                    end
                else
                    valid = true;
                end

                if valid then
                    n = n + 1;
                    InitQuestData(entry);
                    self.questsByMap[uiMapID][n] = entry;
                end
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
            local data = C_Reputation.GetFactionDataByID(v.factionID);
            if data and data.name then
                v.localizedName = data.name;
                return data.name, true
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
                InitQuestData(entry);
            end

            if flagQuest then
                if entry.accountwide then
                    entry.completed = IsQuestFlaggedCompletedOnAccount(flagQuest);
                else
                    entry.completed = IsQuestFlaggedCompleted(flagQuest);
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
                    tsort(entries, SortFuncs.DataIndex);
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
    --Wipe old data
    MapQuestData = nil;
    DynamicQuestDataProvider:Reset();
    DynamicQuestDataProvider:AddQuestsFromMap(2339);     --Dornogal


    local tbl = {};
    local n = 0;
    local numCompleted = 0;

    for _, category in ipairs(ActivityData) do
        category.isCollapsed = ActivityUtil.collapsedHeader[category.headerIndex];
    end

    n, numCompleted = FlattenData(MapQuestData, n, tbl, numCompleted);
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
            if entry.accountwide then
                entry.completed = IsQuestFlaggedCompletedOnAccount(flagQuest);
            else
                entry.completed = IsQuestFlaggedCompleted(flagQuest);
            end
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

        if v.isDynamicQuest and v.questMapID then
            DynamicQuestDataProvider:SetMapCollapsed(v.questMapID, v.isCollapsed);
        end

        --print(dataIndex, v.localizedName or v.name, v.isDynamicQuest, v.questMapID, v.isCollapsed);

        return v.isCollapsed
    end
end

function ActivityUtil.SetHideCompleted(state)
    ActivityUtil.hideCompleted = state;
end
addon.CallbackRegistry:RegisterSettingCallback("LandingPage_Activity_HideCompleted", ActivityUtil.SetHideCompleted);


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