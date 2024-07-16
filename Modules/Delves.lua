if not C_AreaPoiInfo.GetDelvesForMap then return end;


local _, addon = ...
local L = addon.L;
local API = addon.API;
local UIFrameFade = API.UIFrameFade;
local TimeLeftTextToSeconds = API.TimeLeftTextToSeconds;
local IsInDelves = API.IsInDelves;

local GetDelvesForMap = C_AreaPoiInfo.GetDelvesForMap;  --Fail to obtain Bountiful Delves (Bountiful Delves use AreaPOIPinTemplate, Other Delves use DelveEntrancePinTemplate)
local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo;
local C_UIWidgetManager = C_UIWidgetManager;
local GetMajorFactionRenownInfo = C_MajorFactions.GetMajorFactionRenownInfo;
local GetDelvesFactionForSeason = C_DelvesUI.GetDelvesFactionForSeason;


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

do  --Format Data
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


local EL = CreateFrame("Frame");
EL.handlers = {};
EL:SetScript("OnEvent", function(self, event, ...)
    if self.handlers[event] then
        self.handlers[event](...)
    end
end);

function EL:AddHandler(event, func)
    self.handlers[event] = func;
end

function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0 then
        self.t = nil;
        self:SetScript("OnUpdate", nil);
        for _, queuedFunc in ipairs(self.queuedFuncs) do
            queuedFunc();
        end
        self.queuedFuncs = nil;
    end
end

function EL:ProcessOnNextCycle(func)
    if not self.queuedFuncs then
        self.queuedFuncs = {};
    end

    self.t = -0.2;
    self:SetScript("OnUpdate", self.OnUpdate);

    for _, queuedFunc in ipairs(self.queuedFuncs) do
        if queuedFunc == func then
            return
        end
    end

    table.insert(self.queuedFuncs, func);
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
    local mapID, poiID;

    for delveIndex, data in ipairs(DelvePOI) do
        mapID = data[1];
        if data.isBountiful then
            poiID = data[3];
        else
            poiID = data[2];
        end
        poiInfo = GetAreaPOIInfo(mapID, poiID)

        if poiInfo then
            if not data.name then
                data.name = poiInfo.name;
            end

            if data.isBountiful then
                print(delveIndex, "|cnGREEN_FONT_COLOR:"..data.name.."|r");
                if not tooltipWidgetSet then
                    tooltipWidgetSet = poiInfo.tooltipWidgetSet;
                end
                local x, y = poiInfo.position:GetXY();
                API.ConvertMapPositionToContinentPosition(mapID, x, y, poiID);
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


