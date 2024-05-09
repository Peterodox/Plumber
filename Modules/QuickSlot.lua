local _, addon = ...
local API = addon.API;
local UIFrameFade = API.UIFrameFade;


local ACTION_BUTTON_SIZE = 46;
local ACTION_BUTTON_GAP = 4;


local UnitCastingInfo = UnitCastingInfo;
local UnitChannelInfo = UnitChannelInfo;
local InCombatLockdown = InCombatLockdown;
local GetCursorPosition = GetCursorPosition;
local math = math;
local UIParent = UIParent;
local CreateFrame = CreateFrame;
local tinsert = table.insert;


local QuickSlot = CreateFrame("Frame", nil, UIParent);
addon.QuickSlot = QuickSlot;
QuickSlot:Hide();
QuickSlot:SetSize(8, 8);
QuickSlot:SetAlpha(0);
QuickSlot:SetFrameStrata("MEDIUM");
QuickSlot.Buttons = {};
QuickSlot.numActiveButtons = 0;
QuickSlot.SpellXButton = {};

local ContextMenu;

local function ContextMenu_EditMode_OnClick(self, button)
    QuickSlot:EnableEditMode(true);
    return true
end

local ContextMenuData = {
    { text = _G["HUD_EDIT_MODE_MENU"] or "Edit Mode", onClickFunc = ContextMenu_EditMode_OnClick},
};


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

    for i = 0, 1 do
        snappedRadian = self:GetButtonRadianByIndex(i);
        if radian < snappedRadian + 0.043 and radian > snappedRadian - 0.043 then
            radian = snappedRadian;
        end
    end

    self.fromRadian = radian;

    if PlumberDB then
        PlumberDB.quickslotFromRadian = radian;
    end
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
        QuickSlot:SetHeaderText();
        QuickSlot:StartShowingDefaultHeaderCountdown(true);
    end
end

local function RealActionButton_PostClick(self, button)
    local owner = self.owner;

    if owner then
        if button == "LeftButton" and owner:HasCharges() then
            owner:ShowPostClickEffect();
            return
        end

        if button == "RightButton" then
            if not ContextMenu then
                ContextMenu = addon.GetSharedContextMenu();
            end
            local menu = ContextMenu;
            if menu:IsShown() then
                menu:CloseMenu();
                return
            end
            menu:SetOwner(owner);
            menu:ClearAllPoints();
            menu:SetPoint("LEFT", owner, "RIGHT", 12, 0);
            menu:SetContent(ContextMenuData);
            menu:Show();
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
    QuickSlot:SetHeaderText(API.GetColorizedItemName(self.id));
    QuickSlot:StartShowingDefaultHeaderCountdown(false);

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

        local macroText = string.format("/use item:%s", self.id);
        RealActionButton:SetAttribute("type1", "macro");     --Any Mouseclick
        RealActionButton:SetMacroText(macroText);
        RealActionButton:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp");

        self:LockHighlight();
        self.hasActionButton = true;
    end
end

local function ItemButton_OnLeave(self)
    if not (self:IsVisible() and self:IsMouseOver()) then
        QuickSlot:SetHeaderText();
        QuickSlot:StartShowingDefaultHeaderCountdown(true);
    end
end




