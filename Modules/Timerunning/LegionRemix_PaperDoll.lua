local _, addon = ...
local RemixAPI = addon.RemixAPI
if not RemixAPI then return end;


local API = addon.API;
local L = addon.L;
local GetInventoryItemID = GetInventoryItemID;
local GetSpellTexture = C_Spell.GetSpellTexture;
local DataProvider = RemixAPI.DataProvider;


local TEXTURE_FILE = "Interface/AddOns/Plumber/Art/Timerunning/LegionPaperDollWidget.png";


local Controller = CreateFrame("Frame");
do  --Controller
    Controller.WidgetContainer = CreateFrame("Frame");
    Controller.WidgetContainer:SetSize(24, 24);

    function Controller:Init()
        self.Init = nil;

        local parentFrame = PaperDollFrame;

        parentFrame:HookScript("OnShow", function()
            if self.isEnabled then
                self:ListenEvents(true);
                self.WidgetContainer:Show();
                self:UpdateWidgets();
            end
        end);

        parentFrame:HookScript("OnHide", function()
            self:ListenEvents(false);
        end);

        local pane2 = PaperDollFrame.TitleManagerPane;
        local pane3 = PaperDollFrame.EquipmentManagerPane;

        local function UpdateVisibility()
            if pane2:IsShown() or pane3:IsShown() then
                self:ListenEvents(false);
                self.WidgetContainer:Hide();
            else
                if self.isEnabled and parentFrame:IsVisible() then
                    self:ListenEvents(true);
                    self.WidgetContainer:Show();
                    self:UpdateWidgets();
                end
            end
        end

        pane2:HookScript("OnShow", UpdateVisibility);
        pane2:HookScript("OnHide", UpdateVisibility);
        pane3:HookScript("OnShow", UpdateVisibility);
        pane3:HookScript("OnHide", UpdateVisibility);

        self.Init = nil;
    end

    function Controller:UpdateParent()
        if GwDressingRoomGear then
            local parentFrame = GwDressingRoomGear;
            self.WidgetContainer:SetParent(parentFrame);

            parentFrame:HookScript("OnShow", function()
                if Controller.isEnabled then
                    Controller:ListenEvents(true);
                    self.WidgetContainer:Show();
                    Controller:UpdateWidgets();
                end
            end);

            parentFrame:HookScript("OnHide", function()
                Controller:ListenEvents(false);
            end);
        end
    end

    function Controller:UpdatePosition_OnShow()
        --adjustment for serveral addons/WA
        local WidgetContainer = Controller.WidgetContainer;

        if CharacterStatsPaneilvl then
            --Chonky Character Sheet    wago.io/bRl2gJIgz
            WidgetContainer:ClearAllPoints();
            WidgetContainer:SetPoint("CENTER", CharacterStatsPaneilvl, "RIGHT", 22, 0);     --anchor changed after swapping items, IDK why
        elseif C_AddOns.IsAddOnLoaded("DejaCharacterStats") then
            WidgetContainer:ClearAllPoints();
            WidgetContainer:SetPoint("CENTER", PaperDollFrame, "TOPRIGHT", -1, -84);
        elseif GwDressingRoomGear then   --GW2 UI
            WidgetContainer:SetParent(GwDressingRoomGear);
            WidgetContainer:ClearAllPoints();
            WidgetContainer:SetPoint("CENTER", GwDressingRoomGear, "TOPRIGHT", 12, -60);
        elseif CharacterFrame and CharacterStatsPane and CharacterStatsPane.ItemLevelFrame then
            --A universal approach to align to the ItemLevelFrame center    (DejaCharStats)
            local anchor = CharacterStatsPane.ItemLevelFrame;
            local _, anchorY = anchor:GetCenter();
            if anchorY then
                local y0 = CharacterFrame:GetTop();
                WidgetContainer:ClearAllPoints();
                WidgetContainer:SetPoint("CENTER", PaperDollFrame, "TOPRIGHT", -1, anchorY - y0);
            end
        end

        Controller:ResetWidgetPosition();
        WidgetContainer:SetScript("OnShow", nil);
    end

    function Controller:Enable()
        if self.Init then
            self:Init();
        end

        local parentFrame = PaperDollFrame;
        local WidgetContainer = self.WidgetContainer;
        WidgetContainer:ClearAllPoints();
        WidgetContainer:SetParent(parentFrame);
        WidgetContainer:SetPoint("CENTER", parentFrame, "TOPRIGHT", -1, -119);
        WidgetContainer:Show();
        WidgetContainer:SetFrameStrata("HIGH");
        WidgetContainer:SetScript("OnShow", self.UpdatePosition_OnShow);
        self:SetScript("OnEvent", self.OnEvent);
        self:UpdateParent();
        self.isEnabled = true;
    end

    function Controller:Disable()
        if not self.isEnabled then return end;
        self.isEnabled = false;
        self:ListenEvents(false);
        self.WidgetContainer:ClearAllPoints();
        self.WidgetContainer:Hide();
        self.WidgetContainer:SetParent(self);
    end

    function Controller:ListenEvents(state)
        if state then
            self:RegisterEvent("BAG_UPDATE_DELAYED");
            self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
        else
            self:UnregisterEvent("BAG_UPDATE_DELAYED");
            self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
        end
    end

    function Controller:OnEvent(event, ...)
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function Controller:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t >= 0.1 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            self:UpdateWidgets();
        end
    end

    function Controller:UpdateWidgets()
        if self.widgets then
            for _, widget in pairs(self.widgets) do
                if widget.enabled then
                    widget:Update();
                else
                    widget:Hide();
                end
            end
        end
    end

    function Controller:AddWidget(newWidget, index, dbKey)
        if not self.widgets then
            self.widgets = {};
        end

        if self.widgets[index] then return false end;

        newWidget.parent = self.WidgetContainer;
        newWidget.dbKey = dbKey;
        newWidget:ResetAnchor();
        self.widgets[index] = newWidget;
        return true
    end

    function Controller:RemoveWidget(removedWidget)
        for index, widget in pairs(self.widgets) do
            if widget == removedWidget then
                self.widgets[index] = nil;
                widget:Hide();
                widget:ClearAllPoints();
                widget:SetParent(nil);
                break
            end
        end
    end

    function Controller:ResetWidgetPosition()
        if self.widgets then
            for _, widget in pairs(self.widgets) do
                widget:ResetAnchor();
            end
        end
    end

    function Controller:HideNarcissusWidgets()
        local con = NarciPaperDollWidgetController;
        if not con then return end;

        con:ListenEvents(false);
        con.WidgetContainer:Hide();
    end

    local PaperDollSlots = {
        [1] = "HeadSlot",
        [2] = "NeckSlot",
        [3] = "ShoulderSlot",
        [4] = "ShirtSlot",
        [5] = "ChestSlot",
        [6] = "WaistSlot",
        [7] = "LegsSlot",
        [8] = "FeetSlot",
        [9] = "WristSlot",
        [10]= "HandsSlot",
        [11]= "Finger0Slot",
        [12]= "Finger1Slot",
        [13]= "Trinket0Slot",
        [14]= "Trinket1Slot",
        [15]= "BackSlot",
        [16]= "MainHandSlot",
        [17]= "SecondaryHandSlot",
        [18]= "AmmoSlot",
        [19]= "TabardSlot",
    };

    function Controller:GetSlotButton(slotID)
        local slotButton = _G["Character"..PaperDollSlots[slotID]];
        return slotButton
    end
