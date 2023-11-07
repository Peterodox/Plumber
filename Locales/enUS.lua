local _, addon = ...
local L = addon.L;


--Module Control Panel
L["Module Control"] = "Module Control";
L["Quick Slot Generic Description"] = "\n\n*Quick Slot is a set of clickable buttons that appear under certain conditions.";
L["Restriction Combat"] = "Does not work in combat";    --Indicate a feature can only work when out of combat


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Auto Join Events";
L["ModuleDescription AutoJoinEvents"] = "Auto select (Begin Time Rift) when you interact with Soridormi during the event.";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "Backpack Item Tracker";
L["ModuleDescription BackpackItemTracker"] = "Track stackable items on the Bag UI as if they were currencies.\n\nHoliday tokens are automatically tracked and pinned to the left.";
L["Instruction Track Item"] = "Track Item";
L["Hide Not Owned Items"] = "Hide Not Owned Items";
L["Hide Not Owned Items Tooltip"] = "If you no longer own an item you tracked, it will be moved to a hidden menu."
L["Concise Tooltip"] = "Concise Tooltip";
L["Concise Tooltip Tooltip"] = "Only shows the item's binding type and its max quantity.";
L["Item Track Too Many"] = "You may only track %d items at a time."
L["Tracking List Empty"] = "Your custom tracking list is empty.";
L["Holiday Ends Format"] = "Ends: %s";
L["Not Found"] = "Not Found";   --Item not found
L["Own"] = "Own";   --Something that the player has/owns
L["Numbers To Earn"] = "# To Earn";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# Earned";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "Track Crests";     --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "Pin the top-tier crest you have earned to the bar.";
L["Currently Pinned Colon"] = "Currently Pinned:";  --Tells the currently pinned item


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "Dragonriding Race Medal";
L["ModuleDescription GossipFrameMedal Format"] = "Replace the default icon %s with the medal %s you earn.\n\nIt may take a brief moment to acquire your records when you interact with the NPC.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "Druid Model Fix";
L["ModuleDescription DruidModelFix"] = "Fix the Character UI model display issue caused by using Glyph of Stars\n\nThis bug will be fixed by Blizzard in 10.2.0 and this module will be removed.";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "To-Be-Donated Item Count";
L["ModuleDescription PlayerChoiceFrameToken"] = "Show how many to-be-donated items you have on the PlayerChoice UI.\n\nCurrently only supports Dreamseed Nurturing.";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "Quick Slot: Dreamseeds";
L["ModuleDescription EmeraldBountySeedList"] = "Show a list of Dreamseeds when you approach an Emerald Bounty."..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "Map Pin: Dreamseeds";
L["ModuleDescription WorldMapPinSeedPlanting"] = "Show Dreamseed Soil's locations and their Growth Cycles on the world map.\n\n|cffd4641cEnabling this module will remove the game's default map pin for Emerald Bounty, which may affect the behavior of other addons.";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "Choice UI: Dreamseed Nurturing";
L["ModuleDescription AlternativePlayerChoiceUI"] = "Replace the default Dreamseed Nurturing UI with a less view-blocking one, display the numbers of items you own, and allow you to auto contribute items by clicking and holding the button.";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "Handy Lockpick";
L["ModuleDescription HandyLockpick"] = "Right click a lockbox in your bag or Trade UI to unlock it.\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- Cannot directly unlock a bank item\n- Affected by Soft Targeting Mode";
L["Instruction Pick Lock"] = "<Right Click to Pick Lock>";





-- !! Do NOT translate the following entries
L["currency-2706"] = "Whelpling";
L["currency-2707"] = "Drake";
L["currency-2708"] = "Wyrm";
L["currency-2709"] = "Aspect";