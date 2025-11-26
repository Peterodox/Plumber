local _, addon = ...
local L = addon.L;
local API = addon.API;


local GetTime = GetTime;
local SecondsToClock = API.SecondsToClock;


local SHOW_TIME = false;


local BlizzardWidget = QueueStatusButton;
local ProgressDisplay;
local DemoFrame;


local function GetValidTextPositionIndex()
    --0:Center, 1-4:Clockwise
    local index = addon.GetDBValue("QueueStatus_TextPosition");
    if type(index) ~= "number" then
        index = 1;
    end
    index = API.Clamp(index, 0, 4);
    return index
end

local function SetTextPositionByIndex(fontString, relativeTo, index)
    local isCenter;
    local offset = 0;
    if not index then
        index = GetValidTextPositionIndex();
    end
    fontString:ClearAllPoints();
    if index == 0 then
        isCenter = true;
        fontString:SetPoint("CENTER", relativeTo, "CENTER", 0, 0);
    else
        isCenter = false;
        if index == 2 then
            fontString:SetPoint("LEFT", relativeTo, "RIGHT", offset, 0);
        elseif index == 3 then
            fontString:SetPoint("TOP", relativeTo, "BOTTOM", 0, -offset);
        elseif index == 4 then
            fontString:SetPoint("RIGHT", relativeTo, "LEFT", -offset, 0);
        else
            fontString:SetPoint("BOTTOM", relativeTo, "TOP", 0, offset);
        end
    end
    return isCenter
end


local CreateProgressDisplay;
do  --ProgressDisplayMixin
    local TEXUTRE_FILE = "Interface/AddOns/Plumber/Art/Frame/QueueStatusEye.png";

    local ProgressDisplayMixin = {};

    function ProgressDisplayMixin:Attach()
        if self.attached then return end;
        self.attached = true;
        self:SetParent(BlizzardWidget);
        self:ClearAllPoints();
        self:SetPoint("CENTER", BlizzardWidget, "CENTER", 0, 1);
        self:SetFrameLevel(BlizzardWidget:GetFrameLevel() + 5);
        self.AnimSpin:Play();
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
        if self.queueStartTime then
            local diff;
            if self.myWait then
                diff = GetTime() - self.queueStartTime - self.myWait;
                if diff < 0 then
                    diff = -diff;
                    self.TimeText:SetTextColor(1, 1, 1, 0.6);
                else
                    self.TimeText:SetTextColor(1.000, 0.125, 0.125, 1);
                end
            else
                diff = GetTime() - self.queueStartTime;
                self.TimeText:SetTextColor(1, 1, 1, 0.6);
            end
            self.TimeText:SetText(SecondsToClock(diff));
        end
    end

    function ProgressDisplayMixin:UpdateLabelPosition()
        --[[
        local bottom = self:GetBottom();
        self.TimeText:ClearAllPoints();
        if bottom - 14 >= 0 then
            self.TimeText:SetPoint("TOP", self, "BOTTOM", 0, 0);
        else
            self.TimeText:SetPoint("BOTTOM", self, "TOP", 0, 0);
        end
        --]]

        local positionIndex = GetValidTextPositionIndex();
        self.BlackOverlay:SetShown(positionIndex == 0);
        self.Spinner:SetShown(positionIndex == 0);
        SetTextPositionByIndex(self.TimeText, self, positionIndex);
    end

    function ProgressDisplayMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.5 then
            self.t = self.t - 0.5;
            self:UpdateQueueTime();
        end
    end

    function ProgressDisplayMixin:SetQueueTime(myWait, queueStartTime)
        if myWait and myWait <= 0 then
            myWait = nil;
        end

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

        f.Spinner:SetTexture(TEXUTRE_FILE);
        f.Spinner:SetTexCoord(96/256, 192/256, 96/256, 192/256);
        f.Spinner:Hide();
        f.Spinner:SetAlpha(0.5);

        f.BlackOverlay = f:CreateTexture(nil, "BACKGROUND", nil, -1);
        f.BlackOverlay:SetSize(36, 36);
        f.BlackOverlay:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.BlackOverlay:SetTexture(TEXUTRE_FILE);
        f.BlackOverlay:SetTexCoord(224/256, 1, 0, 32/256);
        f.BlackOverlay:Hide();
    end
