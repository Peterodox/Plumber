local _, addon = ...


local Def = {
	CardWidth = 480,
	CardHeight = 120,
	BackgroundWidth = 512,
	BackgroundHeight = 152,
	CardTextPadding = 22,
	CardSpacing = 10,
	TextureFile = "Interface/AddOns/Plumber/Art/Housing/HouseListFrame.png",

	CardEffectiveWidth = 368,
	CardEffectiveHeight = 92,
};


local Module = {};


do	-- HouseListEntry
	local HouseListEntryMixin = {};

	function HouseListEntryMixin:SetHouseInfo(houseInfo)
		if houseInfo then
			self.HouseNameText:SetText(houseInfo.houseName);
			self.HouseOwnerText:SetText(houseInfo.ownerName);
			if addon.Housing.IsAllianceNeighborhood(houseInfo.neighborhoodGUID) then
				self.Background:SetTexCoord(0, 1, 152/512, 304/512);
			else
				self.Background:SetTexCoord(0, 1, 0, 152/512);
			end
			self.VisitHouseButton:Show();
			self.VisitHouseButton:SetupAction(houseInfo.neighborhoodGUID, houseInfo.houseGUID, houseInfo.plotID);
		else
			self.VisitHouseButton:Hide();
		end
	end


	local VisitHouseButtonMixin = {};

	function VisitHouseButtonMixin:OnEvent(event)
		if event == "PLAYER_REGEN_ENABLED" then
			self:Enable();
		elseif event == "PLAYER_REGEN_DISABLED" then
			self:Disable();
		end

		if self:IsMouseMotionFocus() then
			self:OnEnter();
		end
	end

	function VisitHouseButtonMixin:OnShow()
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		self:RegisterEvent("PLAYER_REGEN_DISABLED");
		if InCombatLockdown() then
			self:Disable();
		else
			self:Enable();
		end
	end

	function VisitHouseButtonMixin:OnHide()
		self:UnregisterEvent("PLAYER_REGEN_ENABLED");
		self:UnregisterEvent("PLAYER_REGEN_DISABLED");
	end

	function VisitHouseButtonMixin:OnEnter()
		GameTooltip:Hide();
		local tooltipText;

		if InCombatLockdown() then
			tooltipText = ERR_HOUSING_RESULT_LOCKED_BY_COMBAT;
		else
			local propagateMouseMotion = true;
			local propagateMouseClicks = true;
			local actionButton = addon.AcquireSecureActionButton("HouseList", propagateMouseMotion, propagateMouseClicks);
			if actionButton then
				actionButton:SetParent(self);
				actionButton:CoverParent();
				actionButton:SetVisitHouse(self.neighborhoodGUID, self.houseGUID, self.plotID);
				actionButton:Show();
			end
		end

		if tooltipText then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(tooltipText, 1.000, 0.125, 0.125, 1, true);
			GameTooltip:Show();
		end
	end

	function VisitHouseButtonMixin:OnLeave()
		GameTooltip:Hide();
	end

	function VisitHouseButtonMixin:SetupAction(neighborhoodGUID, houseGUID, plotID)
		self.neighborhoodGUID = neighborhoodGUID;
		self.houseGUID = houseGUID;
		self.plotID = plotID;
	end

	function VisitHouseButtonMixin:OnLoad()
		self:SetScript("OnShow", self.OnShow);
		self:SetScript("OnHide", self.OnHide);
		self:SetScript("OnEnter", self.OnEnter);
		self:SetScript("OnLeave", self.OnLeave);
		self:SetScript("OnEvent", self.OnEvent);
	end


	function Module.CreateEntry(parent)
		local f = CreateFrame("Frame", nil, parent, "PlumberHouseListFrameEntryTemplate");
		Mixin(f, HouseListEntryMixin);

		local effectiveWidth = Def.CardEffectiveWidth;
		local scale = effectiveWidth / Def.CardWidth;

		f:SetSize(effectiveWidth, scale * Def.CardHeight);
		f.Background:SetTexture(Def.TextureFile);
		f.Background:SetSize(scale * Def.BackgroundWidth, scale * Def.BackgroundHeight);
		local offset = 12;
		f.HouseNameText:SetPoint("TOPLEFT", f, "TOPLEFT", offset, -offset);
		f.VisitHouseButton:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", offset, offset);

		Mixin(f.VisitHouseButton, VisitHouseButtonMixin);
		f.VisitHouseButton:OnLoad();

		return f
	end
end


