local _, addon = ...
local L = addon.L;
local API = addon.API;
local ControlCenter = addon.ControlCenter;


local Def = {
    TextureFile = "Interface/AddOns/Plumber/Art/ControlCenter/SettingsPanel.png";
    ButtonSize = 28,
    WidgetGap = 14,
    PageHeight = 576,


    TextColorNormal = {215/255, 192/255, 163/255},
    TextColorHighlight = {1, 1, 1},
};


local MainFrame = CreateFrame("Frame", nil, UIParent);
local SearchBox;
local FilterButton;
local CategoryHighlight;


local function SkinObjects(objects, texture)
    for _, obj in ipairs(objects) do
        if obj.SkinnableObjects then
            SkinObjects(obj.SkinnableObjects, texture);
        elseif obj.SetTexture then
            if obj.useTrilinearFilter then
                obj:SetTexture(texture, nil, nil, "TRILINEAR");
            else
                obj:SetTexture(texture);
            end
        end
    end
end

local function SetTexCoord(obj, x1, x2, y1, y2)
    obj:SetTexCoord(x1/1024, x2/1024, y1/1024, y2/1024);
end

local function SetTextColor(obj, color)
    obj:SetTextColor(color[1], color[2], color[3])
end


local MakeFadingObject;
do
    local FadeMixin = {};

    local function FadeIn_OnUpdate(self, elapsed)
        self.alpha = self.alpha + 5 * elapsed;
        if self.alpha >= self.fadeInAlpha then
            self:SetScript("OnUpdate", nil);
            self.alpha = self.fadeInAlpha;
        end
        self:SetAlpha(self.alpha);
    end

    local function FadeOut_OnUpdate(self, elapsed)
        self.alpha = self.alpha - 5 * elapsed;
        if self.alpha <= self.fadeOutAlpha then
            self:SetScript("OnUpdate", nil);
            self.alpha = self.fadeOutAlpha;
            if self.hideAfterFadeOut then
                self:Hide();
            end
        end
        self:SetAlpha(self.alpha);
    end

    function FadeMixin:FadeIn()
        self.alpha = self:GetAlpha();
        self:SetScript("OnUpdate", FadeIn_OnUpdate);
        self:Show();
    end

    function FadeMixin:FadeOut()
        self.alpha = self:GetAlpha();
        self:SetScript("OnUpdate", FadeOut_OnUpdate);
    end

    function FadeMixin:SetFadeInAlpha(alpha)
        if alpha <= 0.099 then
            self.fadeInAlpha = 1;
        else
            self.fadeInAlpha = alpha;
        end
    end

    function FadeMixin:SetFadeOutAlpha(alpha)
        if alpha <= 0.01 then
            self.fadeOutAlpha = 0;
            self.hideAfterFadeOut = true;
        else
            self.fadeOutAlpha = alpha;
            self.hideAfterFadeOut = false;
        end
    end

    function MakeFadingObject(obj)
        Mixin(obj, FadeMixin);
        obj:SetFadeOutAlpha(0);
        obj:SetFadeInAlpha(1);
        obj.alpha = 1;
    end
end


