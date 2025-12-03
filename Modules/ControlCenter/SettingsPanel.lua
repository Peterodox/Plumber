local _, addon = ...
if addon.IsToCVersionEqualOrNewerThan(110000) then return end;

local API = addon.API;
local L = addon.L;
local GetDBBool = addon.GetDBBool;
local ControlCenter = addon.ControlCenter;
local tinsert = table.insert;
local CreateFrame = CreateFrame;

local DEV_MODE = false;

local RATIO = 0.85; --h/w
local FRAME_WIDTH = 680;
local HEADER_HEIGHT = 18;
local BUTTON_OFFSET_H = 16;
local SCROLL_FRAME_SHRINK = 4;
local PADDING = 16;
local BUTTON_HEIGHT = 30;
local OPTION_GAP_Y = 2;
local DIFFERENT_CATEGORY_OFFSET = 8;
local LEFT_SECTOR_WIDTH = math.floor(0.618*FRAME_WIDTH + 0.5);


local CollapsedCateogry = {
    [1002] = true;
};


local MainFrame = CreateFrame("Frame", nil, UIParent);
addon.SettingsPanel = MainFrame;
ControlCenter.SettingsPanel = MainFrame;
MainFrame:SetSize(FRAME_WIDTH, FRAME_WIDTH * RATIO);
MainFrame:SetPoint("TOP", UIParent, "BOTTOM", 0, -64);
MainFrame:Hide();


local function CreateNewFeatureMark(button)
    local newTag = button:CreateTexture(nil, "OVERLAY");
    newTag:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/NewFeatureTag");
    newTag:SetSize(16, 16);
    newTag:SetPoint("RIGHT", button, "LEFT", -2, 0);
    newTag:Show();
    newTag:SetTexCoord(0, 0.5, 0, 1);
    return newTag
end

local function GenericFadeIn_OnUpdate(self, elapsed)
    self.alpha = self.alpha + 8 * elapsed;
    if self.alpha >= 1 then
        self.alpha = 1;
        self:SetScript("OnUpdate", nil);
    end
    self:SetAlpha(self.alpha);
end


local CategoryButtonMixin = {};
do
    function CategoryButtonMixin:SetCategory(categoryID, categoryName)
        self.categoryID = categoryID;
        self.Label:SetText(categoryName);
    end

    function CategoryButtonMixin:OnLoad()
        self.collapsed = false;
        self:UpdateArrow();
        self:SetScript("OnClick", self.OnClick);
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
    end

    function CategoryButtonMixin:UpdateArrow()
        if self.collapsed then
            self.Arrow:SetTexCoord(0, 0.5, 0, 1);
        else
            self.Arrow:SetTexCoord(0.5, 1, 0, 1);
        end
    end

    function CategoryButtonMixin:Expand()
        if self.collapsed then
            self.collapsed = false;
            CollapsedCateogry[self.categoryID] = false;
            self:UpdateArrow();
            MainFrame:UpdateContent();
        end
    end

    function CategoryButtonMixin:Collapse()
        if not self.collapsed then
            self.collapsed = true;
            CollapsedCateogry[self.categoryID] = true;
            self:UpdateArrow();
            MainFrame:UpdateContent();
        end
    end

    function CategoryButtonMixin:ToggleCollapse()
        self.collapsed = CollapsedCateogry[self.categoryID];
        if self.collapsed then
            self:Expand();
        else
            self:Collapse();
        end
    end

    function CategoryButtonMixin:OnClick()
        self:ToggleCollapse();
    end

    function CategoryButtonMixin:OnEnter()
        self.HighlightFrame.alpha = 0;
        self.HighlightFrame:SetScript("OnUpdate", GenericFadeIn_OnUpdate);
        self.HighlightFrame:Show();
    end

    function CategoryButtonMixin:OnLeave()
        self.HighlightFrame:SetScript("OnUpdate", nil);
        self.HighlightFrame:Hide();
        self.HighlightFrame:SetAlpha(0);
    end

    function CategoryButtonMixin:UpdateCategoryButton()
        if self.subModules then
            local total = #self.subModules;
            local numEnabled = 0;
            for i, data in ipairs(self.subModules) do
                if GetDBBool(data.dbKey) or data.virtual then
                    numEnabled = numEnabled + 1;
                end
            end
            self.Count:SetText(string.format("%d/%d", numEnabled, total));
        else
            self.Count:SetText(nil);
        end

        self.collapsed = CollapsedCateogry[self.categoryID];
        self:UpdateArrow();
    end
