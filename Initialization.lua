local VERSION_TEXT = "v1.1.5";
local VERSION_DATE = 1701315962;


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
    DruidModelFix = true,               --Remove after 10.2.0
    GossipFrameMedal = true,
    EmeraldBountySeedList = true,       --Show a list of Dreamseed when appoaching Emarad Bounty Soil
    WorldMapPinSeedPlanting = true,     --Aditional Map Pin: Dreamseed
    AlternativePlayerChoiceUI = true,   --Revamp PlayerChoiceFrame for Dreamseed Nurturing
    HandyLockpick = true,               --Right-click to lockpick inventory items (Rogue/Mechagnome)

    --PlayerChoiceFrameToken = true,      --First implementation in 10.2.0  --We instead revamp the who PlayerChoiceFrame
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