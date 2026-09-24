local _, addon = ...
local L = addon.L;
local API = addon.API;
local LootUI = addon.LootUI; ---@class LootUISystem
local Def = LootUI.Defination;
local Formatter = LootUI.Formatter;
local IsRareItem = LootUI.IsRareItem;


local AbbreviateNumbers = AbbreviateNumbers;
local IsCosmeticItem = C_Item.IsCosmeticItem or API.Nop;
local IsDressableItemByID = C_Item.IsDressableItemByID or API.Nop;
local GetItemCount = C_Item.GetItemCount;
local IsUncollectedTransmogByItemInfo = API.IsUncollectedTransmogByItemInfo;


local FocusSolver = API.CreateFocusSolver();
FocusSolver:SetUseModifierKeys(true);
FocusSolver:SetDelay(0.05);


local ANIM_DURATION_BUTTON_HOVER = 0.25;
local ANIM_OFFSET_H_BUTTON_HOVER = 8;
local Esaing_OutQuart = addon.EasingFunctions.outQuart;

local function Anim_ShiftButtonCentent_OnUpdate(self, elapsed)
	self.t = self.t + elapsed;
	if self.t < ANIM_DURATION_BUTTON_HOVER then
		self.offset = Esaing_OutQuart(self.t, 0, ANIM_OFFSET_H_BUTTON_HOVER, ANIM_DURATION_BUTTON_HOVER);
	else
		self.offset = ANIM_OFFSET_H_BUTTON_HOVER;
		self:SetScript("OnUpdate", nil);
	end
	self.Reference:SetPoint("LEFT", self, "LEFT", self.offset, 0);
end

local function Anim_ResetButtonCentent_OnUpdate(self, elapsed)
	self.t = self.t + elapsed;
	if self.t < ANIM_DURATION_BUTTON_HOVER then
		self.offset = Esaing_OutQuart(self.t, self.offset, 0, ANIM_DURATION_BUTTON_HOVER);
	else
		self.offset = 0;
		self:SetScript("OnUpdate", nil);
		self.hovered = nil;
		self.t = nil;
	end
	self.Reference:SetPoint("LEFT", self, "LEFT", self.offset, 0);
end

local function Anim_ShiftAndFadeOutButton_OnUpdate(self, elapsed)
	self.t = self.t + elapsed;
	if self.t > 0 then
		self.alpha = self.alpha - 5 * elapsed;
		if self.alpha < 0 then
			self.alpha = 0;
		end
		self:SetAlpha(self.alpha);

		self.offset = self.offset + 128 * elapsed;
		if self.t < ANIM_DURATION_BUTTON_HOVER then

		else
			self:SetScript("OnUpdate", nil);
		end
		self.Reference:SetPoint("LEFT", self, "LEFT", self.offset, 0);
	end
end


local IsMidnightCrafting = {}; -- Midnight crafting items use different crafting quality icons


---@class LootUI_ItemFrame
local ItemFrameMixin = {};

function ItemFrameMixin:ShowHoverVisual()
	self.hovered = true;
	self.t = 0;
	self:SetScript("OnUpdate", Anim_ShiftButtonCentent_OnUpdate);
end

function ItemFrameMixin:PlaySlideOutAnimation(delay)
	if false and self.hovered then
		self:Hide();
	else
		self.hovered = true;
		self.t = (delay and -delay) or 0;
		self.alpha = self:GetAlpha();
		if not self.offset then
			self.offset = 0;
		end
		self:SetScript("OnUpdate", Anim_ShiftAndFadeOutButton_OnUpdate);
	end
end

function ItemFrameMixin:ResetHoverVisual(instant)
	if self.hovered then
		self.t = 0;
		if instant then
			self.hovered = nil;
			self.offset = 0;
			self.Reference:SetPoint("LEFT", self, "LEFT", 0, 0);
			self:SetScript("OnUpdate", nil);
		else
			if not self.offset then
				self.offset = 0;
			end
			self:SetScript("OnUpdate", Anim_ResetButtonCentent_OnUpdate);
		end
	end
end

