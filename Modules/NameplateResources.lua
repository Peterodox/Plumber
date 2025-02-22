local _, addon = ...
local API = addon.API;


local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;
local UnitWidgetSet = UnitWidgetSet;
local GetStatusBarWidgetVisualizationInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo;
--local UnitGUID = UnitGUID;
--local UnitDistanceSquared = UnitDistanceSquared;
local pairs = pairs;


local EL = CreateFrame("Frame");
EL.unitQueue = {};
EL.unitWidgets = {};
EL.widgetPool = {};

local WidgetSetInfo = {};

function EL:OnEvent(event, ...)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local unit = ...
        self.unitQueue[unit] = true;
        self:RequestProcessUnits();
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unit = ...
        self.unitQueue[unit] = nil;
        self:RemoveUnitWidget(unit);
        self:RequestProcessUnits();
    end
end

function EL:EnableModule(state)
    if state then
        self.enabled = true;
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
        self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
        self:SetScript("OnEvent", self.OnEvent);
        self:ProcessExistingNameplates();

    elseif self.enabled then
        self.enabled = nil;
        self:UnregisterEvent("NAME_PLATE_UNIT_ADDED");
        self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED");
        self:SetScript("OnEvent", nil);
        self:SetScript("OnUpdate", nil);

        for unit, widget in pairs(self.unitWidgets) do
            widget:ReleaseWidget();
            table.insert(self.widgetPool, widget);
        end

        self.unitWidgets = {};
        self.unitQueue = {};
        self.t = nil;
    end
end

function EL:ProcessUnits()
    for unit, active in pairs(self.unitQueue) do
        if active then
            self.unitQueue[unit] = false;
            local widgetSetID = UnitWidgetSet(unit);
            if widgetSetID then
                --print(widgetSetID, UnitName(unit))
                if WidgetSetInfo[widgetSetID] then
                    self:SetupNameplateWidget(unit, WidgetSetInfo[widgetSetID]);
                end
            end
        end
    end
end

function EL:ProcessUnits_OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.1 then
        self.t = 0;
        self:SetScript("OnUpdate", nil);
        self:ProcessUnits();
    end
end

function EL:RequestProcessUnits()
    self.t = 0;
    self:SetScript("OnUpdate", self.ProcessUnits_OnUpdate);
end


function EL:RemoveUnitWidget(unit)
    if self.unitWidgets[unit] then
        local widget = self.unitWidgets[unit];
        self.unitWidgets[unit] = nil;
        widget:ReleaseWidget();
        table.insert(self.widgetPool, widget);
    end
end

function EL:ProcessExistingNameplates()
    local nameplates = C_NamePlate.GetNamePlates();
    local unit, anyUnit;
    for _, nameplate in ipairs(nameplates) do
        unit = nameplate.namePlateUnitToken;
        if unit then
            anyUnit = true;
            self.unitQueue[unit] = true;
        end
    end
    if anyUnit then
        self:RequestProcessUnits();
    end
end

function EL:SetupNameplateWidget(unit, widgetInfo)
    local nameplate = GetNamePlateForUnit(unit);
    if nameplate then
        local widget = self:AcquireWidget();
        self.unitWidgets[unit] = widget;
        widget:SetParent(nameplate);

        if widgetInfo.position == "bottom" then
            local anchorTo = (nameplate.UnitFrame and nameplate.UnitFrame.WidgetContainer) or nameplate;
            widget:SetPoint("TOP", anchorTo, "BOTTOM", 0, 0);
        else
            widget:SetPoint("BOTTOM", nameplate, "TOP", 0, 2);
        end

        if widgetInfo.type == "item" then
            widget:SetItem(widgetInfo.id);
        elseif widgetInfo.type == "currency" then
            widget:SetCurrency(widgetInfo.id);
        end

        widget.requiredWidgetID = widgetInfo.requiredWidgetID;
        if widget.requiredWidgetID then
            widget:Show();
            widget:EvaluateVisibility();
        else
            widget.visible = true;
            widget:FadeIn();
        end
    end
end


do
    local WidgetMixin = {};

    function WidgetMixin:ReleaseWidget()
        self:Release();
        self:SetParent(EL);
    end

    function WidgetMixin:EvaluateVisibility(info)
        if self.requiredWidgetID then
            info = info or GetStatusBarWidgetVisualizationInfo(self.requiredWidgetID);
            if info and info.shownState ~= 0 then
                self.alpha = self:GetAlpha();
                self:FadeIn();
                self.visible = true;
            else
                self.toAlpha = nil;
                self.alpha = 0;
                self:SetAlpha(0);
                self.visible = false;
            end
        end
    end

    function EL:AcquireWidget()
        local widget;
        if #self.widgetPool > 0 then
            widget = table.remove(self.widgetPool);
        else
            local selfDrivenUpdate = true;
            widget = API.CreateNameplateToken(self, selfDrivenUpdate);
            widget:SetStyle(1);
            API.Mixin(widget, WidgetMixin);
        end
        return widget
    end
end


local ZoneTriggerModule;

local function EnableModule(state)
    if state then
        if not ZoneTriggerModule then
            local module = API.CreateZoneTriggeredModule("hallowfall");
            ZoneTriggerModule = module;
            module:SetValidZones(2215);     --Hallowfall

            local function OnEnterZoneCallback(mapID)
                EL:EnableModule(true);
            end

            local function OnLeaveZoneCallback()
                EL:EnableModule(false);
            end

            module:SetEnterZoneCallback(OnEnterZoneCallback);
            module:SetLeaveZoneCallback(OnLeaveZoneCallback);
        end
        ZoneTriggerModule:SetEnabled(true);
        ZoneTriggerModule:Update();
    else
        if ZoneTriggerModule then
            ZoneTriggerModule:SetEnabled(false);
        end
    end
end

do
    local moduleData = {
        name = addon.L["ModuleName NameplateWidget"],
        dbKey = "NameplateWidget",
        description = addon.L["ModuleDescription NameplateWidget"],
        toggleFunc = EnableModule,
        categoryID = 2,
        uiOrder = 10,
        moduleAddedTime = 1734426000,
    };

    addon.ControlCenter:AddModule(moduleData);
end


local function AddWidgetInfo(widgetSets, info)
    for _, widgetSetID in ipairs(widgetSets) do
        WidgetSetInfo[widgetSetID] = info;
    end
end

do  --Keyflame
    local Keyflame = {
        837,    --Fungal Field
        838,    --Whirring Field
        839,    --Light's Blooming
        846,    --Stillstone Pond
        847,    --Torchlight Mine
        848,    --Duskrise Acreage
        849,    --Faded Shore
        850,    --Bleak Sand

        989,
        990,
        991,
        992,
        993,
        1034,
        1059,
        1081,
    };

    local widgetInfo = {
        type = "item",
        id = 206350,
        position = "bottom",
    };

    AddWidgetInfo(Keyflame, widgetInfo);
end

do  --Croakit
    WidgetSetInfo[1082] = {
        type = "item",
        id = 211474,    --Shadowblind Grouper
        position = "bottom",
        requiredWidgetID = 5616,
    };
end