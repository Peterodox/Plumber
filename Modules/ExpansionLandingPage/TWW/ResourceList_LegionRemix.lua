local _, addon = ...
local LandingPageUtil = addon.LandingPageUtil;


local ResourceList = {
    {currencyID = 3252},    --Bronze
    {currencyID = 3268},    --Infinite Power
    {currencyID = 3292},    --Infinite Knowledge

    {currencyID = 1155},    --Ancient Mana
    {currencyID = 1149, shownIfOwned = true},   --Sightless Eye

    --{itemID = 0},      --
};


addon.CallbackRegistry:Register("TimerunningSeason", function(seasonID)
    if seasonID == 2 then
        LandingPageUtil.ResourceList = ResourceList;
    end
end);
