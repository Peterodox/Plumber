local _, addon = ...
local API = addon.API;
local L = addon.L;

local BUTTON_MIN_SIZE = 24;

local Mixin = API.Mixin;
local FadeFrame = API.UIFrameFade;

local select = select;
local tinsert = table.insert;
local floor = math.floor;
local ipairs = ipairs;
local unpack = unpack;
local time = time;
local GetTime = GetTime;
local IsMouseButtonDown = IsMouseButtonDown;
local GetMouseFocus = GetMouseFocus;
local PlaySound = PlaySound;
local GetSpellCharges = GetSpellCharges;
local C_Item = C_Item;
local GetItemCount = C_Item.GetItemCount;
local GetItemIconByID = C_Item.GetItemIconByID;
local CreateFrame = CreateFrame;
local UIParent = UIParent;


local function DisableSharpening(texture)
    texture:SetTexelSnappingBias(0);
    texture:SetSnapToPixelGrid(false);
end
API.DisableSharpening = DisableSharpening;

do  -- Slice Frame
    local NineSliceLayouts = {
        WhiteBorder = true,
        WhiteBorderBlackBackdrop = true,
        Tooltip_Brown = true,
        Menu_Black = true,
        NineSlice_GenericBox = true,            --used by BackpackItemTracker
        NineSlice_GenericBox_Border = true,     --used by BackpackItemTracker
    };

    local ThreeSliceLayouts = {
        GenericBox = true,
        WhiteBorder = true,
        WhiteBorderBlackBackdrop = true,
        Metal_Hexagon = true,
        Metal_Hexagon_Red = true,
        Phantom = true,
    };

    local SliceFrameMixin = {};

    --Use the new Texture Slicing   (https://warcraft.wiki.gg/wiki/Patch_10.2.0/API_changes)
    --The SlicedTexture is pixel-perfect but doesn't scale with parent, so we shelve this and observer Blizzard's implementation
    local function NiceSlice_CreatePieces(frame)
        if not frame.NineSlice then
            frame.NineSlice = frame:CreateTexture(nil, "BACKGROUND");
            --frame.NineSlice:SetTextureSliceMode(0); --Enum.UITextureSliceMode, 0 Stretched(Default)  1 Tiled
            --DisableSharpening(frame.NineSlice);
            frame.TestBG = frame:CreateTexture(nil, "OVERLAY");
            frame.TestBG:SetAllPoints(true);
            frame.TestBG:SetColorTexture(1, 0, 0, 0.5);
        end
    end

    local function NiceSlice_SetCornerSize(frame, a)
        frame.NineSlice:SetTextureSliceMargins(32, 32, 32, 32);
        local offset = 0;
        frame.NineSlice:ClearAllPoints();
        frame.NineSlice:SetPoint("TOPLEFT", frame, "TOPLEFT", -offset, offset);
        frame.NineSlice:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", offset, -offset);
    end

    local function NiceSlice_SetTexture(frame, texture)
        frame.NineSlice:SetTexture(texture);
    end

    function SliceFrameMixin:CreatePieces(n)
        --[[
        if n == 9 then
            NiceSlice_CreatePieces(self);
            NiceSlice_SetCornerSize(self, 16);
            return
        end
        --]]

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
            --if true then
            --    NiceSlice_SetCornerSize(self, a);
            --    return
            --end
            self.pieces[1]:SetSize(a, a);
            self.pieces[3]:SetSize(a, a);
            self.pieces[7]:SetSize(a, a);
            self.pieces[9]:SetSize(a, a);
        end
    end

    function SliceFrameMixin:SetTexture(tex)
        --if self.NineSlice then
        --    NiceSlice_SetTexture(self, tex);
        --    return
        --end
        for i = 1, #self.pieces do
            self.pieces[i]:SetTexture(tex);
        end
    end

    function SliceFrameMixin:SetColor(r, g, b)
        for i = 1, #self.pieces do
            self.pieces[i]:SetVertexColor(r, g, b);
        end
    end

    function SliceFrameMixin:CoverParent(padding)
        padding = padding or 0;
        local parent = self:GetParent();
        if parent then
            self:ClearAllPoints();
            self:SetPoint("TOPLEFT", parent, "TOPLEFT", -padding, padding);
            self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", padding, -padding);
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

    local function CreateThreeSliceFrame(parent, layoutName, frameType)
        if not (layoutName and ThreeSliceLayouts[layoutName]) then
            layoutName = "GenericBox";
        end
        frameType = frameType or "Frame";
        local f = CreateFrame(frameType, nil, parent);
        Mixin(f, SliceFrameMixin);
        f:CreatePieces(3);
        f:SetTexture("Interface/AddOns/Plumber/Art/Frame/ThreeSlice_"..layoutName);
        f:ClearAllPoints();
        return f
    end
    addon.CreateThreeSliceFrame = CreateThreeSliceFrame;


    local function CreateTextureSlice(frame)
        if not frame.TextureSlice then
            frame.TextureSlice = frame:CreateTexture(nil, "BACKGROUND");
            frame.TextureSlice:SetTextureSliceMode(1); --Enum.UITextureSliceMode, 0 Stretched(Default)  1 Tiled
        end
        local pixelMargin = 1;
        frame.TextureSlice:SetTextureSliceMargins(pixelMargin, pixelMargin, pixelMargin, pixelMargin);
        local offset = 0;
        frame.TextureSlice:ClearAllPoints();
        frame.TextureSlice:SetPoint("TOPLEFT", frame, "TOPLEFT", -offset, offset);
        frame.TextureSlice:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", offset, -offset);
        frame.TextureSlice:SetTexture("Interface/AddOns/Plumber/Art/Frame/PixelBorder_Dashed_Moving");
    end

    addon.CreateTextureSlice = CreateTextureSlice;
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
            print("Plumber: DB Key not assigned");
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

    function CheckboxMixin:SetData(data)
        self.dbKey = data.dbKey;
        self.tooltip = data.tooltip;
        self.onClickFunc = data.onClickFunc;
        self.onEnterFunc = data.onEnterFunc;
        self.onLeaveFunc = data.onLeaveFunc;

        if data.label then
            return self:SetLabel(data.label)
        else
            return 0
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
    local TOKEN_FRAME_SIDE_PADDING = 8;
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
            self.Icon:SetTexture(134400);   --question mark
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
    local GetItemMaxStackSizeByID = C_Item.GetItemMaxStackSizeByID;

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
        local icon = GetItemIconByID(item);
        self:SetIcon(icon);
        self.id = item;
        self.actionType = "item";
        local stackSize = GetItemMaxStackSizeByID(item)
        self.stackable = stackSize and stackSize > 1;
        self:UpdateCount();
    end

    function PeudoActionButtonMixin:UpdateCount()
        local count = 0;

        if self.actionType == "item" then
            count = GetItemCount(self.id);
            if self.stackable then
                self.Count:SetText(count);
            else
                self.Count:SetText("");
            end
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
            --self.Count:SetText("");
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
    local ceil = math.ceil;

    local function Cooldown_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        if self.t < self.duration then
            self.EdgeTexture:SetRotation( self.t/self.duration * PI2 );
        end

        self.tick = self.tick + elapsed;
        if self.tick >= 0.2 then
            self.tick = 0;
            local startTimeMs, durationMs = self:GetCooldownTimes();
            local currentTimeSeconds = GetTime();
            local elapsedTime = currentTimeSeconds - (startTimeMs / 1000.0);
            local remainingTimeSeconds = (durationMs / 1000.0) - elapsedTime;
            self.t = elapsedTime;   --Sync time
            if self.showCountdownNumber then
                remainingTimeSeconds = ceil(remainingTimeSeconds);
                self.BackupCountdownNumber:SetText(remainingTimeSeconds);
            end
        end
    end

    function ActionButtonSpellCastOverlayMixin:SetDuration(second)
        second = second or 0;
        self.Cooldown:SetCooldownDuration(second);
        if second > 0 then
            self.Cooldown:Resume();
            self.Cooldown.t = 0;
            self.Cooldown.tick = 0;
            self.Cooldown.duration = second;
            self.Cooldown.EdgeTexture:Show();
            self.Cooldown.EdgeTexture:SetRotation(0);
            self.supposedEndTime = time() + second;
            local countdownNumberEnabled = C_CVar.GetCVarBool("countdownForCooldowns");
            self.Cooldown.showCountdownNumber = not countdownNumberEnabled;
            self.Cooldown.BackupCountdownNumber:SetShown(not countdownNumberEnabled);
            self.Cooldown.BackupCountdownNumber:SetText("");
            self.Cooldown:SetScript("OnUpdate", Cooldown_OnUpdate);
        else
            self.Cooldown:SetScript("OnUpdate", nil);
            self.Cooldown.EdgeTexture:Hide();
            self.supposedEndTime = nil;
            self.Cooldown.BackupCountdownNumber:SetText("");
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
        f.Cooldown:SetHideCountdownNumbers(false);  --globally controlled by CVar "countdownForCooldowns" (boolean)
        f.Cooldown.noCooldownCount = true;          --Disabled for OmniCC (  see OmniCC\core\cooldown.lua Cooldown:OnCooldownDone()  )

        local CountdownNumber = f.Cooldown:CreateFontString(nil, "OVERLAY", nil, 6);
        f.Cooldown.BackupCountdownNumber = CountdownNumber;
        local font, fontHeight, flBarShake = GameFontNormal:GetFont();
        CountdownNumber:SetFont(font, 16, "OUTLINE");
        CountdownNumber:SetPoint("CENTER", f.Cooldown, "CENTER", 0, -1);
        CountdownNumber:SetJustifyH("CENTER");
        CountdownNumber:SetJustifyV("MIDDLE");
        CountdownNumber:SetShadowOffset(1, -1);
        CountdownNumber:SetShadowColor(0, 0, 0);
        CountdownNumber:SetTextColor(1, 1, 1);

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

    local SecureButtons = {};               --All SecureButton that were created. Recycle/Share unused buttons unless it was specified not to
    local PrivateSecureButtons = {};        --These are the buttons that are not shared with other modules

    local SecureButtonContainer = CreateFrame("Frame");     --Always hidden
    SecureButtonContainer:Hide();

    function SecureButtonContainer:CollectButton(button)
        if not InCombatLockdown() then
            button:ClearAllPoints();
            button:Hide();
            button:SetParent(self);
            button:ClearActions();
            button:ClearScripts();
            button.isActive = false;
        end
    end

    SecureButtonContainer:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            local anyActive = false;
            for i, button in ipairs(SecureButtons) do
                if button.isActive then
                    self:CollectButton(button);
                    anyActive = true;
                end
            end

            if not anyActive then
                self:UnregisterEvent(event);
            end
        end
    end);

    local function SecureActionButton_OnHide(self)
        if self.isActive then
            self:Release();
        end
        if self.onHideCallback then
            self.onHideCallback(self);
        end
    end

    local SecureButtonMixin = {};

    function SecureButtonMixin:Release()
        SecureButtonContainer:CollectButton(self);
    end

    function SecureButtonMixin:ShowDebugHitRect(state)
        if state then
            if not self.debugBG then
                self.debugBG = self:CreateTexture(nil, "BACKGROUND");
                self.debugBG:SetAllPoints(true);
                self.debugBG:SetColorTexture(1, 0, 0, 0.5);
            end
        else
            if self.debugBG then
                self.debugBG:Hide();
            end
        end
    end

    function SecureButtonMixin:SetMacroText(macroText)
        self:SetAttribute("macrotext", macroText);
        self.macroText = macroText;
    end

    function SecureButtonMixin:ClearActions()
        if self.macroText then
            self.macroText = nil;
            self:SetAttribute("type", nil);
            self:SetAttribute("type1", nil);
            self:SetAttribute("type2", nil);
            self:SetAttribute("macrotext", nil);
        end
    end

    function SecureButtonMixin:ClearScripts()
        self:SetScript("OnEnter", nil);
        self:SetScript("OnLeave", nil);
        self:SetScript("PostClick", nil);
        self:SetScript("OnMouseDown", nil);
        self:SetScript("OnMouseUp", nil);
    end

    local function CreateSecureActionButton()
        if InCombatLockdown() then return end;
        local index = #SecureButtons + 1;
        local button = CreateFrame("Button", nil, nil, "InsecureActionButtonTemplate"); --Perform action outside of combat
        SecureButtons[index] = button;
        button.index = index;
        button.isActive = true;
        Mixin(button, SecureButtonMixin);

        button:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonDown", "RightButtonUp");
        button:SetScript("OnHide", SecureActionButton_OnHide);

        SecureButtonContainer:RegisterEvent("PLAYER_REGEN_DISABLED");
        --SecureButtonContainer:RegisterEvent("PLAYER_REGEN_ENABLED");

        return button
    end

    local function AcquireSecureActionButton(privateKey)
        if InCombatLockdown() then return end;

        local button;

        if privateKey then
            button = PrivateSecureButtons[privateKey];
            if not button then
                button = CreateSecureActionButton();
                PrivateSecureButtons[privateKey] = button;
            end
        else
            for i, b in ipairs(SecureButtons) do
                if not b:IsShown() then
                    b.isActive = true;
                    button = b;
                    break
                end
            end

            if not button then
                button = CreateSecureActionButton();
            end
        end

        button.isActive = true;
        SecureButtonContainer:RegisterEvent("PLAYER_REGEN_DISABLED");

        return button
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

            local font, height, flBarShake = GameFontHighlightSmall:GetFont();
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
                self.BarMark:SetTexCoord(0.625, 1, 0.515625, 0.765625);
                self.BarMark:SetSize(24, 16);
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


    local TinyStatusBarMixin = {};

    function TinyStatusBarMixin:Init()
        local px = API.GetPixelForWidget(self, 1);
        self.Stroke:SetPoint("TOPLEFT", self, "TOPLEFT", -px, px);
        self.Stroke:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", px, -px);
        self.OutStroke:SetPoint("TOPLEFT", self, "TOPLEFT", -2*px, 2*px);
        self.OutStroke:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 2*px, -2*px);
        self:SetHeight((self.heightPixel or 2)*px);
        self:UpdateMaxBarFillWidth();
    end

    function TinyStatusBarMixin:SetBarColor(r, g, b)
        self.BarFill:SetColorTexture(r, g, b);
    end

    function TinyStatusBarMixin:Calibrate()
        if self.startTime then
            local currentTime = time();
            self.t0 = currentTime - self.startTime;
            self.s1 = self.t0;
            self.DisplayProgress(self);
        end
    end

    function TinyStatusBarMixin:Clear()
        self:SetScript("OnUpdate", nil);
        self.t = 0;
        self.duration = 0;
        self.startTime = nil;
        self.BarFill:Hide();
    end

    function TinyStatusBarMixin:UpdateMaxBarFillWidth()
        self.maxBarFillWidth = self:GetWidth();
    end

    function TinyStatusBarMixin:SetTimes(currentSecond, total)
        if currentSecond >= total or total == 0 then
            self:Clear();
        else
            self.t = currentSecond;
            self.duration = total;
            self:SetScript("OnUpdate", self.OnUpdate);
            self:DisplayProgress();
            self.startTime = time();
            self.BarFill:Show();
        end
    end

    function TinyStatusBarMixin:DisplayProgress()
        if self.isReverse then
            self.BarFill:SetWidth(self.maxBarFillWidth * (1 - self.t/self.duration));
        else
            self.BarFill:SetWidth(self.maxBarFillWidth * self.t/self.duration);
        end
    end

    function TinyStatusBarMixin:SetDuration(second)
        self:SetTimes(0, second);
    end

    function TinyStatusBarMixin:SetEndTime(endTime)
        local t = time();
        self:SetDuration( (t > endTime and (t - endTime)) or 0 );
    end

    function TinyStatusBarMixin:SetReverse(reverse)
        self.isReverse = reverse;
    end

    function TinyStatusBarMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t >= self.duration then
            self:SetScript("OnUpdate", nil);
            self.BarFill:Hide();
            return
        end
        self:DisplayProgress();
    end

    function TinyStatusBarMixin:SetBarHeight(pixel)
        if pixel ~= self.heightPixel then
            self.heightPixel = pixel;
            self:Init();
        end
    end

    local function CreateTinyStatusBar(parent)
        local f = CreateFrame("Frame", nil, parent);
        f:SetSize(24, 2);

        f.BarBG = f:CreateTexture(nil, "ARTWORK");
        f.BarBG:SetAllPoints(true);
        f.BarBG:SetColorTexture(0, 0, 0, 0.5);

        f.Stroke = f:CreateTexture(nil, "BORDER");
        f.Stroke:SetColorTexture(0, 0, 0);
        f.Stroke:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 1);
        f.Stroke:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1);

        f.OutStroke = f:CreateTexture(nil, "BACKGROUND");
        f.OutStroke:SetColorTexture(1, 0.82, 0, 0.5);
        f.OutStroke:SetPoint("TOPLEFT", f, "TOPLEFT", -2, 2);
        f.OutStroke:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 2, -2);

        local mask1 = f:CreateMaskTexture(nil, "BORDER");
        mask1:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
        mask1:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);
        mask1:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Exclusion", "CLAMPTOWHITE", "CLAMPTOWHITE");
        f.Stroke:AddMaskTexture(mask1);

        local mask2 = f:CreateMaskTexture(nil, "BACKGROUND");
        mask2:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
        mask2:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);
        mask2:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Exclusion", "CLAMPTOWHITE", "CLAMPTOWHITE");
        f.OutStroke:AddMaskTexture(mask2);
    
        f.BarFill = f:CreateTexture(nil, "OVERLAY");
        f.BarFill:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
        f.BarFill:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0);
        f.BarFill:SetWidth(12);

        DisableSharpening(f.BarBG);
        DisableSharpening(f.Stroke);
        DisableSharpening(f.OutStroke);
        DisableSharpening(mask1);
        DisableSharpening(mask2);
        DisableSharpening(f.BarFill);

        Mixin(f, TinyStatusBarMixin);
        f:SetBarColor(1, 0.82, 0);
        f:SetBarHeight(2);
        f:SetScript("OnShow", f.Calibrate);
        f:Init();

        return f
    end
    addon.CreateTinyStatusBar = CreateTinyStatusBar;
