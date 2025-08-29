-- Requisite: /console SoftTargetIconGameObject 1


local _, addon = ...
local API = addon.API;
local Round = API.Round;


local UIParent = UIParent;
local UnitName = UnitName;
local UnitIsPlayer = UnitIsPlayer;
local StripHyperlinks = StripHyperlinks;
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;
local GetCVarBool = C_CVar.GetCVarBool;
local GetWorldCursor = C_TooltipInfo.GetWorldCursor;


local Display = CreateFrame("Frame");
local EL = CreateFrame("Frame");

local Colors = {
    Yellow = {r = 1, g = 0.82, b = 0},
    UnabledColor = {r = 0.6, g= 0.6, b = 0.6},
}


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
            self.DisplayedName = Display:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
            self.DisplayedName:SetPoint("TOP", self, "TOP", 0, 0);
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

        self:Remove();
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
        if self.t > 0.1 then
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
                    Display:Remove();
                end
                return
            end
        end

        local unit = "softinteract";
        local nameplate = GetNamePlateForUnit(unit);

        if nameplate and not UnitIsPlayer(unit) then
            local f = nameplate.UnitFrame.SoftTargetFrame;
            if f:IsShown() then
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

                --Icon size is determined by SoftTargetFrame
                f:SetSize(18, 18);  --default 24, 24
                local textureFile = f.Icon:GetAtlas();
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
                                fontHeight = Round(13*uiScale);
                                Display:SetSubtext(line.leftText, (unabled and Colors.UnabledColor) or line.leftColor, fontHeight);
                            end
                        end
                    end
                end
            else
                Display:Remove();
            end

            --Fix the Elite icon on GameObject namepalte
            --CompactUnitFrame_UpdateClassificationIndicator(nameplate.UnitFrame);
            if nameplate.UnitFrame.classificationIndicator then
                nameplate.UnitFrame.classificationIndicator:Hide();
            end
        else
            Display:Remove();
        end
    end

    function EL:OnEvent(event, ...)
        if event == "PLAYER_SOFT_INTERACT_CHANGED" then
            local oldTarget, newTarget = ...
            if newTarget then
                self:RequestUpdate();
            else
                Display:Remove();
                self.softTargetUnit = nil;
            end
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
                desc = addon.L["SoftTargetName Req Title"];
            end
            desc = desc.."\n\n- "..addon.L["SoftTargetName Req "..index];
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
        name = addon.L["ModuleName SoftTargetName"],
        dbKey = "SoftTargetName",
        description = addon.L["ModuleDescription SoftTargetName"],
        descriptionFunc = DescriptionFunc,
        toggleFunc = EnableModule,
        categoryID = 2,
        uiOrder = 9,
        moduleAddedTime = 1756400000,
    };

    addon.ControlCenter:AddModule(moduleData);
end