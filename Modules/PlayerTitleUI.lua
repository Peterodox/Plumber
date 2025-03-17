local _, addon = ...
local L = addon.L;
local API = addon.API;


local GetNumTitles = GetNumTitles;
local IsTitleKnown = IsTitleKnown;
local GetTitleName = GetTitleName;
local GetCurrentTitle = GetCurrentTitle;
local find = string.find;
local lower = string.lower;
local strtrim = strtrim;


local Module = {};
local TitleDataProvider = {};

local Header, Searchbox, FilterButton;
local Manager;
local OriginalUpdateFunc;

local STRIPE_COLOR = {r = 0.9, g = 0.9, b = 1};


local SortFunc = {};
do
    function SortFunc.Alphabet(a, b)
        return a.name < b.name
    end

    function SortFunc.ID(a, b)
        return a.id < b.id
    end
end


local GetTitles = {};
do
    function GetTitles.Earned()
        local tbl = {};
        local n = 1;
        local playerTitle = false;
        local tempName = 0;

        tbl[1] = { };
        tbl[1].name = "       ";
        tbl[1].id = -1;

        for i = 1, GetNumTitles() do
            if ( IsTitleKnown(i) ) then
                tempName, playerTitle = GetTitleName(i);
                if tempName and playerTitle then
                    n = n + 1;
                    tbl[n] = {
                        name = strtrim(tempName),
                        id = i,
                        earned = true,
                    };
                end
            end
        end

        return tbl, true
    end

    function GetTitles.Unearned()
        local tbl = {};
        local n = 0;
        local playerTitle = false;
        local tempName = 0;

        for i = 1, GetNumTitles() do
            if not IsTitleKnown(i) then
                tempName, playerTitle = GetTitleName(i);
                if tempName and playerTitle then
                    n = n + 1;
                    tbl[n] = {
                        name = strtrim(tempName),
                        id = i,
                        earned = false,
                    };
                end
            end
        end

        return tbl, false
    end

    function GetTitles.All()
        local tbl = {};
        local n = 1;
        local playerTitle = false;
        local tempName = 0;
        local earned;

        tbl[1] = { };
        tbl[1].name = "       ";
        tbl[1].id = -1;

        for i = 1, GetNumTitles() do
            tempName, playerTitle = GetTitleName(i);
            if tempName and playerTitle then
                earned = IsTitleKnown(i);
                n = n + 1;
                tbl[n] = {
                    name = strtrim(tempName),
                    id = i,
                    earned = earned,
                };
            end
        end

        return tbl, true
    end

    function GetTitles.None()
        return {}, false
    end
end


do  --TitleDataProvider
    function TitleDataProvider:ClearKnownTitles()
        self.knownTitles = nil;
    end
    function TitleDataProvider:GetFilteredData()
        if self.filteredData then
            self.numEntry = #self.filteredData;
            return self.filteredData
        end
        self.numEntry = 0;
        return {};
    end

    function TitleDataProvider:ResetFilteredData()
        self.numMatch = 0;
        self.filteredData = {};
    end

    function TitleDataProvider:AddFilteredEntry(entry)
        if not self.numMatch then
            self:ResetFilteredData();
        end
        self.numMatch = self.numMatch + 1;
        self.filteredData[self.numMatch] = entry;
    end

    function TitleDataProvider:GetOnlyMatch()
        if self.numMatch == 1 and self.filteredData[1].id > 0 then
            return self.filteredData[1].id
        end
    end

    function TitleDataProvider:ClearAllData()
        self:ClearKnownTitles();
        self:ResetFilteredData();
    end
end