local SeasonUtil = {};
do  --Seasonal Journey Progress
    local FADEOUT_DELAY = 4;

    local ProgressBar;

    local function ProgressBar_Init()
        if ProgressBar then return end;

        ProgressBar = addon.CreateLevelProgressBar(UIParent);
        ProgressBar:SetPoint("CENTER", UIParent, "TOP", 0, -128);
        ProgressBar:SetLabel("Seasonal Journey");
        ProgressBar:SetLevel(5);
        ProgressBar:SetFrameStrata("HIGH");
        ProgressBar:SetFrameLevel(990);
        ProgressBar:Hide();
        ProgressBar:SetAlpha(0);
        ProgressBar:SetUseAnimation(true);
        ProgressBar:SetAutoFadeOut(true);

        ProgressBar.FadeUpdateFrame = CreateFrame("Frame");
        ProgressBar.FadeUpdateFrame:Hide();

        ProgressBar.FadeUpdateFrame:SetScript("OnUpdate", function(f, elapsed)
            f.t = f.t + elapsed;
            if f.t >= FADEOUT_DELAY then
                f.t = 0;
                f:Hide();
                UIFrameFade(ProgressBar, 0.25, 0);
            end
        end);

        ProgressBar.onEnterFunc = function()
            ProgressBar:FadeIn();
        end

        ProgressBar.onLeaveFunc = function()
            ProgressBar:StartFadeOutCountdown(1);
        end

        function ProgressBar:FadeIn()
            ProgressBar.FadeUpdateFrame:Hide();
            UIFrameFade(self, 0.25, 1);
        end

        function ProgressBar:StartFadeOutCountdown(delay)
            if self:IsAnimating() then
                return
            end
            ProgressBar.FadeUpdateFrame:Show();
            ProgressBar.FadeUpdateFrame.t = delay or 0;
        end

        function ProgressBar:ShowProgress()
            self:FadeIn();
            local level, earned, threshold = SeasonUtil:GetProgress();
            self:SetLevel(level);
            self:SetMaxValue(threshold);
            self:SetValue(earned);
        end

        PB = ProgressBar;   --Debug

        function ProgressBar:Test()
            local level, earned, threshold = 2, 3300, 4200;
            local deltaEarned, levelUp, reachMaxLevel =  290, true, false;

            self:FadeIn();
            self:SetMaxValue(threshold);
            self:SetValue(earned, levelUp);
            self:AnimateDeltaValue(deltaEarned);
            self:SetLevel(level, reachMaxLevel);
        end
    end


    function SeasonUtil:SetEnabled(state)
        if state then
            EL:RegisterEvent("WALK_IN_DATA_UPDATE");   --Always registered
        else
            EL:UnregisterEvent("WALK_IN_DATA_UPDATE");
            EL:UnregisterEvent("PLAYER_MAP_CHANGED");
            EL:UnregisterEvent("SCENARIO_COMPLETED");
            EL:UnregisterEvent("UPDATE_FACTION");
        end
    end

    function SeasonUtil:GetProgress()
        local renownInfo = GetMajorFactionRenownInfo(GetDelvesFactionForSeason());
        if not renownInfo then return 0, 0, 1 end;

        local level = renownInfo.renownLevel or 1;
        local earned = renownInfo.renownReputationEarned or 0;
        local threshold = renownInfo.renownLevelThreshold or 1;

        level = level - 1;

        return level, earned, threshold
    end

    function SeasonUtil:SnapShotSeasonalProgress()
        --Assume the amount of renown required to gain 1 level is a constant (4200)
        local level, earned, threshold = self:GetProgress();

        local deltaLevel, deltaEarned;

        if self.renownLevel then
            deltaLevel = level - self.renownLevel;
        else
            deltaLevel = 0;
        end

        local levelUp = deltaLevel > 0;

        if self.renownReputationEarned and self.renownLevelThreshold then
            if levelUp then
                deltaEarned = earned + self.renownLevelThreshold - self.renownReputationEarned;
            else
                deltaEarned = earned - self.renownReputationEarned;
            end
        end

        self.renownLevel = level;
        self.renownReputationEarned = earned;
        self.renownLevelThreshold = threshold;

        --print(level, earned, threshold);

        local reachMaxLevel = (not threshold) or threshold <= 0;

        if deltaEarned and deltaEarned > 0 then
            return true, level, earned, threshold, deltaEarned, levelUp, reachMaxLevel
        end
    end

    local function UpdateDelveStatus()
        --Seasonal Progress changes after looting a chest in the end
        --We start listening UPDATE_FACTION after the scenario is completed (Companion level is also a faction)
        --C_DelvesUI.HasActiveDelve doesn't change immediately after PLAYER_MAP_CHANGED
        if IsInDelves() then
            EL:RegisterEvent("SCENARIO_COMPLETED");
            EL:RegisterEvent("PLAYER_MAP_CHANGED");
            print("IN Delve");
            return true
        else
            EL:UnregisterEvent("SCENARIO_COMPLETED");
            EL:UnregisterEvent("PLAYER_MAP_CHANGED");
            EL:UnregisterEvent("UPDATE_FACTION");
            print("NOT in Delve");
            return false
        end
    end
    EL:AddHandler("PLAYER_MAP_CHANGED", function()
        EL:ProcessOnNextCycle(UpdateDelveStatus);
    end);

    local function OnDelveEntered()
        if UpdateDelveStatus() then
            ProgressBar_Init();

            local level, earned, threshold = SeasonUtil:GetProgress();
            ProgressBar:SetLevel(level, threshold <= 0);
            ProgressBar:SetMaxValue(threshold);
            ProgressBar:SetValue(earned);
        end
    end
    EL:AddHandler("WALK_IN_DATA_UPDATE", function()
        EL:ProcessOnNextCycle(OnDelveEntered);
    end);

    local function OnScenarioCompleted()
        EL:RegisterEvent("UPDATE_FACTION");
    end
    EL:AddHandler("SCENARIO_COMPLETED", OnScenarioCompleted);

    local function OnFactionUpdated()
        EL:RegisterEvent("UPDATE_FACTION");
        local anyChange, level, earned, threshold, deltaEarned, levelUp, reachMaxLevel = SeasonUtil:SnapShotSeasonalProgress();
        if anyChange then
            print(string.format("Delve\'s Journey +%s", deltaEarned));

            ProgressBar:FadeIn();
            ProgressBar:SetValue(earned, levelUp);
            ProgressBar:AnimateDeltaValue(deltaEarned);
            ProgressBar:SetLevel(level, reachMaxLevel);
            ProgressBar:SetMaxValue(threshold);
            ProgressBar:StartFadeOutCountdown(0);
        end
    end
    EL:AddHandler("UPDATE_FACTION", function()
        EL:ProcessOnNextCycle(OnFactionUpdated);
    end);

    C_Timer.After(2, function()
        SeasonUtil:SetEnabled(true);
        SeasonUtil:SnapShotSeasonalProgress();
    end);
end