--- For modifying Blizzard frames that are load-on-demand.


local _, addon = ...

local BlizzardFrameUtil = CreateFrame("Frame");
addon.BlizzardFrameUtil = BlizzardFrameUtil;


local FrameToAddon = {
	-- [frameName] = addonName,

	-- HuntTable
	CovenantMissionFrame = "Blizzard_GarrisonUI",

	-- Housing_Macro, SourceAchievementLink, CatalogSearch(Retired)
	HousingDashboardFrame = "Blizzard_HousingDashboard",

	-- CatalogSearch(Retired)
	HouseEditorFrame = "Blizzard_HouseEditor",

	-- CatalystUI, StaticPopup_Confirm
	ItemInteractionFrame = "Blizzard_ItemInteractionUI",

	-- SourceAchievementLink
	MountJournal = "Blizzard_Collections",

	-- CraftSearchExtended(Retired)
	ProfessionsFrame = "Blizzard_Professions",

	-- OutfitSelect, TransmogRestorePending
	TransmogFrame = "Blizzard_Transmog",
};


local function RunFrameCallback(addonName, frameName, callback)
	if _G[frameName] then
		callback(_G[frameName]);
	else
		addon.API.PrintMessage(string.format("%s is loaded but %s is missing", addonName, frameName));
	end
end

local AddonCallbacks = {};

function BlizzardFrameUtil:OnEvent(event, addonName)
	if event == "ADDON_LOADED" then
		if AddonCallbacks[addonName] then
			for callback, frameName in pairs(AddonCallbacks[addonName]) do
				RunFrameCallback(addonName, frameName, callback);
			end
			AddonCallbacks[addonName] = nil;
			self:CheckQueue();
		end
	end
end

function BlizzardFrameUtil:CheckQueue()
	if next(AddonCallbacks) == nil then
		if self.anyCallback then
			self.anyCallback = nil;
			self:UnregisterEvent("ADDON_LOADED");
		end
	end
end

---Process a load-on-demand Blizzard Frame with a function
---@param frameName string The name of the Blizzard Frame
---@param modifierFunc function The frame will be sent into this function
function BlizzardFrameUtil:AddFrameModifier(frameName, modifierFunc)
	local addonName = FrameToAddon[frameName];
	if not addonName then return; end


	if C_AddOns.IsAddOnLoaded(addonName) then
		RunFrameCallback(addonName, frameName, modifierFunc);
	else
		if not AddonCallbacks[addonName] then
			AddonCallbacks[addonName] = {};
		end
		AddonCallbacks[addonName][modifierFunc] = frameName;

		if not self.anyCallback then
			self.anyCallback = true;
			self:RegisterEvent("ADDON_LOADED");
			self:SetScript("OnEvent", self.OnEvent);
		end
	end
end

---Remove a frame modifierFunc
---@param frameName string The name of the Blizzard Frame
---@param modifierFunc function The modifier to be removed
function BlizzardFrameUtil:RemoveFrameModifier(frameName, modifierFunc)
	local addonName = FrameToAddon[frameName];
	if not (addonName and AddonCallbacks[addonName]) then return; end

	AddonCallbacks[addonName][modifierFunc] = nil;

	if next(AddonCallbacks[addonName]) == nil then
		AddonCallbacks[addonName] = nil;
	end

	self:CheckQueue();
end
