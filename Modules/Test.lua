--Show a list of Dreamseed when appoaching Emarad Bounty Soil
--10 yd range: Plant Seed
--6 yd range: Examine Soil (Show what type of flower will sprout. Chat: "Plant a dreamseed from your inventory to sprout [Flower Name]"


local _, addon = ...
local API = addon.API;


local MAPID_EMRALD_DREAM = 2200;
local VIGID_BOUNTY = 5971;
local RANGE_PLANT_SEED = 10;
local SEED_ITEM_IDS = {208066, 208067, 208047};     --Small, Plump, GiganticDreamseed
local SSED_SPELL_IDS = {417642, 417645, 417508};

local C_VignetteInfo = C_VignetteInfo;
local GetVignetteInfo = C_VignetteInfo.GetVignetteInfo;
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition;
local IsFlying = IsFlying;
local InCombatLockdown = InCombatLockdown;

--[[
function YeetPOI()
    --Town
    local uiMapID = C_Map.GetBestMapForUnit("player");
    local areaPoiIDs = C_AreaPoiInfo.GetAreaPOIForMap(uiMapID);
    local info;

    for i, areaPoiID in ipairs(areaPoiIDs) do
        info = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID);
        print(i, info.name);
    end
end

function YeetVignette()
    --5971 Emerald Bounty (Plant Dreamseed)

    local uiMapID = C_Map.GetBestMapForUnit("player");
    local vignetteGUIDs = C_VignetteInfo.GetVignettes();
    local info, position;

    local vignettesGUIDs = {};
    local total = 0;

    for i, guid in ipairs(vignetteGUIDs) do
        info = C_VignetteInfo.GetVignetteInfo(guid);
        if info.name == "Emerald Bounty" then
            total = total + 1;
            vignettesGUIDs[total] = info.vignetteGUID;
            print(total, string.format("#%s  type:%s  %s  WorldMap %s  Minimap %s  Unique %s", info.vignetteID, info.type, info.name, tostring(info.onWorldMap), tostring(info.onMinimap), tostring(info.isUnique)));
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
--]]

local function GetVisibleEmeraldBountyVignetteGUID()
    local vignetteGUIDs = C_VignetteInfo.GetVignettes();
    local info;

    for i, guid in ipairs(vignetteGUIDs) do
        info = GetVignetteInfo(guid);
        if info and info.vignetteID == VIGID_BOUNTY then
            if info.onMinimap then
                return guid
            end
        end
    end
end

local sqrt = math.sqrt;
local EL = CreateFrame("Frame", nil, UIParent);


local function RealActionButton_OnLeave(self)
    if not InCombatLockdown() then
        self:SetScript("OnLeave", nil);
        self:Release();
    end

    if self.owner then
        self.owner:UnlockHighlight();
        self.owner:SetStateNormal();
        self.owner = nil;
    end
end

local function RealActionButton_PostClick(self, button)

end

local function RealActionButton_OnMouseDown(self)
    if self.owner then
        self.owner:SetStatePushed();
    end
end

local function RealActionButton_OnMouseUp(self)
    if self.owner then
        self.owner:SetStateNormal();
    end
end

local function ItemButton_OnEnter(self)
    local RealActionButton = addon.AcquireSecureActionButton();

    if RealActionButton then
        local w, h = self:GetSize();
        RealActionButton:SetFrameStrata("DIALOG");
        RealActionButton:SetFixedFrameStrata(true);
        RealActionButton:SetScript("OnLeave", RealActionButton_OnLeave);
        RealActionButton:SetScript("PostClick", RealActionButton_PostClick);
        RealActionButton:SetScript("OnMouseDown", RealActionButton_OnMouseDown);
        RealActionButton:SetScript("OnMouseUp", RealActionButton_OnMouseUp);
        RealActionButton:ClearAllPoints();
        RealActionButton:SetParent(self);
        RealActionButton:SetSize(w, h);
        RealActionButton:SetPoint("CENTER", self, "CENTER", 0, 0);
        RealActionButton:Show();
        RealActionButton.owner = self;

        local macroText = string.format("/use item:%s", self.id);
        RealActionButton:SetAttribute("type1", "macro");
        RealActionButton:SetAttribute("macrotext", macroText);
        RealActionButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");

        self:LockHighlight();
    end
end

local function ItemButton_OnLeave(self)

end


function EL:Init()
    self.Container = CreateFrame("Frame", nil, self);
    self.Container:SetSize(46, 46);
    self.Container:SetAlpha(0);

    local buttonSize = 46;
    local gap = 4;

    local numButtons = #SEED_ITEM_IDS;
    local span = (buttonSize + gap)*numButtons - gap;
    self.Container:SetWidth(span);
    self.Buttons = {};

    for i, itemID in ipairs(SEED_ITEM_IDS) do
        local button = addon.CreatePeudoActionButton(self.Container);
        self.Buttons[i] = button;
        button:SetPoint("LEFT", self.Container, "LEFT", (i - 1) * (buttonSize +  gap), 0);
        button:SetItem(itemID);
        button:SetScript("OnEnter", ItemButton_OnEnter);
        button:SetScript("OnLeave", ItemButton_OnLeave);
    end

    self.Init = nil;
end

function EL:SetInteractable(state)
    if not self.Buttons then return end;

    for i, button in ipairs(self.Buttons) do
        button:SetEnabled(state);
    end
end

local function GetCastBar()
    return _G["PlayerCastingBarFrame"]
