local _, addon = ...
local API = addon.API;
local L = addon.L;

local SecondsToClock = API.SecondsToClock;

local Round = Round;
local C_Navigation = C_Navigation;
local C_SuperTrack = C_SuperTrack;
local SetSuperTrackedUserWaypoint = C_SuperTrack.SetSuperTrackedUserWaypoint;
local SetUserWaypoint = C_Map.SetUserWaypoint;
local GetCursorPosition = GetCursorPosition;
local ClampedPercentageBetween = ClampedPercentageBetween;
local FrameDeltaLerp = FrameDeltaLerp;
local DeltaLerp = DeltaLerp;
local CreateVector2D = CreateVector2D;
local Vector2D_Normalize = Vector2D_Normalize;
local Vector2D_CalculateAngleBetween = Vector2D_CalculateAngleBetween;
local UIParent = UIParent;
local WorldFrame = WorldFrame;
local AbbreviateNumbers = AbbreviateNumbers;
local C_QuestLog = C_QuestLog;
local GetMouseFocus = GetMouseFocus;
local InCombatLockdown = InCombatLockdown;
local floor = math.floor;
local deg = math.deg;
local PI2 = 2*math.pi;
local sqrt = math.sqrt;

local FORMAT_RANGE = IN_GAME_NAVIGATION_RANGE;
local ALPHA_CLAMPED_TIMER = 0.6;
local CLICK_THRESHOLD = 0.2;			--Right Mouse Button Down/Up within this time window is considered a Right Click
local LOCK_TO_USER_WAYPOINT = true;		--Game will try to track auto-accepted World Quest when passing through, we need to re-set it to our waypoint

local MainFrame;
local UpdateFrame = CreateFrame("Frame");


local function GetSuperTrackFrame()
	if not MainFrame then
		MainFrame = CreateFrame("Frame", nil, UIParent, "PlumberSuperTrackingTemplate");
	end
	return MainFrame
end
addon.GetSuperTrackFrame = GetSuperTrackFrame;


local function InterpolateDimension(lastValue, targetValue, amount, elapsed)
	return lastValue and amount and DeltaLerp(lastValue, targetValue, amount, elapsed) or targetValue;
end


PlumberSuperTrackingMixin = {};

function PlumberSuperTrackingMixin:SetArrowAngle(radian)
	if radian < 0 then
		radian = -radian;
	else
		radian = PI2 - radian;
	end

	local n = floor(( deg(radian) + 2.5) * 0.2 ) + 1;    -- /5
	if n > 72 then
		n = 1;
	end
	local row = floor(n / 8);
	local col = floor(n % 8);
	if col == 0 then
		col = 8;
		row = row - 1;
	end
	col = col - 1;
	self.Arrow:SetTexCoord(0.125*col, 0.125*col + 0.125, 0.0625*row, 0.0625*row + 0.0625);
end

function PlumberSuperTrackingMixin:OnLoad()
	MainFrame = self;

	self.useTitle = true;
	self.t = 0;
	self.mouseToNavVec = CreateVector2D(0, 0);
	self.indicatorVec = CreateVector2D(0, 0);
	self.circularVec = CreateVector2D(0, 0);

	UpdateFrame:SetParent(self);
	self.Arrow:SetTexture("Interface/AddOns/Plumber/Art/SuperTracking/DirectionArrow_Angle.png", nil, nil, "LINEAR");
	self:SetArrowAngle(0);
end

