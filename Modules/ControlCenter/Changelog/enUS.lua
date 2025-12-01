-- DO NOT BOTHER TO TRANSLATE
-- DO NOT BOTHER TO TRANSLATE
-- DO NOT BOTHER TO TRANSLATE


if not (GetLocale() == "enUS") then return end;

local _, addon = ...
local L = addon.L;
local changelogs = addon.ControlCenter.changelogs;


changelogs[10800] = {
    {
        type = "h1",
        isNewFeature = true,
        previewKey = "InstanceDifficulty",
        text = L["ModuleName InstanceDifficulty"],
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
        type = "br",
    },

    {
        type = "h1",
        isNewFeature = true,
        previewKey = "TooltipTransmogEnsemble",
        text = L["ModuleName TooltipTransmogEnsemble"],
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
        type = "br",
    },

    {
        type = "h1",
        isNewFeature = true,
        previewKey = "TransmogChatCommand",
        text = L["ModuleName TransmogChatCommand"],
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
        isNewFeature = true,
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
        text = "Settings UI: New feature markers now stay for a week instead of going away after opening the Settings UI once.",
    },

    {
        type = "p",
        bullet = true,
        text = "Loot UI, Link Item: You can link an item in chat by Shift + clicking an item in Manual Loot mode.",
    },

    {
        type = "p",
        bullet = true,
        text = "Instance Difficulty Selector, No-Show: Fixed an issue where the UI doesn't appear when you travel between different floors in Blackrock Mountain and Caverns of Time. Adjusted the Caverns of Time instance entrance locations. Please note that the UI will not appear for Blackwing Descent's entrance due to limitations.",
    },
};