local _, addon = ...
local API = addon.API;
local L = addon.L;

local Round = API.Round;
local IsUncollectedTransmogByItemInfo = API.IsUncollectedTransmogByItemInfo;
local ipairs = ipairs;

local LootSlot = LootSlot;
local CloseLoot = CloseLoot;
local GetPhysicalScreenSize = GetPhysicalScreenSize;
local InCombatLockdown = InCombatLockdown;
local CreateFrame = CreateFrame;
local IsModifiedClick = IsModifiedClick;
local IsCosmeticItem = C_Item.IsCosmeticItem or API.Nop;
local GetItemCount = C_Item.GetItemCount;
local GetCursorPosition = GetCursorPosition;


-- User Settings
local SHOW_ITEM_COUNT = true;
local USE_HOTKEY = true;
local TAKE_ALL_KEY = "E";
local TAKE_ALL_MODIFIER_KEY = nil;  --"LALT"
local USE_MOG_MARKER = true;
local AUTO_LOOT_ENABLE_TOOLTIP = true;
------------------


local MainFrame = CreateFrame("Frame", nil, UIParent);
MainFrame:Hide();
MainFrame:SetAlpha(0);
MainFrame:SetFrameStrata("DIALOG");
MainFrame:SetToplevel(true);
MainFrame:SetClampedToScreen(true);


local P_Loot = {};
P_Loot.MainFrame = MainFrame;
addon.P_Loot = P_Loot;


local Defination = {
    SLOT_TYPE_CURRENCY = 3,
    SLOT_TYPE_MONEY = 10,       --Game value is 2, but we sort it to top
    SLOT_TYPE_REP = 9,          --Custom Value
    SLOT_TYPE_ITEM = 1,
    SLOT_TYPE_OVERFLOW = 128,   --Display overflown currency

    QUEST_TYPE_NEW = 2,
    QUEST_TYPE_ONGOING = 1,
};
P_Loot.Defination = Defination;

local IsRareItem;   --See Bottom

local Formatter = {};
P_Loot.Formatter = Formatter;
do
    Formatter.tostring = tostring;
    Formatter.strlen = string.len;

    function Formatter:Init()
        local fontSize = PlumberDB and PlumberDB.LootUI_FontSize;
        Formatter:CalculateDimensions(fontSize);

        if not self.DummyFontString then
            self.DummyFontString = MainFrame:CreateFontString(nil, "BACKGROUND", "PlumberLootUIFont");
            self.DummyFontString:Hide();
            self.DummyFontString:SetPoint("TOP", UIParent, "BOTTOM", 0, -64);
        end
    end

    function Formatter:CalculateDimensions(fontSize)
        if not (fontSize and fontSize >= 12 and fontSize <= 16) then
            fontSize = nil;
        end

        local baseFont = _G.ObjectiveTrackerFont14 or _G.GameTooltipHeader or _G.GameFontNormal;
        local fontFile, defaultFontSize = baseFont:GetFont();
        local normalizedFontSize;

        if not fontSize then
            fontSize = defaultFontSize;
        end

        local fontObject = PlumberLootUIFont;
        fontObject:SetFont(fontFile, Round(fontSize), "OUTLINE");
        fontObject:SetShadowOffset(0, 0);

        local locale = GetLocale();
        if locale == "zhCN" or locale == "zhTW" then
            normalizedFontSize = Round(0.8 * fontSize);
        else
            normalizedFontSize = fontSize;
        end

        self.BASE_FONT_SIZE = fontSize;                      --GameFontNormal
        self.ICON_SIZE = Round(32/12 * normalizedFontSize);
        self.TEXT_BUTTON_HEIGHT = Round(16/12 * normalizedFontSize);
        self.ICON_BUTTON_HEIGHT = self.ICON_SIZE;
        self.ICON_TEXT_GAP = Round(self.ICON_SIZE / 4);
        self.DOT_SIZE = Round(1.5 * normalizedFontSize);
        self.COUNT_NAME_GAP = Round(0.5 * normalizedFontSize);
        self.NAME_WIDTH = Round(16 * fontSize);
        self.BUTTON_WIDTH = self.ICON_SIZE + self.ICON_TEXT_GAP + self.BASE_FONT_SIZE + self.COUNT_NAME_GAP + self.NAME_WIDTH;
        self.BUTTON_SPACING = 12;

        self.numberWidths = {};
    end

    function Formatter:GetNumberWidth(number)
        number = number or 0;
        local digits = self.strlen(self.tostring(number));

        if not self.numberWidths[digits] then
            local text = "+";
            for i = 1, digits do
                text = text .. "8";
            end
            text = text.." ";
            self.DummyFontString:SetText(text);
            self.numberWidths[digits] = Round(self.DummyFontString:GetWidth());
        end

        return self.numberWidths[digits]
    end

    function Formatter:GetPixelPerfectScale()
        if not self.pixelPerfectScale then
            local SCREEN_WIDTH, SCREEN_HEIGHT = GetPhysicalScreenSize();
            self.pixelPerfectScale = 768/SCREEN_HEIGHT;
        end
        return self.pixelPerfectScale
    end

    function Formatter:PixelPerfectTextureSlice(object)
        object:SetScale(self:GetPixelPerfectScale());
    end

    function Formatter:PixelSizeForScale(pixelSize, objectScale)
        local scale0 = self:GetPixelPerfectScale();
        return pixelSize * scale0 / objectScale
    end
