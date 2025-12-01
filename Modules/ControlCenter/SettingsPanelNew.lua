local _, addon = ...
local L = addon.L;
local API = addon.API;
local ControlCenter = addon.ControlCenter;
local GetDBBool = addon.GetDBBool;


local Mixin = Mixin;
local CreateFrame = CreateFrame;


local Def = {
    TextureFile = "Interface/AddOns/Plumber/Art/ControlCenter/SettingsPanel.png";
    ButtonSize = 28,
    WidgetGap = 14,
    PageHeight = 576,
    CategoryGap = 40,
    TabButtonHeight = 40,


    ChangelogLineSpacing = 4,
    ChangelogParagraphSpacing = 16,
    ChangelogIndent = 16,   --22 to match Checkbox Label


    TextColorNormal = {215/255, 192/255, 163/255},
    TextColorHighlight = {1, 1, 1},
    TextColorNonInteractable = {148/255, 124/255, 102/255},
    TextColorDisabled = {0.5, 0.5, 0.5},
    TextColorReadable = {163/255, 157/255, 147/255},
};


local MainFrame = CreateFrame("Frame", nil, UIParent, "PlumberSettingsPanelLayoutTemplate");
ControlCenter.SettingsPanel = MainFrame;
local SearchBox;
local FilterButton;
local CategoryHighlight;
local ActiveCategoryInfo = {};


local function SkinObjects(obj, texture)
    if obj.SkinnableObjects then
        for _, _obj in ipairs(obj.SkinnableObjects) do
            SkinObjects(_obj, texture)
        end
    elseif obj.SetTexture then
        if obj.useTrilinearFilter then
            obj:SetTexture(texture, nil, nil, "TRILINEAR");
        else
            obj:SetTexture(texture);
        end
    end
end

local function SetTexCoord(obj, x1, x2, y1, y2)
    obj:SetTexCoord(x1/1024, x2/1024, y1/1024, y2/1024);
end

local function SetTextColor(obj, color)
    obj:SetTextColor(color[1], color[2], color[3])
end

local function CreateNewFeatureMark(button, smallDot)
    local newTag = button:CreateTexture(nil, "OVERLAY");
    newTag:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/NewFeatureTag", nil, nil, smallDot and "TRILINEAR" or "LINEAR");
    newTag:SetSize(16, 16);
    newTag:SetPoint("RIGHT", button, "LEFT", 0, 0);
    newTag:Hide();
    if smallDot then
        newTag:SetTexCoord(0.5, 1, 0, 1);
    else
        newTag:SetTexCoord(0, 0.5, 0, 1);
    end
    return newTag
end


local MakeFadingObject;
do
    local FadeMixin = {};

    local function FadeIn_OnUpdate(self, elapsed)
        self.alpha = self.alpha + self.fadeSpeed * elapsed;
        if self.alpha >= self.fadeInAlpha then
            self:SetScript("OnUpdate", nil);
            self.alpha = self.fadeInAlpha;
        end
        self:SetAlpha(self.alpha);
    end

    local function FadeOut_OnUpdate(self, elapsed)
        self.alpha = self.alpha - self.fadeSpeed * elapsed;
        if self.alpha <= self.fadeOutAlpha then
            self:SetScript("OnUpdate", nil);
            self.alpha = self.fadeOutAlpha;
            if self.hideAfterFadeOut then
                self:Hide();
            end
        end
        self:SetAlpha(self.alpha);
    end

    function FadeMixin:FadeIn(instant)
        if instant then
            self.alpha = 1;
            self:SetScript("OnUpdate", nil);
        else
            self.alpha = self:GetAlpha();
            self:SetScript("OnUpdate", FadeIn_OnUpdate);
        end
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

    function FadeMixin:SetFadeSpeed(fadeSpeed)
        self.fadeSpeed = fadeSpeed;
    end

    function MakeFadingObject(obj)
        Mixin(obj, FadeMixin);
        obj:SetFadeOutAlpha(0);
        obj:SetFadeInAlpha(1);
        obj:SetFadeSpeed(5);
        obj.alpha = 1;
    end
end


local CreateSearchBox;
do
    local SearchBoxMixin = {};
    local StringTrim = API.StringTrim;

    function SearchBoxMixin:SetTexture(texture)
        SkinObjects(self, texture);
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


