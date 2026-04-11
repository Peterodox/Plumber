max_line_length = false

exclude_files = {
	"Modules/AccountStore.lua",
	"Modules/DevTool.lua",
	"Modules/DevTool_HyperlinkEditor.lua",
	"Modules/DruidModelFix.lua",
	"Modules/MerchantUI",
};

ignore = {
	-- Ignore empty if branch
	"542",

	-- Ignore global writes/accesses/mutations on anything prefixed with
	"11./^Plumber_",
	"11./^PlumberFont_",

	-- Ignore unused self. This would popup for Mixins and Objects
	"212/self",
};

globals = {
	"Narci_Attribute",
	"NarciPaperDollWidgetController",
	"PlumberAPI_AddQuickSlotController",
	"PlumberDB",
	"PlumberDB_PC",
	"PlumberDevData",
	"PlumberDreamseedMapPinMixin",
	"PlumberEquipmentFlyoutItemButtonMixin",
	"PlumberExpansionLandingPage",
	"PlumberExpansionLandingPageMixin",
	"PlumberGlobals",
	"PlumberOutfitSelectFrame",
	"PlumberLandingPageMinimapButtonMixin",
	"PlumberLootUIFont",
	"PlumberOutfitSelectOutfitEntryMixin",
	"PlumberStorage",
	"PlumberSuperTrackingMixin",
	"PlumberWorldMapPinMixin",
	"PlumberStrikethroughNumberMixin",
};

read_globals = {
	"AdiBagsContainer1",
	"AdiBagsBagAnchor1",
	"ARKINV_Frame1",
	"Baganator",
	"BagnonContainerItem1",
	"BagnonInventory1",
	"Bagnon",
	"BetterBagsBagBackpack",
	"BetterWardrobeCollectionFrame",
	"CSPilvl",
	"ConsolePort",
	"DialogueUIAPI",
	"EditModeExpandedWarningFrame",
	"EditModeManagerExpandedFrame",
	"ElvUI",
	"ElvUI_ContainerFrame",
	"GwDressingRoom",
	"GwDressingRoomGear",
	"ImmersionFrame",
	"LeaPlusDB",
	"LibStub",
	"LiteBagBackpack",
	"MacroToolkit",
	"MacroToolkitFrame",
	"MacroToolkitSave",
	"MacroToolkitText",
	"MerchantFrameCoverTab",
	"NDui_BackpackBag",
	"Storyline_DialogChoicesScrollFrame",
	"TomTom",
	"TomTomCrazyArrow",
};

std = "lua51+wow";

