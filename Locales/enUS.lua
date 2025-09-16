--Reserved space below so all localization files line up



local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Plumber Addon";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "Toggle Plumber Expansion Summary";   --Show/hide Expansion Summary UI


--Module Control Panel
L["Module Control"] = "Module Control";
L["Quick Slot Generic Description"] = "\n\n*Quick Slot is a set of clickable buttons that appear under certain conditions.";
L["Quick Slot Edit Mode"] = HUD_EDIT_MODE_MENU or "Edit Mode";
L["Quick Slot High Contrast Mode"] = "Toggle High Contrast Mode";
L["Quick Slot Reposition"] = "Change Position";
L["Quick Slot Layout"] = "Layout";
L["Quick Slot Layout Linear"] = "Linear";
L["Quick Slot Layout Radial"] = "Radial";
L["Restriction Combat"] = "Does not work in combat";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*You can change the pin size in World Map> Map Filter> Plumber";
L["Toggle Plumber UI"] = "Toggle Plumber UI";
L["Toggle Plumber UI Tooltip"] = "Show the following Plumber UI in the Edit Mode:\n%s\n\nThis checkbox only controls their visibility in the Edit Mode. It will not enable or disable these modules.";


--Module Categories
--- order: 0
L["Module Category Unknown"] = "Unknown"    --Don't need to translate
--- order: 1
L["Module Category General"] = "General";
--- order: 2
L["Module Category NPC Interaction"] = "NPC Interaction";
--- order: 3
L["Module Category Tooltip"] = "Tooltip";   --Additional Info on Tooltips
--- order: 4
L["Module Category Class"] = "Class";   --Player Class (rogue, paladin...)
--- order: 5
L["Module Category Reduction"] = "Reduction";   --Reduce UI elements
--- order: -1
L["Module Category Timerunning"] = "Legion Remix";   --Change this based on timerunning season


L["Module Category Dragonflight"] = EXPANSION_NAME9 or "Dragonflight";  --Merge Expansion Feature (Dreamseeds, AzerothianArchives) Modules into this
L["Module Category Plumber"] = "Plumber";   --This addon's name

--Deprecated
L["Module Category Dreamseeds"] = "Dreamseeds";     --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "Azerothian Archives";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Auto Join Events";
L["ModuleDescription AutoJoinEvents"] = "Auto join these events when you interact with the NPC: \n\n- Time Rift\n\n- Theater Troupe";


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
L["Track Holiday Item"] = "Track Holiday Currency";       --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "Currently Pinned:";  --Tells the currently pinned item
L["Bar Inside The Bag"] = "Bar Inside The Bag";     --Put the bar inside the bag UI (below money/currency)
L["Bar Inside The Bag Tooltip"] = "Place the bar inside the bag UI.\n\nIt only works in Blizzard's Separate Bags mode.";
L["Catalyst Charges"] = "Catalyst Charges";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "Dragonriding Race Medal";
L["ModuleDescription GossipFrameMedal Format"] = "Replace the default icon %s with the medal %s you earn.\n\nIt may take a brief moment to acquire your records when you interact with the NPC.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "Druid Model Fix";
L["ModuleDescription DruidModelFix"] = "Fix the Character UI model display issue caused by using Glyph of Stars\n\nThis bug will be fixed by Blizzard in 10.2.0 and this module will be removed.";
L["Model Layout"] = "Model Layout";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "Choice UI: Item Cost";
L["ModuleDescription PlayerChoiceFrameToken"] = "Show how many items it needs to complete a certain action on the PlayerChoice UI.\n\nCurrently only supports events in The War Within.";


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
L["ModuleName BlizzFixEventToast"] = "Event Toast";
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
L["TalkingHead Option Below WorldMap"] = "Send To Back When Map Opened";
L["TalkingHead Option Below WorldMap Tooltip"] = "Send the Talking Head to the back when you open the World Map so it doesn't block it.";


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


