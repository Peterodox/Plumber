local _, addon = ...
local API = addon.API;
local L = addon.L;
local tinsert = table.insert
local CreateFrame = CreateFrame;

local RATIO = 0.75; --h/w
local FRAME_WIDTH = 600;
local PADDING = 16;
local BUTTON_HEIGHT = 24;
local OPTION_GAP_Y = 8;
local DIFFERENT_CATEGORY_OFFSET = 8;
local LEFT_SECTOR_WIDTH = math.floor(0.618*FRAME_WIDTH + 0.5);

local CATEGORY_ORDER = {
    --Must match the keys in the localization

    [0] = "Unknown",    --Used during development

    [1] = "General",
    [2] = "NPC Interaction",
    [3] = "Class",

    --Patch Feature uses the tocVersion and #00
    [10020000] = "Dragonflight",
};


local DEFAULT_COLLAPSED_CATEGORY = {
    [10020000] = true;
};


local ControlCenter = CreateFrame("Frame", nil, UIParent);
addon.ControlCenter = ControlCenter;
ControlCenter:SetSize(FRAME_WIDTH, FRAME_WIDTH * RATIO);
ControlCenter:SetPoint("TOP", UIParent, "BOTTOM", 0, -64);
ControlCenter.modules = {};
ControlCenter:Hide();

local ScrollFrame = CreateFrame("Frame", nil, ControlCenter);
ScrollFrame:SetPoint("TOPLEFT", ControlCenter, "TOPLEFT", 0, 0);
ScrollFrame:SetPoint("BOTTOMLEFT", ControlCenter, "BOTTOMLEFT", 0, 0);
ScrollFrame:SetWidth(LEFT_SECTOR_WIDTH);
ControlCenter.ScrollFrame = ScrollFrame;


do
    local OFFSET_PER_SCROLL = (BUTTON_HEIGHT + OPTION_GAP_Y) * 2;

    local function ScrollFrame_OnMouseWheel(self, delta)
        if self.scrollOffset > 0 and delta > 0 then
            self.scrollOffset = self.scrollOffset - OFFSET_PER_SCROLL;
            if self.scrollOffset < 0 then
                self.scrollOffset = 0;
            end
            self.ScrollChild:SetPoint("TOPLEFT", self, "TOPLEFT", 0, self.scrollOffset);
        elseif self.scrollOffset < self.scrollRange and delta < 0 then
            self.scrollOffset = self.scrollOffset + OFFSET_PER_SCROLL;
            if self.scrollOffset > self.scrollRange then
                self.scrollOffset = self.scrollRange;
            end
            self.ScrollChild:SetPoint("TOPLEFT", self, "TOPLEFT", 0, self.scrollOffset);
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

    function ControlCenter:UpdateScrollRange()
        local frameHeight = self.ScrollFrame:GetHeight();
        local firstButton = self.CategoryButtons[1];
        local lastObject = self.lastCategoryButton.Drawer;

        local contentHeight = 2 * PADDING + firstButton:GetTop() - lastObject:GetBottom();

        self:SetScrollRange(math.ceil(contentHeight - frameHeight));
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
    newTag:SetPoint("RIGHT", button, "LEFT", -8, 0);
    newTag:Show();
end


local CategoryButtonMixin = {};

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
    self.drawerHeight = #self.childOptions * (OPTION_GAP_Y + BUTTON_HEIGHT) + OPTION_GAP_Y + DIFFERENT_CATEGORY_OFFSET;
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
    tinsert(self.childOptions, checkbox);
end

function CategoryButtonMixin:UpdateNineSlice(offset)
    --Texture Slice don't follow its parent scale
    --This texture has 4px gap in each direction
    --Unused
    self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", -offset, offset);
    self.Background:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", offset, -offset);
end


