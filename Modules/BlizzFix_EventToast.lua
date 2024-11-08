--Make EventToasts like (EventToastManagerWeeklyRewardToastUnlockTemplate) non-interactable so they doesn't block your mouse action
--To pause animation on mouseover, Blizzard make them interactable, enableMouse="true" so they can be picked up by GetMouseFocus()
--But there are other ways to do this without consuming mouse clicks

local _, addon = ...

local BlizzardFrame = EventToastManagerFrame;

if not BlizzardFrame then
    print("Plumber: Cannot find EventToastManagerFrame");
    return
end

local GetScaledCursorPosition = addon.API.GetScaledCursorPosition;
local GetMouseFocus = addon.API.GetMouseFocus;
local WorldFrame = WorldFrame;
local Original_OnUpdate = EventToastManagerFrameMixin and EventToastManagerFrameMixin.OnUpdate;
local DEFAULT_STATE = BlizzardFrame and BlizzardFrame:IsMouseEnabled();
local MODULE_ENABLED = false;

local CURRENT_TOAST;
local HITBOX_MAX_WIDTH = 160;

local _G = _G;

local Module = CreateFrame("Frame");
Module.ignoreInLayout = true;
Module:Hide();


local function CloseActiveToasts()
    if BlizzardFrame.CloseActiveToasts then
        BlizzardFrame:CloseActiveToasts();
        BlizzardFrame:Hide();
    end
end

local function IsObjectFocused(obj, cursorX, cursorY)
    if obj and obj:IsVisible() then
        local left = obj:GetLeft();
        if not left then return false end;

        local right = obj:GetRight();
        local top = obj:GetTop();
        local bottom = obj:GetBottom();
        local shrinkH = (right - left) - HITBOX_MAX_WIDTH;
        if shrinkH > 0 then
            --if the Title is too wide, we'll shrink the hitbox
            left = left + shrinkH*0.5;
            right = right - shrinkH*0.5;
        end
        return cursorX > left and cursorX < right and cursorY > bottom and cursorY < top
    else
        return false
    end
end

local function HideGameTooltip()
    GameTooltip:Hide();
end

local function IsMethodAvailable()
    local methods = {
        "PauseAnimations",
        "ResumeAnimations",
        "OnUpdate",
        "eventToastPools",
        "SetupButton",
    };

    for _, method in ipairs(methods) do
        if not BlizzardFrame[method] then
            return false
        end
    end

    return true
end

local function SetToastInteractable(toast, interactable)
    toast:EnableMouse(interactable);
    if toast.TitleTextMouseOverFrame then
        toast.TitleTextMouseOverFrame:EnableMouse(interactable);
    end
    if toast.SubTitleMouseOverFrame then
        toast.SubTitleMouseOverFrame:EnableMouse(interactable);
    end
end

local function SetAllToastsInteractable(interactable)
    local pool = BlizzardFrame.eventToastPools;
    if pool then
        interactable = (interactable and true) or false;
        for obj in pool:EnumerateActive() do
            SetToastInteractable(obj, interactable);
        end

        if pool.EnumerateInactive then
            for obj in pool:EnumerateInactive() do
                SetToastInteractable(obj, interactable);
            end
        elseif pool.inactiveObjects then
            for obj in pairs(pool.inactiveObjects) do
                SetToastInteractable(obj, interactable);
            end
        end
    end
end

local function EventToastManager_OnSetupButton(uiTextureKit)
    if not MODULE_ENABLED then return end;

    local currentToast = BlizzardFrame.currentDisplayingToast;
    CURRENT_TOAST = currentToast;

    if not currentToast then
        Module.hasTitleScript = false;
        Module.hasSubtitleScript = false;
        return
    end

    local toastInfo = CURRENT_TOAST.toastInfo;
    local hasTitleScript = toastInfo and toastInfo.titleTooltip or toastInfo.titleTooltipUiWidgetSetID;
    local hasSubtitleScript = toastInfo and toastInfo.subtitleTooltip or toastInfo.subtitleTooltipUiWidgetSetID;

    currentToast:EnableMouse(false);
    if currentToast.TitleTextMouseOverFrame then
        currentToast.TitleTextMouseOverFrame:EnableMouse(hasTitleScript);
    end
    if currentToast.SubTitleMouseOverFrame then
        currentToast.SubTitleMouseOverFrame:EnableMouse(hasSubtitleScript);
    end

    Module.hasTitleScript = hasTitleScript;
    Module.hasSubtitleScript = hasSubtitleScript;

    --[[
    local pool = BlizzardFrame.eventToastPools;
    if pool then
        for obj in pool:EnumerateActive() do
            SetToastInteractable(obj, false);
        end
    end
    --]]
end

local function TopBannerManager_OnShowCallback(banner)
    if MODULE_ENABLED then
        Module:StartWatching();
    end
end

function Module:GetActiveToast()
    if _G.TopBannerQueue and #_G.TopBannerQueue > 0 then
        return _G.TopBannerMgr.currentBanner and _G.TopBannerMgr.currentBanner.frame
    end

    return BlizzardFrame.currentDisplayingToast
end

function Module:StartWatching()
    self:RegisterEvent("GLOBAL_MOUSE_DOWN");
    self.interval = 0;
    self.totalTime = 0;
    self:SetScript("OnUpdate", self.OnUpdate);
    self:Show();
end

function Module:OnShow()
    --print("MANAGER_SHOW");
