-- ItemFrame code is long so we contain it in one file.
-- This file is for simple widgets like "Take All" button and close button.


local _, addon = ...
local L = addon.L;
local API = addon.API;
local LootUI = addon.LootUI; ---@class LootUISystem
local Def = LootUI.Defination;
local Formatter = LootUI.Formatter;


-- Generic UIButton (Hotkey Button)
do
	local UIButtonMixin = {};

	function UIButtonMixin:SetHotkeyVisual(key)
		if key then
			self.hotkeyName = key;
			if API.GetModifierKeyName(key) ~= nil then
				self.HotkeyFrame.Hotkey:SetText(API.GetModifierKeyName(key));
			else
				self.HotkeyFrame.Hotkey:SetText(key);
			end
			self.HotkeyFrame:Show();
		else
			self.hotkeyName = nil;
			self.HotkeyFrame:Hide();
		end
		self:Layout();
	end

	function UIButtonMixin:SetButtonText(text)
		self.Text:SetText(text);
		self:Layout();
	end

	function UIButtonMixin:Layout()
		local textWidth = self.Text:GetUnboundedStringWidth();
		local scale = Formatter:GetPixelPerfectScale();
		self.Text:ClearAllPoints();
		local padding = 12;  --Hotkey Padding
		local buttonHeight = Formatter.UI_BUTTON_HEIGHT;
		local buttonWidth;
		local minWidth = 2 * buttonHeight;
		if self.hotkeyName then
			local bgPadding = 4;
			local bgHeight = Formatter.BASE_FONT_SIZE + 2*bgPadding;
			local bgWidth;
			if string.len(self.hotkeyName) > 1 then
				bgWidth = self.HotkeyFrame.Hotkey:GetUnboundedStringWidth() + 2*bgPadding;
			else
				bgWidth = bgHeight;
			end

			self.HotkeyFrame:SetSize(bgWidth, bgHeight);
			self.HotkeyFrame:SetPoint("LEFT", self, "LEFT", padding, 0);
			self.HotkeyFrame.HotkeyBackdrop:SetScale(scale);
			self.Text:SetPoint("LEFT", self.HotkeyFrame, "RIGHT", bgPadding, 0);
			buttonWidth = API.Round(padding + bgWidth + bgPadding + textWidth + padding);
		else
			self.Text:SetPoint("LEFT", self, "LEFT", padding, 0)
			buttonWidth = API.Round(textWidth + 2*padding);
		end

		if buttonWidth < minWidth then
			buttonWidth = minWidth;
		end

		self:SetSize(buttonWidth, buttonHeight);
	end

	function UIButtonMixin:SetHighlighted(state)
		if state then
			self.Background:SetTexCoord(136/1024, 264/1024, 72/512, 104/512);
		else
			self.Background:SetTexCoord(0, 128/1024, 72/512, 104/512);
		end
	end

	function UIButtonMixin:OnEnter()
		self:SetHighlighted(true);
		self.lootFrame:SetFocused(true);
	end

	function UIButtonMixin:OnLeave()
		self:SetHighlighted(false);
		self.lootFrame:SetFocused(false);
	end

	function LootUI.Templates.CreateUIButton(parent)
		local f = CreateFrame("Button", nil, parent, "PlumberLootUIGenericButtonTemplate");
		local file = "Interface/AddOns/Plumber/Art/LootUI/LootUI.png";
		f.HotkeyFrame.HotkeyBackdrop:SetTexture(file);
		f.HotkeyFrame.HotkeyBackdrop:SetTexCoord(16/1024, 32/1024, 40/512, 56/512);
		f.Background:SetTexture(file);
		f.Background:SetTexCoord(0, 128/1024, 72/512, 104/512);
		f.Highlight:SetTexture(file);
		f.Highlight:SetTexCoord(338/1024, 458/1024, 72/512, 104/512);
		Mixin(f, UIButtonMixin);
		f:SetScript("OnEnter", f.OnEnter);
		f:SetScript("OnLeave", f.OnLeave);
		return f;
	end
