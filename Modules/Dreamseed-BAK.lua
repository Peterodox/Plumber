--Show a list of Dreamseed when approaching Emerald Bounty Soil.
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
local GetPlayerMapCoord = API.GetPlayerMapCoord;
local GetCreatureIDFromGUID = API.GetCreatureIDFromGUID;
local AreWaypointsClose = API.AreWaypointsClose;

local MAPID_EMRALD_DREAM = 2200;
local VIGID_BOUNTY = 5971;
local RANGE_PLANT_SEED = 10;
local FORMAT_ITEM_COUNT_ICON = "%s|T%s:0:0:0:0:64:64:0:64:0:64|t";
local SEED_ITEM_IDS = {208047, 208067, 208066};     --Gigantic, Plump, Small Dreamseed
local SEED_SPELL_IDS = {417508, 417645, 417642};

local math = math;
local sqrt = math.sqrt;
local format = string.format;
local C_VignetteInfo = C_VignetteInfo;
local GetVignetteInfo = C_VignetteInfo.GetVignetteInfo;
local GetStatusBarWidgetVisualizationInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo;
local GetItemDisplayVisualizationInfo = C_UIWidgetManager.GetItemDisplayVisualizationInfo;
local GetAllWidgetsBySetID = C_UIWidgetManager.GetAllWidgetsBySetID;
local IsFlying = IsFlying;
local IsMounted = IsMounted;
local InCombatLockdown = InCombatLockdown;
local GetAchievementCriteriaInfoByID = GetAchievementCriteriaInfoByID;
local UIParent = UIParent;
local GetItemCount = GetItemCount;
local GetItemIconByID = C_Item.GetItemIconByID;
local time = time;
local CreateFrame = CreateFrame;
local GetCursorPosition = GetCursorPosition;


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
        if button == "LeftButton" and self.owner:HasCharges() then
            self.owner:ShowPostClickEffect();
            return
        end
    end

    if button == "RightButton" then
        EL:EnableEditMode(true);
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

    local privateKey = "QuickSlot";
    local RealActionButton = addon.AcquireSecureActionButton(privateKey);

    if RealActionButton then
        local w, h = self:GetSize();
        RealActionButton:SetFrameStrata("DIALOG");
        RealActionButton:SetFixedFrameStrata(true);
        RealActionButton:SetScript("OnEnter", nil);
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

        local macroText = format("/use item:%s", self.id);
        RealActionButton:SetAttribute("type1", "macro");     --Any Mouseclick
        RealActionButton:SetMacroText(macroText);
        RealActionButton:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp");

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
    self.side = 1;

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
        button:SetItem(itemID);
        button.spellID = SEED_SPELL_IDS[i];
        button:SetScript("OnEnter", ItemButton_OnEnter);
        button:SetScript("OnLeave", ItemButton_OnLeave);
    end

    self.SpellCastOverlay = addon.CreateActionButtonSpellCastOverlay(self.Container);
    self.SpellCastOverlay:Hide();

    --self:SetFrameLayout(2);

    self.Init = nil;
end

function EL:SetButtonOrder(side)
    if side ~= self.side then
        self.side = side;
    else
        return
    end

    local items = SEED_ITEM_IDS;
    local spells = SEED_SPELL_IDS;

    if side > 0 then
        --right side of the screen
        items = SEED_ITEM_IDS;
        spells = SEED_SPELL_IDS;
    else
        --left side
        items = API.ReverseList(items);
        spells = API.ReverseList(spells);
    end

    for i, button in ipairs(self.Buttons) do
        button:SetItem(items[i]);
        button.spellID = spells[i];
        self.SpellXButton[ spells[i] ] = button;
    end
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


local Positioner = CreateFrame("Frame", nil, UIParent);
Positioner.alpha = 0;
Positioner:Hide();
Positioner:SetFrameStrata("BACKGROUND");
Positioner.buttonSize = 46;     --Constant
Positioner.buttonGap = 8;       --Constant
Positioner.fromRadian = 0;      --User customizable

function Positioner:GetButtonGap()
    --the gap between to round buttons
    return 8
end

function Positioner:GetRadius()
    return math.floor( (0.5 * UIParent:GetHeight()*16/9 /3) + (self.buttonSize*0.5) + 0.5 );
end

function Positioner:GetButtonCenterGap()
    local radius = self:GetRadius();
    local gapArc = self.buttonGap + self.buttonSize;
    local radianGap = gapArc/radius;
    return radianGap
