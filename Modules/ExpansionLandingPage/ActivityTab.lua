local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;
local LandingPageUtil = addon.LandingPageUtil; ---@class LandingPageUtil
local ActivityUtil = addon.ActivityUtil;
local TooltipUpdator = LandingPageUtil.TooltipUpdator;


local ipairs = ipairs;
local ReadyForTurnIn = API.IsQuestReadyForTurnIn;


local ActivityTab;
local SortedActivityData;


local CreateChecklistButton;
do  --Checklist Button
	local ChecklistButtonMixin = {};

	function ChecklistButtonMixin:OnEnter()
		self:UpdateVisual();
		self:DisplayTooltip();
	end

	function ChecklistButtonMixin:OnLeave()
		self:UpdateVisual();
		TooltipUpdator:StopUpdating();
		GameTooltip:Hide();
	end

	function ChecklistButtonMixin:OnClick()
		if self.isHeader then
			local isCollapsed = self:ToggleCollapsed();
			if isCollapsed then
				LandingPageUtil.PlayUISound("CheckboxOff");
			else
				LandingPageUtil.PlayUISound("CheckboxOn");
			end
		else
			local data = self:GetData();
			if data then
				--[[    --Disabled because the API cause errors
				if data.openMap then
					local questID = data.questID or (self.type == "Quest" and self.id);
					local mapID = questID and GetQuestUiMapID(questID);
					if mapID and not InCombatLockdown() then
						C_Map.OpenWorldMap(mapID);
					end
				end
				--]]
			end
		end
	end

	function ChecklistButtonMixin:GetData()
		return self.dataIndex and ActivityUtil.GetActivityData(self.dataIndex);
	end

	function ChecklistButtonMixin:SetActivity(dataIndex, data)
		if not data then
			data = ActivityUtil.GetActivityData(dataIndex);
		end

		if data then
			self.completed = data.completed;
			self.flagQuest = data.flagQuest or data.questID;
			self.conditions = data.conditions;
			self.Icon:Show();

			if self.completed and not self.isInManageMode then
				self.Icon:SetAtlas("checkmark-minimal-disabled");
			elseif data.icon then
				if data.itemID or data.removeIconBorder then
					self.Icon:SetTexCoord(6/64, 58/64, 6/64, 58/64);
				else
					self.Icon:SetTexCoord(0, 1, 0, 1);
				end
				self.Icon:SetTexture(data.icon);
			elseif data.atlas then
				self.Icon:SetAtlas(data.atlas);
			else
				if not self.isHeader then
					self.Icon:SetAtlas("questlog-questtypeicon-quest"); --debug
				end
			end

			if data.questID then
				self:SetQuest(data.questID);
			elseif data.itemID then
				self:SetItem(data.itemID, data.shownIfOwned);
			elseif data.currencyID then
				self:SetCurrency(data.currencyID);
			else
				self.type = nil;
				self.id = nil;
				if data.setupFunc then
					data.setupFunc(self);
				else
					self.Name:SetText(ActivityUtil.GetActivityName(dataIndex));
				end
			end

			self:UpdateProgress();

			self.Glow:SetShown(data.showGlow);

			self:Layout();
		end
	end

	function ChecklistButtonMixin:UpdateProgress(updateCompletion)
		if self.isInManageMode then
			self:UpdateVisual();
			return;
		end

		self.readyForTurnIn = nil;
		if self.flagQuest then
			self.readyForTurnIn = ReadyForTurnIn(self.flagQuest);
			if self.readyForTurnIn then
				self.Icon:SetAtlas("QuestTurnin");
			else
				if updateCompletion then
					local completed = ActivityUtil.UpdateAndGetProgress(self.dataIndex);
					if completed ~= self.completed then
						self.completed = true;
						self.Icon:SetAtlas("checkmark-minimal-disabled");
						ActivityTab:RequestUpdate(true);
					end
				end
			end
		elseif self.conditions then
			if self.conditions.IsReadyForTurnIn then
				local arg = self.conditions.useItemName and self.Name:GetText() or self.id;
				self.readyForTurnIn = self.conditions.IsReadyForTurnIn(arg);
			end
		end

		if self.type == "Quest" then
			if self.readyForTurnIn then
				self.Text1:SetText(nil);
			else
				local percentText = API.GetQuestProgressPercent(self.id, true);
				self.Text1:SetText(percentText);
			end
		elseif self.type == "Currency" then
			local earned, max = API.GetCurrencyEarnedAndCap(self.id);
			if earned and max and earned < max then
				--self.Text1:SetText(string.format("%s/%s", earned, max));
				self.Text1:SetText(math.floor(100 * earned / max).."%");
				self.completed = false;
			else
				self.Text1:SetText(nil);
				self.completed = true;
			end
		else
			self.Text1:SetText(nil);
		end

		if self.isInManageMode then
			self.completed = false;
		end

		self:UpdateVisual();
	end

	if addon.IS_MISTS then
		--Classic
		local DailyUtil = addon.DailyUtil;

		function ChecklistButtonMixin:SetQuest(questID)
			self.type = "Quest";
			self.id = questID;

			self.Text1:SetText(nil);

			local name = DailyUtil.GetQuestTitle(questID) or ActivityUtil.GetActivityName(self.dataIndex, questID);
			self.Name:SetText(name);
			if not name then
				CallbackRegistry:LoadQuest(questID, function(_questID)
					if questID == self.id then
						local _name = DailyUtil.GetQuestTitle(_questID);
						self.Name:SetText(_name);
						self:UpdateProgress();
						if self:IsMouseMotionFocus() then
							self:OnEnter();
						end
					end
				end);
			end
		end
	else
		--Retail
		function ChecklistButtonMixin:SetQuest(questID)
			self.type = "Quest";
			self.id = questID;

			self.Text1:SetText(nil);

			local name, isLocalized = ActivityUtil.GetActivityName(self.dataIndex, questID);
			self.Name:SetText(name);
			if not isLocalized then
				CallbackRegistry:LoadQuest(questID, function(_questID)
					if questID == self.id then
						local _name = API.GetQuestName(_questID);
						ActivityUtil.StoreQuestActivityName(_questID, _name);
						self.Name:SetText(_name);
						self:UpdateProgress();
						if self:IsMouseMotionFocus() then
							self:OnEnter();
						end
					end
				end);
			end
		end
	end

	local function PrependItemCount(itemID, itemName)
		if itemName then
			local count = C_Item.GetItemCount(itemID);
			if count then
				return count.." "..itemName;
			end
		end
		return itemName
	end

	function ChecklistButtonMixin:SetItem(itemID, showItemCount)
		self.type = "Item";
		self.id = itemID;
		self.showItemCount = showItemCount;

		self.Text1:SetText(nil);

		local name, isLocalized = ActivityUtil.GetActivityName(self.dataIndex);

		if name and showItemCount then
			name = PrependItemCount(itemID, name);
		end

		self.Name:SetText(name);
		if not isLocalized then
			CallbackRegistry:LoadItem(itemID, function(_itemID)
				if _itemID == self.itemID then
					local _name = C_Item.GetItemNameByID(_itemID);
					ActivityUtil.StoreItemActivityName(_itemID, _name);
					if showItemCount then
						_name = PrependItemCount(itemID, _name);
					end
					self.Name:SetText(_name);
					self:UpdateProgress();
				end
			end);
		end
	end

	function ChecklistButtonMixin:SetCurrency(currencyID)
		self.type = "Currency";
		self.id = currencyID;
		local name, isLocalized = ActivityUtil.GetActivityName(self.dataIndex);
		self.Name:SetText(name);
	end

	function ChecklistButtonMixin:ToggleCollapsed()
		local v = self.dataIndex;
		if v then
			local isCollapsed = ActivityUtil.ToggleCollapsed(v);
			ActivityTab:FullUpdate();
			return isCollapsed
		end
	end

	function ChecklistButtonMixin:DisplayTooltip()
		local shouldShowTooltip;

		if self.type == "Quest" and self.id then
			shouldShowTooltip = true;
			TooltipUpdator:SetFocusedObject(self);
			local data = self:GetData();
			if data and data.useActiveQuestTitle then
				TooltipUpdator:SetHeaderText(API.GetQuestName(self.id));
			else
				TooltipUpdator:SetHeaderText(self.Name:GetText());
			end
			TooltipUpdator:SetQuestID(self.id);
			TooltipUpdator:RequestQuestProgress();
			if not self.completed then
				TooltipUpdator:RequestQuestReward();
			end
			if data then
				TooltipUpdator:RequestTooltipSetter(data.tooltipSetter);
			end
		elseif self.type == "Currency" and self.id then
			shouldShowTooltip = true;
			TooltipUpdator:SetFocusedObject(self);
			TooltipUpdator:SetHeaderText(API.GetCurrencyName(self.id));
			TooltipUpdator:SetCurrencyID(self.id);
			local data = self:GetData();
			if data then
				TooltipUpdator:RequestTooltipSetter(data.tooltipSetter);
			end
		else
			local data = self:GetData();
			if data then
				if data.tooltip or data.children or data.tooltipSetter or data.tooltipItem then
					shouldShowTooltip = true;
					TooltipUpdator:SetFocusedObject(self);
					TooltipUpdator:SetHeaderText(data.tooltipHeader or self.Name:GetText());
					local tooltipLines = {};

					if data.children and data.addChildrenToTooltip then
						TooltipUpdator:RequestEntryChildren(data.children);
					else
						if data.completed then
							table.insert(tooltipLines, string.format("|cff808080%s|r", L["Completed"]));
							table.insert(tooltipLines, " ");
						end
					end

					if data.tooltip then
						table.insert(tooltipLines, data.tooltip);
					end

					if data.accountwide then
						table.insert(tooltipLines, " ");
						table.insert(tooltipLines, string.format("|cff00ccff%s|r", L["Warband Weekly Reward Tooltip"]));
					end

					TooltipUpdator:RequestTooltipLines(tooltipLines);
					TooltipUpdator:RequestTooltipSetter(data.tooltipSetter);
					TooltipUpdator:RequestItemID(data.tooltipItem);
				end
			end
		end

		if shouldShowTooltip and ActivityUtil.IsInManageMode() then
			TooltipUpdator:RequestExtraInfoForManageMode(self:GetData());
		end
	end

	function ChecklistButtonMixin:UpdateLocationHighlight()
		local data = self:GetData();
		self.Glow:SetShown(data and data.showGlow);
	end

	function ChecklistButtonMixin:UpdateIgnoredState()
		local data = self:GetData();
		if ActivityUtil.IsEntryIgnored(data) then
			if self.EyeButton then
				self.EyeButton:CloseEye();
			end
			self:SetAlpha(0.5);
		else
			if self.EyeButton then
				self.EyeButton:OpenEye();
			end
			self:SetAlpha(1);
		end
	end

	function ChecklistButtonMixin:ToggleEntryIgnored()
		local data = self:GetData();
		if data then
			ActivityUtil.ToggleEntryIgnored(data);
			self:UpdateIgnoredState();
		end
	end

	function CreateChecklistButton(parent)
		local f = LandingPageUtil.CreateSharedListButton(parent);

		API.Mixin(f, ChecklistButtonMixin);
		f:SetScript("OnEnter", f.OnEnter);
		f:SetScript("OnLeave", f.OnLeave);
		f:SetScript("OnClick", f.OnClick);

		return f
	end