end

local function CreateCategoryButton(parent)
    local b = CreateFrame("Button", nil, parent);
    b:SetSize(LEFT_SECTOR_WIDTH - 2*PADDING, BUTTON_HEIGHT);

    local textureFile = "Interface/AddOns/Plumber/Art/ControlCenter/SettingsPanelWidget.png";

    local disableSharpenging = true;
    local useTrilinearFilter = true;
    b.BackgroundTextures = API.CreateThreeSliceTextures(b, "BACKGROUND", 16, 40, 8, textureFile, disableSharpenging, useTrilinearFilter);
    b.BackgroundTextures[1]:SetTexCoord(36/512, 68/512, 0, 80/512);
    b.BackgroundTextures[2]:SetTexCoord(68/512, 132/512, 0, 80/512);
    b.BackgroundTextures[3]:SetTexCoord(132/512, 164/512, 0, 80/512);

    b.Arrow = b:CreateTexture(nil, "OVERLAY");
    b.Arrow:SetSize(14, 14);
    b.Arrow:SetPoint("LEFT", b, "LEFT", 8, 0);
    b.Arrow:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/CollapseExpand");

    b.Label = b:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    b.Label:SetJustifyH("LEFT");
    b.Label:SetJustifyV("TOP");
    b.Label:SetTextColor(0.92, 0.92, 0.92);
    b.Label:SetPoint("LEFT", b, "LEFT", 28, 0);

    b.Count = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
    b.Count:SetJustifyH("RIGHT");
    b.Count:SetJustifyV("TOP");
    b.Count:SetTextColor(0.5, 0.5, 0.5);
    b.Count:SetPoint("RIGHT", b, "RIGHT", -8, 0);


    local HighlightFrame = CreateFrame("Frame", nil, b);
    b.HighlightFrame = HighlightFrame;
    HighlightFrame:SetUsingParentLevel(true);
    HighlightFrame:SetSize(128, 40);
    HighlightFrame:SetPoint("LEFT", b, "LEFT", -24, 0);
    HighlightFrame:SetPoint("RIGHT", b, "RIGHT", 24, 0);
    HighlightFrame.Texture = HighlightFrame:CreateTexture(nil, "ARTWORK");
    HighlightFrame.Texture:SetAllPoints(true);
    HighlightFrame.Texture:SetTexture(textureFile);
    HighlightFrame.Texture:SetTexCoord(168/512, 296/512, 0, 80/512);
    HighlightFrame:Hide();
    HighlightFrame:SetAlpha(0);


    API.Mixin(b, CategoryButtonMixin);

    b:OnLoad();

    b.Label:SetText("Dreamseed");
    b.Count:SetText("4/4");

    return b
end

local function OptionToggle_SetFocused(optionToggle, focused)
    if focused then
        optionToggle.Texture:SetTexCoord(0.5, 1, 0, 1);
    else
        optionToggle.Texture:SetTexCoord(0, 0.5, 0, 1);
    end
end

local function OptionToggle_OnHide(self)
    OptionToggle_SetFocused(self, false);
end

local function CreateOptionToggle(checkbox)
    local b = CreateFrame("Button", nil, checkbox, "PlumberPropagateMouseMotionTemplate");
    b:SetSize(48, 24);
    b:SetPoint("RIGHT", checkbox, "RIGHT", 0, 0);
    b.Texture = b:CreateTexture(nil, "OVERLAY");
    b.Texture:SetTexture("Interface/AddOns/Plumber/Art/Button/OptionToggle");
    b.Texture:SetSize(16, 16);
    b.Texture:SetPoint("RIGHT", b, "RIGHT", -4, 0);
    b.Texture:SetVertexColor(0.6, 0.6, 0.6);
    API.DisableSharpening(b.Texture);
    b:SetScript("OnHide", OptionToggle_OnHide);
    b.isPlumberEditModeToggle = true;
    OptionToggle_SetFocused(b, false);
    return b
