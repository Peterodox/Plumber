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
local GetStepInfo = C_Scenario.GetStepInfo;

local UIParent = UIParent;

local DELVES_SEASON_FACTION;    --2644

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

function EL:ProcessOnNextCycle(func, delay)
    if not self.queuedFuncs then
        self.queuedFuncs = {};
    end

    delay = delay or 0.5;
    self.t = -delay;
    self:SetScript("OnUpdate", self.OnUpdate);

    for _, queuedFunc in ipairs(self.queuedFuncs) do
        if queuedFunc == func then
            return
        end
    end

    table.insert(self.queuedFuncs, func);
end

local function Dev_GetDelveMapInfo()
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

local function GetEnemyGroupCount()
    local widgetSetID = select(12, GetStepInfo());
    if not widgetSetID then return end;

    local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID);
    if not widgets then return end;

    local TYPE_ID = Enum.UIWidgetVisualizationType.ScenarioHeaderDelves or 29;
    local widgetID;

    for _, widgetInfo in ipairs(widgets) do
        if widgetInfo.widgetType == TYPE_ID then
            widgetID = widgetInfo.widgetID;
        end
    end

    if not widgetID then return end;

    local SPELL_ID = 456037;    --Zekvir's Influence
    local isSpellFound;

    local widgetInfo = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(widgetID);

    if widgetInfo and widgetInfo.shownState == 1 and widgetInfo.spells then
		for _, spellInfo in ipairs(widgetInfo.spells) do
            if spellInfo.spellID == SPELL_ID then
                if spellInfo.shownState == 1 then
                    isSpellFound = true;
                end
                break
            end
        end
	end

    if isSpellFound then
        local isPet = false;
        local showSubtext = true;
        local tooltipData = C_TooltipInfo.GetSpellByID(SPELL_ID, isPet, showSubtext);

        if tooltipData and tooltipData.lines then
            local numLines = #tooltipData.lines;
            local lineText = tooltipData.lines[numLines].leftText;
            print(lineText);    --Zekvir, the Hand of the Harbinger...Enemy groups remaining: 3/3
            local current, total = string.match(lineText, "(%d+)%s*/%s*(%d+)");
            print(current, total)
        end
    end
end


local BonusObjectiveTrackerMixin = {};
do  --Show Enemy Group Count bellow affix spell on the ScenarioHeaderDelves
    local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;

    local CURRENCY_AFFIX_ACTIVE = 3103;
    local CURRENCY_AFFIX_MAXIMUM = 3104;

    function BonusObjectiveTrackerMixin:OnEvent(event, ...)
        --Fire CURRENCY_DISPLAY_UPDATE 1/2 times After killing one group, 3103 changed to 0 then the actual number
        if event == "CURRENCY_DISPLAY_UPDATE" then
            local currencyID = ...
            if currencyID and (currencyID == CURRENCY_AFFIX_ACTIVE or currencyID == CURRENCY_AFFIX_MAXIMUM) then
                self:RequestUpdate(true);
            end
        end
    end

    function BonusObjectiveTrackerMixin:Remove()
        if self.isActive then
            self.isActive = false;
            self:Hide();
            self:ClearAllPoints();
            self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
            self:SetScript("OnUpdate", nil);
            self:SetParent(UIParent);
            self:SetPoint("TOP", UIParent, "BOTTOM", 0, -8);
        end
    end

    function BonusObjectiveTrackerMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t >= 1.0 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            self:Update();
        end
    end

    function BonusObjectiveTrackerMixin:RequestUpdate(newDelve)
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
        self:Show();

        if newDelve then
            self.newDelve = true;
        end
    end

    function BonusObjectiveTrackerMixin:Reposition()
        local widgetSetID = select(12, GetStepInfo());
        if (not widgetSetID) or widgetSetID == 0 then return end;

        local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID);
        if not widgets then return end;

        local TYPE_ID =  29;    --Enum.UIWidgetVisualizationType.ScenarioHeaderDelves
        local widgetID;

        for _, widgetInfo in ipairs(widgets) do
            if widgetInfo.widgetType == TYPE_ID then
                widgetID = widgetInfo.widgetID;
            end
        end

        if not widgetID then return end;

        local SPELL_ID = 456037;    --Zekvir's Influence
        local spellIndex;

        local widgetInfo = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(widgetID);

        if widgetInfo and widgetInfo.shownState == 1 and widgetInfo.spells then
            for i, spellInfo in ipairs(widgetInfo.spells) do
                if spellInfo.spellID == SPELL_ID then
                    if spellInfo.shownState == 1 then
                        spellIndex = i;
                    end
                    break
                end
            end
        end

        self:ClearAllPoints();
        self:SetParent(UIParent);
        self:SetPoint("TOP", UIParent, "BOTTOM", 0, -8);

        local parentObject;

        if spellIndex then
            for widgetContainer in pairs(UIWidgetManager.registeredWidgetContainers) do
                if widgetContainer.widgetSetID == widgetSetID then
                    if widgetContainer and widgetContainer.widgetFrames and widgetContainer.widgetFrames[widgetID] then
                        local p = widgetContainer.widgetFrames[widgetID];
                        if p.SpellContainer and p.SpellContainer.GetLayoutChildren then
                            local frames = p.SpellContainer:GetLayoutChildren();
                            parentObject = frames[spellIndex];
                        end
                    end
                    break
                end
            end
        end

        if parentObject then
            self:SetParent(parentObject);
            self:SetPoint("TOP", parentObject, "BOTTOM", 0, 0);
        end
    end

    function BonusObjectiveTrackerMixin:Update()
        local info;
        local current, max;

        info = GetCurrencyInfo(CURRENCY_AFFIX_ACTIVE);
        if info then
            current = info.quantity;
        end

        info = GetCurrencyInfo(CURRENCY_AFFIX_MAXIMUM);
        if info then
            max = info.quantity;
        end

        if current and max and max > 0 then
            if current <= 0 then
                self.Text:SetText("|TInterface\\AddOns\\Plumber\\Art\\Button\\Checkmark-Green:16|t");
            else
                self.Text:SetText(current);
            end
            self.isActive = true;
            self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");

            if self.newDelve then
                self.newDelve = nil;
                self:Reposition();
            end
        else
            self:Remove();
        end
    end
