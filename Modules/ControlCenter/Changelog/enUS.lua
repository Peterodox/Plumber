-- DO NOT BOTHER TO TRANSLATE
-- DO NOT BOTHER TO TRANSLATE
-- DO NOT BOTHER TO TRANSLATE


if false then return end;

local _, addon = ...
local L = addon.L;
local changelogs = addon.ControlCenter.changelogs;


changelogs[10805] = {
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
        text = L["ModuleName TransmogChatCommand"],
        dbKey = "TransmogChatCommand",
    },

    {
        type = "Checkbox",
        dbKey = "TransmogChatCommand",
    },

    {
        type = "p",
        bullet = true,
        text = "When using a transmog chat command (which starts with /outfit), undress your character first so the old items won't be carried over into the new outfit.",
    },

    {
        type = "p",
        bullet = true,
        text = "When at the Transmogrifier, using a chat command automatically loads all available items to the Transmog UI instead of opening the Dressing Room.",
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
        text = "Loot UI, Link Item: You can link an item in chat by Shift + clicking an item in Manual Loot mode.",
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