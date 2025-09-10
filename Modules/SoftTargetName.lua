-- Requisite: /console SoftTargetIconGameObject 1


local _, addon = ...
local API = addon.API;
local L = addon.L;
local Round = API.Round;


local UIParent = UIParent;
local UnitName = UnitName;
local UnitIsPlayer = UnitIsPlayer;
local UnitIsGameObject = UnitIsGameObject;
local StripHyperlinks = StripHyperlinks;
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;
local GetCVarBool = C_CVar.GetCVarBool;
local GetWorldCursor = C_TooltipInfo and C_TooltipInfo.GetWorldCursor or API.Nop;
local GetUnitIDGeneral = API.GetUnitIDGeneral;
local SetUnitCursorTexture = SetUnitCursorTexture;
local UnitCastingInfo = UnitCastingInfo;
local UnitChannelInfo = UnitChannelInfo;


local Display = CreateFrame("Frame");
local EL = CreateFrame("Frame");

local Colors = {
    Yellow = {r = 1, g = 0.82, b = 0},
    UnabledColor = {r = 0.6, g = 0.6, b = 0.6},
    Red = {r = 1, g = 0.125, b = 0.125},
    White = {r = 1, g = 1, b = 1},
};

local Settings = {
    titleHeight = 15,
    subtextHeight = 13,
    iconSize = 16,
    showCastBar = true,
    fontObject = "GameFontNormal",
    textOutline = false,
    showObjectives = false,
};


local IgnoredGameObjects = {
    [35591] = true,     --Fish Bobber (Other bobbers may have different ids)
};

local SpecialGameObjects = {};


