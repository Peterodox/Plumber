-- DO NOT BOTHER TO TRANSLATE
-- DO NOT BOTHER TO TRANSLATE
-- DO NOT BOTHER TO TRANSLATE


local _, addon = ...
local L = addon.L;
local changelogs = addon.ControlCenter.changelogs;


changelogs[10900] = {
	{
		type = "date",
		versionText = "1.9.0 b",
		timestamp = 1774600000,
	},

	{
		type = "h1",
		text = L["ModuleName HuntTable"],
		dbKey = "HuntTable",
	},

	{
		type = "Checkbox",
		dbKey = "HuntTable",
	},

	{
		type = "p",
		bullet = true,
		text = "Replaces the generic blue quest icons to show difficulties.",
	},

	{
		type = "p",
		bullet = true,
		text = "Shows an indicator if the Prey target is a requirement for an unearned achievement.",
	},

	{
		type = "img",
		dbKey = "HuntTable",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = MISCELLANEOUS,
	},

	{
		type = "p",
		bullet = true,
		text = "Expansion Summary UI: Added \"Gilded Stash\" progress to the Activities tab. Note: This info is only available when you are in Midnight open-world zones.",
	},

	{
		type = "p",
		bullet = true,
		text = "Expansion Summary UI, Great Vault: Fixed an issue where the item level on the tooltip is wrong for Delves and World Activities.",
	},

	{
		type = "br",
	},
	{
		type = "br",
	},

	{
		type = "date",
		versionText = "1.9.0",
		timestamp = 1774400000,
	},

	{
		type = "h1",
		text = L["ModuleName CatalystUI"],
		dbKey = "CatalystUI",
	},

	{
		type = "Checkbox",
		dbKey = "CatalystUI",
	},

	{
		type = "p",
		bullet = true,
		text = "Allows you to Ctrl-Click the output item to view it in the Dressing Room, or Shift-Click to link it to chat.",
	},

	{
		type = "img",
		dbKey = "CatalystUI",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = L["ModuleName NewExpansionLandingPage"],
	},

	{
		type = "p",
		bullet = true,
		text = "Activities Tab: Added item \"Saltheril's Favor\" to Silvermoon Court. Note: These items can be used to unlock more tasks and expire after the weekly reset.",
	},

	{
		type = "p",
		bullet = true,
		text = "Activities Tab: Added quest \"Lost Legends\" to Hara'ti.",
	},

	{
		type = "p",
		bullet = true,
		text = "Activities Tab: Merged \"Bountiful Delves\" under each Renown activity into a single entry named \"Bonus Renown\" under the Delves category.",
	},

	{
		type = "p",
		bullet = true,
		text = "Great Vault: Fixed an issue where the third row incorrectly showed \"Reward at Highest Level.\"",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = MISCELLANEOUS,
	},

	{
		type = "p",
		bullet = true,
		text = "Fixed an issue where hovering your cursor over certain items caused errors after entering and leaving an instance.",
	},
};


