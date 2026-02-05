local _, addon = ...
local API = addon.API;
local L = addon.L;
local GetDBBool = addon.GetDBBool;


local ActivityUtil = {};
addon.ActivityUtil = ActivityUtil;

ActivityUtil.hideCompleted = false;


local ipairs = ipairs;
local tsort = table.sort;
local format = string.format;


local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted;
local IsQuestFlaggedCompletedOnAccount = C_QuestLog.IsQuestFlaggedCompletedOnAccount;
local GetQuestClassification = C_QuestInfoSystem.GetQuestClassification;
local IsOnQuest = C_QuestLog.IsOnQuest;
local GetQuestLineInfo = C_QuestLine.GetQuestLineInfo;
local GetItemCount = C_Item.GetItemCount;
local HaveQuestData = HaveQuestData;
local GetCurrentRenownLevel = C_MajorFactions.GetCurrentRenownLevel;


local function ShownIfOnQuest(questID)
    return questID and IsOnQuest(questID)
end

local function IsCategoryCollapsed(categoryID)
    return GetDBBool("LandingPage_Activity_Collapsed_"..categoryID)
end

local function SetCategoryCollapsed(categoryID, isCollapsed)
    return addon.SetDBValue("LandingPage_Activity_Collapsed_"..categoryID, isCollapsed, true)
end


local ActivityData = {};
local SortedActivity;
local MapQuestData;     --Show quests available on certain maps. The quest markers need to be visible on the world map

local DELVES_REP_TOOLTIP = L["Bountiful Delves Rep Tooltip"];


local DynamicQuestDataProvider = {};


local ConditionFuncs = {};
do
    function ConditionFuncs.OwnItem(itemInfo)
        --itemInfo can be item name
        if itemInfo then
            return GetItemCount(itemInfo) > 0
        end
        return false
    end
end


local ShownQuestClassification = {
    --Show these types of quests
    [Enum.QuestClassification.Recurring] = true,
    [Enum.QuestClassification.Meta] = true,
    [Enum.QuestClassification.Calling] = true,
};


local QuestIconAtlas = {
	[Enum.QuestClassification.Normal] = 	"QuestNormal",
	[Enum.QuestClassification.Questline] = 	"QuestNormal",
	[Enum.QuestClassification.Recurring] =	"quest-recurring-available",
	[Enum.QuestClassification.Meta] = 		"quest-wrapper-available",
	[Enum.QuestClassification.Calling] = 	"Quest-DailyCampaign-Available",
	[Enum.QuestClassification.Campaign] = 	"Quest-Campaign-Available",
	[Enum.QuestClassification.Legendary] =	"UI-QuestPoiLegendary-QuestBang",
	[Enum.QuestClassification.Important] =	"importantavailablequesticon",

    DELVES_BOUNTIFUL = "delves-bountiful",
    DAILY_QUEST = "quest-recurring-available",
    WEEKLY_QUEST = "quest-wrapper-available",
};
ActivityUtil.QuestIconAtlas = QuestIconAtlas;


local InProgressQuestIconFile = {
	[Enum.QuestClassification.Normal] = 	"Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressRed.png",
	[Enum.QuestClassification.Questline] = 	"Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png",
	[Enum.QuestClassification.Recurring] =	"Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png",
	[Enum.QuestClassification.Meta] = 		"Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png",

    [128] = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/Checklist.png",
};


local Conditions = {};
do
    ActivityUtil.Conditions = Conditions;

    Conditions.ItemReadyToTurnInWhenLooted_ItemID = {
        ShouldShowActivity = ConditionFuncs.OwnItem,
        IsReadyForTurnIn = ConditionFuncs.OwnItem,
    };

    Conditions.ItemReadyToTurnInWhenLooted_ItemName = {
        ShouldShowActivity = ConditionFuncs.OwnItem,
        IsReadyForTurnIn = ConditionFuncs.OwnItem,
        useItemName = true,
    };

    Conditions.KareshWarrant = {
        ShouldShowActivity = function()
            return GetCurrentRenownLevel(2658) >= 3
        end,
    };

    Conditions.DelversBounty = {
        ShouldShowActivity = function()
            return GetCurrentRenownLevel(2722) >= 2
        end,
    };
end


