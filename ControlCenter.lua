local _, addon = ...
local API = addon.API;
local L = addon.L;
local GetDBBool = addon.GetDBBool;
local tinsert = table.insert;
local CreateFrame = CreateFrame;

local DEV_MODE = false;

local RATIO = 0.85; --h/w
local FRAME_WIDTH = 680;
local HEADER_HEIGHT = 18;
local BUTTON_OFFSET_H = 16;
local SCROLL_FRAME_SHRINK = 4;
local PADDING = 16;
local BUTTON_HEIGHT = 24;
local OPTION_GAP_Y = 8;
local DIFFERENT_CATEGORY_OFFSET = 8;
local LEFT_SECTOR_WIDTH = math.floor(0.618*FRAME_WIDTH + 0.5);

local CATEGORY_ORDER = {
    --Must match the keys in the localization
    [-1] = "Timerunning",

    [0] = "Unknown",    --Used during development

    [1] = "General",
    [2] = "NPC Interaction",
    [3] = "Tooltip",
    [4] = "Class",
    [5] = "Reduction",

    --Patch Feature uses the tocVersion and #00
    [1002] = "Dragonflight",

    [1208] = "Plumber",
};


local DEFAULT_COLLAPSED_CATEGORY = {
    [1002] = true;
};


local ControlCenter = CreateFrame("Frame", nil, UIParent);
addon.ControlCenter = ControlCenter;
ControlCenter:SetSize(FRAME_WIDTH, FRAME_WIDTH * RATIO);
ControlCenter:SetPoint("TOP", UIParent, "BOTTOM", 0, -64);
ControlCenter.modules = {};
ControlCenter.newDBKeys = {};
ControlCenter:Hide();

local ScrollFrame = CreateFrame("Frame", nil, ControlCenter);
ScrollFrame:SetPoint("TOPLEFT", ControlCenter, "TOPLEFT", SCROLL_FRAME_SHRINK, -HEADER_HEIGHT - SCROLL_FRAME_SHRINK);
ScrollFrame:SetPoint("BOTTOMLEFT", ControlCenter, "BOTTOMLEFT", SCROLL_FRAME_SHRINK, SCROLL_FRAME_SHRINK);
ScrollFrame:SetWidth(LEFT_SECTOR_WIDTH);
ControlCenter.ScrollFrame = ScrollFrame;


local BlizzardPanel = CreateFrame("Frame", nil, UIParent);
BlizzardPanel:Hide();


