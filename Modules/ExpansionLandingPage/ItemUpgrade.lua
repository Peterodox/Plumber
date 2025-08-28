local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;


local BUTTON_WIDTH, BUTTON_HEIGHT = 36, 40;


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

            local quantity = info.useTotalEarnedForMaxQty and info.totalEarned or info.quantity;
            local maxQuantity = info.maxQuantity or 0;

            if info.quantity > 0 then
	            local isCapped = maxQuantity > 0 and quantity >= maxQuantity;
                if isCapped then
                    self.Text:SetTextColor(0.098, 1.000, 0.098);
                else
                    self.Text:SetTextColor(0.88, 0.88, 0.88);
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

    function CurrencyButtonMixin:OnClick()
        API.ToggleBlizzardTokenUIIfWarbandCurrency(self.currencyID);
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
    f:SetScript("OnClick", f.OnClick);

    return f
end
LandingPageUtil.CreateItemUpgradeButton = CreateButton;