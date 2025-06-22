local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;


local TrackerTab;
local EditorPopup;
local PopupLayouts = {};
local DropdownInfoGetters = {};
local SearchResultMenu = {};


local POPUP_WIDTH = 408;


local Enum_TrackerTypes = {
    "Boss",
    "Instance",
    "Quest",
    "Rare",
};

do  --DropdownInfoGetters
    local function GetSelectedTrackerTypeText()
        local trackerType = EditorPopup and EditorPopup.trackerType;
        if trackerType and Enum_TrackerTypes[trackerType] then
            return L["TrackerType "..Enum_TrackerTypes[trackerType]];
        else
            return L["Select Instruction"]
        end
    end
    DropdownInfoGetters.GetSelectedTrackerTypeText = GetSelectedTrackerTypeText;

    function DropdownInfoGetters.NewTrackerType()
        local tbl = {
            key = "TrackerEditor.TrackerType",
        };

        local selectedTrackerType = EditorPopup.trackerType
        local widgets = {};

        for k, v in ipairs(Enum_TrackerTypes) do
            widgets[k] = {
                type = "Radio",
                text = L["TrackerType "..v];
                closeAfterClick = true,
                onClickFunc = function()
                    EditorPopup:SetLayoutByID(k);
                    EditorPopup:Show();
                end,
                selected = k == selectedTrackerType,
            };
        end
        tbl.widgets = widgets;

        return tbl
    end


    function DropdownInfoGetters.GetValidDifficulties()
        local instanceID, encounterID = EditorPopup.instanceID, EditorPopup.encounterID;
        local selectedDifficultyID = EditorPopup.difficultyID;
        local difficulties = instanceID and encounterID and API.GetValidDifficultiesForEncounter(instanceID, encounterID);
        if difficulties then
            local tbl = {
                key = "TrackerEditor.ValidDifficulties",
            };

            local widgets = {};
            for k, v in ipairs(difficulties) do
                widgets[k] = {
                    type = "Radio",
                    text = v.text;
                    closeAfterClick = true,
                    onClickFunc = function()
                        EditorPopup:SetDifficultyID(v.difficultyID);
                    end,
                    selected = v.difficultyID == selectedDifficultyID,
                };
            end
            tbl.widgets = widgets;

            return tbl
        end
    end

    function DropdownInfoGetters.GetSelectedDifficultyText()
        local selectedDifficultyID = EditorPopup.difficultyID;
        if selectedDifficultyID then
            return API.GetRaidDifficultyString(selectedDifficultyID)
        else
            return NONE
        end
    end
end