changelogs[10809] = {
	{
		type = "date",
		versionText = "1.8.9 f",
		timestamp = 1774000000,
	},

	{
		type = "h1",
		text = L["ModuleName NewExpansionLandingPage"],
	},

	{
		type = "p",
		bullet = true,
		text = "Activities Tab: Added Bountiful Delves to each Renown. Note: Opening a Bountiful Coffer increases your reputation with a random Renown. One time per Renown per week.",
	},

	{
		type = "p",
		bullet = true,
		text = "Activities Tab: Added Coffer Key Shards to the Delves category. You can obtain 600 shards per week.",
	},

	{
		type = "p",
		bullet = true,
		text = "Resources: The quantity text of Coffer Key Shards will turn green once you reach the weekly cap.",
	},

	{
		type = "p",
		bullet = true,
		text = "Fixed an issue where \"Fortify the Runestones\" shows twice on the activity list when you are on this quest.",
	},

	{
		type = "p",
		bullet = true,
		text = "Fixed an issue where the number shown next to the \"Hide Completed\" button doesn't match what you see on the list.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = MISCELLANEOUS,
	},

	{
		type = "p",
		bullet = true,
		text = "Modules that display the number of owned Restored Coffer Keys should be working again. The involved modules are \"Chest Keys\" and \"Nameplate: Soft Target\".",
	},

	{
		type = "p",
		bullet = true,
		text = "Loot UI: When \"Show Any Currency Changes\" is enabled, Conquest and Bloody Tokens earned from War Supply Drops should no longer show 100 times the actual quantity.",
	},

	{
		type = "br",
	},
	{
		type = "br",
	},


	{
		type = "date",
		versionText = "1.8.9 d-e",
		timestamp = 1773700000,
	},

	{
		type = "h1",
		text = L["ModuleName NewExpansionLandingPage"],
	},

	{
		type = "p",
		bullet = true,
		text = "Fixed an error when hovering over the Great Vault button.",
	},

	{
		type = "p",
		bullet = true,
		text = "Added faction Slayer\'s Duellum.",
	},

	{
		type = "p",
		bullet = true,
		text = "Raids Tab: Updated Midnight Raid Achievements.",
	},

	{
		type = "p",
		bullet = true,
		text = "Activities Tab now shows how many prey targets you have defeated in each difficulty.",
	},

	{
		type = "p",
		bullet = true,
		text = "Added Delves weekly quest and Trovehunter's Bounty to Activities.",
	},

	{
		type = "p",
		bullet = true,
		text = "Special thanks to Lazey for providing hidden quest data.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Bug Fixes",
	},

	{
		type = "p",
		bullet = true,
		text = "Quick Slot: Resilient Seeds: Fixed an issue where this feature stopped working when you teleported to Harandar.",
	},

	{
		type = "br",
	},
	{
		type = "br",
	},


	{
		type = "date",
		versionText = "1.8.9 a-c",
		timestamp = 1773000000,
	},

	{
		type = "h1",
		text = L["ModuleName TooltipRichSoil"],
		dbKey = "TooltipRichSoil",
	},

	{
		type = "Checkbox",
		dbKey = "TooltipRichSoil",
	},

	{
		type = "p",
		bullet = true,
		text = "For Herbalists: Show Resilient Seed buttons when double-clicking on Rich Soil.",
	},

	{
		type = "img",
		dbKey = "TooltipRichSoil",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = MISCELLANEOUS,
	},

	{
		type = "p",
		bullet = true,
		text = "Nameplate: Soft Target: Show the number of owned Latent Arcana for Misplaced Tomes.",
	},
};


