local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;


local MainFrame;


local TraitFrameMixin = {};
do
	local TraitContainer;

	local DynamicEvents = {
		"TRAIT_TREE_CURRENCY_INFO_UPDATED",
		"TRAIT_CONFIG_UPDATED",
	};

	function TraitFrameMixin:Refresh()
		if TraitContainer then
			TraitContainer:Refresh();
		else
			TraitContainer = addon.CreateTraitContainer(self);
			TraitContainer:SetPoint("CENTER", self, "CENTER", 0, 0);
			TraitContainer:SetScale(36/40);
			TraitContainer:SetConfigIDBySystemID(48); -- RUNES_OF_POWER_SYSTEM_ID
		end
		self:UpdateInstruction();
	end

	function TraitFrameMixin:OnShow()
		self:Refresh();
		API.RegisterFrameForEvents(self, DynamicEvents);
	end

	function TraitFrameMixin:OnHide()
		API.UnregisterFrameForEvents(self, DynamicEvents);
	end

	function TraitFrameMixin:OnEvent(event, ...)
		if event == "TRAIT_CONFIG_UPDATED" then
			local configID = ...
			if configID and configID == TraitContainer.configID then
				self:Refresh();
			end
		elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
			-- Fire twice for auto commiting trait systems
			local treeID = ...
			if treeID and treeID == TraitContainer.treeID and TraitContainer.configID then
				self:UpdateInstruction();
			end
		end
	end

	function TraitFrameMixin:UpdateInstruction()
		-- If player has any unspent currency, show it on the header
		local configID = TraitContainer.configID;
		local treeID = TraitContainer.treeID;

		if configID and treeID then
			local excludeStagedChanges = false;
			local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configID, treeID, excludeStagedChanges);
			local info = treeCurrencyInfo and treeCurrencyInfo[1];
			if info and info.quantity > 0 then
				local flags, type, currencyTypesID, icon = C_Traits.GetTraitCurrencyInfo(info.traitCurrencyID);
				self.CurrencyFrame.Icon:SetTexture(icon);
				self.CurrencyFrame.Count:SetText(info.quantity);
				self.CurrencyFrame:SetPoint("CENTER", self.listCategoryButton, "CENTER", 0, 0);
				self.CurrencyFrame:Show();
				self.listCategoryButton.Name:Hide();
				return
			end
		end

		self.CurrencyFrame:Hide();
		self.listCategoryButton.Name:Show();
	end
end


local function CategoryButtonOnEnterFunc(listCategoryButton)

end

function LandingPageUtil.GetTraitSystemName()
	return RUNES_OF_POWER;
end

function LandingPageUtil.CreateTraitFrame(parent)
	if MainFrame then return MainFrame; end

	local f = CreateFrame("Frame", nil, parent);
	MainFrame = f;
	local width = 240;
	local height = 40;
	f:SetSize(width, height);

	Mixin(f, TraitFrameMixin);
	f:SetScript("OnShow", f.OnShow);
	f:SetScript("OnHide", f.OnHide);
	f:SetScript("OnEvent", f.OnEvent);

	local CurrencyFrame = CreateFrame("Frame", nil, f);
	f.CurrencyFrame = CurrencyFrame;
	CurrencyFrame:Hide();
	CurrencyFrame:SetSize(240, 24);

	CurrencyFrame.Icon = CurrencyFrame:CreateTexture(nil, "OVERLAY");
	CurrencyFrame.Icon:SetSize(16, 16);
	CurrencyFrame.Icon:SetPoint("LEFT", CurrencyFrame, "CENTER", 0, 0);
	CurrencyFrame.Count = CurrencyFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	CurrencyFrame.Count:SetPoint("RIGHT", CurrencyFrame.Icon, "LEFT", -4, 0);
	CurrencyFrame.Count:SetTextColor(0.098, 1.000, 0.098);

	CurrencyFrame:SetScript("OnEnter", function()
		local tooltip = GameTooltip;
		tooltip:SetOwner(CurrencyFrame.Icon, "ANCHOR_RIGHT");
		tooltip:SetSpellByID(1294322); -- Mote of Omnial Inquiry
	end);

	CurrencyFrame:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);


	return f, height, CategoryButtonOnEnterFunc;
end

-- Interface/AddOns/Blizzard_ExpansionLandingPage/Blizzard_MidnightLandingPage.lua
