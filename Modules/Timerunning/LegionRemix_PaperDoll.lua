local _, addon = ...
local RemixAPI = addon.RemixAPI
if not RemixAPI then return end;


local API = addon.API;
local L = addon.L;


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
        if self.delay >= 0.1 then
            self.delay = nil;
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


local LegionWidget = CreatePaperDollWidget("PlumberLegionRemixPaperDollWidgetTemplate");
do
    LegionWidget.enabled = true;
    local TEXTURE_FILE = "Interface/AddOns/Plumber/Art/Timerunning/LegionPaperDollWidget.png";
    LegionWidget.Background:SetTexture(TEXTURE_FILE);
    LegionWidget.Sheen:SetTexture(TEXTURE_FILE);
    LegionWidget.Sheen:SetTexCoord(128/512, 248/512, 0, 96/512);
    LegionWidget.SheenMask:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/Mask-Halo", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
    LegionWidget.Tooltip.BackgroundArt:SetTexture(TEXTURE_FILE);
    LegionWidget.Tooltip.BackgroundArt:SetTexCoord(0/512, 160/512, 96/512, 256/512);

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
        self:ShowTooltip();
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

    function LegionWidget:ShowTooltip()
        local tooltip = self.Tooltip;


        local text3;

        local bonusTraits = {
            1235159,
            1242992,
            1234774,
            1233592,
            1241996,
        };

        local traitFormat = "+%d  |T%s:16:16:0:-2:64:64:4:60:4:60|t |cffffd100%s|r";
        for k, v in ipairs(bonusTraits) do
            local totalIncreased = 3;
            local spellIcon = C_Spell.GetSpellTexture(v);
            local spellName = C_Spell.GetSpellName(v);
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
        tooltip.t = 0;
        tooltip:SetAlpha(0);
        tooltip:SetScript("OnUpdate", SharedFadeIn_OnUpdate);
        tooltip:Show();
        tooltip:SetFrameStrata("TOOLTIP");
    end
end