end

function Module:OnHide()
    self:SetScript("OnUpdate", nil);
    self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
    self.interval = 0;
    self.totalTime = 0;
    --print("MANAGER_HIDE");
end

function Module:OnEvent(event, ...)
    if event == "GLOBAL_MOUSE_DOWN" then
        local button = ...
        if button == "RightButton" then
            local activeBanner = self:GetActiveToast();
            if activeBanner and activeBanner:IsShown() then
                if activeBanner:IsMouseOver() then
                    activeBanner:Hide();
                    CloseActiveToasts();
                    HideGameTooltip();
                end
            else
                self:Hide();
            end
        end
    end
end

function Module:OnUpdate(elapsed)
    self.interval = self.interval + elapsed;
    self.totalTime = self.totalTime + elapsed;

    if self.interval > 0.2 then
        self.interval = 0;
        if CURRENT_TOAST and CURRENT_TOAST:IsShown() then
            local pause = false;
            local x, y = GetScaledCursorPosition();
            local mouseFocus = GetMouseFocus();

            if mouseFocus == WorldFrame then
                if CURRENT_TOAST.BGtext then    --WeeklyRewardToast's size is significantly larger than the black bar's
                    pause = IsObjectFocused(CURRENT_TOAST.BGtext, x, y);
                else
                    pause = IsObjectFocused(CURRENT_TOAST, x, y);
                end
            elseif self.hasTitleScript then
                if IsObjectFocused(CURRENT_TOAST.TitleTextMouseOverFrame, x, y) then
                    pause = true;
                end
            elseif self.hasSubtitleScript then
                if IsObjectFocused(CURRENT_TOAST.SubTitleMouseOverFrame, x, y) then
                    pause = true;
                end
            end

            if pause then
                BlizzardFrame:PauseAnimations();
            else
                BlizzardFrame:ResumeAnimations();
            end
        end
    end

    if self.totalTime > 10 then
        self.totalTime = 8;
        if self:GetActiveToast() == nil then
            self:Hide();
        end
    end
end


function Module:EnableModule()
    if not IsMethodAvailable() then return end;

    MODULE_ENABLED = true;
    BlizzardFrame:EnableMouse(false);
    BlizzardFrame.OnUpdate = nil;     --Let's pray this doesn't taint

    if not self.hooked then
        self.hooked = true;
        hooksecurefunc(BlizzardFrame, "SetupButton", EventToastManager_OnSetupButton);
        if TopBannerManager_Show then
            hooksecurefunc("TopBannerManager_Show", TopBannerManager_OnShowCallback)
        end
    end

    self:SetScript("OnShow", self.OnShow);
    self:SetScript("OnHide", self.OnHide);
    self:SetScript("OnEvent", self.OnEvent);
    self:SetScript("OnUpdate", self.OnUpdate);

    if BlizzardFrame:IsShown() then
        SetAllToastsInteractable(false);
    end
end

function Module:DisableModule()
    if MODULE_ENABLED then
        MODULE_ENABLED = false;
        BlizzardFrame:EnableMouse(DEFAULT_STATE);
        if Original_OnUpdate then
            BlizzardFrame.OnUpdate = Original_OnUpdate;
        end
        SetAllToastsInteractable(true);
        self:SetParent(UIParent);
        self:OnHide();
        self:SetScript("OnUpdate", nil);
    end
end




local function EnableModule(state)
    if state then
        Module:EnableModule();
    else
        Module:DisableModule();
    end
end

do
    local L = addon.L;

    local moduleData = {
        dbKey = "BlizzFixEventToast",
        name = L["ModuleName BlizzFixEventToast"],
        description = L["ModuleDescription BlizzFixEventToast"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 2,
    };

    addon.ControlCenter:AddModule(moduleData);
end


--[[

local DEBUG_TOAST_INFO = {
    title = "Great Vault Slot Upgraded",
    subtitle = "Subtitle",
};

local ShrinkObjects = {
    "Frame",
    "LockGleam",
    "Lock",
    "SlotFill",

    "Particle1",
    "Particle2",
    "Particle1B",

    "GVCircGlw",
    "GVBGGlw",
    "FrameGlw",
    "FrameGlw2",
    "FrameGleam",
    "LockHoleGlw",

    "WindFX1",
    "WindFX2",
}

function DebugWR()
    local f = WR;
    if not f then
        f = CreateFrame("Frame", "WR", BlizzardFrame, "EventToastManagerNormalTitleAndSubtitleTemplate");
    end
    f:SetPoint("TOP", BlizzardFrame, "TOP", 0, -2);
    f:StopAnimating();
    f:Show();
    --f:SetAlpha(1);
    BlizzardFrame:Show();
    BlizzardFrame:SetScript("OnUpdate", BlizzardFrame.OnUpdate);
    DEBUG_TOAST_INFO.subtitle = GetInventoryItemLink("player", 1);
    DEBUG_TOAST_INFO.title = string.upper(DEBUG_TOAST_INFO.title);
    
    CURRENT_TOAST = f;
    f.toastInfo = DEBUG_TOAST_INFO;
    for _, key in ipairs(ShrinkObjects) do
       -- f[key]:SetScale(0.5);
    end

    SetToastInteractable(f, false);
    f:Setup(DEBUG_TOAST_INFO);
    BlizzardFrame.currentDisplayingToast = f;
    BlizzardFrame:Layout();
end
--]]