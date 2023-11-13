local _, addon = ...
local API = addon.API;
local L = addon.L;

local time = time;
local SearchChatHistory = API.SearchChatHistory;
local SecondsToTime = API.SecondsToTime;

local COOLDOWN_ANNOUNCE = 20;
local CAN_SEND_MESSAGE = false;

local DELENSION = "";

local HornButton = CreateFrame("Button");
HornButton:Hide();
HornButton:SetSize(20, 20);
HornButton:SetMotionScriptsWhileDisabled(true);
HornButton:RegisterForClicks("LeftButtonUp");


local PrivateFrame = CreateFrame("Frame");
PrivateFrame:Hide();

local function AlwaysFalse()
    return false
end
PrivateFrame.validateFunc = AlwaysFalse;

function PrivateFrame:GetGlobalUnlockTime()
    --This time is stored in our SavedVariable
    local db = PlumberDB;

    if db and db.announceButtonLockUntil and type(db.announceButtonLockUntil) == "number" then
        local currentTime = time();
        if db.announceButtonLockUntil - currentTime > 60 then
            db.announceButtonLockUntil = currentTime + COOLDOWN_ANNOUNCE;
        end
        return db.announceButtonLockUntil
    else
        return 0
    end
end

function PrivateFrame:SetGlobalUnlockTime(endTime)
    local db = PlumberDB;

    if db then
        if endTime then
            db.announceButtonLockUntil = endTime;
        else
            local currentTime = time();
            db.announceButtonLockUntil = currentTime + COOLDOWN_ANNOUNCE;
        end
    end
end

function PrivateFrame:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0 then
        self:SetScript("OnUpdate", nil);
        self.t = nil;
        self.endTime = nil;
        if HornButton:IsVisible() then
            self:UpdateValidity();
        end
    end
end

function PrivateFrame:StartLockTimer(forceRestart)
    if (not self.endTime) or forceRestart then
        self.t = -COOLDOWN_ANNOUNCE;
        self.endTime = time() + COOLDOWN_ANNOUNCE;
        PrivateFrame:SetGlobalUnlockTime(self.endTime);
        self:SetScript("OnUpdate", self.OnUpdate);
    end
end

function PrivateFrame:GetLockEndTime()
    return self.endTime or self:GetGlobalUnlockTime();
end

function PrivateFrame:GetLockRemainingSeconds()
    local seconds = self:GetLockEndTime() - time();
    if seconds < 0 then
        seconds = 0;
    end
    return seconds
end

function PrivateFrame:IsButtonInCooldown()
    return self:GetLockRemainingSeconds() > 0
end

function PrivateFrame:CalibrateTimer()
    local remainingSeconds = self:GetLockRemainingSeconds()
    if remainingSeconds <= 0 then
        self:UnlockButton();
        self:SetScript("OnUpdate", nil);
    else
        self:LockButton(1, true);
        self.t = -remainingSeconds;
        self.endTime = time() + remainingSeconds;
        self:SetScript("OnUpdate", self.OnUpdate);
    end
end

function PrivateFrame:UpdateValidity()
    local messageFound = SearchChatHistory(self.validateFunc);
    if messageFound then
        self:LockButton(2, true);
    else
        if not self:IsButtonInCooldown() then
            self:UnlockButton();
        end
    end
end

function PrivateFrame:LockButton(reason, overridePreviousReason)
    if (not self.disableReason) or overridePreviousReason then
        self.disableReason = reason;
    end

    CAN_SEND_MESSAGE = false;
    HornButton:Disable();

    --Disable Reason
    --#1 In cooldown (start OnClick)
    --#2 Shared by another player (search chat)
    --#3 Target soon despawn
end

function PrivateFrame:GetLockReason()
    local reason, hasTimer;

    if self.disableReason == 1 then
        reason = L["Announce Forbidden Reason In Cooldown"];
        hasTimer = true;
    elseif self.disableReason == 2 then
        reason = L["Announce Forbidden Reason Duplicate Message"];
    elseif self.disableReason == 3 then
        reason = L["Announce Forbidden Reason Soon Despawn"];
    else
        reason = TOKEN_MARKET_PRICE_NOT_AVAILABLE or "Not Available";
    end

    return reason, hasTimer
