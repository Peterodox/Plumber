--We override ExpansionLandingPageMinimapButton

local _, addon = ...
local API = addon.API;
local L = addon.L;


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


do  --Addon Compartment
    local IDENTIFIER = "PlumberLandingPage";

    local function OnClick()
        ToggleExpansionLandingPage_New();
    end

    local function OnEnter(menuButton, data)
        local tooltip = GameTooltip;
        tooltip:SetOwner(menuButton, "ANCHOR_NONE");
        tooltip:SetPoint("TOPRIGHT", menuButton, "TOPLEFT", -12, 0);
        tooltip:SetText(L["ModuleName ExpansionLandingPage"], 1, 1, 1, true);
        tooltip:AddLine(L["Plumber Experimental Feature Tooltip"], 1, 0.82, 0, true);
        tooltip:Show();
    end

    local function OnLeave(menuButton)
        GameTooltip:Hide();
    end

    C_Timer.After(0.5, function()
        API.AddButtonToAddonCompartment(IDENTIFIER, L["ModuleName ExpansionLandingPage"], nil, OnClick, OnEnter, OnLeave);
    end);
end
