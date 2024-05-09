local _, addon = ...
local API = addon.API;
local QuickSlot = addon.QuickSlot;

local GetMinimapZoneText = GetMinimapZoneText;
local GetUnitCreatureID = API.GetUnitCreatureID;
local GetItemSpellID = API.GetItemSpellID;
local GetItemCount = C_Item.GetItemCount or GetItemCount;
local GetBuffDataByIndex = C_UnitAuras.GetBuffDataByIndex;

local RANCH_NAME = API.GetZoneName(6039);
local QUICKSLOT_NAME = "tillers";
local TILLED_SOIL_ID = 58563;
local NEED_WATER_ID = 63163;
local SPELL_PARCHED = 115824;


local SEED_ITEM = {
    --{79104},    --Watering Can
    {79104, 0, 79102, 89328, 80590, 80592, 80594, 80593, 80591, 89329, 80595, 89326},
    {0, 0, 85216, 85217, 89202, 85215, 89233, 89197},
    {0, 0, 85267, 85268, 85269},
};

local PLANT_NEED_WATER = {};

do
    local CREATURE_PARCHED = {
        65919, 59987, 58565, 66111, 63133, 65988, 63183,
        63248, 66015, 63227, 63163, 65967, 66042, 66127,
        63263, 66005, 66083,
    };

    for _, creatureID in ipairs(CREATURE_PARCHED) do
        PLANT_NEED_WATER[creatureID] = true;
    end
end


local function DoesPlantNeedWater()
    local aura = GetBuffDataByIndex("target", 1);
    if aura and aura.spellId == SPELL_PARCHED then
        return true
    end
end

local ZoneTriggerModule;
local EL = CreateFrame("Frame");

function EL:StopZoneTrigger()
    if ZoneTriggerModule then
        ZoneTriggerModule:SetEnabled(false);
    end
end

function EL:SetupZoneTrigger(maps)
    if not ZoneTriggerModule then
        local module = API.CreateZoneTriggeredModule("halfhill");
        ZoneTriggerModule = module;
        ZoneTriggerModule:SetValidZones(376);   --Valley of Four Winds

        local function OnEnterZoneCallback()
            EL:ListenEvents(true);
        end

        local function OnLeaveZoneCallback()
            EL:ListenEvents(false);
        end

        module:SetEnterZoneCallback(OnEnterZoneCallback);
        module:SetLeaveZoneCallback(OnLeaveZoneCallback);
    end

    ZoneTriggerModule:SetEnabled(true);
    ZoneTriggerModule:Update();
end

function EL:UpdateZone()
    local inZone = GetMinimapZoneText() == RANCH_NAME;
    if inZone and not self.inZone then
        self.inZone = true;
        self:RegisterEvent("PLAYER_TARGET_CHANGED");
        self:RegisterEvent("PLAYER_REGEN_DISABLED");
        self:RegisterEvent("PLAYER_REGEN_ENABLED");
    elseif (not inZone) and self.inZone then
        self.inZone = false;
        self:UnregisterEvent("PLAYER_TARGET_CHANGED");
        self:UnregisterEvent("PLAYER_REGEN_DISABLED");
        self:UnregisterEvent("PLAYER_REGEN_ENABLED");
        self:OnClearSoil();
    end
end

function EL:ListenEvents(state)
    if state then
        self:UpdateZone();
        self:RegisterEvent("ZONE_CHANGED");
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
        self:SetScript("OnEvent", self.OnEvent);
    else
        self.inZone = false;
        self:UnregisterEvent("ZONE_CHANGED");
        self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
        self:UnregisterEvent("PLAYER_TARGET_CHANGED");
        self:UnregisterEvent("PLAYER_REGEN_DISABLED");
        self:UnregisterEvent("PLAYER_REGEN_ENABLED");
        self:SetScript("OnEvent", nil);
        self:OnClearSoil();
    end
end

function EL:OnTargetSoil(creatureID)
    --if self.isTargetingSoil then return end;
    self.isTargetingSoil = true;

    self:ShowQuickSlot(true, creatureID);
end

function EL:OnClearSoil()
    if not self.isTargetingSoil then return end;
    self.isTargetingSoil = false;

    self:ShowQuickSlot(false);
end

function EL:ShowQuickSlot(state, creatureID)
    if state then
        local itemIDs = {};
        local spellIDs = {};
        local spellID;
        local n = 0;

        local needWater = PLANT_NEED_WATER[creatureID];
        local hasBug = false;

        if needWater then
            n = n + 1;
            itemIDs[n] = 79104;
            spellIDs[n] = GetItemSpellID(79104) or 0;
        else
            local showAll = false;
            local count;
            for tier, items in ipairs(SEED_ITEM) do
                for i, itemID in ipairs(items) do
                    count = GetItemCount(itemID);
                    if showAll or count > 0 then
                        n = n + 1;
                        spellID = (itemID > 0 and GetItemSpellID(itemID)) or 0;
                        itemIDs[n] = itemID;
                        spellIDs[n] = spellID;
                    end
                end

                n = n + 1;
                itemIDs[n] = -1;
                spellIDs[n] = 0;
            end
        end

        local isCasting = true;     --false means the it's a channeling spell
        QuickSlot:SetButtonData(itemIDs, spellIDs, QUICKSLOT_NAME, isCasting);
        QuickSlot:ShowUI();
        QuickSlot:SetHeaderText("", true);
        QuickSlot:SetDefaultHeaderText("");
    else
        QuickSlot:RequestCloseUI(QUICKSLOT_NAME);
    end
end

function EL:OnEvent(event, ...)
    if event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
        self:UpdateZone();
    elseif event == "PLAYER_TARGET_CHANGED" then
        local creatureID = GetUnitCreatureID("target");
        if creatureID and (creatureID == TILLED_SOIL_ID or PLANT_NEED_WATER[creatureID]) then
            self:OnTargetSoil(creatureID);
        else
            self:OnClearSoil();
        end
    end
end


local function EnableModule(state)
    if state then
        EL:SetupZoneTrigger();
    else
        EL:StopZoneTrigger();
        EL:ListenEvents(false);
    end
end

do
    local moduleData = {
        name = addon.L["ModuleName TillersFarm"],
        dbKey = "TillersFarm",
        description = addon.L["ModuleDescription TillersFarm"],
        toggleFunc = EnableModule,
        categoryID = 2,
        uiOrder = 10020701,
        moduleAddedTime = 1713000000,
    };

    addon.ControlCenter:AddModule(moduleData);
end


function GetEndingTime()
    --132726
    local aura = C_UnitAuras.GetBuffDataByIndex("target", 1, "HELPFUL");
    if aura and aura.spellId == 132726 then
        local currentTime = GetTime();
        local endTime = aura.expirationTime;
        print(API.SecondsToTime(endTime - currentTime));
    end
end

do
    --C_TradeSkillUI.GetRecipeRequirements(124052)
    --/dump ProfessionsFrame.CraftingPage.SchematicForm.currentRecipeInfo.recipeID
    --124052
end
