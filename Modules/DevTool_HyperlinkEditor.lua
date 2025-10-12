local _, addon = ...
local API = addon.API;


local Editor = {};
local EditBoxUtil = {};

local Constants = {
    EditBoxWidth = 64,
    EditBoxHeight = 16,
    EditBoxGap = 4,
    NumberFont = "Fonts\\ARIALN.TTF",
    NumberHeight = 12,
};


local ReceptorMixin = {};
do
    function ReceptorMixin:OnClick()
        local infoType, arg1, arg2, arg3 = GetCursorInfo();
        if not infoType then return end;

        if infoType == "item" then
            local itemID, itemLink = arg1, arg2;
            Editor:SetHyperlink(itemLink);
        end

        ClearCursor();
    end

    function ReceptorMixin:OnReceiveDrag()
        ReceptorMixin.OnClick(self);
    end
end

do
    function Editor:Update()
        local hyperlink = self:GetModifiedInput()
        self:SetHyperlink(hyperlink);
    end

    function Editor:SetHyperlink(hyperlink)
        local itemID, _, _, _, icon = C_Item.GetItemInfoInstant(hyperlink);
        self.Receptor.Icon:SetTexture(icon);

        if not itemID then return end;

        self.hyperlink = hyperlink;
        self.Tooltip:Hide();
        self.Tooltip:SetOwner(self.Receptor, "ANCHOR_NONE");
        self.Tooltip:SetPoint("BOTTOM", self.Receptor, "TOP", 0, 8);
        self.Tooltip:SetHyperlink(hyperlink);
        self.Tooltip:Show();

        self.oldValues = {};
        self.ObjectPool:Release();
        local segs = {strsplit(":", hyperlink)};
        local value, editbox;
        local n = 0;
        local offsetX = 0;
        self.maxIndex = #segs;

        for i, seg in ipairs(segs) do
            self.oldValues[i] = seg;
            value = seg ~= "" and tonumber(seg) or 0;
            if value ~= 0 then
                editbox = self.ObjectPool:Acquire();
                editbox.index = i;
                editbox.oldText = value;
                editbox:SetNumber(value);
                editbox:SetPoint("LEFT", self.MainFrame, "LEFT", offsetX, 0, 0);
                offsetX = offsetX + Constants.EditBoxWidth + Constants.EditBoxGap;
                if i == self.lastEditPosition then
                    editbox:SetFocus();
                end
                n = n + 1;
            end
        end

        self.lastEditPosition = nil;

        local spanX = n * (Constants.EditBoxWidth + Constants.EditBoxGap) - Constants.EditBoxGap;
        self.MainFrame:SetWidth(spanX);

        self.OutputBox:SetText(string.match(hyperlink, "|H([^|]+)"));
        self.OutputBox:SetCursorPosition(0);
    end


    function Editor:Init()
        if self.MainFrame then return end;

        local f = CreateFrame("Frame", nil, UIParent);
        self.MainFrame = f;
        f:Hide();
        f:SetSize(800, 32);
        f:SetPoint("TOP", UIParent, "CENTER", 0, 0);

        local Tooltip = CreateFrame("GameTooltip", "PlumberDevToolTooltip", f, "SharedTooltipTemplate");
        self.Tooltip = Tooltip;
        local TooltipDataMixin = CreateFromMixins(TooltipDataHandlerMixin);
        Mixin(Tooltip, TooltipDataMixin);
        Tooltip:Hide();

        f:SetScript("OnShow", function()
            f:RegisterEvent("TOOLTIP_DATA_UPDATE");
        end);

        f:SetScript("OnHide", function()
            f:UnregisterEvent("TOOLTIP_DATA_UPDATE");
        end);

        f:SetScript("OnEvent", function(self, event, ...)
            if event == "TOOLTIP_DATA_UPDATE" then
                local dataInstanceID = ...
                if dataInstanceID and Tooltip:HasDataInstanceID(dataInstanceID) then
                    Tooltip:RebuildFromTooltipInfo();
                end
            end
        end);


        local Receptor = CreateFrame("Button", nil, f);
        self.Receptor = Receptor;
        Receptor:SetSize(40, 40);
        Receptor:SetPoint("BOTTOM", f, "TOP", 0, 16);
        Receptor:SetScript("OnClick", ReceptorMixin.OnClick);
        Receptor:SetScript("OnReceiveDrag", ReceptorMixin.OnReceiveDrag);

        Receptor.Background = Receptor:CreateTexture(nil, "BACKGROUND");
        Receptor.Background:SetColorTexture(0.08, 0.08, 0.08, 0.9);
        Receptor.Background:SetAllPoints(true);

        Receptor.Highlight = Receptor:CreateTexture(nil, "HIGHLIGHT");
        Receptor.Highlight:SetAllPoints(true);
        Receptor.Highlight:SetColorTexture(1, 1, 1, 0.2);

        Receptor.Icon = Receptor:CreateTexture(nil, "ARTWORK");
        Receptor.Icon:SetAllPoints(true);


        self.ObjectPool = API.CreateObjectPool(EditBoxUtil.CreateEditBox);


        local OutputBox = CreateFrame("EditBox", nil, f);
        self.OutputBox = OutputBox;
        OutputBox:SetPoint("TOP", f, "BOTTOM", 0, -16);
        OutputBox:SetSize(240, Constants.EditBoxHeight);
        OutputBox:SetAutoFocus(false);
        OutputBox:SetFont(Constants.NumberFont, Constants.NumberHeight, "");
        OutputBox:SetTextColor(1, 1, 1);
        OutputBox:SetJustifyH("CENTER");
        OutputBox:SetTextInsets(4, 4, 0, 0);
        OutputBox.Background = OutputBox:CreateTexture(nil, "BACKGROUND");
        OutputBox.Background:SetAllPoints(true);
        OutputBox.Background:SetColorTexture(0.08, 0.08, 0.08, 0.9);
        OutputBox:SetScript("OnEnterPressed", OutputBox.ClearFocus);
        OutputBox:SetScript("OnEscapePressed", OutputBox.ClearFocus);
        OutputBox:SetScript("OnEditFocusLost", function()
            OutputBox:ClearHighlightText();
        end);
        OutputBox:SetScript("OnEditFocusGained", function()
            OutputBox:HighlightText();
        end);
    end

    function Editor:GetModifiedInput()
        local editboxValues = {};
        for _, editbox in ipairs(self.ObjectPool:GetActiveObjects()) do
            editboxValues[editbox.index] = editbox:GetValueText();
        end

        local hyperlink;
        for i = 1, self.maxIndex do
            if i == 1 then
                hyperlink = self.oldValues[i];
            else
                if editboxValues[i] then
                    hyperlink = hyperlink..":"..editboxValues[i];
                else
                    hyperlink = hyperlink..":"..self.oldValues[i];
                end
            end
        end

        return hyperlink
    end
