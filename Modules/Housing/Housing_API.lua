local _, addon = ...
local L = addon.L;
local Housing = {};
addon.Housing = Housing;

Housing.Database = {};


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

    function Housing.GetDecorSourceText(decorID, ownedOnly)
        if ownedOnly then
            local info = GetCatalogEntryInfoByRecordID(1, decorID, true);
            return info and info.numStored > 0 and info.sourceText
        else
            local info = GetCatalogEntryInfoByRecordID(1, decorID, false);
            return info and info.sourceText
        end
    end

    function Housing.GetDecorItemID(decorID)
        local info = GetCatalogEntryInfoByRecordID(1, decorID, false);
        if info and info.itemID then
            return info.itemID
        end
        return Housing.Database.DecorItem[decorID]
    end
end


do  --Item Search
    DataProvider.numEntries = 0;

    function DataProvider:Init()
        if self.catalogSearcher then return end;

        self.catalogSearcher = C_HousingCatalog.CreateCatalogSearcher();
        self.catalogSearcher:SetOwnedOnly(false);
        self.catalogSearcher:SetEditorModeContext(Enum.HouseEditorMode.BasicDecor);
        self.catalogSearcher:SetCollected(true);
        self.catalogSearcher:SetUncollected(true);
        self.catalogSearcher:SetFirstAcquisitionBonusOnly(false);
        --self.catalogSearcher:SetIncludeMarketEntries(true);

        self.catalogSearcher:SetResultsUpdatedCallback(function()
            self.isLoadingData = false;
            if self.resultsUpdatedCallback then
                local callback = self.resultsUpdatedCallback;
                self.resultsUpdatedCallback = nil;
                callback();
            end
        end);

        self.catalogSearcher:SetSearchText();
        self.catalogSearcher:RunSearch();
        self.isLoadingData = true;
    end

    function DataProvider:IsLoadingData()
        return self.isLoadingData
    end

    function DataProvider:GetAllDecorIDs()
        self:Init();
        if not self.allDecorIDs then
            local tbl = {};
            self.allDecorIDs = tbl;
            local n = 0;
            if self.allEntries then
                for k, v in ipairs(self.allEntries) do
                    if v.entryType == 1 and v.recordID then
                        n = n + 1;
                        tbl[n] = v.recordID;
                    end
                end
            end
        end
        return self.allDecorIDs
    end

    function DataProvider:GetNumEntries()
        return self.numEntries
    end

    function DataProvider:GetAllEntries()
        return self.catalogSearcher:GetCatalogSearchResults();
    end

    function DataProvider:TriggerRefresh()
        self.isLoadingData = true;
        self.catalogSearcher:RunSearch();
    end

    function DataProvider:CleaSearchCallback()
        self.resultsUpdatedCallback = nil;
    end

    function DataProvider:SetSearchCallback(resultsUpdatedCallback)
        self.resultsUpdatedCallback = resultsUpdatedCallback;
    end
end


