local _, addon = ...
local API = addon.API;

local BUTTON_MIN_SIZE = 24;

local Mixin = API.Mixin;
local FadeFrame = API.UIFrameFade;

local select = select;
local tinsert = table.insert;
local floor = math.floor;
local time = time;
local IsMouseButtonDown = IsMouseButtonDown;
local PlaySound = PlaySound;
local GetItemCount = GetItemCount;
local GetSpellCharges = GetSpellCharges;
local C_Item = C_Item;
local CreateFrame = CreateFrame;


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
    local TOKEN_BUTTON_TEXT_ICON_GAP = 2;
    local TOKEN_BUTTON_ICON_SIZE = 12;
    local TOKEN_BUTTON_HEIGHT = 12;

    local TokenDisplayMixin = {};

    local function CreateTokenDisplay(parent)
        local f = addon.CreateThreeSliceFrame(parent);
        f:SetHeight(16);
        f:SetWidth(32);
        Mixin(f, TokenDisplayMixin);
        f.currencies = {};
        f.tokenButtons = {};
        return f
    end
    addon.CreateTokenDisplay = CreateTokenDisplay;

    function TokenDisplayMixin:AddCurrency(currencyID)
        for i, id in ipairs(self.currencies) do
            if id == currencyID then
                return
            end
        end

        tinsert(self.currencies, currencyID);
        self:Update();
    end

    function TokenDisplayMixin:RemoveCurrency(currencyID)
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

    function TokenDisplayMixin:SetCurrencies(...)
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
        local span = TOKEN_BUTTON_ICON_SIZE + TOKEN_BUTTON_TEXT_ICON_GAP + floor(self.Count:GetWrappedWidth() + 0.5);
        self:SetWidth(span);
        return span
    end

    function TokenDisplayMixin:AcquireTokenButton(index)
        if not self.tokenButtons[index] then
            local button = CreateFrame("Frame", nil, self);

            if index == 1 then
                button:SetPoint("LEFT", self, "LEFT", TOKEN_FRAME_SIDE_PADDING, 0);
            else
                button:SetPoint("LEFT", self.tokenButtons[index - 1], "RIGHT", TOKEN_FRAME_BUTTON_PADDING, 0);
            end

            button:SetSize(TOKEN_BUTTON_ICON_SIZE, TOKEN_BUTTON_HEIGHT);

            button.Icon = button:CreateTexture(nil, "ARTWORK");
            button.Icon:SetPoint("RIGHT", button, "RIGHT", 0, 0);
            button.Icon:SetSize(TOKEN_BUTTON_ICON_SIZE, TOKEN_BUTTON_ICON_SIZE);
            button.Icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375);

            button.Count = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
            button.Count:SetJustifyH("RIGHT");
            button.Count:SetPoint("RIGHT", button.Icon, "LEFT", -TOKEN_BUTTON_TEXT_ICON_GAP, 0);

            button:SetScript("OnEnter", TokenButton_OnEnter);
            button:SetScript("OnLeave", TokenButton_OnLeave);

            self.tokenButtons[index] = button;
        end

        return self.tokenButtons[index]
    end

    function TokenDisplayMixin:Update()
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
        self:SetWidth(totalWidth);

        for i = numVisible + 1, #self.tokenButtons do
            self.tokenButtons[i]:Hide();
        end
    end

    function TokenDisplayMixin:SetFrameOwner(owner, position)
        --To avoid taint, our frame isn't parent-ed to owner
        local b = owner:GetBottom();
        local r = owner:GetRight();

        self:ClearAllPoints();
        self:SetFrameStrata("FULLSCREEN");

        local realParent = UIParent;
        local scale = realParent:GetScale();

        if position == "BOTTOMRIGHT" then
            self:SetPoint("BOTTOMRIGHT", realParent, "BOTTOMLEFT", r, b);
            --f:SetPoint("CENTER", UIParent, "BOTTOM", 0, 64)
        end

        self:Show();
    end

    function TokenDisplayMixin:DisplayCurrencyOnFrame(owner, position, ...)
        self:SetFrameOwner(owner, position);
        self:SetCurrencies(...);
    end

    function TokenDisplayMixin:HideTokenFrame()
        if self:IsShown() then
            self:Hide();
            self:ClearAllPoints();
        end
    end