do
	local MainFrame;
	local MainFrameMixin = {};

	function MainFrameMixin:Release()
		for _, card in ipairs(self.cards) do
			card:Hide();
		end
	end

	function MainFrameMixin:InitWithContextData(name, guid, bnetID, isGuildMember)
		self.Title:SetText(string.format(VIEW_HOUSES_TITLE, name));
		self:OnHouseListUpdated(nil);
		self.LoadingSpinner:Show();
		self.NoHousesText:Hide();
		C_Housing.GetOthersOwnedHouses(guid, bnetID, isGuildMember or false);
	end

	function MainFrameMixin:OnShow()
		self:RegisterEvent("VIEW_HOUSES_LIST_RECIEVED");
		self.ReloadHelper:SetShown(not Module.enabled);
	end

	function MainFrameMixin:OnHide()
		self:UnregisterEvent("VIEW_HOUSES_LIST_RECIEVED");
		self.LoadingSpinner:Hide();
	end

	function MainFrameMixin:OnEvent(event, ...)
		if event == "VIEW_HOUSES_LIST_RECIEVED" then
			local houseInfoList = ...;
			self:OnHouseListUpdated(houseInfoList);
			self.LoadingSpinner:Hide();
		end
	end

	function MainFrameMixin:OnHouseListUpdated(houseInfoList)
		local numEntries = 2;
		local headerHeight = 32;

		if houseInfoList and #houseInfoList > 0 then
			--Always show 2
			for i = 1, 2 do
				if houseInfoList[i] then
					local card = self.cards[i];
					if not card then
						card = Module.CreateEntry(self);
						self.cards[i] = card;
						if i == 1 then
							card:SetPoint("TOP", self, "TOP", 0, -headerHeight -Def.CardSpacing);
						else
							card:SetPoint("TOP", self.cards[i - 1], "BOTTOM", 0, -Def.CardSpacing);
						end
					end
					card:SetHouseInfo(houseInfoList[i]);
					card:Show();
				end
			end
			self.NoHousesText:Hide();
		else
			self:Release();
			self.NoHousesText:Show();
		end

		local extraHeight = 0;
		if self.ReloadHelper:IsShown() then
			extraHeight = self.ReloadHelper:GetHeight() + 14;
		end

		self:SetHeight(headerHeight + numEntries * (Def.CardEffectiveHeight + Def.CardSpacing) + Def.CardSpacing + 7 + extraHeight);
		self:UpdatePosition();
	end

	function MainFrameMixin:UpdatePosition()
		if FriendsListFrame and FriendsListFrame:IsShown() then
			self:ClearAllPoints();
			self:SetPoint("TOPLEFT", FriendsListFrame, "TOPRIGHT", 16, 0);
		end
	end


	function Module.InitMainFrame()
		if not MainFrame then
			local frameName = "PlumberHouseListFrame";
			MainFrame = CreateFrame("Frame", frameName, UIParent, "PlumberHouseListFrameTemplate");
			table.insert(UISpecialFrames, frameName);
			Mixin(MainFrame, MainFrameMixin);
			MainFrame.cards = {};
			MainFrame:SetScript("OnShow", MainFrame.OnShow);
			MainFrame:SetScript("OnHide", MainFrame.OnHide);
			MainFrame:SetScript("OnEvent", MainFrame.OnEvent);

			if MainFrame:IsShown() then
				MainFrame:OnShow();
			end
		end
	end

	function Module.RemoveMainFrame()
		if MainFrame then
			MainFrame:Hide();
			MainFrame:Release();
		end
	end

	function Module.InitWithContextData(...)
		Module.InitMainFrame();
		MainFrame:Show();
		MainFrame:InitWithContextData(...);
	end
end


do	-- Module Control
	local function OverrideOnClick(self, contextData)
		local name = UnitPopupSharedUtil.GetFullPlayerName(contextData);
		local guid = UnitPopupSharedUtil.GetGUID(contextData);
		local bnetID = contextData.bnetIDAccount;
		local isGuildMember = contextData.isGuildMember;

		Module.InitWithContextData(name, guid, bnetID, isGuildMember);
	end

	local function EnableModule(state)
		if state then
			Module.enabled = true;
			UnitPopupViewHousesButtonMixin.OnClick = OverrideOnClick;
		elseif Module.enabled then
			Module.enabled = false;
			-- Once tainted, it's irreversible and we ask the user to /reload
			--UnitPopupViewHousesButtonMixin.OnClick = OriginalOnClick;
		end
	end

	EnableModule(true);
end
