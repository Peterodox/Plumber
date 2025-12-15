-- Press hotkey to cycle through / super track different quests


local _, addon = ...


local function CompareQuestWatchInfos(info1, info2)
	local quest1, quest2 = info1.quest, info2.quest;

    if quest1:IsCampaign() ~= quest2:IsCampaign() then
        return quest1:IsCampaign()
    end

	if quest1:IsCalling() ~= quest2:IsCalling() then
		return quest1:IsCalling();
	end

	if quest1.overridesSortOrder ~= quest2.overridesSortOrder then
		return quest1.overridesSortOrder;
	end

	return info1.index < info2.index;
end

local function FocusQuestByDelta(delta)
    local total = C_QuestLog.GetNumQuestWatches();
    if total < 1 then
        return
    end

    local trackedQuestID = C_SuperTrack.GetSuperTrackedQuestID() or 0;
    local QuestCache = QuestCache;
    local GetQuestIDForQuestWatchIndex = C_QuestLog.GetQuestIDForQuestWatchIndex;   --Quests in Objective Trackers are sorted
    --https://sourcegraph.com/github.com/Gethe/wow-ui-source@beta/-/blob/Interface/AddOns/Blizzard_ObjectiveTracker/Blizzard_ObjectiveTrackerModule.lua
    --Objective Tracker may not be able to display all tracked quests due to size
    --usedBlocks

    local objectiveTrackers = {"CampaignQuestObjectiveTracker", "QuestObjectiveTracker"};
    local numShown = 0;
    for _, name in ipairs(objectiveTrackers) do
        local f = _G[name];
        if f and f:IsShown() and f.usedBlocks then
            for _, template in pairs(f.usedBlocks) do
                for _, block in pairs(template) do
                    numShown = numShown + 1;
                end
            end
        end
    end

    local infos = {};
    for i = 1, numShown do
		local questID = GetQuestIDForQuestWatchIndex(i);
		if questID then
			local quest = QuestCache:Get(questID);
			table.insert(infos, { quest = quest, index = i, questID = questID});
		end
	end
    table.sort(infos, CompareQuestWatchInfos);

    local firstQuestID = infos[1].questID;
    local lastQuestID = infos[#infos].questID;
    local newQuestID;

    for i, v in ipairs(infos) do
        if v.questID == trackedQuestID then
            if delta > 0 then
                if infos[i + 1] then
                    newQuestID = infos[i + 1].questID;
                else
                    newQuestID = firstQuestID;
                end
            else
                if infos[i - 1] then
                    newQuestID = infos[i - 1].questID;
                else
                    newQuestID = lastQuestID;
                end
            end
            break
        end
    end

    if not newQuestID then
        if delta > 0 then
            newQuestID = firstQuestID;
        else
            newQuestID = lastQuestID;
        end
    end

    C_SuperTrack.SetSuperTrackedQuestID(newQuestID);
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