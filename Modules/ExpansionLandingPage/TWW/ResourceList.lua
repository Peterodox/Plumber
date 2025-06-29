local _, addon = ...
local LandingPageUtil = addon.LandingPageUtil;


local ResourceList = {
    {itemID = 244465, shownInDelves = true},

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