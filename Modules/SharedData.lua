local _, addon = ...


do  --Item Upgrade Track
    local ItemUpgradeConstant = {
        BaseCurrencyID = 3008,      --Flightstones
        CatalystCurrencyID = 3116;  --Item conversion   /dump ItemInteractionFrame.currencyTypeId
        DelveWeeklyStashCurrencyID = 3110,

        Crests = {
            --Universal Upgrade System (Crests)
            --convert to string for hybrid process
            --CategoryID ~= 142
            --From high tier to low

            --11.1.0
            3110,   --Gilded    (M, M7+)
            3109,   --Runed     (H, M2)
            3108,   --Carved    (N, M0)
            3107,   --Weathered (LFR, H)
        },

        CrestSources = {
            (PLAYER_DIFFICULTY6 or "Mythic") .. ", +7",
            (PLAYER_DIFFICULTY2 or "Heroic") .. ", +6",
            (PLAYER_DIFFICULTY1 or "Normal"),
            (PLAYER_DIFFICULTY3 or "Raid Finder"),
        };
    }
    addon.ItemUpgradeConstant = ItemUpgradeConstant;
end