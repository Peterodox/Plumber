local _, addon = ...
local API = addon.API;
--local L = addon.L;

local SecondsToClock = API.SecondsToClock;
local TimeLeftTextToSeconds = API.TimeLeftTextToSeconds;

local GetSuperTrackedMapPin = C_SuperTrack.GetSuperTrackedMapPin;
local GetBestMapForUnit = C_Map.GetBestMapForUnit;
local GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo;
local GetTextWithStateWidgetVisualizationInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo;

--C_AreaPoiInfo.IsAreaPOITimed


local EL = CreateFrame("Frame");

function EL:OnEvent(event, ...)
    if event == "SUPER_TRACKING_CHANGED" then
        self:OnSuperTrackingChanged();
    end
end

local function GetTimeLeftFromWidget(widgetID)
    local info = GetTextWithStateWidgetVisualizationInfo(widgetID);
    --print(widgetInfo.widgetType, info.text, info.hasTimer, info.shownState, info.enabledState)
    if info and info.shownState == 1 and info.enabledState ~= 0 then  --info.hasTimer can be false
        local seconds = TimeLeftTextToSeconds(info.text);
        if seconds > 0 then
            --print(widgetID, info.text, info.hasTimer, SecondsToClock(seconds));
            return seconds
        end
    end
end

function EL:OnSuperTrackingChanged()
    local timeLeft, timerWidgetID;
    local type, id = GetSuperTrackedMapPin();
    --if type then print(type, id) end;   --debug
    if type and type == 0 and id then  --Enum.SuperTrackingMapPinType.AreaPOI
        local uiMapID = GetBestMapForUnit("player");
        local info = GetAreaPOIInfo(uiMapID, id);
        if info then
            --print(info.name);
            if info.tooltipWidgetSet and info.tooltipWidgetSet ~= 0 then
                local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(info.tooltipWidgetSet);
                local seconds;
                for _, widgetInfo in ipairs(widgets) do
                    if widgetInfo.widgetType == 8 then  --TextWithState
                        seconds = GetTimeLeftFromWidget(widgetInfo.widgetID);
                        if seconds then
                            timeLeft = seconds;
                            timerWidgetID = widgetInfo.widgetID;
                            break
                        end
                    end
                end
            end
        end
    end

    if timeLeft then
       self:ShowTimer(timerWidgetID, timeLeft);
    else
        self:HideTimer();
    end
end

function EL:HideTimer()
    if self.hasTimer then
        self.hasTimer = nil;
        self.TimerFrame:StopCountdown();
        self.TimerFrame:Hide();
        self.TimerFrame:ClearAllPoints();
    end
end

local function TimerFrame_OnUpdate(self, elapsed)
    --Count down internally, sync every other x seconds
    self.interval = self.interval + elapsed;
    if self.interval >= 1 then
        self.seconds = self.seconds - self.interval;

        if self.owner.isClamped then
            if not self.isClamped then
                self.isClamped = true;
                self:FadeToAlpha(0.6);
            end
        else
            if self.isClamped then
                self.isClamped = false;
                self:FadeToAlpha(1);
            end
        end

        if self.seconds >= 0 then
            while self.interval >= 1 do
                self.interval = self.interval - 1;
            end
            self:DisplaySeconds(self.seconds);
        else
            self.interval = 0;
            self.syncTime = 128;
        end
    end

    self.syncTime = self.syncTime + elapsed;
    if self.syncTime > 5 then
        self.syncTime = 0;
        local timeLeft = GetTimeLeftFromWidget(self.timerWidgetID);
        if timeLeft and timeLeft > 0 then
            local diff = timeLeft - self.seconds;
            if diff > 2 or diff < -2 then
                self.seconds = timeLeft;
                self:DisplaySeconds(self.seconds);
            end
        else
            EL:HideTimer()
        end
    end

    if self.changeAlpha then
        self.alpha = self.alpha + elapsed * self.alphaBlend;
        if (self.alphaBlend > 0 and self.alpha > self.toAlpha) or (self.alphaBlend < 0 and self.alpha < self.toAlpha) then
            self.changeAlpha = nil;
            self.alpha = self.toAlpha;
        end
        self:SetAlpha(self.alpha);
    end
end

function EL:InitTimerFrame()
    if self.TimerFrame then return end;

    local f = CreateFrame("Frame", nil, SuperTrackedFrame);
    f.owner = SuperTrackedFrame;
    self.TimerFrame = f;
    f:SetSize(12, 12);
    --f:SetPoint("TOP", SuperTrackedFrame, "BOTTOM", 0, 0);
    f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    f.Text:SetPoint("TOP", f, "TOP", 0, 0);
    f.Text:SetJustifyH("CENTER");
    f.Text:SetJustifyV("TOP");

    function f:SetWidgetTimer(timerWidgetID, seconds)
        f.seconds = seconds;
        f.timerWidgetID = timerWidgetID;
        f.interval = 0;
        f.syncTime = 0;
        f:DisplaySeconds(seconds);
        f:SetScript("OnUpdate", TimerFrame_OnUpdate);
    end

    function f:DisplaySeconds(seconds)
        if seconds and seconds < 900 then   --Hide text when remaining time > 15min
            f.Text:SetText(SecondsToClock(seconds));
        else
            f.Text:SetText(nil);
        end
    end

    function f:StopCountdown()
        f:SetScript("OnUpdate", nil);
        f.seconds = 0;
        f.syncTime = 0;
    end

    f.alpha = 1;
    function f:FadeToAlpha(alpha)
        if self.alpha ~= alpha then
            self.changeAlpha = true;
            if alpha > self.alpha then
                self.alphaBlend = 2;
            else
                self.alphaBlend = -2;
            end
        else
            self.changeAlpha = nil;
        end
        self.toAlpha = alpha;
    end
end

function EL:ShowTimer(timerWidgetID, timeLeft)
    if not timeLeft then
        timeLeft = GetTimeLeftFromWidget(timerWidgetID);
    end

    if timeLeft then
        self:InitTimerFrame();
        self.hasTimer = true;
        self.TimerFrame:SetPoint("TOP", SuperTrackedFrame.DistanceText, "BOTTOM", 0, -2);
        self.TimerFrame:SetWidgetTimer(timerWidgetID, timeLeft);
        self.TimerFrame:Show();
    else
        self:HideTimer();
    end
end

function EL:EnableModule(state)
    if state then
        self.enabled = true;
        self:RegisterEvent("SUPER_TRACKING_CHANGED");
        self:SetScript("OnEvent", self.OnEvent);
        self:OnSuperTrackingChanged();
    elseif self.enabled then
        self.enabled = nil;
        self:UnregisterEvent("SUPER_TRACKING_CHANGED");
        self:SetScript("OnEvent", nil);
        self:HideTimer();
    end
end


do
    local function EnableModule(state)
        EL:EnableModule(state);
    end

    local moduleData = {
        name = addon.L["ModuleName BlizzardSuperTrack"],
        dbKey = "BlizzardSuperTrack",
        description = addon.L["ModuleDescription BlizzardSuperTrack"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1168,
        moduleAddedTime = 1737460000,
    };

    addon.ControlCenter:AddModule(moduleData);
end