--Rare/Location Announcement
L["Announce Location Tooltip"] = "Share this location in chat.";
L["Announce Forbidden Reason In Cooldown"] = "You have shared a location recently.";
L["Announce Forbidden Reason Duplicate Message"] = "This location has been shared by another player recently.";
L["Announce Forbidden Reason Soon Despawn"] = "You cannot share this location because it will soon despawn.";
L["Available In Format"] = "Available in: |cffffffff%s|r";
L["Seed Color Epic"] = ICON_TAG_RAID_TARGET_DIAMOND3 or "Purple";   --Using GlobalStrings as defaults
L["Seed Color Rare"] = ICON_TAG_RAID_TARGET_SQUARE3 or "Blue";
L["Seed Color Uncommon"] = ICON_TAG_RAID_TARGET_TRIANGLE3 or "Green";


--Tooltip Chest Keys
L["ModuleName TooltipChestKeys"] = "Chest Keys";
L["ModuleDescription TooltipChestKeys"] = "Show info on the key required to open the current chest or door.";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "Reputation Tokens";
L["ModuleDescription TooltipRepTokens"] = "Show the faction info if the item can be used to increase reputation.";


--Tooltip Mount Recolor
L["ModuleName TooltipSnapdragonTreats"] = "Snapdragon Treats";
L["ModuleDescription TooltipSnapdragonTreats"] = "Show additional info for Snapdragon Treats.";
L["Color Applied"] = "This is the currently applied color.";


--Tooltip Item Reagents
L["ModuleName TooltipItemReagents"] = "Reagents";
L["ModuleDescription TooltipItemReagents"] = "If an item can be used to combine into something new, display all \"reagents\" used in the process.\n\nPress and hold Shift to display the crafted item if supported.";
L["Can Create Multiple Item Format"] = "You have the resources to create |cffffffff%d|r items.";


--Tooltip DelvesItem
L["ModuleName TooltipDelvesItem"] = "Delves Items";
L["ModuleDescription TooltipDelvesItem"] = "Show how many Coffer Keys and Shards you have earned from weekly caches.";
L["You Have Received Weekly Item Format"] = "You have received %s this week.";


--Plunderstore
L["ModuleName Plunderstore"] = "Plunderstore";
L["ModuleDescription Plunderstore"] = "Modify the store opened via Group Finder:\n\n- Added a checkbox to hide collected items.\n\n- Display the number of uncollected items on the category buttons.\n\n- Added weapon and armor equip location to their tooltips.\n\n- Allow you to view equippable items in the Dressing Room.";
L["Store Full Purchase Price Format"] = "Earn |cffffffff%s|r Plunder to purchase everything in the store.";
L["Store Item Fully Collected"] = "You have collected everything in the store!";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "Merchant Price";
L["ModuleDescription MerchantPrice"] = "Modify Merchant UI's behaviors:\n\n- Grey out only the insufficient currencies.\n\n- Show all required items in the coin box.";
L["Num Items In Bank Format"] = (BANK or "Bank") ..": |cffffffff%d|r";
L["Num Items In Bag Format"] = (HUD_EDIT_MODE_BAGS_LABEL or "Bags") ..": |cffffffff%d|r";
L["Number Thousands"] = "K";    --15K  15,000
L["Number Millions"] = "M";     --1.5M 1,500,000
L["Questionable Item Count Tooltip"] = "The item count may be incorrect due to addon limitations.";


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = WAR_WITHIN_LANDING_PAGE_TITLE or "Khaz Algar Summary";
L["ModuleDescription ExpansionLandingPage"] = "Display extra info on the landing page:\n\n- Paragon Progress\n\n- Severed Threads Pact Level\n\n- Undermine Cartel Standings";
L["Instruction Track Reputation"] = "<Shift click to track this reputation>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift click to stop tracking>";
L["Error Show UI In Combat"] = "You cannot toggle this UI while in combat.";


--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "Minimap Mission Report";
L["ModuleDescription LandingPageSwitch"] = "Access Garrison and Class Hall mission reports by right-clicking on the Renown Summary button on the minimap.";
L["Mission Complete Count Format"] = "%d Ready to complete";
L["Open Mission Report Tooltip"] = "Right click to open mission reports.";


