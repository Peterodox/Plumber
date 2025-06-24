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

local TrackerTypeXID = {};
for k, v in ipairs(Enum_TrackerTypes) do
    TrackerTypeXID[v] = k;
end


local TrackingList = {};
do
    function TrackingList:Init()
        if not PlumberDB then
            self.rawList = {};
            return
        end

        if not PlumberDB.LadningPageTrackingList then
            PlumberDB.LadningPageTrackingList = {};
        end

        if not PlumberDB.LadningPageTrackingListCollapsedTypes then
            PlumberDB.LadningPageTrackingListCollapsedTypes = {};
        end

        self.rawList = PlumberDB.LadningPageTrackingList;
        self.collapsedTypes = PlumberDB.LadningPageTrackingListCollapsedTypes;

        self.uniqueQuestIDs = {};
        self.uniqueCreatureIDs = {};
    end

    local function SortFunc_TypeThenID(a, b)
        if a.type ~= b.type then
            return a.type < b.type
        end

        return a.id < b.id
    end

    function TrackingList:IsTrackerTypeCollapsed(trackerTypeID)
        return self.collapsedTypes[trackerTypeID]
    end

    function TrackingList:SetTrackerTypeCollapsed(trackerTypeID, isCollapsed)
        self.collapsedTypes[trackerTypeID] = isCollapsed;
    end

    function TrackingList:GetSortedList(forceUpdate)
        if self.sortedList and not forceUpdate then
            return self.sortedList
        end

        table.sort(self.rawList, SortFunc_TypeThenID);

        self.uniqueQuestIDs = {};
        self.uniqueCreatureIDs = {};

        local tbl = {};
        local n = 0;
        local lastType;
        local trackerType;
        local numCompleted = 0;
        local data;

        for k, v in ipairs(self.rawList) do
            trackerType = Enum_TrackerTypes[v.type];
            if v.type ~= lastType then
                lastType = v.type;
                n = n + 1;
                data = {
                    isHeader = true,
                    localizedName = L["TrackerTypePlural "..trackerType],
                    isCollapsed = self:IsTrackerTypeCollapsed(lastType);
                    typeID = lastType,
                };
                tbl[n] = data;
            end

            n = n + 1;
            data = {
                type = trackerType,
                id = v.id;
            };
            tbl[n] = data;

            if trackerType == TrackerTypeXID.Quest then
                self.uniqueQuestIDs[v.id] = true;
            elseif trackerType == TrackerTypeXID.Creature then
                self.uniqueCreatureIDs[v.id] = true;
            end
        end

        self.sortedList = tbl;

        return tbl, numCompleted
    end

    function TrackingList:IsQuestAdded(questID)
        return self.uniqueQuestIDs[questID]
    end

    function TrackingList:AddQuest(questID)
        if self:IsQuestAdded(questID) then
            return false
        end

        table.insert(self.rawList, {
            type = TrackerTypeXID.Quest,
            id = questID,
        });

        return true
    end

    function TrackingList:IsCreatureAdded(creatureID)
        return self.uniqueCreatureIDs[creatureID]
    end

    function TrackingList:AddRareCreature(creatureID, flagQuest)
        if (self:IsQuestAdded(creatureID)) or (not flagQuest) then
            return false
        end

        table.insert(self.rawList, {
            type = TrackerTypeXID.Rare,
            id = creatureID,
            flagQuest = flagQuest,
        });

        return true
    end
end


