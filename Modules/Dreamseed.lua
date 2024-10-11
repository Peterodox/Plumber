--Show a list of Dreamseed when approaching Emerald Bounty Soil.
--Show checkmark if the Plant's achievement criteria is complete
--10 yd range: Plant Seed

--Mechanism Explained:
--  Fire "VIGNETTE_MINIMAP_UPDATED" when an Emerald Bounty (growing or not growing) enters/leaves the minimap
--  Fire "UPDATE_UI_WIDGET" after planting a seed (Can be triggered by seeds planted across the entire map)
--  Cast hidden spell "Dreamseed (425856)" when you get to 6 yd, where you get dismounted and your cursor becomes "Investigate"
--  Taking off on Dragon with "Skyward Ascent (372610)" doesn't trigger "PLAYER_STARTED_MOVING", so we need to watch "UNIT_SPELLCAST_SUCCEEDED"

local _, addon = ...
local API = addon.API;
local GetPlayerMapCoord = API.GetPlayerMapCoord;
local GetCreatureIDFromGUID = API.GetCreatureIDFromGUID;
local QuickSlot = addon.QuickSlot;

local MAPID_EMRALD_DREAM = 2200;
local VIGID_BOUNTY = 5971;
local RANGE_PLANT_SEED = 10;
local FORMAT_ITEM_COUNT_ICON = "%s|T%s:0:0:0:0:64:64:0:64:0:64|t";
local SEED_ITEM_IDS = {208047, 208067, 208066};     --Gigantic, Plump, Small Dreamseed
local SEED_SPELL_IDS = {417508, 417645, 417642};
local QUICKSLOT_NAME = "dreamseed";

local math = math;
local sqrt = math.sqrt;
local format = string.format;
local pairs = pairs;
local ipairs = ipairs;
local C_VignetteInfo = C_VignetteInfo;
local GetVignetteInfo = C_VignetteInfo.GetVignetteInfo;
local GetVignettes = C_VignetteInfo.GetVignettes
local GetStatusBarWidgetVisualizationInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo;
local GetItemDisplayVisualizationInfo = C_UIWidgetManager.GetItemDisplayVisualizationInfo;
local GetAllWidgetsBySetID = C_UIWidgetManager.GetAllWidgetsBySetID;
local IsFlying = IsFlying;
local IsMounted = IsMounted;
local GetAchievementCriteriaInfoByID = GetAchievementCriteriaInfoByID;
local UIParent = UIParent;
local GetItemCount = C_Item.GetItemCount;
local GetItemIconByID = C_Item.GetItemIconByID;
local GetBestMapForUnit = C_Map.GetBestMapForUnit;
local time = time;
local GetTime = GetTime;
local UnitChannelInfo = UnitChannelInfo;

local IS_SEED_SPELL = {};
do
    for _, spellID in ipairs(SEED_SPELL_IDS) do
        IS_SEED_SPELL[spellID] = true;
    end
end

local function GetVisibleEmeraldBountyGUID()
    local vignetteGUIDs = GetVignettes();
    local info;

    for i, vignetteGUID in ipairs(vignetteGUIDs) do
        info = GetVignetteInfo(vignetteGUID);
        if info and info.vignetteID == VIGID_BOUNTY then
            if info.onMinimap then
                return vignetteGUID, info.objectGUID
            end
        end
    end
end

local DataProvider = {};
local EL = CreateFrame("Frame", nil, UIParent);

local QUICKSLOT_DATA = {
    buttons = {
        {actionType = "item", itemID = 208047, spellID = 417508},   --Gigantic
        {actionType = "item", itemID = 208067, spellID = 417645},   --Plump
        {actionType = "item", itemID = 208066, spellID = 417642},   --Small Dreamseed
    },
    systemName = QUICKSLOT_NAME,
    spellcastType = 2,      --Channel
};

function EL:IsTrackedPlantGrowing()
    return self.trackedObjectGUID and DataProvider:IsPlantGrowing(self.trackedObjectGUID);
end

function EL:AttemptShowUI()
    if self:IsTrackedPlantGrowing() then
        return
    end

    self:RegisterEvent("UPDATE_UI_WIDGET");
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");

    self.isChanneling = nil;

    QuickSlot:SetButtonData(QUICKSLOT_DATA);
    QuickSlot:ShowUI();

    if self.trackedObjectGUID then
        local plantName, criteriaComplete = DataProvider:GetPlantNameAndProgress(self.trackedObjectGUID);
        if plantName then
            --plantName = "|cff808080"..plantName.."|r";  --DISABLED_FONT_COLOR
            if criteriaComplete then
                plantName = "|TInterface/AddOns/Plumber/Art/Button/Checkmark-Green-Shadow:16:16:-4:-2|t"..plantName;  --"|A:common-icon-checkmark:0:0:-4:-2|a" |TInterface/AddOns/Plumber/Art/Button/Checkmark-Green:0:0:-4:-2|t
            end
            QuickSlot:SetHeaderText(plantName, true);
            QuickSlot:SetDefaultHeaderText(plantName);
        end
    else
        QuickSlot:SetDefaultHeaderText(nil);
    end

    return true
end

function EL:CloseUI()
    self:UnregisterEvent("UPDATE_UI_WIDGET");
    self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");

    QuickSlot:RequestCloseUI(QUICKSLOT_NAME);