changelogs[10808] = {
	{
		type = "date",
		versionText = "1.8.8 e",
		timestamp = 1772900000,
	},

	{
		type = "h1",
		text = "Added",
	},

	{
		type = "p",
		bullet = true,
		text = "Expansion Summary: The Activities tab now supports Saltheril's Soiree and Prey.",
	},

	{
		type = "p",
		bullet = true,
		text = "Choice UI Item Cost: Shows the number of owned Latent Arcana on the \"Runic Shield Charge\" UI.",
	},

	{
		type = "br",
	},
	{
		type = "br",
	},

	{
		type = "date",
		versionText = "1.8.8 c-d",
		timestamp = 1772630000,
	},

	{
		type = "h1",
		text = "Bug Fixes",
	},

	{
		type = "p",
		bullet = true,
		text = "Event Toast: This module has been retired because most event toasts already support \"right click to close\" without using addons. Additionally, this module may have prevented you from viewing Abundance completion details.",
	},

	{
		type = "p",
		bullet = true,
		text = "Loot UI: Midnight ores, herbs, and skins should use the updated version of quality icons.",
	},

	{
		type = "p",
		bullet = true,
		text = "Expansion Summary: Clicking Valeera should show her abilities instead of Brann's.",
	},

	{
		type = "p",
		bullet = true,
		text = "Expansion Summary: To address the taint errors, the renown progress on the faction tooltip has been changed from a progress bar to text.",
	},

	{
		type = "p",
		bullet = true,
		text = "Plumber Torch Macro: Fixed an issue that affected typing in the macro edit box if you used Plumber Torch macro.",
	},

	{
		type = "p",
		bullet = true,
		text = "Fixed an error when pressing hotkeys to focus on the next/previous quest in the objective tracker.",
	},

	{
		type = "p",
		bullet = true,
		text = "Instance Difficulty Selector: Adjusted entrance coordinates for the two Utgarde dungeons.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Added",
	},

	{
		type = "p",
		bullet = true,
		text = "Break Time Reminder: Added an option to postpone the alert when you are in instance.",
	},

	{
		type = "p",
		bullet = true,
		text = "Break Time Reminder: Auto postpone schedule when AFK. The countdown to your next scheduled break will pause when you are AFK. It will continue pausing if the break time is over, but you have not performed any action.",
	},

	{
		type = "p",
		bullet = true,
		text = "Break Time Reminder: The time until your next scheduled break will be displayed on the Plumber minimap button's tooltip.",
	},

	{
		type = "p",
		bullet = true,
		text = "Updated the currencies (crests) used for upgrading Midnight items.",
	},

	{
		type = "br",
	},
	{
		type = "br",
	},

	{
		type = "date",
		versionText = "1.8.8",
		timestamp = 1772120000,
	},

	{
		type = "h1",
		text = L["ModuleName BreakTime"],
		dbKey = "BreakTime",
	},

	{
		type = "Checkbox",
		dbKey = "BreakTime",
	},

	{
		type = "p",
		bullet = true,
		text = "Remind you to take a short break after a period of time.",
	},

	{
		type = "p",
		bullet = true,
		text = "The default schedule is a 5-minute break every 30 min. You can change it in the settings.",
	},

	{
		type = "p",
		bullet = true,
		text = "You can delay or cancel the break when the timer goes off.",
	},

	{
		type = "img",
		dbKey = "BreakTime",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = MISCELLANEOUS,
	},

	{
		type = "p",
		bullet = true,
		text = "Expansion Summary: You can now switch the expansion to Midnight, but the content is still a work in progress.",
	},

	{
		type = "p",
		bullet = true,
		text = "Map Pin modules have been retired. Displaying Bountiful Delves and Special Assignments on Quel'Thalas map is a WoW native feature now.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Bug Fixes",
	},

	{
		type = "p",
		bullet = true,
		text = "Expansion Summary Minimap Button: Fixed a reposition issue when the Minimap's scale was not 100%.",
	},

	{
		type = "p",
		bullet = true,
		text = "Expansion Summary Minimap Button: This button should correctly become hidden when you start pet battle.",
	},

	{
		type = "p",
		bullet = true,
		text = "Queue Status: Fixed the timer for PvP queues.",
	},
};


changelogs[10807] = {
	{
		type = "date",
		versionText = "1.8.7",
		timestamp = 1771000000,
	},

	{
		type = "h1",
		text = L["ModuleName NewExpansionLandingPage"],
		dbKey = "NewExpansionLandingPage",
	},

	{
		type = "Checkbox",
		dbKey = "NewExpansionLandingPage",
	},

	{
		type = "p",
		bullet = true,
		text = "Added a new minimap button to toggle the Expansion Summary UI.",
	},

	{
		type = "p",
		bullet = true,
		text = "You can right-click this button to access Order Hall UI from previous expansions.",
	},

	{
		type = "p",
		bullet = true,
		text = "You can customize the button\'s appearance and behavior.",
	},

	{
		type = "img",
		fileName = "Changelog_LandingButton",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = MISCELLANEOUS,
	},

	{
		type = "p",
		bullet = true,
		text = "Nameplate Quest Indicator: Added an option to show quest progress on all NPC nameplates when pressing a modifier key.",
	},

	{
		type = "p",
		bullet = true,
		text = "Drawer Macros: Unusable toys should no longer appear in the flyout when \"Hide Unusable Actions\" is enabled.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Bug Fixes",
	},

	{
		type = "p",
		bullet = true,
		text = "Nameplate Quest Indicator: Fixed an error when calculating percentage-based quest progress.",
	},

	{
		type = "p",
		bullet = true,
		text = "Loot UI: Fixed an error when displaying the item comparison tooltip.",
	},

	{
		type = "p",
		bullet = true,
		text = "Expansion Summary: Fixed an issue where the reputation level text disappears before reaching Paragon.",
	},
};


