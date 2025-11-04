local _, addon = ...
local L = addon.L;
local API = addon.API;


local SecondsToClock = API.SecondsToClock;


local SHOW_TIME = false;


local BlizzardWidget = QueueStatusButton;
local ProgressDisplay;
local DemoFrame;


local CreateProgressDisplay;
do  --ProgressDisplayMixin
    local GetTime = GetTime;

    local TEXUTRE_FILE = "Interface/AddOns/Plumber/Art/Frame/QueueStatusEye.png";

    local ProgressDisplayMixin = {};

    function ProgressDisplayMixin:Attach()
        if self.attached then return end;
        self.attached = true;
        self:SetParent(BlizzardWidget);
        self:ClearAllPoints();
        self:SetPoint("CENTER", BlizzardWidget, "CENTER", 0, 1);
        self:SetFrameLevel(BlizzardWidget:GetFrameLevel() + 5);
    end

    function ProgressDisplayMixin:Detach()
        self.attached = nil;
        self:SetParent(nil);
        self:ClearAllPoints();
        self:Hide();
        self.t = 0;
        self:SetScript("OnUpdate", nil);
    end

    function ProgressDisplayMixin:UpdateQueueTime()
        if self.queueStartTime and self.myWait then
            local diff = (GetTime() - self.queueStartTime)  - self.myWait;
            if diff < 0 then
                diff = -diff;
                self.TimeText:SetTextColor(1, 1, 1, 0.6);
            else
                self.TimeText:SetTextColor(1.000, 0.125, 0.125, 1);
            end
            self.TimeText:SetText(SecondsToClock(diff));
        end
    end

    function ProgressDisplayMixin:FindBestPositionForLabel()
        local bottom = self:GetBottom();
        self.TimeText:ClearAllPoints();
        if bottom - 14 >= 0 then
            self.TimeText:SetPoint("TOP", self, "BOTTOM", 0, 0);
        else
            self.TimeText:SetPoint("BOTTOM", self, "TOP", 0, 0);
        end
    end

    function ProgressDisplayMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.5 then
            self.t = self.t - 0.5;
            self:UpdateQueueTime();
        end
    end

    function ProgressDisplayMixin:SetQueueTime(myWait, queueStartTime)
        self.myWait = myWait;
        self.queueStartTime = queueStartTime;

        if SHOW_TIME then
            self.TimeText:Show();
            self:SetScript("OnUpdate", self.OnUpdate);
            self.t = 0;
            self:UpdateQueueTime();
        else
            self.TimeText:Hide();
            self:SetScript("OnUpdate", nil);
        end
    end

    function CreateProgressDisplay()
        local f = addon.CreateRadialProgressBar(UIParent);
        ProgressDisplay = f;
        Mixin(f, ProgressDisplayMixin);

        f:Hide();
        f:SetSize(48, 48);
        f:SetFrameStrata("HIGH");
        f:ShowNumber(false);
        f:SetSwipeTexture(TEXUTRE_FILE);
        f:SetSwipeTexCoord(96/256, 192/256, 0/256, 96/256);
        f.Border:SetTexture(TEXUTRE_FILE);
        f.Border:SetTexCoord(0/256, 96/256, 0/256, 96/256);
        f.Background:SetTexture(TEXUTRE_FILE);
        f.Background:SetTexCoord(0/256, 96/256, 96/256, 192/256);
        f:SetEdgeScale(1);

        f.TimeText = f:CreateFontString(nil, "OVERLAY", "WhiteNormalNumberFont", 4);
        f.TimeText:SetJustifyH("CENTER");
        f.TimeText:SetJustifyV("TOP");
        f.TimeText:SetPoint("BOTTOM", f, "BOTTOM", 0, 0);
    end
end

