-- Auto-select "Reporting for duty"

local _, addon = ...
local API = addon.API;

local EL = CreateFrame("Frame");
local UnitName = UnitName;
local SORIDORMI;
local ENABLE_AUTO_REPORT = true;


local function EL_OnGossipShow(self, event, ...)
    if ENABLE_AUTO_REPORT and UnitName("npc") == SORIDORMI then
        if GossipFrame and GossipFrame:IsShown() then
            --Auto Report-in
            local options = C_GossipInfo.GetOptions();
            if options and options[1] and options[1].gossipOptionID == 109275 then
                C_GossipInfo.SelectOption(109275);
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

            module:SetValidZones(2025, 2199);

            local function OnEnterZoneCallback()
                if not SORIDORMI then
                    SORIDORMI = API.GetCreatureName(204450) or "Soridormi";
                end
                EL:RegisterEvent("GOSSIP_SHOW");
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