stds.wow = {
	-- Globals that we mutate.
	globals = {
		"BossBanner",
		"DelvesCompanionConfigurationFrame",
		"DifficultyUtil",
		"EventToastManagerFrame",
		"EventToastManagerFrameMixin",
		"GossipFrame",
		"SlashCmdList",
		"StaticPopupDialogs",
		"WardrobeItemModelMixin",
		"WardrobeItemsCollectionSlotButtonMixin",

		GameTooltip = {
			fields = {
				"factionID",
				"suppressAutomaticCompareItem",
			},
		},
	},

	-- Globals that we access.
	read_globals = {
		"AbbreviateNumbers",
		"AbbreviateLargeNumbers",
		"AccountStoreFrame",
		"AchievementFrameAchievements_ForceUpdate",
		"AddTrackedAchievement",
		"AddonCompartmentFrame",
		"AlertFrame",
		"ArtifactFrame",
		"AutoScalingFontStringMixin",
		"BackpackTokenFrame",
		"BossBanner_OnEvent",
		"BreakUpLargeNumbers",
		"CalculateTotalNumberOfFreeBagSlots",
		"canaccessvalue",
		"CastSpell",
		"CharacterFrame",
		"CharacterStatsPane",
		"ChatEdit_InsertLink",
		"ChatEdit_LinkItem",
		"ChatFrame1",
		"CinematicFrame",
		"ClampedPercentageBetween",
		"ClearAllLFGDungeons",
		"ClearCursor",
		"CloseLoot",
		"ContainerFrame1",
		"ContainerFrameCombinedBags",
		"CreateAtlasMarkup",
		"CreateColor",
		"CreateDataProvider",
		"CreateFont",
		"CreateFrame",
		"CreateFromMixins",
		"CreateKeyChordStringUsingMetaKeyState",
		"CreateMacro",
		"CreateScrollBoxListLinearView",
		"CreateVector2D",
		"CursorHasItem",
		"date",
		"DeleteMacro",
		"DelvesDashboardFrame",
		"DressUpFrame",
		"DressUpItemLocation",
		"DressUpItemTransmogInfoList",
		"DressUpLink",
		"DressUpVisual",
		"DyeSelectionPopout",
		"EditMacro",
		"EditModeManagerFrame",
		"EJ_ClearSearch",
		"EJ_ContentTab_Select",
		"EJ_GetCreatureInfo",
		"EJ_GetEncounterInfo",
		"EJ_GetEncounterInfoByIndex",
		"EJ_GetInstanceInfo",
		"EJ_GetNumLoot",
		"EJ_GetNumSearchResults",
		"EJ_GetSearchResult",
		"EJ_IsSearchFinished",
		"EJ_IsValidInstanceDifficulty",
		"EJ_SelectEncounter",
		"EJ_SelectInstance",
		"EJ_SelectTier",
		"EJ_SetDifficulty",
		"EJ_SetLootFilter",
		"EJ_SetSearch",
		"EmbeddedItemTooltip",
		"EncounterJournal",
		"EncounterJournal_LoadUI",
		"EncounterJournal_OpenJournal",
		"EquipmentFlyoutFrame",
		"EquipmentManager_GetItemInfoByLocation",
		"EquipmentManager_RunAction",
		"EquipmentManager_UnequipItemInSlot",
		"ExpansionLandingPage",
		"ExpansionLandingPageMinimapButton",
		"FindSpellOverrideByID",
		"FlashClientIcon",
		"FrameDeltaLerp",
		"FormatShortDate",
		"GameFontDisable",
		"GameFontHighlight",
		"GameFontHighlightLarge",
		"GameFontHighlightMedium",
		"GameFontHighlightSmall",
		"GameFontHighlight_NoShadow",
		"GameFontNormal",
		"GameFontNormalLarge",
		"GameFontNormalLargeOutline",
		"GameFontNormalSmall",
		"GameFontRed",
		"GameTime_GetFormattedTime",
		"GameTime_GetGameTime",
		"GameTime_GetLocalTime",
		"GameTooltip",
		"GameTooltip_AddBlankLineToTooltip",
		"GameTooltip_AddColoredLine",
		"GameTooltip_AddErrorLine",
		"GameTooltip_AddHighlightLine",
		"GameTooltip_AddInstructionLine",
		"GameTooltip_AddNormalLine",
		"GameTooltip_SetBottomText",
		"GameTooltip_SetTitle",
		"GameTooltip_SetTooltipWaitingForData",
		"GameTooltipText",
		"GarrisonLandingPage",
		"GenerateClosure",
		"GetAchievementCriteriaInfo",
		"GetAchievementCriteriaInfoByID",
		"GetAchievementInfo",
		"GetAchievementLink",
		"GetAchievementNumCriteria",
		"GetActionInfo",
		"GetActiveQuestID",
		"GetActiveTitle",
		"GetAvailableQuestInfo",
		"GetAvailableTitle",
		"GetBattlefieldEstimatedWaitTime",
		"GetBattlefieldStatus",
		"GetBattlefieldTimeWaited",
		"GetBindingKey",
		"GetBindingText",
		"GetBuildInfo",
		"GetBuybackItemInfo",
		"GetCameraZoom",
		"GetCurrentKeyBoardFocus",
		"GetCursorInfo",
		"GetCursorPosition",
		"GetDungeonDifficultyID",
		"GetFactionInfoByID",
		"GetFilteredAchievementID",
		"GetGameTime",
		"GetInstanceInfo",
		"GetInventoryItemID",
		"GetInventoryItemLink",
		"GetInventoryItemTexture",
		"GetLFGCategoryForID",
		"GetLFGDungeonInfo",
		"GetLFGMode",
		"GetLFGProposal",
		"GetLFGQueueStats",
		"GetLFGQueuedList",
		"GetLFGRandomDungeonInfo",
		"GetLFGRoleUpdate",
		"GetLegacyRaidDifficultyID",
		"GetLocale",
		"GetLootSlotInfo",
		"GetLootSlotLink",
		"GetLootSlotType",
		"GetMacroBody",
		"GetMacroIndexByName",
		"GetMacroInfo",
		"GetMaxBattlefieldID",
		"GetMaxLevelForExpansionLevel",
		"GetMerchantItemCostInfo",
		"GetMerchantItemCostItem",
		"GetMerchantItemInfo",
		"GetMerchantNumItems",
		"GetMinimapZoneText",
		"GetModifiedClick",
		"GetMoney",
		"GetMouseFoci",
		"GetNumActiveQuests",
		"GetNumAvailableQuests",
		"GetNumBuybackItems",
		"GetNumDisplayChannels",
		"GetNumFilteredAchievements",
		"GetNumGroupMembers",
		"GetNumLootItems",
		"GetNumMacros",
		"GetNumQuestLeaderBoards",
		"GetNumQuestLogRewards",
		"GetNumQuestLogRewardCurrencies",
		"GetNumRandomDungeons",
		"GetNumSavedInstances",
		"GetNumTitles",
		"GetOverrideBarSkin",
		"GetPartyLFGID",
		"GetPhysicalScreenSize",
		"GetPlayerInfoByGUID",
		"GetPlayerFacing",
		"GetPrimaryGarrisonFollowerType",
		"GetProfessionInfo",
		"GetProfessions",
		"GetQuestID",
		"GetQuestInfo",
		"GetQuestLogCompletionText",
		"GetQuestLogIndexByID",
		"GetQuestLogLeaderBoard",
		"GetQuestLogRewardCurrencyInfo",
		"GetQuestLogRewardHonor",
		"GetQuestLogRewardInfo",
		"GetQuestLogSpecialItemCooldown",
		"GetQuestObjectiveInfo",
		"GetQuestProgressBarPercent",
		"GetQuestUiMapID",
		"GetRaidDifficultyID",
		"GetRaidTargetIndex",
		"GetSavedInstanceChatLink",
		"GetSavedInstanceInfo",
		"GetScaledCursorPosition",
		"GetServerExpansionLevel",
		"GetSpellBookItemInfo",
		"GetSpellBookItemType",
		"GetSpellCharges",
		"GetSpellCooldown",
		"GetText",
		"GetTime",
		"GetTitleName",
		"GetTrackedAchievements",
		"GetCurrentTitle",
		"HandleModifiedItemClick",
		"HasOverrideActionBar",
		"HaveQuestData",
		"HideUIPanel",
		"hooksecurefunc",
		"HouseEditorFrame",
		"HousingControlsFrame",
		"HousingDashboardFrame",
		"HousingItemEarnedAlertFrameSystem",
		"HousingModelPreviewFrame",
		"InCombatLockdown",
		"IsAccountSecured",
		"IsAltKeyDown",
		"IsControlKeyDown",
		"IsCurrentTitle",
		"IsFishingLoot",
		"IsFlying",
		"IsGamePadFreelookEnabled",
		"IsIndoors",
		"IsInGroup",
		"IsInInstance",
		"IsInRaid",
		"IsInventoryItemLocked",
		"IsLegacyDifficulty",
		"IsLFGDungeonJoinable",
		"IsMacClient",
		"IsMouseButtonDown",
		"IsMouselooking",
		"IsModifiedClick",
		"IsMounted",
		"IsPlayerMoving",
		"IsPlayerSpell",
		"IsQuestComplete",
		"IsQuestLogSpecialItemInRange",
		"issecretvalue",
		"IsShiftKeyDown",
		"IsSpellKnown",
		"IsSpellKnownOrOverridesKnown",
		"IsTitleKnown",
		"ItemInteractionFrame",
		"ItemUpgradeFrame",
		"JoinSingleLFG",
		"LeaveChannelByLocalID",
		"LeaveChannelByName",
		"LFDParentFrame",
		"LFDQueueFrame_SetType",
		"LFGListPVEStub",
		"LootFrame",
		"LootSlot",
		"LootSlotHasItem",
		"MacroFrame",
		"MacroFrame_LoadUI",
		"MacroSaveButton",
		"MacroFrameText",
		"MailFrame",
		"MapCanvasDataProviderMixin",
		"MapCanvasPinMixin",
		"MajorFactionButtonUnlockedStateMixin",
		"MerchantExtraCurrencyBgLeft",
		"MerchantExtraCurrencyBgMiddle",
		"MerchantExtraCurrencyBgRight",
		"MerchantExtraCurrencyInset",
		"MerchantFrame",
		"MerchantFrame_Update",
		"MerchantMoneyBgLeft",
		"MerchantMoneyBgMiddle",
		"MerchantMoneyBgRight",
		"MerchantMoneyInset",
		"Minimap",
		"Mixin",
		"Model_ApplyUICamera",
		"MovieSubtitleFont",
		"MountJournal",
		"MountJournal_UpdateMountDisplay",
		"GetNumFilteredAchievements",
		"GuildInviteFrame",
		"ObjectiveTrackerFrame",
		"OpenAchievementFrameToAchievement",
		"PaperDollFrame",
		"PaperDollItemsFrame",
		"PaperDollTitlesPane_InitButton",
		"PickupContainerItem",
		"PickupInventoryItem",
		"PickupMacro",
		"PickupSpell",
		"PlaySound",
		"PlayerChoiceFrame",
		"PlayerGetTimerunningSeasonID",
		"PlayerHasToy",
		"ProfessionsBook_LoadUI",
		"ProfessionsBookFrame",
		"ProfessionsFrame",
		"PVEFrame",
		"PVEFrame_ShowFrame",
		"QuestFont",
		"QuestMapFrame",
		"QuestMapFrame_ShowQuestDetails",
		"QueueStatusButton",
		"RemoveTrackedAchievement",
		"ReputationEntryMixin",
		"ReputationParagonFrame_SetupParagonTooltip",
		"RequestRaidInfo",
		"ResetCursor",
		"securecall",
		"securecallfunction",
		"SearchBoxTemplate_OnTextChanged",
		"SetAchievementSearchString",
		"SetCursor",
		"SetCVar",
		"SetCurrentTitle",
		"SetDungeonDifficultyID",
		"SetItemRef",
		"SetLFGDungeon",
		"SetLegacyRaidDifficultyID",
		"SetPortraitTextureFromCreatureDisplayID",
		"SetRaidDifficultyID",
		"SetUnitCursorTexture",
		"ShoppingTooltip1",
		"ShowGarrisonLandingPage",
		"ShowUIPanel",
		"SideDressUpFrame",
		"SocialPostFrame",
		"Social_InsertLink",
		"Social_IsShown",
		"SocketInventoryItem",
		"SplashFrame",
		"SpellIsTargeting",
		"StaticPopup_Show",
		"StopSound",
		"Storyline_DialogChoicesScrollFrame",
		"strcmputf8i",
		"StripHyperlinks",
		"strlenutf8",
		"strsplit",
		"strtrim",
		"SubtitlesFrame",
		"SuperTrackedFrame",
		"TalkingHeadFrame",
		"time",
		"TopBannerManager_BannerFinished",
		"TopBannerManager_Show",
		"ToggleCharacter",
		"TransmogFrame",
		"TransmogAndMountDressupFrame",
		"Transmog_LoadUI",
		"UIErrorsFrame",
		"UIParent",
		"UISpecialFrames",
		"UnitCastingDuration",
		"UnitCastingInfo",
		"UnitChannelDuration",
		"UnitChannelInfo",
		"UnitClass",
		"UnitExists",
		"UnitFactionGroup",
		"UnitGUID",
		"UnitInParty",
		"UnitInRaid",
		"UnitIsAFK",
		"UnitIsBossMob",
		"UnitIsGameObject",
		"UnitIsGroupLeader",
		"UnitIsPlayer",
		"UnitIsUnit",
		"UnitLevel",
		"UnitName",
		"UnitPowerBarID",
		"UnitPVPName",
		"UnitPosition",
		"UnitRace",
		"UnitSex",
		"UnitWidgetSet",
		"UpdateContainerFrameAnchors",
		"Vector2D_CalculateAngleBetween",
		"Vector2D_Normalize",
		"WardrobeCollectionFrame",
		"WardrobeTransmogFrame",
		"WatchFrame_Update",
		"WeeklyRewards_ShowUI",
		"WeeklyRewardsActivityMixin",
		"WhoFrame",
		"wipe",
		"WorldFrame",
		"WorldMap_GetQuestTimeForTooltip",
		"WorldMapFrame",


		AuraUtil = {
			fields = {
				"ForEachAura",
			},
		},

		bit = {
			fields = {
				"band",
			},
		},

		ChatFrameUtil = {
			fields = {
				"GetActiveWindow",
				"InsertLink",
				"LinkItem",
				"ShowChatChannelContextMenu",
			},
		},

		CollectionWardrobeUtil = {
			fields = {
				"GetPage",
			},
		},

		ColorManager = {
			fields = {
				"GetColorDataForItemQuality",
				"GetFormattedStringForItemQuality",
			},
		},

		Constants = {
			fields = {
				AccountStoreConsts = {
					fields = {
						"PlunderstormStoreFrontID",
					},
				},

				ContentTrackingConsts = {
					fields = {
						"MaxTrackedAchievements",
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

				TransmogOutfitDataConsts = {
					fields = {
						"EQUIP_TRANSMOG_OUTFIT_MANUAL_SPELL_ID",
					},
				},
			},
		},

		ContentTrackingUtil = {
			fields = {
				"DisplayTrackingError",
				"IsContentTrackingEnabled",
				"IsTrackingModifierDown",
			},
		},

		C_AccountStore = {
			fields = {
				"GetCategoryInfo",
				"GetCategoryItems",
				"GetCategories",
				"GetCurrencyIDForStore",
				"GetCurrencyInfo",
			},
		},

		C_AddOns = {
			fields = {
				"GetAddOnInfo",
				"GetAddOnMetadata",
				"GetNumAddOns",
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
				"GetContainerItemID",
				"GetContainerItemInfo",
				"GetContainerItemQuestInfo",
				"GetContainerNumSlots",
				"GetItemCooldown",
				"PickupContainerItem",
			},
		},

		C_ContentTracking = {
			fields = {
				"GetTrackedIDs",
				"IsTracking",
				"StartTracking",
				"StopTracking",
			},
		},

		C_CovenantCallings = {
			fields = {
				"AreCallingsUnlocked",
			},
		},

		C_Covenants = {
			fields = {
				"GetActiveCovenantID",
			},
		},

		C_CreatureInfo = {
			fields = {
				"GetClassInfo",
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
				"PlayerHasMaxQuantity",
				"PlayerHasMaxWeeklyQuantity",
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
				"GetSecondsUntilDailyReset",
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
				"GetAllDyeColors",
				"GetDyeColorInfo",
			},
		},

		C_EncounterJournal = {
			fields = {
				"GetDungeonEntrancesForMap",
				"GetInstanceForGameMap",
				"GetLootInfoByIndex",
				"InitalizeSelectedTier",
				"SetSlotFilter",
			},
		},

		C_EventUtils = {
			fields = {
				"IsEventValid",
			},
		},

		C_FriendList = {
			fields = {
				"GetNumWhoResults",
				"GetWhoInfo",
				"SendWho",
				"SetWhoToUi",
			},
		},

		C_Garrison = {
			fields = {
				"GetAvailableMissions",
				"GetInProgressMissions",
				"GetLandingPageItems",
				"IsOnGarrisonMap",
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

		C_HouseEditor = {
			fields = {
				"GetActiveHouseEditorMode",
				"IsHouseEditorActive",
			},
		},

		C_Housing = {
			fields = {
				"GetCurrentHouseLevelFavor",
				"GetHouseLevelFavorForLevel",
				"GetPlayerOwnedHouses",
				"GetUIMapIDForNeighborhood",
				"GetVisitCooldownInfo",
				"IsInsideHouseOrPlot",
				"IsOnNeighborhoodMap",
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
				"CreateCatalogSearcher",
				"GetCatalogEntryInfo",
				"GetCatalogEntryInfoByRecordID",
			},
		},

		C_HousingCustomizeMode = {
			fields = {
				"ApplyDyeToSelectedDecor",
				"CancelActiveEditing",
				"CommitDyesForSelectedDecor",
				"GetHoveredDecorInfo",
				"GetSelectedDecorInfo",
				"IsDecorSelected",
				"IsHoveringDecor",
			},
		},

		C_HousingDecor = {
			fields = {
				"GetDecorName",
				"GetHoveredDecorInfo",
				"GetMaxPlacementBudget",
				"GetSpentPlacementBudget",
				"HasMaxPlacementBudget",
				"IsHoveringDecor",
			},
		},

		C_HousingNeighborhood = {
			fields = {
				"CanReturnAfterVisitingHouse",
			},
		},

		C_Item = {
			fields = {
				"DoesItemExist",
				"DoesItemExistByID",
				"GetDetailedItemLevelInfo",
				"GetItemClassInfo",
				"GetItemCooldown",
				"GetItemCount",
				"GetItemCreationContext",
				"GetItemIcon",
				"GetItemIconByID",
				"GetItemIDForItemInfo",
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
				"GetItemUpgradeInfo",
				"IsCosmeticItem",
				"IsDecorItem",
				"IsDressableItemByID",
				"IsItemConvertibleAndValidForPlayer",
				"IsItemDataCachedByID",
				"RequestLoadItemDataByID",
			},
		},

		C_ItemInteraction = {
			"ClearPendingItem",
			"SetPendingItem",
		},

		C_ItemUpgrade = {
			fields = {
				"CanUpgradeItem",
			},
		},

		C_LFGList = {
			fields = {
				"HasActiveEntryInfo",
			},
		},

		C_MajorFactions = {
			fields = {
				"GetCurrentRenownLevel",
				"GetMajorFactionData",
				"GetMajorFactionIDs",
				"GetMajorFactionRenownInfo",
				"GetRenownLevels",
				"GetRenownRewardsForLevel",
				"HasMaximumRenown",
				"IsMajorFactionHiddenFromExpansionPage",
			},
		},

		C_Map = {
			fields = {
				"ClearUserWaypoint",
				"GetAreaInfo",
				"GetBestMapForUnit",
				"GetMapGroupID",
				"GetMapGroupMembersInfo",
				"GetMapInfo",
				"GetMapInfoAtPosition",
				"GetMapPosFromWorldPos",
				"GetMapWorldSize",
				"GetPlayerMapPosition",
				"GetUserWaypoint",
				"GetUserWaypointPositionForMap",
				"GetWorldPosFromMapPos",
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

		C_MythicPlus = {
			fields = {
				"RequestMapInfo",
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
				"GetDistance",
				"GetFrame",
				"GetTargetState",
				"HasValidScreenPosition",
				"WasClampedToScreen",
			},
		},

		C_PaperDollInfo = {
			fields = {
				"CanCursorCanGoInSlot",
			},
		},

		C_PartyInfo = {
			fields = {
				"IsCrossFactionParty",
				"IsDelveInProgress",
				"IsPartyWalkIn",
			},
		},

		C_PetBattles = {
			fields = {
				"IsInBattle",
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

		C_PlayerChoice = {
			fields = {
				"GetCurrentPlayerChoiceInfo",
				"OnUIClosed",
				"SendPlayerChoiceResponse",
			},
		},

		C_PlayerInfo = {
			fields = {
				"GetAlternateFormInfo",
				"GetGlidingInfo",
				"IsExpansionLandingPageUnlockedForPlayer",
			},
		},

		C_PlayerInteractionManager = {
			fields = {
				"IsInteractingWithNpcOfType",
			},
		},

		C_ProfSpecs = {
			fields = {
				"GetConfigIDForSkillLine",
				"GetSpendCurrencyForPath",
				"GetSpecTabIDsForSkillLine",
				"GetTabInfo",
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

		C_QuestLine = {
			fields = {
				"GetAvailableQuestLines",
				"GetQuestLineInfo",
				"GetQuestLineQuests",
				"RequestQuestLinesForMap",
			},
		},

		C_QuestLog = {
			fields = {
				"GetActivePreyQuest",
				"GetLogIndexForQuestID",
				"GetNumQuestWatches",
				"GetQuestIDForQuestWatchIndex",
				"GetQuestInfo",
				"GetQuestRewardCurrencies",
				"GetQuestRewardCurrencyInfo",
				"GetTitleForQuestID",
				"IsOnQuest",
				"IsQuestFlaggedCompleted",
				"IsQuestFlaggedCompletedOnAccount",
				"IsQuestTask",
				"IsWorldQuest",
				"ReadyForTurnIn",
				"RequestLoadQuestByID",
				"UnitIsRelatedToActiveQuest",
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
				"GetFactionParagonInfo",
				"GetWatchedFactionData",
				"IsAccountWideReputation",
				"IsFactionParagon",
				"IsFactionParagonForCurrentPlayer",
				"IsMajorFaction",
				"RequestFactionParagonPreloadRewardData",
				"SetWatchedFactionByID",
			},
		},

		C_RemixArtifactUI = {
			fields = {
				"ClearRemixArtifactItem",
				"GetCurrArtifactItemID",
				"GetCurrItemSpecIndex",
				"GetCurrTraitTreeID",
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
				"FindSpellOverrideByID",
				"GetSpellBookItemType",
				"IsSpellInSpellBook",
				"IsSpellKnown",
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
				"GetQuestInfoByQuestID",
				"GetQuestLocation",
				"GetQuestZoneID",
				"GetQuestsForPlayerByMapID",
				"GetQuestsOnMap",
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
				"GetItemCraftedQualityByItemInfo",
				"GetItemReagentQualityByItemInfo",
				"GetItemReagentQualityInfo",
				"GetProfessionInfoBySkillLineID",
				"GetRecipeInfo",
				"GetRecipeItemNameFilter",
				"GetRecipeOutputItemData",
				"GetRecipeSchematic",
				"IsRecipeTracked",
				"OpenRecipe",
				"OpenTradeSkill",
				"SetRecipeItemNameFilter",
				"SetRecipeTracked",
			},
		},

		C_Traits = {
			fields = {
				"CanPurchaseRank",
				"CommitConfig",
				"ConfigHasStagedChanges",
				"GetConfigIDByTreeID",
				"GetConfigInfo",
				"GetDefinitionInfo",
				"GetEntryInfo",
				"GetIncreasedTraitData",
				"GetNodeCost",
				"GetNodeInfo",
				"GetTreeCurrencyInfo",
				"GetTreeNodes",
				"PurchaseRank",
				"ResetTree",
				"RollbackConfig",
				"SetSelection",
				"TryPurchaseToNode",
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

		C_TransmogOutfitInfo = {
			fields = {
				"ChangeToOutfit",
				"GetActiveOutfitID",
				"GetOutfitsInfo",
				"IsEquippedGearOutfitDisplayed",
				"IsLockedOutfit",
				"PickupOutfit",
			},
		},

		C_TransmogSets = {
			fields = {
				"GetAllSourceIDs",
				"GetBaseSetID",
				"GetSetInfo",
				"GetSetPrimaryAppearances",
				"GetVariantSets",
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
				"GetItemInteractionItem",
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
				"GetHorizontalCurrenciesWidgetVisualizationInfo",
				"GetItemDisplayVisualizationInfo",
				"GetScenarioHeaderDelvesWidgetVisualizationInfo",
				"GetSpacerVisualizationInfo",
				"GetSpellDisplayVisualizationInfo",
				"GetStatusBarWidgetVisualizationInfo",
				"GetTextWithStateWidgetVisualizationInfo",
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
				"FindBestUniqueVignette",
				"GetHealthPercent",
				"GetVignetteInfo",
				"GetVignettePosition",
				"GetVignettes",
			},
		},

		C_WeeklyRewards = {
			fields = {
				"GetActivities",
				"GetExampleRewardItemHyperlinks",
				"GetNextActivitiesIncrease",
				"GetSortedProgressForActivity",
				"HasAvailableRewards",
			},
		},

		C_ZoneAbility = {
			fields = {
				"GetActiveAbilities",
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

				ContentTrackingStopType = {
					fields = {
						"Manual",
					},
				},

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

				HouseEditorMode = {
					fields = {
						"BasicDecor",
						"Cleanup",
						"Customize",
						"ExpertDecor",
						"ExteriorCustomization",
						"Layout",
						"None",
					},
				},

				HousingCatalogEntryType = {
					fields = {
						"Decor",
						"Room",
					},
				},

				HousingItemToastType = {
					fields = {
						"Decor",
					},
				},

				ItemSlotFilterType = {
					fields = {
						"NoFilter",
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
						"BonusObjective",
						"Calling",
						"Campaign",
						"Important",
						"Legendary",
						"Meta",
						"Normal",
						"Questline",
						"Recurring",
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

				TooltipDataLineType = {
					fields = {
						"AzeriteEssencePower",
						"AzeriteEssenceSlot",
						"AzeriteItemPowerDescription",
						"Blank",
						"CurrencyTotal",
						"DisabledLine",
						"EquipSlot",
						"ErrorLine",
						"FlavorText",
						"GemSocket",
						"GemSocketEnchantment",
						"ItemBinding",
						"ItemEnchantmentPermanent",
						"ItemLevel",
						"ItemName",
						"ItemQuality",
						"ItemSpellTriggerLearn",
						"ItemUpgradeLevel",
						"LearnTransmogIllusion",
						"LearnTransmogSet",
						"LearnableSpell",
						"NestedBlock",
						"None",
						"ProfessionCraftingQuality",
						"QuestObjective",
						"QuestPlayer",
						"QuestTitle",
						"RuneforgeLegendaryPowerDescription",
						"SellPrice",
						"Separator",
						"SpellDescription",
						"SpellName",
						"SpellPassive",
						"TooltipDataLineType",
						"ToyDescription",
						"ToyDuration",
						"ToyEffect",
						"ToyName",
						"ToySource",
						"ToyText",
						"TradeTimeRemaining",
						"UnitName",
						"UnitOwner",
						"UnitThreat",
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

				TransmogPendingType = {
					fields = {
						"Apply",
					},
				},

				UIMapType = {
					fields = {
						"Continent",
					},
				},

				UIWidgetVisualizationType = {
					fields = {
						"Artifact",
						"Black",
						"BrightBlue",
						"Disabled",
						"Green",
						"Red",
						"ScenarioHeaderDelves",
						"White",
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
						"Artifact",
						"Black",
						"BrightBlue",
						"Disabled",
						"Green",
						"Red",
						"White",
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

		HousingFramesUtil = {
			fields = {
				"PreviewHousingDecorID",
			},
		},

		InputUtil = {
			fields = {
				"GetCursorPosition",
			},
		},

		ItemLocation = {
			fields = {
				"CreateEmpty",
				"SetEquipmentSlot",
			},
		},

		Menu = {
			fields = {
				"ModifyMenu",
			},
		},

		MenuResponse = {
			fields = {
				"Close",
				"CloseAll",
				"Open",
				"Refresh",
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

		RenownRewardUtil = {
			fields = {
				"AddRenownRewardsToTooltip",
			},
		},

		ScrollBoxConstants = {
			fields = {
				"AlignBegin",
				"AlignNearest",
				"RetainScrollPosition",
			},
		},

		ScrollUtil = {
			fields = {
				"AddResizableChildrenBehavior",
				"InitScrollBoxListWithScrollBar",
			},
		},

		Settings = {
			fields = {
				"RegisterAddOnCategory",
				"RegisterCanvasLayoutCategory",
			},
		},

		TooltipDataProcessor = {
			fields = {
				"AddTooltipPostCall",
			},
		},

		UIWidgetManager = {
			fields = {
				"GetWidgetTypeInfo",
				"registeredWidgetContainers",
			},
		},

		UnitPopupSharedUtil = {
			fields = {
				"HasLFGRestrictions",
			},
		},


		-- Global Colors
		"ACCOUNT_WIDE_FONT_COLOR",
		"ARTIFACT_GOLD_COLOR",
		"BLACK_FONT_COLOR",
		"BRIGHTBLUE_FONT_COLOR",
		"DISABLED_FONT_COLOR",
		"GREEN_FONT_COLOR",
		"HIGHLIGHT_FONT_COLOR",
		"INVALID_EQUIPMENT_COLOR",
		"ITEM_QUALITY_COLORS",
		"NORMAL_FONT_COLOR",
		"NORMAL_FONT_COLOR",
		"RAID_CLASS_COLORS",
		"RED_FONT_COLOR",
		"YELLOW_FONT_COLOR",


		-- Global Strings
		"ACCOUNT_BANK_PANEL_TITLE",
		"ACCOUNT_COMPLETED_QUEST_NOTICE",
		"ACCOUNT_STORE_NONREFUNDABLE_TOOLTIP",
		"ACHIEVEMENTFRAME_FILTER_COMPLETED",
		"ACHIEVEMENTFRAME_FILTER_INCOMPLETE",
		"ACHIEVEMENTS",
		"ACHIEVEMENT_WATCH_TOO_MANY",
		"ALL_CLASSES",
		"ALT_KEY_TEXT",
		"AUCTION_HOUSE_FILTER_UNCOLLECTED_ONLY",
		"BANK",
		"BATTLENET_BROADCAST",
		"BONUS_LOOT_TOOLTIP_TITLE",
		"BONUS_OBJECTIVE_TIME_LEFT",
		"BOSS_ALIVE",
		"BOSS_DEAD",
		"BRAWL_TOOLTIP_ENDS",
		"CALENDAR_FULLDATE_MONTH_NAMES",
		"CANCEL",
		"CANNOT_DO_THIS_WHILE_LFGLIST_LISTED",
		"CATALOG_SHOP_NO_SEARCH_RESULTS",
		"CLOSE",
		"CLUB_FINDER_SORT_BY",
		"COLLECTIONS",
		"CONTENT_TRACKING_TRACKABLE_TOOLTIP_PROMPT",
		"CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT",
		"COPPER_AMOUNT_SYMBOL",
		"CRITERIA_COMPLETED",
		"CRITERIA_NOT_COMPLETED",
		"CROSS_FACTION_RAID_DUNGEON_FINDER_ERROR",
		"CTRL_KEY_TEXT",
		"CURRENCY_TOTAL_CAP",
		"CURRENCY_WEEKLY_CAP",
		"DAYS_ABBR",
		"DELVES_GREAT_VAULT_ERR_AVAIL_AT_MAX_LEVEL",
		"DELVES_GREAT_VAULT_REQUIRES_ACTIVE_SEASON",
		"DELVES_LABEL",
		"DUNGEONS_BUTTON",
		"D_DAYS",
		"D_HOURS",
		"D_MINUTES",
		"D_SECONDS",
		"EJ_ITEM_CATEGORY_EXTREMELY_RARE",
		"EJ_ITEM_CATEGORY_VERY_RARE",
		"EMOTE",
		"ENCOUNTER_JOURNAL_DIFF_TEXT",
		"EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION",
		"ERR_ACHIEVEMENT_WATCH_COMPLETED",
		"ERR_COSMETIC_KNOWN",
		"ERR_ITEM_NOT_FOUND",
		"ERR_LFG_PROPOSAL_FAILED",
		"EXPANSION_NAME10",
		"EXPANSION_NAME11",
		"EXPANSION_NAME4",
		"FACTION_ALLIANCE",
		"FACTION_HORDE",
		"FILTER",
		"GAME_VERSION_LABEL",
		"GARRISON_LANDING_PAGE_TITLE",
		"GARRISON_TYPE_8_0_LANDING_PAGE_TITLE",
		"GARRISON_TYPE_9_0_LANDING_PAGE_TITLE",
		"GOLD_AMOUNT_SYMBOL",
		"GREAT_VAULT_REWARDS",
		"GREAT_VAULT_REWARDS_WORLD_COMPLETED_FIRST",
		"GREAT_VAULT_REWARDS_WORLD_COMPLETED_SECOND",
		"GREAT_VAULT_REWARDS_WORLD_INCOMPLETE",
		"GUILD_NEWS_LINK_ITEM",
		"HOUSING_CATALOG_CATEGORIES_ALL",
		"HOUSING_CONTROLS_EDITOR_BUTTON_EXIT",
		"HOUSING_CONTROLS_EDITOR_BUTTON_EXIT_FMT",
		"HOUSING_DASHBOARD_FRAMETITLE",
		"HOUSING_DECOR_CUSTOMIZATION_DEFAULT_COLOR",
		"HOUSING_DECOR_CUSTOMIZATION_DYE_NUM_OWNED",
		"HOUSING_DECOR_SELECT_INSTRUCTION",
		"HOUSING_DECOR_STORAGE_ITEM_DESTROY",
		"HOURS_ABBR",
		"INVSLOT_MAINHAND",
		"IN_GAME_NAVIGATION_RANGE",
		"ITEM_BNETACCOUNTBOUND",
		"ITEM_COOLDOWN_TIME",
		"ITEM_OPENABLE",
		"ITEM_PROPOSED_ENCHANT",
		"ITEM_SOULBOUND",
		"ITEM_SPELL_KNOWN",
		"ITEM_UNIQUE_MULTIPLE",
		"JOURNEYS_LABEL",
		"LANDING_PAGE_RENOWN_LABEL",
		"LE_LFG_CATEGORY_RF",
		"LFG_LIST_DIFFICULTY",
		"LOCKED",
		"LOOT_NOUN",
		"MAJOR_FACTION_BUTTON_RENOWN_LEVEL",
		"MAJOR_FACTION_LIST_TITLE",
		"MAJOR_FACTION_MAX_RENOWN_REACHED",
		"MAP_PIN_HYPERLINK",
		"MAX_ACCOUNT_MACROS",
		"MAX_CHARACTER_MACROS",
		"MINUTES_ABBR",
		"MISCELLANEOUS",
		"NO",
		"NONE",
		"NOT_BOUND",
		"NO_TRANSMOG_VISUAL_ID",
		"OBJECTIVES_STOP_TRACKING",
		"OBJECTIVES_VIEW_ACHIEVEMENT",
		"ORBIT_CAMERA_MOUSE_MODE_PITCH_ROTATION",
		"ORDER_HALL_LANDING_PAGE_TITLE",
		"PARAGON_REPUTATION_TOOLTIP_TEXT",
		"PARAGON_REPUTATION_TOOLTIP_TEXT_LOW_LEVEL",
		"PLAYER_DIFFICULTY1",
		"PLAYER_DIFFICULTY2",
		"PLAYER_DIFFICULTY3",
		"PLAYER_DIFFICULTY6",
		"PLAYER_TITLE_NONE",
		"PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS",
		"PVP_WEEKLY_REWARD",
		"QUEST_COMPLETE",
		"QUEST_PROGRESS_TOOLTIP_QUEST_READY_FOR_TURN_IN",
		"QUEST_REWARDS",
		"QUEST_TOOLTIP_ACTIVE",
		"QUEST_TOOLTIP_REQUIREMENTS",
		"QUEST_WATCH_QUEST_READY",
		"RAID",
		"REAGENT_BANK",
		"RENOWN_REWARD_ACCOUNT_UNLOCK_LABEL",
		"REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL",
		"RETRIEVING_DATA",
		"SAVE",
		"SEARCH",
		"SECONDS_ABBR",
		"SELL_PRICE",
		"SETTINGS",
		"SHOW_MAP",
		"SILVER_AMOUNT_SYMBOL",
		"SOUNDKIT",
		"SOURCES",
		"SPEC_ACTIVE",
		"SUMMON_RANDOM_PET",
		"SWITCH",
		"TALENT_BUTTON_TOOLTIP_NEXT_RANK",
		"TALENT_BUTTON_TOOLTIP_RANK_FORMAT",
		"TALENT_SPEC_ACTIVATE",
		"TEMPSCENE",
		"TIMEMANAGER_TOOLTIP_LOCALTIME",
		"TIMEMANAGER_TOOLTIP_REALMTIME",
		"TIMEMANAGER_TOOLTIP_TITLE",
		"TOKEN_MARKET_PRICE_NOT_AVAILABLE",
		"TOOLTIP_UNIT_LEVEL",
		"TRACK_ACHIEVEMENT",
		"TRANSMOGRIFY",
		"TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN",
		"TRANSMOG_OUTFIT_COPY_TO_CLIPBOARD_NOTICE",
		"TRANSMOG_SHOW_EQUIPPED_GEAR",
		"TYPE",
		"UNKNOWN",
		"UNIT_SKINNABLE_HERB",
		"UNIT_YOU",
		"WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS",
		"WEEKLY_REWARDS_COMPLETE_WORLD",
		"WEEKLY_REWARDS_CURRENT_REWARD",
		"WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL",
		"WEEKLY_REWARDS_ITEM_LEVEL_WORLD",
		"WEEKLY_REWARDS_MAXED_REWARD",
		"WEEKLY_REWARDS_MYTHIC_TOP_RUNS",
		"WEEKLY_REWARDS_UNCLAIMED_TEXT",
		"WEEKLY_REWARDS_UNCLAIMED_TITLE",
		"WEEKLY_REWARDS_UNLOCK_REWARD",
		"YES",
	},
};