do  --MainFrame Scroll
    local OFFSET_PER_SCROLL = (BUTTON_HEIGHT + OPTION_GAP_Y) * 2;

    local function ScrollFrame_OnMouseWheel(self, delta)
        if self.scrollOffset > 0 and delta > 0 then
            self.scrollOffset = self.scrollOffset - OFFSET_PER_SCROLL;
            if self.scrollOffset < 0 then
                self.scrollOffset = 0;
            end
            ControlCenter:SetScrollOffset(self.scrollOffset, true);
        elseif self.scrollOffset < self.scrollRange and delta < 0 then
            self.scrollOffset = self.scrollOffset + OFFSET_PER_SCROLL;
            if self.scrollOffset > self.scrollRange then
                self.scrollOffset = self.scrollRange;
            end
            ControlCenter:SetScrollOffset(self.scrollOffset, true);
        end
    end

    function ControlCenter:SetScrollOffset(offset, fromMouseWheel)
        self.ScrollFrame.ScrollChild:SetPoint("TOPLEFT", self.ScrollFrame, "TOPLEFT", 0, offset);
        self.ScrollFrame.scrollOffset = offset;
        self:UpdateScrollBar(fromMouseWheel);
    end

    function ControlCenter:UpdateScrollBar(fromMouseWheel)
        if self.scrollable then
            self.ScrollBar:SetScrollPercentage(self.ScrollFrame.scrollOffset/self.ScrollFrame.scrollRange, fromMouseWheel);
        end
    end

    function ControlCenter:SetScrollRange(scrollRange)
        local scrollable = scrollRange > 0;

        if scrollable then
            if not self.scrollable then
                self.scrollable = true;
                self.ScrollFrame:SetClipsChildren(true);
                self.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);
                self.ScrollFrame.scrollOffset = 0;
            end
            self.ScrollFrame.scrollRange = scrollRange;

            if self.ScrollBar then
                local frameHeight = ControlCenter:GetHeight();
                self.ScrollBar:SetVisibleExtentPercentage(frameHeight/(frameHeight + scrollRange));
            end
        else
            if self.scrollable then
                self.scrollable = false;
                self.ScrollFrame:SetClipsChildren(false);
                self.ScrollFrame.ScrollChild:SetPoint("TOPLEFT", self.ScrollFrame, "TOPLEFT", 0, 0);
                self.ScrollFrame.scrollOffset = 0;
                self.ScrollFrame.scrollRange = 0;
                self.ScrollFrame:SetScript("OnMouseWheel", nil);
            end
        end
    end

    function ControlCenter:SetScrollPercentage(scrollPercentage)
        if self.scrollable then
            local offset = self.ScrollFrame.scrollRange * scrollPercentage;
            self:SetScrollOffset(offset, true);
        end
    end

    function ControlCenter:UpdateScrollRange()
        local frameHeight = self.ScrollFrame:GetHeight();
        local firstButton = self.CategoryButtons[1];
        local lastObject = self.lastCategoryButton.Drawer;

        local contentHeight = 2 * PADDING + firstButton:GetTop() - lastObject:GetBottom();

        self:SetScrollRange(math.ceil(contentHeight - frameHeight));
        if self.ShowScrollBar then
            self:ShowScrollBar(self.scrollable);
        end
    end

    function ControlCenter:OnMouseWheel(delta)
        if self.scrollable then

        end
    end
end


local function CreateNewFeatureMark(button)
    local newTag = button:CreateTexture(nil, "OVERLAY")
    newTag:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/NewFeatureMark");
    newTag:SetSize(16, 16);
    newTag:SetPoint("RIGHT", button, "LEFT", -2, 0);
    newTag:Show();
end

local function GetCategoryName(categoryID)
    local categoryKey = CATEGORY_ORDER[categoryID];
    if categoryKey then
        return L["Module Category "..categoryKey]
    else
        return "Unknown Category"
    end
end


local CategoryButtonMixin = {};
do
    function CategoryButtonMixin:SetCategory(categoryID)
        self.categoryID = categoryID;
        self.categoryKey = CATEGORY_ORDER[categoryID];

        if self.categoryKey then
            self.Label:SetText(L["Module Category ".. self.categoryKey]);
        else
            self.Label:SetText("Unknown Category");
            self.categoryKey = "Unknown";
        end
    end

    function CategoryButtonMixin:OnLoad()
        self.collapsed = false;
        self.childOptions = {};
        self:UpdateArrow();
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
            self.Drawer:SetHeight(self.drawerHeight);
            self.Drawer:Show();
            self:UpdateArrow();
            ControlCenter:UpdateScrollRange();
        end
    end

    function CategoryButtonMixin:Collapse()
        if not self.collapsed then
            self.collapsed = true;
            self.Drawer:SetHeight(DIFFERENT_CATEGORY_OFFSET);
            self.Drawer:Hide();
            self:UpdateArrow();
            ControlCenter:UpdateScrollRange();
        end
    end

    function CategoryButtonMixin:ToggleCollapse()
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
        --ControlCenter.Preview:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/CategoryPreview_"..self.categoryKey);
    end

    function CategoryButtonMixin:InitializeDrawer()
        self.drawerHeight = self.numOptions * (OPTION_GAP_Y + BUTTON_HEIGHT) + OPTION_GAP_Y + DIFFERENT_CATEGORY_OFFSET;
        self.Drawer:SetHeight(self.drawerHeight);
    end

    function CategoryButtonMixin:UpdateModuleCount()
        if self.childOptions then
            local total = #self.childOptions;
            local numEnabled = 0;
            for i, checkbox in ipairs(self.childOptions) do
                if checkbox:GetChecked() then
                    numEnabled = numEnabled + 1;
                end
            end
            self.Count:SetText(string.format("%d/%d", numEnabled, total));
        else
            self.Count:SetText(nil);
        end
    end

    function CategoryButtonMixin:AddChildOption(checkbox)
        if not self.numOptions then
            self.numOptions = 0;
        end
        self.numOptions = self.numOptions + 1;
        if not checkbox.parentDBKey then
            tinsert(self.childOptions, checkbox);
        end
    end

    function CategoryButtonMixin:UpdateNineSlice(offset)
        --Texture Slice don't follow its parent scale
        --This texture has 4px gap in each direction
        --Unused
        self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", -offset, offset);
        self.Background:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", offset, -offset);
    end
