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

	-- Ignore empty if branch
	"542",
};

globals = {
	-- Globals
	"PlumberGlobals",
	"PlumberDB",
	"PlumberDevData",
	"PlumberStorage",
	"PlumberDB_PC",

	"NarciPaperDollWidgetController",
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

		C_ArtifactUI = {
			fields = {
				"GetArtifactItemID",
				"GetArtifactTier",
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
				"GetItemCooldown",
				"PickupContainerItem",
			},
		},

		C_ContentTracking = {
			fields = {
				"StartTracking",
				"StopTracking",
				"IsTracking",
				"GetTrackedIDs",
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

		C_FriendList = {
			fields = {
				"SetWhoToUi",
				"SendWho",
				"GetWhoInfo",
				"GetNumWhoResults",
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

		C_Navigation = {
			fields = {
				"WasClampedToScreen",
				"GetTargetState",
				"HasValidScreenPosition",
				"GetDistance",
				"GetDistance",
			},
		},

		C_PaperDollInfo = {
			fields = {
				"CanCursorCanGoInSlot",
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

		C_QuestLog = {
			fields = {
				"GetActivePreyQuest",
				"GetNumQuestWatches",
				"GetTitleForQuestID",
				"GetQuestInfo",
				"IsOnQuest",
				"IsQuestFlaggedCompleted",
				"IsQuestFlaggedCompletedOnAccount",
				"IsQuestTask",
				"IsWorldQuest",
				"ReadyForTurnIn",
				"RequestLoadQuestByID",
				"GetLogIndexForQuestID",
				"UnitIsRelatedToActiveQuest",
				"GetQuestRewardCurrencyInfo",
			},
		},

		C_QuestOffer = {
			fields = {
				"GetQuestRewardCurrencyInfo",
			},
		},

		C_RemixArtifactUI = {
			fields = {
				"ClearRemixArtifactItem",
				"GetCurrTraitTreeID",
				"GetCurrArtifactItemID",
				"GetCurrItemSpecIndex",
				"ItemInSlotIsRemixArtifact",
			},
		},

		C_SpecializationInfo = {
			fields = {
				"GetSpecialization",
				"GetSpecializationInfo",
			},
		},

		C_Spell = {
			fields = {
				"DoesSpellExist",
				"GetSpellCharges",
				"GetSpellCooldown",
				"GetSpellCooldownDuration",
				"GetSpellDescription",
				"GetSpellInfo",
				"GetSpellLink",
				"GetSpellName",
				"GetSpellTexture",
				"IsSpellDataCached",
				"PickupSpell",
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

		C_TalkingHead = {
			fields = {
				"GetCurrentLineInfo",
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

		C_Traits = {
			fields = {
				"GetTreeCurrencyInfo",
				"GetEntryInfo",
				"GetNodeInfo",
				"GetTreeNodes",
				"CanPurchaseRank",
				"GetDefinitionInfo",
				"GetConfigIDByTreeID",
				"CommitConfig",
				"GetNodeCost",
				"PurchaseRank",
				"GetConfigInfo",
				"GetIncreasedTraitData",
				"TryPurchaseToNode",
				"SetSelection",
				"ResetTree",
				"ConfigHasStagedChanges",
				"RollbackConfig",
			},
		},

		C_Transmog = {
			fields = {
				"IsAtTransmogNPC",
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
				"GetMerchantCostItem",
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

		C_UIWidgetManager = {
			fields = {
				"GetAllWidgetsBySetID",
				"GetStatusBarWidgetVisualizationInfo",
				"GetTextWithStateWidgetVisualizationInfo",
				"GetHorizontalCurrenciesWidgetVisualizationInfo",
				"GetSpacerVisualizationInfo",
				"GetItemDisplayVisualizationInfo",
				"GetSpellDisplayVisualizationInfo",
				"GetScenarioHeaderDelvesWidgetVisualizationInfo",
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

				ContentTrackingStopType = {
					fields = {
						"Manual",
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
						"Red",
						"White",
						"Green",
						"Artifact",
						"Black",
						"BrightBlue",
					},
				},

				WidgetShownState = {
					fields = {
						"Hidden",
						"Shown",
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
		"HideUIPanel",
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
		"UnitSex",
		"GameTime_GetFormattedTime",
		"CreateVector2D",
		"UnitPosition",
		"IsInInstance",
		"GetLocale",
		"GetInstanceInfo",
		"GetPhysicalScreenSize",
		"BreakUpLargeNumbers",
		"AbbreviateNumbers",
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
		"TopBannerManager_BannerFinished",
		"BossBanner_OnEvent",
		"GetCursorInfo",
		"PlaySound",
		"StopSound",
		"IsGamePadFreelookEnabled",
		"EquipmentManager_GetItemInfoByLocation",
		"EquipmentManager_RunAction",
		"EquipmentManager_UnequipItemInSlot",
		"GetTime",
		"GetInventoryItemID",
		"GetInventoryItemTexture",
		"CursorHasItem",
		"ClearCursor",
		"GetMinimapZoneText",
		"GetNumQuestLeaderBoards",
		"GetQuestLogLeaderBoard",
		"GetPlayerInfoByGUID",
		"UnitIsBossMob",
		"UnitCastingInfo",
		"UnitChannelInfo",
		"IsModifiedClick",
		"GetAchievementInfo",
		"GetAchievementLink",
		"GetNumFilteredAchievements",
		"GetFilteredAchievementID",
		"SetAchievementSearchString",
		"OpenAchievementFrameToAchievement",
		"HandleModifiedItemClick",
		"MountJournal_UpdateMountDisplay",
		"AchievementFrameAchievements_ForceUpdate",
		"strtrim",
		"SetUnitCursorTexture",
		"UnitIsGameObject",
		"CreateKeyChordStringUsingMetaKeyState",
		"GetMoney",
		"IsMouseButtonDown",
		"IsShiftKeyDown",
		"IsAltKeyDown",
		"GetScaledCursorPosition",
		"PlayerGetTimerunningSeasonID",
		"DressUpItemLocation",
		"DressUpLink",
		"DressUpItemTransmogInfoList",
		"PickupMacro",
		"IsInventoryItemLocked",
		"PickupInventoryItem",
		"CalculateTotalNumberOfFreeBagSlots",
		"GetInventoryItemLink",



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
		"QuestFont",

		-- Global Frames
		"AddonCompartmentFrame",
		"ArtifactFrame",
		"BackpackTokenFrame",
		"BossBanner",
		"CharacterFrame",
		"CharacterStatsPane",
		"ChatFrame1",
		"ContainerFrame1",
		"ContainerFrameCombinedBags",
		"DressUpFrame",
		"EditModeManagerFrame",
		"EquipmentFlyoutFrame",
		"EventToastManagerFrame",
		"ExpansionLandingPageMinimapButton",
		"GameTooltip",
		"GossipFrame",
		"GuildInviteFrame",
		"MountJournal",
		"PaperDollFrame",
		"PaperDollItemsFrame",
		"HousingDashboardFrame",
		"SideDressUpFrame",
		"SuperTrackedFrame",
		"TalkingHeadFrame",
		"TransmogAndMountDressupFrame",
		"UIErrorsFrame",
		"UIParent",
		"UISpecialFrames",
		"WardrobeTransmogFrame",
		"WorldFrame",
		"WorldMapFrame",
		"WhoFrame",
		"WardrobeCollectionFrame",


		-- Global Mixins
		"EventToastManagerFrameMixin",

		-- Global Constants
		"ITEM_QUALITY_COLORS",
		"RAID_CLASS_COLORS",
		"YELLOW_FONT_COLOR",
		"HIGHLIGHT_FONT_COLOR",
		"NORMAL_FONT_COLOR",
		"RED_FONT_COLOR",
		"DISABLED_FONT_COLOR",
		"BRIGHTBLUE_FONT_COLOR",
		"GREEN_FONT_COLOR",
		"ARTIFACT_GOLD_COLOR",
		"BLACK_FONT_COLOR",
		"NORMAL_FONT_COLOR",
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
		"UNIT_YOU",
		"INVSLOT_MAINHAND",
		"RETRIEVING_DATA",
		"TALENT_BUTTON_TOOLTIP_RANK_FORMAT",
		"TALENT_SPEC_ACTIVATE",
		"EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION",
		"ERR_LFG_PROPOSAL_FAILED",
		"ACCOUNT_COMPLETED_QUEST_NOTICE",
		"TOOLTIP_UNIT_LEVEL",
		"FACTION_ALLIANCE",
		"FACTION_HORDE",
		"EMOTE",
		"SUMMON_RANDOM_PET",
		"OBJECTIVES_STOP_TRACKING",
		"TRACK_ACHIEVEMENT",
		"OBJECTIVES_VIEW_ACHIEVEMENT",
		"COLLECTIONS",
		"SOUNDKIT",
		"TRANSMOG_OUTFIT_COPY_TO_CLIPBOARD_NOTICE",
		"NOT_BOUND",
		"GOLD_AMOUNT_SYMBOL",
		"SILVER_AMOUNT_SYMBOL",
		"COPPER_AMOUNT_SYMBOL",
		"ERR_ITEM_NOT_FOUND",
		"SELL_PRICE",
		"TYPE",
		"SOURCES",
		"PLAYER_DIFFICULTY1",
		"PLAYER_DIFFICULTY2",
		"PLAYER_DIFFICULTY3",
		"PLAYER_DIFFICULTY6",
		"WEEKLY_REWARDS_MYTHIC_TOP_RUNS",
		"UNKNOWN",
		"ENCOUNTER_JOURNAL_DIFF_TEXT",
		"ALL_CLASSES",
		"ACHIEVEMENTFRAME_FILTER_COMPLETED",
		"ACHIEVEMENTFRAME_FILTER_INCOMPLETE",
		"ACCOUNT_BANK_PANEL_TITLE",
		"NONE",
		"BANK",
		"REAGENT_BANK",
		"ITEM_SOULBOUND",
		"ITEM_BNETACCOUNTBOUND",
		"ITEM_UNIQUE_MULTIPLE",
		"QUEST_PROGRESS_TOOLTIP_QUEST_READY_FOR_TURN_IN",
		"QUEST_TOOLTIP_REQUIREMENTS",
		"QUEST_COMPLETE",
		"ITEM_OPENABLE",
		"TALENT_BUTTON_TOOLTIP_NEXT_RANK",
		"SPEC_ACTIVE",


		-- Other Addons
		"Narci_Attribute",
		"NarciPaperDollWidgetController",
		"BetterWardrobeCollectionFrame",
		"EditModeManagerExpandedFrame",		--EditModeExpanded
		"EditModeExpandedWarningFrame",
		"ElvUI",
		"CSPilvl",				--Chonky Character Sheet
		"GwDressingRoom",		--GW2 UI
		"GwDressingRoomGear",
		"ConsolePort",
	},
};
