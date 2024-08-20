local _, addon = ...
local API = addon.API;
local L = addon.L;
local Mixin = API.Mixin;

local MapFrame = WorldMapFrame;
local TooltipFrame = GameTooltip;
local InCombatLockdown = InCombatLockdown;
local C_UIWidgetManager = C_UIWidgetManager;

local PIN_TEMPLATE_NAME = "PlumberWorldMapPinTemplate";

local PinController = CreateFrame("Frame");     --Events driven, updates Pin
addon.MapPinController = PinController;
local MapTracker = CreateFrame("Frame");        --Attach to WorldMapFrame to monitor changes to map, scale...
local WorldMapDataProvider = CreateFromMixins(MapCanvasDataProviderMixin);
local BlizzardUIUtil = {};


do  --BlizzardUIUtil
    local QuestDetailsFrame = QuestMapFrame and QuestMapFrame.DetailsFrame;

    function BlizzardUIUtil:IsViewingQuestDetails()
        return QuestDetailsFrame and QuestDetailsFrame:IsVisible();
    end

    --Map Filter Menu
    function BlizzardUIUtil:HookIntoMenu()
        if not self.isMenuHooked then
            self.isMenuHooked = true;
        else
            return
        end

        self.isMenuHooked = true;

        if Menu and Menu.ModifyMenu then
            Menu.ModifyMenu("MENU_WORLD_MAP_TRACKING", function(owner, rootDescription, contextData)
                if not PinController.isEnabled then return end;

                local options = PinController:GetFilterOptionsForCurrentMap();
                if options then
                    rootDescription:CreateDivider();
                    rootDescription:CreateTitle("Plumber");
                    for _, option in ipairs(options) do
                        --rootDescription:CreateButton("Button", function() print("Text here!" end);
                        local function IsSelected()
                            return addon.GetDBValue(option.dbKey);
                        end

                        local function SetSelected()
                            local newState = not addon.GetDBValue(option.dbKey);
                            addon.SetDBValue(option.dbKey, newState);
                            PinController:EnableMapDataProvider(option.dbKey, newState);
                            PinController:RequestUpdate();
                        end

                        local checkbox = rootDescription:CreateCheckbox(option.name, IsSelected, SetSelected);

                        checkbox:AddInitializer(function(button, description, menu)
                            local rightTexture = button:AttachTexture();
                            rightTexture:SetPoint("RIGHT");
                            option.iconSetupFunc(rightTexture);

                            local fontString = button.fontString;
                            fontString:SetPoint("RIGHT", rightTexture, "LEFT");
                            fontString:SetTextColor(1, 1, 1);

                            local pad = 20;
                            local width = pad + fontString:GetUnboundedStringWidth() + rightTexture:GetWidth();
                            local height = 20;

                            return width, height;
                        end);
                    end
                end
            end);
        end
    end
end


do  --PinController
    PinController.pins = {};
    PinController.mapDataProviders = {};
    PinController.dbKeyXdataprovider = {};

    local tinsert = table.insert;
    local ipairs = ipairs;

    function PinController:AddPin(pin)
        tinsert(self.pins, pin);
    end

    function PinController:AddMapDataProvider(mapID, dataProvider)
        if not self.mapDataProviders[mapID] then
            self.mapDataProviders[mapID] = {};
        end
        tinsert(self.mapDataProviders[mapID], dataProvider);

        if not self.dbKeyXdataprovider[dataProvider.OptionData.dbKey] then
            self.dbKeyXdataprovider[dataProvider.OptionData.dbKey] = dataProvider;
        else
            print(string.format("Plumber: Duplicated MapDataProvider Key %s", dataProvider.OptionData.dbKey));
        end
    end

    function PinController:InitializeMapDataProvider()
        if self.mapDataProviders then
            for mapID, dataProviders in pairs(self.mapDataProviders) do
                for _, dataProvider in ipairs(dataProviders) do
                    dataProvider.enabled = addon.GetDBValue(dataProvider.OptionData.dbKey);
                end
            end
        end
    end

    function PinController:EnableMapDataProvider(dbKey, state)
        local dataProvider = self.dbKeyXdataprovider[dbKey];
        if dataProvider then
            dataProvider.enabled = state == true or state == nil;
        end
    end

    function PinController:DoesMapHaveData(mapID)
        if mapID and self.mapDataProviders[mapID] then
            for _, dataProvider in ipairs(self.mapDataProviders[mapID]) do
                if dataProvider.enabled then
                    return true
                end
            end
        end
    end

    function PinController:UpdatePinForMap(mapID)
        local pin, pinData;
        local anyPins = false;

        for i, dataProvider in ipairs(self.mapDataProviders[mapID]) do
            if dataProvider.enabled then
                pinData = dataProvider:GetPinDataForMap(mapID);
                if pinData then
                    for _, data in ipairs(pinData) do
                        pin = MapFrame:AcquirePin(PIN_TEMPLATE_NAME, data);
                        if (not anyPins) and pin then
                            anyPins = true;
                        end
                    end
                end
            end
        end

        return anyPins
    end

    function PinController:GetFilterOptionsForCurrentMap()
        local mapID = MapTracker:GetMapID();
        if mapID and self.mapDataProviders[mapID] then
            local options;
            local n = 0;
            for _, dataProvider in ipairs(self.mapDataProviders[mapID]) do
                if not options then
                    options = {};
                end
                n = n + 1;
                options[n] = dataProvider.OptionData;
                --option = {name=, iconSetupFunc=, enabled=}
            end
            return options
        end
    end

    function PinController:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t >= 0.2 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            MapTracker:OnMapChanged();
        end
    end

    function PinController:RequestUpdate()
        --Called by sub module when data is recieved
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function PinController:ListenEvents(state)
        if state and not self.listening then
            self.listening = true;
            self:RegisterEvent("AREA_POIS_UPDATED");
            self:SetScript("OnEvent", self.OnEvent);
        elseif (not state) and self.listening then
            self.listening = false;
            self:UnregisterEvent("AREA_POIS_UPDATED");
            self:SetScript("OnEvent", nil);
        end
    end

    function PinController:OnEvent(event, ...)
        if event == "AREA_POIS_UPDATED" then
            self:RequestUpdate();
        end
    end

    function PinController:UpdatePinScale()

    end
end


do  --WorldMapDataProvider
    function WorldMapDataProvider:GetPinTemplate()
        return PIN_TEMPLATE_NAME
    end

    function WorldMapDataProvider:OnShow()

    end

    function WorldMapDataProvider:OnHide()
        PinController:ListenEvents(false);
    end

    function WorldMapDataProvider:OnEvent(event, ...)
        --This significantly increase RAM usage count
        --So we monitor Events using another frame (PinController) 
    end

    function WorldMapDataProvider:RemoveAllIfNeeded()
        if self.anyPins then
            self:RemoveAllData();
        end
    end

    function WorldMapDataProvider:RemoveAllData()
        self.anyPins = false;
        MapFrame:RemoveAllPinsByTemplate(PIN_TEMPLATE_NAME);
    end

    function WorldMapDataProvider:RefreshAllData(fromOnShow)
        self:RemoveAllIfNeeded();
        self:ShowAllPins();
    end

    function WorldMapDataProvider:RefreshAllDataIfPossible()
        self:RemoveAllIfNeeded();
        if not BlizzardUIUtil:IsViewingQuestDetails() then
            self:ShowAllPins();
        end
    end

    function WorldMapDataProvider:ShowAllPins()
        local mapID = MapTracker:GetMapID();
        self.anyPins = PinController:UpdatePinForMap(mapID);
    end

    function WorldMapDataProvider:OnCanvasScaleChanged()
        --Fires multiple times when opening WorldMapFrame
        PinController:UpdatePinScale();
    end
end


do
    local MapScrollContainer = WorldMapFrame.ScrollContainer;

    function MapTracker:Attach()
        if not self.attached then
            self.attached = true;
            self:SetParent(MapFrame);
            self:EnableScripts();
            self:Show();
        end
    end

    function MapTracker:Detach()
        if self.attached then
            self.attached = nil;
            self.mapID = nil;
            self:SetParent(nil);
            self:DisableScripts();
            self:Hide();
            WorldMapDataProvider:RemoveAllIfNeeded();
            WorldMapDataProvider:OnHide();
        end
    end

    function MapTracker:OnUpdate(elapsed)
        self.t1 = self.t1 + elapsed;
        self.t2 = self.t2 + elapsed;

        if self.t1 > 0.016 then
            self.t1 = 0;

            self.newMapID = MapFrame.mapID;
            if self.newMapID ~= self.mapID then
                self.mapID = self.newMapID;
                self:OnMapChanged(self.mapID);
            end

            self.newScale = MapScrollContainer.targetScale;
            if self.newScale ~= self.mapScale then
                self.mapScale = self.newScale;
                self:OnCanvasScaleChanged();
            end
        end

        if self.t2 > 0.1 then
            self.t2 = 0;
            self.detailsVisiblity = BlizzardUIUtil:IsViewingQuestDetails();
            if self.detailsVisiblity ~= self.isViewingDetails then
                self.isViewingDetails = self.detailsVisiblity;
                self:OnViewingQuestDetailsChanged();
            end
        end
    end

    function MapTracker:OnShow()
        self.mapID = nil;
        self.mapScale = nil;
        self.isViewingDetails = BlizzardUIUtil:IsViewingQuestDetails();
        self.t1 = 1;
    end

    function MapTracker:OnHide()
        WorldMapDataProvider:OnHide();
    end

    function MapTracker:EnableScripts()
        self.t1 = 0;
        self.t2 = 0;
        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function MapTracker:DisableScripts()
        self:SetScript("OnShow", nil);
        self:SetScript("OnHide", nil);
        self:SetScript("OnUpdate", nil);
    end

    function MapTracker:GetMapID()
        return self.mapID
    end

    function MapTracker:OnMapChanged(mapID)
        if not mapID then
            mapID = self:GetMapID();
        end
    
        if not mapID then return end;

        if PinController:DoesMapHaveData(mapID) then
            PinController:ListenEvents(true);
            WorldMapDataProvider:RefreshAllDataIfPossible();
        else
            PinController:ListenEvents(false);
            WorldMapDataProvider:RemoveAllIfNeeded();
        end
    end

    function MapTracker:OnCanvasScaleChanged()
        WorldMapDataProvider:OnCanvasScaleChanged();
    end

    function MapTracker:OnViewingQuestDetailsChanged()
        if self.isViewingDetails then

        else
            self:OnMapChanged();
        end
    end
end


do
    PlumberWorldMapPinMixin = CreateFromMixins(MapCanvasPinMixin);

    local function Dummy_SetPassThroughButtons()
    end

    function PlumberWorldMapPinMixin:OnCreated()
        --When frame being created
        self.originalSetPassThroughButtons = self.SetPassThroughButtons;
        self.SetPassThroughButtons = Dummy_SetPassThroughButtons;
        self:AllowPassThroughRightButton(true);
        PinController:AddPin(self);
    end

    function PlumberWorldMapPinMixin:OnLoad()
        --newPin (see MapCanvasMixin:AcquirePin)
        self:SetScalingLimits(1, 1.0, 1.2);
        self.pinFrameLevelType = "PIN_FRAME_LEVEL_GROUP_MEMBER";    --PIN_FRAME_LEVEL_VIGNETTE  PIN_FRAME_LEVEL_AREA_POI   PIN_FRAME_LEVEL_WAYPOINT_LOCATION  PIN_FRAME_LEVEL_GROUP_MEMBER
        self.pinFrameLevelIndex = 1;
        self:SetTexture("Interface/AddOns/Plumber/Art/MapPin/SeedPlanting-Empty-Distant");
    end

    function PlumberWorldMapPinMixin:AllowPassThroughRightButton(unpackedPrimitiveType)
        --Original "SetPassThroughButtons" (see SimpleScriptRegionAPI for details) has chance to taint when called
        --So we overwrite it
        if (not self.isRightButtonAllowed) and (not InCombatLockdown()) then
            self.isRightButtonAllowed = true;
            if self.originalSetPassThroughButtons then
                self.originalSetPassThroughButtons(self, "RightButton");
            end
        end
    end

    function PlumberWorldMapPinMixin:SetTexture(texture, sampling)
        sampling = sampling or "LINEAR";
        self.Texture:SetTexture(texture, nil, nil, sampling);
        self.HighlightTexture:SetTexture(texture, nil, nil, sampling);
        self.HighlightTexture:SetVertexColor(0.4, 0.4, 0.4);
    end

    function PlumberWorldMapPinMixin:SetTexCoord(l, r, t, b)
        self.Texture:SetTexCoord(l, r, t, b);
        self.HighlightTexture:SetTexCoord(l, r, t, b);
    end

    function PlumberWorldMapPinMixin:OnMouseLeave()
        --BaseMapPoiPinMixin.OnMouseLeave(self);
        TooltipFrame:Hide();
    end

    function PlumberWorldMapPinMixin:SetClickable(state)
        if state ~= self.isClickable then
            self.isClickable = state;
        end
        self:SetMouseClickEnabled(state);
    end

    function PlumberWorldMapPinMixin:OnAcquired(data)
        if self.mixin ~= data.mixin then
            self.mixin = data.mixin;
            Mixin(self, data.mixin);
        end

        self:SetClickable(data.clickable);

        self.data = data;
        self:UpdatePosition();
        self:Update();
    end

    function PlumberWorldMapPinMixin:UpdatePosition()
        if self.data then
            self:SetPosition(self.data.x, self.data.y);
        end
    end

    function PlumberWorldMapPinMixin:OnMouseEnter()
        self.UpdateTooltip = nil;
        self:AllowPassThroughRightButton(true);
        self:PostMouseEnter();
    end

    function PlumberWorldMapPinMixin:TriggerMouseReEnter()
        self.UpdateTooltip = self.OnMouseEnter;
    end

    local function GetTextColorForEnabledState(enabledState)
        local Stats = Enum.WidgetEnabledState;

        if enabledState == Stats.Disabled then
            return DISABLED_FONT_COLOR;
        elseif enabledState == Stats.Red then
            return RED_FONT_COLOR;
        elseif enabledState == Stats.White then
            return HIGHLIGHT_FONT_COLOR;
        elseif enabledState == Stats.Green then
            return GREEN_FONT_COLOR;
        elseif enabledState == Stats.Artifact then
            return ARTIFACT_GOLD_COLOR;
        elseif enabledState == Stats.Black then
            return BLACK_FONT_COLOR;
        elseif enabledState == Stats.BrightBlue then
            return BRIGHTBLUE_FONT_COLOR;
        else
            return NORMAL_FONT_COLOR;
        end
    end

    function PlumberWorldMapPinMixin:AttachWidgetSetToTooltip(tooltip, widgetSetID, textRule)
        local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID);

        --We only show TextWithState
        if widgets then
            for _, info in ipairs(widgets) do
                if info.widgetType == 8 then
                    local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(info.widgetID);
                    if widgetInfo and widgetInfo.shownState ~= 0 and widgetInfo.text then
                        if (not textRule) or (textRule(widgetInfo.text)) then
                            local color = GetTextColorForEnabledState(widgetInfo.enabledState);
                            local r, g, b = color:GetRGB();
                            tooltip:AddLine(widgetInfo.text, r, g, b, true);
                        end
                    end
                end
            end
        end
    end

    function PlumberWorldMapPinMixin:AddQuestTimeToTooltip(tooltip, questID)
        if not questID then return end;

        local formattedTime, color, secondsRemaining = WorldMap_GetQuestTimeForTooltip(questID);
        if formattedTime and color then
            GameTooltip_AddColoredLine(tooltip, formattedTime, color);
        end
    end


    --Overwrite by module
    function PlumberWorldMapPinMixin:PostMouseEnter()

    end

    function PlumberWorldMapPinMixin:IsMouseClickEnabled()
        return true
    end

    function PlumberWorldMapPinMixin:OnMouseClickAction(mouseButton)

    end

    function PlumberWorldMapPinMixin:Update()

    end
