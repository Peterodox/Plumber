-- Press hotkey to cycle through / super track different quests


local _, addon = ...


local function FocusQuestByDelta(delta)
    local total = C_QuestLog.GetNumQuestWatches();
    if total < 1 then
        return
    end

    local oldIndex, newIndex;
    local trackedQuestID = C_SuperTrack.GetSuperTrackedQuestID() or 0;
    local GetQuestIDForQuestWatchIndex = C_QuestLog.GetQuestIDForQuestWatchIndex;

    for i = 1, total do
        if GetQuestIDForQuestWatchIndex(i) == trackedQuestID then
            oldIndex = i;
        end
    end

    if not oldIndex then
        if delta > 0 then
            newIndex = 1;
        else
            newIndex = total;
        end
    else
        newIndex = oldIndex + (delta < 0 and -1 or 1);
        if newIndex > total then
            newIndex = 1;
        elseif newIndex < 1 then
            newIndex = total;
        end
    end
    local questID = GetQuestIDForQuestWatchIndex(newIndex);
    C_SuperTrack.SetSuperTrackedQuestID(questID);
end

local function FocusNextQuest()
    FocusQuestByDelta(1);
end

local function FocusPreviousQuest()
    FocusQuestByDelta(-1);
end


--Globals
_G.Plumber_FocusNextQuest = FocusNextQuest;
_G.Plumber_FocusPreviousQuest = FocusPreviousQuest;


do  --Module Registry
    local moduleData = {
        name = addon.L["ModuleName QuestWatchCycle"],
        dbKey = "QuestWatchCycle",
        description = addon.L["ModuleDescription QuestWatchCycle"],
        categoryID = 1,
        uiOrder = 1,
        moduleAddedTime = 1765500000,
        virtual = true,
		categoryKeys = {
			"Quest",
		},
        searchTags = {
            "Console",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end