end


local FocusSolver = CreateFrame("Frame");
do
    function FocusSolver:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.05 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            if self.object and self.object:IsMouseMotionFocus() then
                self.object:OnFocused();
            end
        end
    end

    function FocusSolver:SetFocus(itemFrame)
        self.object = itemFrame;
        if itemFrame then
            if not self.t then
                self:SetScript("OnUpdate", self.OnUpdate);
            end
            self.t = 0;
        else
            self:SetScript("OnUpdate", nil);
            self.t = nil;
        end
    end

    function FocusSolver:IsLastFocus(itemFrame)
        return self.object and self.object == itemFrame
    end
end


local CreateItemFrame;
local ItemFrameMixin = {};
do  --UI ItemButton
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
                if data.slotType == Defination.SLOT_TYPE_ITEM then
                    if data.questType ~= 0 then
                        if data.questType == Defination.QUEST_TYPE_NEW then
                            f.IconOverlay:SetTexCoord(0.625, 0.75, 0, 0.125);
                        elseif data.questType == Defination.QUEST_TYPE_ONGOING then
                            f.IconOverlay:SetTexCoord(0.75, 0.875, 0, 0.125);
                        end
                        f.IconOverlay:Show();
                        self:SetBorderColor(1, 195/255, 41/255);
                    elseif data.craftQuality and data.craftQuality ~= 0 then
                        f.IconOverlay:SetTexCoord((data.craftQuality - 1) * 0.125, data.craftQuality * 0.125, 0, 0.125);
                        f.IconOverlay:Show();
                    elseif data.id then
                        if IsCosmeticItem(data.id) then
                            f.IconOverlay:SetTexCoord(0, 0.125, 0.125, 0.25);
                            f.IconOverlay:Show();
                            self:SetBorderColor(1, 0, 1);
                        elseif data.classID == 2 or data.classID == 4 then
                            if data.link then
                                if USE_MOG_MARKER and IsUncollectedTransmogByItemInfo(data.link) then
                                    f.IconOverlay:SetTexCoord(0.125, 0.25, 0.125, 0.25);
                                    f.IconOverlay:Show();
                                end
                            end
                        end
                    end

                    if SHOW_ITEM_COUNT and data.id then
                        local numOwned = GetItemCount(data.id);
                        if numOwned > 0 then
                            f.Count:SetText(numOwned);
                        end
                    end
                elseif data.slotType == Defination.SLOT_TYPE_CURRENCY then
                    local overflow, numOwned = API.WillCurrencyRewardOverflow(data.id, data.quantity);

                    if overflow then
                        self:SetBorderColor(1, 0, 0);
                        f.IconOverlay:SetTexCoord(0.875, 1, 0, 0.125);
                        f.IconOverlay:Show();
                    end

                    if SHOW_ITEM_COUNT and numOwned > 9999 then
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
                local f = MainFrame.glowFXPool:Acquire();
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
        color = color or API.GetItemQualityColor(1);
        local r, g, b = color:GetRGB();
        self.Text:SetText(name);
        self.Text:SetTextColor(r, g, b);
        self:SetBorderColor(r, g, b);
    end

    function ItemFrameMixin:SetNameByQuality(name, quality)
        quality = quality or 1;
        self.quality = quality;
        local color = API.GetItemQualityColor(quality);
        self:SetNameByColor(name, color);
    end

    function ItemFrameMixin:SetData(data)
        if self.data and self.data.quantity ~= 0 and not (self.data.toast ~= data.toast and self.data.quantity == data.quantity) then
            data.oldQuantity = self.data.quantity;
            data.quantity = self.data.quantity + data.quantity;
        end

        if data.slotType == Defination.SLOT_TYPE_ITEM then
            self:SetItem(data);
        elseif data.slotType == Defination.SLOT_TYPE_CURRENCY then
            self:SetCurrency(data);
        elseif data.slotType == Defination.SLOT_TYPE_REP then
            self:SetReputation(data);
        elseif data.slotType == Defination.SLOT_TYPE_MONEY then
            self:SetMoney(data);
        elseif data.slotType == Defination.SLOT_TYPE_OVERFLOW then
            self:SetOverflowCurrency(data);
        end

        self.data = data;
    end

    function ItemFrameMixin:SetCount(data)
        if (not data) or (data.hideCount and data.quantity < 2) then
            --We don't show equipment count unless you loot multiple of the same item (Legacy Raid)
            self.countWidth = nil;
            self.Count:Hide();
        else
            local countWidth = Formatter:GetNumberWidth(data.quantity);
            self.countWidth = countWidth;
            if data.oldQuantity then
                self:AnimateItemCount(data.oldQuantity, data.quantity);
                data.oldQuantity = nil;
            else
                self.Count:SetText("+"..data.quantity);
            end
            self.Count:Show();
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
        self:SetNameByQuality(data.name, data.quality);
        self:SetIcon(data.icon, data);
        self:SetCount(data);
        self:Layout();

        if IsRareItem(data) then
            self:ShowGlow(true);
        else
            self:ShowGlow(false);
        end

        if data.classID == 15 and data.subclassID == 4 then
            API.InquiryOpenableItem(data.id, function(bag, slot)
                self:ShowGlow(true);
            end);
        end
    end

    function ItemFrameMixin:SetCurrency(data)
        self:SetNameByQuality(data.name, data.quality);
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

    function ItemFrameMixin:IsSameItem(data)
        if self.data then
            if self.data.slotType == data.slotType then
                if data.slotType == Defination.SLOT_TYPE_REP then
                    return self.data.name == data.name
                else
                    return self.data.id == data.id
                end
            end
        end
        return false
    end

    function ItemFrameMixin:UpdatePixel()
        Formatter:PixelPerfectTextureSlice(self.IconFrame.Border);
    end

    function ItemFrameMixin:OnRemoved()
        self.data = nil;
        self:StopAnimating();
        self:ResetHoverVisual(true);
        self.hasGlowFX = nil;
        self.hasItem = nil;
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
            MainFrame:HighlightItemFrame(self);
            self:ShowHoverVisual();
        elseif self.enableState == 2 then
            --MainFrame:HighlightItemFrame(self);
        end
        FocusSolver:SetFocus(self);
        MainFrame:SetFocused(true);
    end

    function ItemFrameMixin:OnLeave()
        --Effective during Manual Mode
        GameTooltip:Hide();
        MainFrame:HighlightItemFrame(nil);
        self:ResetHoverVisual();
        FocusSolver:SetFocus(nil);
        MainFrame:SetFocused(false);
    end

    function ItemFrameMixin:OnFocused()
        --Effective during Manual Mode
        local tooltip = GameTooltip;
        if self.enableState == 1 then
            if self.data.slotType == Defination.SLOT_TYPE_ITEM then
                tooltip:SetOwner(self, "ANCHOR_RIGHT", -Formatter.BUTTON_SPACING, 0);
                tooltip:SetLootItem(self.data.slotIndex);
            elseif self.data.slotType == Defination.SLOT_TYPE_CURRENCY then
                tooltip:SetOwner(self, "ANCHOR_RIGHT", -Formatter.BUTTON_SPACING, 0);
                tooltip:SetLootCurrency(self.data.slotIndex);
            end

            local comparisonTooltip = ShoppingTooltip1;
            if comparisonTooltip and comparisonTooltip:IsShown() then
                local left1 = tooltip:GetLeft() or 0;
                local left2 = comparisonTooltip:GetLeft() or 0;
                if left2 < left1 then
                    tooltip:ClearAllPoints();
                    tooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 0);
                end
            end

        elseif self.enableState == 2 then
            if self.data.link then
                local width = self:GetWidth();
                local textWidth = self.Text:GetWrappedWidth();
                tooltip:SetOwner(self, "ANCHOR_RIGHT", -(width - textWidth - (self.textOffset or 0)), 0);
                tooltip:SetHyperlink(self.data.link);
            end
        end
    end

    function ItemFrameMixin:OnMouseDown(button)
        if button == "LeftButton" and MainFrame.ButtonHighlight:IsShown() then
            MainFrame.ButtonHighlight:ShowMouseDownFeedback();
        end
    end

    function ItemFrameMixin:OnMouseUp(button)
        MainFrame.ButtonHighlight:ShowMouseUpFeedback();
    end

    function ItemFrameMixin:OnClick(button)
        if button == "LeftButton" then
            if IsModifiedClick("DRESSUP") and not InCombatLockdown() then
                local itemID = self.data.slotType == Defination.SLOT_TYPE_ITEM and self.data.id;
                if itemID and C_Item.IsDressableItemByID(itemID) then
                    DressUpVisual(self.data.link);
                    return
                end
            end
            LootSlot(self.data.slotIndex);
            MainFrame:SetClickedFrameIndex(self.index);
        end
    end

    function ItemFrameMixin:EnableMouseScript(enableState)
        if enableState == 1 then
            --Manual Loot: Enable Clicks and Hover
            self:EnableMouse(true);
            self:EnableMouseMotion(true);
            self.enableState = 1;
        elseif enableState == 2 then
            --Auto Loot: Only enable Hover to display tooltip
            self:EnableMouse(false);
            self:EnableMouseMotion(true);
            self.enableState = 2;
        else
            --Auto Loot: Non-interactable
            self:EnableMouse(false);
            self:EnableMouseMotion(false);
            self.enableState = 0;
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

    function CreateItemFrame()
        local f = CreateFrame("Button", nil, MainFrame, "PlumberLootUIItemFrameTemplate");
        API.Mixin(f, ItemFrameMixin);
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

        return f
    end
