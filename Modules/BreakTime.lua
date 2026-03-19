local _, addon = ...
local L = addon.L;
local API = addon.API;
local GetDBValue = addon.GetDBValue;
local GetDBBool = addon.GetDBBool;
local SecondsToClock = API.SecondsToClock;
local time = time;


local Def = {
	TimeHeight = 48,
	TitleHeight = 14,

	TooltipHeight = 12,
	TooltipTextGapH = 24;
	TooltipIdleAlpha = 0.6,
	TooltipFocusedAlpha = 0.72,
	TooltipParagraphSpacing = 16,
	TooltipMaxWidth = 240,

	DotOffsetX = 12,
	ButtonTextOffsetX = 40,

	InactiveAlpha = 0.5,
	CountdownDuration = 10 * 60,
	TextureFile = "Interface/AddOns/Plumber/Art/Frame/Watch.png",
};

local Options = {
	CycleDuration = {
		minVal = 30,
		maxVal = 60,
		default = 30,
	},

	RestDuration = {
		minVal = 2,
		maxVal = 10,
		default = 5,
	},

	DelayDuration = {
		minVal = 2,
		maxVal = 10,
		default = 5,
	},
};


local Controller = CreateFrame("Frame");
local ClockUI;
local OnUpdate = {};
local DotButtonMixin = {};


local function HideClockUI(resetBreakTime)
	if ClockUI then
		ClockUI:Hide();
		if resetBreakTime then
			Controller:DisableCounting();
			Controller.timeLeft = nil;
		end
	end
	Controller.Scheduler.pauseUpdate = nil;
end


do  --Dot Button
	local TooltipSegmentMixin = {};

	function TooltipSegmentMixin:SetTooltipText(text)
		self:SetText(text);
		local height = math.ceil(self:GetHeight());
		self.Div:SetHeight(height + 4);
		self.height = height;
		local lineWeight = API.GetPixelForWidget(self, 2);
		self.Div:SetWidth(lineWeight);
	end


	function DotButtonMixin:OnEnter()
		API.UIFrameFade(self.Highlight, 0.12, 1);
		self.ButtonText:SetTextColor(1, 1, 1);
		self.TooltipContainer:SetAlpha(Def.TooltipFocusedAlpha);
		self:UpdateTooltip();
		self:ShowTooltip();
	end

	function DotButtonMixin:OnLeave()
		API.UIFrameFade(self.Highlight, 0.2, 0);
		self.ButtonText:SetTextColor(1, 0.82, 0);
		self.TooltipContainer:SetAlpha(Def.TooltipIdleAlpha);
		self:HideTooltip();
		addon.CancelClickAndHoldCallback()
	end

	function DotButtonMixin:OnMouseDown(button)
		self.Highlight:SetVertexColor(0.72, 0.72, 0.72);

		if self.onMouseDownFunc then
			self.onMouseDownFunc(self);
		end
	end

	function DotButtonMixin:OnMouseUp()
		self.Highlight:SetVertexColor(1, 1, 1);
	end

	function DotButtonMixin:SetFormattedTooltip(minutes)
		--override
	end

	function DotButtonMixin:UpdateTooltip()
		self:SetFormattedTooltip(self.timeGetter());
		self:LayoutTooltip();
	end

	function DotButtonMixin:CreateTooltipSegments(numSegments)
		if self.TooltipSegments then
			for i, seg in ipairs(self.TooltipSegments) do
				seg:Hide();
				seg:ClearAllPoints();
				seg.Div:Hide();
				seg.Div:ClearAllPoints();
			end
		else
			self.TooltipSegments = {};
		end

		for i = 1, numSegments do
			local seg = self.TooltipSegments[i];
			if not seg then
				seg = self.TooltipContainer:CreateFontString(nil, "OVERLAY");
				self.TooltipSegments[i] = seg;
				seg:SetFont(Def.FontFile, Def.TooltipHeight, "");
				seg:SetSpacing(4);
				seg:SetShadowOffset(1, -1);
				seg:SetShadowColor(0, 0, 0);
				seg:SetTextColor(1, 1, 1);
				seg:SetWidth(Def.TooltipMaxWidth);

				local Div = self.TooltipContainer:CreateTexture(nil, "OVERLAY");
				Div:SetSize(2, 8);
				Div:SetColorTexture(1, 1, 1, 0.5);
				seg.Div = Div;

				Mixin(seg, TooltipSegmentMixin);
			end

			if self.isLeft then
				seg:SetJustifyH("RIGHT");
				seg.Div:SetPoint("CENTER", seg, "RIGHT", 0.5*Def.TooltipTextGapH, 0);
				if i == 1 then
					seg:SetPoint("TOPRIGHT", self.TooltipContainer, "TOPRIGHT", 0, 0);
				else
					seg:SetPoint("TOPRIGHT", self.TooltipSegments[i - 1], "BOTTOMRIGHT", 0, -Def.TooltipParagraphSpacing);
				end
			else
				seg:SetJustifyH("LEFT");
				seg.Div:SetPoint("CENTER", seg, "LEFT", -0.5*Def.TooltipTextGapH, 0);
				if i == 1 then
					seg:SetPoint("TOPLEFT", self.TooltipContainer, "TOPLEFT", 0, 0);
				else
					seg:SetPoint("TOPLEFT", self.TooltipSegments[i - 1], "BOTTOMLEFT", 0, -Def.TooltipParagraphSpacing);
				end
			end
		end
	end

	function DotButtonMixin:ShowTooltip()

	end

	function DotButtonMixin:HideTooltip()

	end

	function DotButtonMixin:LayoutTooltip()
		local totalHeight = 0;
		for i, seg in ipairs(self.TooltipSegments) do
			totalHeight = totalHeight + seg.height;
			if i > 1 then
				totalHeight = totalHeight + Def.TooltipParagraphSpacing;
			end
		end
		self.TooltipContainer:SetHeight(totalHeight);
	end
