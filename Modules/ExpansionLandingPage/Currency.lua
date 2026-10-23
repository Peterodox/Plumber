local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;
local LandingPageUtil = addon.LandingPageUtil; ---@class LandingPageUtil

local ipairs = ipairs;
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
local GetItemIconByID = C_Item.GetItemIconByID;
local GetItemCount = C_Item.GetItemCount;
local GetItemNameByID = C_Item.GetItemNameByID;


local Def = {
	ButtonWidth = 240,
	ButtonHeight = 24,
	MiniEntryGap = 4,
	MiniEntrySidePadding = 12,
};

local ResourceList = {}; ---@type ResourceListEntry[]
local MainFrame;


local function GetResourcesQuantity(data)
	if data.currencyID then
		local info = GetCurrencyInfo(data.currencyID);
		return info and info.quantity or 0
	elseif data.itemID then
		return GetItemCount(data.itemID, true, false, true, true);
	end

	return 0
end

local CurrencyButtonMixin = {}; -- Name, Quantity, Icon
do
	function CurrencyButtonMixin:TrySetName(name)
		if self.Name then
			self.Name:SetText(name);
		end
	end

	function CurrencyButtonMixin:SetCurrency(currencyID, isMinor, appendTooltipFunc, hasWeeklyCap)
		self.currencyID = currencyID;
		self.itemID = nil;
		self.buttonDitry = true;
		self.appendTooltipFunc = appendTooltipFunc;
		self.hasWeeklyCap = hasWeeklyCap;
		self:Refresh();
		self:SetShownAsMinor(isMinor);
	end

	function CurrencyButtonMixin:SetItem(itemID, isMinor, appendTooltipFunc)
		self.currencyID = nil;
		self.itemID = itemID;
		self.buttonDitry = true;
		self.appendTooltipFunc = appendTooltipFunc;
		self.hasWeeklyCap = nil;
		self:Refresh();
		self:SetShownAsMinor(isMinor);
	end

	---Allow right-click to use an item via SAB
	---@param usableItemID number?
	---@param criteriaFunc function?
	function CurrencyButtonMixin:SetUsableAction(usableItemID, criteriaFunc)
		self.usableItemID = usableItemID;
		self.criteriaFunc = criteriaFunc;
	end

	function CurrencyButtonMixin:HasUsableAction()
		if self.usableItemID then
			return ((not self.criteriaFunc) or self.criteriaFunc()) and API.CanPlayerPerformAction("item", self.usableItemID);
		end
	end

	function CurrencyButtonMixin:Refresh()
		local quantity;
		local isOverflow;

		if self.currencyID then
			local info = GetCurrencyInfo(self.currencyID);
			if info then
				quantity = info.quantity;
				local totalEarned = info.totalEarned or 0;
				local maxQuantity = info.maxQuantity or 0;
				isOverflow = quantity > 0 and maxQuantity > 0 and (((maxQuantity - totalEarned) == 0) or (quantity >= maxQuantity))
				if self.buttonDitry then
					self.buttonDitry = nil;
					self:TrySetName(info.name)
					self.Icon:SetTexture(info.iconFileID);
				end
			else
				return false
			end
		elseif self.itemID then
			quantity = GetItemCount(self.itemID, true, false, true, true);
			if self.buttonDitry then
				self.buttonDitry = nil;
				self.Icon:SetTexture(GetItemIconByID(self.itemID));
				local itemName = GetItemNameByID(self.itemID);
				if itemName then
					self:TrySetName(itemName);
				else
					CallbackRegistry:LoadItem(self.itemID, function(itemID)
						if self.itemID == itemID then
							self:TrySetName(GetItemNameByID(self.itemID));
							self.Icon:SetTexture(GetItemIconByID(self.itemID));
						end
					end);
				end
			end
		else
			return false
		end

		if self:IsMouseMotionFocus() then
			self:OnEnter();
		end

		if quantity then
			if self.hasWeeklyCap and self.currencyID then
				if API.IsCurrencyFullyEarned(self.currencyID) then
					isOverflow = true;
				end
			end

			if quantity > 0 or isOverflow then
				self.anyOwned = true;
				if self.Name then
					self.Name:SetTextColor(0.922, 0.871, 0.761);
				end
				self:SetCount(quantity, isOverflow);
			else
				self.anyOwned = false;
				if self.Name then
					self.Name:SetTextColor(0.5, 0.5, 0.5);
				end
				self:SetCount(quantity);
			end

			return true
		else
			self.anyOwned = false;
			return false
		end
	end

	function CurrencyButtonMixin:SetShownAsMinor(isMinor)
		if self.Name then
			self.Name:SetPoint("LEFT", self, "LEFT", (isMinor and 22) or 8, 0);
		end
	end

	function CurrencyButtonMixin:SetupActionButton()
		-- Release the SAB so a previously acquired one doesn't stay usable after criteria are no longer met
		if not self:HasUsableAction() then
			self:ReleaseActionButton();
			return;
		end

		-- When entering combat, PlayerIsInCombat turns true earlier than InCombatLockdown
		-- We need this additional check so the tooltip will no longer show <...Use Item> on PLAYER_IN_COMBAT_CHANGED
		if PlayerIsInCombat() then return; end

		local propagateMouseMotion = true;
		local propagateMouseClick = true;
		local actionButton = addon.AcquireSecureActionButton("ExpansionLandingPage", propagateMouseMotion, propagateMouseClick);
		if actionButton then
			actionButton:SetParent(self);
			actionButton:CoverParent();
			actionButton:SetUseItem(self.usableItemID, "RightButton");
			actionButton:Show();
			return true
		end
	end

	function CurrencyButtonMixin:ReleaseActionButton()
		addon.HideSecureActionButton("ExpansionLandingPage");
	end

	function CurrencyButtonMixin:ShowTooltip()
		local tooltip = GameTooltip;

		if self.isMiniEntry then
			tooltip:SetOwner(self, "ANCHOR_RIGHT", -4, 0);
		elseif self.isManagerEntry then
			tooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
		else
			tooltip:SetOwner(self.Icon, "ANCHOR_RIGHT", 0, 0);
		end

		if self.currencyID then
			tooltip:SetCurrencyByID(self.currencyID);
		elseif self.itemID then
			tooltip:SetItemByID(self.itemID);
		end

		if tooltip.ProcessInfo and (self.appendTooltipFunc or self.contextualTooltipFunc) then
			local anyChanges;
			local info = API.CreateAppendTooltipInfo();

			if self.appendTooltipFunc then
				if self.appendTooltipFunc(info) then
					anyChanges = true;
				end
			end

			if self.contextualTooltipFunc then
				if self.contextualTooltipFunc(info) then
					anyChanges = true;
				end
			end

			if anyChanges then
				API.DisplayTooltipInfoOnTooltip(tooltip, info);
			end
		end
	end

	function CurrencyButtonMixin:OnEnter()
		self:UpdateVisual();
		self.UpdateTooltip = nil;
		self.contextualTooltipFunc = nil;

		if self:SetupActionButton() then
			local shouldRefreshTooltip;

			-- Show item name if the usable item is not the base item.
			-- Refresh the tooltip if the name is not received.
			if self.itemID ~= self.usableItemID then
				local itemName = API.GetColorizedItemName(self.usableItemID);
				if itemName then
					self.contextualTooltipFunc = function(tooltip)
						tooltip:AddLine(L["Instruction Right Click To Use Format"]:format(itemName), 0.098, 1.000, 0.098, true);
						return true;
					end
				else
					shouldRefreshTooltip = true;
				end
			end

			if not self.contextualTooltipFunc then
				self.contextualTooltipFunc = function(tooltip)
					tooltip:AddLine(L["Instruction Right Click To Use"], 0.098, 1.000, 0.098, true);
					return true
				end
			end

			if shouldRefreshTooltip then
				self.UpdateTooltip = self.OnEnter;
			end

			-- We don't show item cooldown or cast bar for now until we need it.
		end

		self:ShowTooltip();
	end

	function CurrencyButtonMixin:OnLeave()
		self:UpdateVisual();
		GameTooltip:Hide();
	end

	function CurrencyButtonMixin:OnClick()
		API.ToggleBlizzardTokenUIIfWarbandCurrency(self.currencyID);
	end

	function CurrencyButtonMixin:UpdateVisual()
		if self:IsMouseMotionFocus() then
			if self.Name then
				self.Name:SetTextColor(1, 1, 1);
			end
			self.Highlight:Show();
		else
			if self.Name then
				if self.anyOwned then
					self.Name:SetTextColor(0.922, 0.871, 0.761);
				else
					self.Name:SetTextColor(0.5, 0.5, 0.5);
				end
			end
			self.Highlight:Hide();
		end
	end