end


do  --UI Background
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

    function MainFrame:InitBackground()
        self.InitBackground = nil;

        local f = CreateFrame("Frame", nil, self, "PlumberLootUIBackgroundTemplate");
        self.BackgroundFrame = f;
        API.Mixin(f, BackgroundMixin);
        f:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);

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

        --[[
        local tt = self:CreateTexture(nil, "BACKGROUND");
        tt:SetAllPoints(true);
        tt:SetColorTexture(1, 0, 0, 0.5);
        --]]
    end

    function MainFrame:SetBackgroundSize(width, height)
        if self:IsShown() then
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
end


local CreateUIButton
do  --UI Generic Button (Hotkey Button)
    local UIButtonMixin = {};

    function UIButtonMixin:SetHotkey(key)
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
        --self.Background:SetScale(scale);
        self.Text:ClearAllPoints();
        local padding = 12;  --Hotkey Padding
        local buttonHeight = Round(Formatter.BASE_FONT_SIZE + 2*padding);
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
            buttonWidth = Round(padding + bgWidth + bgPadding + textWidth + padding);
        else
            self.Text:SetPoint("LEFT", self, "LEFT", padding, 0)
            buttonWidth = Round(textWidth + 2*padding);
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
        MainFrame:SetFocused(true);
    end

    function UIButtonMixin:OnLeave()
        self:SetHighlighted(false);
        MainFrame:SetFocused(false);
    end

    function CreateUIButton(parent)
        local f = CreateFrame("Button", nil, parent, "PlumberLootUIGenericButtonTemplate");
        local file = "Interface/AddOns/Plumber/Art/LootUI/LootUI.png";
        f.HotkeyFrame.HotkeyBackdrop:SetTexture(file);
        f.HotkeyFrame.HotkeyBackdrop:SetTexCoord(16/1024, 32/1024, 40/512, 56/512);
        f.Background:SetTexture(file);
        f.Background:SetTexCoord(0, 128/1024, 72/512, 104/512);
        f.Highlight:SetTexture(file);
        f.Highlight:SetTexCoord(338/1024, 458/1024, 72/512, 104/512);
        API.Mixin(f, UIButtonMixin);
        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        return f
    end