end

function EL:GetMapPointsDistance(x1, y1, x2, y2)
    local x = self.mapWidth * (x1 - x2);
    local y = self.mapHeight * (y1 - y2);

    return sqrt(x*x + y*y)
end

function EL:OnEvent(event, ...)
    if event == "VIGNETTE_MINIMAP_UPDATED" then
        local vignetteGUID, onMinimap = ...
        if vignetteGUID == self.trackedVignetteGUID then
            self:StopTrackingPosition();
        elseif onMinimap then
            local info = GetVignetteInfo(vignetteGUID);
            if info and info.vignetteID == VIGID_BOUNTY then
                self.trackedObjectGUID = info.objectGUID;
                self:UpdateTargetLocation(vignetteGUID);
            end
        end

    elseif event == "PLAYER_STARTED_MOVING" then
        --Fires like crazy when channeling seed (Repeat START/STOP Moving)
        --Doesn't fire when taking off on a dragon
        self.isPlayerMoving = true;
    elseif event == "PLAYER_STOPPED_MOVING" then
        self.isPlayerMoving = false;
        if not self.isChanneling then
            self:CalculatePlayerToTargetDistance();
        end
    elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" or event == "UNIT_SPELLCAST_SUCCEEDED" then
        self:CalculatePlayerToTargetDistance();
        if IsMounted() then
            self.isPlayerMoving = true;
        end
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            local _, _, spellID = ...
            if spellID and IS_SEED_SPELL[spellID] then
                --This event fires when start Channeling (and we don't have a SPELLCAST_CHANNEL equivalent, it doesn't make sense)
                --UNIT_SPELLCAST_CHANNEL_START fires before this event
                --UNIT_SPELLCAST_CHANNEL_STOP fires regardless of finishing cast or not
                --So we check if the the channel stops after endTime
                local name, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo("player");
                self.channelEndTime = endTime;
            else
                self.channelEndTime = nil;
            end
        end
    elseif event == "UPDATE_UI_WIDGET" then
        local widgetInfo = ...
        if DataProvider:IsValuableWidget(widgetInfo.widgetID) then
            if self:IsTrackedPlantGrowing() then
                self:StopTrackingPosition();
            end
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        self.isChanneling = true;

    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        self.isChanneling = nil;
        if self.channelEndTime then
            local t = GetTime();
            t = t * 1000;
            local diff = t - self.channelEndTime;
            if diff < 200 and diff > -200 then
                --Natural Complete
                C_Timer.After(0.2, function()
                    DataProvider:MarkNearestPlantContributed();
                end);
            else
                --Interrupted
            end
        end
    end
end
EL:SetScript("OnEvent", EL.OnEvent);

function EL:UpdateTargetLocation(vignetteGUID)
    local position, facing = C_VignetteInfo.GetVignettePosition(vignetteGUID, MAPID_EMRALD_DREAM);
    self.trackedVignetteGUID = vignetteGUID;
    if position and not self:IsTrackedPlantGrowing() then
        self.targetX, self.targetY = position.x, position.y;
        self:StartTrackingPosition();
    else
        self:StopTrackingPosition();
    end
end

function EL:UpdateTrackedVignetteInfo()
    local vignetteGUID, objectGUID = GetVisibleEmeraldBountyGUID();
    self.trackedObjectGUID = objectGUID;

    if vignetteGUID then
        if vignetteGUID ~= self.trackedVignetteGUID  then
            self:UpdateTargetLocation(vignetteGUID);
        end
    else
        self:StopTrackingPosition();
    end
end

function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t > self.t0 then
        self.t = 0;
        if self.isPlayerMoving then
            self:CalculatePlayerToTargetDistance();
        end
    end
end

function EL:StartTrackingPosition()
    self:RegisterEvent("PLAYER_STARTED_MOVING");
    self:RegisterEvent("PLAYER_STOPPED_MOVING");
    self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");     --In case player landing right on the soil
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
    self.t = 0;
    self:CalculatePlayerToTargetDistance();
    self:SetScript("OnUpdate", self.OnUpdate);
end

function EL:StopTrackingPosition()
    if self.trackedVignetteGUID then
        self.trackedVignetteGUID = nil;
        self.trackedObjectGUID = nil;
        self.isPlayerMoving = nil;
        self.isChanneling = nil;
        self.isInRange = nil;
        self:UnregisterEvent("PLAYER_STARTED_MOVING");
        self:UnregisterEvent("PLAYER_STOPPED_MOVING");
        self:UnregisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");
        self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
        self:SetScript("OnUpdate", nil);
        self:OnLeavingSoil();
    end
end

function EL:UpdateMap()
    self.mapWidth, self.mapHeight = C_Map.GetMapWorldSize(MAPID_EMRALD_DREAM);
end
EL.mapWidth = 7477.1201171875;
EL.mapHeight = 4983.330078125;


function EL:CalculatePlayerToTargetDistance()
    self.playerX, self.playerY = GetPlayerMapCoord(MAPID_EMRALD_DREAM);
    if self.playerX and self.playerY then
        local d = self:GetMapPointsDistance(self.playerX, self.playerY, self.targetX, self.targetY);
        --print(format("Distance: %.1f yd", d));

        --Change update frequency dynamically
        if d <= 10 then
            self.t0 = 0.2;
        elseif d < 50 then
            self.t0 = 0.5;
        else
            self.t0 = 1;
        end

        if d <= RANGE_PLANT_SEED and not IsFlying() then
            if not self.isInRange then
                self.isInRange = true;
                self:OnApproachingSoil();
            end
        elseif self.isInRange then
            self.isInRange = false;
            self:OnLeavingSoil();
        end
    end