end

do  --Red Button
    local RedButtonMixin = {};


    local LONG_CLICK_DURATION = 0.5;
    local LongClickListner = CreateFrame("Frame");

    function LongClickListner:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t >= LONG_CLICK_DURATION then
            self:SetScript("OnUpdate", nil);
            if self.owner and self.owner:IsVisible() and self.owner:IsEnabled() then
                self.owner:SetButtonState(4);
            end
        end
    end

    function LongClickListner:SetOwner(button)
        self:SetParent(button);
        self.owner = button;
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
        self:Show();
    end

    function LongClickListner:Stop()
        self:SetScript("OnUpdate", nil);
        self.owner = nil;
        self:Hide();
    end

    function LongClickListner:OnHide()
        self:Stop();
    end
    LongClickListner:SetScript("OnHide", LongClickListner.OnHide);


    function RedButtonMixin:SetButtonText(text)
        self.ButtonText:SetText(text);
    end

    local function SetButtonState_Nomral(self, stateIndex)
        local top = 0.25*(stateIndex - 1);
        local bottom = 0.25*stateIndex;
        self.Left:SetTexCoord(0, 0.125, top, bottom);
        self.Middle:SetTexCoord(0.125, 0.875, top, bottom);
        self.Right:SetTexCoord(0.875, 1, top, bottom);
    end

    local function SetButtonState_Large(self, stateIndex)
        local top = 0.1875*(stateIndex - 1);
        local bottom = 0.1875*stateIndex;
        self.Left:SetTexCoord(0, 0.125, top, bottom);
        self.Middle:SetTexCoord(0.125, 0.875, top, bottom);
        self.Right:SetTexCoord(0.875, 1, top, bottom);
    end

    function RedButtonMixin:SetButtonState(stateIndex)
        --1 Normal  2 Pushed  3 Disabled
        if stateIndex ~= self.stateIndex then
            self.stateIndex = stateIndex;
        else
            return
        end

        if stateIndex == 1 or stateIndex == 2 or stateIndex == 4 then --Normal/Pushed/LongClick
            self:Enable();
            if self:IsShown() and self:IsMouseOver() then
                self.ButtonText:SetTextColor(1, 1, 1);
            else
                self.ButtonText:SetTextColor(1, 0.82, 0);
            end
            if stateIndex == 1 then
                self.ButtonText:SetPoint("CENTER", 0, 0);
                self:StopAllAnimations();
            elseif stateIndex == 2 then
                self.ButtonText:SetPoint("CENTER", self.pushOffset, -self.pushOffset);
                self:StopAllAnimations();
            elseif stateIndex == 4 then
                self.ButtonText:SetPoint("CENTER", self.pushOffset, -self.pushOffset*2);
                self.AnimPulse:Play();
            end
        elseif stateIndex == 3 then --Disabled
            self:Disable();
            self:StopAllAnimations();
            self.ButtonText:SetTextColor(0.5, 0.5, 0.5);
            self.ButtonText:SetPoint("CENTER", 0, 0);
        end

        self.SetButtonStateFunc(self, stateIndex);
    end

    function RedButtonMixin:OnMouseDown(button)
        if not self:IsEnabled() then return end;
        self:SetButtonState(2);

        if button == "LeftButton" then
            self.leftButtonDown = true;
            if self.onMouseDownFunc then
                self.onMouseDownFunc(self);
            end

            if self.canLongClick then
                self.AnimFill:Play();
                LongClickListner:SetOwner(self);
            end
        end
    end

    function RedButtonMixin:StopAllAnimations()
        self.AnimFill:Stop();
        self.AnimPulse:Stop();
    end

    function RedButtonMixin:OnMouseUp()
        self.leftButtonDown = nil;

        LongClickListner:Stop();
        self:StopAllAnimations();

        if self.onMouseUpFunc then
            self.onMouseUpFunc(self);
        end
        if not self:IsEnabled() then return end;
        self:SetButtonState(1);
    end

    function RedButtonMixin:OnHide()
        if self:IsEnabled() then
            self:SetButtonState(1);
        else
            self:SetButtonState(3);
        end
        self.leftButtonDown = nil;
    end

    function RedButtonMixin:OnEnter()
        if self:IsEnabled() then
            self.ButtonText:SetTextColor(1, 1, 1);
        end
    end

    function RedButtonMixin:OnLeave()
        if self:IsEnabled() then
            self.ButtonText:SetTextColor(1, 0.82, 0);
        end
    end

    local function CreateLongClickAnimation(f)
        local ScanTexture = f:CreateTexture(nil, "OVERLAY", nil, -1);
        f.ScanTexture = ScanTexture;
        ScanTexture:SetSize(46, 21);
        ScanTexture:SetPoint("RIGHT", f, "RIGHT", -184, -1);
        ScanTexture:SetTexture("Interface/AddOns/Plumber/Art/Frame/RedButton-Scan", nil, nil, "TRILINEAR");
        ScanTexture:SetVertexColor(0.4, 0.1, 0.1);
        ScanTexture:SetBlendMode("ADD");
        ScanTexture:SetAlpha(0);

        local AnimFill = f:CreateAnimationGroup();
        f.AnimFill = AnimFill;
        AnimFill:SetToFinalAlpha(true);
        local t1 = AnimFill:CreateAnimation("Translation");
        t1:SetChildKey("ScanTexture");
        t1:SetOffset(184, 0);
        t1:SetDuration(LONG_CLICK_DURATION);
        t1:SetOrder(1);
        local a1 = AnimFill:CreateAnimation("Alpha");
        a1:SetChildKey("ScanTexture");
        a1:SetFromAlpha(0);
        a1:SetToAlpha(1);
        a1:SetDuration(0.1);
        a1:SetOrder(1);
        local a2 = AnimFill:CreateAnimation("Alpha");
        a2:SetChildKey("ScanTexture");
        a2:SetFromAlpha(1);
        a2:SetToAlpha(0);
        a2:SetDuration(0.5);
        a2:SetStartDelay(LONG_CLICK_DURATION);
        a2:SetOrder(1);

        local PulseTexture = f:CreateTexture(nil, "OVERLAY", nil, -1);
        f.PulseTexture = PulseTexture;
        PulseTexture:SetPoint("TOPLEFT", f, "LEFT", 4, 8);
        PulseTexture:SetPoint("BOTTOMRIGHT", f, "RIGHT", -2, -12);
        PulseTexture:SetTexture("Interface/AddOns/Plumber/Art/Frame/RedButton-Pulse", nil, nil, "TRILINEAR");
        PulseTexture:SetVertexColor(0.5, 0.25, 0.1);
        PulseTexture:SetBlendMode("ADD");
        PulseTexture:SetAlpha(0);

        local AnimPulse = f:CreateAnimationGroup();
        f.AnimPulse = AnimPulse;
        AnimPulse:SetToFinalAlpha(true);
        AnimPulse:SetLooping("BOUNCE");
        local a5 = AnimPulse:CreateAnimation("Alpha");
        a5:SetChildKey("PulseTexture");
        a5:SetFromAlpha(0);
        a5:SetToAlpha(1);
        a5:SetDuration(0.5);
        a5:SetOrder(1);
    end

    local function CreateRedButton(parent, sizeType)
        sizeType = sizeType or "normal";

        local f = CreateFrame("Button", nil, parent);
        Mixin(f, RedButtonMixin);

        f:SetScript("OnMouseDown", RedButtonMixin.OnMouseDown);
        f:SetScript("OnMouseUp", RedButtonMixin.OnMouseUp);
        f:SetScript("OnHide", RedButtonMixin.OnHide);
        f:SetScript("OnEnter", RedButtonMixin.OnEnter);
        f:SetScript("OnLeave", RedButtonMixin.OnLeave);

        f.Left = f:CreateTexture(nil, "BORDER");
        f.Left:SetPoint("CENTER", f, "LEFT", 0, 0);

        f.Right = f:CreateTexture(nil, "BORDER");
        f.Right:SetPoint("CENTER", f, "RIGHT", 0, 0);

        f.Middle = f:CreateTexture(nil, "BORDER");
        f.Middle:SetPoint("TOPLEFT", f.Left, "TOPRIGHT", 0, 0);
        f.Middle:SetPoint("BOTTOMRIGHT", f.Right, "BOTTOMLEFT", 0, 0);

        local file;
        if sizeType == "normal" then
            file = "RedButton-Normal";
            f:SetSize(112, 22);
            f.Left:SetSize(16, 32);
            f.Right:SetSize(16, 32);
            f.SetButtonStateFunc = SetButtonState_Nomral;
            f.pushOffset = 1;
        elseif sizeType == "large" then
            file = "RedButton-Large";
            f:SetSize(224, 30);
            f.Left:SetSize(32, 48);
            f.Right:SetSize(32, 48);
            f.SetButtonStateFunc = SetButtonState_Large;
            f.pushOffset = 2;
        end
        file = "Interface/AddOns/Plumber/Art/Frame/"..file;
        f.Left:SetTexture(file);
        f.Right:SetTexture(file);
        f.Middle:SetTexture(file);

        f.ButtonText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal", 4);
        f.ButtonText:SetJustifyH("CENTER");
        f.ButtonText:SetJustifyV("MIDDLE");
        f.ButtonText:SetTextColor(1, 0.82, 0);
        f.ButtonText:SetPoint("CENTER", f, "CENTER", 0, 0);

        f.Highlight = f:CreateTexture(nil, "HIGHLIGHT");
        f.Highlight:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
        f.Highlight:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);
        f.Highlight:SetTexture("Interface/AddOns/Plumber/Art/Frame/RedButton-Highlight", nil, nil, "TRILINEAR");
        f.Highlight:SetVertexColor(0.4, 0.1, 0.1);
        f.Highlight:SetBlendMode("ADD");

        DisableSharpening(f.Left);
        DisableSharpening(f.Right);
        DisableSharpening(f.Middle);

        CreateLongClickAnimation(f);
        f:SetButtonState(1);

        return f
    end
    addon.CreateRedButton = CreateRedButton;
