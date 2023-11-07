local _, addon = ...
local API = addon.API;


local VIEWPORT_SCALE = 0.25;
local VIEWPORT_WIDTH, VIEWPORT_HEIGHT = 3840 * VIEWPORT_SCALE, 2560 * VIEWPORT_SCALE;
local VIEWPORT_MAX_ZOOM_SCALE = 1;
local VIEWPORT_MAX_ZOOM_STEPS = 5;
local MAP_EFFECTIVE_SCALE = 1;
local PAN_RATIO_X, PAN_RATIO_Y;
local MAP_CANVAS_TILE_SIZE;
local MAP_CANVAS_WIDTH, MAP_CANVAS_HEIGHT = 3840 * VIEWPORT_SCALE, 2560 * VIEWPORT_SCALE;

do
    local tileX, tileY = 4, 3;
    local tilePixel = 1024;
    local mapPixelX, mapPixelY = 3840, 2560;

    MAP_CANVAS_TILE_SIZE = tilePixel * VIEWPORT_SCALE;
    PAN_RATIO_X = mapPixelX * VIEWPORT_SCALE * MAP_CANVAS_WIDTH / VIEWPORT_WIDTH;
    PAN_RATIO_Y = mapPixelY * VIEWPORT_SCALE * MAP_CANVAS_HEIGHT / VIEWPORT_HEIGHT;
end


local MAP_DATA = {
    --[uiMapID] = { zones = { {x1, y1, areaID1}, } }
    [2200] = {--Emerald Dream 10.2.0
        --[[
        zones = {
            {0.2280, 0.3828, 14913},
            {0.3861, 0.1574, 14864},
            {0.6028, 0.2667, 14904},
            {0.3043, 0.5208, 14974},
            {0.5006, 0.4900, 14956},
            {0.7576, 0.4545, 14856},
            {0.5015, 0.5979, 14860},
            {0.6900, 0.6311, 14877},
            {0.3030, 0.7047, 15015},
        },
        --]]
        vignetteIDs = {
            5971,   --Emerald Bounty
            5844, 5789, 5792, 5776, 5787,  --Dreamseed Cache
        },
    },
};


local Clamp = API.Clamp;
local GetPlayerMapCoord = API.GetPlayerMapCoord;
local GetPlayerFacing = GetPlayerFacing;
local GetCursorPosition = GetCursorPosition;
local GetAreaInfo = C_Map.GetAreaInfo;
local C_VignetteInfo = C_VignetteInfo;


local MainFrame = CreateFrame("Frame", "PMAP", UIParent);
MainFrame:SetFrameStrata("HIGH");
MainFrame:SetSize(VIEWPORT_WIDTH, VIEWPORT_HEIGHT);
MainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
MainFrame:Hide();


local ZoneTextFont = CreateFont("PlumberZoneTextFont1");
do
    local pixel = API.GetPixelForWidget(UIParent, 1);

    local font, height = GameFontHighlightSmall:GetFont();
    ZoneTextFont:SetFont(font, 12*pixel, "");
    ZoneTextFont:SetTextColor(93/255, 63/255, 16/255);
    ZoneTextFont:SetJustifyH("CENTER");
    ZoneTextFont:SetJustifyV("MIDDLE");
    ZoneTextFont:SetSpacing(0);
    ZoneTextFont:SetShadowOffset(2*pixel, -2*pixel);
    --ZoneTextFont:SetShadowColor(222/255, 204/255, 90/255);
    ZoneTextFont:SetShadowColor(227/255, 210/255, 132/255);

    local ZoneTextFont2 = CreateFont("PlumberZoneTextFont2");
    ZoneTextFont2:CopyFontObject(ZoneTextFont);
    ZoneTextFont2:SetShadowOffset(-2*pixel, 2*pixel);
    --ZoneTextFont2:SetTextColor(222/255, 204/255, 90/255);
    --ZoneTextFont2:SetShadowColor(202/255, 190/255, 83/255);
    ZoneTextFont2:SetShadowColor(227/255, 210/255, 132/255, 1);
    ZoneTextFont2:SetTextColor(227/255, 210/255, 132/255);

    local ZoneTextFont3 = CreateFont("PlumberZoneTextFont3");
    ZoneTextFont3:CopyFontObject(ZoneTextFont2);
    ZoneTextFont3:SetShadowOffset(-2*pixel, -2*pixel);

    local ZoneTextFont4 = CreateFont("PlumberZoneTextFont4");
    ZoneTextFont4:CopyFontObject(ZoneTextFont2);
    ZoneTextFont4:SetShadowOffset(2*pixel, 2*pixel);
