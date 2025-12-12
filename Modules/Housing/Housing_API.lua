local _, addon = ...
local L = addon.L;
local Housing = {};
addon.Housing = Housing;


local DataProvider = CreateFrame("Frame");
Housing.DataProvider = DataProvider;


local C_Housing = C_Housing;
local GetCatalogEntryInfoByRecordID = C_HousingCatalog.GetCatalogEntryInfoByRecordID;


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


    function Housing.GetCatalogDecorInfo(decorID, tryGetOwnedInfo)
        --Enum.HousingCatalogEntryType.Decor
        tryGetOwnedInfo = true;
        return GetCatalogEntryInfoByRecordID(1, decorID, tryGetOwnedInfo)
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


do  --House Level / Info / Teleport
    --local SecureButton_Home1 = CreateFrame("Button", "PLMR_HOME1", nil, "SecureActionButtonTemplate");
    --SecureButton_Home1:SetSize(1, 1);
    --SecureButton_Home1:SetPoint("BOTTOMRIGHT", UIParent, "TOPLEFT", 0, 0);

    local function SetAction_TeleportHome(neighborhoodGUID, houseGUID, plotID)
        if not InCombatLockdown() then
            SecureButton_Home1:RegisterForClicks("AnyDown", "AnyUp");
            SecureButton_Home1:SetAttribute("type", "teleporthome");
            SecureButton_Home1:SetAttribute("house-neighborhood-guid", neighborhoodGUID);
            SecureButton_Home1:SetAttribute("house-guid", houseGUID);
            SecureButton_Home1:SetAttribute("house-plot-id", plotID);
        end
    end


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
                if i == 1 or mapIndex == factionMapIndex then
                    _G.Plumber_TeleportHome = teleportFunc;
                    --SetAction_TeleportHome(info.neighborhoodGUID, info.houseGUID, info.plotID);
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

    addon.CallbackRegistry:Register("ModulesLoaded", Housing.RequestUpdateHouseInfo);
end


do  --Dye
    local SWATCH_FORMAT = "|TInterface\\AddOns\\Plumber\\Art\\Housing\\DyeSwatchSmall:%d:%d:0:0:64:64:0:32:0:32:%d:%d:%d|t";
    local EMPTY_SWATCH_MARKUP = "|TInterface\\AddOns\\Plumber\\Art\\Housing\\DyeSwatchSmall:%d:%d:0:0:64:64:0:32:32:64|t";


    local GetDyeColorInfo = C_DyeColor.GetDyeColorInfo;


    function Housing.GetSwatchMarkup(dyeColorID, iconSize, showName)
        iconSize = iconSize or 0;
        local markup;
        local dyeColorInfo = dyeColorID and GetDyeColorInfo(dyeColorID);
        local numOwned = 0;
        if dyeColorInfo then
            local r, g, b = dyeColorInfo.swatchColorStart:GetRGBAsBytes();
            markup = SWATCH_FORMAT:format(iconSize, iconSize, r, g, b);
            if showName then
                markup = markup.." "..dyeColorInfo.name;
            end
            numOwned = dyeColorInfo.numOwned;
        else
            markup = EMPTY_SWATCH_MARKUP:format(iconSize, iconSize);
            if showName then
                markup = markup.." "..NONE;
            end
        end
        return markup, numOwned
    end


    local PigmentNameSorted = {};

    local DyePigmentNames;

    local DyeColors = {
        -- {dyeColorID1, dyeColorID2, ...} (by SortOrder)
        Black = {31, 33, 13, 18, 21, 7},
        Blue = {63, 56, 25, 45, 39},
        Brown = {51, 55, 38, 32, 22, 3, 12, 5, 10},
        Green = {44, 24, 57, 53, 34, 43, 60},
        Orange = {42, 28, 17, 14},
        Purple = {41, 29, 50, 26, 36, 40, 54},
        Red = {23, 49, 64, 37, 52, 62, 61, 11},
        Teal = {46, 58, 35, 19},
        White = {30, 59, 4, 8},
        Yellow = {27, 48, 47, 16, 15, 20, 9, 6},
    };

    local PigmentData = {
        --[pigmentItemID]
        --See: https://wago.tools/db2/DyeColor?sort%5BSortOrder%5D=asc

        [262639] = DyeColors.Black,
        [262643] = DyeColors.Blue,
        [262642] = DyeColors.Brown,
        [262647] = DyeColors.Green,
        [262656] = DyeColors.Orange,
        [262625] = DyeColors.Purple,
        [262655] = DyeColors.Red,
        [262628] = DyeColors.Teal,
        [260947] = DyeColors.White,
        [262648] = DyeColors.Yellow,
    };

    local PigmentRecipes = {
        --[recipeID]

        Alchemy = {
            [1269228] = DyeColors.Black,
            [1269226] = DyeColors.Blue,
            [1269235] = DyeColors.Brown,
            [1269230] = DyeColors.Green,
            [1269233] = DyeColors.Orange,
            [1269231] = DyeColors.Purple,
            [1269229] = DyeColors.Red,
            [1269232] = DyeColors.Teal,
            [1269227] = DyeColors.White,
            [1269234] = DyeColors.Yellow,
        },

        Inscription = {
            [1268662] = DyeColors.Black,
            [1268984] = DyeColors.Blue,
            [1267108] = DyeColors.Brown,
            [1268985] = DyeColors.Green,
            [1268993] = DyeColors.Orange,
            [1269057] = DyeColors.Purple,
            [1268998] = DyeColors.Red,
            [1268999] = DyeColors.Teal,
            [1268770] = DyeColors.White,
            [1268989] = DyeColors.Yellow,
        },
    };

    function Housing.GetDyesByPigmentItemID(itemID)
        if PigmentData[itemID] then
            if not PigmentNameSorted[itemID] then
                PigmentNameSorted[itemID] = true;
                local dyeName = {};
                for _, dyeColorID in ipairs(PigmentData[itemID]) do
                    local dyeColorInfo = GetDyeColorInfo(dyeColorID);
                    dyeName[dyeColorID] = dyeColorInfo and dyeColorInfo.name or dyeColorID;
                end

                table.sort(PigmentData[itemID], function(a, b)
                    return dyeName[a] < dyeName[b]
                end);
            end

            return PigmentData[itemID]
        end
    end

    function Housing.GetPigmentRecipes(profession)
        return PigmentRecipes[profession]
    end

    function Housing.GetDyePigmentName(dyeColorID)
        if not DyePigmentNames then
            DyePigmentNames = {};
            for key, colors in pairs(DyeColors) do
                local name = L["DyeColorNameAbbr "..key];
                if name then
                    for _, id in ipairs(colors) do
                        DyePigmentNames[id] = name;
                    end
                end
            end
        end
        return DyePigmentNames[dyeColorID]
    end
end