local TooltipFuncs = {};
do
    ActivityUtil.TooltipFuncs = TooltipFuncs;

    local function ShouldShowAdvancedTooltip()
        return GetDBBool("LandingPage_AdvancedTooltip");
    end

    --Similar to Bullet list
    local function Tooltip_AddListNewLine(tooltip, text, r, g, b)
        tooltip:AddLine("|TInterface/AddOns/Plumber/Art/Tooltip/TabChar_Dash:0:0|t"..text, r, g, b);
    end
    local function Tooltip_AddListInLine(tooltip, text, r, g, b)
        tooltip:AddLine("|TInterface/AddOns/Plumber/Art/Tooltip/TabChar_Space:0:0|t"..text, r, g, b);
    end

    local function Tooltip_AddListQuest(tooltip, questID, questName)
        if IsQuestFlaggedCompleted(questID) then
            Tooltip_AddListInLine(tooltip, questName, 0.251, 0.753, 0.251)
        else
            Tooltip_AddListInLine(tooltip, questName, 0.5, 0.5, 0.5);
        end
    end


    function TooltipFuncs.DevouredEnergyPod(tooltip)
        --Devoured Energy-Pod (20)  Translocated Gorger
        --Add item count if mount not learnt
        if API.IsMountCollected(2602) then return true end;
        local quantityRequired = 20;
        tooltip:AddLine(" ");
        API.AddCraftingReagentToTooltip(tooltip, 246240, quantityRequired);
        return true
    end

    function TooltipFuncs.WeeklyCofferKey_Shared(tooltip, title, dataKey)
        local loaded = true;
        local keepUpdating = false;

        tooltip:AddLine(title, 1, 1, 1, true);

        local tbl = addon.WeeklyRewardsConstant;

        if ShouldShowAdvancedTooltip() then
            for _, itemID in ipairs(tbl[dataKey]) do
                local itemName = C_Item.GetItemNameByID(itemID);
                local sources = tbl.ChestSources[itemID];

                if itemName then
                    tooltip:AddLine(" ");
                    Tooltip_AddListNewLine(tooltip, itemName, 1, 0.82, 0);
                else
                    loaded = false;
                end

                if sources then
                    local quests = sources.quests or (sources.questMap and DynamicQuestDataProvider:GetQuestsByMap(sources.questMap));
                    if quests then
                        if sources.questMap then
                            keepUpdating = true;
                            for _, questInfo in ipairs(quests) do
                                local questID = questInfo.questID;
                                local rewards, missingData = API.GetQuestRewards(questID);
                                if missingData then
                                    loaded = false;
                                end
                                if rewards then
                                    if rewards.items then
                                        for _, v in ipairs(rewards.items) do
                                            if v.id == itemID then
                                                local questName = API.GetQuestName(questID);
                                                if questName then
                                                    Tooltip_AddListQuest(tooltip, questID, questName);
                                                else
                                                    loaded = false;
                                                end
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            for _, questID in ipairs(quests) do
                                local questName = API.GetQuestName(questID);
                                if questName then
                                    Tooltip_AddListQuest(tooltip, questID, questName);
                                else
                                    loaded = false;
                                end
                            end
                        end
                    end
                end
            end
        else
            tooltip:AddLine(" ");
            for _, itemID in ipairs(tbl.MajorChests) do
                local name = C_Item.GetItemNameByID(itemID);
                if name then
                    tooltip:AddLine("- "..name, 1, 1, 1, false);
                else
                    loaded = false;
                end
            end
        end

        return loaded, keepUpdating
    end

    function TooltipFuncs.WeeklyRestoredCofferKey(tooltip)
        return TooltipFuncs.WeeklyCofferKey_Shared(tooltip, L["Weekly Coffer Key Tooltip"], "MajorChests");
    end

    function TooltipFuncs.WeeklyCofferKeyShard(tooltip)
        return TooltipFuncs.WeeklyCofferKey_Shared(tooltip, L["Weekly Coffer Key Shards Tooltip"], "MinorChests");
    end
end


local function CreateChildrenFromQuestList(list)
    local tbl = {};
    for i, questID in ipairs(list) do
        tbl[i] = {questID = questID};
    end
    return tbl
end
ActivityUtil.CreateChildrenFromQuestList = CreateChildrenFromQuestList;


local SortFuncs = {};
do
    function SortFuncs.DataIndex(a, b)
        return a.dataIndex < b.dataIndex
    end

    function SortFuncs.IncompleteFirst(a, b)
        if a.sortToTop ~= b.sortToTop then
            return a.sortToTop
        end

        if a.completed ~= b.completed then
            return b.completed
        end

        if (a.isOnQuest ~= nil) and (b.isOnQuest ~= nil) and a.isOnQuest ~= b.isOnQuest then
            return b.isOnQuest
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

        if a.questID and b.questID then
            return a.questID > b.questID
        end

        return a.name < b.name
    end
end


local function InitQuestData(info)
    local questClassification = info.questClassification or GetQuestClassification(info.questID);
    if HaveQuestData(info.questID) then
        info.questClassification = questClassification;
    end

    info.isOnQuest = IsOnQuest(info.questID);

    if info.isOnQuest then
        --print(API.GetQuestName(info.questID), info.questID, questClassification);
        info.icon = questClassification and InProgressQuestIconFile[questClassification];
    end

    if not info.atlas then
        info.atlas = questClassification and QuestIconAtlas[questClassification] or "QuestNormal";
    end
end


