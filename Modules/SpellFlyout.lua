--Unused

local _, addon = ...
local API = addon.API;
local L = addon.L;

local tinsert = table.insert;
local InCombatLockdown = InCombatLockdown;
local IsPlayerSpell = IsPlayerSpell;
local CreateFrame = CreateFrame;
local UIParent = UIParent;

local FlyoutButtonMixin = {};
local SpellFlyout = CreateFrame("Frame", nil, UIParent);
addon.SpellFlyout = SpellFlyout;
SpellFlyout.UpdateSpellCooldowns = addon.QuickSlot.UpdateSpellCooldowns;
SpellFlyout.UpdateItemCooldowns = addon.QuickSlot.UpdateItemCooldowns;


local function SetupClampedFrame(frame)
    local offset = 4;
    frame:SetClampedToScreen(true);
    frame:SetClampRectInsets(-offset, offset, offset, -offset);
end

do --SpellFlyout Main
    SpellFlyout:Hide();
    SpellFlyout:SetFrameStrata("FULLSCREEN");

    function SpellFlyout:Clear()
        self.flyoutID = nil;
        self.owner = nil;
        self.activeAction = nil;
        self.actions = nil;
        self.SpellButtons = nil;
        self.ItemButtons = nil;
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
            self.ActionButton = nil;
            if self:IsVisible() then
                self:DisplayNote(L["PlumberMacro Error Combat"], false);
            end
        elseif event == "PLAYER_REGEN_ENABLED" then
            if self:IsVisible() then
                self:OnShow();
                self:SetActions(self.actions);
            end
        elseif event == "ACTIONBAR_SLOT_CHANGED" then
            self:Hide();
        elseif event == "SPELL_UPDATE_COOLDOWN" then
            self:UpdateSpellCooldowns();
        elseif event == "BAG_UPDATE_COOLDOWN" then
            self:UpdateItemCooldowns();
        elseif event == "PLAYER_ENTERING_WORLD" then
            self:UnregisterEvent(event);
            self:UpdateCompatibleAddOns();
        end
    end
    SpellFlyout:SetScript("OnEvent", SpellFlyout.OnEvent);

    function SpellFlyout:OnShow()
        self:RegisterEvent("GLOBAL_MOUSE_DOWN");
        self:RegisterEvent("PLAYER_REGEN_DISABLED");
        self:RegisterEvent("PLAYER_REGEN_ENABLED");
        self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
        self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
        self:RegisterEvent("BAG_UPDATE_COOLDOWN");
        local ActionButton = addon.AcquireSecureActionButton("SpellFlyout");
        if ActionButton then
            ActionButton:SetParent(self);
        end
        self.ActionButton = ActionButton;
    end

    function SpellFlyout:OnHide()
        self:Clear();
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
        self:UnregisterEvent("PLAYER_REGEN_DISABLED");
        self:UnregisterEvent("PLAYER_REGEN_ENABLED");
        self:UnregisterEvent("ACTIONBAR_SLOT_CHANGED");
        self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
        self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
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
        self.buttonPool = API.CreateObjectPool(CreateButton);

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

        SetupClampedFrame(self);
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
        self.SpellButtons = {};
        self.ItemButtons = {};

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
            local anySpell, anyItem;

            for _, action in ipairs(actions) do
                button = self.buttonPool:Acquire();
                button:SetAction(action);
                button:SetPoint("LEFT", self, "LEFT", gap + h * (buttonSize + gap), 0);
                button:SetFrameLevel(level);
                h = h + 1;
                if action.actionType == "spell" then
                    anySpell = true;
                    tinsert(self.SpellButtons, button);
                elseif action.actionType == "item" then
                    anyItem = true;
                    tinsert(self.ItemButtons, button);
                end
            end

            self:SetSize(h * (buttonSize + gap) + gap, v * (buttonSize + gap) + gap);

            if InCombatLockdown() then
                self:DisplayNote(L["PlumberMacro Error Combat"], false);
            end
            
            if anySpell then
                self:UpdateSpellCooldowns();
            end
            if anyItem then
                self:UpdateItemCooldowns();
            end
        else
            self:DisplayNote(L["PlumberMacro Error NoAction"], true);
        end
    end

    function SpellFlyout:SetOwner(owner)
        --owner is ActionBarButton
        self.owner = owner;
    end

    function SpellFlyout:SetMacroText(flyoutButton, macroText)
        if self.ActionButton then
            if flyoutButton and macroText then
                self.ActionButton:SetAttribute("type", "macro");
                self.ActionButton:SetMacroText(macroText);
                self.ActionButton:SetFrameLevel(flyoutButton:GetFrameLevel() + 1);
                self.ActionButton:SetPropagateMouseClicks(true);
                self.ActionButton:SetPropagateMouseMotion(true);
                self.ActionButton:CoverObject(flyoutButton, 1);
                self.ActionButton:Show();
            else
                self.ActionButton:ClearActions();
            end
        end
    end
