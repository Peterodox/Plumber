local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;



local ActivityTabMixin = {};
do
    local DynamicEvents = {
        "UPDATE_FACTION",
        "MAJOR_FACTION_RENOWN_LEVEL_CHANGED",
        "MAJOR_FACTION_UNLOCKED",
    };

    function ActivityTabMixin:Refresh()

    end

    function ActivityTabMixin:OnShow()
        self:Refresh();
        API.RegisterFrameForEvents(self, DynamicEvents);
    end

    function ActivityTabMixin:OnHide()
        self:SetScript("OnUpdate", nil);
        API.UnregisterFrameForEvents(self, DynamicEvents);
        self:StopAnimating();
    end

    function ActivityTabMixin:OnEvent(event, ...)

    end
end

local function CreateActivityTab(activityTab)
    API.Mixin(activityTab, ActivityTabMixin);
    activityTab:SetScript("OnShow", activityTab.OnShow);
    activityTab:SetScript("OnHide", activityTab.OnHide);
    activityTab:SetScript("OnEvent", activityTab.OnEvent);
end


LandingPageUtil.AddTab(
    {
        key = "activity",
        name = "Activities",
        uiOrder = 2,
        initFunc = CreateActivityTab,
    }
);