function QuickSlot:Init()
    if PlumberDB and PlumberDB.quickslotFromRadian then
        Positioner:SetFromRadian(PlumberDB.quickslotFromRadian);
    end

    self.side = 1;

    local Header = self:CreateFontString(nil, "OVERLAY", "GameTooltipText");
    self.Header = Header;
    Header:SetJustifyH("CENTER");
    Header:SetJustifyV("MIDDLE");
    Header:SetPoint("BOTTOM", self, "TOP", 0, 8);
    Header:SetSpacing(2);

    local font, height = GameTooltipText:GetFont();
    Header:SetFont(font, height, "");   --OUTLINE
    Header:SetShadowColor(0, 0, 0);
    Header:SetShadowOffset(1, -1);

    local HeaderShadow = self:CreateTexture(nil, "ARTWORK");
    HeaderShadow:SetPoint("TOPLEFT", Header, "TOPLEFT", -8, 6);
    HeaderShadow:SetPoint("BOTTOMRIGHT", Header, "BOTTOMRIGHT", 8, -8);
    HeaderShadow:SetTexture("Interface/AddOns/Plumber/Art/Button/GenericTextDropShadow");
    HeaderShadow:Hide();
    HeaderShadow:SetAlpha(0);

    function QuickSlot:SetHeaderText(text, transparentText)
        if self:IsInEditMode() then return end;

        if text then
            Header:SetSize(0, 0);
            Header:SetText(text);
            if transparentText then
                local toAlpha = 0.6;
                UIFrameFade(Header, 0.5, toAlpha);
                UIFrameFade(HeaderShadow, 0.25, 0);
            else
                API.UIFrameFadeIn(Header, 0.25);
                UIFrameFade(HeaderShadow, 0.25, 1);
            end

            local textWidth = Header:GetWrappedWidth() - 2;
            if textWidth > QuickSlot.headerMaxWidth then
                Header:SetSize(QuickSlot.headerMaxWidth, 64);
                local numLines = Header:GetNumLines();
                Header:SetHeight(numLines*18);
                textWidth = Header:GetWrappedWidth();
                Header:SetWidth(textWidth + 2);
            end
        else
            UIFrameFade(Header, 0.5, 0);
            UIFrameFade(HeaderShadow, 0.25, 0);
        end
    end

    self.SpellCastOverlay = addon.CreateActionButtonSpellCastOverlay(self);
    self.SpellCastOverlay:Hide();

    self.Init = nil;
end

local function ContainerFrame_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 1 then
        self:SetScript("OnUpdate", nil);
        self:SetHeaderText(self.defaultHeaderText, true);
    end
end

function QuickSlot:SetDefaultHeaderText(text)
    self.defaultHeaderText = text;
end

function QuickSlot:StartShowingDefaultHeaderCountdown(state)
    if state and not self:IsInEditMode() then
        self.t = 0;
        self:SetScript("OnUpdate", ContainerFrame_OnUpdate);
    else
        self:SetScript("OnUpdate", nil);
    end
end

function QuickSlot:SetButtonData(itemData, spellData, systemName, isCasting)
    if itemData == self.itemData then
        return
    end

    self.itemData = itemData;
    self.spellData = spellData;
    self.systemName = systemName;
    self.layoutDirty = true;
    self.numActiveButtons = #itemData;
    self.spellcastType = (isCasting and 1) or 2;

    local buttonSize = ACTION_BUTTON_SIZE;
    local gap = ACTION_BUTTON_GAP;
    local positionIndex = 0;
    local trackIndex = 0;

    for i, itemID in ipairs(itemData) do
        positionIndex = positionIndex + 1;
        if itemID == 0 then
            --Used as a spacer

        elseif itemID == -1 then
            --reset radian, reduce radius
            positionIndex = 0;
            trackIndex = trackIndex + 1;
        else
            local button = self.Buttons[i];
            if not button then
                button = addon.CreatePeudoActionButton(self);
                tinsert(self.Buttons, button);
                button:SetPoint("LEFT", self, "LEFT", (i - 1) * (buttonSize +  gap), 0);
            end
            local spellID = spellData and spellData[i] or nil;
            if spellID then
                self.SpellXButton[spellID] = button;
            end
            button:SetItem(itemID);
            button.spellID = spellID;
            button.positionIndex = positionIndex;
            button.trackIndex = trackIndex;
            button:SetScript("OnEnter", ItemButton_OnEnter);
            button:SetScript("OnLeave", ItemButton_OnLeave);
            button:Show();
        end
    end

    for i = self.numActiveButtons + 1, #self.Buttons do
        self.Buttons[i]:Hide();
    end
end

function QuickSlot:SetButtonOrder(side)
    if side ~= self.side then
        self.side = side;
    else
        return
    end

    if not self.itemData then
        return
    end

    local items = self.itemData;
    local spells = self.spellData;

    if side > 0 then
        --right side of the screen
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

