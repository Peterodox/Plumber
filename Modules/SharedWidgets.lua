local _, addon = ...
local API = addon.API;

local BUTTON_MIN_SIZE = 24;

local Mixin = API.Mixin;
local select = select;
local tinsert = table.insert;
local IsMouseButtonDown = IsMouseButtonDown;
local PlaySound = PlaySound;

local function DisableSharpening(texture)
    texture:SetTexelSnappingBias(0);
    texture:SetSnapToPixelGrid(false);
end
API.DisableSharpening = DisableSharpening;

do  -- Slice Frame
    local NineSliceLayouts = {
        WhiteBorder = true,
        WhiteBorderBlackBackdrop = true,
        GreyBorderWithShadow = true,
    };

    local ThreeSliceLayouts = {
        GenericBox = true,
        WhiteBorder = true,
        WhiteBorderBlackBackdrop = true,
    };

    local SliceFrameMixin = {};

    function SliceFrameMixin:CreatePieces(n)
        if self.pieces then return end;
        self.pieces = {};
        self.numSlices = n;

        -- 1 2 3
        -- 4 5 6
        -- 7 8 9

        for i = 1, n do
            self.pieces[i] = self:CreateTexture(nil, "BORDER");
            DisableSharpening(self.pieces[i]);
            self.pieces[i]:ClearAllPoints();
        end

        self:SetCornerSize(16);

        if n == 3 then
            self.pieces[1]:SetPoint("CENTER", self, "LEFT", 0, 0);
            self.pieces[3]:SetPoint("CENTER", self, "RIGHT", 0, 0);
            self.pieces[2]:SetPoint("TOPLEFT", self.pieces[1], "TOPRIGHT", 0, 0);
            self.pieces[2]:SetPoint("BOTTOMRIGHT", self.pieces[3], "BOTTOMLEFT", 0, 0);

            self.pieces[1]:SetTexCoord(0, 0.25, 0, 1);
            self.pieces[2]:SetTexCoord(0.25, 0.75, 0, 1);
            self.pieces[3]:SetTexCoord(0.75, 1, 0, 1);

        elseif n == 9 then
            self.pieces[1]:SetPoint("CENTER", self, "TOPLEFT", 0, 0);
            self.pieces[3]:SetPoint("CENTER", self, "TOPRIGHT", 0, 0);
            self.pieces[7]:SetPoint("CENTER", self, "BOTTOMLEFT", 0, 0);
            self.pieces[9]:SetPoint("CENTER", self, "BOTTOMRIGHT", 0, 0);
            self.pieces[2]:SetPoint("TOPLEFT", self.pieces[1], "TOPRIGHT", 0, 0);
            self.pieces[2]:SetPoint("BOTTOMRIGHT", self.pieces[3], "BOTTOMLEFT", 0, 0);
            self.pieces[4]:SetPoint("TOPLEFT", self.pieces[1], "BOTTOMLEFT", 0, 0);
            self.pieces[4]:SetPoint("BOTTOMRIGHT", self.pieces[7], "TOPRIGHT", 0, 0);
            self.pieces[5]:SetPoint("TOPLEFT", self.pieces[1], "BOTTOMRIGHT", 0, 0);
            self.pieces[5]:SetPoint("BOTTOMRIGHT", self.pieces[9], "TOPLEFT", 0, 0);
            self.pieces[6]:SetPoint("TOPLEFT", self.pieces[3], "BOTTOMLEFT", 0, 0);
            self.pieces[6]:SetPoint("BOTTOMRIGHT", self.pieces[9], "TOPRIGHT", 0, 0);
            self.pieces[8]:SetPoint("TOPLEFT", self.pieces[7], "TOPRIGHT", 0, 0);
            self.pieces[8]:SetPoint("BOTTOMRIGHT", self.pieces[9], "BOTTOMLEFT", 0, 0);
    
            self.pieces[1]:SetTexCoord(0, 0.25, 0, 0.25);
            self.pieces[2]:SetTexCoord(0.25, 0.75, 0, 0.25);
            self.pieces[3]:SetTexCoord(0.75, 1, 0, 0.25);
            self.pieces[4]:SetTexCoord(0, 0.25, 0.25, 0.75);
            self.pieces[5]:SetTexCoord(0.25, 0.75, 0.25, 0.75);
            self.pieces[6]:SetTexCoord(0.75, 1, 0.25, 0.75);
            self.pieces[7]:SetTexCoord(0, 0.25, 0.75, 1);
            self.pieces[8]:SetTexCoord(0.25, 0.75, 0.75, 1);
            self.pieces[9]:SetTexCoord(0.75, 1, 0.75, 1);
        end
    end

    function SliceFrameMixin:SetCornerSize(a)
        if self.numSlices == 3 then
            self.pieces[1]:SetSize(a, 2*a);
            self.pieces[3]:SetSize(a, 2*a);
        elseif self.numSlices == 9 then
            self.pieces[1]:SetSize(a, a);
            self.pieces[3]:SetSize(a, a);
            self.pieces[7]:SetSize(a, a);
            self.pieces[9]:SetSize(a, a);
        end
    end

    function SliceFrameMixin:SetTexture(tex)
        for i = 1, #self.pieces do
            self.pieces[i]:SetTexture(tex);
        end
    end

    function SliceFrameMixin:SetColor(r, g, b)
        for i = 1, #self.pieces do
            self.pieces[i]:SetVertexColor(r, g, b);
        end
    end

    local function CreateNineSliceFrame(parent, layoutName)
        if not (layoutName and NineSliceLayouts[layoutName]) then
            layoutName = "WhiteBorder";
        end
        local f = CreateFrame("Frame", nil, parent);
        Mixin(f, SliceFrameMixin);
        f:CreatePieces(9);
        f:SetTexture("Interface/AddOns/Plumber/Art/Frame/"..layoutName);
        f:ClearAllPoints();
        return f
    end
    addon.CreateNineSliceFrame = CreateNineSliceFrame;

    local function CreateThreeSliceFrame(parent, layoutName)
        if not (layoutName and ThreeSliceLayouts[layoutName]) then
            layoutName = "GenericBox";
        end
        local f = CreateFrame("Frame", nil, parent);
        Mixin(f, SliceFrameMixin);
        f:CreatePieces(3);
        f:SetTexture("Interface/AddOns/Plumber/Art/Frame/ThreeSlice_"..layoutName);
        f:ClearAllPoints();
        return f
    end
    addon.CreateThreeSliceFrame = CreateThreeSliceFrame;


    -- With