local FilterUtil = {};
do
    function FilterUtil.MenuInfoGetter()
        local tbl = {
            key = "SettingsPanelFilterMenu",
        };

        local tinsert = table.insert;

        local widgets = {
            {type = "Header", text = CLUB_FINDER_SORT_BY},
        };


        local selectedIndex = ControlCenter:UpdateCurrentSortMethod();
        for i = 1, ControlCenter:GetNumFilters() do
            tinsert(widgets, {
                type = "Radio",
                text = L["SortMethod "..i];
                closeAfterClick = true,
                onClickFunc = function()
                    ControlCenter:SetCurrentSortMethod(i);
                    MainFrame:RefreshFeatureList();
                end,
                selected = i == selectedIndex,
            });
        end


        tinsert(widgets, {type = "Divider"});
        tinsert(widgets, {type = "Header", text = L["Module Control"]});
        tinsert(widgets, {type = "Checkbox", text = L["ModuleName EnableNewByDefault"], tooltip = L["ModuleDescription EnableNewByDefault"], closeAfterClick = false,
            selected = GetDBBool("EnableNewByDefault"),
            onClickFunc = function() addon.FlipDBBool("EnableNewByDefault") end,
        });


        if ControlCenter:AnyNewFeatureMarker() then
            tinsert(widgets, {type = "Divider"});
            tinsert(widgets, {type = "Button", text = L["Remove New Feature Marker"], tooltip = L["Remove New Feature Marker Tooltip"]:format("|TInterface\\AddOns\\Plumber\\Art\\ControlCenter\\NewFeatureTooltipIcon:0:0|t"), closeAfterClick = true,
                onClickFunc = function()
                    ControlCenter:FlagCurrentNewFeatureMarkerSeen();
                    MainFrame:RefreshFeatureList();
                    for _, button in MainFrame.primaryCategoryPool:EnumerateActive() do
                        button.NewTag:Hide();
                    end
                end,
            });
        end


        tbl.widgets = widgets;
        return tbl
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
        addon.LandingPageUtil.DropdownMenu:ToggleMenu(self, FilterUtil.MenuInfoGetter);
    end


    function CreateSquareButton(parent)
        local f = CreateFrame("Button", nil, parent, "PlumberSquareButtonArtTemplate");
        Mixin(f, FilterButtonMixin);
        f:SetSize(Def.ButtonSize, Def.ButtonSize);

        SkinObjects(f, Def.TextureFile);
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
        MainFrame:HighlightButton(self);
        SetTextColor(self.Label, Def.TextColorHighlight);
    end

    function CategoryButtonMixin:OnLeave()
        MainFrame:HighlightButton();
        SetTextColor(self.Label, Def.TextColorNormal);
    end

    function CategoryButtonMixin:SetCategory(key, text, anyNewFeature)
        self.Label:SetText(text);
        self.cateogoryName = string.lower(text);
        self.categoryKey = key;

        self.NewTag:ClearAllPoints();
        self.NewTag:SetPoint("CENTER", self, "LEFT", 0, 0);
        self.NewTag:SetShown(anyNewFeature);
    end

    function CategoryButtonMixin:ShowCount(count)
        if count and count > 0 then
            self.Count:SetText(count);
            self.CountContainer:FadeIn();
        else
            self.CountContainer:FadeOut();
        end
    end

    function CategoryButtonMixin:OnClick()
        if ActiveCategoryInfo[self.categoryKey] then
            MainFrame.ModuleTab.ScrollView:ScrollTo(ActiveCategoryInfo[self.categoryKey].scrollOffset);
            addon.LandingPageUtil.PlayUISound("ScrollBarStep");
        end
    end

    function CategoryButtonMixin:OnMouseDown()
        if ActiveCategoryInfo[self.categoryKey] then
            self.Label:SetPoint("LEFT", self, "LEFT", self.labelOffset + 1, -1);
        end
    end

    function CategoryButtonMixin:OnMouseUp()
        self:ResetOffset();
    end

    function CategoryButtonMixin:ResetOffset()
        self.Label:SetPoint("LEFT", self, "LEFT", self.labelOffset, 0);
    end

    function CreateCategoryButton(parent)
        local f = CreateFrame("Button", nil, parent);
        Mixin(f, CategoryButtonMixin);
        f:SetSize(120, 26);
        f.labelOffset = 9;
        f.Label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Label:SetJustifyH("LEFT");
        f.Label:SetPoint("LEFT", f, "LEFT", 9, 0);
        SetTextColor(f.Label, Def.TextColorNormal);

        local CountContainer = CreateFrame("Frame", nil, f);
        f.CountContainer = CountContainer;
        CountContainer:SetSize(Def.ButtonSize, Def.ButtonSize);
        CountContainer:SetPoint("RIGHT", f, "RIGHT", 0, 0);
        CountContainer:Hide();
        CountContainer:SetAlpha(0);
        MakeFadingObject(CountContainer);
        CountContainer:SetFadeSpeed(8);

        f.Count = CountContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Count:SetJustifyH("RIGHT");
        f.Count:SetPoint("RIGHT", CountContainer, "RIGHT", -9, 0);
        SetTextColor(f.Count, Def.TextColorNonInteractable);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);
        f:SetScript("OnMouseDown", f.OnMouseDown);
        f:SetScript("OnMouseUp", f.OnMouseUp);

        f.NewTag = CreateNewFeatureMark(f, true);

        return f
    end
end


local OptionToggleMixin = {};
do
    function OptionToggleMixin:OnEnter()
        self.Texture:SetVertexColor(1, 1, 1);
        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        tooltip:SetText(SETTINGS, 1, 1, 1, 1);
        tooltip:Show();
    end

    function OptionToggleMixin:OnLeave()
        self:ResetVisual();
        GameTooltip:Hide();
    end

    function OptionToggleMixin:OnClick(button)
        if self.onClickFunc then
            self.onClickFunc(button);
        end
    end

    function OptionToggleMixin:SetOnClickFunc(onClickFunc)
        self.onClickFunc = onClickFunc;
    end

    function OptionToggleMixin:ResetVisual()
        self.Texture:SetVertexColor(0.65, 0.65, 0.65);
    end

    function OptionToggleMixin:OnLoad()
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnClick", self.OnClick);
        self:ResetVisual();
        self.isPlumberEditModeToggle = true;
    end
end


