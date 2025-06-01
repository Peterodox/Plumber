--We override ExpansionLandingPageMinimapButton

local _, addon = ...


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
