if not (C_HousingCatalog and C_HousingCatalog.CreateCatalogSearcher) then return end;


local _, addon = ...

local DataProvider = {};
addon.HousingDataProvider = DataProvider;


function DataProvider:Init()
    if self.catalogSearcher then return end;

    local requeryDone = false;

    self.catalogSearcher = C_HousingCatalog.CreateCatalogSearcher();
    self.catalogSearcher:SetOwnedOnly(false);
    self.catalogSearcher:SetIncludeMarketEntries(true);
    self.catalogSearcher:SetResultsUpdatedCallback(function()
        self.isLoaded = true;
        self.isLoadingData = false;

        local entries = self.catalogSearcher:GetCatalogSearchResults(); --A list of HousingCatalogEntryID (this is a table)
        local total = #entries;
        if total > 0 then
            self.catalogSearcher:SetResultsUpdatedCallback(function() end);

            local GetCatalogEntryInfo = C_HousingCatalog.GetCatalogEntryInfo
            local entryInfo;
            self.itemIDXFileID = {};
            for _, entryID in ipairs(entries) do
                entryInfo = GetCatalogEntryInfo(entryID);
                if entryInfo then
                    if entryInfo.asset and entryInfo.itemID then
                        self.itemIDXFileID[entryInfo.itemID] = entryInfo.asset;
                    else
                        --print("Missing", entryInfo.name, entryInfo.itemID);
                    end
                end
            end

            collectgarbage();
        else
            if not requeryDone then
                requeryDone = true;
                C_Timer.After(1.0, function()
                    self.catalogSearcher:RunSearch();
                end);
            end
        end
    end);
    self.catalogSearcher:SetSearchText("");
    self.catalogSearcher:RunSearch();
    self.isLoadingData = true;
    --SetSearchText
end

function DataProvider:GetDecorModelFileIDByItem(item)
    self:Init();

    if self.itemIDXFileID then
        return self.itemIDXFileID[item];
    end
end

function DataProvider:IsLoadingData()
    return self.isLoadingData
end