end

local function CreateStandardEntry(parent)
	local f = CreateFrame("Button", nil, parent, "PlumberStrikethroughNumberTemplate");
	f:SetSize(Def.ButtonWidth, Def.ButtonHeight);
	API.Mixin(f, CurrencyButtonMixin);

	f.Icon = f:CreateTexture(nil, "ARTWORK");
	f.Icon:SetSize(20, 20);
	f.Icon:SetPoint("RIGHT", f, "RIGHT", -8, 0);

	f.breakupLargeNumbers = true;
	f.Count:SetPoint("RIGHT", f, "RIGHT", -32, 0);
	f.Count:SetJustifyH("RIGHT");
	f.Count:SetTextColor(1, 1, 1);
	f.Count:SetText("0");

	f.Name = f:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	f.Name:SetPoint("LEFT", f, "LEFT", 8, 0);
	f.Name:SetPoint("RIGHT", f.Count, "LEFT", -20, 0);
	f.Name:SetJustifyH("LEFT");
	f.Name:SetTextColor(1, 1, 1);
	f.Name:SetMaxLines(1);

	f.Highlight = f:CreateTexture(nil, "BACKGROUND");
	f.Highlight:SetAllPoints(true);
	f.Highlight:Hide();
	f.Highlight:SetTextureSliceMode(1);
	local m = 8;
	f.Highlight:SetTextureSliceMargins(m, m, m, m);
	f.Highlight:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/SmallListButtonHighlight");
	f.Highlight:SetBlendMode("ADD");
	f.Highlight:SetAlpha(0.08);

	f:SetScript("OnEnter", f.OnEnter);
	f:SetScript("OnLeave", f.OnLeave);
	f:SetScript("OnClick", f.OnClick);

	return f;
