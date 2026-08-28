local _, addon = ...
local API = addon.API;
local CallbackRegistry = addon.CallbackRegistry;
local LandingPageUtil = addon.LandingPageUtil; ---@class LandingPageUtil
local TimedDispatcher = addon.TimedDispatcher;
local SetupThreeSliceBackground = API.SetupThreeSliceBackground;
local CreateFrame = CreateFrame;


local GetItemNameByID = C_Item.GetItemNameByID;
local TEXTURE = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/ChecklistButton.tga";
local CreateEyeButton;


local CreateSharedListButton;
do  --ScrollViewListButton
	local SharedListButtonMixin = {};

	function SharedListButtonMixin:SetBackgroundColor(r, g, b)
		self.Left:SetVertexColor(r, g, b);
		self.Right:SetVertexColor(r, g, b);
		self.Center:SetVertexColor(r, g, b);
	end

	function SharedListButtonMixin:ShouldShowHighlight()
		--Override when there is a child button
		return self:IsMouseMotionFocus();
	end

	function SharedListButtonMixin:UpdateVisual()
		if self:ShouldShowHighlight() then
			self.Left:SetTexCoord(0/512, 64/512, 128/512, 192/512);
			self.Right:SetTexCoord(448/512, 512/512, 128/512, 192/512);
			self.Center:SetTexCoord(64/512, 448/512, 128/512, 192/512);
			self.Name:SetTextColor(1, 1, 1);
		else
			if self.isOdd then
				self.Left:SetTexCoord(0/512, 64/512, 64/512, 128/512);
				self.Right:SetTexCoord(448/512, 512/512, 64/512, 128/512);
				self.Center:SetTexCoord(64/512, 448/512, 64/512, 128/512);
			else
				self.Left:SetTexCoord(0/512, 64/512, 0/512, 64/512);
				self.Right:SetTexCoord(448/512, 512/512, 0/512, 64/512);
				self.Center:SetTexCoord(64/512, 448/512, 0/512, 64/512);
			end
			if self.isHeader or self.completed then
				self.Name:SetTextColor(0.6, 0.6, 0.6);
			elseif self.readyForTurnIn then
				self.Name:SetTextColor(0.098, 1.000, 0.098);
			else
				if self.selected then
					self.Name:SetTextColor(1, 1, 1);
				else
					if self.SetDefaultTextColor then
						self:SetDefaultTextColor();
					else
						self.Name:SetTextColor(0.922, 0.871, 0.761);
					end
				end
			end
		end
	end

	function SharedListButtonMixin:SetHeader()
		self.id = nil;
		self.type = "Header";

		self.isHeader = true;
		self.readyForTurnIn = nil;
		self.flagQuest = nil;
		self.Icon:SetTexture(TEXTURE);
		self.Icon:SetSize(18, 18);
		self.Icon:SetPoint("CENTER", self, "LEFT", 16, 0);
		self.Icon:Show();
		self.Name:SetTextColor(0.6, 0.6, 0.6);
		self.Name:SetWidth(0);
		self.Name:SetMaxLines(1);
		self.Text1:SetText(nil);

		if self.isCollapsed then
			self.Icon:SetTexCoord(336/512, 384/512, 208/512, 256/512);
		else
			self.Icon:SetTexCoord(0, 48/512, 208/512, 256/512);
		end

		self:Layout();
	end

	function SharedListButtonMixin:SetEntry()
		--Clear Atlas
		self.isHeader = nil;
		self.Icon:SetSize(18, 18);
		self.Icon:SetTexture(nil);
		self.Icon:SetPoint("CENTER", self, "LEFT", 16, 0);
		self.Icon:SetTexCoord(0, 1, 0, 1);
		self.Name:SetTextColor(0.88, 0.88, 0.88);
		self.Name:SetWidth(288);
		self.Name:SetMaxLines(2);
	end

	function SharedListButtonMixin:Layout()
		local textOffset = 10;

		if self.Icon:IsShown() then
			textOffset = textOffset + 22;
		end

		self.Name:SetPoint("LEFT", self, "LEFT", textOffset, 0);
	end

	function SharedListButtonMixin:ShowGlow(showGlow)
		self.Glow:SetShown(showGlow);
	end

	function SharedListButtonMixin:ShowEyeButton(state)
		if state then
			if not self.EyeButton then
				self.EyeButton = CreateEyeButton(self);
				self.EyeButton:SetPoint("RIGHT", self, "LEFT", -4, 0);
			end
			self.EyeButton.isOdd = self.isOdd;
			self.EyeButton:UpdateVisual();
			self.EyeButton:Show();
		elseif self.EyeButton then
			self.EyeButton:Hide();
		end
	end

	function CreateSharedListButton(parent)
		local f = CreateFrame("Button", nil, parent);
		API.Mixin(f, SharedListButtonMixin);
		f:SetSize(248, 24);

		SetupThreeSliceBackground(f, TEXTURE, -4, 4);
		f.Left:SetSize(32, 32);
		f.Left:SetTexCoord(0/512, 64/512, 0/512, 64/512);
		f.Right:SetSize(32, 32);
		f.Right:SetTexCoord(448/512, 512/512, 0/512, 64/512);
		f.Center:SetTexCoord(64/512, 448/512, 0/512, 64/512);

		f.Icon = f:CreateTexture(nil, "OVERLAY");
		f.Icon:SetSize(18, 18);
		f.Icon:SetPoint("CENTER", f, "LEFT", 16, 0);

		f.Name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		f.Name:SetPoint("LEFT", f, "LEFT", 32, 0);
		f.Name:SetTextColor(0.88, 0.88, 0.88);
		f.Name:SetJustifyH("LEFT");

		f.Text1 = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		f.Text1:SetPoint("RIGHT", f, "RIGHT", -96, 0);
		f.Text1:SetTextColor(0.88, 0.88, 0.88);
		f.Text1:SetJustifyH("CENTER");

		f.Glow = f:CreateTexture(nil, "BORDER");
		f.Glow:Hide();
		f.Glow:SetTexture(TEXTURE);
		f.Glow:SetTexCoord(0/512, 512/512, 352/512, 416/512);
		f.Glow:SetPoint("LEFT", f.Left, "LEFT", 0, 0);
		f.Glow:SetSize(256, 32);
		f.Glow:SetBlendMode("ADD");
		f.Glow:SetVertexColor(0.5, 0.5, 0.5);

		return f;
	end
	LandingPageUtil.CreateSharedListButton = CreateSharedListButton;
