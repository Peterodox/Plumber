local _, addon = ...
local API = addon.API;

local EL = CreateFrame("Frame");
addon.QuestAreaTrigger = EL;

local QuestCallbacks = {};


local IsOnQuest = C_QuestLog.IsOnQuest;
local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted;
local IsInsideQuestBlob = C_Minimap.IsInsideQuestBlob;

if addon.IsToCVersionEqualOrNewerThan(110007) and IsInsideQuestBlob then
    function EL:ListenQuestBlobEvent(state)
        if state then
            self:RegisterEvent("PLAYER_ENTERING_WORLD");
            self:RegisterEvent("PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED");
        else
            self:UnregisterEvent("PLAYER_ENTERING_WORLD");
            self:UnregisterEvent("PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED");
        end
    end
else
    function EL:ListenQuestBlobEvent()

    end

    function IsInsideQuestBlob(questID)
        return false
    end
end


do
    function EL:OnEvent(event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            self:UnregisterEvent(event);
            self:RequestUpdateWatcher();
        elseif event == "PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED" then
            self:OnQuestBlobStateChanged(...);
        elseif event == "QUEST_ACCEPTED" then
            self:OnQuestAccepted(...)
        end
    end
    EL:SetScript("OnEvent", EL.OnEvent);
    EL:RegisterEvent("PLAYER_ENTERING_WORLD");  --debug

    function EL:OnQuestBlobStateChanged(questID, isInside)
        if questID and QuestCallbacks[questID] then
            for _, callback in ipairs(QuestCallbacks[questID]) do
                callback(questID, isInside)
            end
        end
    end

    function EL:OnQuestAccepted(questID)
        if QuestCallbacks[questID] then
            self:ListenQuestBlobEvent(true);
            if IsInsideQuestBlob(questID) then
                self:OnQuestBlobStateChanged(questID, true);
            end
        end
    end
end


function EL:AddAreaChangedCallback(questID, callback)
    if not QuestCallbacks[questID] then
        QuestCallbacks[questID] = {};
    end

    table.insert(QuestCallbacks[questID], callback)
end

function EL:UpdateWatcher()
    local anyActiveQuest;
    local anyIncompleteQuest;

    for questID, callbacks in pairs(QuestCallbacks) do
        if IsOnQuest(questID) then
            anyActiveQuest = true;
        end

        if not IsQuestFlaggedCompleted(questID) then
            anyIncompleteQuest = true;
        end
    end

    if anyActiveQuest then
        self:ListenQuestBlobEvent(true);
    else
        self:ListenQuestBlobEvent(false);
    end

    if anyIncompleteQuest then
        self:RegisterEvent("QUEST_ACCEPTED");
    else
        self:UnregisterEvent("QUEST_ACCEPTED");
    end
end

function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0 then
        self.t = 0;
        self:SetScript("OnUpdate", nil);
        self:UpdateWatcher();
    end
end

function EL:RequestUpdateWatcher()
    self.t = -1;
    self:SetScript("OnUpdate", self.OnUpdate);
end