end

function EL:OnApproachingSoil()
    local success = self:AttemptShowUI();
    --Frame not shown if Growth Cycle has already begun
end

function EL:OnLeavingSoil()
    self:CloseUI();
end


local ZoneTriggerModule;

local function EnableModule(state)
    if state then
        if not ZoneTriggerModule then
            local module = API.CreateZoneTriggeredModule("quickslotseed");
            ZoneTriggerModule = module;
            module:SetValidZones(MAPID_EMRALD_DREAM);
            EL:UpdateMap();

            local function OnEnterZoneCallback()
                EL:RegisterEvent("VIGNETTE_MINIMAP_UPDATED");
                EL:UpdateTrackedVignetteInfo();
            end

            local function OnLeaveZoneCallback()
                EL:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED");
                EL:StopTrackingPosition();
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
        EL:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED");
        EL:StopTrackingPosition();
        EL:CloseUI();
    end
end

do
    local moduleData = {
        name = addon.L["ModuleName EmeraldBountySeedList"],
        dbKey = "EmeraldBountySeedList",
        description = addon.L["ModuleDescription EmeraldBountySeedList"],
        toggleFunc = EnableModule,
        categoryID = 10020000,
        uiOrder = 1,
    };

    addon.ControlCenter:AddModule(moduleData);
end


local PLANT_DATA = {
    --17 types of Plant + 1 Tutorial
    --Kudos to @patf0rd on Twitter!

    --from VigInfo.ObjectGUID
    --/dump C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(5136) (bag max 180(3 min))
    --C_UIWidgetManager.GetItemDisplayVisualizationInfo()
    --C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo()
    --shownState = 1, itemInfo = {showAsEarned = true}
    --AchievementID = 19013;    --I Dream of Seeds
    --https://warcraft.wiki.gg/wiki/UPDATE_UI_WIDGET
    --C_UIWidgetManager.GetAllWidgetsBySetID
    --DBC: Vignette - VisibleTrackingQuestID to find 3 chest for each plant

    --[creatureID] = {criteriaID, widgetID(Growth Cycle),   3 Nurture Widgets,  6 Reward Widgets(There are actually 12 item widgets but only need 6)(Small, Plump, Gigantic Bounty, Small, Medium, Large Bloom(Shared by 3 rarities)),   3 DreamseedChest[VigID] (based on quality)} --Purple/Blue/Green, 3 widgetSetIDs
    --          1      2        3     4     5        6     7     8     9     10    11       12    13    14       15   16   17
    [208443] = {62028, 5084,    4994, 5087, 5088,    5183, 5181, 5182, 5184, 5245, 5247,    5769, 5856, 5857,    869, 918, 919}, --"Ysera's Clover"
    [208511] = {62029, 5122,    4995, 5089, 5090,    5186, 5188, 5187, 5185, 5248, 5249,    5772, 5854, 5855,    870, 920, 921}, --"Chiming Foxglove"
    [208556] = {62030, 5123,    4996, 5091, 5092,    5179, 5172, 5180, 5173, 5250, 5251,    5773, 5853, 5853,    871, 922, 923}, --"Dragon's Daffodil"
    [208563] = {62031, 5125,    5000, 5095, 5096,    5194, 5195, 5196, 5193, 5254, 5255,    5775, 5848, 5849,    873, 926, 927}, --"Singing Weedling"
    [208605] = {62032, 5126,    5001, 5097, 5098,    5198, 5200, 5199, 5197, 5256, 5257,    5776, 5846, 5847,    879, 928, 929}, --"Fuzzy Licorice"
    [208606] = {62039, 5127,    5002, 5099, 5100,    5202, 5204, 5203, 5201, 5258, 5259,    5777, 5844, 5845,    875, 930, 931}, --"Lofty Lupin"
    [208607] = {62038, 5128,    5003, 5101, 5102,    5206, 5208, 5207, 5205, 5260, 5261,    5778, 5842, 5843,    876, 932, 933}, --"Ringing Rose"  (ok)
    [208615] = {62037, 5129,    5004, 5103, 5104,    5210, 5212, 5211, 5209, 5262, 5263,    5779, 5840, 5841,    877, 934, 935}, --"Dreamer's Daisy"  (ok)
    [208616] = {62035, 5130,    5005, 5105, 5106,    5214, 5216, 5215, 5213, 5264, 5265,    5780, 5838, 5839,    878, 936, 937}, --"Viridescent Sprout"
    [208617] = {62041, 5124,    4999, 5093, 5094,    5191, 5189, 5190, 5192, 5252, 5253,    5774, 5850, 5851,    872, 924, 925}, --"Belligerent Begonias"  --Sometimes not visible due to phasing?
    [209583] = {62027, 5131,    5075, 5108, 5109,    5218, 5220, 5219, 5217, 5266, 5267,    5782, 5783, 5784,    897, 938, 939}, --"Lavatouched Lilies" (ok)
    [209599] = {62040, 5132,    5076, 5107, 5110,    5222, 5224, 5223, 5221, 5268, 5269,    5787, 5788, 5789,    941, 898, 940}, --"Lullaby Lavender" (ok)
    [209880] = {62036, 5133,    5077, 5111, 5112,    5226, 5228, 5227, 5225, 5270, 5271,    5790, 5791, 5792,    899, 942, 943}, --"Glade Goldenrod"  (ok)
    [210723] = {62185, 5134,    5113, 5114, 5115,    5230, 5232, 5231, 5229, 5272, 5273,    5793, 5862, 5863,    944, 946, 945}, --"Comfy Chamomile"
    [210724] = {62186, 5135,    5116, 5117, 5118,    5234, 5236, 5235, 5233, 5274, 5275,    5864, 5865, 5866,    947, 948, 949}, --"Moon Tulip"
    [210725] = {62189, 5136,    5119, 5120, 5121,    5238, 5240, 5239, 5237, 5276, 5277,    5867, 5868, 5869,    950, 951, 952}, --"Flourishing Scurfpea"
    [211059] = {62397, 5149,    5146, 5147, 5148,    5242, 5244, 5243, 5241, 5278, 5279,    5876, 5877, 5878,    970, 971, 972}, --"Whisperbloom Sapling" ! (not spawning due to Superbloom phasing)

    --Ageless Blossom (criteriaID: 62396)
};