local CreateSettingsEntry;
do
    local EntryButtonMixin = {};

    function EntryButtonMixin:SetData(moduleData)
        self.Label:SetText(moduleData.name);
        self.dbKey = moduleData.dbKey;
        self.data = moduleData;
        self.NewTag:SetShown((not self.isChangelogButton) and moduleData.isNewFeature);
        self.OptionToggle:SetOnClickFunc(moduleData.optionToggleFunc);
        self.hasOptions = moduleData.optionToggleFunc ~= nil;
        self:UpdateState();
        self:UpdateVisual();
    end

    function EntryButtonMixin:OnEnter()
        MainFrame:HighlightButton(self);
        self:UpdateVisual();
        if not self.isChangelogButton then
            MainFrame:ShowFeaturePreview(self.data, self.parentDBKey);
        end
    end

    function EntryButtonMixin:OnLeave()
        MainFrame:HighlightButton();
        self:UpdateVisual();
    end

    function EntryButtonMixin:OnEnable()
        self:UpdateVisual();
    end

    function EntryButtonMixin:OnDisable()
        self:UpdateVisual();
    end

    function EntryButtonMixin:OnClick()
        if self.dbKey and self.data.toggleFunc then
            local newState = not GetDBBool(self.dbKey);
            addon.SetDBValue(self.dbKey, newState, true);
            self.data.toggleFunc(newState);
            if newState then
                addon.LandingPageUtil.PlayUISound("CheckboxOn");
            else
                addon.LandingPageUtil.PlayUISound("CheckboxOff");
            end
        end

        MainFrame:UpdateSettingsEntries();
    end

    function EntryButtonMixin:UpdateState()
        local disabled;
        if self.parentDBKey and not GetDBBool(self.parentDBKey) then
            disabled = true;
        end

        if GetDBBool(self.dbKey) then
            if disabled then
                SetTexCoord(self.Box, 784, 832, 64, 112);
            else
                SetTexCoord(self.Box, 736, 784, 16, 64);
            end
            self.OptionToggle:SetShown(self.hasOptions);
        else
            if disabled then
                SetTexCoord(self.Box, 784, 832, 16, 64);
            else
                SetTexCoord(self.Box, 688, 736, 16, 64);
            end
            self.OptionToggle:Hide();
        end

        if disabled then
            self:Disable();
        else
            self:Enable();
        end
    end

    function EntryButtonMixin:UpdateVisual()
        if self:IsEnabled() then
            if self:IsMouseMotionFocus() then
                SetTextColor(self.Label, Def.TextColorHighlight);
                SetTexCoord(self.OptionToggle.Texture, 904, 944, 40, 80);
            else
                SetTextColor(self.Label, Def.TextColorNormal);
                SetTexCoord(self.OptionToggle.Texture, 864, 904, 40, 80);
            end
        else
            SetTextColor(self.Label, Def.TextColorDisabled);
        end
    end

    function CreateSettingsEntry(parent)
        local f = CreateFrame("Button", nil, parent, "PlumberSettingsPanelEntryTemplate");
        Mixin(f, EntryButtonMixin);
        f:SetMotionScriptsWhileDisabled(true);
        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnEnable", f.OnEnable);
        f:SetScript("OnDisable", f.OnDisable);
        f:SetScript("OnClick", f.OnClick);
        SetTextColor(f.Label, Def.TextColorNormal);

        f.Box.useTrilinearFilter = true;
        --f.OptionToggle.Texture.useTrilinearFilter = true;
        SkinObjects(f, Def.TextureFile);

        f.NewTag = CreateNewFeatureMark(f);

        Mixin(f.OptionToggle, OptionToggleMixin);
        f.OptionToggle:OnLoad();

        return f
    end
end


local CreateSettingsHeader;
do
    local HeaderMixin = {};

    function HeaderMixin:SetText(text)
        self.Label:SetText(text)
    end


    function CreateSettingsHeader(parent)
        local f = CreateFrame("Frame", nil, parent, "PlumberSettingsPanelHeaderTemplate");
        Mixin(f, HeaderMixin);
        SetTextColor(f.Label, Def.TextColorNonInteractable);

        SkinObjects(f, Def.TextureFile);
        SetTexCoord(f.Left, 416, 456, 80, 120);
        SetTexCoord(f.Right, 456, 736, 80, 120);

        return f
    end
end


local CreateSelectionHighlight;
do
    local SelectionHighlightMixin = {};
    local outQuart = addon.EasingFunctions.outQuart;

    function SelectionHighlightMixin:FadeIn()
        self.isFading = true;
        self:SetAlpha(0);
        self.t = 0;
        self.alpha = 0;
        --self:UpdateSize();
        self:SetScript("OnUpdate", self.OnUpdate);
        self:Show();
    end

    function SelectionHighlightMixin:UpdateSize()
        local width, height = self:GetSize();
        width = width;
        self.length = 2 * (width + height);
        self.fromX = -0.5*width;
        self.fromY = 0.5*height;
        self.speed = 256;
        self.t1 = width / self.speed;
        self.t2 = (width + height) / self.speed;
        self.t3 = (2*width + height) / self.speed;
        self.t4 = (2*width + 2*height) / self.speed;
        self.Mask1:ClearAllPoints();
        self.Mask1:SetPoint("CENTER", self, "CENTER", self.fromX, self.fromY);
        self.Mask2:ClearAllPoints();
        self.Mask2:SetPoint("CENTER", self, "CENTER", -self.fromX, -self.fromY);
    end

    --[[
    function SelectionHighlightMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;

        if self.isFading then
            self.alpha = self.alpha + 5 * elapsed;
            if self.alpha > 1 then
                self.alpha = 1;
                self.isFading = nil;
            end
            self:SetAlpha(self.alpha);
        end

        if self.t > self.t4 then
            self.t = self.t - self.t4;
        end

        if self.t > self.t3 then
            self.a = (self.t - self.t3)/(self.t4 - self.t3);
            self.x = self.fromX;
            self.y =  -(1-self.a)*self.fromY + self.a*self.fromY;
        elseif self.t > self.t2 then
            self.a = (self.t - self.t2)/(self.t3 - self.t2);
            self.x = -(1-self.a)*self.fromX +self.a*self.fromX;
            self.y = -self.fromY;
        elseif self.t > self.t1 then
            self.a = (self.t - self.t1)/(self.t2 - self.t1);
            self.x = -self.fromX;
            self.y = (1-self.a)*self.fromY - self.a*self.fromY;
        else
            self.a = self.t/self.t1;
            self.x = (1-self.a)*self.fromX -self.a*self.fromX;
            self.y = self.fromY;
        end

        self.Mask1:SetPoint("CENTER", self, "CENTER", self.x, self.y);
        self.Mask2:SetPoint("CENTER", self, "CENTER", -self.x, -self.y);
    end
    --]]

    function SelectionHighlightMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;

        if self.isFading then
            self.alpha = self.alpha + 5 * elapsed;
            if self.alpha > 1 then
                self.alpha = 1;
                self.isFading = nil;
                self:SetScript("OnUpdate", nil);
            end
            self:SetAlpha(self.alpha);
        end

        --[[
        self.x = outQuart(self.t, self.fromX - 160, self.fromX, self.d);
        self.Mask1:SetPoint("CENTER", self, "CENTER", self.x, self.fromY);
        self.Mask2:SetPoint("CENTER", self, "CENTER", -self.x, -self.fromY -20);
        if self.t > self.d then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
        end
        --]]
    end

    function SelectionHighlightMixin:OnHide()
        self:Hide();
        self:ClearAllPoints();
    end

    function CreateSelectionHighlight(parent)
        local f = CreateFrame("Frame", nil, parent, "PlumberSettingsAnimSelectionTemplate");
        Mixin(f, SelectionHighlightMixin);

        SkinObjects(f, Def.TextureFile);

        SetTexCoord(f.Left, 0, 32, 80, 160);
        SetTexCoord(f.Center, 32, 160, 80, 160);
        SetTexCoord(f.Right, 160, 192, 80, 160);

        --[[
        SetTexCoord(f.Border1Left, 192, 224, 80, 160);
        SetTexCoord(f.Border2Left, 192, 224, 80, 160);
        SetTexCoord(f.Border1Center, 224, 352, 80, 160);
        SetTexCoord(f.Border2Center, 224, 352, 80, 160);
        SetTexCoord(f.Border1Right, 352, 384, 80, 160);
        SetTexCoord(f.Border2Right, 352, 384, 80, 160);
        --]]

        f.d = 0.6;
        f:Hide();
        f:SetScript("OnHide", f.OnHide);

        return f
    end
