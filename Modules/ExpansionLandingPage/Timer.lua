local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;


local format = string.format;
local SecondsToTime = API.SecondsToTime;
local SecondsToClock = API.SecondsToClock;


do  --TimerFrame
    local TimerFrameMixin = {};

    function TimerFrameMixin:SetTimeGetter(getterFunc)
        self.getterFunc = getterFunc;
    end

    function TimerFrameMixin:SetCountdownMode(isCountdown)
        self.isCountdown = isCountdown;
    end

    function TimerFrameMixin:SetAutoStart(autoStart)
        self.autoStart = autoStart;
    end

    function TimerFrameMixin:SetShownThreshold(thresholdSeconds)
        --Show frame if seconds < threshold (countdown mode)
        self.thresholdSeconds = thresholdSeconds;
    end

    function TimerFrameMixin:SetLowThresholdAndColor(lowSeconds, lowSecondsHexColor)
        self.lowSeconds = lowSeconds;
        self.lowSecondsHexColor = lowSecondsHexColor;
    end

    function TimerFrameMixin:Sync()
        self.updateCounter = 0;
        self.t = 0;
        self.seconds = self.getterFunc() or 0;
        self:DisplayTime();
    end

    function TimerFrameMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 1 then
            self.updateCounter = self.updateCounter + 1;
            while self.t > 1 do
                self.t = self.t - 1;
                if self.isCountdown then
                    self.seconds = self.seconds - 1;
                else
                    self.seconds = self.seconds + 1;
                end
            end

            if self.seconds < 0 then
                self.seconds = 0;
            end

            if self.updateCounter > 10 then
                self:Sync();
            else
                self:DisplayTime();
            end
        end
    end

    function TimerFrameMixin:StartTimer()
        self:Sync();
        if self.thresholdSeconds then
            if (self.isCountdown and self.seconds > self.thresholdSeconds) or ((not self.isCountdown) and self.seconds < self.thresholdSeconds) then
                self:Hide();
                return
            end
        end
        self.Content:Show();
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function TimerFrameMixin:StopTimer(clearText)
        self:SetScript("OnUpdate", nil);
        self.t = nil;
        if clearText then
            self.Content:Hide();
        end
    end


    local DisplayTimeMethods = {};
    do
        function DisplayTimeMethods.SimpleText(self)
            --1 hours, 2 mins, 8 seconds
            self.Text:SetText(self:WrapTextInColor(SecondsToTime(self.seconds, true, true)));
        end

        function DisplayTimeMethods.SimpleClock(self)
            --1:02:08
            self.Text:SetText(self:WrapTextInColor(SecondsToClock(self.seconds)));
        end

        function DisplayTimeMethods.FormattedText(self)
            --Label: 1 hours, 2 mins, 8 seconds
            self.Text:SetText(format(self.timeTextFormat, self:WrapTextInColor(SecondsToTime(self.seconds, true, true))));
        end

        function DisplayTimeMethods.FormattedClock(self)
            --Label: 1:02:08
            self.Text:SetText(format(self.timeTextFormat, self:WrapTextInColor(SecondsToClock(self.seconds))));
        end
    end


    function TimerFrameMixin:SetDisplayStyle(style)
        local method = style and DisplayTimeMethods[style] or DisplayTimeMethods.SimpleClock;
        self.DisplayTime = method;
    end

    function TimerFrameMixin:SetTimeTextFormat(timeTextFormat)
        self.timeTextFormat = timeTextFormat;
    end

    function TimerFrameMixin:WrapTextInColor(text)
        if self.lowSeconds then
            if self.seconds < self.lowSeconds then
                text = format("|c%s%s|r", self.lowSecondsHexColor, text or "");
            end
        end
        return text
    end

    function TimerFrameMixin:DisplayTime()
        --Override
    end

    function TimerFrameMixin:OnShow()
        if self.autoStart then
            self:StartTimer();
        end
    end

    function TimerFrameMixin:OnHide()
        self:StopTimer();
    end

    function TimerFrameMixin:SetFontObject(fontObject)
        self.Text:SetFontObject(fontObject)
    end

    function TimerFrameMixin:SetTooltip(tooltipTitle, tooltipText)
        self.tooltipTitle = tooltipTitle;
        self.tooltipText = tooltipText;
        if tooltipTitle then
            self:SetScript("OnEnter", self.OnEnter);
            self:SetScript("OnLeave", self.OnLeave);
            self:EnableMouse(true);
            self:EnableMouseMotion(true);
        else
            self:EnableMouse(false);
            self:EnableMouseMotion(false);
        end
    end

    function TimerFrameMixin:OnEnter()
        if self.tooltipTitle then
            local tooltip = GameTooltip;
            tooltip:SetOwner(self, "ANCHOR_RIGHT");
            tooltip:SetText(self.tooltipTitle, 1, 1, 1, true);
            if self.tooltipText then
                tooltip:AddLine(self.tooltipText, 1, 0.82, 0, true);
            end
            tooltip:Show();
        end
    end

    function TimerFrameMixin:OnLeave()
        GameTooltip:Hide();
    end

    function LandingPageUtil.CreateTimerFrame(parent)
        local f = CreateFrame("Frame", nil, parent);
        f:SetSize(48, 24);
        API.Mixin(f, TimerFrameMixin);

        f.Content = CreateFrame("Frame", nil, f);
        f.Content:SetAllPoints(true);

        f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Text:SetJustifyH("LEFT");
        f.Text:SetTextColor(0.5, 0.5, 0.5);
        f.Text:SetPoint("LEFT", f, "LEFT", 0, 0);

        f:SetCountdownMode(true);

        f:SetScript("OnShow", f.OnShow);
        f:SetScript("OnHide", f.OnHide);

        return f
    end
end