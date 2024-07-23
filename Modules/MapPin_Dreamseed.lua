local _, addon = ...
local API = addon.API;
local TomTomUtil = addon.TomTomUtil;        --Send location to TomTom

local HIDE_INACTIVE_PIN = false;
local DATA_PROVIDER_ADDED = false;
local ENABLE_MAP_PIN = false;
local PIN_ICON_PRIORITIZE_REWARD = false;   --If the plant is active and has unclaimed reward, show Seed or Flower icon

local VIGID_BOUNTY = 5971;
local MAPID_EMRALD_DREAM = 2200;
local PIN_SIZE_DORMANT = 12;
local PIN_SIZE_ACTIVE = 18;
local PIN_TINY_BAR_HEIGHT = 2;
local PIN_TEMPLATE_NAME = "PlumberDreamseedMapPinTemplate";
local PIN_DORMANT_TEXTURE = "Interface/AddOns/Plumber/Art/MapPin/SeedPlanting-Empty-Distant";   --optional postfix: -HC, High Contrast
local FORMAT_TIME_LEFT = BONUS_OBJECTIVE_TIME_LEFT or "Time Left: %s";

local DB_KEY_MASTER_SWITCH = "WorldMapPinSeedPlanting";     --This is the key that enable/disable our entire Map Pin Module. Since we only have one type of pins for now, we use the same key
local DB_KEY_DREAMSEED = "WorldMapPinSeedPlanting";         --Control Dreamseed Pins (Show spawned soils, unclaimed chests, timer below active one)

local MapFrame = WorldMapFrame;
local MapScrollContainer = WorldMapFrame.ScrollContainer;
local QuestDetailsFrame = QuestMapFrame and QuestMapFrame.DetailsFrame or nil;      --Hide our pins when viewing quest details
local TooltipFrame = GameTooltip;

local PinController = CreateFrame("Frame");
local WorldMapDataProvider = CreateFromMixins(MapCanvasDataProviderMixin);

--As a solution to the potential taint caused by MapDataProvider
--We use this child frame of WorldMapFrame to check its mapID every 1/60 seconds
local MapTracker = CreateFrame("Frame");
MapTracker:Hide();

local C_VignetteInfo = C_VignetteInfo;
local GetVignetteInfo = C_VignetteInfo.GetVignetteInfo;
local GetVignettePosition = C_VignetteInfo.GetVignettePosition;
local IsWorldQuest = C_QuestLog.IsWorldQuest;
local After = C_Timer.After;
local InCombatLockdown = InCombatLockdown;
local format = string.format;
local pairs = pairs;
local ipairs = ipairs;
local _G = _G;

local SecondsToTime = API.SecondsToTime;
local DreamseedUtil = API.DreamseedUtil;    --Defined in Dreamseed.lua
local GetCreatureIDFromGUID = API.GetCreatureIDFromGUID;
local GetVignetteIDFromGUID = API.GetVignetteIDFromGUID;    --this is a string method, not using C_VignetteInfo

PinController.pins = {};
PinController.isRelavantVignetteGUID = {};
PinController.chestOwnerCreatureID = nil;     --Construct when required

local function Debug_SaveCreatureLocation(objectGUID, x, y)
    if not PlumberDevOutput then
        PlumberDevOutput = {};
    end
    if not PlumberDevOutput.CreatureLocations then
        PlumberDevOutput.CreatureLocations = {};
    end

    local creatureID = API.GetCreatureIDFromGUID(objectGUID);

    if not PlumberDevOutput.CreatureLocations[creatureID] then
        local total = 0;
        for k, v in pairs(PlumberDevOutput.CreatureLocations) do
            total = total + 1;
        end
        print(string.format("#%d NEW POSITION ADDED", total + 1));
        PlumberDevOutput.CreatureLocations[creatureID] = {x, y};
    end
end

local function IsViewingQuestDetails()
    return QuestDetailsFrame and QuestDetailsFrame:IsVisible();
end

function PinController:AddPin(pin)
    table.insert(self.pins, pin);
end

function PinController:UpdatePins()
    self.pinDirty = false;
    for _, pin in pairs(self.pins) do
        if not pin.cachedCreatureID then
            --Do not update cached (not-spawned) pins
            pin:UpdateState();
        end
    end
end

function PinController:AddTinyBar(tinybar)
    if not self.tinybars then
        self.tinybars = {};
    end
    table.insert(self.tinybars, tinybar);
end

function PinController:UpdateTinyBarSize()
    self.tinybarDirty = false;
    if self.tinybars then
        for i, tinybar in ipairs(self.tinybars) do
            if tinybar:IsShown() then
                tinybar:Init();
            end
        end
    end
end

function PinController:UpdatePinSize()
    local tempIndex;
    for _, pin in ipairs(self.pins) do
        tempIndex = pin.visualIndex;
        pin.visualIndex = nil;
        pin:SetVisual(tempIndex);
    end
end

function PinController:UpdateTinyBarHeight()
    self.tinybarDirty = false;
    if self.tinybars then
        for i, tinybar in ipairs(self.tinybars) do
            tinybar:SetWidth(PIN_SIZE_ACTIVE);
            tinybar:SetBarHeight(PIN_TINY_BAR_HEIGHT);
        end
    end
end

function PinController:RequestUpdatePins()
    self.pinDirty = true;
    self:SetScript("OnUpdate", self.OnUpdate);
end