end


do  --Left Section
    function MainFrame:HighlightButton(button)
        CategoryHighlight:Hide();
        CategoryHighlight:ClearAllPoints();
        if button then
            CategoryHighlight:SetPoint("LEFT", button, "LEFT", 0, 0);
            CategoryHighlight:SetPoint("RIGHT", button, "RIGHT", 0, 0);
            CategoryHighlight:SetParent(button);
            CategoryHighlight:FadeIn();
        end
    end
end


do  --Right Section
    function MainFrame:ShowFeaturePreview(moduleData, parentDBKey)
        if not moduleData then return end;
        local desc = moduleData.description;
        local additonalDesc = moduleData.descriptionFunc and moduleData.descriptionFunc() or nil;
        if additonalDesc then
            if desc then
                desc = desc.."\n\n"..additonalDesc;
            else
                desc = additonalDesc;
            end
        end
        self.FeatureDescription:SetText(desc);
        self.FeaturePreview:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/Preview_"..(parentDBKey or moduleData.dbKey));
    end
end


do  --Search
    function MainFrame:RunSearch(text)
        if text and text ~= "" then
            self.listGetter = function()
                return ControlCenter:GetSearchResult(text);
            end;
            self:RefreshFeatureList();
            for _, button in self.primaryCategoryPool:EnumerateActive() do
                if ActiveCategoryInfo[button.categoryKey] then
                    button:FadeIn();
                    button:ShowCount(ActiveCategoryInfo[button.categoryKey].numModules)
                else
                    button:FadeOut();
                    button:ShowCount(false);
                end
            end
        else
            self.listGetter = ControlCenter.GetSortedModules;
            self:RefreshFeatureList();
            for _, button in self.primaryCategoryPool:EnumerateActive() do
                button:FadeIn();
                button:ShowCount(false);
            end
        end
    end
end


do  --Centeral
    function MainFrame:RefreshFeatureList()
        local top, bottom;
        local n = 0;
        local fromOffsetY = Def.ButtonSize;
        local offsetY = fromOffsetY;
        local content = {};

        local buttonHeight = Def.ButtonSize;
        local categoryGap = Def.CategoryGap;
        local buttonGap = 0;
        local subOptionOffset = Def.ButtonSize;
        local offsetX = 0;

        ActiveCategoryInfo = {};
        self.firstModuleData = nil;

        local sortedModule = self.listGetter and self.listGetter() or ControlCenter:GetSortedModules();

        for index, categoryInfo in ipairs(sortedModule) do   --ControlCenter:GetValidModules()
            n = n + 1;
            top = offsetY;
            bottom = offsetY + buttonHeight + buttonGap;

            ActiveCategoryInfo[categoryInfo.key] = {
                scrollOffset = top - fromOffsetY,
                numModules = categoryInfo.numModules,
            };

            content[n] = {
                dataIndex = n,
                templateKey = "Header",
                setupFunc = function(obj)
                    obj:SetText(categoryInfo.categoryName);
                end,
                top = top,
                bottom = bottom,
                offsetX = offsetX,
            };
            offsetY = bottom;

            if n == 1 then
                self.firstModuleData = categoryInfo.modules[1];
            end

            for _, data in ipairs(categoryInfo.modules) do
                n = n + 1;
                top = offsetY;
                bottom = offsetY + buttonHeight + buttonGap;
                content[n] = {
                    dataIndex = n,
                    templateKey = "Entry",
                    setupFunc = function(obj)
                        obj.parentDBKey = nil;
                        obj:SetData(data);
                    end,
                    top = top,
                    bottom = bottom,
                    offsetX = offsetX,
                };
                offsetY = bottom;

                if data.subOptions then
                    for _, v in ipairs(data.subOptions) do
                        n = n + 1;
                        top = offsetY;
                        bottom = offsetY + buttonHeight + buttonGap;
                        content[n] = {
                            dataIndex = n,
                            templateKey = "Entry",
                            setupFunc = function(obj)
                                obj.parentDBKey = data.dbKey;
                                obj:SetData(v);
                            end,
                            top = top,
                            bottom = bottom,
                            offsetX = offsetX + 0.5*subOptionOffset,
                        };
                        offsetY = bottom;
                    end
                end
            end
            offsetY = offsetY + categoryGap;
        end

        local retainPosition = true;
        self.ModuleTab.ScrollView:SetContent(content, retainPosition);

        if self.firstModuleData then
            self:ShowFeaturePreview(self.firstModuleData);
        end
    end

    function MainFrame:RefreshCategoryList()
        self.primaryCategoryPool:ReleaseAll();
        for index, categoryInfo in ipairs(ControlCenter:GetSortedModules()) do
            local categoryButton = self.primaryCategoryPool:Acquire();
            categoryButton:SetCategory(categoryInfo.key, categoryInfo.categoryName, categoryInfo.anyNewFeature);
            categoryButton:SetPoint("TOPLEFT", self.LeftSection, self.primaryCategoryPool.offsetX, self.primaryCategoryPool.leftListFromY - (index - 1) * Def.ButtonSize);
        end
    end

    function MainFrame:UpdateSettingsEntries()
        self.ModuleTab.ScrollView:CallObjectMethod("Entry", "UpdateState");
        if self.ChangelogTab.ScrollView then
            self.ChangelogTab.ScrollView:CallObjectMethod("Entry", "UpdateState");
            self.ChangelogTab.AutoShowToggle:UpdateState();
        end
    end
