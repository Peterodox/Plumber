local _, addon = ...
local API = addon.API;
local RaidCheck = addon.RaidCheck;


local SelectorUI = RaidCheck.SelectorUI;


local IsInInstance = IsInInstance;
local IsIndoors = IsIndoors;
local GetPlayerMap = API.GetPlayerMap;
local GetPlayerMapCoord = API.GetPlayerMapCoord;
local API_GetDungeonEntrancesForMap = C_EncounterJournal.GetDungeonEntrancesForMap;
local GetMapWorldSize = C_Map.GetMapWorldSize;
local GetMapGroupID = C_Map.GetMapGroupID;
local GetMapGroupMembersInfo = C_Map.GetMapGroupMembersInfo;


local DEFAULT_RANGE = 31^2;


local EL = CreateFrame("Frame");
RaidCheck.LocationTracker = EL;
EL.updateDelay = 0.5;   --Increase if the player is far away


EL.mapEvents = {
    PLAYER_ENTERING_WORLD = true,
    PLAYER_MAP_CHANGED = true,
    ZONE_CHANGED = true,
    ZONE_CHANGED_NEW_AREA = true,
    NEW_WMO_CHUNK = true,   --Flying from Caverns of Time exterior to interior doesn't trigger other events, so we need this to update the best uiMapID
    ZONE_CHANGED_INDOORS = true,
};

EL.instancePos = {
    --This overrides the info from map pin
    --Hardcode XY for certain instance whose entrance position doesn't match the pin
    --Some map pins don't show on map until you complete relevant quests or discover the map
    --[journalInstanceID] = {x, y, indoors}
    [786] = {0.44148, 0.59743, true},   --Nighthold
    [726] = {0.41068, 0.61744, true},   --The Arcway
    [187] = {0.61534, 0.26397},         --Dragon Soul
    [184] = {0.57381, 0.29142},         --End Time
    [750] = {0.35528, 0.15325},         --The Battle For Mount Hyjal
    [251] = {0.26814, 0.35114},         --Old Hillsbrad Foothills
    [255] = {0.35972, 0.83893},         --The Black Morass
    [279] = {0.57488, 0.82711},         --The Culling of Stratholme
    [1023]= {0.71979, 0.15423},         --Siege of Boralus (Alliance)
};

EL.instancePos_Horde = {
    [1023]= {0.88284, 0.51036},         --Siege of Boralus (Horde)
};

EL.mapsWithFloors = {
    --The usual map events may not trigger when BestMap changes. e.g. flying from Searing Gorge to Blackrock Depths
    [32] = true,
    [33] = true,
    [34] = true,
    [35] = true,
};

EL.extraPins = {
    --For instances with multiple entrances but the map only shows one.
    --[uimapID] = { {position = {x = 0, y = 0}, journalInstanceID = 0} }

    [42] = {
        {position = {x = 0.46691, y = 0.70226}, journalInstanceID = 860},    --Karazhan Side Entrance (Return to Karazhan, the dungeon) Main Entrance is the old raid
    },

    [55] = {
        {position = {x = 0.25667, y = 0.50933}, journalInstanceID = 63},    --Deadmines
    },
};

EL.ignoredMap = {
    --[uiMapID] = true,
    [52] = true,    --Westfall Deadmines entrance is actually on 55
};


local function GetDungeonEntrancesForMap(uiMapID)
    local dungeonEntrances;

    if not EL.ignoredMap[uiMapID] then
        dungeonEntrances = API_GetDungeonEntrancesForMap(uiMapID);
    end

    if EL.extraPins[uiMapID] then
        if not dungeonEntrances then
            dungeonEntrances = {};
        end
        for _, v in ipairs(EL.extraPins[uiMapID]) do
            table.insert(dungeonEntrances, v);
        end
    end

    return dungeonEntrances
end


function EL:DoesMapHaveFloors(uiMapID)
    if self.mapsWithFloors[uiMapID] == nil then
        local mapGroupID = GetMapGroupID(uiMapID);
        if mapGroupID and GetMapGroupMembersInfo(mapGroupID) then
            self.mapsWithFloors[uiMapID] = true;
        else
            self.mapsWithFloors[uiMapID] = false;
        end
    end
    return self.mapsWithFloors[uiMapID]
end

function EL:LoadFactionOverride()
    if API.GetPlayerFactionIndex() == 2 then
        for k, v in ipairs(self.instancePos_Horde) do
            self.instancePos[k] = v;
        end
    end
end

