-- PlayerChoiceFrame Revamp
-- Smaller UI, show item count, long-click to auto-donate

local _, addon = ...

if not addon.IsGame_10_2_0 then
    return
end

local MAPID_EMRALD_DREAM = 2200;
local OPTION_FRAME_WIDTH = 196;
local OPTION_FRAME_GAP = 48;
local UI_OFFSET_X = 0;      --Set by user via RepositionButton
local UI_OFFSET_Y = 0;      --Controlled by Camera Zoom
local PATTERN_RESOURCE_DISPLAY = "%s |T%s:16:16:0:0:64:64:4:60:4:60|t";

local API = addon.API;
local L = addon.L;
local GetCreatureIDFromGUID = API.GetCreatureIDFromGUID;
local DreamseedUtil = API.DreamseedUtil;
local GetWaypointFromText = API.GetWaypointFromText;
local AreWaypointsClose = API.AreWaypointsClose;
local easingFunc = addon.EasingFunctions.outQuart;
local C_PlayerChoice = C_PlayerChoice;
local C_UIWidgetManager = C_UIWidgetManager;
local C_Item = C_Item;
local GetItemCount = GetItemCount;
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
local match = string.match;
local find = string.find;
local lower = string.lower;
local format = string.format;
local tonumber = tonumber;
local floor = math.floor;

local UIParent = UIParent;

local VALID_CREATURES = {};

do
    local DreamseedBloom = {
        211142, 211143, 211120, 208463, 208633,
        208635, 211091, 211126, 211130, 211219,
        211091, 211221,
    };

    for _, creatureID in ipairs(DreamseedBloom) do
        VALID_CREATURES[creatureID] = 2650;   --Emerald Dewdrop
    end
end


local function HideBlizzardFrame_Default()
    local f = PlayerChoiceFrame;
    if f then
        f:ClearAllPoints();
        f:SetClampedToScreen(false);
        f:SetPoint("TOP", UIParent, "BOTTOM", 0, -64);
    end
end

local function HideBlizzardFrame_MoveAny()
    --Fixed an compatibility issue where after "MoveAny" users adjust the PlayerChoiceFrame
    --the frame will be clamped to screen and constantly restore its previous position
    --Mechanism: MoveAny hooks frame's SetPoint method
    --see MoveAny\moveframes.lua

    local f = PlayerChoiceFrame;
    if f then
        f:ClearAllPoints();
        f:SetClampedToScreen(false);
        f.maframesetpoint = true;
        f:SetPoint("TOP", UIParent, "BOTTOM", 0, -64);
        f.maframesetpoint = false;
    end
end

local function HideBlizzardFrame_Drift()
    --Similar to MoveAny, they hook the SetPoint method
    --see Drift\DriftHelpers.lua

    local f = PlayerChoiceFrame;
    if f then
        f:ClearAllPoints();
        f:SetClampedToScreen(false);
        f.DriftAboutToSetPoint = true;
        f:SetPoint("TOP", UIParent, "BOTTOM", 0, -64);
        f.DriftAboutToSetPoint = false;
    end
end

local HideBlizzardFrame = HideBlizzardFrame_Default;

local function OnUpdate_OnShot(self)
    self:SetScript("OnUpdate", nil);
    HideBlizzardFrame();
end

local BlizzardFrameMover = CreateFrame("Frame");    --Attempted Fix for Report #10: "both the addon's UI and the default one are there"
function BlizzardFrameMover:HidePlayerChoiceFrame()
    HideBlizzardFrame();
    self:SetScript("OnUpdate", OnUpdate_OnShot);
end


local PlayerChoiceUI = CreateFrame("Frame", nil, UIParent);
PlayerChoiceUI:SetSize(64, 64);
PlayerChoiceUI:SetPoint("CENTER", UIParent, "CENTER", UI_OFFSET_X, UI_OFFSET_Y);
PlayerChoiceUI:Hide();
PlayerChoiceUI:SetFrameStrata("DIALOG");
PlayerChoiceUI:SetFixedFrameStrata(true);
PlayerChoiceUI:SetFrameLevel(50);
PlayerChoiceUI:SetClampedToScreen(true);
PlayerChoiceUI.LongClickWatcher = CreateFrame("Frame", nil, PlayerChoiceUI);


local function CalculateOffsetYFromZoom(zoom)
    --Move the UI downwards when zooming out, so it doesn't block the timer (nameplate)
    zoom = zoom or 0;

    local y = 0.094*zoom*zoom - 8.495*zoom + 140.73;
    if y > 0 then
        y = 0;
    elseif y < -50 then
        y = -50;
    end
    return floor(y + 0.5);
end

local ZoomCalculator = CreateFrame("Frame", nil, PlayerChoiceUI);
local FrameMover = CreateFrame("Frame", nil, PlayerChoiceUI);


local OptionFrameMixin = {};