end



local function CreateUI()
    local pageHeight = Def.PageHeight;

    local scalerWidth = 1/ 0.85;
    local ratio_Center = 0.618;
    local sideSectionWidth = API.Round((pageHeight * scalerWidth) * (1 - ratio_Center));
    local centralSectionWidth = API.Round((pageHeight * scalerWidth) * ratio_Center);
    MainFrame:SetSize(2 * sideSectionWidth + centralSectionWidth, Def.PageHeight);
    MainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    MainFrame:SetToplevel(true);
    MainFrame:EnableMouse(true);
    MainFrame:EnableMouseMotion(true);
    MainFrame:SetScript("OnMouseWheel", function(self, delta)
    end);


    local baseFrameLevel = MainFrame:GetFrameLevel();

    local LeftSection = MainFrame.LeftSection;
    local CentralSection = MainFrame.CentralSection;
    local RightSection = MainFrame.RightSection;
    local Tab1 = MainFrame.ModuleTab;

    LeftSection:SetWidth(sideSectionWidth);
    RightSection:SetWidth(sideSectionWidth);


    --LeftSection
    do
        SearchBox = CreateSearchBox(Tab1);
        SearchBox:SetPoint("TOPLEFT", LeftSection, "TOPLEFT", Def.WidgetGap, -Def.WidgetGap);
        SearchBox:SetWidth(sideSectionWidth - Def.ButtonSize - 3 * Def.WidgetGap);

        FilterButton = CreateSquareButton(Tab1);
        FilterButton:SetPoint("LEFT", SearchBox, "RIGHT", Def.WidgetGap, 0);

        local leftListFromY = 2*Def.WidgetGap + Def.ButtonSize;

        local DivH = Tab1:CreateTexture(nil, "OVERLAY");
        DivH:SetSize(sideSectionWidth - 0.5*Def.WidgetGap, 24);
        DivH:SetPoint("CENTER", LeftSection, "TOP", 0, -leftListFromY);
        API.DisableSharpening(DivH);
        DivH:SetTexture(Def.TextureFile);
        SetTexCoord(DivH, 416, 672, 16, 64);


        leftListFromY = leftListFromY + Def.WidgetGap;
        local categoryButtonWidth = sideSectionWidth - 2*Def.WidgetGap;

        local function Category_Create()
            local obj = CreateCategoryButton(Tab1);
            obj:SetSize(categoryButtonWidth, Def.ButtonSize);
            MakeFadingObject(obj);
            obj:SetFadeInAlpha(1);
            obj:SetFadeOutAlpha(0.5);
            obj.Label:SetWidth(categoryButtonWidth - 2 * obj.labelOffset - 14);
            return obj
        end

        local function Category_Acquire(obj)
            obj:FadeIn(true);
            obj:ResetOffset();
        end

        MainFrame.primaryCategoryPool = addon.LandingPageUtil.CreateObjectPool(Category_Create, Category_Acquire);
        MainFrame.primaryCategoryPool.leftListFromY = -leftListFromY;
        MainFrame.primaryCategoryPool.offsetX = Def.WidgetGap;


        CategoryHighlight = CreateSelectionHighlight(Tab1);
        CategoryHighlight:SetSize(categoryButtonWidth, Def.ButtonSize);


        -- 6-piece Background
        local function CreatePiece(point, relativeTo, relativePoint, offsetX, offsetY, l, r, t, b)
            local tex = MainFrame.SideTab:CreateTexture(nil, "BORDER");
            tex:SetTexture(Def.TextureFile);
            tex:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
            SetTexCoord(tex, l, r, t, b);
            API.DisableSharpening(tex);
            return tex
        end

        local r1 = CreatePiece("TOP", LeftSection, "TOPRIGHT", 0, 0,    280, 360, 176, 240);
        r1:SetSize(40, 32);
        local r3 = CreatePiece("BOTTOM", LeftSection, "BOTTOMRIGHT", 0, 0,    280, 360, 832, 896);
        r3:SetSize(40, 32);
        local r2 = CreatePiece("TOPLEFT", r1, "BOTTOMLEFT", 0, 0,    280, 360, 240, 832);
        r2:SetPoint("BOTTOMRIGHT", r3, "TOPRIGHT", 0, 0);

        local l1 = CreatePiece("TOPLEFT", LeftSection, "TOPLEFT", 0, 0,    0, 280, 176, 240);
        l1:SetPoint("BOTTOMRIGHT", r1, "BOTTOMLEFT", 0, 0);
        local l3 = CreatePiece("BOTTOMLEFT", LeftSection, "BOTTOMLEFT", 0, 0,    0, 280, 832, 896);
        l3:SetPoint("TOPRIGHT", r3, "TOPLEFT", 0, 0);
        local l2 = CreatePiece("TOPLEFT", l1, "BOTTOMLEFT", 0, 0,    0, 280, 240, 832);
        l2:SetPoint("BOTTOMRIGHT", l3, "TOPRIGHT", 0, 0);
    end


    do  --RightSection
        local previewSize = sideSectionWidth - 2*Def.WidgetGap;

        local preview = Tab1:CreateTexture(nil, "OVERLAY");
        MainFrame.FeaturePreview = preview;
        preview:SetSize(previewSize, previewSize);
        preview:SetPoint("TOP", RightSection, "TOP", 0, -Def.WidgetGap);

        local mask = Tab1:CreateMaskTexture(nil, "OVERLAY");
        mask:SetPoint("TOPLEFT", preview, "TOPLEFT", 0, 0);
        mask:SetPoint("BOTTOMRIGHT", preview, "BOTTOMRIGHT", 0, 0);
        mask:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/PreviewMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        preview:AddMaskTexture(mask);


        local description = Tab1:CreateFontString(nil, "OVERLAY", "GameTooltipText"); --GameFontNormal (ObjectiveFont), GameTooltipTextSmall
        MainFrame.FeatureDescription = description;
        SetTextColor(description, Def.TextColorReadable);
        description:SetJustifyH("LEFT");
        description:SetJustifyV("TOP");
        description:SetSpacing(4);
        local visualOffset = 2;
        description:SetPoint("TOPLEFT", preview, "BOTTOMLEFT", visualOffset, -Def.WidgetGap -visualOffset);
        description:SetPoint("BOTTOMRIGHT", RightSection, "BOTTOMRIGHT", -visualOffset -Def.WidgetGap, Def.WidgetGap);
        description:SetShadowColor(0, 0, 0);
        description:SetShadowOffset(1, -1);
    end


    do  --CentralSection
        local Background = CentralSection:CreateTexture(nil, "BACKGROUND");
        Background:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/SettingsPanelBackground");
        Background:SetPoint("TOPLEFT", CentralSection, "TOPLEFT", -8, 0);
        Background:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 0);


        local ScrollBar = ControlCenter.CreateScrollBarWithDynamicSize(Tab1);
        ScrollBar:SetPoint("TOP", CentralSection, "TOPRIGHT", 0, -0.5*Def.WidgetGap)
        ScrollBar:SetPoint("BOTTOM", CentralSection, "BOTTOMRIGHT", 0, 0.5*Def.WidgetGap);
        ScrollBar:SetFrameLevel(20);
        MainFrame.ModuleTab.ScrollBar = ScrollBar;
        ScrollBar:UpdateThumbRange();


        local ScrollView = API.CreateScrollView(Tab1, ScrollBar);
        MainFrame.ModuleTab.ScrollView = ScrollView;
        ScrollBar.ScrollView = ScrollView;
        ScrollView:SetPoint("TOPLEFT", CentralSection, "TOPLEFT", 0, -2);
        ScrollView:SetPoint("BOTTOMRIGHT", CentralSection, "BOTTOMRIGHT", 0, 2);
        ScrollView:SetStepSize(Def.ButtonSize * 2);
        ScrollView:OnSizeChanged();
        ScrollView:EnableMouseBlocker(true);
        ScrollView:SetBottomOvershoot(Def.CategoryGap);
        ScrollView:SetAlwaysShowScrollBar(true);
        ScrollView:SetShowNoContentAlert(true);
        ScrollView:SetNoContentAlertText(CATALOG_SHOP_NO_SEARCH_RESULTS);


        local centerButtonWidth = API.Round(centralSectionWidth - 2*Def.ButtonSize);
        Def.centerButtonWidth = centerButtonWidth;

        local function EntryButton_Create()
            local obj = CreateSettingsEntry(ScrollView);
            obj:SetSize(centerButtonWidth, Def.ButtonSize);
            return obj
        end

        ScrollView:AddTemplate("Entry", EntryButton_Create);


        local function Header_Create()
            local obj = CreateSettingsHeader(ScrollView);
            obj:SetSize(centerButtonWidth, Def.ButtonSize);
            return obj
        end

        ScrollView:AddTemplate("Header", Header_Create);
    end


    local NineSlice = addon.LandingPageUtil.CreateExpansionThemeFrame(MainFrame, 10);
    MainFrame.NineSlice = NineSlice;
    NineSlice:CoverParent(-24);
    NineSlice.Background:Hide();
    NineSlice:SetUsingParentLevel(false);
    NineSlice:SetFrameLevel(baseFrameLevel + 20);
    NineSlice:ShowCloseButton(true);
    NineSlice:SetCloseButtonOwner(MainFrame);


    Tab1:SetScript("OnShow", function()
        MainFrame:RefreshFeatureList();
    end);
