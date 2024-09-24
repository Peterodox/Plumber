local _, addon = ...
local API = addon.API;


local LootSlot = LootSlot;
local GetPhysicalScreenSize = GetPhysicalScreenSize;
local ipairs = ipairs;
local CreateFrame = CreateFrame;


local MainFrame = CreateFrame("Frame");
MainFrame:Hide();
MainFrame:SetAlpha(0);

local P_Loot = {};
P_Loot.MainFrame = MainFrame;
addon.P_Loot = P_Loot;


local Defination = {
    SLOT_TYPE_CURRENCY = 3,
    SLOT_TYPE_MONEY = 10,       --Game value is 2, but we sort it to top
    SLOT_TYPE_REP = 9,          --Custom Value
    SLOT_TYPE_ITEM = 1,

    QUEST_TYPE_NEW = 2,
    QUEST_TYPE_ONGOING = 1,
};
P_Loot.Defination = Defination;


local Formatter = {};
P_Loot.Formatter = Formatter;
do
    Formatter.tostring = tostring;
    Formatter.strlen = string.len;
    local Round = API.Round;

    function Formatter:Init()
        Formatter:CalculateDimensions();

        if not self.DummyFontString then
            self.DummyFontString = MainFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
            self.DummyFontString:Hide();
            self.DummyFontString:SetPoint("TOP", UIParent, "BOTTOM", 0, -64);
        end

        local font = GameFontNormal:GetFont();
        self.DummyFontString:SetFont(font, self.BASE_FONT_SIZE, "");
        self.numberWidths = {};
    end

    function Formatter:CalculateDimensions(fontSize)
        if not fontSize then
            local _;
            _, fontSize = GameFontNormal:GetFont();
        end

        local locale = GetLocale();

        if locale == "zhCN" or locale == "zhTW" then
            fontSize = 0.8 * fontSize;
        end

        self.BASE_FONT_SIZE = fontSize;                      --GameFontNormal
        self.ICON_SIZE = Round(32/12 * fontSize);
        self.TEXT_BUTTON_HEIGHT = Round(16/12 * fontSize);
        self.ICON_BUTTON_HEIGHT = self.ICON_SIZE;
        self.ICON_TEXT_GAP = Round(self.ICON_SIZE / 4);
        self.DOT_SIZE = Round(1.5 * fontSize);
        self.COUNT_NAME_GAP = Round(0.5 * fontSize);
        self.NAME_WIDTH = Round(16 * fontSize);
        self.BUTTON_WIDTH = self.ICON_SIZE + self.ICON_TEXT_GAP + self.BASE_FONT_SIZE + self.COUNT_NAME_GAP + self.NAME_WIDTH;
        self.BUTTON_SPACING = 12;
    end

    function Formatter:GetNumberWidth(number)
        number = number or 0;
        local digits = self.strlen(self.tostring(number));

        if not self.numberWidths[digits] then
            local text = "+";
            for i = 1, digits do
                text = text .. "8";
            end
            self.DummyFontString:SetText(text);
            self.numberWidths[digits] = Round(self.DummyFontString:GetWidth());
        end

        return self.numberWidths[digits]
    end
end