end


local function CreateMiniEntry(parent)
	local f = CreateFrame("Button", nil, parent, "PlumberStrikethroughNumberTemplate");
	f:SetSize(Def.ButtonWidth, Def.ButtonHeight);
	f.isMiniEntry = true;
	API.Mixin(f, CurrencyButtonMixin);

	f.Icon = f:CreateTexture(nil, "ARTWORK");
	f.Icon:SetSize(20, 20);
	f.Icon:SetPoint("LEFT", f, "LEFT", Def.MiniEntrySidePadding, 0);
	--f.Icon:SetTexCoord(6/64, 58/64, 6/64, 58/64);

	f.breakupLargeNumbers = true;
	f.Count:SetPoint("RIGHT", f, "RIGHT", -Def.MiniEntrySidePadding, 0);
	f.Count:SetMaxLines(1);
	f.Count:SetJustifyH("RIGHT");
	f.Count:SetTextColor(1, 1, 1);
	f.Count:SetText("0");

	f.Highlight = f:CreateTexture(nil, "BACKGROUND");
	f.Highlight:SetAllPoints(true);
	f.Highlight:Hide();
	f.Highlight:SetTextureSliceMode(1);
	local m = 8;
	f.Highlight:SetTextureSliceMargins(m, m, m, m);
	f.Highlight:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/SmallListButtonHighlight");
	f.Highlight:SetBlendMode("ADD");
	f.Highlight:SetAlpha(0.08);

	f:SetScript("OnEnter", f.OnEnter);
	f:SetScript("OnLeave", f.OnLeave);
	f:SetScript("OnClick", f.OnClick);

	return f;
end


