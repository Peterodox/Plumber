if not C_AreaPoiInfo.GetDelvesForMap then return end;


local _, addon = ...
local L = addon.L;
local API = addon.API;
local TimeLeftTextToSeconds = API.TimeLeftTextToSeconds;

local GetDelvesForMap = C_AreaPoiInfo.GetDelvesForMap;  --Fail to obtain Bountiful Delves (Bountiful Delves use AreaPOIPinTemplate, Other Delves use DelveEntrancePinTemplate)
local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo;
local C_UIWidgetManager = C_UIWidgetManager;


local DelvePOI = {
    --{mapID, normalPoi, bountifulPoi}

    --Isle of Dorn
    {2248, 7863, 7787},   --Earthcrawl Mines
    {2248, 7864, 7779},   --Fungal Folly
    {2248, 7865, 7781},   --Kriegval's Rest

    --Ringing Deeps
    {2214, 7867, 7788},   --The Dread Pit
    {2214, 7866, 7782},   --The Waterworks

    --Hallowfall
    {2215, 7869, 7780},   --Mycomancer Cavern
    {2215, 7868, 7785},   --Nightfall Sanctum
    {2215, 7871, 7789},   --Skittering Breach
    {2215, 7870, 7783},   --The Sinkhole

    --Azj-Kahet
    {2255, 7873, 7784},   --Tak-Rethan Abyss        
    {2255, 7874, 7790},   --The Spiral Weave
    {2255, 7872, 7786},   --The Underkeep


    --{0, 7875, nil},    --Zekvir's Lair (Mystery 13th Delve)
};

local DelveMaps = {
    2248, 2214, 2215, 2255,
};

local POIxDelveIndex = {};

do
    local poiID;

    for delveIndex, data in ipairs(DelvePOI) do
        poiID = data[2];
        if poiID then
            POIxDelveIndex[poiID] = delveIndex;
        end
        poiID = data[3];
        if poiID then
            POIxDelveIndex[poiID] = delveIndex;
        end
    end
end

function Dev_GetDelveMapInfo()
    --Bountfiul Delves have different poiID different from their regular modes
    --C_AreaPoiInfo.GetAreaPOISecondsLeft returns nil

    --/dump C_AreaPoiInfo.GetAreaPOIInfo(2215, 7783)

    for delveIndex, data in ipairs(DelvePOI) do
        data.isBountiful = true;
    end

    local areaPoiIDs, poiInfo;

    local n = 0;
    local poiData = {};
    local delveIndex;

    for _, mapID in ipairs(DelveMaps) do
        areaPoiIDs = GetDelvesForMap(mapID);
        for _, poiID in ipairs(areaPoiIDs) do
            delveIndex = POIxDelveIndex[poiID];
            if delveIndex then
                DelvePOI[delveIndex].isBountiful = nil;
            end
        end
    end

    local tooltipWidgetSet;

    for delveIndex, data in ipairs(DelvePOI) do
        if data.isBountiful then
            poiInfo = GetAreaPOIInfo(data[1], data[3])
        else
            poiInfo = GetAreaPOIInfo(data[1], data[2]);
        end
        
        if poiInfo then
            if not data.name then
                data.name = poiInfo.name;
            end

            if data.isBountiful then
                print(delveIndex, "|cnGREEN_FONT_COLOR:"..data.name.."|r");
                if not tooltipWidgetSet then
                    tooltipWidgetSet = poiInfo.tooltipWidgetSet;
                end
            else
                print(delveIndex, data.name);
            end
        end
    end

    if tooltipWidgetSet then
        local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(tooltipWidgetSet);
        local widgetID = widgets and widgets[1] and widgets[1].widgetID;

        if widgetID then
            local widgetInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(widgetID);
            if widgetInfo then
                local seconds = TimeLeftTextToSeconds(widgetInfo.text);
                print(seconds);
                print(API.SecondsToTime(seconds))
            end
        end
    end
end