do  --DropdownInfoGetters
    local function GetSelectedTrackerTypeText()
        local trackerTypeID = EditorPopup and EditorPopup.trackerTypeID;
        if trackerTypeID and Enum_TrackerTypes[trackerTypeID] then
            return L["TrackerType "..Enum_TrackerTypes[trackerTypeID]];
        else
            return L["Select Instruction"]
        end
    end
    DropdownInfoGetters.GetSelectedTrackerTypeText = GetSelectedTrackerTypeText;

    function DropdownInfoGetters.NewTrackerType()
        local tbl = {
            key = "TrackerEditor.TrackerType",
        };

        local selectedTrackerType = EditorPopup.trackerTypeID
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


    local function GetValidDifficulties(getterFunc, ...)
        local instanceID, encounterID = EditorPopup.instanceID, EditorPopup.encounterID;
        local selectedDifficultyID = EditorPopup.difficultyID;
        local showAllDifficulties = true;
        local difficulties = getterFunc(instanceID, encounterID, showAllDifficulties);

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

    function DropdownInfoGetters.GetValidDifficultiesForEncounter(instanceID, encounterID)
        return GetValidDifficulties(API.GetValidDifficultiesForEncounter, instanceID, encounterID, true)
    end

    function DropdownInfoGetters.GetValidDifficultiesForInstance(instanceID)
        return GetValidDifficulties(API.GetValidDifficultiesForEncounter, instanceID, nil, true)
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
            self.trackerTypeID = trackerTypeID;
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
        self.flagQuestID = nil;
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
                obj:SetGetCheckedFunc(v.getCheckedFunc);
                obj:SetOnClickFunc(v.onClickFunc);
                obj:UpdateVisual();
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
        EditorPopup:Hide();
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

        local function Checkbox_Remove(obj)
            obj:ClearCallbacks();
        end

        local CheckboxPool = LandingPageUtil.CreateObjectPool(Checkbox_Create, Checkbox_Remove);
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
        self.SaveButton:SetScript("OnClick", function()
            EditorPopup:TrySave();
        end);

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
        local failureReason;

        if forceEnabled then
            enabled = true;
        else
            enabled, failureReason = self:CanSaveOptions();
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
        if self.instanceID and self.difficultyID then
            local valid = API.IsDifficultyValidForEncounter(self.instanceID, nil, self.difficultyID);
            return valid
        end
    end

    function EditorPopupMixin:CanSaveOptions_Quest()
        --We also update some widgets here
        local valid, failureReason;
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
                    if self.trackerTypeID == TrackerTypeXID.Quest and self.questID == _questID then
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

        if TrackingList:IsQuestAdded(questID) then
            valid = false;
            failureReason = L["FailureReason Already Exist"];
        end

        return valid, failureReason
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

        local flagQuestID = creatureID and API.GetKnownRareFlagQuest(creatureID);
        if flagQuestID then
            self.flagQuestID = flagQuestID;
            local flagQuestEditBox = self:GetWidgetByKey("CreatureFlagQuestEditBox");
            if flagQuestEditBox then
                flagQuestEditBox:SetText(flagQuestID);
                flagQuestEditBox:UpdateTextInsets();
                flagQuestEditBox:Disable();
                flagQuestEditBox:GetParent():SetOptionEnabled(false);
            end
        else
            local flagQuestEditBox = self:GetWidgetByKey("CreatureFlagQuestEditBox");
            if flagQuestEditBox then
                flagQuestEditBox:UpdateTextInsets();
                flagQuestEditBox:Enable();
                flagQuestEditBox:GetParent():SetOptionEnabled(true);
            end
        end

        if not self.flagQuestID then
            valid = false;
        end

        return valid
    end


    function EditorPopupMixin:TrySave()
        local success;
        if self.trackerTypeID == TrackerTypeXID.Quest then
            if self:CanSaveOptions_Quest() then
                success = TrackingList:AddQuest(self.questID);
            end
        elseif self.trackerTypeID == TrackerTypeXID.Rare then
            if self:CanSaveOptions_Rare() then
                success = TrackingList:AddRareCreature(self.creatureID, self.flagQuestID);
            end
        end

        EditorPopup:Hide();
        TrackerTab:FullUpdate();
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

local function SearchBox_FlagQuest(searchBox, flagQuestID)
    EditorPopup.flagQuestID = flagQuestID;
    EditorPopup:UpdateSaveButton();
end

local function Checkbox_Accountwide_Quest_GetChecked()
    return EditorPopup.questAccountwide == true
end

local function Checkbox_Accountwide_Quest_OnClick(checkbox, state)
    EditorPopup.questAccountwide = state;
end

local function Checkbox_Accountwide_Rare_GetChecked()
    return EditorPopup.rareAccountwide == true
end

