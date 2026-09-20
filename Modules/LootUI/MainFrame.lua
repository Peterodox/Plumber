local _, addon = ...
local L = addon.L;
local API = addon.API;
local LootUI = addon.LootUI; ---@class LootUISystem
local Def = LootUI.Defination;
local Formatter = LootUI.Formatter;
local MainFrame = LootUI.MainFrame;


local tremove = table.remove;
local LootSlotHasItem = LootSlotHasItem;


function MainFrame:Init()
	self.Init = nil;

	Formatter:Init();

	self:SetAlpha(0);
	self:SetToplevel(true);
	self:SetClampedToScreen(true);
	self.HeaderWidgetContainer = CreateFrame("Frame", nil, MainFrame);
	self.HeaderWidgetContainer:Hide();
	self.HeaderWidgets = {};
	self.isUISpecialFrame = false;

	local Header = self:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	self.Header = Header;
	Header:SetJustifyH("CENTER");
	Header:SetPoint("BOTTOM", self, "TOP", 0, Formatter.BUTTON_SPACING);
	Header:SetText(L["You Received"]);
	Header:SetTextColor(1, 1, 1, 0.5);
	Header:Hide();

	self.itemFramePool = API.CreateObjectPool(function()
		local f = LootUI.Templates.CreateItemFrame(self);
		f.lootFrame = self;
		return f;
	end);

	self.glowFXPool = API.CreateObjectPool(function()
		return LootUI.Templates.CreateSpikeyGlowFrame(self);
	end);

	local function CreatePagniation()
		local texture = self:CreateTexture(nil, "OVERLAY");
		texture:SetTexture("Interface/AddOns/Plumber/Art/LootUI/LootUI.png");
		texture:SetTexCoord(0, 32/1024, 0, 32/512);
		return texture;
	end
	self.paginationPool = API.CreateObjectPool(CreatePagniation);

	self.MoneyFrame = LootUI.Templates.CreateMoneyFrame(self);
	self.MoneyFrame.lootFrame = self;
	self.BackgroundFrame = LootUI.Templates.CreateFrameBackground(self);
	self.BackgroundFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
	self.ButtonHighlight = LootUI.Templates.CreateItemFrameHighlight(self);

	local CloseButton = LootUI.Templates.CreateCloseButton(self.HeaderWidgetContainer);
	self.CloseButton = CloseButton;
	CloseButton.lootFrame = self;
	CloseButton:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, Formatter.BUTTON_SPACING);
	table.insert(self.HeaderWidgets, CloseButton);

	local TakeAllButton = LootUI.Templates.CreateTakeAllButton(self.HeaderWidgetContainer);
	self.TakeAllButton = TakeAllButton;
	TakeAllButton.lootFrame = self;
	TakeAllButton:SetPoint("RIGHT", CloseButton, "LEFT", -Formatter.BUTTON_SPACING + 4, 0);
	table.insert(self.HeaderWidgets, TakeAllButton);

	self:SetScript("OnShow", self.OnShow);
	self:SetScript("OnHide", self.OnHide);
	self:SetScript("OnEvent", self.OnEvent);
	self:SetScript("OnEnter", self.OnEnter);
	self:SetScript("OnLeave", self.OnLeave);

	self:LoadPosition();
end

function MainFrame:ReleaseAll()
	if self.activeFrames then
		self.activeFrames = nil;
		self.itemFramePool:ReleaseAll();
		self.glowFXPool:ReleaseAll();
		self.MoneyFrame:Hide();
		self.MoneyFrame:ClearAllPoints();
		self:SetMaxPage(nil);
		self:SetClickedFrameIndex(nil);
	end
end

function MainFrame:Disable()
	self:Hide();
	self:SetAlpha(0);
	self:SetScript("OnUpdate", nil);
end

function MainFrame:EnableHeaderWidgets(state)
	for _, widget in ipairs(self.HeaderWidgets) do
		widget:SetEnabled(state);
		widget:EnableMouseMotion(state);
		widget:EnableMouse(state);
	end
end