function DataProvider:IsValuableWidget(widgetID)
    if not self.valuableWidgets then
        self.valuableWidgets = {};
        for _, data in pairs(PLANT_DATA) do
            if data[2] then
                self.valuableWidgets[ data[2] ] = true
            end
        end
    end

    return widgetID and self.valuableWidgets[widgetID]
end

function DataProvider:GetGrowthTimesByCreatureID(creatureID)
    if creatureID and PLANT_DATA[creatureID] then
        local widgetID = PLANT_DATA[creatureID][2];
        local info = widgetID and GetStatusBarWidgetVisualizationInfo(widgetID);
        if info then
            return info.barValue, info.barMax
        end
    end
end

function DataProvider:GetGrowthTimes(objectGUID)
    local creatureID = GetCreatureIDFromGUID(objectGUID);
    return self:GetGrowthTimesByCreatureID(creatureID)
end

function DataProvider:IsPlantGrowingByCreatureID(creatureID)
    local remainingTime = self:GetGrowthTimesByCreatureID(creatureID)
    return remainingTime and remainingTime > 0
end

function DataProvider:IsPlantGrowing(objectGUID)
    local remainingTime = self:GetGrowthTimes(objectGUID);
    return remainingTime and remainingTime > 0
end

function DataProvider:GetPlantNameByCreatureID(creatureID)
    if creatureID and PLANT_DATA[creatureID] then
        local criteriaString = GetAchievementCriteriaInfoByID(19013, PLANT_DATA[creatureID][1]);
        return criteriaString
    end
end

function DataProvider:GetPlantNameAndProgress(objectGUID, isCreatureID)
    local id;
    if isCreatureID then
        id = objectGUID;
    else
        id = GetCreatureIDFromGUID(objectGUID);
    end
    if id and PLANT_DATA[id] then
        local criteriaString, criteriaType, completed = GetAchievementCriteriaInfoByID(19013, PLANT_DATA[id][1]);
        return criteriaString, completed
    end
end

function DataProvider.GetActiveDreamseedGrowthTimes()
    --This function shares between modules. (additional "Growth Cycle Timer" on PlayerChoiceFrame)
    --If this module is disabled "trackedVignetteGUID" will be nil and we to obtain it

    local vignetteGUID = EL.trackedVignetteGUID or DataProvider.lastVignetteGUID;

    if not vignetteGUID then
        vignetteGUID = GetVisibleEmeraldBountyGUID();
        DataProvider.lastVignetteGUID = vignetteGUID;
    end

    if vignetteGUID then
        local info = GetVignetteInfo(vignetteGUID);
        if info and info.vignetteID == VIGID_BOUNTY then
            if info.onMinimap then
                return DataProvider:GetGrowthTimes(info.objectGUID)
            end
        end
    end
end

function DataProvider:GetNurtureProgress(objectGUID, convertToString)
    local creatureID = GetCreatureIDFromGUID(objectGUID);
    if creatureID and PLANT_DATA[creatureID] then
        local widgetID = PLANT_DATA[creatureID][3];
        local info = widgetID and GetStatusBarWidgetVisualizationInfo(widgetID);
        if info and info.barValue and info.barMax then
            local barValue, barMax = info.barValue, info.barMax;
            if not (barValue and barMax) then return end;

            if barValue > barMax then
                barValue = barMax;
            end

            if convertToString then
                local str = info.text;
                if str then
                    str = str..": ".. barValue .. "/" ..barMax
                else
                    str = barValue .. "/" ..barMax
                end
                return str
            else
                return barValue, barMax
            end
        end
    end
end