function ItemFrameMixin:SetIcon(texture, data)
	self.StackedIconContainer:Hide();
	self.showIcon = texture ~= nil;
	local f = self.IconFrame;
	if texture then
		self.hasIcon = true;
		local iconSize = Formatter.ICON_SIZE;
		f.Icon:SetTexture(texture);
		f:SetSize(iconSize, iconSize);
		f:SetPoint("LEFT", self.Reference, "LEFT", 0, 0);
		f.Count:SetText(nil);
		f.IconOverlay:Hide();
		f.IconOverlay:SetSize(2*iconSize, 2*iconSize);
		self:SetButtonHeight(Formatter.ICON_BUTTON_HEIGHT);

		if data then
			if data.locked then
				f.Icon:SetVertexColor(0.9, 0, 0);
			else
				f.Icon:SetVertexColor(1, 1, 1);
			end
			if data.slotType == Def.SLOT_TYPE_ITEM then
				if data.questType ~= 0 then
					if data.questType == Def.QUEST_TYPE_NEW then
						f.IconOverlay:SetTexCoord(0.625, 0.75, 0, 0.125);
					elseif data.questType == Def.QUEST_TYPE_ONGOING then
						f.IconOverlay:SetTexCoord(0.75, 0.875, 0, 0.125);
					end
					f.IconOverlay:Show();
					self:SetBorderColor(1, 195/255, 41/255);
				elseif data.craftQuality and data.craftQuality ~= 0 then
					if (data.craftQuality == 1 or data.craftQuality == 2) then
						if IsMidnightCrafting[data.id] == nil then
							local info = C_TradeSkillUI.GetItemReagentQualityInfo(data.id);
							if info and info.icon and string.find(info.icon, "[Qq]uality%-12") then
								IsMidnightCrafting[data.id] = true;
							else
								IsMidnightCrafting[data.id] = false;
							end
						end
					end

					if IsMidnightCrafting[data.id] then
						f.IconOverlay:SetTexCoord((data.craftQuality + 1) * 0.125, (data.craftQuality + 2) * 0.125, 0.125, 0.25);
					else
						f.IconOverlay:SetTexCoord((data.craftQuality - 1) * 0.125, data.craftQuality * 0.125, 0, 0.125);
					end

					f.IconOverlay:Show();
				elseif data.id then
					if IsCosmeticItem(data.id) then
						f.IconOverlay:SetTexCoord(0, 0.125, 0.125, 0.25);
						f.IconOverlay:Show();
						self:SetBorderColor(1, 0, 1);
					elseif data.classID == 2 or data.classID == 4 then
						if data.link then
							if Def.USE_MOG_MARKER and IsUncollectedTransmogByItemInfo(data.link) then
								f.IconOverlay:SetTexCoord(0.125, 0.25, 0.125, 0.25);
								f.IconOverlay:Show();
							end
						end
					end
				end

				self:UpdateItemCount();
			elseif data.slotType == Def.SLOT_TYPE_CURRENCY then
				local overflow, numOwned = API.WillCurrencyRewardOverflow(data.id, data.quantity);

				if overflow then
					self:SetBorderColor(1, 0, 0);
					f.IconOverlay:SetTexCoord(0.875, 1, 0, 0.125);
					f.IconOverlay:Show();
				end

				if Def.SHOW_ITEM_COUNT and numOwned > 9999 then
					f.Count:SetText(AbbreviateNumbers(numOwned));
				end
			end
		else
			f.Icon:SetVertexColor(1, 1, 1);
		end

		f:Show();
	else
		self.hasIcon = nil;
		f:Hide();
		self:SetHeight(Formatter.TEXT_BUTTON_HEIGHT);
	end
end

function ItemFrameMixin:ShowGlow(state)
	if state then
		if not self.glowFX then
			local f = self.lootFrame.glowFXPool:Acquire();
			f.glowFX = f;
			f:ClearAllPoints();
			f:SetPoint("CENTER", self.IconFrame, "CENTER", 0, 0);
			f:SetParent(self.IconFrame);
			f:SetFrameSize(Formatter.ICON_SIZE, Formatter.ICON_SIZE);
			f.AnimGlow:Play();
			f:SetQualityColor(self.quality);
			f:Show();
		end
	else
		if self.glowFX then
			self.glowFX:Release();
			self.glowFX = nil;
		end
	end
end

function ItemFrameMixin:SetButtonHeight(height)
	self:SetHeight(height);
	self.Reference:SetHeight(height);
end

function ItemFrameMixin:SetBorderColor(r, g, b)
	self.IconFrame.Border:SetVertexColor(r, g, b);
end

function ItemFrameMixin:SetNameByColor(name, color)
	color = color or LootUI.QualityColorGetter(1);
	local r, g, b = color.r, color.g, color.b;
	self.Text:SetText(name);
	self.Text:SetTextColor(r, g, b);
	self:SetBorderColor(r, g, b);
end