end

do  --Metal Progress Bar
    local ProgressBarMixin = {};

    function ProgressBarMixin:SetBarWidth(width)
        self:SetWidth(width);
        self.maxBarFillWidth = width;
    end

    function ProgressBarMixin:SetValueByRatio(ratio)
        self.BarFill:SetWidth(ratio * self.maxBarFillWidth);
        self.BarFill:SetTexCoord(0, ratio, self.barfillTop, self.barfillBottom);
        self.visualRatio = ratio;
    end

    local FILL_SIZE_PER_SEC = 100;
    local EasingFunc = addon.EasingFunctions.outQuart;

    local function SmoothFill_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        local ratio = EasingFunc(self.t, self.fromRatio, self.toRatio, self.easeDuration);
        if self.t >= self.easeDuration then
            ratio = self.toRatio;
            self.easeDuration = nil;
            self:SetScript("OnUpdate", nil);
        end
        self:SetValueByRatio(ratio);
    end

    function ProgressBarMixin:SetValue(barValue, barMax, playPulse)
        if barValue > barMax then
            barValue = barMax;
        end
        if self.BarValue then
            self.BarValue:SetText(barValue.."/"..barMax);
        end
        if barValue == 0 or barMax == 0 then
            self.BarFill:Hide();
            self:SetScript("OnUpdate", nil);
        else
            self.BarFill:Show();
            local newRatio = barValue/barMax;
            if self.smoothFill then
                local deltaRatio, oldRatio;

                if self.barMax and self.visualRatio then
                    if self.barMax == 0 then
                        oldRatio = 0;
                    else
                        oldRatio = self.visualRatio;
                    end
                    deltaRatio = newRatio - oldRatio;
                else
                    oldRatio = 0;
                    deltaRatio = newRatio;
                end

                if oldRatio < 0 then
                    oldRatio = -oldRatio;
                end

                if deltaRatio < 0 then
                    deltaRatio = -deltaRatio;
                end

                local easeDuration = deltaRatio*self.maxBarFillWidth / FILL_SIZE_PER_SEC;

                if self.wasHidden then
                    --don't animte if the bar was hidden
                    self.wasHidden = false;
                    easeDuration = 0;
                end
                if easeDuration > 0.25 then
                    self.toRatio = newRatio;
                    self.fromRatio = oldRatio;
                    if easeDuration > 1.5 then
                        easeDuration = 1.5;
                    end
                    self.easeDuration = easeDuration;
                    self.t = 0;
                    self:SetScript("OnUpdate", SmoothFill_OnUpdate);
                else
                    self.easeDuration = nil;
                    self:SetValueByRatio(newRatio);
                    self:SetScript("OnUpdate", nil);
                end
            else
                self:SetValueByRatio(newRatio);
            end
        end

        if playPulse and barValue > self.barValue then
            self:Flash();
        end

        self.barValue = barValue;
        self.barMax = barMax;
    end

    function ProgressBarMixin:OnHide()
        self.wasHidden = true;
    end

    function ProgressBarMixin:GetValue()
        return self.barValue
    end

    function ProgressBarMixin:GetBarMax()
        return self.barMax
    end

    function ProgressBarMixin:SetSmoothFill(state)
        state = state or false;
        self.smoothFill = state;
        if not state then
            self:SetScript("OnUpdate", nil);
            if self.barValue and self.barMax then
                self:SetValue(self.barValue, self.barMax);
            end
            self.easeDuration = nil;
        end
    end

    function ProgressBarMixin:Flash()
        self.BarPulse.AnimPulse:Stop();
        self.BarPulse.AnimPulse:Play();
        if self.playShake then
            self.BarShake:Play();
        end
    end

    function ProgressBarMixin:SetBarColor(r, g, b)
        self.BarFill:SetVertexColor(r, g, b);
    end

    function ProgressBarMixin:SetBarColorTint(index)
        if index < 1 or index > 8 then index = 2 end;   --White

        if index ~= self.colorTint then
            self.colorTint = index;
        else
            return
        end

        self.BarFill:SetVertexColor(1, 1, 1);
        self.barfillTop = (index - 1)*0.125;
        self.barfillBottom = index*0.125;

        if self.barValue and self.barMax then
            self:SetValue(self.barValue, self.barMax);
        end
    end

    function ProgressBarMixin:GetBarColorTint()
        return self.colorTint
    end

    local function SetupNotchTexture_Normal(notch)
        notch:SetTexCoord(0.815, 0.875, 0, 0.375);
        notch:SetSize(16, 24);
    end

    local function SetupNotchTexture_Large(notch)
        notch:SetTexCoord(0.5625, 0.59375, 0, 0.25);
        notch:SetSize(16, 64);
    end

    function ProgressBarMixin:SetNumThreshold(numThreshold)
        --Divide the bar evenly
        --"partitionValues", in Blizzard's term
        if numThreshold == self.numThreshold then return end;
        self.numThreshold = numThreshold;

        if not self.notches then
            self.notches = {};
        end

        for _, n in ipairs(self.notches) do
            n:Hide();
        end

        if numThreshold == 0 then return end;

        local d = self.maxBarFillWidth / (numThreshold + 1);
        for i = 1, numThreshold do
            if not self.notches[i] then
                self.notches[i] = self.Container:CreateTexture(nil, "OVERLAY", nil, 2);
                self.notches[i]:SetTexture(self.textureFile);
                self.SetupNotchTexture(self.notches[i]);
                API.DisableSharpening(self.notches[i]);
            end
            self.notches[i]:ClearAllPoints();
            self.notches[i]:SetPoint("CENTER", self.Container, "LEFT", i*d, 0);
            self.notches[i]:Show();
        end
    end

    local function CreateMetalProgressBar(parent, sizeType)
        sizeType = sizeType or "normal";

        local f = CreateFrame("Frame", nil, parent);
        Mixin(f, ProgressBarMixin);

        f:SetScript("OnHide", ProgressBarMixin.OnHide);

        local Container = CreateFrame("Frame", nil, f); --Textures are attached to this frame, so we can setup animations
        f.Container = Container;
        Container:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
        Container:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0 ,0);

        f.visualRatio = 0;
        f.wasHidden = true;

        f.BarFill = Container:CreateTexture(nil, "ARTWORK");
        f.BarFill:SetTexCoord(0, 1, 0, 0.125);
        f.BarFill:SetTexture("Interface/AddOns/Plumber/Art/Frame/ProgressBar-Fill");
        f.BarFill:SetPoint("LEFT", Container, "LEFT", 0, 0);

        f.Background = Container:CreateTexture(nil, "BACKGROUND");
        f.Background:SetColorTexture(0.1, 0.1, 0.1, 0.8);
        f.Background:SetPoint("TOPLEFT", Container, "TOPLEFT", 0, -2);
        f.Background:SetPoint("BOTTOMRIGHT", Container, "BOTTOMRIGHT", 0, 2);

        f.BarLeft = Container:CreateTexture(nil, "OVERLAY");
        f.BarLeft:SetPoint("CENTER", Container, "LEFT", 0, 0);

        f.BarRight = Container:CreateTexture(nil, "OVERLAY");
        f.BarRight:SetPoint("CENTER", Container, "RIGHT", 0, 0);

        f.BarMiddle = Container:CreateTexture(nil, "OVERLAY");
        f.BarMiddle:SetPoint("TOPLEFT", f.BarLeft, "TOPRIGHT", 0, 0);
        f.BarMiddle:SetPoint("BOTTOMRIGHT", f.BarRight, "BOTTOMLEFT", 0, 0);

        local file, barWidth, barHeight;
        if sizeType == "normal" then
            file = "ProgressBar-Metal-Normal";
            barWidth, barHeight = 168, 18;
            f.BarLeft:SetTexCoord(0, 0.09375, 0, 0.375);
            f.BarRight:SetTexCoord(0.65625, 0.75, 0, 0.375);
            f.BarMiddle:SetTexCoord(0.09375, 0.65625, 0, 0.375);
            f.BarLeft:SetSize(24, 24);
            f.BarRight:SetSize(24, 24);
            f.BarFill:SetSize(barWidth, 12);
            f.SetupNotchTexture = SetupNotchTexture_Normal;
        elseif sizeType == "large" then
            file = "ProgressBar-Metal-Large";
            barWidth, barHeight = 248, 28;  --32
            f.BarLeft:SetTexCoord(0, 0.0625, 0, 0.25);
            f.BarRight:SetTexCoord(0.46875, 0.53125, 0, 0.25);
            f.BarMiddle:SetTexCoord(0.0625, 0.46875, 0, 0.25);
            f.BarLeft:SetSize(32, 64);
            f.BarRight:SetSize(32, 64);
            f.BarFill:SetSize(barWidth, 20);    --24
            f.SetupNotchTexture = SetupNotchTexture_Large;
        end

        local barFile = "Interface/AddOns/Plumber/Art/Frame/"..file;
        f.textureFile = barFile;
        f.BarLeft:SetTexture(barFile);
        f.BarRight:SetTexture(barFile);
        f.BarMiddle:SetTexture(barFile);

        API.DisableSharpening(f.BarFill);
        API.DisableSharpening(f.BarLeft);
        API.DisableSharpening(f.BarRight);
        API.DisableSharpening(f.BarMiddle);

        f:SetBarWidth(barWidth);
        f:SetHeight(barHeight);
        f:SetBarColorTint(2);
        --f:SetNumThreshold(0);
        f:SetValue(0, 100);

        
        local BarPulse = CreateFrame("Frame", nil, f, "PlumberBarPulseTemplate");
        BarPulse:SetPoint("RIGHT", f.BarFill, "RIGHT", 0, 0);
        f.BarPulse = BarPulse;

        
        local BarShake = Container:CreateAnimationGroup();
        f.BarShake = BarShake;
        local a1 = BarShake:CreateAnimation("Translation");
        a1:SetOrder(1);
        a1:SetStartDelay(0.15);
        a1:SetOffset(3, 0);
        a1:SetDuration(0.05);
        local a2 = BarShake:CreateAnimation("Translation");
        a2:SetOrder(2);
        a2:SetOffset(-4, 0);
        a2:SetDuration(0.1);
        local a3 = BarShake:CreateAnimation("Translation");
        a3:SetOrder(3);
        a3:SetOffset(1, 0);
        a3:SetDuration(0.1);

        return f
    end
    addon.CreateMetalProgressBar = CreateMetalProgressBar;