local FilterButtonMixin = {};
do  --Filter
    Module.showEarned = true;
    Module.showUnearned = false;

    local FilterSchematics = {
        tag = "PlumberTitleManagerFilter",
        objects = {
            {type = "Checkbox", name = L["Earned"], IsSelected = function() return Module.showEarned end, ToggleSelected = function() Module:Filter_ToggleEarned() end},
            {type = "Checkbox", name = L["Unearned"], IsSelected = function() return Module.showUnearned end, ToggleSelected = function() Module:Filter_ToggleUnearned() end, tooltip = L["Unearned Filter Tooltip"]},
        },

        onMenuClosedCallback = function()
            --Reset the filter if the user closes the filter without selecting any criteria
            if not (Module.showEarned or Module.showUnearned) then
                Module:ResetFilter();
            end
        end,
    };

    --API.TranslateContextMenu

    function FilterButtonMixin:SetVisual(id)
        if id == 1 then      --Hollow Grey
            self.Icon:SetTexCoord(0.5, 0.75, 0, 0.25);
        elseif id == 2 then  --Solid Yellow
            self.Icon:SetTexCoord(0, 0.25, 0, 0.25);
        end
        self.visualID = id;
    end

    function FilterButtonMixin:OnEnter()
        self.Icon:SetAlpha(1);

        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        tooltip:SetText(FILTER, 1, 1, 1);
        if self.visualID == 2 then
            tooltip:AddLine(L["Right Click To Reset Filter"], 1, 0.82, 0, true);
        end
        tooltip:Show();
    end

    function FilterButtonMixin:OnLeave()
        self.Icon:SetAlpha(0.67);
        GameTooltip:Hide();
    end

    function FilterButtonMixin:OnClick(button)
        if button == "LeftButton" then
            local ownerRegion = self;
            local contextData = {};
            GameTooltip:Hide();
            API.ShowBlizzardMenu(ownerRegion, FilterSchematics, contextData);
        elseif button == "RightButton" then
            Module:ResetFilter();
            if self:IsMouseMotionFocus() then
                GameTooltip:Hide();
                self:OnEnter();
            end
        end
    end

    function FilterButtonMixin:OnMouseDown()
        self.Icon:SetPoint("CENTER", self, "CENTER", 1, -1);
    end

    function FilterButtonMixin:OnMouseUp()
        self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0);
    end

    function FilterButtonMixin:OnLoad()
        self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnClick", self.OnClick);
        self:SetScript("OnMouseDown", self.OnMouseDown);
        self:SetScript("OnMouseUp", self.OnMouseUp);
        self.Icon:SetAlpha(0.67);
        self:SetVisual(1);
        self:SetHitRectInsets(-2, -2, -4, 0);   --Extend the hitbox to 24x24
    end


    function Module:ResetFilter()
        if self.getTitleFunc ~= GetTitles.Earned then
           self.showEarned = true;
           self.showUnearned = false;
           self:UpdateAfterFilterChange();
        end
    end

    function Module:UpdateAfterFilterChange()
        local valid;
        if self.showEarned and not self.showUnearned then
            FilterButton:SetVisual(1);
            self.getTitleFunc = GetTitles.Earned;
            valid = true;
        else
            FilterButton:SetVisual(2);
            if self.showEarned and self.showUnearned then
                self.getTitleFunc = GetTitles.All;
                valid = true;
            elseif (not self.showEarned) and self.showUnearned then
                self.getTitleFunc = GetTitles.Unearned;
                valid = true;
            else
                --Don't update if none of the criteria is selected
                self.getTitleFunc = GetTitles.None;
                valid = false;
            end
        end
        if valid then
            if self:UpdateIfShown() then
                Manager.ScrollBox:ScrollToBegin(true);
            end
        end
    end

    function Module:Filter_ToggleEarned()
        self.showEarned = not self.showEarned;
        Module:UpdateAfterFilterChange();
    end

    function Module:Filter_ToggleUnearned()
        self.showUnearned = not self.showUnearned;
        Module:UpdateAfterFilterChange();
    end
end