function OptionFrameMixin:SetupItem(itemID, showAsEarned)
    if itemID then
        self.RewardFrame:Show();

        if showAsEarned then
            self.RewardFrame.Checkmark:Show();
            if PlayerChoiceUI.requireRewardCheck then
                PlayerChoiceUI.requireRewardCheck = false;
                DreamseedUtil:MarkNearestPlantContributed();
            end
        else
            self.RewardFrame.Checkmark:Hide();
        end

        if itemID ~= self.itemID then
            self.itemID = itemID;
        else
            return
        end

        local icon = C_Item.GetItemIconByID(itemID);
        local name = C_Item.GetItemNameByID(itemID);
        local quality = C_Item.GetItemQualityByID(itemID);

        self.itemCached = quality and name and name ~= "";

        if not (self.itemCached and self:IsShown()) then
            C_Timer.After(0.1, function()
                if not self.itemCached then
                    self.itemID = nil;
                    self:SetupItem(itemID, showAsEarned);
                end
            end);
            return
        end

        local color = API.GetItemQualityColor(quality);
        local r, g, b = color:GetRGB();
        self.RewardFrame.Icon:SetTexture(icon);
        self.RewardFrame.Name:SetText(name);
        self.RewardFrame.Name:SetTextColor(r, g, b);
    else
        self.RewardFrame:Hide();
    end
end


