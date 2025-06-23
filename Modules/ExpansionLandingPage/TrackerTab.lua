local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;
local CallbackRegistry = addon.CallbackRegistry;


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
                rightTexture = string.format("Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/TrackerType-%s.png", v);
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


local LabelFrameMixin = {};
do
    function LabelFrameMixin:SetOptionEnabled(state)
        if state then
            self.Label:SetTextColor(0.804, 0.667, 0.498);
        else
            self.Label:SetTextColor(0.5, 0.5, 0.5);
        end
    end

    function LabelFrameMixin:SetLabelText(text)
        self.Label:SetText(text);
    end
end


local EditorPopupMixin = {};
local EditorPopup_Init;
do  --EditorPopupMixin
    function EditorPopupMixin:ReleaseAllObjects()
        self.LabelFramePool:ReleaseAll();
        self.DropdownButtonPool:ReleaseAll();
        self.EditBoxPool:ReleaseAll();
        self.CheckboxPool:ReleaseAll();
        self.keyXWidget = {};
        SearchResultMenu:ClearResult();
    end

    function EditorPopupMixin:SetLayoutByID(trackerTypeID)
        local layoutKey = Enum_TrackerTypes[trackerTypeID];
        if layoutKey then
            self.trackerType = trackerTypeID;
            if layoutKey ~= self.layoutKey then
                self:ClearArguments();
                self:SetLayout(layoutKey);
            end
        end
    end

    function EditorPopupMixin:ClearArguments()
        self.instanceID = nil;
        self.encounterID = nil;
        self.difficultyID = nil;
        self.creatureID = nil;
        self.questID = nil;
    end

    function EditorPopupMixin:SetLayout(layoutKey)
        self:ReleaseAllObjects();
        if not PopupLayouts[layoutKey] then return end;

        self.layoutKey = layoutKey;
        self.CanSaveOptions = self["CanSaveOptions_"..layoutKey] or self.CanSaveOptions_False;

        local offsetY = 36;
        local rowHeight = 24;
        local rowGap = 16;
        local f, obj;
        local headerHeight = 80;

        for k, v in ipairs(PopupLayouts[layoutKey]) do
            obj = nil;
            f = self.LabelFramePool:Acquire();
            f:SetLabelText(v.label);
            f:SetOptionEnabled(not v.disabled);
            f:SetPoint("TOP", self, "TOP", 0, -offsetY);
            offsetY = offsetY + rowHeight;
            offsetY = offsetY + rowGap;

            if v.type == "Dropdown" then
                obj = self.DropdownButtonPool:Acquire();
                obj:SetParent(f);
                obj:SetPoint("RIGHT", f, "RIGHT", 0, 0);
                obj:SetEnabled(not v.disabled);
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
                if v.isSearchbox then
                    obj:SetSearchResultMenu(SearchResultMenu);
                end
                obj.HasStickyFocus = v.HasStickyFocus;
                obj:SetNumeric(v.numeric);
                obj:SetMaxLetters(v.maxLetters or 0);
                obj:SetSearchFunc(v.searchFunc);
                obj:SetOnEditFocusGainedCallback(v.onEditFocusGainedCallback);
                obj:SetOnEditFocusLostCallback(v.onEditFocusLostCallback);
                obj:SetDisabledTooltipText(v.disabledTooltipText);
                obj:SetEnabled(not v.disabled);

            elseif v.type == "Checkbox" then
                obj = self.CheckboxPool:Acquire();
                obj:SetParent(f);
                obj:SetPoint("LEFT", f, "LEFT", 0, 0);
                obj:SetText(v.label);
                f.Label:SetText(nil);

            end

            if obj then
                obj.parentLabelFrame = f;
                if v.widgetKey then
                    self.keyXWidget[v.widgetKey] = obj;
                end
            end

            if k == 1 then
                local gap = 4;
                offsetY = offsetY + gap;
                self.Divider:ClearAllPoints();
                self.Divider:SetPoint("CENTER", self, "TOP", 0, -offsetY);
                headerHeight = offsetY;
                offsetY = offsetY + gap + rowGap;
            end
        end
        local totalHeight = offsetY + headerHeight;
        self:SetHeight(totalHeight);

        self:UpdateSaveButton();
    end

    function EditorPopupMixin:ShowHomePage()
        if not self.layoutKey then
            self:SetLayout("HomePage");
        end
        self:Show();
    end

    function EditorPopupMixin:SetInstanceAndEncounter(instanceID, encounterID)
        self.instanceID = instanceID;
        self.encounterID = encounterID;

        local valid, bestDifficultyID = API.IsDifficultyValidForEncounter(instanceID, encounterID, self.difficultyID);
        if bestDifficultyID then
            self:SetDifficultyID(bestDifficultyID);
            self:UpdateSaveButton(true);
        end
    end

    function EditorPopupMixin:SetDifficultyID(difficultyID)
        self.difficultyID = difficultyID;
        local dropdownButton = self:GetWidgetByKey("DifficultyDropdown");
        if dropdownButton then
            dropdownButton:Enable();
            dropdownButton:SetText(DropdownInfoGetters.GetSelectedDifficultyText());
            dropdownButton.parentLabelFrame:SetOptionEnabled(true);
            self:UpdateSaveButton();
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
            API.Mixin(f, LabelFrameMixin);
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


        local redButtonOffsetY = 24;
        local redButtonGap = 16;
        local redbuttonWidth = 0.5 * (POPUP_WIDTH - redButtonGap - 2*redButtonOffsetY);
        self.SaveButton = LandingPageUtil.CreateRedButton(self);
        self.SaveButton:SetWidth(redbuttonWidth);
        self.SaveButton:SetButtonText(SAVE);
        self.SaveButton:SetPoint("BOTTOMRIGHT", self, "BOTTOM", -0.5*redButtonGap, redButtonOffsetY);

        self.CancelButton = LandingPageUtil.CreateRedButton(self);
        self.CancelButton:SetWidth(redbuttonWidth);
        self.CancelButton:SetButtonText(CANCEL);
        self.CancelButton:SetPoint("BOTTOMLEFT", self, "BOTTOM", 0.5*redButtonGap, redButtonOffsetY);
        self.CancelButton:SetScript("OnClick", function()
            self:Hide();
        end);
    end
