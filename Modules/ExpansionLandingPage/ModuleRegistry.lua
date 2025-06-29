--We override ExpansionLandingPageMinimapButton

local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;
local FactionUtil = addon.FactionUtil;
local IsExpansionLandingPageUnlockedForPlayer = C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer or API.Nop;


local function ShouldShowWarWithinLandingPage()
    return IsExpansionLandingPageUnlockedForPlayer(10)
end


local ToggleExpansionLandingPage_Old = ToggleExpansionLandingPage;

local function Plumber_ToggleLandingPage()
    PlumberExpansionLandingPage:ToggleUI();
end

local function ToggleExpansionLandingPage_New()
    if ShouldShowWarWithinLandingPage() then
        Plumber_ToggleLandingPage();
    else
        ToggleExpansionLandingPage_Old();
    end
end

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

    local hotkey1, hotkey2 = GetBindingKey("TOGGLE_PLUMBER_LANDINGPAGE");
    local hotkey = hotkey1 or hotkey2;
    local title = L["ModuleName NewExpansionLandingPage"];
    if hotkey then
        local bindingText = GetBindingText(hotkey) or hotkey;
        title = title .. string.format(" |cffffd100(%s)|r", bindingText);
    end
    tooltip:SetText(title, 1, 1, 1, true);
    tooltip:AddLine(L["Plumber Experimental Feature Tooltip"], 1, 0.82, 0, true);
    tooltip:Show();
end

local function AddonCompartment_OnLeave(menuButton)
    GameTooltip:Hide();
end


local EL = CreateFrame("Frame");
EL:RegisterEvent("LOADING_SCREEN_DISABLED");

EL:SetScript("OnEvent", function(self, event, ...)
    if event == "LOADING_SCREEN_DISABLED" then
        self:UnregisterEvent(event);
        if EL.enabled then
            C_Timer.After(3, function()
                if ShouldShowWarWithinLandingPage() and FactionUtil:IsAnyParagonRewardPending() then
                    API.TriggerExpansionMinimapButtonAlert(L["Paragon Reward Available"]);
                end
            end);
        end
    elseif event == "QUEST_ACCEPTED" then
        local questID = ...
        local factionID = FactionUtil:GetParagonRewardQuestFaction(questID);
        if factionID then
            API.TriggerExpansionMinimapButtonAlert(L["Paragon Reward Available"]);
            CallbackRegistry:Trigger("ParagonRewardReady", factionID);
        end
    elseif event == "QUEST_TURNED_IN" then
        local questID = ...
        if FactionUtil:IsParagonRewardQuest(questID) then
            CallbackRegistry:Trigger("ParagonRewardQuestTurnedIn", questID);
        end
    end
end);

function EL.EnableModule(state)
    if state then
        if not EL.enabled then
            EL.enabled = true;
            _G.ToggleExpansionLandingPage = ToggleExpansionLandingPage_New;     --Override Default API
            EL:RegisterEvent("QUEST_ACCEPTED");
            EL:RegisterEvent("QUEST_TURNED_IN");
            API.AddButtonToAddonCompartment(IDENTIFIER, L["ModuleName NewExpansionLandingPage"], nil, AddonCompartment_OnClick, AddonCompartment_OnEnter, AddonCompartment_OnLeave);
        end
    else
        if EL.enabled then
            EL.enabled = false;
            _G.ToggleExpansionLandingPage = ToggleExpansionLandingPage_Old;
            EL:UnregisterEvent("QUEST_ACCEPTED");
            EL:UnregisterEvent("QUEST_TURNED_IN");
            API.RemoveButtonFromAddonCompartment(IDENTIFIER);
        end
    end
end


do
    local moduleData = {
        name = L["ModuleName NewExpansionLandingPage"],
        dbKey = "NewExpansionLandingPage",
        description = L["ModuleDescription NewExpansionLandingPage"],
        toggleFunc = EL.EnableModule,
        categoryID = 1,
        uiOrder = 0,
        moduleAddedTime = 1750160000,
    };

    addon.ControlCenter:AddModule(moduleData);
end