function DataProvider:GetRewardTierByCreatureID(creatureID)
    local seedTier, bloomTier = 0, 0;
    if creatureID and PLANT_DATA[creatureID] then
        local info, widgetID, itemID;
        for i = 6, 8 do
            widgetID = PLANT_DATA[creatureID][i];
            info = widgetID and GetItemDisplayVisualizationInfo(widgetID);
            if info and info.shownState == 1 and info.itemInfo and info.itemInfo.showAsEarned then
                itemID = info.itemInfo.itemID;
                if itemID == 210217 then
                    seedTier = 1;   --Small Dreamy Bounty
                elseif itemID == 210218 then
                    seedTier = 2;   --Plump Dreamy Bounty
                elseif itemID == 210219 then
                    seedTier = 3;   --Gigantic Dreamy Bounty
                end
                break
            end
        end
        for i = 9, 11 do
            widgetID = PLANT_DATA[creatureID][i];
            info = widgetID and GetItemDisplayVisualizationInfo(widgetID);
            if info and info.shownState == 1 and info.itemInfo and info.itemInfo.showAsEarned then
                itemID = info.itemInfo.itemID;
                if itemID == 210224 then
                    bloomTier = 1;  --Small     <50
                elseif itemID == 210225 then
                    bloomTier = 2;  --Medium    <100
                elseif itemID == 210226 then
                    bloomTier = 3;  --Large     =100
                end
                break
            end
        end
    end
    return seedTier, bloomTier
end

function DataProvider:GetRewardTier(objectGUID)
    local creatureID = GetCreatureIDFromGUID(objectGUID);
    return self:GetRewardTierByCreatureID(creatureID)
end

function DataProvider:GetGrowthStateChanged(creatureID, growthRemainingSeconds)
    if not self.growthEndTimes then
        self.growthEndTimes = {};
    end

    if growthRemainingSeconds <= 0 then
        if self.growthEndTimes[creatureID] then
            return true
        else
            return false
        end
    end

    local isChanged = false;
    local currentTime = time();

    if self.growthEndTimes[creatureID] then
        if currentTime > self.growthEndTimes[creatureID] then
            isChanged = true;
        end
    else
        isChanged = true;
    end

    self.growthEndTimes[creatureID] = currentTime + growthRemainingSeconds;

    return isChanged
end

function DataProvider:Debug_ConstructWidgetID()
    --3 Bounty, 3 Blooms
    local REWARD_ITEMS = {210217, 210218, 210219, 210224, 210225, 210226};

    for creatureID in pairs(PLANT_DATA) do
        local info, widgetSetID, setWidgets;
        local itemIDxWidgetID = {};

        for i = 15, 17 do
            widgetSetID = PLANT_DATA[creatureID][i];
            setWidgets = GetAllWidgetsBySetID(widgetSetID);
            if setWidgets then
                local numItems = 0;
                for _, widgetInfo in ipairs(setWidgets) do
                    if widgetInfo.widgetType == 27 then
                        numItems = numItems + 1;
                        local widgetID = widgetInfo.widgetID;
                        info = GetItemDisplayVisualizationInfo(widgetID);
                        local itemID = info.itemInfo.itemID;
                        if not itemIDxWidgetID[itemID] then
                            itemIDxWidgetID[itemID] = widgetID;
                        end
                    end
                end
            end
        end

        local output;
        for i, itemID in ipairs(REWARD_ITEMS) do
            local widgetID = itemIDxWidgetID[itemID];
            if output then
                output = output..", "..widgetID;
            else
                output = widgetID;
            end
        end
        API.SaveDataUnderKey(creatureID, output);
    end
end

--[[
function DataProvider:HasAnyRewardByCreatureID(creatureID)
    --We now use a more RAM friendly (not getting all the widgets in a wigetSet), but less robust approach
    if creatureID and PLANT_DATA[creatureID] then
        if self:IsDreamseedChestAvailableByCreatureID(creatureID) then
            return true, true
        end
        local creatureData = PLANT_DATA[creatureID];
        local info;
        for i = 6, 11 do
            info = GetItemDisplayVisualizationInfo(creatureData[i]);
            if info and info.shownState == 1 and info.itemInfo and info.itemInfo.showAsEarned then
                return true, false
            end
        end
    end
    return false, false
end
--]]

function DataProvider:HasAnyReward(objectGUID)
    local creatureID = GetCreatureIDFromGUID(objectGUID);
    return self:HasAnyRewardByCreatureID(creatureID);
end

function DataProvider:GetResourcesText()
    --208066, 208067, 208047
    local info = C_CurrencyInfo.GetCurrencyInfo(2650);  --Emerald Dewdrop
    local anyNonZero = false;
    local text;

    if info then
        local quantity = info.quantity;
        if quantity > 0 then
            anyNonZero = true;
            if quantity > 9999 then
                quantity = "9999+";
            end
        else
            quantity = "|cff8080800|r";
        end
        text = format(FORMAT_ITEM_COUNT_ICON, quantity, info.iconFileID).."  ";
    else
        return
    end

    local count, icon;

    for _, itemID in ipairs(SEED_ITEM_IDS) do
        count = GetItemCount(itemID);
        icon = GetItemIconByID(itemID);
        if count == 0 then
            count = "|cff8080800|r";
        else
            anyNonZero = true;
        end
        text = text.."  "..format(FORMAT_ITEM_COUNT_ICON, count, icon);
    end

    if anyNonZero then
        return text
    else
        --we don't show this text if player has none of the required resources
    end
end