end


-- TakeAllButton
do
	local TakeAllButtonMixin = {};

	function TakeAllButtonMixin:OnClick()
		self.lootFrame:LootAllItemsSorted();
		self.AnimClick:Stop();
		self.AnimClick:Play();
		self.Highlight:Show();
	end

	function TakeAllButtonMixin:OnKeyDown(key)
		local isValid;
		if key == self.hotkeyName then
			isValid = true;
			self:OnClick();
		end
		if not InCombatLockdown() then
			self:SetPropagateKeyboardInput(not isValid);
		end
	end

	function TakeAllButtonMixin:OnEvent(event, ...)
		if event == "PLAYER_REGEN_DISABLED" then
			self:SetPropagateKeyboardInput(true);
			self:UpdateHotKey();
		elseif event == "PLAYER_REGEN_ENABLED" then
			self:UpdateHotKey();
		elseif event == "MODIFIER_STATE_CHANGED" then
			local key, down = ...
			if down == 1 and key == Def.TAKE_ALL_MODIFIER_KEY then
				self:OnClick();
			end
		end
	end

	function TakeAllButtonMixin:OnShow()
		if self.lootFrame.inEditMode then
			self:SetScript("OnKeyDown", nil);
			self:UnregisterEvent("MODIFIER_STATE_CHANGED");
			self:SetHotkeyVisual(Def.TAKE_ALL_KEY);
			return;
		end

		self:RegisterEvent("PLAYER_REGEN_DISABLED");
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		self:UpdateHotKey();
	end

	function TakeAllButtonMixin:OnHide()
		self:SetScript("OnKeyDown", nil);
		self:UnregisterEvent("PLAYER_REGEN_DISABLED");
		self:UnregisterEvent("PLAYER_REGEN_ENABLED");
		self:UnregisterEvent("MODIFIER_STATE_CHANGED");
		self.AnimClick:Stop();
		self.Highlight:Hide();
	end

	function TakeAllButtonMixin:UpdateHotKey(inCombat)
		self:SetScript("OnKeyDown", nil);
		self:UnregisterEvent("MODIFIER_STATE_CHANGED");

		if Def.USE_HOTKEY and Def.TAKE_ALL_KEY and (Def.TAKE_ALL_MODIFIER_KEY or (not (InCombatLockdown() or inCombat))) then
			self:SetHotkeyVisual(Def.TAKE_ALL_KEY);
			if Def.TAKE_ALL_MODIFIER_KEY then
				self:RegisterEvent("MODIFIER_STATE_CHANGED");
			else
				self:SetScript("OnKeyDown", self.OnKeyDown);
			end
		else
			self:SetHotkeyVisual(nil);
		end
	end

	function LootUI.Templates.CreateTakeAllButton(parent)
		local f = LootUI.Templates.CreateUIButton(parent);
		Mixin(f, TakeAllButtonMixin);
		f:SetScript("OnEvent", f.OnEvent);
		f:SetScript("OnShow", f.OnShow);
		f:SetScript("OnHide", f.OnHide);
		f:SetScript("OnClick", f.OnClick);
		f:UpdateHotKey();
		f:SetButtonText(L["Take All"]);
		return f;
	end
end