-- Background
do
	function MainFrame:SetBackgroundAlpha(alpha)
		if self.BackgroundFrame then
			self.BackgroundFrame:ShowBorderLine(alpha > 0);
			alpha = 0.9 * alpha;
			self.BackgroundFrame:SetBackgroundAlpha(alpha);
		end
	end

	function MainFrame:SetBackgroundSize(width, height)
		if self:IsShown() and not self.growUpwards then
			self.BackgroundFrame:AnimateSize(width, height);
		else
			self.BackgroundFrame:SetScript("OnUpdate", nil);
			self.BackgroundFrame.toWidth = nil;
			self.BackgroundFrame.toHeight = nil;
			self.BackgroundFrame:SetBackgroundSize(width, height);
		end
	end

	function MainFrame:SetClickedFrameIndex(index)
		self.clickedFrameIndex = index;
	end

	function MainFrame:SetBottomFrameIndex(index)
		self.bottomFrameIndex = index;
	end

	function MainFrame:UpdateBackgroundHeightAfterClicks()
		if self.clickedFrameIndex then
			self:SetClickedFrameIndex(nil);

			if self.activeFrames and self.bottomFrameIndex > 0 then
				local itemFrame;
				local bottomFrameIndex;
				for i = #self.activeFrames, 1, -1 do
					itemFrame = self.activeFrames[i];
					if itemFrame.hasItem then
						bottomFrameIndex = i;
						break
					end
				end
				if bottomFrameIndex and bottomFrameIndex > 0 and bottomFrameIndex ~= self.bottomFrameIndex then
					self:SetBottomFrameIndex(bottomFrameIndex);
					local frameHeight = bottomFrameIndex * (Formatter.ICON_BUTTON_HEIGHT + Formatter.BUTTON_SPACING) + Formatter.BUTTON_SPACING;
					self:SetHeight(frameHeight);
					local scale = self:GetEffectiveScale();
					self:SetBackgroundSize(self.BackgroundFrame.width, (frameHeight + Formatter.ICON_BUTTON_HEIGHT) * scale);
				end
			end
		end
	end

	-- Show dots on the bottom if the items can't be displayed in one page.
	-- "Page" only serves as a visual indicator. The user can't change pages manually.
	function MainFrame:SetMaxPage(page)
		self.paginationPool:ReleaseAll();
		if page and page > 1 then
			local numDots = page - 1;
			local dot;
			local gap = 0;
			local dotSize = Formatter.DOT_SIZE;
			local offsetX = Formatter.ICON_TEXT_GAP;
			local fromOffsetY = 0.5*(numDots * (dotSize + gap) - gap);
			for i = 1, numDots do
				dot = self.paginationPool:Acquire();
				dot:SetSize(dotSize, dotSize);
				dot:SetPoint("TOPRIGHT", self, "LEFT", -offsetX, fromOffsetY - (i - 1) * (dotSize + gap));
			end
		end
	end
end


-- Frame Position
do
	function MainFrame:LoadPosition()
		self:ClearAllPoints();
		local DB = PlumberDB;
		local growUpwards = DB and DB.LootUI_GrowUpwards;
		self.growUpwards = growUpwards;
		local point = growUpwards and "BOTTOMLEFT" or "TOPLEFT";
		if DB and DB.LootUI_PositionX and DB.LootUI_PositionY then
			self:SetPoint(point, UIParent, "BOTTOMLEFT", DB.LootUI_PositionX, DB.LootUI_PositionY);
		else
			local viewportWidth, viewportHeight = WorldFrame:GetSize();
			viewportWidth = math.min(viewportWidth, viewportHeight * 16/9);
			local scale = UIParent:GetEffectiveScale();
			local offsetX = math.floor((0.5 - 0.3333) * viewportWidth /scale);
			self:SetPoint(point, nil, "CENTER", offsetX, 0);
		end
	end

	function MainFrame:PositionUnderMouse()
		local x, y = GetCursorPosition();
		local scale = self:GetEffectiveScale();
		x = x / (scale) - Formatter.ICON_SIZE;
		y = math.max((y / scale) + 24, 350);
		self:ClearAllPoints();
		self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x, y);
		self:Raise();
	end
end


