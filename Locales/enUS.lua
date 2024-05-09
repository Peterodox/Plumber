--Reserved space below so all localization files line up



local _, addon = ...
local L = addon.L;


--Module Control Panel
L["Module Control"] = "Module Control";
L["Quick Slot Generic Description"] = "\n\n*Quick Slot is a set of clickable buttons that appear under certain conditions.";
L["Restriction Combat"] = "Does not work in combat";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*You can change the pin size in World Map - Map Filter - Plumber";


--Module Categories
--- order: 0
L["Module Category Unknown"] = "Unknown"    --Don't need to translate
--- order: 1
L["Module Category General"] = "General";
--- order: 2
L["Module Category NPC Interaction"] = "NPC Interaction";
--- order: 3
L["Module Category Class"] = "Class";   --Player Class (rogue, paladin...)
--- order: 4
L["Module Category Dreamseeds"] = "Dreamseeds";     --Added in patch 10.2.0
--- order: 5
L["Module Category AzerothianArchives"] = "Azerothian Archives";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Auto Join Events";
L["ModuleDescription AutoJoinEvents"] = "Auto select (Begin Time Rift) when you interact with Soridormi during the event.";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "Backpack Item Tracker";
L["ModuleDescription BackpackItemTracker"] = "Track stackable items on the Bag UI as if they were currencies.\n\nHoliday tokens are automatically tracked and pinned to the left.";
L["Instruction Track Item"] = "Track Item";
L["Hide Not Owned Items"] = "Hide Not Owned Items";
L["Hide Not Owned Items Tooltip"] = "If you no longer own an item you tracked, it will be moved to a hidden menu.";
L["Concise Tooltip"] = "Concise Tooltip";
L["Concise Tooltip Tooltip"] = "Only shows the item's binding type and its max quantity.";
L["Item Track Too Many"] = "You may only track %d items at a time."
L["Tracking List Empty"] = "Your custom tracking list is empty.";
L["Holiday Ends Format"] = "Ends: %s";
L["Not Found"] = "Not Found";   --Item not found
L["Own"] = "Own";   --Something that the player has/owns
L["Numbers To Earn"] = "# To Earn";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# Earned";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "Track Crests";       --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "Pin the top-tier crest you have earned to the bar.";
L["Currently Pinned Colon"] = "Currently Pinned:";  --Tells the currently pinned item
L["Bar Inside The Bag"] = "Bar Inside The Bag";     --Put the bar inside the bag UI (below money/currency)
L["Bar Inside The Bag Tooltip"] = "Place the bar inside the bag UI.\n\nIt only works in Blizzard's Separate Bags mode.";


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
L["ModuleDescription WorldMapPinSeedPlanting"] = "Show Dreamseed Soil's locations and their Growth Cycles on the world map."..L["Map Pin Change Size Method"].."\n\n|cffd4641cEnabling this module will remove the game's default map pin for Emerald Bounty, which may affect the behavior of other addons.";
L["Pin Size"] = "Pin Size";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "Choice UI: Dreamseed Nurturing";
L["ModuleDescription AlternativePlayerChoiceUI"] = "Replace the default Dreamseed Nurturing UI with a less view-blocking one, display the numbers of items you own, and allow you to auto contribute items by clicking and holding the button.";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "Handy Lockpick";
L["ModuleDescription HandyLockpick"] = "Right click a lockbox in your bag or Trade UI to unlock it.\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- Cannot directly unlock a bank item\n- Affected by Soft Targeting Mode";
L["Instruction Pick Lock"] = "<Right Click to Pick Lock>";


--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "Blitz Fix: Event Toast";
L["ModuleDescription BlizzFixEventToast"] = "Modify the behavior of Event Toasts so they don't consume your mouse clicks. Also allow you to Right Click on the toast and close it immediately.\n\n*Event Toasts are banners that appear on the top of the screen when you complete certain activities.";


