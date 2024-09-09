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
        --The method above no longer works

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


do  --Dev Tool
    local function Yeet()
        local tbl = {};
        local index = 0;
        for _, data in ipairs(DelvePOI) do
            index = index + 1;
            tbl[index] = {data[1], data[2]};
        end
        for _, data in ipairs(DelvePOI) do
            index = index + 1;
            tbl[index] = {data[1], data[3]};
        end
        addon.SavePOIPosition(tbl)
    end
end


POILocation = {
    [7786] = {
        ["uiMapID"] = 2255,
        ["y"] = 0.863,
        ["x"] = 0.451,
        ["poiID"] = 7786,
        ["continent"] = 2274,
    },
    [7863] = {
        ["uiMapID"] = 2248,
        ["y"] = 0.339,
        ["x"] = 0.673,
        ["poiID"] = 7863,
        ["continent"] = 2274,
    },
    [7865] = {
        ["uiMapID"] = 2248,
        ["y"] = 0.201,
        ["x"] = 0.778,
        ["poiID"] = 7865,
        ["continent"] = 2274,
    },
    [7867] = {
        ["uiMapID"] = 2214,
        ["y"] = 0.544,
        ["x"] = 0.62,
        ["poiID"] = 7867,
        ["continent"] = 2274,
    },
    [7868] = {
        ["uiMapID"] = 2215,
        ["y"] = 0.524,
        ["x"] = 0.327,
        ["poiID"] = 7868,
        ["continent"] = 2274,
    },
    [7779] = {
        ["uiMapID"] = 2248,
        ["y"] = 0.303,
        ["x"] = 0.733,
        ["poiID"] = 7779,
        ["continent"] = 2274,
    },
    [7870] = {
        ["uiMapID"] = 2215,
        ["y"] = 0.547,
        ["x"] = 0.39,
        ["poiID"] = 7870,
        ["continent"] = 2274,
    },
    [7871] = {
        ["uiMapID"] = 2215,
        ["y"] = 0.58,
        ["x"] = 0.448,
        ["poiID"] = 7871,
        ["continent"] = 2274,
    },
    [7782] = {
        ["uiMapID"] = 2214,
        ["y"] = 0.583,
        ["x"] = 0.525,
        ["poiID"] = 7782,
        ["continent"] = 2274,
    },
    [7873] = {
        ["uiMapID"] = 2255,
        ["y"] = 0.816,
        ["x"] = 0.461,
        ["poiID"] = 7873,
        ["continent"] = 2274,
    },
    [7874] = {
        ["uiMapID"] = 2255,
        ["y"] = 0.639,
        ["x"] = 0.429,
        ["poiID"] = 7874,
        ["continent"] = 2274,
    },
    [7780] = {
        ["uiMapID"] = 2215,
        ["y"] = 0.461,
        ["x"] = 0.47,
        ["poiID"] = 7780,
        ["continent"] = 2274,
    },
};

for _, data in pairs(DelvePOI) do
    local poi1 = data[2];
    local poi2 = data[3];

    if POILocation[poi1] and not POILocation[poi2] then
        POILocation[poi2] = POILocation[poi1];
    end

    if POILocation[poi2] and not POILocation[poi1] then
        POILocation[poi1] = POILocation[poi2];
    end
end