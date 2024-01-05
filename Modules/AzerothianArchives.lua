-- 1. Adjust Talking Head's layout  so it doesn't get in the way (12.28.2023, talking Head is being frequently used for this event) (UIParentBottomManagedFrameTemplate)
---- The lines are always shown in the chat
---- Play the voiceover but hide the UI? TalkingHeadFrame:UnregisterEvent("TALKINGHEAD_REQUESTED") Avoide interference with other addons that mute it categorically
-- Doesn't automatically trigger ZONE_CHANGED_NEW_AREA when the event starts/ends

local _, addon = ...
local API = addon.API;
local TalkingHead = addon.TalkingHead;

local MAPID_AZURE_SPAN = 2024;
local MAPID_TRAITORS_REST = 2262;
local DIGSITE_NAME = "Traitor\'s Rest";    --Automatically localized
local GetMinimapZoneText = GetMinimapZoneText;


local EL = CreateFrame("Frame");

function EL:OnEnterDigsite()
    if not self.inDigsite then
        self.inDigsite = true;
        TalkingHead:EnableTalkingHead();
        print("OnEnterDigsite")
    end
end

function EL:OnLeaveDigsite()
    if self.inDigsite then
        self.inDigsite = false;
        TalkingHead:TryDisable();
        print("OnLeaveDigsite")
    end
end

function EL:IsInDigsite()
    return GetMinimapZoneText() == DIGSITE_NAME
end

function EL:OnEvent(event, ...)
    if event == "ZONE_CHANGED" then
        --This event is registered when player in 
        --Triggered when MinimapZoneText changed
        if self:IsInDigsite() then
            self:OnEnterDigsite();
        else
            self:OnLeaveDigsite();
        end
    end
end

function EL:OnMapChanged(isValidMap)
    if isValidMap then
        self:RegisterEvent("ZONE_CHANGED");
        self:SetScript("OnEvent", self.OnEvent);
        self:OnEvent("ZONE_CHANGED");
    else
        self:UnregisterEvent("ZONE_CHANGED");
        self:SetScript("OnEvent", nil);
        self:OnLeaveDigsite();
    end
end


local ZoneTriggerModule;

local function EnableModule(state)
    if state then
        if not ZoneTriggerModule then
            local module = API.CreateZoneTriggeredModule("quickslotseed");
            ZoneTriggerModule = module;
            module:SetValidZones(MAPID_AZURE_SPAN, MAPID_TRAITORS_REST);

            DIGSITE_NAME = C_Map.GetAreaInfo(13844) or DIGSITE_NAME;

            TalkingHead:Init();

            local function OnEnterZoneCallback()
                EL:OnMapChanged(true);
            end

            local function OnLeaveZoneCallback()
                EL:OnMapChanged(false);
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
    end
end

do
    local moduleData = {
        name = addon.L["ModuleName AzerothianArchives"],
        dbKey = "AzerothianArchives",
        description = addon.L["ModuleDescription AzerothianArchives"],
        toggleFunc = EnableModule,
        categoryID = 2,
        uiOrder = 4,
    };

    addon.ControlCenter:AddModule(moduleData);
end