end

do
    local function CreateTextDropShadow(fontString, parent)
        parent = parent or fontString:GetParent();
        local Shadow = parent:CreateTexture(nil, "BACKGROUND", nil, -1);
        Shadow:SetPoint("TOPLEFT", fontString, "TOPLEFT", -8, 6);
        Shadow:SetPoint("BOTTOMRIGHT", fontString, "BOTTOMRIGHT", 8, -8);
        Shadow:SetTexture("Interface/AddOns/Plumber/Art/Button/GenericTextDropShadow");
        fontString.Shadow = Shadow;
    end
    addon.CreateTextDropShadow = CreateTextDropShadow;
end

do  --Hotkey/Keyboard Icon
    local TEXTURE_WIDTH, TEXTURE_HEIGHT = 256, 256;
    local BLEEDING = 10;    --the distance between the key icon and the texture edge
    local PIXEL_INGAME_RATIO = 0.5;

    local KeyboardKeys;

    if IsMacClient and IsMacClient() then
        --Mac
        KeyboardKeys = {
            --Key = {left(pixel), right, top, bottom, keyName}
            Alt = {128, 192, 0, 64, "LALT"},
        };
    else
        --Windows
        KeyboardKeys = {
            Alt = {0, 78, 0, 64, "LALT"},
        };
    end


    local HotkeyIconMixin = {};

    function HotkeyIconMixin:SetKey(key, responsive)
        self.responsive = responsive or false;

        if responsive then
            self:SetScript("OnEvent", self.OnEvent);
        else
            self:SetScript("OnEvent", nil);
        end

        if key == self.hotkey then
            return
        else
            self.hotkey = key;
        end

        if KeyboardKeys[key] then
            local left, right, top, bottom, keyName = unpack(KeyboardKeys[key]);
            local textureWidth = (right - left) * PIXEL_INGAME_RATIO;
            local textureHeight = (bottom - top) * PIXEL_INGAME_RATIO;
            local effectiveWidth = (right - left - 2*BLEEDING) * PIXEL_INGAME_RATIO;
            local effectiveHeight = (bottom - top - 2*BLEEDING) * PIXEL_INGAME_RATIO;
            self.Texture:SetTexCoord(left/TEXTURE_WIDTH, right/TEXTURE_WIDTH, top/TEXTURE_HEIGHT, bottom/TEXTURE_HEIGHT);
            self.Texture:SetSize(textureWidth, textureHeight);
            self:SetSize(effectiveWidth, effectiveHeight);
            self.keyName = keyName;
        end
    end

    function HotkeyIconMixin:Flash()
        self.AnimFlash:Stop();
        self.AnimFlash:Play();
    end

    function HotkeyIconMixin:OnShow()
        self.FlashTexture:SetAlpha(0);
        if self.responsive and self.hotkey then
            self:RegisterEvent("MODIFIER_STATE_CHANGED");
        end
    end

    function HotkeyIconMixin:OnHide()
        self:UnregisterEvent("MODIFIER_STATE_CHANGED");
        self.AnimFlash:Stop();
    end

    function HotkeyIconMixin:OnEvent(event, ...)
        if event == "MODIFIER_STATE_CHANGED" then
            local key, down = ...
            if down == 1 then
                if key == self.keyName then
                    self:Flash();
                end
            end
        end
    end

    local function CreateHotkeyIcon(parent)
        local f = CreateFrame("Frame", nil, parent);
        f:SetSize(22, 22);
        f.Texture = f:CreateTexture(nil, "ARTWORK");
        f.Texture:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.Texture:SetSize(32, 32);
        f.Texture:SetTexture("Interface/AddOns/Plumber/Art/Button/Keyboard", nil, nil, "LINEAR");
        f.Texture:SetTexCoord(0, 0.001, 0, 0.001);
        DisableSharpening(f.Texture);

        f.FlashTexture = f:CreateTexture(nil, "OVERLAY");
        f.FlashTexture:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 2, 1);
        f.FlashTexture:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 1);
        f.FlashTexture:SetHeight(8);
        f.FlashTexture:SetTexture("Interface/AddOns/Plumber/Art/Button/KeyboardFlash", nil, nil, "TRILINEAR");
        f.FlashTexture:SetBlendMode("ADD");
        f.FlashTexture:SetAlpha(0);

        local AnimFlash = f:CreateAnimationGroup();
        AnimFlash:SetToFinalAlpha(true);
        f.AnimFlash = AnimFlash;
        local a1 = AnimFlash:CreateAnimation("ALPHA");
        a1:SetChildKey("FlashTexture");
        a1:SetFromAlpha(0);
        a1:SetToAlpha(0.67);
        a1:SetDuration(0.1);
        a1:SetOrder(1);
        local a2 = AnimFlash:CreateAnimation("ALPHA");
        a2:SetChildKey("FlashTexture");
        a2:SetFromAlpha(0.67);
        a2:SetToAlpha(0);
        a2:SetDuration(0.5);
        a2:SetOrder(2);

        Mixin(f, HotkeyIconMixin);
        f:SetScript("OnShow", HotkeyIconMixin.OnShow);
        f:SetScript("OnHide", HotkeyIconMixin.OnHide);

        return f
    end
    addon.CreateHotkeyIcon = CreateHotkeyIcon;
end

do  --Cursor Cooldown (Displayed near the cursor)
    local UnitCastingInfo = UnitCastingInfo;

    local CursorProgressIndicator;

    local CursorProgressMixin = {};

    function CursorProgressMixin:FadeIn()
        FadeFrame(self, 0.2, 1, 0);
    end

    function CursorProgressMixin:FadeOut()
        FadeFrame(self, 0.2, 0);
    end

    function CursorProgressMixin:OnHide()
        self:Clear();
    end

    function CursorProgressMixin:SetColorIndex(colorIndex)
        if colorIndex == 1 then
            self:SetSwipeTexture("Interface/AddOns/Plumber/Art/Button/GenericCooldown-Swipe-Blue");
        elseif colorIndex == 2 then
            self:SetSwipeTexture("Interface/AddOns/Plumber/Art/Button/GenericCooldown-Swipe-Yellow");
        end
    end

    function CursorProgressMixin:OnEvent(event, ...)
        if event == "UNIT_SPELLCAST_START" then
            local _, _, spellID = ...
            if spellID ~= self.watchedSpellID then
                return
            end
            local _, _, _, startTimeMs, endTimeMs = UnitCastingInfo("player");
			if startTimeMs and endTimeMs then
				--self:SetCooldownUNIX(startTime, endTime - startTime);
                local durationMs = endTimeMs - startTimeMs;
                self:SetCooldown(startTimeMs / 1000.0, durationMs / 1000.0);
                self:FadeIn();
            else
                self:Clear();
			end
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then

        elseif event == "UNIT_SPELLCAST_STOP" then
            self:Clear();
        end
    end

    function CursorProgressMixin:WatchSpell(spellID)
        self.watchedSpellID = spellID;
        self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player");
        self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
        self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player");
    end

    function CursorProgressMixin:ClearWatch()
        self:Hide();
        self:Clear();
        self:UnregisterEvent("UNIT_SPELLCAST_START");
        self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
        self:UnregisterEvent("UNIT_SPELLCAST_STOP");
    end

    local function AcquireCursorProgressIndicator()
        if not CursorProgressIndicator then
            local f = CreateFrame("Cooldown", nil, UIParent, "PlumberGenericCooldownTemplate");
            CursorProgressIndicator = f;
            f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
            Mixin(f, CursorProgressMixin);
            DisableSharpening(f.Background);
            f:SetScript("OnEvent", CursorProgressMixin.OnEvent);
            f:SetScript("OnHide", CursorProgressMixin.OnHide);
            f:SetUseCircularEdge(true);
            f:SetColorIndex(2);
            f:SetFrameStrata("FULLSCREEN");
            f:SetFixedFrameStrata(true);
            f:WatchSpell();
        end
        return CursorProgressIndicator
    end
    addon.AcquireCursorProgressIndicator = AcquireCursorProgressIndicator;
end

