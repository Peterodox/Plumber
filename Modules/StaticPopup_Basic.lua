local _, addon = ...
local L = addon.L;
local API = addon.API;
local _G = _G;
local pairs = pairs;


local SIDE_SPACING = 8;
local TITLE_DESC_GAP = 4;
local MAX_TEXT_WIDTH = 256;


local StaticPopupUtil = CreateFrame("Frame");
addon.StaticPopupUtil = StaticPopupUtil;


function StaticPopupUtil:FindFrame(which)
    local f;
    for i = 1, 3 do
        f = _G["StaticPopup"..i];
        if f and f:IsShown() and f.which == which then
            return f
        end
    end
end

function StaticPopupUtil:AddTooltipInfoCallback(dataInstanceID, callback)
    if not self.dataInstanceCallbacks then
        self.dataInstanceCallbacks = {};
    end
    self.dataInstanceCallbacks[dataInstanceID] = callback;
    self:RegisterEvent("TOOLTIP_DATA_UPDATE");
    self:RequestUpdate();
end

function StaticPopupUtil:OnEvent(event, ...)
    if event == "TOOLTIP_DATA_UPDATE" then
        local dataInstanceID = ...
        if self.dataInstanceCallbacks[dataInstanceID] then
            self.dataInstanceCallbacks[dataInstanceID]();
        end
    end
end
StaticPopupUtil:SetScript("OnEvent", StaticPopupUtil.OnEvent);

function StaticPopupUtil:AttachWidgetToStaticPopup(which, widget, direction)
    local f = self:FindFrame(which);
    if not f then return false end;

    local point, offsetY;

    if direction == "TOP" then
        point = "BOTTOM";
        offsetY = f:GetTop() + 4;
    else
        point = "TOP";
        offsetY = f:GetBottom() - 12;   --To avoide "YES" "NO" button
    end

    widget:ClearAllPoints();
    widget:SetPoint(point, UIParent, "BOTTOM", 0, offsetY);

    if not self.widgetOwners then
        self.widgetOwners = {};
    end
    self.widgetOwners[f] = which;

    if not self.popupWidgets then
        self.popupWidgets = {};
    end
    self.popupWidgets[which] = widget;

    self:RequestUpdate();

    return true
end

function StaticPopupUtil:CreateSimpleTooltip()
    if self.Tooltip then return end;
    self.Tooltip = addon.CreateSimpleTooltip(UIParent);
end

function StaticPopupUtil:HideSimpleTooltip()
    if self.Tooltip then
        self.Tooltip:Hide();
        self.Tooltip:ClearAllPoints();
    end
end

function StaticPopupUtil:ShowSimpleTooltip(which, title, description, direction)
    if title then
        self:CreateSimpleTooltip();
        self.Tooltip:SetText(title, description);
        self.Tooltip:Show();
        return self:AttachWidgetToStaticPopup(which, self.Tooltip, direction);
    else
        self:HideSimpleTooltip();
        return false
    end
end

function StaticPopupUtil:GetTooltipFrame()
    return self.Tooltip
end

function StaticPopupUtil:HidePopupWidget(which)
    if self.popupWidgets then
        if self.popupWidgets[which] then
            self.popupWidgets[which]:Hide();
            self.popupWidgets[which]:ClearAllPoints();
            self.popupWidgets[which] = nil;
        end
    end
end

function StaticPopupUtil:CheckPopupVisibilities()
    if self.widgetOwners then
        for popup, which in pairs(self.widgetOwners) do
            if (popup:IsVisible() and popup.which == which) then
                return
            end
        end
    end

    self:SetScript("OnUpdate", nil);
    self.updateTimer = 0;
    self.widgetOwners = nil;
    self:UnregisterEvent("TOOLTIP_DATA_UPDATE");
    self.dataInstanceCallbacks = nil;

    if self.popupWidgets then
        for which, widget in pairs(self.popupWidgets) do
            widget:Hide();
            widget:ClearAllPoints();
        end
        self.popupWidgets = nil;
    end
end

function StaticPopupUtil:OnUpdate(elapsed)
   self.updateTimer = self.updateTimer + elapsed;
    if self.updateTimer > 0.2 then
        self.updateTimer = 0;
        self:CheckPopupVisibilities();
    end
end

function StaticPopupUtil:RequestUpdate()
    self.updateTimer = 0;
    self:SetScript("OnUpdate", self.OnUpdate);
end