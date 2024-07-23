-- 1. Show Special Assignment Quest (Complete 4 normal WQs) Location on Khaz Algar (Continent) Map
---- Locked SA Quest appears before you reach max level, but it disappears when you unlock it. It will probably be fixed in the next builds.



local _, addon = ...
local L = addon.L;
local API = addon.API;
local PinController = addon.MapPinController;

local CreateVector2D = CreateVector2D;
local GetMapPosFromWorldPos = C_Map.GetMapPosFromWorldPos;
local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo;
local GetMapInfoAtPosition = C_Map.GetMapInfoAtPosition;

local MAPID_KHAZALGAR = 2274;


local POI_SPECIAL_WQ = {
    --Special Assignment
    --poiID, x, y, continent, widgetSetID
    --https://wago.tools/db2/AreaPOI?filter[Name_lang]=special%20as&page=1&sort[ID]=asc

    {7823, 2988, -4587, 2552, 1108},
    {7824, 1091, -1021, 2552, 1117},
    {7825, 1411, -4226, 2601, 1118},
    {7826, 3227.21, -3330, 2601, 1119},
    {7827, 1284, -1001, 2601, 1121},

    {7828, 4449, -834, 2601, 1120},
    {7829, -625, -1424, 2601, 1122},
    {7830, 4449, -834, 2601, 1123},
    {7886, 1049, -4334, 2552, 1297},
    {7887, 3385, -4532, 2552, 1298},
};



local POILocation = {};
POILocation[7829] = {   --Special Assignment: Bombs from Behind
    uiMapID = 2255,
    x = 0.4659,
    y = 0.78,           --(The real y is 0.7312) We changed this manually so it doesn't overlap the map's name (HitRect of Azj-Kahet map is bit messy, there are multiple sub areas)
};


local QuestPinMixin = {};
do
    local function WidgetTextRule(text)
        if string.find(text, "%d") then
            return true
        end
    end

    function QuestPinMixin:PostMouseEnter(fromTimer)
        if self.data.uiMapID and self.data.poiID then
            local poiInfo = GetAreaPOIInfo(self.data.uiMapID, self.data.poiID);
            if poiInfo then
                local tooltip = GameTooltip;
                tooltip:Hide();
                tooltip:SetOwner(self, "ANCHOR_RIGHT");
                tooltip:SetText(poiInfo.name, 1, 1, 1);

                if poiInfo.tooltipWidgetSet then
                    self:AttachWidgetSetToTooltip(tooltip, poiInfo.tooltipWidgetSet, WidgetTextRule);
                end

                tooltip:Show();

                --[[
                local verticalPadding = nil;
                if poiInfo.tooltipWidgetSet then
                    local titleAdded = true;
                    local overflow = GameTooltip_AddWidgetSet(tooltip, poiInfo.tooltipWidgetSet, titleAdded and poiInfo.addPaddingAboveTooltipWidgets and 10);  --This affects FPS
                    if overflow then
                        verticalPadding = -overflow;
                    end
                end

                tooltip:Show();

                if verticalPadding then
                    tooltip:SetPadding(0, verticalPadding);
                end

                if not fromTimer then
                    --Item Reward takes time to retrieve data
                    C_Timer.After(0.2, function()
                        if self:IsMouseMotionFocus() then
                            self:PostMouseEnter(true);
                        end
                    end);
                end
                --]]
            end
        end
    end

    function QuestPinMixin:IsMouseClickEnabled()
        return false
    end

    function QuestPinMixin:OnMouseClickAction(mouseButton)

    end

    function QuestPinMixin:Update()
        self:SetTexture("Interface/AddOns/Plumber/Art/MapPin/WorldQuest-Capstone", "LINEAR");
        self.Texture:SetSize(20, 25);

        local isLocked = false; --poiInfo.atlasName == worldquest-Capstone-questmarker-epic-Locked

        if isLocked then
            self:SetTexCoord(0, 0.5, 0, 0.625);
        else
            self:SetTexCoord(0.5, 1, 0, 0.625);
        end
    end
end


local SpecialQuestPinDataProvider = {};
do
    local function onCoordReceivedFunc(positionData)
        POILocation[positionData.poiID] = positionData;
    end

    local function onConvertFinishedFunc()
        PinController:RequestUpdate();
    end

    function SpecialQuestPinDataProvider:GetPinDataForMap(uiMapID)
        if uiMapID ~= MAPID_KHAZALGAR then return end;

        local data;
        local positionToCache, p;
        local poiID, continentID, worldPosition;
        local n = 0;

        for _, d in ipairs(POI_SPECIAL_WQ) do
            poiID = d[1];
            continentID = d[4];
            worldPosition = CreateVector2D(d[2], d[3]);
            local uiMapID, mapPosition = GetMapPosFromWorldPos(continentID, worldPosition);
            if uiMapID then
                local x, y = mapPosition:GetXY();
                local zoneMapInfo = GetMapInfoAtPosition(uiMapID, x, y);
                local zoneMapID = zoneMapInfo and zoneMapInfo.mapID or uiMapID;
                local poiInfo = GetAreaPOIInfo(zoneMapID, poiID);
                if poiInfo then
                    uiMapID = zoneMapID;
                    if POILocation[poiID] then
                        n = n + 1;

                        if not data then
                            data = {};
                        end

                        data[n] = {
                            mixin = QuestPinMixin,
                            x = POILocation[poiID].x,
                            y = POILocation[poiID].y,
                            clickable = false,
                            uiMapID = uiMapID,
                            poiID = poiID,
                        };

                    else
                        if not positionToCache then
                            positionToCache = {};
                            p = 0;
                        end

                        p = p + 1;
                        local x, y = poiInfo.position:GetXY();
                        local position = {
                            uiMapID = uiMapID,
                            poiID = poiID,
                            x = x,
                            y = y,
                        };

                        positionToCache[p] = position;
                    end
                end
            end
        end

        if positionToCache then
            API.ConvertAndCacheMapPositions(positionToCache, onCoordReceivedFunc, onConvertFinishedFunc);
        end

        return data
    end

    local OptionData = {
        name = L["Special Assignment"],
        dbKey = "WorldMapPin_TWW_Quest",
        iconSetupFunc = function(texture)
            texture:SetTexture("Interface/AddOns/Plumber/Art/MapPin/FilterMenuIcons");
            texture:SetSize(20, 20);
            texture:SetTexCoord(0.25, 0.5, 0, 0.25);
        end
    };

    SpecialQuestPinDataProvider.OptionData = OptionData;
    PinController:AddMapDataProvider(MAPID_KHAZALGAR, SpecialQuestPinDataProvider);
end