do  --Display
    Display:Hide();
    Display:SetSize(16, 16);
    Display:SetIgnoreParentScale(true);
    Display.TooltipWatcher = CreateFrame("Frame", nil, Display);


    local function CreateTextBackground(parent, fontString, height, extensionX)
        height = height or 32;
        extensionX = extensionX or 16;
        local bg = parent:CreateTexture(nil, "BACKGROUND");
        bg:SetTexture("Interface/AddOns/Plumber/Art/Frame/NameplateTextShadow");
        bg:SetTextureSliceMargins(40, 24, 40, 24);
        bg:SetTextureSliceMode(0);
        bg:SetHeight(height);
        local offsetY = 0;
        bg:SetPoint("LEFT", fontString, "LEFT", -extensionX, offsetY);
        bg:SetPoint("RIGHT", fontString, "RIGHT", extensionX, offsetY);
        bg:SetAlpha(0.4);
        return bg
    end

    function Display:UpdateFonts()
        local file, height, flags = _G[Settings.fontObject]:GetFont();
        if Settings.textOutline then
            flags = "OUTLINE";
        else
            flags = "";
        end

        local uiScale = UIParent:GetEffectiveScale() or 1;

        if self.Title then
            height = Round(Settings.titleHeight*uiScale);
            self.Title:SetFont(file, height, flags);
            if Settings.textOutline then
                self.Title:SetShadowOffset(0, 0);
            else
                self.Title:SetShadowOffset(1, -1);
            end
        end

        if self.Subtext then
            height = Round(Settings.subtextHeight*uiScale);
            self.Subtext:SetFont(file, height, flags);
            if Settings.textOutline then
                self.Subtext:SetShadowOffset(0, 0);
            else
                self.Subtext:SetShadowOffset(1, -1);
            end
        end
    end

    function Display:Init()
        self.Init = nil;

        if not self.Title then
            self.Title = Display:CreateFontString(nil, "OVERLAY", Settings.fontObject);
            self.Title:SetPoint("TOP", self, "TOP", 0, 0);
            local file, height, flags = _G[Settings.fontObject]:GetFont();
            self.Title:SetFont(file, height, "OUTLINE");
            self.Title:SetShadowOffset(0, 0);
        end

        if not self.Background then
            self.Background = CreateTextBackground(self, self.Title, 30);
        end

        if not self.SubtextContainer then
            self.SubtextContainer = CreateFrame("Frame", nil, self);
            self.SubtextContainer:SetSize(16, 16);
            self.SubtextContainer:SetPoint("CENTER", self, "CENTER", 0, 0);
            self.SubtextContainer.alpha = 0;
        end

        if not self.Subtext then
            self.Subtext = self.SubtextContainer:CreateFontString(nil, "OVERLAY", Settings.fontObject);
            self.Subtext:SetPoint("TOP", self.Title, "BOTTOM", 0, -2);
            self.Subtext.Background = CreateTextBackground(self.SubtextContainer, self.Subtext, 28, 12);
        end

        local iconOffsetY = 16;

        if not self.InteractIcon then
            self.InteractIcon = self:CreateTexture(nil, "ARTWORK");
            self.InteractIcon:SetSize(18, 18);
            self.InteractIcon:SetPoint("CENTER", self, "TOP", 0, iconOffsetY);
            self.InteractIcon:Hide();
        end

        if not self.CastingIndicator then
            local f = CreateFrame("Cooldown", nil, self, "PlumberGenericCooldownTemplate");
            self.CastingIndicator = f;
            f:SetPoint("CENTER", self, "TOP", 0, iconOffsetY);
            local a = 24;
            f:SetSize(a, a);
            f.Background:SetSize(2*a, 2*a);
            f.Background:SetTexture("Interface/AddOns/Plumber/Art/Cooldown/ThickCircle-Background");
            f:SetSwipeTexture("Interface/AddOns/Plumber/Art/Cooldown/ThickCircle-Swipe-Blue");
            f:SetEdgeTexture("Interface/AddOns/Plumber/Art/Cooldown/ThickCircle-Edge");
            f.SuccessGlow = f:CreateTexture(nil, "OVERLAY");
            f.SuccessGlow:SetSize(a, a);
            f.SuccessGlow:SetPoint("CENTER", f, "CENTER", 0, 0);
            f.SuccessGlow:SetTexture("Interface/AddOns/Plumber/Art/Cooldown/ThickCircle-SuccessGlow");
            f.SuccessGlow:Hide();
        end

        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);
        self:SetScript("OnEvent", self.OnEvent);

        self:Remove();
        self:UpdateFonts();
    end

    function Display:ListenSpellCastEvents(state)
        if state then
            self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
            self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player");
            self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
            self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
            self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
        else
            self:UnregisterEvent("UNIT_SPELLCAST_START");
            self:UnregisterEvent("UNIT_SPELLCAST_STOP");
            self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
            self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
            self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
        end
    end

    function Display:OnShow()
        if Settings.showCastBar then
            self:ListenSpellCastEvents(true);
        end
    end

    function Display:OnHide()
        self:Remove();
        self:ListenSpellCastEvents(false);
    end

    function Display:OnEvent(event, ...)
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unitTarget, castGUID, spellID = ...
            self.succeededSpellID = spellID;
        else
            if event == "UNIT_SPELLCAST_STOP" then
                if self.succeededSpellID == self.currentSpellID then
                    self:ShowCastSuccessVisual();
                else
                    self:UpdateCastingIndicator();
                end
                self.succeededSpellID = nil;
                self.currentSpellID = nil;
            else
                self:UpdateCastingIndicator();
            end
        end
    end

    local function SharedFadeIn_OnUpdate(self, elapsed)
        self.alpha = self.alpha + 8*elapsed;
        if self.alpha >= 1 then
            self.alpha = 1;
            self:SetScript("OnUpdate", nil);
        end
        self:SetAlpha(self.alpha);
    end

    function Display:ShowBlizzardInteractIcon(state)
        local nameplate = GetNamePlateForUnit("softinteract");
        if nameplate then
            nameplate.UnitFrame.SoftTargetFrame.Icon:SetShown(state)
        end
    end

    function Display:EditModeShowCastingIndicator(state)
        local f = self.CastingIndicator;
        if not f then return end;

        if state then
            if self:IsVisible() then
                local seconds = 1.5;
                f:SetCooldown(GetTime(), seconds);
                f:SetEdgeScale(self:GetEffectiveScale());
                f:SetDrawEdge(true);
                f:Resume();
                f.alpha = 0;
                f:SetAlpha(0);
                f:SetScript("OnUpdate", SharedFadeIn_OnUpdate);
                f:SetScript("OnCooldownDone", function()
                    self:ShowBlizzardInteractIcon(true);
                end);
                f.SuccessGlow:Hide();
                self:ShowBlizzardInteractIcon(false);
            end
        else
            f:SetScript("OnUpdate", nil);
            f:Hide();
            f.SuccessGlow:Hide();
            self:ShowBlizzardInteractIcon(true);
        end
    end

    function Display:UpdateCastingIndicator()
        self.currentSpellID = nil;
        self.succeededSpellID = nil;
        local _, _, _, startTime, endTime, _, castID, _, spellID = UnitCastingInfo("player");
        self.currentSpellID = spellID;
        if not startTime then
            _, _, _, startTime, endTime = UnitChannelInfo("player");
        end
        if startTime and endTime and (endTime - startTime) > 0.1 then
            self:ShowBlizzardInteractIcon(false);
            local duration = endTime - startTime;
            local f = self.CastingIndicator;
            f:SetCooldown(startTime / 1000.0, duration / 1000.0);
            f:SetEdgeScale(self:GetEffectiveScale());
            f:SetDrawEdge(true);
            f:Resume();
            f.alpha = 0;
            f:SetAlpha(0);
            f:SetScript("OnUpdate", SharedFadeIn_OnUpdate);
            f.SuccessGlow:Hide();
        else
            self:ShowBlizzardInteractIcon(true);
            self.CastingIndicator:Hide();
        end
    end

    local function SuccessVisual_OnUpdate(self, elapsed)
        self.alpha = self.alpha - 2 * elapsed;
        if self.alpha <= 0 then
            self.alpha = 0;
            self:SetScript("OnUpdate", nil);
            self:Hide();
        end
        self:SetAlpha(self.alpha);
    end

    function Display:ShowCastSuccessVisual()
        local f = self.CastingIndicator;
        f:Pause();
        local seconds = 100;
        local percentage = 1;
        f:SetCooldown(GetTime() - (seconds * percentage), seconds);
        f:SetDrawEdge(false);
        f.SuccessGlow:Show();
        f.alpha = 1;
        f:SetScript("OnUpdate", SuccessVisual_OnUpdate);
        self:ShowBlizzardInteractIcon(true);
    end

    function Display:OnUpdate(elapsed)
        self.alpha = self.alpha + 8*elapsed;
        if self.alpha >= 1 then
            self.alpha = 1;
            self:SetScript("OnUpdate", nil);
        end
        self:SetAlpha(self.alpha);
    end

    function Display:SetTitle(text, color, fontHeight)
        self.objectName = text;
        self.Title:SetText(text);
        self.Title:SetTextColor(color.r, color.g, color.b);
        self.Title:Show();
        if fontHeight then
            self.Title:SetFontHeight(fontHeight);
        end
    end

    function Display:SetSubtext(text, color, fontHeight)
        local fs = self.Subtext;
        fs:SetText(text);
        fs:SetTextColor(1, 1, 1);

        if fontHeight then
            fs:SetFontHeight(fontHeight);
        end

        if color then
            fs:SetTextColor(color.r, color.g, color.b);
        else
            fs:SetTextColor(1, 1, 1);
        end

        self.SubtextContainer:Show();
        self.SubtextContainer:SetScript("OnUpdate", SharedFadeIn_OnUpdate);
    end

    function Display:Remove()
        self:SetScript("OnUpdate", nil);
        self:SetParent(nil);
        self:Hide();
        self.alpha = 0;
        self:SetAlpha(0);
        if self.SubtextContainer then
            self.SubtextContainer.alpha = 0;
            self.SubtextContainer:SetAlpha(0);
            self.SubtextContainer:Hide();
        end
    end

    function Display:ShowFrame()
        self:SetScript("OnUpdate", self.OnUpdate);
        self:Show();
    end

    local function TooltipWatcher_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        if self.t >= 0.25 then
            self.t = 0;
            Display:UpdateTooltip();
        end
    end

    function Display:WatchTooltip(state)
        if state then
            self.TooltipWatcher.t = 0.25;
            self.TooltipWatcher:SetScript("OnUpdate", TooltipWatcher_OnUpdate);
        else
            self.TooltipWatcher:SetScript("OnUpdate", nil);
        end
    end

    function Display:UpdateTooltip()
        local tooltipInfo = GetWorldCursor();
        if tooltipInfo and tooltipInfo.lines then
            local numLines = #tooltipInfo.lines;
            for index, line in ipairs(tooltipInfo.lines) do
                if index == 1 then
                    if not (self.objectName and self.objectName == line.leftText) then
                        break
                    end
                else
                    if index == numLines and line.type == 8 then  --quest criteria
                        Display:SetSubtext(line.leftText, (self.unabled and Colors.UnabledColor) or line.leftColor, self.subtextFontHeight);
                    end
                end
            end
        end
    end

    function Display:LoadSettings()
        local GetDBBool = addon.GetDBBool;

        Settings.titleHeight, Settings.subtextHeight = unpack(addon.GetValidOptionChoice(Settings.FontSizes, "SoftTarget_FontSize"));
        Settings.iconSize = addon.GetValidOptionChoice(Settings.IconSizes, "SoftTarget_IconSize")
        Settings.showCastBar = GetDBBool("SoftTarget_CastBar");
        Settings.showObjectives = GetDBBool("SoftTarget_Objectives");
        Settings.textOutline = GetDBBool("SoftTarget_TextOutline");
        Settings.includeNPC = GetDBBool("SoftTarget_ShowNPC");

        if self.Init then return end;

        if self:IsVisible() then
            EL:ProcessSoftInteractNameplate();

            if Settings.showCastBar then
                self:ListenSpellCastEvents(true);
                self:UpdateCastingIndicator();
            else
                self:ListenSpellCastEvents(false);
                self.CastingIndicator:Hide();
            end
        end
    end
