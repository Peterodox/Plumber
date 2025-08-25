local _, addon = ...
local LandingPageUtil = addon.LandingPageUtil;


--Greedy Emissary Events
--[[
local IsBaseSetCollected = C_TransmogSets.IsBaseSetCollected;

local IsSetCollected;
local HellstoneTransmogSets = {
    4567, 4566, 4571, 4562, 4563, 4570, 4565, 4574, 4572, 4568, 4569, 4573, 4564,
};

local function HasUncollectedSets()
    local collected;
    if not IsSetCollected then
        IsSetCollected = {};
        for _, transmogSetID in ipairs(HellstoneTransmogSets) do
            collected = IsBaseSetCollected(transmogSetID);
            if not collected then
                IsSetCollected[transmogSetID] = false;
            end
        end
    end

    local anyUncollected;
    for transmogSetID in pairs(IsSetCollected) do
        collected = IsBaseSetCollected(transmogSetID);
        if collected then
            IsSetCollected[transmogSetID] = nil;
        else
            anyUncollected = true;
        end
    end
    return anyUncollected
end

local function ShowUncollectedSets(tooltip)
    if HasUncollectedSets() then
        local total = 0;
        for transmogSetID in pairs(IsSetCollected) do
            total = total + 1;
        end
        tooltip:AddLine(addon.L["Uncollected Set Counter Format"]:format(total), CONTEXT_FEEDBACK_COLOR);
        return true
    end
end
--]]



local ResourceList = {
    {currencyID = 3028},    --Restored Coffer Key
    {itemID = 245653, isMinor = false, useActionButton = true},   --Coffer Key Shard
    {itemID = addon.ItemUpgradeConstant.RadiantEchoItemID},      --Radiant Echo

    {currencyID = 1602, shownIfOwned = true},    --Conquest
    {currencyID = 1792, shownIfOwned = true},    --Honor

    {currencyID = 3149, shownIfOwned = true},    --Displaced Corrupted Mementos
    {currencyID = 2815},    --Resonance Crystals
    {currencyID = 3218},    --Empty Kaja'Cola Can
    {currencyID = 3226, shownIfOwned = true},    --Market Research
    {currencyID = 3090, shownIfOwned = true},    --Flame-Blessed Iron
    {currencyID = 3056},    --Kej
    --{currencyID = 3055},      --Mereldar Derby Mark
    {currencyID = 2803},    --Undercoin

    ---{isHeader = true, name = PVP},
    {currencyID = 2123, shownIfOwned = true},    --Bloody Tokens
    {currencyID = 2797, shownIfOwned = true},    --Trophy of Strife


    --{currencyID = 3309, conditionFunc = HasUncollectedSets, appendTooltipFunc = ShowUncollectedSets},    --Hellstone Shard (Greedy Emissary)
};
LandingPageUtil.ResourceList = ResourceList;


if addon.ItemUpgradeConstant.CatalystCurrencyID then
    table.insert(ResourceList, 1, {
        currencyID = addon.ItemUpgradeConstant.CatalystCurrencyID,
        shownIfOwned = true,
    });
end