--https://warcraft.wiki.gg/wiki/Mists_of_Pandaria_daily_quests

local _, addon = ...
local API = addon.API;
local L = addon.L;
local DailyUtil = addon.DailyUtil;


local ActivityUtil = {};
addon.ActivityUtil = ActivityUtil;


local IsQuestActiveFromCache = DailyUtil.IsQuestActive;
local IsQuestCompletedFromCache = DailyUtil.IsQuestCompleted;


ActivityUtil.hideCompleted = false;
ActivityUtil.collapsedHeader = {};


local ipairs = ipairs;
local tsort = table.sort;

local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted;
local IsOnQuest = C_QuestLog.IsOnQuest;
local GetFactionInfoByID = GetFactionInfoByID;


local DAILY_QUEST = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/DailyQuestAvailable.png";  --"QuestNormal"


local function ShownIfOnQuest(questID)
    return questID and IsOnQuest(questID)
end

local function IsCategoryCollapsed(categoryID)
    return addon.GetDBBool("LandingPage_Activity_Collapsed_"..categoryID)
end

local function SetCategoryCollapsed(categoryID, isCollapsed)
    return addon.SetDBValue("LandingPage_Activity_Collapsed_"..categoryID, isCollapsed, true)
end

local QuestPools = {};
do  --QuestPools (Random quests from pool)
    QuestPools.Anglers = {
        --3 quests plus up to 3 rare fish quests
        30613, 30754, 30588, 30658, 30586, 30753, 30678, 30763, 30698, 30584, 30700, 30701, 30585, 30598,
        31443, 31446, 31444,
    };

    QuestPools.Tillers = {
        --Completing 1 quest flags 5 quests as completed
        31672, 31942, 31673, 31941, 31670, 31669, 31674, 31675, 31943, 31671,
        32642, 32643, 32647, 32648, 32645, 32646, 32649, 32650, 32942, 32943, 32653, 32657, 32658, 32659,
        30337, 30335, 30334, 30336, 30333,
        30318, 30322, 30324, 30319, 30326, 30323, 30317, 30321, 30325, 30327,
        30471, 30474, 30473, 30475, 30479, 30477, 30478, 30476, 30472, 30470,
        30329, 30332, 30331, 30328, 30330,
    };

    QuestPools.Klaxxi = {
        31216, 31808,
    };

    QuestPools.Chiji = {
        30725, 30726, 30727, 30728, 30729, 30730, 30731, 30732, 30733, 30734, 30735, 30736, 30737, 30738, 30739, 30740,
    };

    QuestPools.Yulon = {
        30065, 30063, 30006, 30066, 30064,
        30068, 30067,
    };

    QuestPools.Xuen = {
        31517, 31491, 31492,
    };

    QuestPools.ShadowPan = {
        31198, 31200, 31199, 31201, 31196, 31197, 31204, 31203,
        31118, 31114, 31113, 31119, 31116, 31117, 31120,
    };

    QuestPools.CloudSerpent = {
        30151, 31704, 30150, 31705,
        30157, 30156, 30158, 31194,
        31699, 31700, 31703,
        30154, 30155, 31698, 31701, 31702,
        30152, 31717, 31718, 31719, 31721, 31720,
        31707, 31709, 31708, 31710, 31706, 31711,
        31713, 31712, 30159, 31714, 31715,
    };

    QuestPools.GoldenLotus = {
        30307, 31755, 30312, 31760, 31762, 30309, 30308, 30310, 31757, 31754, 30320, 31756, 31758,
        30286, 30285, 30289, 30290, 31293, 30288,
        30196, 30193, 30231, 30263, 30238, 30232, 30237, 30194, 30192, 30191, 30190, 30195,
        30283, 30282, 30293, 30292, 30281,
        30314, 30313, 30341, 30284, 30342, 30338, 30265, 30291, 30340, 30339,
        30298, 30301, 30481, 30305, 30299, 30300,
        30200, 30204, 30304, 30206, 30205, 30228, 30226,
        30306, 30242, 30240, 30266, 30243, 30245, 30244, 30261, 30246, 30444,
        30297, 30296,
        30236, 30239, 30235,
        30302, 30280,
        30225, 30227, 30277,
        30248, 30249, 30251, 30264,
        31136,
        30233, 30482, 30234,
    };

    for k, questPool in pairs(QuestPools) do
        DailyUtil.AddQuestPool(questPool);
    end

    DailyUtil.AddAugustCelestialQuests(QuestPools.Chiji, 1);
    DailyUtil.AddAugustCelestialQuests(QuestPools.Yulon, 2);
    DailyUtil.AddAugustCelestialQuests(QuestPools.Xuen, 4);
