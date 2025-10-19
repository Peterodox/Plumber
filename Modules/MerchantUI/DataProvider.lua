local _, addon = ...
local L = addon.L;
local API = addon.API;


local tinsert = table.insert;


local MerchantUIUtil = {};
addon.MerchantUIUtil = MerchantUIUtil;


local UnifiedItemTypes = {
    -- classID * 100 + subClassID
    -- names should be plural

    [0008] = {  --Consumable, Other
        overrideName = L["ItemType Consumables"],
    },

    [0214] = {  --Consumable, Generic
        overrideName = L["ItemType Weapons"],
    },

    [0309] = {  --Gem, Other
        overrideName = L["ItemType Gems"],
    },

    [0400] = {  --Armor, Generic
        overrideName = L["ItemType Armor Generic"],
    },


    -- Custom Types:
    [9900] = {  --Mounts
        overrideName = L["ItemType Mounts"],
    },

    [9905] = {  --Pets
        overrideName = L["ItemType Pets"],
    },

    [9910] = {  --Toys
        overrideName = L["ItemType Toys"],
    },

    [9915] = {
        overrideName = L["ItemType TransmogSet"]
    },

    [9920] = {
        overrideName = L["ItemType Transmog"]
    },
};

local OverrideItemTypes = {
    -- Redirect 9: Recipe to 19: Profession
    [0904] = 1900,  --Blacksmithing
    [0901] = 1901,  --Leatherworking
    [0906] = 1902,  --Alchemy
    [0905] = 1904,  --Cooking
    [0902] = 1906,  --Tailoring
    [0907] = 1906,  --Tailoring (First Aid)
    [0903] = 1907,  --Engineering
    [0908] = 1907,  --Enchanting
    [0909] = 1909,  --Fishing
    [0910] = 1911,  --Jewelcrafting
    [0911] = 1912,  --Inscription

    -- No recipes for these items
    --[0901] = 1905,  --Mining
    --[0901] = 1903,  --Herbalism
    --[0901] = 1910,  --Skinning


    [1505] = 9900,  --Mounts
    [1502] = 9905,  --Pets
};


local DataProvider = {};
MerchantUIUtil.DataProvider = DataProvider;


