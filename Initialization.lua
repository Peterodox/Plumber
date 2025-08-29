local VERSION_TEXT = "v1.7.4";
local VERSION_DATE = 1756400000;


local addonName, addon = ...

local L = {};       --Locale
local API = {};     --Custom APIs used by this addon
local DB;
local DB_PC;        --Per Character

PlumberGlobals = {};

addon.L = L;
addon.API = API;
addon.VERSION_TEXT = VERSION_TEXT;


local CallbackRegistry = {};
CallbackRegistry.events = {};
addon.CallbackRegistry = CallbackRegistry;

local tinsert = table.insert;
local type = type;
local ipairs = ipairs;

--[[
    callbackType:
        1. Function func(owner)
        2. Method owner:func()
--]]

function CallbackRegistry:Register(event, func, owner)
    if not self.events[event] then
        self.events[event] = {};
    end

    local callbackType;

    if type(func) == "string" then
        callbackType = 2;
    else
        callbackType = 1;
    end

    tinsert(self.events[event], {callbackType, func, owner})
end

function CallbackRegistry:Trigger(event, ...)
    if self.events[event] then
        for _, cb in ipairs(self.events[event]) do
            if cb[1] == 1 then
                if cb[3] then
                    cb[2](cb[3], ...);
                else
                    cb[2](...);
                end
            else
                cb[3][cb[2]](cb[3], ...);
            end
        end
    end
end

function CallbackRegistry:RegisterSettingCallback(dbKey, func, owner)
    self:Register("SettingChanged."..dbKey, func, owner);
end


local function GetDBValue(dbKey)
    return DB[dbKey]
end
addon.GetDBValue = GetDBValue;

local function SetDBValue(dbKey, value, userInput)
    if DB then
        DB[dbKey] = value;
        addon.CallbackRegistry:Trigger("SettingChanged."..dbKey, value, userInput);
    end
end
addon.SetDBValue = SetDBValue;

local function GetDBBool(dbKey)
    return DB[dbKey] == true
end
addon.GetDBBool = GetDBBool;


local function GetPersonalData(dbKey)
    --From SavedVariablesPerCharacter
    return DB_PC[dbKey]
end
addon.GetPersonalData = GetPersonalData;

local function SetPersonalData(dbKey, value, userInput)
    DB_PC[dbKey] = value;
end
addon.SetPersonalData = SetPersonalData;