local ListManager = {};
do	-- ManagerFrame / ManagerEntry
	local ManagerFrame;

	local ManagerEntryMixin = {};

	function ManagerEntryMixin:OnEnter()
		self:UpdateVisual();
		if not (self.EyeButton:IsMouseMotionFocus() or self.DeleteButton:IsMouseMotionFocus()) then
			CurrencyButtonMixin.ShowTooltip(self);
		end
	end

	function ManagerEntryMixin:OnLeave()
		GameTooltip:Hide();
		self:UpdateVisual();
	end

	function ManagerEntryMixin:SetCurrency(currencyID)
		self.currencyID = currencyID;
		self.itemID = nil;
		self.isCustomItem = false;
		local info = GetCurrencyInfo(self.currencyID);
		if info then
			self.Name:SetText(info.name)
			self.Icon:SetTexture(info.iconFileID);
		else
			self.Name:SetText("Currency:"..currencyID);
			self.Icon:SetTexture(134400);
		end
		self:UpdateVisual();
	end

	function ManagerEntryMixin:SetItem(itemID)
		self.currencyID = nil;
		self.itemID = itemID;
		self.isCustomItem = true; -- TEMP
		self.Icon:SetTexture(GetItemIconByID(self.itemID));
		local itemName = GetItemNameByID(self.itemID);
		if itemName then
			self.Name:SetText(itemName);
		else
			CallbackRegistry:LoadItem(self.itemID, function(itemID)
				if self.itemID == itemID then
					self.Name:SetText(GetItemNameByID(self.itemID));
					self.Icon:SetTexture(GetItemIconByID(self.itemID));
				end
			end);
		end
		self:UpdateVisual();
	end

	function ManagerEntryMixin:IsFocused()
		return self:IsMouseMotionFocus() or self.EyeButton:IsMouseMotionFocus() or self.DeleteButton:IsMouseMotionFocus();
	end

	function ManagerEntryMixin:UpdateVisual()
		if self.ignored and not self.markedDeleted then
			self:SetAlpha(0.5);
		else
			self:SetAlpha(1);
		end

		if self:IsFocused() then
			self.Name:SetTextColor(1, 1, 1);
			self.Highlight:Show();
		else
			self.Name:SetTextColor(0.922, 0.871, 0.761);
			self.Highlight:Hide();
		end

		self.EyeButton:UpdateVisual();
		self.DeleteButton:UpdateVisual();

		self.EyeButton:SetShown(not self.markedDeleted);
		self.DeleteButton:SetShown(self.isCustomItem);

		if self.markedDeleted then
			self.Name:SetTextColor(1, 0.125, 0.125);
			self.Icon:SetVertexColor(0.5, 0.5, 0.5);
		else
			self.Icon:SetVertexColor(1, 1, 1);
		end
	end

	function ManagerEntryMixin:ToggleEntryIgnored()
		if self.markedDeleted then return; end

		self.ignored = not self.ignored;
		self.EyeButton.parentEntryIgnored = self.ignored;
		if self.ignored then
			self.EyeButton:CloseEye();
		else
			self.EyeButton:OpenEye();
		end
		self:UpdateVisual();
	end

	function ManagerEntryMixin:ToggleEntryDeleted()
		self.markedDeleted = not self.markedDeleted;
		self.DeleteButton.parentEntryMarkedDeleted = self.markedDeleted;
		self:UpdateVisual();
	end

	local function EyeButton_UpdateVisual(self)
		local l, r;
		local t, b = 0, 64;
		if self:IsMouseMotionFocus() then
			l, r = 128, 192;
			self.Background:Show();
		elseif self:GetParent():IsMouseMotionFocus() then
			l, r = 0, 64;
			self.Background:Show();
		else
			l, r = 64, 128;
			self.Background:Hide();
		end
		self.Background:SetTexCoord(l/512, r/512, t/512, b/512);
	end

	local function DeleteButton_UpdateVisual(self)
		if self.parentEntryMarkedDeleted then -- Undo
			self.Icon:SetTexCoord(144/512, 192/512, 64/512, 112/512);
		else -- X
			self.Icon:SetTexCoord(96/512, 144/512, 64/512, 112/512);
		end

		local l, r;
		local t, b = 0, 64;
		if self:IsMouseMotionFocus() then
			if self.parentEntryMarkedDeleted then
				l, r = 128, 192;
			else
				l, r = 192, 256;
			end
			self.Background:Show();
			self.Icon:SetVertexColor(1, 1, 1);
		else
			if self:GetParent():IsMouseMotionFocus() then
				l, r = 0, 64;
				self.Background:Show();
			else
				l, r = 64, 128;
				self.Background:Hide();
			end
			self.Icon:SetVertexColor(0.922, 0.871, 0.761);
		end
		self.Background:SetTexCoord(r/512, l/512, t/512, b/512);
	end

	local function CreateManagerEntry(parent)
		local f = CreateFrame("Button", nil, parent);
		f:SetSize(Def.ButtonWidth, Def.ButtonHeight);
		API.Mixin(f, ManagerEntryMixin);
		f.isManagerEntry = true;

		f.Icon = f:CreateTexture(nil, "ARTWORK");
		f.Icon:SetSize(20, 20);
		f.Icon:SetPoint("RIGHT", f, "RIGHT", -32, 0);

		f.Name = f:CreateFontString(nil, "ARTWORK", "GameFontNormal");
		f.Name:SetPoint("LEFT", f, "LEFT", 32, 0);
		f.Name:SetPoint("RIGHT", f.Icon, "LEFT", -8, 0);
		f.Name:SetJustifyH("LEFT");
		f.Name:SetTextColor(1, 1, 1);
		f.Name:SetMaxLines(1);

		f.Highlight = f:CreateTexture(nil, "BACKGROUND");
		f.Highlight:SetAllPoints(true);
		f.Highlight:Hide();
		f.Highlight:SetTextureSliceMode(1);
		local m = 8;
		f.Highlight:SetTextureSliceMargins(m, m, m, m);
		f.Highlight:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/SmallListButtonHighlight");
		f.Highlight:SetBlendMode("ADD");
		f.Highlight:SetAlpha(0.08);

		f.EyeButton = LandingPageUtil.CreateEyeButton(f);
		f.EyeButton:SetPoint("LEFT", f, "LEFT", 0, 0);
		f.EyeButton.UpdateVisual = EyeButton_UpdateVisual;
		f.EyeButton:SetPropagateMouseMotion(true);
		f.EyeButton:SetIgnoreParentAlpha(true);

		f.DeleteButton = LandingPageUtil.CreateDeleteButton(f);
		f.DeleteButton:SetPoint("RIGHT", f, "RIGHT", 0, 0);
		f.DeleteButton.UpdateVisual = DeleteButton_UpdateVisual;
		f.DeleteButton:SetPropagateMouseMotion(true);
		f.DeleteButton:SetIgnoreParentAlpha(true);

		f:SetScript("OnEnter", f.OnEnter);
		f:SetScript("OnLeave", f.OnLeave);

		return f;
	end

	function ListManager:Init()
		if ManagerFrame then return; end

		local container = MainFrame.listCategoryButton:GetParent();
		local relativeTo = PlumberExpansionLandingPage.LeftSection;


		local f = CreateFrame("Frame", nil, container);
		ManagerFrame = f;
		f:SetPoint("TOPLEFT", relativeTo, "TOPLEFT", 0, 0);
		f:SetPoint("BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", 0, 0);
		f:EnableMouse(true);
		f:EnableMouseMotion(true);
		f:SetFrameLevel(227);

		f.Background = f:CreateTexture(nil, "BACKGROUND");
		f.Background:SetPoint("TOPLEFT", relativeTo, "TOPLEFT", 8, -8);
		f.Background:SetPoint("BOTTOMRIGHT", relativeTo, "BOTTOMRIGHT", -8, 8);
		f.Background:SetColorTexture(0.067, 0.040, 0.024);

		-- Header
		local categoryButtonHeight = 36;
		local categoryButtonOffsetY = 96;
		local categoryButton = LandingPageUtil.CreateListCategoryButton(f, L["Resources"]);
		categoryButton:SetPoint("TOP", f, "TOP", 0, -categoryButtonOffsetY);

		-- Footer: Save and Cancel buttons
		local redButtonOffsetY = 18;
		local redButtonGap = 8;
		local redbuttonWidth = 0.5 * (Def.ButtonWidth - redButtonGap);
		f.SaveButton = LandingPageUtil.CreateRedButton(f);
		f.SaveButton:SetWidth(redbuttonWidth);
		f.SaveButton:SetButtonText(SAVE);
		f.SaveButton:SetPoint("BOTTOMRIGHT", relativeTo, "BOTTOM", -0.5 * redButtonGap, redButtonOffsetY);
		f.SaveButton:SetScript("OnClick", function()
			ListManager:SaveChanges();
		end);
		f.CancelButton = LandingPageUtil.CreateRedButton(f);
		f.CancelButton:SetWidth(redbuttonWidth);
		f.CancelButton:SetButtonText(CANCEL);
		f.CancelButton:SetPoint("BOTTOMLEFT", relativeTo, "BOTTOM", 0.5 * redButtonGap, redButtonOffsetY);
		f.CancelButton:SetScript("OnClick", function()
			ListManager:Cancel();
		end);

		local headerHeight = categoryButtonOffsetY + categoryButtonHeight;
		local footerHeight = 24 + 2 * redButtonOffsetY;

		local ScrollView = LandingPageUtil.CreateScrollViewForTab(f);
		f.ScrollView = ScrollView;
		ScrollView:Hide();
		ScrollView:ClearAllPoints();
		ScrollView:SetWidth(Def.ButtonWidth);
		ScrollView:SetPoint("TOP", f, "TOP", 0, -headerHeight);
		ScrollView:SetPoint("BOTTOM", f, "BOTTOM", 0, footerHeight);
		ScrollView:MinimizeScrollBar(true);
		ScrollView:OnSizeChanged();
		ScrollView:SetAlwaysShowScrollBar(false);
		ScrollView:SetSmartClipsChildren(true);
		ScrollView:SetStepSize(2.5 * Def.ButtonHeight);
		ScrollView:SetBottomOvershoot(Def.ButtonHeight);
		ScrollView:ResetScrollBarPosition();
		ScrollView:UseBoundaryGradient(true);
		ScrollView:SetBoundaryGradientSize(Def.ButtonHeight);

		local function EntryButton_Create()
			return CreateManagerEntry(ScrollView);
		end

		local function EntryButton_OnAcquired(obj)
			if ScrollView:IsScrollable() then
				obj:SetWidth(Def.ButtonWidth - 24);
			else
				obj:SetWidth(Def.ButtonWidth);
			end
		end

		local function EntryButton_OnRemoved(obj)
			obj.currencyID = nil;
			obj.itemID = nil;
		end

		ScrollView:AddTemplate("ManagerEntry", EntryButton_Create, EntryButton_OnAcquired, EntryButton_OnRemoved);

		-- Exit if tab changes
		addon.CallbackRegistry:Register("LandingPage_TabChanged", self.Cancel, self);
	end

	function ListManager:SaveChanges()

	end

	function ListManager:Cancel()
		self:HideFrame();
	end

	function ListManager:ShowFrame()
		self:Init();
		ManagerFrame:Show();
		self:FullUpdate();
		MainFrame:Hide();
		LandingPageUtil.HighlightWidget(ManagerFrame, true);
	end

	function ListManager:HideFrame()
		if ManagerFrame and ManagerFrame:IsShown() then
			ManagerFrame:Hide();
			MainFrame:Show();
			LandingPageUtil.HighlightWidget(nil);
		end
	end

	function ListManager:UpdateIfVisible()
		if ManagerFrame and ManagerFrame:IsShown() then
			self:FullUpdate();
		end
	end

	function ListManager:FullUpdate()
		local n = 0;
		local content = {};
		local offsetY = 0;
		local offsetX = -0.5 * Def.ButtonWidth;
		local objectHeight = Def.ButtonHeight;
		local gap = 0;
		local top, bottom;

		for _, v in ipairs(ResourceList) do
			n = n + 1;
			top = offsetY;
			bottom = offsetY + objectHeight + gap;
			content[n] = {
				templateKey = "ManagerEntry",
				top = top,
				bottom = bottom,
				point = "TOPLEFT",
				offsetX = offsetX,
			};
			if v.currencyID then
				content[n].setupFunc = function(obj)
					obj:SetCurrency(v.currencyID, v.isMinor, v.appendTooltipFunc, v.hasWeeklyCap);
				end;
			elseif v.itemID then
				content[n].setupFunc = function(obj)
					obj:SetItem(v.itemID, v.isMinor, v.appendTooltipFunc, v.useActionButton);
				end;
			end
			offsetY = bottom;
		end

		local retainPosition = false;
		ManagerFrame.ScrollView:Show();
		ManagerFrame.ScrollView:SetContent(content, retainPosition);
	end