--Display the number of required resources that you own below the button
local function ResourceDisplay_OnEnter(resourceFrame)
    GameTooltip:Hide();
    if resourceFrame.itemID then
        GameTooltip:SetOwner(resourceFrame, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:SetItemByID(resourceFrame.itemID);
        GameTooltip:Show();
    elseif resourceFrame.currencyID then
        GameTooltip:SetOwner(resourceFrame, "ANCHOR_BOTTOMRIGHT");
        GameTooltip:SetCurrencyByID(resourceFrame.currencyID);
        GameTooltip:Show();
    end
end

local function ResourceDisplay_OnLeave()
    GameTooltip:Hide();
end

local function ResourceDisplay_SetResource(optionFrame, numRequired, numOwned, icon, itemID, currencyID)
    local f = optionFrame.ResourceDisplay;
    if not f then
        f = addon.CreateThreeSliceFrame(optionFrame, "Phantom");
        --f = CreateFrame("Frame", nil, optionFrame);
        optionFrame.ResourceDisplay = f;
        --f:SetSize(60, 20);
        f:SetHitRectInsets(8, 8, 2, 2);
        --f:SetPoint("BOTTOM", optionFrame, "BOTTOM", 0, 0);
        f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
        f.Text:SetTextColor(1, 1, 1);
        f.Text:SetJustifyH("CENTER");
        --f.Text:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.Text:SetPoint("BOTTOM", optionFrame, "BOTTOM", 0, 0);
        f:SetHeight(20);
        f:SetPoint("LEFT", f.Text, "LEFT", -4, 0);
        f:SetPoint("RIGHT", f.Text, "RIGHT", 4, 0);
        f:SetScript("OnEnter", ResourceDisplay_OnEnter);
        f:SetScript("OnLeave", ResourceDisplay_OnLeave);
        --addon.CreateTextDropShadow(f.Text, f);
    end

    if numOwned > 9999 then
        numOwned = "A Lot";
    else
        if numRequired > numOwned then
            numOwned = "|cffff4800"..numOwned.."|r";    --WARNING_FONT_COLOR
        end
    end

    local text = format(PATTERN_RESOURCE_DISPLAY, numOwned, icon);
    f:Show();
    f.Text:SetText(text);
    f.itemID = itemID;
    f.currencyID = currencyID;
end

local function ResourceDisplay_Hide(optionFrame)
    if optionFrame.ResourceFrame then
        optionFrame.ResourceFrame:Hide();
    end
end

local function ResourceDisplay_SetItem(optionFrame, itemID, numRequired)
    local quantity = GetItemCount(itemID) or 0;
    local icon = C_Item.GetItemIconByID(itemID);
    ResourceDisplay_SetResource(optionFrame, numRequired, quantity, icon, itemID);
end

local function ResourceDisplay_SetCurrency(optionFrame, currencyID, numRequired)
    --Blizzard's Dreamseed tutorial quest requirement is wrong, but it's trival
    local info = GetCurrencyInfo(currencyID);
    if info then
        local icon = info.iconFileID;
        local quantity = info.quantity;
        ResourceDisplay_SetResource(optionFrame, numRequired, quantity, icon, nil, currencyID);
    else
        ResourceDisplay_Hide(optionFrame);
    end
end

local function ProcessButtonText(text)
    --Get itemID from iconFile
    local numRequired, iconFile = match(text, "(%d+)%s*|T([^|]+)|t");
    local resourceType, resourceID;
    --print(text);
    --print(iconFile)
    if numRequired and iconFile then
        numRequired = tonumber(numRequired);
        iconFile = lower(iconFile);
        if find(iconFile, "shadowdew") then
            resourceType = 2;
            resourceID = 2650;
        elseif find(iconFile, "green") then
            resourceType = 1;
            resourceID = 208066;
        elseif find(iconFile, "blue") then
            resourceType = 1;
            resourceID = 208067;
        elseif find(iconFile, "purple") then
            resourceType = 1;
            resourceID = 208047;
        end
    end
    --print(resourceType, resourceID);
    return text, numRequired, resourceType, resourceID
end


function OptionFrameMixin:SetupButton(buttonInfo)
    if buttonInfo then
        local button = self.Button;
        if buttonInfo.disabled then
            button:SetButtonState(3);
        else
            if button.leftButtonDown then
                if button.stateIndex == 4 then
                    button:SetButtonState(4);
                else
                    button:SetButtonState(2);
                end
            else
                button:SetButtonState(1);
            end
        end
        button.canLongClick = false;
        button.id = buttonInfo.id;
        local text, numRequired, resourceType, resourceID = ProcessButtonText(buttonInfo.text);
        button:SetButtonText(text);
        if resourceType then
            if resourceType == 1 then
                ResourceDisplay_SetItem(self, resourceID, numRequired);
            elseif resourceType == 2 then
                ResourceDisplay_SetCurrency(self, resourceID, numRequired);
                if resourceID == 2650 then
                    button.canLongClick = true;
                    PlayerChoiceUI.repeatButtonID = buttonInfo.id;
                end
            end
        else
            ResourceDisplay_Hide(self);
        end
    else
        self.Button:Hide();
        ResourceDisplay_Hide(self);
    end
end

local function LongClick_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.5 then
        --Now start auto-donating item
        --We apply additional animations to indicate this Long-click state
        self:SetScript("OnUpdate", nil);
        PlayerChoiceUI.autoClick = true;
        if PlayerChoiceUI.repeatButtonID then
            C_PlayerChoice.SendPlayerChoiceResponse(PlayerChoiceUI.repeatButtonID);
            PlayerChoiceUI.consumeNextClick = true;
            PlayerChoiceUI.ProgressBar.playShake = true;
        end
    end
end

function PlayerChoiceUI:StartHoldCountdown()
    self.autoClick = false;
    self.LongClickWatcher.t = 0;
    self.LongClickWatcher:SetScript("OnUpdate", LongClick_OnUpdate);
end

function PlayerChoiceUI:StopAutoClick()
    self.autoClick = false;
    self.LongClickWatcher.t = 0;
    self.LongClickWatcher:SetScript("OnUpdate", nil);
    self.ProgressBar.playShake = false;
end

local function Debug_ShowFrameSize(frame)
    local bg = frame:CreateTexture(nil, "BACKGROUND", nil, -1);
    bg:SetAllPoints(true);
    bg:SetColorTexture(1, 1, 1, 0.5);
    bg:SetIgnoreParentAlpha(true);
end

local function RewardItem_OnEnter(self)
    GameTooltip:Hide();
    if self.OptionFrame.itemID then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetItemByID(self.OptionFrame.itemID);
        GameTooltip:Show();
    end
end

local function RewardItem_OnLeave(self)
    GameTooltip:Hide();
end

local function OptionButton_OnClick(self)
    --We need to consume this click if long-click just ended
    --Sometimes the intial second click doesn't work due to Event not firing that fast? 

    if self.id and not PlayerChoiceUI.consumeNextClick then
        C_PlayerChoice.SendPlayerChoiceResponse(self.id);
    end
    PlayerChoiceUI.consumeNextClick = false;
end

local function OptionButton_OnMouseDown(self)
    if self.canLongClick then
        PlayerChoiceUI:StartHoldCountdown();
    end
end

local function OptionButton_OnMouseUp(self)
    PlayerChoiceUI:StopAutoClick();
end

local function CreateOptionFrame()
    local f = CreateFrame("Frame", nil, PlayerChoiceUI);
    API.Mixin(f, OptionFrameMixin);
    f:SetSize(OPTION_FRAME_WIDTH, 102);

    --Item Reward
    local RewardFrame = CreateFrame("Frame", nil, f);
    f.RewardFrame = RewardFrame;
    RewardFrame:SetSize(OPTION_FRAME_WIDTH, 64);
    RewardFrame:SetPoint("TOP", f, "TOP", 0, 0);

    local RewardBorder = RewardFrame:CreateTexture(nil, "OVERLAY");
    RewardFrame.Border = RewardBorder;
    RewardBorder:SetSize(48, 48);
    RewardBorder:SetTexCoord(0, 0.1875, 0, 0.1875);
    RewardBorder:SetPoint("TOP", RewardFrame, "TOP", 0, -5);
    RewardBorder:SetTexture("Interface/AddOns/Plumber/Art/PlayerChoiceUI/UI");
    API.DisableSharpening(RewardBorder);

    local Hitbox = CreateFrame("Frame", nil, RewardFrame);
    Hitbox:SetSize(38, 38);
    Hitbox:SetPoint("CENTER", RewardBorder, "CENTER", 0, 0);
    Hitbox:SetScript("OnEnter", RewardItem_OnEnter);
    Hitbox:SetScript("OnLeave", RewardItem_OnLeave);
    Hitbox.OptionFrame = f;

    local RewardIcon = RewardFrame:CreateTexture(nil, "ARTWORK");
    RewardFrame.Icon = RewardIcon;
    RewardIcon:SetSize(34, 34);
    RewardIcon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375);
    RewardIcon:SetPoint("CENTER", RewardBorder, "CENTER", 0, 0);

    local IconMask = RewardFrame:CreateMaskTexture(nil, "ARTWORK");
    IconMask:SetPoint("TOPLEFT", RewardIcon, "TOPLEFT", 0, 0);
    IconMask:SetPoint("BOTTOMRIGHT", RewardIcon, "BOTTOMRIGHT", 0, 0);
    IconMask:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Circle", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
    RewardIcon:AddMaskTexture(IconMask);

    local RewardTick = RewardFrame:CreateTexture(nil, "OVERLAY", nil, 4);
    RewardFrame.Checkmark = RewardTick;
    RewardTick:SetSize(24, 24);
    RewardTick:SetTexture("Interface/AddOns/Plumber/Art/Button/Checkmark-Green");
    RewardTick:SetPoint("CENTER", RewardBorder, "CENTER", 16, -9);
    RewardTick:Show();

    local RewardName = RewardFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText");
    RewardFrame.Name = RewardName;
    RewardName:SetJustifyH("CENTER");
    RewardName:SetShadowOffset(1, -1);
    RewardName:SetPoint("TOP", RewardBorder, "BOTTOM", 0, 0);
    RewardName:SetTextColor(1, 1, 1);
    RewardName:SetText("Item Name");

    local TextShadow = addon.CreateTextDropShadow(RewardName, RewardFrame);

    --Debug_ShowFrameSize(f);

    --Donate Button
    local Button = addon.CreateRedButton(f, "large");
    f.Button = Button;

    local resourceHeight = 22;

    Button:SetPoint("BOTTOM", f, "BOTTOM", 0, resourceHeight);
    Button:SetWidth(OPTION_FRAME_WIDTH);
    Button:SetScript("OnClick", OptionButton_OnClick);
    Button.onMouseDownFunc = OptionButton_OnMouseDown;
    Button.onMouseUpFunc = OptionButton_OnMouseUp;

    f:SetHeight(102 + resourceHeight);

    return f