-- ItemFrame
do
	function MainFrame:LayoutActiveFrames(fixedFrameWidth)
		if not self.activeFrames then
			self:TryHide(true);
			return;
		end

		local height = 0;
		local spacing = Formatter.BUTTON_SPACING;
		local iconSize = Formatter.ICON_SIZE;
		local textWidth;
		local maxTextWidth = 0;

		for i, itemFrame in ipairs(self.activeFrames) do
			if i == 1 then
				itemFrame:SetPoint("TOPLEFT", self, "TOPLEFT", spacing, -spacing);
			else
				itemFrame:SetPoint("TOPLEFT", self.activeFrames[i - 1], "BOTTOMLEFT", 0, -spacing);
			end

			height = height + itemFrame:GetHeight() + spacing;

			if itemFrame.Text then
				textWidth = itemFrame.Text:GetWrappedWidth();
			else
				textWidth = itemFrame:GetWidth() - 2*iconSize;
			end
			if textWidth > maxTextWidth then
				maxTextWidth = textWidth;
			end

			itemFrame.index = i;
		end

		local frameWidth = maxTextWidth + 2*iconSize + Formatter:GetNumberWidth(10) + spacing;
		local frameHeight = height + spacing;

		local maxFrameWidth = Formatter.BUTTON_WIDTH + Formatter.BUTTON_SPACING * 2;
		if frameWidth > maxFrameWidth then
			frameWidth = maxFrameWidth;
		end

		local backgroundWidth;

		if fixedFrameWidth then
			frameWidth = Formatter.BUTTON_WIDTH;
			backgroundWidth = frameWidth + Formatter.BUTTON_SPACING * 2;
			self:SetBottomFrameIndex(#self.activeFrames);
		else
			backgroundWidth = frameWidth + Formatter.ICON_BUTTON_HEIGHT
		end

		self:SetSize(frameWidth, frameHeight);

		local scale = self:GetEffectiveScale();
		self:SetBackgroundSize(backgroundWidth * scale, (frameHeight + Formatter.ICON_BUTTON_HEIGHT) * scale);
	end

	function MainFrame:GetFocusedItemFrame()
		if self.activeFrames then
			for i, itemFrame in ipairs(self.activeFrames) do
				if itemFrame:IsMouseOver() then
					return itemFrame;
				end
			end
		end
	end

	---@return LootUI_ItemFrame
	function MainFrame:AcquireItemFrame()
		local f = self.itemFramePool:Acquire();
		f.Text:SetWidth(Formatter.NAME_WIDTH);
		f:SetWidth(Formatter.BUTTON_WIDTH);
		return f;
	end

	function MainFrame:HighlightItemFrame(itemFrame)
		self.ButtonHighlight:Hide();
		self.ButtonHighlight:ClearAllPoints();
		if itemFrame then
			local spacing = Formatter.BUTTON_SPACING;
			self.ButtonHighlight:SetPoint("TOPLEFT", itemFrame, "TOPLEFT", -Formatter.ICON_BUTTON_HEIGHT, 0.5 * spacing);
			self.ButtonHighlight:SetPoint("BOTTOMRIGHT", itemFrame, "BOTTOMRIGHT", 0, -0.5 * spacing);
			self.ButtonHighlight:SetParent(itemFrame);
			self.ButtonHighlight:Show();
		end
	end

	function MainFrame:SetLootSlotCleared(slotIndex)
		if self.activeFrames then
			for i, itemFrame in ipairs(self.activeFrames) do
				if itemFrame.data.slotIndex == slotIndex then
					--itemFrame:Hide();
					itemFrame:EnableMouseScript();
					itemFrame:PlaySlideOutAnimation();
					itemFrame.hasItem = nil;
					self:UpdateBackgroundHeightAfterClicks();
					return true
				end
			end
		end
	end

	function MainFrame:UpdateLootSlotData(slotIndex, data)
		if self.activeFrames then
			for _, itemFrame in ipairs(self.activeFrames) do
				if itemFrame.data.slotIndex == slotIndex then
					itemFrame.data = nil;
					itemFrame:SetData(data);
					return true
				end
			end
		end
	end

	function MainFrame:UpdateItemCount()
		if self.activeFrames then
			for i, itemFrame in ipairs(self.activeFrames) do
				if itemFrame.UpdateItemCount then
					-- MoneyFrame could be an activeFrame without this method
					itemFrame:UpdateItemCount();
				end
			end
		end
	end
end


-- TryHide
do
	local function OnUpdate_FadeOut(self, elapsed)
		self.alpha = self.alpha - 4*elapsed;
		if self.alpha <= 0 then
			self.alpha = 0;
			self:SetScript("OnUpdate", nil);
			self:Hide();
		end
		self:SetAlpha(self.alpha);
	end

	local function OnUpdate_FadeOut_IfNotFocused(self, elapsed)
		if self.isFocused then return end;
		self.t = self.t + elapsed;
		if self.t > 0.1 then
			self.t = 0;
			if not self:IsMouseOver() then
				self:TryHide(true);
			end
		end
	end

	function MainFrame:TryHide(forceHide)
		if forceHide then
			self.isUpdatingPage = nil;
			self.alpha = self:GetAlpha();
			self:SetScript("OnUpdate", OnUpdate_FadeOut);
			self:UnregisterEvent("GLOBAL_MOUSE_UP");
		else
			self.t = 0;
			self:SetScript("OnUpdate", OnUpdate_FadeOut_IfNotFocused);
		end
	end
end


-- Dynamic Frame Strata
do
	function MainFrame:UpdateFrameStrata()
		if C_PlayerInteractionManager.IsInteractingWithNpcOfType(40) then
			--Lower frame strata when using Scrapping Machine so our window appear behind bag UI
			self:SetFrameStrata("LOW");
		else
			if self.inEditMode then
				self:SetFrameStrata("HIGH");
			elseif Def.LOW_FRAME_STRATA and not self.manualMode then
				self:SetFrameStrata("MEDIUM");
				self:Lower();
			else
				self:SetFrameStrata("DIALOG");
			end
		end
	end

	function MainFrame:EnableMouseScript(state)
		if state then
			self:EnableMouse(true);
			self:EnableMouseMotion(true);
		else
			self:EnableMouse(false);
			self:EnableMouseMotion(true);
		end
	end

	function MainFrame:IsFocused()
		return (self:IsShown() and (self:IsMouseOver() or self.TakeAllButton:IsMouseOver())) or (self.OptionFrame and self.OptionFrame:IsShown() and self.OptionFrame:IsMouseOver());
	end

	function MainFrame:SetFocused(state)
		--Mouse Motion will be propagated to frames below
		--If the user mouse down on our frames (e.g. move camera), the game triggers OnLeave so we do a IsMouseOver check
		--if (not state) and (not self:IsMouseOver()) then
		if not state then
			self.isFocused = false;
		else
			self.isFocused = true;
		end
	end

	function MainFrame:AddToUISpecialFrames(state)
		if state ~= self.isUISpecialFrame then
			self.isUISpecialFrame = state;
			local selfName = "PlumberLootWindow";
			if state then
				for i, name in ipairs(UISpecialFrames) do
					if name == selfName then
						return;
					end
				end
				table.insert(UISpecialFrames, selfName);
			else
				for i, name in ipairs(UISpecialFrames) do
					if name == selfName then
						tremove(UISpecialFrames, i);
						return;
					end
				end
			end
		end
	end
end


-- Widget Scripts
do
	function MainFrame:OnShow()
		self:UpdateFrameStrata();
		if Def.SHOW_ITEM_COUNT then
			self:RegisterEvent("BAG_UPDATE_DELAYED");
		end
	end

	function MainFrame:OnHide()
		if self.manualMode then
			CloseLoot();
		end
		if self:IsShown() then return end;  --Due to hiding UIParent
		self:ReleaseAll();
		self.isFocused = false;
		self.manualMode = nil;
		self.errorMode = nil;
		self:UnregisterEvent("GLOBAL_MOUSE_UP");
		self:UnregisterEvent("BAG_UPDATE_DELAYED");
	end

	function MainFrame:OnEvent(event, ...)
		if event == "GLOBAL_MOUSE_UP" then
			if self:IsMouseOver() then
				local button = ...
				if button == "RightButton" then
					CloseLoot();
					self:TryHide(true);
				elseif (not (self:IsInMaualModeOrEditMode())) and button == "LeftButton" and not InCombatLockdown() then
					local itemFrame = self:GetFocusedItemFrame();
					if itemFrame and itemFrame.OnClick then
						itemFrame:OnClick("EmulateLeftButton");
					end
				end
			end
		elseif event == "BAG_UPDATE_DELAYED" then
			self:UpdateItemCount();
		end
	end

	function MainFrame:OnEnter()
		self:SetFocused(true);
	end

	function MainFrame:OnLeave()
		self:SetFocused(false);
	end

	function MainFrame:OnUIScaleChanged()
		if not self.uiScaleDirty then
			self.uiScaleDirty = true;
			C_Timer.After(0.33, function()
				Formatter.pixelPerfectScale = nil;
				self.uiScaleDirty = nil;
				self:LoadPosition();
				if self.itemFramePool then
					self.itemFramePool:CallAllObjects("UpdatePixel");
				end
				if self.BackgroundFrame then
					self.BackgroundFrame:UpdatePixel();
				end
				if self.ButtonHighlight then
					self.ButtonHighlight:UpdatePixel();
				end
			end);
		end
	end
end


-- Loot Display
do
	local AUTO_HIDE_DELAY = 3.0; -- Determined by the number of items. From 2.0s to 3.0s

	local MergeSimilarItems = LootUI.MergeSimilarItems;
	local SortFunc_LootSlot = LootUI.SortFunc_LootSlot;

	local function MergeData(d1, d2)
		if d1 and d2 then
			if d1.slotType == d2.slotType then
				if d1.slotType == Def.SLOT_TYPE_REP then
					if d1.name == d2.name then
						d1.quantity = d1.quantity + d2.quantity;
						return true
					end
				else
					if (d1.id == d2.id) and (not d1.mergedData) and (not d2.mergedData) then
						if (d1.quantity == d2.quantity) and (d1.toast ~= d2.toast) then
							d1.toast = true;
						else
							d1.quantity = d1.quantity + d2.quantity;
						end
						return true
					elseif Def.MERGE_SIMILAR_ITEMS then
						return MergeSimilarItems(d1, d2)
					end
				end
			end
		end
		return false
	end

	local function OnUpdate_FadeIn(self, elapsed)
		self.alpha = self.alpha + 8*elapsed;
		if self.alpha >= 1 then
			self.alpha = 1;
			self.toAlpha = nil;
			self:SetScript("OnUpdate", nil);
		end
		self:SetAlpha(self.alpha);
	end

	local function OnUpdate_FadeIn_All_ThenHide(self, elapsed)
		if self.toAlpha then
			self.alpha = self.alpha + 8*elapsed;
			if self.alpha > 1 then
				self.alpha = 1;
				self.toAlpha = nil;
			end
			self:SetAlpha(self.alpha);
		end

		self.t = self.t + elapsed;
		if self.t >= AUTO_HIDE_DELAY then
			self.t = 0;
			self:SetScript("OnUpdate", nil);
			self:DisplayNextPage();
		end
	end

	local function OnUpdate_FadeOut_DisableMotion(self, elapsed)
		self.alpha = self.alpha - 8*elapsed;
		if self.alpha <= 0 then
			self.alpha = 0;
			self:SetScript("OnUpdate", nil);
			self:Hide();
		end
		self:SetAlpha(self.alpha);
	end

	local function OnUpdate_FadeOut_ThenDisplayNextPage(self, elapsed)
		if self.isFocused then return end;

		if self.anyAlphaChange then
			self.anyAlphaChange = nil;
			for _, obj in ipairs(self.activeFrames) do
				if obj.toAlpha then
					self.anyAlphaChange = true;
					obj.alpha = obj.alpha - 8*elapsed;
					if obj.alpha <= 0 then
						obj.alpha = 0;
						obj.toAlpha = nil;
					end
					obj:SetAlpha(obj.alpha);
				end
			end
		end

		if not self.anyAlphaChange then
			self.isUpdatingPage = nil;
			self:SetScript("OnUpdate", nil);
			self:ReleaseAll();
			self:DisplayLootResult();
		end
	end

	local function OnUpdate_FadeIn_Individual(self, elapsed)
		if self.anyAlphaChange then
			self.anyAlphaChange = nil;
			if self.activeFrames then
				for _, obj in ipairs(self.activeFrames) do
					if obj.toAlpha then
						self.anyAlphaChange = true;
						obj.alpha = obj.alpha + 8*elapsed;
						if obj.alpha > 1 then
							obj.alpha = 1;
							obj.toAlpha = nil;
						end
						obj:SetAlpha(obj.alpha);
					end
				end
			end
		end

		if self.toAlpha then
			self.alpha = self.alpha + 8*elapsed;
			if self.alpha > 1 then
				self.alpha = 1;
				self.toAlpha = nil;
			end
			self:SetAlpha(self.alpha);
		end

		if not (self.anyAlphaChange or self.toAlpha) then
			self.t = self.t + elapsed;
			if self.t >= AUTO_HIDE_DELAY then
				self.t = 0;
				self:SetScript("OnUpdate", nil);
				self:DisplayNextPage();
			end
		end
	end

	function MainFrame:DisplayLootResult()
		local overflowWarning;
		local anyNotification;  --Other Plumber module may use this as notification (e.g. auto-selected trait)

		local lootQueue = LootUI.GetLootQueue();

		if lootQueue then
			overflowWarning = false;
		else
			lootQueue = LootUI.GetAndClearOverflowedCurrency();
			if lootQueue then
				overflowWarning = true;
			else
				self:TryHide();
				return;
			end
		end

		self:SetManualMode(false);

		--Merge Data
		local numQueued = #lootQueue;

		if numQueued > 1 then
			local index1 = 1;
			local index2 = 2;
			local data1 = lootQueue[index1];
			local data2 = lootQueue[index2];

			while (data1) do
				while (data2) do
					if MergeData(data1, data2) then
						tremove(lootQueue, index2);
						numQueued = numQueued - 1;
					else
						index2 = index2 + 1;
					end
					data2 = lootQueue[index2];
				end
				index1 = index1 + 1;
				index2 = index1 + 1;
				data1 = lootQueue[index1];
				data2 = lootQueue[index2];
			end
		end

		local itemFrame;
		local numExisting = self.activeFrames and #self.activeFrames or 0;

		if numExisting > 0 then
			local foundIndex;
			local dataIndex = 1;
			local data = lootQueue[dataIndex];

			while (data) do
				foundIndex = nil;
				for i, object in ipairs(self.activeFrames) do
					if object:IsSameItem(data) then
						foundIndex = i;
						object:SetData(data);
						break
					elseif Def.MERGE_SIMILAR_ITEMS and data.slotType == Def.SLOT_TYPE_ITEM and object.data and MergeSimilarItems(object.data, data) then
						foundIndex = i;
						object:SetMergedItem(object.data);
						break
					end
				end

				if foundIndex then
					tremove(lootQueue, dataIndex);
					numQueued = numQueued - 1;
				else
					dataIndex = dataIndex + 1;
				end
				data = lootQueue[dataIndex];
			end
		end

		local numTotal = numQueued + numExisting;
		self:SetMaxPage(math.ceil(numTotal / Def.MAX_ITEM_PER_PAGE));

		if self.isUpdatingPage then
			return;
		end

		table.sort(lootQueue, SortFunc_LootSlot);

		self.alpha = self:GetAlpha();
		local fadeIndividualFrame = self:IsShown() and self.alpha > 0.25;
		local multipage = numTotal > Def.MAX_ITEM_PER_PAGE;
		local lootThisPage;

		if multipage then
			lootThisPage = {};
			local numThisPage = Def.MAX_ITEM_PER_PAGE - numExisting;
			for i = 1, numThisPage do
				lootThisPage[i] = tremove(lootQueue, 1);
			end
		else
			lootThisPage = lootQueue;
			LootUI.WipeLootQueue();
		end

		local enableState = Def.AUTO_LOOT_ENABLE_TOOLTIP and 2 or 0;

		for i, data in ipairs(lootThisPage) do
			if data.slotType == Def.SLOT_TYPE_MONEY then
				self.MoneyFrame:SetData(data);
				self.MoneyFrame:Show();
				itemFrame = self.MoneyFrame;
			else
				itemFrame = self:AcquireItemFrame();
				itemFrame:SetData(data);
			end

			if itemFrame then
				if not self.activeFrames then
					self.activeFrames = {};
				end
				local n = #self.activeFrames;
				n = n + 1;
				self.activeFrames[n] = itemFrame;
				itemFrame:EnableMouseScript(enableState);
				itemFrame.hasItem = true;
			end

			if data.isNotification then
				anyNotification = true;
			end
		end

		local numFrames = (self.activeFrames and #self.activeFrames) or 0;

		if numFrames > 0 then
			if overflowWarning then
				AUTO_HIDE_DELAY = 4.0 + numFrames * Def.FADE_DELAY_PER_ITEM;
				self.Header:SetText(L["Reach Currency Cap"]);
			else
				AUTO_HIDE_DELAY = 2.0 + numFrames * Def.FADE_DELAY_PER_ITEM;
				if anyNotification then
					AUTO_HIDE_DELAY = AUTO_HIDE_DELAY + 2.0;
				end
				if addon.GetDBBool("LootUI_HideTitle") then
					self.Header:SetText(nil);
				else
					self.Header:SetText(L["You Received"]);
				end
			end

			self:LayoutActiveFrames();

			self.t = 0;
			self.toAlpha = 1;

			if fadeIndividualFrame then
				self.anyAlphaChange = true;
				self:SetScript("OnUpdate", OnUpdate_FadeIn_Individual);

				for _, _itemFrame in ipairs(self.activeFrames) do
					_itemFrame.toAlpha = 1;
					_itemFrame.alpha = _itemFrame:GetAlpha();
				end
			else
				self:SetScript("OnUpdate", OnUpdate_FadeIn_All_ThenHide);
				self:Show();
				self.anyAlphaChange = nil;

				for _, _itemFrame in ipairs(self.activeFrames) do
					_itemFrame.toAlpha = nil;
					_itemFrame.alpha = 1;
					_itemFrame:SetAlpha(1);
				end
			end
		else
			self:TryHide(true);
		end

		self:RegisterEvent("GLOBAL_MOUSE_UP");
	end

	function MainFrame:DisplayNextPage()
		local lootQueue = LootUI.GetLootQueue();
		if (lootQueue and #lootQueue > 0) or LootUI.HasAnyOverflowedCurrency() then
			self.anyAlphaChange = true;
			self.isUpdatingPage = true;
			for _, obj in ipairs(self.activeFrames) do
				obj.toAlpha = 0;
				obj.alpha = obj:GetAlpha();
			end
			self:SetScript("OnUpdate", OnUpdate_FadeOut_ThenDisplayNextPage);
			return true;
		else
			self:TryHide();
			return false;
		end
	end

	function MainFrame:DisplayPendingLoot()
		local lootList = LootUI.GetCurrentLoot();
		if not lootList then return; end
		--loots have been sorted so the key is no longer slotIndex

		table.sort(lootList, SortFunc_LootSlot);
		self:SetManualMode(true);

		local itemFrame;
		local activeFrames = {};
		self.activeFrames = activeFrames;

		for i, data in ipairs(lootList) do
			itemFrame = self:AcquireItemFrame();
			itemFrame:SetData(data);
			activeFrames[i] = itemFrame;
			itemFrame:SetAlpha(1);
			itemFrame.toAlpha = nil;
			itemFrame:EnableMouseScript(1);
			itemFrame.hasItem = true;
		end

		local fixedFrameWidth = true;
		self:LayoutActiveFrames(fixedFrameWidth);

		self.t = 0;
		self.toAlpha = 1;
		self.alpha = self:GetAlpha();

		self:SetScript("OnUpdate", OnUpdate_FadeIn);
		self:Show();
		self:RegisterEvent("GLOBAL_MOUSE_UP");
	end

	function MainFrame:ClosePendingLoot()
		if not self:IsShown() then return; end

		self.isUpdatingPage = nil;
		self.alpha = self:GetAlpha();

		if self.activeFrames then
			for _, itemFrame in ipairs(self.activeFrames) do
				itemFrame:EnableMouseScript();
			end
		end

		self:EnableMouseScript(false);

		self:SetScript("OnUpdate", OnUpdate_FadeOut_DisableMotion);
	end

	local function OnUpdate_FadeIn_ThenHideLootedFrames(self, elapsed)
		self.alpha = self.alpha + 8*elapsed;
		if self.alpha >= 1 then
			self.alpha = 1;
			self.toAlpha = nil;
			self.t = self.t + elapsed;
			if self.t > 0.5 then
				self.t = 0;
				self:SetScript("OnUpdate", nil);
				if self.lootedFrames then
					for i, itemFrame in ipairs(self.lootedFrames) do
						itemFrame:PlaySlideOutAnimation((i - 1) * 0.1);
					end
					self.lootedFrames = nil;
				end
				if self.lootErrorCallback then
					self.lootErrorCallback(self);
					self.lootErrorCallback = nil;
				end
			end
		else
			self.t = 0;
		end
		self:SetAlpha(self.alpha);
	end

	local function MainFrame_DisplayUnlootedItems(self)
		local lootList = LootUI.GetCurrentLoot();
		if not lootList then return; end

		self:ReleaseAll();

		local itemFrame, slotIndex;
		local activeFrames = {};
		local n = 0;

		self.activeFrames = activeFrames;

		for i, data in ipairs(lootList) do
			slotIndex = data.slotIndex;
			if LootSlotHasItem(slotIndex) then
				itemFrame = self:AcquireItemFrame();
				itemFrame:SetData(data);
				n = n + 1;
				activeFrames[n] = itemFrame;
				itemFrame:SetAlpha(1);
				itemFrame.toAlpha = nil;
				itemFrame:EnableMouseScript(1);
				itemFrame.hasItem = true;

				if self.anyLootInSlot then
					if self.anyLootInSlot[slotIndex] then
						self.anyLootInSlot[slotIndex] = true;
					end
				end
			end
		end

		local fixedFrameWidth = true;
		self:LayoutActiveFrames(fixedFrameWidth);
	end

	function MainFrame:OnErrored(errorType)
		local lootList = LootUI.GetCurrentLoot();
		if not (lootList and #lootList > 0) then return; end

		if self.errorMode then return; end
		self.errorMode = true;

		self:SetManualMode(true);

		local itemFrame, slotIndex;
		local activeFrames = {};
		local lootedFrames = {};
		local n = 0;

		self.activeFrames = activeFrames;
		self.lootedFrames = lootedFrames;

		for i, data in ipairs(lootList) do
			if LootSlotHasItem(data.slotIndex) then
				data.looted = false;
			else
				data.looted = true;
			end
		end

		table.sort(lootList, SortFunc_LootSlot);

		for i, data in ipairs(lootList) do
			itemFrame = self:AcquireItemFrame();
			itemFrame:SetData(data);
			activeFrames[i] = itemFrame;
			itemFrame:SetAlpha(1);
			itemFrame.toAlpha = nil;
			slotIndex = data.slotIndex;
			if LootSlotHasItem(slotIndex) then
				itemFrame:EnableMouseScript(1);
				itemFrame.hasItem = true;
			else
				itemFrame:EnableMouseScript();
				itemFrame.hasItem = nil;
				n = n + 1;
				lootedFrames[n] = itemFrame;

				if self.anyLootInSlot then
					if self.anyLootInSlot[slotIndex] then
						self.anyLootInSlot[slotIndex] = false;
					end
				end
			end
		end

		local fixedFrameWidth = true;
		self:LayoutActiveFrames(fixedFrameWidth);

		self.t = 0;
		self.toAlpha = 1;
		self.alpha = self:GetAlpha();

		if n > 0 then
			self.lootErrorCallback = function()
				self.t = 0;
				local delay = n * 0.1 + 0.25;
				self:SetScript("OnUpdate", function(_, elapsed)
					self.t = self.t + elapsed;
					if self.t > delay then
						self:SetScript("OnUpdate", nil);
						MainFrame_DisplayUnlootedItems(self);
					end
				end);
			end
		else
			self.lootErrorCallback = nil;
		end

		self:SetScript("OnUpdate", OnUpdate_FadeIn_ThenHideLootedFrames);
		self:Show();
		self:RegisterEvent("GLOBAL_MOUSE_UP");
	end
end


-- LootFrame Mode
do
	function MainFrame:SetManualMode(state)
		state = state == true;

		if state or self.manualMode then
			self:ReleaseAll();
		elseif (not state) and self.manualMode then
			self:ReleaseAll();
		end

		self.manualMode = state;
		self:HighlightItemFrame(nil);

		if state then
			self.Header:Hide();
			self.HeaderWidgetContainer:Show();
			self:SetBackgroundAlpha(1);
			self.isFocused = false;
			if Def.LOOT_UNDER_MOUSE then
				self:PositionUnderMouse();
			end
		else
			self.Header:Show();
			self.HeaderWidgetContainer:Hide();
			self:SetBackgroundAlpha(Def.BG_OPACITY);
			if Def.LOOT_UNDER_MOUSE then
				self:LoadPosition();
			end
		end

		self:EnableMouseScript(state);
		self:AddToUISpecialFrames(state);
	end

	function MainFrame:IsInMaualModeOrEditMode()
		return self.manualMode or self.inEditMode;
	end
end


-- Loot Pickup
do
	---Used by clicking "Take All" to loot items from top to bottom
	function MainFrame:LootAllItemsSorted()
		if self.activeFrames then
			local slotIndex;
			for _, itemFrame in ipairs(self.activeFrames) do
				if itemFrame.data then
					slotIndex = itemFrame.data.slotIndex;
					if slotIndex and LootSlotHasItem(slotIndex) then
						LootSlot(slotIndex);
					end
				end
			end
		end
	end
end