function EL:ListenEvents(state)
    if state then
        for event in pairs(self.mapEvents) do
            self:RegisterEvent(event);
        end
        self:SetScript("OnEvent", self.OnEvent);
    else
        for event in pairs(self.mapEvents) do
            self:UnregisterEvent(event);
        end
        self:SetScript("OnEvent", nil);
    end
end

function EL:OnEvent(event, ...)
    if self.mapEvents[event] then
        self:RequestUpdateMap();
        --print(event);
    else

    end
end

function EL:RequestUpdateMap()
    self.t = 0;
    self.mapDirty = true;
    self:SetScript("OnUpdate", self.OnUpdate);
end

function EL:UpdateMap()
    if self.isMultiFloors then
        self.mapDirty = true;
    else
        self.mapDirty = nil;
    end

    local uiMapID = GetPlayerMap();

    if uiMapID ~= self.uiMapID then
        self.uiMapID = uiMapID;

        local isMultiFloors = uiMapID and self:DoesMapHaveFloors(uiMapID);
        --print(uiMapID, isMultiFloors)
        if isMultiFloors then
            self.isMultiFloors = true;
        else
            self.isMultiFloors = nil;
        end

        local trackPosition;

        if IsInInstance() then
            self.isMultiFloors = nil;
        else
            if uiMapID then
                local dungeonEntrances = GetDungeonEntrancesForMap(uiMapID);
                self.x, self.y = GetPlayerMapCoord(uiMapID);
                self.mapWidth, self.mapHeight = GetMapWorldSize(uiMapID);
                if dungeonEntrances and #dungeonEntrances > 0 and self.x and self.y and self.mapWidth > 0 and self.mapHeight > 0 then
                    trackPosition = true;
                    self.dungeonEntrances = dungeonEntrances;
                    local entranceInfo = {};
                    local n = 0;
                    local x, y, indoorsOnly;
                    for k, v in ipairs(dungeonEntrances) do
                        if v.position then
                            n = n + 1;
                            if self.instancePos[v.journalInstanceID] then
                                x, y, indoorsOnly = unpack(self.instancePos[v.journalInstanceID]);
                            else
                                x = v.position.x;
                                y = v.position.y;
                            end
                            entranceInfo[n] = {
                                x = x,
                                y = y,
                                journalInstanceID = v.journalInstanceID,
                                indoorsOnly = indoorsOnly,
                            };
                        end
                    end
                    self.total = n;
                    self.entranceInfo = entranceInfo;
                    trackPosition = n > 0;
                end
            else

            end
        end

        if trackPosition then
            self.trackPosition = true;
            self.defaultRange = DEFAULT_RANGE;
            self:SetScript("OnUpdate", self.OnUpdate);
        else
            self.trackPosition = nil;
            self.total = 0;
            self.entranceInfo = nil;
            self:SetScript("OnUpdate", nil);
            SelectorUI:HideUI();
        end
    end
end

function EL:GetMapPointsDistanceSquare(x1, y1, x2, y2)
    local x = self.mapWidth * (x1 - x2);
    local y = self.mapHeight * (y1 - y2);

    return x*x + y*y
end

function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t >= self.updateDelay then
        self.t = 0;

        if self.mapDirty then
            self:UpdateMap();
        end

        if self.trackPosition then
            self.x, self.y = GetPlayerMapCoord(self.uiMapID);
            self.closestDistance = 10000;
            self.closestIndex = nil;

            if self.x then
                for i = 1, self.total do
                    local d = self:GetMapPointsDistanceSquare(self.x, self.y, self.entranceInfo[i].x, self.entranceInfo[i].y);
                    if d < self.closestDistance then
                        if (not self.entranceInfo[i].indoorsOnly) or IsIndoors() then
                            self.closestDistance = d;
                            self.closestIndex = i;
                        end
                    end
                end

                if self.closestDistance < 3600 then
                    --60 yds
                    self.updateDelay = 0.5;
                else
                    self.updateDelay = 1;
                end
            end

            --print(self.closestDistance, self.closestIndex and self.entranceInfo[self.closestIndex].journalInstanceID, self.x, self.y)

            if self.closestIndex and self.closestDistance < self.defaultRange then
                SelectorUI:ShowInstance(self.entranceInfo[self.closestIndex].journalInstanceID, self.uiMapID);
            else
                SelectorUI:HideUI();
            end
        end
    end
end

function EL:Enable(state)
    if state then
        self:ListenEvents(true);
        self:LoadFactionOverride();
        self:RequestUpdateMap();
    else
        self:SetScript("OnUpdate", nil);
        self:ListenEvents(false);
    end
end