end


local function CreateCategoryButton(parent)
    local b = CreateFrame("Button", nil, parent);

    b:SetSize(LEFT_SECTOR_WIDTH - 2*PADDING, BUTTON_HEIGHT);

    b.Background = b:CreateTexture(nil, "BACKGROUND");
    b.Background:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/CategoryButton-NineSlice");
    b.Background:SetTextureSliceMargins(16, 16, 16, 16);
    b.Background:SetTextureSliceMode(0);
    b.Background:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0);
    b.Background:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0);


    b.Arrow = b:CreateTexture(nil, "OVERLAY");
    b.Arrow:SetSize(14, 14);
    b.Arrow:SetPoint("LEFT", b, "LEFT", 8, 0);
    b.Arrow:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/CollapseExpand");

    b.Label = b:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    b.Label:SetJustifyH("LEFT");
    b.Label:SetJustifyV("TOP");
    b.Label:SetTextColor(1, 1, 1);
    b.Label:SetPoint("LEFT", b, "LEFT", 28, 0);

    b.Count = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
    b.Count:SetJustifyH("RIGHT");
    b.Count:SetJustifyV("TOP");
    b.Count:SetTextColor(0.5, 0.5, 0.5);
    b.Count:SetPoint("RIGHT", b, "RIGHT", -8, 0);

    b.Drawer = CreateFrame("Frame", nil, b);
    b.Drawer:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 0, 0);
    b.Drawer:SetSize(16, 16);

    API.Mixin(b, CategoryButtonMixin);
    b:SetScript("OnClick", b.OnClick);
    b:SetScript("OnEnter", b.OnEnter);

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

local function CreateOptionToggle(checkbox, onClickFunc)
    if not checkbox.OptionToggle then
        local b = CreateFrame("Button", nil, checkbox);
        checkbox.OptionToggle = b;
        b:SetSize(48, 24);
        b:SetPoint("RIGHT", checkbox, "RIGHT", 0, 0);
        b.Texture = b:CreateTexture(nil, "OVERLAY");
        b.Texture:SetTexture("Interface/AddOns/Plumber/Art/Button/OptionToggle");
        b.Texture:SetSize(16, 16);
        b.Texture:SetPoint("RIGHT", b, "RIGHT", -4, 0);
        b.Texture:SetVertexColor(0.6, 0.6, 0.6);
        API.DisableSharpening(b.Texture);
        b:SetScript("OnClick", onClickFunc);
        b:SetScript("OnHide", OptionToggle_OnHide);
        b.isPlumberEditModeToggle = true;
        OptionToggle_SetFocused(b, false);
        return b
    end
end