end


local CreatePaperDollWidget;
do
    local PaperDollWidgetSharedMixin = {};

    function CreatePaperDollWidget(template)
        local f = CreateFrame("Button", nil, nil, template);
        API.Mixin(f, PaperDollWidgetSharedMixin);
        return f
    end

    function PaperDollWidgetSharedMixin:ResetAnchor()
        self:ClearAllPoints();
        self:SetParent(self.parent);
        self:SetPoint("CENTER", self.parent, "CENTER", self.offsetX or 0, 0);
    end

    function PaperDollWidgetSharedMixin:Update()

    end
end


local function CreateSubIconPool()
    local function IconFrame_Create()
        local object = CreateFrame("Frame");
        object:SetSize(16, 16);
        object.Icon = object:CreateTexture(nil, "OVERLAY");
        object.Icon:SetSize(16, 16);
        object.Icon:SetPoint("CENTER", object, "CENTER", 0, 0);
        local shrink = 8;
        object.Icon:SetTexCoord(shrink/64, 1-shrink/64, shrink/64, 1-shrink/64);
        object.Border = object:CreateTexture(nil, "OVERLAY", nil, 2);
        object.Border:SetTexture(TEXTURE_FILE);
        object.Border:SetTexCoord(384/512, 448/512, 0, 64/512);
        object.Border:SetSize(32, 32);
        object.Border:SetPoint("CENTER", object, "CENTER", 0, 0);
        object.Icon:SetTexture(134400);
        return object
    end

    local function IconFrame_Remove(object)
        object:ClearAllPoints();
        object:Hide();
        object:SetParent(nil);
    end

    return API.CreateObjectPool(IconFrame_Create, IconFrame_Remove);
