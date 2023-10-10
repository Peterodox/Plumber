--Show a list of Dreamseed when appoaching Emarad Bounty Soil.
--Show checkmark if the Plant's achievement criteria is complete
--10 yd range: Plant Seed

--Mechanism Explained:
--  Fire "VIGNETTE_MINIMAP_UPDATED" when an Emerald Bounty (growing or not growing) enters/leaves the minimap
--  Fire "UPDATE_UI_WIDGET" after planting a seed (Can be triggered by seeds planted across the entire map)
--  Cast hidden spell "Dreamseed (425856)" when you get to 6 yd, where you get dismounted and your cursor becomes "Investigate"
--  Taking off on Dragon with "Skyward Ascent (372610)" doesn't trigger "PLAYER_STARTED_MOVING", so we need to watch "UNIT_SPELLCAST_SUCCEEDED"

local _, addon = ...
if not addon.IsGame_10_2_0 then
    return
end

local API = addon.API;


local MAPID_EMRALD_DREAM = 2200;
local VIGID_BOUNTY = 5971;
local RANGE_PLANT_SEED = 10;

local sqrt = math.sqrt;
local C_VignetteInfo = C_VignetteInfo;
local GetVignetteInfo = C_VignetteInfo.GetVignetteInfo;
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition;
local IsFlying = IsFlying;
local IsMounted = IsMounted;
local InCombatLockdown = InCombatLockdown;
local GetAchievementCriteriaInfoByID = GetAchievementCriteriaInfoByID;
local UIParent = UIParent;


local function GetVisibleEmeraldBountyGUID()
    local vignetteGUIDs = C_VignetteInfo.GetVignettes();
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


local function RealActionButton_OnLeave(self)
    if not InCombatLockdown() then
        self:SetScript("OnLeave", nil);
        self:Release();
    end

    if self.owner then
        self.owner:UnlockHighlight();
        self.owner:SetStateNormal();
        self.owner.hasActionButton = nil;
        self.owner = nil;
        EL:SetHeaderText();
        EL:StartShowingDefaultHeaderCountdown(true);
    end
end

local function RealActionButton_PostClick(self, button)
    if self.owner then
        if self.owner:HasCharges() then
            self.owner:ShowPostClickEffect();
        end
    end
end

local function RealActionButton_OnMouseDown(self, button)
    if self.owner then
        if self.owner:HasCharges() then
            self.owner:SetStatePushed();
        end
    end
end

local function RealActionButton_OnMouseUp(self)
    if self.owner then
        self.owner:SetStateNormal();
    end
end

local function ItemButton_OnEnter(self)
    EL:SetHeaderText(API.GetColorizedItemName(self.id));
    EL:StartShowingDefaultHeaderCountdown(false);

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
        RealActionButton:SetAttribute("type", "macro");     --Any Mouseclick
        RealActionButton:SetAttribute("macrotext", macroText);
        RealActionButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");

        self:LockHighlight();
        self.hasActionButton = true;
    end
end

local function ItemButton_OnLeave(self)
    if not (self:IsVisible() and self:IsMouseOver()) then
        EL:SetHeaderText();
        EL:StartShowingDefaultHeaderCountdown(true);
    end
end

