local _, addon = ...
local API = addon.API;
local L = addon.L;

local tinsert = table.insert;
local InCombatLockdown = InCombatLockdown;
local IsPlayerSpell = IsPlayerSpell;
local CreateFrame = CreateFrame;
local GetCVarBool = C_CVar.GetCVarBool;
local GetItemCount = C_Item.GetItemCount;
local find = string.find;
local gsub = string.gsub;
local UIParent = UIParent;

local ActionButtonPool = {};
local VisualButtonMixin = {};

local SpellFlyout = CreateFrame("Frame", nil, UIParent);
addon.SecureSpellFlyout = SpellFlyout;
SpellFlyout.UpdateSpellCooldowns = addon.QuickSlot.UpdateSpellCooldowns;
SpellFlyout.UpdateItemCooldowns = addon.QuickSlot.UpdateItemCooldowns;


local function SetupClampedFrame(frame)
    local offset = 8;
    frame:SetClampedToScreen(true);
    frame:SetClampRectInsets(-offset, offset, offset, -offset);
end


--Flyout Cursor OffsetX = 24.0
--Flyout Cursor OffsetY = 26.0



do --SpellFlyout Main
    SpellFlyout:Hide();
    SpellFlyout:SetFrameStrata("FULLSCREEN_DIALOG");

    function SpellFlyout:Clear()
        self:Hide();
        self:ClearAllPoints();
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
        if event == "SPELL_UPDATE_COOLDOWN" then
            self:UpdateSpellCooldowns();
        elseif event == "BAG_UPDATE_COOLDOWN" then
            self:UpdateItemCooldowns();
        elseif event == "BAG_UPDATE_DELAYED" then
            self:UpdateItemCount();
        end
    end
    SpellFlyout:SetScript("OnEvent", SpellFlyout.OnEvent);

    function SpellFlyout:OnShow()
        self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
        self:RegisterEvent("BAG_UPDATE_COOLDOWN");
        self:RegisterEvent("BAG_UPDATE_DELAYED");
    end

    function SpellFlyout:OnHide()
        self:Clear();
        self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
        self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
        self:UnregisterEvent("BAG_UPDATE_DELAYED");
    end

    function SpellFlyout:OnMouseDown(button)

    end

    function SpellFlyout:Init()
        self.Init = nil;

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
        self.FlyoutArrow:Hide();

        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);
        self:SetScript("OnEvent", self.OnEvent);
        self:SetScript("OnMouseDown", self.OnMouseDown);

        SetupClampedFrame(self);
    end

    function SpellFlyout:ShowActions(actions)
        self.actions = actions;
        self.SpellButtons = {};
        self.ItemButtons = {};

        if self.Init then
            self:Init();
        end

        if actions and #actions > 0 then
            local buttonSize = 45;
            local gap = 2;
            local h, v = 0, 1;
            local level = 9;
            local action;
            local anySpell, anyItem;

            for index, button in ipairs(ActionButtonPool.visualButtons) do
                button:ClearAction();
                action = actions[index];
                if action then
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
            end

            self:SetSize(h * (buttonSize + gap) + gap, v * (buttonSize + gap) + gap);

            local x, y = API.GetScaledCursorPosition();
            self:ClearAllPoints();
            self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x - 24.0, y + 26.0);
            self:SetFrameStrata("FULLSCREEN_DIALOG");
            self:SetFrameLevel(7);
            self:EnableMouse(true);
            self:Show();

            if anySpell then
                self:UpdateSpellCooldowns();
            end
            if anyItem then
                self:UpdateItemCooldowns();
                self:UpdateItemCount();
            end
        else

        end
    end

    function SpellFlyout:SetOwner(owner)
        --owner is ActionBarButton
        self.owner = owner;
    end

    function SpellFlyout:UpdateItemCount()
        if self.ItemButtons then
            for i, button in ipairs(self.ItemButtons) do
                button:UpdateCount();
            end
        end
    end
end