end


do  --EL
    function EL:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.03 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            self:ProcessSoftInteractNameplate();
        end
    end

    function EL:RequestUpdate()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function EL:ProcessSoftInteractNameplate()
        if Display.Init then
            Display:LoadSettings();
            Display:Init();
        end

        local nameplateEnabled = GetCVarBool("SoftTargetIconGameObject");
        if nameplateEnabled ~= self.nameplateEnabled then
            self.nameplateEnabled = nameplateEnabled;
            if not nameplateEnabled then
                if Display:IsShown() then
                    Display:Hide();
                end
                return
            end
        end

        local unit = "softinteract";
        local nameplate = GetNamePlateForUnit(unit);

        if nameplate and (UnitIsGameObject(unit) or (Settings.includeNPC and not UnitIsPlayer(unit))) then
            local f = nameplate.UnitFrame.SoftTargetFrame;
            if f:IsShown() then
                local unitID = GetUnitIDGeneral(unit);
                --print("GameObject:", unitID);
                if unitID and IgnoredGameObjects[unitID] then
                    Display:Hide();
                    return
                end

                local objectName = UnitName(unit);
                if objectName then
                    objectName = StripHyperlinks(objectName);
                end
                Display:ClearAllPoints();
                Display:SetParent(nameplate);
                Display:SetPoint("TOP", f.Icon, "BOTTOM", 0, -6);
                Display.SubtextContainer:Hide();
                Display:ShowFrame();

                local uiScale = UIParent:GetEffectiveScale() or 1;
                local fontHeight = Round(Settings.titleHeight*uiScale);

                SetUnitCursorTexture(Display.InteractIcon, unit);
                local textureFile = Display.InteractIcon:GetAtlas();

                --Icon size is determined by SoftTargetFrame
                f:SetSize(Settings.iconSize, Settings.iconSize);  --Game default: 24, Ours: 16
                --local textureFile = f.Icon:GetAtlas();

                if not textureFile then
                    textureFile = f.Icon:GetTexture();
                end

                --To determine if the interaction is in range:
                local unabled = (not textureFile) or string.find(string.lower(textureFile), "unable");
                Display.unabled = unabled;
                if unabled then
                    Display:SetTitle(objectName, Colors.UnabledColor, fontHeight);
                else
                    Display:SetTitle(objectName, Colors.Yellow, fontHeight);
                end
                self.softTargetUnit = unit;

                if nameplate.UnitFrame.name:IsShown() then
                    Display.Title:Hide();
                    Display.Background:Hide();
                else
                    Display.Background:Show();
                end
                --[[
                local guid = UnitGUID(unit);
                if guid then
                    TTI = C_TooltipInfo.GetHyperlink("unit:"..guid);    --debug, always nil
                end
                --]]

                local subtextFontHeight = Round(Settings.subtextHeight*uiScale);
                Display.subtextFontHeight = subtextFontHeight;

                if unitID and SpecialGameObjects[unitID] then
                    local subtext, color = SpecialGameObjects[unitID]();
                    if subtext then
                        Display:SetSubtext(subtext, color, subtextFontHeight);
                    end
                elseif Settings.showObjectives then
                    Display:UpdateTooltip();
                    Display:WatchTooltip(true);
                else
                    Display:WatchTooltip(false);
                end

                if Settings.showCastBar then
                    Display:UpdateCastingIndicator();
                end
            else
                Display:Hide();
            end

            --Fix the Elite icon on GameObject namepalte
            --CompactUnitFrame_UpdateClassificationIndicator(nameplate.UnitFrame);
            if nameplate.UnitFrame.classificationIndicator then
                nameplate.UnitFrame.classificationIndicator:Hide();
            end
        else
            Display:Hide();
        end
    end

    function EL:OnEvent(event, ...)
        if event == "PLAYER_SOFT_INTERACT_CHANGED" then
            local oldTarget, newTarget = ...
            if newTarget then
                self:RequestUpdate();
            else
                Display:Hide();
                self.softTargetUnit = nil;
            end
        end
    end
