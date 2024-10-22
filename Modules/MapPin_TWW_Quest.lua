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
local IsQuestActive = C_TaskQuest.IsActive;
local GetQuestLocation = C_TaskQuest.GetQuestLocation;
local GetQuestInfoByQuestID = C_TaskQuest.GetQuestInfoByQuestID;

local MAPID_KHAZALGAR = 2274;

local POI_SPECIAL_WQ = {
    --Special Assignment
    --poiID, x, y, continent, widgetSetID, questID
    --https://wago.tools/db2/AreaPOI?filter[Name_lang]=special%20as&page=1&sort[ID]=asc

    {7823, 2988, -4587, 2552, 1108, 82355},     --Special Assignment: Cinderbee Surge
    {7824, 1091, -1021, 2552, 1117, 81647},     --Special Assignment: Titanic Resurgence (Isle of Dorn)
    {7825, 1411, -4226, 2601, 1118, 81691},     --Special Assignment: Shadows Below
    {7826, 3227.21, -3330, 2601, 1119, 83229},  --Special Assignment: When the Deeps Stir
    {7827, 1284, -1001, 2601, 1121, 82852},     --Special Assignment: Lynx Rescue

    {7828, 4449, -834, 2601, 1120, 82787},      --Special Assignment: Rise of the Colossals
    {7829, -625, -1424, 2601, 1122, 82531},     --Special Assignment: Bombs from Behind
    {7830, 4449, -834, 2601, 1123, 82414},      --Special Assignment: A Pound of Cure
    {7886, 1049, -4334, 2552, 1297, 81649},     --Special Assignment: Titanic Resurgence
    {7887, 3385, -4532, 2552, 1298, 81650},     --Special Assignment: Titanic Resurgence (Same name different locations?)
};



local POILocation = {};


local QuestPinMixin = {};
do
    local function WidgetTextRule(text)
        if string.find(text, "%d") then
            return true
        end
    end

    function QuestPinMixin:PostMouseEnter(fromTimer)
        if self.data.uiMapID and self.data.poiID then
            local tooltip = GameTooltip;
            tooltip:Hide();

            local questID = self.data.questID;

            if self.data.isQuest and questID then
                tooltip:SetOwner(self, "ANCHOR_RIGHT");

                if ( not HaveQuestData(questID) ) then
                    GameTooltip_SetTitle(tooltip, RETRIEVING_DATA, RED_FONT_COLOR);
                    GameTooltip_SetTooltipWaitingForData(tooltip, true);
                    tooltip:Show();
                    self:TriggerMouseReEnter();
                    return
                end

                local questName = GetQuestInfoByQuestID(questID)
                tooltip:SetText(questName, 1, 1, 1, true);
                self:AddQuestTimeToTooltip(tooltip, questID);
                tooltip:Show();

                return
            end

            local poiInfo = GetAreaPOIInfo(self.data.uiMapID, self.data.poiID);
            if poiInfo then
                tooltip:SetOwner(self, "ANCHOR_RIGHT");
                tooltip:SetText(poiInfo.name, 1, 1, 1, true);

                if poiInfo.tooltipWidgetSet then
                    self:AttachWidgetSetToTooltip(tooltip, poiInfo.tooltipWidgetSet, WidgetTextRule);
                end

                tooltip:Show();
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

        local isLocked = not self.data.isQuest; --poiInfo.atlasName == worldquest-Capstone-questmarker-epic-Locked

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
        local poiID, questID, continentID, worldPosition, key, isQuest, isSpawned;
        local n = 0;

        for _, d in ipairs(POI_SPECIAL_WQ) do
            poiID = d[1];
            questID = d[6];
            continentID = d[4];
            worldPosition = CreateVector2D(d[2], d[3]);

            if questID and IsQuestActive(questID) then
                key = questID;
                isQuest = true;
            else
                key = poiID;
                isQuest = false;
            end

            local uiMapID, mapPosition = GetMapPosFromWorldPos(continentID, worldPosition);
            if uiMapID then
                local x, y = mapPosition:GetXY();
                local zoneMapInfo = GetMapInfoAtPosition(uiMapID, x, y);
                local zoneMapID = zoneMapInfo and zoneMapInfo.mapID or uiMapID;
                local localX, localY;

                if isQuest then
                    isSpawned = true;
                    localX, localY = GetQuestLocation(questID, zoneMapID);
                else
                    local poiInfo = GetAreaPOIInfo(zoneMapID, poiID);
                    if poiInfo then
                        isSpawned = true;
                        localX, localY = poiInfo.position:GetXY();
                    else
                        isSpawned = false;
                    end
                end

                if isSpawned then
                    uiMapID = zoneMapID;
                    if POILocation[key] then
                        n = n + 1;

                        if not data then
                            data = {};
                        end

                        data[n] = {
                            mixin = QuestPinMixin,
                            x = POILocation[key].x,
                            y = POILocation[key].y,
                            clickable = false,
                            uiMapID = uiMapID,
                            poiID = poiID,
                            questID = questID,
                            isQuest = isQuest,
                        };

                    else
                        if not positionToCache then
                            positionToCache = {};
                            p = 0;
                        end

                        p = p + 1;

                        local position = {
                            uiMapID = uiMapID,
                            x = localX,
                            y = localY,
                            poiID = key,
                            questID = questID,
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


do  --Dev Tool
    local DevTool;

    local function Yeet()
        local tbl = {};
        local index = 0;

        for _, d in ipairs(POI_SPECIAL_WQ) do
            local poiID = d[1];
            local questID = d[6];
            local continentID = d[4];
            local worldPosition = CreateVector2D(d[2], d[3]);

            local uiMapID, mapPosition = GetMapPosFromWorldPos(continentID, worldPosition);
            if uiMapID then
                index = index + 1;
                local x, y = mapPosition:GetXY();
                tbl[index] = {
                    uiMapID = uiMapID,
                    x = x,
                    y = y,
                    poiID = poiID,
                };
            else
                print("NOT FOUND:", poiID, questID);
            end
        end


        if not DevTool then
            DevTool = CreateFrame("Frame");
        end

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
            local data = tbl[self.index];
            if not data then
                self:SetScript("OnUpdate", nil);
                return
            end

            API.ConvertMapPositionToContinentPosition(data.uiMapID, data.x, data.y, data.poiID);
        end);
    end

    local function PrintTaskNames(uiMapID)
        uiMapID = uiMapID or C_Map.GetBestMapForUnit("player");
        print("MAP", uiMapID)
        for _, data in ipairs(C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID)) do
            print(data.questId, QuestUtils_GetQuestName(data.questId), API.RoundCoord(data.x), API.RoundCoord(data.y))
        end
    end