end

function EL:ShowUI()
    if self.Init then
        self:Init();
    end

    --CastingBar's position is not updated on PLAYER_ENTERING_WORLD, so if the player is standing on Soil upon entering, the bar's position can be different
    local anchorTo = GetCastBar();
    local y = anchorTo:GetTop();
    local scale = anchorTo:GetScale();

    self.Container:ClearAllPoints();
    self.Container:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, (y + 30)*scale);   --Default CastingBar moves up 29y when start casting
    self.Container:Show();
    API.UIFrameFade(self.Container, 0.5, 1);

    self:SetInteractable(true);
end

function EL:CloseUI()
    if self.Container and self.Container:IsShown() then
        --self.Container:Hide();
        --self.Container:ClearAllPoints();
        --self.Container:SetPoint("TOP", UIParent, "BOTTOM", 0, -64);
        self:SetInteractable(false);
        API.UIFrameFade(self.Container, 0.5, 0);
    end
end

function EL:GetMapPointsDistance(x1, y1, x2, y2)
    local x = self.mapWidth * (x1 - x2);
    local y = self.mapHeight * (y1 - y2);

    return sqrt(x*x + y*y)
end

EL:RegisterEvent("UPDATE_UI_WIDGET");
EL.widgetData = {};

function EL:AddWidgetInfo(widgetInfo)
    local widgetID = widgetInfo.widgetID;
    if not self.widgetData[widgetID] then
        self.widgetData[widgetID] = widgetInfo.widgetType;
        return true
    end
end

function YeetWidgetInfo()
    for widgetID, widgetType in pairs(EL.widgetData) do
        print("ID:", widgetID, "  Type:", widgetType)
    end
end

function EL:OnEvent(event, ...)
    if event == "VIGNETTE_MINIMAP_UPDATED" then
        local vignetteGUID, onMinimap = ...
        if vignetteGUID == self.trackedVignetteGUID then
            self:StopTrackingPosition();
        elseif onMinimap then
            local info = GetVignetteInfo(vignetteGUID);
            if info.vignetteID == VIGID_BOUNTY then
                self:UpdateTargetLocation(vignetteGUID);
            end
        end
        --print(vignetteGUID, onMinimap);
    elseif event == "PLAYER_STARTED_MOVING" then
        self.isPlayerMoving = true;
    elseif event == "PLAYER_STOPPED_MOVING" then
        self.isPlayerMoving = false;
        self:CalculatePlayerToTargetDistance();
    elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
        self:CalculatePlayerToTargetDistance();
    elseif event == "UPDATE_UI_WIDGET" then
        local widgetInfo = ...
        local isNew = self:AddWidgetInfo(widgetInfo);
        if isNew then
            print("ID:", widgetInfo.widgetID, "  Type:", widgetInfo.widgetType)     --https://wowpedia.fandom.com/wiki/UPDATE_UI_WIDGET
            --/dump C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(5136);    --Growth Cycle!
            --Trigger on the whole map!
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        print(event, ...)
    elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        print(event, ...)
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        print(event, ...)
    end

end
EL:SetScript("OnEvent", EL.OnEvent);

function EL:UpdateTargetLocation(vignetteGUID)
    local position, facing = C_VignetteInfo.GetVignettePosition(vignetteGUID, MAPID_EMRALD_DREAM);
    self.trackedVignetteGUID = vignetteGUID;
    if position then
        self.targetX, self.targetY = position.x, position.y;
        self:StartTrackingPosition();
    else
        self:StopTrackingPosition();
    end
end

function EL:UpdateTrackedVignetteInfo()
    local vignetteGUID = GetVisibleEmeraldBountyVignetteGUID();

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
    if self.t > 0.5 then
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
    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate);
    self:CalculatePlayerToTargetDistance();
end

function EL:StopTrackingPosition()
    if self.trackedVignetteGUID then
        self.trackedVignetteGUID = nil;
        self.isPlayerMoving = nil;
        self:UnregisterEvent("PLAYER_STARTED_MOVING");
        self:UnregisterEvent("PLAYER_STOPPED_MOVING");
        self:UnregisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");
        self:SetScript("OnUpdate", nil);
    end
end

function EL:UpdateMap()
    self.mapWidth, self.mapHeight = C_Map.GetMapWorldSize(MAPID_EMRALD_DREAM);
end

function EL:CalculatePlayerToTargetDistance()
    local position = GetPlayerMapPosition(MAPID_EMRALD_DREAM, "player");
    if position then
        local d = self:GetMapPointsDistance(position.x, position.y, self.targetX, self.targetY);
        --print(string.format("Distance: %.1f yd", d));

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
    self:ShowUI();

    --Watch spell channeling
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "player");
end

function EL:OnLeavingSoil()
    self:CloseUI();

    self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
end


local ZoneTriggerModule;

local function EnableModule(state)
    if state then
        if not ZoneTriggerModule then
            local module = API.CreateZoneTriggeredModule();
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
    end
end

do
    local moduleData = {
        name = addon.L["ModuleName EmeraldBountySeedList"],
        dbKey = "EmeraldBountySeedList",
        description = addon.L["ModuleDescription EmeraldBountySeedList"],
        toggleFunc = EnableModule,
    };

    addon.ControlCenter:AddModule(moduleData);
end

--/script local map = C_Map.GetBestMapForUnit("player");local position = C_Map.GetPlayerMapPosition(map, "player");print(position:GetXY())