end


do  --Master Switch
    local function EnableMapPinSystem(state)
        if state then
            MapTracker:Attach();
            PinController:InitializeMapDataProvider();
            PinController.isEnabled = true;
            BlizzardUIUtil:HookIntoMenu();
        else
            MapTracker:Detach();
            PinController.isEnabled = false;
            PinController:ListenEvents(false);
        end
    end

    local moduleData = {
        name = addon.L["ModuleName WorldMapPin_TWW"],
        dbKey = "WorldMapPin_TWW",
        description = string.format(L["ModuleDescription WorldMapPin_TWW"], L["Bountiful Delve"], L["Special Assignment"]);
        toggleFunc = EnableMapPinSystem,
        categoryID = 1,
        uiOrder = 1101,
        moduleAddedTime = 1721730000,
    };

    addon.ControlCenter:AddModule(moduleData);
end


do  --Dev Tool
    local DevTool;

    local function SavePOIPosition(poiData)
        if not DevTool then
            DevTool = CreateFrame("Frame");
        end

        DevTool.poiData = poiData;
        DevTool.index = 0;
        DevTool.t = 0;

        DevTool:SetScript("OnUpdate", function(self, elapsed)
            self.t = self.t + elapsed;
            if self.t > 0.25 then
                self.t = 0;
            else
                return
            end

            self.index = self.index + 1;
            local data = self.poiData[self.index];
            if not data then
                self:SetScript("OnUpdate", nil);
                return
            end

            local mapID = data[1];
            local poiID = data[2];
            local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, poiID);

            if poiInfo then
                if not data.name then
                    data.name = poiInfo.name;
                end

                local x, y = poiInfo.position:GetXY();
                API.ConvertMapPositionToContinentPosition(mapID, x, y, poiID);
            else
                print("Missing POI", poiID);
            end
        end);
    end
    addon.SavePOIPosition = SavePOIPosition;
end