-- A popup within Landing Page
-- Currently unused

local _, addon = ...
local L = addon.L;
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil; ---@class LandingPageUtil

local Def = {
	PopupWidth = 408,
	PopupSidePadding = 24,
	RedButtonGap = 16,
	WidgetHeight = 24,
};

local PopupFrame;


local PopupFrameMixin = {};
do
	function PopupFrameMixin:OnShow()

	end

	function PopupFrameMixin:OnHide()
		self:Hide();
		self:ReleaseAllObjects();
		LandingPageUtil.HighlightWidget(nil);
	end

	function PopupFrameMixin:SetTitle(title)
		self.Header:SetName(title);
	end

	function PopupFrameMixin:ReleaseAllObjects()

	end

	function PopupFrameMixin:UpdateSaveButton(forceEnabled)
		local enabled = true or forceEnabled;
		self.SaveButton:SetEnabled(enabled);
	end

	function PopupFrameMixin:Layout(popupInfo)
		self:SetTitle(popupInfo.title);

		local headerHeight = 36;
		local offsetY = headerHeight;

		local totalHeight = offsetY + 2 + Def.RedButtonGap + Def.WidgetHeight + Def.PopupSidePadding;
		totalHeight = totalHeight + 256;
		self:SetHeight(totalHeight);
	end
end


local function PopupFrame_Init()
	if PopupFrame then return; end

	local parent = PlumberExpansionLandingPage;
	local f = CreateFrame("Frame", nil, parent);
	PopupFrame = f;
	f:Hide();
	API.Mixin(f, PopupFrameMixin);
	f:SetPoint("CENTER", parent, "CENTER", 0, 0);
	f:SetSize(Def.PopupWidth, 480);
	f:SetFrameStrata("DIALOG");
	f:EnableMouse(true);
	f:EnableMouseMotion(true);

	-- Frame background
	local NineSlice = LandingPageUtil.CreateExpansionThemeFrame(f, 10);
	f.NineSlice = NineSlice;
	NineSlice:ShowCloseButton(false);
	NineSlice:SetCloseButtonOwner(f);

	-- Header/Title area
	local Header = LandingPageUtil.CreateListCategoryButton(f, L["New Tracker Title"]);
	f.Header = Header;
	Header:SetPoint("CENTER", f, "TOP", 0, -4);

	-- Unused Divider
	local Divider = LandingPageUtil.CreateMajorDivider(f);
	f.Divider = Divider;
	Divider:Hide();
	Divider:SetWidth(Def.PopupWidth - 32);

	-- Save and Cancel buttons
	local redButtonOffsetY = Def.PopupSidePadding;
	local redButtonGap = Def.RedButtonGap;
	local redbuttonWidth = 0.5 * (Def.PopupWidth - redButtonGap - 2*redButtonOffsetY);
	f.SaveButton = LandingPageUtil.CreateRedButton(f);
	f.SaveButton:SetWidth(redbuttonWidth);
	f.SaveButton:SetButtonText(SAVE);
	f.SaveButton:SetPoint("BOTTOMRIGHT", f, "BOTTOM", -0.5*redButtonGap, redButtonOffsetY);

	f.CancelButton = LandingPageUtil.CreateRedButton(f);
	f.CancelButton:SetWidth(redbuttonWidth);
	f.CancelButton:SetButtonText(CANCEL);
	f.CancelButton:SetPoint("BOTTOMLEFT", f, "BOTTOM", 0.5*redButtonGap, redButtonOffsetY);
	f.CancelButton:SetScript("OnClick", function()
		f:Hide();
	end);

	f:SetScript("OnShow", f.OnShow);
	f:SetScript("OnHide", f.OnHide);
end

function LandingPageUtil.ShowPopup(popupInfo)
	PopupFrame_Init();
	PopupFrame:Layout(popupInfo);
	PopupFrame:Show();
end

function LandingPageUtil.HidePopup()
	if PopupFrame then
		PopupFrame:Hide();
	end
end