end

local EL = CreateFrame("Frame");
do
    local GetLFGQueueStats = GetLFGQueueStats;
    local GetMaxBattlefieldID = GetMaxBattlefieldID;
    local GetBattlefieldStatus = GetBattlefieldStatus;
    local GetPVPTimeInQueue = GetBattlefieldTimeWaited;
    local GetPVPWaitTime = GetBattlefieldEstimatedWaitTime;

    local LFGCategories = {
        1,  --Dungeon
        3,  --LFR
    };

    function EL:LoadSettings()
        SHOW_TIME = addon.GetDBBool("QueueStatus_ShowTime");

        if SHOW_TIME and self.enabled then
            self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
            self:RegisterEvent("PVP_BRAWL_INFO_UPDATED");
        else
            self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS");
            self:UnregisterEvent("PVP_BRAWL_INFO_UPDATED");
        end

        if DemoFrame then
            DemoFrame:Update();
        end

        self:RequestUpdate();
    end

    function EL:Enable()
        if self.enabled then return end;
        self.enabled = true;
        self:RegisterEvent("LFG_UPDATE");
        self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE");
        self:SetScript("OnEvent", self.OnEvent);
        self:LoadSettings();
        self:RequestUpdate();
    end

    function EL:Disable()
        if not self.enabled then return end;
        self.enabled = nil;
        self:HideWidget();
        self:UnregisterEvent("LFG_UPDATE");
        self:UnregisterEvent("LFG_QUEUE_STATUS_UPDATE");
        self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS");
        self:UnregisterEvent("PVP_BRAWL_INFO_UPDATED");
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
        local hasValidQueue, waitTime, queueStartTime, percentage;

        for _, category in ipairs(LFGCategories) do
            local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime, activeID = GetLFGQueueStats(category);
            if activeID then
                --print(tankNeeds, healerNeeds, dpsNeeds);
                --print(totalTanks, totalHealers, totalDPS);
                --print(averageWait, myWait, queuedTime);
                if averageWait > 0 then
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

                    if percentage < 0.02 then
                        percentage = 0;
                    end

                    hasValidQueue = true;
                    waitTime = myWait;
                    queueStartTime = queuedTime;

                    break
                end
            end
        end

        if (not hasValidQueue) and SHOW_TIME then
            --Check PVP queue
            for i = 1, GetMaxBattlefieldID() do
                local status = GetBattlefieldStatus(i);
                if status == "queued" then
                    hasValidQueue = true;
                    percentage = 0;
                    local timeInQueue = GetPVPTimeInQueue(i);
                    queueStartTime = GetTime() - timeInQueue / 1000;
                    waitTime = GetPVPWaitTime(i);
                    break
                end
            end
        end

        if hasValidQueue then
            if not ProgressDisplay then
                CreateProgressDisplay();
            end
            ProgressDisplay:Attach();
            ProgressDisplay:SetPercentage(percentage);
            ProgressDisplay:UpdateLabelPosition();
            ProgressDisplay:SetQueueTime(waitTime, queueStartTime);
            ProgressDisplay:Show();
        else
            self:HideWidget();
        end
    end
end