local function CreateUI()
    local CHECKBOX_WIDTH = LEFT_SECTOR_WIDTH - 2*PADDING - BUTTON_OFFSET_H;

    local db = PlumberDB;
    DB = db;

    local settingsOpenTime = db.settingsOpenTime;
    local isFirstMet;
    if not settingsOpenTime then
        settingsOpenTime = 0;
        isFirstMet = true;
    end

    local parent = ControlCenter;
    local showCloseButton = true;
    local f = addon.CreateHeaderFrame(parent, showCloseButton);
    parent.BackgroundFrame = f;
    f:SetUsingParentLevel(true);

    f.CloseUI = function()
        ControlCenter:Hide();
    end


    local ScrollChild = CreateFrame("Frame", nil, ScrollFrame);
    ScrollFrame.ScrollChild = ScrollChild;
    ScrollChild:SetSize(8, 8);
    ScrollChild:SetPoint("TOPLEFT", ScrollFrame, "TOPLEFT", 0, 0);

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

    ControlCenter.dividers = {
        dividerTop, dividerMiddle, dividerBottom,
    };

    API.DisableSharpening(dividerTop);
    API.DisableSharpening(dividerBottom);
    API.DisableSharpening(dividerMiddle);


    local SelectionTexture = ScrollChild:CreateTexture(nil, "ARTWORK");
    SelectionTexture:SetSize(LEFT_SECTOR_WIDTH - PADDING, BUTTON_HEIGHT);
    SelectionTexture:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/SelectionTexture");
    SelectionTexture:SetVertexColor(1, 1, 1, 0.1);
    SelectionTexture:SetBlendMode("ADD");
    SelectionTexture:Hide();


    local fromOffsetY = PADDING - SCROLL_FRAME_SHRINK; -- +headerHeight
    local numButton = 0;

    parent.Checkboxs = {};
    parent.CategoryButtons = {};

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
        SelectionTexture:SetPoint("LEFT", self, "LEFT", -PADDING, 0);
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
            ControlCenter:UpdateCategoryButtons();
        end

        if self.OptionToggle then
            self.OptionToggle:SetShown(self:GetChecked());
        end

        if self.subOptionWidgets then
            local enabled = GetDBBool(self.dbKey);
            for _, widget in ipairs(self.subOptionWidgets) do
                widget:SetChecked(GetDBBool(widget.dbKey));
                widget:SetEnabled(enabled);
            end
        end
    end

    local function OptionToggle_OnEnter(self)
        Checkbox_OnEnter(self:GetParent());
        self.Texture:SetVertexColor(1, 1, 1);
        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        tooltip:SetText(SETTINGS, 1, 1, 1, 1);
        tooltip:Show();
    end

    local function OptionToggle_OnLeave(self)
        Checkbox_OnLeave(self:GetParent());
        self.Texture:SetVertexColor(0.6, 0.6, 0.6);
        GameTooltip:Hide();
    end

    local newCategoryPosition = {};

    local function SortFunc_Module(a, b)
        if a.categoryID ~= b.categoryID then
            return a.categoryID < b.categoryID
        end

        if a.uiOrder ~= b.uiOrder then
            return a.uiOrder < b.uiOrder
            --should be finished here
        else
            if (a.categoryID == b.categoryID) and (a ~= b) then
                --print("Plumber: Duplicated Module uiOrder", a.uiOrder, a.name, b.name);   --debug
            end
        end

        return a.name < b.name
    end

    table.sort(parent.modules, SortFunc_Module);

    local validModules = {};
    local lastCategoryID;
    local numValid = 0;

    for i, data in ipairs(parent.modules) do
        if (not data.validityCheck) or (data.validityCheck()) then
            numValid = numValid + 1;
            if data.categoryID ~= lastCategoryID then
                lastCategoryID = data.categoryID;
                newCategoryPosition[numValid] = true;
            end
            tinsert(validModules, data);
        end
    end

    parent.modules = validModules;


    local function SetupCheckboxFromData(checkbox, data)
        checkbox.dbKey = data.dbKey;
        checkbox.data = data;
        checkbox.onEnterFunc = Checkbox_OnEnter;
        checkbox.onLeaveFunc = Checkbox_OnLeave;
        checkbox.onClickFunc = Checkbox_OnClick;
        checkbox:SetLabel(data.name);
        checkbox:SetMotionScriptsWhileDisabled(true);
    end


    local checkbox;
    local lastCategoryButton;
    local positionInCategory;
    local CreateCheckbox = addon.CreateCheckbox;

    for i, data in ipairs(parent.modules) do
        if newCategoryPosition[i] then
            local categoryButton = CreateCategoryButton(ScrollChild);
            tinsert(parent.CategoryButtons, categoryButton);

            if i == 1 then
                categoryButton:SetPoint("TOPLEFT", ScrollChild, "TOPLEFT", PADDING - SCROLL_FRAME_SHRINK, -fromOffsetY);
            else
                categoryButton:SetPoint("TOPLEFT", lastCategoryButton.Drawer, "BOTTOMLEFT", 0, 0);
            end

            categoryButton:SetCategory(data.categoryID);

            lastCategoryButton = categoryButton;
            positionInCategory = 0;


            if DEV_MODE then
                if parent.modules[i - 1] then
                    print("uiOrder:", parent.modules[i - 1].uiOrder);
                end
                print("category:", data.categoryID, GetCategoryName(data.categoryID));
            end
        end

        numButton = numButton + 1;
        checkbox = CreateCheckbox(lastCategoryButton.Drawer);
        parent.Checkboxs[numButton] = checkbox;
        checkbox:SetPoint("TOPLEFT", lastCategoryButton.Drawer, "TOPLEFT", 8, -positionInCategory * (OPTION_GAP_Y + BUTTON_HEIGHT) - OPTION_GAP_Y);
        checkbox:SetFixedWidth(CHECKBOX_WIDTH);
        SetupCheckboxFromData(checkbox, data);

        if (not isFirstMet) and data.moduleAddedTime and data.moduleAddedTime > settingsOpenTime then
            CreateNewFeatureMark(checkbox);
        end

        if data.optionToggleFunc then
            local button = CreateOptionToggle(checkbox, data.optionToggleFunc);
            button:SetScript("OnEnter", OptionToggle_OnEnter);
            button:SetScript("OnLeave", OptionToggle_OnLeave);
        end

        lastCategoryButton:AddChildOption(checkbox);
        positionInCategory = positionInCategory + 1;

        if data.subOptions then
            local offsetX = BUTTON_HEIGHT;
            for j, v in ipairs(data.subOptions) do
                local widget = CreateCheckbox(checkbox);
                numButton = numButton + 1;
                parent.Checkboxs[numButton] = widget;
                widget.parentDBKey = data.dbKey;
                SetupCheckboxFromData(widget, v);
                widget:SetPoint("TOPLEFT", checkbox, "TOPLEFT", offsetX, -j * (OPTION_GAP_Y + BUTTON_HEIGHT));
                widget:SetFixedWidth(CHECKBOX_WIDTH - offsetX);
                if not checkbox.subOptionWidgets then
                    checkbox.subOptionWidgets = {};
                end
                checkbox.subOptionWidgets[j] = widget;
                lastCategoryButton:AddChildOption(widget);
                positionInCategory = positionInCategory + 1;
            end
        end
    end

    ControlCenter.lastCategoryButton = lastCategoryButton;

    for i, categoryButton in ipairs(parent.CategoryButtons) do
        categoryButton:InitializeDrawer();
    end

    for i, categoryButton in ipairs(parent.CategoryButtons) do
        if DEFAULT_COLLAPSED_CATEGORY[categoryButton.categoryID] then
            categoryButton:Collapse();
        end
    end

    --Temporary "About" Tab
    local VersionText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal"); --GameFontNormal (ObjectiveFont), GameTooltipTextSmall
    VersionText:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -PADDING, PADDING);
    VersionText:SetTextColor(0.24, 0.24, 0.24);
    VersionText:SetJustifyH("RIGHT");
    VersionText:SetJustifyV("BOTTOM");
    VersionText:SetText(addon.VERSION_TEXT);

    db.settingsOpenTime = time();


    local ScrollBar = CreateFrame("EventFrame", nil, container, "MinimalScrollBar");
    ScrollBar:SetPoint("TOP", DividerFrame, "TOP", 0, -8)
    ScrollBar:SetPoint("BOTTOM", DividerFrame, "BOTTOM", 0, 8);
    ControlCenter.ScrollBar = ScrollBar;

    function ScrollBar:SetScrollPercentage(scrollPercentage, fromMouseWheel)
        ScrollControllerMixin.SetScrollPercentage(ScrollBar, scrollPercentage);
        ScrollBar:Update();
        if not fromMouseWheel then
            ControlCenter:SetScrollPercentage(scrollPercentage);
        end
    end


    function ControlCenter:UpdateLayout()
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

        ScrollFrame:SetWidth(leftSectorWidth);
    end

    function ControlCenter:ShowScrollBar(state)
        if state then
            ScrollBar:Show();
            dividerTop:SetShown(false);
            dividerMiddle:SetShown(false);
            dividerBottom:SetShown(false);
            self:UpdateScrollBar(true);
        else
            ScrollBar:Hide();
            dividerTop:SetShown(true);
            dividerMiddle:SetShown(true);
            dividerBottom:SetShown(true);
        end
    end
