-- 1. Show Quick Slot for Technoscrying World Quest


local _, addon = ...
local API = addon.API;
local QuickSlot = addon.QuickSlot;

local IsQuestActive = C_TaskQuest.IsActive;
local IsOnQuest = C_QuestLog.IsOnQuest;
local HasOverrideActionBar = HasOverrideActionBar;
local GetOverrideBarSkin = GetOverrideBarSkin;
local UnitPowerBarID = UnitPowerBarID;  --659
local IsFlying = IsFlying;

local GOGGLE_NAME = C_Item.GetItemNameByID(202247);
local GOGGLE_ITEM_ID = {202247};
local GOGGLE_SPELL_ID = {398013};

local QUICKSLOT_NAME = "technoscryers";

local QUESTS = {
    [78820] = 2133,     --Zaralek Cavern
    [78931] = 2151,     --The Forbidden Reach
    [78616] = 2022,     --The Waking Shores
};

local QUEST_MAPS = {};
for _, uiMapID in pairs(QUESTS) do
    table.insert(QUEST_MAPS, uiMapID);
end

local ZoneTriggerModule;
local EL = CreateFrame("Frame");


function EL:ShouldShowQuickSlot()
    if IsFlying() then
        return false
    end
    return not ((HasOverrideActionBar() and GetOverrideBarSkin() == 534041) or (UnitPowerBarID("player") == 659))
end

function EL:StopZoneTrigger()
    if ZoneTriggerModule then
        ZoneTriggerModule:SetEnabled(false);
    end
end

function EL:SetupZoneTrigger(maps)
    if not ZoneTriggerModule then
        local module = API.CreateZoneTriggeredModule("azarchives");
        ZoneTriggerModule = module;
        ZoneTriggerModule:SetValidZones(QUEST_MAPS);

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

function EL:SearchQuests()
    --Not used
    --We don't know when the quests will refresh so we always listen quest events on 3 maps

    local maps = {};

    for questID, uiMapID in pairs(QUESTS) do
        if IsQuestActive(questID) then
            table.insert(maps, uiMapID);
        end
    end

    if #maps > 0 then
        self:SetupZoneTrigger(maps);
    else
        self:StopZoneTrigger();
    end
end

function EL:ListenEvents(state)
    if state then
        self:RegisterEvent("QUEST_ACCEPTED");
        self:RegisterEvent("QUEST_REMOVED");
        self:SetScript("OnEvent", self.OnEvent);
    else
        self:UnregisterEvent("QUEST_ACCEPTED");
        self:UnregisterEvent("QUEST_REMOVED");
        self:UnregisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
        self:UnregisterEvent("UNIT_POWER_BAR_HIDE");
        self:UnregisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");
        self:SetScript("OnEvent", nil);
        self:SetCheckFlying(false);
        QuickSlot:RequestCloseUI(QUICKSLOT_NAME);
    end
end

local function CheckFlying_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.5 then
        self.t = 0;
        local isFlying = IsFlying();
        if isFlying ~= self.isFlying then
            self.isFlying = isFlying;
            self:UpdateQuickSlot();
        end
    end
end

function EL:SetCheckFlying(state)
    if state then
        self.t = 0;
        self.isFlying = nil;
        self:SetScript("OnUpdate", CheckFlying_OnUpdate);
    else
        self:SetScript("OnUpdate", nil);
    end
end

function EL:UpdateQuest()
    local isOnQuest;

    for questID in pairs(QUESTS) do
        if IsOnQuest(questID) then
            isOnQuest = true
            break
        end
    end

    if isOnQuest then
        self:ListenEvents(true);
        self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
        self:RegisterUnitEvent("UNIT_POWER_BAR_HIDE", "player");
        self:UpdateQuickSlot();
        self:SetCheckFlying(true);
    else
        self:UnregisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
        self:UnregisterEvent("UNIT_POWER_BAR_HIDE");
        self:SetCheckFlying(false);
        QuickSlot:RequestCloseUI(QUICKSLOT_NAME);
    end
end

function EL:UpdateQuickSlot()
    if self:ShouldShowQuickSlot() then
        QuickSlot:SetButtonData(GOGGLE_ITEM_ID, GOGGLE_SPELL_ID, QUICKSLOT_NAME);
        QuickSlot:ShowUI();
        if not GOGGLE_NAME then
            GOGGLE_NAME = C_Item.GetItemNameByID(202247);
        end
        local itemName = GOGGLE_NAME or "Technoscryers";
        QuickSlot:SetHeaderText(itemName, true);
        QuickSlot:SetDefaultHeaderText(itemName);
    else
        QuickSlot:RequestCloseUI(QUICKSLOT_NAME);
    end
end

function EL:OnEvent(event, ...)
    if event == "QUEST_ACCEPTED" then
        local questID = ...
        if questID and QUESTS[questID] then
            self:UpdateQuest()
        end

    elseif event == "QUEST_REMOVED" then
        local questID = ...
        if questID and QUESTS[questID] then
            self:UpdateQuest();
            --self:SearchQuests();
        end

    elseif event == "UPDATE_OVERRIDE_ACTIONBAR" or event == "UNIT_POWER_BAR_HIDE" then
        self:UpdateQuickSlot();
    end
end




local function EnableModule(state)
    if state then
        --EL:SearchQuests();
        EL:SetupZoneTrigger();
        EL:UpdateQuest();
    else
        EL:StopZoneTrigger();
        EL:ListenEvents(false);
    end
end

do
    local moduleData = {
        name = addon.L["ModuleName Technoscryers"],
        dbKey = "Technoscryers",
        description = addon.L["ModuleDescription Technoscryers"],
        toggleFunc = EnableModule,
        categoryID = 10020501,
        uiOrder = 1,
        moduleAddedTime = 1706633000,
    };

    addon.ControlCenter:AddModule(moduleData);
end