function DataProvider:GetChestOwnerCreatureIDs()
    local tbl = {};
    local vignetteID;
    for creatureID, data in pairs(PLANT_DATA) do
        for i = 12, 14 do
            vignetteID = data[i];
            tbl[vignetteID] = creatureID;
        end
    end
    return tbl
end

function DataProvider:SetChestStateByCreatureID(creatureID, state, objectGUID, x, y)
    if not creatureID then return end;

    if not self.dreamseedChestStates then
        self.dreamseedChestStates = {};
    end

    --local plantName = self:GetPlantNameAndProgress(creatureID, true);
    if state and not self.dreamseedChestStates[creatureID] then
        self.dreamseedChestStates[creatureID] = {objectGUID, x, y};
        if self.BackupCreaturePositions[creatureID] then
            self.BackupCreaturePositions[creatureID] = {x, y};  --overwrite our database in case Blizzard moves things
        end
    else
        self.dreamseedChestStates[creatureID] = nil;
    end

    if not state then
        --Player looted the chest
        self:SetPlantContributedByCreatureID(creatureID, nil);
    end
end

function DataProvider:SetChestState(objectGUID, state, x, y)
    local creatureID = GetCreatureIDFromGUID(objectGUID);
    self:SetChestStateByCreatureID(creatureID, state, objectGUID, x, y)
end

function DataProvider:TryGetChestInfoByCreatureID(creatureID)
    if self.dreamseedChestStates then
        return self.dreamseedChestStates[creatureID]
    end
end

function DataProvider:GetPlantCreatureIDs()
    local tbl = {};
    for creatureID in pairs(PLANT_DATA) do
        tbl[creatureID] = false;
    end
    return tbl
end

function DataProvider:GetBackupLocation(creatureID)
    return creatureID and self.BackupCreaturePositions[creatureID]
end

function DataProvider:EnumerateSpawnLocations()
    return pairs(self.BackupCreaturePositions)
end

function DataProvider:GetNearbyPlantInfo()
    local uiMapID = GetBestMapForUnit("player");
    if uiMapID ~= MAPID_EMRALD_DREAM then return end;

    local x, y = GetPlayerMapCoord(MAPID_EMRALD_DREAM);
    if x and y then
        EL:UpdateMap();
        local distance;
        for creatureID, position in self:EnumerateSpawnLocations() do
            distance = EL:GetMapPointsDistance(x, y, position[1], position[2]);
            if distance <= 15 then
                return creatureID, position[1], position[2]
            end
        end
    end
end

function DataProvider:BuildPlantIndexTable()
    local function SortByCriteriaID(a, b)
        return PLANT_DATA[a] < PLANT_DATA[b]
    end

    local plants = {};
    local n = 0;

    for creatureID, data in pairs(PLANT_DATA) do
        n = n + 1;
        plants[n] = creatureID;
    end

    table.sort(plants, SortByCriteriaID);

    local plantXIndex = {};
    for index, creatureID in ipairs(plants) do
        plantXIndex[creatureID] = index;
    end

    self.indexXPlant = plants;
    self.plantXIndex = plantXIndex;
end

function DataProvider:GetPlantIndexByCreatureID(creatureID)
    if not self.plantXIndex then
        self:BuildPlantIndexTable();
    end

    return self.plantXIndex[creatureID]
end

function DataProvider:GetPlantCreatureIDByIndex(index)
    if not self.indexXPlant then
        self:BuildPlantIndexTable();
    end

    return self.indexXPlant[index]
end

function DataProvider:SetPlantContributedByCreatureID(creatureID, chestFlag)
    --chestFlag:
    --nil (no chest)
    --1 Potential chest (data from WidgetInfo)
    --2 Chest (Player made contribution during current game session)
    if not self.plantContributed then
        self.plantContributed = {};
    end
    self.plantContributed[creatureID] = chestFlag
end

function DataProvider:HasAnyRewardByCreatureID(creatureID)
    --Alternative approach due to inconsistent data between actual spawn and widgetInfo
    --Check if player has successfully cast Dreamseed / made contributions using PlayerChoiceUI
    if creatureID and PLANT_DATA[creatureID] then
        if not self.plantContributed then
            self.plantContributed = {};
        end
        return self.plantContributed[creatureID] ~= nil
    end
    return false, false
end

function DataProvider:MarkNearestPlantContributed()
    local creatureID = self:GetNearbyPlantInfo();
    if creatureID then
        self:SetPlantContributedByCreatureID(creatureID, 2);
    end
end

function DataProvider:GetPlayerDistanceToTarget(playerX, playerY, targetX, targetY)
    return EL:GetMapPointsDistance(playerX, playerY, targetX, targetY);
end


---- Workaround for inconsistent Chest flag:
---- 1. When player logs in, query UIWidgetManager to get chests from previous game session
---- 2. We check if the chests actually exist when player gets to their approximate locations

function DataProvider:HasAnyPotentialRewardByCreatureID(creatureID)
    --We now use a more RAM friendly (not getting all the widgets in a wigetSet), but less robust approach
    if creatureID and PLANT_DATA[creatureID] then
        local creatureData = PLANT_DATA[creatureID];
        local info;
        for i = 6, 11 do
            info = GetItemDisplayVisualizationInfo(creatureData[i]);
            if info and info.shownState == 1 and info.itemInfo and info.itemInfo.showAsEarned then
                return true
            end
        end
    end
    return false
end