function PlumberSuperTrackingMixin:EnableSuperTracking(state)
	local f = SuperTrackedFrame;

	if (not state) and self.enabled then
		self.enabled = false;
		self:UnregisterEvent("NAVIGATION_FRAME_CREATED");
		self:UnregisterEvent("NAVIGATION_FRAME_DESTROYED");
		self:UnregisterEvent("SUPER_TRACKING_CHANGED");
		self:UnregisterEvent("QUEST_ACCEPTED");
		self:MonitorClicks(false);
		self:Hide();
		f:RegisterEvent("NAVIGATION_FRAME_CREATED");
		f:RegisterEvent("NAVIGATION_FRAME_DESTROYED");
		f:RegisterEvent("SUPER_TRACKING_CHANGED");
		C_Map.ClearUserWaypoint();
		f:InitializeNavigationFrame();
		f:Show();

	elseif state and not self.enabled then
		self.enabled = true;
		self:RegisterEvent("NAVIGATION_FRAME_CREATED");
		self:RegisterEvent("NAVIGATION_FRAME_DESTROYED");
		self:RegisterEvent("SUPER_TRACKING_CHANGED");
		self:RegisterEvent("QUEST_ACCEPTED");
		self:MonitorClicks(true);
		self:Show();
		f:UnregisterEvent("NAVIGATION_FRAME_CREATED");
		f:UnregisterEvent("NAVIGATION_FRAME_DESTROYED");
		f:UnregisterEvent("SUPER_TRACKING_CHANGED");
		f:ShutdownNavigationFrame();
		f:Hide();
	end
end

function PlumberSuperTrackingMixin:TryEnableByModule()
	if PlumberDB.Navigator_MasterSwitch then
		self:EnableSuperTracking(true);
	end
end



function PlumberSuperTrackingMixin:OnEvent(event, ...)
	if event == "NAVIGATION_FRAME_CREATED" then
		self:InitializeNavigationFrame();
	elseif event == "NAVIGATION_FRAME_DESTROYED" then
		self:ShutdownNavigationFrame();
	elseif event == "SUPER_TRACKING_CHANGED" then
		self:OnSuperTrackingChanged();
		--print(event, ...)
	elseif event == "QUEST_ACCEPTED" then
		self:OnQuestAccepted(...);
	elseif event == "GLOBAL_MOUSE_DOWN" then
		local button = ...
		if button == "RightButton" then
			self:OnMouseStateChanged(true);
		end
	elseif event == "GLOBAL_MOUSE_UP" then
		self:OnMouseStateChanged(false);
	end
end

function PlumberSuperTrackingMixin:OnMouseStateChanged(rightButtonDown)
	if rightButtonDown then
		self.rightButtonDownTime = 0;
	else
		if self.rightButtonDownTime and self.rightButtonDownTime < CLICK_THRESHOLD then
			if self.Icon:IsMouseOver(-6, 6, 6, -6) and GetMouseFocus() == WorldFrame then
				--Shrink from 32 to 20
				if self.isClamped or (self.distance and self.distance > 15) then	--Hack to avoid conflict with interacting with NPC, objects...
					if not InCombatLockdown() or (self.Icon:IsMouseOver(-8, 8, 8, -8)) then	--Sticker rules to trigger right-click during combat
						self:ToggleMenu();
					end
				end
			end
		end
		self.rightButtonDownTime = nil;
	end
end

function PlumberSuperTrackingMixin:OnUpdate(elapsed)
	self:CheckInitializeNavigationFrame();

	if self.navFrame then
		self.t = self.t + elapsed;
		if self.t > 1 then
			self.t = 0;
			self.requestUpdate = true;
			self:UpdateTimer();
		end

		if self.rightButtonDownTime then
			self.rightButtonDownTime = self.rightButtonDownTime + elapsed;
			if self.rightButtonDownTime > 0.5 then
				self.rightButtonDownTime = nil;
			end
		end

		self:UpdateClampedState();
		self:UpdatePosition();
		self:UpdateInterpolation(elapsed);
		self:UpdateArrow();
		self:UpdateDistance();
		self:UpdateAlpha();

		self.requestUpdate = false;
	end

	self.setByPlumber = false;
end

function PlumberSuperTrackingMixin:UpdateClampedState()
	local clamped = C_Navigation.WasClampedToScreen();
	self.clampedChanged = clamped ~= self.isClamped;
	self.isClamped = clamped;

	if self.clampedChanged then
		self:OnClampedChanged();
	end
end

function PlumberSuperTrackingMixin:OnClampedChanged()
	if self.isClamped then
		if self.keepTitle then
			self.Title:SetAlpha(ALPHA_CLAMPED_TIMER);
		end
		self:TransitToTimer(false);
		self:ShowTimer();
	else
		if self.hasTimer and self.waypointName then
			self.Title:SetText(self.waypointName);
			self:TransitToTimer(true);
		end
	end

	self:UpdateTitleVisibility();
