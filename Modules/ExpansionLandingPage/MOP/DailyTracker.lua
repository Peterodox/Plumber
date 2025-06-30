-- Log active dailies when speaking with the NPC

local _, addon = ...
local API = addon.API;
local L = addon.L;


local ipairs = ipairs;
local time = time;
local GetQuestID = GetQuestID;
local GetNumAvailableQuests = GetNumAvailableQuests;
local GetAvailableTitle = GetAvailableTitle;
local GetAvailableQuestInfo = GetAvailableQuestInfo;
local GetNumActiveQuests = GetNumActiveQuests;
local GetActiveTitle = GetActiveTitle;
local GetActiveQuestID = GetActiveQuestID;
local GetSecondsUntilDailyReset = C_DateAndTime.GetSecondsUntilDailyReset;
local GetAvailableQuests = C_GossipInfo.GetAvailableQuests;
local GetActiveQuests = C_GossipInfo.GetActiveQuests;


local function GetDailyResetStartTime()
    local current = time();
    local countdown = GetSecondsUntilDailyReset();
    return current + countdown
end

local DailyUtil = {};
addon.DailyUtil = DailyUtil;


local QuestStatus = {
    --[questID] = 0 (not found), 1 (not completed), 2 (completed)
};


local SV = {};  --SavedVariables
do
    function SV:LoadSavedVariables()
        local wipeOldData = false;
        local nextDailyReset = GetDailyResetStartTime();
        self.nextDailyReset = nextDailyReset;
        local delta = math.abs(nextDailyReset - ((PlumberDB.nextDailyReset or 0)));

        if delta > 60 then
            PlumberDB.nextDailyReset = nextDailyReset;
            wipeOldData = true;
        end

        if wipeOldData or not PlumberDB_PC.CompletedDailyQuests then
            PlumberDB_PC.CompletedDailyQuests = {};
        end
        self.CompletedDailyQuests = PlumberDB_PC.CompletedDailyQuests or {};

        if wipeOldData or (not PlumberDB.DailyQuestStatus_A) then
            --Alliance
            PlumberDB.DailyQuestStatus_A = {};
        end

        if wipeOldData or (not PlumberDB.DailyQuestStatus_H) then
            --Horde
            PlumberDB.DailyQuestStatus_H = {};
        end

        if UnitFactionGroup("player") == "Horde" then
            self.QuestStatus = PlumberDB.DailyQuestStatus_H;
        else
            self.QuestStatus = PlumberDB.DailyQuestStatus_A;
        end

        for questID, status in pairs(self.QuestStatus) do
            QuestStatus[questID] = status;
        end

        for questID in pairs(self.CompletedDailyQuests) do
            QuestStatus[questID] = 2;
        end
    end

    function SV:SetQuestCompleted(questID)
        self.CompletedDailyQuests = questID;
    end

    function SV:SetQuestStatus(questID, status)
        self.QuestStatus[questID] = status;
    end

    function SV:CheckDailyResetTime()
        local nextDailyReset = GetDailyResetStartTime();
        local delta = math.abs(nextDailyReset - ((self.nextDailyReset or 0)));
        if delta > 60 then
            self:LoadSavedVariables();
            return true
        end
        return false
    end
end


local EL = CreateFrame("Frame");
do
    EL:RegisterEvent("PLAYER_ENTERING_WORLD");

    EL:SetScript("OnEvent", function(self)
        SV:LoadSavedVariables();
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        self:RegisterEvent("GOSSIP_SHOW");
        self:RegisterEvent("QUEST_DETAIL");
        self:RegisterEvent("QUEST_GREETING");
        self:RegisterEvent("QUEST_TURNED_IN");
        self:SetScript("OnEvent", EL.OnEvent);
    end);

    function EL:OnEvent(event, ...)
        if event == "GOSSIP_SHOW" then
            self:HandleGossip();
        elseif event == "QUEST_DETAIL" then
            self:HandleQuestDetail();
        elseif event == "QUEST_GREETING" then
            self:HandleQuestGreeting();
        elseif event == "QUEST_TURNED_IN" then
            self:HandleQuestTurnedIn(...);
        end
    end

    function EL:HandleQuestDetail()
        local questID = GetQuestID();
        if questID then
            DailyUtil.TryFlagQuestActive(questID);
        end
    end

    function EL:HandleGossip()
        local availableQuests = GetAvailableQuests();
        local activeQuests = GetActiveQuests();
        local questID;

        for i, questInfo in ipairs(availableQuests) do
            questID = questInfo.questID;
            DailyUtil.TryFlagQuestActive(questID);
        end

        for i, questInfo in ipairs(activeQuests) do
            questID = questInfo.questID;
            DailyUtil.TryFlagQuestActive(questID);
        end
    end

    function EL:HandleQuestGreeting()
        local title, questID;

        for i = 1, GetNumAvailableQuests() do
            title = GetAvailableTitle(i);
            _, _, _, _, questID = GetAvailableQuestInfo(i);
            DailyUtil.TryFlagQuestActive(questID);
        end

        for i = 1, GetNumActiveQuests() do
            title = GetActiveTitle(i);
            questID = GetActiveQuestID(i);
            DailyUtil.TryFlagQuestActive(questID);
        end
    end

    function EL:HandleQuestTurnedIn(questID)
        DailyUtil.TryFlagQuestCompleted(questID);
    end
end


do  --DailyUtil
    function DailyUtil.AddQuestPool(quests)
        for _, questID in ipairs(quests) do
            QuestStatus[questID] = 0;
        end
    end

    function DailyUtil.TryFlagQuestActive(questID)
        if QuestStatus[questID] and QuestStatus[questID] == 0 then
            QuestStatus[questID] = 1;
            SV:SetQuestStatus(questID, 1);
        end
    end

    function DailyUtil.TryFlagQuestCompleted(questID)
        if QuestStatus[questID] then
            QuestStatus[questID] = 2;
            SV:SetQuestStatus(questID, 2);
            SV:SetQuestCompleted(questID);
        end
    end

    function DailyUtil.IsQuestActive(questID)
        return QuestStatus[questID] == 1 or QuestStatus[questID] == 2
    end

    function DailyUtil.IsQuestCompleted(questID)
        return QuestStatus[questID] == 2
    end

    function DailyUtil.CheckDailyResetTime()
        SV:CheckDailyResetTime();
    end
end