do  --Simple Size Select (S/M/L)
    local OPTION_BUTTON_WIDTH = 16;     --Slightly larger: served as gap between buttons
    local OPTION_BUTTON_HEIGHT = 14;

    local SizeOptionButtonMixin = {};

    function SizeOptionButtonMixin:OnEnter()
        self:SetAlpha(1);
        self:GetParent():ShowTitle(true);
    end

    function SizeOptionButtonMixin:OnLeave()
        if not self.selected then
            self:SetAlpha(0.6);
        else
            self:SetAlpha(0.8);
        end
        self:GetParent():ShowTitle(false);
    end

    function SizeOptionButtonMixin:OnClick()
        self:GetParent():SelectSize(self.id, true);
    end

    function SizeOptionButtonMixin:SetSelected(state)
        self.selected = state;
        if state then
            self.Icon:SetTexCoord(0.25*(self.id - 1), 0.25*self.id, 0, 0.5);
            self:SetAlpha(1);
        else
            self.Icon:SetTexCoord(0.25*(self.id - 1), 0.25*self.id, 0.5, 1);
        end

        if self:IsMouseOver() then
            self:SetAlpha(1);
        else
            if state then
                self:SetAlpha(0.8);
            else
                self:SetAlpha(0.6);
            end
        end
    end


    local SizeSelectMixin = {};

    function SizeSelectMixin:SelectSize(id, runScript)
        if id ~= self.selectedSize then
            self.selectedSize = id;
        else
            return
        end

        for i, button in ipairs(self.buttons) do
            button:SetSelected(i == id);
        end

        if runScript and self.callback then
            self.callback(id, true);
        end
    end

    function SizeSelectMixin:SetNumChoices(numChoices)
        if numChoices > 3 then
            numChoices = 3;
        end

        if numChoices ~= self.numChoices then
            self.numChoices = numChoices;
        else
            return
        end

        if not self.buttons then
            self.buttons = {};
        end

        for i = 1, numChoices do
            if not self.buttons[i] then
                local button = CreateFrame("Button", nil, self);
                self.buttons[i] = button;
                button.id = i;
                button:SetSize(OPTION_BUTTON_WIDTH, OPTION_BUTTON_HEIGHT);
                button:SetPoint("LEFT", self, "LEFT", (i - 1)*OPTION_BUTTON_WIDTH, 0);
                button.Icon = button:CreateTexture(nil, "OVERLAY");
                button.Icon:SetSize(OPTION_BUTTON_HEIGHT, OPTION_BUTTON_HEIGHT);
                button.Icon:SetPoint("CENTER", button, "CENTER", 0, 0);
                button.Icon:SetTexture("Interface/AddOns/Plumber/Art/Button/SimpleSizeSelect");
                button.Icon:SetTexCoord(0.75, 1, 0.5, 1);
                button:SetAlpha(0.6);
                button:SetScript("OnEnter", SizeOptionButtonMixin.OnEnter);
                button:SetScript("OnLeave", SizeOptionButtonMixin.OnLeave);
                button:SetScript("OnClick", SizeOptionButtonMixin.OnClick);
                Mixin(button, SizeOptionButtonMixin);
            end
            self.buttons[i]:Show();
        end
        self:SetWidth(numChoices*OPTION_BUTTON_WIDTH);

        for i = numChoices + 1, #self.buttons do
            self.buttons[i]:Hide();
        end
    end

    function SizeSelectMixin:SetOnSizeChangedCallback(callback)
        self.callback = callback;
    end

    function SizeSelectMixin:ShowTitle(state)
        self.Title:SetShown(state);
    end

    local function CreateSimpleSizeSelect(parent)
        local f = CreateFrame("Frame", nil, parent);
        f:SetSize(OPTION_BUTTON_WIDTH, 16);

        f.Title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
        f.Title:SetJustifyH("RIGHT");
        f.Title:SetPoint("RIGHT", f, "LEFT", -2, 0);
        f.Title:Hide();
        f.Title:SetText(addon.L["Pin Size"]);
        f.Title:SetTextColor(1, 0.82, 0);

        Mixin(f, SizeSelectMixin);
        return f
    end
    addon.CreateSimpleSizeSelect = CreateSimpleSizeSelect;
end

do  --Draw shapes
    local ArcMixin = {};

    function ArcMixin:SetThickness(pixel, update)
        self.px = API.GetPixelForWidget(self, pixel*0.5);
        if self.radius and update then
            self:SetRadius(self.radius);
        end
    end

    function ArcMixin:SetColor(r, g, b, a)
        a = a or 1;
        self.Circle:SetVertexColor(r, g, b, a);
    end

    function ArcMixin:SetRadius(radius)
        self.radius = radius;
        local d = 2*(radius + self.px);
        self.Circle:SetSize(d, d);
        d = 2*(radius - self.px);
        self.Mask1:SetSize(d, d);
        self.Mask2:SetSize(d, d);
    end

    function ArcMixin:SetFromRadian(fromRadian)
        -- y+, positive
        -- y-, negative
        self.Mask1:SetRotation(fromRadian);
    end

    function ArcMixin:SetToRadian(toRadian)
        self.Mask2:SetRotation(toRadian);
    end

    function ArcMixin:SetFromDegree(fromDegree)
        self:SetFromRadian(math.rad(fromDegree));
    end

    function ArcMixin:SetToDegree(toDegree)
        self:SetToRadian(math.rad(toDegree));
    end

    function ArcMixin:Init()
        local circle0 = self:CreateTexture(nil, "BACKGROUND");
        self.Circle = circle0;
        circle0:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Circle-HD");
        circle0:SetPoint("CENTER", self, "CENTER", 0, 0);
        DisableSharpening(circle0);

        local circle1 = self:CreateMaskTexture(nil, "BACKGROUND");
        self.Mask1 = circle1;
        circle1:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Circle-Inverse-Right-HD", "CLAMP", "CLAMP");
        circle1:SetPoint("CENTER", self, "CENTER", 0, 0);
        circle0:AddMaskTexture(circle1);
        DisableSharpening(circle1);

        local circle3 = self:CreateMaskTexture(nil, "BACKGROUND");
        self.Mask2 = circle3;
        circle3:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Circle-Inverse-Right-HD", "CLAMP", "CLAMP");
        circle3:SetPoint("CENTER", self, "CENTER", 0, 0);
        circle0:AddMaskTexture(circle3);
        DisableSharpening(circle3);

        self.Init = nil;
    end

    local function CreateArc(parent)
        local f = CreateFrame("Frame", nil, parent);
        f:SetSize(8, 8);
        Mixin(f, ArcMixin);
        f:SetThickness(1);
        f:Init();
        return f
    end
    addon.CreateArc = CreateArc;
end

