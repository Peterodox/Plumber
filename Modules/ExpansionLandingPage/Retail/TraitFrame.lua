local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;


local MainFrame;


local TraitFrameMixin = {};
do
	local TraitContainer;

	function TraitFrameMixin:Refresh()
		if TraitContainer then
			TraitContainer:Refresh();
		else
			TraitContainer = addon.CreateTraitContainer(self);
			TraitContainer:SetPoint("CENTER", self, "CENTER", 0, 0);
			TraitContainer:SetScale(36/40);
			TraitContainer:SetConfigIDBySystemID(48); -- RUNES_OF_POWER_SYSTEM_ID
		end
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

	return f, height, CategoryButtonOnEnterFunc;
end

-- Interface/AddOns/Blizzard_ExpansionLandingPage/Blizzard_MidnightLandingPage.lua