changelogs[10806] = {
	{
		type = "date",
		versionText = "1.8.6 b",
		timestamp = 1770130000,
	},

	{
		type = "h1",
		text = L["ModuleName LootUI"],
		dbKey = "LootUI",
	},

	{
		type = "Checkbox",
		dbKey = "LootUI",
	},

	{
		type = "p",
		bullet = true,
		text = "Added an option to show currencies earned from all sources, not just loot.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = L["ModuleName NameplateQuest"],
	},

	{
		type = "p",
		bullet = true,
		text = "You can now customize the progress text format to show Completed/Required or Remaining quantity, and keep the quest icon visible.",
	},

	{
		type = "br",
	},
	{
		type = "br",
	},


	{
		type = "date",
		versionText = "1.8.6",
		timestamp = 1769870000,
	},

	{
		type = "h1",
		text = L["ModuleName NameplateQuest"],
		dbKey = "NameplateQuest",
	},

	{
		type = "Checkbox",
		dbKey = "NameplateQuest",
	},

	{
		type = "p",
		bullet = true,
		text = "Show quest indicator on nameplates. This indicator is customizable.",
	},

	{
		type = "p",
		bullet = true,
		text = "(Optional) Show quest objective progress on your target or mouseover.",
	},

	{
		type = "p",
		bullet = true,
		text = "(Optional) Show quest indicator if your party members haven't completed the objective.",
	},

	{
		type = "img",
		dbKey = "NameplateQuest",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = MISCELLANEOUS,
	},

	{
		type = "p",
		bullet = true,
		text = "Loot Window: Added an option to hide the \"You received\" text.",
	},

	{
		type = "p",
		bullet = true,
		text = "Fixed several secret-related errors. \"Trust me, bro.\"",
	},
};


changelogs[10805] = {
	{
		type = "date",
		versionText = "1.8.5 b-e",
		timestamp = 1769530000,
	},

	{
		type = "h1",
		text = L["ModuleName LootUI"],
		dbKey = "LootUI",
	},

	{
		type = "Checkbox",
		dbKey = "LootUI",
	},

	{
		type = "p",
		bullet = true,
		text = "Added an option to display money earned from all sources, not just loot.",
	},

	{
		type = "p",
		bullet = true,
		text = "Money earned while interacting with mailbox or NPC will be displayed afterwards.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = L["ModuleName TransmogOutfitSelect"],
		dbKey = "TransmogOutfitSelect",
	},

	{
		type = "Checkbox",
		dbKey = "TransmogOutfitSelect",
	},

	{
		type = "p",
		bullet = true,
		text = L["ModuleDescription1 TransmogOutfitSelect"],
	},

	{
		type = "p",
		bullet = true,
		text = L["ModuleDescription2 TransmogOutfitSelect"],
	},

	{
		type = "p",
		bullet = true,
		text = "You can drag the top area of this window to move it.",
	},

	{
		type = "img",
		fileName = "Changelog_TransmogOutfitSelect",
		large = true,
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Bug Fixes",
	},

	{
		type = "p",
		bullet = true,
		text = "Expansion Summary, Great Vault: World Activities should show the correct, post-stat-squished item levels.",
	},

	{
		type = "p",
		bullet = true,
		text = "Loot Window, Reputations: Fixed an issue that prevents the changes to Weaver, General, and Vizier from showing.",
	},

	{
		type = "p",
		bullet = true,
		text = "Drawer Macros should be able to work in combat again.",
	},

	{
		type = "p",
		bullet = true,
		text = "Decor Catalog: Fixed an error when using the decor search box in house editing mode.",
	},

	{
		type = "p",
		bullet = true,
		text = "Expansion Summary: The UI should no longer display the paragon progress for factions that haven't reached maximum renown.",
	},

	{
		type = "p",
		bullet = true,
		text = "Appearances Tab: Fixed an error when Ctrl-clicking an appearance.",
	},

	{
		type = "p",
		bullet = true,
		text = "Nameplate: Keyflame: Fixed an error when you were in specific areas in Hallowfall.",
	},

	{
		type = "br",
	},
	{
		type = "br",
	},


	{
		type = "date",
		versionText = "1.8.5",
		timestamp = 1768900000,
	},

	{
		type = "h1",
		text = L["ModuleName InstanceDifficulty"],
	},

	{
		type = "p",
		bullet = true,
		text = "You can now adjust this UI's position in Edit Mode.",
	},

	{
		type = "br",
	},

	{
		type = "tocVersionCheck",
		minimumTocVersion = 120000,
		breakpoint = false,
	},


	{
		type = "h1",
		text = L["ModuleName LootUI"],
		dbKey = "LootUI",
	},

	{
		type = "Checkbox",
		dbKey = "LootUI",
	},

	{
		type = "p",
		bullet = true,
		text = "Added a new option to display reputations earned from all sources in the loot window.",
	},

	{
		type = "p",
		bullet = true,
		text = "Hover the cursor over the notification to show the reputation's progress.",
	},

	{
		type = "p",
		bullet = true,
		text = "Reputations earned during combat or in PvP instances will be displayed afterwards.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = L["ModuleName Housing_Macro"],
	},

	{
		type = "p",
		bullet = true,
		text = "The Teleport Home macro will be automatically changed to Return to Previous Location when eligible.",
	},

	{
		type = "p",
		bullet = true,
		text = "Shout-outs to ConsolePort dev Munk, and a mysterious helper that works in extreme weather, and of course myelf for reviving the Teleport Home macro in Midnight.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = L["ModuleName NewExpansionLandingPage"],
	},

	{
		type = "p",
		bullet = true,
		text = "The Khaz Algar landing page button has been removed. To open Plumber Expansion Summary, set a hotkey in Game Settings> Keybindings> Plumber Addon, or use the Addon Compartment under the Calendar button.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Retired Features",
	},

	{
		type = "p",
		bullet = true,
		text = L["ModuleName SpellcastingInfo"],
	},

	{
		type = "p",
		bullet = true,
		text = L["ModuleName Delves_SeasonProgress"]..": ".."Blizzard has redesigned this UI. Your Delves Progress is now shown in Adventure Guide> Journeys.",
	},

	{
		type = "p",
		bullet = true,
		text = L["ModuleName SoftTargetName"]..": ".."The radial cast bar on nameplates has been removed.",
	},

	{
		type = "p",
		bullet = true,
		text = L["ModuleName TransmogChatCommand"]..": ".."This module has been removed. Features like \"using outfit slash commands to load available items to the Transmog UI\" will be migrated to the Narcissus addon.",
	},
};


