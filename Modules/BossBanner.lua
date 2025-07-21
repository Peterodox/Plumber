-- BossBanner Revamp
-- Hide player name when solo
-- Loot Filter


local _, addon = ...
local API = addon.API;
local GetDBBool = addon.GetDBBool;


local GetInstanceInfo = GetInstanceInfo;
local GetNumGroupMembers = GetNumGroupMembers;
local GetItemTransmogInfo = C_TransmogCollection.GetItemInfo;
local GetItemInfoInstant = C_Item.GetItemInfoInstant;
local GetItemQualityByID = C_Item.GetItemQualityByID;


local BossBanner = BossBanner;
local Old_BossBanner_OnEvent = BossBanner_OnEvent;


local ValuableLoot = {};


local EL = CreateFrame("Frame", nil, UIParent);

local function New_BossBanner_OnEvent(self, event, ...)
    local proceed;
    if event == "ENCOUNTER_LOOT_RECEIVED" then
        if EL.shouldShowLootFrame then
            local encounterID, itemID, itemLink, quantity, playerName, className = ...;
            if EL.valuableItemOnly then
                if itemID then
                    if ValuableLoot[itemID] then
                        proceed = true;
                    elseif GetItemQualityByID(itemID) == 5 then
                        proceed = true;
                    else
                        local _, _, _, _, _, classID, subClassID = GetItemInfoInstant(itemID);
                        if (classID == 15 and (subClassID == 5 or subClassID == 2)) or (classID == 5 and subClassID == 2) then
                            --Mount, Pet, Context Token (Curio)
                            proceed = true;
                        end
                    end
                end
            else
                proceed = true;
            end
        end
    else
        proceed = true;
    end

    if proceed then
        Old_BossBanner_OnEvent(BossBanner, event, ...);
    end
end


function EL:EnableModule(state)
    if state and (not self.enabled) then
        self.enabled = true;
        self:RegisterEvent("BOSS_KILL");
        self:SetScript("OnEvent", self.OnEvent);
        if BossBanner and Old_BossBanner_OnEvent then
            BossBanner:SetScript("OnEvent", New_BossBanner_OnEvent);
        end
    elseif (not state) and self.enabled then
        self.enabled = false;
        self:UnregisterEvent("BOSS_KILL");
        self:SetScript("OnEvent", nil);
        if BossBanner and Old_BossBanner_OnEvent then
            BossBanner:SetScript("OnEvent", Old_BossBanner_OnEvent);
        end
    end
end

function EL.LoadSettings()
    local enabled = GetDBBool("BossBanner_MasterSwitch");
    EL:EnableModule(enabled)
    EL.hideLootWhenSolo = enabled and GetDBBool("BossBanner_HideLootWhenSolo");
    EL.valuableItemOnly = enabled and GetDBBool("BossBanner_ValuableItemOnly");
    --print(EL.enabled, EL.hideLootWhenSolo, EL.valuableItemOnly);
end

function EL:OnEvent(event, ...)
    if event == "BOSS_KILL" then
        local encounterID, name = ...;
        self.encounterID = encounterID;
        self.shouldShowLootFrame = not (self.hideLootWhenSolo and (GetNumGroupMembers() <= 1));
        self:StartEndCountdown();
    elseif event == "ENCOUNTER_LOOT_RECEIVED" then
        --Unused
        local encounterID, itemID, itemLink, quantity, playerName, className = ...;
        local _, instanceType = GetInstanceInfo();
        if encounterID == self.encounterID and (instanceType == "party" or instanceType == "raid") and itemLink then
            local _, itemModifiedAppearanceID = GetItemTransmogInfo(itemLink);
            if itemModifiedAppearanceID and self.recentlyAddedSources[itemModifiedAppearanceID] then
                self.recentlyAddedSources[itemModifiedAppearanceID] = false;
            end
        end
    elseif event == "TRANSMOG_COLLECTION_SOURCE_ADDED" then
        --Unused
        --Sometimes fires after CHAT_MSG_LOOT, but usually before
        local itemModifiedAppearanceID = ...;
        if not self.recentlyAddedSources then
            self.recentlyAddedSources = {};
        end
        self.recentlyAddedSources[itemModifiedAppearanceID] = true;
    end
end