local function Checkbox_Accountwide_Rare_OnClick(checkbox, state)
    EditorPopup.rareAccountwide = state;
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
                        EditorPopup:SetInstanceAndEncounter(v.instanceID, v.encounterID);
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
        {type = "Dropdown", label = L["Difficulty"], widgetKey = "DifficultyDropdown", disabled = true, menuInfoGetter = DropdownInfoGetters.GetValidDifficultiesForEncounter, valueGetter = DropdownInfoGetters.GetSelectedDifficultyText},
    };

    PopupLayouts.Instance = {
        SharedHeader,
        {type = "EditBox", label = L["Name"], instruction = L["Instance Or Boss Name"], isSearchbox = true, HasStickyFocus = SearchBox_HasStickyFocus,
            searchFunc = function(searchBox, text) LandingPageUtil.SearchInstance(text, SearchResultMenu) end,
            onEditFocusGainedCallback = SearchBox_OnEditFocusGainedCallback,
            onEditFocusLostCallback = SearchBox_OnEditFocusLostCallback,
        },
        {type = "Dropdown", label = L["Difficulty"], widgetKey = "DifficultyDropdown", disabled = true, menuInfoGetter = DropdownInfoGetters.GetValidDifficultiesForInstance, valueGetter = DropdownInfoGetters.GetSelectedDifficultyText},
    };

    PopupLayouts.Quest = {
        SharedHeader,
        {type = "EditBox", label = "Quest ID", numeric = true, maxLetters = 6, searchFunc = SearchBox_QusetID},
        {type = "EditBox", label = L["Name"], widgetKey = "QuestNameEditBox", disabled = true, disabledTooltipText = L["Name EditBox Disabled Reason Format"]:format("Quest ID")},
        {type = "Checkbox", label = L["Accountwide"], getCheckedFunc = Checkbox_Accountwide_Quest_GetChecked, onClickFunc = Checkbox_Accountwide_Quest_OnClick},
    };

    PopupLayouts.Rare = {
        SharedHeader,
        {type = "EditBox", label = "Creature ID", numeric = true, maxLetters = 6, searchFunc = SearchBox_CreatureID},
        {type = "EditBox", label = L["Name"], widgetKey = "CreatureNameEditBox", disabled = true, disabledTooltipText = L["Name EditBox Disabled Reason Format"]:format("Creature ID")},
        {type = "EditBox", label = L["Flag Quest"], widgetKey = "CreatureFlagQuestEditBox", numeric = true, maxLetters = 6, searchFunc = SearchBox_FlagQuest},
        {type = "Checkbox", label = L["Accountwide"], getCheckedFunc = Checkbox_Accountwide_Rare_GetChecked, onClickFunc = Checkbox_Accountwide_Rare_OnClick},
    };
end


local GenericEntryButtonMixin = {};
do
    function GenericEntryButtonMixin:OnClick(button)
        if button == "LeftButton" then
            if self.isHeader then
                self:ToggleCollapsed();
            end
        end
    end

    function GenericEntryButtonMixin:ToggleCollapsed()
        local trackerTypeID = self.data and self.data.typeID;
        if trackerTypeID then
            TrackerTab:SetTrackerTypeCollapsed(trackerTypeID, not TrackingList:IsTrackerTypeCollapsed(trackerTypeID));
        end
    end
end