end


local ActivityTabMixin = {};
do
	local DynamicEvents = {
		"QUEST_LOG_UPDATE",
		"QUEST_REMOVED",
		"QUEST_ACCEPTED",
		"QUEST_TURNED_IN",
		--"LOOT_CLOSED",       --Looting some items triggers hidden quest flag, but the quest events don't fire
		"ZONE_CHANGED_NEW_AREA",
		"BAG_UPDATE_DELAYED",
	};

	local OptionalEvents = {
		--For Classic
		"QUESTLINE_UPDATE",
	};

	for _, event in ipairs(OptionalEvents) do
		if C_EventUtils.IsEventValid(event) then
			table.insert(DynamicEvents, event);
		end
	end

	function ActivityTabMixin:FullUpdate(resetScrollOffset)
		self.fullUpdate = nil;

		local uiMapID = API.GetPlayerMap();
		self.uiMapID = uiMapID;

		local content = {};
		local n = 0;
		local buttonHeight = 24;
		local gap = 4;
		local offsetY = 2;

		local entryWidth = 544;
		local headerWidth = entryWidth + 62;

		local top, bottom;
		local showActivity, showGroup;
		local numCompleted, numIgnored;
		local inManageMode = ActivityUtil.IsInManageMode();

		SortedActivityData, numCompleted, numIgnored = ActivityUtil.GetSortedActivity();

		for k, v in ipairs(SortedActivityData) do
			if v.isHeader then
				showActivity = true;
				showGroup = not v.isCollapsed;
			else
				showActivity = showGroup;
			end

			if showActivity then
				n = n + 1;
				local isOdd = n % 2 == 1;
				top = offsetY;
				bottom = offsetY + buttonHeight + gap;

				if v.uiMapID then
					v.showGlow = (not v.isHeader) and (not v.completed) and (v.uiMapID == uiMapID);
				else
					v.showGlow = false;
				end

				content[n] = {
					templateKey = "ChecklistButton",
					setupFunc = function(obj)
						obj.dataIndex = v.dataIndex;
						obj.isOdd = isOdd;
						obj.isInManageMode = inManageMode or nil;
						if v.isHeader then
							obj:SetWidth(headerWidth);
							obj.isCollapsed = v.isCollapsed;
							obj:SetHeader();
							obj:ShowEyeButton(false);
						else
							obj:SetWidth(entryWidth);
							obj:SetEntry();
							obj:ShowEyeButton(inManageMode);
						end
						obj:SetActivity(v.dataIndex, v);
						if inManageMode then
							obj:UpdateIgnoredState();
						end
					end,
					top = top,
					bottom = bottom,
				};
				offsetY = bottom;
			end
		end

		local retainPosition = not resetScrollOffset;
		self.ScrollView:SetContent(content, retainPosition);

		self.Checkbox_HideCompleted:SetFormattedText(numCompleted);

		if self.ManageSwitch then
			self.ManageSwitch.numIgnored = numIgnored;
		end
	end

	function ActivityTabMixin:OnShow()
		self:FullUpdate();
		API.RegisterFrameForEvents(self, DynamicEvents);
		self:SetScript("OnEvent", self.OnEvent);
	end

	function ActivityTabMixin:OnHide()
		self.t = nil;
		self:SetScript("OnUpdate", nil);
		API.UnregisterFrameForEvents(self, DynamicEvents);
		self:SetScript("OnEvent", nil);
		self:StopAnimating();
	end

	function ActivityTabMixin:OnEvent(event, ...)
		if event == "QUEST_LOG_UPDATE" then
			self:RequestUpdate();
		elseif event == "QUEST_REMOVED" or event == "QUEST_ACCEPTED" or event == "QUEST_TURNED_IN" or event == "QUESTLINE_UPDATE" or event == "UPDATE_FACTION" or event == "BAG_UPDATE_DELAYED" then
			self:RequestUpdate(true);
		elseif event == "ZONE_CHANGED_NEW_AREA" then
			self:UpdateMap(true);
		end
	end

	function ActivityTabMixin:InitChecklist()
		local headerWidgetOffsetY = -10;


		local Checkbox_HideCompleted = LandingPageUtil.CreateCheckboxButton(self);
		self.Checkbox_HideCompleted = Checkbox_HideCompleted;
		Checkbox_HideCompleted:SetPoint("TOPRIGHT", self, "TOPRIGHT", -52, headerWidgetOffsetY);
		Checkbox_HideCompleted:SetText(L["Filter Hide Completed Format"], true);
		Checkbox_HideCompleted.dbKey = "LandingPage_Activity_HideCompleted";
		Checkbox_HideCompleted.textFormat = L["Filter Hide Completed Format"];
		Checkbox_HideCompleted:SetUseDarkYellowLabel(true);
		Checkbox_HideCompleted:UpdateChecked();
		addon.CallbackRegistry:RegisterSettingCallback("LandingPage_Activity_HideCompleted", self.SetHideCompleted, self);


		local ManageSwitch; -- ManageButton

		if ActivityUtil.IsManageModeSupported() then
			ManageSwitch = LandingPageUtil.CreateBasicIconTextButton(self);
			self.ManageSwitch = ManageSwitch;
			ManageSwitch:SetPoint("TOPLEFT", self, "TOPLEFT", 55, headerWidgetOffsetY);
			ManageSwitch:SetTexture(nil, 518/1024, 582/1024, 176/1024, 240/1024);
			ManageSwitch:SetText(L["Manage Activities Abbr"], true);
			ManageSwitch:EnableColorizeIcon(false);
			ManageSwitch:SetUseDarkYellowLabel(true);
			ManageSwitch:UpdateVisual();

			ManageSwitch:SetOnEnterFunc(function(widget)
				if not ActivityUtil.IsInManageMode() then
					GameTooltip:SetOwner(widget, "ANCHOR_RIGHT");
					LandingPageUtil.SetTooltip(L["Manage Activities"], L["Manage Activities Tooltip"]);
					if ManageSwitch.numIgnored and ManageSwitch.numIgnored > 0 then
						GameTooltip:AddLine(" ");
						GameTooltip:AddLine(string.format(L["Total Ignored Tooltip Format"], ManageSwitch.numIgnored), 0.5, 0.5, 0.5, true);
					end
					GameTooltip:Show();
				end
			end);

			ManageSwitch:SetOnClickFunc(function(widget, button)
				GameTooltip:Hide();
				self:ToggleManageMode();
				if widget:IsMouseMotionFocus() then
					widget:OnEnter();
				end
			end);
		end


		local WeeklyResetTimer = LandingPageUtil.CreateTimerFrame(self);
		self.WeeklyResetTimer = WeeklyResetTimer;
		if ManageSwitch then
			WeeklyResetTimer:SetPoint("LEFT", ManageSwitch, "RIGHT", 24, 0);
		else
			WeeklyResetTimer:SetPoint("TOPLEFT", self, "TOPLEFT", 58, headerWidgetOffsetY);
		end
		if addon.IS_MOP then
			WeeklyResetTimer:SetTimeGetter(C_DateAndTime.GetSecondsUntilDailyReset);
			WeeklyResetTimer:SetTimeTextFormat(L["Daily Reset Format"]);
			WeeklyResetTimer:SetLowThresholdAndColor(2*3600, "ffe24c45");
		else
			WeeklyResetTimer:SetTimeGetter(C_DateAndTime.GetSecondsUntilWeeklyReset);
			WeeklyResetTimer:SetTimeTextFormat(L["Weekly Reset Format"]);
			WeeklyResetTimer:SetLowThresholdAndColor(6*3600, "ffe24c45");
		end
		WeeklyResetTimer:SetDisplayStyle("FormattedText");
		WeeklyResetTimer:SetAutoStart(true);
		WeeklyResetTimer:SetShownThreshold(86400);
		WeeklyResetTimer:OnShow();


		local ScrollView = LandingPageUtil.CreateScrollViewForTab(self, -32);
		ScrollView:SetScrollBarOffsetY(-4);

		local function ChecklistButton_Create()
			return CreateChecklistButton(ScrollView)
		end

		local function ChecklistButton_OnAcquired(button)

		end

		local function ChecklistButton_OnRemoved(button)
			button.tooltipWidgetSet = nil;
			button:SetAlpha(1);
		end

		ScrollView:AddTemplate("ChecklistButton", ChecklistButton_Create, ChecklistButton_OnAcquired, ChecklistButton_OnRemoved);


		CallbackRegistry:Register("Classic.QuestLogged", self.RequestFullUpdateIfShown, self);
		CallbackRegistry:Register("activeAugustCelestial", self.RequestFullUpdateIfShown, self);


		CallbackRegistry:Register("LandingPage.ActivityManageMode", function(inManageMode)
			if not ManageSwitch then return; end
			if inManageMode then
				ManageSwitch:SetText(L["Save And Exit"], true);
				ManageSwitch:SetDefaultColor(0.098, 1.000, 0.098);
				ManageSwitch:SetTexture(nil, 582/1024, 646/1024, 176/1024, 240/1024);
			else
				ManageSwitch:SetText(L["Manage Activities Abbr"], true);
				ManageSwitch:ClearDefaultColor();
				ManageSwitch:SetTexture(nil, 518/1024, 582/1024, 176/1024, 240/1024);
			end
			WeeklyResetTimer:SetShown(not inManageMode);
			Checkbox_HideCompleted:SetShown(not inManageMode);
		end);
	end

	function ActivityTabMixin:UpdateScrollViewContent()
		if self.ScrollView then
			self.ScrollView:CallObjectMethod("ChecklistButton", "UpdateProgress", true);
		end
	end

	function ActivityTabMixin:RequestUpdate(fullUpdate)
		self.t = 0;
		self:SetScript("OnUpdate", self.OnUpdate);
		if fullUpdate then
			self.fullUpdate = true;
		end
	end

	function ActivityTabMixin:RequestFullUpdateIfShown()
		if self:IsVisible() then
			self:RequestUpdate(true);
		end
	end

	function ActivityTabMixin:UpdateMap(updateScrollView)
		local uiMapID = API.GetPlayerMap();
		if uiMapID ~= self.uiMapID then
			self.uiMapID = uiMapID;
			if SortedActivityData then
				for k, v in ipairs(SortedActivityData) do
					if v.uiMapID and v.uiMapID == uiMapID and (not v.isHeader) then
						v.showGlow = true;
					else
						v.showGlow = nil;
					end
				end
				if updateScrollView then
					self.ScrollView:CallObjectMethod("ChecklistButton", "UpdateLocationHighlight");
				end
			end
		end
	end

	function ActivityTabMixin:OnUpdate(elapsed)
		self.t = self.t + elapsed;
		if self.t >= 0.5 then
			self.t = nil;
			self:SetScript("OnUpdate", nil);
			if self.fullUpdate then
				self:FullUpdate();
			else
				self:UpdateScrollViewContent();
			end
		end
	end

	function ActivityTabMixin:SetHideCompleted(state)
		ActivityUtil.SetHideCompleted(state);
		self:FullUpdate();
	end

	function ActivityTabMixin:ToggleManageMode()
		local inManageMode = not ActivityUtil.IsInManageMode();
		ActivityUtil.SetManageMode(inManageMode);
		CallbackRegistry:Trigger("LandingPage.ActivityManageMode", inManageMode);
		if self:IsVisible() then
			self:FullUpdate(true);
		end
	end
