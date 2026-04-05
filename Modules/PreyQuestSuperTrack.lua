local _, addon = ...

local Module = {};

function Module:PingQuestIDCallback(questID)
	local preyQuest = C_QuestLog.GetActivePreyQuest();
	if preyQuest and preyQuest == questID then
		--Only triggers when clicking the UIWidget, ignore QuestObjectiveHeader
		local focus = addon.API.GetMouseFocus();
		if focus and focus.progressState then
			if not self.pauseUpdate then
				self.pauseUpdate = true;
				--Add a delay so the player can see the pin turns yellow (tracked)
				C_Timer.After(0.5, function()
					self.pauseUpdate = nil;
					C_SuperTrack.SetSuperTrackedQuestID(questID);
				end);
			end
		end
	end
end

function Module.EnableModule(state)
	if state and not Module.enabled then
		Module.enabled = true;
		EventRegistry:RegisterCallback("MapCanvas.PingQuestID", Module.PingQuestIDCallback, Module);
	elseif (not state) and Module.enabled then
		Module.enabled = nil;
		EventRegistry:UnregisterCallback("MapCanvas.PingQuestID", Module);
	end
end

local moduleData = {
	name = addon.L["ModuleName PreyQuestSuperTrack"],
	dbKey = "PreyQuestSuperTrack",
	description = addon.L["ModuleDescription PreyQuestSuperTrack"],
	toggleFunc = Module.EnableModule,
	moduleAddedTime = 1775400000,
	categoryKeys = {
		"Quest",
	},
};

addon.ControlCenter:AddModule(moduleData);