do  --VisualButtonMixin
    function VisualButtonMixin:OnLoad()
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

    function VisualButtonMixin:SetAction(action)
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

    function VisualButtonMixin:UpdateCount()
        if self.actionType == "item" then
            local count = GetItemCount(self.id);
            if count > 1 then
                self.Count:SetText(count);
            else
                self.Count:SetText(nil);
            end
            self:SetUsableVisual(count > 0);
        end
    end

    function VisualButtonMixin:SetUsableVisual(state)
        if state then
            self.Icon:SetVertexColor(1, 1, 1);
            self.Icon:SetDesaturated(false);
        else
            self.Icon:SetVertexColor(0.8, 0.8, 0.8);
            self.Icon:SetDesaturated(true);
        end
    end

    function VisualButtonMixin:OnEnter()
        self:ShowTooltip();
    end

    function VisualButtonMixin:OnLeave()
        GameTooltip:Hide();
        self:SetButtonState("NORMAL");
    end

    function VisualButtonMixin:ShowTooltip()
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

    function VisualButtonMixin:ClearAction()
        if self.actionType then
            self.Icon:SetTexture(nil);
            self.id = nil;
            self.actionType = nil;
            self.tooltipMethod = nil;
            self.macroText = nil;
            self.text = nil;
            self.tooltipText = nil;
            self.Cooldown:Clear();
            self.Cooldown:Hide();
            self.Count:SetText(nil);
            self:SetUsableVisual(true);
        end
    end


    --Default Actions
    function VisualButtonMixin:SetRandomFavoritePet()
        self.tooltipMethod = "SetSpellByID";
        self.id = 243819;
        self.Icon:SetTexture(C_Spell.GetSpellTexture(self.id));
    end

    function VisualButtonMixin:SetRandomPet()
        self.tooltipText = SUMMON_RANDOM_PET;
        self.Icon:SetTexture(613074);
    end

    function VisualButtonMixin:SetDismissPet()
        self.tooltipText = L["Dismiss Battle Pet"];
        self.Icon:SetTexture(653220);
    end

    function VisualButtonMixin:SetSummonPet(petNameOrGUID)
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

    function VisualButtonMixin:SetCustomEmote(customEmote)
        self.tooltipText = (EMOTE or "Emote")..": "..customEmote;
    end
end



---- Secure Objects ----
local SecureRootContainer = CreateFrame("Frame", nil, UIParent, "SecureHandlerMouseUpDownTemplate, SecureHandlerShowHideTemplate", "SecureHandlerClickTemplate");
SecureRootContainer:Hide();
SecureRootContainer:SetAllPoints(true);
SecureRootContainer:SetFrameStrata("BACKGROUND");
SecureRootContainer:SetPropagateMouseMotion(true);
SecureRootContainer:SetPropagateMouseClicks(true);

SecureRootContainer:SetAttribute("_onmousedown", [=[
    self:Hide();
]=]);

SecureRootContainer:SetAttribute("_onmouseup", [=[

]=]);

SecureRootContainer:SetAttribute("_onclick", [=[
    self:Hide();
]=]);

SecureRootContainer:SetAttribute("_onshow", [=[
    self:SetBindingClick(true, "ESCAPE", self)
]=]);

SecureRootContainer:SetAttribute("_onhide", [=[
    self:ClearBindings();
]=]);

SpellFlyout:SetParent(SecureRootContainer);


local ActionButtonContainer = CreateFrame("Frame", nil, SecureRootContainer, "SecureHandlerStateTemplate");
ActionButtonContainer:SetFrameStrata("FULLSCREEN_DIALOG");
ActionButtonContainer:SetFixedFrameStrata(true);
SetupClampedFrame(ActionButtonContainer);