end

local LegionWidget = CreatePaperDollWidget("PlumberLegionRemixPaperDollWidgetTemplate");
do
    LegionWidget.enabled = true;
    LegionWidget.Background:SetTexture(TEXTURE_FILE);
    LegionWidget.Sheen:SetTexture(TEXTURE_FILE);
    LegionWidget.Sheen:SetTexCoord(128/512, 248/512, 0, 96/512);
    LegionWidget.SheenMask:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/Mask-Halo", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
    LegionWidget.Tooltip.BackgroundArt:SetTexture(TEXTURE_FILE);
    LegionWidget.Tooltip.BackgroundArt:SetTexCoord(0/512, 160/512, 96/512, 256/512);
    LegionWidget:RegisterForClicks("LeftButtonUp", "RightButtonUp");

    Controller:AddWidget(LegionWidget, 1, "LegionRemixPaperDollWidget");
    Controller:Enable();

    function LegionWidget:UpdateVisual()
        self.Background:SetTexCoord(0, 120/512, 0, 96/512);
    end
    LegionWidget:UpdateVisual();

    function LegionWidget:PlaySheen()
        self.Sheen:Show();
        self.AnimSheen:Play();
    end

    function LegionWidget:OnEnter()
        self:UpdateVisual();
        self:PlaySheen();
        self:ShowTooltip(true);
    end
    LegionWidget:SetScript("OnEnter", LegionWidget.OnEnter);

    function LegionWidget:OnLeave()
        self:UpdateVisual();
        self.Tooltip:Hide();
    end
    LegionWidget:SetScript("OnLeave", LegionWidget.OnLeave);

    function LegionWidget:OnClick()
        RemixAPI.ToggleArtifactUI()
    end
    LegionWidget:SetScript("OnClick", LegionWidget.OnClick);

    function LegionWidget:OnHide()
        self.Tooltip:Hide();
        self.t = nil;
        self:SetScript("OnUpdate", nil);
    end
    LegionWidget:SetScript("OnHide", LegionWidget.OnHide);

    local function SharedFadeIn_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        local alpha = 8 * self.t;
        if alpha > 1 then
            alpha = 1;
            self:SetScript("OnUpdate", nil);
            self.t = 0;
        end
        self:SetAlpha(alpha);
    end

    local DebugBonusTraits = {
        1235159,
        1242992,
        1234774,
        1233592,
        1241996,
    };

    function LegionWidget:ShowTooltip(fadeIn)
        local tooltip = self.Tooltip;


        local isLoaded = true;
        local text3;

        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(3292);    --Infinite Knowledge
        if currencyInfo then
            text3 = string.format("|cffe6cc80%s:|r |cffffffff%s/%s|r\n", currencyInfo.name, currencyInfo.quantity, currencyInfo.maxQuantity);
        end



        if #DebugBonusTraits > 0 then
            if text3 then
                text3 = text3.."\n|cff999999"..L["Bonus Traits"].."|r";
            end
        end

        local traitFormat = "+%d  |T%s:16:16:0:-2:64:64:4:60:4:60|t |cffffd100%s|r";
        for k, v in ipairs(DebugBonusTraits) do
            local totalIncreased = 3;
            local spellIcon = GetSpellTexture(v) or 134400;
            local spellName = C_Spell.GetSpellName(v);
            if not spellName then
                spellName = " ";
                isLoaded = false;
            end
            local lineText = string.format(traitFormat, totalIncreased, spellIcon, spellName);
            if text3 then
                text3 = text3.."\n"..lineText;
            else
                text3 = lineText;
            end
        end


        tooltip.Text1:SetText("42,000 to unlock");
        tooltip.Text1:SetTextColor(0.6, 0.6, 0.6);
        tooltip.Text2:SetText("|cffb6b6b6Rank 3|r  Call of the Legion");
        tooltip.Text2:SetTextColor(177/255, 190/255, 95/255);
        tooltip.Text3:SetText(text3);
        tooltip.Instruction:SetText("Click to show Artifact UI");
        tooltip.Instruction:SetTextColor(0.6, 0.6, 0.6);

        local spacing = 16;
        local width = math.max(tooltip.Text1:GetWrappedWidth(), tooltip.Text2:GetWrappedWidth(), (text3 and tooltip.Text3:GetWrappedWidth()) or 0, tooltip.Instruction:GetWrappedWidth());
        local height = tooltip.Text1:GetHeight() + 4 + tooltip.Text2:GetHeight() + (text3 and (spacing + tooltip.Text3:GetHeight()) or 0) + spacing + tooltip.Instruction:GetHeight();
        local padding = 20;

        tooltip:SetSize(width + 2*padding, height + 2*padding + 6);

        tooltip.Text1:ClearAllPoints();
        tooltip.Text1:SetPoint("TOPLEFT", tooltip, "TOPLEFT", padding, -padding);
        tooltip.Text2:ClearAllPoints();
        tooltip.Text2:SetPoint("TOPLEFT", tooltip.Text1, "BOTTOMLEFT", 0, -4);
        if text3 then
            tooltip.Text3:ClearAllPoints();
            tooltip.Text3:SetPoint("TOPLEFT", tooltip.Text2, "BOTTOMLEFT", 0, -spacing);
            tooltip.Instruction:ClearAllPoints();
            tooltip.Instruction:SetPoint("TOPLEFT", tooltip.Text3, "BOTTOMLEFT", 0, -spacing);
        else
            tooltip.Instruction:ClearAllPoints();
            tooltip.Instruction:SetPoint("TOPLEFT", tooltip.Text2, "BOTTOMLEFT", 0, -spacing);
        end

        API.UpdateTextureSliceScale(tooltip.BackgroundFrame.Texture);
        if fadeIn then
            tooltip.t = 0;
            tooltip:SetAlpha(0);
            tooltip:SetScript("OnUpdate", SharedFadeIn_OnUpdate);
        end
        tooltip:Show();
        tooltip:SetFrameStrata("TOOLTIP");

        if not isLoaded then
            self.t = 0;
            self:SetScript("OnUpdate", self.OnUpdate);
        end
    end

    function LegionWidget:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.2 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            if self.Tooltip:IsVisible() then
                self:ShowTooltip();
            end
        end
    end

    local IconPool;     --ItemButton SubIconTexture
    local ValidSlots = {    --Neck, Rings, Trinkets
        2, 11, 12, 13, 14
    };

    function LegionWidget:ShowSlotTraitIcons(state)
        if IconPool then
            IconPool:Release();
        end

        if state then
            if not IconPool then
                IconPool = CreateSubIconPool();
            end

            for i, slotID in ipairs(ValidSlots) do
                local itemID = GetInventoryItemID("player", slotID);
                if itemID then
                    local slotButton = Controller:GetSlotButton(slotID);
                    if slotButton then
                        local texture = DataProvider:GetItemTraitTexture(itemID);
                        if texture then
                            local object = IconPool:Acquire();
                            object:SetParent(slotButton);
                            object:SetPoint("TOPRIGHT", slotButton, "TOPRIGHT", -2, -2);
                            object.Icon:SetTexture(texture);
                            slotButton.icon:SetTexture(texture);
                        end
                    end
                end
            end
        end
    end

    function LegionWidget:Update()
        --self:ShowSlotTraitIcons(true);
    end
