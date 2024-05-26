local VERSION_TEXT = "v1.2.9";
local VERSION_DATE = 1716689000;


local addonName, addon = ...

local L = {};       --Locale
local API = {};     --Custom APIs used by this addon

addon.L = L;
addon.API = API;
addon.VERSION_TEXT = VERSION_TEXT;

local DefaultValues = {
    AutoJoinEvents = true,
    BackpackItemTracker = true,
        HideZeroCountItem = true,
        ConciseTokenTooltip = true,
        TrackItemUpgradeCurrency = true,
        TrackerBarInsideSeparateBag = false,
    GossipFrameMedal = true,
    EmeraldBountySeedList = true,       --Show a list of Dreamseed when appoaching Emarad Bounty Soil
    WorldMapPinSeedPlanting = true,     --Aditional Map Pin: Dreamseed
    AlternativePlayerChoiceUI = true,   --Revamp PlayerChoiceFrame for Dreamseed Nurturing
    HandyLockpick = true,               --Right-click to lockpick inventory items (Rogue/Mechagnome)
    Technoscryers = true,               --Show Technoscryers on QuickSlot (Azerothian Archives World Quest)
    TillersFarm = true,

    --Modify default interface behavior:
    BlizzFixEventToast = true,          --Make Toast non-interactable

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

    --Declared elsewhere:
        --DreamseedChestABTesting = math.random(100) >= 50

    --Deprecated:
    --DruidModelFix = true,               --Fixed by Blizzard in 10.2.0
    --PlayerChoiceFrameToken = true,      --First implementation in 10.2.0  --We instead revamp the who PlayerChoiceFrame
    --BlizzFixWardrobeTrackingTip = true, --Hide Wardrobe tip that cannot be disabled   --Tip removed by Blizzard
};

local function LoadDatabase()
    PlumberDB = PlumberDB or {};
    local db = PlumberDB;

    for dbKey, value in pairs(DefaultValues) do
        if db[dbKey] == nil then
            db[dbKey] = value;
        end
    end

    if not db.installTime or type(db.installTime) ~= "number" then
        db.installTime = VERSION_DATE;
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
    addon.IsGame_10_2_0 = true;

    local tocVersion = select(4, GetBuildInfo());
    addon.IsGame_10_2_0 = tocVersion and tocVersion >= 100200
end