do  --Shared Context Menu
    local MENU_PADDING_X = 2;
    local MENU_PADDING_Y = 8;
    local MENU_BUTTON_HEIGHT = 24;
    local MENU_DIVIDER_HEIGHT = 14;
    local MENU_BUTTON_WIDTH = 240;
    local MENU_BUTTON_TEXT_OFFSET = 12;
    local MENU_SUBBUTTON_TEXT_OFFSET = 30;
    local MENU_TOOLTIP_DELAY = 0.5;

    local UIParent = UIParent;
    local GetScaledCursorPosition = API.GetScaledCursorPosition;

    local SharedContextMenu;
    local ContextMenuMixin = {};
    local MenuButtonMixin = {};


    function MenuButtonMixin:OnEnter()
        self.parent:FocusOnButton(self);
    end

    function MenuButtonMixin:OnLeave()
        self.parent:FocusOnButton(nil);
        GameTooltip:Hide();
    end

    function MenuButtonMixin:OnClick(button)
        if self.onClickFunc and self.onClickFunc(self, button) then
            self.parent:CloseMenu();
        end
    end

    function MenuButtonMixin:OnMouseDown(button)
        if not self:IsEnabled() then return end;

        if button == "LeftButton" then
            self.Text:SetPoint("LEFT", self, "LEFT", self.baseTextOffset + 1, 0);
        end
    end

    function MenuButtonMixin:OnMouseUp(button)
        self.Text:SetPoint("LEFT", self, "LEFT", self.baseTextOffset, 0);
    end

    function MenuButtonMixin:SetupButtonTexture()
        if self.divider then
            self.divider:Hide();
        end

        if (not self.buttonType) or self.buttonType == "title" or self.buttonType == "divider" then
            if self.Tex1 then
                self.Tex1:Hide();
            end
            if self.Tex2 then
                self.Tex2:Hide();
            end

            if self.buttonType == "divider" then
                if not self.divider then
                    self.divider = self:CreateTexture(nil, "ARTWORK");
                    self.divider:SetPoint("LEFT", self, "LEFT", MENU_PADDING_X, 0);
                    self.divider:SetPoint("RIGHT", self, "RIGHT", -MENU_PADDING_X, 0);
                    self.divider:SetColorTexture(0.2, 0.2, 0.2);
                    DisableSharpening(self.divider);
                end
                local px = API.GetPixelForWidget(self, 1);
                self.divider:SetHeight(px);
                self.divider:Show();
            end

            return
        end


        if not self.Tex1 then
            self.Tex1 = self:CreateTexture(nil, "ARTWORK");
            self.Tex1:SetSize(32, 32);
            self.Tex1:SetPoint("CENTER", self, "LEFT", MENU_BUTTON_TEXT_OFFSET + 6, 0);
            self.Tex1:SetTexture("Interface/AddOns/Plumber/Art/Button/Checkbox");
            self.Tex1:SetTexCoord(0, 0.5, 0, 0.5);
            DisableSharpening(self.Tex1);
        end
        if not self.Tex2 then
            self.Tex2 = self:CreateTexture(nil, "OVERLAY");
            self.Tex2:SetSize(16, 16);
            self.Tex2:SetPoint("CENTER", self.Tex1, "CENTER", 0, 0);
            self.Tex2:SetTexture("Interface/AddOns/Plumber/Art/Button/Checkbox");
            self.Tex2:SetTexCoord(0.5, 0.75, 0.5, 0.75);
            DisableSharpening(self.Tex2);
        end

        if self.buttonType == "checkbox" then
            self.Tex1:SetTexture("Interface/AddOns/Plumber/Art/Button/Checkbox");
            self.Tex2:SetTexture("Interface/AddOns/Plumber/Art/Button/Checkbox");
        elseif self.buttonType == "radio" then
            self.Tex1:SetTexture("Interface/AddOns/Plumber/Art/Button/RadioButton");
            self.Tex2:SetTexture("Interface/AddOns/Plumber/Art/Button/RadioButton");
        end

        self.Tex2:SetShown(self.selected);
        if self.selected then
            self.Tex1:SetTexCoord(0, 0.5, 0, 0.5);
        else
            self.Tex1:SetTexCoord(0.5, 1, 0, 0.5);
        end
    end

    function MenuButtonMixin:SetButtonType(buttonType, selected)
        if buttonType ~= self.buttonType or selected ~= self.selected then
            self.buttonType = buttonType;
            self.selected = selected;
        else
            return
        end

        if buttonType == "divider" then
            self:SetHeight(MENU_DIVIDER_HEIGHT);
        else
            self:SetHeight(MENU_BUTTON_HEIGHT);
        end

        if buttonType == "divider" or buttonType == "title" then
            self:Disable();
            if self.Tex1 then
                self.Tex1:Hide();
            end
            if self.Tex2 then
                self.Tex2:Hide();
            end
        else
            self:Enable();
        end

        self:SetupButtonTexture();
    end

    function MenuButtonMixin:SetButtonColor(color)
        if self.buttonType == "title" then
            self.Text:SetTextColor(0.5, 0.5, 0.5);
        elseif color then
            self.Text:SetTextColor(color[1], color[2], color[3]);
        else
            self.Text:SetTextColor(1, 1, 1);
        end
    end

    function MenuButtonMixin:SetButtonData(buttonData)
        self.Text:SetText(buttonData.text);
        self.onClickFunc = buttonData.onClickFunc;
        self.tooltip = buttonData.tooltip;
        self:SetButtonLevel(buttonData.level);
        self:SetButtonType(buttonData.type, buttonData.selected);
        self:SetButtonColor(buttonData.color);
    end

    function MenuButtonMixin:SetButtonLevel(level)
        if level == 1 then
            self.baseTextOffset = MENU_SUBBUTTON_TEXT_OFFSET;
        else
            self.baseTextOffset = MENU_BUTTON_TEXT_OFFSET;
        end
        self.Text:SetPoint("LEFT", self, "LEFT", self.baseTextOffset, 0);
    end

    function ContextMenuMixin:ReleaseButtons()
        if not self.buttons then return end;

        for i, button in ipairs(self.buttons) do
            button:Hide();
        end

        self.numActive = 0;
    end

    function ContextMenuMixin:AcquireButton()
        if not self.buttons then
            self.numActive = 0;
            self.buttons = {};
            self.ButtonContainer = CreateFrame("Frame", nil, self);
            self.ButtonContainer:SetSize(8, 8);
            self.ButtonContainer:SetPoint("CENTER", self, "CENTER", 0, 0);
        end

        local index = self.numActive + 1;
        self.numActive = index;
        local button = self.buttons[index];

        if not button then
            button = CreateFrame("Button", nil, self.ButtonContainer);
            self.buttons[index] = button;
            button:SetSize(MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT);
            button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            button.Text:SetJustifyH("LEFT");
            button.Text:SetPoint("LEFT", button, "LEFT", MENU_BUTTON_TEXT_OFFSET, 0);
            button.Text:SetTextColor(1, 1, 1);
            button.id = index;
            --button:SetPoint("TOPLEFT", self, "TOPLEFT", MENU_PADDING_X, -MENU_PADDING_Y + (1-index)*MENU_BUTTON_HEIGHT);
            if index == 1 then
                button:SetPoint("TOPLEFT", self, "TOPLEFT", MENU_PADDING_X, -MENU_PADDING_Y);
            else
                button:SetPoint("TOPLEFT", self.buttons[index - 1], "BOTTOMLEFT", 0, 0);
            end
            Mixin(button, MenuButtonMixin);
            button:SetScript("OnEnter", MenuButtonMixin.OnEnter);
            button:SetScript("OnLeave", MenuButtonMixin.OnLeave);
            button:SetScript("OnClick", MenuButtonMixin.OnClick);
            button:SetScript("OnMouseDown", MenuButtonMixin.OnMouseDown);
            button:SetScript("OnMouseUp", MenuButtonMixin.OnMouseUp);
            button.parent = self;
        end

        button:Show();

        return button
    end

    function ContextMenuMixin:SetMinWidth(minWidth)
        self.minWidth = minWidth;
    end

    function ContextMenuMixin:SetMinHeight(minHeight)
        self.minHeight = minHeight;
    end

    function ContextMenuMixin:SetMenuSize(width, height)
        if self.minWidth and width < self.minWidth then
            width = self.minWidth;
        end
        if self.minHeight and height < self.minHeight then
            height = self.minHeight;
        end
        self:SetSize(width, height);
    end

    function ContextMenuMixin:SetOwner(owner)
        self.owner = owner;
    end

    function ContextMenuMixin:SetContent(content, forceUpdate)
        if content == self.content and not forceUpdate then
            return
        end
        self.content = content;
        self:ReleaseButtons();

        local button;
        local numDivider = 0;

        for i, buttonData in ipairs(content) do
            button = self:AcquireButton();
            button:SetButtonData(buttonData);
            if buttonData.type == "divider" then
                numDivider = numDivider + 1;
            end
        end

        self:SetHeight((#content - numDivider) * MENU_BUTTON_HEIGHT + numDivider * MENU_DIVIDER_HEIGHT + 2 * MENU_PADDING_Y);
    end

    function ContextMenuMixin:CloseMenu()
        self:Hide();
        self:ClearAllPoints();
    end

    function ContextMenuMixin:OnHide()
        self:CloseMenu();
        self:SetScript("OnUpdate", nil);
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
    end

    function ContextMenuMixin:OnShow()
        self:RegisterEvent("GLOBAL_MOUSE_DOWN");
    end

    function ContextMenuMixin:IsFocuesd()
        return self:IsMouseOver() or (self.owner and self.owner:IsMouseOver())
    end

    function ContextMenuMixin:OnEvent(event, ...)
        if event == "GLOBAL_MOUSE_DOWN" then
            if not self:IsFocuesd() then
                self:CloseMenu();
            end
        end
    end

    local function HighlightFrame_OnUpdate(self, elapsed)
        local x, y = GetScaledCursorPosition();
        self.HighlightTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);

        if self.mouseoverTime then
            self.mouseoverTime = self.mouseoverTime + elapsed;
            if self.mouseoverTime >= MENU_TOOLTIP_DELAY then
                self.mouseoverTime = nil;
                SharedContextMenu:ShowFocusedButtonTooltip();
            end
        end
    end

    function ContextMenuMixin:FocusOnButton(menuButton)
        self.focusedButton = menuButton;
        if menuButton then
            self.HighlightFrame:ClearAllPoints();
            self.HighlightFrame:SetPoint("TOPLEFT", menuButton, "TOPLEFT", 0, 0);
            self.HighlightFrame:SetPoint("BOTTOMRIGHT", menuButton, "BOTTOMRIGHT", 0, 0);
            self.HighlightFrame.mouseoverTime = 0;
            self.HighlightFrame:Show();
        else
            self.HighlightFrame:Hide();
            self.HighlightFrame.mouseoverTime = nil;
        end
    end

    function ContextMenuMixin:ShowFocusedButtonTooltip()
        if self.focusedButton and self.focusedButton.tooltip and self.focusedButton:IsVisible() then
            local tooltip = GameTooltip;
            tooltip:Hide();
            tooltip:SetOwner(self.focusedButton, "ANCHOR_NONE");

            local buttonRight = self.focusedButton:GetRight();
            local uiRight = UIParent:GetRight();
            if buttonRight and uiRight and buttonRight + 240 > uiRight then
                tooltip:SetPoint("TOPRIGHT", self.focusedButton, "TOPLEFT", -4, 6);
            else
                tooltip:SetPoint("TOPLEFT", self.focusedButton, "TOPRIGHT", 4, 6);
            end

            tooltip:SetText(self.focusedButton.Text:GetText(), 1, 1, 1, true);
            tooltip:AddLine(self.focusedButton.tooltip, 1, 0.82, 0, true);
            tooltip:Show();
        end
    end

    function ContextMenuMixin:Init()
        self:SetFrameStrata("TOOLTIP");
        self:SetFixedFrameStrata(true);
        self:SetClampedToScreen(true);

        self:SetScript("OnShow", ContextMenuMixin.OnShow);
        self:SetScript("OnHide", ContextMenuMixin.OnHide);
        self:SetScript("OnEvent", ContextMenuMixin.OnEvent);

        self:SetMinWidth(MENU_BUTTON_WIDTH + 2*MENU_PADDING_X);
        self:SetMinHeight(MENU_BUTTON_HEIGHT + 2*MENU_PADDING_Y);
        self:SetMenuSize(64, 64);

        self.HighlightFrame = CreateFrame("Frame", nil, self);
        self.HighlightFrame:SetClipsChildren(true);
        local HighlightTexture = self.HighlightFrame:CreateTexture(nil, "ARTWORK");
        HighlightTexture:SetSize(480, 480);
        HighlightTexture:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Circle-Blurry");
        HighlightTexture:SetAlpha(0.15);
        self.HighlightFrame.HighlightTexture = HighlightTexture;
        self.HighlightFrame:SetScript("OnUpdate", HighlightFrame_OnUpdate);

        self.Init = nil;
    end


    local function GetSharedContextMenu()
        if not SharedContextMenu then
            local parent = UIParent;
            local f = addon.CreateNineSliceFrame(parent, "Menu_Black");
            SharedContextMenu = f;
            Mixin(f, ContextMenuMixin);
            f:Hide();
            f:Init();
        end
        return SharedContextMenu
    end
    addon.GetSharedContextMenu = GetSharedContextMenu;
end

do  --Frame Reposition Button
    local GetScaledCursorPosition = API.GetScaledCursorPosition;

    local function OnUpdate_Frequency(self, elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.016 then
            self.t = 0;
            return true
        end
        return false
    end

    local function OnUpdate_OnMoving(self, elapsed)
        if OnUpdate_Frequency(self, elapsed) then
            local x, y = GetScaledCursorPosition();
            local offsetX, offsetY;
            local anyChange;

            if self.orientation == "x" then
                offsetX = x - self.fromX;
                if offsetX ~= self.offsetX then
                    self.offsetX = offsetX;
                    anyChange = true
                end
            elseif self.orientation == "y" then
                offsetY = y - self.fromX;
                if offsetY ~= self.offsetY then
                    self.offsetY = offsetY;
                    anyChange = true
                end
            end

            if anyChange then
                self.frameToControl:RepositionFrame(offsetX, offsetY);
            end
        end
    end

    local function OnUpdate_MonitorDiff(self, elapsed)
        --start moving Owner once the cursor moves 2 units
        if OnUpdate_Frequency(self, elapsed) then
            local diff = 0;
            local x, y = GetScaledCursorPosition();
            if self.orientation == "x" then
                diff = x - self.fromX;
            elseif self.orientation == "y" then
                diff = y - self.fromY;
            end
            if diff < 0 then
                diff = -diff;
            end
            if diff >= 4 then   --Threshold
                self.fromX, self.fromY = x, y;
                self.isMovingFrame = true;
                self:OnLeave();
                self.frameToControl:SnapShotFramePosition();
                self:SetScript("OnUpdate", OnUpdate_OnMoving);
            end
        end
    end

    local RepositionButtonMixin = {};

    function RepositionButtonMixin:OnMouseDown(button)
        if self:IsEnabled() then
            self.Icon:SetPoint("CENTER", self, "CENTER", 0, -1);
            if button == "LeftButton" then
                --Pre Frame Reposition
                self:LockHighlight();
                self.t = 0;
                self.fromX, self.fromY = GetScaledCursorPosition();
                self:SetScript("OnUpdate", OnUpdate_MonitorDiff);
            end
        end
    end

    function RepositionButtonMixin:StopReposition()
        self:SetScript("OnUpdate", nil);
        self.isMovingFrame = false;
        self.fromX, self.fromY = nil, nil;
        self.offsetX, self.offsetY = nil, nil;
    end

    function RepositionButtonMixin:OnMouseUp()
        if self.isMovingFrame then
            self.frameToControl:ConfirmNewPosition();
            self:StopReposition();
        end
        self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0);
        self:UnlockHighlight();
    end

    function RepositionButtonMixin:OnClick(button)
        if button =="RightButton" then
            self:OnDoubleClick();
        end
    end

    function RepositionButtonMixin:OnDoubleClick()
        self:StopReposition();
        if self.frameToControl then
            self.frameToControl:ResetFramePosition();
        end
    end

    function RepositionButtonMixin:OnEnable()
        self.Icon:SetDesaturated(false);
        self.Icon:SetVertexColor(1, 1, 1);
        self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0);
        self:RefreshOnEnter();
    end

    function RepositionButtonMixin:OnDisable()
        self.Icon:SetDesaturated(true);
        self.Icon:SetVertexColor(0.8, 0.8, 0.8);
        self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0);
        --self.Highlight:Hide();
        self:RefreshOnEnter();
    end

    function RepositionButtonMixin:RefreshOnEnter()
        if self:IsVisible() and self:IsMouseOver() then
            self:OnEnter();
        end
    end

    function RepositionButtonMixin:OnShow()

    end

    function RepositionButtonMixin:OnHide()
        self:StopReposition();
    end

    function RepositionButtonMixin:OnEnter()
        if self.isMovingFrame then return end;
        --self.Highlight:Show();

        local tooltip = GameTooltip;
        tooltip:Hide();
        tooltip:SetOwner(self, "ANCHOR_RIGHT");

        if self.orientation == "x" then
            tooltip:SetText(L["Reposition Button Horizontal"], 1, 1, 1);
        elseif self.orientation == "y" then
            tooltip:SetText(L["Reposition Button Vertical"], 1, 1, 1);
        end

        tooltip:AddLine(L["Reposition Button Tooltip"], 1, 0.82, 0, true);
        tooltip:Show();
    end

    function RepositionButtonMixin:OnLeave()
        GameTooltip:Hide();
        --self.Highlight:Hide();
    end

    function RepositionButtonMixin:SetOrientation(xy)
        self.orientation = xy;
        local tex;
        if xy == "x" then
            tex = "Interface/AddOns/Plumber/Art/Button/MoveButton-X";
        elseif xy == "y" then
            tex = "Interface/AddOns/Plumber/Art/Button/MoveButton-Y";
        end
        self.Highlight:SetTexture(tex);
        self.Icon:SetTexture(tex);
    end

    local function CreateRepositionButton(frameToControl)
        local button = CreateFrame("Button", nil, frameToControl);
        button.frameToControl = frameToControl;
        button:SetSize(20, 20);
        button:SetMotionScriptsWhileDisabled(true);
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
        Mixin(button, RepositionButtonMixin);

        local tex = "Interface/AddOns/Plumber/Art/Button/MoveButton-X";

        button.Highlight = button:CreateTexture(nil, "HIGHLIGHT");
        --button.Highlight:Hide();
        button.Highlight:SetSize(32, 32);
        button.Highlight:SetPoint("CENTER", button, "CENTER", 0, 0);
        button.Highlight:SetTexture(tex);
        button.Highlight:SetTexCoord(0.5, 1, 0, 1);

        button.Icon = button:CreateTexture(nil, "ARTWORK");
        button.Icon:SetSize(32, 32);
        button.Icon:SetPoint("CENTER", button, "CENTER", 0, 0);
        button.Icon:SetTexture(tex);
        button.Icon:SetTexCoord(0, 0.5, 0, 1);

        button:SetScript("OnMouseDown", button.OnMouseDown);
        button:SetScript("OnMouseUp", button.OnMouseUp);
        button:SetScript("OnClick", button.OnClick);
        button:SetScript("OnDoubleClick", button.OnDoubleClick);
        button:SetScript("OnEnable", button.OnEnable);
        button:SetScript("OnDisable", button.OnDisable);
        button:SetScript("OnShow", button.OnShow);
        button:SetScript("OnHide", button.OnHide);
        button:SetScript("OnEnter", button.OnEnter);
        button:SetScript("OnLeave", button.OnLeave);

        return button
    end
    addon.CreateRepositionButton = CreateRepositionButton;
