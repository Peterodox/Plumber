local _, addon = ...
local API = addon.API;
local RaidCheck = addon.RaidCheck;


local SelectorUI = RaidCheck.SelectorUI;


local IsInInstance = IsInInstance;
local GetPlayerMap = API.GetPlayerMap;
local GetPlayerMapCoord = API.GetPlayerMapCoord;
local GetDungeonEntrancesForMap = C_EncounterJournal.GetDungeonEntrancesForMap;
local GetMapWorldSize = C_Map.GetMapWorldSize;


local RangeCheckPresets = {
    --Occasionally Raid Entrance on map is far away from its actual position, increase range check in this case
    --[uiMapID] = range(number),

    [0] = 31^2,     --Default

    [680] = 120^2,  --Suramar
};


local EL = CreateFrame("Frame");
RaidCheck.LocationTracker = EL;


EL.events = {
    "PLAYER_ENTERING_WORLD",
    "PLAYER_MAP_CHANGED",
    "ZONE_CHANGED",
    "ZONE_CHANGED_NEW_AREA",
};

EL.mapEvents = {
    PLAYER_ENTERING_WORLD = true,
    PLAYER_MAP_CHANGED = true,
    ZONE_CHANGED = true,
    ZONE_CHANGED_NEW_AREA = true,
};

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
    else

    end
end

function EL:RequestUpdateMap()
    self.t = 0;
    self.mapDirty = true;
    self:SetScript("OnUpdate", self.OnUpdate);
end

function EL:UpdateMap()
    self.mapDirty = nil;

    local uiMapID = GetPlayerMap();
    if uiMapID ~= self.uiMapID then
        self.uiMapID = uiMapID;
        local trackPosition;

        if IsInInstance() then
            
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
                    for k, v in ipairs(dungeonEntrances) do
                        if v.position then
                            n = n + 1;
                            entranceInfo[n] = {
                                x = v.position.x,
                                y = v.position.y,
                                journalInstanceID = v.journalInstanceID,
                            }
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
            self.defaultRange = RangeCheckPresets[uiMapID] or RangeCheckPresets[0];
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
    if self.t >= 0.5 then
        self.t = 0;

        if self.mapDirty then
            self:UpdateMap();
        end

        if self.trackPosition then
            self.x, self.y = GetPlayerMapCoord(self.uiMapID);
            self.closestDistance = self.defaultRange;
            self.closestIndex = nil;

            for i = 1, self.total do
                local d = self:GetMapPointsDistanceSquare(self.x, self.y, self.entranceInfo[i].x, self.entranceInfo[i].y);
                if d < self.closestDistance then
                    self.closestDistance = d;
                    self.closestIndex = i;
                end
            end

            if self.closestIndex then
                --print(self.entranceInfo[self.closestIndex].journalInstanceID);
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
        self:RequestUpdateMap();
    else
        self:SetScript("OnUpdate", nil);
        self:ListenEvents(false);
    end
end