end


local CurrencyListMixin = {};
do
	function CurrencyListMixin:OnLoad()
		--Called once when frame is created
		self:OnSizeChanged();
	end

	function CurrencyListMixin:OnShow()
		API.ClearUnusedCurrencyCache();
		self:FullUpdate();
	end

	function CurrencyListMixin:OnHide()
		self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
		self:UnregisterEvent("BAG_UPDATE_DELAYED");
		self:UnregisterEvent("UPDATE_FACTION");
		self:UnregisterEvent("PLAYER_IN_COMBAT_CHANGED");
		self.anyCurrency = nil;
		self.anyItem = nil;
	end

	function CurrencyListMixin:OnEvent(event, ...)
		if event == "CURRENCY_DISPLAY_UPDATE" then
			if not self.anyCurrency then return end;
			local currencyID = ...

			if self.currencyXButton[currencyID] then
				self.currencyXButton[currencyID]:Refresh();
				return
			end

			local processFunc = function(obj)
				if obj.currencyID == currencyID then
					obj:Refresh();
					return true
				end
			end
			self.ScrollView:ProcessActiveObjects("CurrencyButton", processFunc);
		elseif event == "BAG_UPDATE_DELAYED" then
			if not self.anyItem then return end;
			local processFunc = function(obj)
				if obj.itemID then
					obj:Refresh();
				end
			end
			self.ScrollView:ProcessActiveObjects("CurrencyButton", processFunc);
		elseif event == "UPDATE_FACTION" then
			self.ScrollView:CallObjectMethod("RepBar", "Refresh");
		elseif event == "PLAYER_IN_COMBAT_CHANGED" then
			local processFunc = function(obj)
				if obj.usableItemID and obj:IsMouseMotionFocus() then
					obj:OnEnter();
					return true;
				end
			end
			self.ScrollView:ProcessActiveObjects("CurrencyButton", processFunc);
		end
	end

	function CurrencyListMixin:FullUpdate(resetScrollOffset)
		self.anyCurrency = nil;
		self.anyItem = nil;
		self.anyRep = nil;
		self.anyAction = nil;
		self.inactiveCurrencyIDs = nil;

		local n = 0;
		local content = {};
		local offsetY = 0;
		local offsetX = -0.5 * Def.ButtonWidth;
		local gap = 0;
		local repBarGap = 10;
		local miniEntryMode = addon.GetDBValue("LandingPage_Currency_Layout") == 2;
		local isLeftCol = true;
		local top, bottom;
		local objectHeight;
		local valid;
		local uiMapID;

		if miniEntryMode then
			self.ScrollView:ExtendRenderDataIndex(2);
			self.ScrollView:SetStepSize(2 * (Def.ButtonHeight + Def.MiniEntryGap));
		else
			self.ScrollView:ExtendRenderDataIndex(0);
			self.ScrollView:SetStepSize(2.5 * Def.ButtonHeight);
		end

		for _, v in ipairs(ResourceList) do
			valid = true;
			if v.hidden then
				valid = false;      --for transition between WoW content updates
			elseif v.shownInDelves then
				valid = API.IsInDelves();
			elseif v.conditionFunc then
				valid = v.conditionFunc();
			elseif v.uiMapID then
				valid = false;

				if not uiMapID then
					uiMapID = C_Map.GetBestMapForUnit("player");
				end

				if uiMapID then
					if type(v.uiMapID) == "table" then
						for _, id in ipairs(v.uiMapID) do
							if uiMapID == id then
								valid = true;
							end
						end
					else
						valid = uiMapID == v.uiMapID;
					end
				end
			end

			if valid and v.shownIfOwned then
				valid = GetResourcesQuantity(v) > 0;
			end

			if valid and v.currencyID then
				if API.IsCurrencyUnused(v.currencyID) then
					valid = false;
					if not self.inactiveCurrencyIDs then
						self.inactiveCurrencyIDs = {};
					end
					table.insert(self.inactiveCurrencyIDs, v.currencyID);
				end
			end

			if valid then
				n = n + 1;
				top = offsetY;
				if v.isHeader then
					objectHeight = 16;
					bottom = offsetY + objectHeight + gap;
					content[n] = {
						templateKey = "HeaderTitle",
						setupFunc = function(obj)
							obj:SetText(v.name);
						end,
						top = top,
						bottom = bottom,
						point = "TOPLEFT",
						offsetX = offsetX,
					};
				elseif v.faction then
					self.anyRep = true;
					objectHeight = Def.ButtonHeight;
					bottom = offsetY + objectHeight + repBarGap;
					content[n] = {
						templateKey = "RepBar",
						top = top,
						bottom = bottom,
						point = "TOPLEFT",
						offsetX = offsetX,
						setupFunc = function(obj)
							obj.appendTooltipFunc = v.appendTooltipFunc;
							obj:SetFaction(v.faction);
						end;
					};
				else
					objectHeight = Def.ButtonHeight;
					if miniEntryMode then
						local buttonOffsetX;
						if isLeftCol then
							buttonOffsetX = -0.5 * Def.ButtonWidth;
						else
							buttonOffsetX = Def.MiniEntryGap;
						end
						bottom = offsetY + objectHeight + Def.MiniEntryGap;
						content[n] = {
							templateKey = "MiniCurrencyButton",
							top = top,
							bottom = bottom,
							point = "TOPLEFT",
							offsetX = buttonOffsetX,
						};

						if isLeftCol then
							-- Reset bottom so the button on the right col has the same top.
							bottom = offsetY;
						end

						isLeftCol = not isLeftCol;
					else
						bottom = offsetY + objectHeight + gap;
						content[n] = {
							templateKey = "CurrencyButton",
							top = top,
							bottom = bottom,
							point = "TOPLEFT",
							offsetX = offsetX,
						};
					end

					if v.currencyID then
						self.anyCurrency = true;
						content[n].setupFunc = function(obj)
							obj:SetUsableAction(v.usableItemID, v.criteriaFunc);
							obj:SetCurrency(v.currencyID, v.isMinor, v.appendTooltipFunc, v.hasWeeklyCap);
						end;
					elseif v.itemID then
						self.anyItem = true;
						content[n].setupFunc = function(obj)
							obj:SetUsableAction(v.usableItemID, v.criteriaFunc);
							obj:SetItem(v.itemID, v.isMinor, v.appendTooltipFunc);
						end;
					end
				end
				offsetY = bottom;
			end
		end

		local retainPosition = not resetScrollOffset;
		self.ScrollView:Show();
		self.ScrollView:SetContent(content, retainPosition);


		self.currencyXButton = {};
		local itemUpgradeButtons = LandingPageUtil.GetItemUpgradeButtons();
		if itemUpgradeButtons then
			self.anyCurrency = true;
			for _, button in ipairs(itemUpgradeButtons) do
				self.currencyXButton[button.currencyID] = button;
				button:Refresh();
			end
		end

		if self.anyCurrency then
			self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
		else
			self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
		end

		if self.anyItem then
			self:RegisterEvent("BAG_UPDATE_DELAYED");
		else
			self:UnregisterEvent("BAG_UPDATE_DELAYED");
		end

		if self.anyRep then
			self:RegisterEvent("UPDATE_FACTION");
		else
			self:UnregisterEvent("UPDATE_FACTION");
		end

		if self.anyAction then
			self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED");
		else
			self:UnregisterEvent("PLAYER_IN_COMBAT_CHANGED");
		end
	end

	function CurrencyListMixin:UpdateScrollViewContent()
		if self.ScrollView then
			self.ScrollView:CallObjectMethod("CurrencyButton", "Refresh");
			self.ScrollView:CallObjectMethod("MiniCurrencyButton", "Refresh");
		end
	end

	function CurrencyListMixin:OnSizeChanged()
		if self.ScrollView then
			self.ScrollView:OnSizeChanged();
		end
	end