end


local TakeAllButtonMixin = {};
do  --TakeAllButton
    function TakeAllButtonMixin:OnClick()
        MainFrame:LootAllItemsSorted();
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
        elseif event == "PLAYER_REGEN_ENABLED" then
            if self.hotkeyName and not self.hasOnKeyDownScript then
                self:SetScript("OnKeyDown", self.OnKeyDown);
                self.hasOnKeyDownScript = true;
            end
        elseif event == "MODIFIER_STATE_CHANGED" then
            local key, down = ...
            if down == 1 and key == TAKE_ALL_MODIFIER_KEY then
                self:OnClick();
            end
        end
    end

    function TakeAllButtonMixin:OnShow()
        if MainFrame.inEditMode then return end;

        if self.hotkeyName and (not InCombatLockdown()) or self:GetPropagateKeyboardInput() then
            self:SetScript("OnKeyDown", self.OnKeyDown);
            self.hasOnKeyDownScript = true;
        end
        self:RegisterEvent("PLAYER_REGEN_DISABLED");
        self:RegisterEvent("PLAYER_REGEN_ENABLED");
        if TAKE_ALL_MODIFIER_KEY then
            self:RegisterEvent("MODIFIER_STATE_CHANGED");
        end
    end

    function TakeAllButtonMixin:OnHide()
        self:SetScript("OnKeyDown", nil);
        self.hasOnKeyDownScript = nil;
        self:UnregisterEvent("PLAYER_REGEN_DISABLED");
        self:UnregisterEvent("PLAYER_REGEN_ENABLED");
        self:UnregisterEvent("MODIFIER_STATE_CHANGED");
        self.AnimClick:Stop();
        self.Highlight:Hide();
    end

    function TakeAllButtonMixin:UpdateHotKey()
        if USE_HOTKEY then
            self:SetHotkey(TAKE_ALL_KEY);
        else
            self:SetHotkey(nil);
        end
    end

    function TakeAllButtonMixin:OnLoad()
        self:SetScript("OnEvent", self.OnEvent);
        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);
        self:SetScript("OnClick", self.OnClick);
    end