end


local InitClockUI;
do  --Main UI
	local ClockUIMixin = {};

	function ClockUIMixin:ShowButtonText(state)
		self.ButtonContainer.alpha = self.ButtonContainer:GetAlpha();
		if state then
			self.LeftDot:Hide();
			self.RightDot:Hide();
			self.ButtonContainer:Show();
			self.ButtonContainer.DelayButton:UpdateTooltip();
			self.ButtonContainer.CancelButton:UpdateTooltip();
			self.ButtonContainer:SetScript("OnUpdate", function(f, elapsed)
				f.alpha = f.alpha + 5 * elapsed;
				if f.alpha >= 1 then
					f.alpha = 1;
					f.t = 0;
					f:SetScript("OnUpdate", OnUpdate.ButtonContainer_UpdateTooltip);
				end
				self.ButtonContainer:SetAlpha(f.alpha);
			end);
		else
			self.LeftDot:Show();
			self.RightDot:Show();
			self.ButtonContainer:SetScript("OnUpdate", function(f, elapsed)
				f.alpha = f.alpha - 5 * elapsed;
				if f.alpha <= 0 then
					f.alpha = 0;
					f:SetScript("OnUpdate", nil);
				end
				self.ButtonContainer:SetAlpha(f.alpha);
			end);
		end
	end

	function ClockUIMixin:UpdateFrameStrata(settingsShown)
		if (addon.ControlCenter.SettingsPanel:IsVisible()) or settingsShown then
			self:SetFrameStrata("LOW");
		else
			self:SetFrameStrata("HIGH");
		end
	end


	function InitClockUI()
		if ClockUI then return end;

		ClockUI = CreateFrame("Frame", nil, UIParent, "PlumberBreakTimeReminderTemplate");
		Mixin(ClockUI, ClockUIMixin);

		ClockUI.Background:SetTexture(Def.TextureFile);
		ClockUI.Background:SetTexCoord(0, 1, 0, 0.5);
		ClockUI.Dial:SetTexture(Def.TextureFile);
		ClockUI.Dial:SetTexCoord(0, 0.5, 0.5, 1);

		local cheeringTexture = "Interface/AddOns/Plumber/Art/Frame/WatchFace.png";
		ClockUI.CheeringFace:SetTexture(cheeringTexture);
		ClockUI.CheeringFace:SetTexCoord(0.5, 0.75, 0, 0.125);
		ClockUI.CheeringLeftArm:SetTexture(cheeringTexture);
		ClockUI.CheeringLeftArm:SetTexCoord(0, 0.5, 0, 0.5);
		ClockUI.CheeringRightArm:SetTexture(cheeringTexture);
		ClockUI.CheeringRightArm:SetTexCoord(0.5, 0, 0, 0.5);

		local _SetAlpha = ClockUI.ButtonContainer.SetAlpha;
		function ClockUI.ButtonContainer:SetAlpha(alpha)
			ClockUI.LeftDot:SetAlpha(1 - alpha);
			ClockUI.RightDot:SetAlpha(1 - alpha);
			_SetAlpha(self, alpha);
		end


		local font;
		if GetLocale() == "enUS" then
			font = PlumberFont_Clock48:GetFont();
		else
			font = GameFontNormal:GetFont();
		end
		Def.FontFile = font;
		ClockUI.Title:SetFont(font, Def.TitleHeight, "OUTLINE");
		ClockUI.Title:SetText(L["BreakTime Title AllCaps"]);


		local function SetupDotButton(button, isLeft)
			Mixin(button, DotButtonMixin);
			button:SetScript("OnEnter", DotButtonMixin.OnEnter);
			button:SetScript("OnLeave", DotButtonMixin.OnLeave);
			button:SetScript("OnMouseDown", DotButtonMixin.OnMouseDown);
			button:SetScript("OnMouseUp", DotButtonMixin.OnMouseUp);

			button.ButtonText:ClearAllPoints();
			button.TooltipContainer:ClearAllPoints();
			button.Highlight:ClearAllPoints();

			button.ButtonText:SetFont(font, Def.TitleHeight, "");
			button.ButtonText:SetShadowOffset(1, -1);

			button.TooltipContainer:SetAlpha(Def.TooltipIdleAlpha);
			button.isLeft = isLeft;

			if isLeft then
				button.Dot = ClockUI.LeftDot;
			else
				button.Dot = ClockUI.RightDot;
			end

			button.Dot:SetTexture(Def.TextureFile);
			button.Dot:SetTexCoord(0.5, 0.625, 0.5, 0.625);
			button.Dot:ClearAllPoints();

			button.Highlight:SetTexture(Def.TextureFile);

			if isLeft then
				button.ButtonText:SetText(L["BreakTime Delay Button"]);
				button.ButtonText:SetPoint("RIGHT", button, "RIGHT", -Def.ButtonTextOffsetX, 0);
				button.tooltipFormat = L["BreakTime Delay Button Tooltip Format"];
				button.TooltipContainer:SetPoint("RIGHT", button.ButtonText, "LEFT", -Def.TooltipTextGapH, 0);
				button.Dot:SetPoint("CENTER", button, "RIGHT", -6 - Def.DotOffsetX - Def.ButtonTextOffsetX, 0);
				button.Highlight:SetTexCoord(1, 0.625, 0.5, 1);
				button.Highlight:SetPoint("RIGHT", ClockUI, "CENTER", -32, 0);
				button.timeGetter = Controller.GetDefaultDelayInMinutes;

				button:CreateTooltipSegments(1);
				function button:SetFormattedTooltip(minutes)
					button.TooltipSegments[1]:SetTooltipText(L["BreakTime Delay Button Tooltip Format"]:format(minutes));
				end

				button:SetScript("OnClick", function()
					Controller.DelayCurrentTimer();
				end);
			else
				button.ButtonText:SetText(L["BreakTime Cancel Button"]);
				button.ButtonText:SetPoint("LEFT", button, "LEFT", Def.ButtonTextOffsetX, 0);
				button.tooltipFormat = L["BreakTime Cancel Button Tooltip Format"];
				button.TooltipContainer:SetPoint("LEFT", button.ButtonText, "RIGHT", Def.TooltipTextGapH, 0);
				button.Dot:SetPoint("CENTER", button, "LEFT", 6 + Def.DotOffsetX + Def.ButtonTextOffsetX, 0);
				button.Highlight:SetTexCoord(0.625, 1, 0.5, 1);
				button.Highlight:SetPoint("LEFT", ClockUI, "CENTER", 32, 0);
				button.timeGetter = Controller.GetMinutesAfterSkip;

				button.onMouseDownFunc = function()
					button.AnimFadeOutText:Stop();
					button.AnimFadeOutText:Play();
					addon.SetClickAndHoldCallback(1, Controller.CancelForSession, button, button.ButtonText, function()
						button.AnimFadeOutText:Stop();
					end);
				end

				button:CreateTooltipSegments(2);
				function button:SetFormattedTooltip(minutes)
					button.TooltipSegments[1]:SetTooltipText(L["BreakTime Cancel Button Tooltip Format 1"]:format(minutes));
					button.TooltipSegments[2]:SetTooltipText(L["BreakTime Cancel Button Tooltip 2"]);
				end

				button:SetScript("OnClick", function()
					if not addon.IsClickAndHoldInProgress() then
						Controller.SkipCurrentCycle();
					end
				end);
			end

			button:SetFormattedTooltip(0);
			button:LayoutTooltip();
		end


		SetupDotButton(ClockUI.ButtonContainer.DelayButton, true);
		SetupDotButton(ClockUI.ButtonContainer.CancelButton, false);


		ClockUI.MouseoverFrame:SetScript("OnEnter", function()
			ClockUI:ShowButtonText(true);
		end);

		ClockUI.MouseoverFrame:SetScript("OnLeave", function()
			ClockUI:ShowButtonText(false);
		end);


		addon.InitClickAndHoldCallback();


		addon.CallbackRegistry:Register("SettingsPanel.Show", function()
			ClockUI:UpdateFrameStrata(true);
		end);
		addon.CallbackRegistry:Register("SettingsPanel.Hide", function()
			ClockUI:UpdateFrameStrata(false);
		end);
	end
