local _, addon = ...
local L = addon.L;
local API = addon.API;


local Housing = addon.Housing;
local GetCurrencyName = API.GetCurrencyName;
local GetDecorSourceText = Housing.GetDecorSourceText;


local strlenutf8 = strlenutf8;
local strtrim = strtrim;
local find = string.find;
local lower = string.lower;
local match = string.match;


local MODULE_ENABLED;


--Storage List Injection
--  HouseEditorStorageFrameTemplate (HouseEditorFrame.StoragePanel.OptionsContainer)
--      OptionsContainer (ScrollingHousingCatalogTemplate) HouseEditorFrame.StoragePanel.OptionsContainer.SetCatalogElements
--      SetCatalogData


local function ShouldShowDecor(catalogSearcher)
    return catalogSearcher:GetEditorModeContext() ~= Enum.HouseEditorMode.Layout;
end


local CreateUpdator;
do
    local UpdatorMixin = {};

    function UpdatorMixin:OnHide()
        self:Hide();
    end

    function UpdatorMixin:OnUpdate(elapsed)
        if not self.foundIDs then
            local foundIDs = {};
            for _, v in ipairs(self.catalogEntries) do
                if v.entryType == 1 then
                    foundIDs[v.recordID] = true;
                end
            end
            self.foundIDs = foundIDs;
            return
        end

        local v, decorID, sourceText;
        local currencyID, currencyName;
        local updateThisFrame = 0;

        while updateThisFrame < 50 do   --update per frame: 50
            self.index = self.index + 1;
            v = self.allEntries[self.index];
            if v then
                if v.entryType == 1 then
                    decorID = v.recordID;
                    if not self.foundIDs[decorID] then
                        sourceText = GetDecorSourceText(decorID, self.ownedOnly);
                        if sourceText then
                            updateThisFrame = updateThisFrame + 1;
                            sourceText = lower(sourceText);
                            currencyID = match(sourceText, "currency:(%d+)");

                            if currencyID then
                                currencyName = GetCurrencyName(currencyID);
                                if currencyName then
                                    currencyName = lower(currencyName);
                                end
                            else
                                currencyName = nil;
                            end

                            if find(sourceText, self.searchText, 1, true) or (currencyName and find(currencyName, self.searchText, 1, true)) then
                                self.foundIDs[decorID] = true;
                                if not self.anyMatch then
                                    self.anyMatch = true;
                                    self.n = self.n + 1;
                                    self.catalogEntries[self.n] = {isHeader = true, text = L["Match Sources"]};
                                end
                                self.n = self.n + 1;
                                self.catalogEntries[self.n] = v;
                            end
                        end
                    end
                end
            else
                self:SetScript("OnUpdate", nil);
                self:ProcessResult();
                break
            end
        end
    end

    function UpdatorMixin:Wipe()
        self:SetScript("OnUpdate", nil);
        self.anyMatch = nil;
        self.n = 0;
        self.index = 0;
        self.toIndex = 0;
        self.searchText = nil;
        self.headerText = nil;
        self.instructionText = nil;
        self.foundIDs = nil;
        self.catalogEntries = {};
        Housing.DataProvider:CleaSearchCallback();
    end

    function UpdatorMixin:ProcessResult()
        self:SetScript("OnUpdate", nil);

        local searchText = self.searcher:GetSearchText() or "";
        searchText = strtrim(searchText);

        local useAdvancedSearch = searchText and strlenutf8(searchText) >= 3;
        if not (ShouldShowDecor(self.searcher) and useAdvancedSearch and self.catalogEntries) then
            self:Wipe();
            return
        end

        local entryTypeDecor = Enum.HousingCatalogEntryType.Decor;
        local entryTypeRoom = Enum.HousingCatalogEntryType.Room;

        local lastTemplate = nil;
        local n = 0;
        local catalogElements = {};

        if self.headerText then
            n = n + 1;
            catalogElements[n] = { templateKey = "CATALOG_ENTRY_HEADER", text = self.headerText };
        end

        for _, catalogEntry in ipairs(self.catalogEntries) do
            local elementData = catalogEntry;

            if catalogEntry.decorEntries then
                elementData.templateKey = "CATALOG_ENTRY_BUNDLE";
            else
                if lastTemplate == "CATALOG_ENTRY_BUNDLE" then
                    n = n + 1;
                    catalogElements[n] = { templateKey = "CATALOG_ENTRY_BUNDLE_DIVIDER" };
                end

                if catalogEntry.isHeader then
                    n = n + 1;
                    catalogElements[n] = { templateKey = "CATALOG_ENTRY_HEADER", text = catalogEntry.text };
                else
                    if catalogEntry.decorID then
                        elementData = { bundleItemInfo = catalogEntry, };
                        elementData.templateKey = "CATALOG_ENTRY_DECOR";
                    else
                        elementData = { entryID = catalogEntry, };
                        local entryType = catalogEntry.entryType;
                        if entryType == entryTypeDecor then
                            elementData.templateKey = "CATALOG_ENTRY_DECOR";
                        elseif entryType == entryTypeRoom then
                            elementData.templateKey = "CATALOG_ENTRY_ROOM";
                        end
                    end
                end
            end

            if elementData.templateKey then
                lastTemplate = elementData.templateKey;
                n = n + 1;
                catalogElements[n] = elementData;
            end
        end

        if self.instructionText then
            n = n + 1;
            catalogElements[n] = { templateKey = "CATALOG_ENTRY_INSTRUCTIONS", text = self.instructionText };
        end

        self.optionsContainer:SetCatalogElements(catalogElements, self.retainCurrentPosition);
    end


    function CreateUpdator(searcher, optionsContainer)
        local f = CreateFrame("Frame", nil, optionsContainer);
        f:Hide();
        Mixin(f, UpdatorMixin);

        f.searcher = searcher;
        f.optionsContainer = optionsContainer;
        f:SetScript("OnHide", f.OnHide);

        return f
    end