end


local CreateSpikeyGlowFrame;
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

    function SpikeyGlowMixin:OnLoad()
        self.Glow:SetTexture("Interface/AddOns/Plumber/Art/LootUI/IconOverlay.png");
        self.Glow:SetTexCoord(0.875, 1, 0.875, 1);

        self.Spike:SetTexture("Interface/AddOns/Plumber/Art/LootUI/LootUI.png");
        self.Spike:SetTexCoord(422/1024, 494/1024, 0, 72/512);
    end

    function SpikeyGlowMixin:SetFrameSize(width, height)
        self:SetSize(width, height);
        local scale = 1.75;
        self.Spike:SetSize(width*scale, height*scale);
        self.SpikeMask:SetSize(width*scale, height*scale)
        self.Glow:SetSize(2*width, 2*height);
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
            --self.Spike:SetVertexColor(c[1], c[2], c[3]);
            self.Spike:SetVertexColor(1, 1, 1);
        else
            self:Hide();
        end
    end

    function CreateSpikeyGlowFrame(parent)
        local f = CreateFrame("Frame", nil, parent, "PlumberSpikeyGlowTemplate");
        API.Mixin(f, SpikeyGlowMixin);
        f:OnLoad();
        return f
    end
end


local ButtonHighlightMixin = {};
do
    function ButtonHighlightMixin:UpdatePixel()
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

    local function OnUpdate_ClickFeedback(self, elapsed)
        self.offsetX = self.offsetX + 512 * elapsed;
        self.alpha = self.alpha - 5 * elapsed;
        if self.alpha < 0 then
            self.alpha = 0;
            self.offsetX = 0;
            self:Hide();
            self:SetScript("OnUpdate", nil);
        else
            self:SetPoint("LEFT", self.parent, "LEFT", self.offsetX, 0);
            self:SetAlpha(self.alpha);
        end
    end

    function ButtonHighlightMixin:ShowMouseDownFeedback()
        self.Texture:SetAlpha(1);
    end

    function ButtonHighlightMixin:ShowMouseUpFeedback()
        self.Texture:SetAlpha(0.8);
    end

    function ButtonHighlightMixin:ShowClickFeedback()
        local f = self.FeedbackFrame;
        f:SetHeight(self:GetHeight());
        f:SetAlpha(1);
        f.alpha = 1;
        f.offsetX = Formatter.ICON_BUTTON_HEIGHT * 2;
        f.parent = self;
        f:ClearAllPoints();
        f:SetScript("OnUpdate", OnUpdate_ClickFeedback);
        f:Show();
    end

    function ButtonHighlightMixin:StopClickFeedback()
        self.FeedbackFrame:Hide();
    end