local AcquireDemoFrame;
do
    local DemoFrameMixin = {};

    function DemoFrameMixin:OnShow()
        DemoFrame:Update();
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function DemoFrameMixin:OnHide()
        self.t = 0;
        self.total = 0;
        self:SetScript("OnUpdate", nil);
    end

    function DemoFrameMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        self.t2 = self.t2 + elapsed;

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

        if self.t2 > 0.2 then
            self.t2 = 0;
            if self:IsMouseOver() then
                if not self.focused then
                    self.focused = true;
                    self.shouldFade = true;
                end
            else
                if self.focused or self.focused == nil then
                    self.focused = false;
                    self.shouldFade = true;
                end
            end
        end

        if self.shouldFade then
            if self.focused then
                self.nodeAlpha = self.nodeAlpha + 5 * elapsed;
                if self.nodeAlpha >= 1 then
                    self.nodeAlpha = 1;
                    self.shouldFade = nil;
                end
            else
                self.nodeAlpha = self.nodeAlpha - 5 * elapsed;
                if self.nodeAlpha <= self.unfocusedAlpha then
                    self.nodeAlpha = self.unfocusedAlpha;
                    self.shouldFade = nil;
                end
            end

            self.NodeContainer:SetAlpha(self.nodeAlpha);
        end
    end

    function DemoFrameMixin:UpdateNodes()
        local positionIndex = GetValidTextPositionIndex();
        if positionIndex == 0 and SHOW_TIME then
            DemoFrame.Background:SetTexCoord(0.5, 1, 0, 1);
        else
            DemoFrame.Background:SetTexCoord(0, 0.5, 0, 1);
        end

        for i, node in ipairs(self.nodes) do
            node:SetShown(node.index ~= positionIndex);
        end

        SetTextPositionByIndex(self.TimeText, self.NodeContainer, positionIndex);
    end

    function DemoFrameMixin:Update()
        self.t = 2;
        self.t2 = 2;
        self.total = 0;
        self.shouldFade = nil;
        self.focused = nil;
        self.nodeAlpha = self.NodeContainer:GetAlpha();
        self.TimeText:SetShown(SHOW_TIME);
        self.NodeContainer:SetShown(SHOW_TIME);
        self:UpdateNodes();
    end

    local function NodeButton_OnClick(self)
        addon.SetDBValue("QueueStatus_TextPosition", self.index, true);
        EL:LoadSettings();
    end

    function AcquireDemoFrame()
        if not DemoFrame then
            DemoFrame = CreateFrame("Frame");
            API.Mixin(DemoFrame, DemoFrameMixin);
            DemoFrame:SetSize(192, 96);
            DemoFrame.cycle = 10;
            DemoFrame.unfocusedAlpha = 0.4;


            DemoFrame.Background = DemoFrame:CreateTexture(nil, "ARTWORK");
            DemoFrame.Background:SetPoint("CENTER", DemoFrame, "CENTER", 0, 0);
            DemoFrame.Background:SetSize(64, 64);
            DemoFrame.Background:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/Demo_QueueStatus.png");


            DemoFrame.TimeText = DemoFrame:CreateFontString(nil, "OVERLAY", "WhiteNormalNumberFont", 4);
            DemoFrame.TimeText:SetJustifyH("CENTER");
            DemoFrame.TimeText:SetJustifyV("TOP");
            --DemoFrame.TimeText:SetPoint("BOTTOM", DemoFrame.Background, "CENTER", 0, 24);


            local NodeContainer = CreateFrame("Frame", nil, DemoFrame);
            DemoFrame.NodeContainer = NodeContainer;
            NodeContainer:SetSize(48, 48);
            NodeContainer:SetPoint("CENTER", DemoFrame.Background, "CENTER", 0, 0);
            NodeContainer:SetAlpha(DemoFrame.unfocusedAlpha);


            local nodeTexture = "Interface/AddOns/Plumber/Art/ControlCenter/EditModeControlPoint.png";
            local nodes = {};
            DemoFrame.nodes = nodes;

            for i = 1, 5 do
                local node = CreateFrame("Button", nil, NodeContainer);
                nodes[i] = node;
                node.index = i - 1;
                node:SetSize(20, 20);
                node.Texture = node:CreateTexture(nil, "ARTWORK");
                node.Texture:SetSize(12, 12);
                node.Texture:SetPoint("CENTER", node, "CENTER", 0, 0);
                node.Texture:SetTexture(nodeTexture, nil, nil, "TRILINEAR");
                node.Texture:SetTexCoord(0, 0.25, 0, 0.25);
                node.Highlight = node:CreateTexture(nil, "HIGHLIGHT");
                node.Highlight:SetSize(32, 32);
                node.Highlight:SetPoint("CENTER", node, "CENTER", 0, 0);
                node.Highlight:SetTexture(nodeTexture, nil, nil, "TRILINEAR");
                node.Highlight:SetTexCoord(0.5, 1, 0, 0.5);
                node:SetScript("OnClick", NodeButton_OnClick);
                SetTextPositionByIndex(node, NodeContainer, node.index);
            end


            DemoFrame:SetScript("OnShow", DemoFrame.OnShow);
            DemoFrame:SetScript("OnHide", DemoFrame.OnHide);
            DemoFrame:OnShow();
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
		categoryKeys = {
			"Instance",
		},
    };

    addon.ControlCenter:AddModule(moduleData);
end