end


do
    local EditBoxMixin = {};

    function EditBoxMixin:OnEnterPressed()
        self:ClearFocus();
        Editor:Update();
    end

    function EditBoxMixin:OnEscapePressed()
        self:ClearFocus();
        self:SetText(self.oldText);
        Editor:Update();
    end

    function EditBoxMixin:OnEditFocusLost()
        self:ClearHighlightText();
    end

    function EditBoxMixin:OnArrowPressed(key)
        local value = self:GetNumber();
        if key == "UP" then
            value = value + 1;
        elseif key == "DOWN" then
            if value <= 0 then
                return
            end
            value = value - 1;
        end
        self:SetNumber(value);
        Editor.lastEditPosition = self.index;
        Editor:Update();
    end

    function EditBoxMixin:GetValueText()
        local value = self:GetNumber() or 0;
        if value == 0 then
            return ""
        else
            return value
        end
    end

    function EditBoxUtil.CreateEditBox()
        local f = CreateFrame("EditBox", nil, Editor.MainFrame);
        f:SetAutoFocus(false);
        f:SetNumeric(true);
        f:SetSize(Constants.EditBoxWidth, Constants.EditBoxHeight);
        f:SetFont(Constants.NumberFont, Constants.NumberHeight, "");
        f:SetTextColor(1, 1, 1);
        f:SetJustifyH("CENTER");
        f.Background = f:CreateTexture(nil, "BACKGROUND");
        f.Background:SetAllPoints(true);
        f.Background:SetColorTexture(0.08, 0.08, 0.08, 0.9);
        Mixin(f, EditBoxMixin);
        f:SetScript("OnEnterPressed", f.OnEnterPressed);
        f:SetScript("OnEscapePressed", f.OnEscapePressed);
        f:SetScript("OnArrowPressed", f.OnArrowPressed);
        f:SetScript("OnEditFocusLost", f.OnEditFocusLost);
        return f
    end
end

local function ToggleHyperlinkEditor()
    if not Editor.MainFrame then
        Editor:Init();
    end
    Editor.MainFrame:SetShown(not Editor.MainFrame:IsShown());
end

_G.Plumber_ToggleHyperlinkEditor = ToggleHyperlinkEditor;