local CreateSearchBox;
do
    local SearchBoxMixin = {};
    local StringTrim = API.StringTrim;

    function SearchBoxMixin:SetTexture(texture)
        SkinObjects(self.SkinnableObjects, texture);
    end

    function SearchBoxMixin:SetInstruction(text)
        self.Instruction:SetText(text);
    end

    function SearchBoxMixin:OnEnable()
        self:UpdateVisual();
    end

    function SearchBoxMixin:OnDisable()
        self:UpdateVisual();
    end

    function SearchBoxMixin:UpdateVisual()
        if self:IsEnabled() then
            if self:HasFocus() then
                self:SetTextColor(1, 1, 1);
            elseif self:IsMouseMotionFocus() then
                self:SetTextColor(1, 1, 1);
            else
                SetTextColor(self, Def.TextColorNormal);
            end
            self.Left:SetDesaturated(false);
            self.Center:SetDesaturated(false);
            self.Right:SetDesaturated(false);
            self.Left:SetVertexColor(1, 1, 1);
            self.Center:SetVertexColor(1, 1, 1);
            self.Right:SetVertexColor(1, 1, 1);
        else
            self:SetTextColor(0.5, 0.5, 0.5);
            self.Left:SetDesaturated(true);
            self.Center:SetDesaturated(true);
            self.Right:SetDesaturated(true);
            self.Left:SetVertexColor(0.5, 0.5, 0.5);
            self.Center:SetVertexColor(0.5, 0.5, 0.5);
            self.Right:SetVertexColor(0.5, 0.5, 0.5);
        end
    end

    function SearchBoxMixin:OnEscapePressed()
        self:ClearFocus();
    end

    function SearchBoxMixin:OnEnterPressed()
        self:ClearFocus();
    end

    function SearchBoxMixin:OnTextChanged(userInput)
        if self.hasOnTextChangeCallback then
            self.t = 0;
            self:SetScript("OnUpdate", self.OnUpdate);
        end
        self.ResetButton:SetShown(self:HasText());
    end

    function SearchBoxMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.2 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            if self.searchFunc then
                if self:IsNumeric() then
                    self.searchFunc(self, self:GetNumber());
                else
                    self.searchFunc(self, StringTrim(self:GetText()));
                end
            end
        end
    end

    function SearchBoxMixin:SetSearchFunc(searchFunc)
        self.searchFunc = searchFunc;
        self.hasOnTextChangeCallback = searchFunc ~= nil;
    end

    function SearchBoxMixin:OnHide()
        self.t = nil;
        self:SetScript("OnUpdate", nil);
    end

    function SearchBoxMixin:UpdateText()
        local text = self:GetText();
        text = StringTrim(text);
        self:SetText(text or "");
        if text then
            self.Instruction:Hide();
            self.ResetButton:Show();
        else
            self.Instruction:Show();
            self.ResetButton:Hide();
        end
    end

    function SearchBoxMixin:OnEditFocusLost()
        self.Magnifier:SetVertexColor(0.5, 0.5, 0.5);
        self:UpdateText();
        self:UnlockHighlight();
        self:UpdateVisual();
    end

    function SearchBoxMixin:OnEditFocusGained()
        self.Instruction:Hide();
        self.Magnifier:SetVertexColor(1, 1, 1);
        self:LockHighlight();
        self:UpdateVisual();
    end

    function SearchBoxMixin:ClearText()
        self:SetText("");
        if not self:HasFocus() then
            self.Instruction:Show();
        end
    end

    function SearchBoxMixin:HasStickyFocus()
        return self:IsMouseMotionFocus() or self.ResetButton:IsMouseMotionFocus()
    end

    local function ResetButton_OnEnter(self)
        SetTexCoord(self.Texture, 904, 944, 0, 40);
    end

    local function ResetButton_OnLeave(self)
        SetTexCoord(self.Texture, 864, 904, 0, 40);
    end

    local function ResetButton_OnClick(self)
        self:GetParent():ClearText();
    end


    function CreateSearchBox(parent)
        local f = CreateFrame("EditBox", nil, parent, "PlumberEditBoxArtTemplate");
        Mixin(f, SearchBoxMixin);

        f:SetTexture(Def.TextureFile);

        SetTexCoord(f.Left, 0, 32, 0, 80);
        SetTexCoord(f.Center, 32, 160, 0, 80);
        SetTexCoord(f.Right, 160, 192, 0, 80);

        SetTexCoord(f.Magnifier, 984, 1024, 0, 40);
        f.Magnifier:SetVertexColor(0.5, 0.5, 0.5);

        f:SetInstruction(SEARCH);

        f:SetSize(168, Def.ButtonSize);

        f:SetScript("OnEditFocusGained", f.OnEditFocusGained);
        f:SetScript("OnEditFocusLost", f.OnEditFocusLost);
        f:SetScript("OnEscapePressed", f.OnEscapePressed);
        f:SetScript("OnEnterPressed", f.OnEnterPressed);
        f:SetScript("OnEnable", f.OnEnable);
        f:SetScript("OnDisable", f.OnDisable);
        f:SetScript("OnHide", f.OnHide);
        f:SetScript("OnTextChanged", f.OnTextChanged);

        f.ResetButton:SetScript("OnEnter", ResetButton_OnEnter);
        f.ResetButton:SetScript("OnLeave", ResetButton_OnLeave);
        f.ResetButton:SetScript("OnClick", ResetButton_OnClick);
        SetTexCoord(f.ResetButton.Texture, 864, 904, 0, 40);

        f:SetSearchFunc(function(self, text)
            MainFrame:RunSearch(text);
        end);

        return f
    end
end


local CreateSquareButton;
do
    local FilterButtonMixin = {};

    function FilterButtonMixin:OnMouseDown()
        if not self:IsEnabled() then return end;
        SetTexCoord(self.Texture, 320, 368, 16, 64);
    end

    function FilterButtonMixin:OnMouseUp()
        SetTexCoord(self.Texture, 272, 320, 16, 64);
    end

    function FilterButtonMixin:OnClick()

    end

    function CreateSquareButton(parent)
        local f = CreateFrame("Button", nil, parent, "PlumberSquareButtonArtTemplate");
        Mixin(f, FilterButtonMixin);
        f:SetSize(Def.ButtonSize, Def.ButtonSize);

        SkinObjects(f.SkinnableObjects, Def.TextureFile);
        SetTexCoord(f.Background, 192, 272, 0, 80);
        SetTexCoord(f.Texture, 272, 320, 16, 64);
        SetTexCoord(f.Highlight, 368, 416, 16, 64);
        f.Highlight:SetVertexColor(0.4, 0.2, 0.1);

        f:SetScript("OnMouseDown", f.OnMouseDown);
        f:SetScript("OnMouseUp", f.OnMouseUp);
        f:SetScript("OnClick", f.OnClick);

        return f
    end