end


function PlayerChoiceUI:OnEvent(event, ...)
    if event == "PLAYER_CHOICE_UPDATE" then
        self:PLAYER_CHOICE_UPDATE();
    elseif event == "PLAYER_CHOICE_CLOSE" then
        self:CloseUI();
    elseif event == "UPDATE_UI_WIDGET" then
        self:UPDATE_UI_WIDGET(...);
    elseif event == "UPDATE_ALL_UI_WIDGETS" then
        self:ProcessAllWidgets();
    elseif event == "PLAYER_DEAD" or event == "PLAYER_ENTERING_WORLD" then
        self:CloseUI();
    end
end

function PlayerChoiceUI:OnShow()

end

function PlayerChoiceUI:OnHide()
    self:StopAutoClick();
    self:SetScript("OnUpdate", nil);
    self.consumeNextClick = false;
end

local function CloseButton_OnEnter(self)
    self.ButtonText:SetTextColor(1, 1, 1);
end

local function CloseButton_OnLeave(self)
    self.ButtonText:SetTextColor(1, 0.82, 0);
end

local function CloseButton_OnClick(self)
    PlayerChoiceUI:CloseUI();
    C_PlayerChoice.OnUIClosed();
end

function PlayerChoiceUI:Init()
    --Debug_ShowFrameSize(self);

    self.Init = nil;
    self.optionFrames = {};

    self:SetScript("OnHide", self.OnHide);

    local offsetY = 0;

    local Title = self:CreateFontString(nil, "OVERLAY", "GameTooltipText");
    self.Title = Title;
    Title:SetJustifyH("CENTER");
    Title:SetShadowOffset(1, -1);
    Title:SetPoint("TOP", self, "TOP", 0, -offsetY);
    Title:SetTextColor(1, 0.82, 0);

    offsetY = offsetY + 16;

    local BarName = self:CreateFontString(nil, "OVERLAY", "GameTooltipText");
    self.BarName = BarName;
    BarName:SetJustifyH("CENTER");
    BarName:SetShadowOffset(1, -1);
    BarName:SetPoint("TOP", self, "TOP", 0, -offsetY);
    BarName:SetTextColor(1, 1, 1);

    offsetY = offsetY + 16;

    local BarValue = self:CreateFontString(nil, "OVERLAY", nil, 6);
    self.BarValue = BarValue;
    local font, fontHeight, flag = GameFontNormal:GetFont();
    BarValue:SetFont(font, 16, "OUTLINE");
    BarValue:SetPoint("TOP", self, "TOP", 0, -offsetY);
    BarValue:SetJustifyH("CENTER");
    BarValue:SetJustifyV("MIDDLE");
    BarValue:SetShadowOffset(1, -1);
    BarValue:SetShadowColor(0, 0, 0);
    BarValue:SetTextColor(1, 1, 1);

    offsetY = offsetY + 20;

    local ProgressBar = addon.CreateMetalProgressBar(self, "large");
    self.ProgressBar = ProgressBar;
    ProgressBar:SetPoint("TOP", self, "TOP", 0, -offsetY);
    ProgressBar.BarValue = BarValue;
    ProgressBar:SetNumThreshold(1);
    ProgressBar:SetValue(0, 100);
    ProgressBar:SetSmoothFill(true);

    local BarHeight = ProgressBar:GetHeight();
    offsetY = offsetY + BarHeight;
    self:SetSize(174, offsetY); --Header Height 84

    local Shadow = self:CreateTexture(nil, "BACKGROUND", nil, -1);
    Shadow:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/DispersiveShadow_Round");
    Shadow:SetPoint("CENTER", self, "CENTER", 0, 0);
    Shadow:SetVertexColor(0, 0, 0, 0.6);
    Shadow:SetSize(500, 500);
    self.CentralShadow = Shadow;


    local CloseButton = addon.CreateThreeSliceFrame(self, "Metal_Hexagon_Red", "Button");
    CloseButton:SetPoint("TOP", self, "BOTTOM", 0, -20);
    CloseButton:SetSize(60, 20);
    CloseButton.ButtonText = CloseButton:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    CloseButton.ButtonText:SetJustifyH("CENTER");
    CloseButton.ButtonText:SetJustifyV("MIDDLE");
    CloseButton.ButtonText:SetTextColor(1, 0.82, 0);
    CloseButton.ButtonText:SetPoint("CENTER", CloseButton, "CENTER", 0, 0);
    CloseButton.ButtonText:SetText(CLOSE or "Close");

    local textWidth = CloseButton.ButtonText:GetWidth();
    if textWidth < 32 then textWidth = 32 end;
    textWidth = floor(textWidth + 0.5);
    CloseButton:SetWidth(textWidth + 24);

    CloseButton.Highlight = CloseButton:CreateTexture(nil, "HIGHLIGHT");
    CloseButton.Highlight:SetPoint("TOPLEFT", CloseButton, "TOPLEFT", 0, 0);
    CloseButton.Highlight:SetPoint("BOTTOMRIGHT", CloseButton, "BOTTOMRIGHT", 0, 0);
    CloseButton.Highlight:SetTexture("Interface/AddOns/Plumber/Art/Frame/RedButton-Highlight", nil, nil, "TRILINEAR");
    CloseButton.Highlight:SetVertexColor(0.4, 0.1, 0.1);
    CloseButton.Highlight:SetBlendMode("ADD");

    CloseButton:SetScript("OnEnter", CloseButton_OnEnter);
    CloseButton:SetScript("OnLeave", CloseButton_OnLeave);
    CloseButton:SetScript("OnClick", CloseButton_OnClick);

    local rb = addon.CreateRepositionButton(self);
    self.RepositionButton = rb;
    rb:SetOrientation("x");
    rb:SetPoint("TOP", CloseButton, "BOTTOM", 0, -40);