function DataProvider:GetChestOwnerCreatureID(vignetteID)
    if not self.chestOwnerCreatureIDs then
        self.chestOwnerCreatureIDs = self:GetChestOwnerCreatureIDs();
    end
    return vignetteID and self.chestOwnerCreatureIDs[vignetteID]
end

function DataProvider:IsDreamseedChest(vignetteID)
    return self:GetChestOwnerCreatureID(vignetteID) ~= nil
end

function DataProvider:RequestScanChests()
    if self.scanComplete then return end;

    if self.scanner then
        self.scanner.t = 0;
        self.scanner:Show();
        return
    end

    local anyPotentionReward;
    local targetList = {};

    local chestFlagAuto = 1;
    local numTargets = 0;

    for creatureID in pairs(PLANT_DATA) do
        if self:HasAnyPotentialRewardByCreatureID(creatureID) then
            anyPotentionReward = true;
            if self.BackupCreaturePositions[creatureID] then
                targetList[creatureID] = true;
                self:SetPlantContributedByCreatureID(creatureID, chestFlagAuto);
                numTargets = numTargets + 1;
            end
        end
    end

    --debugprint("numTargets", numTargets)


    --[[
        --Disable AB Testing (Dreamseed Chests Icon can still be stuck on the map, so we have to enable on-set scanning every game session)
    if PlumberDB then
        if PlumberDB.DreamseedChestABTesting == nil then
            PlumberDB.DreamseedChestABTesting = math.random(100) >= 50;
        end
        if not PlumberDB.DreamseedChestABTesting then
            self.scanComplete = true;
            return
        end
    end
    --]]

    if anyPotentionReward then
        if not self.scanner then
            self.scanner = CreateFrame("Frame");
            self.scanner.t = 0;
            self.scanner:SetScript("OnUpdate", function(f, elapsed)
                f.t = f.t + elapsed;
                if f.t > 3 then
                    f.t = 0;
                    local playerX, playerY = GetPlayerMapCoord(MAPID_EMRALD_DREAM);
                    local distance;
                    if playerX and playerY then
                        local anyTarget, nearbyCreatureID, location;

                        for creatureID in pairs(targetList) do
                            anyTarget = true;
                            location = self.BackupCreaturePositions[creatureID];
                            if location then
                                distance = self:GetPlayerDistanceToTarget(playerX, playerY, location[1], location[2]);
                                if distance <= 200 then
                                    nearbyCreatureID = creatureID;
                                    break
                                end
                            end
                        end

                        if not anyTarget then
                            f:SetScript("OnUpdate", nil);
                            f.t = nil;
                            self.scanComplete = true;
                            --debugprint("Scan Complete");
                        end

                        if nearbyCreatureID then
                            local vignetteGUIDs = GetVignettes();
                            local info, ownerCreatureID;
                            for i, vignetteGUID in ipairs(vignetteGUIDs) do
                                info = GetVignetteInfo(vignetteGUID);
                                if info then
                                    ownerCreatureID = self:GetChestOwnerCreatureID(info.vignetteID);
                                    if ownerCreatureID then
                                        --debugprint(ownerCreatureID, nearbyCreatureID)
                                    end
                                    if ownerCreatureID == nearbyCreatureID then
                                        targetList[ownerCreatureID] = nil;
                                        self:SetPlantContributedByCreatureID(nearbyCreatureID, 2);
                                        --debugprint("Found One");
                                        break
                                    end
                                end
                            end
                            if self.plantContributed[nearbyCreatureID] == chestFlagAuto then
                                if DataProvider:IsPlantGrowingByCreatureID(nearbyCreatureID) then
                                    --debugprint("Still Growing");
                                else
                                    self:SetPlantContributedByCreatureID(nearbyCreatureID, nil);
                                    --debugprint("Doesn't Exist");
                                end
                            end
                        end
                    end
                end
            end);
        end
    else
        self.scanComplete = true;
    end
end

function DataProvider:PauseScanner()
    if self.scanComplete then return end;

    if self.scanner then
        self.scanner:Hide();
    end
end


API.GetActiveDreamseedGrowthTimes = DataProvider.GetActiveDreamseedGrowthTimes;
API.DreamseedUtil = DataProvider;




DataProvider.BackupCreaturePositions = {
    [208605] = {
        0.634965717792511,
        0.4709928631782532,
    },
    [209880] = {
        0.4074325561523438,
        0.4348400235176086,
    },
    [210725] = {
        0.4873448014259338,
        0.8045594692230225,
    },
    [208563] = {
        0.6302892565727234,
        0.5284437537193298,
    },
    [208443] = {
        0.5924164056777954,
        0.5876181125640869,
    },
    [208606] = {
        0.5665966272354126,
        0.4488694071769714,
    },
    [211059] = {
        0.5114631652832031,
        0.5863984823226929,
    },
    [208556] = {
        0.6395775675773621,
        0.6483616232872009,
    },
    [209583] = {
        0.4067537784576416,
        0.2478460669517517,
    },
    [209599] = {
        0.5651239156723022,
        0.3766665458679199,
    },
    [208615] = {
        0.4638132452964783,
        0.4048779606819153,
    },
    [208511] = {
        0.5459136962890625,
        0.6763055324554443,
    },
    [208617] = {
        0.4990068674087524,
        0.3544299006462097,
    },
    [208616] = {
        0.400239109992981,
        0.5268844366073608,
    },
    [210724] = {
        0.4264156222343445,
        0.740414023399353,
    },
    [208607] = {
        0.4916412830352783,
        0.4806915521621704,
    },
    [210723] = {
        0.3845012784004211,
        0.5920345783233643,
    },
};

