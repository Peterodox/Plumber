-- Save specific MerchantItemInfo so player can check their list regardless of their current location
-- LIST ALL NPC & ITEMS BELOW:
-- -- 1. Azerothian Archive Vendor: Provisioner Aristta (209192), Algeth'ar Academy (61.4, 31.4, Content Tracking unavailable 10.2.5.52646)     Currency: Mysterious Fragment (2657)

local _, addon = ...
local API = addon.API;

function Debug_ShowCurrentMerchantItemList()
    SetMerchantFilter(1);   --All

    local numMerchantItems = GetMerchantNumItems();

    local name, texture, price, stackCount, numAvailable, isPurchasable, isUsable, extendedCost, currencyID, spellID;
    local itemID;
    local output, lineText;
    local numCost, cost, itemTexture, itemValue, itemLink, currencyName;

    for i = 1, numMerchantItems do
        name, texture, price, stackCount, numAvailable, isPurchasable, isUsable, extendedCost, currencyID, spellID = GetMerchantItemInfo(i);
        itemID = GetMerchantItemID(i);
        numCost = GetMerchantItemCostInfo(i);

        for n = 1, numCost do
            itemTexture, itemValue, itemLink, currencyName = GetMerchantItemCostItem(i, n);
            price = itemValue;
            currencyID = currencyID or string.match(itemLink, "currency:(%d+)");
        end

        lineText = strjoin(", ", name, itemID, price, currencyID);

        if i == 1 then
            output = lineText;
        else
            output = output .. "\n" .. lineText;
        end
    end

    API.PrintTextToClipboard(output);
end


--[[
    uiMapID: Azure Span (2024)      Traitor's Rest Azerothian Archive Started (2262)
--]]

--[[
    Priceless Artifact, 213536, 1000, 2657
    Historian's Utility Belt, 212635, 5000, 2657
    Historian's Fingerless Gloves, 212634, 5000, 2657
    Historian's Striders, 212637, 5000, 2657
    Historian's Trousers, 212636, 7000, 2657
    Historian's Fitted Vest, 212633, 7000, 2657
    Archivist's Magnifying Mace, 213276, 10000, 2657
    Archivist's Rockpuller, 213275, 10000, 2657
    Archivist's Pathfinder, 213274, 10000, 2657
    Archivist's Stone Chisel, 212870, 10000, 2657
    Archivist's Improvised Cudgel, 208459, 10000, 2657
    Archivist's Extravagant Lantern, 208458, 10000, 2657
    Archivist's "Light Touch", 212941, 10000, 2657
    Archivist's Spelunking Torch, 208457, 10000, 2657
    Archivist's Sturdy Hook, 208455, 10000, 2657
    Archivist's Mining Pick, 208454, 10000, 2657
    Archivist's Super Scooper, 208453, 10000, 2657
    Coiled Archivist's Rope, 208450, 10000, 2657
    Archivist's Reading Spectacles, 208547, 12000, 2657
    Archivist's Rose-Tinted Glasses, 208546, 12000, 2657
    Archivist's Elegant Bag, 208456, 15000, 2657
    Historian's Hefty Habersack, 212794, 15000, 2657
    Historian's Dapper Cap, 208452, 15000, 2657
    Explorer's Stonehide Packbeast, 192796, 20000, 2657
--]]