changelogs[10804] = {
	{
		type = "date",
		versionText = "1.8.4 c",
		timestamp = 1766320000,
	},

	{
		type = "h1",
		text = "Housing Modules",
	},

	{
		type = "p",
		bullet = true,
		text = "House Editor, Customize Mode: You can Shift Click a dye swatch to track its recipe, or post it in chat.",
	},

	{
		type = "p",
		bullet = true,
		text = "Decor Catalog: You can Shift Click a decor to post it in chat if the chat edit box is active. Alternatively, from its context menu.",
	},

	{
		type = "p",
		bullet = true,
		text = "Thanks to Cabal members Keyboardturner and Ghost for the inspiration and for providing a cozy place to code.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = L["ModuleName InstanceDifficulty"],
		dbKey = "InstanceDifficulty",
	},

	{
		type = "Checkbox",
		dbKey = "InstanceDifficulty",
	},

	{
		type = "p",
		bullet = true,
		text = "You can now Alt Right Click on the instance name to reset all instances.",
	},

	{
		type = "p",
		bullet = true,
		text = "You can now Shift Click on a difficulty button to post your raid progress in chat if you have killed any boss on that difficulty.",
	},

	{
		type = "p",
		bullet = true,
		text = "Karazhan side entrance should show the correct difficulties.",
	},

	{
		type = "p",
		bullet = true,
		text = "Thanks to the Dawnsong Twins, especially the nicer one, for testing this module multiple times and giving valuable feedback.",
	},

	{
		type = "br",
	},
	{
		type = "br",
	},



	{
		type = "date",
		versionText = "1.8.4 b",
		timestamp = 1766070000,
	},

	{
		type = "h1",
		text = L["ModuleName Housing_ItemAcquiredAlert"],
		dbKey = "Housing_ItemAcquiredAlert",
	},

	{
		type = "Checkbox",
		dbKey = "Housing_ItemAcquiredAlert",
	},

	{
		type = "p",
		bullet = true,
		text = L["ModuleDescription Housing_ItemAcquiredAlert"],
	},

	{
		type = "img",
		dbKey = "Housing_ItemAcquiredAlert",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = MISCELLANEOUS,
	},

	{
		type = "p",
		bullet = true,
		text = "Chat Channel Options: Fixed an issue where the Leave Channel buttons always appeared disabled.",
	},

	{
		type = "p",
		bullet = true,
		text = "Nameplate: Soft Target: Added options to hide the interact icon and object name when you are in a house.",
	},

	{
		type = "p",
		bullet = true,
		text = "Decor Catalog: Extend Search Results: Shows the number of matches next to the category. Auto-selects the first match.",
	},

	{
		type = "p",
		bullet = true,
		text = "House Editor: Clock: It now tracks your total time spent in the house editor, instead of just the current game session.",
	},

	{
		type = "br",
	},
	{
		type = "br",
	},



	{
		type = "date",
		versionText = "1.8.4",
		timestamp = 1765900000,
	},

	{
		type = "h1",
		text = "House Editor: Clock",
		dbKey = "Housing_Clock",
	},

	{
		type = "Checkbox",
		dbKey = "Housing_Clock",
	},

	{
		type = "p",
		bullet = true,
		text = "While using the house editor, show a clock on the top of the screen. You can switch Between analog and digital.",
	},

	{
		type = "p",
		bullet = true,
		text = "Hover the cursor over the clock to show how long you have spent in the house Editor during your current game session.",
	},

	{
		type = "img",
		dbKey = "Housing_Clock",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Interactable Source Info",
		dbKey = "SourceAchievementLink",
	},

	{
		type = "Checkbox",
		dbKey = "SourceAchievementLink",
	},

	{
		type = "p",
		text = "The Achievement names on the following UI become interactable, allowing you to See their details or track them.",
	},

	{
		type = "p",
		bullet = true,
		text = "Decor Catalog",
	},

	{
		type = "p",
		bullet = true,
		text = "Mount Journal",
	},

	{
		type = "img",
		dbKey = "SourceAchievementLink",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Decor Catalog: Extend Search Results",
		dbKey = "Housing_CatalogSearch",
	},

	{
		type = "Checkbox",
		dbKey = "Housing_CatalogSearch",
	},

	{
		type = "p",
		bullet = true,
		text = "Enhances the search box on the decor catalog and storage Tab, allowing you to find items by achievement, vendor, zone, or currency.",
	},

	{
		type = "img",
		dbKey = "Housing_CatalogSearch",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Bug Fixes",
	},

	{
		type = "p",
		bullet = true,
		text = "Backpack Item Tracker: Fixed an issue that automatically Re-enabled this module when disabled.",
	},

	{
		type = "p",
		bullet = true,
		text = "Keybindings, Focus On Quest: Fixed An issue where the next/previous quest you set doesn't match its order in the objective tracker.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = MISCELLANEOUS,
	},

	{
		type = "p",
		bullet = true,
		text = "Decor Catalog: Banana For Scale: This module will slightly adjust the default camera pitch angle when Enabled.",
	},
};


