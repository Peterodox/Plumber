-- 1. Show Bountiful Delve Entrance on Khaz Algar (Continent) Map



local _, addon = ...
local L = addon.L;
local API = addon.API;
local PinController = addon.MapPinController;

local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo;
local GetDelvesForMap = C_AreaPoiInfo.GetDelvesForMap;

local MAPID_KHAZALGAR = 2274;


local DelvePOI = {
    --{uiMapID, normalPoi, bountifulPoi}

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

local POILocation = {}; --See the bottom of this file


local DelvesPinMixin = {};
do
    function DelvesPinMixin:PostMouseEnter()
        if self.data.uiMapID and self.data.poiID then
            local poiInfo = GetAreaPOIInfo(self.data.uiMapID, self.data.poiID);
            if poiInfo then
                local tooltip = GameTooltip;
                tooltip:Hide();
                tooltip:SetOwner(self, "ANCHOR_RIGHT");
                tooltip:SetText(poiInfo.name, 1, 1, 1);

                if poiInfo.description then
                    tooltip:AddLine(poiInfo.description, 1, 1, 1, true);
                    tooltip:AddLine(" ", 1, 1, 1, true);
                end

                if poiInfo.tooltipWidgetSet then
                    self:AttachWidgetSetToTooltip(tooltip, poiInfo.tooltipWidgetSet);
                end

                tooltip:Show();
            end
        end
    end

    function DelvesPinMixin:IsMouseClickEnabled()
        return false
    end

    function DelvesPinMixin:OnMouseClickAction(mouseButton)

    end

    function DelvesPinMixin:Update()
        self:SetTexture("Interface/AddOns/Plumber/Art/MapPin/Delve-Bountiful", "LINEAR");
        self:SetTexCoord(0, 1, 0, 1);
        self.Texture:SetSize(20, 20);
    end
end


local DelvesPinDataProvider = {};
do
    local POIxDelveIndex;

    local function onCoordReceivedFunc(positionData)
        POILocation[positionData.poiID] = positionData;
    end

    local function onConvertFinishedFunc()
        PinController:RequestUpdate();
    end

    function DelvesPinDataProvider:GetPinDataForMap(uiMapID)
        --Bountiful Delves won't appear in GetDelvesForMap() table, that's how we identify them
        if uiMapID ~= MAPID_KHAZALGAR then return end;

        local data = {};
        local poiID;
        local n = 0;

        local ipairs = ipairs;

        if not POIxDelveIndex then
            POIxDelveIndex = {};
            for delveIndex, info in ipairs(DelvePOI) do
                poiID = info[2];
                if poiID then
                    POIxDelveIndex[poiID] = delveIndex;
                end
                poiID = info[3];
                if poiID then
                    POIxDelveIndex[poiID] = delveIndex;
                end
            end
        end

        local isBountiful = {};

        for delveIndex, info in ipairs(DelvePOI) do
            isBountiful[delveIndex] = true;
        end

        local delveIndex, areaPoiIDs;
        for _, mapID in ipairs(DelveMaps) do
            areaPoiIDs = GetDelvesForMap(mapID) or {};
            for _, poiID in ipairs(areaPoiIDs) do
                delveIndex = POIxDelveIndex[poiID];
                if delveIndex then
                    isBountiful[delveIndex] = false;
                end
            end
        end


        local uiMapID, poiInfo;
        local positionToCache, p;

        for delveIndex, info in ipairs(DelvePOI) do
            uiMapID = info[1];
            if isBountiful[delveIndex] then
                poiID = info[3];
                poiInfo = GetAreaPOIInfo(uiMapID, poiID)

                if poiInfo then
                    if isBountiful[delveIndex] then
                        if POILocation[poiID] then
                            n = n + 1;

                            if not data then
                                data = {};
                            end

                            data[n] = {
                                mixin = DelvesPinMixin,
                                x = POILocation[poiID].x,
                                y = POILocation[poiID].y,
                                clickable = false,
                                uiMapID = uiMapID,
                                poiID = poiID,
                            };

                        else
                            if poiInfo then
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
            end
        end

        if positionToCache then
            API.ConvertAndCacheMapPositions(positionToCache, onCoordReceivedFunc, onConvertFinishedFunc);
        end

        return data
    end

    local OptionData = {
        name = L["Bountiful Delve"],
        dbKey = "WorldMapPin_TWW_Delve",
        iconSetupFunc = function(texture)
            texture:SetTexture("Interface/AddOns/Plumber/Art/MapPin/FilterMenuIcons");
            texture:SetSize(20, 20);
            texture:SetTexCoord(0, 0.25, 0, 0.25);
        end
    };

    DelvesPinDataProvider.OptionData = OptionData;

    PinController:AddMapDataProvider(MAPID_KHAZALGAR, DelvesPinDataProvider);
end


do  --Deve Tool
    local function Yeet()
        local tbl = {};
        for index, data in ipairs(DelvePOI) do
            tbl[index] = {data[1], data[2]};
        end
        addon.SavePOIPosition(tbl)
    end
end