end


do  --OnUpdate Funcs
	function OnUpdate.CallAfterDelay(self, elapsed)
		self.t = self.t + elapsed;
		if self.t >= 0 then
			self:SetScript("OnUpdate", nil);
			if self.delayFinishedCallback then
				local callback = self.delayFinishedCallback;
				self.delayFinishedCallback = nil;
				callback(self);
			end
		end
	end

	function OnUpdate.Counting(self, elapsed)
		--elapsed = elapsed * 50;  --Debug Time multiplier

		self.radian = self.radian + 0.1*elapsed * self.pi2;
		if self.radian > self.pi2 then
			self.radian = self.radian - self.pi2;
		end
		ClockUI.Dial:SetRotation(-self.radian);

		self.second = self.second + elapsed;
		while self.second > 1 do
			self.second = self.second - 1;
			self.timeLeft = self.timeLeft - 1;
			ClockUI.TimeText:SetText(SecondsToClock(self.timeLeft, true));
		end

		if self.timeLeft <= 0 then
			self:SetScript("OnUpdate", nil);
			ClockUI.TimeText:SetText(SecondsToClock(0, true));
			self.timeLeft = nil;
			self:OnCountdownComplete();
		end

		if self.alphaDirty then
			self.alpha = self.alpha + 1 * elapsed;
			if self.alpha >= 1 then
				self.alpha = 1;
				self.alphaDirty = nil;
			end
			ClockUI.TimeText:SetAlpha(self.alpha);
			ClockUI.Dial:SetAlpha(self.alpha);
		end
	end

	function OnUpdate.PauseCountdown(self, elapsed)
		self.alpha = self.alpha - 2 * elapsed;
		if self.alpha <= Def.InactiveAlpha then
			self.alpha = Def.InactiveAlpha;
			self:SetScript("OnUpdate", nil);
		end
		ClockUI.Dial:SetAlpha(self.alpha);
		ClockUI.TimeText:SetAlpha(self.alpha);
	end

	function OnUpdate.ButtonContainer_UpdateTooltip(self, elapsed)
		self.t = self.t + elapsed;
		if self.t > 5 then
			self.t = 0;
			self.DelayButton:UpdateTooltip();
			self.CancelButton:UpdateTooltip();
		end
	end