end

function PrivateFrame:UnlockButton()
    CAN_SEND_MESSAGE = true;
    HornButton:Enable();
    self.disableReason = nil;
end

function PrivateFrame:ListenEvents(state)
    if state then
        self:RegisterEvent("CHAT_MSG_CHANNEL");
    else
        self:UnregisterEvent("CHAT_MSG_CHANNEL");
    end
end

function PrivateFrame:OnShow()
    self:CalibrateTimer();
    self:ListenEvents(true);
    self:UpdateValidity();
end

function PrivateFrame:OnHide()
    self:ListenEvents(false);
end

PrivateFrame:SetScript("OnShow", PrivateFrame.OnShow);
PrivateFrame:SetScript("OnHide", PrivateFrame.OnHide);

PrivateFrame:SetScript("OnEvent", function(self, event, ...)
    local text = ...
    if text and self.validateFunc(text) then
        self:LockButton(2, true);
    end
end);


function HornButton:OnMouseDown(button)
    if self:IsEnabled() and button == "LeftButton" then
        self.Icon:SetPoint("CENTER", self, "CENTER", 0, -1);
    end
end

function HornButton:OnMouseUp()
    self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0);
end

function HornButton:GetAnnounceText()
    if self.sourceFunction then
        return self.sourceFunction()
    end
end

function HornButton:SetAnnouceTextSource(sourceFunction)
    self.sourceFunction = sourceFunction;
end

function HornButton:OnClick()
    local success, msg = self:GetAnnounceText();

    if not success then
        local reasonCode = msg;
        PrivateFrame:LockButton(reasonCode, true);
        return
    end

    if CAN_SEND_MESSAGE and msg then
        --print(msg);
        local channelID = C_ChatInfo.GetGeneralChannelID();
        if channelID then
            SendChatMessage(msg, "CHANNEL", nil, channelID);
        else
            UIErrorsFrame:AddExternalErrorMessage("Could not find General Chat channel.");
        end
        PrivateFrame:LockButton(1, true);
        PrivateFrame:StartLockTimer(true);
    end
end

function HornButton:OnEnable()
    self.Icon:SetDesaturated(false);
    self.Icon:SetVertexColor(1, 1, 1);
    self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0);
    self:RefreshOnEnter();
end

function HornButton:OnDisable()
    self.Icon:SetDesaturated(true);
    self.Icon:SetVertexColor(0.8, 0.8, 0.8);
    self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0);
    self.Highlight:Hide();
    self:RefreshOnEnter();
end

function HornButton:RefreshOnEnter()
    if self:IsVisible() and self:IsMouseOver() then
        self:OnEnter();
    end
end

function HornButton:OnShow()
    --PrivateFrame:Show();
end

function HornButton:OnHide()
    self:SetScript("OnUpdate", nil);
    PrivateFrame:Hide();
end

function HornButton:UpdateTooltipTimer()
    self:OnEnter();
end

function HornButton:OnEnter()
    local tooltip = GameTooltip;
    tooltip:Hide();
    tooltip:SetOwner(self, "ANCHOR_RIGHT");
    tooltip:SetText(BATTLENET_BROADCAST or "Broadcast", 1, 1, 1);

    if self:IsEnabled() and CAN_SEND_MESSAGE then
        self.Highlight:Show();
        tooltip:AddLine(L["Announce Location Tooltip"], 1, 0.82, 0, true);
        self.UpdateTooltip = nil;
    else
        self.Highlight:Hide();
        local lockReason, hasTimer = PrivateFrame:GetLockReason();
        tooltip:AddLine(lockReason, 1.000, 0.282, 0.000, true); --WARNING_FONT_COLOR
        if hasTimer then
            local seconds = PrivateFrame:GetLockRemainingSeconds();
            if seconds and seconds > 0 then
                local remainingTime = string.format(L["Available In Format"], SecondsToTime(seconds, true));
                tooltip:AddLine(remainingTime, 1, 0.82, 0, true);
                self.UpdateTooltip = self.UpdateTooltipTimer;
            else
                self.UpdateTooltip = nil;
            end
        else
            self.UpdateTooltip = nil;
        end
    end
    tooltip:Show();
