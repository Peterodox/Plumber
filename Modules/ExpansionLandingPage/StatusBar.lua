local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;


local GetReputationProgress = API.GetReputationProgress;


local StatusBarMixin = {};
do
    function StatusBarMixin:SetMinMaxValues(minVal, maxVal)
        self.minVal = minVal;
        self.maxVal = maxVal;
        self.threshold = maxVal - minVal;
    end

    function StatusBarMixin:SetValue(value)
        value = API.Clamp(value, self.minVal, self.maxVal);
        self.value = value;
        local percent = (value - self.minVal) / (self.maxVal - self.minVal);
        self:SetFillPercent(percent);

        self.ValueText:SetText(value.." / "..self.threshold);
    end

    function StatusBarMixin:SetBarColor(r, g, b)
        self.FillLeft:SetVertexColor(r, g, b);
        self.FillCenter:SetVertexColor(r, g, b);
        self.FillRight:SetVertexColor(r, g, b);
    end

    function StatusBarMixin:SetFillPercent(a)
        local width = self.Bar:GetWidth();
        local fillWidth = a * width;

        self.FillMask:SetPoint("CENTER", self.Fill, "LEFT", fillWidth, 0);
        self.FillSurface:SetPoint("RIGHT", self.Fill, "LEFT", fillWidth, 0);

        self.FillSurface:SetShown(fillWidth >= 6);

        --[[
        if a <= 0 then
            self.FillLeft:Hide();
            self.FillCenter:Hide();
            self.FillRight:Hide();
            self.FillSurface:Hide();
        else
            self.FillSurface:SetShown(a < 1);
            if fillWidth > 6 then
                self.FillLeft:Show();
                self.FillCenter:Show();
                self.FillLeft:SetTexCoord(0, 12/512, 18/512, 30/512);
                self.FillLeft:SetWidth(6);
                self.FillCenter:SetTexCoord(12/512, 256 * a/512, 18/512, 30/512);
                self.FillCenter:SetWidth(fillWidth - 6);
            else
                self.FillLeft:Show();
                self.FillCenter:Hide();
                self.FillLeft:SetWidth(fillWidth);
                self.FillLeft:SetTexCoord(0, 256 * a/512, 18/512, 30/512);
            end

            if fillWidth > (width - 6) then
                self.FillRight:Show();
                self.FillRight:SetWidth(6 - width + fillWidth);
                self.FillRight:SetTexCoord(244/512, 256 * a/512, 18/512, 30/512);
                self.FillCenter:SetTexCoord(12/512, 244/512, 18/512, 30/512);
                self.FillCenter:ClearAllPoints();
                self.FillCenter:SetPoint("TOPLEFT", self.FillLeft, "TOPRIGHT", 0, 0);
                self.FillCenter:SetPoint("BOTTOMRIGHT", self.FillRight, "BOTTOMLEFT", 0, 0);
            else
                self.FillRight:Hide();
                if fillWidth > 6 then
                    self.FillCenter:ClearAllPoints();
                    self.FillCenter:SetPoint("TOPLEFT", self.FillLeft, "TOPRIGHT", 0, 0);
                    self.FillCenter:SetPoint("BOTTOMLEFT", self.FillLeft, "BOTTOMRIGHT", 0, 0);
                    self.FillCenter:SetHeight(6);
                end
            end
        end
        --]]
    end

    function StatusBarMixin:UpdateVisual()
        if self:IsMouseMotionFocus() then
            self.Label:SetTextColor(1, 1, 1);
            self.ValueText:Show();
        else
            self.Label:SetTextColor(0.922, 0.871, 0.761);
            self.ValueText:Hide();
        end
    end

    function StatusBarMixin:SetFaction(factionID)
        self.factionID = factionID;
        self:Refresh();
    end

    function StatusBarMixin:SetPaddingH(paddingH)
        self.Label:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", paddingH, 10);
        self.RightText:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -paddingH, 10);
        self.Bar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", paddingH, 0);
        self.Bar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -paddingH, 0);
    end

    function StatusBarMixin:Refresh()
        local factionID = self.factionID;
        if not factionID then return end;

        local currentValue, maxValue;
        local progress = GetReputationProgress(factionID);
        if progress then
            self.Label:SetText(progress.name);
            self.reputationType = progress.reputationType;

            if progress.isFull then
                local paragonLevel;
                currentValue, maxValue, paragonLevel = API.GetParagonValuesAndLevel(factionID);
            else
                currentValue, maxValue = progress.currentValue, progress.maxValue;
            end

            if progress.reaction then
                local standingText = API.GetReputationStandingText(progress.reaction);
                self.RightText:SetText(standingText);
            end

            if progress.level then
                local r, g, b;
                if progress.level < 0 then
                    --Below Neutral
                    r, g, b = 203/255, 99/255, 95/255;
                elseif progress.level < 1 then
                    --Neutral
                    r, g, b = 184/255, 159/255, 92/255;
                elseif progress.level < 3 then
                    --Friendly, Honored
                    r, g, b = 118/255, 177/255, 125/255;
                elseif progress.level < 4 then
                    --Revered
                    r, g, b = 92/255, 179/255, 149/255;
                else
                    --Exalted
                    r, g, b = 92/255, 179/255, 178/255;
                end
                self.RightText:SetTextColor(r, g, b);
                self:SetBarColor(r, g, b);
            end
        else
            self.reputationType = 0;
            currentValue = 0;
            maxValue = 1;
        end

        self:SetMinMaxValues(0, maxValue);
        self:SetValue(currentValue);
    end

    function StatusBarMixin:OnEnter()
        self:UpdateVisual();
        if self.Label:IsTruncated() or self.appendTooltipFunc then
            local tooltip = GameTooltip;
            tooltip:SetOwner(self, "ANCHOR_RIGHT");
            tooltip:SetText(self.Label:GetText(), 1, 1, 1, 1, true);
            if self.appendTooltipFunc then
                self.appendTooltipFunc(tooltip);
            end
            tooltip:Show();
        end
    end

    function StatusBarMixin:OnLeave()
        self:UpdateVisual();
        GameTooltip:Hide();
    end

    local function CreateStatusBar(parent)
        local f = CreateFrame("Frame", nil, parent);
        API.Mixin(f, StatusBarMixin);
        f:SetSize(128, 24);

        local Bar = CreateFrame("Frame", nil, f);
        f.Bar = Bar;
        Bar:SetUsingParentLevel(true);
        Bar:SetSize(128, 6);
        Bar:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0);
        Bar:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);

        local Fill = CreateFrame("Frame", nil, f);
        f.Fill = Fill;
        Fill:SetSize(128, 6);
        Fill:SetPoint("BOTTOMLEFT", f.Bar, "BOTTOMLEFT", 0, 0);
        Fill:SetPoint("BOTTOMRIGHT", f.Bar, "BOTTOMRIGHT", 0, 0);

        local file = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/StatusBar";

        API.SetupThreeSliceBackground(Bar, file, 0, 0);
        Bar.Left:SetSize(6, 6);
        Bar.Right:SetSize(6, 6);

        Bar.Left:SetTexCoord(0, 12/512, 2/512, 14/512);
        Bar.Center:SetTexCoord(12/512, 244/512, 2/512, 14/512);
        Bar.Right:SetTexCoord(244/512, 256/512, 2/512, 14/512);

        Bar.Left:SetVertexColor(0.5, 0.5, 0.5, 0.2);
        Bar.Center:SetVertexColor(0.5, 0.5, 0.5, 0.2);
        Bar.Right:SetVertexColor(0.5, 0.5, 0.5, 0.2);

        API.SetupThreeSliceBackground(Fill, file, 0, 0);
        f.FillLeft = Fill.Left;
        f.FillCenter = Fill.Center;
        f.FillRight = Fill.Right;
        Fill.Left:SetSize(6, 6);
        Fill.Right:SetSize(6, 6);

        Fill.Left:SetTexCoord(0, 12/512, 18/512, 30/512);
        Fill.Center:SetTexCoord(12/512, 244/512, 18/512, 30/512);
        Fill.Right:SetTexCoord(244/512, 256/512, 18/512, 30/512);


        local Surface = Fill:CreateTexture(nil, "OVERLAY");
        f.FillSurface = Surface;
        Surface:SetSize(8, 6);
        Surface:SetTexture(file);
        Surface:SetTexCoord(257/512, 273/512, 2/512, 14/512);
        Surface:SetAlpha(0.67);


        local FillMask = Fill:CreateMaskTexture(nil, "BACKGROUND");
        f.FillMask = FillMask;
        FillMask:SetSize(16, 16);
        FillMask:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/StatusBarMask", "CLAMP", "CLAMP");
        Fill.Left:AddMaskTexture(FillMask);
        Fill.Center:AddMaskTexture(FillMask);
        Fill.Right:AddMaskTexture(FillMask);


        local ValueText = Fill:CreateFontString(nil, "OVERLAY", "PlumberFont_StatusBarValue", 2);
        f.ValueText = ValueText;
        ValueText:SetPoint("CENTER", Fill, "CENTER", 0, 0);
        ValueText:Hide();


        local RightText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.RightText = RightText;
        RightText:SetJustifyH("RIGHT");
        RightText:SetJustifyV("BOTTOM");
        RightText:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 10);
        RightText:SetTextColor(0.5, 0.5, 0.5);
        RightText:SetText("Honored");
        RightText:SetMaxLines(1);

        local Label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Label = Label;
        Label:SetJustifyH("LEFT");
        Label:SetJustifyV("BOTTOM");
        Label:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 10);
        Label:SetPoint("BOTTOMRIGHT", RightText, "BOTTOMLEFT", -10, 0);
        Label:SetTextColor(0.922, 0.871, 0.761);
        Label:SetText("Label");
        Label:SetMaxLines(1);


        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);

        return f
    end
    LandingPageUtil.CreateStatusBar = CreateStatusBar;
end