end


POILocation = {
    [7887] = {
        ["uiMapID"] = 2248,
        ["y"] = 0.148,
        ["x"] = 0.825,
        ["poiID"] = 7887,
        ["continent"] = 2274,
    },
    [7823] = {
        ["uiMapID"] = 2248,
        ["y"] = 0.179,
        ["x"] = 0.828,
        ["poiID"] = 7823,
        ["continent"] = 2274,
    },
    [7824] = {
        ["uiMapID"] = 2248,
        ["y"] = 0.327,
        ["x"] = 0.641,
        ["poiID"] = 7824,
        ["continent"] = 2274,
    },
    [7825] = {
        ["uiMapID"] = 2274,
        ["y"] = 0.588,
        ["x"] = 0.597,
        ["poiID"] = 7825,
        ["continent"] = 2274,
    },
    [7826] = {
        ["uiMapID"] = 2274,
        ["y"] = 0.461,
        ["x"] = 0.555,
        ["poiID"] = 7826,
        ["continent"] = 2274,
    },
    [7827] = {
        ["uiMapID"] = 2274,
        ["y"] = 0.597,
        ["x"] = 0.446,
        ["poiID"] = 7827,
        ["continent"] = 2274,
    },
    [7828] = {
        ["uiMapID"] = 2274,
        ["y"] = 0.375,
        ["x"] = 0.438,
        ["poiID"] = 7828,
        ["continent"] = 2274,
    },
    [7829] = {
        ["uiMapID"] = 2274,
        ["y"] = 0.731,
        ["x"] = 0.466,
        ["poiID"] = 7829,
        ["continent"] = 2274,
    },
    [7830] = {  --Pound of Cure
        ["uiMapID"] = 2274,
        ["y"] = 0.375,
        ["x"] = 0.438,
        ["poiID"] = 7830,
        ["continent"] = 2274,
    },
    [7886] = {
        ["uiMapID"] = 2248,
        ["y"] = 0.33,
        ["x"] = 0.814,
        ["poiID"] = 7886,
        ["continent"] = 2274,
    },
};

for _, data in pairs(POI_SPECIAL_WQ) do
    local poiID = data[1];
    local questID = data[6];

    if POILocation[poiID] and not POILocation[questID] then
        POILocation[questID] = POILocation[poiID];
    end
end

--Override Location
POILocation[7829] = {   --Special Assignment: Bombs from Behind
    uiMapID = 2255,
    x = 0.4659,
    y = 0.78,           --(The real y is 0.7312) We changed this manually so it doesn't overlap the map's name (HitRect of Azj-Kahet map is bit messy, there are multiple sub areas)
};

POILocation[82414] = {
    --Pound of Cure (It seems the quest pin moves to its true location after being unlocked)
    --We slightly move the pin so player knows it's in Azj-Kahet
    ["uiMapID"] = 2274,
    ["y"] = 0.65,  --0.606
    ["x"] = 0.495,  --0.491
    ["poiID"] = 7830,
    ["continent"] = 2274,
};