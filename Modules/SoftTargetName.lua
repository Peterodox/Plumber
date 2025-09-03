-- Requisite: /console SoftTargetIconGameObject 1


local _, addon = ...
local API = addon.API;
local L = addon.L;
local Round = API.Round;


local UIParent = UIParent;
local UnitName = UnitName;
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
}


local IgnoredGameObjects = {
    [35591] = true,     --Fish Bobber (Other bobbers may have different ids)
};

local SpecialGameObjects = {};


do  --Display
    Display:Hide();
    Display:SetSize(16, 16);
    Display:SetIgnoreParentScale(true);


    local function CreateTextBackground(fontString, height, extensionX)
        height = height or 32;
        extensionX = extensionX or 16;
        local bg = Display:CreateTexture(nil, "BACKGROUND");
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

    function Display:Init()
        self.Init = nil;

        if not self.DisplayedName then
            self.DisplayedName = Display:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            self.DisplayedName:SetPoint("TOP", self, "TOP", 0, 0);
            local file, height, flags = GameFontNormal:GetFont();
            self.DisplayedName:SetFont(file, height, "OUTLINE");
            self.DisplayedName:SetShadowOffset(0, 0);
        end

        if not self.Background then
            self.Background = CreateTextBackground(self.DisplayedName, 30);
        end

        if not self.subtextPool then
            local function Subtext_Create()
                local fs = Display:CreateFontString(nil, "OVERLAY", "SystemFont_Tiny");
                fs:SetShadowOffset(1, -1);
                fs:SetShadowColor(0, 0, 0);
                fs.Background = CreateTextBackground(fs, 28, 12);
                return fs
            end

            local function Subtext_OnRemove(fs)
                fs.Background:Hide();
            end

            self.subtextPool = API.CreateObjectPool(Subtext_Create, Subtext_OnRemove);
        end

        local iconOffsetY = 16;

        if not self.InteractIcon then
            self.InteractIcon = self:CreateTexture(nil, "ARTWORK");
            self.InteractIcon:SetSize(18, 18);
            self.InteractIcon:SetPoint("CENTER", self, "TOP", 0, iconOffsetY);
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
    end

    function Display:OnShow()
        self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
        self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player");
        self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
        self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
        self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
    end

    function Display:OnHide()
        self:Remove();
        self:UnregisterEvent("UNIT_SPELLCAST_START");
        self:UnregisterEvent("UNIT_SPELLCAST_STOP");
        self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
        self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
        self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
    end

    function Display:OnEvent(event, ...)
        print(event)
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

    function Display:UpdateCastingIndicator()
        self.currentSpellID = nil;
        self.succeededSpellID = nil;
        local _, _, _, startTime, endTime, _, castID, _, spellID = UnitCastingInfo("player");
        self.currentSpellID = spellID;
        if not startTime then
            _, _, _, startTime, endTime = UnitChannelInfo("player");
        end
        if startTime and endTime and (endTime - startTime) > 0.1 then
            self.InteractIcon:Hide();
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
            self.InteractIcon:Show();
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
        self.InteractIcon:Show();
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
        self.DisplayedName:SetText(text);
        self.DisplayedName:SetTextColor(color.r, color.g, color.b);

        if fontHeight then
            self.DisplayedName:SetFontHeight(fontHeight);
        end
    end

    function Display:SetSubtext(text, color, fontHeight)
        self.subtextPool:Release();
        local fs = self.subtextPool:Acquire();
        fs:SetText(text);
        fs:SetTextColor(1, 1, 1);
        fs.Background:Show();
        fs:ClearAllPoints();
        fs:SetPoint("TOP", self.DisplayedName, "BOTTOM", 0, -2);

        if fontHeight then
            fs:SetFontHeight(fontHeight);
        end

        if color then
            fs:SetTextColor(color.r, color.g, color.b);
        else
            fs:SetTextColor(1, 1, 1);
        end
    end

    function Display:Remove()
        self:SetScript("OnUpdate", nil);
        self:SetParent(nil);
        self:Hide();
        self.alpha = 0;
        self:SetAlpha(0);
        self:ClearAllPoints();
        if self.subtextPool then
            self.subtextPool:Release();
        end
    end

    function Display:ShowFrame()
        self:SetScript("OnUpdate", self.OnUpdate);
        self:Show();
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

        if nameplate and UnitIsGameObject(unit) then
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
                Display.subtextPool:Release();
                Display:ShowFrame();

                local uiScale = UIParent:GetEffectiveScale() or 1;
                local fontHeight = Round(15*uiScale);

                SetUnitCursorTexture(Display.InteractIcon, unit);
                local textureFile = Display.InteractIcon:GetAtlas();
                if f.Icon then
                    f.Icon:SetAlpha(0);
                end
                --Icon size is determined by SoftTargetFrame
                --f:SetSize(18, 18);  --default 24, 24
                --local textureFile = f.Icon:GetAtlas();

                if not textureFile then
                    textureFile = f.Icon:GetTexture();
                end

                --To determine if the interaction is in range:
                local unabled = (not textureFile) or string.find(string.lower(textureFile), "unable");
                if unabled then
                    Display:SetTitle(objectName, Colors.UnabledColor, fontHeight);
                else
                    Display:SetTitle(objectName, Colors.Yellow, fontHeight);
                end
                self.softTargetUnit = unit;

                --[[
                local guid = UnitGUID(unit);
                if guid then
                    TTI = C_TooltipInfo.GetHyperlink("unit:"..guid);    --debug, always nil
                end
                --]]

                local subtextFontHeight = Round(13*uiScale);

                if unitID and SpecialGameObjects[unitID] then
                    local subtext, color = SpecialGameObjects[unitID]();
                    if subtext then
                        Display:SetSubtext(subtext, color, subtextFontHeight);
                    end
                else
                    local tooltipInfo = GetWorldCursor();
                    if tooltipInfo and tooltipInfo.lines then
                        local numLines = #tooltipInfo.lines;
                        for index, line in ipairs(tooltipInfo.lines) do
                            if index == 1 then
                                if not (objectName == line.leftText) then
                                    break
                                end
                            else
                                if index == numLines and line.type == 8 then  --quest criteria
                                    Display:SetSubtext(line.leftText, (unabled and Colors.UnabledColor) or line.leftColor, subtextFontHeight);
                                end
                            end
                        end
                    end
                end

                Display:UpdateCastingIndicator();
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
do  --Options
    local function Options_TextOutline_OnClick(self, state)

    end

    local function Options_FontSizeSlider_OnValueChanged(value)
        print(value)
    end

    local function Options_FontSizeSlider_FormatValue(value)
        value = API.Round(value);
        return value
    end

    local function Options_CastBar_OnClick(self, state)
        
    end

    local function Options_Objectives_OnClick(self, state)

    end

    local function Options_ShowNPC_OnClick(self, state)

    end

    local OPTIONS_SCHEMATIC = {
        title = L["ModuleName SoftTargetName"],
        widgets = {
            {type = "Checkbox", label = L["TalkingHead Option TextOutline"], onClickFunc = Options_TextOutline_OnClick, dbKey = "SoftTarget_TextOutline"},
            {type = "Slider", label = L["Font Size"], minValue = 1, maxValue = 4, valueStep = 1, onValueChangedFunc = Options_FontSizeSlider_OnValueChanged, formatValueFunc = Options_FontSizeSlider_FormatValue, dbKey = "SoftTarget_FontSize"},

            {type = "Divider"},
            {type = "Checkbox", label = L["SoftTargetName CastBar"], tooltip = L["SoftTargetName CastBar Tooltip"], onClickFunc = Options_CastBar_OnClick, dbKey = "SoftTarget_CastBar"},
            {type = "Checkbox", label = L["SoftTargetName QuestObjective"], tooltip = L["SoftTargetName QuestObjective Tooltip"], onClickFunc = Options_Objectives_OnClick, dbKey = "SoftTarget_Objectives"},

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
    local function SubtextFunc_RestoredCofferKey()
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(3028);
        if currencyInfo then
            --local name = currencyInfo.name;
            local numOwned = currencyInfo.quantity;
            local icon = currencyInfo.iconFileID;
            local subtext = string.format("%d / %d |T%s:16:16|t", numOwned, 1, icon);
            return subtext, (numOwned >= 1 and Colors.White) or Colors.Red
        end
    end

    SpecialGameObjects[413590] = SubtextFunc_RestoredCofferKey;
end