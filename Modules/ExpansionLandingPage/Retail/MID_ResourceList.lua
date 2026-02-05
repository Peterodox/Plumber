local _, addon = ...
local LandingPageUtil = addon.LandingPageUtil;

local ResourceList = {
    {currencyID = 3028},    --Restored Coffer Key
    {currencyID = 3310},    --Coffer Key Shard
    {currencyID = 3316},    --Voidlight Marl

    {currencyID = 1602, shownIfOwned = true},    --Conquest
    {currencyID = 1792, shownIfOwned = true},    --Honor

    {currencyID = 2803},    --Undercoin

};


if addon.ItemUpgradeConstant.CatalystCurrencyID then
    table.insert(ResourceList, 1, {
        currencyID = addon.ItemUpgradeConstant.CatalystCurrencyID,
        shownIfOwned = true,
    });
end

LandingPageUtil.AddExpansionData(12, "resource", ResourceList);
