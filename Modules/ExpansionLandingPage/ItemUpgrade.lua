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
			local quantity = info.quantity;
			local totalEarned = info.useTotalEarnedForMaxQty and info.totalEarned or info.quantity;
			local maxQuantity = info.maxQuantity or 0;
			local isCapped = maxQuantity > 0 and totalEarned >= maxQuantity;
			self:SetCount(quantity, isCapped);
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
	local f = CreateFrame("Button", nil, parent, "PlumberStrikethroughNumberTemplate");
	f:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);
	API.Mixin(f, CurrencyButtonMixin);

	f.Count:SetPoint("BOTTOM", f, "BOTTOM", 0, 0);
	f.Count:SetJustifyH("CENTER");
	f.Count:SetTextColor(1, 1, 1);
	f.Count:SetText("0");

	f.Icon = f:CreateTexture(nil, "OVERLAY");
	f.Icon:SetSize(24, 24);
	f.Icon:SetPoint("TOP", f, "TOP", 0, 0);

	f:SetScript("OnEnter", f.OnEnter);
	f:SetScript("OnLeave", f.OnLeave);
	f:SetScript("OnClick", f.OnClick);

	return f
end
LandingPageUtil.CreateItemUpgradeButton = CreateButton;