end


local CreateCategoryButton;
do
    local CategoryButtonMixin = {};

    function CategoryButtonMixin:OnEnter()
        MainFrame:HighlightCategoryButton(self);
        SetTextColor(self.Text, Def.TextColorHighlight);
    end

    function CategoryButtonMixin:OnLeave()
        MainFrame:HighlightCategoryButton();
        SetTextColor(self.Text, Def.TextColorNormal);
    end

    function CategoryButtonMixin:SetCategory(text)
        self.Text:SetText(text);
        self.cateogoryName = string.lower(text);
    end

    function CategoryButtonMixin:OnClick()

    end

    function CreateCategoryButton(parent)
        local f = CreateFrame("Button", nil, parent);
        Mixin(f, CategoryButtonMixin);
        f:SetSize(120, 26);
        f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Text:SetJustifyH("LEFT");
        f.Text:SetPoint("LEFT", f, "LEFT", 9, 0);
        SetTextColor(f.Text, Def.TextColorNormal);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);

        return f
    end
end


do  --Left Section
    function MainFrame:HighlightCategoryButton(button)
        CategoryHighlight:Hide();
        CategoryHighlight:ClearAllPoints();
        if button then
            CategoryHighlight:SetAlpha(0);
            CategoryHighlight:SetPoint("CENTER", button, "CENTER", 0, 0);
            CategoryHighlight:SetParent(button);
            CategoryHighlight:FadeIn();
        end
    end
end


do  --Right Section
    function MainFrame:ShowFeaturePreview(dbKey)
        self.FeaturePreview:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/Preview_"..dbKey);
        self.FeatureDescription:SetText(ControlCenter:GetModuleDescription(dbKey));
    end
end


do  --Search
    function MainFrame:RunSearch(text)
        if text then
            text = string.lower(text);
            local find = string.find;
            for _, button in ipairs(self.CategoryButtons) do
                if find(button.cateogoryName, text) then
                    button:FadeIn();
                else
                    button:FadeOut();
                end
            end
        else
            for _, button in ipairs(self.CategoryButtons) do
                button:FadeIn();
            end
        end
    end
end


local CategoryDef = {
    "Signature", "Current Content", "Action Bars", "Chat", "Collections", "Instances", "Inventory", "Loot", "Map", "Professions", "Quests", "Unit Frame",
};