local EL = CreateFrame("Frame");
do
    local GetLFGQueueStats = GetLFGQueueStats;

    local LFGCategories = {
        1,  --Dungeon
        3,  --LFR
    };

    function EL:LoadSettings()
        SHOW_TIME = addon.GetDBBool("QueueStatus_ShowTime");

        if DemoFrame then
            DemoFrame:Update();
        end

        self:RequestUpdate();
    end

    function EL:Enable()
        self:RegisterEvent("LFG_UPDATE");
        self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE");
        self:SetScript("OnEvent", self.OnEvent);
        self:LoadSettings();
        self:RequestUpdate();
    end

    function EL:Disable()
        self:HideWidget();
        self:UnregisterEvent("LFG_UPDATE");
        self:UnregisterEvent("LFG_QUEUE_STATUS_UPDATE");
        self:SetScript("OnEvent", nil);
        self:SetScript("OnUpdate", nil);
        self.t = 0;
    end

    function EL:OnEvent(event)
        self:RequestUpdate();
    end

    function EL:RequestUpdate()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function EL:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.2 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            self:FullUpdate();
        end
    end

    function EL:HideWidget()
        if ProgressDisplay then
            ProgressDisplay:Detach();
        end
    end

    function EL:FullUpdate()
        for _, category in ipairs(LFGCategories) do
            local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime, activeID = GetLFGQueueStats(category);
            if activeID then
                --print(tankNeeds, healerNeeds, dpsNeeds);
                --print(totalTanks, totalHealers, totalDPS);
                --print(averageWait, myWait, queuedTime);
                if averageWait > 0 then
                    local percentage;
                    local total = totalTanks + totalHealers + totalDPS;
                    if total <= 1 then
                        percentage = 1;
                    else
                        if totalTanks > 0 and totalHealers > 0 and totalDPS > 0 then
                            --When every role is needed, assign different weight
                            local part = 1 / 3;
                            local tankWeight = part / totalTanks;
                            local healerWeight = part / totalHealers;
                            local dpsWeight = part / totalDPS;
                            percentage = (totalTanks - tankNeeds) * tankWeight + (totalHealers - healerNeeds) * healerWeight + (totalDPS - dpsNeeds) * dpsWeight;
                        else
                            --Treat all roles equally
                            percentage = 1 - (tankNeeds + healerNeeds + dpsNeeds) / total;
                        end
                    end

                    if not ProgressDisplay then
                        CreateProgressDisplay();
                    end

                    if percentage < 0.02 then
                        percentage = 0;
                    end

                    ProgressDisplay:Attach();
                    ProgressDisplay:SetPercentage(percentage);
                    ProgressDisplay:FindBestPositionForLabel();
                    ProgressDisplay:SetQueueTime(myWait, queuedTime);
                    ProgressDisplay:Show();

                    return
                end
            end
        end

        self:HideWidget();
    end
end


local AcquireDemoFrame;
do
    local DemoFrameMixin = {};

    function DemoFrameMixin:OnShow()
        self.t = 2;
        self.total = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function DemoFrameMixin:OnHide()
        self.t = 0;
        self.total = 0;
        self:SetScript("OnUpdate", nil);
    end

    function DemoFrameMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t >= 1 then
            self.t = 0;
            self.total = self.total + 1;
            if self.total > self.cycle then
                self.total = 0;
            end
            local diff = self.total - 0.5 * self.cycle;
            if diff < 0 then
                diff = -diff;
                self.TimeText:SetTextColor(1, 1, 1, 0.6);
            else
                self.TimeText:SetTextColor(1.000, 0.125, 0.125, 1);
            end
            self.TimeText:SetText(SecondsToClock(diff));
        end
    end

    function DemoFrameMixin:Update()
        self.t = 2;
        self.total = 0;
        self.TimeText:SetShown(SHOW_TIME);
    end

    function AcquireDemoFrame()
        if not DemoFrame then
            DemoFrame = CreateFrame("Frame");
            API.Mixin(DemoFrame, DemoFrameMixin);
            DemoFrame:SetSize(64, 76);
            DemoFrame.cycle = 10;

            DemoFrame.Background = DemoFrame:CreateTexture(nil, "ARTWORK");
            DemoFrame.Background:SetPoint("BOTTOM", DemoFrame, "BOTTOM", 0, 0);
            DemoFrame.Background:SetSize(64, 64);
            DemoFrame.Background:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/Demo_QueueStatus.png");

            DemoFrame.TimeText = DemoFrame:CreateFontString(nil, "OVERLAY", "WhiteNormalNumberFont", 4);
            DemoFrame.TimeText:SetJustifyH("CENTER");
            DemoFrame.TimeText:SetJustifyV("TOP");
            DemoFrame.TimeText:SetPoint("BOTTOM", DemoFrame.Background, "CENTER", 0, 24);

            DemoFrame:SetScript("OnShow", DemoFrame.OnShow);
            DemoFrame:SetScript("OnHide", DemoFrame.OnHide);
            DemoFrame:OnShow();
            DemoFrame:Update();
        end

        return DemoFrame
    end
end


local OptionToggle_OnClick;
do  --Options
    local function Checkbox_OnClick()
        EL:LoadSettings();
    end

    local OPTIONS_SCHEMATIC = {
        title = L["ModuleName QueueStatus"],
        widgets = {
            {type = "Checkbox", label = L["QueueStatus Show Time"], onClickFunc = Checkbox_OnClick, dbKey = "QueueStatus_ShowTime", tooltip = L["QueueStatus Show Time Tooltip"]},

            {type = "Divider"},
            {type = "Custom", onAcquire = AcquireDemoFrame, align = "center"},
        },
    };

    function OptionToggle_OnClick(self, button)
        OptionFrame = addon.ToggleSettingsDialog(self, OPTIONS_SCHEMATIC);
        if OptionFrame then
            OptionFrame:ConvertAnchor();
        end
    end
end


do
    local function EnableModule(state)
        if state then
            EL:Enable();
        else
            EL:Disable();
        end
    end

    local moduleData = {
        name = addon.L["ModuleName QueueStatus"],
        dbKey = "QueueStatus",
        description = addon.L["ModuleDescription QueueStatus"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 10,
        moduleAddedTime = 1762300000,
        optionToggleFunc = OptionToggle_OnClick,
    };

    addon.ControlCenter:AddModule(moduleData);
end