end


local AnnounceButtonData = {};

function AnnounceButtonData:SetTargetCoord(x, y)
    self.x, self.y = x, y;
end

function AnnounceButtonData.ValidityCheck(msg)
    local uiMapID, x, y = GetWaypointFromText(msg);
    if uiMapID and uiMapID == 2200 then
        x = x / 10000;
        y = y / 10000;

        local isClose = AreWaypointsClose(x, y, AnnounceButtonData.x or 0, AnnounceButtonData.y or 0);
        return isClose
    end
end

function AnnounceButtonData:GetDreamseedName()
    if not self.nameDeamseed then
        local spellID = 425856;
        local name = GetSpellInfo(spellID);
        if name then
            self.nameDeamseed = name;
        end
    end
    return self.nameDeamseed or "Dreamseed"
end

function AnnounceButtonData.UpdatePlayerLocation()
    local creatureID, coordX, coordY = DreamseedUtil:GetNearbyPlantInfo();
    if coordX and coordY then
        AnnounceButtonData:SetTargetCoord(coordX, coordY);
    end
end

function AnnounceButtonData.GenerateMessage()
    local creatureID, coordX, coordY = DreamseedUtil:GetNearbyPlantInfo();
    if not creatureID then
        return false, 0
    end

    AnnounceButtonData:SetTargetCoord(coordX, coordY);

    local DISABLE_ANNOUNCE_TIME = 20;

    --local name = DreamseedUtil:GetPlantNameByCreatureID(creatureID);
    local remainingTime = DreamseedUtil:GetGrowthTimesByCreatureID(creatureID);
    local tint = PlayerChoiceUI.ProgressBar and PlayerChoiceUI.ProgressBar:GetBarColorTint() or 0;
    local colorText;

    if tint == 6 then   --purple
        colorText = L["Seed Color Epic"];
    elseif tint == 7 then   --green
        colorText = L["Seed Color Uncommon"];
    elseif tint == 8 then   --blue
        colorText = L["Seed Color Rare"];
    end

    if colorText then
        colorText = string.gsub(colorText, "^%l",string.upper);
    end

    if not (remainingTime and colorText) then
        return false, 0
    end

    if remainingTime < DISABLE_ANNOUNCE_TIME then
        return false, 3
    end

    local waypointText = API.CreateWaypointHyperlink(MAPID_EMRALD_DREAM, coordX, coordY);
    local name = AnnounceButtonData:GetDreamseedName();
    local msg = string.format("%s %s %s", colorText, name, waypointText);

    if remainingTime < 90 then
        --Add time
        local abbreviated = true;
        local partialTime = false;
        local bakePluralEscapeSequence = true;
        local timeText = API.SecondsToTime(remainingTime, abbreviated, partialTime, bakePluralEscapeSequence);
        msg = msg.." "..timeText;
    end

    return true, msg
end

function PlayerChoiceUI:SetupAnnounceButton()
    local Horn = addon.GetAnnounceButton();
    Horn:SetParent(self);
    Horn:ClearAllPoints();
    Horn:SetPoint("BOTTOM", self, "TOP", 0, 2);
    Horn:SetValidityCheck(AnnounceButtonData.ValidityCheck);
    Horn:SetAnnouceTextSource(AnnounceButtonData.GenerateMessage);
    Horn:EnableCursorBlocker(true);
    Horn:ShowAndRequestUpdate(AnnounceButtonData.UpdatePlayerLocation);
    AnnounceButtonData:GetDreamseedName();  --to cache item name