end

do
	local navStateToTargetAlpha =
	{
		[Enum.NavigationState.Invalid] = 0.5,   --0		--state change to 0 within 70 yds
		[Enum.NavigationState.Occluded] = 0.6,  --1
		[Enum.NavigationState.InRange] = 1.0,   --2
		[Enum.NavigationState.Disabled] = 0.0,  --3
	};

	function PlumberSuperTrackingMixin:GetTargetAlphaBaseValue()
		local state = C_Navigation.GetTargetState();

		if self.distance then
			if self.distance < 8 then
				state = 3;
			elseif self.distance < 40 then
				state = 0;
			elseif self.distance < 80 then
				if state == 0 then
					state = 2;
				end
			end
		end

		local alpha = navStateToTargetAlpha[state];


		if alpha and alpha > 0 then
			if self.isClamped then
				return 1; -- Just to make the indicator easier to see
			end
		end

		return alpha;
	end

	function PlumberSuperTrackingMixin:GetTargetAlpha()
		if not C_Navigation.HasValidScreenPosition() then
			return 0;
		end

		local additionalFade = 1.0;

		if self:IsMouseOver() then
			local mouseX, mouseY = GetCursorPosition();
			local scale = UIParent:GetEffectiveScale();
			mouseX = mouseX / scale
			mouseY = mouseY / scale;
			local centerX, centerY = self:GetCenter();
			self.mouseToNavVec:SetXY(mouseX - centerX, mouseY - centerY);
			local mouseToNavDistanceSq = self.mouseToNavVec:GetLengthSquared();
			additionalFade = ClampedPercentageBetween(mouseToNavDistanceSq, 0, self.navFrameRadiusSq * 2);
			if additionalFade < 0.2 then
				additionalFade = 0.2;
			end
		end

		return FrameDeltaLerp(self:GetAlpha(), self:GetTargetAlphaBaseValue() * additionalFade, 0.1);
	end

	function PlumberSuperTrackingMixin:SetTargetAlphaForState(state, alpha)
		navStateToTargetAlpha[state] = alpha;
	end

	function PlumberSuperTrackingMixin:UpdateAlpha()
		self:SetAlpha(self:GetTargetAlpha());
	end
end

do	--Menu
	local ContextMenu;

	local function ChangePriority_NewSeeds()
		API.DreamseedUtil:SetNavigatorPrioritizingReward(false);
		LOCK_TO_USER_WAYPOINT = true;
		MainFrame:SetManualMode(false);

		return true	--Auto-close
	end

	local function ChangePriority_CollecRewards()
		API.DreamseedUtil:SetNavigatorPrioritizingReward(true);
		LOCK_TO_USER_WAYPOINT = true;
		MainFrame:SetManualMode(false);

		return true
	end

	local function TrackingSeedSwitch_OnClick()
		LOCK_TO_USER_WAYPOINT = false;
		MainFrame:SetManualMode(true);

		return true
	end

	local function StopTracking_OnClick()
		MainFrame:EnableSuperTracking(false);
		PlumberDB.Navigator_MasterSwitch = false;
		return true
	end

	local warningColor = { API.GetColorByName("WarningRed") };

	local ContextMenuData = {
		{text = L["Priority"], type = "title"},
		{text = L["Priority New Seeds"], level = 1, type = "radio", onClickFunc = ChangePriority_NewSeeds,},
		{text = L["Priority Rewards"], level = 1, type = "radio", onClickFunc = ChangePriority_CollecRewards},
		{text = L["Priority Default"], level = 1, type = "radio", onClickFunc = TrackingSeedSwitch_OnClick, tooltip = L["Priority Default Tooltip"]},

		{type = "divider"},

		{text = L["Stop Tracking"], color = warningColor, onClickFunc = StopTracking_OnClick, tooltip = L["Stop Tracking Dreamseed Tooltip"]},
	};

	function PlumberSuperTrackingMixin:ToggleMenu()
		if not ContextMenu then
			ContextMenu = addon.GetSharedContextMenu();
		end
		local menu = ContextMenu;
		if menu:IsShown() then
			menu:CloseMenu();
			return
		end

		local rewardFirst = API.DreamseedUtil:IsNavigatorPrioritizingReward();
		local questFirst = not LOCK_TO_USER_WAYPOINT or (self:IsManualMode());
		local selectedButtonIndex;

		if questFirst then
			selectedButtonIndex = 3;
		elseif rewardFirst then
			selectedButtonIndex = 2;
		else
			selectedButtonIndex = 1;
		end
		selectedButtonIndex = selectedButtonIndex + 1;

		for i = 2, 4 do
			ContextMenuData[i].selected = i == selectedButtonIndex;
		end

		local cursorX, cursorY = API.GetScaledCursorPosition();
		menu:SetOwner(self.Icon);
		menu:ClearAllPoints();
		menu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", cursorX + 8, cursorY);

		local forceUpdate = true;
		menu:SetContent(ContextMenuData, forceUpdate);

		menu:Show();
	end
