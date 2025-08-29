local _, addon = ...
local API = addon.API;


do  --Item Upgrade Track
    local ItemUpgradeConstant = {
        BaseCurrencyID = 3008,      --Flightstones
        CatalystCurrencyID = 3269;  --Item conversion   /dump ItemInteractionFrame.currencyTypeId
        DelveWeeklyStashCurrencyID = 3290,
        RadiantEchoItemID = 246771,

        Crests = {
            --Universal Upgrade System (Crests)
            --convert to string for hybrid process
            --CategoryID ~= 142
            --From high tier to low

            --11.2.0
            3290,   --Gilded    (M, M7+)
            3288,   --Runed     (H, M2)
            3286,   --Carved    (N, M0)
            3284,   --Weathered (LFR, H)
        },

        CrestSources = {
            (PLAYER_DIFFICULTY6 or "Mythic") .. ", +7",
            (PLAYER_DIFFICULTY2 or "Heroic") .. ", +2",
            (PLAYER_DIFFICULTY1 or "Normal"),
            (PLAYER_DIFFICULTY3 or "Raid Finder"),
        };
    };


    addon.ItemUpgradeConstant = ItemUpgradeConstant;
end


do  --Weekly Caches (Meta quest rewards)
    local WeeklyRewardsConstant = {
        MajorChests = { --Change every season
            244842,     --Fabled Veteran's Cache
            244865,     --Pinnacle Cache
            245611,     --Wriggling Pinnacle Cache
            255676,     --Phase Diver's Cache
        },

        MinorChests = {
            245280,     --Seasoned Khaz Algar Adventurer's Cache
            250763,     --Theater Troupe's Trove
            250764,     --Nanny's Surge Dividends
            250765,     --Awakened Mechanical Cache
            250766,     --Radiant Cache
            250767,     --The General's War Chest
            250768,     --The Vizier's Capital
            250769,     --The Weaver's Gratuity
        },

        ChestSources = {
            [244842] = {
                quests = {
                    89293,  --Special Assignment: Overshadowed
                    89294,  --Special Assignment: Aligned Views
                },
            },

            [244865] = {
                questMap = 2339,    --Dornogal Meta Quest
            },

            [245611] = {
                quests = {
                    85460,  --Ecological Succession
                },
            },

            [255676] = {
                quests = {
                    91093,  --More Than Just a Phase
                },
            },

            [250763] = {
                quests = {
                    83240,  --The Theater Troupe
                },
            },

            [250764] = {
                quests = {
                    86775,  --Urge to Surge
                },
            },

            [250765] = {
                quests = {
                    83333,  --Gearing Up for Trouble
                },
            },

            [250766] = {
                quests = {
                    76586,  --Speading the Light
                },
            },

            [250767] = {
                quests = {
                    80671,  --Blade of the General
                },
            },

            [250768] = {
                quests = {
                    80672,  --Hand of the Vizier
                },
            },

            [250769] = {
                quests = {
                    80670,  --Eyes of the Weaver
                },
            },
        },

        CofferKeyFlags = {
            91175, 91176, 91177, 91178,
        },

        CofferKeyShardFlags = {
            84736, 84737, 84738, 84739,
        },

        DelvesGreatVaultItemLevel = {
            --Hardcode this because BLZ API is unreliable in 11.2.0
            668,
            671,
            675,
            678,
            681,

            688,
            691,
            694,    --Tier 8 Max
            694,
            694,

            694,
        },
    };


    addon.WeeklyRewardsConstant = WeeklyRewardsConstant;


    function API.GetDelvesGreatVaultItemLevel(tier)
        return WeeklyRewardsConstant.DelvesGreatVaultItemLevel[tier]
    end
end