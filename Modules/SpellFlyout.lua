local _, addon = ...
local API = addon.API;
local L = addon.L;

local InCombatLockdown = InCombatLockdown;


local FlyoutButtonMixin = {};
local SpellFlyout = CreateFrame("Frame", nil, UIParent);
addon.SpellFlyout = SpellFlyout;


do --SpellFlyout
    SpellFlyout:Hide();
    SpellFlyout:SetFrameStrata("FULLSCREEN");

    function SpellFlyout:Clear()
        self.flyoutID = nil;
        self.owner = nil;
        self.activeAction = nil;
        self.actions = nil;
        addon.HideSecureActionButton("SpellFlyout");
        self:Hide();
        self:ClearAllPoints();
        self:ReleaseButtons();
    end

    function SpellFlyout:SetArrowDirection(direction)
        self.FlyoutArrow:ClearAllPoints();
        if direction == "down" then
            self.FlyoutArrow:SetPoint("CENTER", self, "BOTTOMLEFT", 2 + 45/2, -1);
            self.FlyoutArrow:SetTexCoord(48/512, 96/512, 0, 48/512);
        elseif direction == "up" then
            self.FlyoutArrow:SetPoint("CENTER", self, "TOPLEFT", 2 + 45/2, 1);
            self.FlyoutArrow:SetTexCoord(0/512, 48/512, 0, 48/512);
        elseif direction == "right" then
            self.FlyoutArrow:SetPoint("CENTER", self, "RIGHT", 1, 0);
            self.FlyoutArrow:SetTexCoord(144/512, 192/512, 0, 48/512);
        elseif direction == "left" then
            self.FlyoutArrow:SetPoint("CENTER", self, "LEFT", -1, 0);
            self.FlyoutArrow:SetTexCoord(96/512, 144/512, 0, 48/512);
        end
    end

    function SpellFlyout:IsFocused()
        if self:IsVisible() then
            if self:IsMouseOver() or (self.owner and self.owner:IsMouseMotionFocus()) then
                return true
            end
        end
        return false
    end

    function SpellFlyout:OnEvent(event, ...)
        if event == "GLOBAL_MOUSE_DOWN" then
            if not self:IsFocused() then
                self:Hide();
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            if self:IsVisible() then
                self:DisplayNote(L["PlumberMacro Error Combat"], false);
            end
        elseif event == "PLAYER_REGEN_ENABLED" then
            if self:IsVisible() then
                self:SetActions(self.actions);
                self:OnShow();
            end
        elseif event == "ACTIONBAR_SLOT_CHANGED" then
            self:Hide();
        end
    end

    function SpellFlyout:OnShow()
        self:RegisterEvent("GLOBAL_MOUSE_DOWN");
        self:RegisterEvent("PLAYER_REGEN_DISABLED");
        self:RegisterEvent("PLAYER_REGEN_ENABLED");
        self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
        local ActionButton = addon.AcquireSecureActionButton("SpellFlyout");
        if ActionButton then
            ActionButton:SetParent(self);
            ActionButton:CoverParent();
            ActionButton:SetFrameLevel(self:GetFrameLevel() + 1);
            ActionButton:Show();
        end
        self.ActionButton = ActionButton;
    end

    function SpellFlyout:OnHide()
        self:Clear();
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
        self:UnregisterEvent("PLAYER_REGEN_DISABLED");
        self:UnregisterEvent("PLAYER_REGEN_ENABLED");
        self:UnregisterEvent("ACTIONBAR_SLOT_CHANGED");
    end

    function SpellFlyout:OnMouseDown(button)
        --if self.activeAction then
        --    print(button, self.activeAction)
        --end
    end

    function SpellFlyout:Init()
        self.Init = nil;
        local function CreateButton()
            local button = CreateFrame("Button", nil, self, "PlumberActionBarButtonTemplate");
            API.Mixin(button, FlyoutButtonMixin);
            button:OnLoad();
            return button
        end
        local function RemoveButton(button)
            button:Hide();
            button:ClearAllPoints();
            button:ClearAction();
        end
        self.buttonPool = API.CreateObjectPool(CreateButton, RemoveButton);

        local bg = addon.CreateNineSliceFrame(self, "NineSlice_GenericBox_Black");
        bg:SetUsingParentLevel(true);
        bg:SetAllPoints(true);

        self:EnableMouse(true);
        self:EnableMouseMotion(true);

        local file = "Interface/AddOns/Plumber/Art/Frame/SpellFlyout";

        self.FlyoutArrow = self:CreateTexture(nil, "OVERLAY");
        self.FlyoutArrow:SetTexture(file)
        self.FlyoutArrow:SetTexCoord(0, 48/512, 0, 48/512);
        self.FlyoutArrow:SetSize(24, 24);

        local Overlay = CreateFrame("Frame", nil, self);
        Overlay:Hide();
        self.Overlay = Overlay;
        Overlay.Background = Overlay:CreateTexture(nil, "ARTWORK");
        Overlay.Background:SetColorTexture(0, 0, 0, 0.8);
        Overlay.Background:SetAllPoints(true);
        Overlay:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2);
        Overlay:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2);
        Overlay:EnableMouse(true);
        Overlay:EnableMouseMotion(true);

        self.Note = Overlay:CreateFontString(nil, "OVERLAY", "GameFontRed");
        self.Note:SetPoint("CENTER", self, "CENTER", 0, 0);
        self.Note:SetJustifyH("CENTER");

        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);
        self:SetScript("OnEvent", self.OnEvent);
        self:SetScript("OnMouseDown", self.OnMouseDown);

        self:SetClampedToScreen(true);
        self:SetClampRectInsets(-4, 4, 4, -4);
    end

    function SpellFlyout:DisplayNote(text, updateSize)
        if updateSize then
            self.Note:SetWidth(0);
        else
            self.Note:SetWidth(math.max(self:GetWidth(), 45) - 8);
        end
        self.Note:SetText(text);

        if text then
            self.Overlay:Show();
            if updateSize then
                local width, height = self.Note:GetSize();
                self:SetSize(API.Round(width + 16), API.Round(height + 16));
            end
        else
            self.Overlay:Hide();
        end
    end

    function SpellFlyout:ReleaseButtons()
        if self.buttonPool then
            self.buttonPool:ReleaseAll();
        end
        if self.Note then
            self.Note:SetText(nil);
            self.Overlay:Hide();
        end
    end

    function SpellFlyout:SetActions(actions)
        self:ReleaseButtons();
        self.actions = actions;

        if self.Init then
            self:Init();
        end

        local baseFrameLevel = self:GetFrameLevel();
        self.Overlay:SetFrameLevel(baseFrameLevel + 10);

        if actions and #actions > 0 then
            local buttonSize = 45;
            local gap = 2;
            local h, v = 0, 1;
            local button;
            local level = baseFrameLevel + 5;

            for _, action in ipairs(actions) do
                button = self.buttonPool:Acquire();
                button:SetAction(action);
                button:SetPoint("LEFT", self, "LEFT", gap + h * (buttonSize + gap), 0);
                button:SetFrameLevel(level);
                h = h + 1;
            end

            self:SetSize(h * (buttonSize + gap) + gap, v * (buttonSize + gap) + gap);
            if InCombatLockdown() then
                self:DisplayNote(L["PlumberMacro Error Combat"], false);
            end
        else
            self:DisplayNote(L["PlumberMacro Error NoAction"], true);
        end
    end

    function SpellFlyout:SetOwner(owner)
        --owner is ActionBarButton
        self.owner = owner;
    end

    function SpellFlyout:SetMacroText(macroText)
        if self.ActionButton then
            if macroText then
                self.ActionButton:SetAttribute("type1", "macro");
                self.ActionButton:SetMacroText(macroText);
            else
                self.ActionButton:ClearActions();
            end
        end
    end