local function CreateUI()
    local function CreateBG(frame, a)
        local bg = frame:CreateTexture(nil, "BACKGROUND");
        bg:SetAllPoints(true);
        --bg:SetColorTexture(a, a, a, 1);
    end

    local height = Def.PageHeight;

    local scalerWidth = 1/ 0.85;
    local ratio_Center = 0.618;
    local sideSectionWidth = API.Round((height * scalerWidth) * (1 - ratio_Center));
    local centerSectionWidth = API.Round((height * scalerWidth) * ratio_Center);
    MainFrame:SetSize(2 * sideSectionWidth + centerSectionWidth, Def.PageHeight);
    MainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);


    local LeftSection = CreateFrame("Frame", nil, MainFrame);
    LeftSection:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 0, 0);
    LeftSection:SetPoint("BOTTOMLEFT", MainFrame, "BOTTOMLEFT", 0, 0);
    LeftSection:SetWidth(sideSectionWidth);
    CreateBG(LeftSection, 0.1);


    local RightSection = CreateFrame("Frame", nil, MainFrame);
    RightSection:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", 0, 0);
    RightSection:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 0);
    RightSection:SetWidth(sideSectionWidth);
    CreateBG(RightSection, 0.1);


    local CenterSection = CreateFrame("Frame", nil, MainFrame);
    CenterSection:SetPoint("TOPLEFT", LeftSection, "TOPRIGHT", 0, 0);
    CenterSection:SetPoint("BOTTOMRIGHT", RightSection, "BOTTOMLEFT", 0, 0);
    CreateBG(CenterSection, 0.08);


    --LeftSection
    do
        SearchBox = CreateSearchBox(LeftSection);
        SearchBox:SetPoint("TOPLEFT", LeftSection, "TOPLEFT", Def.WidgetGap, -Def.WidgetGap);
        SearchBox:SetWidth(sideSectionWidth - Def.ButtonSize - 3 * Def.WidgetGap);

        FilterButton = CreateSquareButton(LeftSection);
        FilterButton:SetPoint("LEFT", SearchBox, "RIGHT", Def.WidgetGap, 0);

        local leftListFromY = 2*Def.WidgetGap + Def.ButtonSize;

        local DivH = LeftSection:CreateTexture(nil, "OVERLAY");
        DivH:SetSize(sideSectionWidth - 0.5*Def.WidgetGap, 24);
        DivH:SetPoint("CENTER", LeftSection, "TOP", 0, -leftListFromY);
        API.DisableSharpening(DivH);
        DivH:SetTexture(Def.TextureFile);
        SetTexCoord(DivH, 416, 672, 16, 64);

        leftListFromY = leftListFromY + Def.WidgetGap;
        local categoryButtonWidth = sideSectionWidth - 2*Def.WidgetGap;
        MainFrame.CategoryButtons = {};
        for i, name in ipairs(CategoryDef) do
            local button = CreateCategoryButton(LeftSection);
            button:SetSize(categoryButtonWidth, Def.ButtonSize);
            button:SetPoint("TOPLEFT", LeftSection, "TOPLEFT", Def.WidgetGap, -leftListFromY - (i - 1) * Def.ButtonSize);
            button:SetCategory(name);
            MakeFadingObject(button);
            button:SetFadeInAlpha(1);
            button:SetFadeOutAlpha(0.5);
            MainFrame.CategoryButtons[i] = button;
        end


        CategoryHighlight = CreateFrame("Frame", nil, LeftSection);
        CategoryHighlight:Hide();
        CategoryHighlight:SetUsingParentLevel(true);
        CategoryHighlight:SetSize(categoryButtonWidth, Def.ButtonSize);
        local disableSharpenging = true;
        CategoryHighlight.BackgroundTextures = API.CreateThreeSliceTextures(CategoryHighlight, "BACKGROUND", 16, 40, 8, Def.TextureFile, disableSharpenging);
        CategoryHighlight:SetAlpha(0);
        SetTexCoord(CategoryHighlight.BackgroundTextures[1], 0, 32, 80, 160);
        SetTexCoord(CategoryHighlight.BackgroundTextures[2], 32, 160, 80, 160);
        SetTexCoord(CategoryHighlight.BackgroundTextures[3], 160, 192, 80, 160);
        MakeFadingObject(CategoryHighlight);
        CategoryHighlight:SetFadeInAlpha(1);
    end


    do  --RightSection
        local previewSize = sideSectionWidth - 2*Def.WidgetGap;

        local preview = RightSection:CreateTexture(nil, "OVERLAY");
        MainFrame.FeaturePreview = preview;
        preview:SetSize(previewSize, previewSize);
        preview:SetPoint("TOP", RightSection, "TOP", 0, -Def.WidgetGap);

        local mask = RightSection:CreateMaskTexture(nil, "OVERLAY");
        mask:SetPoint("TOPLEFT", preview, "TOPLEFT", 0, 0);
        mask:SetPoint("BOTTOMRIGHT", preview, "BOTTOMRIGHT", 0, 0);
        mask:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/PreviewMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        preview:AddMaskTexture(mask);


        local description = RightSection:CreateFontString(nil, "OVERLAY", "GameTooltipText"); --GameFontNormal (ObjectiveFont), GameTooltipTextSmall
        MainFrame.FeatureDescription = description;
        description:SetTextColor(0.659, 0.659, 0.659);    --0.5, 0.5, 0.5
        description:SetJustifyH("LEFT");
        description:SetJustifyV("TOP");
        description:SetSpacing(4);
        local visualOffset = 2;
        description:SetPoint("TOPLEFT", preview, "BOTTOMLEFT", visualOffset, -Def.WidgetGap -visualOffset);
        description:SetPoint("BOTTOMRIGHT", RightSection, "BOTTOMRIGHT", -visualOffset -Def.WidgetGap, Def.WidgetGap);
        description:SetShadowColor(0, 0, 0);
        description:SetShadowOffset(1, -1);


        MainFrame:ShowFeaturePreview("WorldMapPin_TWW")  --debug
    end


    do  --CenterSection
        local Slider = ControlCenter.CreateScrollBarWithDynamicSize(CenterSection);
        Slider:SetPoint("TOP", CenterSection, "TOPRIGHT", 0, -Def.WidgetGap)
        Slider:SetPoint("BOTTOM", CenterSection, "BOTTOMRIGHT", 0, Def.WidgetGap);
        Slider:SetFrameLevel(20);
        MainFrame.ScrollBar = Slider;
        Slider:SetVisibleExtentPercentage(0.25);
        Slider:UpdateThumbRange();
    end


    local NineSlice = addon.LandingPageUtil.CreateExpansionThemeFrame(MainFrame, 10);
    NineSlice:CoverParent(-24);
end

C_Timer.After(0, CreateUI);