changelogs[10803] = {
	{
		type = "date",
		versionText = "1.8.3",
		timestamp = 1765550000,
	},

	{
		type = "h1",
		text = "Editor: Customize Mode",
		dbKey = "Housing_CustomizeMode",
	},

	{
		type = "Checkbox",
		dbKey = "Housing_CustomizeMode",
	},

	{
		type = "p",
		bullet = true,
		text = "This module only functions in Customize Mode.",
	},

	{
		type = "p",
		bullet = true,
		text = "Allows you to copy dyes from one decor to another.\nRight Click on a decor to copy the applied dyes.\nCtrl Left Click on another object to preview the dyes.",
	},

	{
		type = "p",
		bullet = true,
		text = "When a decor is already selected, you can Right Click on another object to copy its dyes.",
	},

	{
		type = "p",
		bullet = true,
		text = "Change the dye slot name from index to the color's name.",
	},

	{
		type = "img",
		dbKey = "Housing_CustomizeMode",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Extend Search Results",
		dbKey = "CraftSearchExtended",
	},

	{
		type = "Checkbox",
		dbKey = "CraftSearchExtended",
	},

	{
		type = "p",
		bullet = true,
		text = "For Alchemy and Inscription: you can now find housing pigment recipes by searching dye colors.",
	},

	{
		type = "p",
		bullet = true,
		text = "Press Enter to select the first match.",
	},

	{
		type = "img",
		dbKey = "CraftSearchExtended",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Tooltip: Dye Pigment",
		dbKey = "TooltipDyeDeez",
	},

	{
		type = "Checkbox",
		dbKey = "TooltipDyeDeez",
	},

	{
		type = "p",
		bullet = true,
		text = "Display the dye color names on housing pigment's tooltip.",
	},

	{
		type = "p",
		bullet = true,
		text = "You can press Alt to show or hide this info.",
	},

	{
		type = "img",
		dbKey = "TooltipDyeDeez",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Keybindings: Focus On Quest",
	},

	{
		type = "p",
		bullet = true,
		text = "Allows you to press hotkeys to focus on the next/previous quest in the objective tracker.",
	},

	{
		type = "p",
		bullet = true,
		text = "Set your hotkeys in Game Settings> Keybindings> Plumber Addon.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = MISCELLANEOUS,
	},

	{
		type = "p",
		bullet = true,
		text = "Editor, Decorate Mode: The hovered decor's placement cost will be displayed next to its name.",
	},
};