end

local MapPinMixin = {};

function MapPinMixin:SetXY(x, y)
    self.x, self.y = x, y;
    if x and y then
        self:UpdatePosition();
    end
end

function MapPinMixin:UpdatePosition()
    if not self.x then return end;
    local offsetX, offsetY = self.x * MAP_CANVAS_WIDTH * MAP_EFFECTIVE_SCALE, self.y * MAP_CANVAS_HEIGHT * MAP_EFFECTIVE_SCALE;
    self:SetPoint("CENTER", offsetX, -offsetY);
end

function MapPinMixin:Update()
    if self.updateFunc then
        self.updateFunc(self);
    end
end

function MapPinMixin:Remove()
    self.active = false;
    self:Hide();
    self:ClearAllPoints();
    if self.Icon then
        self.Icon:SetTexture(nil);
    end
    if self.TinyBar then
        self.TinyBar:Hide();
    end
    self:EnableMouse(false);
end

function MapPinMixin:OnEnter()
    if self.objectGUID then
        GameTooltip:Hide();
        local name = API.DreamseedUtil:GetPlantNameAndProgress(self.objectGUID);
        if name then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddLine(name, 1, 1, 1, true);
            GameTooltip:Show();
        end
        API.DreamseedUtil:GetRewards(self.objectGUID)
    end
end

function MapPinMixin:OnLeave()
    GameTooltip:Hide();
end

function MapPinMixin:OnMouseDown()
    MainFrame:OnMouseDown();
end

function MapPinMixin:OnMouseUp()
    MainFrame:OnMouseUp();
end


local function PinUpdateFunc_SeedPlanting(self)
    if not self.objectGUID then return end;
    
    local currentTime, fullTime = API.DreamseedUtil:GetGrowthTimes(self.objectGUID);
    if currentTime and currentTime > 0 then
        self.Icon:SetTexture("Interface/AddOns/Plumber/Art/MapPin/SeedPlanting-Green");
        self:SetSize(16, 16);

        if not self.TinyBar then
            self.TinyBar = addon.CreateTinyStatusBar(self);
            self.TinyBar:SetPoint("TOP", self, "BOTTOM", 0, -2);
            self.TinyBar:SetWidth(16);
        end
        self.TinyBar:Show();
        self.TinyBar:UpdateMaxBarFillWidth();
        self.TinyBar:SetReverse(true);
        self.TinyBar:SetTimes(fullTime - currentTime, fullTime);
    else
        self.Icon:SetTexture("Interface/AddOns/Plumber/Art/MapPin/SeedPlanting-Empty-Nearby");
        self:SetSize(12, 12);
        if self.TinyBar then
            self.TinyBar:Hide();
        end
    end
end

local PinUtil = {};

PinUtil.templates = {
    Player = {
        icon = "Player",
        level = 50,
        --size = 32,
    },

    ZoneText = {
        level = 10,
        hasLabel = true,
        icon = "ZoneTextDropShadow",
    },

    SeedPlanting = {
        icon = "SeedPlanting-Empty-Nearby",
        level = 40,
        size = 20,
        updateFunc = PinUpdateFunc_SeedPlanting,
    },
};

function PinUtil:RemoveAllPins()
    if not self.pins then return end;

    for _, pin in pairs(self.pins) do
        if pin.active then
            pin:Remove();
        end
    end
end

