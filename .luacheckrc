max_line_length = false

exclude_files = {
	"Modules/DevTool.lua",
	"Modules/DevTool_HyperlinkEditor.lua",
	"Modules/MerchantUI",
};

ignore = {
	-- Ignore global writes/accesses/mutations on anything prefixed with
	"11./^Plumber_",
	"11./^PlumberFont_",

	-- Ignore unused self. This would popup for Mixins and Objects
	"212/self",

	-- Ignore empty if branch
	"542",

	"PlumberSuperTrackingMixin",

};

globals = {
	-- Globals
	"PlumberGlobals",
	"PlumberDB",
	"PlumberDevData",
	"PlumberStorage",
	"PlumberDB_PC",

	"PlumberLootUIFont",

	"PlumberAPI_AddQuickSlotController",
	"PlumberEquipmentFlyoutItemButtonMixin",
	"PlumberDreamseedMapPinMixin",
	"PlumberWorldMapPinMixin",
	"PlumberExpansionLandingPage",

	"NarciPaperDollWidgetController",
	"Narci_Attribute",
	"NarciPaperDollWidgetController",
};

read_globals = {
	"DialogueUIAPI",

	"BetterWardrobeCollectionFrame",
	"EditModeManagerExpandedFrame",		--EditModeExpanded
	"EditModeExpandedWarningFrame",
	"LeaPlusDB",
	"LibStub",
	"ElvUI",
	"CSPilvl",				--Chonky Character Sheet
	"GwDressingRoom",		--GW2 UI
	"GwDressingRoomGear",
	"ConsolePort",
	"MerchantFrameCoverTab",
	"TomTom",
	"TomTomCrazyArrow",
	"ImmersionFrame",
	"Storyline_DialogChoicesScrollFrame",

	"Bagnon",
	"BagnonInventory1",
	"BagnonContainerItem1",
	"AdiBagsContainer1",
	"AdiBagsBagAnchor1",
	"ARKINV_Frame1",
	"ElvUI_ContainerFrame",
	"NDui_BackpackBag",
	"LiteBagBackpack",
	"Baganator",
	"BetterBagsBagBackpack",
};

std = "lua51+wow";