end

do  -- Checkbox
    local LABEL_OFFSET = 20;
    local BUTTON_HITBOX_MIN_WIDTH = 120;

    local SFX_CHECKBOX_ON = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856;
    local SFX_CHECKBOX_OFF = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or 857;

    local CheckboxMixin = {};

    function CheckboxMixin:OnEnter()
        if IsMouseButtonDown() then return end;

        if self.tooltip then
            GameTooltip:Hide();
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:SetText(self.Label:GetText(), 1, 1, 1, true);
            GameTooltip:AddLine(self.tooltip, 1, 0.82, 0, true);
            GameTooltip:Show();
        end

        if self.onEnterFunc then
            self.onEnterFunc(self);
        end
    end

    function CheckboxMixin:OnLeave()
        GameTooltip:Hide();

        if self.onLeaveFunc then
            self.onLeaveFunc(self);
        end
    end

    function CheckboxMixin:OnClick()
        local newState;

        if self.dbKey then
            newState = not PlumberDB[self.dbKey];
            PlumberDB[self.dbKey] = newState;
            self:SetChecked(newState);
        else
            newState = not self:GetChecked();
            self:SetChecked(newState);
            print("DB Key not assigned");
        end

        if self.onClickFunc then
            self.onClickFunc(self, newState);
        end

        if self.checked then
            PlaySound(SFX_CHECKBOX_ON);
        else
            PlaySound(SFX_CHECKBOX_OFF);
        end

        GameTooltip:Hide();
    end

    function CheckboxMixin:GetChecked()
        return self.checked
    end

    function CheckboxMixin:SetChecked(state)
        state = state or false;
        self.CheckedTexture:SetShown(state);
        self.checked = state;
    end

    function CheckboxMixin:SetFixedWidth(width)
        self.fixedWidth = width;
        self:SetWidth(width);
    end

    function CheckboxMixin:SetMaxWidth(maxWidth)
        --this width includes box and label
        self.Label:SetWidth(maxWidth - LABEL_OFFSET);
        self.SetWidth(maxWidth);
    end

    function CheckboxMixin:SetLabel(label)
        self.Label:SetText(label);
        local width = self.Label:GetWrappedWidth() + LABEL_OFFSET;
        local height = self.Label:GetHeight();
        local lines = self.Label:GetNumLines();

        self.Label:ClearAllPoints();
        if lines > 1 then
            self.Label:SetPoint("TOPLEFT", self, "TOPLEFT", LABEL_OFFSET, -4);
        else
            self.Label:SetPoint("LEFT", self, "LEFT", LABEL_OFFSET, 0);
        end

        if self.fixedWidth then
            return self.fixedWidth
        else
            self:SetWidth(math.max(BUTTON_HITBOX_MIN_WIDTH, width));
            return width
        end
    end

    local function CreateCheckbox(parent)
        local b = CreateFrame("Button", nil, parent);
        b:SetSize(BUTTON_MIN_SIZE, BUTTON_MIN_SIZE);

        b.Label = b:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        b.Label:SetJustifyH("LEFT");
        b.Label:SetJustifyV("TOP");
        b.Label:SetTextColor(1, 0.82, 0);  --labelcolor
        b.Label:SetPoint("LEFT", b, "LEFT", LABEL_OFFSET, 0);

        b.Border = b:CreateTexture(nil, "ARTWORK");
        b.Border:SetTexture("Interface/AddOns/Plumber/Art/Button/Checkbox");
        b.Border:SetTexCoord(0, 0.5, 0, 0.5);
        b.Border:SetPoint("CENTER", b, "LEFT", 8, 0);
        b.Border:SetSize(32, 32);
        DisableSharpening(b.Border);

        b.CheckedTexture = b:CreateTexture(nil, "OVERLAY");
        b.CheckedTexture:SetTexture("Interface/AddOns/Plumber/Art/Button/Checkbox");
        b.CheckedTexture:SetTexCoord(0.5, 0.75, 0.5, 0.75);
        b.CheckedTexture:SetPoint("CENTER", b.Border, "CENTER", 0, 0);
        b.CheckedTexture:SetSize(16, 16);
        DisableSharpening(b.CheckedTexture);
        b.CheckedTexture:Hide();

        b.Highlight = b:CreateTexture(nil, "HIGHLIGHT");
        b.Highlight:SetTexture("Interface/AddOns/Plumber/Art/Button/Checkbox");
        b.Highlight:SetTexCoord(0, 0.5, 0.5, 1);
        b.Highlight:SetPoint("CENTER", b.Border, "CENTER", 0, 0);
        b.Highlight:SetSize(32, 32);
        --b.Highlight:Hide();
        DisableSharpening(b.Highlight);

        Mixin(b, CheckboxMixin);
        b:SetScript("OnClick", CheckboxMixin.OnClick);
        b:SetScript("OnEnter", CheckboxMixin.OnEnter);
        b:SetScript("OnLeave", CheckboxMixin.OnLeave);

        return b
    end

    addon.CreateCheckbox = CreateCheckbox;
