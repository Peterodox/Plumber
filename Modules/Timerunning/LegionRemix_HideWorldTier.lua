local _, addon = ...

local FRAME_NAME = "UIWidgetBelowMinimapContainerFrame";


local EL = CreateFrame("Frame");

function EL:HideContainer()
    local f = _G[FRAME_NAME];
    if f then
        f:Hide();
        f:UnregisterEvent("UPDATE_ALL_UI_WIDGETS");
        f:UnregisterEvent("UPDATE_UI_WIDGET");
    end
end

function EL:ShowContainer()
    local f = _G[FRAME_NAME];
    if f then
        f:Show();
        f:RegisterEvent("UPDATE_ALL_UI_WIDGETS");
        f:RegisterEvent("UPDATE_UI_WIDGET");
    end
end

function EL:OnEvent(event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent(event);
        if self.isEnabled then
            self:HideContainer();
        else
            self:ShowContainer();
        end
    end
end

function EL:EnableModule(state)
    if addon.API.GetTimerunningSeason() ~= 2 then
        return
    end

    if state and not self.isEnabled then
        self.isEnabled = true;
        self:SetScript("OnEvent", self.OnEvent);
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED");
        else
            self:HideContainer();
            self:UnregisterEvent("PLAYER_REGEN_ENABLED");
        end
    elseif (not state) and self.isEnabled then
        self.isEnabled = nil;
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED");
        else
            self:ShowContainer();
            self:UnregisterEvent("PLAYER_REGEN_ENABLED");
        end
    end
end


do
    local EnableModule = function(state)
        EL:EnableModule(state)
    end

    local moduleData = {
        name = addon.L["ModuleName LegionRemix_HideWorldTier"],
        dbKey = "LegionRemix_HideWorldTier",
        description = addon.L["ModuleDescription LegionRemix_HideWorldTier"],
        toggleFunc = EnableModule,
        categoryID = -1,
        uiOrder = 5,
        moduleAddedTime = 1760500000,
        timerunningSeason = 2,
		categoryKeys = {
			"Current",
		},
    };

    addon.ControlCenter:AddModule(moduleData);
end