end


do  --UI Basic
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
        if (not AUTO_LOOT_ENABLE_TOOLTIP) or forceHide then
            self.lootQueue = nil;
            self.isUpdatingPage = nil;
            self.alpha = self:GetAlpha();
            self:SetScript("OnUpdate", OnUpdate_FadeOut);
            self:UnregisterEvent("GLOBAL_MOUSE_UP");
        else
            self.t = 0;
            self:SetScript("OnUpdate", OnUpdate_FadeOut_IfNotFocused);
        end
    end

    function MainFrame:Disable()
        if self.timerFrame then
            self.timerFrame:SetScript("OnUpdate", nil);
            self.timerFrame.t = nil;
        end

        self:Hide();
        self:SetScript("OnUpdate", nil);
    end

    function MainFrame:LoadPosition()
        self:ClearAllPoints();
        local DB = PlumberDB;
        if DB and DB.LootUI_PositionX and DB.LootUI_PositionY then
            self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", DB.LootUI_PositionX, DB.LootUI_PositionY);
        else
            local viewportWidth, viewportHeight = WorldFrame:GetSize();
            viewportWidth = math.min(viewportWidth, viewportHeight * 16/9);

            local scale = UIParent:GetEffectiveScale();
            local offsetX = math.floor((0.5 - 0.3333) * viewportWidth /scale);

            self:SetPoint("TOPLEFT", nil, "CENTER", offsetX, 0);
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

    function MainFrame:LayoutActiveFrames(fixedFrameWidth)
        if not self.activeFrames then
            self:TryHide(true);
            return
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

        --return frameWidth, frameHeight

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

    function MainFrame:Init()
        self.Init = nil;

        Formatter:Init()

        self.itemFramePool = API.CreateObjectPool(CreateItemFrame);

        local function CreatePagniation()
            local texture = self:CreateTexture(nil, "OVERLAY");
            texture:SetTexture("Interface/AddOns/Plumber/Art/LootUI/LootUI.png");
            texture:SetTexCoord(0, 32/1024, 0, 32/512);
            return texture
        end
        self.paginationPool = API.CreateObjectPool(CreatePagniation);

        self.glowFXPool = API.CreateObjectPool(CreateSpikeyGlowFrame);

        local MoneyFrame = addon.CreateMoneyDisplay(self, "PlumberLootUIFont");
        self.MoneyFrame = MoneyFrame;
        MoneyFrame:SetHeight(Formatter.TEXT_BUTTON_HEIGHT);
        MoneyFrame:Hide();
        MoneyFrame.EnableMouseScript = ItemFrameMixin.EnableMouseScript;
        MoneyFrame:SetScript("OnMouseDown", ItemFrameMixin.OnMouseDown);
        MoneyFrame:SetScript("OnEnter", ItemFrameMixin.OnEnter);
        MoneyFrame:SetScript("OnLeave", ItemFrameMixin.OnLeave);

        function MoneyFrame:SetData(data)
            if self:IsShown() then
                self:SetAmountByDelta(data.quantity, true);     --true: animate
            else
                self:SetAmount(data.quantity);
            end
        end

        function MoneyFrame:IsSameItem(data)
            return data.slotType == Defination.SLOT_TYPE_MONEY
        end

        function MoneyFrame:OnFocused()

        end

        function MoneyFrame:ResetHoverVisual()

        end

        self:InitBackground();

        local Header = self:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        self.Header = Header;
        Header:SetJustifyH("CENTER");
        Header:SetPoint("BOTTOM", self, "TOP", 0, Formatter.BUTTON_SPACING);
        Header:SetText(L["You Received"]);
        Header:SetTextColor(1, 1, 1, 0.5);
        Header:Hide();

        local ButtonHighlight = CreateFrame("Frame", nil, self, "PlumberLootUIButtonHighlightTemplate");
        self.ButtonHighlight = ButtonHighlight;
        ButtonHighlight.Texture:SetTexCoord(40/1024, 420/1024, 0, 64/512);
        ButtonHighlight.FeedbackFrame.TopTexture:SetTexCoord(272/1024, 336/1024, 74/512, 102/512);
        ButtonHighlight.FeedbackFrame.BottomTexture:SetTexCoord(272/1024, 336/1024, 102/512, 74/512);
        API.Mixin(ButtonHighlight, ButtonHighlightMixin);
        ButtonHighlight:UpdatePixel();
        ButtonHighlight:ShowMouseUpFeedback();

        local TakeAllButton = CreateUIButton(self);
        self.TakeAllButton = TakeAllButton;
        TakeAllButton:SetButtonText(L["Take All"]);
        TakeAllButton:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, Formatter.BUTTON_SPACING);
        TakeAllButton:Hide();
        API.Mixin(TakeAllButton, TakeAllButtonMixin);
        TakeAllButton:OnLoad();
        TakeAllButton:UpdateHotKey();

        self:LoadPosition();
    end

    function MainFrame:HighlightItemFrame(itemFrame)
        self.ButtonHighlight:Hide();
        self.ButtonHighlight:ClearAllPoints();
        if itemFrame then
            local spacing = Formatter.BUTTON_SPACING;
            self.ButtonHighlight:SetPoint("TOPLEFT", itemFrame, "TOPLEFT", -Formatter.ICON_BUTTON_HEIGHT, 0.5*spacing);
            self.ButtonHighlight:SetPoint("BOTTOMRIGHT", itemFrame, "BOTTOMRIGHT", 0, -0.5*spacing);
            self.ButtonHighlight:SetParent(itemFrame);
            self.ButtonHighlight:Show();
        end
    end

    function MainFrame:AcquireItemFrame()
        local f = self.itemFramePool:Acquire();
        f.Text:SetWidth(Formatter.NAME_WIDTH);
        f:SetWidth(Formatter.BUTTON_WIDTH);
        return f
    end

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

    function MainFrame:OnHide()
        if self:IsShown() then return end;  --Due to hiding UIParent
        self:ReleaseAll();
        self.isFocused = false;
        self.manualMode = nil;
        self:StopQueue();
        self:UnregisterEvent("GLOBAL_MOUSE_UP");
    end
    MainFrame:SetScript("OnHide", MainFrame.OnHide);

    function MainFrame:OnEvent(event, ...)
        if event == "GLOBAL_MOUSE_UP" then
            local button = ...
            if button == "RightButton" and self:IsMouseOver() then
                CloseLoot();
                self:TryHide(true);
            end
        end
    end
    MainFrame:SetScript("OnEvent", MainFrame.OnEvent);

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
        return (self:IsShown() and (self:IsMouseOver() or self.TakeAllButton:IsMouseOver())) or (self.OptionFrame and self.OptionFrame:IsShown() and self.OptionFrame:IsMouseOver())
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

    function MainFrame:OnEnter()
        self:SetFocused(true);
    end
    MainFrame:SetScript("OnEnter", MainFrame.OnEnter);

    function MainFrame:OnLeave()
        self:SetFocused(false);
    end
    MainFrame:SetScript("OnLeave", MainFrame.OnLeave);