end


local OptionToggle_OnClick;
do  --Options, Settings
    Settings.FontSizes = {
        --{titleHeight, subtextHeight}
        {14, 12},
        {15, 13},
        {16, 14},
        {18, 16},
        {20, 18},
        {22, 20},
        {24, 22},
        {26, 24},
    };

    Settings.IconSizes = {
        14, 16, 18, 20, 22, 24, 26, 28,
    };

    local function Options_TextOutline_OnClick(self, state)
        Display:LoadSettings();
        Display:UpdateFonts();
    end

    local function Options_IconSizeSlider_OnValueChanged(value)
        addon.SetDBValue("SoftTarget_IconSize", value);
        Display:LoadSettings();
    end

    local function Options_FontSizeSlider_OnValueChanged(value)
        addon.SetDBValue("SoftTarget_FontSize", value);
        Display:LoadSettings();
    end

    local function Options_GenericSizeSlider_FormatValue(value)
        value = Round(value);
        return value
    end

    local function Options_ShowCastBar_OnClick(self, state)
        Display:LoadSettings();
        Display:EditModeShowCastingIndicator(state);
    end

    local function Options_ShowObjectives_OnClick(self, state)
        Display:LoadSettings();
    end

    local function Options_ShowObjectives_Tooltip()
        if GetCVarBool("SoftTargetTooltipInteract") then
            return L["SoftTargetName QuestObjective Tooltip"]
        else
            return L["SoftTargetName QuestObjective Tooltip"].."\n\n"..L["SoftTargetName QuestObjective Alert"]
        end
    end

    local function Options_ShowNPC_OnClick(self, state)
        Display:LoadSettings();
    end

    local OPTIONS_SCHEMATIC = {
        title = L["ModuleName SoftTargetName"],
        widgets = {
            {type = "Slider", label = L["Icon Size"], minValue = 1, maxValue = #Settings.IconSizes, valueStep = 1, onValueChangedFunc = Options_IconSizeSlider_OnValueChanged, formatValueFunc = Options_GenericSizeSlider_FormatValue, dbKey = "SoftTarget_FontSize"},
            {type = "Checkbox", label = L["TalkingHead Option TextOutline"], onClickFunc = Options_TextOutline_OnClick, dbKey = "SoftTarget_TextOutline"},
            {type = "Slider", label = L["Font Size"], minValue = 1, maxValue = #Settings.FontSizes, valueStep = 1, onValueChangedFunc = Options_FontSizeSlider_OnValueChanged, formatValueFunc = Options_GenericSizeSlider_FormatValue, dbKey = "SoftTarget_FontSize"},

            {type = "Divider"},
            {type = "Checkbox", label = L["SoftTargetName CastBar"], tooltip = L["SoftTargetName CastBar Tooltip"], onClickFunc = Options_ShowCastBar_OnClick, dbKey = "SoftTarget_CastBar"},
            {type = "Checkbox", label = L["SoftTargetName QuestObjective"], tooltip = Options_ShowObjectives_Tooltip, onClickFunc = Options_ShowObjectives_OnClick, dbKey = "SoftTarget_Objectives"},

            {type = "Divider"},
            --{type = "Header", label = L["SoftTargetName Option Condition Header"]};
            {type = "Checkbox", label = L["SoftTargetName ShowNPC"], tooltip = L["SoftTargetName ShowNPC Tooltip"], onClickFunc = Options_ShowNPC_OnClick, dbKey = "SoftTarget_ShowNPC"},
        },
    };

    function OptionToggle_OnClick(self, button)
        OptionFrame = addon.ToggleSettingsDialog(self, OPTIONS_SCHEMATIC);
        if OptionFrame then
            OptionFrame:ConvertAnchor();
        end
    end
end


do  --Module Registery
    local function EnableModule(state)
        if state and not EL.enabled then
            EL.enabled = true;
            EL:SetScript("OnEvent", EL.OnEvent);
            EL:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED");
            EL:ProcessSoftInteractNameplate();
        elseif (not state) and EL.enabled then
            EL.enabled = nil;
            EL:UnregisterEvent("PLAYER_SOFT_INTERACT_CHANGED");
            EL:SetScript("OnUpdate", nil);
            Display:Remove();
        end
    end

    local function DescriptionFunc()
        local value = C_CVar.GetCVar("SoftTargetInteract");
        value = value and tonumber(value) or 0;

        local desc;

        local function ConcatenateReq(index)
            if not desc then
                desc = L["SoftTargetName Req Title"];
            end
            desc = desc.."\n\n- "..L["SoftTargetName Req "..index];
        end

        if not (value == 2 or value == 3) then
            ConcatenateReq(1);
        end

        value = GetCVarBool("SoftTargetIconGameObject");
        if not value then
            ConcatenateReq(2);
        end

        return desc
    end

    local moduleData = {
        name = L["ModuleName SoftTargetName"],
        dbKey = "SoftTargetName",
        description = L["ModuleDescription SoftTargetName"],
        descriptionFunc = DescriptionFunc,
        toggleFunc = EnableModule,
        categoryID = 2,
        uiOrder = 9,
        optionToggleFunc = OptionToggle_OnClick,
        moduleAddedTime = 1756400000,
    };

    addon.ControlCenter:AddModule(moduleData);
end


do  --SpecialGameObjects
    local function SubtextFunc_Currency(currencyID, useMaxQuantity, requiredNumber)
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
        if currencyInfo then
            --local name = currencyInfo.name;
            local numOwned = currencyInfo.quantity;
            local icon = currencyInfo.iconFileID;
            local maxQuantity = useMaxQuantity and currencyInfo.maxQuantity or requiredNumber;
            local subtext = string.format("%d / %d |T%s:16:16|t", numOwned, maxQuantity, icon);
            local color;
            if (useMaxQuantity and numOwned >= currencyInfo.maxQuantity) or (requiredNumber and requiredNumber > numOwned) then
                color = Colors.Red;
            else
                color = Colors.White;
            end
            return subtext, color
        end
    end

    local function SubtextFunc_RestoredCofferKey()
        return SubtextFunc_Currency(3028, false, 1)
    end
    SpecialGameObjects[413590] = SubtextFunc_RestoredCofferKey;


    local function SubtextFunc_AncientMana()
        return SubtextFunc_Currency(1155, true)
    end
    SpecialGameObjects[252408] = SubtextFunc_AncientMana;   --Ancient Mana Shard +15
    SpecialGameObjects[252772] = SubtextFunc_AncientMana;   --Ancient Mana Shard +30
    SpecialGameObjects[252774] = SubtextFunc_AncientMana;   --Ancient Mana Shard +50 (item)
end