--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "Map Pin: "..(EXPANSION_NAME10 or "The War Within");
L["ModuleDescription WorldMapPin_TWW"] = "Show additional pins on Khaz Algar continent map:\n\n- %s\n\n- %s";  --Wwe'll replace %s with locales (See Map Pin Filter Name at the bottom)


--Delves
L["Great Vault Tier Format"] = GREAT_VAULT_WORLD_TIER or "Tier %s";
L["Item Level Format"] = ITEM_LEVEL or "Item Level %d";
L["Item Level Abbr"] = ITEM_LEVEL_ABBR or "iLvl";
L["Delves Reputation Name"] = "Delver's Journey";
L["ModuleName Delves_SeasonProgress"] = "Delves: Delver's Journey";
L["ModuleDescription Delves_SeasonProgress"] = "Display a progress bar on the top of the screen whenever you earn Delver's Journey";
L["ModuleName Delves_Dashboard"] = "Delves: Weekly Reward";
L["ModuleDescription Delves_Dashboard"] = "Show your Great Vault and Gilded Stash progress on the Delves Dashboard.";
L["ModuleName Delves_Automation"] = "Delves: Auto Choose Power";
L["ModuleDescription Delves_Automation"] = "Automatically choose the power dropped by treasures and rares.";
L["Delve Crest Stash No Info"] = "This info is unavailable in your current location.";
L["Delve Crest Stash Requirement"] = "Appears in Tier 11 Bountiful Delves.";
L["Overcharged Delve"] = "Overcharged Delve";
L["Delves History Requires AddOn"] = "Delves history is stored locally by the Plumber AddOn.";
L["Auto Select"] = "Auto Select";
L["Power Borrowed"] = "Power Borrowed";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "WoW Anniversary";
L["ModuleDescription WoWAnniversary"] = "- Summon the corresponding mount easily during the Mount Maniac event.\n\n- Show voting results during the Fashion Frenzy event. ";
L["Voting Result Header"] = "Results";
L["Mount Not Collected"] = MOUNT_JOURNAL_NOT_COLLECTED or "You have not collected this mount.";


--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "Blitz Fix: Underlight Angler";
L["ModuleDescription BlizzFixFishingArtifact"] = "Allow you to view the fishing artifact\'s traits again.";


--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "Quest Item Delete Confirmation";
L["ModuleDescription QuestItemDestroyAlert"] = "Show the associate quest info when you attempt to destroy an item that starts a quest. \n\n|cffd4641cOnly works for items that start quests, not those you obtain after accepting a quest.|r";


--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "Target Spellcasting Info";
L["ModuleDescription SpellcastingInfo"] = "- Show the spell tooltip when hovering over the Cast Bar on the Target Frame.\n\n- Save the monster's abilities that can be later viewed by right-clicking on the Target Frame.";
L["Abilities"] = ABILITIES or "Abilities";
L["Spell Colon"] = "Spell: ";   --Display SpellID
L["Icon Colon"] = "Icon: ";     --Display IconFileID


--Chat Options
L["ModuleName ChatOptions"] = "Chat Channel Options";
L["ModuleDescription ChatOptions"] = "Add Leave buttons to the menu that appears when you right-click on the channel name in the chat window.";
L["Chat Leave"] = CHAT_LEAVE or "Leave";
L["Chat Leave All Characters"] = "Leave On All Characters";
L["Chat Leave All Characters Tooltip"] = "You will automatically leave this channel when you log in on a character.";
L["Chat Auto Leave Alert Format"] = "Do you wish to automatically leave |cffffc0c0[%s]|r on all your characters?";
L["Chat Auto Leave Cancel Format"] = "Auto Leave Disabled for %s. Please use /join command to rejoin the channel.";
L["Auto Leave Channel Format"] = "Auto Leave \"%s\"";
L["Click To Disable"] = "Click to disable";


--NameplateWidget
L["ModuleName NameplateWidget"] = "Nameplate: Keyflame";
L["ModuleDescription NameplateWidget"] = "Show the number of owned Radiant Remnant on the nameplate.";