local EditorPopup_Init;
do  --EditorPopupMixin
    local EditorPopupMixin = {};

    function EditorPopupMixin:ReleaseAllObjects()
        self.LabelFramePool:ReleaseAll();
        self.DropdownButtonPool:ReleaseAll();
        self.EditBoxPool:ReleaseAll();
        self.CheckboxPool:ReleaseAll();
        self.keyXWidget = {};
    end

    function EditorPopupMixin:SetLayoutByID(trackerTypeID)
        local layoutKey = Enum_TrackerTypes[trackerTypeID];
        if layoutKey then
            self.trackerType = trackerTypeID;
            self:SetLayout(layoutKey);
        end
    end

    function EditorPopupMixin:SetLayout(layoutKey)
        self:ReleaseAllObjects();
        if PopupLayouts[layoutKey] then
            self.layoutKey = layoutKey;
            local offsetY = 36;
            local rowHeight = 24;
            local rowGap = 16;
            local f, obj;

            for k, v in ipairs(PopupLayouts[layoutKey]) do
                obj = nil;
                f = self.LabelFramePool:Acquire();
                f.Label:SetText(v.label);
                if v.disabled then
                    f.Label:SetTextColor(0.5, 0.5, 0.5);
                else
                    f.Label:SetTextColor(0.804, 0.667, 0.498);
                end
                f:SetPoint("TOP", self, "TOP", 0, -offsetY);
                offsetY = offsetY + rowHeight;
                offsetY = offsetY + rowGap;

                if v.type == "Dropdown" then
                    obj = self.DropdownButtonPool:Acquire();
                    obj:SetParent(f);
                    obj:SetPoint("RIGHT", f, "RIGHT", 0, 0);
                    obj.menuInfoGetter = v.menuInfoGetter;
                    if v.valueGetter then
                        obj:SetText(v.valueGetter());
                    end

                elseif v.type == "EditBox" then
                    obj = self.EditBoxPool:Acquire();
                    obj:SetParent(f);
                    obj:SetPoint("RIGHT", f, "RIGHT", 0, 0);
                    obj:SetInstruction(v.instruction);
                    obj:SetIsSearchBox(v.isSearchbox);
                    obj.HasStickyFocus = v.HasStickyFocus;
                    obj:SetNumeric(v.numeric);
                    obj:SetSearchFunc(v.searchFunc);
                    obj:SetOnEditFocusGainedCallback(v.onEditFocusGainedCallback);
                    obj:SetOnEditFocusLostCallback(v.onEditFocusLostCallback);
                    obj:SetDisabledTooltipText(v.disabledTooltipText);
                    if v.disabled then
                        obj:Disable();
                    else
                        obj:Enable();
                    end

                elseif v.type == "Checkbox" then
                    obj = self.CheckboxPool:Acquire();
                    obj:SetParent(f);
                    obj:SetPoint("LEFT", f, "LEFT", 0, 0);
                    obj:SetText(v.label);
                    f.Label:SetText(nil);

                end

                if obj and v.widgetKey then
                    self.keyXWidget[v.widgetKey] = obj;
                end

                if k == 1 then
                    local gap = 4;
                    offsetY = offsetY + gap;
                    self.Divider:ClearAllPoints();
                    self.Divider:SetPoint("CENTER", self, "TOP", 0, -offsetY);
                    offsetY = offsetY + gap + rowGap;
                end
            end
        end
    end

    function EditorPopupMixin:ShowHomePage()
        self:SetLayout("HomePage");
        self:Show();
    end

    function EditorPopupMixin:SetInstanceAndEncounter(instanceID, encounterID)
        self.instanceID = instanceID;
        self.encounterID = encounterID;

        local difficulties = instanceID and encounterID and API.GetValidDifficultiesForEncounter(instanceID, encounterID);
        if difficulties then
            local bestDifficultyID;
            if self.difficultyID then
                for k, v in ipairs(difficulties) do
                    if v.difficultyID == self.difficultyID then
                        bestDifficultyID = v.difficultyID;
                    end
                end
            end

            if not bestDifficultyID then
                bestDifficultyID = difficulties[1].difficultyID;
            end

            self:SetDifficultyID(bestDifficultyID);
        end
    end

    function EditorPopupMixin:SetDifficultyID(difficultyID)
        self.difficultyID = difficultyID;
        local dropdownButton = self:GetWidgetByKey("DifficultyDropdown");
        if dropdownButton then
            dropdownButton:SetText(DropdownInfoGetters.GetSelectedDifficultyText());
        end
    end

    function EditorPopupMixin:GetWidgetByKey(widgetKey)
        return self.keyXWidget and self.keyXWidget[widgetKey] or nil;
    end

    function EditorPopup_Init()
        if EditorPopup then return end;

        local self = CreateFrame("Frame", nil, TrackerTab);
        EditorPopup = self;
        API.Mixin(self, EditorPopupMixin);
        self:SetSize(POPUP_WIDTH, 480);
        self:SetFrameStrata("DIALOG");

        local MainFrame = PlumberExpansionLandingPage;

        self:SetPoint("CENTER", MainFrame, "CENTER", 0, 0);

        local BlackScreen = self:CreateTexture(nil, "BACKGROUND", nil, -1);
        BlackScreen:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 8, -8);
        BlackScreen:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -8, 8);
        BlackScreen:SetColorTexture(0, 0, 0, 0.8);

        local NineSlice = LandingPageUtil.CreateExpansionThemeFrame(self, 10);
        self.NineSlice = NineSlice;
        NineSlice:ShowCloseButton(true);
        NineSlice:SetCloseButtonOwner(self);

        local Header = LandingPageUtil.CreateListCategoryButton(self, L["New Tracker Title"]);
        self.Header = Header;
        Header:SetPoint("CENTER", self, "TOP", 0, -4);


        local Divider = LandingPageUtil.CreateMajorDivider(self);
        self.Divider = Divider;
        Divider:SetPoint("CENTER", self, "CENTER", 0, 0);
        Divider:SetWidth(POPUP_WIDTH - 32);


        local function LabelFrame_Create()
            local f = CreateFrame("Frame", nil, self);
            f:SetSize(POPUP_WIDTH - 80, 24);

            local fs = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            f.Label = fs;
            fs:SetTextColor(0.804, 0.667, 0.498);
            fs:SetJustifyH("LEFT");
            fs:SetPoint("LEFT", f, "LEFT", 0, 0);

            return f
        end

        local LabelFramePool = LandingPageUtil.CreateObjectPool(LabelFrame_Create);
        self.LabelFramePool = LabelFramePool;


        local widgetWidth = 192;

        local function DropdownButton_Create()
            local f = LandingPageUtil.CreateDropdownButton(self);
            f:SetWidth(widgetWidth);
            return f
        end

        local DropdownButtonPool = LandingPageUtil.CreateObjectPool(DropdownButton_Create);
        self.DropdownButtonPool = DropdownButtonPool;


        local function Checkbox_Create()
            local f = LandingPageUtil.CreateCheckboxButton(self);
            f:SetWidth(widgetWidth);
            return f
        end

        local CheckboxPool = LandingPageUtil.CreateObjectPool(Checkbox_Create);
        self.CheckboxPool = CheckboxPool;


        local function EditBox_Create()
            local f = LandingPageUtil.CreateEditBox(self);
            f:SetWidth(widgetWidth);
            return f
        end

        local function EditBox_Remove(obj)
            obj:SetText("");
            obj:ClearCallbacks();
        end

        local EditBoxPool = LandingPageUtil.CreateObjectPool(EditBox_Create, EditBox_Remove);
        self.EditBoxPool = EditBoxPool;
    end