function QuickSlot:SetFrameLayout(layoutIndex)
    local buttonSize = Positioner.buttonSize;
    local buttonGap = Positioner.buttonGap;

    if layoutIndex == 1 then
        --Normal, below the center
        --CastingBar's position is changed conditionally

        local anchorTo = Positioner:GetCastBar();
        local y = anchorTo:GetTop();
        local scale = anchorTo:GetScale();

        self:ClearAllPoints();
        self:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 250); --(y + 30)*scale   --Default CastingBar moves up 29y when start casting

        for i, button in ipairs(self.Buttons) do
            button:ClearAllPoints();
            button:SetPoint("LEFT", self, "LEFT", (i - 1) * (buttonSize +  buttonGap), 0);
        end

        self.Header:ClearAllPoints();
        self.Header:SetPoint("BOTTOM", self, "TOP", 0, 8);
        self.headerMaxWidth = 0;
    else
        --Circular, on the right side
        local radius = math.floor( (0.5 * UIParent:GetHeight()*16/9 /3) + (buttonSize*0.5) + 0.5);
        local track0Radius = radius;
        local gapArc = buttonGap + buttonSize;
        local fromRadian = Positioner:GetFromRadian();
        local radianGap = gapArc/radius;
        local radian;
        local x, y;
        local cx, cy = UIParent:GetCenter();

        local cos = math.cos;
        local sin = math.sin;

        local trackIndex = 0;

        for i, button in ipairs(self.Buttons) do
            button:ClearAllPoints();

            if trackIndex ~= button.trackIndex then
                trackIndex = button.trackIndex;
                radius = track0Radius - trackIndex * gapArc;
                radianGap = gapArc/radius;
            end

            radian = fromRadian + (1 - button.positionIndex or i)*radianGap;
            x = cx + radius * cos(radian);
            y = cy + radius * sin(radian);
            button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);

            if i == 2 then
                Positioner:SetCircleMaskPosition(x, y);
            end
        end

        local headerRadiusOffset = 112;  --Positive value moves towards center
        local headerMaxWidth = 2*(headerRadiusOffset - buttonSize*0.5) - 8;
        radian = fromRadian - (self.numActiveButtons - 1)*radianGap*0.5;
        x = cx + (radius - headerRadiusOffset) * cos(radian);
        y = cy + (radius - headerRadiusOffset) * sin(radian);

        self.headerMaxWidth = headerMaxWidth;
        self.Header:ClearAllPoints();
        self.Header:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);

        if self.RepositionButton then
            --Adjust Radian:
            radian = Positioner:GetEditButtonRadian();
            self.RepositionButton:ClearAllPoints();
            self.RepositionButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx + radius * cos(radian), cy + radius * sin(radian));
            --self.RepositionButton:SetRotation(radian);

            --Adjust Radius:
            --[[
            radian = fromRadian;
            radius = radius + buttonSize;
            self.RepositionButton:ClearAllPoints();
            self.RepositionButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx + radius * cos(radian), cy + radius * sin(radian));
            self.RepositionButton:SetRotation(radian);
            --]]
        end
    end
end

function QuickSlot:SetInteractable(state, dueToCombat)
    if state then
        UIFrameFade(self, 0.5, 1);
    else
        if dueToCombat then
            if self:IsShown() and not self:IsInEditMode() then
                local toAlpha = 0.25;
                UIFrameFade(self, 0.2, toAlpha);
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

function QuickSlot:UpdateItemCount()
    for i, button in ipairs(self.Buttons) do
        button:UpdateCount();
    end
end

function QuickSlot:OnSpellCastChanged(spellID, isStartCasting)
    local targetButton = self.SpellXButton[spellID];

    if self.lastSpellTargetButton then
        self.lastSpellTargetButton.Count:Show();
    end
    self.lastSpellTargetButton = targetButton;

    if targetButton then
        if isStartCasting then
            self.isPlayerMoving = false;
            self.isChanneling = true;
            for i, button in ipairs(self.Buttons) do
                if button.spellID == spellID then
                    local _, _, _, startTime, endTime = UnitChannelInfo("player");
                    if not _ then
                        _, _, _, startTime, endTime = UnitCastingInfo("player");
                    end

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
            self.lastSpellTargetButton = nil;
            self.SpellCastOverlay:FadeOut();
        end
    end