local function CreateCategoryButton(parent)
    local b = CreateFrame("Button", nil, parent);

    b:SetSize(LEFT_SECTOR_WIDTH - PADDING, BUTTON_HEIGHT);

    b.Background = b:CreateTexture(nil, "BACKGROUND");
    b.Background:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/CategoryButton-NineSlice");
    b.Background:SetTextureSliceMargins(16, 16, 16, 16);
    b.Background:SetTextureSliceMode(0);
    b.Background:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0);
    b.Background:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0);
    --API.DisableSharpening(b.Background);

    local arrowOffsetX = 8;

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
        b:SetSize(24, 24);
        b:SetPoint("RIGHT", checkbox, "RIGHT", 0, 0);
        b.Texture = b:CreateTexture(nil, "OVERLAY");
        b.Texture:SetTexture("Interface/AddOns/Plumber/Art/Button/OptionToggle");
        b.Texture:SetSize(16, 16);
        b.Texture:SetPoint("CENTER", b, "CENTER", 0, 0);
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
    local CHECKBOX_WIDTH = LEFT_SECTOR_WIDTH - 2*PADDING;

    local db = PlumberDB;
    DB = db;
    local settingsOpenTime = db.settingsOpenTime or 0;

    local parent = ControlCenter;
    local showCloseButton = true;
    local f = addon.CreateHeaderFrame(parent, showCloseButton);
    parent.Frame = f;


    local ScrollChild = CreateFrame("Frame", nil, ScrollFrame);
    ScrollFrame.ScrollChild = ScrollChild;
    ScrollChild:SetSize(8, 8);
    ScrollChild:SetPoint("TOPLEFT", ScrollFrame, "TOPLEFT", 0, 0);

    local container = parent;

    f:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0);
    f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0);
    f:SetTitle(L["Module Control"]);

    local headerHeight = f:GetHeaderHeight();
    local previewSize = FRAME_WIDTH - LEFT_SECTOR_WIDTH - 2*PADDING + 4;

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
    description:SetPoint("TOPLEFT", preview, "BOTTOMLEFT", visualOffset + 4, -PADDING);
    description:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -PADDING - visualOffset, PADDING);
    description:SetShadowColor(0, 0, 0);
    description:SetShadowOffset(1, -1);

    local dividerTop = container:CreateTexture(nil, "OVERLAY");
    dividerTop:SetSize(16, 16);
    dividerTop:SetPoint("TOPRIGHT", container, "TOPLEFT", LEFT_SECTOR_WIDTH, -headerHeight);
    dividerTop:SetTexCoord(0, 1, 0, 0.25);

    local dividerBottom = container:CreateTexture(nil, "OVERLAY");
    dividerBottom:SetSize(16, 16);
    dividerBottom:SetPoint("BOTTOMRIGHT", container, "BOTTOMLEFT", LEFT_SECTOR_WIDTH, 0);
    dividerBottom:SetTexCoord(0, 1, 0.75, 1);

    local dividerMiddle = container:CreateTexture(nil, "OVERLAY");
    dividerMiddle:SetPoint("TOPLEFT", dividerTop, "BOTTOMLEFT", 0, 0);
    dividerMiddle:SetPoint("BOTTOMRIGHT", dividerBottom, "TOPRIGHT", 0, 0);
    dividerMiddle:SetTexCoord(0, 1, 0.25, 0.75);

    dividerTop:SetTexture("Interface/AddOns/Plumber/Art/Frame/Divider_DropShadow_Vertical");
    dividerBottom:SetTexture("Interface/AddOns/Plumber/Art/Frame/Divider_DropShadow_Vertical");
    dividerMiddle:SetTexture("Interface/AddOns/Plumber/Art/Frame/Divider_DropShadow_Vertical");

    API.DisableSharpening(dividerTop);
    API.DisableSharpening(dividerBottom);
    API.DisableSharpening(dividerMiddle);


    local SelectionTexture = ScrollChild:CreateTexture(nil, "ARTWORK");
    SelectionTexture:SetSize(LEFT_SECTOR_WIDTH - PADDING, BUTTON_HEIGHT);
    SelectionTexture:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/SelectionTexture");
    SelectionTexture:SetVertexColor(1, 1, 1, 0.1);
    SelectionTexture:SetBlendMode("ADD");
    SelectionTexture:Hide();


    local checkbox;
    local fromOffsetY = PADDING; -- +headerHeight
    local numButton = 0;

    parent.Checkboxs = {};
    parent.CategoryButtons = {};

    local function Checkbox_OnEnter(self)
        description:SetText(self.data.description);
        preview:SetTexture("Interface/AddOns/Plumber/Art/ControlCenter/Preview_"..self.dbKey);
        SelectionTexture:ClearAllPoints();
        SelectionTexture:SetPoint("LEFT", self, "LEFT", -PADDING, 0);
        SelectionTexture:Show();
        if self.OptionToggle then
            OptionToggle_SetFocused(self.OptionToggle, true);
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
    end

    local function OptionToggle_OnEnter(self)
        Checkbox_OnEnter(self:GetParent());
        self.Texture:SetVertexColor(1, 1, 1);
    end

    local function OptionToggle_OnLeave(self)
        Checkbox_OnLeave(self:GetParent());
        self.Texture:SetVertexColor(0.6, 0.6, 0.6);
    end

    local newCategoryPosition = {};

    local function SortFunc_Module(a, b)
        if a.categoryID ~= b.categoryID then
            return a.categoryID < b.categoryID
        end

        if a.uiOrder ~= b.uiOrder then
            return a.uiOrder < b.uiOrder
            --should be finished here
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

    local lastCategoryButton;
    local positionInCategory;

    for i, data in ipairs(parent.modules) do
        if newCategoryPosition[i] then
            local categoryButton = CreateCategoryButton(ScrollChild);
            tinsert(parent.CategoryButtons, categoryButton);

            if i == 1 then
                categoryButton:SetPoint("TOPLEFT", ScrollChild, "TOPLEFT", PADDING, -fromOffsetY);
            else
                categoryButton:SetPoint("TOPLEFT", lastCategoryButton.Drawer, "BOTTOMLEFT", 0, 0);
            end

            categoryButton:SetCategory(data.categoryID);

            lastCategoryButton = categoryButton;
            positionInCategory = 0;
        end

        numButton = numButton + 1;
        checkbox = addon.CreateCheckbox(lastCategoryButton.Drawer);
        parent.Checkboxs[numButton] = checkbox;
        checkbox.dbKey = data.dbKey;
        checkbox:SetPoint("TOPLEFT", lastCategoryButton.Drawer, "TOPLEFT", 8, -positionInCategory * (OPTION_GAP_Y + BUTTON_HEIGHT) - OPTION_GAP_Y);
        checkbox.data = data;
        checkbox.onEnterFunc = Checkbox_OnEnter;
        checkbox.onLeaveFunc = Checkbox_OnLeave;
        checkbox.onClickFunc = Checkbox_OnClick;
        checkbox:SetFixedWidth(CHECKBOX_WIDTH);
        checkbox:SetLabel(data.name);

        if data.moduleAddedTime and data.moduleAddedTime > settingsOpenTime then
            CreateNewFeatureMark(checkbox);
        end

        if data.optionToggleFunc then
            local button = CreateOptionToggle(checkbox, data.optionToggleFunc);
            button:SetScript("OnEnter", OptionToggle_OnEnter);
            button:SetScript("OnLeave", OptionToggle_OnLeave);
        end

        lastCategoryButton:AddChildOption(checkbox);
        positionInCategory = positionInCategory + 1;
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


    function ControlCenter:UpdateLayout()
        local frameWidth = math.floor(self:GetWidth() + 0.5);
        if frameWidth == self.frameWidth then
            return
        end
        self.frameWidth = frameWidth;

        local leftSectorWidth = math.floor(0.618*frameWidth + 0.5);

        dividerTop:SetPoint("TOPRIGHT", container, "TOPLEFT", leftSectorWidth, -headerHeight);
        dividerBottom:SetPoint("BOTTOMRIGHT", container, "BOTTOMLEFT", leftSectorWidth, 0);

        previewSize = frameWidth - leftSectorWidth - 2*PADDING + 4;
        preview:SetSize(previewSize, previewSize);

        ScrollFrame:SetWidth(leftSectorWidth);
    end