end

function MainFrame:UpdateLayout()
    local frameWidth = math.floor(self:GetWidth() + 0.5);
    if frameWidth == self.frameWidth then
        return
    end
    self.frameWidth = frameWidth;

    self.ModuleTab.ScrollView:OnSizeChanged();
    self.ModuleTab.ScrollBar:OnSizeChanged();

    if self.ChangelogTab.ScrollView then
        self.ChangelogTab.ScrollView:OnSizeChanged();
        self.ChangelogTab.ScrollBar:OnSizeChanged();
    end
end


local InitChangelogTab;
do  --ChangelogTab
    local Formatter = {};

    Formatter.TagFonts = {
        ["h1"] = "PlumberFont_16",
        ["p"] = "GameFontNormal",
    };

    function Formatter:GetTextHeight(fontTag, text, width)
        if not self.UtilityFontString then
            local UtilityFontString = MainFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
            UtilityFontString:SetJustifyH("LEFT");
            UtilityFontString:SetPoint("TOP", UIParent, "BOTTOM", 0, -4);
            self.UtilityFontString = UtilityFontString;
        end

        self.UtilityFontString:SetSpacing(Def.ChangelogLineSpacing);
        self.UtilityFontString:SetSize(width or Def.centerButtonWidth, 0);
        if fontTag ~= self.utilityFontTag then
            self.utilityFontTag = fontTag;
            self.UtilityFontString:SetFontObject(self.TagFonts[fontTag]);
        end
        self.UtilityFontString:SetText(text);
        local height = self.UtilityFontString:GetHeight();
        self.UtilityFontString:SetText(nil);
        return height
    end


    function InitChangelogTab()
        local LeftSection = MainFrame.LeftSection;
        local CentralSection = MainFrame.CentralSection;
        local Tab2 = MainFrame.ChangelogTab;


        --local Background = Tab2:CreateTexture(nil, "BACKGROUND");
        --Background:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/SettingsPanelBackground");
        --Background:SetPoint("TOPLEFT", CentralSection, "TOPLEFT", -8, 0);
        --Background:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 0);

        local scrollBarOffsetX = 12;
        local ScrollBar = ControlCenter.CreateScrollBarWithDynamicSize(Tab2);
        ScrollBar:SetPoint("TOP", MainFrame, "TOPRIGHT", -scrollBarOffsetX, -32);
        ScrollBar:SetPoint("BOTTOM", MainFrame, "BOTTOMRIGHT", -scrollBarOffsetX, 0.5*Def.WidgetGap);
        ScrollBar:SetFrameLevel(20);
        Tab2.ScrollBar = ScrollBar;
        ScrollBar:UpdateThumbRange();


        local ScrollView = API.CreateScrollView(Tab2, ScrollBar);
        Tab2.ScrollView = ScrollView;
        ScrollBar.ScrollView = ScrollView;
        ScrollView:SetPoint("TOPLEFT", CentralSection, "TOPLEFT", 0, -2);
        ScrollView:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 2);
        ScrollView:SetStepSize(Def.ButtonSize * 2);
        ScrollView:OnSizeChanged();
        ScrollView:EnableMouseBlocker(true);
        ScrollView:SetBottomOvershoot(Def.CategoryGap);
        ScrollView:SetAlwaysShowScrollBar(false);
        ScrollView.renderAllObjects = true;     --debug


        local function CreateFontString()
            local fontString = ScrollView:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            fontString:SetSpacing(Def.ChangelogLineSpacing);
            fontString:SetJustifyH("LEFT")
            return fontString
        end

        local function RemoveFontString(fontString)
            fontString:SetText(nil);
            fontString:Hide();
            fontString:ClearAllPoints();
        end

        ScrollView:AddTemplate("FontString", CreateFontString, RemoveFontString);


        local function EntryButton_Create()
            local obj = CreateSettingsEntry(ScrollView);
            obj:SetSize(Def.centerButtonWidth + 6, Def.ButtonSize);
            obj.isChangelogButton = true;
            return obj
        end

        ScrollView:AddTemplate("Entry", EntryButton_Create);


        local function CreateTextureObject()
            local texture = ScrollView:CreateTexture(nil, "OVERLAY");
            texture:SetTexture(Def.TextureFile);
            texture:SetSize(8, 8);
            return texture
        end

        local function RemoveTextureObject(obj)
            obj:ClearAllPoints();
            obj:Hide();
        end

        ScrollView:AddTemplate("Texture", CreateTextureObject, RemoveTextureObject);


        local DivH = Tab2:CreateTexture(nil, "OVERLAY");
        local sideSectionWidth = LeftSection:GetWidth();
        DivH:SetSize(sideSectionWidth - 0.5*Def.WidgetGap, 24);
        DivH:SetPoint("CENTER", LeftSection, "BOTTOM", 0, 2*Def.WidgetGap + Def.ButtonSize);
        API.DisableSharpening(DivH);
        DivH:SetTexture(Def.TextureFile);
        SetTexCoord(DivH, 416, 672, 16, 64);


        local AutoShowToggle = CreateSettingsEntry(Tab2);
        AutoShowToggle:SetSize(sideSectionWidth - 2*Def.WidgetGap, Def.ButtonSize);
        AutoShowToggle:SetPoint("BOTTOM", LeftSection, "BOTTOM", 0, Def.WidgetGap);

        local AutoShowToggleData = {
            name = L["Auto Show Relase Notes"],
            dbKey = "SettingsPanel_AutoShowChangelog",
            toggleFunc = function() end,
        };

        AutoShowToggle:SetData(AutoShowToggleData);
        Tab2.AutoShowToggle = AutoShowToggle;

        MainFrame:ShowLatestChangelog();
    end


    function MainFrame:ShowChangelog(versionID)
        local changelog = ControlCenter.changelogs[versionID];
        if not changelog then return end;

        local top, bottom;
        local n = 0;
        local objectWidth = Def.centerButtonWidth;
        local fromOffsetY = 1.5 * Def.ButtonSize;
        local leftOffset = 1.5 * Def.ButtonSize;
        local offsetY = fromOffsetY;
        local content = {};
        local objectHeight;

        for i, info in ipairs(changelog) do
            top = offsetY;

            if info.type == "h1" or info.type == "p" then
                local textWidth;
                if info.bullet then
                    textWidth = objectWidth - Def.ChangelogIndent;
                else
                    textWidth = objectWidth;
                end
                objectHeight = Formatter:GetTextHeight(info.type, info.text, textWidth);
                bottom = offsetY + objectHeight;
                if not (changelog[i + 1] and changelog[i + 1].type == "Checkbox") then
                    bottom = bottom + Def.ChangelogParagraphSpacing;
                end

                n = n + 1;
                content[n] = {
                    dataIndex = n,
                    templateKey = "FontString",
                    top = top,
                    bottom = bottom,
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    setupFunc = function(obj)
                        obj:SetWidth(textWidth);
                        obj:SetFontObject(Formatter.TagFonts[info.type]);
                        obj:SetText(info.text);
                        SetTextColor(obj, Def.TextColorReadable);
                    end;
                };

                if info.type == "h1" then
                    content[n].offsetX = leftOffset;
                    if false and info.previewKey then   --debug
                        n = n + 1;
                        content[n] = {
                            dataIndex = n,
                            templateKey = "Texture",
                            top = top + 6,
                            bottom = bottom,
                            point = "LEFT",
                            relativePoint = "TOPLEFT",
                            offsetX = leftOffset -6,
                            setupFunc = function(obj)

                            end,
                        };
                    end
                else
                    content[n].offsetX = leftOffset + (info.bullet and Def.ChangelogIndent or 0);
                    if info.bullet then
                        n = n + 1;
                        content[n] = {
                            dataIndex = n,
                            templateKey = "Texture",
                            top = top + 6,
                            bottom = bottom,
                            point = "LEFT",
                            relativePoint = "TOPLEFT",
                            offsetX = leftOffset -6,
                            setupFunc = function(obj)
                                obj:SetSize(20, 20);
                                SetTexCoord(obj, 904, 944, 80, 120); --864, 904, 80, 120
                                local color = Def.TextColorReadable;
                                obj:SetVertexColor(color[1], color[2], color[3]);
                            end;
                        };
                    end
                end

            elseif info.type == "Checkbox" then
                local visualOffset = 12;
                objectHeight = Def.ButtonSize;
                top = top + visualOffset - 4;
                bottom = top + objectHeight + visualOffset;
                n = n + 1;
                content[n] = {
                    dataIndex = n,
                    templateKey = "Entry",
                    setupFunc = function(obj)
                        local data = ControlCenter:GetModule(info.dbKey);
                        obj:SetData(data);
                    end,
                    top = top,
                    bottom = bottom,
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    offsetX = leftOffset - 6,
                };

            elseif info.type == "br" then
                bottom = bottom + Def.ChangelogParagraphSpacing + 2*Def.ChangelogLineSpacing;
            end

            offsetY = bottom;
        end

        self.ChangelogTab.ScrollView:SetContent(content);
    end

    function MainFrame:ShowLatestChangelog()
        self:ShowChangelog(10800);
    end