function PinController:RequestUpdateTinyBarSize()
    self.tinybarDirty = true;
    self:SetScript("OnUpdate", self.OnUpdate);
end

function PinController:RequestUpdateAllData()
    self.vignetteDirty = true;
    self:SetScript("OnUpdate", self.OnUpdate);
end

function PinController:OnUpdate(elapsed)
    self:SetScript("OnUpdate", nil);
    if self.tinybarDirty then
        self:UpdateTinyBarSize();
    end
    if self.vignetteDirty then
        self.vignetteDirty = false;
        self.pinDirty = false;
        WorldMapDataProvider:RefreshAllData();
    end
    if self.pinDirty then
        self:UpdatePins();  --60 KB
    end
end

function PinController:ListenEvents(state)
    if state then
        self:RegisterEvent("UPDATE_UI_WIDGET");
        self:RegisterEvent("VIGNETTES_UPDATED");
        self.mapOpened = true;
        --self:RegisterEvent("VIGNETTE_MINIMAP_UPDATED");
    else
        self:UnregisterEvent("UPDATE_UI_WIDGET");
        self:UnregisterEvent("VIGNETTES_UPDATED");
        self.mapOpened = false;
        --self:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED");
    end
end

function PinController:OnEvent(event, ...)
    if event == "UPDATE_UI_WIDGET" then
        local widgetInfo = ...
        if (not self.pinDirty) and DreamseedUtil:IsValuableWidget(widgetInfo.widgetID) then
            self:RequestUpdatePins();
        end
    elseif event == "VIGNETTES_UPDATED" then
        self:RequestUpdateAllData();
    elseif event == "VIGNETTE_MINIMAP_UPDATED" then
        local vignetteGUID, onMinimap = ...
        if not onMinimap then
            local vignetteID = GetVignetteIDFromGUID(vignetteGUID);
            if self.chestOwnerCreatureID[vignetteID] then
                --if the removed minimap icon is a Dreamseed Chest
                After(0.5, function()
                    local owner = self.chestOwnerCreatureID[vignetteID];
                    if not GetVignetteInfo(vignetteGUID) then
                        DreamseedUtil:SetChestStateByCreatureID(owner, false);
                    end
                end)
            end
        end
        if self.mapOpened and self.isRelavantVignetteGUID[vignetteGUID] then
            self:RequestUpdateAllData();
        end
    end
end

function PinController:ResetAllCreatureSpawnStates()
    if not self.creatureIDXPin then
        self.creatureIDXPin = DreamseedUtil:GetPlantCreatureIDs();
    end

    for creatureID in pairs(self.creatureIDXPin) do
        self.creatureIDXPin[creatureID] = false;
    end
end

function PinController:SetCreatureSpawnState(creatureID, hasSpawned)
    self.creatureIDXPin[creatureID] = hasSpawned;
end

function PinController:ProcessNotSpawnedCreatures(mapFrame)
    --Show pin that is not spawned but has an unlooted chest
    local pin;

    for creatureID, state in pairs(self.creatureIDXPin) do
        if not state then
            if DreamseedUtil:HasAnyRewardByCreatureID(creatureID) then
                local chestInfo = DreamseedUtil:TryGetChestInfoByCreatureID(creatureID);
                local objectGUID, x, y;

                if chestInfo then
                    objectGUID, x, y = chestInfo[1], chestInfo[2], chestInfo[3];
                else
                    local position = DreamseedUtil:GetBackupLocation(creatureID);
                    if position then
                        x, y = position[1], position[2];
                    end
                end

                if x and y then
                    pin = mapFrame:AcquirePin(PIN_TEMPLATE_NAME, nil, objectGUID);
                    pin.cachedCreatureID = creatureID;
                    pin:SetPosition(x, y);
                    pin:SetVisual(0);
                    if pin.TinyBar then
                        pin.TinyBar:Hide();
                    end
                end
            end
        end
    end
end

function PinController:EnableModule(state)
    if state then
        if not self.chestOwnerCreatureID then
            self.chestOwnerCreatureID = DreamseedUtil:GetChestOwnerCreatureIDs();
        end
        self:ResetAllCreatureSpawnStates();
        self:RegisterEvent("VIGNETTE_MINIMAP_UPDATED");     --This event will be registered all the time while in Emerald Dream, we need it to track if the player loots a Dreamseed Chest
        self:SetScript("OnEvent", self.OnEvent);
        --DreamseedUtil:Debug_ConstructWidgetID();
    else
        self:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED");
        self:ListenEvents(false);
        self:SetScript("OnEvent", nil);
    end
end


local function RemoveDefaultVignettePins()
    local pool = MapFrame.pinPools["VignettePinTemplate"];
    if pool then
        for pin in pool:EnumerateActive() do
            if pin:GetVignetteID() == VIGID_BOUNTY then
                --This will make the RAM usage of Blizzard VignetteDataProvider count towards our addon
                --But it doesn't really increase the overall RAM usage
                --Users might wonder why this addon uses 500 KB RAM per second when the WorldMapFrame is open in Emerald Dream
                pin.vignetteGUID = 0;
            end
        end
    end
end



local function Dummy_SetPassThroughButtons()
end

PlumberDreamseedMapPinMixin = CreateFromMixins(MapCanvasPinMixin);

function PlumberDreamseedMapPinMixin:OnCreated()
    --When frame being created
    self.originalSetPassThroughButtons = self.SetPassThroughButtons;
    self.SetPassThroughButtons = Dummy_SetPassThroughButtons;
    self:AllowPassThroughRightButton(true);