end

do  -- PeudoActionButton (a real ActionButtonTemplate will be attached to the button onMouseOver)
    local PostClickOverlay;

    local function PostClickOverlay_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        self.alpha = 1 - self.t*5;
        self.scale = 1 + self.t*0.5;
        if self.alpha < 0 then
            self.alpha = 0;
            self:Hide();
        end
        self:SetAlpha(self.alpha);
        self:SetScale(self.scale);
    end

    local PeudoActionButtonMixin = {};

    function PeudoActionButtonMixin:ShowPostClickEffect()
        if not PostClickOverlay then
            PostClickOverlay = CreateFrame("Frame", nil, self);
            PostClickOverlay:Hide();
            PostClickOverlay:SetScript("OnUpdate", PostClickOverlay_OnUpdate);
            PostClickOverlay:SetSize(64, 64);

            local texture = PostClickOverlay:CreateTexture(nil, "OVERLAY");
            PostClickOverlay.Texture = texture;
            texture:SetSize(64, 64);
            texture:SetPoint("CENTER", PostClickOverlay, "CENTER", 0, 0);
            texture:SetTexture("Interface/AddOns/Plumber/Art/Button/ActionButtonCircle-PostClickFeedback");
            texture:SetBlendMode("ADD");
        end

        PostClickOverlay:ClearAllPoints();
        PostClickOverlay:SetParent(self);
        PostClickOverlay:SetScale(1);
        PostClickOverlay:SetAlpha(0);
        PostClickOverlay.t = 0;
        PostClickOverlay:SetPoint("CENTER", self, "CENTER", 0, 0);
        PostClickOverlay:Show();
    end

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
        self:SetIcon(icon);
        self.id = item;
        self.actionType = "item";
        self:UpdateCount();
    end

    function PeudoActionButtonMixin:UpdateCount()
        local count = 0;

        if self.actionType == "item" then
            count = GetItemCount(self.id);
            self.Count:SetText(count);
        elseif self.actionType == "spell" then
            local currentCharges, maxCharges = GetSpellCharges();
            if currentCharges then
                count = currentCharges;
            else
                self.Count:SetText("");
            end
        end

        self.charges = count;

        if count > 0 then
            self:SetIconState(1);
        else
            self:SetIconState(2);
            self.Count:SetText("");
        end
    end

    function PeudoActionButtonMixin:GetCharges()
        if not self.charges then
            self:UpdateCount();
        end
        return self.charges
    end

    function PeudoActionButtonMixin:HasCharges()
        return self:GetCharges() > 0
    end

    function PeudoActionButtonMixin:SetStatePushed()
        self.NormalTexture:Hide();
        self.PushedTexture:Show();
        self.Icon:SetSize(39, 39);
    end

    function PeudoActionButtonMixin:SetStateNormal()
        self.NormalTexture:Show();
        self.PushedTexture:Hide();
        self.Icon:SetSize(40, 40);
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


    local ActionButtonSpellCastOverlayMixin = {};

    function ActionButtonSpellCastOverlayMixin:FadeIn()
        FadeFrame(self, 0.25, 1, 0);
    end

    function ActionButtonSpellCastOverlayMixin:FadeOut()
        FadeFrame(self, 0.25, 0);
        self.Cooldown:Pause();
    end

    local PI2 = -2*math.pi;

    local function Cooldown_OnUpdate(self, elapsed)
        --Animation will desync once the frame becomes hidden
        self.t = self.t + elapsed;
        if self.t < self.duration then
            self.EdgeTexture:SetRotation( self.t/self.duration * PI2 );
        end
    end

    function ActionButtonSpellCastOverlayMixin:SetDuration(second)
        second = second or 0;
        self.Cooldown:SetCooldownDuration(second);
        if second > 0 then
            self.Cooldown:Resume();
            self.Cooldown.t = 0;
            self.Cooldown.duration = second;
            self.Cooldown:SetScript("OnUpdate", Cooldown_OnUpdate);
            self.Cooldown.EdgeTexture:Show();
            self.Cooldown.EdgeTexture:SetRotation(0);
            self.supposedEndTime = time() + second;
        else
            self.Cooldown:SetScript("OnUpdate", nil);
            self.Cooldown.EdgeTexture:Hide();
            self.supposedEndTime = nil;
        end
    end

    local function CreateActionButtonSpellCastOverlay(parent)
        local f = CreateFrame("Frame", nil, parent);
        f:SetSize(46, 46);

        --[[
        f.Border = f:CreateTexture(nil, "BACKGROUND", nil, 4);
        f.Border:SetSize(64, 64);
        f.Border:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.Border:SetTexture("Interface/AddOns/Plumber/Art/Button/ActionButtonCircle-SpellCast-Border", nil, nil, "TRILINEAR");
        f.Border:SetTexCoord(0, 1, 0, 1);
        f.Border:Hide();
        --]]

        local InnerShadow = f:CreateTexture(nil, "OVERLAY", nil, 1);   --Use this texture to increase contrast (HighlightTexture/SwipeTexture)
        InnerShadow:SetSize(64, 64);
        InnerShadow:SetPoint("CENTER", f, "CENTER", 0, 0);
        InnerShadow:SetTexture("Interface/AddOns/Plumber/Art/Button/ActionButtonCircle-SpellCast-InnerShadow");
        InnerShadow:SetTexCoord(0, 1, 0, 1);

        f.Cooldown = CreateFrame("Cooldown", nil, f);
        f.Cooldown:SetSize(64, 64);
        f.Cooldown:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.Cooldown:SetHideCountdownNumbers(false);

        f.Cooldown:SetSwipeTexture("Interface/AddOns/Plumber/Art/Button/ActionButtonCircle-SpellCast-Swipe");
        f.Cooldown:SetSwipeColor(1, 1, 1);
        f.Cooldown:SetDrawSwipe(true);

        ---- It seems creating edge doesn't work in Lua
        --f.Cooldown:SetEdgeTexture("Interface/Cooldown/edge", 1, 1, 1, 1);  --Interface/AddOns/Plumber/Art/Button/ActionButtonCircle-SpellCast-Edge
        --f.Cooldown:SetDrawEdge(true);
        --f.Cooldown:SetEdgeScale(1);
        --f.Cooldown:SetUseCircularEdge(true);

        local EdgeTexture = f.Cooldown:CreateTexture(nil, "OVERLAY", nil, 6);
        f.Cooldown.EdgeTexture = EdgeTexture;
        EdgeTexture:SetSize(64, 64);
        EdgeTexture:SetPoint("CENTER", f, "CENTER", 0, 0);
        EdgeTexture:SetTexture("Interface/AddOns/Plumber/Art/Button/ActionButtonCircle-SpellCast-Edge");
        EdgeTexture:SetTexCoord(0, 1, 0, 1);
        EdgeTexture:Hide();

        Mixin(f, ActionButtonSpellCastOverlayMixin);

        return f
    end
    addon.CreateActionButtonSpellCastOverlay = CreateActionButtonSpellCastOverlay;
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