end

do  -- Common Frame with Header (and close button)
    local function CloseButton_OnClick(self)
        local parent = self:GetParent();
        if parent.CloseUI then
            parent:CloseUI();
        else
            parent:Hide();
        end
    end

    local function CloseButton_ShowNormalTexture(self)
        self.Texture:SetTexCoord(0, 0.5, 0, 0.5);
        self.Highlight:SetTexCoord(0, 0.5, 0.5, 1);
    end

    local function CloseButton_ShowPushedTexture(self)
        self.Texture:SetTexCoord(0.5, 1, 0, 0.5);
        self.Highlight:SetTexCoord(0.5, 1, 0.5, 1);
    end

    local function CreateCloseButton(parent)
        local b = CreateFrame("Button", nil, parent);
        b:SetSize(BUTTON_MIN_SIZE, BUTTON_MIN_SIZE);

        b.Texture = b:CreateTexture(nil, "ARTWORK");
        b.Texture:SetTexture("Interface/AddOns/Plumber/Art/Button/CloseButton");
        b.Texture:SetPoint("CENTER", b, "CENTER", 0, 0);
        b.Texture:SetSize(32, 32);
        DisableSharpening(b.Texture);

        b.Highlight = b:CreateTexture(nil, "HIGHLIGHT");
        b.Highlight:SetTexture("Interface/AddOns/Plumber/Art/Button/CloseButton");
        b.Highlight:SetPoint("CENTER", b, "CENTER", 0, 0);
        b.Highlight:SetSize(32, 32);
        DisableSharpening(b.Highlight);

        CloseButton_ShowNormalTexture(b);

        b:SetScript("OnClick", CloseButton_OnClick);
        b:SetScript("OnMouseUp", CloseButton_ShowNormalTexture);
        b:SetScript("OnMouseDown", CloseButton_ShowPushedTexture);
        b:SetScript("OnShow", CloseButton_ShowNormalTexture);

        return b
    end


    local CategoryDividerMixin = {};

    function CategoryDividerMixin:HideDivider()
        self.Divider:Hide();
    end

    local function CreateCategoryDivider(parent, alignCenter)
        local fontString = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        if alignCenter then
            fontString:SetJustifyH("CENTER");
        else
            fontString:SetJustifyH("LEFT");
        end

        fontString:SetJustifyV("TOP");
        fontString:SetTextColor(1, 1, 1);

        local divider = parent:CreateTexture(nil, "OVERLAY");
        divider:SetHeight(4);
        --divider:SetWidth(240);
        divider:SetPoint("TOPLEFT", fontString, "BOTTOMLEFT", 0, -4);
        divider:SetPoint("RIGHT", parent, "RIGHT", -8, 0);

        divider:SetTexture("Interface/AddOns/Plumber/Art/Frame/Divider_Gradient_Horizontal");
        divider:SetVertexColor(0.5, 0.5, 0.5);
        DisableSharpening(divider);

        Mixin(fontString, CategoryDividerMixin);

        return fontString
    end

    addon.CreateCategoryDivider = CreateCategoryDivider;


    local HeaderFrameMixin = {};

    function HeaderFrameMixin:SetCornerSize(a)

    end

    function HeaderFrameMixin:ShowCloseButton(state)
        self.CloseButton:SetShown(state);
    end

    function HeaderFrameMixin:SetTitle(title)
        self.Title:SetText(title);
    end

    function HeaderFrameMixin:GetHeaderHeight()
        return 18
    end

    local function CreateHeaderFrame(parent, showCloseButton)
        local f = CreateFrame("Frame", nil, parent);
        f:ClearAllPoints();

        local p = {};
        f.pieces = p;

        f.Title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Title:SetJustifyH("CENTER");
        f.Title:SetJustifyV("MIDDLE");
        f.Title:SetTextColor(1, 0.82, 0);
        f.Title:SetPoint("CENTER", f, "TOP", 0, -8 -1);

        f.CloseButton = CreateCloseButton(f);
        f.CloseButton:SetPoint("CENTER", f, "TOPRIGHT", -9, -9);
        -- 1 2 3
        -- 4 5 6
        -- 7 8 9

        local tex = "Interface/AddOns/Plumber/Art/Frame/CommonFrameWithHeader_Opaque";

        for i = 1, 9 do
            p[i] = f:CreateTexture(nil, "BORDER");
            p[i]:SetTexture(tex);
            DisableSharpening(p[i]);
            p[i]:ClearAllPoints();
        end

        p[1]:SetPoint("CENTER", f, "TOPLEFT", 0, -8);
        p[3]:SetPoint("CENTER", f, "TOPRIGHT", 0, -8);
        p[7]:SetPoint("CENTER", f, "BOTTOMLEFT", 0, 0);
        p[9]:SetPoint("CENTER", f, "BOTTOMRIGHT", 0, 0);
        p[2]:SetPoint("TOPLEFT", p[1], "TOPRIGHT", 0, 0);
        p[2]:SetPoint("BOTTOMRIGHT", p[3], "BOTTOMLEFT", 0, 0);
        p[4]:SetPoint("TOPLEFT", p[1], "BOTTOMLEFT", 0, 0);
        p[4]:SetPoint("BOTTOMRIGHT",p[7], "TOPRIGHT", 0, 0);
        p[5]:SetPoint("TOPLEFT",p[1], "BOTTOMRIGHT", 0, 0);
        p[5]:SetPoint("BOTTOMRIGHT",p[9], "TOPLEFT", 0, 0);
        p[6]:SetPoint("TOPLEFT",p[3], "BOTTOMLEFT", 0, 0);
        p[6]:SetPoint("BOTTOMRIGHT",p[9], "TOPRIGHT", 0, 0);
        p[8]:SetPoint("TOPLEFT",p[7], "TOPRIGHT", 0, 0);
        p[8]:SetPoint("BOTTOMRIGHT",p[9], "BOTTOMLEFT", 0, 0);

        p[1]:SetSize(16, 32);
        p[3]:SetSize(16, 32);
        p[7]:SetSize(16, 16);
        p[9]:SetSize(16, 16);

        p[1]:SetTexCoord(0, 0.25, 0, 0.5);
        p[2]:SetTexCoord(0.25, 0.75, 0, 0.5);
        p[3]:SetTexCoord(0.75, 1, 0, 0.5);
        p[4]:SetTexCoord(0, 0.25, 0.5, 0.75);
        p[5]:SetTexCoord(0.25, 0.75, 0.5, 0.75);
        p[6]:SetTexCoord(0.75, 1, 0.5, 0.75);
        p[7]:SetTexCoord(0, 0.25, 0.75, 1);
        p[8]:SetTexCoord(0.25, 0.75, 0.75, 1);
        p[9]:SetTexCoord(0.75, 1, 0.75, 1);

        Mixin(f, HeaderFrameMixin);
        f:ShowCloseButton(showCloseButton);
        f:EnableMouse(true);

        return f
    end

    addon.CreateHeaderFrame = CreateHeaderFrame;