end

do
	local UP_VECTOR = CreateVector2D(0, 1);
	local RIGHT_VECTOR = CreateVector2D(1, 0);

	local function GetCenterScreenPoint()
		local centerX, centerY = WorldFrame:GetCenter();
		local scale = UIParent:GetEffectiveScale() or 1;
		return centerX / scale, centerY / scale;
	end

	function PlumberSuperTrackingMixin:UpdateArrow()
		if self.isClamped then
			local centerScreenX, centerScreenY = GetCenterScreenPoint();
			local indicatorX, indicatorY = self:GetCenter();

			local indicatorVec = self.indicatorVec;
			indicatorVec:SetXY(indicatorX - centerScreenX, indicatorY - centerScreenY);

			local angle = Vector2D_CalculateAngleBetween(indicatorVec.x, indicatorVec.y, UP_VECTOR.x, UP_VECTOR.y);
			--self.Arrow:SetRotation(-angle);

			local toArrowX, toArrowY = Vector2D_Normalize(indicatorVec.x, indicatorVec.y);
			self.Arrow:SetPoint("CENTER", self, "CENTER", toArrowX * self.navFrameRadius, toArrowY * self.navFrameRadius);

			self:SetArrowAngle(angle);
		end

		self.Arrow:SetShown(self.isClamped);
	end

	function PlumberSuperTrackingMixin:ClampCircular()
		local centerX, centerY = GetCenterScreenPoint();
		local navX, navY = self.navFrame:GetCenter();
		local v = self.circularVec;
		v:SetXY(navX - centerX, navY - centerY);
		v:Normalize();
		v:ScaleBy(self.clampRadius);
		self:SetPoint("CENTER", WorldFrame, "CENTER", v.x, v.y);
	end

	function PlumberSuperTrackingMixin:ClampElliptical()
		local centerX, centerY = GetCenterScreenPoint();
		local navX, navY = self.navFrame:GetCenter();

		-- This is the point we want to find the intersection, translated to origin
		local pX = navX - centerX;
		local pY = navY - centerY;
		local denominator = sqrt(self.majorAxisSquared * pY * pY + self.minorAxisSquared * pX * pX);

		if denominator ~= 0 then
			local ratio = self.axesMultiplied / denominator;
			local intersectionX = pX * ratio;
			local intersectionY = pY * ratio;

			self:SetPoint("CENTER", WorldFrame, "CENTER", intersectionX, intersectionY);
		end
	end

	function PlumberSuperTrackingMixin:UpdatePosition()
		if self.isClamped or self.clampedChanged then
			self:ClearAllPoints();

			if self.isClamped then
				if self.clampMode == 0 then
					self:ClampCircular();
				else
					self:ClampElliptical();
				end
				self.useInterpolation = false;
			else
				--self:SetPoint("CENTER", self.navFrame, "CENTER");
				if self.clampedChanged then
					self.interpolatedTargetX, self.interpolatedTargetY = self:GetCenter();
					self.useInterpolation = true;
					self.targetInterpolationAmount = 0.05;
				else
					self.useInterpolation = false;
				end
			end
		end
	end

	function PlumberSuperTrackingMixin:UpdateInterpolation(elapsed)
		if self.useInterpolation then
			local targetX, targetY = self.navFrame:GetCenter();
			self.targetInterpolationAmount = self.targetInterpolationAmount + 0.65*elapsed;
			if self.targetInterpolationAmount >= 1 then
				self.targetInterpolationAmount = 1;
				self.useInterpolation = false;
			end

			self.interpolatedTargetX = InterpolateDimension(self.interpolatedTargetX, targetX, self.targetInterpolationAmount, elapsed);	--targetInterpolationAmount: 0.15
			self.interpolatedTargetY = InterpolateDimension(self.interpolatedTargetY, targetY, self.targetInterpolationAmount, elapsed);
			self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", self.interpolatedTargetX, self.interpolatedTargetY);

			if self.useInterpolation then
				local diffX = targetX - self.interpolatedTargetX;
				local diffY = targetY - self.interpolatedTargetY;
				local diff = diffX*diffX + diffY*diffY;
				if diff <= 0.5 then
					self.useInterpolation = false;
				end
			end
		else
			if not self.isClamped then
				if self.clampedChanged then
					self:ClearAllPoints();
				end
				self:SetPoint("CENTER", self.navFrame, "CENTER");
			end
		end
	end