function EL:Init()
    local SEED_ITEM_IDS = {208066, 208067, 208047};     --Small, Plump, GiganticDreamseed
    local SEED_SPELL_IDS = {417642, 417645, 417508};
    local START_FROM_RAREST = true;

    if START_FROM_RAREST then
        SEED_ITEM_IDS = API.ReverseList(SEED_ITEM_IDS);
        SEED_SPELL_IDS = API.ReverseList(SEED_SPELL_IDS);
    end

    self.Container = CreateFrame("Frame", nil, self);
    self.Container:SetSize(46, 46);
    self.Container:SetAlpha(0);

    local buttonSize = 46;
    local gap = 4;

    local numButtons = #SEED_ITEM_IDS;
    local span = (buttonSize + gap)*numButtons - gap;
    self.Container:SetWidth(span);

    local Header = self.Container:CreateFontString(nil, "OVERLAY", "GameTooltipText");
    self.Header = Header;
    Header:SetJustifyH("CENTER");
    Header:SetJustifyV("MIDDLE");
    Header:SetPoint("BOTTOM", self.Container, "TOP", 0, 8);
    Header:SetSpacing(2);

    local font, height = GameTooltipText:GetFont();
    Header:SetFont(font, height, "");   --OUTLINE
    Header:SetShadowColor(0, 0, 0);
    Header:SetShadowOffset(1, -1);

    local HeaderShadow = self.Container:CreateTexture(nil, "ARTWORK");
    HeaderShadow:SetPoint("TOPLEFT", Header, "TOPLEFT", -8, 6);
    HeaderShadow:SetPoint("BOTTOMRIGHT", Header, "BOTTOMRIGHT", 8, -8);
    HeaderShadow:SetTexture("Interface/AddOns/Plumber/Art/Button/GenericTextDropShadow");
    HeaderShadow:Hide();
    HeaderShadow:SetAlpha(0);

    function EL:SetHeaderText(text, transparentText)
        if text then
            Header:SetSize(0, 0);
            Header:SetText(text);
            if transparentText then
                local toAlpha = 0.6;
                API.UIFrameFade(Header, 0.5, toAlpha);
                API.UIFrameFade(HeaderShadow, 0.25, 0);
            else
                API.UIFrameFadeIn(Header, 0.25);
                API.UIFrameFade(HeaderShadow, 0.25, 1);
            end

            local textWidth = Header:GetWrappedWidth() - 2;
            if textWidth > EL.headerMaxWidth then
                Header:SetSize(EL.headerMaxWidth, 64);
                local numLines = Header:GetNumLines();
                Header:SetHeight(numLines*18);
                textWidth = Header:GetWrappedWidth();
                Header:SetWidth(textWidth + 2);
            end
        else
            API.UIFrameFade(Header, 0.5, 0);
            API.UIFrameFade(HeaderShadow, 0.25, 0);
        end
    end

    self.Buttons = {};
    self.SpellXButton = {};

    for i, itemID in ipairs(SEED_ITEM_IDS) do
        local button = addon.CreatePeudoActionButton(self.Container);
        self.Buttons[i] = button;
        self.SpellXButton[ SEED_SPELL_IDS[i] ] = button;
        button:SetPoint("LEFT", self.Container, "LEFT", (i - 1) * (buttonSize +  gap), 0);
        button:SetItem(itemID, button);
        button.spellID = SEED_SPELL_IDS[i];
        button:SetScript("OnEnter", ItemButton_OnEnter);
        button:SetScript("OnLeave", ItemButton_OnLeave);
    end

    self.SpellCastOverlay = addon.CreateActionButtonSpellCastOverlay(self.Container);
    self.SpellCastOverlay:Hide();

    --self:SetFrameLayout(2);

    self.Init = nil;
end


local function ContainerFrame_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 1 then
        self:SetScript("OnUpdate", nil);
        EL:SetHeaderText(EL.defaultHeaderText, true);
    end
end

function EL:StartShowingDefaultHeaderCountdown(state)
    if state then
        self.Container.t = 0;
        self.Container:SetScript("OnUpdate", ContainerFrame_OnUpdate);
    else
        self.Container:SetScript("OnUpdate", nil);
    end
end


local function GetCastBar()
    return _G["PlayerCastingBarFrame"]
end