end


local QuestSets = {};
do  --QuestSets (One set of quest per day. Detecting a quest to find the active set)
    QuestSets.Klaxxi = {
        {31267, 31268, 31024, 31270, 31269, 31271, 31272},
        {31231, 31235, 31238, 31232, 31233, 31234, 31237, 31677},
        {31109, 31494, 31487, 31496, 31503, 31502, 31504, 31599},
        {31111, 31505, 31506, 31507, 31509, 31508, 31510, 31598},
    };

    QuestSets.Chiji = {
        {30718, 30716, 30717},
    };

    QuestSets.Niuzao = {
        {30956, 30959, 30957, 30958},
        {30954, 30952, 30953, 30955},
    };

    QuestSets.Xuen = {
        {30879, 30881, 30883, 30907},
        {30880, 30882, 30885, 30902},
    };

    QuestSets.ShadowPan = {
        {31039, 31040, 31041, 31046, 31049},
        {31042, 31043, 31047, 31105, 31061},
        {31044, 31045, 31048, 31106, 31062},
    };

    for k, questSet in pairs(QuestSets) do
        DailyUtil.AddQuestSet(questSet);
    end

    DailyUtil.AddAugustCelestialQuests(QuestSets.Chiji, 1);
    DailyUtil.AddAugustCelestialQuests(QuestSets.Niuzao, 3);
    DailyUtil.AddAugustCelestialQuests(QuestSets.Xuen, 4);
end


local QuestUnlockConditions = {};
do
    local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo;

    QuestUnlockConditions.KlaxxiParagonUnlocked = {};

    function QuestUnlockConditions.RefreshKlaxxiParagon()
        local tbl = {};
        local _, completed;
        for i = 1, 10 do
            _, _, completed = GetAchievementCriteriaInfo(7312, i);
            tbl[i] = completed;
        end
        QuestUnlockConditions.KlaxxiParagonUnlocked = tbl;
    end

    function QuestUnlockConditions.AddKlaxxiParagonToTooltip(tooltip)
        --Only show locked npc
        local text, _, completed;
        local noHeader = true;
        for i = 1, 10 do
            text, _, completed = GetAchievementCriteriaInfo(7312, i);
            if not completed then
                if noHeader then
                    noHeader = false;
                    tooltip:AddLine(" ");
                    tooltip:AddLine(L["Unavailable Klaxxi Paragons"], 1, 0.82, 0, true);
                end
                tooltip:AddLine("- "..text, 0.5, 0.5, 0.5, true);
            end
        end
    end

    function QuestUnlockConditions.Kilruk()
        return QuestUnlockConditions.KlaxxiParagonUnlocked[1]
    end

    function QuestUnlockConditions.Malik()
        return QuestUnlockConditions.KlaxxiParagonUnlocked[2]
    end

    function QuestUnlockConditions.Iyyokuk()
        return QuestUnlockConditions.KlaxxiParagonUnlocked[3]
    end

    function QuestUnlockConditions.Kaztik()
        return QuestUnlockConditions.KlaxxiParagonUnlocked[4]
    end

    function QuestUnlockConditions.Korven()
        return QuestUnlockConditions.KlaxxiParagonUnlocked[5]
    end

    function QuestUnlockConditions.Karoz()
        return QuestUnlockConditions.KlaxxiParagonUnlocked[6]
    end

    function QuestUnlockConditions.Rikkal()
        return QuestUnlockConditions.KlaxxiParagonUnlocked[7]
    end

    function QuestUnlockConditions.Skeer()
        return QuestUnlockConditions.KlaxxiParagonUnlocked[8]
    end

    function QuestUnlockConditions.Hisek()
        return QuestUnlockConditions.KlaxxiParagonUnlocked[9]
    end

    function QuestUnlockConditions.Xaril()
        return QuestUnlockConditions.KlaxxiParagonUnlocked[10]
    end