local CreateItemFrame;
local ItemFrameMixin = {};
do  --UI LootButton
    function ItemFrameMixin:SetIcon(texture, data)
        self.showIcon = texture ~= nil;
        self.Count:ClearAllPoints();
        self.Text:ClearAllPoints();
        local f = self.IconFrame;
        if texture then
            local iconSize = Formatter.ICON_SIZE;
            f.Icon:SetTexture(texture);
            f:SetSize(iconSize, iconSize);
            f:SetPoint("LEFT", self, "LEFT", 0, 0);
            f.IconOverlay:SetSize(2*iconSize, 2*iconSize);
            self.Count:SetPoint("LEFT", self, "LEFT", iconSize + Formatter.ICON_TEXT_GAP, 0);
            self.Text:SetPoint("LEFT", self, "LEFT", iconSize + Formatter.ICON_TEXT_GAP, 0);
            self:SetHeight(Formatter.ICON_BUTTON_HEIGHT);

            if data then
                if data.questType ~= 0 then
                    if data.questType == Defination.QUEST_TYPE_NEW then
                        f.IconOverlay:SetTexCoord(0.625, 0.75, 0, 0.125);
                    elseif data.questType == Defination.QUEST_TYPE_ONGOING then
                        f.IconOverlay:SetTexCoord(0.75, 0.875, 0, 0.125);
                    end
                    f.IconOverlay:Show();
                    self:SetBorderColor(1, 195/255, 41/255);
                elseif data.craftQuality ~= 0 then
                    f.IconOverlay:SetTexCoord((data.craftQuality - 1) * 0.125, data.craftQuality * 0.125, 0, 0.125);
                    f.IconOverlay:Show();
                else
                    f.IconOverlay:Hide();
                end
            else
                f.IconOverlay:Hide();
            end

            f:Show();
        else
            f:Hide();
            self.Text:SetPoint("LEFT", self, "LEFT", 0, 0);
            self:SetHeight(Formatter.TEXT_BUTTON_HEIGHT);
        end
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
        self:SetNameByColor(name, API.GetItemQualityColor(quality or 1));
    end

    function ItemFrameMixin:SetData(data)
        if self.data and self.data.quantity ~= 0 then
            data.oldQuantity = self.data.quantity;
            data.quantity = self.data.quantity + data.quantity;
        end

        if data.slotType == Defination.SLOT_TYPE_ITEM then
            self:SetItem(data);
        elseif data.slotType == Defination.SLOT_TYPE_CURRENCY then
            self:SetCurrency(data);
        elseif data.slotType == Defination.SLOT_TYPE_REP then
            self:SetReputation(data);
        end

        self.data = data;
    end

    function ItemFrameMixin:SetCount(data)
        if (not data) or data.hideCount then
            self.Count:Hide();
        else
            local countWidth = Formatter:GetNumberWidth(data.quantity);
            self.Text:ClearAllPoints();
            self.Text:SetPoint("LEFT", self, "LEFT",  Formatter.ICON_SIZE + Formatter.ICON_TEXT_GAP + countWidth + Formatter.COUNT_NAME_GAP, 0);
            if data.oldQuantity then
                self:AnimateItemCount(data.oldQuantity, data.quantity);
                data.oldQuantity = nil;
            else
                self.Count:SetText("+"..data.quantity);
            end
            self.Count:Show();
        end
    end

    function ItemFrameMixin:SetItem(data)
        self:SetNameByQuality(data.name, data.quality);
        self:SetIcon(data.icon, data);
        self:SetCount(data);
    end

    function ItemFrameMixin:SetCurrency(data)
        self:SetNameByQuality(data.name, data.quality);
        self:SetIcon(data.icon);
        self:SetCount(data);
    end

    function ItemFrameMixin:SetReputation(data)
        local name = string.format("%s +%s", data.name, (data.quantity or ""));
        self:SetIcon(nil);
        self:SetCount(nil);
        self.Text:SetText(name);
        self.Text:SetTextColor(0.5, 0.5, 1);
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
        local SCREEN_WIDTH, SCREEN_HEIGHT = GetPhysicalScreenSize();
        self.IconFrame.Border:SetScale(768/SCREEN_HEIGHT);
    end

    function ItemFrameMixin:OnRemoved()
        self.data = nil;
        self:StopAnimating();
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
        --Effective during Manual Mode
        if self.data.slotType == Defination.SLOT_TYPE_ITEM then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:SetLootItem(self.data.slotIndex);
        elseif self.data.slotType == Defination.SLOT_TYPE_CURRENCY then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:SetLootCurrency(self.data.slotIndex);
        end
    end

    function ItemFrameMixin:OnLeave()
        --Effective during Manual Mode
        GameTooltip:Hide();
    end

    function ItemFrameMixin:OnMouseDown()
        LootSlot(self.data.slotIndex);
    end

    function ItemFrameMixin:EnableMouseScript(state)
        if state then
            self:EnableMouse(true);
            self:EnableMouseMotion(true);
        else
            self:EnableMouse(false);
            self:EnableMouseMotion(false);
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
        local f = CreateFrame("Frame", nil, MainFrame, "PlumberLootUIItemFrameTemplate");
        API.Mixin(f, ItemFrameMixin);
        CreateIconFrame(f);
        f:UpdatePixel();

        f.AnimItemCount.DummyCount = f.DummyCount;
        f.AnimItemCount:SetScript("OnStop", AnimItemCount_OnStop);
        f.AnimItemCount:SetScript("OnFinished", AnimItemCount_OnStop);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnMouseDown", f.OnMouseDown);

        f.scriptEnabled = true;
        f:EnableMouseScript(false);

        return f
    end


    function MainFrame:LayoutActiveFrames()
        local height = 0;
        local spacing = Formatter.BUTTON_SPACING;

        for i, itemFrame in ipairs(self.activeFrames) do
            if i == 1 then
                itemFrame:SetPoint("TOPLEFT", self, "TOPLEFT", spacing, -spacing);
            else
                itemFrame:SetPoint("TOPLEFT", self.activeFrames[i - 1], "BOTTOMLEFT", 0, -spacing);
            end
            height = height + itemFrame:GetHeight() + spacing;
        end

        local frameHeight = height + spacing;
        return frameHeight
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

        local f = CreateFrame("Frame", "TTBG", self, "PlumberLootUIBackgroundTemplate");
        self.BackgroundFrame = f;
        API.Mixin(f, BackgroundMixin);
        f:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);

        f:UpdatePixel();
        f:SetBackgroundSize(256, 256);
        f:SetBackgroundAlpha(0.6);

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