end

function PlumberDreamseedMapPinMixin:OnLoad()
    --newPin (see MapCanvasMixin:AcquirePin)
	self:SetScalingLimits(1, 1.0, 1.2);
    self.pinFrameLevelType = "PIN_FRAME_LEVEL_GROUP_MEMBER";    --PIN_FRAME_LEVEL_VIGNETTE  PIN_FRAME_LEVEL_AREA_POI   PIN_FRAME_LEVEL_WAYPOINT_LOCATION  PIN_FRAME_LEVEL_GROUP_MEMBER
    self.pinFrameLevelIndex = 1;
    self:SetTexture("Interface/AddOns/Plumber/Art/MapPin/SeedPlanting-Empty-Distant");
    PinController:AddPin(self);
end

function PlumberDreamseedMapPinMixin:IsMouseClickEnabled()
    return true
end

function PlumberDreamseedMapPinMixin:AllowPassThroughRightButton(unpackedPrimitiveType)
    --Original "SetPassThroughButtons" (see SimpleScriptRegionAPI for details) has chance to taint when called
    --So we overwrite it
    if (not self.isRightButtonAllowed) and (not InCombatLockdown()) then
        self.isRightButtonAllowed = true;
        if self.originalSetPassThroughButtons then
            self.originalSetPassThroughButtons(self, "RightButton");
        end
    end
end

function PlumberDreamseedMapPinMixin:SetTexture(texture)
    self.Texture:SetTexture(texture, nil, nil, "LINEAR");
    self.HighlightTexture:SetTexture(texture, nil, nil, "LINEAR");
    self.HighlightTexture:SetVertexColor(0.4, 0.4, 0.4);
end

function PlumberDreamseedMapPinMixin:OnMouseLeave()
    --BaseMapPoiPinMixin.OnMouseLeave(self);

    TooltipFrame:Hide();
end

local function MapPin_UpdateTooltip(self)
    if self.objectGUID then
        local remainingTime, fullTime = DreamseedUtil:GetGrowthTimes(self.objectGUID);
        if remainingTime and remainingTime > 0 then
            if remainingTime ~= self.remainingTime then
                self.remainingTime = remainingTime;
                local timeText = format(FORMAT_TIME_LEFT, SecondsToTime(remainingTime, true));
                if TooltipFrame.TextLeft2 and TooltipFrame.TextLeft2:GetText() then
                    TooltipFrame.TextLeft2:SetText(timeText);
                else
                    TooltipFrame:AddLine(timeText, 1, 0.82, 0, false);
                end

                local progressText = DreamseedUtil:GetNurtureProgress(self.objectGUID, true);
                if GameTooltipTextLeft3 and GameTooltipTextLeft3:GetText() then
                    GameTooltipTextLeft3:SetText(progressText);
                else
                    TooltipFrame:AddLine(progressText, 1, 1, 1, false);
                end

                TooltipFrame:Show();
            end
        end
    end
end

function PlumberDreamseedMapPinMixin:OnMouseEnter()
    local name, hasReward, isFromCache;

    if self.objectGUID then
        name = DreamseedUtil:GetPlantNameAndProgress(self.objectGUID);
        hasReward = DreamseedUtil:HasAnyReward(self.objectGUID);
    elseif self.cachedCreatureID then
        --This is when the pin doesn't spawn but has a possible loot
        name = DreamseedUtil:GetPlantNameByCreatureID(self.cachedCreatureID);
        hasReward = true;
        isFromCache = true;
    end

    self.name = name;
    if name then
        TooltipFrame:Hide();
        TooltipFrame:SetOwner(self, "ANCHOR_RIGHT");
        TooltipFrame:AddLine(name, 1, 1, 1, true);
        TooltipFrame:Show();
    else
        return
    end

    if self.isActive then
        self.remainingTime = nil;
        MapPin_UpdateTooltip(self);
    end

    local resourceText = DreamseedUtil:GetResourcesText();
    if resourceText then
        TooltipFrame:AddLine(resourceText, 1, 1, 1, false);
    end

    if hasReward then
        TooltipFrame:AddLine(WEEKLY_REWARDS_UNCLAIMED_TITLE, 0.098, 1.000, 0.098, false);   --GREEN_FONT_COLOR
    end

    if TomTomUtil:IsTomTomAvailable() then
        TooltipFrame:AddLine(addon.L["Click To Track In TomTom"], 1, 0.82, 0, true);
        self:SetClickable(true);
    else
        if (hasReward or self.isActive) and addon.ControlCenter:ShouldShowNavigatorOnDreamseedPins() then
            TooltipFrame:AddLine(addon.L["Click To Track Location"], 1, 0.82, 0, true);
            self:SetClickable(true);
        else
            self:SetClickable(false);
        end
    end

    TooltipFrame:Show();

    self:AllowPassThroughRightButton(true);
end

function PlumberDreamseedMapPinMixin:OnMouseClickAction(mouseButton)
    if mouseButton == "LeftButton" then
        if TomTomUtil:IsTomTomAvailable() then
            local x, y = self:GetPosition();
            local desc = self.name;
            TomTomUtil:AddWaypoint(MAPID_EMRALD_DREAM, x, y, desc);
        else
            if addon.ControlCenter:ShouldShowNavigatorOnDreamseedPins() then
                addon.ControlCenter:EnableSuperTracking();
                self:OnMouseEnter();
            end
        end
    end