end


local function CreateUI()
    local parent = MainFrame;
    local showCloseButton = true;
    local f = addon.CreateHeaderFrame(parent, showCloseButton);
    parent.BackgroundFrame = f;
    f:SetUsingParentLevel(true);

    f.CloseUI = function()
        MainFrame:Hide();
    end


    local container = parent;

    f:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0);
    f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0);
    f:SetTitle(L["Module Control"]);

    local headerHeight = HEADER_HEIGHT;
    local previewSize = FRAME_WIDTH - LEFT_SECTOR_WIDTH - 2*PADDING;

    local preview = container:CreateTexture(nil, "OVERLAY");
    parent.Preview = preview;
    preview:SetSize(previewSize, previewSize);
    preview:SetPoint("TOPRIGHT", container, "TOPRIGHT", -PADDING, -headerHeight -PADDING);
    --preview:SetColorTexture(0.25, 0.25, 0.25);

    local mask = container:CreateMaskTexture(nil, "OVERLAY");
    mask:SetPoint("TOPLEFT", preview, "TOPLEFT", 0, 0);
    mask:SetPoint("BOTTOMRIGHT", preview, "BOTTOMRIGHT", 0, 0);
    mask:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/PreviewMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
    preview:AddMaskTexture(mask);

    local description = container:CreateFontString(nil, "OVERLAY", "GameTooltipText"); --GameFontNormal (ObjectiveFont), GameTooltipTextSmall
    parent.Description = description;
    description:SetTextColor(0.659, 0.659, 0.659);    --0.5, 0.5, 0.5
    description:SetJustifyH("LEFT");
    description:SetJustifyV("TOP");
    description:SetSpacing(2);
    local visualOffset = 4;
    description:SetPoint("TOPLEFT", preview, "BOTTOMLEFT", visualOffset, -PADDING);
    description:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -PADDING - visualOffset, PADDING);
    description:SetShadowColor(0, 0, 0);
    description:SetShadowOffset(1, -1);

    local DividerFrame = CreateFrame("Frame", nil, container);
    parent.DividerFrame = DividerFrame;
    local dividerHeight = container:GetHeight() - headerHeight;
    DividerFrame:SetSize(4, dividerHeight);
    DividerFrame:SetPoint("TOP", container, "TOPLEFT", LEFT_SECTOR_WIDTH, -headerHeight);

    local dividerTop = DividerFrame:CreateTexture(nil, "OVERLAY");
    dividerTop:SetSize(16, 16);
    dividerTop:SetPoint("TOPRIGHT", DividerFrame, "TOP", 2, 0);
    dividerTop:SetTexCoord(0, 1, 0, 0.25);

    local dividerBottom = DividerFrame:CreateTexture(nil, "OVERLAY");
    dividerBottom:SetSize(16, 16);
    dividerBottom:SetPoint("BOTTOMRIGHT", DividerFrame, "BOTTOM", 2, 0);
    dividerBottom:SetTexCoord(0, 1, 0.75, 1);

    local dividerMiddle = DividerFrame:CreateTexture(nil, "OVERLAY");
    dividerMiddle:SetPoint("TOPLEFT", dividerTop, "BOTTOMLEFT", 0, 0);
    dividerMiddle:SetPoint("BOTTOMRIGHT", dividerBottom, "TOPRIGHT", 0, 0);
    dividerMiddle:SetTexCoord(0, 1, 0.25, 0.75);

    dividerTop:SetTexture("Interface/AddOns/Plumber/Art/Frame/Divider_DropShadow_Vertical");
    dividerBottom:SetTexture("Interface/AddOns/Plumber/Art/Frame/Divider_DropShadow_Vertical");
    dividerMiddle:SetTexture("Interface/AddOns/Plumber/Art/Frame/Divider_DropShadow_Vertical");

    MainFrame.dividers = {
        dividerTop, dividerMiddle, dividerBottom,
    };

    API.DisableSharpening(dividerTop);
    API.DisableSharpening(dividerBottom);
    API.DisableSharpening(dividerMiddle);


    local Slider = ControlCenter.CreateScrollBarWithDynamicSize(container);
    Slider:SetPoint("TOP", DividerFrame, "TOP", 0, -4)
    Slider:SetPoint("BOTTOM", DividerFrame, "BOTTOM", 0, 4);
    Slider:SetFrameLevel(20);
    MainFrame.ScrollBar = Slider;


    local ScrollView = API.CreateScrollView(MainFrame, Slider);
    MainFrame.ScrollView = ScrollView;
    ScrollView:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", SCROLL_FRAME_SHRINK, -HEADER_HEIGHT - SCROLL_FRAME_SHRINK);
    ScrollView:SetPoint("BOTTOMLEFT", MainFrame, "BOTTOMLEFT", SCROLL_FRAME_SHRINK, SCROLL_FRAME_SHRINK);
    ScrollView:SetWidth(LEFT_SECTOR_WIDTH);
    ScrollView:SetStepSize((BUTTON_HEIGHT + OPTION_GAP_Y) * 2);
    ScrollView:OnSizeChanged();
    ScrollView:EnableMouseBlocker(true);
    ScrollView:SetBottomOvershoot(DIFFERENT_CATEGORY_OFFSET);
    Slider.ScrollView = ScrollView;


    local SelectionTexture = CreateFrame("Frame", nil, ScrollView);
    SelectionTexture:SetSize(LEFT_SECTOR_WIDTH, 64);
    SelectionTexture.Texture = SelectionTexture:CreateTexture(nil, "ARTWORK");
    SelectionTexture.Texture:SetAllPoints(true);
    SelectionTexture.Texture:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/OptionEntryHighlight.png", nil, nil, "TRILINEAR");
    API.DisableSharpening(SelectionTexture.Texture);
    SelectionTexture:Hide();

    ScrollView:SetOnScrollStartCallback(function()
        SelectionTexture:Hide();
    end);


    parent.Checkboxs = {};

    local function Checkbox_OnEnter(self)
        local desc = self.data.description;
        local additonalDesc = self.data.descriptionFunc and self.data.descriptionFunc() or nil;
        if additonalDesc then
            if desc then
                desc = desc.."\n\n"..additonalDesc;
            else
                desc = additonalDesc;
            end
        end
        description:SetText(desc);

        if self.parentDBKey then
            preview:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/Preview_"..self.parentDBKey);
        else
            preview:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/Preview_"..self.dbKey);
        end

        SelectionTexture:ClearAllPoints();
        SelectionTexture:SetPoint("LEFT", self, "LEFT", -32, 0);
        SelectionTexture:SetPoint("RIGHT", self, "RIGHT", 32, 0);
        SelectionTexture.alpha = 0;
        SelectionTexture:SetAlpha(0);
        SelectionTexture:SetScript("OnUpdate", GenericFadeIn_OnUpdate);
        SelectionTexture:Show();

        if self.OptionToggle then
            OptionToggle_SetFocused(self.OptionToggle, true);
        end

        if DEV_MODE then
            print(self.data.uiOrder);
        end
    end

    local function Checkbox_OnLeave(self)
        if not self:IsMouseOver() then
            SelectionTexture:Hide();
            if self.OptionToggle then
                OptionToggle_SetFocused(self.OptionToggle, false);
            end
        end
    end

    local function Checkbox_OnClick(self)
        if self.dbKey and self.data.toggleFunc then
            self.data.toggleFunc( self:GetChecked() );
        end

        if self.subOptionWidgets then
            local enabled = GetDBBool(self.dbKey);
            for _, widget in ipairs(self.subOptionWidgets) do
                widget:SetChecked(GetDBBool(widget.dbKey));
                widget:SetEnabled(enabled);
            end
        end

        if self.data.subOptions then
            MainFrame:UpdateCheckboxes();
        else
            self:UpdateChecked();
        end

        MainFrame:UpdateCategoryCount();
    end

    local function OptionToggle_OnEnter(self)
        self.Texture:SetVertexColor(1, 1, 1);
        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        tooltip:SetText(SETTINGS, 1, 1, 1, 1);
        tooltip:Show();
    end

    local function OptionToggle_OnLeave(self)
        self.Texture:SetVertexColor(0.6, 0.6, 0.6);
        GameTooltip:Hide();
    end

    local function Checkbox_UpdateChecked(self)
        if self.data.virtual then
            self:SetChecked(true);
            if self.OptionToggle then
                self.OptionToggle:Hide();
            end
            self:Disable();
            return
        end

        local isChecked = GetDBBool(self.dbKey);
        self:SetChecked(isChecked);
        if self.dbKey and self.data.toggleFunc then
            self.data.toggleFunc(isChecked);
        end

        if self.subOptionWidgets then
            local enabled = GetDBBool(self.dbKey);
            for _, widget in ipairs(self.subOptionWidgets) do
                widget:SetChecked(GetDBBool(widget.dbKey));
                widget:SetEnabled(enabled);
            end
        end

        if self.data.optionToggleFunc and isChecked then
            if not self.OptionToggle then
                self.OptionToggle = CreateOptionToggle(self);
                self.OptionToggle:SetScript("OnEnter", OptionToggle_OnEnter);
                self.OptionToggle:SetScript("OnLeave", OptionToggle_OnLeave);
            end
            self.OptionToggle:SetScript("OnClick", self.data.optionToggleFunc);
            self.OptionToggle:Show();
            OptionToggle_SetFocused(self.OptionToggle, self:IsMouseMotionFocus());
        else
            if self.OptionToggle then
                self.OptionToggle:Hide();
            end
        end

        if self.parentDBKey and not GetDBBool(self.parentDBKey) then
            self:Disable();
        else
            self:Enable();
        end
    end

    local function SetupCheckboxFromData(checkbox, data)
        checkbox.dbKey = data.dbKey;
        checkbox.data = data;
        checkbox:SetLabel(data.name);
        checkbox:UpdateChecked();

        if data.isNewFeature then
            if not checkbox.NewTag then
                checkbox.NewTag = CreateNewFeatureMark(checkbox);
            end
            checkbox.NewTag:Show();
        elseif checkbox.NewTag then
            checkbox.NewTag:Hide();
        end
    end

    local function Checkbox_Create()
        local obj = addon.CreateCheckbox(ScrollView);
        obj.onEnterFunc = Checkbox_OnEnter;
        obj.onLeaveFunc = Checkbox_OnLeave;
        obj.onClickFunc = Checkbox_OnClick;
        obj:SetMotionScriptsWhileDisabled(true);
        obj.SetupCheckboxFromData = SetupCheckboxFromData;
        obj.UpdateChecked = Checkbox_UpdateChecked;
        obj:SetHeight(BUTTON_HEIGHT)
        return obj
    end

    ScrollView:AddTemplate("Checkbox", Checkbox_Create);


    local function CategoryButton_Create()
        local obj = CreateCategoryButton(ScrollView);
        return obj
    end

    local function CategoryButton_Remove(obj)
        obj:OnLeave();
    end

    ScrollView:AddTemplate("CategoryButton", CategoryButton_Create, CategoryButton_Remove);


    --Temporary "About" Tab
    local VersionText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal"); --GameFontNormal (ObjectiveFont), GameTooltipTextSmall
    VersionText:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -PADDING, PADDING);
    VersionText:SetTextColor(0.24, 0.24, 0.24);
    VersionText:SetJustifyH("RIGHT");
    VersionText:SetJustifyV("BOTTOM");
    VersionText:SetText(addon.VERSION_TEXT);


    function MainFrame:UpdateLayout()
        local frameWidth = math.floor(self:GetWidth() + 0.5);
        if frameWidth == self.frameWidth then
            return
        end
        self.frameWidth = frameWidth;

        local leftSectorWidth = math.floor(0.618*frameWidth + 0.5);

        self.DividerFrame:SetPoint("TOP", self, "TOPLEFT", leftSectorWidth, -headerHeight);
        self.DividerFrame:SetHeight(self:GetHeight() - HEADER_HEIGHT);

        previewSize = frameWidth - leftSectorWidth - 2*PADDING;
        preview:SetSize(previewSize, previewSize);

        ScrollView:SetWidth(leftSectorWidth);
        ScrollView:OnSizeChanged();
        self.ScrollBar:OnSizeChanged();
    end

    function MainFrame:ShowScrollBar(state)
        if state then
            self.ScrollBar:Show();
            dividerTop:SetShown(false);
            dividerMiddle:SetShown(false);
            dividerBottom:SetShown(false);
            self.ScrollBar:UpdateVisibleExtentPercentage();
        else
            self.ScrollBar:Hide();
            dividerTop:SetShown(true);
            dividerMiddle:SetShown(true);
            dividerBottom:SetShown(true);
        end
    end
