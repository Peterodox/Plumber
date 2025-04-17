-- User Settings
local CLOSE_AFTER_CLICK = true;
local GRID_LAYOUT = true;           --Multi-row, not single row
local MAX_BUTTON_PER_ROW = 4;
------------------

local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;

local tinsert = table.insert;
local InCombatLockdown = InCombatLockdown;
local CreateFrame = CreateFrame;
local GetCVarBool = C_CVar.GetCVarBool;
local GetItemCount = C_Item.GetItemCount;
local PlayerHasToy = PlayerHasToy or API.Nop;
local C_PetJournal = C_PetJournal;
local GetSpellTexture = C_Spell.GetSpellTexture;
local IsSpellDataCached = C_Spell.IsSpellDataCached;
local GetItemCraftingQuality = API.GetItemCraftingQuality;
local CanPlayerPerformAction = API.CanPlayerPerformAction;
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


local IS_CLASSIC = addon.IS_CLASSIC;
local ACTION_BUTTON_SIZE = 45;
if IS_CLASSIC then
    ACTION_BUTTON_SIZE = 36;
end

--Flyout Cursor OffsetX = 24.0
--Flyout Cursor OffsetY = 26.0


do --SpellFlyout Main
    SpellFlyout:Hide();
    SpellFlyout:SetFrameStrata("FULLSCREEN_DIALOG");

    function SpellFlyout:Clear()
        self.actions = nil;
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

        --Create Background. TO-DO convert into a template?
        --This texture has a large shadow
        local bg = addon.CreateNineSliceFrame(self, "NineSlice_GenericBox_Black_Shadowed");
        local buttonScale = ACTION_BUTTON_SIZE / 45;
        bg:SetUsingParentLevel(true);
        bg:CoverParent(16 * buttonScale);
        bg.pieces[1]:SetTexCoord(0/128, 48/128, 0/128, 48/128);
        bg.pieces[2]:SetTexCoord(48/128, 80/128, 0/128, 48/128);
        bg.pieces[3]:SetTexCoord(80/128, 128/128, 0/128, 48/128);
        bg.pieces[4]:SetTexCoord(0/128, 48/128, 48/128, 80/128);
        bg.pieces[5]:SetTexCoord(48/128, 80/128, 48/128, 80/128);
        bg.pieces[6]:SetTexCoord(80/128, 128/128, 48/128, 80/128);
        bg.pieces[7]:SetTexCoord(0/128, 48/128, 80/128, 128/128);
        bg.pieces[8]:SetTexCoord(48/128, 80/128, 80/128, 128/128);
        bg.pieces[9]:SetTexCoord(80/128, 128/128, 80/128, 128/128);
        if IS_CLASSIC then
           bg:SetCornerSize(48 * buttonScale);
        else
            bg:SetCornerSize(48);
        end

        self:EnableMouse(true);
        self:EnableMouseMotion(true);

        local file = "Interface/AddOns/Plumber/Art/Frame/SpellFlyout";
        self.FlyoutArrow = self:CreateTexture(nil, "OVERLAY");
        self.FlyoutArrow:SetTexture(file)
        self.FlyoutArrow:SetTexCoord(0, 48/512, 0, 48/512);
        self.FlyoutArrow:SetSize(24, 24);
        self.FlyoutArrow:Hide();

        self.Note = self:CreateFontString(nil, "OVERLAY", "GameFontRed");
        self.Note:SetPoint("CENTER", self, "CENTER", 0, 0);
        self.Note:SetJustifyH("CENTER");
        self.Note:SetJustifyH("CENTER");
        self.Note:Hide();

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

        local buttonSize = ACTION_BUTTON_SIZE;
        local gap = 2;
        local h, v = 0, 0;

        if actions and #actions > 0 then
            self.Note:Hide();
            local level = 9;
            local n = 0;
            local action;
            local anySpell, anyItem;

            for index, button in ipairs(ActionButtonPool.visualButtons) do
                button:ClearAction();
                action = actions[index];
                if action then
                    n = n + 1;
                    h = h + 1;

                    if GRID_LAYOUT then
                        if h > MAX_BUTTON_PER_ROW then
                            h = 1;
                            v = v + 1;
                        end
                    end

                    button:SetAction(action);
                    button:SetButtonState("NORMAL");
                    button:SetPoint("TOPLEFT", self, "TOPLEFT", gap + (h - 1) * (buttonSize + gap), -gap - v * (buttonSize + gap));
                    button:SetFrameLevel(level);

                    if action.actionType == "spell" then
                        anySpell = true;
                        tinsert(self.SpellButtons, button);
                    elseif action.actionType == "item" then
                        anyItem = true;
                        tinsert(self.ItemButtons, button);
                    end
                end
            end

            if v > 0 then
                h = MAX_BUTTON_PER_ROW;
            end

            if anySpell then
                self:UpdateSpellCooldowns();
            end
            if anyItem then
                self:UpdateItemCooldowns();
                self:UpdateItemCount();
            end

            self:SetSize(h * (buttonSize + gap) + gap, (v + 1) * (buttonSize + gap) + gap);
        else
            self.Note:SetText(L["PlumberMacro Error NoAction"]);
            self.Note:Show();
            h = 4;
            v = 0;

            self.Note:SetWidth(3 * (buttonSize + gap) - gap);
            local textWidth = API.Round(self.Note:GetWrappedWidth());
            local textHeight = API.Round(self.Note:GetHeight());
            self:SetSize(textWidth + 32, textHeight + 24);
            --self:SetSize(h * (buttonSize + gap) + gap, (v + 1) * (buttonSize + gap) + gap);
        end

        local x, y = API.GetScaledCursorPositionForFrame(self);
        self:ClearAllPoints();
        self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x - 24.0, y + 26.0);
        self:SetFrameStrata("FULLSCREEN_DIALOG");
        self:SetFrameLevel(7);
        self:EnableMouse(true);
        self:Show();
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
        self.IconOverlay:SetTexture(file);
        self.IconOverlay:SetTexCoord(0/512, 48/512, 144/512, 192/512);

        self.NormalTexture:SetDrawLayer("OVERLAY");
        self.PushedTexture:SetDrawLayer("OVERLAY");

        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);

        if IS_CLASSIC then
            self:SetEffectiveSize(ACTION_BUTTON_SIZE);
        end
    end

    function VisualButtonMixin:SetAction(action)
        self.id = action.id;
        self.Icon:SetTexture(action.icon);
        self.actionType = action.actionType;
        self.macroText = action.macroText;
        self.rawMacroText = action.rawMacroText;
        self.tooltipLineText = action.tooltipLineText;

        if self.actionType == "spell" then
            self.tooltipMethod = "SetSpellByID";
            if not CanPlayerPerformAction("spell", self.id) then
                self:SetUsableVisual(false);
            end

        elseif self.actionType == "item" then
            if API.IsToyItem(self.id) then
                self.isToy = true;
                self.tooltipMethod = "SetToyByItemID";
            else
                self.tooltipMethod = "SetItemByID";
            end
            local craftingQuality = GetItemCraftingQuality(self.id);
            self:SetCraftingQuality(craftingQuality);
        elseif self.actionType == "profession" then
            self:SetPrimaryProfession(action.id);
        elseif self.actionType == "mount" then
            --Only RandomFavoriteMount use this method
            --Regular mounts have been converted to spells 
            self:SetMount(self.id);
        elseif self[action.actionType] then
            self[action.actionType](self, action.id);
        end
    end

    function VisualButtonMixin:UpdateCount()
        if self.actionType == "item" then
            local count = GetItemCount(self.id);
            if self.isToy then
                count = PlayerHasToy(self.id) and 1 or 0;
            end
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
            self.IconOverlay:SetVertexColor(1, 1, 1);
        else
            self.Icon:SetVertexColor(0.5, 0.5, 0.5);
            self.Icon:SetDesaturated(true);
            self.IconOverlay:SetVertexColor(0.8, 0.8, 0.8);
        end
    end

    function VisualButtonMixin:SetCraftingQuality(quality)
        if quality then
            self.IconOverlay:Show();
            if quality == 1 then
                self.IconOverlay:SetTexCoord(0/512, 48/512, 144/512, 192/512);
            elseif quality == 2 then
                self.IconOverlay:SetTexCoord(48/512, 96/512, 144/512, 192/512);
            elseif quality == 3 then
                self.IconOverlay:SetTexCoord(96/512, 144/512, 144/512, 192/512);
            elseif quality == 4 then
                self.IconOverlay:SetTexCoord(144/512, 192/512, 144/512, 192/512);
            elseif quality == 5 then
                self.IconOverlay:SetTexCoord(192/512, 240/512, 144/512, 192/512);
            else
                self.IconOverlay:Hide();
                return
            end
        else
            self.IconOverlay:Hide();
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
            return true
        elseif self.tooltipText then
            local tooltip = GameTooltip;
            tooltip:SetOwner(self, "ANCHOR_RIGHT");
            tooltip:SetText(self.tooltipText, 1, 1, 1, true);
            tooltip:Show();
            self.UpdateTooltip = nil;
            return true
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
            self.rawMacroText = nil;
            self.tooltipLineText = nil;
            self.tooltipText = nil;
            self.isToy = nil;
            if self.Cooldown then
                self.Cooldown:Clear();
                self.Cooldown:Hide();
            end
            if self.Count then
                self.Count:SetText(nil);
            end
            self:SetUsableVisual(true);
            self:SetCraftingQuality(nil);
        end
    end

    function VisualButtonMixin:SetEffectiveSize(size)
        local s = size / 45;
        self:SetSize(45 * s, 45 * s);
        self.Icon:SetSize(40 * s, 40 * s);
        self.NormalTexture:SetSize(48 * s, 48 * s);
        self.PushedTexture:SetSize(48 * s, 48 * s);
        self.HighlightTexture:SetSize(48 * s, 48 * s);
        self.IconOverlay:SetSize(24 * s, 24 * s);
    end

    function VisualButtonMixin:IsDataCached()
        if self.actionType == "spell" then
            return IsSpellDataCached(self.id);
        elseif self.actionType == "item" then
            return C_Item.IsItemDataCachedByID(self.id);
        end
        return true
    end

    --Default Actions
    function VisualButtonMixin:SetRandomFavoritePet()
        self.tooltipMethod = "SetSpellByID";
        self.id = 243819;
        self.Icon:SetTexture(GetSpellTexture(self.id));
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

    function VisualButtonMixin:SetPrimaryProfession(spellID)
        if spellID and spellID > 0 then
            self.tooltipMethod = "SetSpellByID";
        else
            self.tooltipText = self.tooltipLineText;
        end
    end

    function VisualButtonMixin:SetMount(spellID)
        self.tooltipMethod = "SetMountBySpellID";
        self.Icon:SetTexture(GetSpellTexture(spellID));
    end


    function SpellFlyout:PopulateButtonMixin(externalMixin)
        for k, v in pairs(VisualButtonMixin) do
            if not externalMixin[k] then
                externalMixin[k] = v;
            end
        end
        return externalMixin
    end