end

local INTRO_DURATION = 0.35;

local function Intro_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    local alpha = self.t * 2.857;
    if alpha > 1 then
        alpha = 1;
    end

    local height = easingFunc(self.t, self.fullHeight - 48, self.fullHeight, INTRO_DURATION);

    if self.t > INTRO_DURATION then
        alpha = 1;
        height = self.fullHeight;
        self:SetScript("OnUpdate", nil);
    end

    PlayerChoiceUI:SetAlpha(alpha);
    PlayerChoiceUI:SetHeight(height);
end

function PlayerChoiceUI:PlayIntro()
    self.t = 0;
    Intro_OnUpdate(self, 0);
    self:SetScript("OnUpdate", Intro_OnUpdate);
end

function PlayerChoiceUI:ShowUI()
    if self.Init then
        self:Init();
    end

    local success = self:Setup(self.choiceInfo and self.choiceInfo.options[1]);

    if not success then
        self:CloseUI();
        return false
    end

    if not self:IsShown() then
        ZoomCalculator:Sync();
        self:PlayIntro();
        self:RegisterEvent("UPDATE_UI_WIDGET");
        self:RegisterEvent("UPDATE_ALL_UI_WIDGETS");
        self:RegisterEvent("PLAYER_DEAD");
        self:RegisterEvent("PLAYER_ENTERING_WORLD");
        self.consumeNextClick = false;
        self.requireRewardCheck = true;
        self:SetupAnnounceButton();
    end

    self:Show();
    return true
end

function PlayerChoiceUI:CloseUI()
    self:Hide();
    self.choiceInfo = nil;
    self.items = nil;
    self:UnregisterEvent("UPDATE_UI_WIDGET");
    self:UnregisterEvent("UPDATE_ALL_UI_WIDGETS");
    self:UnregisterEvent("PLAYER_DEAD");
    self:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

local function ContinueAutoClick()
    if PlayerChoiceUI:IsShown() and PlayerChoiceUI.autoClick and PlayerChoiceUI.repeatButtonID then
        C_PlayerChoice.SendPlayerChoiceResponse(PlayerChoiceUI.repeatButtonID);
    end
end

function PlayerChoiceUI:PLAYER_CHOICE_UPDATE()
    local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo();

    self.choiceInfo = choiceInfo;
    self.repeatButtonID = nil;

    if not choiceInfo then
        self:CloseUI();
        return
    end

    local creatureID = GetCreatureIDFromGUID(choiceInfo.objectGUID);

    if VALID_CREATURES[creatureID] then
        local success = self:ShowUI();
        if success then
            BlizzardFrameMover:HidePlayerChoiceFrame();
        end

        if self.autoClick and self.repeatButtonID then
            local barValue = self.ProgressBar:GetValue();
            if barValue == 50 then
                C_Timer.After(0.75, ContinueAutoClick);
            else
                C_PlayerChoice.SendPlayerChoiceResponse(self.repeatButtonID);
            end
        end
    else
        self:CloseUI();
    end
end

function PlayerChoiceUI:UPDATE_UI_WIDGET(widgetInfo)
    if widgetInfo.widgetSetID and widgetInfo.widgetSetID == self.widgetSetID then
        self:ProcessWidget(widgetInfo.widgetID, widgetInfo.widgetType);
    end
end

function PlayerChoiceUI:AcquireOptionFrame(optionIndex)
    if not self.optionFrames[optionIndex] then
        self.optionFrames[optionIndex] = CreateOptionFrame();
    end
    self.optionFrames[optionIndex]:Show();
    return self.optionFrames[optionIndex];
end

function PlayerChoiceUI:Setup(option)
    if not (option and option.buttons) then
        return false
    end

    local buttons = option.buttons;

    for buttonIndex, buttonInfo in ipairs(buttons) do
        self:AcquireOptionFrame(buttonIndex);
        self.optionFrames[buttonIndex]:SetupButton(buttonInfo);
    end

    self.Title:SetText(option.header);

    local numOptions = #buttons;
    local fullHeight = 220;

    if numOptions ~= self.numOptions then
        self.numOptions = numOptions;
        local optionFrame;
        local optionHeight;

        for i = 1, numOptions do
            self.optionFrames[i]:ClearAllPoints();
            self.optionFrames[i]:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", (i- 1)*(OPTION_FRAME_WIDTH + OPTION_FRAME_GAP), 0);
            if not optionHeight then
                optionHeight = self.optionFrames[i]:GetHeight();
            end
        end

        for i = numOptions + 1, #self.optionFrames do
            self.optionFrames[i]:Hide();
        end
        
        if numOptions > 0 then
            self:SetWidth(numOptions*(OPTION_FRAME_WIDTH + OPTION_FRAME_GAP) - OPTION_FRAME_GAP);
            local headerHeight = 84;
            local gap = 12;
            fullHeight = headerHeight + gap + optionHeight;
            self:SetHeight(fullHeight);
            self.fullHeight = fullHeight;
        else
            self:SetHeight(174);
            self.fullHeight = 174;
        end
    end

    self.fullHeight = fullHeight;
    self.widgetSetID = option.widgetSetID;

    self:ProcessAllWidgets();

    return true