function EL:SetFrameLayout(layoutIndex)
    local buttonSize = 46;

    if layoutIndex == 1 then
        --Normal, below the center
        --CastingBar's position is changed conditionally
        local buttonGap = 4;

        local anchorTo = GetCastBar();
        local y = anchorTo:GetTop();
        local scale = anchorTo:GetScale();

        self.Container:ClearAllPoints();
        self.Container:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 250); --(y + 30)*scale   --Default CastingBar moves up 29y when start casting

        for i, button in ipairs(self.Buttons) do
            button:ClearAllPoints();
            button:SetPoint("LEFT", self.Container, "LEFT", (i - 1) * (buttonSize +  buttonGap), 0);
        end

        self.Header:ClearAllPoints();
        self.Header:SetPoint("BOTTOM", self.Container, "TOP", 0, 8);
        self.headerMaxWidth = 0;
    else
        --Circular, on the right side
        local radius = math.floor( (0.5 * UIParent:GetHeight()*16/9 /3) + (buttonSize*0.5) + 0.5);
        local gapArc = 8 + buttonSize;
        local radianGap = gapArc/radius;

        local radian;
        local x, y;
        local cx, cy = UIParent:GetCenter();

        for i, button in ipairs(self.Buttons) do
            button:ClearAllPoints();
            radian = (1 - i)*radianGap;
            x = cx + radius * math.cos(radian);
            y = cy + radius * math.sin(radian);
            button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
        end

        local headerRadiusOffset = 112;  --Positive value moves towards center
        local headerMaxWidth = 2*(headerRadiusOffset - buttonSize*0.5) - 8;
        radian = -(#self.Buttons - 1)*radianGap*0.5;
        x = cx + (radius - headerRadiusOffset) * math.cos(radian);
        y = cy + (radius - headerRadiusOffset) * math.sin(radian);

        self.headerMaxWidth = headerMaxWidth;
        self.Header:ClearAllPoints();
        self.Header:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
    end
end

function EL:SetInteractable(state, dueToCombat)
    if state then
        API.UIFrameFade(self.Container, 0.5, 1);
    else
        if dueToCombat then
            if self.Container:IsShown() then
                local toAlpha = 0.25;
                API.UIFrameFade(self.Container, 0.2, toAlpha);
            end
        else

        end
    end

    for i, button in ipairs(self.Buttons) do
        button:SetEnabled(state);
        button:EnableMouse(state);
        button:UnlockHighlight();
    end
end

function EL:UpdateItemCount()
    for i, button in ipairs(self.Buttons) do
        button:UpdateCount();
    end
end

function EL:OnSpellCastChanged(spellID, isStartCasting)
    local targetButton = self.SpellXButton[spellID];

    if self.lastTargetButton then
        self.lastTargetButton.Count:Show();
    end
    self.lastTargetButton = targetButton;

    if targetButton then
        if isStartCasting then
            self.isPlayerMoving = false;
            self.isChanneling = true;
            for i, button in ipairs(self.Buttons) do
                if button.spellID == spellID then
                    local _, _, _, startTime, endTime = UnitChannelInfo("player");

                    self.SpellCastOverlay:ClearAllPoints();
                    self.SpellCastOverlay:SetPoint("CENTER", button, "CENTER", 0, 0);
                    self.SpellCastOverlay:FadeIn();
                    self.SpellCastOverlay:SetDuration( (endTime - startTime) / 1000);
                    self.SpellCastOverlay:SetFrameStrata("HIGH");

                    button.Count:Hide();
                end
            end
        else
            self.isChanneling = false;
            self.SpellCastOverlay:FadeOut();
        end
    end
end

function EL:IsTrackedPlantGrowing()
    return self.trackedObjectGUID and DataProvider:IsPlantGrowing(self.trackedObjectGUID);
end

function EL:AttemptShowUI()
    if self:IsTrackedPlantGrowing() then
        return
    end

    if self.Init then
        self:Init();
    end

    self:RegisterEvent("BAG_UPDATE");
    self:RegisterEvent("PLAYER_REGEN_DISABLED");
    self:RegisterEvent("PLAYER_REGEN_ENABLED");
    self:RegisterEvent("UI_SCALE_CHANGED");
    self:RegisterEvent("UPDATE_UI_WIDGET");

    self:SetFrameLayout(2);

    self.isChanneling = nil;
    self.Container:Show();

    if InCombatLockdown() then
        self:SetInteractable(false, true);
    else
        self:SetInteractable(true);
    end

    if self.trackedObjectGUID then
        local plantName, criteriaComplete = DataProvider:GetPlantNameAndProgress(self.trackedObjectGUID);
        if plantName then
            --plantName = "|cff808080"..plantName.."|r";  --DISABLED_FONT_COLOR
            if criteriaComplete then
                plantName = "|TInterface/AddOns/Plumber/Art/Button/Checkmark-Green-Shadow:16:16:-4:-2|t"..plantName;  --"|A:common-icon-checkmark:0:0:-4:-2|a" |TInterface/AddOns/Plumber/Art/Button/Checkmark-Green:0:0:-4:-2|t
            end
            self:SetHeaderText(plantName, true);
            self.defaultHeaderText = plantName;
        end
    else
        self.defaultHeaderText = nil;
    end

    return true
end

function EL:CloseUI()
    if self.Container and self.Container:IsShown() then
        --self.Container:Hide();
        --self.Container:ClearAllPoints();
        --self.Container:SetPoint("TOP", UIParent, "BOTTOM", 0, -64);
        API.UIFrameFade(self.Container, 0.5, 0);
        self:UnregisterEvent("BAG_UPDATE");
        self:UnregisterEvent("PLAYER_REGEN_DISABLED");
        self:UnregisterEvent("PLAYER_REGEN_ENABLED");
        self:UnregisterEvent("UI_SCALE_CHANGED");
        self:UnregisterEvent("UPDATE_UI_WIDGET");
        self:SetInteractable(false);
        self.isChanneling = nil;
        self.defaultHeaderText = nil;
        self.SpellCastOverlay:Hide();
    end
end

function EL:GetMapPointsDistance(x1, y1, x2, y2)
    local x = self.mapWidth * (x1 - x2);
    local y = self.mapHeight * (y1 - y2);

    return sqrt(x*x + y*y)
end

--EL:RegisterEvent("UPDATE_UI_WIDGET");
EL.widgetData = {};

function EL:AddWidgetInfo(widgetInfo)
    local widgetID = widgetInfo.widgetID;
    if not self.widgetData[widgetID] then
        self.widgetData[widgetID] = widgetInfo.widgetType;
        return true
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
    elseif event == "UPDATE_UI_WIDGET" then
        local widgetInfo = ...
        if DataProvider:IsValuableWidget(widgetInfo.widgetID) then
            if self:IsTrackedPlantGrowing() then
                self:CloseUI();
            end
        end
        --[[
        local isNew = self:AddWidgetInfo(widgetInfo);
        if isNew then
            print("ID:", widgetInfo.widgetID, "  Type:", widgetInfo.widgetType)     --https://wowpedia.fandom.com/wiki/UPDATE_UI_WIDGET
        end
        --]]
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        local _, _, spellID = ...
        self:OnSpellCastChanged(spellID, true);
    elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then

    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local _, _, spellID = ...
        self:OnSpellCastChanged(spellID, false);
    elseif event == "BAG_UPDATE" then
        self:UpdateItemCount();
    elseif event == "PLAYER_REGEN_DISABLED" then
        self:SetInteractable(false, true);
    elseif event == "PLAYER_REGEN_ENABLED" then
        self:SetInteractable(true);
    elseif event == "UI_SCALE_CHANGED" then
        self:SetFrameLayout(2);
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

function EL:CalculatePlayerToTargetDistance()
    local position = GetPlayerMapPosition(MAPID_EMRALD_DREAM, "player");
    if position then
        local d = self:GetMapPointsDistance(position.x, position.y, self.targetX, self.targetY);
        --print(string.format("Distance: %.1f yd", d));

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

    if success then
        self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
        self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
        self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "player");
    end
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
    };

    addon.ControlCenter:AddModule(moduleData);
