max_line_length = false

exclude_files = {
	"Modules/DevTool.lua",
	"Modules/DevTool_HyperlinkEditor.lua",
};

ignore = {
	-- Ignore global writes/accesses/mutations on anything prefixed with
	-- "Plumber_". This is the standard prefix for all of our global frame names
	-- and mixins.
	"11./^Plumber_",
	"11./^PlumberFont_",

	-- Ignore unused self. This would popup for Mixins and Objects
	"212/self",
};

globals = {
	-- Globals
	"PlumberGlobals",
	"PlumberDB",
	"PlumberDevData",
	"PlumberStorage",
	"PlumberDB_PC",
};

read_globals = {

};

std = "lua51+wow";

stds.wow = {
	-- Globals that we mutate.
	globals = {
		"SlashCmdList",
		"StaticPopupDialogs",
	},

	-- Globals that we access.
	read_globals = {
		-- Lua function aliases and extensions

		-- string = {
		-- 	fields = {

		-- 	},
		-- },

		"date",
		"strlenutf8",
		"time",

		-- Global Functions

		ChatFrameUtil = {
			fields = {
				"GetActiveWindow",
				"InsertLink",
				"LinkItem",
				"ShowChatChannelContextMenu",
			},
		},

		Constants = {
			fields = {
				AccountStoreConsts = {
					fields = {
						"PlunderstormStoreFrontID",
					},
				},

				CurrencyConsts = {
					fields = {
						"CLASSIC_HONOR_CURRENCY_ID",
						"CONQUEST_POINTS_CURRENCY_ID",
					},
				},

				HousingCatalogConsts = {
					fields = {
						"HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT",
					},
				},
			},
		},

		C_AddOns = {
			fields = {
				"GetNumAddOns",
				"GetAddOnInfo",
				"GetAddOnMetadata",
				"IsAddOnLoaded",
				"LoadAddOn",
			},
		},

		C_Calendar = {
			fields = {
				"GetHolidayInfo",
				"GetNumDayEvents",
				"OpenCalendar",
				"SetAbsMonth",
			},
		},

		C_ChatInfo = {
			fields = {
				"GetChannelInfoFromIdentifier",
				"GetGeneralChannelID",
			},
		},

		C_Container = {
			fields = {
				"GetContainerItemQuestInfo",
				"GetContainerItemID",
				"GetContainerItemInfo",
				"GetContainerNumSlots",
			},
		},

		C_CurrencyInfo = {
			fields = {
				"GetCurrencyContainerInfo",
				"GetCurrencyIDFromLink",
				"GetCurrencyInfo",
				"GetCurrencyInfoFromLink",
				"GetCurrencyLink",
				"GetFactionGrantedByCurrency",
			},
		},

		C_CVar = {
			fields = {
				"GetCVar",
				"GetCVarBool",
				"SetCVar",
				"SetCVarBitfield",
			},
		},

		C_DateAndTime = {
			fields = {
				"GetCurrentCalendarTime",
				"GetSecondsUntilWeeklyReset",
				"GetWeeklyResetStartTime",
			},
		},

		C_EventUtils = {
			fields = {
				"IsEventValid",
			},
		},

		C_GossipInfo = {
			fields = {
				"GetActiveQuests",
				"GetAvailableQuests",
				"GetFriendshipReputation",
				"GetFriendshipReputationRanks",
				"GetOptions",
				"SelectOption",
			},
		},

		C_Item = {
			fields = {
				"DoesItemExistByID",
				"GetDetailedItemLevelInfo",
				"GetItemCooldown",
				"GetItemCount",
				"GetItemIconByID",
				"GetItemInfo",
				"GetItemInfoInstant",
				"GetItemLearnTransmogSet",
				"GetItemLinkByGUID",
				"GetItemMaxStackSizeByID",
				"GetItemNameByID",
				"GetItemQualityByID",
				"GetItemQualityColor",
				"GetItemSpell",
				"GetItemSubClassInfo",
				"IsCosmeticItem",
				"IsDecorItem",
				"IsDressableItemByID",
				"IsItemDataCachedByID",
				"RequestLoadItemDataByID",
			},
		},

		C_ItemUpgrade = {
			fields = {
				"CanUpgradeItem",
			},
		},

		C_Map = {
			fields = {
				"ClearUserWaypoint",
				"GetAreaInfo",
				"GetBestMapForUnit",
				"GetMapGroupMembersInfo",
				"GetMapInfo",
				"GetMapPosFromWorldPos",
				"GetPlayerMapPosition",
				"GetUserWaypointPositionForMap",
				"OpenWorldMap",
				"SetUserWaypoint",
			},
		},

		C_MountJournal = {
			fields = {
				"GetMountFromItem",
				"GetMountFromSpell",
				"GetMountInfoByID",
				"GetMountInfoExtraByID",
				"SummonByID",
			},
		},

		C_NamePlate = {
			fields = {
				"GetNamePlateForUnit",
				"GetNamePlates",
			},
		},

		C_PetJournal = {
			fields = {
				"FindPetIDByName",
				"GetNumCollectedInfo",
				"GetPetInfoByIndex",
				"GetPetInfoByItemID",
				"GetPetInfoByPetID",
				"GetPetInfoBySpeciesID",
				"GetSummonedPetGUID",
			},
		},

		C_PlayerInfo = {
			fields = {
				"GetAlternateFormInfo",
				"GetGlidingInfo",
				"IsExpansionLandingPageUnlockedForPlayer",
			},
		},

		C_PvP = {
			fields = {
				"IsActiveBattlefield",
			},
		},

		C_QuestOffer = {
			fields = {
				"GetQuestRewardCurrencyInfo",
			},
		},

		C_Spell = {
			fields = {
				"DoesSpellExist",
				"GetSpellCharges",
				"GetSpellCooldown",
				"GetSpellCooldownDuration",
				"GetSpellInfo",
				"GetSpellLink",
				"GetSpellName",
				"GetSpellTexture",
				"IsSpellDataCached",
				"RequestLoadSpellData",
			},
		},

		C_SpellBook = {
			fields = {
				"GetSpellBookItemType",
				"IsSpellKnown",
				"IsSpellInSpellBook",
			},
		},

		C_StringUtil = {
			fields = {
				"StripHyperlinks",
			},
		},

		C_SuperTrack = {
			fields = {
				"GetHighestPrioritySuperTrackingType",
				"GetSuperTrackedMapPin",
				"GetSuperTrackedQuestID",
				"IsSuperTrackingAnything",
				"SetSuperTrackedUserWaypoint",
			},
		},

		C_TaskQuest = {
			fields = {
				"GetQuestsForPlayerByMapID",
				"GetQuestInfoByQuestID",
				"GetQuestLocation",
				"GetQuestsOnMap",
				"IsActive",
			},
		},

		C_Timer = {
			fields = {
				"After",
			},
		},

		C_Transmog = {
			fields = {
				"SetPending",
			},
		},

		C_TransmogCollection = {
			fields = {
				"GetAllAppearanceSources",
				"GetAppearanceSourceInfo",
				"GetAppearanceSources",
				"GetCategoryInfo",
				"GetItemInfo",
				"GetSourceInfo",
				"GetSourceItemID",
				"GetValidAppearanceSourcesForClass",
				"IsSearchInProgress",
				"PlayerHasTransmogItemModifiedAppearance",
			},
		},

		C_TooltipInfo = {
			fields = {
				"GetBagItem",
				"GetCurrencyByID",
				"GetHyperlink",
				"GetInventoryItem",
				"GetItemByGUID",
				"GetItemByID",
				"GetMerchantItem",
				"GetQuestCurrency",
				"GetQuestItem",
				"GetSpellByID",
				"GetTradeTargetItem",
				"GetTraitEntry",
				"GetUnit",
				"GetUnitBuffByAuraInstanceID",
				"GetWorldCursor",

			},
		},

		C_ToyBox = {
			fields = {
				"GetToyInfo",
				"IsToyUsable",
			},
		},

		C_UnitAuras = {
			fields = {
				"GetAuraDataByAuraInstanceID",
				"GetAuraDataByIndex",
				"GetBuffDataByIndex",
				"GetUnitAuraBySpellID",
			},
		},

		Enum = {
			fields = {
				ContentTrackingType = {
					fields = {
						"Achievement",
						"Decor",
					},
				},

				GarrisonType = {
					fields = {
						"Type_6_0_Garrison",
						"Type_7_0_Garrison",
						"Type_8_0_Garrison",
						"Type_9_0_Garrison",
					},
				},

				HousingCatalogEntryType = {
					fields = {
						"Decor",
						"Room",
					},
				},

				HouseEditorMode = {
					fields = {
						"None",
						"BasicDecor",
						"ExpertDecor",
						"Layout",
						"Customize",
						"Cleanup",
						"ExteriorCustomization",
					},
				},

				HousingItemToastType = {
					fields = {
						"Decor",
					},
				},

				NavigationState = {
					fields = {
						"Disabled",
						"InRange",
						"Invalid",
						"Occluded",
					},
				},

				PlayerInteractionType = {
					fields = {
						"Gossip",
						"ItemUpgrade",
						"Merchant",
						"QuestGiver",
					},
				},

				PingTextureType = {
					fields = {
						"Center",
						"Expand",
						"Rotation",
					},
				},

				QuestClassification = {
					fields = {
						"Important",
						"Legendary",
						"Campaign",
						"Calling",
						"Meta",
						"Recurring",
						"Questline",
						"Normal",
						"BonusObjective",
						"Threat",
						"WorldQuest",
					},
				},

				SpellBookSpellBank = {
					fields = {
						"Pet",
						"Player",
					},
				},

				TransmogPendingType = {
					fields = {
						"Apply",
					},
				},

				TooltipDataLineType = {
					fields = {
						"None",
						"Blank",
						"UnitName",
						"GemSocket",
						"AzeriteEssenceSlot",
						"AzeriteEssencePower",
						"LearnableSpell",
						"UnitThreat",
						"QuestObjective",
						"AzeriteItemPowerDescription",
						"RuneforgeLegendaryPowerDescription",
						"SellPrice",
						"ProfessionCraftingQuality",
						"SpellName",
						"CurrencyTotal",
						"ItemEnchantmentPermanent",
						"UnitOwner",
						"QuestTitle",
						"QuestPlayer",
						"NestedBlock",
						"ItemBinding",
						"EquipSlot",
						"ItemName",
						"Separator",
						"ToyName",
						"ToyText",
						"ToyEffect",
						"ToyDuration",
						"ToyDescription",
						"ToySource",
						"GemSocketEnchantment",
						"ItemLevel",
						"ItemUpgradeLevel",
						"SpellPassive",
						"SpellDescription",
						"ItemQuality",
						"TradeTimeRemaining",
						"FlavorText",
						"ItemSpellTriggerLearn",
						"LearnTransmogSet",
						"LearnTransmogIllusion",
						"ErrorLine",
						"DisabledLine",
						"UsageRequirement",
					},
				},

				TooltipDataType = {
					fields = {
						"Currency",
						"Item",
						"Macro",
						"MinimapMouseover",
						"Object",
						"Spell",
						"Unit",
					},
				},

				UIMapType = {
					fields = {
						"Continent",
					},
				},

				UIWidgetVisualizationType = {
					fields = {
						"Disabled",
						"Red",
						"White",
						"Green",
						"Artifact",
						"Black",
						"BrightBlue",
					},
				},

				WeeklyRewardChestThresholdType = {
					fields = {
						"Activities",
						"Raid",
						"World",
					},
				},

				WidgetEnabledState = {
					fields = {
						"Disabled",
					},
				},
			},
		},

		EventRegistry = {
			fields = {
				"RegisterCallback",
				"TriggerEvent",
				"UnregisterCallback",
			},
		},

		EventUtil = {
			fields = {
				"ContinueOnAddOnLoaded",
				"ContinueOnPlayerLogin",
			},
		},

		Menu = {
			fields = {
				"ModifyMenu",
			},
		},

		MenuUtil = {
			fields = {
				"CreateContextMenu",
				"GetElementText",
			},
		},

		"AbbreviateLargeNumbers",
		"canaccessvalue",
		"CreateColor",
		"CreateDataProvider",
		"CreateFrame",
		"CreateFromMixins",
		"FlashClientIcon",
		"FormatShortDate",
		"issecretvalue",
		"Mixin",
		"ResetCursor",
		"securecallfunction",
		"SetCursor",
		"SetItemRef",
		"ShowUIPanel",
		"StripHyperlinks",
		"UnitClass",
		"UnitExists",
		"UnitFactionGroup",
		"UnitGUID",
		"UnitInParty",
		"UnitInRaid",
		"UnitIsAFK",
		"UnitIsPlayer",
		"UnitIsUnit",
		"UnitRace",
		"UnitLevel",
		"UnitName",
		"UnitPVPName",
		"UnitRace",
		"GameTime_GetFormattedTime",
		"CreateVector2D",
		"UnitPosition",
		"IsInInstance",
		"GetLocale",
		"GetInstanceInfo",
		"GetPhysicalScreenSize",
		"BreakUpLargeNumbers",
		"GetCurrentKeyBoardFocus",
		"ChatEdit_InsertLink",
		"GetCursorPosition",
		"GetText",
		"IsSpellKnownOrOverridesKnown",
		"IsSpellKnown",
		"GetMouseFoci",
		"IsMacClient",
		"InCombatLockdown",
		"GetServerExpansionLevel",
		"GetBuildInfo",
		"HasOverrideActionBar",
		"GetOverrideBarSkin",
		"UnitPowerBarID",
		"IsFlying",
		"IsMouselooking",
		"IsPlayerMoving",
		"hooksecurefunc",
		"GetNumGroupMembers",
		"TopBannerManager_Show",
		"BossBanner_OnEvent",


		-- Global Fonts
		"GameFontNormal",
		"GameFontNormalLarge",
		"GameFontNormalLargeOutline",
		"GameFontNormalSmall",
		"GameFontHighlight",
		"GameFontHighlightLarge",
		"GameFontHighlightMedium",
		"GameFontHighlightSmall",
		"GameFontHighlight_NoShadow",
		"GameFontDisable",
		"GameFontRed",

		-- Global Frames
		"AddonCompartmentFrame",
		"BossBanner",
		"ChatFrame1",
		"EventToastManagerFrame",
		"ExpansionLandingPageMinimapButton",
		"GossipFrame",
		"UIErrorsFrame",
		"UIParent",
		"UISpecialFrames",
		"WorldFrame",
		"WorldMapFrame",
		"SuperTrackedFrame",
		"GameTooltip",

		-- Global Mixins
		"EventToastManagerFrameMixin",

		-- Global Constants
		"ITEM_QUALITY_COLORS",
		"D_DAYS",
		"D_HOURS",
		"D_MINUTES",
		"D_SECONDS",
		"DAYS_ABBR",
		"HOURS_ABBR",
		"MINUTES_ABBR",
		"SECONDS_ABBR",
		"DAYS_ABBR",
		"CALENDAR_FULLDATE_MONTH_NAMES",
		"MISCELLANEOUS",
		"MAP_PIN_HYPERLINK",
		"ACCOUNT_STORE_NONREFUNDABLE_TOOLTIP",
		"AUCTION_HOUSE_FILTER_UNCOLLECTED_ONLY",
		"YES",
		"NO",

	},
};