local DefaultValues = {
    AutoJoinEvents = true,
    BackpackItemTracker = true,
        HideZeroCountItem = true,
        ConciseTokenTooltip = true,
        TrackItemUpgradeCurrency = true,
        TrackHolidayItem = true,
        TrackerBarInsideSeparateBag = false,
    GossipFrameMedal = true,
    EmeraldBountySeedList = true,       --Show a list of Dreamseed when appoaching Emarad Bounty Soil
    WorldMapPinSeedPlanting = true,     --Aditional Map Pin: Dreamseed
    AlternativePlayerChoiceUI = true,   --Revamp PlayerChoiceFrame for Dreamseed Nurturing
    HandyLockpick = true,               --Right-click to lockpick inventory items (Rogue/Mechagnome)
    Technoscryers = true,               --Show Technoscryers on QuickSlot (Azerothian Archives World Quest)
    PlayerChoiceFrameToken = true,      --Add owned token count to PlayerChoiceFrame
    ExpansionLandingPage = true,        --Display extra info on the ExpansionLandingPage
    Delves_Dashboard = true,            --Show Great Vault Progress on DelvesDashboardFrame
    Delves_SeasonProgress = true,       --Display Seaonal Journey changes on a progress bar
    WoWAnniversary = true,              --QuickSlot for Mount Maniac Event
        VotingResultsExpanded = true,
    BlizzFixFishingArtifact = true,     --Fix Fishing Artifact Traits Not Showing bug
    QuestItemDestroyAlert = true,       --Show related quest info when destroying a quest-starting item
    SpellcastingInfo = false,           --Show the spell info when hovering over target/focus cast bars. Logging target spells and displayed it on UnitPopupMenu
    ChatOptions = true,                 --Add Leave button to Channel Context Menu
    NameplateWidget = true,             --Show required items on nameplate widget set
    PartyInviterInfo = false,           --Show the inviter's level and class
        PartyInviter_Race = false,
        PartyInviter_Faction = false,
    PlayerTitleUI = false,              --Add search box and filter to TitleManagerPane
    Plunderstore = true,
        Plunderstore_HideCollected = true,
    BlizzardSuperTrack = false,         --Add timer to the SuperTrackedFrame when tracking a POI with time format
    ProfessionsBook = true,             --Show unspent points on ProfessionsBookFrame
    EditModeShowPlumberUI = true,
    LandingPageSwitch = true,           --Right click on ExpansionLandingPageMinimapButton to open a menu to access mission report
    SoftTargetName = false,             --Show object's name on SoftTargetFrame

    AppearanceTab = false,              --Adjust Appearance Tab models to reduce GPU usage spike
        AppearanceTab_ModelCount = 1,


    --Tooltip
    TooltipChestKeys = true,            --Show keys that unlocked the current chest or door
    TooltipRepTokens = true,            --Show faction info for items that grant rep
    TooltipSnapdragonTreats = true,     --Show info on Snapdragon Treats (An item that changes this mount's color)
    TooltipItemReagents = false,        --For items with "use to combine": show the reagent count
    TooltipProfessionKnowledge = true,  --Show unspent points on GameTooltip
    TooltipDelvesItem = true,           --Show weekly Coffer Key cap on chest tooltip


    --Reduction
    BossBanner_MasterSwitch = false,
        BossBanner_HideLootWhenSolo = true,
        BossBanner_ValuableItemOnly = true,


    --New Expansion Landing Page
    NewExpansionLandingPage = true,
        LandingPage_Activity_HideCompleted = true,
        LandingPage_Raid_CollapsedAchievement = false,
        LandingPage_AdvancedTooltip = true,


    --Custom Loot Window
    LootUI = false,
        LootUI_FontSize = 12,
        LootUI_FadeDelayPerItem = 0.25,
        LootUI_ItemsPerPage = 6,
        LootUI_BackgroundAlpha = 0.5,
        LootUI_ShowItemCount = false,
        LootUI_NewTransmogIcon = true,
        LootUI_UseCustomColor = false,
        LootUI_GrowUpwards = false,
        LootUI_ForceAutoLoot = true,
        LootUI_LootUnderMouse = false,
        LootUI_UseHotkey = true,
        LootUI_HotkeyName = "E",
        LootUI_ReplaceDefaultAlert = false,
        LootUI_UseStockUI = false,


    --Unified Map Pin System
    WorldMapPin_TWW = true,             --Master Switch for TWW Map Pins
        WorldMapPin_Size = 1,           --1: Default
        WorldMapPin_TWW_Delve = true,   --Show Bountiful Delves on continent map
        WorldMapPin_TWW_Quest = true,   --Show Special Assignment on continent map


    --Modify default interface behavior:
    BlizzFixEventToast = true,          --Make Toast non-interactable
    MerchantPrice = false,              --Merchant Price (Alt Currency) Overview, gray insufficient items


    --In-game Navigation: Use waypoint (Super Tracking) to navigate players. Generally default to false, since it will mute WoW's own SuperTrackedFrame
    Navigator_MasterSwitch = true,      --Decide if using our SuperTrackedFrame or the default one
        Navigator_Dreamseed = false,


    --Talking Head Revamp
    TalkingHead_MasterSwitch = false,
        TalkingHead_FontSize = 100,         --% Multiply default QuestFont Height
        TalkingHead_InstantText = false,
        TalkingHead_TextOutline = false,
        TalkingHead_HideInInstance = false,
        TalkingHead_HideWorldQuest = false,
        TalkingHead_BelowWorldMap = false,


    --QuickSlot
        QuickSlotHighContrastMode = false,


    --SpellFlyout DrawerMacro
        SpellFlyout_CloseAfterClick = true,
        SpellFlyout_SingleRow = false,
        SpellFlyout_HideUnusable = false,
        SpellFlyout_UpdateFrequently = false,


    --LegionRemix
    LegionRemix = true,


    EnableNewByDefault = false,             --Always enable newly added features


    --Declared elsewhere:
        --DreamseedChestABTesting = math.random(100) >= 50


    --Deprecated:
    --DruidModelFix = true,                 --Fixed by Blizzard in 10.2.0
    --BlizzFixWardrobeTrackingTip = true,   --Hide Wardrobe tip that cannot be disabled   --Tip removed by Blizzard
    --MinimapMouseover = false,             --Ridden with compatibility issue
};


local NeverEnableByDefault = {
    AppearanceTab = true,
};


local function LoadDatabase()
    PlumberDB = PlumberDB or {};
    PlumberStorage = PlumberStorage or {};  --Save large data (Spell)
    PlumberDB_PC = PlumberDB_PC or {};

    DB = PlumberDB;
    DB_PC = PlumberDB_PC;

    local alwaysEnableNew = DB.EnableNewByDefault or false;
    local newDBKeys = {};

    for dbKey, value in pairs(DefaultValues) do
        if DB[dbKey] == nil then
            DB[dbKey] = value;
            if alwaysEnableNew and type(value) == "boolean" and not NeverEnableByDefault[dbKey] then
                --Not all Booleans are the master switch of individual module
                --Send these new ones to ControlCenter
                --Test: /run PlumberDB = {EnableNewByDefault = true}
                newDBKeys[dbKey] = true;
            end
        end
    end

    for dbKey, value in pairs(DB) do
        CallbackRegistry:Trigger("SettingChanged."..dbKey, value);
    end

    if not DB.installTime or type(DB.installTime) ~= "number" then
        DB.installTime = VERSION_DATE;
    end

    DefaultValues = nil;

    CallbackRegistry:Trigger("NewDBKeysAdded", newDBKeys);
    CallbackRegistry:Trigger("DBLoaded", DB);
end


local EL = CreateFrame("Frame");
EL:RegisterEvent("ADDON_LOADED");
EL:RegisterEvent("PLAYER_ENTERING_WORLD");

EL:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            self:UnregisterEvent(event);
            LoadDatabase();
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent(event);
        if PlayerGetTimerunningSeasonID then
            local seasonID = PlayerGetTimerunningSeasonID();
            if seasonID and seasonID > 0 then
                CallbackRegistry:Trigger("TimerunningSeason", seasonID);
            end
        end
    end
end);


do
    local tocVersion = select(4, GetBuildInfo());
    tocVersion = tonumber(tocVersion or 0);

    local function IsToCVersionEqualOrNewerThan(targetVersion)
        return tocVersion >= targetVersion
    end
    addon.IsToCVersionEqualOrNewerThan = IsToCVersionEqualOrNewerThan;

    addon.IS_CLASSIC = C_AddOns.GetAddOnMetadata(addonName, "X-Flavor") ~= "retail";

    addon.IS_MOP = C_AddOns.GetAddOnMetadata(addonName, "X-Expansion") == "MOP";
end