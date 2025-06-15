--We override ExpansionLandingPageMinimapButton

local _, addon = ...
local API = addon.API;
local L = addon.L;
local FactionUtil = addon.FactionUtil;


local function SetupMinimapButton()
    local MinimapButton = ExpansionLandingPageMinimapButton;
    if not MinimapButton then return end;
end


local ToggleExpansionLandingPage_Old = ToggleExpansionLandingPage;

local function ToggleExpansionLandingPage_New()
    PlumberExpansionLandingPage:ToggleUI();
end
ToggleExpansionLandingPage = ToggleExpansionLandingPage_New;


_G.Plumber_ToggleLandingPage = ToggleExpansionLandingPage_New;


--Addon Compartment
local IDENTIFIER = "PlumberLandingPage";

local function AddonCompartment_OnClick()
    ToggleExpansionLandingPage_New();
end

local function AddonCompartment_OnEnter(menuButton, data)
    local tooltip = GameTooltip;
    tooltip:SetOwner(menuButton, "ANCHOR_NONE");
    tooltip:SetPoint("TOPRIGHT", menuButton, "TOPLEFT", -12, 0);
    tooltip:SetText(L["ModuleName ExpansionLandingPage"], 1, 1, 1, true);
    tooltip:AddLine(L["Plumber Experimental Feature Tooltip"], 1, 0.82, 0, true);
    tooltip:Show();
end

local function AddonCompartment_OnLeave(menuButton)
    GameTooltip:Hide();
end


local EL = CreateFrame("Frame");

EL:RegisterEvent("LOADING_SCREEN_DISABLED");
EL:RegisterEvent("QUEST_ACCEPTED");
--EL:ReigsterEvent("PLAYER_ENTERING_WORLD");

EL:SetScript("OnEvent", function(self, event, ...)
    if event == "LOADING_SCREEN_DISABLED" then
        self:UnregisterEvent(event);
        API.AddButtonToAddonCompartment(IDENTIFIER, L["ModuleName ExpansionLandingPage"], nil, AddonCompartment_OnClick, AddonCompartment_OnEnter, AddonCompartment_OnLeave);
        C_Timer.After(3, function()
            if FactionUtil:IsAnyParagonRewardPending() then
                API.TriggerExpansionMinimapButtonAlert(L["Paragon Reward Available"]);
            end
        end);
    elseif event == "QUEST_ACCEPTED" then
        local questID = ...
        if FactionUtil:IsParagonRewardQuest(questID) then
            API.TriggerExpansionMinimapButtonAlert(L["Paragon Reward Available"]);
        end
    end
end);