changelogs[10802] = {
	{
		type = "date",
		versionText = "1.8.2",
		timestamp = 1764900000,
	},

	{
		type = "h1",
		text = "Decor Editor: Object Name and Duplicate",
		dbKey = "Housing_DecorHover",
	},

	{
		type = "Checkbox",
		dbKey = "Housing_DecorHover",
	},

	{
		type = "p",
		bullet = true,
		text = "This module only functions in Decorate Mode.",
	},

	{
		type = "p",
		bullet = true,
		text = "Hover the cursor over a decor to display its name and its item count in storage.",
	},

	{
		type = "p",
		bullet = true,
		text = "While a decor is hovered, press the ALT key to place another instance of this object if there is at least one left in storage.",
	},

	{
		type = "img",
		dbKey = "Housing_DecorHover",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = "Plumber Macros",
	},

	{
		type = "p",
		text = "Create a new macro then enter the following |cffd7c0a3#plumber:command|r in the command editbox.",
	},

	{
		type = "p",
		bullet = true,
		text = "|cffd7c0a3#plumber:home|r\nUse this macro to teleport to your house.",
	},

	{
		type = "p",
		bullet = true,
		text = "|cffd7c0a3#plumber:torch|r\nToggle Cave Spelunker's Torch while you are in housing zones.",
	},

	{
		type = "img",
		dbKey = "Housing_Macro",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = MISCELLANEOUS,
	},

	{
		type = "p",
		bullet = true,
		text = "Settings Panel: If a module has a movable widget, clicking the module settings will minimize the module list to avoid blocking other UI elements.",
	},

	{
		type = "p",
		bullet = true,
		text = "Settings Panel: Added an option to increase the font size for release notes.",
	},

	{
		type = "p",
		bullet = true,
		text = "Decor Catalog: Banana For Scale: Updated the banana to its HD version.",
	},
};


changelogs[10801] = {
	{
		type = "date",
		versionText = "1.8.1",
		timestamp = 1764700000,
	},

	{
		type = "h1",
		text = L["Settings Panel"],
	},

	{
		type = "p",
		bullet = true,
		text = "The Settings Panel has been redesigned, and you are looking at it right now. Hopefully, the new search box and categorization can help you find the features you need.",
	},

	{
		type = "p",
		bullet = true,
		text = "A checkbox may appear on the release note, allowing you to conveniently enable or disable a new feature.",
	},

	{
		type = "p",
		bullet = true,
		text = "You can now use slash command |cffd7c0a3/plumber|r to toggle the Settings Panel.",
	},

	{
		type = "br",
	},

	{
		type = "tocVersionCheck",
		minimumTocVersion = 110207,
		breakpoint = false,
	},

	{
		type = "h1",
		text = L["ModuleName DecorModelScaleRef"],
		dbKey = "DecorModelScaleRef",
	},


	{
		type = "Checkbox",
		dbKey = "DecorModelScaleRef",
	},

	{
		type = "p",
		bullet = true,
		text = "Add a size reference (a banana) to the decor preview window, allowing you to gauge the size of the objects. You can show/hide the banana at any time.",
	},

	{
		type = "p",
		bullet = true,
		text = "Allow you to change the camera pitch by holding down the Left Button and moving vertically.",
	},

	{
		type = "img",
		dbKey = "DecorModelScaleRef",
	},
};


