-- DO NOT BOTHER TO TRANSLATE
-- DO NOT BOTHER TO TRANSLATE
-- DO NOT BOTHER TO TRANSLATE


local _, addon = ...
local L = addon.L;
local changelogs = addon.ControlCenter.changelogs_Forever;

changelogs[10907] = {
	{
		type = "date",
		versionText = "1.9.7 g",
		timestamp = 1795700000,
	},

	{
		type = "p",
		bullet = true,
		text = "Loot Window: To address a conflict with the game, Plumber Loot Window will now be automatically disabled if you are the Loot Master in a group.",
	},

	{
		type = "p",
		bullet = true,
		text = "Nameplate: Soft Target: It should now only display your own quest objective progress when you are in a group.",
	},

	{
		type = "p",
		bullet = true,
		text = "Handy Lockpick: This module has been re-enabled on Forever, allowing you to right-click a lockbox in your bag or the Trade UI to unlock it.",
	},

	{
		type = "p",
		bullet = 2,
		text = "Note: We don't have any rogues to verify this feature on Forever, though the underlying system should be identical to modern WoW.",
	},

	{
		type = "br",
	},
	{
		type = "br",
	},

	{
		type = "date",
		versionText = "1.9.7 e",
		timestamp = 1794900000,
	},

	{
		type = "p",
		bullet = true,
		text = "Transmog UI, Restore Pending Changes: This module works again on Forever.",
	},

	{
		type = "p",
		bullet = 2,
		text = "You should no longer see \"Invalid Custom Set Link\" in chat upon entering the game.",
	},

	{
		type = "p",
		bullet = true,
		text = "Drawer Macro: It now respects spell ranks, and the rank will be shown on the drawer buttons.",
	},

	{
		type = "p",
		bullet = true,
		text = "Tooltip Reagents: This module is now available on Forever. If an item can be used to combine into something new, display all \"reagents\" used in the process.",
	},

	{
		type = "br",
	},
	{
		type = "br",
	},

	{
		type = "date",
		versionText = "1.9.7 d",
		timestamp = 1794200000,
	},

	{
		type = "h1",
		text = L["ModuleName PetFoodMenu"],
		dbKey = "PetFoodMenu",
	},

	{
		type = "Checkbox",
		dbKey = "PetFoodMenu",
	},

	{
		type = "p",
		bullet = true,
		text = L["ModuleDescription PetFoodMenu"],
	},

	{
		type = "img",
		dbKey = "PetFoodMenu",
	},
};