end

function Positioner:GetFromRadian()
    return self.fromRadian
end

function Positioner:SetFromRadian(radian)
    local snappedRadian = math.rad(45);

    if radian > snappedRadian then
        radian = snappedRadian;
    else
        snappedRadian = math.rad(-60) + self:GetButtonRadianByIndex(-1);
        if radian < snappedRadian then
            radian = snappedRadian;
        end
    end
    --[[
    local temp = radian;
    if radian < 0 then
        temp = -temp;
    end
    --]]
    for i = 0, 1 do
        snappedRadian = self:GetButtonRadianByIndex(i);
        if radian < snappedRadian + 0.043 and radian > snappedRadian - 0.043 then
            radian = snappedRadian;
        end
    end

    self.fromRadian = radian;
end

function Positioner:GetEditButtonRadian()
    local radius = self:GetRadius();
    return self.fromRadian + (self.buttonSize)/radius;
end

function Positioner:GetButtonRadianByIndex(index)
    local radius = self:GetRadius();
    local gapArc = self.buttonGap + self.buttonSize;
    local radianGap = gapArc/radius;

    return (1 - index)*radianGap;
end

function Positioner:GetRadianPerButton()
    local radius = self:GetRadius();
    local radianPerButton = self.buttonSize/radius;
    return radianPerButton
end

function Positioner:GetCastBar()
    return _G["PlayerCastingBarFrame"]
end

function Positioner:OnUpdate_FadeIn(elapsed)
    self.alpha = self.alpha + elapsed*5;
    if self.alpha >= 1 then
        self.alpha = 1;
        self:SetScript("OnUpdate", nil);
    end
    self:SetAlpha(self.alpha);
end

function Positioner:FadeInGuideLine()
    self:SetScript("OnUpdate", self.OnUpdate_FadeIn);
    self.t = nil;
    self:Show();
end

function Positioner:OnUpdate_FadeOut(elapsed)
    if self.t < 0.5 then
        self.t = self.t + elapsed;
        return
    end

    self.alpha = self.alpha - elapsed*2;
    if self.alpha <= 0 then
        self.alpha = 0;
        self.t = nil;
        self:Hide();
        self:SetScript("OnUpdate", nil);
    end
    self:SetAlpha(self.alpha);
end

function Positioner:FadeOutGuideLine()
    if not self.t then
        if self.alpha >= 0.8 then
            self.t = 0;
        else
            self.t = 1; --no delay
        end
    end
    self:SetScript("OnUpdate", self.OnUpdate_FadeOut);
end

function Positioner:ShowGuideLineCircle(state)
    self.showingGuideLine = state;
    if state then
        if not self.GuideLineCircle then
            self.GuideLineCircle = addon.CreateArc(self);
            self.GuideLineCircle:SetThickness(2);
            self.GuideLineCircle:SetPoint("CENTER", UIParent, "CENTER", 0, 0);

            local buttonRadian = self:GetRadianPerButton();
            local toRdian = math.rad(-45.5) + buttonRadian*0.5;
            local fromRadian = math.rad(30.5) - buttonRadian*0.5;
            self.GuideLineCircle:SetToRadian(toRdian);
            self.GuideLineCircle:SetFromRadian(fromRadian);
            self.GuideLineCircle:SetAlpha(0.5);

            --[[
            local snappedRadian = math.rad(45);

            if radian > snappedRadian then
                radian = snappedRadian;
            else
                snappedRadian = math.rad(-60) + self:GetButtonRadianByIndex(-1);
                if radian < snappedRadian then
                    radian = snappedRadian;
                end
            end
            --]]
        end

        local radius = self:GetRadius();
        self.GuideLineCircle:SetRadius(radius);

        --self:Show();
        self:FadeInGuideLine();
    else
        --self:Hide();
        self:FadeOutGuideLine();
    end
end

function Positioner:SetCircleMaskPosition(x, y)
    if self.CircleMask2 then
        self.CircleMask2:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
    end
end

function Positioner:HideGuideLine()
    self.showingGuideLine = false;
    self:Hide();
    self:SetScript("OnUpdate", nil);
end