local SecureControllerPool = {};
do
    local VIRTUAL_BUTTON_NAME = "PLMR";

    SecureControllerPool.clickHandlers = {};
    SecureControllerPool.numHandlers = 0;

    function SecureControllerPool:ReleaseClickHandlers()
        if InCombatLockdown() then
            return
        end

        self.numIdleHandlers = #self.clickHandlers;

        for _, handler in ipairs(self.clickHandlers) do
            handler:SetAttribute("_onclick", nil);
        end
    end

    function SecureControllerPool:AcquireClickHandler()
        local handler;
        if self.numIdleHandlers == 0 then
            self.numHandlers = self.numHandlers + 1;
            local id = self.numHandlers;
            local name = VIRTUAL_BUTTON_NAME..self.numHandlers;
            handler = CreateFrame("Button", name, UIParent, "SecureHandlerClickTemplate");
            self.clickHandlers[id] = handler;
            handler:Hide();
            handler:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
            handler:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0);
            self:SetupHandler(handler);
            handler:SetID(id);
        else
            handler = self.clickHandlers[self.numIdleHandlers];
            self.numIdleHandlers = self.numIdleHandlers - 1;
        end
        return handler
    end

    function SecureControllerPool:SetupHandler(handler)
        handler:RegisterForClicks("AnyUp");
        handler:SetFrameRef("MainFrame", SecureRootContainer);
        handler:SetFrameRef("UIParent", UIParent);
        handler:SetFrameRef("ActionButtonContainer", ActionButtonContainer);
        ActionButtonPool:AddFrameRef(handler);  --SetFrameRef("SecureButton")
    end

    local HANDLER_ONCLICK = [=[
        local frame = self:GetFrameRef("MainFrame");
        local handlerID = self:GetID();
        local show = (not frame:IsShown()) or (handlerID ~= frame:GetID());
        if show then
            frame:SetID(handlerID);
            local UIParent = self:GetFrameRef("UIParent");
            local uiWidth = UIParent:GetWidth();
            local uiHeight = UIParent:GetHeight();
            local xRatio, yRatio = self:GetMousePosition();
            if xRatio and yRatio then
                local numActions = self:GetAttribute("numActions");
                local ActionButtonContainer = self:GetFrameRef("ActionButtonContainer");
                local index = numActions + 1;

                local button = self:GetFrameRef("SecureButton"..index);
                while button do
                    button:Hide();
                    index = index + 1;
                    button = self:GetFrameRef("SecureButton"..index);
                end

                local numButtons = 0;
                local buttonSize = 45;
                local gap = 2;

                for i = 1, numActions do
                    button = self:GetFrameRef("SecureButton"..i);
                    if button then
                        numButtons = numButtons + 1;
                        local macroText = self:GetAttribute("customMacroText"..i);
                        button:SetAttribute("type", "macro");
                        button:SetAttribute("macrotext", macroText);
                        button:SetFrameLevel(10);
                        button:ClearAllPoints();
                        button:SetPoint("BOTTOMLEFT", ActionButtonContainer, "BOTTOMLEFT", gap + (i - 1) * (buttonSize + gap), 2);
                        button:Show();
                    end
                end

                local x = uiWidth * xRatio;
                local y = uiHeight * yRatio;

                ActionButtonContainer:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x - 24.0, y + 26.0);
                ActionButtonContainer:SetWidth(numButtons * (45 + 2) + 2);
                ActionButtonContainer:SetHeight(1 * (45 + 2) + 2);
                --ActionButtonContainer:RegisterAutoHide(2);
                frame:Show();
                ActionButtonContainer:Show();
            end
        else
            frame:Hide();
        end
    ]=]

    function SecureControllerPool:AddActions(actions)
        local handler = self:AcquireClickHandler();
        local handlerName = handler:GetName();
        handler:SetAttribute("numActions", #actions);

        for i, action in ipairs(actions) do
            handler:SetAttribute("customMacroText"..i, action.macroText);
        end

        handler:SetScript("PreClick", function()
            SpellFlyout:ShowActions(actions);
        end);

        handler:SetAttribute("_onclick", HANDLER_ONCLICK);

        return handlerName
    end

    function SpellFlyout:ReleaseClickHandlers()
        SecureControllerPool:ReleaseClickHandlers();
    end

    function SpellFlyout:AddActionsAndGetHandler(actions)
        return SecureControllerPool:AddActions(actions)
    end

    function SpellFlyout:RemoveClickHandlerFromMacro(body)
        local pattern = "/click%s+"..VIRTUAL_BUTTON_NAME.."%d+";
        if find(body, pattern) then
            body = gsub(body, pattern, "");
            while find(body, "\n\n") do
                body = gsub(body, "\n\n", "\n");
            end
            body = gsub(body, "%s+$", "");
        end
        return body
    end
end

do  --SecureHandler
    ActionButtonPool.actionButtons = {};
    ActionButtonPool.visualButtons = {};

    function ActionButtonPool:InitButtons(numButtons)
        local n = #self.actionButtons;
        if numButtons > n then
            local diff = numButtons - n;
            local index, button;
            for i = 1, diff do
                index = n + i;
                button = CreateFrame("Button", nil, ActionButtonContainer, "PlumberSecureActionBarButtonTemplate");
                self.actionButtons[index] = button;

                local vb = CreateFrame("Button", nil, UIParent, "PlumberActionBarButtonTemplate");
                self.visualButtons[index] = vb;
                button.VisualButton = vb;
                API.Mixin(vb, VisualButtonMixin);
                vb:SetSize(45, 45);
                vb:SetFrameStrata("FULLSCREEN_DIALOG");
                vb:OnLoad();
                vb:SetScript("OnEnter", vb.OnEnter);
                vb:SetScript("OnLeave", vb.OnLeave);
            end
        end
        self:UpdateClicks();
    end

    function ActionButtonPool:UpdateClicks()
        local useKeyDown = GetCVarBool("ActionButtonUseKeyDown");
        if useKeyDown ~= self.useKeyDown then
            local btn1, btn2;
            if useKeyDown then
                btn1, btn2 = "LeftButtonDown", "RightButtonDown";
            else
                btn1, btn2 = "LeftButtonUp", "RightButtonUp";
            end
            for _, button in ipairs(self.actionButtons) do
                button:RegisterForClicks(btn1, btn2);
            end
        end
    end

    function ActionButtonPool:AddFrameRef(handler)
        for index, button in ipairs(self.actionButtons) do
            handler:SetFrameRef("SecureButton"..index, button);
        end
    end

    ActionButtonPool:InitButtons(16);
end