end


local function HasStickyFocus(searchBox)
    if searchBox:IsMouseOver() or SearchResultMenu:IsFocused() then
        return true
    end
end

local function SearchBox_OnEditFocusGainedCallback(searchBox)
    SearchResultMenu:SetOwner(searchBox);
    searchBox:HighlightText();
end

local function SearchBox_OnEditFocusLostCallback(searchBox)
    SearchResultMenu:HideMenu();
    searchBox:SetCursorPosition(0);
end


do  --SearchResultMenu
    function SearchResultMenu:OnLoad()
        self.OnLoad = nil;
        LandingPageUtil.CreateMenuFrame(TrackerTab, self);
        self:SetKeepContentOnHide(true);
        self:SetNoAutoHide(true);
        self.name = "SearchResultMenu";
    end

    function SearchResultMenu:IsFocused()
        return self.Frame and self.Frame:IsShown() and self.Frame:IsMouseOver()
    end

    function SearchResultMenu:SetOwner(searchBox)
        if self.OnLoad then
            self:OnLoad();
        end

        if searchBox and searchBox == self.owner then
            self:AnchorToObject(searchBox);
            if self.Frame then
                self.Frame:Show();
            end
        end

        self.owner = searchBox;
        if not searchBox then
            self:Hide();
        end
    end

    function SearchResultMenu:OnSearchComplete(results)
        if not(self.owner and self.owner:HasFocus()) then return end;

        if self.OnLoad then
            self:OnLoad();
        end

        if results then
            local menuInfo = {
                key = "TrackerEditor.SearchResult",
            };

            local format = string.format;
            local nameFormat = "%s, |cff808080%s|r";

            local widgets = {};
            for k, v in ipairs(results) do
                widgets[k] = {
                    type = "Button",
                    text = format(nameFormat, v.name, v.instanceName);
                    closeAfterClick = true,
                    onClickFunc = function(mouseButton)
                        self.owner:SetText(v.name);
                        self.owner:ClearFocus();
                        EditorPopup:SetInstanceAndEncounter(v.instanceID, v.encounterID);
                    end,
                };
            end
            menuInfo.widgets = widgets;

            self:ShowMenu(self.owner, menuInfo);
        else
            self:ShowMenu(self.owner, nil);
            print("NO DATA")
        end
    end