end


do  --Rare Items
    local RareItems = {
        --[210796] = true,    --debug
        [210939] = true,    --Null Stone
        [224025] = true,    --Crackling Shard
        [221758] = true,    --Profaned Tinderbox
    };

    function IsRareItem(data)
        if RareItems[data.id] then
            return true;
        elseif data.classID == 15 and data.subclassID == 5 then
            --Mount
            return true
        end
    end
end


do  --Callback Registery
    local function SettingChanged_ShowItemCount(state, userInput)
        SHOW_ITEM_COUNT = state;
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_ShowItemCount", SettingChanged_ShowItemCount);

    local function SettingChanged_UseHotkey(state, userInput)
        USE_HOTKEY = state;
        if userInput then
            local button = MainFrame.TakeAllButton;
            if button then
                button:UpdateHotKey();
            end
        end
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_UseHotkey", SettingChanged_UseHotkey);

    local function SettingChanged_NewTransmogIcon(state, userInput)
        USE_MOG_MARKER = state;
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_NewTransmogIcon", SettingChanged_NewTransmogIcon);

    local function SettingChanged_HotkeyName(value, userInput)
        if not (value and type("value") == "string") then
            value = nil;
        end
        TAKE_ALL_KEY = value;
        if API.GetModifierKeyName(value) ~= nil then
            TAKE_ALL_MODIFIER_KEY = value;
        else
            TAKE_ALL_MODIFIER_KEY = nil;
        end

        if userInput then
            local button = MainFrame.TakeAllButton;
            if button then
                button:UpdateHotKey();
            end
        end
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_HotkeyName", SettingChanged_HotkeyName);
end


--[[    --Debug
C_Timer.After(0, function()
    local f = CreateSpikeyGlowFrame(UIParent);
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    f:SetQualityColor(2);
    f:SetFrameSize(Formatter.ICON_SIZE, Formatter.ICON_SIZE);
    f:Show();
    f.AnimGlow:Play();
end);
--]]