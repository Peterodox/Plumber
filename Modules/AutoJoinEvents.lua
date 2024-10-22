-- Auto-select "Reporting for duty", "Theater"

local _, addon = ...
local API = addon.API;

local EL = CreateFrame("Frame");
local UnitName = UnitName;
local TARGET_NPC_NAME;
local TARGET_OPTION_ID;
local MODULE_ENABLED = true;

local Data = {
    --[map] = {},

    [2248] = {  --Begin Theater
        gossipOptionID = 120733,
        creature = 214296,
        fallbackName = "Stage Manager Huberta",
    },

    [2025] = {  --Time Rift
        gossipOptionID = 109275,
        creature = 204450,
        fallbackName = "Soridormi",
    },
};

Data[2199] = Data[2025];

local function EL_OnGossipShow(self, event, ...)
    if MODULE_ENABLED and UnitName("npc") == TARGET_NPC_NAME then
        if GossipFrame and GossipFrame:IsShown() then
            --Auto Report-in
            local options = C_GossipInfo.GetOptions();
            if options and options[1] and options[1].gossipOptionID == TARGET_OPTION_ID then
                C_GossipInfo.SelectOption(TARGET_OPTION_ID);
                return
            end
        end
    end
end

EL:RegisterEvent("PLAYER_ENTERING_WORLD");

EL:SetScript("OnEvent", function(self, event, ...)
    self:UnregisterEvent(event);
    API.GetCreatureName(204450);
    EL:SetScript("OnEvent", EL_OnGossipShow);
end);


local ZoneTriggerModule;

local function EnableModule(state)
    if state then
        if not ZoneTriggerModule then
            local module = API.CreateZoneTriggeredModule();
            ZoneTriggerModule = module;

            local maps = {};
            for mapID, v in pairs(Data) do
                API.GetCreatureName(v.creature);
                table.insert(maps, mapID);
            end

            module:SetValidZones(maps);

            local function OnEnterZoneCallback(mapID)
                if Data[mapID] then
                    EL:RegisterEvent("GOSSIP_SHOW");
                    if not Data[mapID].localizedName then
                        Data[mapID].localizedName = API.GetCreatureName(Data[mapID].creature);
                    end
                    TARGET_NPC_NAME = Data[mapID].localizedName or Data[mapID].fallbackName;
                    TARGET_OPTION_ID = Data[mapID].gossipOptionID;
                else
                    EL:UnregisterEvent("GOSSIP_SHOW");
                end
            end

            local function OnLeaveZoneCallback()
                EL:UnregisterEvent("GOSSIP_SHOW");
            end

            module:SetEnterZoneCallback(OnEnterZoneCallback);
            module:SetLeaveZoneCallback(OnLeaveZoneCallback);
        end
        ZoneTriggerModule:SetEnabled(true);
        ZoneTriggerModule:Update();
    else
        if ZoneTriggerModule then
            ZoneTriggerModule:SetEnabled(false);
        end
        EL:UnregisterEvent("GOSSIP_SHOW");
    end
end

do

    local moduleData = {
        name = addon.L["ModuleName AutoJoinEvents"],
        dbKey = "AutoJoinEvents",
        description = addon.L["ModuleDescription AutoJoinEvents"],
        toggleFunc = EnableModule,
        categoryID = 2,
        uiOrder = 2,
    };

    addon.ControlCenter:AddModule(moduleData);
end