end

function PlumberDreamseedMapPinMixin:SetClickable(state)
    if state ~= self.isClickable then
        self.isClickable = state;
    end
    self:SetMouseClickEnabled(state);
end

function PlumberDreamseedMapPinMixin:OnAcquired(vignetteGUID, objectGUID)
    self.vignetteGUID = vignetteGUID;
    self.Texture:SetTexCoord(0.21875, 0.78125, 0.21875, 0.78125);
    self.HighlightTexture:SetTexCoord(0.21875, 0.78125, 0.21875, 0.78125);
    self.remainingTime = nil;
    self.objectGUID = objectGUID;
    self.isActive = nil;
    self.hasReawrd = nil;
    self.cachedCreatureID = nil;
end

function PlumberDreamseedMapPinMixin:UpdateReward(creatureID)
    local hasReawrd, hasLocation = DreamseedUtil:HasAnyRewardByCreatureID(creatureID);
    if hasReawrd then
        self.hasReawrd = true;
        if not hasLocation then
            local x, y = self:GetPosition();
            DreamseedUtil:SetChestStateByCreatureID(creatureID, true, self.objectGUID, x, y);
        end
    end
end

function PlumberDreamseedMapPinMixin:UpdateState()
    if not self.objectGUID then
        self:Hide();
        return
    end

    local creatureID = GetCreatureIDFromGUID(self.objectGUID);
    local remainingTime, fullTime = DreamseedUtil:GetGrowthTimesByCreatureID(creatureID);
    local isActive = remainingTime and remainingTime > 0;
    PinController:SetCreatureSpawnState(creatureID, true);

    if isActive then
        if not self.isActive then
            self.isActive = true;
            self:SetVisual(3);
            self.UpdateTooltip = MapPin_UpdateTooltip;

            if not self.TinyBar then
                self.TinyBar = addon.CreateTinyStatusBar(self);
                self.TinyBar:SetPoint("TOP", self, "BOTTOM", 0, -2);
                self.TinyBar:SetWidth(PIN_SIZE_ACTIVE);
                self.TinyBar:SetBarHeight(PIN_TINY_BAR_HEIGHT);
                PinController:AddTinyBar(self.TinyBar);
            end

            self.TinyBar:Show();
            self.TinyBar:SetReverse(true);
            self.TinyBar:Init();

            self:UpdateReward(creatureID);
        end
        self.TinyBar:SetTimes(fullTime - remainingTime, fullTime);
    else
        if self.isActive or self.isActive == nil then
            self.isActive = false;
            self:SetVisual(1);
            self.UpdateTooltip = nil;
            if self.TinyBar then
                self.TinyBar:Hide();
            end
        end

        self:UpdateReward(creatureID);
        if self.hasReawrd then
            self:SetVisual(0);
        elseif HIDE_INACTIVE_PIN then
            self:Hide();
        end
    end
end

function PlumberDreamseedMapPinMixin:SetVisual(index)
    if index ~= self.visualIndex then
        self.visualIndex = index;
    else
        return
    end

    if index == 1 or index == 0 then
        --EmptySoil, far away
        self:SetSize(PIN_SIZE_DORMANT, PIN_SIZE_DORMANT);
        self.Texture:SetSize(PIN_SIZE_ACTIVE, PIN_SIZE_ACTIVE); --We changed the icon size in the file
        if index == 1 then
            self:SetTexture(PIN_DORMANT_TEXTURE);
        elseif index == 0 then
            self:SetTexture("Interface/AddOns/Plumber/Art/MapPin/SeedPlanting-Bud");   --Unlooted
        end
    else
        self:SetSize(PIN_SIZE_ACTIVE, PIN_SIZE_ACTIVE);
        self.Texture:SetSize(PIN_SIZE_ACTIVE, PIN_SIZE_ACTIVE);
        if index == 2 then
            --EmptySoil, nearby
            self:SetTexture("Interface/AddOns/Plumber/Art/MapPin/SeedPlanting-Empty-Nearby");
        elseif index == 3 then
            --Small
            self:SetTexture("Interface/AddOns/Plumber/Art/MapPin/SeedPlanting-Full");   --Green
        elseif index == 4 then
            --Plump
            self:SetTexture("Interface/AddOns/Plumber/Art/MapPin/SeedPlanting-Full");   --Blue
        elseif index == 5 then
            --Gigantic
            self:SetTexture("Interface/AddOns/Plumber/Art/MapPin/SeedPlanting-Full");   --Purple
        end
    end
end


function WorldMapDataProvider:GetPinTemplate()
	return PIN_TEMPLATE_NAME
end

function WorldMapDataProvider:OnShow()

end

function WorldMapDataProvider:OnHide()
    PinController:ListenEvents(false);
end

function WorldMapDataProvider:OnEvent(event, ...)
    --This significantly increase RAM usage count
    --So we monitor Events using another frame (PinController) 
end

function WorldMapDataProvider:RemoveAllIfNeeded()
    if self.anyPins then
        self:RemoveAllData();
    end
end

function WorldMapDataProvider:RemoveAllData()
    self.anyPins = false;
    PinController:ResetAllCreatureSpawnStates();
	MapFrame:RemoveAllPinsByTemplate(self:GetPinTemplate());
end