function PinUtil:Acquire(templateName)
    if not self.pins then
        self.pins = {};
        self.numPins = 0;
    end

    local pin;

    for i, p in ipairs(self.pins) do
        if not p.active then
            pin = p;
            break
        end
    end

    if not pin then
        pin = CreateFrame("Frame", nil, MainFrame.MapContainer);
        pin:SetSize(16, 16);
        table.insert(self.pins, pin);
        API.Mixin(pin, MapPinMixin);
        pin:SetScript("OnMouseDown", MapPinMixin.OnMouseDown);
        pin:SetScript("OnMouseUp", MapPinMixin.OnMouseUp);

        self.numPins = self.numPins + 1;

        pin:SetIgnoreParentScale(true);
        pin.Icon = pin:CreateTexture(nil, "ARTWORK");
        pin.Icon:SetAllPoints(true);
        pin:SetIgnoreParentAlpha(true);
        print("NEW PIN", #self.pins)
    end

    local templateData = templateName and self.templates[templateName];
    if templateData then
        if templateData.level then
            pin:SetFrameLevel(templateData.level);
        end

        if templateData.hasLabel then
            if not pin.Label then
                pin.Label = pin:CreateFontString(nil, "OVERLAY", "PlumberZoneTextFont1");
                pin.Label:SetPoint("CENTER", pin, "CENTER", 0, 0);
                pin.Label2 = pin:CreateFontString(nil, "ARTWORK", "PlumberZoneTextFont2");
                pin.Label2:SetPoint("CENTER", pin, "CENTER", 0, 0);
                pin.Label3 = pin:CreateFontString(nil, "ARTWORK", "PlumberZoneTextFont3");
                pin.Label3:SetPoint("CENTER", pin, "CENTER", 0, 0);
                pin.Label4 = pin:CreateFontString(nil, "ARTWORK", "PlumberZoneTextFont4");
                pin.Label4:SetPoint("CENTER", pin, "CENTER", 0, 0);
            end
            pin.Label:Show();
            pin.Label2:Show();
            pin.Label3:Show();
            pin.Label4:Show();
        end

        if templateData.icon then
            pin.Icon:SetTexture("Interface/AddOns/Plumber/Art/MapPin/"..templateData.icon, nil, nil, "TRILINEAR");
            pin.Icon:ClearAllPoints();
            if templateData.hasLabel then
                pin.Icon:SetPoint("TOPLEFT", pin.Label, "TOPLEFT", -12, 4);
                pin.Icon:SetPoint("BOTTOMRIGHT", pin.Label, "BOTTOMRIGHT", 12, -4);
            else
                pin.Icon:SetAllPoints(true);
            end
        end

        if templateData.size then
            local a = templateData.size;
            local uiScale = UIParent:GetEffectiveScale();
            pin:SetSize(a*uiScale, a*uiScale);
            local b = a/64;
            pin.Icon:SetTexCoord(0.5 - b, 0.5 + b, 0.5 - b, 0.5 + b);
        else
            pin:SetSize(16, 16);
            pin.Icon:SetTexCoord(0, 1, 0, 1);
        end
        
        pin.updateFunc = templateData.updateFunc;
    end

    pin:SetPoint("CENTER", MainFrame.MapContainer, "TOPLEFT", 0, 0);
    pin:Show();
    pin.active = true;

    return pin
end

function PinUtil:UpdateAllPins()
    for i, pin in ipairs(self.pins) do
        if pin.active then
            pin:UpdatePosition();
        end
    end
end

local function AddInteractableObject(obj)
    table.insert(MainFrame.InteractableObjects, obj);
end

local function UpdateMaxZoom()
    local SCREEN_WIDTH, SCREEN_HEIGHT = GetPhysicalScreenSize();
    local frameScale = MainFrame:GetEffectiveScale();
    local scale = 768 / SCREEN_HEIGHT / frameScale / VIEWPORT_SCALE;

    VIEWPORT_MAX_ZOOM_SCALE = scale;

    --print("MAX_ZOOM: "..VIEWPORT_MAX_ZOOM_SCALE);

    local zoomScale = 1;
    local scalePerDelta = 0.5;
    local maxZoomSteps = 1;

    for i = 2, VIEWPORT_MAX_ZOOM_STEPS do
        zoomScale = zoomScale + scalePerDelta;
        if zoomScale < VIEWPORT_MAX_ZOOM_SCALE then
            if zoomScale + scalePerDelta > VIEWPORT_MAX_ZOOM_SCALE then
                MainFrame.zoomScales[i] = VIEWPORT_MAX_ZOOM_SCALE;
                maxZoomSteps = i;
            else
                MainFrame.zoomScales[i] = zoomScale;
                maxZoomSteps = maxZoomSteps + 1;
            end
        else
            MainFrame.zoomScales[i] = VIEWPORT_MAX_ZOOM_SCALE;
        end
    end
    MainFrame.zoomScales[ VIEWPORT_MAX_ZOOM_STEPS ] = VIEWPORT_MAX_ZOOM_SCALE;

    MainFrame.maxZoomSteps = maxZoomSteps;
    --print("MAX STEPS: "..maxZoomSteps)
end


function MainFrame:Init()
    self.zoom = 1;
    self.zoomStep = 1;
    self.maxZoomSteps = 1;
    self.zoomScales = {1};
    self.InteractableObjects = {};

    --Tiles: total = 12(4*3), image = 1024x1024
    self.MapSlices = {};

    local ClipFrame = CreateFrame("Frame", nil, self);
    self.ClipFrame = ClipFrame;
    ClipFrame:SetClipsChildren(true);
    ClipFrame:SetSize(VIEWPORT_WIDTH, VIEWPORT_HEIGHT);
    ClipFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
    AddInteractableObject(ClipFrame);

    local container = CreateFrame("Frame", nil, ClipFrame);
    self.MapContainer = container;
    container:SetSize(8, 8);
    container:SetPoint("TOPLEFT", ClipFrame, "TOPLEFT", 0, 0);

    local size = MAP_CANVAS_TILE_SIZE;
    local slice;
    local col, row = 0, 0;

    self.Blackout = ClipFrame:CreateTexture(nil, "BACKGROUND", nil, -1);
    self.Blackout:SetPoint("TOPLEFT", ClipFrame, "TOPLEFT", 0, 0);
    self.Blackout:SetPoint("BOTTOMRIGHT", ClipFrame, "BOTTOMRIGHT", 0, 0);

    for i = 1, 12 do
        slice = container:CreateTexture(nil, "BACKGROUND");
        self.MapSlices[i] = slice;
        slice:SetSize(size, size);
        slice:SetPoint("TOPLEFT", container, "TOPLEFT", col*size, -row*size);
        col = col + 1;
        if col >= 4 then
            col = 0;
            row = row + 1;
        end
    end

    UpdateMaxZoom();
    self:RegisterEvent("UI_SCALE_CHANGED");
    self:RegisterEvent("DISPLAY_SIZE_CHANGED");

    self:LoadMap();

    --Header
    local CursorPosText = self:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    CursorPosText:SetPoint("BOTTOMLEFT", ClipFrame, "TOPLEFT", 0, 4);
    self.CursorPosText = CursorPosText;

    self.t1 = 0;    --Update player position, 60FPS
    self.t2 = 0;    --Update cursor position, 8FPS
    self:SetScript("OnUpdate", self.OnUpdate);
    --self:SetScript("OnMouseWheel", self.OnMouseWheel);
    --self:SetScript("OnMouseDown", self.OnMouseDown);
    --self:SetScript("OnMouseUp", self.OnMouseUp);

    self.Init = nil;
end

function MainFrame:LoadMap(uiMapID)
    uiMapID = uiMapID or C_Map.GetBestMapForUnit("player");

    local mapData = MAP_DATA[uiMapID];

    if not mapData then
        return
    end

    if uiMapID == self.uiMapID then return end;
    self.uiMapID = uiMapID;

    local filePrefix = "Interface/AddOns/Plumber/Art/WorldMap/2200_";
    local id;
    local filter = "TRILINEAR";    --TRILINEAR-LINEAR

    --self.Blackout:SetTexture(filePrefix.."thumbnail", nil, nil, "NEAREST");

    for i = 1, 12 do
        if i < 10 then
            id = "0"..i;
        else
            id = i;
        end
        self.MapSlices[i]:SetTexture(filePrefix..id, nil, nil, filter);
    end


    PinUtil:RemoveAllPins();
    self.PlayerPin = PinUtil:Acquire("Player");

    if mapData.zones then
        local pin, zoneName;
        for _, zoneData in ipairs(mapData.zones) do
            pin = PinUtil:Acquire("ZoneText");
            pin:SetXY(zoneData[1], zoneData[2]);
            zoneName = GetAreaInfo(zoneData[3]);
            if zoneName then
                zoneName = string.upper(zoneName);
                zoneName = string.gsub(zoneName, " ", "\n", 1);
                pin.Label:SetText(zoneName);
                pin.Label2:SetText(zoneName);
                pin.Label3:SetText(zoneName);
                pin.Label4:SetText(zoneName);
            end
        end
    end

    self.watchedVigetteIDs = {};
    if mapData.vignetteIDs then
        for i, vignetteID in ipairs(mapData.vignetteIDs) do
            self.watchedVigetteIDs[vignetteID] = true;
        end
    end

    self:SetMapScale(1);
    self:SetMapOffset(0, 0);
    self:UpdateVignettes();
end

function MainFrame:UpdateVignettes()
    --POIs
    local vignetteGUIDs = C_VignetteInfo.GetVignettes();
    local pin;
    local info, vignettePosition, vignetteFacing;
    local vignettesGUIDs = {};
    local total = 0;
    local uiMapID = self.uiMapID;

    PinUtil:RemoveAllPins();
    self.PlayerPin = PinUtil:Acquire("Player");

    for i, guid in ipairs(vignetteGUIDs) do
        info = C_VignetteInfo.GetVignetteInfo(guid);
        if info and info.vignetteID and self.watchedVigetteIDs[info.vignetteID] then
            total = total + 1;
            vignettesGUIDs[total] = info.vignetteGUID;
            vignettePosition, vignetteFacing = C_VignetteInfo.GetVignettePosition(info.vignetteGUID, uiMapID);
            if vignettePosition then
                pin = PinUtil:Acquire("SeedPlanting");
                pin:SetScript("OnEnter", MapPinMixin.OnEnter);
                pin:SetScript("OnLeave", MapPinMixin.OnLeave);
                pin:EnableMouse(true);
                pin:SetXY(vignettePosition:GetXY());
                pin.objectGUID = info.objectGUID;
                pin:Update();
            end
        end
    end

    --print("UpdateVignettes")
end

function MainFrame:OnUpdate(elapsed)
    self.t1 = self.t1 + elapsed;
    if self.t1 > 0.016 then
        self.t1 = 0;
        if self.PlayerPin then
            local coordX, coordY = GetPlayerMapCoord(self.uiMapID);
            self.PlayerPin:SetXY(coordX, coordY);
            self.facing = GetPlayerFacing();
            self.PlayerPin.Icon:SetRotation(self.facing or 0);
            --self:CenterMapAtCoord(coordX, coordY);
        end
    end

    self.t2 = self.t2 + elapsed;
    if self.t2 >= 0.125 then
        self.t2 = 0;
        local cx, cy = self:GetCursorMapCoord();
        self.CursorPosText:SetText(string.format("%.2f, %.2f", cx*100, cy*100));
    end

    if self.isMouseDown then
        self:ProcessMousePan();
    end
end

function MainFrame:GetCursorMapCoord()
    local cursorX, cursorY = GetCursorPosition();
    local effectiveScale = self:GetEffectiveScale();
    cursorX = cursorX / effectiveScale;
    cursorY = cursorY / effectiveScale;

    local left = MainFrame.ClipFrame:GetLeft();
    local top = MainFrame.ClipFrame:GetTop();

    local rx =  ((cursorX - left)/self.mapScale - self.mapOffsetX)/MAP_CANVAS_WIDTH;
    local ry = ((top - cursorY)/self.mapScale + self.mapOffsetY)/MAP_CANVAS_HEIGHT;

    rx = Clamp(rx, 0, 1);
    ry = Clamp(ry, 0, 1);

    return rx, ry
end

function MainFrame:ConvertMapCoordToOffset(coordX, coordY)
    local cursorX, cursorY = GetCursorPosition();
    local effectiveScale = self:GetEffectiveScale();
    cursorX = cursorX / effectiveScale;
    cursorY = cursorY / effectiveScale;

    local left = MainFrame.ClipFrame:GetLeft();
    local top = MainFrame.ClipFrame:GetTop();

    local x = (cursorX - left)/self.mapScale - coordX*MAP_CANVAS_WIDTH;
    local y = coordY*MAP_CANVAS_HEIGHT - (top - cursorY)/self.mapScale;
    return x, y
end

function MainFrame:OnMouseWheel(delta)
    if delta > 0 and self.zoomStep < self.maxZoomSteps then
        self.zoomStep = self.zoomStep + 1;
    elseif delta < 0 and self.zoomStep > 1 then
        self.zoomStep = self.zoomStep - 1;
    else
        return
    end

    local rx, ry = self:GetCursorMapCoord();

    local newScale = self.zoomScales[self.zoomStep];
    self:SetMapScale(newScale);

    local x, y = self:ConvertMapCoordToOffset(rx, ry);
    self:SetMapOffset(x, y)
end

function MainFrame:SetMapScale(mapScale)
    self.mapScale = mapScale;
    self.MapContainer:SetScale(mapScale);

    MAP_EFFECTIVE_SCALE = self.MapContainer:GetEffectiveScale();

    self.maxPanX = -MAP_CANVAS_WIDTH + VIEWPORT_WIDTH/mapScale;
    self.maxPanY = MAP_CANVAS_HEIGHT - VIEWPORT_HEIGHT/mapScale;

    if self.mapOffsetX and self.mapOffsetY then
        self:SetMapOffset(self.mapOffsetX, self.mapOffsetY);
    end

    PinUtil:UpdateAllPins();
end

function MainFrame:SetInteractable(state)
    for _, obj in pairs(self.InteractableObjects) do
        obj:EnableMouse(state);
    end
end


function MainFrame:ProcessMousePan()
    local cursorX, cursorY = GetCursorPosition();
    local diffX = cursorX - self.fromCursorX;
    local diffY = cursorY - self.fromCursorY;
    diffX = diffX * self.cursorScale / self.mapScale;
    diffY = diffY * self.cursorScale / self.mapScale;

    self:SetMapOffset(self.fromOffsetX + diffX, self.fromOffsetY + diffY);
end

function MainFrame:SetMapOffset(offsetX, offsetY)
    offsetX = Clamp(offsetX, self.maxPanX, 0);
    offsetY = Clamp(offsetY, 0, self.maxPanY);
    self.MapContainer:SetPoint("TOPLEFT", offsetX, offsetY);
    self.mapOffsetX = offsetX;
    self.mapOffsetY = offsetY;
end

function MainFrame:CenterMapAtCoord(coordX, coordY)
    local canvasX = coordX * MAP_CANVAS_WIDTH;
    local canvasY = coordY * MAP_CANVAS_HEIGHT;
    local viewportX = VIEWPORT_WIDTH * 0.5;
    local viewportY = VIEWPORT_HEIGHT * 0.5;
    local diffX = -canvasX + viewportX/self.mapScale;
    local diffY = canvasY - viewportY/self.mapScale;
    self:SetMapOffset(diffX, diffY);
end

function MainFrame:OnMouseDown()
    self.fromCursorX, self.fromCursorY = GetCursorPosition();
    local _;
    _, _, _, self.fromOffsetX, self.fromOffsetY = self.MapContainer:GetPoint(1);
    self.cursorScale = 1/UIParent:GetEffectiveScale();

    self.isMouseDown = true;
end

function MainFrame:OnMouseUp()
    self.isMouseDown = false;
end

function MainFrame:OnShow()
    self:RegisterEvent("UPDATE_UI_WIDGET");
    self:RegisterEvent("VIGNETTES_UPDATED");
end
MainFrame:SetScript("OnShow", MainFrame.OnShow);

function MainFrame:OnHide()
    self.isMouseDown = false;
    self:UnregisterEvent("UPDATE_UI_WIDGET");
    self:UnregisterEvent("VIGNETTES_UPDATED");
end
MainFrame:SetScript("OnHide", MainFrame.OnHide);


MainFrame.widgetData = {};

function MainFrame:AddWidgetInfo(widgetInfo)
    local widgetID = widgetInfo.widgetID;
    if not self.widgetData[widgetID] then
        self.widgetData[widgetID] = widgetInfo.widgetType;
        print("ID:", widgetInfo.widgetID, "  Type:", widgetInfo.widgetType)
        return true
    end
end

local numWidgets = 0;
local WATCHED_TYPE = {
    [2] = true,
    [27] = true,
    [8] = true,
    [20] = true,
}
local function YeetWidgetInfo(widgetID, widgetType)
    --https://wowpedia.fandom.com/wiki/UPDATE_UI_WIDGET
    if not WATCHED_TYPE[widgetType] then return end;

    local widgetTypeInfo = UIWidgetManager:GetWidgetTypeInfo(widgetType);
    if not widgetTypeInfo then return end;

    local widgetInfo = widgetTypeInfo.visInfoDataFunction(widgetID);
    if not widgetInfo then return end;

    if widgetInfo.text then print(widgetInfo.text) end;
    if widgetInfo.tooltip then print(widgetInfo.tooltip) end;
    if widgetInfo.timerTooltip then print(widgetInfo.timerTooltip) end;

    if false then
        local widgetFrame = CreateFrame(widgetTypeInfo.templateInfo.frameType, nil, MainFrame, widgetTypeInfo.templateInfo.frameTemplate);
        numWidgets = numWidgets + 1;
        widgetFrame:SetPoint("TOP", UIParent, "TOP", 0, -48*numWidgets);

        widgetFrame.widgetID = widgetID;
        widgetFrame.widgetSetID = 0;
        widgetFrame.widgetType = widgetType;
        widgetFrame.hasTimer = widgetInfo.hasTimer;
        widgetFrame.orderIndex = widgetInfo.orderIndex;
        widgetFrame.widgetTag = widgetInfo.widgetTag;
        widgetFrame.inAnimType = widgetInfo.inAnimType;
        widgetFrame.outAnimType = widgetInfo.outAnimType;
        widgetFrame.layoutDirection = widgetInfo.layoutDirection; 
        widgetFrame.modelSceneLayer = widgetInfo.modelSceneLayer;
        widgetFrame.scriptedAnimationEffectID = widgetInfo.scriptedAnimationEffectID;
        widgetFrame.markedForRemove = nil;

        if widgetFrame.hasTimer then
            print(widgetID, "has a timer");
        end

        widgetFrame:Setup(widgetInfo, MainFrame);

        local isNewWidget = true;
        if isNewWidget and widgetFrame.OnAcquired then
            widgetFrame:OnAcquired(widgetInfo);
        end
    end
end

MainFrame:RegisterEvent("VIGNETTES_UPDATED");

function MainFrame:OnEvent(event, ...)
    if event == "UPDATE_UI_WIDGET" then
        local widgetInfo = ...
        if API.DreamseedUtil:IsValuableWidget(widgetInfo.widgetID) then
            self:UpdateVignettes();
        end
        local isNew = self:AddWidgetInfo(widgetInfo);
        if isNew then
            YeetWidgetInfo(widgetInfo.widgetID, widgetInfo.widgetType);
        end
    elseif event == "VIGNETTES_UPDATED" then
        self:UpdateVignettes();

    elseif event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
        UpdateMaxZoom();
    end
end

MainFrame:SetScript("OnEvent", MainFrame.OnEvent);

--C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo

MainFrame:Init()
MainFrame:Show();
MainFrame:SetAlpha(0)