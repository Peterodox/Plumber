-- DO NOT BOTHER TO TRANSLATE
-- DO NOT BOTHER TO TRANSLATE
-- DO NOT BOTHER TO TRANSLATE


if false then return end;

local _, addon = ...
local L = addon.L;
local changelogs = addon.ControlCenter.changelogs;


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
        isNewFeature = true,
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
        isNewFeature = true,
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
        isNewFeature = true,
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
        isNewFeature = true,
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
        isNewFeature = true,
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
        isNewFeature = true,
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
        isNewFeature = true,
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