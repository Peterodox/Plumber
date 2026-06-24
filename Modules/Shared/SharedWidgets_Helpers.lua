local _, addon = ...
local L = addon.L;
local API = addon.API;


PlumberReloadHelperMixin = {};
do	-- Create a clickable instruction: You must [reload the UI] to undo the changes.
	function PlumberReloadHelperMixin:OnLoad()
		if self.textFontObject then
			self.Instruction:SetFontObject(_G[self.textFontObject]);
		end
		self.Instruction:SetTextColor(1, 1, 1);
		self:UpdateText();
	end

	function PlumberReloadHelperMixin:UpdateText()
		local link = API.GenerateCustomLink("ReloadUI", L["Reload The UI"]);
		local spacing = 2;

		self.Instruction:SetText(string.format(L["Disabled Module Requires Reload Format"], link));
		self.Instruction:SetSpacing(spacing);

		local textHeight = self.Instruction:GetHeight();
		self:SetHeight(textHeight);

		-- If the fontObject/size changes, the numLines may not be accurate until later
	end

	function PlumberReloadHelperMixin:OnHyperlinkClick()
		C_UI.Reload();
	end

	function PlumberReloadHelperMixin:OnHyperlinkEnter(link, text, fontString, left, bottom, width, height)
		local tooltip = GameTooltip;
		tooltip:SetOwner(self, "ANCHOR_PRESERVE");
		tooltip:ClearAllPoints();
		tooltip:SetPoint("BOTTOMLEFT", fontString, "TOPLEFT", left + width, bottom);
		tooltip:SetText(L["Click To Reload UI"], 1, 0.82, 0, 1, true);
		tooltip:Show();
	end

	function PlumberReloadHelperMixin:OnHyperlinkLeave()
		GameTooltip:Hide();
	end
end