function ItemFrameMixin:SetNameByQuality(name, quality)
	quality = quality or 1;
	self.quality = quality;
	local color = LootUI.QualityColorGetter(quality);
	self:SetNameByColor(name, color);
end

function ItemFrameMixin:SetData(data)
	if self.data and self.data.quantity ~= 0 and not (self.data.toast ~= data.toast and self.data.quantity == data.quantity) then
		data.oldQuantity = self.data.quantity;
		data.quantity = self.data.quantity + data.quantity;
	end

	if data.slotType == Def.SLOT_TYPE_ITEM then
		if data.mergedData then
			self:SetMergedItem(data);
		else
			self:SetItem(data);
		end
	elseif data.slotType == Def.SLOT_TYPE_CURRENCY then
		self:SetCurrency(data);
	elseif data.slotType == Def.SLOT_TYPE_REP then
		self:SetReputation(data);
	elseif data.slotType == Def.SLOT_TYPE_MONEY then
		self:SetMoney(data);
	elseif data.slotType == Def.SLOT_TYPE_OVERFLOW then
		self:SetOverflowCurrency(data);
	elseif data.slotType == Def.SLOT_TYPE_CUSTOM then
		self:SetCustomInfo(data);
	end

	self.data = data;
end

function ItemFrameMixin:SetCount(data)
	if (not data) or (data.hideCount and data.quantity < 2) then
		--We don't show equipment count unless you loot multiple of the same item (Legacy Raid)
		self.countWidth = nil;
		self.Count:Hide();
	else
		local quantity = data.totalQuantity or data.quantity;
		local countWidth = Formatter:GetNumberWidth(quantity);
		self.countWidth = countWidth;
		if data.oldQuantity then
			self:AnimateItemCount(data.oldQuantity, quantity);
			data.oldQuantity = nil;
		else
			self.Count:SetText("+"..quantity);
		end
		self.Count:Show();
	end
end

function ItemFrameMixin:UpdateItemCount()
	if self.singleItemID and Def.SHOW_ITEM_COUNT then
		local numOwned = GetItemCount(self.singleItemID);
		if numOwned > 0 then
			self.IconFrame.Count:SetText(numOwned);
		end
	end
end

function ItemFrameMixin:Layout()
	local offset;

	if self.hasIcon then
		offset = Formatter.ICON_SIZE + Formatter.ICON_TEXT_GAP;
	else
		offset = 0;
	end
	self.Count:ClearAllPoints();
	self.Count:SetPoint("LEFT", self.Reference, "LEFT", offset, 0);

	if self.countWidth then
		offset = offset + self.countWidth;
	end
	self.Text:ClearAllPoints();
	self.Text:SetPoint("LEFT", self.Reference, "LEFT", offset, 0);

	self.textOffset = offset;
end

function ItemFrameMixin:SetItem(data)
	self.singleItemID = data.id;

	local showGlow, subtitle = IsRareItem(data);

	if subtitle then
		self:SetNameByQuality(string.format("%s\n|cff19ff19%s|r", data.name, subtitle), data.quality);
	else
		self:SetNameByQuality(data.name, data.quality);
	end

	self:SetIcon(data.icon, data);
	self:SetCount(data);
	self:Layout();

	if showGlow then
		self:ShowGlow(true);
	else
		self:ShowGlow(false);
	end

	--[[
	if data.classID == 15 and data.subclassID == 4 then
		API.InquiryOpenableItem(data.id, function(bag, slot)
			self:ShowGlow(true);
		end);
	end
	--]]
end

local function CreateStackedIconPool(itemFrame)
	local function OnCreate()
		local f = CreateFrame("Frame", nil, itemFrame.StackedIconContainer, "PlumberLootUISharedIconTemplate");
		return f
	end
	return API.CreateObjectPool(OnCreate);
end

local function SortFunc_Quality(a, b)
	if a.quality ~= b.quality then
		return a.quality > b.quality
	end
	return a.id > b.id
end