do
    local SecondsToTime = API.SecondsToTime;

    local TimerFrameMixin = {};
    --t0:  totalElapsed
    --t1: totalElapsed (between 0 - 1)
    --s1: elapsedSeconds
    --s0: full duration

    function TimerFrameMixin:Init()
        if not self.styleID then
            self:SetStyle(2);
            self:SetBarColor(131/255, 208/255, 228/255);
            self:AbbreviateTimeText(true);
        end
    end

    function TimerFrameMixin:Clear()
        self:SetScript("OnUpdate", nil);
        self.t0 = 0;
        self.t1 = 0;
        self.s1 = 1;
        self.s0 = 1;
        self.startTime = nil;
        if self.BarMark then
            self.BarMark:Hide();
        end
        self.DisplayProgress(self);
    end

    function TimerFrameMixin:Calibrate()
        if self.startTime then
            local currentTime = time();
            self.t0 = currentTime - self.startTime;
            self.s1 = self.t0;
            self.DisplayProgress(self);
        end
    end

    function TimerFrameMixin:SetTimes(currentSecond, total)
        if currentSecond >= total or total == 0 then
            self:Clear();
        else
            self.t0 = currentSecond;
            self.t1 = 0;
            self.s1 = floor(currentSecond + 0.5);
            self.s0 = total;
            self:SetScript("OnUpdate", self.OnUpdate);
            self.DisplayProgress(self);
            self.startTime = time();
            if self.BarMark and self.styleID == 2 then
                self.BarMark:Show();
            end
        end
    end

    function TimerFrameMixin:SetDuration(second)
        self:SetTimes(0, second);
    end

    function TimerFrameMixin:SetEndTime(endTime)
        local t = time();
        self:SetDuration( (t > endTime and (t - endTime)) or 0 );
    end

    function TimerFrameMixin:SetReverse(reverse)
        --If reverse, show remaining seconds instead of elpased seconds
        self.isReverse = reverse;
    end

    function TimerFrameMixin:OnUpdate(elapsed)
        self.t0 = self.t0 + elapsed;
        self.t1 = self.t1 + elapsed;

        if self.t0 >= self.s0 then
            self:Clear();
            return
        end

        if self.t1 > 1 then
            self.t1 = self.t1 - 1;
            self.s1 = self.s1 + 1;
            self.DisplayProgress(self);
        end

        if self.continuous then
            self.UpdateEveryFrame(self);
        end
    end

    function TimerFrameMixin:AbbreviateTimeText(state)
        self.abbreviated = state or false;
    end

    local function DisplayProgress_SimpleText(self)
        if self.isReverse then
            self.TimeText:SetText( SecondsToTime(self.s0 - self.s1, self.abbreviated) );
        else
            self.TimeText:SetText( SecondsToTime(self.s1, self.abbreviated) );
        end
    end

    local function DisplayProgress_StatusBar(self)
        if self.isReverse then
            self.fw = (1 - self.s1/self.s0) * self.maxBarFillWidth;
        else
            self.fw = (self.s1/self.s0) * self.maxBarFillWidth;
        end
        if self.fw < 0.1 then
            self.fw = 0.1;
        end
        self.BarFill:SetWidth(self.fw);
    end

    local function DisplayProgress_Style2(self)
        DisplayProgress_SimpleText(self);
        DisplayProgress_StatusBar(self);
    end

    local function UpdateEveryFrame_TimeText(self)

    end

    local function UpdateEveryFrame_StatusBar(self)
        if self.isReverse then
            self.fw = (1 - self.t0/self.s0) * self.maxBarFillWidth;
        else
            self.fw = (self.t0/self.s0) * self.maxBarFillWidth;
        end
        if self.fw < 0.1 then
            self.fw = 0.1;
        end
        self.BarFill:SetWidth(self.fw);
    end

    function TimerFrameMixin:UpdateMaxBarFillWidth()
        self.maxBarFillWidth = self:GetWidth() - 4;
    end

    function TimerFrameMixin:SetContinuous(state)
        --Do something every frame instead of every second
        self.continuous = state or false;
    end

    function TimerFrameMixin:SetStyle(styleID)
        if styleID == self.styleID then return end;
        self.styleID = styleID;

        if styleID == 1 then
            --Simple Text
            self.DisplayProgress = DisplayProgress_SimpleText;
            self.UpdateEveryFrame = UpdateEveryFrame_TimeText;
            self.TimeText:SetFontObject("GameTooltipText");
            self.TimeText:SetTextColor(1, 1, 1);
            if self.BarLeft then
                self.BarLeft:Hide();
                self.BarCenter:Hide();
                self.BarRight:Hide();
                self.BarBG:Hide();
                self.BarFill:Hide();
                self.BarMark:Hide();
            end
        elseif styleID == 2 then
            --StatusBar
            self.DisplayProgress = DisplayProgress_Style2;
            self.UpdateEveryFrame = UpdateEveryFrame_StatusBar;

            local font, height, flag = GameFontHighlightSmall:GetFont();
            self.TimeText:SetFont(font, 10, "");
            self.TimeText:SetTextColor(0, 0, 0);

            if not self.BarLeft then
                local file = "Interface/AddOns/Plumber/Art/Frame/StatusBar_Small";
                self.BarLeft = self:CreateTexture(nil, "OVERLAY");
                self.BarLeft:SetSize(16, 32);
                self.BarLeft:SetTexture(file);
                self.BarLeft:SetTexCoord(0, 0.25, 0, 0.5);
                self.BarLeft:SetPoint("CENTER", self, "LEFT", 0, 0);

                self.BarRight = self:CreateTexture(nil, "OVERLAY");
                self.BarRight:SetSize(16, 32);
                self.BarRight:SetTexture(file);
                self.BarRight:SetTexCoord(0.75, 1, 0, 0.5);
                self.BarRight:SetPoint("CENTER", self, "RIGHT", 0, 0);

                self.BarCenter = self:CreateTexture(nil, "OVERLAY");
                self.BarCenter:SetTexture(file);
                self.BarCenter:SetTexCoord(0.25, 0.75, 0, 0.5);
                self.BarCenter:SetPoint("TOPLEFT", self.BarLeft, "TOPRIGHT", 0, 0);
                self.BarCenter:SetPoint("BOTTOMRIGHT", self.BarRight, "BOTTOMLEFT", 0, 0);

                self.BarBG = self:CreateTexture(nil, "BACKGROUND");
                self.BarBG:SetTexture(file);
                self.BarBG:SetTexCoord(0.015625, 0.265625, 0.515625, 0.765625);
                self.BarBG:SetSize(14, 14);
                self.BarBG:SetPoint("LEFT", self, "LEFT", 0, 0);
                self.BarBG:SetPoint("RIGHT", self, "RIGHT", 0, 0);

                self.BarFill = self:CreateTexture(nil, "ARTWORK");
                self.BarFill:SetTexture(file);
                self.BarFill:SetTexCoord(0.296875, 0.5, 0.53125, 0.734375);
                self.BarFill:SetSize(13, 13);
                self.BarFill:SetPoint("LEFT", self, "LEFT", 2, 0);

                self.BarMark = self:CreateTexture(nil, "OVERLAY", nil, 1);
                self.BarMark:SetTexture(file);
                self.BarMark:SetTexCoord(0.75, 1, 0.515625, 0.765625);
                self.BarMark:SetSize(16, 16);
                self.BarMark:SetPoint("CENTER", self.BarFill, "RIGHT", 0, 0);

                API.DisableSharpening(self.BarLeft);
                API.DisableSharpening(self.BarRight);
                API.DisableSharpening(self.BarCenter);
                API.DisableSharpening(self.BarBG);
                API.DisableSharpening(self.BarFill);

                self:UpdateMaxBarFillWidth();
            end

            self.BarLeft:Show();
            self.BarCenter:Show();
            self.BarRight:Show();
            self.BarBG:Show();
            self.BarFill:Show();
            self.BarMark:Show();
        end
    end

    function TimerFrameMixin:SetBarColor(r, g, b)
        if self.BarFill then
            self.BarFill:SetVertexColor(r, g, b);
        end
    end

    local function CreateTimerFrame(parent)
        local f = CreateFrame("Frame", nil, parent);
        f:SetSize(48, 16);

        f.TimeText = f:CreateFontString(nil, "OVERLAY", "GameTooltipText", 2);
        f.TimeText:SetJustifyH("CENTER");
        f.TimeText:SetPoint("CENTER", f, "CENTER", 0, 0);

        Mixin(f, TimerFrameMixin);
        f:SetScript("OnSizeChanged", f.UpdateMaxBarFillWidth);
        f:SetScript("OnShow", f.Calibrate);
        f:Init();

        return f
    end
    addon.CreateTimerFrame = CreateTimerFrame;
end