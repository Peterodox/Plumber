--We override ExpansionLandingPageMinimapButton

local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;
local FactionUtil = addon.FactionUtil;
local LandingPageUtil = addon.LandingPageUtil;


local function Plumber_ToggleLandingPage()
	PlumberExpansionLandingPage:ToggleUI();
end

-- C_Garrison.IsOnGarrisonMap()

--Global Declares
_G.Plumber_ToggleLandingPage = Plumber_ToggleLandingPage;


--Addon Compartment
local IDENTIFIER = "PlumberLandingPage";

local function AddonCompartment_OnClick()
	Plumber_ToggleLandingPage();
end

local function AddonCompartment_OnEnter(menuButton, data)
	local tooltip = GameTooltip;
	tooltip:SetOwner(menuButton, "ANCHOR_NONE");
	tooltip:SetPoint("TOPRIGHT", menuButton, "TOPLEFT", -12, 0);

	local title = LandingPageUtil.GetModuleNameWithHotkey();
	tooltip:SetText(title, 1, 1, 1, 1, true);
	tooltip:AddLine(L["Plumber Experimental Feature Tooltip"], 1, 0.82, 0, true);
	tooltip:Show();
end

local function AddonCompartment_OnLeave(menuButton)
	GameTooltip:Hide();
end


local EL = CreateFrame("Frame");
EL:RegisterEvent("LOADING_SCREEN_DISABLED");

EL.events = {
	"QUEST_ACCEPTED",
	"QUEST_TURNED_IN",
};

if C_EventUtils.IsEventValid("TRAIT_TREE_CURRENCY_INFO_UPDATED") then
	table.insert(EL.events, "TRAIT_TREE_CURRENCY_INFO_UPDATED");
end

EL:SetScript("OnEvent", function(self, event, ...)
	if event == "LOADING_SCREEN_DISABLED" then
		self:UnregisterEvent(event);
		if EL.enabled then
			C_Timer.After(3, function()
				local factionName = FactionUtil:GetRewardPendingFactioName();
				if factionName then
					LandingPageUtil.ShowMinimapButtonAlert(L["Paragon Reward Available"].."\n"..factionName, "ParagonReward");
				end
				LandingPageUtil.HandleTraitTreeCurrencyChanged(1186);
			end);
		end
	elseif event == "QUEST_ACCEPTED" then
		local questID = ...
		local factionID = FactionUtil:GetParagonRewardQuestFaction(questID);
		if factionID then
			local factionName = FactionUtil:GetFactionName(factionID);
			if factionName then
				LandingPageUtil.ShowMinimapButtonAlert(L["Paragon Reward Available"].."\n"..factionName, "ParagonReward");
			end
			CallbackRegistry:Trigger("LandingPage.UpdateNotification");
		end
	elseif event == "QUEST_TURNED_IN" then
		local questID = ...
		if FactionUtil:IsParagonRewardQuest(questID) then
			CallbackRegistry:Trigger("LandingPage.UpdateNotification");
		end
	elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		local treeID = ...
		LandingPageUtil.HandleTraitTreeCurrencyChanged(treeID);
	end
end);

function EL.EnableModule(state)
	if state then
		if not EL.enabled then
			EL.enabled = true;
			API.RegisterFrameForEvents(EL, EL.events);
			API.AddButtonToAddonCompartment(IDENTIFIER, L["Abbr NewExpansionLandingPage"], nil, AddonCompartment_OnClick, AddonCompartment_OnEnter, AddonCompartment_OnLeave);
		end
	else
		if EL.enabled then
			EL.enabled = false;
			API.UnregisterFrameForEvents(EL, EL.events);
			API.RemoveButtonFromAddonCompartment(IDENTIFIER);
		end
	end
	LandingPageUtil.UpdateMinimapButtonVisibility();
end


do
	local moduleData = {
		name = L["ModuleName NewExpansionLandingPage"],
		dbKey = "NewExpansionLandingPage",
		description = L["ModuleDescription NewExpansionLandingPage"],
		toggleFunc = EL.EnableModule,
		categoryID = 1,
		uiOrder = -10,
		moduleAddedTime = 1750160000,
		optionToggleFunc = LandingPageUtil.ToggleMinimapSettings,
		validityCheck = function()
			return addon.IsToCVersionEqualOrNewerThan(50000);
		end,
		categoryKeys = {
			"Signature",
		},
	};

	addon.ControlCenter:AddModule(moduleData);
end