do  --House Level / Info / Teleport
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

    function DataProvider:ProcessHouseInfoList()
        self.teleportHomeInfo = {};
        _G.Plumber_TeleportHome = nil;

        if (not self.houseInfoList) or #self.houseInfoList == 0 then
            return
        end

        local faction = UnitFactionGroup("player");
        local factionMapIndex = faction == "Horde" and 2 or 1;
        local TeleportHomeButtons = Housing.TeleportHomeButtons;

        for i = 1, self:GetMaxHousePlayerCanOwn() do
            local info = self.houseInfoList[i];
            if info then
                local uiMapID = C_Housing.GetUIMapIDForNeighborhood(info.neighborhoodGUID);
                local mapIndex = uiMapID and NeighborhoodMapIndex[uiMapID] or 1;

                if i == 1 or mapIndex == factionMapIndex then
                    TeleportHomeButtons.CurrentFaction:SetAction_TeleportHome(info.neighborhoodGUID, info.houseGUID, info.plotID);
                end

                if mapIndex == 1 then
                    TeleportHomeButtons.Alliance:SetAction_TeleportHome(info.neighborhoodGUID, info.houseGUID, info.plotID);
                elseif mapIndex == 2 then
                    TeleportHomeButtons.Horde:SetAction_TeleportHome(info.neighborhoodGUID, info.houseGUID, info.plotID);
                end

                self.teleportHomeInfo[i] = {
                    ownerName = info.ownerName,
                    houseName = info.houseName,
                    mapIndex = mapIndex,
                };
            end
        end
    end

    function DataProvider:OnHouseListUpdated(houseInfoList)
        self.houseInfoList = houseInfoList;
        self:RequestHouseLevelInfo();
        self:ProcessHouseInfoList();
    end


    function Housing.CheckTeleportInCooldown()
        local timeString = DataProvider:GetTeleportCooldownText();
        if timeString then
            local messageType = 0;
            UIErrorsFrame:TryDisplayMessage(messageType, ITEM_COOLDOWN_TIME:format("|cffffffff"..timeString.."|r"), RED_FONT_COLOR:GetRGB());
            return true
        end
    end

    function Housing.SetupTeleportTooltip(tooltip)
        if C_HousingNeighborhood.CanReturnAfterVisitingHouse() then
            tooltip:SetText(L["Leave Home"]);
        else
            tooltip:SetText(L["Teleport Home"]);
            local timeString = DataProvider:GetTeleportCooldownText();
            if timeString then
                tooltip:AddLine(ITEM_COOLDOWN_TIME:format(timeString), 1, 1, 1, true);
            end
            tooltip:Show();
        end
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

    local DyeRecipes = {
        --[dyeColorID] = recipeID
        --For Dye Station

        nil,
        nil,
        1277207,
        1277205,
        1277209,
        1277200,
        1277215,
        1277204,
        1277201,
        1277208,
        1277206,
        1277210,
        1265116,
        1265114,
        1265119,
        1265120,
        1265115,
        1265112,
        1265117,
        1264760,
        1265113,
        1265111,
        1265091,
        1264720,
        1264719,
        1264715,
        1265106,
        1264722,
        1265084,
        1264713,
        1264885,
        1264938,
        1264886,
        1265078,
        1265079,
        1265085,
        1264725,
        1264955,
        1264891,
        1265086,
        1265087,
        1264940,
        1265080,
        1265098,
        1264894,
        1264717,
        1265107,
        1265109,
        1265121,
        1265088,
        1264942,
        1264944,
        1265081,
        1265089,
        1264945,
        1264895,
        1265082,
        1265101,
        1264914,
        1264950,
        1265122,
        1265094,
        1264889,
        1265097,
    };


    local function Debug_SaveDyeRecipes()
        --Use at Dye Station
        local tbl = {};
        local dyeColorXItem = {};

        local ownedColorsOnly = false;
        for _, dyeColorID in ipairs(C_DyeColor.GetAllDyeColors(ownedColorsOnly)) do
            local info = C_DyeColor.GetDyeColorInfo(dyeColorID);
            if info and info.itemID then
                dyeColorXItem[info.itemID] = dyeColorID;
            else
                print("Missing Dye:", dyeColorID);
            end
        end

        for _, recipeID in ipairs(C_TradeSkillUI.GetFilteredRecipeIDs()) do
            local outputInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID);
            local itemID = outputInfo and outputInfo.itemID;
            if itemID then
                local dyeColorID = dyeColorXItem[itemID];
                if dyeColorID then
                    tbl[dyeColorID] = recipeID;
                else
                    print("Cannot find item for dye:", dyeColorID);
                end
            else
                print("Missing recipe:", recipeID);
            end
        end

        PlumberDevData = PlumberDevData or {};
        PlumberDevData.DyeRecipes = tbl;
    end
    --_G.Plumber_SaveDyeRecipes = Debug_SaveDyeRecipes;


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

    function Housing.GetDyeRecipeID(dyeColorID)
        return dyeColorID and DyeRecipes[dyeColorID]
    end
end