end

local function GetDistanceString(distance)
	if distance < 9000 then --1000
		return tostring(distance);
	else
		return AbbreviateNumbers(distance);
	end
end

function PlumberSuperTrackingMixin:UpdateDistance()
	if not self.isClamped then
		local distance = Round(C_Navigation.GetDistance());

		if self.distance ~= distance then
			self.DistanceText:SetText(FORMAT_RANGE:format(GetDistanceString(distance)));
			self.distance = distance;
		end

		if self.requestUpdate then
			if self.lastDistance and distance then
				local distanceDiff = self.lastDistance - distance;
				if distanceDiff > 100 then	--after chaning waypoint
					distanceDiff = 0;
				end
				self.speed = distanceDiff;	--distanceDiff/1
			else
				self.speed = 0;
			end
			self.lastDistance = distance;

			if self.speed and self.speed > 0 and distance > 40 then
				local seconds = distance / self.speed;
				if seconds < 300 then
					local eta = SecondsToClock(seconds);
					self.ETAText:SetText(eta);
				else
					self.ETAText:SetText(nil);
				end
			else
				self.ETAText:SetText(nil);
			end
		end
	end

	self.DistanceText:SetShown(not self.isClamped);
	self.ETAText:SetShown(not self.isClamped);
end

function PlumberSuperTrackingMixin:UpdateIconSize()
	self.navFrameRadius = 32;	--math.max(self.Icon:GetSize())
	self.navFrameRadiusSq = self.navFrameRadius * self.navFrameRadius;
end

function PlumberSuperTrackingMixin:UpdateTimer()
	--called every second

	if self.hasTimer and self.remainingSeconds and self.remainingSeconds >= 1 then
		self.keepTitle = true;
		self.remainingSeconds = self.remainingSeconds - 1;
		local clock = SecondsToClock(self.remainingSeconds);
		if self.pauseTimer then
			return
		end
		self.Title:SetText(clock);
	else
		self.keepTitle = false;
	end
end

local ICON_NAME_LOOKUP = {
	[0] = "Quest",		--Quest		Navigation-Tracked-Icon
	[1] = "Waypoint",	--Content	Waypoint-MapPin-Tracked
	--UserWaypoint
	[2] = "Corpse",		--Corpse	Navigation-Tombstone-Icon
	[3] = "Waypoint",	--Scenario	
	[4] = "Waypoint",	--Content	Waypoint-MapPin-Tracked
};


function PlumberSuperTrackingMixin:SetIconTexture(iconName)
	if iconName then
		self.Icon:SetTexture("Interface/AddOns/Plumber/Art/SuperTracking/"..iconName..".png");
	else
		self.Icon:SetAtlas("Navigation-Tracked-Icon", true);
	end
end

function PlumberSuperTrackingMixin:UpdateIcon(setByPlumber)
	--local superTrackingType = C_SuperTrack.GetHighestPrioritySuperTrackingType() or Enum.SuperTrackingType.Quest;
	--local atlas = iconLookup[superTrackingType] or "Navigation-Tracked-Icon";
	--self.Icon:SetAtlas(atlas, true);
	--print("superTrackingType", self.superTrackingType)
	if self.superTrackingType and (not setByPlumber) and ICON_NAME_LOOKUP[self.superTrackingType] then
		self:SetIconTexture(ICON_NAME_LOOKUP[self.superTrackingType]);
	end

	self:UpdateIconSize();