--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "Group Inviter Info";
L["ModuleDescription PartyInviterInfo"] = "Show the inviter's level and class when you are invited to a group or a guild.";
L["Additional Info"] = "Additional Info";
L["Race"] = RACE or "Race";
L["Faction"] = FACTION or "Faction";
L["Click To Search Player"] = "Search This Player";
L["Searching Player In Progress"] = FRIENDS_FRIENDS_WAITING or "Searching...";
L["Player Not Found"] = ERR_FRIEND_NOT_FOUND or "Player not found.";


--PlayerTitleUI
L["ModuleName PlayerTitleUI"] = "Title Manager";
L["ModuleDescription PlayerTitleUI"] = "Add a search box and a filter to the default Character Pane.";
L["Right Click To Reset Filter"] = "Right click to reset.";
L["Earned"] = ACHIEVEMENTFRAME_FILTER_COMPLETED or "Earned";
L["Unearned"] = "Unearned";
L["Unearned Filter Tooltip"] = "You may see duplicated titles that are unavailable to your faction.";


--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "Waypoint: Event Timer";
L["ModuleDescription BlizzardSuperTrack"] = "Add a timer to your active waypoint if its map pin tooltip has one.";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS or "Unspent Knowledge";
L["ModuleDescription ProfessionsBook"] = "Display the number of your unspent Profession Specialization Knowledge on the Professions Book UI";
L["Unspent Knowledge Tooltip Format"] = "You have |cffffffff%s|r unspent Profession Specialization Knowledge."  --see PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = L["ModuleName ProfessionsBook"];
L["ModuleDescription TooltipProfessionKnowledge"] = "Show the number of your unspent Profession Specialization Knowledge.";
L["Available Knowledge Format"] = "Available Knowledge: |cffffffff%s|r";


--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "Minimap Target";
L["ModuleDescription MinimapMouseover"] = "Alt Click a creature on the Minimap to set it as your target.".."\n\n|cffd4641c- " ..L["Restriction Combat"].."|r";


--BossBanner
L["ModuleName BossBanner"] = "Boss Loot Banner";
L["ModuleDescription BossBanner"] = "Modify the banner that appears on the top of the screen when a player in your group receives a loot.\n\n- Hide when solo.\n\n- Show valuable items only.";
L["BossBanner Hide When Solo"] = "Hide When Solo";
L["BossBanner Hide When Solo Tooltip"] = "Hide the banner if there is only one person (you) in your group.";
L["BossBanner Valuable Item Only"] = "Valuable Items Only";
L["BossBanner Valuable Item Only Tooltip"] = "Only display mounts, class tokens, and items that are marked as Very Rare or Extremely Rare on the banner.";


--AppearanceTab
L["ModuleName AppearanceTab"] = "Appearances Tab";
L["ModuleDescription AppearanceTab"] = "Modify the Appearances Tab in the Warband Collections:\n\n- Reduce GPU load by improving model loading sequence and changing the number of items shown per page. It can reduce the chance of graphics crash when opening this UI.\n\n- Remember the page you visit after changing slots.";


--SoftTargetName
L["ModuleName SoftTargetName"] = "Nameplate: Soft Target";
L["ModuleDescription SoftTargetName"] = "Display the soft target object's name.";
L["SoftTargetName Req Title"] = "|cffd4641cYou need to manually change these settings to make it work:|r";
L["SoftTargetName Req 1"] = "|cffffd100Enable Interact Key|r in Game Options> Gameplay> Controls.";
L["SoftTargetName Req 2"] = "Set CVar |cffffd100SoftTargetIconGameObject|r to |cffffffff1|r";
L["SoftTargetName CastBar"] = "Show Cast Bar";
L["SoftTargetName CastBar Tooltip"] = "Show a radial cast bar on the nameplate.\n\n|cffff4800The addon will not be able to tell which object is your spell's target.|r"
L["SoftTargetName QuestObjective"] = QUEST_LOG_SHOW_OBJECTIVES or "Show Quest Objectives";
L["SoftTargetName QuestObjective Tooltip"] = "Show quest objectives (if any) below the name.";
L["SoftTargetName QuestObjective Alert"] = "This feature requires enabling |cffffffffShow Target Tooltip|r in Game Options> Accessibility> General.";   --See globals: TARGET_TOOLTIP_OPTION
L["SoftTargetName ShowNPC"] = "Include NPC";
L["SoftTargetName ShowNPC Tooltip"] = "If disabled, the name will only appear on interactable Game Objects";