function WorldMapDataProvider:RefreshAllData(fromOnShow)
	self:RemoveAllIfNeeded();
    self:ShowAllPins();
end

function WorldMapDataProvider:RefreshAllDataIfPossible()
    if DATA_PROVIDER_ADDED then
        self:RemoveAllIfNeeded();
        if not IsViewingQuestDetails() then
            self:ShowAllPins();
        end
    end
end

function WorldMapDataProvider:ShowAllPins()
    if not ENABLE_MAP_PIN then return end;

    local uiMapID = MapTracker:GetMapID()   --self:GetMap():GetMapID();

    if uiMapID ~= MAPID_EMRALD_DREAM then
        PinController:ListenEvents(false);
        return
    end

    local vignetteGUIDs = C_VignetteInfo.GetVignettes();
    local pin;
    local info, vignettePosition, vignetteFacing;
    local mapFrame = MapFrame;
    local relavantVignetteGUIDs = {};
    local total = 0;
    local pins = {};

    PinController.isRelavantVignetteGUID = {};

    for i, vignetteGUID in ipairs(vignetteGUIDs) do
        info = GetVignetteInfo(vignetteGUID);
        if info and info.vignetteID == VIGID_BOUNTY then
            vignettePosition, vignetteFacing = GetVignettePosition(info.vignetteGUID, uiMapID);
            if vignettePosition then
                pin = mapFrame:AcquirePin(PIN_TEMPLATE_NAME, vignetteGUID, info.objectGUID);
                pin:SetPosition(vignettePosition:GetXY());
                pin:UpdateState();
                total = total + 1;
                relavantVignetteGUIDs[total] = vignetteGUID;
                PinController.isRelavantVignetteGUID[vignetteGUID] = true;
                pins[total] = pin;

                --Debug_SaveCreatureLocation(info.objectGUID, vignettePosition:GetXY());
            end
        end
    end

    PinController:ProcessNotSpawnedCreatures(mapFrame);

    local bestUniqueVignetteIndex = C_VignetteInfo.FindBestUniqueVignette(relavantVignetteGUIDs) or 0;
    for i, pin in ipairs(pins) do
        if pin.isActive then
            if PIN_ICON_PRIORITIZE_REWARD and pin.hasReawrd then
                pin:SetVisual(0);
            else
                pin:SetVisual(3);
            end
        elseif pin.hasReawrd then
            pin:SetVisual(0);
        elseif i == bestUniqueVignetteIndex then
            pin:SetVisual(2);
        else
            pin:SetVisual(1);
        end
    end

    PinController:ListenEvents(true);
    self.anyPins = true;
    RemoveDefaultVignettePins();
end

function WorldMapDataProvider:OnCanvasScaleChanged()
    --Fires multiple times when opening WorldMapFrame
    PinController:RequestUpdateTinyBarSize();
end


local function OnPingQuestID(f, questID)
    --TODO? Hide pins when checking quest detail?
    if not ENABLE_MAP_PIN then return end;

    if questID and IsWorldQuest(questID) then

    else
        local uiMapID = MapFrame:GetMapID();
        if uiMapID == MAPID_EMRALD_DREAM then
            --Temporarily mutes our pin when viewing quest details
            WorldMapDataProvider:RemoveAllIfNeeded();
            PinController:ListenEvents(false);
        end
    end
end


local FilterFrame = CreateFrame("Frame", nil, UIParent);
FilterFrame:Hide();
FilterFrame:SetFrameStrata("TOOLTIP");
FilterFrame:SetFixedFrameStrata(true);
FilterFrame:SetIgnoreParentScale(true);


function MapTracker:Attach()
    if not self.attached then
        self.attached = true;
        self:SetParent(MapFrame);
        self:EnableScripts();
        self:Show();
    end
end

function MapTracker:Detach()
    if self.attached then
        self.attached = nil;
        self.mapID = nil;
        self:SetParent(nil);
        self:DisableScripts();
        self:Hide();
        WorldMapDataProvider:RemoveAllIfNeeded();
        WorldMapDataProvider:OnHide();
    end
end

function MapTracker:OnUpdate(elapsed)
    self.t1 = self.t1 + elapsed;
    self.t2 = self.t2 + elapsed;

    if self.t1 > 0.016 then
        self.t1 = 0;

        self.newMapID = MapFrame.mapID;
        if self.newMapID ~= self.mapID then
            self.mapID = self.newMapID;
            self:OnMapChanged();
        end

        self.newScale = MapScrollContainer.targetScale;
        if self.newScale ~= self.mapScale then
            self.mapScale = self.newScale;
            self:OnCanvasScaleChanged();
        end
    end

    if self.t2 > 0.1 then
        self.t2 = 0;
        self.detailsVisiblity = IsViewingQuestDetails();
        if self.detailsVisiblity ~= self.isViewingDetails then
            self.isViewingDetails = self.detailsVisiblity;
            self:OnViewingQuestDetailsChanged();
        end
    end
end

function MapTracker:OnShow()
    self.mapID = nil;
    self.mapScale = nil;
    self.isViewingDetails = IsViewingQuestDetails();
    self.t1 = 1;
    --self:OnUpdate(1);
end

function MapTracker:OnHide()
    WorldMapDataProvider:OnHide();
end

function MapTracker:EnableScripts()
    self.t1 = 0;
    self.t2 = 0;
    self:SetScript("OnShow", self.OnShow);
    self:SetScript("OnHide", self.OnHide);
    self:SetScript("OnUpdate", self.OnUpdate);