end


do  --EditorPopupMixin:CanSaveOptions
    function EditorPopupMixin:UpdateSaveButton(forceEnabled)
        local enabled;
        local disabledReason;

        if forceEnabled then
            enabled = true;
        else
            enabled = self:CanSaveOptions();
        end

        self.SaveButton:SetEnabled(enabled);
    end

    function EditorPopupMixin:CanSaveOptions()
        --Override
    end

    function EditorPopupMixin:CanSaveOptions_False()
        return false
    end

    function EditorPopupMixin:CanSaveOptions_Boss()
        if self.instanceID and self.encounterID and self.difficultyID then
            local valid = API.IsDifficultyValidForEncounter(self.instanceID, self.encounterID, self.difficultyID);
            return valid
        end
    end

    function EditorPopupMixin:CanSaveOptions_Instance()

    end

    function EditorPopupMixin:CanSaveOptions_Quest()
        --We also update some widgets here
        local valid;
        local questID = self.questID;
        local editBoxText;

        if questID then
            local name = API.GetQuestName(questID);
            if name then
                valid = true;
                editBoxText = name;
            else
                editBoxText = "";
                CallbackRegistry:LoadQuest(questID, function(_questID)
                    if self.layoutKey == "Quest" and self.questID == _questID then
                        self:UpdateSaveButton();
                    end
                end);
            end
        else
            editBoxText = "";
        end

        local nameEditBox = self:GetWidgetByKey("QuestNameEditBox");
        if nameEditBox then
            nameEditBox:SetText(editBoxText);
            nameEditBox:UpdateTextInsets();
        end

        return valid
    end

    function EditorPopupMixin:CanSaveOptions_Rare()
        --We also update some widgets here
        local valid;
        local creatureID = self.creatureID;
        local editBoxText;

        if creatureID then
            local name = API.GetAndCacheCreatureName(creatureID);
            if name then
                valid = true;
                editBoxText = name;
            else
                editBoxText = "";
                CallbackRegistry:LoadCreature(creatureID, function(_creatureID, _name)
                    if self.layoutKey == "Rare" and self.creatureID == _creatureID then
                        self:UpdateSaveButton();
                    end
                end);
            end
        else
            editBoxText = "";
        end

        local nameEditBox = self:GetWidgetByKey("CreatureNameEditBox");
        if nameEditBox then
            nameEditBox:SetText(editBoxText);
            nameEditBox:UpdateTextInsets();
        end

        return valid
    end
end


local function SearchBox_HasStickyFocus(searchBox)
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

local function SearchBox_QusetID(searchBox, questID)
    EditorPopup.questID = questID;
    EditorPopup:UpdateSaveButton();
end

local function SearchBox_CreatureID(searchBox, creatureID)
    --API.GetCreatureName
    EditorPopup.creatureID = creatureID;
    EditorPopup:UpdateSaveButton();
end