function Module:Init()
    self.Init = nil;

    if not OriginalUpdateFunc then
        OriginalUpdateFunc = _G.PaperDollTitlesPane_Update;
    end

    Manager = PaperDollFrame.TitleManagerPane;


    local rightOffset = 28;

    Header = CreateFrame("Frame", nil, Manager);
    Header:SetPoint("TOPLEFT", Manager, "TOPLEFT", 8, -2);
    Header:SetPoint("TOPRIGHT", Manager, "TOPRIGHT", -8 + rightOffset, -2);
    Header:SetHeight(20);

    --debugBG
    local bg = Header:CreateTexture(nil, "BACKGROUND");
    bg:SetAllPoints(true);
    --bg:SetColorTexture(1, 0, 0, 0.5);

    Header:SetScript("OnShow", function()

    end);

    Header:SetScript("OnHide", function()
        Module:StopSearching();
        TitleDataProvider:ClearAllData();
        Manager.titles = {};
        Searchbox:SetText("");
        Module:ResetFilter();
    end);


    Searchbox = CreateFrame("EditBox", nil, Header, "SearchBoxTemplate");
    Searchbox:SetSize(160, 20); --160 184
    Searchbox:SetPoint("TOPLEFT", Header, "TOPLEFT", 0, 0);

    Searchbox:SetScript("OnTextChanged", function(self, userInput)
        SearchBoxTemplate_OnTextChanged(self);
        if Header:IsVisible() then
            Module:SearchByKeyword(self:GetText())
        end
    end);

    Searchbox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus();
        local matchedTitleID = TitleDataProvider:GetOnlyMatch();
        if matchedTitleID then
            SetCurrentTitle(matchedTitleID);
        end
    end);


    FilterButton = CreateFrame("Button", nil, Header);

    FilterButton:SetSize(20, 20);
    FilterButton:SetPoint("TOPRIGHT", Header, "TOPRIGHT", -2, 0);
    local file = "Interface/AddOns/Plumber/Art/Button/FilterButton";

    FilterButton.Icon = FilterButton:CreateTexture(nil, "OVERLAY");
    FilterButton.Icon:SetPoint("CENTER", FilterButton, "CENTER", 0, 0);
    FilterButton.Icon:SetSize(16, 16);
    FilterButton.Icon:SetTexture(file);

    API.Mixin(FilterButton, FilterButtonMixin);
    FilterButton:OnLoad();


    --3rd Party Addon Skin
    API.SetupSkinExternal(Searchbox);
end

function Module:SetSearchboxInstructions(text)
    Searchbox.Instructions:SetTextColor(0.5, 0.5, 0.5);
    Searchbox.Instructions:SetText(text);
    Searchbox.instructionText = text;
end


local function TitlesPane_UpdateScrollBox()
	local dataProvider = CreateDataProvider();
	for index, titleInfo in ipairs(TitleDataProvider:GetFilteredData()) do
		dataProvider:Insert({index = index, titleInfo = titleInfo});
	end
	Manager.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

local function TitlesPane_InitButton(button, elementData)
	local index = elementData.index;

	local info = elementData.titleInfo;
	button.text:SetText(info.name);
	button.titleId = info.id;

    if info.id == TitleDataProvider.selectedID then
		button.Check:Show();
		button.SelectedBar:Show();
	else
		button.Check:Hide();
		button.SelectedBar:Hide();
	end

	if index == 1 then
		button.BgTop:Show();
		button.BgMiddle:SetPoint("TOP", button.BgTop, "BOTTOM");
	else
		button.BgTop:Hide();
		button.BgMiddle:SetPoint("TOP");
	end

	if index == TitleDataProvider.numEntry then
		button.BgBottom:Show();
		button.BgMiddle:SetPoint("BOTTOM", button.BgBottom, "TOP");
	else
		button.BgBottom:Hide();
		button.BgMiddle:SetPoint("BOTTOM");
	end

	if index % 2 == 0 then
		button.Stripe:SetColorTexture(STRIPE_COLOR.r, STRIPE_COLOR.g, STRIPE_COLOR.b);
		button.Stripe:SetAlpha(0.1);
		button.Stripe:Show();
	else
		button.Stripe:Hide();
	end

    if info.earned then
        button:Enable();
        button.text:SetTextColor(1, 0.82, 0);
    else
        button:Disable();
        button.text:SetTextColor(0.60, 0.60, 0.60);
    end
end


local PROCESS_PER_SEC = 600;    --10 per frame, fps 60

local function OnUpdate_Search(self, elapsed)
    if TitleDataProvider.knownTitles then
        self.isSearching = true;
        local i = self.lastIndex;
        local n = 0;
        local finished = false;
        local v;

        while n < PROCESS_PER_SEC * elapsed do
            n = n + 1;
            i = i + 1;
            v = TitleDataProvider.knownTitles[i];
            if v then
                if not v.lowcaseName then
                    v.lowcaseName = lower(v.name);
                end
                if find(v.lowcaseName, self.keyword) then
                    TitleDataProvider:AddFilteredEntry(v);
                end
                self.lastIndex = i;
            else
                finished = true;
                break
            end
        end

        if finished then
            Module:StopSearching();
            TitlesPane_UpdateScrollBox();
        else

        end
    else
        Module:StopSearching();
    end