end

function MapTracker:DisableScripts()
    self:SetScript("OnShow", nil);
    self:SetScript("OnHide", nil);
    self:SetScript("OnUpdate", nil);
end

function MapTracker:GetMapID()
    return self.mapID
end

function MapTracker:OnMapChanged()
    WorldMapDataProvider:RefreshAllDataIfPossible();
end

function MapTracker:OnCanvasScaleChanged()
    WorldMapDataProvider:OnCanvasScaleChanged();
    --PinController:UpdateTinyBarSize();
end

function MapTracker:OnViewingQuestDetailsChanged()
    if self.isViewingDetails then

    else
        if ENABLE_MAP_PIN then
            WorldMapDataProvider:RefreshAllDataIfPossible();
        end
    end
end


local function LoadOptionalSettings()
    --Settings that are controlled by command, no UI (due to specific user request)
    --Requires /reload
    if not PlumberDB then return end;

    PIN_ICON_PRIORITIZE_REWARD = (PlumberDB.PinIconPrioritizeReward and true) or false;
end

local ZoneTriggerModule;

local function EnableModule(state)
    if state then
        ENABLE_MAP_PIN = true;

        if not ZoneTriggerModule then
            local module = API.CreateZoneTriggeredModule("mappin");
            ZoneTriggerModule = module;
            module:SetValidZones(MAPID_EMRALD_DREAM);

            local function OnEnterZoneCallback()
                if not DATA_PROVIDER_ADDED then
                    --We register our module when the player is in Emerald Dream
                    DATA_PROVIDER_ADDED = true;
                    --MapFrame:AddDataProvider(WorldMapDataProvider);   --Potential taint!
                    MapFrame:RegisterCallback("PingQuestID", OnPingQuestID, PinController);
                end
                MapTracker:Attach();
                PinController:EnableModule(true);
                DreamseedUtil:RequestScanChests();
            end

            local function OnLeaveZoneCallback()
                MapTracker:Detach();
                PinController:EnableModule(false);
                DreamseedUtil:PauseScanner();
            end

            module:SetEnterZoneCallback(OnEnterZoneCallback);
            module:SetLeaveZoneCallback(OnLeaveZoneCallback);

            LoadOptionalSettings();
        end
        ZoneTriggerModule:SetEnabled(true);
        ZoneTriggerModule:Update();
    else
        if ENABLE_MAP_PIN then
            if DATA_PROVIDER_ADDED then
                WorldMapDataProvider:RemoveAllData();
            end
            PinController:ListenEvents(false);
            PinController:SetScript("OnUpdate", nil);
        end
        if ZoneTriggerModule then
            ZoneTriggerModule:SetEnabled(false);
        end
        ENABLE_MAP_PIN = false;
    end
end

local function GetMapPinSizeSetting()
    local id = PlumberDB and PlumberDB.MapPinSize;
    if not id then
        id = 1;
    end
    return id
end

local function SetPinSizeByID(id, update)
    if (not id) or (id ~= 1 and id ~= 2) then return end;

    if id == 1 then
        PIN_SIZE_DORMANT = 12;
        PIN_SIZE_ACTIVE = 18;
        PIN_TINY_BAR_HEIGHT = 2;
        PIN_DORMANT_TEXTURE = "Interface/AddOns/Plumber/Art/MapPin/SeedPlanting-Empty-Distant";
    elseif id == 2 then
        PIN_SIZE_DORMANT = 18;
        PIN_SIZE_ACTIVE = 22;
        PIN_TINY_BAR_HEIGHT = 4;
        PIN_DORMANT_TEXTURE = "Interface/AddOns/Plumber/Art/MapPin/SeedPlanting-Empty-Distant-HC";
    end

    if update then
        PinController:UpdatePinSize();
        PinController:UpdateTinyBarHeight();
    end

    if PlumberDB then
        PlumberDB.MapPinSize = id;
    end
end


local LABEL_EMERALD_BOUNTY;

local DropDownButtonMixin = {}; --Shared Template

function DropDownButtonMixin:OnClick()

end

function DropDownButtonMixin:Setup()
    --Show checkmark, button text, icon, etc.
end

function DropDownButtonMixin:SetTitle(text)
    --Title / Dummy button does nothing when clicked
    self.CheckedTexture:Hide();
    self.Text:SetText(text);
    self.Icon:SetTexture(nil);
    self.clickable = false;
    self.dbKey = nil;
    self.Text:ClearAllPoints();
    self.Text:SetPoint("LEFT", self, "LEFT", 5, 0);
    self.Text:SetFontObject("GameFontNormalSmallLeft");
end

function DropDownButtonMixin:SetClickable()
    self.clickable = true;
    self.Reference:SetPoint("LEFT", 0, 0);
    self.Text:ClearAllPoints();
    self.Text:SetPoint("LEFT", self.Reference, "LEFT", 20, 0);
    self.Text:SetFontObject("GameFontHighlightSmallLeft");
end

function DropDownButtonMixin:OnEnter()
    if self.clickable then
        self.Highlight:Show();
    else
        --Header or Divider
    end
end

function DropDownButtonMixin:OnLeave()
    self.Highlight:Hide();
end

function DropDownButtonMixin:OnMouseDown()
    if self.clickable then
        self.Reference:SetPoint("LEFT", 1, -1);
    end
end