end

function PlayerChoiceUI:ProcessAllWidgets()
    self.itemOptionFrame = {};
    self.items = {};
    if self.widgetSetID then
        local setWidgets = C_UIWidgetManager.GetAllWidgetsBySetID(self.widgetSetID);
        for _, widgetInfo in ipairs(setWidgets) do
            self:ProcessWidget(widgetInfo.widgetID, widgetInfo.widgetType);
        end

        local numItems = 0;
        local optionFrame;
        for order = 1, 10 do
            if self.items[order] then
                numItems = numItems + 1;
                optionFrame = self:AcquireOptionFrame(numItems);
                self.itemOptionFrame[order] = optionFrame;
                optionFrame:SetupItem(self.items[order][1], self.items[order][2]);
                if numItems == 2 then
                    break
                end
            end
        end
    end
end

function PlayerChoiceUI:ProcessWidget(widgetID, widgetType)
    local widgetInfo;

    if widgetType == 2 then
        widgetInfo = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widgetID);
        if widgetInfo then
            self.BarName:SetText(widgetInfo.text);
            self.ProgressBar:SetValue(widgetInfo.barValue, widgetInfo.barMax, true);
            self.ProgressBar:SetNumThreshold( widgetInfo.barMax > 10 and 1 or 0 );  --Tutorial Plant only requires 5
            self.ProgressBar:SetBarColorTint(widgetInfo.colorTint);
        end
    elseif widgetType == 27 then
        --all items fire, we only need shownState == 1
        widgetInfo = C_UIWidgetManager.GetItemDisplayVisualizationInfo(widgetID);
        if widgetInfo and widgetInfo.shownState == 1 then
            local order = widgetInfo.orderIndex;
            local itemID = widgetInfo.itemInfo.itemID;
            local isEarned = widgetInfo.itemInfo.showAsEarned;
            if not self.items[order] then
                self.items[order] = {itemID, isEarned};
            else
                self.items[order][2] = isEarned;
                if self.itemOptionFrame[order] then
                    self.itemOptionFrame[order]:SetupItem(self.items[order][1], self.items[order][2]);
                end
            end
            --local layoutDirection = widgetInfo.layoutDirection;
            --local name = C_Item.GetItemNameByID(itemID);
            --print(itemID, name, order, layoutDirection, isEarned);
        end
    end
end

function PlayerChoiceUI:Enable()
    self:RegisterEvent("PLAYER_CHOICE_UPDATE");
    self:RegisterEvent("PLAYER_CHOICE_CLOSE");
    self:SetScript("OnEvent", self.OnEvent);
end

function PlayerChoiceUI:Disable()
    self:CloseUI();
    self:UnregisterEvent("PLAYER_CHOICE_UPDATE");
    self:UnregisterEvent("PLAYER_CHOICE_CLOSE");
    self:SetScript("OnEvent", nil);
end


local function SetAndSaveFramePosition(offsetX)
    UI_OFFSET_X = offsetX;
    PlumberDB.playerchoiceuiOffsetX = offsetX;
    local y = ZoomCalculator.fromY or 0;
    PlayerChoiceUI:SetPoint("CENTER", UI_OFFSET_X, y);
end


local function LoadFramePosition()
    local userPositionX = PlumberDB and PlumberDB.playerchoiceuiOffsetX;
    if userPositionX then
        if type(userPositionX) ~= "number" then
            userPositionX = 0;
            PlumberDB.playerchoiceuiOffsetX = userPositionX;
        end
        SetAndSaveFramePosition(userPositionX);
    end
end


local ZoneTriggerModule;

local function EnableModule(state)
    if state then
        if not ZoneTriggerModule then
            local module = API.CreateZoneTriggeredModule("nurture");
            ZoneTriggerModule = module;
            module:SetValidZones(MAPID_EMRALD_DREAM);

            local function OnEnterZoneCallback()
                PlayerChoiceUI:Enable();
            end

            local function OnLeaveZoneCallback()
                PlayerChoiceUI:Disable();
            end

            module:SetEnterZoneCallback(OnEnterZoneCallback);
            module:SetLeaveZoneCallback(OnLeaveZoneCallback);

            LoadFramePosition();
        end
        ZoneTriggerModule:SetEnabled(true);
        ZoneTriggerModule:Update();

        if C_AddOns then
            if C_AddOns.IsAddOnLoaded("MoveAny") then
                HideBlizzardFrame = HideBlizzardFrame_MoveAny;
            elseif C_AddOns.IsAddOnLoaded("Drift") then
                HideBlizzardFrame = HideBlizzardFrame_Drift;
            end
            --BlizzMove does not support PlayerChoiceFrame
            --MoveAnything cannot move anything after 10.0
        end
    else
        if ZoneTriggerModule then
            ZoneTriggerModule:SetEnabled(false);
        end
        PlayerChoiceUI:Disable();
    end
end