end


local QuestXCondition = {};
do
    QuestXCondition[31267] = QuestUnlockConditions.Kilruk;
    QuestXCondition[31235] = QuestUnlockConditions.Kilruk;
    QuestXCondition[31231] = QuestUnlockConditions.Kilruk;
    QuestXCondition[31109] = QuestUnlockConditions.Kilruk;
    QuestXCondition[31111] = QuestUnlockConditions.Kilruk;
    QuestXCondition[31505] = QuestUnlockConditions.Kilruk;
    QuestXCondition[31677] = QuestUnlockConditions.Kilruk;

    QuestXCondition[31268] = QuestUnlockConditions.Kaztik;
    QuestXCondition[31024] = QuestUnlockConditions.Kaztik;
    QuestXCondition[31238] = QuestUnlockConditions.Kaztik;
    QuestXCondition[31494] = QuestUnlockConditions.Kaztik;
    QuestXCondition[31487] = QuestUnlockConditions.Kaztik;
    QuestXCondition[31506] = QuestUnlockConditions.Kaztik;
    QuestXCondition[31808] = QuestUnlockConditions.Kaztik;

    QuestXCondition[31270] = QuestUnlockConditions.Korven;
    QuestXCondition[31269] = QuestUnlockConditions.Korven;
    QuestXCondition[31232] = QuestUnlockConditions.Korven;
    QuestXCondition[31233] = QuestUnlockConditions.Korven;
    QuestXCondition[31496] = QuestUnlockConditions.Korven;
    QuestXCondition[31507] = QuestUnlockConditions.Korven;

    QuestXCondition[31271] = QuestUnlockConditions.Rikkal;
    QuestXCondition[31234] = QuestUnlockConditions.Rikkal;
    QuestXCondition[31503] = QuestUnlockConditions.Rikkal;
    QuestXCondition[31502] = QuestUnlockConditions.Rikkal;
    QuestXCondition[31509] = QuestUnlockConditions.Rikkal;
    QuestXCondition[31508] = QuestUnlockConditions.Rikkal;

    QuestXCondition[31272] = QuestUnlockConditions.Hisek;
    QuestXCondition[31237] = QuestUnlockConditions.Hisek;
    QuestXCondition[31504] = QuestUnlockConditions.Hisek;
    QuestXCondition[31510] = QuestUnlockConditions.Hisek;

    QuestXCondition[31216] = QuestUnlockConditions.Xaril;
end


local CategoryCandidates = {
    Chiji = {isHeader = true, subFactionID = 1, name = "The August Celestials: Cradle of Chi-Ji", factionID = 1341, categoryID = 13411, uiMapID = 418, areaID = 6155, questsPerDay = 4, questPool = QuestPools.Chiji, questSet = QuestSets.Chiji,
            staticEntries = {
                {questID = 31378, shownIfOnQuest = true},
                {questID = 31379, shownIfOnQuest = true},
            },
        },
    Yulon = {isHeader = true, subFactionID = 2, name = "The August Celestials: Temple of the Jade Serpent", factionID = 1341, categoryID = 13412, uiMapID = 371, areaID = 5975, questsPerDay = 4, questPool = QuestPools.Yulon,
            staticEntries = {
                {questID = 31376, shownIfOnQuest = true},
                {questID = 31377, shownIfOnQuest = true},
            },
        },
    Niuzao = {isHeader = true, subFactionID = 3, name = "The August Celestials: Niuzao Temple", factionID = 1341, categoryID = 13413, uiMapID = 388, areaID = 6213, fixedQuestsPerDay = 4, questSet = QuestSets.Niuzao,
            staticEntries = {
                {questID = 31382, shownIfOnQuest = true},
                {questID = 31383, shownIfOnQuest = true},
            },
        },
    Xuen = {isHeader = true, subFactionID = 4, name = "The August Celestials: Temple of the White Tiger", factionID = 1341, categoryID = 13414, uiMapID = 379, areaID = 6174, fixedQuestsPerDay = 5, questPool = QuestPools.Xuen, questSet = QuestSets.Xuen,
            staticEntries = {
                {questID = 31380, shownIfOnQuest = true},
                {questID = 31381, shownIfOnQuest = true},
            },
        },
};