function EL:SetFrameLayout(layoutIndex)
    local buttonSize = Positioner.buttonSize;
    local buttonGap = Positioner.buttonGap;

    if layoutIndex == 1 then
        --Normal, below the center
        --CastingBar's position is changed conditionally

        local anchorTo = Positioner:GetCastBar();
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
        local gapArc = buttonGap + buttonSize;
        local fromRadian = Positioner:GetFromRadian();
        local radianGap = gapArc/radius;
        local numButtons = #self.Buttons;
        local radian;
        local x, y;
        local cx, cy = UIParent:GetCenter();

        for i, button in ipairs(self.Buttons) do
            button:ClearAllPoints();
            radian = fromRadian + (1 - i)*radianGap;
            x = cx + radius * math.cos(radian);
            y = cy + radius * math.sin(radian);
            button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
            if i == 2 then
                Positioner:SetCircleMaskPosition(x, y);
            end
        end

        local headerRadiusOffset = 112;  --Positive value moves towards center
        local headerMaxWidth = 2*(headerRadiusOffset - buttonSize*0.5) - 8;
        radian = fromRadian -(numButtons - 1)*radianGap*0.5;
        x = cx + (radius - headerRadiusOffset) * math.cos(radian);
        y = cy + (radius - headerRadiusOffset) * math.sin(radian);

        self.headerMaxWidth = headerMaxWidth;
        self.Header:ClearAllPoints();
        self.Header:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);

        if self.RepositionButton then
            --Adjust Radian:
            radian = Positioner:GetEditButtonRadian();
            self.RepositionButton:ClearAllPoints();
            self.RepositionButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx + radius * math.cos(radian), cy + radius * math.sin(radian));
            --self.RepositionButton:SetRotation(radian);

            --Adjust Radius:
            --[[
            radian = fromRadian;
            radius = radius + buttonSize;
            self.RepositionButton:ClearAllPoints();
            self.RepositionButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx + radius * math.cos(radian), cy + radius * math.sin(radian));
            self.RepositionButton:SetRotation(radian);
            --]]
        end
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
    self:UpdateItemCount();

    for _, button in ipairs(self.Buttons) do
        button.Count:Show();
    end

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
    self:EnableEditMode(false);
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
    elseif event == "UPDATE_UI_WIDGET" then
        local widgetInfo = ...
        if DataProvider:IsValuableWidget(widgetInfo.widgetID) then
            if self:IsTrackedPlantGrowing() then
                self:StopTrackingPosition();
                --self:CloseUI();
            end
        end

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
        if not self.isEditing then
            self:SetInteractable(true);
        end
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

local function GetCursorRadianToPoint(cx, cy, uiRatio)
    local x, y = GetCursorPosition();
    x = x *uiRatio;
    y = y * uiRatio;
    return math.atan2(y - cy, x - cx);
end

local function RepositionButton_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0.016 then
        self.t = 0;
        local radian = GetCursorRadianToPoint(self.cx, self.cy, self.uiRatio);
        if radian ~= self.radian then
            self.radian = radian;
            Positioner:SetFromRadian(self.frameRadian + radian - self.selfRadian);
            EL:SetFrameLayout(2);
            --[[
            if radian > -1.57 and radian < 1.57 then
                EL:SetButtonOrder(1);
            else
                EL:SetButtonOrder(-1);
            end
            --]]
        end
    end
end

local function RepositionButton_OnMouseDown(self, button)
    if button == "RightButton" then
        Positioner:SetFromRadian(0);
        EL:SetFrameLayout(2);
        return
    end
    self.t = 0;
    self.cx, self.cy = UIParent:GetCenter();
    self.uiRatio = 1/ UIParent:GetEffectiveScale();
    self.radian = GetCursorRadianToPoint(self.cx, self.cy, self.uiRatio);
    self.selfRadian = Positioner:GetEditButtonRadian();
    self.frameRadian = Positioner:GetFromRadian();
    self:SetScript("OnUpdate", RepositionButton_OnUpdate);
    EL:SetInteractable(false);
    self:LockHighlight();

    Positioner:ShowGuideLineCircle(true);
end

local function RepositionButton_OnMouseUp(self)
    self.t = nil;
    self.cx, self.cy = nil, nil;
    self:SetScript("OnUpdate", nil);
    self:UnlockHighlight();

    Positioner:ShowGuideLineCircle(false);
end

local function RepositionButton_OnClick(self)
    local delta = -1;   --clock-wise
    local oldRadian = Positioner:GetFromRadian();
    local dRadian = Positioner:GetButtonCenterGap();
    local newRadian = oldRadian + delta*dRadian;
    Positioner:SetFromRadian(newRadian);

    EL:SetFrameLayout(2);
