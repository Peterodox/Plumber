local VERSION_TEXT = "v1.0.4";
local VERSION_DATE = 1696553418;


local addonName, addon = ...

local L = {};       --Locale
local API = {};     --Custom APIs used by this addon

addon.L = L;
addon.API = API;
addon.VERSION_TEXT = VERSION_TEXT;

local DefaultValues = {
    AutoJoinEvents = true,
    BackpackItemTracker = true,
    DruidModelFix = true,               --Remove after 10.2.0
    GossipFrameMedal = true,
    PlayerChoiceFrameToken = true,      --First implementation in 10.2.0
    EmeraldBountySeedList = true,       --Show a list of Dreamseed when appoaching Emarad Bounty Soil
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
    local tocVersion = select(4, GetBuildInfo());
    addon.IsGame_10_2_0 = tocVersion and tocVersion >= 100200
end