end


do  --PopupLayouts
    local SharedHeader = {type = "Dropdown", label = L["Type"], menuInfoGetter = DropdownInfoGetters.NewTrackerType, valueGetter = DropdownInfoGetters.GetSelectedTrackerTypeText};

    PopupLayouts.HomePage = {
        SharedHeader
    };

    PopupLayouts.Boss = {
        SharedHeader,
        {type = "EditBox", label = L["Name"], instruction = L["Boss Or Instance Name"], isSearchbox = true, HasStickyFocus = HasStickyFocus,
            searchFunc = function(text) LandingPageUtil.SearchBoss(text, SearchResultMenu) end,
            onEditFocusGainedCallback = SearchBox_OnEditFocusGainedCallback,
            onEditFocusLostCallback = SearchBox_OnEditFocusLostCallback,
        },
        {type = "Dropdown", label = L["Difficulty"], widgetKey = "DifficultyDropdown", menuInfoGetter = DropdownInfoGetters.GetValidDifficulties, valueGetter = DropdownInfoGetters.GetSelectedDifficultyText},
    };

    PopupLayouts.Instance = {
        SharedHeader,
        {type = "EditBox", label = L["Name"], instruction = L["Instance Or Boss Name"], isSearchbox = true, HasStickyFocus = HasStickyFocus,
            searchFunc = function(text) LandingPageUtil.SearchInstance(text, SearchResultMenu) end,
            onEditFocusGainedCallback = SearchBox_OnEditFocusGainedCallback,
            onEditFocusLostCallback = SearchBox_OnEditFocusLostCallback,
        },
        {type = "Dropdown", label = L["Difficulty"], widgetKey = "DifficultyDropdown", menuInfoGetter = DropdownInfoGetters.GetValidDifficulties, valueGetter = DropdownInfoGetters.GetSelectedDifficultyText},
    };

    PopupLayouts.Quest = {
        SharedHeader,
        {type = "EditBox", label = "Quest ID", numeric = true},
        {type = "EditBox", label = L["Name"], disabled = true, disabledTooltipText = L["Name EditBox Disabled Reason Format"]:format("Quest ID")},
        {type = "Checkbox", label = L["Accountwide"]},
    };

    PopupLayouts.Rare = {
        SharedHeader,
        {type = "EditBox", label = "Creature ID", numeric = true},
        {type = "EditBox", label = L["Name"], disabled = true, disabledTooltipText = L["Name EditBox Disabled Reason Format"]:format("Creature ID")},
        {type = "EditBox", label = L["Quest Flag"], numeric = true},
        {type = "Checkbox", label = L["Accountwide"]},
    };
end


local TrackerTabMixin = {};
do
    function TrackerTabMixin:OnShow()
        EditorPopup:ShowHomePage();
    end

    function TrackerTabMixin:OnHide()

    end

    function TrackerTabMixin:OnEvent()

    end

    function TrackerTabMixin:Init()
        self.Init = nil;
        EditorPopup_Init();
    end
end


local function CreateTrackerTab(f)
    TrackerTab = f;
    API.Mixin(f, TrackerTabMixin);
    f:Init();
    f:SetScript("OnShow", f.OnShow);
    f:SetScript("OnHide", f.OnHide);
    f:SetScript("OnEvent", f.OnEvent);
end

LandingPageUtil.AddTab(
    {
        key = "tracker",
        name = L["Trackers"],
        uiOrder = 4,
        initFunc = CreateTrackerTab,
        dimBackground = true,
    }
);