---- Dev Tool
--[[
do
    function YeetWidget_StatusBar()
        local GetStatusBarWidgetVisualizationInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo;
        local info;
        local n = 0;
        for widgetID = 5000, 5200 do
            info = GetStatusBarWidgetVisualizationInfo(widgetID);
            if info and info.barMax ~= 180 and info.barValue > 0 then
                n = n + 1;
                print("#"..n, widgetID, info.text);
            end
        end
    end

    function YeetWidgetInfo()
        for widgetID, widgetType in pairs(EL.widgetData) do
            print("ID:", widgetID, "  Type:", widgetType)
        end
    end

    function YeetPOI()
        local uiMapID = C_Map.GetBestMapForUnit("player");
        local areaPoiIDs = C_AreaPoiInfo.GetAreaPOIForMap(uiMapID);
        local info;

        for i, areaPoiID in ipairs(areaPoiIDs) do
            info = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID);
            print(i, info.name);
        end
    end

    function YeetVignette()
        local vignetteGUIDs = C_VignetteInfo.GetVignettes();
        local info, position;

        local vignettesGUIDs = {};
        local total = 0;

        for i, guid in ipairs(vignetteGUIDs) do
            info = C_VignetteInfo.GetVignetteInfo(guid);
            if info and info.name then
                total = total + 1;
                vignettesGUIDs[total] = info.vignetteGUID;
                if info.name == "Dreamseed Chest" and true then
                    print(total, format("#%s  type:%s  %s  WorldMap %s  Minimap %s  Unique %s  %s", info.vignetteID, info.type, info.name, tostring(info.onWorldMap), tostring(info.onMinimap), tostring(info.isUnique), info.vignetteGUID));
                end
            end
        end

        local bestUniqueVignetteIndex = C_VignetteInfo.FindBestUniqueVignette(vignettesGUIDs);
        print("Show ",bestUniqueVignetteIndex);
        if bestUniqueVignetteIndex then
            info = C_VignetteInfo.GetVignetteInfo( vignettesGUIDs[bestUniqueVignetteIndex] );
            print(info.atlasName);
        end
    end

    function YeetDistance()
        local uiMapID = C_Map.GetBestMapForUnit("player");
        local trueDistance = C_Navigation.GetDistance();

        local waypoint = C_Map.GetUserWaypoint();
        local x0, y0 = waypoint.position.x, waypoint.position.y;

        local playerPosition = C_Map.GetPlayerMapPosition(uiMapID, "player");
        local x1, y1 = playerPosition:GetXY();
        local width, height = C_Map.GetMapWorldSize(uiMapID);

        local distance = math.sqrt( ((x1 -x0)*width)^2 + ((y1 -y0)*height)^2 );
        print(trueDistance, distance);
    end

    function TestStatusBar()
        if not PlumberTestStatusBar then
            PlumberTestStatusBar = addon.CreateTimerFrame(UIParent);
            PlumberTestStatusBar:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
            PlumberTestStatusBar:SetStyle(2);
            PlumberTestStatusBar:SetWidth(192);
            PlumberTestStatusBar:UpdateMaxBarFillWidth();
            PlumberTestStatusBar:SetReverse(true);
            PlumberTestStatusBar:SetContinuous(false);
        end
        PlumberTestStatusBar:SetDuration(180);
    end

    function TestTinyBar()
        if not PlumberTestStatusBar then
            PlumberTestStatusBar = addon.CreateTinyStatusBar(UIParent);
            PlumberTestStatusBar:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
            PlumberTestStatusBar:UpdateMaxBarFillWidth();
            PlumberTestStatusBar:SetReverse(true);
        end
        PlumberTestStatusBar:SetDuration(10);
    end
end
--]]

--[[
local UiWidgets_Reward_Bounty = {
    --{Small, Plump, Gigantic Bounty, Small, Medium, Large Bloom}
    {5179, 5172, 5180, 5173, 5245, 5247},
    {5183, 5181, 5182, 5184, 5248, 5249},
    {5186, 5188, 5187, 5185, 5250, 5251},
    {5191, 5189, 5190, 5192, 5252, 5253},
    {5194, 5195, 5196, 5193, 5254, 5255},
    {5198, 5200, 5199, 5197, 5256, 5257},
    {5202, 5204, 5203, 5201, 5258, 5259},
    {5206, 5208, 5207, 5205, 5260, 5261},
    {5210, 5212, 5211, 5209, 5262, 5263},
    {5214, 5216, 5215, 5213, 5264, 5265},
    {5218, 5220, 5219, 5217, 5266, 5267},
    {5222, 5224, 5223, 5221, 5268, 5269},
    {5226, 5228, 5227, 5225, 5270, 5271},
    {5230, 5232, 5231, 5229, 5272, 5273},
    {5234, 5236, 5235, 5233, 5274, 5275},
    {5238, 5240, 5239, 5237, 5276, 5277},
    {5242, 5244, 5243, 5241, 5278, 5279},
};
--]]