function ItemFrameMixin:SetMergedItem(data)
	if not self.stackedIconPool then
		self.stackedIconPool = CreateStackedIconPool(self);
	end
	self.stackedIconPool:ReleaseAll();

	local maxQuality = -1;
	local totalQuantity = 0;
	local groupID, fallbackName, bestIcon;

	table.sort(data.mergedData, SortFunc_Quality);

	for _, v in ipairs(data.mergedData) do
		if v.quality > maxQuality then
			maxQuality = v.quality;
			fallbackName = v.name;
			bestIcon = v.icon;
		end
		totalQuantity = totalQuantity + v.quantity;
		if not groupID then
			groupID = LootUI.GetItemGroupID(data.mergedData[1].id);
		end
	end

	if data.totalQuantity then
		data.oldQuantity = data.totalQuantity;
	end
	data.totalQuantity = totalQuantity;
	data.hideCount = false;

	local name;
	if maxQuality == 0 then
		name = L["Junk Items"] or fallbackName;
	else
		name = LootUI.GetItemGroupName(groupID) or fallbackName;
	end

	self:SetNameByQuality(name, maxQuality);

	local numIcons = math.min(#data.mergedData, 4);
	if numIcons > 1 then
		local overlapRatio = 0.15;
		local iconSize = Formatter.ICON_SIZE / (1 + (numIcons - 1) * overlapRatio);
		local iconOffset = iconSize * overlapRatio;
		local baseFrameLevel = self.StackedIconContainer:GetFrameLevel() + numIcons + 1;
		local fromY = Formatter.ICON_SIZE * 0.5;
		for i = 1, numIcons do
			local f = self.stackedIconPool:Acquire();
			f:SetPoint("TOPLEFT", self.Reference, "LEFT", (i - 1)*iconOffset, fromY - (i - 1)*iconOffset);
			f:SetFrameLevel(baseFrameLevel - i);
			local v = data.mergedData[i];
			f.Icon:SetTexture(v.icon);
			local color = LootUI.QualityColorGetter(v.quality);
			local r, g, b = color.r, color.g, color.b;
			--Make the icon below darker
			local a = 1 - (i - 1) * 0.2;
			f.Border:SetVertexColor(r * a, g * a, b * a);
			f.Icon:SetVertexColor(a, a, a);
			f:SetSize(iconSize, iconSize);
		end
		self.StackedIconContainer:Show();
		self.IconFrame:Hide();
		self.hasIcon = true;
	else
		self:SetIcon(bestIcon);
	end

	self:SetCount(data);
	self:Layout();
end

function ItemFrameMixin:SetCurrency(data)
	local extraTooltip = API.GetExtraTooltipForCurrency(data.id);
	local name = data.name;
	if extraTooltip then
		name = name.."\n"..extraTooltip;
	end
	self:SetNameByQuality(name, data.quality);
	self:SetIcon(data.icon, data);
	self:SetCount(data);
	self:Layout();
	self:ShowGlow(false);
end

function ItemFrameMixin:SetReputation(data)
	self:SetIcon(nil);
	if data.quantity then
		self:SetCount(data);
	else
		self:SetCount(nil);
	end
	self.Text:SetText(data.name);
	self.Text:SetTextColor(0, 0.8, 1);    --The default color (0.5, 0.5, 1) is too dark so we use INFLUENCE_COLOR
	self:Layout();
	self:ShowGlow(false);
end

function ItemFrameMixin:SetMoney(data)
	--For manual pick-up mode
	local name = string.gsub(data.name, "%c", ", ");
	self:SetIcon(data.icon);
	self:SetCount(nil);
	self:SetNameByQuality(name, 1);
	self:Layout();
	self:ShowGlow(false);
end

function ItemFrameMixin:SetOverflowCurrency(data)
	local currencyID = data.id;
	local info = C_CurrencyInfo.GetCurrencyInfo(currencyID);

	local quantity;
	local label;

	if info.useTotalEarnedForMaxQty then
		quantity = info.totalEarned;
		label = L["Total Maximum"];
	else
		quantity = info.quantity;
		label = "Total Cap: ";
	end

	local maxQuantity = info.maxQuantity or quantity;
	label = "|cffff4800"..quantity.."/"..maxQuantity.."|r";
	local name = info.name;
	local text = name.."\n"..label;

	self:SetNameByQuality(text, info.quality);
	self:SetIcon(info.iconFileID);
	self:SetBorderColor(1, 0, 0);
	self.IconFrame.IconOverlay:SetTexCoord(0.875, 1, 0, 0.125);
	self.IconFrame.IconOverlay:Show();
	self:SetCount(nil);
	self:Layout();
end

function ItemFrameMixin:SetCustomInfo(data)
	self:SetIcon(data.icon);
	self:SetCount(data);
	self:SetNameByQuality(data.name, data.quality or 1);
	self:ShowGlow(data.showGlow);
	self:Layout();
end

function ItemFrameMixin:IsSameItem(data)
	if self.data and (not self.data.mergedData) and (not data.mergedData) then
		if self.data.slotType == data.slotType and data.slotType ~= Def.SLOT_TYPE_CUSTOM then
			if data.slotType == Def.SLOT_TYPE_REP then
				return self.data.name == data.name;
			else
				return self.data.id == data.id;
			end
		end
	end
	return false;
end

function ItemFrameMixin:UpdatePixel()
	Formatter:PixelPerfectTextureSlice(self.IconFrame.Border);
end

function ItemFrameMixin:OnRemoved()
	self.data = nil;
	self.items = nil;
	self.singleItemID = nil;
	self:StopAnimating();
	self:ResetHoverVisual(true);
	self.hasGlowFX = nil;
	self.hasItem = nil;
	self.oldQuantity = nil;
end

function ItemFrameMixin:AnimateItemCount(oldValue, newValue)
	self.AnimItemCount:Stop();
	if self.Count:IsShown() then
		self.Count:SetText("+"..newValue);
		self.DummyCount:SetText("+"..oldValue);
		self.DummyCount:Show();
		self.AnimItemCount:Play();
	end
end

function ItemFrameMixin:OnEnter()
	if self.enableState == 1 then
		self.lootFrame:HighlightItemFrame(self);
		self:ShowHoverVisual();
	elseif self.enableState == 2 then
		--self.lootFrame:HighlightItemFrame(self);
	end
	FocusSolver:SetFocus(self);
	self.lootFrame:SetFocused(true);
end

function ItemFrameMixin:OnLeave()
	--Effective during Manual Mode
	GameTooltip:Hide();
	self.lootFrame:HighlightItemFrame(nil);
	self:ResetHoverVisual();
	FocusSolver:SetFocus(nil);
	self.lootFrame:SetFocused(false);
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	self:SetScript("OnEvent", nil);
end

function ItemFrameMixin:ShowTooltip()
	--Effective during Manual Mode
	local tooltip = GameTooltip;
	if self.enableState == 1 then   --Manual Loot
		if self.data.slotType == Def.SLOT_TYPE_ITEM then
			tooltip:SetOwner(self, "ANCHOR_RIGHT", -Formatter.BUTTON_SPACING, 0);
			tooltip.suppressAutomaticCompareItem = true;
			tooltip:SetLootItem(self.data.slotIndex);
		elseif self.data.slotType == Def.SLOT_TYPE_CURRENCY then
			tooltip:SetOwner(self, "ANCHOR_RIGHT", -Formatter.BUTTON_SPACING, 0);
			tooltip:SetLootCurrency(self.data.slotIndex);
		end

		local comparisonTooltip = ShoppingTooltip1;
		if comparisonTooltip and comparisonTooltip:IsShown() then
			local left1 = tooltip:GetLeft();
			local left2 = comparisonTooltip:GetLeft();
			if API.Secret_CanAccessValues(left1, left2) then
				if left2 < left1 then
					tooltip:ClearAllPoints();
					tooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 0);
				end
			end
		end

	elseif self.enableState == 2 then   --Auto Loot
		local hyperLink = self.data.mergedData and self.data.mergedData[1].link or self.data.link;
		local width = self:GetWidth();
		local textWidth = self.Text:GetWrappedWidth();
		local offset = -(width - textWidth - (self.textOffset or 0));
		if hyperLink then
			tooltip:SetOwner(self, "ANCHOR_RIGHT", offset, 0);
			tooltip.suppressAutomaticCompareItem = true;
			tooltip:SetHyperlink(hyperLink);
		elseif self.data.tooltipMethod then
			tooltip:SetOwner(self, "ANCHOR_RIGHT", offset, 0);
			tooltip[self.data.tooltipMethod](tooltip, self.data.id);
		elseif self.data.tooltipFunc then
			tooltip:SetOwner(self, "ANCHOR_RIGHT", offset, 0);
			self.data.tooltipFunc(tooltip, self.data.id, self.data);
		end
	end

	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	self:SetScript("OnEvent", self.OnEvent);
