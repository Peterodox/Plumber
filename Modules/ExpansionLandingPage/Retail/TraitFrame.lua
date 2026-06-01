local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;


local MainFrame;


local QUEST_PROVIDER_MAP = 2649; -- The Lycaneum
local QUEST_PIN_MAP = 2424; -- Use Isle map instead of the indoor map


local function GetBestMapForQuest(questID)
	if API.IsQuestReadyForTurnIn(questID) or (not C_QuestLog.IsOnQuest(questID)) then
		return QUEST_PIN_MAP;
	else
		return GetQuestUiMapID(questID);
	end
end

local TraitFrameMixin = {};
do
	local TraitContainer;

	local DynamicEvents = {
		"TRAIT_TREE_CURRENCY_INFO_UPDATED",
		"TRAIT_CONFIG_UPDATED",
		"CONFIG_COMMIT_FAILED",
		"QUEST_LOG_UPDATE",
		"QUESTLINE_UPDATE",
	};

	function TraitFrameMixin:Refresh()
		if TraitContainer then
			TraitContainer:Refresh();
		else
			TraitContainer = addon.CreateTraitContainer(self);
			TraitContainer:SetPoint("CENTER", self, "CENTER", 0, 0);
			TraitContainer:SetScale(36/40);
			TraitContainer:SetConfigIDBySystemID(48); -- RUNES_OF_POWER_SYSTEM_ID
			TraitContainer:SetEnableAutoCommit(true);
		end
		self:UpdateHeader();
	end

	function TraitFrameMixin:OnShow()
		self:Refresh();
		API.RegisterFrameForEvents(self, DynamicEvents);
		C_QuestLine.RequestQuestLinesForMap(QUEST_PROVIDER_MAP);
	end

	function TraitFrameMixin:OnHide()
		API.UnregisterFrameForEvents(self, DynamicEvents);
	end

	function TraitFrameMixin:OnEvent(event, ...)
		if event == "TRAIT_CONFIG_UPDATED" or event == "CONFIG_COMMIT_FAILED" then
			local configID = ...
			if configID and configID == TraitContainer.configID then
				self:Refresh();
			end
		elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
			-- Fire twice for auto commiting trait systems
			local treeID = ...
			if treeID and treeID == TraitContainer.treeID and TraitContainer.configID then
				self:Refresh();
			end
		elseif event == "QUEST_LOG_UPDATE" or event == "QUESTLINE_UPDATE" then
			C_QuestLine.RequestQuestLinesForMap(QUEST_PROVIDER_MAP);
			self:RequestUpdate();
		end
	end

	function TraitFrameMixin:RequestUpdate()
		self.t = 0;
		self:SetScript("OnUpdate", self.OnUpdate);
	end

	function TraitFrameMixin:OnUpdate(elapsed)
		self.t = self.t + elapsed;
		if self.t >= 0.5 then
			self.t = 0;
			self:SetScript("OnUpdate", nil);
			self:Refresh();
		end
	end

	function TraitFrameMixin:UpdateTraitSpentInstruction()
		-- If player has any unspent currency, show it on the header
		local configID = TraitContainer.configID;
		local treeID = TraitContainer.treeID;

		if configID and treeID then
			local excludeStagedChanges = false;
			local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configID, treeID, excludeStagedChanges);
			local info = treeCurrencyInfo and treeCurrencyInfo[1];
			if info and info.quantity > 0 then
				local flags, type, currencyTypesID, icon = C_Traits.GetTraitCurrencyInfo(info.traitCurrencyID);
				self.HeaderFrame:DisplayTraitCurrency(icon, info.quantity);
				MainFrame.BlackOverlay:Show();
				return true;
			else
				MainFrame.BlackOverlay:Hide();
				return false;
			end
		else
			MainFrame.BlackOverlay:Hide();
			return false;
		end
	end

	function TraitFrameMixin:UpdateQuestNotification()
		-- When a new quest becomes available
		local questID, isStartingQuest;
		local quests = C_QuestLine.GetAvailableQuestLines(QUEST_PROVIDER_MAP);

		if quests then
			for _, quest in ipairs(quests) do
				if quest.questLineID == 6307 then
					-- The Empowered Folio
					if not quest.isAccountCompleted then
						isStartingQuest = true;
						questID = quest.questID;
					end
				end
			end
		end

		if not questID then
			local questIDs = {96410, 96441, 96442, 96443, 96444};
			for _, _questID in ipairs(questIDs) do
				if C_QuestLog.IsOnQuest(_questID) then
					questID = _questID;
					break
				end
			end
		end

		if questID then
			self.HeaderFrame:DisplayQuest(questID, isStartingQuest);
			return true;
		else
			return false;
		end
	end

	function TraitFrameMixin:ShowHeaderFrame(state)
		if state then
			self.HeaderFrame:SetPoint("CENTER", self.listCategoryButton, "CENTER", 0, 0);
			self.HeaderFrame:Show();
			self.listCategoryButton.Name:Hide();
			self.listCategoryButton:EnableMouseMotion(false);
		else
			self.HeaderFrame:Hide();
			self.listCategoryButton.Name:Show();
		end
	end

	function TraitFrameMixin:UpdateHeader()
		local anyShown = self:UpdateTraitSpentInstruction();
		if not anyShown then
			anyShown = self:UpdateQuestNotification();
			local minimapButton = ExpansionLandingPageMinimapButton;
			if minimapButton and minimapButton:IsShown() then
				HelpTip:Hide(minimapButton);
				minimapButton:ClearPulses();
			end
		end
		self:ShowHeaderFrame(anyShown);
	end