end

function ControlCenter:ShowUI(mode)
    if CreateUI then
        CreateUI();
        CreateUI = nil;
    end

    mode = mode or "standalone";
    self.mode = mode;

    self:Show();
    self.BackgroundFrame:SetShown(mode == "standalone");
    self:UpdateLayout();
    self:UpdateButtonStates();
    self:UpdateScrollRange();
end

function ControlCenter:InitializeModules()
    --Initial Enable/Disable Modules
    local db = PlumberDB;
    local enabled, isForceEnabled;

    local timerunningSeason = API.GetTimerunningSeason();

    for _, moduleData in pairs(self.modules) do
        if moduleData.timerunningSeason and moduleData.timerunningSeason ~= timerunningSeason then
            moduleData.validityCheck = function()
                return false
            end;
        end
    end

    for _, moduleData in pairs(self.modules) do
        isForceEnabled = false;
        if (not moduleData.validityCheck) or (moduleData.validityCheck()) then
            enabled = db[moduleData.dbKey];

            if (not enabled) and (self.newDBKeys[moduleData.dbKey]) then
                enabled = true;
                isForceEnabled = true;
                db[moduleData.dbKey] = true;
            end

            if moduleData.requiredDBValues then
                for dbKey, value in pairs(moduleData.requiredDBValues) do
                    if db[dbKey] ~= nil and db[dbKey] ~= value then
                        enabled = false;
                    end
                end
            end

            moduleData.toggleFunc(enabled);

            if enabled and isForceEnabled then
                API.PrintMessage(string.format(L["New Feature Auto Enabled Format"], moduleData.name));     --Todo: click link to view detail |cff71d5ff
            end
        end
    end

    self.newDBKeys = {};