end


do  --Action Bar Addon Supports
    local ActionGetter = {};

    local DirectionGetter = {};
    DirectionGetter.methodsToTry = {};

    local ScaleGetter = {};
    ScaleGetter.methodsToTry = {};


    function SpellFlyout:UpdateCompatibleAddOns()
        local addons = {
            --LibActionButton-1.0
            "ElvUI", "NDui",
        };

        local anySupported;
        local IsAddOnLoaded = C_AddOns.IsAddOnLoaded;
        for _, addonName in ipairs(addons) do
            if IsAddOnLoaded(addonName) then
                anySupported = true;
                tinsert(DirectionGetter.methodsToTry, DirectionGetter[addonName]);
            end
        end

        if anySupported then
            SpellFlyout.GetFlyoutDirectionFromMouseFocus = DirectionGetter.Hybrid;
        end
    end
    SpellFlyout:RegisterEvent("PLAYER_ENTERING_WORLD");


    -- ActionGetter
    function ActionGetter.Blizzard(focus)
        if focus.action and type(focus.action) == "number" then
            return focus.action
        end
    end

    function ActionGetter.LibActionButton(focus)
        local action = ActionGetter.Blizzard(focus);
        if action and action ~= 0 then
            return action
        end
        if focus._state_type == "action" and type(focus._state_action) == "number" then
            return focus._state_action;
        end
    end
    SpellFlyout.GetActionFromMouseFocus = ActionGetter.LibActionButton;


    -- DirectionGetter
    function DirectionGetter.Blizzard(focus)
        return focus.bar and focus.bar.flyoutDirection or "UP"
    end
    SpellFlyout.GetFlyoutDirectionFromMouseFocus = DirectionGetter.Blizzard;

    function DirectionGetter.Hybrid(focus)
        if focus.bar and focus.bar.flyoutDirection then
            return focus.bar and focus.bar.flyoutDirection
        end
        for _, method in ipairs(DirectionGetter.methodsToTry) do
            local direction = method(focus);
            if direction then
                return direction
            end
        end
    end

    function DirectionGetter.ElvUI(focus)
        local bar = focus:GetParent();
        local direction = (bar.db and bar.db.flyoutDirection) or "AUTOMATIC";
        if direction == "AUTOMATIC" then
            local E = unpack(ElvUI);
            local point = E:GetScreenQuadrant(bar);
            if point == "RIGHT" then
                return "LEFT"
            elseif point == "LEFT" then
                return "RIGHT"
            elseif point == "BOTTOM" then
                return "UP"
            elseif point == "TOP" then
                return "DOWN"
            end
        end
    end


    -- ScaleGetter
    function ScaleGetter.Blizzard(focus)
        return focus:GetParent():GetScale()
    end
    SpellFlyout.GetFlyoutScaleFromMouseFocus = ScaleGetter.Blizzard;
end