end


do  --EquipmentFlyout
    local FlyoutIconPool = CreateSubIconPool();
    local EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION = EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION or 0xFFFFFFFD;
    local EquipmentManager_GetItemInfoByLocation = EquipmentManager_GetItemInfoByLocation;

    local function UpdateFlyout()
        FlyoutIconPool:Release();
        local flyout = EquipmentFlyoutFrame;
        --if not (flyout and flyout:IsVisible()) then return end;

        local buttons = flyout.buttons;
        local numButtons = flyout.numItemButtons or 0;

        for i = 1, numButtons do
            local location = buttons[i].location;
            if location and location < EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
                local itemID = EquipmentManager_GetItemInfoByLocation(location);
                local texture = itemID and DataProvider:GetItemTraitTexture(itemID);
                if texture then
                    local object = FlyoutIconPool:Acquire();
                    object:SetParent(buttons[i]);
                    object:SetPoint("TOPRIGHT", buttons[i], "TOPRIGHT", -2, -2);
                    object.Icon:SetTexture(texture);
                end
            end
        end
    end

    hooksecurefunc("EquipmentFlyout_UpdateItems", UpdateFlyout);

    hooksecurefunc("PaperDollItemSlotButton_Update", function(slotButton)
        local slotID = slotButton:GetID();
        local itemID = slotID and GetInventoryItemID("player", slotID);
        if itemID then
            local texture = DataProvider:GetItemTraitTexture(itemID);
            if texture and slotButton.icon then
                slotButton.icon:SetTexture(texture);
            end
        end
    end)
end