end

function ControlCenter:UpdateCategoryButtons()
    for _, categoryButton in pairs(self.CategoryButtons) do
        categoryButton:UpdateModuleCount();
    end
end

function ControlCenter:UpdateButtonStates()
    local db = PlumberDB;

    for _, button in pairs(self.Checkboxs) do
        if button.dbKey then
            button:SetChecked( db[button.dbKey] );
            if button.OptionToggle then
                button.OptionToggle:SetShown(button:GetChecked());
            end
            if button.subOptionWidgets then
                local enabled = db[button.dbKey];
                for _, widget in ipairs(button.subOptionWidgets) do
                    widget:SetChecked(GetDBBool(widget.dbKey));
                    widget:SetEnabled(enabled);
                end
            end
        else
            button:SetChecked(false);
        end
    end

    self:UpdateCategoryButtons();
end

function ControlCenter:AddModule(moduleData)
    --moduleData = {name = ModuleName, dbKey = PlumberDB[key], description = string, toggleFunc = function, validityCheck = function, categoryID = number, uiOrder = number}

    if not moduleData.categoryID then
        moduleData.categoryID = 0;
        moduleData.uiOrder = 0;
        print("Plumber Debug:", moduleData.name, "No Category");
    end

    table.insert(self.modules, moduleData);

    if moduleData.visibleInEditMode then
        addon.AddEditModeVisibleModule(moduleData);
    end
end


ControlCenter:RegisterEvent("PLAYER_ENTERING_WORLD");

ControlCenter:SetScript("OnEvent", function(self, event, ...)
    self:UnregisterEvent(event);
    self:SetScript("OnEvent", nil);
    ControlCenter:InitializeModules();
end);


