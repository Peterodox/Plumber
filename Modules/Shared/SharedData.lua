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
			233,
			237,
			240,
			243,
			246,

			253,
			256,
			259,    --Tier 8 Max
			259,
			259,

			259,
		},
	};


	addon.WeeklyRewardsConstant = WeeklyRewardsConstant;


	function API.GetDelvesGreatVaultItemLevel(tier)
		return WeeklyRewardsConstant.DelvesGreatVaultItemLevel[tier]
	end
end


do	--Prey System
--[[
do	--Debug Output
	function GenerateQuestXAchievement()
		local difficultyKeys = {"Normal", "Hard", "Nightmare"};
		local GetQuestName = addon.API.GetQuestName;
		local allNameCached = true;
		local numQuests = 0;

		for i, k in ipairs(difficultyKeys) do
			for _, questID in ipairs(addon.PreyTargetQuests[k]) do
				numQuests = numQuests + 1;
				if not GetQuestName(questID) then
					allNameCached = false;
				end
			end
		end

		if not allNameCached then
			print("Quest Name Pending...");
			return
		end

		local DifficultyCriteria = {};

		for i, achievementID in ipairs(PreyTargetListAchivements) do
			local numCriteria = GetAchievementNumCriteria(achievementID);
			print(difficultyKeys[i], numCriteria);
			for index = 1, numCriteria do
				local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID = GetAchievementCriteriaInfo(achievementID, index);
				if not DifficultyCriteria[i] then
					DifficultyCriteria[i] = {};
				end
				DifficultyCriteria[i][criteriaID] = criteriaString;
			end
		end

		local tbl = {};
		local numMatch = 0;

		for i, k in ipairs(difficultyKeys) do
			for _, questID in ipairs(addon.PreyTargetQuests[k]) do
				local questName = GetQuestName(questID);
				local matchFound = false;
				questName = questName:gsub("Jan\'alai", "Janali");	--Quest Name, Criteria Mismatch

				for criteriaID, criteriaString in pairs(DifficultyCriteria[i]) do
					if string.find(questName, criteriaString, 1, true) then
						numMatch = numMatch + 1;
						matchFound = true;
						tbl[questID] = {i, criteriaID};
						break;
					end
				end

				if not matchFound then
					print("Missing: ", questName);
				end
			end
		end

		print(string.format("Match: %s/%s", numMatch, numQuests));

		if not PlumberDevData then
			PlumberDevData = {};
		end

		PlumberDevData.PreyQuestData = tbl;
	end
end
--]]

addon.PreyQuestData = {	--[questID] = {difficulty, criteriaID};
[91098] = {
1,
105915,
},
[91106] = {
1,
105923,
},
[91114] = {
1,
105931,
},
[91249] = {
2,
105965,
},
[91257] = {
3,
105989,
},
[91265] = {
3,
105997,
},
[91210] = {
2,
105942,
},
[91218] = {
2,
105946,
},
[91226] = {
2,
105950,
},
[91107] = {
1,
105924,
},
[91242] = {
2,
105958,
},
[91250] = {
2,
105966,
},
[91258] = {
3,
105990,
},
[91266] = {
3,
105998,
},
[91211] = {
3,
105972,
},
[91219] = {
3,
105976,
},
[91100] = {
1,
105917,
},
[91108] = {
1,
105925,
},
[91243] = {
2,
105959,
},
[91251] = {
2,
105967,
},
[91259] = {
3,
105991,
},
[91267] = {
3,
105999,
},
[91212] = {
2,
105943,
},
[91220] = {
2,
105947,
},
[91228] = {
2,
105951,
},
[91109] = {
1,
105926,
},
[91117] = {
1,
105934,
},
[91252] = {
2,
105968,
},
[91260] = {
3,
105992,
},
[91268] = {
3,
106000,
},
[91213] = {
3,
105973,
},
[91221] = {
3,
105977,
},
[91102] = {
1,
105919,
},
[91110] = {
1,
105927,
},
[91118] = {
1,
105935,
},
[91253] = {
2,
105969,
},
[91261] = {
3,
105993,
},
[91269] = {
3,
106001,
},
[91103] = {
1,
105920,
},
[91225] = {
3,
105979,
},
[91214] = {
2,
105944,
},
[91222] = {
2,
105948,
},
[91230] = {
2,
105952,
},
[91111] = {
1,
105928,
},
[91119] = {
1,
105936,
},
[91254] = {
2,
105970,
},
[91262] = {
3,
105994,
},
[91099] = {
1,
105916,
},
[91241] = {
3,
105987,
},
[91239] = {
3,
105986,
},
[91237] = {
3,
105985,
},
[91235] = {
3,
105984,
},
[91233] = {
3,
105983,
},
[91231] = {
3,
105982,
},
[91229] = {
3,
105981,
},
[91227] = {
3,
105980,
},
[91215] = {
3,
105974,
},
[91096] = {
1,
105913,
},
[91104] = {
1,
105921,
},
[91112] = {
1,
105929,
},
[91120] = {
1,
105937,
},
[91255] = {
2,
105971,
},
[91263] = {
3,
105995,
},
[91223] = {
3,
105978,
},
[91122] = {
1,
105939,
},
[91234] = {
2,
105954,
},
[91238] = {
2,
105956,
},
[91246] = {
2,
105962,
},
[91240] = {
2,
105957,
},
[91232] = {
2,
105953,
},
[91097] = {
1,
105914,
},
[91095] = {
1,
105912,
},
[91216] = {
2,
105945,
},
[91224] = {
2,
105949,
},
[91105] = {
1,
105922,
},
[91113] = {
1,
105930,
},
[91121] = {
1,
105938,
},
[91256] = {
3,
105988,
},
[91264] = {
3,
105996,
},
[91115] = {
1,
105932,
},
[91123] = {
1,
105940,
},
[91248] = {
2,
105964,
},
[91247] = {
2,
105963,
},
[91116] = {
1,
105933,
},
[91124] = {
1,
105941,
},
[91245] = {
2,
105961,
},
[91244] = {
2,
105960,
},
[91236] = {
2,
105955,
},
[91217] = {
3,
105975,
},
[91101] = {
1,
105918,
},
};
end
