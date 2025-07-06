local _, addon = ...
local LandingPageUtil = addon.LandingPageUtil;


local IsBaseSetCollected = C_TransmogSets.IsBaseSetCollected;




--Greedy Emissary Events
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




local ResourceList = {
    {itemID = 244465, shownInDelves = true},
    {currencyID = 3309, conditionFunc = HasUncollectedSets, appendedTooltipFunc = ShowUncollectedSets},    --Hellstone Shard (Greedy Emissary)

    {currencyID = 3028},    --Restored Coffer Key
    {itemID = 236096, isMinor = false},   --Coffer Key Shard
    {itemID = 235897},      --Radiant Echo

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
};
LandingPageUtil.ResourceList = ResourceList;