end

local SeasonTracker = {};
do  --Seasonal Journey Progress
    --Currently can't track it on the ReputationBar by C_Reputation.SetWatchedFactionByID (C_Reputation.IsMajorFaction returns true but no C_MajorFactions.GetMajorFactionData)

    local FADEOUT_DELAY = 4;
    local MAPID_DORNOGAL = 2339;    --Only listen UPDATE_FACTION in Delves and Dornogal (Weekly Quest Turn-in)

    local ProgressBar;
    local BonusObjectiveTracker;
    local ZoneTriggerModule;


    local function ProgressBar_Init()
        if ProgressBar then return end;

        ProgressBar = addon.CreateLevelProgressBar(UIParent);
        ProgressBar:SetPoint("CENTER", UIParent, "TOP", 0, -128);
        ProgressBar:SetLabel(L["Delves Reputation Name"]);
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
            ProgressBar:StartFadeOutCountdown(2);
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
            local level, earned, threshold = SeasonTracker:GetProgress();
            self:SetLevel(level);
            self:SetMaxValue(threshold);
            self:SetValue(earned);
        end

        local level, earned, threshold = SeasonTracker:GetProgress();
        ProgressBar:SetLevel(level, threshold <= 0);
        ProgressBar:SetMaxValue(threshold);
        ProgressBar:SetValue(earned);

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

    local function BonusObjectiveTracker_Init()
        if BonusObjectiveTracker then return end;

        local f = CreateFrame("Frame");
        BonusObjectiveTracker = f;
        f:SetSize(30, 24);

        local Text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        f.Text = Text;
        Text:SetJustifyH("CENTER");
        Text:SetPoint("CENTER", f, "CENTER", 0, 0);

        local Bg = f:CreateTexture(nil, "BORDER");
        Bg:SetAllPoints(true);
        Bg:SetTexture("Interface/AddOns/Plumber/Art/Delves/Delves-Scenario");
        Bg:SetTexCoord(0, 60/256, 0, 48/256);

        API.Mixin(f, BonusObjectiveTrackerMixin);
        f:SetScript("OnEvent", f.OnEvent);
    end

    local function BonusObjectiveTracker_Hide()
        if BonusObjectiveTracker then
            BonusObjectiveTracker:Remove();
        end
    end

    function SeasonTracker:GetProgress()
        if not DELVES_SEASON_FACTION then
            DELVES_SEASON_FACTION = C_DelvesUI and C_DelvesUI.GetDelvesFactionForSeason and C_DelvesUI.GetDelvesFactionForSeason() or 0;
        end

        local renownInfo = GetMajorFactionRenownInfo(DELVES_SEASON_FACTION);
        if not renownInfo then return 0, 0, 1 end;

        local level = renownInfo.renownLevel or 1;
        local earned = renownInfo.renownReputationEarned or 0;
        local threshold = renownInfo.renownLevelThreshold or 1;

        return level, earned, threshold
    end

    function SeasonTracker:SnapShotSeasonalProgress()
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

    local function UpdateInDelveStatus()
        --Seasonal Progress changes after looting a chest in the end
        --To reduce usage, we start listening UPDATE_FACTION after the scenario is completed (the event fires after killing the final boss) (Companion level is also a faction)
        --If player resets UI after scenario completion, we won't show the progress bar
        --C_DelvesUI.HasActiveDelve doesn't change immediately after PLAYER_MAP_CHANGED
        if IsInDelves() then
            EL:RegisterEvent("SCENARIO_COMPLETED");
            EL:RegisterEvent("PLAYER_MAP_CHANGED");
            BonusObjectiveTracker_Init();
            BonusObjectiveTracker:RequestUpdate(true);
            --print("IN Delve");
            return true
        else
            EL:UnregisterEvent("SCENARIO_COMPLETED");
            EL:UnregisterEvent("PLAYER_MAP_CHANGED");
            EL:UnregisterEvent("UPDATE_FACTION");
            BonusObjectiveTracker_Hide();
            --print("NOT in Delve");
            return false
        end
    end
    EL:AddHandler("PLAYER_MAP_CHANGED", function()
        EL:ProcessOnNextCycle(UpdateInDelveStatus);
    end);

    local function OnDelveEntered()
        if UpdateInDelveStatus() then
            ProgressBar_Init();
        end
    end
    EL:AddHandler("WALK_IN_DATA_UPDATE", function()
        EL:ProcessOnNextCycle(OnDelveEntered, 3);
    end);

    local function OnScenarioCompleted()
        EL:RegisterEvent("UPDATE_FACTION");
    end
    EL:AddHandler("SCENARIO_COMPLETED", OnScenarioCompleted);

    local function OnFactionUpdated()
        EL:RegisterEvent("UPDATE_FACTION");
        local anyChange, level, earned, threshold, deltaEarned, levelUp, reachMaxLevel = SeasonTracker:SnapShotSeasonalProgress();
        if anyChange then
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


    local function ZoneTriggerModule_Enable(state)
        if state then
            if not ZoneTriggerModule then
                local module = API.CreateZoneTriggeredModule("dornogal");
                ZoneTriggerModule = module;
                module:SetValidZones(MAPID_DORNOGAL);

                local function OnEnterZoneCallback()
                    SeasonTracker:SnapShotSeasonalProgress();
                    ProgressBar_Init();
                    EL:RegisterEvent("UPDATE_FACTION");
                end

                local function OnLeaveZoneCallback()
                    UpdateInDelveStatus();
                end

                module:SetEnterZoneCallback(OnEnterZoneCallback);
                module:SetLeaveZoneCallback(OnLeaveZoneCallback);
            end
            ZoneTriggerModule:SetEnabled(true);
            ZoneTriggerModule:Update();
        else
            if ZoneTriggerModule then
                ZoneTriggerModule:SetEnabled(false);
            end
        end
    end

    function SeasonTracker:SetEnabled(state)
        if state then
            EL:RegisterEvent("WALK_IN_DATA_UPDATE");   --Always registered
            self:SnapShotSeasonalProgress();
            OnDelveEntered();
        else
            EL:UnregisterEvent("WALK_IN_DATA_UPDATE");
            EL:UnregisterEvent("PLAYER_MAP_CHANGED");
            EL:UnregisterEvent("SCENARIO_COMPLETED");
            EL:UnregisterEvent("UPDATE_FACTION");
        end
        ZoneTriggerModule_Enable(state);
    end
end




do
    local function EnableModule(state)
        SeasonTracker:SetEnabled(state);
    end

    local moduleData = {
        name = addon.L["ModuleName Delves_SeasonProgress"],
        dbKey = "Delves_SeasonProgress",
        description = addon.L["ModuleDescription Delves_SeasonProgress"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1105,
        moduleAddedTime = 1724100000,
    };

    addon.ControlCenter:AddModule(moduleData);
end