end

function QuickSlot:OnShow()

end

function QuickSlot:OnHide()
    self:EnableEditMode(false);
end
QuickSlot:SetScript("OnHide", QuickSlot.OnHide);


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
            QuickSlot:SetFrameLayout(2);
            --[[
            if radian > -1.57 and radian < 1.57 then
                QuickSlot:SetButtonOrder(1);
            else
                QuickSlot:SetButtonOrder(-1);
            end
            --]]
        end
    end
end

local function RepositionButton_OnMouseDown(self, button)
    if button == "RightButton" then
        Positioner:SetFromRadian(0);
        QuickSlot:SetFrameLayout(2);
        return
    end
    self.t = 0;
    self.cx, self.cy = UIParent:GetCenter();
    self.uiRatio = 1/ UIParent:GetEffectiveScale();
    self.radian = GetCursorRadianToPoint(self.cx, self.cy, self.uiRatio);
    self.selfRadian = Positioner:GetEditButtonRadian();
    self.frameRadian = Positioner:GetFromRadian();
    self:SetScript("OnUpdate", RepositionButton_OnUpdate);
    QuickSlot:SetInteractable(false);
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

    QuickSlot:SetFrameLayout(2);
end

local function RepositionButton_SetRotation(self, radian)
    self.Icon:SetRotation(radian);
    self.Highlight:SetRotation(radian);
end

function QuickSlot:IsInEditMode()
    return self.isEditing == true
end

local function SetControlNodeAnimation(obj)
    local ag = obj:CreateAnimationGroup();
    obj.AnimIn = ag;

    local s1 = ag:CreateAnimation("Scale");
    s1:SetOrder(1);
    s1:SetDuration(0);
    s1:SetScale(0.25, 0.25);

    local s2 = ag:CreateAnimation("Scale");
    s2:SetOrder(2);
    s2:SetDuration(0.3);
    s2:SetScale(6, 6);
    s2:SetSmoothing("IN_OUT");

    local s3 = ag:CreateAnimation("Scale");
    s3:SetOrder(3);
    s3:SetDuration(0.4);
    s3:SetScale(0.67, 0.67);
    s3:SetSmoothing("OUT");
end

function QuickSlot:EnableEditMode(state)
    if state then
        if not self.RepositionButton then
            local b = CreateFrame("Button", nil, self);
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

            b.SetRotation = RepositionButton_SetRotation;
            --b:SetScript("OnClick", RepositionButton_OnClick);
            b:SetScript("OnMouseDown", RepositionButton_OnMouseDown);
            b:SetScript("OnMouseUp", RepositionButton_OnMouseUp);

            SetControlNodeAnimation(b);
        end

        if not self.EditModeConfirmButton then
            local b = CreateFrame("Button", nil, self);
            b:SetSize(30, 30);
            self.EditModeConfirmButton = b;
            b:SetFrameStrata("DIALOG");
            b:SetFixedFrameStrata(true);

            local tex = "Interface/AddOns/Plumber/Art/Button/EditMode-Confirm";

            b.Icon = b:CreateTexture(nil, "ARTWORK");
            b.Icon:SetSize(32, 32);
            b.Icon:SetPoint("CENTER", b, "CENTER", 0, 0);
            b.Icon:SetTexture(tex);
            API.DisableSharpening(b.Icon);

            b.Highlight = b:CreateTexture(nil, "HIGHLIGHT");
            b.Highlight:SetSize(32, 32);
            b.Highlight:SetPoint("CENTER", b, "CENTER", 0, 0);
            b.Highlight:SetTexture(tex.."-Highlight");
            API.DisableSharpening(b.Highlight);

            b:SetPoint("CENTER", self.Header, "CENTER", 0, 0);
            b:SetScript("OnClick", function()
                self:EnableEditMode(false);
            end);
        end

        if not self.isEditing then
            self.RepositionButton:Show();
            self.EditModeConfirmButton:Show();
            self.RepositionButton.AnimIn:Play();
            UIFrameFade(self.EditModeConfirmButton, 0.25, 1, 0);
            self:SetInteractable(false);
            self:SetHeaderText();   --HUD_EDIT_MODE_MENU
            self:StartShowingDefaultHeaderCountdown(false);
            for i, button in ipairs(self.Buttons) do
                button.Count:Hide();
            end
            self.isEditing = true;
            self:SetFrameLayout(2);
        end
    else
        if self.isEditing then
            self.isEditing = nil;
            self.RepositionButton:Hide();
            self.RepositionButton:SetScript("OnUpdate", nil);
            self.EditModeConfirmButton:Hide();
            Positioner:HideGuideLine();
            for i, button in ipairs(self.Buttons) do
                if button ~= self.lastSpellTargetButton then
                    button.Count:Show();
                end
            end
            if not InCombatLockdown() then
                self:SetInteractable(true);
            end

            if self.closeUIAfterEditing then
                self.closeUIAfterEditing = nil;
                self:CloseUI();
            end
        else
            return
        end
    end