do
    local moduleData = {
        name = L["ModuleName AlternativePlayerChoiceUI"],
        dbKey = "AlternativePlayerChoiceUI",
        description = L["ModuleDescription AlternativePlayerChoiceUI"],
        toggleFunc = EnableModule,
        categoryID = 10020001,
        uiOrder = 3,
    };

    addon.ControlCenter:AddModule(moduleData);
end



--[[
Rework PlayerChoiceFrame
    Title.Left/Middle/Right/Text
    NineSlice

    

    PlayerChoiceTimeRemaining
    PlayerChoiceNormalOptionTemplate
    PlayerChoiceFrame.optionPools.EnumerateActive

    function ModifyDefaultUI()
        local f = _G["PlayerChoiceFrame"];
        local pool = f and f.optionPools;
        if not pool then return end;

        f:EnableMouse(false);
        f.NineSlice:Hide();

        f.Background:Hide();
        f.Title.Left:SetTexture();
        f.Title.Middle:SetTexture();
        f.Title.Right:SetTexture();

        for optionFrame in pool:EnumerateActive() do
            --optionFrame.WidgetContainer:Hide(); --progress bar
            optionFrame:EnableMouse(false);
            optionFrame.Artwork:SetTexture();
            optionFrame.ArtworkBorder:SetTexture();
            optionFrame.Background:SetTexture();
        end
    end

--]]


ZoomCalculator.GetCameraZoom = GetCameraZoom;
ZoomCalculator.fromY = UI_OFFSET_Y;
ZoomCalculator.t = 0;

FrameMover:Hide();
FrameMover.t = 0;

function ZoomCalculator:Sync()
    local zoom = self.GetCameraZoom();
    if zoom ~= self.zoom then
        self.zoom = zoom;
        local toY = CalculateOffsetYFromZoom(zoom);
        self.fromY = toY;
        PlayerChoiceUI:SetPoint("CENTER", UI_OFFSET_X, toY);
    end
end

ZoomCalculator:SetScript("OnUpdate", function(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.1 then
        self.t = 0;
    else
        return
    end

    local zoom = self.GetCameraZoom();
    if zoom ~= self.zoom then
        self.zoom = zoom;
        local toY = CalculateOffsetYFromZoom(zoom)
        FrameMover.t = 0;
        FrameMover.fromY = self.fromY;
        FrameMover.toY = toY;
        FrameMover:Show();
    end
end);

local EASING_DURATION = 0.25;
local inOutSine = addon.EasingFunctions.outSine;

FrameMover:SetScript("OnUpdate", function(self, elapsed)
    self.t = self.t + elapsed;
    local y = inOutSine(self.t, self.fromY, self.toY, EASING_DURATION);
    if self.t >= EASING_DURATION then
        y = self.toY;
        self:Hide();
    end
    ZoomCalculator.fromY = y;
    PlayerChoiceUI:SetPoint("CENTER", UI_OFFSET_X, y);
end);




local function CalculateOffsetXToUIParentCenter()
    local uiCenterX, uiCenterY = UIParent:GetCenter();
    local x, y = PlayerChoiceUI:GetCenter();
    return x - uiCenterX, y - uiCenterY
end

function PlayerChoiceUI:ResetFramePosition()
    SetAndSaveFramePosition(0);
end

function PlayerChoiceUI:SnapShotFramePosition()
    self.repositionFromX, self.repositionFromY = CalculateOffsetXToUIParentCenter();
end

function PlayerChoiceUI:ConfirmNewPosition()
    local x = CalculateOffsetXToUIParentCenter();
    SetAndSaveFramePosition(x);
    self.repositionFromX, self.repositionFromY = nil, nil;
end

function PlayerChoiceUI:RepositionFrame(offsetX, offsetY)
    if not self.repositionFromX then
        self:SnapShotFramePosition();
    end
    self:SetPoint("CENTER", self.repositionFromX + (offsetX or 0), self.repositionFromY + (offsetY or 0));
end




do
    if GetLocale() == "deDE" then
        --German words are longer, so we need to adjust the button width
        OPTION_FRAME_WIDTH = OPTION_FRAME_WIDTH + 24;
    end
end


--[[
    --Dev Tool for ajust UI offset based on CameraZoom
local AjustButton = CreateFrame("Frame", nil, UIParent);
AjustButton.frameY = 0;
AjustButton.GetCursorPosition = GetCursorPosition;
Debug_ShowFrameSize(AjustButton);
AjustButton:SetPoint("CENTER", 400, 0);
AjustButton:SetSize(30, 30);
local function AjustButton_OnUpdate(self)
    local _, y = self.GetCursorPosition();
    if y ~= self.lastY then
        local d = y - self.lastY;
        self.lastY = y;
        self.frameY = self.frameY + d;
        print(floor(self.frameY*1000)/1000,"  ", floor(GetCameraZoom() * 1000)/1000);
        PlayerChoiceUI:SetPoint("CENTER", 0, self.frameY);
    end
end

AjustButton:SetScript("OnMouseDown", function(self)
    local _, y = self.GetCursorPosition();
    self.lastY = y;
    self:SetScript("OnUpdate", AjustButton_OnUpdate);
end);

AjustButton:SetScript("OnMouseUp", function(self)
    self:SetScript("OnUpdate", nil);
end);

function TestAnim()
    PlayerChoiceUI:ShowUI();
    PlayerChoiceUI:Show();
end
-]]