end

local HeaderFrameMixin = {};
do
	function HeaderFrameMixin:DisplayTraitCurrency(icon, quantity)
		self.clickResponse = nil;
		self.Icon:ClearAllPoints();
		self.Text:ClearAllPoints();
		self.Icon:SetSize(16, 16);
		self.Icon:SetPoint("LEFT", self, "CENTER", 0, 0);
		self.Icon:SetTexture(icon);
		self.Text:SetPoint("RIGHT", self.Icon, "LEFT", -4, 0);
		self.Text:SetText(quantity);
		self.Text:SetTextColor(0.098, 1.000, 0.098);
		self:SetScript("OnEnter", self.ShowTooltipSpell);
	end

	function HeaderFrameMixin:ShowTooltipSpell()
		local tooltip = GameTooltip;
		tooltip:SetOwner(self.Icon, "ANCHOR_RIGHT");
		tooltip:SetSpellByID(1294322); -- Mote of Omnial Inquiry
	end

	function HeaderFrameMixin:DisplayQuest(questID, isStartingQuest)
		self.clickResponse = "quest";
		self.Icon:ClearAllPoints();
		self.Text:ClearAllPoints();
		self.Text:SetPoint("CENTER", self, "CENTER", 8, 0);
		local iconOffset = 0;

		if isStartingQuest then
			self.Text:SetText(addon.L["New Quest"]);
			self.Text:SetTextColor(0.922, 0.871, 0.761);
			self.Icon:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/TrackerType-Quest.png");
			self.Icon:SetTexCoord(0, 1, 0, 1);
		elseif API.IsQuestReadyForTurnIn(questID) then
			self.Text:SetText(QUEST_WATCH_QUEST_READY);
			self.Text:SetTextColor(0.098, 1.000, 0.098);
			self.Icon:SetAtlas("QuestTurnin");
			iconOffset = -2;
		else
			self.Text:SetText(GARRISON_MISSION_IN_PROGRESS_TOOLTIP);
			self.Text:SetTextColor(0.922, 0.871, 0.761);
			self.Icon:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressRed.png");
			self.Icon:SetTexCoord(0, 1, 0, 1);
			iconOffset = -4;
		end

		self.Icon:SetSize(16, 16);
		self.Icon:SetPoint("RIGHT", self.Text, "LEFT", iconOffset, 0);

		self.questID = questID;
		self:SetScript("OnEnter", self.ShowTooltipQuest);
	end

	function HeaderFrameMixin:ShowTooltipQuest()
		if not self.questID then return; end
		local TooltipUpdator = LandingPageUtil.TooltipUpdator;
		TooltipUpdator:SetFocusedObject(self);
		TooltipUpdator:SetHeaderText(API.GetQuestName(self.questID))
		TooltipUpdator:SetQuestID(self.questID);
		TooltipUpdator:RequestQuestProgress();
		TooltipUpdator:RequestQuestReward();
		local questUiMapID = GetBestMapForQuest(self.questID);
		TooltipUpdator:SetEnableShowOnMap(questUiMapID);
	end

	function HeaderFrameMixin:OnLeave()
		GameTooltip:Hide();
		LandingPageUtil.TooltipUpdator:StopUpdating();
	end

	function HeaderFrameMixin:OnClick(button)
		if self.clickResponse == "quest" then
			if button == "LeftButton" and IsControlKeyDown() and (not InCombatLockdown()) then
				API.SuperTrackQuestMapPin(self.questID);
				local questUiMapID = GetBestMapForQuest(self.questID);
				C_Map.OpenWorldMap(questUiMapID);
			end
		end
	end
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
	f:SetFrameLevel(LandingPageUtil.GetUIFrameLevel() + 10);

	Mixin(f, TraitFrameMixin);
	f:SetScript("OnShow", f.OnShow);
	f:SetScript("OnHide", f.OnHide);
	f:SetScript("OnEvent", f.OnEvent);

	local HeaderFrame = CreateFrame("Button", nil, f);
	f.HeaderFrame = HeaderFrame;
	HeaderFrame:Hide();
	HeaderFrame:SetSize(240, 24);
	HeaderFrame.Icon = HeaderFrame:CreateTexture(nil, "OVERLAY");
	HeaderFrame.Text = HeaderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	Mixin(HeaderFrame, HeaderFrameMixin);
	HeaderFrame:SetScript("OnEnter", HeaderFrame.OnEnter);
	HeaderFrame:SetScript("OnLeave", HeaderFrame.OnLeave);
	HeaderFrame:SetScript("OnClick", HeaderFrame.OnClick);

	local container = PlumberExpansionLandingPage.LeftSection;
	f.BlackOverlay = f:CreateTexture(nil, "BACKGROUND");
	f.BlackOverlay:Hide();
	f.BlackOverlay:SetColorTexture(0, 0, 0, 0.8);
	f.BlackOverlay:SetPoint("TOPLEFT", container, "TOPLEFT", 8, -8);
	f.BlackOverlay:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -8, 8);

	return f, height
end

-- Interface/AddOns/Blizzard_ExpansionLandingPage/Blizzard_MidnightLandingPage.lua
