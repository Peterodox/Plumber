local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;


local BUTTON_WIDTH, BUTTON_HEIGHT = 36, 40;
local ItemUpgradeFrame;

local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;


local CurrencyButtonMixin = {};
do
    function CurrencyButtonMixin:Refresh()
        local info = GetCurrencyInfo(self.currencyID);
        if info then
            self:Show();
            self.Icon:SetTexture(info.iconFileID);
            if self.displayedMax and info.quantity > self.displayedMax then
                self.Text:SetText(self.displayedMax.."+");
            else
                self.Text:SetText(info.quantity);
            end

            local totalEarned = info.totalEarned or 0;
            local maxQuantity = info.maxQuantity or 0;

            if info.quantity > 0 then
                if maxQuantity > 0 and (((maxQuantity - totalEarned) == 0) or (info.quantity >= maxQuantity)) then
                    --Full
                    self.Text:SetTextColor(0.098, 1.000, 0.098);
                else
                    self.Text:SetTextColor(0.92, 0.92, 0.92);
                end
            else
                self.Text:SetTextColor(0.5, 0.5, 0.5);
            end
        else
            self:Hide();
        end
    end

    function CurrencyButtonMixin:OnEnter()
        GameTooltip:SetOwner(self.Icon, "ANCHOR_RIGHT", 2, 2);
        GameTooltip:SetCurrencyByID(self.currencyID);
    end

    function CurrencyButtonMixin:OnLeave()
        GameTooltip:Hide();
    end
end


local function CreateButton(parent)
    local f = CreateFrame("Button", nil, parent);
    f:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);
    API.Mixin(f, CurrencyButtonMixin);

    f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    f.Text:SetPoint("BOTTOM", f, "BOTTOM", 0, 0);
    f.Text:SetJustifyH("CENTER");
    f.Text:SetTextColor(1, 1, 1);
    f.Text:SetText("0");

    f.Icon = f:CreateTexture(nil, "OVERLAY");
    f.Icon:SetSize(24, 24);
    f.Icon:SetPoint("TOP", f, "TOP", 0, 0);

    f:SetScript("OnEnter", f.OnEnter);
    f:SetScript("OnLeave", f.OnLeave);

    return f
end




local ItemUpgradeFrameMixin = {};
do
    function ItemUpgradeFrameMixin:Refresh()
        for _, button in ipairs(self.buttons) do
            button:Refresh();
        end
    end

    function ItemUpgradeFrameMixin:GetActiveWidgets()
        return self.buttons
    end
end


function LandingPageUtil.CreateItemUpgradeFrame(parent)
    if ItemUpgradeFrame then return ItemUpgradeFrame end;

    local f = CreateFrame("Frame", nil, parent);
    ItemUpgradeFrame = f;

    local n = 0;
    local buttons = {};

    local ItemUpgradeConstant = addon.ItemUpgradeConstant;

    for i, currencyID in ipairs(ItemUpgradeConstant.Crests) do
        n = n + 1;
        local button = CreateButton(parent);
        buttons[n] = button;
        button:SetPoint("TOPRIGHT", f, "TOPRIGHT", (1 - i) * BUTTON_WIDTH, 0);
        button.currencyID = currencyID;
        button.displayedMax = 999;
    end

    local button = CreateButton(parent);
    table.insert(buttons, button);
    button:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
    button.currencyID = ItemUpgradeConstant.BaseCurrencyID;

    local width = 5.5 * BUTTON_WIDTH;
    local height = BUTTON_HEIGHT;

    f:SetSize(width, height);

    API.Mixin(f, ItemUpgradeFrameMixin);
    f.buttons = buttons;

    return f, height
end

function LandingPageUtil.GetItemUpgradeButtons()
    if ItemUpgradeFrame then
        return ItemUpgradeFrame:GetActiveWidgets()
    end
end