local function CategoryDataGetter_AugustCelestials()
    local subFactionID = DailyUtil.TryGetActiveAugustCelestial();
    if subFactionID then
        if subFactionID == 1 then
            return CategoryCandidates.Chiji
        elseif subFactionID == 2 then
            return CategoryCandidates.Yulon
        elseif subFactionID == 3 then
            return CategoryCandidates.Niuzao
        elseif subFactionID == 4 then
            return CategoryCandidates.Xuen
        end
    end
end

local function GetOverrideCategory(category)
    if category.categoryDataGetter then
        return category.categoryDataGetter() or category;
    else
        return category
    end
end

local ActivityData = {  --Constant
    --questsPerDay: number of quests each day from the questPool. Need to add the # from questSet
    {isHeader = true, name = "The Klaxxi", factionID = 1337, categoryID = 1337, uiMapID = 422, questsPerDay = 1, questPool = QuestPools.Klaxxi, questSet = QuestSets.Klaxxi, tooltipSetter = QuestUnlockConditions.AddKlaxxiParagonToTooltip},
    {isHeader = true, name = "The August Celestials", factionID = 1341, categoryID = 1341, uiMapID = 390, categoryDataGetter = CategoryDataGetter_AugustCelestials, tooltip = L["Quest Hub Instruction Celestials"]},
    {isHeader = true, name = "Shado-Pan", factionID = 1270, categoryID = 1270, uiMapID = 388, fixedQuestsPerDay = 5, questPool = QuestPools.ShadowPan, questSet = QuestSets.ShadowPan,},
    {isHeader = true, name = "Order of the Cloud Serpent", factionID = 1271, categoryID = 1271, uiMapID = 371, fixedQuestsPerDay = 7, questPool = QuestPools.CloudSerpent,
        staticEntries = {
            {questID = 30149, name = "A Feast for the Senses"},
            {questID = 30147, name = "Fragments of the Past"},
            {questID = 30148, name = "Just a Flesh Wound"},
            {questID = 30146, name = "Snack Time"},
        };
    },
    {isHeader = true, name = "Golden Lotus", factionID = 1269, categoryID = 1269, uiMapID = 390, questsPerDay = 5, questPool = QuestPools.GoldenLotus},
    {isHeader = true, name = "The Anglers", factionID = 1302, categoryID = 1302, uiMapID = 418, questsPerDay = 6, questPool = QuestPools.Anglers},
    {isHeader = true, name = "The Tillers", factionID = 1272, categoryID = 1272, uiMapID = 376, questsPerDay = 6, questPool = QuestPools.Tillers},
};

local function CreateQuestCounter(questPool, numCompleted, questsPerDay, tooltip)
    local tbl = {};
    numCompleted = numCompleted or 0;
    local completed;

    if questPool then
        for _, questID in ipairs(questPool) do
            if DailyUtil.IsQuestCompleted(questID) then
                numCompleted = numCompleted + 1;
                if numCompleted >= questsPerDay then
                    completed = true;
                    break
                end
            end
        end
    end

    completed = questsPerDay > 0 and numCompleted >= questsPerDay;
    if questsPerDay == 0 then
        questsPerDay = "?";
    end

    tbl.localizedName = string.format("%s: %s/%s", L["Completed"], numCompleted, questsPerDay);
    tbl.completed = completed;
    tbl.dataIndex = 128;    --At bottom
    tbl.sortToTop = true;
    tbl.alwaysShown = true;
    tbl.ignoredInQuestCount = true;
    tbl.icon = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/Checklist.png";
    if not completed then
        tbl.tooltip = tooltip or L["Visit Quest Hub To Log Quests"];
    end

    return tbl