changelogs[10800] = {
	{
		type = "date",
		versionText = "1.8.0",
		timestamp = 1763400000,
	},

	{
		type = "h1",
		text = L["ModuleName InstanceDifficulty"],
		dbKey = "InstanceDifficulty",
	},

	{
		type = "Checkbox",
		dbKey = "InstanceDifficulty",
	},

	{
		type = "p",
		bullet = true,
		text = "Show a Difficulty Selector when you are at the entrance of a raid or dungeon.",
	},

	{
		type = "p",
		bullet = true,
		text = "Show the current difficulty and lockout info at the top of the screen when you enter an instance.",
	},

	{
		type = "img",
		dbKey = "InstanceDifficulty",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = L["ModuleName TooltipTransmogEnsemble"],
		dbKey = "TooltipTransmogEnsemble",
	},

	{
		type = "Checkbox",
		dbKey = "TooltipTransmogEnsemble",
	},

	{
		type = "p",
		bullet = true,
		text = "Show the number of collectable appearances from an Ensemble.",
	},

	{
		type = "p",
		bullet = true,
		text = "Fixed the issue where the tooltip says \"Already known,\" but you can still use it to unlock new appearances.",
	},

	{
		type = "img",
		dbKey = "TooltipTransmogEnsemble",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = MISCELLANEOUS,
	},

	{
		type = "p",
		bullet = true,
		text = "WoW Anniversary: This module has been re-enabled. You can summon the corresponding mount easily during the Mount Maniac event.",
	},

	{
		type = "p",
		bullet = true,
		text = "Loot Window, Link Item: You can link an item in chat by Shift + clicking an item in Manual Loot mode.",
	},
};


changelogs[10709] = {
	{
		type = "date",
		versionText = "1.7.9",
		timestamp = 1761400000,
	},

	{
		type = "h1",
		text = L["ModuleName QueueStatus"],
		dbKey = "QueueStatus",
	},

	{
		type = "Checkbox",
		dbKey = "QueueStatus",
	},

	{
		type = "p",
		bullet = true,
		text = "Add a progress bar to the Group Finder Eye that shows the percentage of teammates found. Tanks and Healers weigh more.",
	},

	{
		type = "p",
		bullet = true,
		text = "(Optional) Show the delta between Average Wait Time and your Time In Queue.",
	},

	{
		type = "img",
		dbKey = "QueueStatus",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = L["ModuleName PlayerPing"],
		dbKey = "WorldMapPin_PlayerPing",
	},

	{
		type = "Checkbox",
		dbKey = "WorldMapPin_PlayerPing",
	},

	{
		type = "p",
		text = "By default, WoW only shows the player ping when you change maps or the first time you open the World Map. Whereas this module highlights the player's location with a ping effect when you:",
	},

	{
		type = "p",
		bullet = true,
		text = "Open World Map.",
	},

	{
		type = "p",
		bullet = true,
		text = "Press the ALT key.",
	},

	{
		type = "p",
		bullet = true,
		text = "Click the Maximize button.",
	},

	{
		type = "p",
		text = "Updated the ping texture",
	},

	{
		type = "img",
		dbKey = "WorldMapPin_PlayerPing",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = L["ModuleName HolidayDungeon"],
		dbKey = "HolidayDungeon",
	},

	{
		type = "Checkbox",
		dbKey = "HolidayDungeon",
	},

	{
		type = "p",
		bullet = true,
		text = "Automatically select holiday and timewalking dungeons when you open Dungeon Finder for the first time.",
	},

	{
		type = "br",
	},

	{
		type = "h1",
		text = L["New Features"],
	},

	{
		type = "p",
		bullet = true,
		text = "Tooltip: Quest Starting Items: If an item in your bag starts a quest, show the quest details. You can Ctrl Left Click the item to view it in the quest log if you are already on the quest.",
	},

	{
		type = "p",
		bullet = true,
		text = "Non-refundable Purchase Alert: Adjust the confirmation dialog that appears when buying a non-refundable item, adding a brief lockdown to the 'Yes' button and highlighting the keywords in red. This module also reduces the class set conversion delay by half.",
	},

	{
		type = "p",
		bullet = true,
		text = "Legion Remix: Auto-set Adventure Guide expansion to Legion.",
	},

	{
		type = "p",
		bullet = true,
		text = "This module should now support addons that modify the max number of items per page. It also shows thousands separator on alt currencies like Bronze.",
	},
};