function DropDownButtonMixin:OnMouseUp()
    self.Reference:SetPoint("LEFT", 0, 0);
end


local DropDownButtonMixin_Dreamseed = {};

function DropDownButtonMixin_Dreamseed:OnClick()
    if not self.dbKey then return end;

    local newState = not PlumberDB[self.dbKey];
    PlumberDB[self.dbKey] = newState;
    EnableModule(newState);

    if newState and MapFrame:IsShown() and not IsViewingQuestDetails() then
        WorldMapDataProvider:RefreshAllDataIfPossible();
    end

    DropDownButtonMixin_Dreamseed.Setup(self);
end

function DropDownButtonMixin_Dreamseed:Setup()
    local dbKey = DB_KEY_DREAMSEED;
    local state = PlumberDB[dbKey];

    if state then
        self.CheckedTexture:Show();
    else
        self.CheckedTexture:Hide();
    end

    if self.dbKey ~= dbKey then
        self.dbKey = dbKey;
        if not LABEL_EMERALD_BOUNTY then
            LABEL_EMERALD_BOUNTY = API.GetCreatureName(211123);
        end
        self.Text:SetText(LABEL_EMERALD_BOUNTY or "Emerald Bounty");
        self.Icon:SetTexture("Interface/AddOns/Plumber/Art/MapPin/DopdownIcon/Dreamseed");
        self.Icon:Show();
    end
end

local MAP_FILTER_OPTIONS = {
    [MAPID_EMRALD_DREAM] = {DropDownButtonMixin_Dreamseed},
};


function FilterFrame:HookWorldFilterFrameButton()
    --Find WorldMapTrackingOptionsButtonMixin (Map Filter)
    if self.hasHooked then return end;
    self.hasHooked = true;  --Assert it true no matter we find the button or not

    if not MapFrame.overlayFrames then return end;

    local objType;

    for i, obj in ipairs(MapFrame.overlayFrames) do
        objType = obj:GetObjectType();
        if objType == "Button" then
            if obj.IsTrackingFilter ~= nil and obj.DropDown ~= nil then
                obj:HookScript("OnMouseDown", function(_, button)
                    self:BlizzardMapFilter_OnMouseDown();
                end);
            end
        end
    end
end

function FilterFrame:AcquireOptionButton(i)
    local button = self.buttons[i];

    if not button then
        button = CreateFrame("Button", nil, self);
        self.buttons[i] = button;
        button:SetSize(100, 16);

        if i ~= 1 then
            button:SetPoint("TOPLEFT", self.buttons[i - 1], "BOTTOMLEFT", 0, 0);
        end

        button.Reference = button:CreateTexture(nil, "BACKGROUND");
        button.Reference:SetSize(16, 16);
        button.Reference:SetPoint("LEFT", button, "LEFT", 0, 0);

        button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmallLeft");
        button.Text:SetJustifyH("LEFT");
        button.Text:SetPoint("LEFT", button.Reference, "LEFT", 20, 0);

        button.CheckedTexture = button:CreateTexture(nil, "OVERLAY");
        button.CheckedTexture:SetTexture("Interface/AddOns/Plumber/Art/Button/Checkbox");
        button.CheckedTexture:SetTexCoord(0.5, 0.75, 0.5, 0.75);
        button.CheckedTexture:SetSize(16, 16);
        button.CheckedTexture:SetPoint("LEFT", button, "LEFT", 0, 0);

        button.Icon = button:CreateTexture(nil, "OVERLAY");
        button.Icon:SetSize(16, 16);
        button.Icon:SetPoint("RIGHT", button, "RIGHT", 0, 0);

        button.Highlight = button:CreateTexture(nil, "BACKGROUND");
        button.Highlight:Hide();
        button.Highlight:SetAllPoints(true);
        button.Highlight:SetTexture("Interface/QuestFrame/UI-QuestTitleHighlight");
        button.Highlight:SetBlendMode("ADD");

        button:SetScript("OnEnter", DropDownButtonMixin.OnEnter);
        button:SetScript("OnLeave", DropDownButtonMixin.OnLeave);
        button:SetScript("OnMouseDown", DropDownButtonMixin.OnMouseDown);
        button:SetScript("OnMouseUp", DropDownButtonMixin.OnMouseUp);
    end

    button:Show();
    return button
end

function FilterFrame:CreateOptionList(dropdownWidth)
    local buttonWidth = (dropdownWidth or 120) - 22;

    if not self.buttons then
        self.buttons = {};
    end

    local numButtons = #self.buttonList;
    local numDummies = 2;    --add a Divider and a Title

    numButtons = numButtons + numDummies;

    local button, buttonMixin, dataIndex;

    for i = 1, numButtons do
        button = self:AcquireOptionButton(i);
        if i <= numDummies then
            if i == 1 then
                DropDownButtonMixin.SetTitle(button, nil);
            elseif i == 2 then
                --[[
                if not self.mapName then
                    local info = C_Map.GetMapInfo(self.uiMapID);
                    self.mapName = info and info.name or nil;
                end
                --]]
                DropDownButtonMixin.SetTitle(button, "Plumber");
            end
            button:SetScript("OnClick", nil);
        else
            buttonMixin = self.buttonList[i - numDummies];
            DropDownButtonMixin.SetClickable(button);
            buttonMixin.Setup(button);
            button:SetScript("OnClick", buttonMixin.OnClick);
        end
        button:SetWidth(buttonWidth);
    end

    return self.buttons[1], numButtons