--LegionRemix
L["ModuleName LegionRemix"] = "Legion Remix";
L["ModuleDescription LegionRemix"] = "Legion Remix";
L["Artifact Weapon"] = "Artifact Weapon";
L["Earn X To Upgrade Y Format"] = "Earn another |cffffffff%s|r %s to upgrade %s"; --Example: Earn another 100 Infinite Power to upgrade Artifact Weapon
L["Until Next Upgrade Format"] = "%s until next upgrade";
L["New Trait Available"] = "New trait available.";
L["Rank Increased"] = "Rank Increased";
L["Infinite Knowledge Tooltip"] = "You can obtain Inifite Knowledge by earning certain Legion Remix achievements.";


--ItemUpgradeUI
L["ModuleName ItemUpgradeUI"] = "Item Upgrades: Show Character Pane";
L["ModuleDescription ItemUpgradeUI"] = "Automatically open Character Pane when you interact with an Item Upgrades NPC.";


--Loot UI
L["ModuleName LootUI"] = HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Loot Window";
L["ModuleDescription LootUI"] = "Replace the default Loot Window and provide some optional features:\n\n- Loot items fast.\n\n- Fix Auto Loot failure bug.\n\n- Show a Take All button when looting manually.";
L["Take All"] = "Take All";     --Take all items from a loot window
L["You Received"] = YOU_RECEIVED_LABEL or "You recieved";
L["Reach Currency Cap"] = "Reached currency caps";
L["Sample Item 4"] = "Awesome Epic Item";
L["Sample Item 3"] = "Awesome Rare Item";
L["Sample Item 2"] = "Awesome Uncommon Item";
L["Sample Item 1"] = "Common Item";
L["EditMode LootUI"] =  "Plumber: "..(HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Loot Window");
L["Manual Loot Instruction Format"] = "To temporarily cancel auto loot on a specific pickup, press and hold |cffffffff%s|r key until the loot window appears.";
L["LootUI Option Force Auto Loot"] = "Force Auto Loot";
L["LootUI Option Force Auto Loot Tooltip"] = "Always enable Auto Loot to counter the occasional auto loot failure.";
L["LootUI Option Owned Count"] = "Show Number Of Owned Items";
L["LootUI Option New Transmog"] = "Mark Uncollected Appearance";
L["LootUI Option New Transmog Tooltip"] = "Add a marker %s if you have not collected the item's appearance.";
L["LootUI Option Use Hotkey"] = "Press Key To Take All Items";
L["LootUI Option Use Hotkey Tooltip"] = "While in Manual Loot Mode, press the following hotkey to take all items.";
L["LootUI Option Fade Delay"] = "Fade Out Delay Per Item";
L["LootUI Option Items Per Page"] = "Items Per Page";
L["LootUI Option Items Per Page Tooltip"] = "Adjust the amount of items that can be displayed on one page when receiving loots.\n\nThis option doesn't affect Manual Loot Mode or Edit Mode.";
L["LootUI Option Replace Default"] = "Replace Default Loot Alert";
L["LootUI Option Replace Default Tooltip"] = "Replace the default loot alerts that usually appear above the action bars.";
L["LootUI Option Loot Under Mouse"] = LOOT_UNDER_MOUSE_TEXT or "Open Loot Window at Mouse";
L["LootUI Option Loot Under Mouse Tooltip"] = "While in |cffffffffManual Loot|r Mode, the window will appear under the current mouse location";
L["LootUI Option Use Default UI"] = "Use Default Loot Window";
L["LootUI Option Use Default UI Tooltip"] = "Use WoW\'s default loot window.\n\n|cffff4800Enabling this option nullifies all settings above.|r";
L["LootUI Option Background Opacity"] = "Opacity";
L["LootUI Option Background Opacity Tooltip"] = "Set the background's opacity in Loot Notification Mode.\n\nThis option doesn't affect Manual Loot Mode.";
L["LootUI Option Custom Quality Color"] = "Use Custom Quality Color";
L["LootUI Option Custom Quality Color Tooltip"] = "Use the colors you set in Game Options> Accessibility> Colors."
L["LootUI Option Grow Direction"] = "Grow Upwards";
L["LootUI Option Grow Direction Tooltip 1"] = "When enabled: the bottom left of the window remains still, and new notifications will appear on top of the old ones.";
L["LootUI Option Grow Direction Tooltip 2"] = "When disabled: the top left of the window remains still, and new notifications will appear on bottom of the old ones.";
L["Junk Items"] = "Junk Items";
L["LootUI Option Combine Items"] = "Combine Similar Items";
L["LootUI Option Combine Items Tooltip"] = "Display similar items on a single row. Supported Categories:\n\n- Junk Items\n- Epoch Mementos (Legion Remix)";


--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "Module Info";
L["QuickSlot Error 1"] = "Quick Slot: You have already added this controller.";
L["QuickSlot Error 2"] = "Quick Slot: The controller is missing \"%s\"";
L["QuickSlot Error 3"] = "Quick Slot: A controller with the same key \"%s\" already exists.";


--Plumber Macro
L["PlumberMacro Drive"] = "Plumber D.R.I.V.E. Macro";
L["PlumberMacro Drawer"] = "Plumber Drawer Macro";
L["PlumberMacro DrawerFlag Combat"] = "The drawer will be updated after leaving combat.";
L["PlumberMacro DrawerFlag Stuck"] = "Something went wrong when updating the drawer.";
L["PlumberMacro Error Combat"] = "Unavailable in combat";
L["PlumberMacro Error NoAction"] = "No usable actions";
L["PlumberMacro Error EditMacroInCombat"] = "Cannot edit macros while in combat";
L["Random Favorite Mount"] = "Random Favorite Mount"; --A shorter version of MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT
L["Dismiss Battle Pet"] = "Dismiss Battle Pet";
L["Drag And Drop Item Here"] = "Drag and drop an item here.";
L["Drag To Reorder"] = "Left click and drag to reorder";
L["Click To Set Macro Icon"] = "Ctrl click to set as macro icon";
L["Unsupported Action Type Format"] = "Unsupported action type: %s";
L["Drawer Add Action Format"] = "Add |cffffffff%s|r";
L["Drawer Add Profession1"] = "First Profession";
L["Drawer Add Profession2"] = "Second Profession";
L["Drawer Option Global Tooltip"] = "This setting is shared across all drawer macros.";
L["Drawer Option CloseAfterClick"] = "Close After Clicks";
L["Drawer Option CloseAfterClick Tooltip"] = "Close the drawer after clicking any button in it, regardless of successful or not.";
L["Drawer Option SingleRow"] = "Single Row";
L["Drawer Option SingleRow Tooltip"] = "If checked, align all buttons on the same row instead of 4 items per row.";
L["Drawer Option Hide Unusable"] = "Hide Unusable Actions";
L["Drawer Option Hide Unusable Tooltip"] = "Hide unowned items and unlearned spells.";
L["Drawer Option Hide Unusable Tooltip 2"] = "Consumable items like potions will always be shown."
L["Drawer Option Update Frequently"] = "Update Frequently";
L["Drawer Option Update Frequently Tooltip"] = "Attempt to update the button states whenever there is a change in your bags or spellbooks. Enabling this option may slightly increase resource usage.";


--New Expansion Landing Page
L["ModuleName NewExpansionLandingPage"] = "Expansion Summary";
L["ModuleDescription NewExpansionLandingPage"] = "A UI that displays factions, weekly activities, and raid lockouts. You can open it by:\n\n- Click Khaz Algar Summary button on the minimap.\n\n- Set a hotkey in Game Setting> Keybindings.";
L["Reward Available"] = "Reward Available";  --As brief as possible
L["Paragon Reward Available"] = "Paragon Reward Available";
L["Until Next Level Format"] = "%d until next level";   --Earn x reputation to reach the next level
L["Until Paragon Reward Format"] = "%d until Paragon reward";
L["Instruction Click To View Renown"] = REPUTATION_BUTTON_TOOLTIP_VIEW_RENOWN_INSTRUCTION or "<Click to view Renown>";
L["Not On Quest"] = "You are not on this quest";
L["Factions"] = "Factions";
L["Activities"] = MAP_LEGEND_CATEGORY_ACTIVITIES or "Activities";
L["Raids"] = RAIDS or "Raids";
L["Instruction Track Achievement"] = "<Shift click to track this achievement>";
L["Instruction Untrack Achievement"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift click to stop tracking>";
L["No Data"] = "No data";
L["No Raid Boss Selected"] = "No boss selected";
L["Your Class"] = "(Your Class)";
L["Great Vault"] = DELVES_GREAT_VAULT_LABEL or "Great Vault";
L["Item Upgrade"] = ITEM_UPGRADE or "Item Upgrade";
L["Resources"] = WORLD_QUEST_REWARD_FILTERS_RESOURCES or "Resources";
L["Plumber Experimental Feature Tooltip"] = "An experimental feature in Plumber addon.";
L["Bountiful Delves Rep Tooltip"] = "Opening a Bountiful Coffer has a chance to increase your reputation with this faction.";
L["Warband Weekly Reward Tooltip"] = "You Warband can only receive this reward once per week.";
L["Completed"] = CRITERIA_COMPLETED or "Completed";
L["Filter Hide Completed Format"] = "Hide Completed (%d)";
L["Weeky Reset Format"] = "Weekly Reset: %s";
L["Daily Reset Format"] = "Daily Reset: %s";
L["Ready To Turn In Tooltip"] = "Ready to turn in.";
L["Trackers"] = "Trackers";
L["New Tracker Title"] = "New Tracker";     --Create a new Tracker
L["Edit Tracker Title"] = "Edit Tracker";
L["Type"] = "Type";
L["Select Instruction"] = LFG_LIST_SELECT or "Select";
L["Name"] = "Name";
L["Difficulty"] = LFG_LIST_DIFFICULTY or "Difficulty";
L["All Difficulties"] = "All Difficulties";
L["TrackerType Boss"] = "Boss";
L["TrackerType Instance"] = "Instance";
L["TrackerType Quest"] = "Quest";
L["TrackerType Rare"] = "Rare Creature";
L["TrackerTypePlural Boss"] = "Bosses";
L["TrackerTypePlural Instance"] = "Instances";
L["TrackerTypePlural Quest"] = "Quests";
L["TrackerTypePlural Rare"] = "Rare Creatures";
L["Accountwide"] = "Account-wide";
L["Flag Quest"] = "Flag Quest";
L["Boss Name"] = "Boss name";
L["Instance Or Boss Name"] = "Instance or boss name";
L["Name EditBox Disabled Reason Format"] = "This box will be filled automatically when you enter a valid %s.";
L["Search No Matches"] = CLUB_FINDER_APPLICANT_LIST_NO_MATCHING_SPECS or "No Matches";
L["Create New Tracker"] = "New Tracker";
L["FailureReason Already Exist"] = "This entry already exists.";
L["Quest ID"] = "Quest ID";
L["Creature ID"] = "Creature ID";
L["Edit"] = EDIT or "Edit";
L["Delete"] = DELETE or "Delete";
L["Visit Quest Hub To Log Quests"] = "Visit the quest hub and interact with the quest givers to log today's quests."
L["Quest Hub Instruction Celestials"] = "Visit the August Celestials Quartermaster in Vale of Eternal Blossoms to find out which temple needs your assistance."
L["Unavailable Klaxxi Paragons"] = "Unavailable Klaxxi Paragons:";
L["Weekly Coffer Key Tooltip"] = "The first four weekly caches you earn each week contain a Restored Coffer Key.";
L["Weekly Coffer Key Shards Tooltip"] = "The first four weekly caches you earn each week contain Coffer Key Shards.";
L["Weekly Cap"] = "Weekly Cap";
L["Weekly Cap Reached"] = "Weekly cap reached.";
L["Instruction Right Click To Use"] = "<Right Click to Use>";


--Generic
L["Total Colon"] = FROM_TOTAL or "Total:";
L["Reposition Button Horizontal"] = "Move Horizontally";   --Move the window horizontally
L["Reposition Button Vertical"] = "Move Vertically";
L["Reposition Button Tooltip"] = "Left click and drag to move the window";
L["Font Size"] = FONT_SIZE or "Font Size";
L["Icon Size"] = "Icon Size";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Reset To Default Position";
L["Renown Level Label"] = "Renown ";  --There is a space
L["Paragon Reputation"] = "Paragon";
L["Level Maxed"] = "(Maxed)";   --Reached max level
L["Current Colon"] = ITEM_UPGRADE_CURRENT or "Current:";
L["Unclaimed Reward Alert"] = WEEKLY_REWARDS_UNCLAIMED_TITLE or "You have unclaimed rewards";
L["Uncollected Set Counter Format"] = "You have |cffffffff%d|r uncollected transmog |4set:sets;.";


--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "Always Enable New Features";
L["ModuleDescription EnableNewByDefault"] = "Always enable newly added features.\n\n*You will see a notification in the chat window when a new module is enabled this way.";
L["New Feature Auto Enabled Format"] = "New Module %s has been enabled.";
L["Click To See Details"] = "Click to see details";




-- !! Do NOT translate the following entries
L["currency-2706"] = "Whelpling";
L["currency-2707"] = "Drake";
L["currency-2708"] = "Wyrm";
L["currency-2709"] = "Aspect";

L["currency-2914"] = "Weathered";
L["currency-2915"] = "Carved";
L["currency-2916"] = "Runed";
L["currency-2917"] = "Gilded";

L["Scenario Delves"] = "Delves";
L["GameObject Door"] = "Door";
L["Delve Chest 1 Rare"] = "Bountiful Coffer";   --We'll use the GameObjectID once it shows up in the database

L["Season Maximum Colon"] = "Season Maximum:";  --CURRENCY_SEASON_TOTAL_MAXIMUM
L["Item Changed"] = "was changed to";   --CHANGED_OWN_ITEM
L["Completed CHETT List"] = "Completed C.H.E.T.T. List";
L["Devourer Attack"] = "Devourer Attack";
L["Restored Coffer Key"] = "Restored Coffer Key";
L["Coffer Key Shard"] = "Coffer Key Shard";
L["Epoch Mementos"] = "Epoch Mementos";     --See currency:3293


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "Bountiful Delves";
L["Special Assignment"] = "Special Assignments";

L["Match Pattern Gold"] = "([%d%,]+) Gold";
L["Match Pattern Silver"] = "([%d]+) Silver";
L["Match Pattern Copper"] = "([%d]+) Copper";

L["Match Pattern Rep 1"] = "Your Warband's reputation with (.+) increased by ([%d%,]+)";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Pattern Rep 2"] = "Reputation with (.+) increased by ([%d%,]+)";   --FACTION_STANDING_INCREASED

L["Match Pattern Item Level"] = "^Item Level (%d+)";
L["Match Pattern Item Upgrade Tooltip"] = "^Upgrade Level: (.+) (%d+)/(%d+)";  --See ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
L["Upgrade Track 1"] = "Adventurer";
L["Upgrade Track 2"] = "Explorer";
L["Upgrade Track 3"] = "Veteran";
L["Upgrade Track 4"] = "Champion";
L["Upgrade Track 5"] = "Hero";
L["Upgrade Track 6"] = "Myth";