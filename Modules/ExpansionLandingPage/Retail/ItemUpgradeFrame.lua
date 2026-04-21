local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;
local CreateButton = LandingPageUtil.CreateItemUpgradeButton;


local BUTTON_WIDTH, BUTTON_HEIGHT = 36, 40;
local BUTTON_GAP = 2;
local ItemUpgradeFrame;


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

	function ItemUpgradeFrameMixin:UpdateCurrencies()
		local n = 0;

		for _, button in ipairs(self.buttons) do
			button:Hide();
			button:ClearAllPoints();
		end

		local activeCurrencyIDs = {};

		for _, currencyID in ipairs(self.currencyIDs) do
			if not API.IsCurrencyUnused(currencyID) then
				table.insert(activeCurrencyIDs, currencyID);
			end
		end

		if #activeCurrencyIDs == 0 then
			activeCurrencyIDs[1] = self.currencyIDs[1]; -- Default to track the highest tier
		end

		for i, currencyID in ipairs(activeCurrencyIDs) do
			n = n + 1;
			local button = self.currencyXButton[currencyID];
			if button then
				button:SetPoint("TOPRIGHT", self, "TOPRIGHT", (1 - i) * (BUTTON_WIDTH + BUTTON_GAP), 0);
				button:Show();
			end
		end

		local width = n * (BUTTON_WIDTH + BUTTON_GAP) - BUTTON_GAP;
		self:SetWidth(width);
	end

	function LandingPageUtil.GetItemUpgradeButtons()
		if ItemUpgradeFrame then
			return ItemUpgradeFrame:GetActiveWidgets()
		end
	end
end


function LandingPageUtil.CreateItemUpgradeFrame(parent)
	if ItemUpgradeFrame then return ItemUpgradeFrame end;

	local f = CreateFrame("Frame", nil, parent);
	ItemUpgradeFrame = f;

	local n = 0;
	local buttons = {};

	f.currencyXButton = {};
	f.currencyIDs = addon.ItemUpgradeConstant.Crests;

	for i, currencyID in ipairs(f.currencyIDs) do
		n = n + 1;
		local button = CreateButton(parent);
		buttons[n] = button;
		button.currencyID = currencyID;
		button.displayedMax = 999;
		f.currencyXButton[currencyID] = button;
	end

	--[[    --Valorstones Removed. Replaced by 5 tiers of crests in Midnight
	local button = CreateButton(parent);
	table.insert(buttons, button);
	button:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
	button.currencyID = ItemUpgradeConstant.BaseCurrencyID;
	--]]

	local width = #buttons * (BUTTON_WIDTH + BUTTON_GAP) - BUTTON_GAP;
	local height = BUTTON_HEIGHT;

	f:SetSize(width, height);

	API.Mixin(f, ItemUpgradeFrameMixin);
	f.buttons = buttons;

	f:UpdateCurrencies();

	return f, height
end

addon.CallbackRegistry:Register("UnusedCurrencyChanged", function()
	if ItemUpgradeFrame then
		ItemUpgradeFrame:UpdateCurrencies();
	end
end);