end

function Module:StopSearching()
    if Header.isSearching then
        Header.isSearching = nil;
        Header:SetScript("OnUpdate", nil);
    end
end

function Module:SearchByKeyword(keyword)
    self:StopSearching();
    TitleDataProvider:ResetFilteredData();
    if Header:IsVisible() then
        keyword = keyword and strtrim(keyword);
        if keyword and keyword ~= "" then
            keyword = lower(keyword);
            Header.keyword = keyword;
            Header.lastIndex = 0;
            Header.isSearching = true;
            Header:SetScript("OnUpdate", OnUpdate_Search);
        else
            TitleDataProvider.filteredData = TitleDataProvider.knownTitles;
            TitlesPane_UpdateScrollBox();
        end
    end
end


local function Override_TitlesPane_Update()
    if Header.isSearching then
        return
    end

    local updateData = true;
    if TitleDataProvider.knownTitles and TitleDataProvider.knownTitles ~= TitleDataProvider.filteredData then
        updateData = false;
    end

    if updateData then
        local currentTitle = GetCurrentTitle();
        local titles, showRemoveTitle = Module.getTitleFunc();
        if ( currentTitle > 0 and currentTitle <= GetNumTitles() and IsTitleKnown(currentTitle) ) then
            Manager.selected = currentTitle;
        else
            Manager.selected = -1;
        end
        table.sort(titles, SortFunc.Alphabet);

        if showRemoveTitle then
            --Don't add "No Title" button if the filter is set to "unearned" only
            titles[1].name = PLAYER_TITLE_NONE;
            titles[1].id = -1;
            titles[1].earned = true;
        end

        Manager.titles = titles;

        local total = #titles;
        Module:SetSearchboxInstructions(L["Total Colon"].." "..total);

        TitleDataProvider.knownTitles = titles;
        TitleDataProvider.filteredData = titles;
        Module:StopSearching();
    else
        local currentTitle = GetCurrentTitle();
        if currentTitle > 0 and IsTitleKnown(currentTitle) then
            Manager.selected = currentTitle;
        else
            Manager.selected = -1;
        end
    end

    TitleDataProvider.selectedID = Manager.selected;

    TitlesPane_UpdateScrollBox();
end

function Module:UpdateIfShown()
    if Header and Header:IsVisible() then
        Override_TitlesPane_Update();
        return true
    end
end


function Module:EnableModule(state)
    if state and not self.enabled then
        self.enabled = true;

        if self.Init then
            self:Init();
        end

        Header:Show();

        Manager.ScrollBox:ClearAllPoints();
        Manager.ScrollBox:SetPoint("TOPLEFT", Manager, "TOPLEFT", 0, -22);
        Manager.ScrollBox:SetPoint("BOTTOMRIGHT", Manager, "BOTTOMRIGHT", -4, 4);

        --!Override Global API!
        _G.PaperDollTitlesPane_Update = Override_TitlesPane_Update;
        --_G.PaperDollTitlesPane_InitButton = TitlesPane_InitButton;

        local view = Manager.ScrollBox:GetView();
        view:SetElementInitializer("PlayerTitleButtonTemplate", function(button, elementData)
            TitlesPane_InitButton(button, elementData);
        end);

        self:ResetFilter();
        --[[
        local function TitleButton_OnClick(self)
            if self.titleId == -1 or IsTitleKnown(self.titleId) then
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
                SetCurrentTitle(self.titleId);
            end
        end
        _G.PlayerTitleButton_OnClick = TitleButton_OnClick;
        --]]

    elseif (not state) and self.enabled then
        self.enabled = nil;

        Manager.ScrollBox:ClearAllPoints();
        Manager.ScrollBox:SetPoint("TOPLEFT", Manager, "TOPLEFT", 0, 0);

        if OriginalUpdateFunc then
            _G.PaperDollTitlesPane_Update = OriginalUpdateFunc;
        end

        Header:Hide();

        local view = Manager.ScrollBox:GetView();
        view:SetElementInitializer("PlayerTitleButtonTemplate", function(button, elementData)
            PaperDollTitlesPane_InitButton(button, elementData);
            button.text:SetTextColor(1, 0.82, 0);
            button:Enable();
        end);
    end