end

function FilterFrame:CloseUI()
    if self.buttons then
        for i, button in ipairs(self.buttons) do
            if i == 1 then
                button:ClearAllPoints();
            end
            button:Hide();
        end
    end
    self:SetScript("OnUpdate", nil);
    self:SetScript("OnEvent", nil);
    self:Hide();
    self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
    self.targetDropdown = nil;
end

function FilterFrame:ShowUI()
    self:RegisterEvent("GLOBAL_MOUSE_DOWN");
    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate_CheckVisibility);
    self:SetScript("OnEvent", self.OnEvent);
    self:Show();
end

function FilterFrame:OnEvent(event, ...)
    if not (self.targetDropdown and self.targetDropdown:IsMouseOver()) then
        self:CloseUI();
    end
end

function FilterFrame:OnUpdate_CheckVisibility(elapsed)
    if not (self.targetDropdown and self.targetDropdown:IsShown()) then
        self:CloseUI();
    end
end

function FilterFrame:OnUpdate_UpdateAfter(elapsed)
    --We update on the next n frame
    self.n = self.n + 1;
    if self.n < 2 then return end;

    self:SetScript("OnUpdate", nil);
    if self.targetDropdown and self.targetDropdown:IsShown() then
        self:SetupDropDown(self.targetDropdown);
    end
end

function FilterFrame:RequestUpdateDropdown(targetDropdown, uiMapID)
    self.n = 0;
    self.targetDropdown = targetDropdown;
    if uiMapID ~= self.uiMapID then
        self.uiMapID = uiMapID;
        self.mapName = nil;
    end
    self.buttonList = MAP_FILTER_OPTIONS[uiMapID];
    self:Show();
    self:SetScript("OnUpdate", self.OnUpdate_UpdateAfter);
end

function FilterFrame:GetBestDropDownHeight(dropdown)
    local backgroundFrame = _G["DropDownList1MenuBackdrop"];
    local height1 = dropdown:GetHeight();
    local height2;
    local diffHeight = 0;
    if backgroundFrame then
        height2 = backgroundFrame:GetHeight();
        if height2 - height1 > 1 then
            diffHeight = height2 - height1;
        end
    end
    return math.max(height1, height2), diffHeight
end

function FilterFrame:SetupDropDown(dropdown)
    local scale = dropdown:GetEffectiveScale();
    local top = dropdown:GetTop();
    local left = dropdown:GetLeft();
    local width = dropdown:GetWidth();
    local height, diffHeight = self:GetBestDropDownHeight(dropdown);
    local firstButton, numButtons = self:CreateOptionList(width);
    local extraHeight = (UIDROPDOWNMENU_BUTTON_HEIGHT or 16) * numButtons - diffHeight;
    local xPos = 11;

    self:SetScale(scale);
    firstButton:ClearAllPoints();
    firstButton:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left + xPos, top - height + (UIDROPDOWNMENU_BORDER_HEIGHT or 15));
    dropdown:SetHeight(height + extraHeight);

    self:ShowUI();

    if not self.SizeSelectFrame then
        local SizeSelectFrame = addon.CreateSimpleSizeSelect(self);
        self.SizeSelectFrame = SizeSelectFrame;
        SizeSelectFrame:ClearAllPoints();
        SizeSelectFrame:SetPoint("TOPRIGHT", firstButton, "BOTTOMRIGHT", 0, 0); --firstButton is a blank line
        SizeSelectFrame:SetNumChoices(2);
        SizeSelectFrame:SelectSize( GetMapPinSizeSetting() );
        SizeSelectFrame:SetOnSizeChangedCallback(SetPinSizeByID);
        SizeSelectFrame:Show();
    end
end

function FilterFrame:BlizzardMapFilter_OnMouseDown()
    local uiMapID = MapFrame:GetMapID();
    if not (uiMapID and MAP_FILTER_OPTIONS[uiMapID]) then return end;

    local dropdown = _G["DropDownList1"];
    if dropdown and dropdown:IsShown() then
        self:RequestUpdateDropdown(dropdown, uiMapID);
    else
        self:CloseUI();
    end
end

FilterFrame:SetScript("OnHide", function(self)
    self:CloseUI();
end);


do
    --Map Filter is independent from Map Pin Settings
    FilterFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
    FilterFrame:SetScript("OnEvent", function(self, event)
        self:UnregisterEvent(event);
        self:SetScript("OnEvent", nil);
        self:HookWorldFilterFrameButton();
        LABEL_EMERALD_BOUNTY = API.GetCreatureName(211123);

        SetPinSizeByID( GetMapPinSizeSetting() );
    end);
end


do
    local moduleData = {
        name = addon.L["ModuleName WorldMapPinSeedPlanting"],
        dbKey = DB_KEY_MASTER_SWITCH,   --WorldMapPinSeedPlanting
        description = addon.L["ModuleDescription WorldMapPinSeedPlanting"],
        toggleFunc = EnableModule,
        categoryID = 10020000,
        uiOrder = 2,
    };

    addon.ControlCenter:AddModule(moduleData);
end



--[[
The map pin for Ringing Rose overlays with zone text "Lushdream Crags", players may find it annoying

Superbloom
    Bloom: /dump C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(4969)
    Scenario Progess: /dump C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo(4997) --4990, 4947
    Next Superbloom: /dump C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo(5328)
    C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo
--]]