do  --SearchResultMenu
    function SearchResultMenu:OnLoad()
        self.OnLoad = nil;
        LandingPageUtil.CreateMenuFrame(TrackerTab, self);
        self:SetKeepContentOnHide(true);
        self:SetNoAutoHide(true);
        self:SetNoContentAlert(L["Search No Matches"]);
        self.name = "SearchResultMenu";
    end

    function SearchResultMenu:IsFocused()
        return self.Frame and self.Frame:IsShown() and self.Frame:IsMouseOver()
    end

    function SearchResultMenu:ClearResult()
        self.hasSeachResult = nil;
        self.owner = nil;
        if self.buttonPool then
            self.buttonPool:ReleaseAll();
        end
    end

    function SearchResultMenu:SetOwner(searchBox)
        if self.OnLoad then
            self:OnLoad();
        end

        if searchBox and searchBox == self.owner then
            self:AnchorToObject(searchBox);
            if self.Frame and self.hasSeachResult then
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
            local displayedName;
            local nameFormat1 = "%s, |cff808080%s|r";   --Grey instance name
            local nameFormat2 = "|cff808080%s|r, %s";   --Grey boss name

            local widgets = {};
            for k, v in ipairs(results) do
                if v.instanceName then
                    displayedName = format(nameFormat1, v.name, v.instanceName);
                elseif v.bossName then
                    displayedName = format(nameFormat2, v.bossName, v.name);
                else
                    displayedName = v.name;
                end
                widgets[k] = {
                    type = "Button",
                    text = displayedName,
                    closeAfterClick = true,
                    onClickFunc = function(mouseButton)
                        self.owner:SetText(v.name);
                        self.owner:ClearFocus();
                        EditorPopup:SetInstanceAndEncounter(v.instanceID, v.encounterID or 0);
                    end,
                };
            end
            menuInfo.widgets = widgets;

            self.firstOnClickFunc = widgets[1].onClickFunc;
            self:ShowMenu(self.owner, menuInfo);
        else
            self.firstOnClickFunc = nil;
            self:ShowMenu(self.owner, nil);
        end

        self.hasSeachResult = true;
    end

    function SearchResultMenu:SelectFirstResult()
        if self.firstOnClickFunc then
            self.firstOnClickFunc();
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
        {type = "EditBox", label = L["Name"], instruction = L["Boss Name"], isSearchbox = true, HasStickyFocus = SearchBox_HasStickyFocus,
            searchFunc = function(searchBox, text) LandingPageUtil.SearchBoss(text, SearchResultMenu) end,
            onEditFocusGainedCallback = SearchBox_OnEditFocusGainedCallback,
            onEditFocusLostCallback = SearchBox_OnEditFocusLostCallback,
        },
        {type = "Dropdown", label = L["Difficulty"], widgetKey = "DifficultyDropdown", disabled = true, menuInfoGetter = DropdownInfoGetters.GetValidDifficulties, valueGetter = DropdownInfoGetters.GetSelectedDifficultyText},
    };

    PopupLayouts.Instance = {
        SharedHeader,
        {type = "EditBox", label = L["Name"], instruction = L["Instance Or Boss Name"], isSearchbox = true, HasStickyFocus = SearchBox_HasStickyFocus,
            searchFunc = function(searchBox, text) LandingPageUtil.SearchInstance(text, SearchResultMenu) end,
            onEditFocusGainedCallback = SearchBox_OnEditFocusGainedCallback,
            onEditFocusLostCallback = SearchBox_OnEditFocusLostCallback,
        },
        {type = "Dropdown", label = L["Difficulty"], widgetKey = "DifficultyDropdown", disabled = true, menuInfoGetter = DropdownInfoGetters.GetValidDifficulties, valueGetter = DropdownInfoGetters.GetSelectedDifficultyText},
    };

    PopupLayouts.Quest = {
        SharedHeader,
        {type = "EditBox", label = "Quest ID", numeric = true, maxLetters = 6, searchFunc = SearchBox_QusetID},
        {type = "EditBox", label = L["Name"], widgetKey = "QuestNameEditBox", disabled = true, disabledTooltipText = L["Name EditBox Disabled Reason Format"]:format("Quest ID")},
        {type = "Checkbox", label = L["Accountwide"]},
    };

    PopupLayouts.Rare = {
        SharedHeader,
        {type = "EditBox", label = "Creature ID", numeric = true, maxLetters = 6, searchFunc = SearchBox_CreatureID},
        {type = "EditBox", label = L["Name"], widgetKey = "CreatureNameEditBox", disabled = true, disabledTooltipText = L["Name EditBox Disabled Reason Format"]:format("Creature ID")},
        {type = "EditBox", label = L["Quest Flag"], numeric = true, maxLetters = 6},
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