end

--/script local map = C_Map.GetBestMapForUnit("player");local position = C_Map.GetPlayerMapPosition(map, "player");print(position:GetXY())


local PLANT_DATA = {
    --17 types of Plant + 1 Tutorial
    --Kudos to @patf0rd on Twitter!

    --from VigInfo.ObjectGUID
    --[creatureID] = {criteriaID, widgetID}
    --/dump C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(5136) (bag max 180(3 min))
    --AchievementID = 19013;    --I Dream of Seeds

    [208443] = {62028, 5084}, --"Ysera's Clover"
    [208511] = {62029, 5122}, --"Chiming Foxglove"    --Oct. 10  Bugged. The map thinks another plant to the north-east is the closest
    [208556] = {62030, 5123}, --"Dragon's Daffodil"
    [208563] = {62031, 5125}, --"Singing Weedling"
    [208605] = {62032, 5126}, --"Fuzzy Licorice"
    [208606] = {62039, 5127}, --"Lofty Lupin"
    [208607] = {62038, 5128}, --"Ringing Rose"
    [208615] = {62037, 5129}, --"Dreamer's Daisy"
    [208616] = {62035, 5130}, --"Viridescent Sprout"
    [208617] = {62041, 5124}, --"Belligerent Begonias"
    [209583] = {62027, 5131}, --"Lavatouched Lilies"
    [209599] = {62040, 5132}, --"Lullaby Lavender"
    [209880] = {62036, 5133}, --"Glade Goldenrod"
    [210723] = {62185, 5134}, --"Comfy Chamomile"
    [210724] = {62186, 5135}, --"Moon Tulip"
    [210725] = {62189, 5136}, --"Flourishing Scurfpea"
    [211059] = {62397, 5149}, --"Whisperbloom Sapling" ! (not spawning)

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

function DataProvider:GetGrowthTimes(objectGUID)
    local creatureID = API.GetCreatureIDFromGUID(objectGUID);
    if creatureID and PLANT_DATA[creatureID] then
        local widgetID = PLANT_DATA[creatureID][2];
        local info = widgetID and C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widgetID);
        if info then
            return info.barValue, info.barMax
        end
    end
end

function DataProvider:IsPlantGrowing(objectGUID)
    local remainingTime = self:GetGrowthTimes(objectGUID);
    return remainingTime and remainingTime > 0
end

function DataProvider:GetPlantNameAndProgress(objectGUID)
    local id = API.GetCreatureIDFromGUID(objectGUID);
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

API.GetActiveDreamseedGrowthTimes = DataProvider.GetActiveDreamseedGrowthTimes;

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

    function TextStatusBar()
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
end
--]]