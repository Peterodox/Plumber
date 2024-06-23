--Automatically add Dreamseed locations to Super Track
--Waypoints Priority: 1.Growing (haven't contributed)  2.Chest Available  3.Growing (contributed)


local _, addon = ...
local API = addon.API;

local WIDGET_UPDATE_INTERVAL = 2;
local WAYPOINT_MIN_DISTANCE = 10;   --Don't add waypoint if it's closeby
local WAYPOINT_PRIOTIRY_DISTANCE = 180;  --Prioritize location that is within x yd away from player --253 yd is where Dreamseed Chest shown on WorldMap
local VIGID_BOUNTY = 5971;
local MAPID_EMRALD_DREAM = 2200;

local DreamseedUtil = API.DreamseedUtil;    --Defined in Dreamseed.lua
local GetCreatureIDFromGUID = API.GetCreatureIDFromGUID;
local GetPlayerMapCoord = API.GetPlayerMapCoord;

local SuperTrackFrame;

local C_VignetteInfo = C_VignetteInfo;
local ClearUserWaypoint = C_Map.ClearUserWaypoint;
local tinsert = table.insert;
local tsort = table.sort;

local EL;
local MODULE_ENABLED = false;
local DREAMSEED_FLAGS = {};    --key: creatureID
local CHEST_VIGNETTE_X_CREATURE = {};
local NAME_DREAMSEED_CHEST = nil; --Localized later by API
local FOCUSED_CREATURE;     --Plant shown on the Arrow
local PRIORITIZE_CHEST = false;   --if false, don't add new waypoints so player can go back and collect rewards


--Flags
--0: not spawned or not growing
--1: growing, contributed
--2: finished growing, has rewards (chest)
--3: growing, haven't contributed

local FLAG_ICON = {
    [0] = "Dreamseed-Active",
    [1] = "Dreamseed-Active-Visited",
    [2] = "Dreamseed-Chest",
    [3] = "Dreamseed-Active-New",
};

local function SetDreamseedFlag(creatureID, flag)
    if DREAMSEED_FLAGS[creatureID] then
        if DREAMSEED_FLAGS[creatureID] ~= flag then
            DREAMSEED_FLAGS[creatureID] = flag;
            return true
        end
    end
end

local function GetPlantPosition(creatureID)
    local pos = DreamseedUtil:GetBackupLocation(creatureID);
    return pos[1], pos[2]
end

function DreamseedUtil:SetNavigatorPrioritizingReward(state)
    PRIORITIZE_CHEST = state;
end

function DreamseedUtil:IsNavigatorPrioritizingReward()
    return PRIORITIZE_CHEST
end


local function SortFunc_Generic(loc1, loc2)
    --locationData: creatureID, x, y, flag, remainingTime, distance

    --Prioritize nearyby spawned chest
    if loc1[4] == 2 and loc1[6] < WAYPOINT_PRIOTIRY_DISTANCE then
        return true
    elseif loc2[4] == 2 and loc2[6] < WAYPOINT_PRIOTIRY_DISTANCE then
        return false
    end

    --If there are two uncontributed plants, prioritize the one whose time is running out
    if loc1[4] == 3 and loc2[4] == 3 then
        if loc1[5] + 60 < loc2[5] then
            return true
        elseif loc2[5] + 60 < loc1[5] then
            return false
        end
    end

    if loc1[4] ~= loc2[4] then
        return loc1[4] > loc2[4]
    elseif loc1[6] ~= loc2[6] then
        return loc1[6] < loc2[6]
    end

    return false
end

local function SortFunc_RewardFirst(loc1, loc2)
    --Prioritize nearyby spawned chest
    if loc1[4] == 2 then
        if loc2[4] == 2 then
            return loc1[6] < loc2[6]
        else
            return true
        end
    elseif loc2[4] == 2 then
        return false
    end

    if loc1[4] == 1 then
        if loc2[4] == 1 then
            --prioritize time
            return loc1[5] < loc2[5]
        else
            return true
        end
    elseif loc2[4] == 1 then
        return false
    end

    if loc1[6] ~= loc2[6] then
        return loc1[6] < loc2[6]
    end

    return false
end


local function UpdateWaypoints()
    if not (SuperTrackFrame and SuperTrackFrame:CanReceiveDataFromNavigator()) then return end;

    local playerX, playerY = GetPlayerMapCoord(MAPID_EMRALD_DREAM);
    if not (playerX and playerY) then return end;

    local vignetteGUIDs = C_VignetteInfo.GetVignettes();
    local info;
    local uiMapID = MAPID_EMRALD_DREAM;
    local creatureID;
    local x, y;
    local remainingTime, fullTime;
    local isActive;
    local hasReward, distance;
    local flag;
    local locations;
    local processedCreatures = {};

    for i, vignetteGUID in ipairs(vignetteGUIDs) do
        info = C_VignetteInfo.GetVignetteInfo(vignetteGUID);
        if info then
            if info.vignetteID == VIGID_BOUNTY then
                --Soil
                creatureID = GetCreatureIDFromGUID(info.objectGUID);
            elseif CHEST_VIGNETTE_X_CREATURE[info.vignetteID] then
                --Dreamseed Chest
                if not NAME_DREAMSEED_CHEST then
                    NAME_DREAMSEED_CHEST = info.name or "Dreamseed Chest";
                    NAME_DREAMSEED_CHEST = "|cff19ff19"..(NAME_DREAMSEED_CHEST or "Dreamseed Chest").."|r";
                end

                flag = 2;
                creatureID = CHEST_VIGNETTE_X_CREATURE[info.vignetteID];
                if not processedCreatures[creatureID] then
                    processedCreatures[creatureID] = true;
                    SetDreamseedFlag(creatureID, flag);

                    local vignettePosition, vignetteFacing = C_VignetteInfo.GetVignettePosition(info.vignetteGUID, uiMapID);
                    x, y = vignettePosition:GetXY();
                    distance = DreamseedUtil:GetPlayerDistanceToTarget(playerX, playerY, x, y);

                    if distance >= WAYPOINT_MIN_DISTANCE then
                        if not locations then
                            locations = {};
                        end
                        tinsert(locations, {creatureID, x, y, flag, 0, distance});
                    end

                    DreamseedUtil:SetPlantContributedByCreatureID(creatureID, true);
                end
            end
        end
    end

    for creatureID in pairs(DREAMSEED_FLAGS) do
        if not processedCreatures[creatureID] then
            processedCreatures[creatureID] = true;
            remainingTime, fullTime = DreamseedUtil:GetGrowthTimesByCreatureID(creatureID);
            isActive = remainingTime and remainingTime > 0;

            if DreamseedUtil:HasAnyRewardByCreatureID(creatureID) then
                if isActive then
                    flag = 1;
                else
                    flag = 2;
                end
            else
                if isActive then
                    if remainingTime > 5 then
                        --We hide the uncontributed plant that is about to despawn
                        flag = 3;
                    else
                        flag = 0;
                    end
                else
                    flag = 0;
                end
            end

            SetDreamseedFlag(creatureID, flag)
            hasReward = flag == 1 or flag == 2;
            if isActive then
                x, y = GetPlantPosition(creatureID);
                distance = DreamseedUtil:GetPlayerDistanceToTarget(playerX, playerY, x, y);
                if distance >= WAYPOINT_MIN_DISTANCE then
                    if not locations then
                        locations = {};
                    end
                    tinsert(locations, {creatureID, x, y, flag, remainingTime, distance});
                end
            elseif hasReward then
                if not locations then
                    locations = {};
                end
                x, y = GetPlantPosition(creatureID);
                distance = DreamseedUtil:GetPlayerDistanceToTarget(playerX, playerY, x, y);
                if distance >= WAYPOINT_MIN_DISTANCE then
                    if not locations then
                        locations = {};
                    end
                    tinsert(locations, {creatureID, x, y, flag, 0, distance});
                end
            end
        end
    end

    if locations then
        if PRIORITIZE_CHEST then
            tsort(locations, SortFunc_RewardFirst);
        else
            tsort(locations, SortFunc_Generic);
        end
    end

    local bestCreatureID = locations and locations[1] and locations[1][1];

    if bestCreatureID ~= FOCUSED_CREATURE or true then
        FOCUSED_CREATURE = bestCreatureID;
        if bestCreatureID then
            local data = locations[1];
            flag = data[4];
            creatureID = data[1];
            local plantName;
            if flag == 2 then
                plantName = NAME_DREAMSEED_CHEST;
            else
                plantName = DreamseedUtil:GetPlantNameByCreatureID(data[1]);
                if flag == 3 then   --haven't contributed
                    --plantName = plantName.."|TInterface/AddOns/Plumber/Art/MapPin/RedDot:8:8:4:4|t";
                elseif flag == 1 then   --has reward but still growing
                    plantName = "|cffcccccc"..plantName.."|r";
                end
            end

            if flag == 0 then
                ClearUserWaypoint();
                return
            end
            local hasTimer = flag == 3 or flag == 1;
            SuperTrackFrame:SetTimerTarget(plantName, uiMapID, data[2], data[3], FLAG_ICON[flag], hasTimer, data[5]);
        else
            ClearUserWaypoint();
        end
    end
end

local function EL_UpdateNow_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > WIDGET_UPDATE_INTERVAL then
        self.t = 0;
        self:SetScript("OnUpdate", nil);
        if MODULE_ENABLED then
            self:RegisterEvent("VIGNETTES_UPDATED");
            self:RegisterEvent("UPDATE_UI_WIDGET");
        end
    end
end

local function EL_UpdateAfter_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 1 then
        self.t = 0;
        self:SetScript("OnUpdate", nil);
        if MODULE_ENABLED then
            UpdateWaypoints();
            self:RegisterEvent("VIGNETTES_UPDATED");
            self:RegisterEvent("UPDATE_UI_WIDGET");
        end
    end
end

local function EL_OnEvent(self, event)
    if event == "VIGNETTES_UPDATED" then
        self.t = 0;
        self:SetScript("OnUpdate", EL_UpdateAfter_OnUpdate);
        self:UnregisterEvent(event);
    elseif event == "UPDATE_UI_WIDGET" then
        self.t = 0;
        UpdateWaypoints();
        self:SetScript("OnUpdate", EL_UpdateNow_OnUpdate);
        self:UnregisterEvent(event);
    end
end

local function EnableEventListener(state)
    if EL then
        MODULE_ENABLED = state;
        if state then
            for creatureID in pairs(DREAMSEED_FLAGS) do
                DREAMSEED_FLAGS[creatureID] = 0;
            end
            EL:RegisterEvent("UPDATE_UI_WIDGET");
            EL:RegisterEvent("VIGNETTES_UPDATED");
            if not SuperTrackFrame then
                SuperTrackFrame = addon.GetSuperTrackFrame();
            end
            SuperTrackFrame:TryEnableByModule();
        else
            EL:UnregisterEvent("UPDATE_UI_WIDGET");
            EL:UnregisterEvent("VIGNETTES_UPDATED");
            EL:SetScript("OnUpdate", nil);
            EL.t = 0;
            FOCUSED_CREATURE = nil;
            if SuperTrackFrame then
                SuperTrackFrame:EnableSuperTracking(false);
            end
        end
    end
end


local ZoneTriggerModule;

local function EnableModule(state)
    if state then
        if not EL then
            EL = CreateFrame("Frame");
            EL:SetScript("OnEvent", EL_OnEvent);
            DREAMSEED_FLAGS = DreamseedUtil:GetPlantCreatureIDs();
            CHEST_VIGNETTE_X_CREATURE = DreamseedUtil:GetChestOwnerCreatureIDs();
        end

        if not ZoneTriggerModule then
            local module = API.CreateZoneTriggeredModule("navigator-dreamseed");
            ZoneTriggerModule = module;

            module:SetValidZones(MAPID_EMRALD_DREAM);

            local function OnEnterZoneCallback()
                EnableEventListener(true);
            end

            local function OnLeaveZoneCallback()
                EnableEventListener(false);
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
        EnableEventListener(false);
    end
end

do
    local moduleData = {
        name = addon.L["ModuleName Navigator_Dreamseed"],
        dbKey = "Navigator_Dreamseed",   --WorldMapPinSeedPlanting
        description = addon.L["ModuleDescription Navigator_Dreamseed"],
        toggleFunc = EnableModule,
        moduleAddedTime = 1702258000,
        categoryID = 10020000,
        uiOrder = 4,
    };

    addon.ControlCenter:AddModule(moduleData);
end