local TrackerTabMixin = {};
do
    local DynamicEvents = {
        "QUEST_TURNED_IN",
    };

    function TrackerTabMixin:OnShow()
        self:FullUpdate();
        API.RegisterFrameForEvents(self, DynamicEvents);
    end

    function TrackerTabMixin:OnHide()
        API.UnregisterFrameForEvents(self, DynamicEvents);
    end

    function TrackerTabMixin:OnEvent(event, ...)
        if event == "QUEST_TURNED_IN" then
            self:FullUpdate();
        end
    end

    function TrackerTabMixin:OpenEditorPopup()
        if not EditorPopup then
            EditorPopup_Init();
        end
        EditorPopup:ShowHomePage();
    end

    function TrackerTabMixin:Init()
        self.Init = nil;
        EditorPopup_Init();


        --Right List
        local headerWidgetOffsetY = -10;
        local Checkbox_HideCompleted = LandingPageUtil.CreateCheckboxButton(self);
        self.Checkbox_HideCompleted = Checkbox_HideCompleted;
        Checkbox_HideCompleted:SetPoint("TOPRIGHT", self, "TOPRIGHT", -52, headerWidgetOffsetY);
        Checkbox_HideCompleted:SetText(L["Filter Hide Completed Format"], true);
        Checkbox_HideCompleted.dbKey = "LandingPage_Tracker_HideCompleted";
        Checkbox_HideCompleted.textFormat = L["Filter Hide Completed Format"];
        Checkbox_HideCompleted.useDarkYellowLabel = true;
        Checkbox_HideCompleted:UpdateChecked();
        Checkbox_HideCompleted:SetFormattedText(0);

        local CreateNewTrackerButton = LandingPageUtil.CreateCheckboxButton(self);
        self.CreateNewTrackerButton = CreateNewTrackerButton;
        CreateNewTrackerButton:SetPoint("TOPLEFT", self, "TOPLEFT", 56, headerWidgetOffsetY);
        CreateNewTrackerButton:SetText(L["Creater New Tracker"], true);
        CreateNewTrackerButton.useDarkYellowLabel = true;
        CreateNewTrackerButton:UpdateChecked();
        CreateNewTrackerButton:SetOnClickFunc(function()
            TrackerTab:OpenEditorPopup();
        end);


        --ScrollView
        local ScrollView = LandingPageUtil.CreateScrollViewForTab(self, -32);
        ScrollView:SetScrollBarOffsetY(-4);

        local function GenericEntryButton_Create()
            local button = LandingPageUtil.CreateChecklistButton(ScrollView);
            API.Mixin(button, GenericEntryButtonMixin);
            button:SetScript("OnClick", button.OnClick);
            return button
        end

        local function GenericEntryButton_OnAcquired(button)

        end
        local function GenericEntryButton_OnRemoved(button)

        end

        ScrollView:AddTemplate("GenericEntryButton", GenericEntryButton_Create, GenericEntryButton_OnAcquired, GenericEntryButton_OnRemoved);


        TrackingList:Init();
    end

    function TrackerTabMixin:FullUpdate()
        self.fullUpdate = nil;

        local uiMapID = API.GetPlayerMap();
        self.uiMapID = uiMapID;

        local content = {};
        local n = 0;
        local buttonHeight = 24;
        local gap = 4;
        local offsetY = 2;

        local entryWidth = 544;
        local headerWidth = entryWidth + 62;

        local top, bottom;
        local showActivity, showGroup;

        local sortedList, numCompleted = TrackingList:GetSortedList(true);

        for k, v in ipairs(sortedList) do
            if v.isHeader then
                showActivity = true;
                showGroup = not v.isCollapsed;
            else
                showActivity = showGroup;
            end

            if showActivity then
                n = n + 1;
                local isOdd = n % 2 == 0;
                top = offsetY;
                bottom = offsetY + buttonHeight + gap;

                if v.uiMapID then
                    v.showGlow = (not v.isHeader) and (not v.completed) and (v.uiMapID == uiMapID);
                else
                    v.showGlow = false;
                end

                content[n] = {
                    templateKey = "GenericEntryButton",
                    setupFunc = function(obj)
                        obj.isOdd = isOdd;
                        if v.isHeader then
                            obj:SetWidth(headerWidth);
                            obj.isCollapsed = v.isCollapsed;
                            obj:SetHeader();
                        else
                            obj:SetWidth(entryWidth);
                            obj:SetEntry();
                        end
                        obj:SetData(v);
                    end,
                    top = top,
                    bottom = bottom,
                };
                offsetY = bottom;
            end
        end

        local retainPosition = true;
        self.ScrollView:SetContent(content, retainPosition);

        self.Checkbox_HideCompleted:SetFormattedText(numCompleted);
    end

    function TrackerTabMixin:SetTrackerTypeCollapsed(trackerTypeID, isCollapsed)
        TrackingList:SetTrackerTypeCollapsed(trackerTypeID, isCollapsed);
        self:FullUpdate();
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