end


do	--EyeButton controls visibility
	local EyeButtonMixin = {};

	function EyeButtonMixin:OnEnter()
		self:UpdateVisual();
		TimedDispatcher:ShowWidgetTooltipAfterDelay(self);
	end

	function EyeButtonMixin:OnLeave()
		self:UpdateVisual();
		GameTooltip:Hide();
		TimedDispatcher:Kill();
	end

	function EyeButtonMixin:OnClick(button)
		self:GetParent():ToggleEntryIgnored();
		GameTooltip:Hide();
		TimedDispatcher:ShowWidgetTooltipAfterDelay(self);
	end

	function EyeButtonMixin:UpdateVisual()
		local l, r;
		local t, b = 272, 336;
		if self:IsMouseMotionFocus() then
			l, r = 400, 464;
		else
			if self.isOdd then
				l, r = 336, 400;
			else
				l, r = 272, 336;
			end
		end
		self.Background:SetTexCoord(l/512, r/512, t/512, b/512);
	end

	function EyeButtonMixin:SetIconCoord(l, r, t, b)
		self.Icon:SetTexCoord(l, r, t, b);
		self.IconHighlight:SetTexCoord(l, r, t, b);
	end

	function EyeButtonMixin:OpenEye()
		self.parentEntryIgnored = false;
		self:SetIconCoord(432/512, 480/512, 208/512, 256/512);
	end

	function EyeButtonMixin:CloseEye()
		self.parentEntryIgnored = true;
		self:SetIconCoord(384/512, 432/512, 208/512, 256/512);
	end

	function EyeButtonMixin:ShowTooltip()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		if self.parentEntryIgnored then
			LandingPageUtil.SetTooltip(addon.L["Click To Enable Activity"]);
		else
			LandingPageUtil.SetTooltip(addon.L["Click To Ignore Activity"]);
		end
		GameTooltip:Show();
	end

	function CreateEyeButton(parent)
		local f = CreateFrame("Button", nil, parent);
		Mixin(f, EyeButtonMixin);
		f:SetSize(24, 24);

		f.Icon = f:CreateTexture(nil, "OVERLAY");
		f.Icon:SetSize(24, 24);
		f.Icon:SetPoint("CENTER", f, "CENTER", 0, 0);

		f.IconHighlight = f:CreateTexture(nil, "HIGHLIGHT");
		f.IconHighlight:SetSize(24, 24);
		f.IconHighlight:SetPoint("CENTER", f, "CENTER", 0, 0);
		f.IconHighlight:SetVertexColor(0.5, 0.5, 0.5);
		f.IconHighlight:SetBlendMode("ADD");

		f.Background = f:CreateTexture(nil, "BACKGROUND");
		f.Background:SetSize(32, 32);
		f.Background:SetPoint("CENTER", f, "CENTER", 0, 0);

		f.Icon:SetTexture(TEXTURE);
		f.IconHighlight:SetTexture(TEXTURE);
		f.Background:SetTexture(TEXTURE);

		API.DisableSharpening(f.Icon);
		API.DisableSharpening(f.IconHighlight);

		f:UpdateVisual();
		f:OpenEye();

		f:SetScript("OnEnter", f.OnEnter);
		f:SetScript("OnLeave", f.OnLeave);
		f:SetScript("OnClick", f.OnClick);

		f:SetIgnoreParentAlpha(true);

		return f;
	end