end

function QuickSlot:ShowUI()
    if self.Init then
        self:Init();
    end

    if self.layoutDirty then
        self.layoutDirty = nil;
        self:SetFrameLayout(2);
    end

    self:RegisterEvent("BAG_UPDATE");
    self:RegisterEvent("PLAYER_REGEN_DISABLED");
    self:RegisterEvent("PLAYER_REGEN_ENABLED");
    self:RegisterEvent("UI_SCALE_CHANGED");

    if self.spellcastType == 1 then
        self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
        self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player");
    else
        self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
        self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
        self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "player");
    end

    self:UpdateItemCount();

    for _, button in ipairs(self.Buttons) do
        button.Count:Show();
    end

    self.closeUIAfterEditing = nil;
    self.isChanneling = nil;
    self.lastSpellTargetButton = nil;
    self:Show();

    if InCombatLockdown() then
        self:SetInteractable(false, true);
    else
        self:SetInteractable(true);
    end

    return true
end

function QuickSlot:CloseUI()
    if self:IsShown() then
        self:EnableEditMode(false);
        UIFrameFade(self, 0.5, 0);
        self:UnregisterEvent("BAG_UPDATE");
        self:UnregisterEvent("PLAYER_REGEN_DISABLED");
        self:UnregisterEvent("PLAYER_REGEN_ENABLED");
        self:UnregisterEvent("UI_SCALE_CHANGED");
        self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
        self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
        self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
        self:UnregisterEvent("UNIT_SPELLCAST_START");
        self:UnregisterEvent("UNIT_SPELLCAST_STOP");
        self:SetInteractable(false);
        self.isChanneling = nil;
        self.defaultHeaderText = nil;
        self.SpellCastOverlay:Hide();
    end
end

function QuickSlot:RequestCloseUI(systemName)
    if self:IsInEditMode() then
        self.closeUIAfterEditing = true;
    else
        if (not systemName) or (systemName and systemName == self.systemName) then
            self:CloseUI();
        end
    end
end


function QuickSlot:OnEvent(event, ...)
    if event == "BAG_UPDATE" then
        self:UpdateItemCount();
    elseif event == "PLAYER_REGEN_DISABLED" then
        self:SetInteractable(false, true);
    elseif event == "PLAYER_REGEN_ENABLED" then
        if not self.isEditing then
            self:SetInteractable(true);
        end
    elseif event == "UI_SCALE_CHANGED" then
        self:SetFrameLayout(2);
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_START" then
        local _, _, spellID = ...
        QuickSlot:OnSpellCastChanged(spellID, true);
    elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then

    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_STOP" then
        local _, _, spellID = ...
        self:OnSpellCastChanged(spellID, false);
    end
end
QuickSlot:SetScript("OnEvent", QuickSlot.OnEvent);