end

do  --Slider
    local Round = API.Round;
    local SliderFrameMixin = {};

    local TEXTURE_FILE = "Interface/AddOns/Plumber/Art/Frame/Slider";
    local TEX_COORDS = {
        Thumb_Nomral = {0, 0.5, 0, 0.25},
        Thumb_Disable = {0.5, 1, 0, 0.25},
        Thumb_Highlight = {0, 0.5, 0.25, 0.5},

        Back_Nomral = {0, 0.25, 0.5, 0.625},
        Back_Disable = {0.25, 0.5, 0.5, 0.625},
        Back_Highlight = {0.5, 0.75, 0.5, 0.625},

        Forward_Nomral = {0, 0.25, 0.625, 0.75},
        Forward_Disable = {0.25, 0.5, 0.625, 0.75},
        Forward_Highlight = {0.5, 0.75, 0.625, 0.75},

        Slider_Left = {0, 0.125, 0.875, 1},
        Slider_Middle = {0.125, 0.375, 0.875, 1},
        Slider_Right = {0.375, 0.5, 0.875, 1},
    };

    local function SetTextureCoord(texture, key)
        texture:SetTexCoord( unpack(TEX_COORDS[key]) );
    end

    local SharedMethods = {
        "GetValue", "SetValue", "SetMinMaxValues",
    };

    for k, v in ipairs(SharedMethods) do
        SliderFrameMixin[v] = function(self, ...)
            return self.Slider[v](self.Slider, ...);
        end;
    end


    local SliderScripts = {};

    function SliderScripts:OnMinMaxChanged(min, max)
        if self.formatMinMaxValueFunc then
            self.formatMinMaxValueFunc(min, max);
        end
    end

    function SliderScripts:OnValueChanged(value, userInput)
        if value ~= self.value then
            self.value = value;
        else
            return
        end

        self.ThumbTexture:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0);

        if self.ValueText then
            if self.formatValueFunc then
                self.ValueText:SetText(self.formatValueFunc(value));
            else
                self.ValueText:SetText(value);
            end
        end

        if userInput then
            if self.onValueChangedFunc then
                self.onValueChangedFunc(value);
            end
        end
    end

    function SliderScripts:OnMouseDown()
        if self:IsEnabled() then
            self:LockHighlight();
        end
    end

    function SliderScripts:OnMouseUp()
        self:UnlockHighlight();
    end


    local function BackForwardButton_OnClick(self)
        if self.delta then
            self:GetParent():SetValueByDelta(self.delta, true);
        end
    end

    function SliderFrameMixin:OnLoad()
        for k, v in pairs(SliderScripts) do
            self.Slider:SetScript(k, v);
        end

        self.Back:SetScript("OnClick", BackForwardButton_OnClick);
        self.Forward:SetScript("OnClick", BackForwardButton_OnClick);

        self.Slider.Left:SetTexture(TEXTURE_FILE);
        self.Slider.Middle:SetTexture(TEXTURE_FILE);
        self.Slider.Right:SetTexture(TEXTURE_FILE);
        self.Slider.ThumbTexture:SetTexture(TEXTURE_FILE);
        self.Slider.ThumbHighlight:SetTexture(TEXTURE_FILE);
        SetTextureCoord(self.Slider.Left, "Slider_Left");
        SetTextureCoord(self.Slider.Middle, "Slider_Middle");
        SetTextureCoord(self.Slider.Right, "Slider_Right");
        SetTextureCoord(self.Slider.ThumbTexture, "Thumb_Nomral");
        SetTextureCoord(self.Slider.ThumbHighlight, "Thumb_Highlight");

        self.Back.Texture:SetTexture(TEXTURE_FILE);
        self.Back.Highlight:SetTexture(TEXTURE_FILE);
        SetTextureCoord(self.Back.Texture, "Back_Nomral");
        SetTextureCoord(self.Back.Highlight, "Back_Highlight");

        self.Forward.Texture:SetTexture(TEXTURE_FILE);
        self.Forward.Highlight:SetTexture(TEXTURE_FILE);
        SetTextureCoord(self.Forward.Texture, "Forward_Nomral");
        SetTextureCoord(self.Forward.Highlight, "Forward_Highlight");

        self:SetMinMaxValues(0, 100);
        self:SetValueStep(10);
        self:SetObeyStepOnDrag(true);
        self:SetValue(0);

        self:Enable();

        DisableSharpening(self.Slider.Left);
        DisableSharpening(self.Slider.Middle);
        DisableSharpening(self.Slider.Right);
    end

    function SliderFrameMixin:Enable()
        self.Slider:Enable();
        self.Back:Enable();
        self.Forward:Enable();
        SetTextureCoord(self.Slider.ThumbTexture, "Thumb_Nomral");
        SetTextureCoord(self.Back.Texture, "Back_Nomral");
        SetTextureCoord(self.Forward.Texture, "Forward_Nomral");
        self.Label:SetTextColor(1, 1, 1);
        self.RightText:SetTextColor(1, 0.82, 0);
    end

    function SliderFrameMixin:Disable()
        self.Slider:Disable();
        self.Back:Disable();
        self.Forward:Disable();
        self.Slider:UnlockHighlight();
        SetTextureCoord(self.Slider.ThumbTexture, "Thumb_Disable");
        SetTextureCoord(self.Back, "Back_Disable");
        SetTextureCoord(self.Forward.Texture, "Forward_Disable");
        self.Label:SetTextColor(0.5, 0.5, 0.5);
        self.RightText:SetTextColor(0.5, 0.5, 0.5);
    end

    function SliderFrameMixin:SetValueByDelta(delta, userInput)
        local value = self:GetValue();
        self:SetValue(value + delta);

        if userInput then
            if self.onValueChangedFunc then
                self.onValueChangedFunc(self:GetValue());
            end
        end
    end

    function SliderFrameMixin:SetValueStep(valueStep)
        self.Slider:SetValueStep(valueStep);
        self.Back.delta = -valueStep;
        self.Forward.delta = valueStep;
    end

    function SliderFrameMixin:SetObeyStepOnDrag(obey)
        self.Slider:SetObeyStepOnDrag(obey);
        if not obey then
            local min, max = self.GetMinMaxValues();
            local delta = (max - min) * 0.1;
            self.Back.delta = -delta;
            self.Forward.delta = delta;
        end
    end

    function SliderFrameMixin:SetLabel(label)
        self.Label:SetText(label);
    end

    function SliderFrameMixin:SetFormatValueFunc(formatValueFunc)
        self.Slider.formatValueFunc = formatValueFunc;
        self.RightText:SetText(formatValueFunc(self:GetValue() or 0));
    end

    function SliderFrameMixin:SetOnValueChangedFunc(onValueChangedFunc)
        self.Slider.onValueChangedFunc = onValueChangedFunc;
        self.onValueChangedFunc = onValueChangedFunc;
    end

    local function FormatValue(value)
        return value
    end

    local function CreateSlider(parent)
        local f = CreateFrame("Frame", nil, parent, "PlumberMinimalSliderWithControllerTemplate");
        Mixin(f, SliderFrameMixin);

        f.Slider.ValueText = f.RightText;
        f.Slider.Back = f.Back;
        f.Slider.Forward = f.Forward;

        f:SetFormatValueFunc(FormatValue);
        f:OnLoad();

        return f
    end
    addon.CreateSlider = CreateSlider;
end

do  --UIPanelButton
    local UIPanelButtonMixin = {};

    function UIPanelButtonMixin:OnClick(button)

    end

    function UIPanelButtonMixin:OnMouseDown(button)
        if self:IsEnabled() then
            self.Background:SetTexture("Interface/AddOns/Plumber/Art/Button/UIPanelButton-Down");
        end
    end

    function UIPanelButtonMixin:OnMouseUp(button)
        if self:IsEnabled() then
            self.Background:SetTexture("Interface/AddOns/Plumber/Art/Button/UIPanelButton-Up");
        end
    end

    function UIPanelButtonMixin:OnDisable()
        self.Background:SetTexture("Interface/AddOns/Plumber/Art/Button/UIPanelButton-Disabled");
    end

    function UIPanelButtonMixin:OnEnable()
        self.Background:SetTexture("Interface/AddOns/Plumber/Art/Button/UIPanelButton-Up");
    end

    function UIPanelButtonMixin:OnEnter()

    end

    function UIPanelButtonMixin:OnLeave()

    end

    function UIPanelButtonMixin:SetButtonText(text)
        self:SetText(text);
    end

    local function CreateUIPanelButton(parent)
        local f = CreateFrame("Button", nil, parent);
        f:SetSize(144, 24);
        Mixin(f, UIPanelButtonMixin);

        f:SetScript("OnMouseDown", f.OnMouseDown);
        f:SetScript("OnMouseUp", f.OnMouseUp);
        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnEnable", f.OnEnable);
        f:SetScript("OnDisable", f.OnDisable);

        f.Background = f:CreateTexture(nil, "BACKGROUND");
        f.Background:SetTexture("Interface/AddOns/Plumber/Art/Button/UIPanelButton-Up");
        f.Background:SetTextureSliceMargins(32, 16, 32, 16);
        f.Background:SetTextureSliceMode(1);
        f.Background:SetAllPoints(true);
        DisableSharpening(f.Background);

        f.Highlight = f:CreateTexture(nil, "HIGHLIGHT");
        f.Highlight:SetTexture("Interface/AddOns/Plumber/Art/Button/UIPanelButton-Highlight");
        f.Highlight:SetTextureSliceMargins(32, 16, 32, 16);
        f.Highlight:SetTextureSliceMode(0);
        f.Highlight:SetAllPoints(true);
        f.Highlight:SetBlendMode("ADD");
        f.Highlight:SetVertexColor(0.5, 0.5, 0.5);

        f:SetNormalFontObject("GameFontNormal");
        f:SetHighlightFontObject("GameFontHighlight");
        f:SetDisabledFontObject("GameFontDisable");
        f:SetPushedTextOffset(0, -1);

        return f
    end
    addon.CreateUIPanelButton = CreateUIPanelButton;