end


do  --FlyoutButtonMixin
    function FlyoutButtonMixin:OnLoad()
        self.NormalTexture:SetDrawLayer("OVERLAY");
        self.PushedTexture:SetDrawLayer("OVERLAY");

        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
    end

    function FlyoutButtonMixin:SetAction(action)
        self.id = action.id;
        self.Icon:SetTexture(action.icon);
        self.actionType = action.actionType;
        self.macroText = action.macroText;
        if self.actionType == "spell" then
            self.tooltipMethod = "SetSpellByID";
        elseif self.actionType == "item" then
            if API.IsToyItem(self.id) then
                self.tooltipMethod = "SetToyByItemID";
            else
                self.tooltipMethod = "SetItemByID";
            end
        end
    end

    function FlyoutButtonMixin:OnEnter()
        self:ShowTooltip();
        SpellFlyout:SetMacroText(self.macroText);
    end

    function FlyoutButtonMixin:OnLeave()
        GameTooltip:Hide();
        SpellFlyout:SetMacroText(nil);
    end

    function FlyoutButtonMixin:ShowTooltip()
        if self.tooltipMethod then
            local tooltip = GameTooltip;
            tooltip:SetOwner(self, "ANCHOR_RIGHT");
            tooltip[self.tooltipMethod](tooltip, self.id);
            tooltip:Show();
            self.UpdateTooltip = self.ShowTooltip;
        else
            self.UpdateTooltip = nil;
        end
    end

    function FlyoutButtonMixin:ClearAction()
        self.Icon:SetTexture(nil);
        self.id = nil;
        self.actionType = nil;
        self.tooltipMethod = nil;
        self.macroText = nil;
    end
end