end

local function BuildEntriesForCategory(category)
    category = GetOverrideCategory(category);

    local uiMapID = category.uiMapID;
    local entries = {};
    local n = 0;

    if category.staticEntries then
        for _, entry in ipairs(category.staticEntries) do
            n = n + 1;
            entry.icon = DAILY_QUEST;
            if not entry.uiMapID then
                entry.uiMapID = uiMapID;
            end
            entries[n] = entry;
        end
    end

    local numCompleted = 0;
    local questsPerDay = category.questsPerDay or 0;
    local unlockCondition;

    if category.questPool then
        for _, questID in ipairs(category.questPool) do
            unlockCondition = QuestXCondition[questID];
            if (not unlockCondition) or (unlockCondition()) then
                n = n + 1;
                entries[n] = {
                    questID = questID,
                    icon = DAILY_QUEST,
                    shownIfOnQuest = true,
                    uiMapID = uiMapID,
                };
            end
        end
    end


    if category.questSet then
        local questSetIndex, completed;
        local numAvailable = 0;
        for i, quests in ipairs(category.questSet) do
            for _, questID in ipairs(quests) do
                if IsQuestActiveFromCache(questID) then
                    questSetIndex = i;
                    for _, questID in ipairs(quests) do
                        unlockCondition = QuestXCondition[questID];
                        if (not unlockCondition) or (unlockCondition()) then
                            n = n + 1;
                            numAvailable = numAvailable + 1;
                            completed = IsQuestFlaggedCompleted(questID);
                            entries[n] = {
                                questID = questID,
                                icon = DAILY_QUEST,
                                shownIfOnQuest = true,
                                uiMapID = uiMapID,
                                isActive = true,
                                completed = completed,
                            };

                            if completed then
                                DailyUtil.TryFlagQuestCompleted(questID);
                                numCompleted = numCompleted + 1;
                            end
                        end
                    end
                    questsPerDay = questsPerDay + numAvailable;
                    break
                end
            end
            if questSetIndex then
                break
            end
        end
    end


    if category.fixedQuestsPerDay then
        questsPerDay = category.fixedQuestsPerDay;
    end


    local counterEntry = CreateQuestCounter(category.questPool, numCompleted, questsPerDay, category.tooltip);
    counterEntry.tooltipSetter = category.tooltipSetter;
    n = n + 1;
    entries[n] = counterEntry;


    category.entries = entries;
end


local function GetQuestPoolProgress(questPool)
    local completed = 0;
    local active = 0;
    for _, questID in ipairs(questPool) do
        if IsQuestFlaggedCompleted(questID) then
            completed = completed + 1;
        elseif IsOnQuest(questID) then
            active = active + 1;
        end
    end
    print("completed:", completed, "in progress:", active);
end