do  --FlyoutButtonMixin
    function FlyoutButtonMixin:OnLoad()
        local file = "Interface/AddOns/Plumber/Art/Frame/SpellFlyout";

        self.NormalTexture:SetTexture(file);
        self.NormalTexture:SetTexCoord(0/512, 96/512, 48/512, 144/512);
        self.PushedTexture:SetTexture(file);
        self.PushedTexture:SetTexCoord(96/512, 192/512, 48/512, 144/512);
        self.HighlightTexture:SetTexture(file);
        self.HighlightTexture:SetTexCoord(192/512, 288/512, 48/512, 144/512);

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
        self.text = action.text;

        if self.actionType == "spell" then
            self.tooltipMethod = "SetSpellByID";
            if not IsPlayerSpell(self.id) then
                self:SetUsableVisual(false);
            end
        elseif self.actionType == "item" then
            if API.IsToyItem(self.id) then
                self.tooltipMethod = "SetToyByItemID";
            else
                self.tooltipMethod = "SetItemByID";
            end
        elseif self[action.actionType] then
            self[action.actionType](self, action.id);
        end
    end

    function FlyoutButtonMixin:SetUsableVisual(state)
        if state then
            self.Icon:SetVertexColor(1, 1, 1);
            self.Icon:SetDesaturated(false);
        else
            self.Icon:SetVertexColor(0.8, 0.8, 0.8);
            self.Icon:SetDesaturated(true);
        end
    end

    function FlyoutButtonMixin:OnEnter()
        self:ShowTooltip();
        SpellFlyout:SetMacroText(self, self.macroText);
    end

    function FlyoutButtonMixin:OnLeave()
        GameTooltip:Hide();
        SpellFlyout:SetMacroText(nil);
        self:SetButtonState("NORMAL");
    end

    function FlyoutButtonMixin:ShowTooltip()
        if self.tooltipMethod then
            local tooltip = GameTooltip;
            tooltip:SetOwner(self, "ANCHOR_RIGHT");
            tooltip[self.tooltipMethod](tooltip, self.id);
            tooltip:Show();
            self.UpdateTooltip = self.ShowTooltip;
        elseif self.tooltipText then
            local tooltip = GameTooltip;
            tooltip:SetOwner(self, "ANCHOR_RIGHT");
            tooltip:SetText(self.tooltipText, 1, 1, 1, true);
            tooltip:Show();
            self.UpdateTooltip = nil;
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
        self.text = nil;
        self.tooltipText = nil;
        self.Cooldown:Clear();
        self.Cooldown:Hide();
        self:SetUsableVisual(true);
    end

    function FlyoutButtonMixin:OnRemoved()
        self:ClearAction();
    end


    --Default Actions
    function FlyoutButtonMixin:SetRandomFavoritePet()
        self.tooltipMethod = "SetSpellByID";
        self.id = 243819;
        self.Icon:SetTexture(C_Spell.GetSpellTexture(self.id));
    end

    function FlyoutButtonMixin:SetRandomPet()
        self.tooltipText = SUMMON_RANDOM_PET;
        self.Icon:SetTexture(613074);
    end

    function FlyoutButtonMixin:SetDismissPet()
        self.tooltipText = L["Dismiss Battle Pet"];
        self.Icon:SetTexture(653220);
    end

    function FlyoutButtonMixin:SetSummonPet(petNameOrGUID)
        local speciesID, petGUID = C_PetJournal.FindPetIDByName(petNameOrGUID);
        if petGUID then
            self.tooltipMethod = "SetCompanionPet";
            self.id = petGUID;
            local icon = select(9, C_PetJournal.GetPetInfoByPetID(petGUID));
            self.Icon:SetTexture(icon);
        elseif speciesID then   --Summoning not owned pet causes errors
            local speciesName, icon = C_PetJournal.GetPetInfoBySpeciesID(speciesID);
            self.tooltipText = speciesName;
            self.Icon:SetTexture(icon);
            self:SetUsableVisual(false);
            self.macroText = nil;
        end
    end

    function FlyoutButtonMixin:SetCustomEmote(customEmote)
        self.tooltipText = (EMOTE or "Emote")..": "..customEmote;
    end
end