-- CloseButton
do
	local CloseButtonMixin = {};

	function CloseButtonMixin:SetHighlighted(state)
		if state then
			self.Background:SetTexCoord(32/1024, 64/1024, 104/512, 136/512);
		else
			self.Background:SetTexCoord(0, 32/1024, 104/512, 136/512);
		end
	end

	function CloseButtonMixin:OnEnter()
		self:SetHighlighted(true);
		self.lootFrame:SetFocused(true);
	end

	function CloseButtonMixin:OnLeave()
		self:SetHighlighted(false);
		self.lootFrame:SetFocused(false);
	end

	function CloseButtonMixin:OnShow()
		local a = Formatter.UI_BUTTON_HEIGHT;
		self:SetSize(a, a);
	end

	function CloseButtonMixin:OnClick()
		if not self.pauseUpdate then
			self.pauseUpdate = true;
			CloseLoot();
			C_Timer.After(0.5, function()
				self.pauseUpdate = nil;
			end);
		end
		self.lootFrame:TryHide(true);
	end

	function LootUI.Templates.CreateCloseButton(parent)
		local f = CreateFrame("Button", nil, parent, "PlumberLootUISquareIconButtonTemplate");
		Mixin(f, CloseButtonMixin);
		local file = "Interface/AddOns/Plumber/Art/LootUI/LootUI.png";
		f.Icon:SetTexture(file);
		f.Icon:SetTexCoord(64/1024, 96/1024, 104/512, 136/512);
		f.Background:SetTexture(file);
		f:SetHighlighted(false);
		f:SetScript("OnEnter", f.OnEnter);
		f:SetScript("OnLeave", f.OnLeave);
		f:SetScript("OnShow", f.OnShow);
		f:SetScript("OnClick", f.OnClick);
		f:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		return f;
	end
end


-- ItemFrame Highlight
do
	local FrameHighlightMixin = {};

	function FrameHighlightMixin:UpdatePixel()
		local scale = self:GetEffectiveScale();
		local textureHeight = Formatter:PixelSizeForScale(28, scale);
		local offsetY = Formatter:PixelSizeForScale(2, scale);
		local textureWidth = 4 * textureHeight;
		self.FeedbackFrame.TopTexture:SetSize(textureWidth, textureHeight);
		self.FeedbackFrame.BottomTexture:SetSize(textureWidth, textureHeight);
		self.FeedbackFrame.TopTexture:SetPoint("BOTTOM", self.FeedbackFrame, "TOP", 0.33*textureHeight, -offsetY);
		self.FeedbackFrame.BottomTexture:SetPoint("TOP", self.FeedbackFrame, "BOTTOM", -0.33*textureHeight, offsetY);

		Formatter:PixelPerfectTextureSlice(self.Texture);
	end

	function FrameHighlightMixin:ShowMouseDownFeedback()
		self.Texture:SetAlpha(1);
	end

	function FrameHighlightMixin:ShowMouseUpFeedback()
		self.Texture:SetAlpha(0.8);
	end

	function FrameHighlightMixin:StopClickFeedback()
		self.FeedbackFrame:Hide();
	end

	function LootUI.Templates.CreateItemFrameHighlight(parent)
		local f = CreateFrame("Frame", nil, parent, "PlumberLootUIButtonHighlightTemplate");
		f.Texture:SetTexCoord(40/1024, 420/1024, 0, 64/512);
		f.FeedbackFrame.TopTexture:SetTexCoord(272/1024, 336/1024, 74/512, 102/512);
		f.FeedbackFrame.BottomTexture:SetTexCoord(272/1024, 336/1024, 102/512, 74/512);
		Mixin(f, FrameHighlightMixin);
		f:UpdatePixel();
		f:ShowMouseUpFeedback();
		return f;
	end
end


