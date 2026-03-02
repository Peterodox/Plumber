local _, addon = ...
local L = addon.L;
local API = addon.API;


do  --Item Upgrade Track
    local ItemUpgradeConstant = {
        BaseCurrencyID = 3008,      --Flightstones (This type of currency is retired in Midnight)
        CatalystCurrencyID = 3378;  --Item conversion   /dump ItemInteractionFrame.currencyTypeId
        DelveWeeklyStashCurrencyID = 3347,
        RadiantEchoItemID = 246771, --Retired in Midnight

        Crests = {
            --Universal Upgrade System (Crests)
            --convert to string for hybrid process
            --CategoryID ~= 142
            --From high tier to low

            --12.0.1
            3347,   --Myth
            3345,   --Hero    (M, M7+)
            3343,   --Champion     (H, M2)
            3341,   --Veteran    (N, M0)
            3383,   --Adventurer (LFR, H)
        },

        CrestSources = {    --TODO: Midnight S1: Dawncrest
            (PLAYER_DIFFICULTY6 or "Mythic") .. ", +9",
            (PLAYER_DIFFICULTY2 or "Heroic") .. ", +4",
            (PLAYER_DIFFICULTY1 or "Normal") .. ", +2",
            (PLAYER_DIFFICULTY3 or "Raid Finder"),
            " ",
        };
    };


    addon.ItemUpgradeConstant = ItemUpgradeConstant;


    L["currency-3347"] = L["Upgrade Track 6"];
    L["currency-3345"] = L["Upgrade Track 5"];
    L["currency-3343"] = L["Upgrade Track 4"];
    L["currency-3341"] = L["Upgrade Track 3"];
    L["currency-3383"] = L["Upgrade Track 1"];
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
            250765,     --Awakened Mechanical Cache
            250766,     --Radiant Cache
            250767,     --The General's War Chest
            250768,     --The Vizier's Capital
            250769,     --The Weaver's Gratuity
            250764,     --Nanny's Surge Dividends
            244883,     --Seasoned Undermine Adventurer's Cache
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
            108,
            111,
            115,
            118,
            121,

            128,
            131,
            134,    --Tier 8 Max
            134,
            134,

            134,
        },
    };


    addon.WeeklyRewardsConstant = WeeklyRewardsConstant;


    function API.GetDelvesGreatVaultItemLevel(tier)
        return WeeklyRewardsConstant.DelvesGreatVaultItemLevel[tier]
    end
end