end

local function RepositionButton_SetRotation(self, radian)
    self.Icon:SetRotation(radian);
    self.Highlight:SetRotation(radian);
end

function EL:EnableEditMode(state)
    if state then
        if not self.RepositionButton then
            local b = CreateFrame("Button", nil, self.Container);
            b:SetSize(16, 16);
            self.RepositionButton = b;
            b:SetFrameStrata("DIALOG");
            b:SetFixedFrameStrata(true);

            local tex = "Interface/AddOns/Plumber/Art/Button/RepositionButton-Circle";

            b.Icon = b:CreateTexture(nil, "ARTWORK");
            b.Icon:SetSize(16, 16);
            b.Icon:SetPoint("CENTER", b, "CENTER", 0, 0);
            b.Icon:SetTexture(tex, nil, nil, "TRILINEAR");

            b.Highlight = b:CreateTexture(nil, "HIGHLIGHT");
            b.Highlight:SetSize(32, 32);
            b.Highlight:SetPoint("CENTER", b, "CENTER", 0, 0);
            b.Highlight:SetTexture(tex.."-Highlight", nil, nil, "TRILINEAR");
            --b.Highlight:SetBlendMode("ADD");
            --b.Highlight:SetVertexColor(0.4, 0.4, 0.4);

            b.SetRotation = RepositionButton_SetRotation;
            --b:SetScript("OnClick", RepositionButton_OnClick);
            b:SetScript("OnMouseDown", RepositionButton_OnMouseDown);
            b:SetScript("OnMouseUp", RepositionButton_OnMouseUp);
        end

        if not self.isEditing then
            self.isEditing = true;
            self.RepositionButton:Show();
            self:SetFrameLayout(2);
            self:SetInteractable(false);
            self:SetHeaderText();   --HUD_EDIT_MODE_MENU
            for i, button in ipairs(self.Buttons) do
                button.Count:Hide();
            end
        end
    else
        if self.isEditing then
            self.isEditing = nil;
            self.RepositionButton:Hide();
            self.RepositionButton:SetScript("OnUpdate", nil);
            Positioner:HideGuideLine();
            for i, button in ipairs(self.Buttons) do
                button.Count:Show();
            end
            if not InCombatLockdown() then
                self:SetInteractable(true);
            end
        else
            return
        end
    end
end

EL:SetScript("OnHide", function()
    EL:EnableEditMode(false);
end);


local ZoneTriggerModule;

local function EnableModule(state)
    if state then
        if not ZoneTriggerModule then

            --Debug
            C_Timer.After(1, function()
                EL:OnApproachingSoil();
                --EL:EnableEditMode(true);
            end)

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
    --Three widgetSet for each plant, mapped to 3 different rarities
    --All three Emerald Bloom rewards of each widgetSet will be flagged simultaneously
    --All three status bar of each widgetSet also change in sync
    --Save the objectGUID and position if it has unclaimed reward
    --Returns: hasAnyReward, isRewardLocationCached
    if creatureID and PLANT_DATA[creatureID] then
        if self:IsDreamseedChestAvailableByCreatureID(creatureID) then
            return true, true
        end
        local info, widgetSetID, setWidgets;
        for i = 15, 17 do
            widgetSetID = PLANT_DATA[creatureID][i];
            setWidgets = GetAllWidgetsBySetID(widgetSetID);
            if setWidgets then
                for _, widgetInfo in ipairs(setWidgets) do
                    if widgetInfo.widgetType == 27 then
                        info = GetItemDisplayVisualizationInfo(widgetInfo.widgetID);
                        if info and info.shownState == 1 and info.itemInfo and info.itemInfo.showAsEarned then
                            return true, false
                        end
                    end
                end
            end
        end
    end
    return false, false
end
--]]

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

function DataProvider:IsDreamseedChestAvailableByCreatureID(creatureID)
    if not self.dreamseedChestStates then
        return false
    end

    return self.dreamseedChestStates[creatureID] ~= nil
end

function DataProvider:IsDreamseedChestAvailable(objectGUID)
    local creatureID = GetCreatureIDFromGUID(objectGUID);
    return self:IsDreamseedChestAvailableByCreatureID(creatureID)
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
    local uiMapID = C_Map.GetBestMapForUnit("player");
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