end




local function EnableModule(state)
    Module:EnableModule(state);
end

do
    local moduleData = {
        name = addon.L["ModuleName PlayerTitleUI"],
        dbKey = "PlayerTitleUI",
        description = addon.L["ModuleDescription PlayerTitleUI"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1163,
        moduleAddedTime = 1736240000,
    };

    addon.ControlCenter:AddModule(moduleData);
end




--Unused. Investigating the Title Spam since 11.0.5
--[[
local PLAYER_NAME;

local EL = CreateFrame("Frame");
EL.titleStatus = {};
EL.numTitles = 0;

function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0.5 then
        self.t = nil;
        self:SetScript("OnUpdate", nil);
        self:CheckStatusChange();
    end
end

function EL:RequestUpdateTitleStatus()
    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate);
end

function EL:CacheTitleStatus()
    local numTitles = GetNumTitles() or 0;
    if numTitles ~= self.numTitles then
        self.numTitles = numTitles;
        self.titleStatus = {};
        for i = 1, numTitles do
            self.titleStatus[i] = IsTitleKnown(i);
        end
    end
end

function EL:CheckStatusChange()
    local isKnown;
    local changes = {};
    local n = 0;

    for i = 1, self.numTitles do
        isKnown = IsTitleKnown(i);
        if self.titleStatus[i] ~= isKnown then
            self.titleStatus[i] = isKnown;
            n = n + 1;
            if isKnown then
                changes[n] = i;
            else
                changes[n] = -i;
            end
        end
    end

    if n > 0 then
        self:DisplayTitleChange(changes);
    end
end

local function GetFormattedTitle(id)
    --CharacterFrame uses UnitPVPName to get titled name
    local name = GetTitleName(id);
    if name then
        if find(name, " $") then
            return name .. PLAYER_NAME
        else
            return PLAYER_NAME .. ", " .. name
        end
    end
    return ""
end

local function DisplayChatMessage(text, r, g, b)
    r = r or 1;
    g = g or 1;
    b = b or 0;
    DEFAULT_CHAT_FRAME:AddMessage(text, r, g, b);   --Default System Messages: FFFF00
end

function EL:DisplayTitleChange(changes)
    local maxShown = 10;
    local numAdded = 0;

    for i, id in ipairs(changes) do
        if id > 0 then
            numAdded = numAdded + 1;
            DisplayChatMessage(string.format(NEW_TITLE_EARNED, GetFormattedTitle(id)))
        elseif id < 0 then
            DisplayChatMessage(string.format(OLD_TITLE_LOST, GetFormattedTitle(-id)))
        end
        if numAdded > maxShown then
            local overflow = #changes - maxShown;
            DisplayChatMessage(string.format(LFG_LIST_AND_MORE, overflow))
            break
        end
    end
end


function EL:ListenEvents(state)
    if state then
        self:RegisterUnitEvent("KNOWN_TITLES_UPDATE", "player");
        self:RegisterUnitEvent("UNIT_NAME_UPDATE", "player");
        self:SetScript("OnEvent", self.OnEvent);
    else
        self:UnregisterEvent("KNOWN_TITLES_UPDATE");
        self:UnregisterEvent("UNIT_NAME_UPDATE");
    end
end

function EL:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        PLAYER_NAME = UnitName("player");
        self:UnregisterEvent(event);
        self:CacheTitleStatus();
    elseif event == "KNOWN_TITLES_UPDATE" then
        self:RequestUpdateTitleStatus();
    end
end

EL:ListenEvents(true);
EL:RegisterEvent("PLAYER_ENTERING_WORLD");


local match = string.match;
local MATCH_TITLE = string.gsub(NEW_TITLE_EARNED or "You have earned the title '%s'.", "%%s", "%(.+%)");

local function RemoveTitleAnnouncement(self, event, text)
	if text and match(text, MATCH_TITLE) then
        return true
    end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", RemoveTitleAnnouncement)
--]]