end

function MainFrame:ShowUI(mode)
    if CreateUI then
        CreateUI();
        CreateUI = nil;
    end

    mode = mode or "standalone";
    self.mode = mode;

    self:Show();
    self.BackgroundFrame:SetShown(mode == "standalone");
    self:UpdateLayout();
    self:UpdateContent();
end

function MainFrame:UpdateCheckboxes()
    self.ScrollView:CallObjectMethod("Checkbox", "UpdateChecked");
end

function MainFrame:UpdateCategoryCount()
    self.ScrollView:CallObjectMethod("CategoryButton", "UpdateCategoryButton");
end

function MainFrame:UpdateContent()
    local top, bottom;
    local n = 0;
    local offsetY = 12;
    local content = {};

    local buttonHeight = BUTTON_HEIGHT;
    local categoryButtonWidth = LEFT_SECTOR_WIDTH - 2*PADDING;
    local checkboxWidth = LEFT_SECTOR_WIDTH - 2*PADDING - BUTTON_OFFSET_H;
    local buttonGap = OPTION_GAP_Y;
    local subOptionOffset = 20;
    local offsetX = -4;

    for index, categoryInfo in ipairs(ControlCenter:GetValidModules()) do
        n = n + 1;
        top = offsetY;
        bottom = offsetY + buttonHeight + buttonGap;
        content[n] = {
            dataIndex = n,
            templateKey = "CategoryButton",
            setupFunc = function(obj)
                obj:SetCategory(categoryInfo.categoryID, categoryInfo.categoryName);
                obj.subModules = categoryInfo.subModules;
                obj:UpdateCategoryButton();
                obj:SetWidth(categoryButtonWidth);
            end,
            top = top,
            bottom = bottom,
            offsetX = offsetX,
        };
        offsetY = bottom;

        if not CollapsedCateogry[categoryInfo.categoryID] then
            for _, data in ipairs(categoryInfo.subModules) do
                n = n + 1;
                top = offsetY;
                bottom = offsetY + buttonHeight + buttonGap;
                content[n] = {
                    dataIndex = n,
                    templateKey = "Checkbox",
                    setupFunc = function(obj)
                        obj.parentDBKey = nil;
                        obj:SetupCheckboxFromData(data);
                        obj:SetWidth(checkboxWidth);
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
                            templateKey = "Checkbox",
                            setupFunc = function(obj)
                                obj.parentDBKey = data.dbKey;
                                obj:SetupCheckboxFromData(v);
                                obj:SetWidth(checkboxWidth - subOptionOffset);
                            end,
                            top = top,
                            bottom = bottom,
                            offsetX = offsetX + 0.5*subOptionOffset,
                        };
                        offsetY = bottom;
                    end
                end
            end

            offsetY = offsetY + DIFFERENT_CATEGORY_OFFSET;
        end
    end

    local retainPosition = true;
    self.ScrollView:SetContent(content, retainPosition);
    self:ShowScrollBar(self.ScrollView:IsScrollable());
end