-- 1. Show Bountiful Delve Entrance on Khaz Algar (Continent) Map



local _, addon = ...
local L = addon.L;
local API = addon.API;
local PinController = addon.MapPinController;

local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo;
local GetDelvesForMap = C_AreaPoiInfo.GetDelvesForMap;
local C_UIWidgetManager = C_UIWidgetManager;


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
    {2214, 8143, 8181},   --Excavation Site 9

    --Hallowfall
    {2215, 7869, 7780},   --Mycomancer Cavern
    {2215, 7868, 7785},   --Nightfall Sanctum
    {2215, 7871, 7789},   --Skittering Breach
    {2215, 7870, 7783},   --The Sinkhole

    --Azj-Kahet
    {2255, 7873, 7784},   --Tak-Rethan Abyss        
    {2255, 7874, 7790},   --The Spiral Weave
    {2255, 7872, 7786},   --The Underkeep

    --Undermine
    {2346, 8140, 8246},   --Sidestreet Sluice

    --K'aresh
    {2371, 8274, 8273},   --Archival Assault


    --{0, 7875, nil},    --Zekvir's Lair (Mystery 13th Delve)
    --8142 Demolition Dome  --Undermine Challenge
};

local POILocation = {}; --See the bottom of this file


local function IsOverchargedDelve(poiInfo)
    --11.1.7 Overcharge Delve
    if poiInfo.iconWidgetSet then
        local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(poiInfo.iconWidgetSet);
        if widgets then
            local widgetInfo;
            for _, widget in ipairs(widgets) do
                if widget.widgetType == 22 then     --Enum.UIWidgetVisualizationType.Spacer
                    widgetInfo = C_UIWidgetManager.GetSpacerVisualizationInfo(widget.widgetID);
                    if widgetInfo.shownState == 1 and widgetInfo.scriptedAnimationEffectID == 183 then
                        return true
                    end
                end
            end
        end
    end
end


local DelvesPinMixin = {};
do
    local ICON_WIDTH, ICON_HEIGHT = 20, 20;

    function DelvesPinMixin:PostMouseEnter()
        if self.data.uiMapID and self.data.poiID then
            local poiInfo = GetAreaPOIInfo(self.data.uiMapID, self.data.poiID);
            if poiInfo then
                local tooltip = GameTooltip;
                tooltip:Hide();
                tooltip:SetOwner(self, "ANCHOR_RIGHT");
                tooltip:SetText(poiInfo.name, 1, 1, 1);

                if poiInfo.description then
                    if self.data.bountiful then
                        tooltip:AddLine(poiInfo.description, 1, 0.82, 0, true);
                    end
                    if self.data.overcharged then
                        tooltip:AddLine(L["Overcharged Delve"], 0.000, 0.800, 1.000, true);
                    end
                end

                if poiInfo.tooltipWidgetSet then
                    tooltip:AddLine(" ");
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
        if self.data.overcharged then
            if self.data.bountiful then
                self:SetTexture("Interface/AddOns/Plumber/Art/MapPin/Delve-OverchargedBountiful", "LINEAR");
            else
                self:SetTexture("Interface/AddOns/Plumber/Art/MapPin/Delve-OverchargedOnly", "LINEAR");
            end
            self.sizeMultiplier = 2;
        else
            self:SetTexture("Interface/AddOns/Plumber/Art/MapPin/Delve-Bountiful", "LINEAR");
            self.sizeMultiplier = 1;
        end
        self:SetTexCoord(0, 1, 0, 1);
    end

    function DelvesPinMixin:SetSizeScale(scale)
        if not self.sizeMultiplier then
            self.sizeMultiplier = 1;
        end
        self.Texture:SetSize(ICON_WIDTH * scale * self.sizeMultiplier, ICON_HEIGHT * scale * self.sizeMultiplier);
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

        local uiMapID, poiInfo;
        local positionToCache, p;
        local bountiful, overcharged;

        for delveIndex, info in ipairs(DelvePOI) do
            uiMapID = info[1];
            poiID = info[3];    --bountifulPoi
            poiInfo = GetAreaPOIInfo(uiMapID, poiID);
            overcharged = false;

            if poiInfo then
                bountiful = true;
            else
                bountiful = false;
                poiID = info[2];
                poiInfo = GetAreaPOIInfo(uiMapID, poiID);
            end

            if poiInfo then
                --overcharged = IsOverchargedDelve(poiInfo);
            end

            if poiInfo and (bountiful or overcharged) then
                --overcharged = IsOverchargedDelve(poiInfo);

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
                        bountiful = bountiful,
                        overcharged = overcharged,
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

        --if positionToCache then
        --    API.ConvertAndCacheMapPositions(positionToCache, onCoordReceivedFunc, onConvertFinishedFunc);
        --end

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
    [8181] = {
        ["uiMapID"] = 2214,
        ["y"] = 0.744,
        ["x"] = 0.64,
        ["poiID"] = 8181,
        ["continent"] = 2274,
    },
    [8246] = {  --Slightly shift its position to it doesn't cover Gallywix's face
        ["uiMapID"] = 2346,
        ["y"] = 0.687,  --0.753
        ["x"] = 0.744,  --0.794
        ["poiID"] = 8246,
        ["continent"] = 2274,
    },

    [8273] = {  --K'aresh
        ["uiMapID"] = 2371,
        ["y"] = 0.290,
        ["x"] = 0.178,
        ["poiID"] = 8273,
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