end


local function CreateActivityTab(f)
	ActivityTab = f;
	API.Mixin(f, ActivityTabMixin);
	f:InitChecklist();

	f:SetScript("OnShow", f.OnShow);
	f:SetScript("OnHide", f.OnHide);
	f:SetScript("OnEvent", f.OnEvent);
end

LandingPageUtil.AddTab(
	{
		key = "activity",
		name = L["Activities"],
		uiOrder = 2,
		initFunc = CreateActivityTab,
		dimBackground = true,
	}
);

CallbackRegistry:Register("LandingPage.ExpansionChanged", function(expansionID)
	if ActivityTab and ActivityTab:IsVisible() then
		ActivityTab:FullUpdate();
	end
end);


do  --Debug
	local function Plumber_PrintWorldQuestsForMap(uiMapID)
		if not uiMapID and WorldMapFrame:IsShown() then
			uiMapID = WorldMapFrame:GetMapID();
		end
		if not uiMapID then
			uiMapID = C_Map.GetBestMapForUnit("player");
		end
		local quests = C_TaskQuest.GetQuestsOnMap(uiMapID);
		for _, v in ipairs(quests) do
			local name = C_TaskQuest.GetQuestInfoByQuestID(v.questID);
			print(v.questID, name);
		end
	end
end