end


local function ModifySearcherBase(f, ownedOnly)
    local searcher = f.catalogSearcher;

    local Updator = CreateUpdator(searcher, f.OptionsContainer);
    Updator.ownedOnly = ownedOnly;

    hooksecurefunc(f.OptionsContainer, "SetCatalogData", function(_, catalogEntries, retainCurrentPosition, headerText, instructionText)
        Updator:Wipe();
        if MODULE_ENABLED and ShouldShowDecor(searcher) and catalogEntries then
            local searchText = searcher:GetSearchText() or "";
            if strlenutf8(searchText) >= 3 then
                searchText = strtrim(searchText);
                Housing.DataProvider:SetSearchCallback(
                    function()
                        local allEntries = Housing.DataProvider:GetAllEntries() --Housing.DataProvider.allEntries;

                        if allEntries then
                            Updator.toIndex = #allEntries;
                            Updator.index = 1;
                            Updator.allEntries = allEntries;
                            Updator.searchText = lower(searchText);
                            Updator.n = #catalogEntries;

                            Updator.catalogEntries = catalogEntries;
                            Updator.retainCurrentPosition = retainCurrentPosition;
                            Updator.headerText = headerText;
                            Updator.instructionText = instructionText;

                            Updator:SetScript("OnUpdate", Updator.OnUpdate);
                            Updator:Show();
                        end
                    end
                );
                Housing.DataProvider:TriggerRefresh();
            end
        end
    end);
end


local function Blizzard_HouseEditor_OnLoad()
    Housing.DataProvider:Init();

    C_Timer.After(0, function()
        local ownedOnly = true;
        ModifySearcherBase(HouseEditorFrame.StoragePanel, ownedOnly);
    end);
end


local function Blizzard_HousingDashboard_OnLoad()
    Housing.DataProvider:Init();

    C_Timer.After(0, function()
        ModifySearcherBase(HousingDashboardFrame.CatalogContent);
    end);
end


local BlizzardAddOns = {
    {name = "Blizzard_HousingDashboard", callback = Blizzard_HousingDashboard_OnLoad},
    {name = "Blizzard_HouseEditor", callback = Blizzard_HouseEditor_OnLoad},
};

do
    local function EnableModule(state)
        if state then
            for _, v in ipairs(BlizzardAddOns) do
                if not v.registered then
                    v.registered = true;
                    if C_AddOns.IsAddOnLoaded(v.name) then
                        v.callback();
                    else
                        EventUtil.ContinueOnAddOnLoaded(v.name, v.callback);
                    end
                end
            end

            MODULE_ENABLED = true;
        else
            MODULE_ENABLED = false;
        end
    end

    local moduleData = {
        name = L["ModuleName Housing_CatalogSearch"],
        dbKey ="Housing_CatalogSearch",
        description = L["ModuleDescription Housing_CatalogSearch"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1,
        moduleAddedTime = 1765900000,
		categoryKeys = {
			"Housing",
		},
        searchTags = {
            "Housing",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end