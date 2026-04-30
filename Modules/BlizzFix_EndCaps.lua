local _, addon = ...

local UIParentTracker;

local function TempFix_RestoreActionBarEndCaps()
	--Something happened in 12.0.5 causing EndCaps (gryphons) to appear after Hide/Show UI
	--BorderArt seems unaffected

	MainActionBar.EndCaps:SetShown(MainActionBar.BorderArt:IsShown());
end

local function OnEvent()
	-- Just one UPDATE_OVERRIDE_ACTIONBAR
	TempFix_RestoreActionBarEndCaps();
end

local function EnableModule(state)
	if state then
		if not UIParentTracker then
			UIParentTracker = CreateFrame("Frame", nil, UIParent);

			UIParentTracker:SetScript("OnShow", function()
				if UIParentTracker.enabled then
					TempFix_RestoreActionBarEndCaps();
				end
			end);

			UIParentTracker:SetScript("OnEvent", OnEvent);
		end
		UIParentTracker.enabled = true;
		UIParentTracker:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
		TempFix_RestoreActionBarEndCaps();
	else
		if UIParentTracker then
			UIParentTracker.enabled = false;
			UIParentTracker:UnregisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
		end
	end
end

do
	local moduleData = {
		name = addon.L["ModuleName BlizzFixActionBarArt"],
		dbKey = "BlizzFixActionBarArt",
		description = addon.L["ModuleDescription BlizzFixActionBarArt"],
		toggleFunc = EnableModule,
		moduleAddedTime = 1755200000,
		categoryKeys = {
			"Housing",
		},
	};

	addon.ControlCenter:AddModule(moduleData);
end
