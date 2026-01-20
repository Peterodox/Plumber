-- Create Action Buttons to Teleport to Alliance, Horde Homes, and Leave home.
-- Thanks to Console Port dev Munk, a mysterious helper that works in extreme weather, and of course myelf for reviving Teleport Home macro in Midnight. 


local _, addon = ...
local Housing = addon.Housing;


local TeleportHomeButtons = {};
Housing.TeleportHomeButtons = TeleportHomeButtons;


local TeleportButtonMixin = {};
do
    function TeleportButtonMixin:SetAction_TeleportHome(neighborhoodGUID, houseGUID, plotID)
        self.neighborhoodGUID = neighborhoodGUID;
        self.houseGUID = houseGUID;
        self.plotID = plotID;
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED");
            self.setupFunc = self.SetAction_TeleportHome;
        else
            self:UnregisterEvent("PLAYER_REGEN_ENABLED");
            self:SetAttribute("useOnKeyDown", false);
            self:RegisterForClicks("AnyDown", "AnyUp");
            self:SetScript("PostClick", self.PostClick);
            if neighborhoodGUID and houseGUID and plotID then
                self:SetAttribute("type", "teleporthome");
                self:SetAttribute("house-neighborhood-guid", self.neighborhoodGUID);
                self:SetAttribute("house-guid", self.houseGUID);
                self:SetAttribute("house-plot-id", self.plotID);
            else
                self:SetAttribute("type", nil);
            end
        end
    end

    function TeleportButtonMixin:SetAction_ReturnHome()
        -- C_Housing.ReturnAfterVisitingHouse
        -- Spell:1270311, it uses a generic hearthstone icon, the actual icon exist as atlas teleport-out-button

        self.neighborhoodGUID = nil;
        self.houseGUID = nil;
        self.plotID = nil;
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED");
            self.setupFunc = self.SetAction_ReturnHome;
        else
            self:UnregisterEvent("PLAYER_REGEN_ENABLED");
            self:SetAttribute("useOnKeyDown", false);
            self:RegisterForClicks("AnyDown", "AnyUp");
            self:SetScript("PostClick", nil);
            self:SetAttribute("type", "returnhome");
        end
    end

    function TeleportButtonMixin:OnEvent(event)
        if event == "PLAYER_REGEN_ENABLED" and self.setupFunc then
            self.setupFunc(self, self.neighborhoodGUID, self.houseGUID, self.plotID);
        end
    end

    function TeleportButtonMixin:PostClick()
        Housing.CheckTeleportInCooldown();
    end
end


local function CreateTeleportHomeButton(index)
    local f = CreateFrame("Button", "PLMR_HOME"..index, nil, "SecureActionButtonTemplate");
    Mixin(f, TeleportButtonMixin);
    f:SetSize(1, 1);
    f:SetPoint("BOTTOMRIGHT", UIParent, "TOPLEFT", -1, -1);
    f:SetScript("OnEvent", f.OnEvent);
    return f
end


local ActionButtonKeys = {
    "CurrentFaction", "Alliance", "Horde", "Leave",
};
for index, key in ipairs(ActionButtonKeys) do
    TeleportHomeButtons[key] = CreateTeleportHomeButton(index);
end
ActionButtonKeys = nil;


TeleportHomeButtons.Leave:SetAction_ReturnHome();


function Housing.GetTeleportHomeMacro()
    return "/click "..TeleportHomeButtons.CurrentFaction:GetName();
end

function Housing.GetTeleportAllianceHomeMacro()
    return "/click "..TeleportHomeButtons.Alliance:GetName();
end

function Housing.GetTeleportHordeHomeMacro()
    return "/click "..TeleportHomeButtons.Horde:GetName();
end

function Housing.GetLeaveHomeMacro()
    return "/click "..TeleportHomeButtons.Leave:GetName();
end