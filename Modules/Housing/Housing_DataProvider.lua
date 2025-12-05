local _, addon = ...
local L = addon.L;
local Housing = {};
addon.Housing = Housing;


local DataProvider = CreateFrame("Frame");
Housing.DataProvider = DataProvider;


local C_Housing = C_Housing;


do  --Basic
    function DataProvider:OnEvent(event, ...)
        local callbackInfo = self[event];
        local anyCallback;

        for callback, info in pairs(callbackInfo) do
            if (info.oneoff and not info.processed) or (not info.oneoff) then
                info.processed = true;
                anyCallback = true;
                callback(self, ...);
            end
        end

        if not anyCallback then
            self[event] = nil;
            self:UnregisterEvent(event);
        end
    end
    DataProvider:SetScript("OnEvent", DataProvider.OnEvent);

    function DataProvider:RegisterEventCallback(event, callback, oneoff)
        local callbackInfo = self[event];
        if not callbackInfo then
            callbackInfo = {};
            self[event] = callbackInfo;
        end
        callbackInfo[callback] = {
            processed = false,
            oneoff = oneoff or false,
        };
        self:RegisterEvent(event);
    end
end


do  --Item Search
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
end


do  --House Level
    function DataProvider:GetMaxHousePlayerCanOwn()
        return 2
    end

    function DataProvider:RequestHouseLevelInfo()
        local houseInfo = self.houseInfoList and self.houseInfoList[1];
        if houseInfo then
            self:RegisterEventCallback("HOUSE_LEVEL_FAVOR_UPDATED", self.OnHouseLevelReceived, true);
            C_Housing.GetCurrentHouseLevelFavor(houseInfo.houseGUID);   --Trigger HOUSE_LEVEL_FAVOR_UPDATED
        end
    end

    function DataProvider:OnHouseLevelReceived(houseLevelFavor)
        if not houseLevelFavor then
            return
        end
        self.actualLevel = houseLevelFavor.houseLevel;
        self.displayLevel = houseLevelFavor.houseLevel + 1;
        self.houseFavor = houseLevelFavor.houseFavor;
        self.houseFavorNeeded = C_Housing.GetHouseLevelFavorForLevel(self.actualLevel + 1);
        --This is the radial progress bar value
        --print(self.actualLevel, self.displayLevel, self.houseFavor, self.houseFavorNeeded);
    end

    function DataProvider:LoadHouses()
        self:RegisterEventCallback("PLAYER_HOUSE_LIST_UPDATED", self.OnHouseListUpdated, true);
        C_Housing.GetPlayerOwnedHouses();   --Tigger PLAYER_HOUSE_LIST_UPDATED
    end

    local NeighborhoodMapIndex = {
        [2352] = 1, --Alliance, Founder's Point
        [2351] = 2, --Horde, Razorwind Shores
    };

    function DataProvider:GetTeleportCooldownText()
        local cooldownInfo = C_Housing.GetVisitCooldownInfo();
        if cooldownInfo and cooldownInfo.isEnabled then
            local endTime = cooldownInfo.startTime + cooldownInfo.duration;
            local currentTime = GetTime();
            local diff = endTime - currentTime;
            if diff > 1 then
                local timeString = addon.API.SecondsToTime(diff, true);
                return timeString
            end
        end
    end

    function DataProvider:CheckTeleportInCooldown()
        local timeString = self:GetTeleportCooldownText();
        if timeString then
            local messageType = 0;
            UIErrorsFrame:TryDisplayMessage(messageType, ITEM_COOLDOWN_TIME:format("|cffffffff"..timeString.."|r"), RED_FONT_COLOR:GetRGB());
            return true
        end
    end

    function Housing.SetupTeleportTooltip(tooltip)
        tooltip:SetText(L["Teleport Home"]);
        local timeString = DataProvider:GetTeleportCooldownText();
        if timeString then
            tooltip:AddLine(ITEM_COOLDOWN_TIME:format(timeString), 1, 1, 1, true);
        end
        tooltip:Show();
    end

    function DataProvider:ProcessHouseInfoList()
        self.teleportHomeInfo = {};
        _G.Plumber_TeleportHome = nil;

        if (not self.houseInfoList) or #self.houseInfoList == 0 then
            return
        end

        local faction = UnitFactionGroup("player");
        local factionMapIndex = faction == "Horde" and 2 or 1;

        for i = 1, self:GetMaxHousePlayerCanOwn() do
            local info = self.houseInfoList[i];
            if info then
                local uiMapID = C_Housing.GetUIMapIDForNeighborhood(info.neighborhoodGUID);
                local mapIndex = uiMapID and NeighborhoodMapIndex[uiMapID] or 1;
                local teleportFunc = function()
                    if DataProvider:CheckTeleportInCooldown() or InCombatLockdown() then
                        return
                    end
                    C_Housing.TeleportHome(info.neighborhoodGUID, info.houseGUID, info.plotID);     --C_Housing.ReturnAfterVisitingHouse
                end
                if mapIndex == factionMapIndex then
                    _G.Plumber_TeleportHome = teleportFunc;
                end
                self.teleportHomeInfo[i] = {
                    ownerName = info.ownerName,
                    houseName = info.houseName,
                    mapIndex = mapIndex,
                    func = teleportFunc,
                };
            end
        end
    end

    function DataProvider:OnHouseListUpdated(houseInfoList)
        self.houseInfoList = houseInfoList;
        self:RequestHouseLevelInfo();
        self:ProcessHouseInfoList();
    end


    function Housing.RequestUpdateHouseInfo()
        if not Housing.isUpdatingHouseInfo then
            Housing.isUpdatingHouseInfo = true;
            DataProvider:LoadHouses();
            C_Timer.After(1, function()
                Housing.isUpdatingHouseInfo = nil;
            end);
        end
    end
end