end

function HornButton:OnLeave()
    GameTooltip:Hide();
    self.Highlight:Hide();
end

function HornButton:EnableCursorBlocker(state)
    self.CursorBlocker:SetShown(state);
end

function HornButton:Init()
    local tex = "Interface/AddOns/Plumber/Art/Button/HornButton";

    self.Highlight = self:CreateTexture(nil, "OVERLAY");    --HIGHLIGHT layers doesn't work well when SetMotionScriptsWhileDisabled = true
    self.Highlight:Hide();
    self.Highlight:SetSize(32, 32);
    self.Highlight:SetPoint("CENTER", self, "CENTER", 0, 0);
    self.Highlight:SetTexture(tex);
    self.Highlight:SetTexCoord(0.5, 1, 0, 1);

    self.Icon = self:CreateTexture(nil, "ARTWORK");
    self.Icon:SetSize(32, 32);
    self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0);
    self.Icon:SetTexture(tex);
    self.Icon:SetTexCoord(0, 0.5, 0, 1);

    self:SetScript("OnMouseDown", self.OnMouseDown);
    self:SetScript("OnMouseUp", self.OnMouseUp);
    self:SetScript("OnClick", self.OnClick);
    self:SetScript("OnEnable", self.OnEnable);
    self:SetScript("OnDisable", self.OnDisable);
    self:SetScript("OnShow", self.OnShow);
    self:SetScript("OnHide", self.OnHide);
    self:SetScript("OnEnter", self.OnEnter);
    self:SetScript("OnLeave", self.OnLeave);

    local CursorBlocker = CreateFrame("Frame", nil, self);
    self.CursorBlocker = CursorBlocker;
    CursorBlocker:SetSize(40, 40);
    CursorBlocker:Hide();
    CursorBlocker:SetPoint("CENTER", self, "CENTER", 0, 0);
    CursorBlocker:SetFrameStrata("BACKGROUND");
    CursorBlocker:SetFixedFrameStrata(true);
    CursorBlocker:EnableMouse(true);

    self.Init = nil;
end

function HornButton:SetValidityCheck(validateFunc)
    PrivateFrame.validateFunc = validateFunc or AlwaysFalse;
end

function HornButton:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0.5 then
        self:SetScript("OnUpdate", nil);
        if self.callback then
            self.callback();
            self.callback = nil;
        end
        PrivateFrame:Show();
        PrivateFrame:UpdateValidity();
    end
end

function HornButton:ShowAndRequestUpdate(optionalCallback)
    self:Disable();
    self.t = 0;
    self.callback = optionalCallback;
    self:SetScript("OnUpdate", self.OnUpdate);
    self:Show();
end

local function GetAnnounceButton()
    if HornButton.Init then
        HornButton:Init();
    end
    HornButton:Hide();

    return HornButton
end
addon.GetAnnounceButton = GetAnnounceButton;



do
    local locale = GetLocale();
    if locale == "ruRU" then
        DELENSION = ": ";
    end
end
--Debug
--[[
local function ProcessChatMessage(msg)
    local uiMapID, x, y = GetWaypointFromText(msg);
    if uiMapID then
        print(uiMapID, x, y)
    end
end

function PrintChatWaypoints()
    SearchChatHistory(ProcessChatMessage);
end

function Debug_WaypointsMatch()
    local uiMapID = C_Map.GetBestMapForUnit("player");
    local posVector = C_Map.GetUserWaypointPositionForMap(uiMapID);

    if posVector then
        local x, y = posVector:GetXY();
        local LocationDataProvider = API.DreamseedUtil;
        local isClose;

        for creatureID, position in LocationDataProvider:EnumerateSpawnLocations() do
            isClose = AreWaypointsClose(x, y, position[1], position[2]);
            if isClose then
                local name = LocationDataProvider:GetPlantNameByCreatureID(creatureID);
                print(name)
                break
            end
        end
    end
end
--]]