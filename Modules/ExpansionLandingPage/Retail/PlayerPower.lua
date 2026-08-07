local _, addon = ...
local L = addon.L;
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil; ---@class LandingPageUtil

local PlayerPowerTab;

local ExpansionPlayerPowerSystem = {
	[12] = {"Omni"},
};


local CreateSystemCard;
do
	function CreateSystemCard(systemName, traitFrame)
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

		traitFrame:ClearAllPoints();
		traitFrame:SetParent(f);
		traitFrame:SetPoint("RIGHT", f, "RIGHT", -20, 0);

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


local function PlayerPowerTab_Init(tab)
	API.Mixin(tab, PlayerPowerTabMixin);
	PlayerPowerTab = tab;
	tab:SetScript("OnShow", PlayerPowerTab.OnShow);
	tab:SetScript("OnHide", PlayerPowerTab.OnHide);

	local OmniumFolioFrame = LandingPageUtil.CreateTraitFrame(tab);
	local Card1 = CreateSystemCard(RUNES_OF_POWER, OmniumFolioFrame);
	Card1:SetPoint("CENTER", tab, "CENTER", 0, 6);

	if OmniumFolioFrame.OnLoad then
		OmniumFolioFrame:OnLoad();
	end
	if OmniumFolioFrame.OnShow and OmniumFolioFrame:IsVisible() then
		OmniumFolioFrame:OnShow();
	end
end

local function NotificationCheck(asTooltip)
	return false;
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
