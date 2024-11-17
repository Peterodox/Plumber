local VERSION_TEXT = "v1.4.8";
local VERSION_DATE = 1731800000;


local addonName, addon = ...

local L = {};       --Locale
local API = {};     --Custom APIs used by this addon
local DB;

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
    DB[dbKey] = value;
    addon.CallbackRegistry:Trigger("SettingChanged."..dbKey, value, userInput);
end
addon.SetDBValue = SetDBValue;

local function GetDBBool(dbKey)
    return DB[dbKey] == true
end
addon.GetDBBool = GetDBBool;


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
    TooltipChestKeys = true,            --Show keys that unlocked the current chest or door
    TooltipRepTokens = true,            --Show faction info for items that grant rep
    PlayerChoiceFrameToken = true,      --Add owned token count to PlayerChoiceFrame
    ExpansionLandingPage = true,        --Display extra info on the ExpansionLandingPage
    Delves_SeasonProgress = true,       --Display Seaonal Journey changes on a progress bar
    WoWAnniversary = true,              --QuickSlot for Mount Maniac Event
        VotingResultsExpanded = true,
    BlizzFixFishingArtifact = true,     --Fix Fishing Artifact Traits Not Showing bug
    QuestItemDestroyAlert = true,       --Show related quest info when destroying a quest-starting item

    --Custom Loot Window
    LootUI = false,
        LootUI_FontSize = 14,
        LootUI_ShowItemCount = false,
        LootUI_UseHotkey = true,
        LootUI_HotkeyName = "E",
        LootUI_ForceAutoLoot = true,
        LootUI_NewTransmogIcon = true,
        LootUI_FadeDelayPerItem = 0.25,
        LootUI_ReplaceDefaultAlert = false,
        LootUI_LootUnderMouse = false;
        LootUI_UseStockUI = false,


    --Unified Map Pin System
    WorldMapPin_TWW = true,             --Master Switch for TWW Map Pins
        WorldMapPin_TWW_Delve = true,   --Show Bountiful Delves on continent map
        WorldMapPin_TWW_Quest = true,   --Show Special Assignment on continent map


    --Modify default interface behavior:
    BlizzFixEventToast = true,          --Make Toast non-interactable
    MerchantPrice = false;              --Merchant Price (Alt Currency) Overview, gray insufficient items


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


    --Declared elsewhere:
        --DreamseedChestABTesting = math.random(100) >= 50


    --Deprecated:
    --DruidModelFix = true,               --Fixed by Blizzard in 10.2.0
    --BlizzFixWardrobeTrackingTip = true, --Hide Wardrobe tip that cannot be disabled   --Tip removed by Blizzard
};

local function LoadDatabase()
    PlumberDB = PlumberDB or {};
    DB = PlumberDB;

    for dbKey, value in pairs(DefaultValues) do
        if DB[dbKey] == nil then
            DB[dbKey] = value;
        end
    end

    for dbKey, value in pairs(DB) do
        addon.CallbackRegistry:Trigger("SettingChanged."..dbKey, value);
    end

    if not DB.installTime or type(DB.installTime) ~= "number" then
        DB.installTime = VERSION_DATE;
    end

    DefaultValues = nil;
end

local EL = CreateFrame("Frame");
EL:RegisterEvent("ADDON_LOADED");

EL:SetScript("OnEvent", function(self, event, ...)
    local name = ...
    if name == addonName then
        self:UnregisterEvent(event);
        LoadDatabase();
    end
end);


do
    local tocVersion = select(4, GetBuildInfo());
    tocVersion = tonumber(tocVersion or 0);

    local function IsToCVersionEqualOrNewerThan(targetVersion)
        return tocVersion >= targetVersion
    end
    addon.IsToCVersionEqualOrNewerThan = IsToCVersionEqualOrNewerThan;
end