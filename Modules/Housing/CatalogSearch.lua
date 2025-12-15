local _, addon = ...
local L = addon.L;


local GetGlobalObject = addon.API.GetGlobalObject;
local Housing = addon.Housing;


local SharedAchievementLinkScripts = addon.SharedAchievementLinkScripts;
local Database_DecorAchievement = Housing.Database.DecorAchievement;
local GetDecorSourceText = Housing.GetDecorSourceText;


local strlenutf8 = strlenutf8;
local strtrim = strtrim;
local find = string.find;
local lower = string.lower;


local MODULE_ENABLED = true;


--Storage List Injection
--  HouseEditorStorageFrameTemplate (HouseEditorFrame.StoragePanel.OptionsContainer)
--      OptionsContainer (ScrollingHousingCatalogTemplate) HouseEditorFrame.StoragePanel.OptionsContainer.SetCatalogElements
--      SetCatalogData


local CreateUpdator;
do
    local UpdatorMixin = {};

    function UpdatorMixin:OnHide()
        self:Hide();
    end

    function UpdatorMixin:OnUpdate(elapsed)
        local v, decorID, sourceText;
        local updateThisFrame = 0;

        while updateThisFrame < 100 do
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
                            if find(sourceText, self.searchText, 1, true) then
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
        self.catalogEntries = {};
        self.foundIDs = {};
    end

    function UpdatorMixin:ProcessResult()
        self:SetScript("OnUpdate", nil);

        local searchText = self.searcher:GetSearchText() or "";
        searchText = strtrim(searchText);

        local useAdvancedSearch = searchText and strlenutf8(searchText) >= 3;
        if not (useAdvancedSearch and self.catalogEntries) then
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

            -- Bundle entries have a list of decor entries
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
        if MODULE_ENABLED and catalogEntries then
            local searchText = searcher:GetSearchText() or "";
            if strlenutf8(searchText) >= 3 then
                searchText = strtrim(searchText);
                local allEntries = Housing.DataProvider.allEntries;

                if allEntries then
                    Updator.index = 1;
                    Updator.toIndex = #allEntries;
                    Updator.allEntries = allEntries;
                    Updator.searchText = lower(searchText);
                    Updator.n = #catalogEntries;

                    Updator.catalogEntries = catalogEntries;
                    Updator.retainCurrentPosition = retainCurrentPosition;
                    Updator.headerText = headerText;
                    Updator.instructionText = instructionText;

                    for _, v in ipairs(catalogEntries) do
                        if v.entryType == 1 then
                            Updator.foundIDs[v.recordID] = true;
                        end
                    end

                    Updator:SetScript("OnUpdate", Updator.OnUpdate);
                    Updator:Show();
                end
            end
        end
    end);
end


local TextContainerHooked = false;



local function ModifySourceInfo(catalogEntryInfo)
    if not catalogEntryInfo.sourceText then return end;

    local decorID = catalogEntryInfo.entryID.recordID;
    if Database_DecorAchievement[decorID] then
        local achievementID = Database_DecorAchievement[decorID][2];
        local _, name = GetAchievementInfo(achievementID);
        local link = GetAchievementLink(achievementID);

        name = string.gsub(name, "%-", "%%-");
        name = string.gsub(name, "%!", "%%!");
        name = string.gsub(name, "%(", "%%(");
        name = string.gsub(name, "%)", "%%)");

        local sourceText = string.gsub(catalogEntryInfo.sourceText, name, link);
        local TextContainer = GetGlobalObject("HousingDashboardFrame.CatalogContent.PreviewFrame.TextContainer");

        if not TextContainerHooked then
            TextContainerHooked = true;
            TextContainer:SetHyperlinksEnabled(true);
            TextContainer:HookScript("OnHyperlinkClick", SharedAchievementLinkScripts.OnHyperlinkClick);
            TextContainer:HookScript("OnHyperlinkEnter", SharedAchievementLinkScripts.OnHyperlinkEnter);
            TextContainer:HookScript("OnHyperlinkLeave", SharedAchievementLinkScripts.OnHyperlinkLeave);
        end

        TextContainer.SourceInfo:SetText(sourceText);
        --TextContainer:Layout();
    end
end


local function ModifyTextContainer(previewFrame)
    if previewFrame.PreviewCatalogEntryInfo then
        hooksecurefunc(previewFrame, "PreviewCatalogEntryInfo", function(_, catalogEntryInfo)
            ModifySourceInfo(catalogEntryInfo);
        end);
    end
end


local function Load_Blizzard_HouseEditor()
    Housing.DataProvider:Init();

    C_Timer.After(0, function()
        local ownedOnly = true;
        ModifySearcherBase(HouseEditorFrame.StoragePanel, ownedOnly);
    end);
end
EventUtil.ContinueOnAddOnLoaded("Blizzard_HouseEditor", Load_Blizzard_HouseEditor);


local function Load_Blizzard_HousingDashboard()
    Housing.DataProvider:Init();

    C_Timer.After(0, function()
        ModifySearcherBase(HousingDashboardFrame.CatalogContent);
        ModifyTextContainer(HousingDashboardFrame.CatalogContent.PreviewFrame);
    end);
end
EventUtil.ContinueOnAddOnLoaded("Blizzard_HousingDashboard", Load_Blizzard_HousingDashboard);