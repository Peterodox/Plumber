-- Add a button to the Expansion and Garrison Landing Page to switch to content from different expansions


local _, addon = ...
local L = addon.L;
local API = addon.API;


local Module = {};
Module.enabled = false;
Module.clickHooked = false;


local function OpenGarrisonReport(garrTypeID)
    if API.CheckAndDisplayErrorIfInCombat() then
        return
    end

    local frame = GarrisonLandingPage;
    if frame then
        HideUIPanel(frame);

        if frame.SoulbindPanel then
            frame.SoulbindPanel:Hide();
        end

        if frame.CovenantCallings then
            frame.CovenantCallings:Hide();
        end
    end

    ShowGarrisonLandingPage(garrTypeID)

    if garrTypeID == Enum.GarrisonType.Type_9_0_Garrison then
        local unlocked = C_CovenantCallings.AreCallingsUnlocked();
        if unlocked and frame and frame.CovenantCallings then
            frame.CovenantCallings:Show();
        end
    end
end

local function IsAnyMission(garrTypeID)
    local garrFollowerTypeID = GetPrimaryGarrisonFollowerType(garrTypeID);
    local info1 = C_Garrison.GetAvailableMissions(garrFollowerTypeID);
    local info2 = C_Garrison.GetInProgressMissions(garrFollowerTypeID);
    return info1 ~= nil or info2 ~= nil

    --For BFA Mission, the API returns nil if the feature isn't unlocked
end

local function GetNumCompletedMission(garrTypeID)
    local items = C_Garrison.GetLandingPageItems(garrTypeID);
    local n = 0;
    if items then
        for _, v in ipairs(items) do
            if v.completed or v.isComplete then
                n = n + 1;
            end
        end
    end
    return n
end

local function GetMissionTooltip(garrTypeID)
    local numCompleted = GetNumCompletedMission(garrTypeID);
    if numCompleted > 0 then
        return L["Mission Complete Count Format"]:format(numCompleted), 0.098, 1.000, 0.098
    end
end


local function IsCovenantUnlocked()
    local id = C_Covenants.GetActiveCovenantID();
    if id and id ~= 0 then
        return IsAnyMission(Enum.GarrisonType.Type_9_0_Garrison)
    end
    return false
end


local ELPOverride = {}; --Unused. Taint the UI
do
    function ELPOverride.Init()
        if not ELPOverride.overlayByExpansion then
            ELPOverride.overlayByExpansion = {
                [LE_EXPANSION_DRAGONFLIGHT] = CreateFromMixins(DragonflightLandingOverlayMixin),
                [LE_EXPANSION_WAR_WITHIN] = CreateFromMixins(WarWithinLandingOverlayMixin),
            };
        end
    end

    function ELPOverride.GetNewestExpansionOverlayForPlayer()
        ELPOverride.Init();
        for expansion = LE_EXPANSION_LEVEL_CURRENT, LE_EXPANSION_CLASSIC, -1 do
            local overlay = ELPOverride.overlayByExpansion[expansion];
            if overlay and overlay.IsOverlayUnlocked() then
                return overlay;
            end
        end
    end

    function ELPOverride.OpenExpansionLandingPage(expansion)
        if API.CheckAndDisplayErrorIfInCombat() then
            return
        end
        ELPOverride.Init();
        local overlay = ELPOverride.overlayByExpansion[expansion];
        if overlay then
            local frame = ExpansionLandingPage;
            if frame then
                frame.GetNewestExpansionOverlayForPlayer = function()
                    return overlay
                end
                frame:RefreshExpansionOverlay();
                ShowUIPanel(frame);
            end
        end
    end
end


local ButtonMenu = {
    tag = "PlumberELPMinimapButtonMenu",
    objects = {
        --WoD Garrison
        {type = "Button", name = GARRISON_LANDING_PAGE_TITLE, garrTypeID = Enum.GarrisonType.Type_6_0_Garrison},

        --LEG Class Hall
        {type = "Button", name = ORDER_HALL_LANDING_PAGE_TITLE, garrTypeID = Enum.GarrisonType.Type_7_0_Garrison},

        --BFA Missions
        {type = "Button", name = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, garrTypeID = Enum.GarrisonType.Type_8_0_Garrison},

         --Covenant Sanctum
        {type = "Button", name = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE, garrTypeID = Enum.GarrisonType.Type_9_0_Garrison, IsEnabledFunc = IsCovenantUnlocked},


        --No DF or TWW landing page due to taint
        --{type = "Divider"},

        --{type = "Button", name = DRAGONFLIGHT_LANDING_PAGE_TITLE, OnClick = function() ELPOverride.OpenExpansionLandingPage(LE_EXPANSION_DRAGONFLIGHT) end},
        --{type = "Button", name = WAR_WITHIN_LANDING_PAGE_TITLE, OnClick = function() ELPOverride.OpenExpansionLandingPage(LE_EXPANSION_WAR_WITHIN) end},
    },
};

function Module:InitMenuSchematic()
    for _, v in ipairs(ButtonMenu.objects) do
        if v.garrTypeID then
            v.OnClick = function()
                OpenGarrisonReport(v.garrTypeID);
            end

            if not v.IsEnabledFunc then
                v.IsEnabledFunc = function()
                    return IsAnyMission(v.garrTypeID)
                end
            end

            v.DynamicTooltipFunc = function()
                return GetMissionTooltip(v.garrTypeID)
            end

            v.tooltip = v.name;
        end
    end
end


function Module:Enable()
    if self.enabled then return end;
    self.enabled = true;

    local widget = ExpansionLandingPageMinimapButton;
    if not widget then return end;

    --widget:RegisterForClicks("LeftButtonUp", "RightButtonUp");

    if not self.clickHooked then
        self.clickHooked = true;

        self:InitMenuSchematic();

        widget:HookScript("OnMouseUp", function(_, button)
            if not (self.enabled and button == "RightButton" and widget:IsMouseMotionFocus()) then return end;

            local contextData = {};
            addon.API.ShowBlizzardMenu(widget, ButtonMenu, contextData);
        end);

        widget:HookScript("OnEnter", function()
            if not self.enabled then return end;
            local tooltip = GameTooltip;
            tooltip:AddLine(L["Open Mission Report Tooltip"], 1, 0.82, 0, true);
            tooltip:Show();
        end);
    end
end

function Module:Disable()
    if not self.enabled then return end;
    self.enabled = false;
end

function Module.SetEnabled(state)
    if state then
        Module:Enable();
    else
        Module:Disable();
    end
end


do
    local moduleData = {
        name = addon.L["ModuleName LandingPageSwitch"],
        dbKey = "LandingPageSwitch",
        description = addon.L["ModuleDescription LandingPageSwitch"],
        toggleFunc = Module.SetEnabled,
        categoryID = 1,
        uiOrder = 1170,
        moduleAddedTime = 1744520000,
    };

    addon.ControlCenter:AddModule(moduleData);
end