end


local function CategoryButtonOnEnterFunc(listCategoryButton)
	if MainFrame then
		LandingPageUtil.DisplayInactiveCurrencies(listCategoryButton, MainFrame.inactiveCurrencyIDs);
	end
end

local function GenerateSettingsPopupInfo()
	local popupInfo = {
		title = L["Edit Resource List"],
	};

	return popupInfo;
end

local function MenuInfoGetter_CurrencySettings()
	local tbl = {
		key = "LandingPageCurrencySettings",
	};

	local tinsert = table.insert;

	local widgets = {
		{type = "Header", text = L["Quick Slot Layout"]},
	};


	local selectedIndex = addon.GetDBValue("LandingPage_Currency_Layout");

	for i = 1, 2 do
		tinsert(widgets, {
			type = "Radio",
			text = L["Currency Button Layout "..i];
			closeAfterClick = true,
			onClickFunc = function()
				addon.SetDBValue("LandingPage_Currency_Layout", i);
				MainFrame:FullUpdate(true);
			end,
			selected = i == selectedIndex,
		});
	end

	tinsert(widgets, {type = "Divider"});
	tinsert(widgets, {type = "Button", text = L["Edit Resource List"], tooltip = nil, closeAfterClick = true,
		onClickFunc = function()
			ListManager:ShowFrame();
		end,
	});

	tbl.widgets = widgets;
	return tbl