end

function ItemFrameMixin:OnFocused()
	self:ShowTooltip();
end

function ItemFrameMixin:OnMouseDown(button)
	if button == "LeftButton" and self.lootFrame.ButtonHighlight:IsShown() then
		self.lootFrame.ButtonHighlight:ShowMouseDownFeedback();
	end
end

function ItemFrameMixin:OnMouseUp(button)
	self.lootFrame.ButtonHighlight:ShowMouseUpFeedback();
end

function ItemFrameMixin:OnClick(button)
	if button == "LeftButton" or button == "EmulateLeftButton" then
		if IsModifiedClick("DRESSUP") and not InCombatLockdown() then
			local itemID = self.data.slotType == Def.SLOT_TYPE_ITEM and self.data.id;
			if itemID then
				if DressUpVisual and IsDressableItemByID(itemID) then
					DressUpVisual(self.data.link);
					return;
				end

				if C_Item.IsDecorItem and C_Item.IsDecorItem(itemID) then
					DressUpLink(self.data.link);
					return;
				end
			end
		elseif IsModifiedClick("CHATLINK") then
			if self.data.link then
				if ChatEdit_InsertLink(self.data.link) then
					return;
				elseif SocialPostFrame and Social_IsShown() then
					Social_InsertLink(self.data.link);
					return;
				end
			end
		end
		if button == "EmulateLeftButton" then
			return;
		end
		LootSlot(self.data.slotIndex);
		self.lootFrame:SetClickedFrameIndex(self.index);
	end