end

function PlumberSuperTrackingMixin:InitializeNavigationFrame()
	self.navFrame = C_Navigation.GetFrame();
	self:SetShown(self.navFrame ~= nil);

	if self.navFrame then
		self:SetPoint("CENTER", self.navFrame);
		self:UpdateIcon();

		--0:Circular  1: Elliptical
		self.clampMode = 1;

		-- Circular
		self.clampRadius = 350;

		-- Elliptical
		self:SetEllipticalRadii(320, 180);	--500, 200
	end
end

function PlumberSuperTrackingMixin:SetEllipticalRadii(major, minor)
	self.majorAxis = major;
	self.minorAxis = minor;
	self.majorAxisSquared = self.majorAxis * self.majorAxis;
	self.minorAxisSquared = self.minorAxis * self.minorAxis;
	self.axesMultiplied = self.majorAxis * self.minorAxis;
end

function PlumberSuperTrackingMixin:CheckInitializeNavigationFrame()
	if not self.navFrame then
		self:InitializeNavigationFrame();
		self.frameReady = true;
	end
end

function PlumberSuperTrackingMixin:ShutdownNavigationFrame()
	self:ClearAllPoints();
	self.navFrame = nil;
	self:MonitorClicks(false);
end


local function UpdateFrame_OnUpdate_FadeIn(self, elapsed)
	self.alpha = self.alpha + 4*elapsed;
	if self.alpha >= 1 then
		self.alpha = 1;
		self:SetScript("OnUpdate", nil);
		if self.callback then
			self.callback(self);
		end
	end
	self.object:SetAlpha(self.alpha);
end

local function UpdateFrame_OnUpdate_FadeOut(self, elapsed)
	self.alpha = self.alpha - 4*elapsed;
	local alpha = self.alpha;

	if alpha > 1 then
		alpha = 1;
	end

	if alpha <= 0 then
		self.alpha = 0;
		alpha = 0;
		self:SetScript("OnUpdate", nil);
		if self.callback then
			self.callback(self);
		end
	end
	self.object:SetAlpha(alpha);
end

local function ResumeTimer()
	MainFrame.pauseTimer = false;
end

function PlumberSuperTrackingMixin:ShowTimer()
	if MainFrame.hasTimer and MainFrame.remainingSeconds and MainFrame.remainingSeconds >= 1 then
		local clock = SecondsToClock(MainFrame.remainingSeconds);
		MainFrame.Title:SetText(clock);
	end
end

local function TitleTimer_FadeOut_Callback()
	MainFrame:ShowTimer();
	MainFrame.Title:SetAlpha(0);
	UpdateFrame.object = MainFrame.Title;
	UpdateFrame.alpha = 0;
	UpdateFrame.callback = ResumeTimer;
	UpdateFrame:SetScript("OnUpdate", UpdateFrame_OnUpdate_FadeIn);
end


function PlumberSuperTrackingMixin:TransitToTimer(state)
	if state then
		self.pauseTimer = true;
		UpdateFrame.object = self.Title;
		UpdateFrame.alpha = self.Title:GetAlpha() + 4;	--Keep name for 1 second
		UpdateFrame.callback = TitleTimer_FadeOut_Callback;
		UpdateFrame:SetScript("OnUpdate", UpdateFrame_OnUpdate_FadeOut);
	else
		self.pauseTimer = false;
		UpdateFrame:SetScript("OnUpdate", nil);
	end
end

function PlumberSuperTrackingMixin:UpdateTitleVisibility()
	if self.useTitle then
		if self.isClamped then
			if self.keepTitle then
				self.Title:Show();
			else
				self.Title:Hide();
			end
		else
			self.Title:Show();
		end
	else
		self.Title:Hide();
	end
end

local PreviousPoint;