end


local OptionToggle_OnClick;
do  --Options
	local function GetValidValue(value, valueDefination)
		if type(value) == "number" then
			if value > valueDefination.maxVal or value < valueDefination.minVal then
				value = nil;
			end
		else
			value = nil;
		end

		if not value then
			value = valueDefination.default;
		end

		return value
	end

	function Options.GetValidatedDurationsInMinutes()
		local cycle = GetValidValue(GetDBValue("BreakTime_Cycle"), Options.CycleDuration);
		local rest = GetValidValue(GetDBValue("BreakTime_Rest"), Options.RestDuration);
		return cycle, rest
	end

	function Options.GetValidatedDurationsInSeconds()
		local cycle, rest = Options.GetValidatedDurationsInMinutes();
		return 60 * cycle, 60 * rest
	end

	function Options.GetValidatedDelay()
		return GetValidValue(GetDBValue("BreakTime_Delay"), Options.DelayDuration);
	end

	function Options.TryUpdateDemoFrame()
		if Options.UpdateDemoFrame then
			Options.UpdateDemoFrame();
		end
	end

	function Options.GetScheduleTooltip()
		if GetDBBool("BreakTime") then
			local cycle, rest = Options.GetValidatedDurationsInMinutes();
			local scheduleText = L["BreakTime Current Schedule Format"]:format(rest, cycle);
			local tooltip;
			if Controller.isCancelledForSession then
				tooltip = scheduleText.."\n\n|cffd4641c"..L["BreakTime Announce Timer Cancelled"].."|r";
			else
				local nextText = L["BreakTime Announce Time Before Alert Format"]:format(Controller.GetMinutesUntilNextGoOff());
				tooltip = scheduleText.."\n\n"..nextText;
			end
			return string.gsub(tooltip, "|cffffffff", "|cffd7c0a3");
		end
	end

	local DemoFrame;

	local function AcquireDemoFrame()
		if DemoFrame then return DemoFrame end;

		local f = CreateFrame("Frame");
		DemoFrame = f;
		f:SetSize(192, 96);

		f.Title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		f.Title:SetJustifyH("CENTER");
		f.Title:SetWidth(288);
		f.Title:SetPoint("CENTER", f, "CENTER", 0, 0);
		f.Title:SetTextColor(1, 0.82, 0);
		f.Title:SetSpacing(4);

		function Options.UpdateDemoFrame()
			local cycle, rest = Options.GetValidatedDurationsInMinutes();
			local scheduleText = L["BreakTime Current Schedule Format"]:format(rest, cycle);
			if Controller.isCancelledForSession then
				f.Title:SetText(scheduleText.."\n|cff808080"..L["BreakTime Announce Timer Cancelled"].."|r");
			else
				local nextText = L["BreakTime Announce Time Before Alert Format"]:format(Controller.GetMinutesUntilNextGoOff());
				if Controller.Scheduler.isAFK then
					nextText = nextText.."\n|cff808080"..L["BreakTime AFK Pause"].."|r";
				end
				f.Title:SetText(scheduleText.."\n"..nextText);
			end
		end

		f.t = 0;
		f:SetScript("OnUpdate", function(self, elapsed)
			self.t = self.t + elapsed;
			if self.t >= 2 then
				self.t = 0;
				Options.UpdateDemoFrame();
			end
		end);

		f:SetScript("OnShow", function(self, elapsed)
			self.t = 0;
			Options.UpdateDemoFrame();
		end);

		return f
	end

	local function FormatNumericValue(value)
		return string.format("%.0f", value)
	end

	local function Shared_Slider_OnValueChanged(value)
		local _, restSeconds = Options.GetValidatedDurationsInSeconds();
		Controller.timeLeft = restSeconds;
		Controller.second = 1;
		if ClockUI then
			ClockUI.TimeText:SetText(SecondsToClock(Controller.timeLeft, true));
		end
		Controller:UpdateSchedule();
	end

	local function Rest_Slider_OnValueChanged(value)
		addon.SetDBValue("BreakTime_Rest", value);
		Shared_Slider_OnValueChanged(value);
	end

	local function Cycle_Slider_OnValueChanged(value)
		addon.SetDBValue("BreakTime_Cycle", value);
		Shared_Slider_OnValueChanged(value);
	end

	local function Delay_Slider_OnValueChanged(value)
		addon.SetDBValue("BreakTime_Delay", value);
	end

	local function IsAnyScheduleCancelled()
		if GetDBBool("BreakTimeFlag_Cancelled") then
			return true
		end

		return PlumberDB.lastLoginTime and PlumberDB.lastLoginTime > time()
	end

	local function ResetCancelledSchedule()
		local current = time();
		if PlumberDB.lastLoginTime and PlumberDB.lastLoginTime > current then
			Controller:UpdateLastLoginTime();
		end
		Controller.OnNewGameSessionBegin();
		addon.UpdateSettingsDialog();
	end


	local OPTIONS_SCHEMATIC = {
		title = L["ModuleName BreakTime"],
		moduleDBKey = "BreakTime",
		widgets = {
			{type = "Custom", onAcquire = AcquireDemoFrame, align = "center"},
			{type = "UIPanelButton", label = L["BreakTime Reset Cancellation"], onClickFunc = ResetCancelledSchedule, stateCheckFunc = IsAnyScheduleCancelled, widgetKey = "ResetButton", validityCheckFunc = IsAnyScheduleCancelled},

			{type = "Divider"},
			{type = "Slider", label = L["BreakTime Option Rest"], tooltip = L["BreakTime Option Rest Tooltip"], minValue = Options.RestDuration.minVal, maxValue = Options.RestDuration.maxVal, valueStep = 1, onValueChangedFunc = Rest_Slider_OnValueChanged, formatValueFunc = FormatNumericValue, dbKey = "BreakTime_Rest"},
			{type = "Slider", label = L["BreakTime Option Cycle"], tooltip = L["BreakTime Option Cycle Tooltip"], minValue = Options.CycleDuration.minVal, maxValue = Options.CycleDuration.maxVal, valueStep = 5, onValueChangedFunc = Cycle_Slider_OnValueChanged, formatValueFunc = FormatNumericValue, dbKey = "BreakTime_Cycle"},

			{type = "Divider"},
			{type = "Slider", label = L["BreakTime Option Delay"], tooltip = L["BreakTime Option Delay Tooltip"], minValue = Options.DelayDuration.minVal, maxValue = Options.DelayDuration.maxVal, valueStep = 1, onValueChangedFunc = Delay_Slider_OnValueChanged, formatValueFunc = FormatNumericValue, dbKey = "BreakTime_Delay"},
			{type = "Checkbox", label = L["BreakTime Option FlashTaskbar"], tooltip = L["BreakTime Option FlashTaskbar Tooltip"], dbKey = "BreakTime_FlashTaskbar"},

			{type = "Divider"},
			{type = "Header", label = L["BreakTime Option DND"]};
			{type = "Checkbox", label = L["BreakTime Option DNDCombat"], tooltip = L["BreakTime Option DNDCombat Tooltip"], dbKey = "BreakTime_DNDCombat", stateCheckFunc = function() return false end},   --This option is always enabled
			{type = "Checkbox", label = L["BreakTime Option DNDInstances"], tooltip = L["BreakTime Option DNDInstances Tooltip"], dbKey = "BreakTime_DNDInstances"},
		},
	};

	function OptionToggle_OnClick(self, button)
		local OptionFrame = addon.ToggleSettingsDialog(self, OPTIONS_SCHEMATIC, true);
		if OptionFrame then
			OptionFrame:ConvertAnchor();
		end
	end