end



---- Secure Objects ----
local SecureRootContainer = CreateFrame("Frame", "PlumberSecureFlyoutContainer", UIParent, "SecureHandlerMouseUpDownTemplate, SecureHandlerShowHideTemplate", "SecureHandlerClickTemplate");    --Name is need for OverrideBindingClick
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
do  --SecureControllerPool
    local VIRTUAL_BUTTON_NAME = "PLMR";

    SecureControllerPool.clickHandlers = {};
    SecureControllerPool.numHandlers = 0;
    SecureControllerPool.usedHandlers = 0;

    function SecureControllerPool:ReleaseClickHandlers()
        if InCombatLockdown() then
            return
        end

        self.usedHandlers = 0;
        self.emptyActionHandlerName = nil;

        for _, handler in ipairs(self.clickHandlers) do
            handler:SetAttribute("_onclick", nil);
        end
    end

    function SecureControllerPool:CreateClickHandler(id)
        local name = VIRTUAL_BUTTON_NAME..id;
        local handler = CreateFrame("Button", name, UIParent, "SecureHandlerClickTemplate");
        handler:Hide();
        handler:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
        handler:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0);
        self:SetupHandler(handler);
        handler:SetID(id);
        return handler
    end

    function SecureControllerPool:AcquireClickHandler()
        local handler;
        self.usedHandlers = self.usedHandlers + 1;
        if self.usedHandlers > self.numHandlers then
            self.numHandlers = self.numHandlers + 1;
            local id = self.numHandlers;
            handler = self:CreateClickHandler(id);
            self.clickHandlers[id] = handler;
        else
            handler = self.clickHandlers[self.usedHandlers];
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

    local HANDLER_ONCLICK_FORMAT = [=[
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
                local buttonSize = %s;
                local useGridLayout = %s;
                local maxButtonPerRow = %s;
                local gap = 2;
                local h = 0;
                local v = 0;

                for i = 1, numActions do
                    button = self:GetFrameRef("SecureButton"..i);
                    if button then
                        numButtons = numButtons + 1;
                        local macroText = self:GetAttribute("customMacroText"..i);
                        button:SetAttribute("type", "macro");
                        button:SetAttribute("macrotext", macroText);
                        button:SetFrameLevel(10);
                        button:ClearAllPoints();
                        h = h + 1;
                        if useGridLayout then
                            if h > maxButtonPerRow then
                                h = 1;
                                v = v + 1;
                            end
                        end
                        button:SetPoint("TOPLEFT", ActionButtonContainer, "TOPLEFT", gap + (h - 1) * (buttonSize + gap), -gap - v * (buttonSize + gap));
                        button:Show();
                    end
                end

                if v > 0 then
                    h = maxButtonPerRow;
                end

                local x = uiWidth * xRatio;
                local y = uiHeight * yRatio;

                if numActions == 0 then
                    h = 4;
                end

                ActionButtonContainer:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x - 24.0, y + 26.0);
                ActionButtonContainer:SetWidth(h * (buttonSize + gap) + gap);
                ActionButtonContainer:SetHeight((v + 1) * (buttonSize + gap) + gap);
                --ActionButtonContainer:RegisterAutoHide(2);
                frame:Show();
                ActionButtonContainer:Show();
            end
        else
            frame:Hide();
        end
    ]=];

    local HANDLER_ONCLICK;

    function SecureControllerPool:UpdateLayout()
        HANDLER_ONCLICK = HANDLER_ONCLICK_FORMAT:format(ACTION_BUTTON_SIZE, tostring(GRID_LAYOUT), MAX_BUTTON_PER_ROW);
    end
    SecureControllerPool:UpdateLayout()

    function SecureControllerPool:AddActions(actions)
        local numActions = actions and #actions or 0;

        if numActions == 0 and self.emptyActionHandlerName then
            return self.emptyActionHandlerName;
        end

        local handler = self:AcquireClickHandler();
        local handlerName = handler:GetName();

        if numActions == 0 then
            self.emptyActionHandlerName = handlerName;
        end

        handler:SetAttribute("numActions", numActions);

        if numActions > 0 then
            if CLOSE_AFTER_CLICK then
                local closeFlyoutMacro = self:GetCloseFlyoutMacro();
                closeFlyoutMacro = "\n"..closeFlyoutMacro;
                for i, action in ipairs(actions) do
                    handler:SetAttribute("customMacroText"..i, (action.macroText or "")..closeFlyoutMacro);
                end
            else
                for i, action in ipairs(actions) do
                    handler:SetAttribute("customMacroText"..i, action.macroText);
                end
            end
        else

        end

        handler:SetScript("PreClick", function()
            if not(SpellFlyout:IsShown() and SpellFlyout.actions == actions) then
                SpellFlyout:ShowActions(actions);
            end
            if not InCombatLockdown() then
                ActionButtonPool:UpdateClicks();
            end
            --Also triggered when clicking the handler to close the menu
        end);

        handler:SetAttribute("_onclick", HANDLER_ONCLICK);

        return handlerName
    end

    function SecureControllerPool:GetCloseFlyoutMacro()
        --We create a ClickHandler that closes the SecureRootContainer
        --This handler will not be reused/released by other drawer macro
        if not self.CloseFrameClickHandler then
            local id = 0;
            local handler = self:CreateClickHandler(id);
            self.CloseFrameClickHandler = handler;
            handler:SetAttribute("_onclick", [==[
                local frame = self:GetFrameRef("MainFrame");
                frame:Hide();
            ]==]);
            self.clickToCloseMacro = "/click "..handler:GetName();
        end
        return self.clickToCloseMacro
    end


    function SpellFlyout:ReleaseClickHandlers()
        SecureControllerPool:ReleaseClickHandlers();
    end

    function SpellFlyout:AddActionsAndGetHandler(actions)
        return SecureControllerPool:AddActions(actions)
    end

    function SpellFlyout:RemoveClickHandlerFromMacro(body)
        local pattern = "/click%s+"..VIRTUAL_BUTTON_NAME.."%d+";
        local anyChange;
        if find(body, pattern) then
            body = gsub(body, pattern, "");
            while find(body, "\n\n") do
                body = gsub(body, "\n\n", "\n");
            end
            body = gsub(body, "%s+$", "");
            anyChange = true;
        else
            anyChange = false;
        end
        return body, anyChange
    end

    function SpellFlyout:Close()
        if not InCombatLockdown() then
            if SecureRootContainer:IsShown() then
                SecureRootContainer:Hide();
            end
        end
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
                button:SetSize(ACTION_BUTTON_SIZE, ACTION_BUTTON_SIZE);

                local vb = CreateFrame("Button", nil, UIParent, "PlumberActionBarButtonTemplate");
                vb:Hide();
                self.visualButtons[index] = vb;
                button.VisualButton = vb;
                API.Mixin(vb, VisualButtonMixin);
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

    ActionButtonPool:InitButtons(16);   --255/16
end

do  --Settings Registry
    CallbackRegistry:RegisterSettingCallback("SpellFlyout_CloseAfterClick", function(state, userInput)
        CLOSE_AFTER_CLICK = state;
        if userInput and not InCombatLockdown() then
            SecureRootContainer:Hide();
        end
    end);

    CallbackRegistry:RegisterSettingCallback("SpellFlyout_SingleRow", function(state, userInput)
        GRID_LAYOUT = not state;
        SecureControllerPool:UpdateLayout();
        if userInput and not InCombatLockdown() then
            SecureRootContainer:Hide();
        end
    end);

    CallbackRegistry:RegisterSettingCallback("SpellFlyout_HideUnusable", function(state, userInput)
        if userInput and not InCombatLockdown() then
            SecureRootContainer:Hide();
        end
    end);
end