function PlumberSuperTrackingMixin:SetTarget(name, uiMapID, x, y, iconName)
	if not (self.enabled and self.frameReady) then return end;

    local point = {
        uiMapID = uiMapID,
        position = CreateVector2D(x, y);
    };

	self.setByPlumber = true
	--[[
	if PreviousPoint then
		if PreviousPoint.position:IsEqualTo(point.position) then
			self.setByPlumber = true;
		end
	end
	--]]

    SetUserWaypoint(point);
    SetSuperTrackedUserWaypoint(true);

	if name ~= self.waypointName then
		self.waypointName = name;
		self.Title:SetText(name);
		UpdateFrame:SetScript("OnUpdate", nil);
		if self.hasTimer and not self.isClamped then
			self:TransitToTimer(true);
		end
	end

	self:SetIconTexture(iconName);
	self.hasTimer = false;
	self.remainingSeconds = nil;
end

function PlumberSuperTrackingMixin:SetTimerTarget(name, uiMapID, x, y, iconName, hasTimer, remainingSeconds)
	--Show Name on the Title first, then replace it with a timer
	self:SetTarget(name, uiMapID, x, y, iconName);
	self.hasTimer = hasTimer;
	self.remainingSeconds = remainingSeconds;

	if not hasTimer then
		self:TransitToTimer(false);
		self.pauseTimer = false;
		self.keepTitle = false;
		self.Title:SetAlpha(1);
	end

	if (not self.isClamped) or self.keepTitle then
		if self.keepTitle and self.isClamped then
			self.Title:SetAlpha(ALPHA_CLAMPED_TIMER);
		end
	end

	self:UpdateTitleVisibility();
end

function PlumberSuperTrackingMixin:OnQuestAccepted(questID)
	self.setByPlumber = false;

	if LOCK_TO_USER_WAYPOINT or (questID and C_QuestLog.IsWorldQuest(questID)) then
		SetSuperTrackedUserWaypoint(true);
	end
end

function PlumberSuperTrackingMixin:SetUseTitle(useTitle)
	if useTitle ~= self.useTitle then
		self.useTitle = useTitle;
		self.DistanceText:ClearAllPoints();
		if useTitle then
			self.DistanceText:SetPoint("TOP", self.Title, "BOTTOM", 0, -2);
		else
			self.keepTitle = false;
			self.hasTimer = false;
			self.DistanceText:SetPoint("TOP", self.Icon, "BOTTOM", 0, 0);
			self:TransitToTimer(false);
		end

		self:UpdateTitleVisibility();
	end
end

function PlumberSuperTrackingMixin:SetManualMode(isUserInput)
	--SuperTrack changed by player manually
	self.isUserInput = isUserInput;
	if isUserInput then
		self:SetUseTitle(false);
		self.Title:SetText(nil);
		self.waypointName = nil;
		SetSuperTrackedUserWaypoint(false);
		PreviousPoint = nil;
	else
		self:SetUseTitle(true);
	end
end

function PlumberSuperTrackingMixin:IsManualMode()
	return self.isUserInput or false
end

function PlumberSuperTrackingMixin:CanReceiveDataFromNavigator()
	return self.enabled and not self:IsManualMode()
end


function PlumberSuperTrackingMixin:MonitorClicks(state)
	if state then
		self:RegisterEvent("GLOBAL_MOUSE_DOWN");
		self:RegisterEvent("GLOBAL_MOUSE_UP");
	else
		self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
		self:UnregisterEvent("GLOBAL_MOUSE_UP");
	end
end

function PlumberSuperTrackingMixin:OnSuperTrackingChanged()
	local superTrackingType = C_SuperTrack.GetHighestPrioritySuperTrackingType();
	self.superTrackingType = superTrackingType;


	local isSetByPlumber = self.setByPlumber;
	self.setByPlumber = false;

	if isSetByPlumber then
		self:SetManualMode(false);
		--print("Changed by Plumber", superTrackingType);
	else
		self:SetManualMode(true);
		--print("Not by", superTrackingType);
	end

	if C_SuperTrack.IsSuperTrackingAnything() then
		self:MonitorClicks(true);
	else
		self:SetManualMode(false);
		self:MonitorClicks(false);
	end

	self:UpdateIcon(isSetByPlumber);
end