-- Glow/Spike animation for special item
do
	local GLOW_COLORS = {
		[1] = {0.8, 0.8, 0.8},
		[2] = {0, 1, 0},
		[3] = {0, 0.5, 1},
		[4] = {0.5, 0, 1},
		[5] = {1, 0.5, 0},
	};

	local SPIKE_COLORS = {
		[3] = {0.5, 0.8, 1},
		[4] = {0.83, 0.5, 1},
	};

	local SpikeyGlowMixin = {};

	function SpikeyGlowMixin:SetFrameSize(width, height)
		self:SetSize(width, height);
		local scale = 1.75;
		self.Spike:SetSize(width * scale, height * scale);
		self.SpikeMask:SetSize(width * scale, height * scale)
		self.Glow:SetSize(2 * width, 2 * height);
		self.Exclusion:SetSize(width, height);
	end

	function SpikeyGlowMixin:SetQualityColor(quality)
		if not GLOW_COLORS[quality] then
			quality = 1;
		end
		if GLOW_COLORS[quality] then
			local c = GLOW_COLORS[quality];
			self.Glow:SetVertexColor(c[1], c[2], c[3]);
			if SPIKE_COLORS[quality] then
				c = SPIKE_COLORS[quality];
			end
			self.Spike:SetVertexColor(1, 1, 1);
		else
			self:Hide();
		end
	end

	function LootUI.Templates.CreateSpikeyGlowFrame(parent)
		local f = CreateFrame("Frame", nil, parent, "PlumberSpikeyGlowTemplate");
		Mixin(f, SpikeyGlowMixin);
		f.Glow:SetTexture("Interface/AddOns/Plumber/Art/LootUI/IconOverlay.png");
		f.Glow:SetTexCoord(0.875, 1, 0.875, 1);
		f.Spike:SetTexture("Interface/AddOns/Plumber/Art/LootUI/LootUI.png");
		f.Spike:SetTexCoord(422/1024, 494/1024, 0, 72/512);
		return f
	end
end