if Settings then
    local category = Settings.RegisterCanvasLayoutCategory(BlizzardPanel, "Plumber");
    Settings.RegisterAddOnCategory(category);

    BlizzardPanel:SetScript("OnShow", function(self)
        ControlCenter:Hide();
        ControlCenter:SetParent(BlizzardPanel);
        ControlCenter:ClearAllPoints();
        ControlCenter:SetPoint("TOPLEFT", self, "TOPLEFT", -12, 25);
        ControlCenter:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
        ControlCenter:ShowUI("blizzard");
    end);

    BlizzardPanel:SetScript("OnHide", function(self)
        self:Hide();
        ControlCenter:Hide();
    end);

    --local bg = BlizzardPanel:CreateTexture(nil, "BACKGROUND");
    --bg:SetAllPoints(true);
    --bg:SetColorTexture(1, 0, 0, 0.5);
end


do  --Our SuperTracking system is unused
    function ControlCenter:ShouldShowNavigatorOnDreamseedPins()
        return PlumberDB.Navigator_Dreamseed and not PlumberDB.Navigator_MasterSwitch
    end

    function ControlCenter:EnableSuperTracking()
        --PlumberDB.Navigator_MasterSwitch = true;
        --local SuperTrackFrame = addon.GetSuperTrackFrame();
        --SuperTrackFrame:TryEnableByModule();
    end
end


do
    addon.CallbackRegistry:Register("NewDBKeysAdded", function(newDBKeys)
        ControlCenter.newDBKeys = newDBKeys;
    end);

    local function ToggleFunc_EnableNewByDefault(state)

    end

    local moduleData = {
        name = L["ModuleName EnableNewByDefault"],
        dbKey = "EnableNewByDefault",
        description = L["ModuleDescription EnableNewByDefault"],
        toggleFunc = ToggleFunc_EnableNewByDefault,
        categoryID = 1208,
        uiOrder = 1,
    };

    ControlCenter:AddModule(moduleData);
end


do  --Press Escape to close
    local CloseDummy = CreateFrame("Frame", "PlumberSharedUISpecialFrame", UIParent);
    CloseDummy:Hide();
    table.insert(UISpecialFrames, CloseDummy:GetName());

    CloseDummy:SetScript("OnHide", function()
        ControlCenter:Hide();
    end);

    ControlCenter:HookScript("OnShow", function()
        if ControlCenter.mode == "standalone" then
            CloseDummy:Show();
        end
    end);

    ControlCenter:HookScript("OnHide", function()
        CloseDummy:Hide();
    end);
end


do  --Globals, AddOn Compartment
    local function Plumber_ToggleSettings()
        if BlizzardPanel:IsShown() then return end;

        if ControlCenter:IsShown() then
            ControlCenter:Hide();
        else
            ControlCenter:ClearAllPoints();
            ControlCenter:SetParent(UIParent);
            ControlCenter:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
            ControlCenter:ShowUI();
        end
    end
    _G.Plumber_ToggleSettings = Plumber_ToggleSettings;


    local IDENTIFIER = "PlumberSettings";

    local function AddonCompartment_OnClick()
        Plumber_ToggleSettings();
    end

    local function AddonCompartment_OnEnter(menuButton)
        local tooltip = GameTooltip;
        tooltip:SetOwner(menuButton, "ANCHOR_NONE");
        tooltip:SetPoint("TOPRIGHT", menuButton, "TOPLEFT", -12, 0);
        tooltip:SetText(L["Module Category Plumber"], 1, 1, 1);
        tooltip:AddLine(L["Click To Show Settings"], 1, 0.82, 0, true);
        tooltip:Show();
    end

    local function AddonCompartment_OnLeave(menuButton)
        GameTooltip:Hide();
    end

    API.AddButtonToAddonCompartment(IDENTIFIER, L["Module Category Plumber"], "Interface/AddOns/Plumber/Art/Logo/PlumberLogo64", AddonCompartment_OnClick, AddonCompartment_OnEnter, AddonCompartment_OnLeave);
end