stds.wow = {
	-- Globals that we mutate.
	globals = {
		"BossBanner",
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

		C_AccountStore = {
			fields = {
				"GetCategoryItems",
				"GetCategories",
				"GetCategoryInfo",
				"GetCurrencyIDForStore",
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

		C_AreaPoiInfo = {
			fields = {
				"GetAreaPOIForMap",
				"GetAreaPOIInfo",
				"GetDelvesForMap",
				"GetEventsForMap",
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
				"SendChatMessage",
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

		C_DelvesUI = {
			fields = {
				"GetCurrentDelvesSeasonNumber",
				"GetDelvesFactionForSeason",
				"HasActiveDelve",
			},
		},

		C_DyeColor = {
			fields = {
				"GetDyeColorInfo",
				"GetAllDyeColors",
			},
		},

		C_EncounterJournal = {
			fields = {
				"GetDungeonEntrancesForMap",
				"GetInstanceForGameMap",
				"GetLootInfoByIndex",
				"SetSlotFilter",
				"InitalizeSelectedTier",
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

		C_Housing = {
			fields = {
				"IsInsideHouseOrPlot",
				"IsOnNeighborhoodMap",
				"GetCurrentHouseLevelFavor",
				"GetHouseLevelFavorForLevel",
				"GetPlayerOwnedHouses",
				"GetVisitCooldownInfo",
				"GetUIMapIDForNeighborhood",
			},
		},

		C_HousingBasicMode = {
			fields = {
				"IsDecorSelected",
				"StartPlacingNewDecor",
			},
		},

		C_HousingCatalog = {
			fields = {
				"GetCatalogEntryInfoByRecordID",
				"CreateCatalogSearcher",
				"GetCatalogEntryInfo",
			},
		},

		C_HousingCustomizeMode = {
			fields = {
				"ApplyDyeToSelectedDecor",
				"CancelActiveEditing",
				"CommitDyesForSelectedDecor",
				"IsDecorSelected",
				"IsHoveringDecor",
				"GetHoveredDecorInfo",
				"GetSelectedDecorInfo",
			},
		},

		C_HousingDecor = {
			fields = {
				"GetDecorName",
				"GetHoveredDecorInfo",
				"IsHoveringDecor",
				"GetSpentPlacementBudget",
				"GetMaxPlacementBudget",
				"HasMaxPlacementBudget",
			},
		},

		C_Item = {
			fields = {
				"DoesItemExist",
				"DoesItemExistByID",
				"GetDetailedItemLevelInfo",
				"GetItemClassInfo",
				"GetItemCreationContext",
				"GetItemCooldown",
				"GetItemCount",
				"GetItemIcon",
				"GetItemIconByID",
				"GetItemInfo",
				"GetItemInfoInstant",
				"GetItemLearnTransmogSet",
				"GetItemLink",
				"GetItemLinkByGUID",
				"GetItemMaxStackSizeByID",
				"GetItemNameByID",
				"GetItemQuality",
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

		C_MajorFactions = {
			fields = {
				"HasMaximumRenown",
				"IsMajorFactionHiddenFromExpansionPage",
				"GetMajorFactionIDs",
				"GetMajorFactionRenownInfo",
				"GetMajorFactionData",
				"GetRenownLevels",
				"GetCurrentRenownLevel",
				"GetRenownRewardsForLevel",
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
				"GetMapGroupID",
				"GetMapInfoAtPosition",
				"GetMapWorldSize",
				"GetPlayerMapPosition",
				"GetUserWaypoint",
				"GetUserWaypointPositionForMap",
				"OpenWorldMap",
				"SetUserWaypoint",
			},
		},

		C_MerchantFrame = {
			fields = {
				"GetItemInfo",
			},
		},

		C_Minimap = {
			fields = {
				"IsInsideQuestBlob",
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
				"GetFrame",
			},
		},

		C_PaperDollInfo = {
			fields = {
				"CanCursorCanGoInSlot",
			},
		},

		C_PartyInfo = {
			fields = {
				"IsPartyWalkIn",
				"IsCrossFactionParty",
				"IsDelveInProgress",
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

		C_ProfSpecs = {
			fields = {
				"GetSpecTabIDsForSkillLine",
				"GetConfigIDForSkillLine",
				"GetTabInfo",
				"GetSpendCurrencyForPath",
				"GetUnlockEntryForPath",
			},
		},

		C_PvP = {
			fields = {
				"IsActiveBattlefield",
			},
		},

		C_QuestInfoSystem = {
			fields = {
				"GetQuestClassification",
				"GetQuestRewardSpellInfo",
				"GetQuestRewardSpells",
				"HasQuestRewardCurrencies",
				"HasQuestRewardSpells",
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
				"GetQuestIDForQuestWatchIndex",
				"GetQuestRewardCurrencies",
			},
		},

		C_QuestOffer = {
			fields = {
				"GetQuestRewardCurrencyInfo",
			},
		},

		C_RaidLocks = {
			fields = {
				"IsEncounterComplete",
			},
		},

		C_Reputation = {
			fields = {
				"GetFactionDataByID",
				"IsMajorFaction",
				"IsAccountWideReputation",
				"IsFactionParagon",
				"SetWatchedFactionByID",
				"RequestFactionParagonPreloadRewardData",
				"GetFactionParagonInfo",
				"GetWatchedFactionData",
				"IsFactionParagonForCurrentPlayer",
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

		C_Scenario = {
			fields = {
				"GetStepInfo",
			},
		},

		C_ScenarioInfo = {
			fields = {
				"GetScenarioInfo",
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
				"SetSuperTrackedQuestID",
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
				"GetQuestZoneID",
				"IsActive",
			},
		},

		C_Timer = {
			fields = {
				"After",
			},
		},

		C_TradeSkillUI = {
			fields = {
				"CloseTradeSkill",
				"GetAllProfessionTradeSkillLines",
				"GetBaseProfessionInfo",
				"GetChildProfessionInfo",
				"GetFilteredRecipeIDs",
				"GetProfessionInfoBySkillLineID",
				"GetRecipeItemNameFilter",
				"GetRecipeOutputItemData",
				"GetRecipeSchematic",
				"GetRecipeInfo",
				"GetItemCraftedQualityByItemInfo",
				"GetItemReagentQualityByItemInfo",
				"IsRecipeTracked",
				"OpenRecipe",
				"OpenTradeSkill",
				"SetRecipeItemNameFilter",
				"SetRecipeTracked",
				"GetItemReagentQualityInfo",
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
				"GetAllSetAppearancesByID",
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

		C_TransmogSets = {
			fields = {
				"GetAllSourceIDs",
				"GetBaseSetID",
				"GetVariantSets",
				"GetSetInfo",
				"GetSetPrimaryAppearances",
				"IsBaseSetCollected",
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

		C_VignetteInfo = {
			fields = {
				"GetHealthPercent",
				"GetVignetteInfo",
				"GetVignettes",
				"GetVignettePosition",
				"FindBestUniqueVignette",
				"",
				"",
				"",
			},
		},

		C_WeeklyRewards = {
			fields = {
				"GetExampleRewardItemHyperlinks",
				"GetNextActivitiesIncrease",
				"GetActivities",
				"HasAvailableRewards",
			},
		},

		ColorManager = {
			fields = {
				"GetFormattedStringForItemQuality",
				"GetColorDataForItemQuality",
			},
		},

		Enum = {
			fields = {
				AccountStoreItemStatus = {
					fields = {
						"Owned",
						"Refundable",
					},
				},

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
						"ScenarioHeaderDelves",
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

		MenuResponse = {
			fields = {
				"Open",
				"Refresh",
				"Close",
				"CloseAll",
			},
		},

		MenuUtil = {
			fields = {
				"CreateContextMenu",
				"GetElementText",
			},
		},

		QuestCache = {
			fields = {
				"Get",
			},
		},

		Settings = {
			fields = {
				"RegisterAddOnCategory",
				"RegisterCanvasLayoutCategory",
			},
		},

		ScrollBoxConstants = {
			fields = {
				"AlignBegin",
				"RetainScrollPosition",
			},
		},

		TooltipDataProcessor = {
			fields = {
				"AddTooltipPostCall",
			},
		},

		UnitPopupSharedUtil = {
			fields = {
				"HasLFGRestrictions",
			},
		},

		"AbbreviateLargeNumbers",
		"canaccessvalue",
		"CreateAtlasMarkup",
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
		"ChatEdit_LinkItem",
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
		"GetGameTime",
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
		"GetModifiedClick",
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
		"IsControlKeyDown",
		"GetScaledCursorPosition",
		"PlayerGetTimerunningSeasonID",
		"DressUpItemLocation",
		"DressUpLink",
		"DressUpItemTransmogInfoList",
		"DressUpVisual",
		"PickupMacro",
		"IsInventoryItemLocked",
		"PickupInventoryItem",
		"CalculateTotalNumberOfFreeBagSlots",
		"GetInventoryItemLink",
		"Vector2D_CalculateAngleBetween",
		"Vector2D_Normalize",
		"FrameDeltaLerp",
		"ClampedPercentageBetween",
		"PlayerHasToy",
		"IsIndoors",
		"RequestRaidInfo",
		"IsInGroup",
		"IsInRaid",
		"UnitIsGroupLeader",
		"IsLegacyDifficulty",
		"GetLegacyRaidDifficultyID",
		"GetDungeonDifficultyID",
		"GetRaidDifficultyID",
		"GetSavedInstanceInfo",
		"GetNumSavedInstances",
		"StaticPopup_Show",
		"GetSavedInstanceChatLink",
		"GetBattlefieldEstimatedWaitTime",
		"GetBattlefieldTimeWaited",
		"GetBattlefieldStatus",
		"GetMaxBattlefieldID",
		"GetLFGQueueStats",
		"IsQuestLogSpecialItemInRange",
		"GetQuestLogSpecialItemCooldown",
		"GetBindingKey",
		"GetBindingText",
		"ProfessionsBook_LoadUI",
		"Transmog_LoadUI",
		"GetCurrentTitle",
		"GetNumTitles",
		"IsTitleKnown",
		"GetTitleName",
		"SearchBoxTemplate_OnTextChanged",
		"GetCameraZoom",
		"UnitWidgetSet",
		"GetMerchantNumItems",
		"GetMerchantItemCostInfo",
		"GetMerchantItemCostItem",
		"GetNumBuybackItems",
		"GetBuybackItemInfo",
		"WorldMap_GetQuestTimeForTooltip",
		"GameTooltip_SetTitle",
		"GameTooltip_SetTooltipWaitingForData",
		"GameTooltip_AddColoredLine",
		"GameTooltip_AddBlankLineToTooltip",
		"GameTooltip_AddErrorLine",
		"GameTooltip_AddHighlightLine",
		"GameTooltip_AddNormalLine",
		"HaveQuestData",
		"GetFactionInfoByID",
		"GetSpellCooldown",
		"GetSpellCharges",
		"ToggleCharacter",
		"GetMaxLevelForExpansionLevel",
		"GetQuestLogIndexByID",
		"IsQuestComplete",
		"GetNumQuestLogRewards",
		"GetQuestLogRewardInfo",
		"GetQuestObjectiveInfo",
		"GetQuestProgressBarPercent",
		"GetQuestLogRewardCurrencyInfo",
		"GetQuestLogRewardHonor",
		"IsPlayerSpell",
		"GetProfessions",
		"GetProfessionInfo",
		"GetSpellBookItemInfo",
		"CastSpell",
		"UpdateContainerFrameAnchors",
		"Model_ApplyUICamera",
		"LeaveChannelByLocalID",
		"LeaveChannelByName",
		"GetNumDisplayChannels",
		"EncounterJournal_LoadUI",
		"EncounterJournal_OpenJournal",
		"EJ_ClearSearch",
		"EJ_ContentTab_Select",
		"EJ_GetCreatureInfo",
		"EJ_GetEncounterInfo",
		"EJ_GetInstanceInfo",
		"EJ_GetNumSearchResults",
		"EJ_GetSearchResult",
		"EJ_IsSearchFinished",
		"EJ_IsValidInstanceDifficulty",
		"EJ_SetSearch",
		"ShowGarrisonLandingPage",
		"GetPrimaryGarrisonFollowerType",
		"securecall",
		"MacroFrame_LoadUI",


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
		"GameTooltipText",
		"MovieSubtitleFont",
		"QuestFont",

		-- Global Frames
		"AccountStoreFrame",
		"AddonCompartmentFrame",
		"AlertFrame",
		"ArtifactFrame",
		"BackpackTokenFrame",
		"CharacterFrame",
		"CharacterStatsPane",
		"ChatFrame1",
		"CinematicFrame",
		"ContainerFrame1",
		"ContainerFrameCombinedBags",
		"DressUpFrame",
		"DyeSelectionPopout",
		"EditModeManagerFrame",
		"EncounterJournal",
		"EquipmentFlyoutFrame",
		"EventToastManagerFrame",
		"ExpansionLandingPageMinimapButton",
		"GarrisonLandingPage",
		"GameTooltip",
		"GossipFrame",
		"GuildInviteFrame",
		"HousingControlsFrame",
		"HousingDashboardFrame",
		"HouseEditorFrame",
		"ItemUpgradeFrame",
		"MailFrame",
		"MacroFrame",
		"MerchantFrame",
		"MerchantMoneyInset",
		"MerchantMoneyBgLeft",
		"MerchantMoneyBgMiddle",
		"MerchantMoneyBgRight",
		"MerchantExtraCurrencyInset",
		"MerchantExtraCurrencyBgLeft",
		"MerchantExtraCurrencyBgMiddle",
		"MerchantExtraCurrencyBgRight",
		"Minimap",
		"MountJournal",
		"ObjectiveTrackerFrame",
		"PaperDollFrame",
		"PaperDollItemsFrame",
		"PlayerChoiceFrame",
		"ProfessionsBookFrame",
		"ProfessionsFrame",
		"PVEFrame",
		"QuestMapFrame",
		"QueueStatusButton",
		"ShoppingTooltip1",
		"SideDressUpFrame",
		"SplashFrame",
		"SubtitlesFrame",
		"SuperTrackedFrame",
		"TalkingHeadFrame",
		"TransmogFrame",
		"TransmogAndMountDressupFrame",
		"UIErrorsFrame",
		"UIParent",
		"UISpecialFrames",
		"WardrobeTransmogFrame",
		"WardrobeCollectionFrame",
		"WhoFrame",
		"WorldFrame",
		"WorldMapFrame",


		-- Global Mixins
		"EventToastManagerFrameMixin",
		"WardrobeItemModelMixin",

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
		"IN_GAME_NAVIGATION_RANGE",
		"HOUSING_DASHBOARD_FRAMETITLE",
		"BATTLENET_BROADCAST",
		"TOKEN_MARKET_PRICE_NOT_AVAILABLE",
		"BOSS_DEAD",
		"BOSS_ALIVE",
		"PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS",
		"PLAYER_TITLE_NONE",
		"FILTER",
		"CLOSE",
		"WEEKLY_REWARDS_UNCLAIMED_TITLE",
		"BONUS_OBJECTIVE_TIME_LEFT",
		"WEEKLY_REWARDS_UNLOCK_REWARD",
		"GREAT_VAULT_REWARDS_WORLD_COMPLETED_FIRST",
		"GREAT_VAULT_REWARDS_WORLD_COMPLETED_SECOND",
		"GREAT_VAULT_REWARDS_WORLD_INCOMPLETE",
		"WEEKLY_REWARDS_CURRENT_REWARD",
		"WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL",
		"WEEKLY_REWARDS_ITEM_LEVEL_WORLD",
		"WEEKLY_REWARDS_COMPLETE_WORLD",
		"WEEKLY_REWARDS_MAXED_REWARD",
		"WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS",
		"ERR_COSMETIC_KNOWN",
		"TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN",
		"BRAWL_TOOLTIP_ENDS",
		"NO_TRANSMOG_VISUAL_ID",
		"GAME_VERSION_LABEL",
		"DELVES_GREAT_VAULT_ERR_AVAIL_AT_MAX_LEVEL",
		"DELVES_GREAT_VAULT_REQUIRES_ACTIVE_SEASON",
		"GARRISON_LANDING_PAGE_TITLE",
		"ORDER_HALL_LANDING_PAGE_TITLE",
		"GARRISON_TYPE_8_0_LANDING_PAGE_TITLE",
		"GARRISON_TYPE_9_0_LANDING_PAGE_TITLE",
		"JOURNEYS_LABEL",
		"DELVES_LABEL",
		"QUEST_REWARDS",
		"CRITERIA_COMPLETED",
		"CRITERIA_NOT_COMPLETED",
		"SAVE",
		"CANCEL",
		"QUEST_WATCH_QUEST_READY",
		"QUEST_TOOLTIP_ACTIVE",
		"UNIT_SKINNABLE_HERB",
		"ITEM_SPELL_KNOWN",
		"GUILD_NEWS_LINK_ITEM",
		"HOUSING_DECOR_STORAGE_ITEM_DESTROY",
		"HOUSING_DECOR_SELECT_INSTRUCTION",
		"CTRL_KEY_TEXT",
		"ALT_KEY_TEXT",
		"HOUSING_CONTROLS_EDITOR_BUTTON_EXIT_FMT",
		"HOUSING_CONTROLS_EDITOR_BUTTON_EXIT",
		"TIMEMANAGER_TOOLTIP_TITLE",
		"TIMEMANAGER_TOOLTIP_LOCALTIME",
		"TIMEMANAGER_TOOLTIP_REALMTIME",
		"HOUSING_DECOR_CUSTOMIZATION_DYE_NUM_OWNED",
		"HOUSING_DECOR_CUSTOMIZATION_DEFAULT_COLOR",
		"CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT",
		"CONTENT_TRACKING_TRACKABLE_TOOLTIP_PROMPT",
		"ITEM_COOLDOWN_TIME",
		"LOCKED",
		"ITEM_PROPOSED_ENCHANT",

	},
};
