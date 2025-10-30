local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;


local VisualInfoGetter = {};
if C_UIWidgetManager and Enum.UIWidgetVisualizationType then
    local tbl = {
        TextWithState = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo,
        StatusBar = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo,
    };
    for key, func in pairs(tbl) do
        local widgetType = Enum.UIWidgetVisualizationType[key];
        if widgetType then
            VisualInfoGetter[widgetType] = func;
        end
    end
    tbl = nil;
end


local WidgetDisplayMixin = {};
do
    --Our widget is not driven by UPDATE_UI_WIDGET

    function WidgetDisplayMixin:SetWidgetSetID(widgetSetID)
        self.widgetSetID = widgetSetID;

        local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID);
        local primaryWidgetID;

        for _, widget in ipairs(widgets) do
            --debug
            --[[
            local widgetTypeName;
            for k, v in pairs(Enum.UIWidgetVisualizationType) do
                if widget.widgetType == v then
                    widgetTypeName = k;
                    break
                end
            end
            print(widget.widgetID, widget.widgetType, widgetTypeName);
            --]]

            if VisualInfoGetter[widget.widgetType] then
                primaryWidgetID = widget.widgetID;
                self.widgetID = primaryWidgetID;
                self.visualInfoGetter = VisualInfoGetter[widget.widgetType];
                self:SetInteractable(true);
                return
            end
        end
    end

    function WidgetDisplayMixin:Update()
        if self.widgetSetID and (not self.visualInfoGetter) then
            self:SetWidgetSetID(self.widgetSetID);
            return
        end

        if not self.visualInfoGetter then return end;

        local info = self.visualInfoGetter(self.widgetID);
        if info then
            local text;
            if info.barMax and info.barMax > 0 and info.barValue then
                text = info.barValue.."/"..info.barMax;
            end

            if info.text then
                if text then
                    text = info.text..": "..text;
                else
                    text = info.text;
                end
            end

            self.Text:SetText(text);
            local textWidth = self.Text:GetWrappedWidth();
            if textWidth < 48 then
                textWidth = 48;
            end
            self:SetWidth(textWidth);
        end
    end

    function WidgetDisplayMixin:ShowTooltip()
        if not self.visualInfoGetter then return end;
        local info = self.visualInfoGetter(self.widgetID);
        if info and info.tooltip and info.tooltip ~="" then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:SetText(info.tooltip, 1, 0.82, 0, 1, true);
            GameTooltip:Show();
        end
    end

    function WidgetDisplayMixin:OnShow()

    end

    function WidgetDisplayMixin:OnHide()

    end

    function WidgetDisplayMixin:OnEnter()
        self:UpdateVisual();
        self:ShowTooltip();
    end

    function WidgetDisplayMixin:OnLeave()
        self:UpdateVisual();
        GameTooltip:Hide();
    end

    function WidgetDisplayMixin:UpdateVisual()
        if self.interactable then
            if self:IsMouseMotionFocus() then
                self.Text:SetTextColor(1, 1, 1);
            else
                self.Text:SetTextColor(0.6, 0.6, 0.6);
            end
        else
            self.Text:SetTextColor(0.5, 0.5, 0.5);
        end
    end

    function WidgetDisplayMixin:SetInteractable(state)
        self.interactable = state;
        if state then
            self:SetScript("OnEnter", self.OnEnter);
            self:SetScript("OnLeave", self.OnLeave);
        else
            self:SetScript("OnEnter", nil);
            self:SetScript("OnLeave", nil);
        end
        self:UpdateVisual();
    end
end

function LandingPageUtil.CreateWidgetDisplay(parent, widgetSetID)
    local f = CreateFrame("Frame", nil, parent);
    f:SetSize(48, 24);
    API.Mixin(f, WidgetDisplayMixin);

    f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    f.Text:SetJustifyH("LEFT");
    f.Text:SetTextColor(0.5, 0.5, 0.5);
    f.Text:SetPoint("LEFT", f, "LEFT", 0, 0);

    f:SetScript("OnShow", f.OnShow);
    f:SetScript("OnHide", f.OnHide);

    if widgetSetID then
        f:SetWidgetSetID(widgetSetID);
    end

    return f
end