end

do  -- TokenFrame
    local TOKEN_FRAME_SIDE_PADDING = 12;
    local TOKEN_FRAME_BUTTON_PADDING = 8;
    local TOKEN_BUTTON_TEXT_ICON_GAP = 0;
    local TOKEN_BUTTON_ICON_SIZE = 12;
    local TOKEN_BUTTON_HEIGHT = 12;

    local TokenDisplay = {};

    local function CreateTokenDisplay()
        return API.CreateFromMixins(TokenDisplay)
    end

    addon.CreateTokenDisplay = CreateTokenDisplay;

    function TokenDisplay:GetFrame(hideBorder)
        if not self.frame then
            local f = CreateFrame("Frame", nil, UIParent, "ContainerFrameCurrencyBorderTemplate");
            f:SetWidth(34);
            f:SetPoint("CENTER", 0, 0);
            f:Hide();
            if not hideBorder then
                f.leftEdge = "common-currencybox-left";
                f.rightEdge = "common-currencybox-right";
                f.centerEdge = "_common-currencybox-center";
                f:OnLoad();
            end
            self.currencies = {};
            self.tokenButtons = {};
            self.frame = f;
        end

        return self.frame
    end

    function TokenDisplay:SetFrameWidth(width)
        self.frame:SetWidth(width);
    end

    function TokenDisplay:AddCurrency(currencyID)
        for i, id in ipairs(self.currencies) do
            if id == currencyID then
                return
            end
        end

        tinsert(self.currencies, currencyID);
        self:Update();
    end

    function TokenDisplay:RemoveCurrency(currencyID)
        local anyChange = false;

        if currencyID then
            anyChange = API.RemoveValueFromList(self.currencies, currencyID);
        else
            self.currencies = {};
            anyChange = true;
        end

        if anyChange then
            self:Update();
        end
    end

    function TokenDisplay:SetCurrencies(...)
        self.currencies = {};

        local n = select('#', ...);
        local id = select(1, ...);

        if id and type(id) == "table" then
            for _, v in ipairs(id) do
                tinsert(self.currencies, v);
            end
        else
            for i = 1, n do
                id = select(i, ...);
                tinsert(self.currencies, id);
            end
        end

        self:Update();
    end

    local function TokenButton_OnEnter(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetCurrencyByID(self.currencyID);
    end

    local function TokenButton_OnLeave(self)
        GameTooltip:Hide();
    end

    local function TokenButton_Setup(self, currencyID)
        self.currencyID = currencyID;
        local info = C_CurrencyInfo.GetCurrencyInfo(currencyID);
        if info then
            self.Icon:SetTexture(info.iconFileID);
            self.Count:SetText(info.quantity);
        else
            self.Icon:SetTexture(134400);
            self.Count:SetText("??");
        end

        --update width
        local span = TOKEN_BUTTON_ICON_SIZE + TOKEN_BUTTON_TEXT_ICON_GAP + math.floor(self.Count:GetWrappedWidth() + 0.5);
        self:SetWidth(span);
        return span
    end

    function TokenDisplay:AcquireTokenButton(index)
        if not self.tokenButtons[index] then
            local f = self:GetFrame();

            local button = CreateFrame("Frame", nil, f);

            if index == 1 then
                button:SetPoint("LEFT", f, "LEFT", TOKEN_FRAME_SIDE_PADDING, 0);
            else
                button:SetPoint("LEFT", self.tokenButtons[index - 1], "RIGHT", TOKEN_FRAME_BUTTON_PADDING, 0);
            end

            button:SetSize(TOKEN_BUTTON_ICON_SIZE, TOKEN_BUTTON_HEIGHT);

            button.Icon = button:CreateTexture(nil, "ARTWORK");
            button.Icon:SetPoint("RIGHT", button, "RIGHT", 0, 0);
            button.Icon:SetSize(TOKEN_BUTTON_ICON_SIZE, TOKEN_BUTTON_ICON_SIZE);

            button.Count = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
            button.Count:SetJustifyH("RIGHT");
            button.Count:SetPoint("RIGHT", button.Icon, "LEFT", -TOKEN_BUTTON_TEXT_ICON_GAP, 0);

            button:SetScript("OnEnter", TokenButton_OnEnter);
            button:SetScript("OnLeave", TokenButton_OnLeave);

            self.tokenButtons[index] = button;
        end

        return self.tokenButtons[index]
    end

    function TokenDisplay:Update()
        local numVisible = #self.currencies;
        local button;

        local totalWidth = 0;
        local buttonWidth;

        for i, currencyID in ipairs(self.currencies) do
            button = self:AcquireTokenButton(i);
            button:Show();
            buttonWidth = TokenButton_Setup(button, currencyID);
            totalWidth = totalWidth + buttonWidth + TOKEN_FRAME_BUTTON_PADDING;
        end

        totalWidth = totalWidth - TOKEN_FRAME_BUTTON_PADDING + 2*TOKEN_FRAME_SIDE_PADDING;
        if totalWidth < TOKEN_BUTTON_ICON_SIZE then
            totalWidth = TOKEN_BUTTON_ICON_SIZE;
        end
        self:SetFrameWidth(totalWidth);

        for i = numVisible + 1, #self.tokenButtons do
            self.tokenButtons[i]:Hide();
        end
    end

    function TokenDisplay:SetFrameOwner(owner, position)
        --To avoid taint, our frame isn't parent-ed to owner
        local b = owner:GetBottom();
        local r = owner:GetRight();

        local f = self:GetFrame();
        f:ClearAllPoints();

        f:SetFrameStrata("FULLSCREEN");

        local realParent = UIParent;
        local scale = realParent:GetScale();

        if position == "BOTTOMRIGHT" then
            f:SetPoint("BOTTOMRIGHT", realParent, "BOTTOMLEFT", r, b);
            --f:SetPoint("CENTER", UIParent, "BOTTOM", 0, 64)
        end

        f:Show();
    end

    function TokenDisplay:DisplayCurrencyOnFrame(owner, position, ...)
        self:SetFrameOwner(owner, position);
        self:SetCurrencies(...);
    end

    function TokenDisplay:HideTokenFrame()
        if self.frame and self.frame:IsShown() then
            self.frame:Hide();
            self.frame:ClearAllPoints();
        end
    end
end

do  -- PeudoActionButton (a real ActionButtonTemplate will be )
    local PeudoActionButtonMixin = {};

    function PeudoActionButtonMixin:SetIcon(icon)
        self.Icon:SetTexture(icon);
    end

    function PeudoActionButtonMixin:SetIconState(index)
        if index == 1 then
            self.Icon:SetVertexColor(1, 1, 1);
        elseif index == 2 then
            self.Icon:SetVertexColor(0.4, 0.4, 0.4);
        else
            self.Icon:SetVertexColor(1, 1, 1);
        end
    end

    function PeudoActionButtonMixin:SetItem(item)
        local icon = C_Item.GetItemIconByID(item);
        local count = GetItemCount(item);

        self:SetIcon(icon);
        self.id = item;
        self.actionType = "item";

        if count > 0 then
            self:SetIconState(1);
        else
            self:SetIconState(2);
        end

        self.Count:SetText(count);
    end

    function PeudoActionButtonMixin:SetStatePushed()
        self.NormalTexture:Hide();
        self.PushedTexture:Show();
    end

    function PeudoActionButtonMixin:SetStateNormal()
        self.NormalTexture:Show();
        self.PushedTexture:Hide();
    end

    local function CreatePeudoActionButton(parent)
        local button = CreateFrame("Button", nil, parent);
        button:SetSize(46, 46);     --Stock ActionButton is 45x45

        --[[
        button.Border = button:CreateTexture(nil, "ARTWORK", nil, 2);
        button.Border:SetSize(64, 64);
        button.Border:SetPoint("CENTER", button, "CENTER", 0, 0);
        button.Border:SetTexture("Interface/AddOns/Plumber/Art/Button/ActionButtonCircle-Border");
        button.Border:SetTexCoord(0, 1, 0, 1);
        --]]

        local NormalTexture = button:CreateTexture(nil, "OVERLAY", nil, 2);
        button.NormalTexture = NormalTexture;
        NormalTexture:SetSize(64, 64);
        NormalTexture:SetPoint("CENTER", button, "CENTER", 0, 0);
        NormalTexture:SetTexture("Interface/AddOns/Plumber/Art/Button/ActionButtonCircle-Border");
        NormalTexture:SetTexCoord(0, 1, 0, 1);
        button:SetNormalTexture(NormalTexture);
    
        local PushedTexture = button:CreateTexture(nil, "OVERLAY", nil, 2);
        button.PushedTexture = PushedTexture;
        PushedTexture:SetSize(64, 64);
        PushedTexture:SetPoint("CENTER", button, "CENTER", 0, 0);
        PushedTexture:SetTexture("Interface/AddOns/Plumber/Art/Button/ActionButtonCircle-Highlight-Full");
        PushedTexture:SetTexCoord(0, 1, 0, 1);
        button:SetPushedTexture(PushedTexture);

        local HighlightTexture = button:CreateTexture(nil, "OVERLAY", nil, 5);
        button.HighlightTexture = HighlightTexture;
        HighlightTexture:SetSize(64, 64);
        HighlightTexture:SetPoint("CENTER", button, "CENTER", 0, 0);
        HighlightTexture:SetTexture("Interface/AddOns/Plumber/Art/Button/ActionButtonCircle-Highlight-Inner");
        HighlightTexture:SetTexCoord(0, 1, 0, 1);
        button:SetHighlightTexture(HighlightTexture, "BLEND");

        button.Icon = button:CreateTexture(nil, "BORDER");
        button.Icon:SetSize(40, 40);
        button.Icon:SetPoint("CENTER", button, "CENTER", 0, 0);
        button.Icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375);

        local mask = button:CreateMaskTexture(nil, "ARTWORK", nil, 2);
        mask:SetPoint("TOPLEFT", button.Icon, "TOPLEFT", 0, 0);
        mask:SetPoint("BOTTOMRIGHT", button.Icon, "BOTTOMRIGHT", 0, 0);
        mask:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Circle", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        button.Icon:AddMaskTexture(mask);

        button.Count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal", 6);
        button.Count:SetJustifyH("RIGHT");
        button.Count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2);

        Mixin(button, PeudoActionButtonMixin);

        return button
    end

    addon.CreatePeudoActionButton = CreatePeudoActionButton;