end

do  --Generic Checklist Button
	local ChecklistButtonMixin = {};

	function ChecklistButtonMixin:OnEnter()
		self:UpdateVisual();
	end

	function ChecklistButtonMixin:OnLeave()
		self:UpdateVisual();
	end

	function ChecklistButtonMixin:OnClick(button)

	end

	function ChecklistButtonMixin:UpdateProgress()
		self.completed = nil;
		self.readyForTurnIn = nil;
		self.Text1:SetText(nil);

		if self.updateProgressFunc then
			self.updateProgressFunc(self);
		end
		self:UpdateVisual();
	end

	function ChecklistButtonMixin:UpdateProgress_Quest()
		local data = API.GetQuestData(self.id);
		if data then
			if data.completed or (self.data.warband and data.warbandCompleted) then
				self.Icon:SetAtlas("checkmark-minimal-disabled");
				self.completed = true;
			else
				self.readyForTurnIn = data.readyForTurnIn;
				if data.iconAtlas then
					self.Icon:SetAtlas(data.iconAtlas);
				else
					self.Icon:SetTexture(data.iconFile);
				end

				if data.isOnQuest then
					if self.readyForTurnIn then

					else
						local percentText = API.GetQuestProgressPercent(self.id, true);
						self.Text1:SetText(percentText);
					end
				end
			end
		end
	end

	function ChecklistButtonMixin:UpdateProgress_Item()

	end

	function ChecklistButtonMixin:UpdateProgress_Rare()
		if API.IsRareCreatureKilled(self.id, self.data.flagQuest, self.data.warband) then
			self.completed = true;
			self.Icon:SetAtlas("checkmark-minimal-disabled");
		else
			self.Icon:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/TrackerType-Rare.png");
		end
	end

	function ChecklistButtonMixin:SetData(data)
		self.data = data;

		if not data then
			self.type = nil;
			self.Name:SetText(nil);
			return;
		end

		if data.localizedName then
			self.loaded = true;
			self.Name:SetText(data.localizedName);
		else
			self.loaded = false;
			self.Name:SetText(data.name);
		end

		self.type = data.type;

		if data.isHeader then
			self.updateProgressFunc = nil;
		end

		if self.type == "Quest" then
			self:SetQuest(data.id);
		elseif self.type == "Item" then
			self:SetItem(data.id);
		elseif self.type == "Rare" then
			self:SetRareCreature(data.id, data.flagQuest);
		end

		self:UpdateProgress();
	end

	function ChecklistButtonMixin:SetQuest(questID)
		self.type = "Quest";
		self.id = questID;
		self.updateProgressFunc = self.UpdateProgress_Quest;

		if not self.loaded then
			CallbackRegistry:LoadQuest(questID, function(_questID)
				if questID == self.id and self.type == "Quest" then
					self.loaded = true;
					local name = API.GetQuestName(_questID);
					self.data.localizedName = name;
					self.Name:SetText(name);
					self:UpdateProgress();
					if self:IsMouseMotionFocus() then
						self:OnEnter();
					end
				end
			end);
		end
	end

	function ChecklistButtonMixin:SetItem(itemID)
		self.type = "Item";
		self.id = itemID;
		self.updateProgressFunc = self.UpdateProgress_Item;

		if not self.loaded then
			CallbackRegistry:LoadItem(itemID, function(_itemID)
				if _itemID == self.id and self.type == "Item" then
					self.loaded = true;
					local name = GetItemNameByID(_itemID);
					self.data.localizedName = name;
					self.Name:SetText(name);
					self:UpdateProgress();
				end
			end);
		end
	end

	function ChecklistButtonMixin:SetRareCreature(creatureID, flagQuest)
		self.type = "Rare";
		self.id = creatureID;
		self.updateProgressFunc = self.UpdateProgress_Rare;
		self.flagQuest = flagQuest;

		if not self.loaded then
			local name = API.GetAndCacheCreatureName(creatureID);
			if name then
				self.loaded = true;
				self.data.localizedName = name;
				self.Name:SetText(name);
			else
				CallbackRegistry:LoadCreature(creatureID, function(_creatureID, _name)
					if _creatureID == self.id and self.type == "Rare" then
						self.loaded = true;
						self.data.localizedName = _name;
						self.Name:SetText(_name);
					end
				end);
			end
		end
	end

	function ChecklistButtonMixin:ToggleCollapsed()

	end

	function ChecklistButtonMixin:DisplayTooltip()

	end

	local function CreateChecklistButton(parent)
		local f = CreateSharedListButton(parent);

		API.Mixin(f, ChecklistButtonMixin);
		f:SetScript("OnEnter", f.OnEnter);
		f:SetScript("OnLeave", f.OnLeave);
		f:SetScript("OnClick", f.OnClick);

		return f;
	end
	LandingPageUtil.CreateChecklistButton = CreateChecklistButton;
end