end

---@alias ItemFrameInteractionState
---| 0 # Non-interactable.
---| 1 # Enable Clicks and Hover. For Manual Loot.
---| 2 # Only enable Hover to display tooltip. For Loot Notification.

---@param enableState ItemFrameInteractionState?
function ItemFrameMixin:EnableMouseScript(enableState)
	if enableState == 1 then
		self:EnableMouse(true);
		self:EnableMouseMotion(true);
		self.enableState = 1;
	elseif enableState == 2 then
		self:EnableMouse(false);
		self:EnableMouseMotion(true);
		self.enableState = 2;
	else
		self:EnableMouse(false);
		self:EnableMouseMotion(false);
		self.enableState = 0;
	end
end

function ItemFrameMixin:OnEvent(event, ...)
	if event == "MODIFIER_STATE_CHANGED" then
		local key, down = ...
		if self:IsMouseMotionFocus() then  --IsModifiedClick("COMPAREITEMS")
			if key == "LSHIFT" or key == "RSHIFT" then
				self:ShowTooltip();
			end
		else
			self:UnregisterEvent(event);
		end
	end
end

local function CreateIconFrame(itemFrame)
	local f = CreateFrame("Frame", nil, itemFrame, "PlumberLootUIIconTemplate");
	f.Border:SetIgnoreParentScale(true);
	f.IconOverlay:SetTexture("Interface/AddOns/Plumber/Art/LootUI/IconOverlay.png");
	itemFrame.IconFrame = f;
	return f
end

local function AnimItemCount_OnStop(self)
	self.DummyCount:Hide();
end

function LootUI.Templates.CreateItemFrame(parent)
	local f = CreateFrame("Button", nil, parent, "PlumberLootUIItemFrameTemplate");
	API.Mixin(f, ItemFrameMixin);
	f.lootFrame = parent;
	CreateIconFrame(f);
	f:UpdatePixel();

	f.AnimItemCount.DummyCount = f.DummyCount;
	f.AnimItemCount:SetScript("OnStop", AnimItemCount_OnStop);
	f.AnimItemCount:SetScript("OnFinished", AnimItemCount_OnStop);

	f:SetScript("OnEnter", f.OnEnter);
	f:SetScript("OnLeave", f.OnLeave);
	f:SetScript("OnMouseDown", f.OnMouseDown);
	f:SetScript("OnMouseUp", f.OnMouseUp);
	f:SetScript("OnClick", f.OnClick);

	f.scriptEnabled = true;
	f:EnableMouseScript();

	return f;
end

function LootUI.Templates.CreateMoneyFrame(parent)
	local f = addon.CreateMoneyDisplay(parent, "PlumberLootUIFont");
	f:SetHeight(Formatter.TEXT_BUTTON_HEIGHT);
	f:Hide();
	f.EnableMouseScript = ItemFrameMixin.EnableMouseScript;
	f:SetScript("OnMouseDown", ItemFrameMixin.OnMouseDown);
	f:SetScript("OnEnter", ItemFrameMixin.OnEnter);
	f:SetScript("OnLeave", ItemFrameMixin.OnLeave);
	f.lootFrame = parent;

	function f:SetData(data)
		if self:IsShown() then
			self:SetAmountByDelta(data.quantity, true);     --true: animate
		else
			self:SetAmount(data.quantity);
		end
	end

	function f:IsSameItem(data)
		return data.slotType == Def.SLOT_TYPE_MONEY
	end

	function f:OnFocused()
	end

	function f:ResetHoverVisual()
	end

	return f;
end