end


do  --Tab Buttons
    local TabInfo = {
        {name = L["Modules"], tabKey = "ModuleTab"},
        {name = L["Release Notes"], tabKey = "ChangelogTab", initFunc = InitChangelogTab},
    };


    local TabButtonMixin = {};

    function TabButtonMixin:OnEnter()
        self:UpdateVisual();
    end

    function TabButtonMixin:OnLeave()
        self:UpdateVisual();
    end

    function TabButtonMixin:OnClick()
        MainFrame:ShowTab(self.tabKey);
    end

    function TabButtonMixin:OnMouseDown()
        if not self.selected then
            self.Name:SetPoint("CENTER", self, "CENTER", 1, -1);
        end
    end

    function TabButtonMixin:OnMouseUp()
        self.Name:SetPoint("CENTER", self, "CENTER", 0, 0);
    end

    function TabButtonMixin:UpdateVisual()
        if self.selected then
            SetTextColor(self.Name, Def.TextColorHighlight);
            SetTexCoord(self.Left, 600, 648, 176, 272);
            SetTexCoord(self.Center, 648, 760, 176, 272);
            SetTexCoord(self.Right, 760, 808, 176, 272);
        else
            if self:IsMouseMotionFocus() then
                SetTextColor(self.Name, Def.TextColorHighlight);
            else
                SetTextColor(self.Name, Def.TextColorNormal);
            end
            SetTexCoord(self.Left, 392, 440, 176, 272);
            SetTexCoord(self.Center, 440, 552, 176, 272);
            SetTexCoord(self.Right, 552, 600, 176, 272);
        end
    end

    function TabButtonMixin:UpdateState()
        self.selected = MainFrame[self.tabKey] and MainFrame[self.tabKey]:IsShown();
        self:UpdateVisual();
    end

    function TabButtonMixin:SetTabInfo(info)
        self.Name:SetText(info.name);
        self.tabKey = info.tabKey;
        local buttonWidth = API.Round(math.max(18*2 + self.Name:GetWrappedWidth(), 2.5*Def.TabButtonHeight));
        self:SetSize(buttonWidth, Def.TabButtonHeight);
        return buttonWidth
    end


    local function CreateTabButton(parent)
        local f = CreateFrame("Button", nil, parent, "PlumberTabButtonTemplate");
        Mixin(f, TabButtonMixin);
        SkinObjects(f, Def.TextureFile);
        SetTexCoord(f.Left, 392, 440, 176, 272);
        SetTexCoord(f.Center, 440, 552, 176, 272);
        SetTexCoord(f.Right, 552, 600, 176, 272);
        f:UpdateVisual();

        f:SetScript("OnClick", f.OnClick);
        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnMouseDown", f.OnMouseDown);
        f:SetScript("OnMouseUp", f.OnMouseUp);

        return f
    end


    function MainFrame:UpdateTabButtons()
        if not self.tabButtonPool then
            local function TabButton_Create()
                local obj = CreateTabButton(self.TabButtonContainer);
                return obj
            end
            self.tabButtonPool = addon.LandingPageUtil.CreateObjectPool(TabButton_Create);

            local offsetX = Def.WidgetGap;
            local gap = Def.WidgetGap/2;

            for k, v in ipairs(TabInfo) do
                local button = self.tabButtonPool:Acquire();
                button:SetPoint("TOPLEFT", self, "BOTTOMLEFT", offsetX, 0);
                local width = button:SetTabInfo(v);
                button.index = k;
                offsetX = offsetX + width + gap;
            end

            self.TabButtonContainer:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0);
            self.TabButtonContainer:SetSize(offsetX, Def.TabButtonHeight);
        end

        self.tabButtonPool:CallMethod("UpdateState");
    end

    function MainFrame:ShowTab(tabKey)
        if not tabKey then
            tabKey = "ModuleTab";
        end

        for i, info in ipairs(TabInfo) do
            if info.tabKey == tabKey then
                if info.initFunc then
                    local func = info.initFunc;
                    info.initFunc = nil;
                    func(self);
                end
                self[info.tabKey]:Show();
            else
                self[info.tabKey]:Hide();
            end
        end

        self:UpdateTabButtons();
    end
end


function MainFrame:ShowUI(mode)
    if CreateUI then
        CreateUI();
        CreateUI = nil;

        ControlCenter:UpdateCurrentSortMethod();
        self:RefreshCategoryList();
    end

    mode = mode or "standalone";
    self.mode = mode;
    self:UpdateLayout();
    self:UpdateTabButtons();
    self:Show();
end


C_Timer.After(1, function()
    MainFrame:ShowUI();
end);