do  --DynamicQuestDataProvider  Dynamic Quests are acquired using Game API, instead of using a pre-determined table
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

    local DynamicQuestMaps = {
        --Automatically find repeatable quests from these maps
        --[uiMapID] = categoryID,
    };

    function DynamicQuestDataProvider:Reset()
        self.addedQuests = {};
        self.questsByMap = {};
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

    function DynamicQuestDataProvider:AddQuestsFromMap(uiMapID, categoryID)
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
                categoryID = categoryID,
                isCollapsed = IsCategoryCollapsed(categoryID),
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

    function DynamicQuestDataProvider:QueryQuests()
        for uiMapID, categoryID in pairs(DynamicQuestMaps) do
            self:AddQuestsFromMap(uiMapID, categoryID);
        end
    end

    function DynamicQuestDataProvider:GetQuestsByMap(uiMapID)
        return self.questsByMap[uiMapID]
    end


    addon.CallbackRegistry:Register("LandingPage.SetActivityQuestMaps", function(activityQuestMap)
        DynamicQuestMaps = activityQuestMap or {};
        DynamicQuestDataProvider:Reset();
    end);
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

        if v.isHeader and (v.areaID or v.factionID) then
            if v.areaID then
                local zoneName = API.GetZoneName(v.areaID);
                return zoneName, true
            end
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
            showActivity = true;
            flagQuest = nil;

            if entry.children then
                if not entry.icon then
                    entry.icon = InProgressQuestIconFile[128];
                end
                local completed = true;
                local totalChildren = #entry.children;
                local numCompletedChildren = 0;
                for k, v in ipairs(entry.children) do
                    flagQuest = v.questID;
                    if flagQuest then
                        if (v.accountwide and IsQuestFlaggedCompletedOnAccount(flagQuest)) or (not v.accountwide and IsQuestFlaggedCompleted(flagQuest)) then
                            numCompletedChildren = numCompletedChildren + 1;
                        else
                            completed = false;
                        end
                    end
                end
                entry.completed = completed;
                if entry.label then
                    entry.localizedName = format("%s/%s %s", numCompletedChildren, totalChildren, entry.label);
                end
            else
                flagQuest = entry.flagQuest or entry.questID;
                if entry.questID then
                    InitQuestData(entry);
                else
                    entry.isOnQuest = false;
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
            end

            if entry.conditions then
                local arg = entry.conditions.useItemName and entry.localizedName or entry.itemID;
                if entry.conditions.ShouldShowActivity then
                    showActivity = entry.conditions.ShouldShowActivity(arg);
                end
                if entry.conditions.IsActivityCompleted then
                    entry.completed = entry.conditions.IsActivityCompleted(arg);
                end
            end

            if entry.shownIfOnQuest then
                if hideCompleted then
                    if not entry.isOnQuest then
                        showActivity = false;
                    end
                else
                    if not (entry.completed or entry.isOnQuest) then
                        showActivity = false;
                    end
                end
            end

            if entry.completed then
                numCompleted = numCompleted + 1;
            elseif showActivity then
                anyIncomplted = true;
            end

            if showActivity then
                if entry.isDelveReputation then
                    if not entry.atlas then
                        entry.atlas = QuestIconAtlas.DELVES_BOUNTIFUL;
                    end

                    if not entry.tooltip then
                        entry.tooltip = DELVES_REP_TOOLTIP;
                    end
                end

                if entry.isWeeklyQuest then
                    if not entry.atlas then
                        entry.atlas = QuestIconAtlas.WEEKLY_QUEST;
                    end
                elseif entry.isDailyQuest then
                    if not entry.atlas then
                        entry.atlas = QuestIconAtlas.DAILY_QUEST;
                    end
                end

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
                    tsort(entries, SortFuncs.IncompleteFirst);
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
    --Wipe old data
    MapQuestData = nil;
    DynamicQuestDataProvider:Reset();
    DynamicQuestDataProvider:QueryQuests();


    local tbl = {};
    local n = 0;
    local numCompleted = 0;

    for _, category in ipairs(ActivityData) do
        category.isCollapsed = IsCategoryCollapsed(category.categoryID);
    end

    n, numCompleted = FlattenData(MapQuestData, n, tbl, numCompleted);
    n, numCompleted = FlattenData(ActivityData, n, tbl, numCompleted);

    for k, v in ipairs(tbl) do
        v.dataIndex = k;
    end

    SortedActivity = tbl;

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

        if v.categoryID then
            SetCategoryCollapsed(v.categoryID, v.isCollapsed);
        end

        --print(dataIndex, v.localizedName or v.name, v.isDynamicQuest, v.questMapID, v.isCollapsed);

        return v.isCollapsed
    end
end

function ActivityUtil.SetHideCompleted(state)
    ActivityUtil.hideCompleted = state;
end
addon.CallbackRegistry:RegisterSettingCallback("LandingPage_Activity_HideCompleted", ActivityUtil.SetHideCompleted);


addon.CallbackRegistry:Register("LandingPage.SetActivityData", function(data)
    if data then
        ActivityData = data;
    end
end);


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