--Talking Head
L["ModuleName TalkingHead"] = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL or "Talking Head";
L["ModuleDescription TalkingHead"] = "Replace the default Talking Head UI with a clean, headless one.";
L["EditMode TalkingHead"] = "Plumber: "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "Instant Text";   --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "Text Outline";   --Added a stroke/outline to the letter
L["TalkingHead Option Condition Header"] = "Hide Texts From Source:";
L["TalkingHead Option Condition WorldQuest"] = TRACKER_HEADER_WORLD_QUESTS or "World Quests";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "Hide the transcription if it's from a World Quest.\nSometimes Talking Head is triggered before accepting the World Quest, and we won't be able to hide it.";
L["TalkingHead Option Condition Instance"] = INSTANCE or "Instance";
L["TalkingHead Option Condition Instance Tooltip"] = "Hide the transcription when you are in an instance.";


--AzerothianArchives
L["ModuleName Technoscryers"] = "Quick Slot: Technoscryers";
L["ModuleDescription Technoscryers"] = "Show a button to put on the Technoscryers when you are doing Technoscrying World Quest."..L["Quick Slot Generic Description"];


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "Priority";
L["Priority Default"] = "Default";  --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "Follow WoW's default settings. Prioritize quest, corpse, vendor locations if possible. Otherwise, start tracking active seeds.";
L["Stop Tracking"] = "Stop Tracking";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-SuperTrack:0:0:0:0|t " .. "Left click to track locations";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t " .. "Left click to track in TomTom";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "Navigator: Dreamseeds";
L["ModuleDescription Navigator_Dreamseed"] = "Use the Waypoint system to guide you to the Dreamseeds.\n\n*Right click on the location indicator (if any) for more options.\n\n|cffd4641cThe game's default waypoints will be replaced while you are in the Emerald Dream.\n\nSeed location indicator may be overridden by quests.|r";
L["Priority New Seeds"] = "Finding New Seeds";
L["Priority Rewards"] = "Collecting Rewards";
L["Stop Tracking Dreamseed Tooltip"] = "Stop tracking seeds until you Left Click on a map pin.";


--BlizzFixWardrobeTrackingTip (Permanently disable the tip for wardrobe shortcuts)
L["ModuleName BlizzFixWardrobeTrackingTip"] = "Blitz Fix: Wardrobe Tip";
L["ModuleDescription BlizzFixWardrobeTrackingTip"] = "Hide the tutorial for Wardrobe shortcuts.";


--TillersFarm
L["ModuleName TillersFarm"] = "Tillers Farm"
L["ModuleDescription TillersFarm"] = "Show a list of seeds when you target the soils in Sunsong Ranch.";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "Share this location in chat.";
L["Announce Forbidden Reason In Cooldown"] = "You have shared a location recently.";
L["Announce Forbidden Reason Duplicate Message"] = "This location has been shared by another player recently.";
L["Announce Forbidden Reason Soon Despawn"] = "You cannot share this location because it will soon despawn.";
L["Available In Format"] = "Available in: |cffffffff%s|r";
L["Seed Color Epic"] = ICON_TAG_RAID_TARGET_DIAMOND3 or "Purple";   --Using GlobalStrings as defaults
L["Seed Color Rare"] = ICON_TAG_RAID_TARGET_SQUARE3 or "Blue";
L["Seed Color Uncommon"] = ICON_TAG_RAID_TARGET_TRIANGLE3 or "Green";


--Generic
L["Reposition Button Horizontal"] = "Move Horizontally";   --Move the window horizontally
L["Reposition Button Vertical"] = "Move Vertically";
L["Reposition Button Tooltip"] = "Left-click and drag to move the window.";
L["Font Size"] = FONT_SIZE or "Font Size";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Reset To Default Position";




-- !! Do NOT translate the following entries
L["currency-2706"] = "Whelpling";
L["currency-2707"] = "Drake";
L["currency-2708"] = "Wyrm";
L["currency-2709"] = "Aspect";

L["currency-2806"] = L["currency-2706"];
L["currency-2807"] = L["currency-2707"];
L["currency-2809"] = L["currency-2708"];
L["currency-2812"] = L["currency-2709"];