do  --Item/Merchant APIs
    local GetItemQualityColor = API.GetItemQualityColor;
    local GetItemInfoInstant = C_Item.GetItemInfoInstant;
    local GetItemInfo = C_MerchantFrame.GetItemInfo;
    local GetMerchantNumItems = GetMerchantNumItems;
    local GetMerchantItemLink = GetMerchantItemLink;
    local GetMerchantItemCostInfo = GetMerchantItemCostInfo;
    local GetMerchantItemCostItem = GetMerchantItemCostItem;
    local GetNumBuybackItems = GetNumBuybackItems;
    local GetBuybackItemInfo = GetBuybackItemInfo;
    local CanAffordMerchantItem = CanAffordMerchantItem;
    local GetMoney = GetMoney;


    local GetToyInfo = C_ToyBox.GetToyInfo or API.Nop;
    local function IsToyItem(itemID, classID, subClassID)
        if classID == 15 or (classID == 0 and (subClassID == 0 or subClassID == 8)) then
            return GetToyInfo(itemID) ~= nil and true
        end
    end


    local GetPetInfoByItemID = C_PetJournal.GetPetInfoByItemID or API.Nop;
    local function GetPetSpeciesID(itemID, classID, subClassID)
        if classID == 17 or (classID == 15 and (subClassID == 2 or subClassID == 4)) then
            local speciesID = select(13, GetPetInfoByItemID(itemID));
            return speciesID
        end
    end


    local GetItemSubClassInfo = C_Item.GetItemSubClassInfo;
    local function GetItemTypeName(classID, subClassID, unifiedItemType)
        if unifiedItemType and UnifiedItemTypes[unifiedItemType] then
            return UnifiedItemTypes[unifiedItemType].overrideName
        end
        return GetItemSubClassInfo(classID, subClassID)
    end
    MerchantUIUtil.GetItemTypeName = GetItemTypeName;


    local GetMountFromItem = C_MountJournal.GetMountFromItem or API.Nop;
    local GetMountInfoByID = C_MountJournal.GetMountInfoByID;
    local GetNumCollectedInfo = C_PetJournal.GetNumCollectedInfo;
    local PlayerHasToy = PlayerHasToy;
    local IsCosmeticItem = C_Item.IsCosmeticItem;
    local GetItemLearnTransmogSet = C_Item.GetItemLearnTransmogSet;

    local function IsItemCollected(itemID, unifiedItemType)
        if not (itemID and unifiedItemType) then return end;
        local isCollected, canBuyMore;  --canBuyMore: for pets

        if unifiedItemType == 9900 then
            local mountID = GetMountFromItem(itemID);
            if mountID then
                isCollected = select(11, GetMountInfoByID(mountID));
            end

        elseif unifiedItemType == 9905 then
            local speciesID = select(13, GetPetInfoByItemID(itemID));
            if speciesID then
                local numCollected, limit = GetNumCollectedInfo(speciesID);
                limit = limit or 1;
                canBuyMore = numCollected < limit;
                isCollected = numCollected > 0 and not canBuyMore;  --debug
                
            end

        elseif unifiedItemType == 9910 then
            isCollected = PlayerHasToy(itemID)
        end

        return isCollected, canBuyMore
    end
    MerchantUIUtil.IsItemCollected = IsItemCollected;


    local function GetUnifiedItemType(itemID, classID, subClassID)
        if IsToyItem(itemID, classID, subClassID) then
            return 9910
        end

        if GetPetSpeciesID(itemID, classID, subClassID) then
            return 9905
        end

        if GetItemLearnTransmogSet(itemID) then
            return 9915
        end

        if IsCosmeticItem(itemID) then
            return 9920
        end

        local unifiedItemType = 100 * classID + subClassID;
        return OverrideItemTypes[unifiedItemType] or unifiedItemType
    end


    function DataProvider:GetMerchantItemLink(index)
        return GetMerchantItemLink(index)
    end

    function DataProvider:GetItemInfo(index)
        local info = GetItemInfo(index);
        local link = GetMerchantItemLink(index);   --May need to update
        if info then
            info.itemIndex = index;
            info.link = link;
            return info
        end
    end

    function DataProvider:GetMerchantNumItems()
        return GetMerchantNumItems()
    end

    function DataProvider:CanAffordMerchantItem(index)
        return CanAffordMerchantItem(index)
    end

    function DataProvider:GetMerchantItemCost(index)
        local itemCount = GetMerchantItemCostInfo(index);
        if itemCount > 0 then
            local tbl;
            local n = 0;
            for i = 1, 3 do   --MAX_ITEM_COST
                local itemTexture, itemValue, itemLink = GetMerchantItemCostItem(index, i);
                if itemTexture then
                    if not tbl then
                        tbl = {};
                    end
                    n = n + 1;
                    tbl[n] = {itemValue, itemTexture, itemLink};    --itemLink may not be immediately available
                end
            end
            return tbl
        end
    end

    local function SortFunc_GroupByClass(a, b)
        --[[
        if a.classID ~= b.classID then
            return a.classID < b.classID
        end

        if a.subClassID ~= b.subClassID then
            return a.subClassID < b.subClassID
        end
        --]]

        if a.itemType ~= b.itemType then
            return a.itemType > b.itemType
        end

        if a.collectState ~= nil and b.collectState ~= nil and a.collectState ~= b.collectState then
            return b.collectState
        end

        if a.isPurchasable ~= b.isPurchasable then
            return a.isPurchasable
        end

        return a.itemIndex < b.itemIndex
    end

    function DataProvider:GetSortedBuyList()
        local n = 0;
        local list = {};

        local itemClassName = {};

        for index = 1, GetMerchantNumItems() do
            local info = self:GetItemInfo(index);
            if info and info.link then
                local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID = GetItemInfoInstant(info.link);
                info.itemID = itemID;
                info.classID = classID;
                info.subClassID = subClassID;
                info.itemType = GetUnifiedItemType(itemID, classID, subClassID);
                info.collectState = IsItemCollected(itemID, info.itemType);

                n = n + 1;
                list[n] = info;

                if not itemClassName[classID] then
                    itemClassName[classID] = itemType;
                end
            end
        end

        if n > 1 then
            table.sort(list, SortFunc_GroupByClass);

            local lastItemType;
            for i, v in ipairs(list) do
                if lastItemType ~= v.itemType then
                    lastItemType = v.itemType;
                    local info = {
                        isSubheader = true,
                        text = GetItemTypeName(v.classID, v.subClassID, v.itemType),
                        classID = v.classID,
                        subClassID = v.subClassID,
                    }
                    tinsert(list, i, info);
                end
            end
        end

        return list
    end

    if ColorManager and ColorManager.GetColorDataForItemQuality then
        function DataProvider:GetQualityColor(quality)
            local color = ColorManager.GetColorDataForItemQuality(quality);
            if color then
                return color.r, color.g, color.b
            else
                return 1, 1, 1
            end
        end
    else
        function DataProvider:GetQualityColor(quality)
            local r, g, b = C_Item.GetItemQualityColor(quality);
            if r then
                return r, g, b
            else
                return 1, 1, 1
            end
        end
    end

    function DataProvider:GetQualityColor(quality)
        local color = GetItemQualityColor(quality);
        return color.r, color.g, color.b
    end
end


do  --Tooltip API
    local GetMerchantItem = addon.TooltipAPI.GetMerchantItem;

    local Restrictions = {
        [Enum.TooltipDataLineType.RestrictedRaceClass] = true,
        [Enum.TooltipDataLineType.RestrictedFaction] = true,
        [Enum.TooltipDataLineType.RestrictedSkill] = true,
        --[Enum.TooltipDataLineType.RestrictedPVPMedal] = true,
        [Enum.TooltipDataLineType.RestrictedReputation] = true,
        [Enum.TooltipDataLineType.RestrictedLevel] = true,
    };

    local function IsLineColorRed(leftColor)
        if leftColor then
            local r, g, b = leftColor.r, leftColor.g, leftColor.b;
            if (g > 0.124 and g < 0.126) and (b > 0.124 and b < 0.126) and (r > 0.99) then
                return true
            end
        end
    end

    function DataProvider:GetMerchantItemRestrictions(index)
        local info = GetMerchantItem(index);
        local lines = info and info.lines;
        if lines then
            local dataInstanceID = info.dataInstanceID;
            local hasRestrictions = false;
            local lineData;

            for i = 2, #lines do
                lineData = lines[i];
                if lineData.type and Restrictions[lineData.type] then
                    if IsLineColorRed(lineData.leftColor) then
                        hasRestrictions = true;
                        print(lineData.type, lineData.leftText);
                        break
                    end
                else
                    if IsLineColorRed(lineData.leftColor) then
                        print(0, lineData.leftText);
                    end
                end
            end

            return dataInstanceID, hasRestrictions
        end
    end
end
