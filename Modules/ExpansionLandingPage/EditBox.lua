local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;
local StringTrim = API.StringTrim;


local After = C_Timer.After;


local EditBoxMixin = {};
do
    function EditBoxMixin:OnEnable()
        self:UpdateVisual();
    end

    function EditBoxMixin:OnDisable()
        self:UpdateVisual();
    end

    function EditBoxMixin:UpdateVisual()
        if self:IsEnabled() then
            local alpha = 0.25;
            if self:HasFocus() then
                alpha = 0.6;
                self:SetTextColor(1, 1, 1);
            elseif self:IsMouseMotionFocus() then
                self:SetTextColor(1, 1, 1);
            else
                self:SetTextColor(0.922, 0.871, 0.761);
            end
            self.HighlightLeft:SetAlpha(alpha);
            self.HighlightCenter:SetAlpha(alpha);
            self.HighlightRight:SetAlpha(alpha);
            self.Left:SetDesaturated(false);
            self.Center:SetDesaturated(false);
            self.Right:SetDesaturated(false);
            self.Left:SetVertexColor(1, 1, 1);
            self.Center:SetVertexColor(1, 1, 1);
            self.Right:SetVertexColor(1, 1, 1);
        else
            self:SetTextColor(0.5, 0.5, 0.5);
            self.Left:SetDesaturated(true);
            self.Center:SetDesaturated(true);
            self.Right:SetDesaturated(true);
            self.Left:SetVertexColor(0.5, 0.5, 0.5);
            self.Center:SetVertexColor(0.5, 0.5, 0.5);
            self.Right:SetVertexColor(0.5, 0.5, 0.5);
            self.HighlightLeft:SetAlpha(0);
            self.HighlightCenter:SetAlpha(0);
            self.HighlightRight:SetAlpha(0);
        end
    end

    function EditBoxMixin:OnEnter()
        self:UpdateVisual();

        local tooltipText;
        if self:IsEnabled() then
            
        else
            tooltipText = self.disabledTooltipText;
        end

        if tooltipText then
            local tooltip = GameTooltip;
            tooltip:SetOwner(self, "ANCHOR_RIGHT");
            tooltip:SetText(tooltipText, 1, 1, 1, 1, true);
            tooltip:Show();
        end
    end

    function EditBoxMixin:OnLeave()
        self:UpdateVisual();
        GameTooltip:Hide();
    end

    function EditBoxMixin:OnHide()
        self.t = nil;
        self:SetScript("OnUpdate", nil);
    end

    function EditBoxMixin:UpdateText()
        local text = self:GetText();
        text = StringTrim(text);
        self:SetText(text or "");
        if text then
            self.Instruction:Hide();
        else
            self.Instruction:Show();
        end
    end

    function EditBoxMixin:OnEditFocusLost()
        self.Magnifier:SetVertexColor(0.5, 0.5, 0.5);
        self:UpdateText();
        self:UnlockHighlight();
        self:UpdateVisual();

        if self.onEditFocusLostCallback then
            self.onEditFocusLostCallback(self);
        end
    end

    function EditBoxMixin:OnEditFocusGained()
        self.Instruction:Hide();
        self.Magnifier:SetVertexColor(1, 1, 1);
        self:LockHighlight();
        self:UpdateVisual();
        if self.onEditFocusGainedCallback then
            self.onEditFocusGainedCallback(self);
        end
    end

    function EditBoxMixin:UpdateTextInsets()
        local leftOffset;
        if self.isSearchbox then
            leftOffset = 28;
        else
            leftOffset = 8;
        end
        self:SetTextInsets(leftOffset, 8, 0, 0);
        After(0, function()
            self:SetTextInsets(leftOffset, 8, 0, 0);
        end);
    end

    function EditBoxMixin:SetIsSearchBox(state)
        self.isSearchbox = state;
        local leftOffset;
        if state then
            self.Magnifier:Show();
            leftOffset = 28;
        else
            self.Magnifier:Hide();
            leftOffset = 8;
        end
        --self:SetTextInsets(leftOffset, 8, 0, 0);    --May not function until next update
        self.Instruction:SetPoint("LEFT", self, "LEFT", leftOffset, 0);
        self:UpdateText();
        self:UpdateVisual();
        self:UpdateTextInsets();
    end

    function EditBoxMixin:SetInstruction(text)
        self.Instruction:SetText(text);
    end

    function EditBoxMixin:OnEscapePressed()
        self:ClearFocus();
    end

    function EditBoxMixin:SetSearchResultMenu(searchResultMenu)
        self.searchResultMenu = searchResultMenu;
    end

    function EditBoxMixin:OnEnterPressed()
        self:ClearFocus();
        if self.isSearchbox then
            if self.searchResultMenu then
                return self.searchResultMenu:SelectFirstResult();
            end
        end
    end

    function EditBoxMixin:OnTextChanged(userInput)
        if userInput and self.hasOnTextChangeCallback then
            self.t = 0;
            self:SetScript("OnUpdate", self.OnUpdate);
        end
    end

    function EditBoxMixin:TriggerOnTextChanged()
        self:OnTextChanged(true);
    end

    function EditBoxMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.2 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            if self.searchFunc then
                if self:IsNumeric() then
                    self.searchFunc(self, self:GetNumber());
                else
                    self.searchFunc(self, StringTrim(self:GetText()));
                end
            end
        end
    end

    function EditBoxMixin:SetDisabledTooltipText(disabledTooltipText)
        self.disabledTooltipText = disabledTooltipText;
    end

    function EditBoxMixin:SetSearchFunc(searchFunc)
        self.searchFunc = searchFunc;
        self.hasOnTextChangeCallback = searchFunc ~= nil;
    end

    function EditBoxMixin:SetOnEditFocusGainedCallback(onEditFocusGainedCallback)
        self.onEditFocusGainedCallback = onEditFocusGainedCallback;
    end

    function EditBoxMixin:SetOnEditFocusLostCallback(onEditFocusLostCallback)
        self.onEditFocusLostCallback = onEditFocusLostCallback;
    end

    function EditBoxMixin:ClearCallbacks()
        self.searchFunc = nil;
        self.hasOnTextChangeCallback = nil;
        self.onEditFocusGainedCallback = nil;
        self.onEditFocusLostCallback = nil;
        self.searchResultMenu = nil;
    end

    function LandingPageUtil.CreateEditBox(parent)
        local TEXTURE_FILE = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/ExpansionBorder_TWW";

        local f = CreateFrame("EditBox", nil, parent);
        f:SetAutoFocus(false);
        API.Mixin(f, EditBoxMixin);
        f:SetSize(240, 24);
        f:SetFontObject("GameFontNormal");
        f:SetHitRectInsets(-2, -2, -4, -4);
        f:SetTextInsets(8, 8, 0, 0);

        for i = 1, 2 do
            local setupFunc;
            local prefix;
            if i == 1 then
                setupFunc = API.SetupThreeSliceBackground;
                prefix = "";
            else
                setupFunc = API.SetupThressSliceHighlight;
                prefix = "Highlight";
            end
            setupFunc(f, TEXTURE_FILE, -2.5, 2.5);
            f[prefix.."Left"]:SetSize(16, 32);
            f[prefix.."Left"]:SetTexCoord(768/1024, 800/1024, 384/1024, 448/1024);
            f[prefix.."Right"]:SetSize(16, 32);
            f[prefix.."Right"]:SetTexCoord(972/1024, 1004/1024, 384/1024, 448/1024);
            f[prefix.."Center"]:SetTexCoord(800/1024, 972/1024, 384/1024, 448/1024);
        end

        f.Instruction = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Instruction:SetTextColor(0.5, 0.5, 0.5);
        f.Instruction:SetJustifyH("LEFT");
        f.Instruction:SetPoint("LEFT", f, "LEFT", 8, 0);
        f.Instruction:SetPoint("RIGHT", f, "RIGHT", -8, 0);
        f.Instruction:SetMaxLines(1);

        f.Magnifier = f:CreateTexture(nil, "OVERLAY");
        f.Magnifier:SetSize(24, 24);
        f.Magnifier:SetPoint("LEFT", f, "LEFT", 2, 0);
        f.Magnifier:SetTexture(TEXTURE_FILE);
        f.Magnifier:SetTexCoord(956/1024, 1004/1024, 328/1024, 376/1024);
        f.Magnifier:SetVertexColor(0.5, 0.5, 0.5);
        f.Magnifier:Hide();

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnEditFocusGained", f.OnEditFocusGained);
        f:SetScript("OnEditFocusLost", f.OnEditFocusLost);
        f:SetScript("OnEscapePressed", f.OnEscapePressed);
        f:SetScript("OnEnterPressed", f.OnEnterPressed);
        f:SetScript("OnEnable", f.OnEnable);
        f:SetScript("OnDisable", f.OnDisable);
        f:SetScript("OnHide", f.OnHide);
        f:SetScript("OnTextChanged", f.OnTextChanged);

        f:UpdateVisual();

        return f
    end
end