end


do  --Controller
	Controller.pi2 = 2*math.pi;


	local Scheduler = CreateFrame("Frame");
	Controller.Scheduler = Scheduler;

	Scheduler:SetScript("OnEvent", function(self, event, ...)
		--only CHAT_MSG_SYSTEM
		--UnitIsAFK doesn't change immediately
		self.afkUpdateElapsed = 0;
	end);

	function Scheduler:UpdateAFKStatus()
		local isAFK = UnitIsAFK("player");
		if API.Secret_CanAccess(isAFK) then
			isAFK = isAFK;
		else
			isAFK = false;
		end

		if isAFK ~= self.isAFK then
			if (self.isAFK and not isAFK) and self.afkStartTime then
				local _, restSeconds = Options.GetValidatedDurationsInSeconds();
				if time() - self.afkStartTime > 0.98 * restSeconds then     --2% 2s/120s
					Controller:UpdateLastLoginTime();
					Controller:UpdateSchedule();
				end
			end

			if isAFK then
				self.afkStartTime = time();
			else
				self.afkStartTime = nil;
			end

			self.isAFK = isAFK;
			Options.TryUpdateDemoFrame();
		end
	end


	local HealthyEvents = {
		PLAYER_STOPPED_MOVING = true,
		PLAYER_STOPPED_LOOKING = true,
		PLAYER_STOPPED_TURNING = true,
	};

	local UnhealthyEvents = {
		PLAYER_STARTED_MOVING = true,
		PLAYER_STARTED_LOOKING = true,
		PLAYER_STARTED_TURNING = true,
	};

	local function RegisterEvent(frame, events, state)
		if state then
			for event in pairs(events) do
				frame:RegisterEvent(event);
			end
		else
			for event in pairs(events) do
				frame:UnregisterEvent(event);
			end
		end
	end

	function Controller:Stop()
		self:UnregisterAllEvents();
		self:SetScript("OnEvent", nil);
		self:SetScript("OnUpdate", nil);
	end

	function Controller:OnClockReady()
		RegisterEvent(self, HealthyEvents, true);
		RegisterEvent(self, UnhealthyEvents, true);
		self:SetScript("OnEvent", self.OnEvent_ClockReady);
	end

	function Controller:OnEvent_ClockReady(event, ...)
		if UnhealthyEvents[event] then
			self:PauseCountdown();
		elseif HealthyEvents[event] then
			self:RequestEvaluateCountdown();
		end
	end

	function Controller:CallAfterDelay(delay, callback)
		self.t = -delay;
		self.delayFinishedCallback = callback;
		self:SetScript("OnUpdate", OnUpdate.CallAfterDelay);
	end

	function Controller:RequestEvaluateCountdown()
		self:CallAfterDelay(1, self.EvaluateCountdown);
	end

	function Controller:EvaluateCountdown()
		if IsMouselooking() or IsPlayerMoving() then
			return
		else
			self:StartCoundown();
		end
	end

	function Controller:StartCoundown()
		self.alpha = ClockUI.Dial:GetAlpha();
		self.alphaDirty = true;
		if self.timeLeft then
			self:SetScript("OnUpdate", OnUpdate.Counting);
		end
	end

	function Controller:PauseCountdown()
		self.alpha = ClockUI.Dial:GetAlpha();
		self:SetScript("OnUpdate", OnUpdate.PauseCountdown);
	end

	function Controller:PlayIntroAnimation()
		InitClockUI();

		if ClockUI:IsShown() and ClockUI.AnimIn:IsPlaying() then
			return
		end

		self:Stop();
		self.radian = 0;
		self.second = self.second or 0;

		ClockUI:StopAnimating();
		ClockUI:SetScript("OnUpdate", nil);
		ClockUI.ButtonContainer:Hide();
		ClockUI.MouseoverFrame:Hide();
		ClockUI.Dial:SetRotation(0);
		ClockUI.TimeText:SetText(SecondsToClock(Controller.timeLeft, true));
		ClockUI.ButtonContainer:SetAlpha(0);
		ClockUI.ButtonContainer:SetScript("OnUpdate", nil);
		ClockUI.LeftDot:Show();
		ClockUI.RightDot:Show();
		ClockUI.AnimIn:Play();
		ClockUI.CheeringFace:SetAlpha(0);
		ClockUI.CheeringLeftArm:Hide();
		ClockUI.CheeringRightArm:Hide();
		ClockUI:Show();
		ClockUI:UpdateFrameStrata();
		self:CallAfterDelay(1.5, self.StartWatching);
	end

	function Controller:PlayCheeringAnimation()
		ClockUI:StopAnimating();
		ClockUI:SetScript("OnUpdate", nil);
		ClockUI.ButtonContainer:Hide();
		ClockUI.MouseoverFrame:Hide();
		ClockUI.CheeringFace:SetAlpha(1);
		ClockUI.CheeringLeftArm:Show();
		ClockUI.CheeringRightArm:Show();
		ClockUI.AnimCheering:Play();
		ClockUI.AnimCheeringFade:Play();
		ClockUI.LeftDot:Hide();
		ClockUI.RightDot:Hide();
	end

	function Controller:StartWatching()
		ClockUI.TimeText:SetAlpha(Def.InactiveAlpha);
		ClockUI.Dial:SetAlpha(Def.InactiveAlpha);
		ClockUI.MouseoverFrame:Show();

		self.alpha = Def.InactiveAlpha;
		self:Stop();
		self:OnClockReady();
		self:EvaluateCountdown();
	end

	function Controller:UpdateLastLoginTime()
		PlumberDB.lastLoginTime = time();
	end

	function Controller.GetDefaultDelayInMinutes()
		return Options.GetValidatedDelay()
	end

	function Controller:DisableCounting()
		if self:GetScript("OnUpdate") == OnUpdate.Counting or self:GetScript("OnUpdate") == OnUpdate.PauseCountdown then
			self:SetScript("OnUpdate", nil);
			RegisterEvent(self, HealthyEvents, false);
			RegisterEvent(self, UnhealthyEvents, false);
			if self:GetScript("OnEvent") == self.OnEvent_ClockReady then
				self:SetScript("OnEvent", nil);
			end
		end
	end

	function Controller.DelayCurrentTimer()
		HideClockUI();
		local delay = Controller.GetDefaultDelayInMinutes();
		local delaySeconds = 60 * delay;
		API.DisplayAlertMessage(L["BreakTime Announce Time Before Alert Format"]:format(delay));
		local cycleSeconds = Options.GetValidatedDurationsInSeconds();
		PlumberDB.lastLoginTime = time() - (cycleSeconds - delaySeconds);
		Controller:DisableCounting();
		Controller:UpdateSchedule();

		Options.TryUpdateDemoFrame();
	end

	function Controller.SkipCurrentCycle()
		if Controller.isCancelledForSession then
			return
		end
		HideClockUI(true);
		Controller.second = 0;

		if Scheduler.remainingTime then
			API.DisplayAlertMessage(L["BreakTime Announce Time Before Alert Format"]:format(Controller.GetMinutesUntilNextGoOff()));
		end

		Options.TryUpdateDemoFrame();
	end

	function Controller.CancelForSession()
		Controller.isCancelledForSession = true;
		addon.SetDBValue("BreakTimeFlag_Cancelled", true);
		HideClockUI(true);
		Controller.second = 0;
		API.DisplayErrorMessage(L["BreakTime Announce Timer Cancelled"]);
		Options.TryUpdateDemoFrame();
	end

	function Controller.OnNewGameSessionBegin()
		addon.SetDBValue("BreakTimeFlag_Cancelled", false);
		Controller:UpdateSchedule();
	end
	addon.CallbackRegistry:Register("NewGameSessionBegin", Controller.OnNewGameSessionBegin);

	---GetNextGoOffTime
	---@return number nextGoOff The epoch time when the next timer goes off
	---@return number remainingTime Seconds before next go-off
	function Controller:GetNextGoOffTime()
		local cycleSeconds, restSeconds = Options.GetValidatedDurationsInSeconds();
		local nextGoOff = addon.GetLastLoginTime() + cycleSeconds;
		local current = time();

		while nextGoOff <= current + 1 do
			nextGoOff = nextGoOff + cycleSeconds;
		end


		--debug
		--[[
		if not self.firstGoOffModified then
			self.firstGoOffModified = true;
			nextGoOff = current + 5;
		end
		--]]

		return nextGoOff, nextGoOff - current
	end

	function Controller.GetMinutesUntilNextGoOff()
		if Scheduler.remainingTime then
			return math.ceil(Scheduler.remainingTime / 60)
		else
			return 0
		end
	end

	function Controller.GetMinutesAfterSkip()
		local scheduledGoOff = Controller.GetMinutesUntilNextGoOff();
		if Controller.lastCycleComplete then
			local cycleSeconds = Options.GetValidatedDurationsInSeconds();
			return math.ceil(scheduledGoOff + cycleSeconds / 60)
		else
			return scheduledGoOff
		end
	end

	function Controller:UpdateSchedule()
		self.enabled = GetDBBool("BreakTime");
		self.isCancelledForSession = GetDBBool("BreakTimeFlag_Cancelled");

		if self.enabled then
			if self.isCancelledForSession then
				Scheduler:SetScript("OnUpdate", nil);
			else
				local nextGoOff, remainingTime = Controller:GetNextGoOffTime();
				Scheduler.remainingTime = remainingTime;

				Scheduler:SetScript("OnUpdate", function(f, elapsed)
					--elapsed = elapsed * 50;  --Debug Time multiplier

					if f.afkUpdateElapsed then
						f.afkUpdateElapsed = f.afkUpdateElapsed + elapsed;
						if f.afkUpdateElapsed >= 1 then
							f.afkUpdateElapsed = nil;
							f:UpdateAFKStatus();
						end
					end

					if f.isAFK or f.pauseUpdate then
						return
					end

					f.remainingTime = f.remainingTime - elapsed;
					if f.remainingTime <= 0 then
						f.remainingTime = 0;
						f:SetScript("OnUpdate", nil);

						if self.isCancelledForSession then return end;

						local _, restSeconds = Options.GetValidatedDurationsInSeconds();
						if (not Controller.timeLeft) or Controller.timeLeft > restSeconds then
							Controller.timeLeft = restSeconds;
						end
						Controller.lastCycleComplete = false;

						self:TryShowTimer();
					end
				end);
			end

			Options.TryUpdateDemoFrame();
		else
			HideClockUI(true);
			Scheduler:SetScript("OnUpdate", nil);
			self:Stop();
		end
	end


	local AutoCloseEvents = {
		PLAYER_STARTED_MOVING = true,
		PLAYER_STARTED_LOOKING = true,
		PLAYER_STARTED_TURNING = true,
		GLOBAL_MOUSE_DOWN = true,
		GLOBAL_MOUSE_UP = true,
	};

	function Controller:OnEvent_CountdownComplete(event)
		self:Stop();
		HideClockUI();
	end

	function Controller:OnCountdownComplete()
		self.lastCycleComplete = true;
		self.second = 0;
		self:Stop();
		if ClockUI:IsShown() then
			ClockUI.MouseoverFrame:Hide();
			ClockUI.ButtonContainer:Hide();
			Scheduler.pauseUpdate = true;
			self:PlayCheeringAnimation();
			for event in pairs(AutoCloseEvents) do
				self:RegisterEvent(event);
			end
			self:SetScript("OnEvent", self.OnEvent_CountdownComplete);
		end
	end


	local InCombatLockdown = InCombatLockdown;
	local IsPlayerInInstance = API.IsPlayerInInstance;

	local DeferredEvents = {
		PLAYER_REGEN_ENABLED = true,
		LOADING_SCREEN_DISABLED = true,
		PLAYER_MAP_CHANGED = true,
		SCENARIO_COMPLETED = true,
	};

	function Controller:OnEvent_TryShowTimer(event)
		if DeferredEvents[event] then
			self:CallAfterDelay(1, self.TryShowTimer);
		end
	end

	function Controller:TryShowTimer()
		if API.IsInPvP() or InCombatLockdown() or (GetDBBool("BreakTime_DNDInstances") and IsPlayerInInstance()) then
			if self:GetScript("OnEvent") ~= self.OnEvent_TryShowTimer then
				self:SetScript("OnEvent", self.OnEvent_TryShowTimer);
				RegisterEvent(self, DeferredEvents, true);
				API.PrintMessage(L["BreakTime Annouce Timer Deferred Combat"]);
			end
		else
			RegisterEvent(self, DeferredEvents, false);
			self:SetScript("OnEvent", nil);
			self:PlayIntroAnimation();
			self:UpdateLastLoginTime();
			self:UpdateSchedule();
			Scheduler.pauseUpdate = nil;
			if GetDBBool("BreakTime_FlashTaskbar") then
				FlashClientIcon();
			end
		end
	end

	function Controller.EnableModule(state)
		Controller:UpdateSchedule();
		if state then
			Controller.Scheduler:RegisterEvent("CHAT_MSG_SYSTEM");
			Controller.Scheduler:UpdateAFKStatus();
		else
			Controller.Scheduler:UnregisterEvent("CHAT_MSG_SYSTEM");
		end
	end
end


do
	local moduleData = {
		name = L["ModuleName BreakTime"],
		dbKey = "BreakTime",
		description = L["ModuleDescription BreakTime"],
		descriptionFunc = Options.GetScheduleTooltip,
		toggleFunc = Controller.EnableModule,
		moduleAddedTime = 1771800000,
		optionToggleFunc = OptionToggle_OnClick,
		categoryKeys = {
			"Signature",
		},
	};

	addon.ControlCenter:AddModule(moduleData);
end


do
	function addon.TryAddBreakTimeToTooltip(tooltip)
		if GetDBBool("BreakTime") and not GetDBBool("BreakTimeFlag_Cancelled") then
			tooltip:AddLine(" ");
			tooltip:AddLine(L["BreakTime Shared Countdown Tooltip Format"]:format(Controller.GetMinutesUntilNextGoOff()), 1, 0.82, 0, false);
		end
	end
end


--do  --Debug
	--function Plumber_TriggerTimer()
	--    Controller.Scheduler.remainingTime = 1;
	--end
--end