end

function ControlCenter:ShowUI(onBlizzardOptionsUI)
    if CreateUI then
        CreateUI();
        CreateUI = nil;
    end

    self:Show();
    self.Frame:SetShown(not onBlizzardOptionsUI);
    self:UpdateLayout();
    self:UpdateButtonStates();
    self:UpdateScrollRange();
end

function ControlCenter:InitializeModules()
    --Initial Enable/Disable Modules
    local db = PlumberDB;
    local enabled;

    for _, moduleData in pairs(self.modules) do
        if (not moduleData.validityCheck) or (moduleData.validityCheck()) then
            enabled = db[moduleData.dbKey];
            if moduleData.requiredDBValues then
                for dbKey, value in pairs(moduleData.requiredDBValues) do
                    if db[dbKey] ~= nil and db[dbKey] ~= value then
                        enabled = false;
                    end
                end
            end
            moduleData.toggleFunc(enabled);
        end
    end
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
end


ControlCenter:RegisterEvent("PLAYER_ENTERING_WORLD");

ControlCenter:SetScript("OnEvent", function(self, event, ...)
    self:UnregisterEvent(event);
    self:SetScript("OnEvent", nil);
    ControlCenter:InitializeModules();
end);

ControlCenter:SetScript("OnShow", function(self)
    local hideBackground = true;
    self:ShowUI(hideBackground);
end);




if Settings then
    local panel = ControlCenter;
    local category = Settings.RegisterCanvasLayoutCategory(panel, "Plumber");
    Settings.RegisterAddOnCategory(category);
end


do
    function ControlCenter:ShouldShowNavigatorOnDreamseedPins()
        return PlumberDB.Navigator_Dreamseed and not PlumberDB.Navigator_MasterSwitch
    end

    function ControlCenter:EnableSuperTracking()
        PlumberDB.Navigator_MasterSwitch = true;
        local SuperTrackFrame = addon.GetSuperTrackFrame();
        SuperTrackFrame:TryEnableByModule();
    end
end