end


do  --(In)Secure Button Pool
    local InCombatLockdown = InCombatLockdown;
    local GetCVar = C_CVar.GetCVar;
    local SetCVar = C_CVar.SetCVar;

    local SecureButtons = {};
    local SecureButtonContainer = CreateFrame("Frame");
    SecureButtonContainer:Hide();

    local BUTTON_NAME = "PlumberSecureButton";

    function SecureButtonContainer:CollectButton(button)
        if not InCombatLockdown() then
            button:ClearAllPoints();
            button:Hide();
            button:SetParent(self);
            button.isActive = false;
        end
    end

    SecureButtonContainer:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            for i, button in ipairs(SecureButtons) do
                if button.isActive then
                    self:CollectButton(button);
                end
            end
            if self.previousValue then
                SetCVar("ActionButtonUseKeyDown", self.previousValue);
                self.previousValue = nil;
            end
        end
    end);

    local function SecureButtonContainer_OnUpdate_OnShot(self, elapsed)
        self:SetScript("OnUpdate", nil);
        if self.previousValue then
            SetCVar("ActionButtonUseKeyDown", self.previousValue);
            self.previousValue = nil;
        end
    end

    local function SecureActionButton_PreClick()
        if not SecureButtonContainer.previousValue then
            SecureButtonContainer.previousValue = GetCVar("ActionButtonUseKeyDown");
            SetCVar("ActionButtonUseKeyDown", 0);
            SecureButtonContainer:SetScript("OnUpdate", SecureButtonContainer_OnUpdate_OnShot);
        end
    end

    local function SecureActionButton_OnHide(self)
        if self.isActive then
            self:Release();
        end
    end

    local SecureButtonMixin = {};

    function SecureButtonMixin:Release()
        SecureButtonContainer:CollectButton(self);
    end

    local function CreateSecureActionButton()
        if InCombatLockdown() then return end;
        local index = #SecureButtons + 1;
        local button = CreateFrame("Button", nil, nil, "InsecureActionButtonTemplate"); --Perform action outside of combat
        SecureButtons[index] = button;
        button.index = index;
        button.isActive = true;
        Mixin(button, SecureButtonMixin);

        button:SetScript("PreClick", SecureActionButton_PreClick);
        button:SetScript("OnHide", SecureActionButton_OnHide);

        SecureButtonContainer:RegisterEvent("PLAYER_REGEN_DISABLED");
        SecureButtonContainer:RegisterEvent("PLAYER_REGEN_ENABLED");

        return button
    end

    local function AcquireSecureActionButton()
        if InCombatLockdown() then return end;

        for i, button in ipairs(SecureButtons) do
            if not button:IsShown() then
                button.isActive = true;
                return button
            end
        end

        return CreateSecureActionButton()
    end
    addon.AcquireSecureActionButton = AcquireSecureActionButton;
end