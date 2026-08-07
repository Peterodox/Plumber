local _, addon = ...
local L = addon.L;
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil; ---@class LandingPageUtil

local PlayerPowerTab;

local ExpansionPlayerPowerSystem = {
	[12] = {
		{systemID = 48, treeID = 1186, name = RUNES_OF_POWER}, -- RUNES_OF_POWER_SYSTEM_ID
	},
};


local CreateSystemCard;
do
	function CreateSystemCard(systemID, systemName)
		local f = CreateFrame("Frame", nil, PlayerPowerTab);
		f:SetSize(512, 80);

		local texture = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/PlayerPowerCard.png";

		local Left = f:CreateTexture(nil, "BACKGROUND");
		f.Left = Left;
		Left:SetSize(120, 144);
		Left:SetPoint("LEFT", f, "LEFT", -24, 0);

		local Right = f:CreateTexture(nil, "BACKGROUND");
		f.Right = Right;
		Right:SetSize(32, 144);
		Right:SetPoint("RIGHT", f, "RIGHT", 16, 0);

		local Center = f:CreateTexture(nil, "BACKGROUND");
		f.Center = Center;
		Center:SetPoint("TOPLEFT", Left, "TOPRIGHT", 0, 0);
		Center:SetPoint("BOTTOMRIGHT", Right, "BOTTOMLEFT", 0, 0);

		Left:SetTexture(texture);
		Center:SetTexture(texture);
		Right:SetTexture(texture);

		Left:SetTexCoord(0, 240/1024, 0, 288/1024);
		Center:SetTexCoord(240/1024, 448/1024, 0, 288/1024);
		Right:SetTexCoord(448/1024, 512/1024, 0, 288/1024);

		local traitFrame = LandingPageUtil.CreateTraitFrame(f);
		traitFrame:ClearAllPoints();
		traitFrame:SetPoint("RIGHT", f, "RIGHT", -20, 0);
		traitFrame:SetSystemID(systemID);

		if traitFrame.OnLoad then
			traitFrame:OnLoad();
		end

		if traitFrame.OnShow and traitFrame:IsVisible() then
			traitFrame:OnShow();
		end

		local Name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		Name:SetPoint("LEFT", f, "LEFT", 86, 0);
		Name:SetPoint("RIGHT", traitFrame, "LEFT", -20, 0);
		Name:SetTextColor(0.804, 0.667, 0.498);
		Name:SetText(systemName);

		f.TraitFrame = traitFrame;

		return f
	end
end


local PlayerPowerTabMixin = {};
do
	function PlayerPowerTabMixin:OnShow()
		LandingPageUtil.ShowLeftFrame(true);
	end

	function PlayerPowerTabMixin:OnHide()

	end
end


do	--Event Handler
	local Frame = CreateFrame("Frame");

	Frame.systemIDXName = {};
	Frame.watchedTreeID = {};

	for expansionID, data in pairs(ExpansionPlayerPowerSystem) do
		for _, v in ipairs(data) do
			Frame.systemIDXName[v.systemID] = v.name;
			Frame.watchedTreeID[v.treeID] = true;
		end
	end

	function LandingPageUtil.GetPurchasableTraitSystem()
		for systemID, name in pairs(Frame.systemIDXName) do
			if API.HasAnyPurchasableTraitInSystem(systemID) then
				return systemID, name;
			end
		end
	end

	---@diagnostic disable-next-line: duplicate-set-field
	function LandingPageUtil.HasAnyPurchasableTrait()
		return LandingPageUtil.GetPurchasableTraitSystem() ~= nil;
	end

	---@diagnostic disable-next-line: duplicate-set-field
	function LandingPageUtil.HandleTraitTreeCurrencyChanged(treeID)
		if (not treeID) or (treeID and Frame.watchedTreeID[treeID]) then
			if not Frame.t then
				Frame.t = 0;
				Frame:SetScript("OnUpdate", function(self, elapsed)
					self.t = self.t + elapsed;
					if self.t >= 0.1 then
						self.t = nil;
						self:SetScript("OnUpdate", nil);
						addon.CallbackRegistry:Trigger("LandingPage.HasPurchasableTrait", LandingPageUtil.HasAnyPurchasableTrait());
					end
				end);
			end
			Frame.t = 0;
		end
	end


	addon.CallbackRegistry:RegisterCallback("LandingPage.HasPurchasableTrait", function(hasPurchasableTrait)
		if hasPurchasableTrait and (not InCombatLockdown()) then
			if not PlumberExpansionLandingPage:IsShown() then
				LandingPageUtil.ShowMinimapButtonAlert(OMNIUM_FOLIO_UNSPENT_POINTS, "TraitSystem", true);
			end
		else
			LandingPageUtil.HideMinimapButtonAlert("TraitSystem");
		end
	end);
end


local function PlayerPowerTab_Init(tab)
	API.Mixin(tab, PlayerPowerTabMixin);
	PlayerPowerTab = tab;
	tab:SetScript("OnShow", PlayerPowerTab.OnShow);
	tab:SetScript("OnHide", PlayerPowerTab.OnHide);

	local sytemInfo = ExpansionPlayerPowerSystem[12][1]; -- Just one Omnium Folio
	local Card1 = CreateSystemCard(sytemInfo.systemID, sytemInfo.name);
	Card1:SetPoint("CENTER", tab, "CENTER", 0, 6);
end

local function NotificationCheck(asTooltip)
	if asTooltip then
		local systemID, systemName = LandingPageUtil.GetPurchasableTraitSystem();
		if systemID and systemName then
			local tooltipLines = {};
			table.insert(tooltipLines, L["Unspent Points"]);
			table.insert(tooltipLines, "- "..systemName);
			return tooltipLines;
		end
	else
		return LandingPageUtil.HasAnyPurchasableTrait();
	end
end

local function PlayerPowerTab_OnSelected()

end

local function PlayerPowerTab_IsValid()
	local expansionID = LandingPageUtil.GetCurrentExpansionID();
	return expansionID and ExpansionPlayerPowerSystem[expansionID] ~= nil;
end

LandingPageUtil.AddTab(
	{
		key = "playerpower",
		name = L["Player Power"],
		uiOrder = 4,
		initFunc = PlayerPowerTab_Init,
		notificationGetter = NotificationCheck,
		useCustomLeftFrame = true,
		onTabSelected = PlayerPowerTab_OnSelected,
		validityCheck = PlayerPowerTab_IsValid,
		dimBackground = true,
	}
);