local function GetQuestGroupTotal(questPool)
    print("total:", #questPool)
    return #questPool
end


local InProgressQuestIconFile = {
	[Enum.QuestClassification.Normal] = 	"Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressRed.png",
	[Enum.QuestClassification.Questline] = 	"Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png",
	[Enum.QuestClassification.Recurring] =	"Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png",   --5
	[Enum.QuestClassification.Meta] = 		"Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png",
};

local function InitQuestData(info)
    --Most quests are daily

    info.isOnQuest = IsOnQuest(info.questID);

    if info.isOnQuest then
        info.icon = InProgressQuestIconFile[5];
    else
        info.icon = DAILY_QUEST;
    end

    if info.isActive == nil then
        info.isActive = IsQuestActiveFromCache(info.questID);
    end
end

--[[
local EL = CreateFrame("Frame");
EL:RegisterEvent("QUEST_ACCEPTED");
EL:RegisterEvent("QUEST_TURNED_IN");
EL:RegisterEvent("PLAYER_ENTERING_WORLD");
EL:SetScript("OnEvent", function(self, event, ...)
    if event == "QUEST_ACCEPTED" or event == "QUEST_TURNED_IN" then
        GetQuestPoolProgress(QuestPools.Tillers);
    elseif event == "PLAYER_ENTERING_WORLD" then
        GetQuestPoolProgress(QuestPools.Tillers);
        GetQuestGroupTotal(QuestPools.Tillers);
    end
end);
--]]



local SortFuncs = {};
do
    function SortFuncs.DataIndex(a, b)
        if a.sortToTop ~= b.sortToTop then
            return a.sortToTop
        end
        return a.dataIndex < b.dataIndex
    end

    function SortFuncs.IncompleteFirst(a, b)
        if a.sortToTop ~= b.sortToTop then
            return a.sortToTop
        end

        if a.completed ~= b.completed then
            return b.completed
        end

        if a.isActive ~= b.isActive then
            return a.isActive
        end

        if a.isOnQuest ~= b.isOnQuest then
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
                if v.areaID then
                    local zoneName = API.GetZoneName(v.areaID);
                    if zoneName then
                        name = name .. ": "..zoneName;
                    end
                end
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
        return ShownIfOnQuest(data.questID) or IsQuestActiveFromCache(data.questID)
    end

    return true
end


do
    local function IndexData(activityData)
        local n = 0;
        for _, category in ipairs(activityData) do
            n = n + 1;
            category = GetOverrideCategory(category);
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
        numCompleted = numCompleted or 0;

        for _, category in ipairs(activityData) do
            category = GetOverrideCategory(category);

            local numEntries = 0;
            local entries = {};
            local flagQuest;
            local showActivity;

            for _, entry in ipairs(category.entries) do
                flagQuest = entry.flagQuest or entry.questID;
                showActivity = true;

                if entry.questID then
                    InitQuestData(entry);
                else
                    entry.isOnQuest = false;
                end

                if flagQuest then
                    entry.completed = entry.completed or IsQuestCompletedFromCache(flagQuest);
                elseif entry.conditions then
                    if entry.conditions.ShouldShowActivity then
                        showActivity = entry.conditions.ShouldShowActivity();
                    end
                    if entry.conditions.IsActivityCompleted then
                        entry.completed = entry.conditions.IsActivityCompleted();
                    end
                else
                    entry.completed = entry.completed or false;
                end

                if entry.shownIfOnQuest then
                    if entry.isActive then
                        showActivity = true;
                    else
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
                end

                if entry.completed and not entry.ignoredInQuestCount then
                    numCompleted = numCompleted + 1;
                end

                if showActivity then
                    if hideCompleted then
                        if entry.isHeader or entry.alwaysShown or (not entry.completed) then
                            numEntries = numEntries + 1;
                            entries[numEntries] = entry;
                        end
                    else
                        numEntries = numEntries + 1;
                        entries[numEntries] = entry;
                    end
                end
            end

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

        return n, numCompleted
    end

    function ActivityUtil.GetSortedActivity()
        DailyUtil.CheckDailyResetTime();
        QuestUnlockConditions.RefreshKlaxxiParagon();

        local tbl = {};
        local n = 0;
        local numCompleted = 0;

        for _, category in ipairs(ActivityData) do
            category.isCollapsed = category.categoryID and IsCategoryCollapsed(category.categoryID);
            BuildEntriesForCategory(category);
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
                entry.completed = IsQuestCompletedFromCache(flagQuest);
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

            return v.isCollapsed
        end
    end

    function ActivityUtil.SetHideCompleted(state)
        ActivityUtil.hideCompleted = state;
    end
    addon.CallbackRegistry:RegisterSettingCallback("LandingPage_Activity_HideCompleted", ActivityUtil.SetHideCompleted);
end