-- MainFrame Background
do
	local function OnUpdate_Background(self, elapsed)
		if self.toWidth then
			self.deltaValue = (self.toWidth - self.width) * 4 * elapsed;
			if self.deltaValue > -0.12 and self.deltaValue < 0.12 then
				if self.deltaValue < 0 then
					self.deltaValue = -0.12;
				else
					self.deltaValue = 0.12;
				end
			end
			self.width = self.width + self.deltaValue;
			if self.widthDelta > 0 then
				if self.width + 0.5 >= self.toWidth then
					self.width = self.toWidth;
					self.toWidth = nil;
				end
			else
				if self.width - 0.5 <= self.toWidth then
					self.width = self.toWidth;
					self.toWidth = nil;
				end
			end
		end

		if self.toHeight then
			self.deltaValue = (self.toHeight - self.height) * 4 * elapsed
			if self.deltaValue > -0.12 and self.deltaValue < 0.12 then
				if self.deltaValue < 0 then
					self.deltaValue = -0.12;
				else
					self.deltaValue = 0.12;
				end
			end
			self.height = self.height + self.deltaValue;
			if self.heightDelta > 0 then
				if self.height + 0.5 >= self.toHeight then
					self.height = self.toHeight;
					self.toHeight = nil;
				end
			else
				if self.height - 0.5 <= self.toHeight then
					self.height = self.toHeight;
					self.toHeight = nil;
				end
			end
		end

		if not (self.toWidth or self.toHeight) then
			self:SetScript("OnUpdate", nil);
		end

		self:SetBackgroundSize(self.width, self.height);
	end

	local BackgroundMixin = {};

	function BackgroundMixin:SetBackgroundSize(width, height)
		local lineLenth;

		lineLenth = height + self.lineShrink;
		self.LeftLine:SetSize(self.lineWeight, lineLenth);
		if lineLenth > self.maxLineSize then
			self.LeftLine:SetTexCoord(504/1024, 0.5, 0, 1);
		else
			self.LeftLine:SetTexCoord(504/1024, 0.5, 0, lineLenth/self.maxLineSize);
		end

		lineLenth = width + self.lineShrink;
		self.TopLine:SetSize(lineLenth, self.lineWeight);
		if lineLenth > self.maxLineSize then
			self.TopLine:SetTexCoord(0, 0.5, 504/512, 1);
		else
			self.TopLine:SetTexCoord(0, lineLenth/self.maxLineSize * 0.5, 504/512, 1);
		end

		local bgWidth = width + self.bgExtrude;
		local bgHeight = height + self.bgExtrude;

		local maxSize = (bgWidth > bgHeight and bgWidth) or bgHeight;

		if maxSize > self.maxBgSize then
			local bgScale = maxSize / self.maxBgSize;
			self.Background:SetTexCoord(0.5, 0.5 + 0.5*(bgWidth/bgScale/self.maxBgSize), 0, 1*(bgHeight/bgScale/self.maxBgSize));
			self.MaskRight:SetSize(self.bgMaskSize, maxSize + 2);
			self.MaskBottom:SetSize(maxSize + 2, self.bgMaskSize);
		else
			self.Background:SetTexCoord(0.5, 0.5 + 0.5*(bgWidth/self.maxBgSize), 0, 1*(bgHeight/self.maxBgSize));
			self.MaskRight:SetSize(self.bgMaskSize, self.maxBgSize + 2);
			self.MaskBottom:SetSize(self.maxBgSize + 2, self.bgMaskSize);
		end

		self.Background:SetSize(bgWidth, bgHeight);
		self.width = width;
		self.height = height;
	end

	function BackgroundMixin:SetBackgroundAlpha(alpha)
		self.Background:SetAlpha(alpha);
	end

	function BackgroundMixin:ShowBorderLine(state)
		self.LeftLine:SetShown(state);
		self.LeftLineEnd:SetShown(state);
		self.TopLine:SetShown(state);
		self.TopLineEnd:SetShown(state);
	end

	function BackgroundMixin:UpdatePixel()
		local scale = 1;
		local px = API.GetPixelForScale(scale, 1);

		local lineOffset = 16*px;
		local bgExtrude = 16*px;
		self.lineWeight = 8*px;
		self.lineShrink = -16*px;
		self.maxLineSize = 504*px;
		self.maxBgSize = 512*px;
		self.bgExtrude = bgExtrude;
		self.bgMaskSize = 64*px;

		self.LeftLine:ClearAllPoints();
		self.LeftLine:SetPoint("TOP", self, "TOPLEFT", 0, lineOffset);
		self.TopLine:ClearAllPoints();
		self.TopLine:SetPoint("LEFT", self, "TOPLEFT", -lineOffset, 0);

		self.LeftLineEnd:SetSize(self.lineWeight, 2*self.lineWeight);
		self.TopLineEnd:SetSize(2*self.lineWeight, self.lineWeight);

		self.Background:ClearAllPoints();
		self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", -bgExtrude, bgExtrude);

		self.MaskRight:ClearAllPoints();
		self.MaskRight:SetPoint("TOPRIGHT", self.Background, "TOPRIGHT", 0, 0);
		self.MaskBottom:ClearAllPoints();
		self.MaskBottom:SetPoint("BOTTOMLEFT", self.Background, "BOTTOMLEFT", 0, 0);
	end

	function BackgroundMixin:AnimateSize(width, height)
		if width > self.width then
			self.widthDelta = 1;
			self.toWidth = width;
		elseif width < self.width then
			self.widthDelta = -1;
			self.toWidth = width;
		end

		if height > self.height then
			self.heightDelta = 1;
			self.toHeight = height;
		elseif height < self.height then
			self.heightDelta = -1;
			self.toHeight = height;
		end

		self:SetScript("OnUpdate", OnUpdate_Background);
	end

	function LootUI.Templates.CreateFrameBackground(parent)
		local f = CreateFrame("Frame", nil, parent, "PlumberLootUIBackgroundTemplate");
		Mixin(f, BackgroundMixin);

		f:UpdatePixel();
		f:SetBackgroundSize(256, 256);
		f:SetBackgroundAlpha(0.50);

		local file = "Interface/AddOns/Plumber/Art/LootUI/LootUI.png";
		f.Background:SetTexture(file);
		f.TopLine:SetTexture(file);
		f.TopLineEnd:SetTexture(file);
		f.LeftLine:SetTexture(file);
		f.LeftLineEnd:SetTexture(file);
		f.TopLineEnd:SetTexCoord(16/1024, 0, 504/512, 1);
		f.LeftLineEnd:SetTexCoord(504/1024, 0.5, 16/512, 0);

		return f;
	end
end