end

function LandingPageUtil.CreateCurrencyList(parent)
	local f = CreateFrame("Frame", nil, parent);
	MainFrame = f;
	API.Mixin(f, CurrencyListMixin);

	local height = 7 * Def.ButtonHeight;
	f:SetSize(Def.ButtonWidth, height);


	local ScrollView = LandingPageUtil.CreateScrollViewForTab(f);
	f.ScrollView = ScrollView;
	ScrollView:Hide();
	ScrollView:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
	ScrollView:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);
	ScrollView:MinimizeScrollBar(true);
	ScrollView:OnSizeChanged();
	ScrollView:SetAlwaysShowScrollBar(false);
	ScrollView:SetSmartClipsChildren(true);
	ScrollView:SetStepSize(2.5 * Def.ButtonHeight);
	ScrollView:SetBottomOvershoot(Def.ButtonHeight);
	ScrollView:ResetScrollBarPosition();
	ScrollView:UseBoundaryGradient(true);
	ScrollView:SetBoundaryGradientSize(Def.ButtonHeight);

	local function CurrencyButton_Create()
		return CreateStandardEntry(ScrollView);
	end

	local function CurrencyButton_OnAcquired(obj)
		if ScrollView:IsScrollable() then
			obj:SetWidth(Def.ButtonWidth - 10);
		else
			obj:SetWidth(Def.ButtonWidth);
		end
	end

	local function CurrencyButton_OnRemoved(obj)
		obj.currencyID = nil;
		obj.itemID = nil;
	end

	ScrollView:AddTemplate("CurrencyButton", CurrencyButton_Create, CurrencyButton_OnAcquired, CurrencyButton_OnRemoved);


	local function MiniCurrencyButton_Create()
		return CreateMiniEntry(ScrollView);
	end

	local function MiniCurrencyButton_OnAcquired(obj)
		if ScrollView:IsScrollable() then
			obj:SetWidth((Def.ButtonWidth - Def.MiniEntryGap - 10) / 2);
		else
			obj:SetWidth((Def.ButtonWidth - Def.MiniEntryGap) / 2);
		end
	end

	ScrollView:AddTemplate("MiniCurrencyButton", MiniCurrencyButton_Create, MiniCurrencyButton_OnAcquired, CurrencyButton_OnRemoved);


	local function HeaderTitle_Create()
		local fs = ScrollView:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		fs:SetSize(208, 16);
		fs:SetTextColor(0.8, 0.8, 0.8);
		return fs
	end

	ScrollView:AddTemplate("HeaderTitle", HeaderTitle_Create);


	--Simple Reputation List
	local function RepBar_Create()
		local obj = LandingPageUtil.CreateStatusBar(ScrollView);
		obj:SetPaddingH(8);
		return obj;
	end

	local function RepBar_OnAcquired(obj)
		if ScrollView:IsScrollable() then
			obj:SetWidth(Def.ButtonWidth - 20);
		else
			obj:SetWidth(Def.ButtonWidth);
		end
	end

	local function RepBar_OnRemoved(obj)
		obj.currencyID = nil;
		obj.itemID = nil;
	end

	ScrollView:AddTemplate("RepBar", RepBar_Create, RepBar_OnAcquired, RepBar_OnRemoved);


	f:SetScript("OnShow", f.OnShow);
	f:SetScript("OnHide", f.OnHide);
	f:SetScript("OnEvent", f.OnEvent);

	return f, height, CategoryButtonOnEnterFunc, MenuInfoGetter_CurrencySettings;
end


local function UpdateIfVisible()
	if MainFrame and MainFrame:IsVisible() then
		MainFrame:FullUpdate();
	end
	ListManager:UpdateIfVisible();
end

CallbackRegistry:Register("LandingPage.SetResourceList", function(list)
	if list then
		ResourceList = list;
		UpdateIfVisible();
	end
end);

CallbackRegistry:Register("UnusedCurrencyChanged", UpdateIfVisible);


if TokenFramePopup and TokenFramePopup.InactiveCheckbox then
	TokenFramePopup.InactiveCheckbox:HookScript("OnClick", function()
		API.ClearUnusedCurrencyCache();
		CallbackRegistry:Trigger("UnusedCurrencyChanged");
	end);
end