end

do  --EditMode
    local Round = API.Round;
    local EditModeSelectionMixin = {};

    function EditModeSelectionMixin:OnDragStart()
        self.parent:OnDragStart();
    end

    function EditModeSelectionMixin:OnDragStop()
        self.parent:OnDragStop();
    end

    function EditModeSelectionMixin:ShowHighlighted()
        --Blue
        if not self.parent:IsShown() then return end;
        self.isSelected = false;
        self.Background:SetTexture("Interface/AddOns/Plumber/Art/Frame/EditModeHighlighted");
        self:Show();
        self.Label:Hide();
    end

    function EditModeSelectionMixin:ShowSelected()
        --Yellow
        if not self.parent:IsShown() then return end;
        self.isSelected = true;
        self.Background:SetTexture("Interface/AddOns/Plumber/Art/Frame/EditModeSelected");
        self:Show();

        if not self.hideLabel then
            self.Label:Show();
        end
    end

    function EditModeSelectionMixin:OnShow()
        local offset = API.GetPixelForWidget(self, 6);
        self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", -offset, offset);
        self.Background:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", offset, -offset);
        self:RegisterEvent("GLOBAL_MOUSE_DOWN");
    end

    function EditModeSelectionMixin:OnHide()
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
    end

    local function IsMouseOverOptionToggle()
        local obj = GetMouseFocus();
        if obj and obj.isPlumberEditModeToggle then
            return true
        else
            return false
        end
    end

    function EditModeSelectionMixin:OnEvent(event, ...)
        if event == "GLOBAL_MOUSE_DOWN" then
            if self:IsShown() and not(self.parent:IsFocused() or IsMouseOverOptionToggle()) then
                self:ShowHighlighted();
                self.parent:ShowOptions(false);
            end
        end
    end

    function EditModeSelectionMixin:OnMouseDown()
        self:ShowSelected();
        self.parent:ShowOptions(true);

        if EditModeManagerFrame and EditModeManagerFrame.ClearSelectedSystem then
            EditModeManagerFrame:ClearSelectedSystem()
        end
    end


    local function CreateEditModeSelection(parent, uiName, hideLabel)
        local f = CreateFrame("Frame", nil, parent);
        f:Hide();
        f:SetAllPoints(true);
        f:SetFrameStrata(parent:GetFrameStrata());
        f:SetToplevel(true);
        f:SetFrameLevel(999);
        f:EnableMouse(true);
        f:RegisterForDrag("LeftButton");
        f:SetIgnoreParentAlpha(true);

        f.Label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium");
        f.Label:SetText(uiName);
        f.Label:SetJustifyH("CENTER");
        f.Label:SetPoint("CENTER", f, "CENTER", 0, 0);

        f.Background = f:CreateTexture(nil, "BACKGROUND");
        f.Background:SetTexture("Interface/AddOns/Plumber/Art/Frame/EditModeHighlighted");
        f.Background:SetTextureSliceMargins(16, 16, 16, 16);
        f.Background:SetTextureSliceMode(0);
        f.Background:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
        f.Background:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);

        Mixin(f, EditModeSelectionMixin);

        f:SetScript("OnShow", f.OnShow);
        f:SetScript("OnHide", f.OnHide);
        f:SetScript("OnEvent", f.OnEvent);
        f:SetScript("OnMouseDown", f.OnMouseDown);
        f:SetScript("OnDragStart", f.OnDragStart);
        f:SetScript("OnDragStop", f.OnDragStop);

        parent.Selection = f;
        f.parent = parent;
        f.hideLabel = hideLabel;

        return f
    end
    addon.CreateEditModeSelection = CreateEditModeSelection;


    local EditModeSettingsDialog;
    local DIALOG_WIDTH = 382;

    local EditModeSettingsDialogMixin = {};

    function EditModeSettingsDialogMixin:Exit()
        self:Hide();
        self:ClearAllPoints();
        self.requireResetPosition = true;
        if self.parent then
            if self.parent.Selection then
                self.parent.Selection:ShowHighlighted();
            end
            if self.parent.ExitEditMode and not API.IsInEditMode() then
                self.parent:ExitEditMode();
            end
            self.parent = nil;
        end
    end

    function EditModeSettingsDialogMixin:ReleaseAllWidgets()
        for _, widget in pairs(self.widgets) do
            widget:Hide();
            widget:ClearAllPoints();
        end

        self.activeWidgets = {};
    end

    function EditModeSettingsDialogMixin:Layout()
        local leftPadding = 20;
        local topPadding = 48;
        local bottomPadding = 20;
        local OPTION_GAP_Y = 8;  --consistent with ControlCenter
        local height = topPadding;
        local widgetHeight;
        local contentWidth = DIALOG_WIDTH - 2*leftPadding;

        for order, widget in ipairs(self.activeWidgets) do
            if widget.isGap then
                height = height + 8 + OPTION_GAP_Y;
            else
                widget:SetPoint("TOPLEFT", self, "TOPLEFT", leftPadding, -height);
                widgetHeight = Round(widget:GetHeight());
                height = height + widgetHeight + OPTION_GAP_Y;
                if widget.matchParentWidth then
                    widget:SetWidth(contentWidth);
                end
            end
        end
        
        height = height - OPTION_GAP_Y + bottomPadding;
        self:SetHeight(height);
    end

    function EditModeSettingsDialogMixin:AcquireWidgetByType(type)
        local widget;

        if type == "Checkbox" then
            if not self.checkboxes then
                self.checkboxes = {};
            end
            widget = addon.CreateCheckbox(self);
        elseif type == "Slider" then
            if not self.sliders then
                self.sliders = {};
            end
            widget = addon.CreateSlider(self);
        elseif type == "UIPanelButton" then
            widget = addon.CreateUIPanelButton(self);
        elseif type == "Texture" then
            widget = self:CreateTexture(nil, "OVERLAY");
            widget.isDivider = nil;
            widget.matchParentWidth = nil;
        elseif type == "FontString" then
            widget = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
            widget.matchParentWidth = true;
        end

        widget:Show();

        return widget
    end

    function EditModeSettingsDialogMixin:CreateCheckbox(widgetData)
        local checkbox = self:AcquireWidgetByType("Checkbox");

        checkbox.Label:SetFontObject("GameFontHighlightMedium");    --Fonts in EditMode and Options are different
        checkbox.Label:SetTextColor(1, 1, 1);

        checkbox:SetData(widgetData);
        checkbox:SetChecked( PlumberDB[checkbox.dbKey] );

        return checkbox
    end

    function EditModeSettingsDialogMixin:CreateSlider(widgetData)
        local slider = self:AcquireWidgetByType("Slider");

        slider:SetLabel(widgetData.label);
        slider:SetMinMaxValues(widgetData.minValue, widgetData.maxValue);

        if widgetData.valueStep then
            slider:SetObeyStepOnDrag(true);
            slider:SetValueStep(widgetData.valueStep);
        else
            slider:SetObeyStepOnDrag(false);
        end

        slider:SetFormatValueFunc(widgetData.formatValueFunc);
        slider:SetOnValueChangedFunc(widgetData.onValueChangedFunc);

        if widgetData.dbKey and PlumberDB[widgetData.dbKey] then
            slider:SetValue(PlumberDB[widgetData.dbKey]);
        end

        return slider
    end

    function EditModeSettingsDialogMixin:CreateUIPanelButton(widgetData)
        local button = self:AcquireWidgetByType("UIPanelButton");
        button:SetButtonText(widgetData.label);
        button:SetScript("OnClick", widgetData.onClickFunc);
        if (not widgetData.stateCheckFunc) or (widgetData.stateCheckFunc()) then
            button:Enable();
        else
            button:Disable();
        end
        button.matchParentWidth = true;
        return button
    end

    function EditModeSettingsDialogMixin:CreateDivider(widgetData)
        local texture = self:AcquireWidgetByType("Texture");
        texture:SetTexture("Interface/AddOns/Plumber/Art/Frame/Divider_NineSlice");
        texture:SetTextureSliceMargins(48, 4, 48, 4);
        texture:SetTextureSliceMode(0);
        texture:SetHeight(4);
        texture.isDivider = true;
        texture.matchParentWidth = true;
        return texture
    end

    function EditModeSettingsDialogMixin:CreateHeader(widgetData)
        local fontString = self:AcquireWidgetByType("FontString");
        fontString:SetJustifyH("CENTER");
        fontString:SetJustifyV("TOP");
        fontString:SetSpacing(2);
        fontString.matchParentWidth = true;
        fontString:SetText(widgetData.label);
        return fontString
    end

    function EditModeSettingsDialogMixin:SetupOptions(schematic)
        self:ReleaseAllWidgets();
        self:SetTitle(schematic.title);

        if schematic.widgets then
            for order, widgetData in ipairs(schematic.widgets) do
                local widget;
                if widgetData.type == "Checkbox" then
                    widget = self:CreateCheckbox(widgetData);
                elseif widgetData.type == "RadioGroup" then

                elseif widgetData.type == "Slider" then
                    widget = self:CreateSlider(widgetData);
                elseif widgetData.type == "UIPanelButton" then
                    widget = self:CreateUIPanelButton(widgetData);
                elseif widgetData.type == "Divider" then
                    widget = self:CreateDivider(widgetData);
                elseif widgetData.type == "Header" then
                    widget = self:CreateHeader(widgetData);
                end

                if widget then
                    tinsert(self.activeWidgets, widget);
                    widget.widgetKey = widgetData.widgetKey;
                end
            end
        end
        self:Layout();
    end

    function EditModeSettingsDialogMixin:FindWidget(widgetKey)
        if self.activeWidgets then
            for _, widget in pairs(self.activeWidgets) do
                if widget.widgetKey == widgetKey then
                    return widget
                end
            end
        end
    end

    function EditModeSettingsDialogMixin:OnDragStart()
        self:StartMoving();
    end

    function EditModeSettingsDialogMixin:OnDragStop()
        self:StopMovingOrSizing();
    end

    function EditModeSettingsDialogMixin:SetTitle(title)
        self.Title:SetText(title);
    end

    local function SetupSettingsDialog(parent, schematic)
        if not EditModeSettingsDialog then
            local f = CreateFrame("Frame", nil, UIParent);
            EditModeSettingsDialog = f;
            f:Hide();
            f:SetSize(DIALOG_WIDTH, 350);
            f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
            f:SetMovable(true);
            f:SetClampedToScreen(true);
            f:RegisterForDrag("LeftButton");
            f:SetDontSavePosition(true);
            f:SetFrameStrata("DIALOG");
            f:SetFrameLevel(200);
            f:EnableMouse(true);

            f.widgets = {};
            f.requireResetPosition = true;

            Mixin(f, EditModeSettingsDialogMixin);

            f.Border = CreateFrame("Frame", nil, f, "DialogBorderTranslucentTemplate");
            f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButtonNoScripts");
            f.CloseButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0);
            f.CloseButton:SetScript("OnClick", function()
                f:Exit();
            end);
            f.Title = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge");
            f.Title:SetPoint("TOP", f, "TOP", 0, -16);
            f.Title:SetText("Title");

            f:SetScript("OnDragStart", f.OnDragStart);
            f:SetScript("OnDragStop", f.OnDragStop);
        end

        if schematic ~= EditModeSettingsDialog.schematic then
            EditModeSettingsDialog.requireResetPosition = true;
            EditModeSettingsDialog.schematic = schematic;
            EditModeSettingsDialog:ClearAllPoints();
            EditModeSettingsDialog:SetupOptions(schematic);
        end

        EditModeSettingsDialog.parent = parent;

        return EditModeSettingsDialog
    end
    addon.SetupSettingsDialog = SetupSettingsDialog;
end