function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;

    if self.t > 30 then
        self:SetScript("OnUpdate", nil);
        self:WipeQueue();
        if BossBanner and (not BossBanner:IsShown()) then
            --wipe pendingLoot
            API.CloseBossBanner();
        end
    end
end

function EL:WipeQueue()
    self:UnregisterEvent("ENCOUNTER_LOOT_RECEIVED");
    self:UnregisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED");
    self.recentlyAddedSources = nil;
end

function EL:StartEndCountdown()
    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate);
end


--[[
function TTTTest()
    local self = BossBanner;
    local BB_STATE_LOOT_EXPAND = 4;
    local BB_STATE_LOOT_INSERT = 5;
    local BB_MAX_LOOT = 7;
    local encounterID = 2480;

    local function BossBanner_IsExclusiveQueued()
        return true
    end

    TopBannerManager_Show(self, { encounterID = encounterID, name = "Illidan Stormrage", mode = "KILL" }, BossBanner_IsExclusiveQueued)

    if true then
        for i = 1, BB_MAX_LOOT do
            local data = { itemID = 195480, quantity = 1, playerName = "Peter", className = "ROGUE", itemLink = "item:195480" };
            tinsert(self.pendingLoot, data);
            -- check state
            if ( self.animState == BB_STATE_LOOT_INSERT and self.lootShown < BB_MAX_LOOT ) then
                -- show it now
                BossBanner_SetAnimState(self, BB_STATE_LOOT_EXPAND);
            elseif ( not self.animState and self.lootShown == 0 ) then
                -- banner is not displaying and have not done loot for this encounter yet
                -- TODO: animate in kill banner
                TopBannerManager_Show(self, { encounterID = encounterID, name = nil, mode = "LOOT" }, BossBanner_IsExclusiveQueued);
            end
        end
    end
end
--]]


do  --Module Registry
    local L = addon.L;

    local moduleData = {
        dbKey = "BossBanner_MasterSwitch",
        name = L["ModuleName BossBanner"],
        description = L["ModuleDescription BossBanner"],
        toggleFunc = EL.LoadSettings,
        categoryID = 5,
        uiOrder = 1,
        moduleAddedTime = 1753100000,

        subOptions = {
            {
                dbKey = "BossBanner_HideLootWhenSolo",
                name = L["BossBanner Hide When Solo"],
                description = L["BossBanner Hide When Solo Tooltip"],
                toggleFunc = EL.LoadSettings,
            },

            {
                dbKey = "BossBanner_ValuableItemOnly",
                name = L["BossBanner Valuable Item Only"],
                description = L["BossBanner Valuable Item Only Tooltip"],
                toggleFunc = EL.LoadSettings,
            },
        };
    };

    addon.ControlCenter:AddModule(moduleData);
end


do  --ValuableLoot
    --Extremely Rare: https://wago.tools/db2/JournalEncounterItem?filter%5BFlags%5D=0x10&page=1
    --Very Rare:      https://wago.tools/db2/JournalEncounterItem?filter%5BFlags%5D=0x8&page=1

    ValuableLoot = {
        [195480] = true,
        [194301] = true,
        [195526] = true,
        [195527] = true,
        [202612] = true,
        [204202] = true,
        [204211] = true,
        [204201] = true,
        [202569] = true,
        [204465] = true,
        [205145] = true,
        [204696] = true,
        [205140] = true,
        [205144] = true,
        [205036] = true,
        [204975] = true,
        [204968] = true,
        [210170] = true,
        [210169] = true,
        [210175] = true,
        [207171] = true,
        [208614] = true,
        [207174] = true,
        [208616] = true,
        [210214] = true,
        [210644] = true,
        [210670] = true,
        [219877] = true,
        [225577] = true,
        [225578] = true,
        [225574] = true,
        [225548] = true,
        [226683] = true,
        [223097] = true,
        [224435] = true,
        [223048] = true,
        [223144] = true,
        [226190] = true,
        [231265] = true,
        [228844] = true,
        [232526] = true,
        [232804] = true,
        [243365] = true,
        [243305] = true,
        [243306] = true,
        [243308] = true,
        [243307] = true,
        [206955] = true,
        [208216] = true,
        [210536] = true,
        [224147] = true,
        [204255] = true,
        [207728] = true,
        [236960] = true,
    };
end