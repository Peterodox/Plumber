local _, addon = ...
local API = addon.API;


local Def = {
	Art = "Interface/AddOns/Plumber/Art/Frame/TraitSystem.png",
	ButtonSize = 40,
	ButtonGap = 10,
};


local CommitUtil = CreateFrame("Frame");


local NodeButtonMixin = {};
do
	function NodeButtonMixin:OnLoad()
		self.Border:SetTexture(Def.Art);
		self.GreenGlow:SetTexture(Def.Art);
		self.Sheen:SetTexture(Def.Art);
		self:SetSquare();
		self.Icon:SetTexCoord(4/64, 60/64, 4/64, 60/64);
		self.Border:SetSize(64, 64);
		self.Icon:SetSize(36, 36);
		self.IconMask:SetSize(36, 36);
		self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		self:SetScript("OnEnter", self.OnEnter);
		self:SetScript("OnLeave", self.OnLeave);
		self:SetScript("OnDragStart", self.OnDragStart);
		self:SetScript("OnClick", self.OnClick);


		local function AnimSheen_OnPlay()
			self.SheenMask:Show();
			self.Sheen:Show();
		end

		local function AnimSheen_OnStop()
			self.SheenMask:Hide();
			self.Sheen:Hide();
		end

		self.AnimSheen:SetScript("OnPlay", AnimSheen_OnPlay);
		self.AnimSheen:SetScript("OnFinished", AnimSheen_OnStop);
		self.AnimSheen:SetScript("OnStop", AnimSheen_OnStop);
	end

	function NodeButtonMixin:OnEnter()
		self.ownerFrame:HoverNode(self);
	end

	function NodeButtonMixin:OnLeave()
		self.ownerFrame:HoverNode();
		if self.entryIDs or self.isFlyoutButton then
			if not self.ownerFrame:IsNodeFlyoutFocused(self) then
				self.ownerFrame:CloseNodeFlyout();
			end
		end
	end

	function NodeButtonMixin:OnDragStart()

	end

	function NodeButtonMixin:OnFocused()
		if self.entryIDs then
			self.ownerFrame:ShowNodeFlyout(self);
		else
			self:ShowTooltip();
		end
	end

	function NodeButtonMixin:SetSpell(spellID)
		local iconID, originalIconID = C_Spell.GetSpellTexture(spellID);
		self.Icon:SetTexture(originalIconID or iconID);
		self.spellID = spellID;
	end

	function NodeButtonMixin:SetNode(nodeID)
		self.nodeID = nodeID;
		self.isNodeDirty = true;
	end

	function NodeButtonMixin:SetEntry(entryID)
		self.entryID = entryID;
		local entryInfo = self.ownerFrame:GetEntryInfo(entryID);
		self.definitionID = entryInfo.definitionID;
		self.maxRanks = entryInfo.maxRanks;

		if self.entryType ~= 0 then
			if entryInfo.type == 1 then --SpendSquare
				self:SetSquare();
			elseif entryInfo.type == 2 then --SpendCircle
				self:SetCircle();
			end
		end

		local spellID = C_Traits.GetDefinitionInfo(self.definitionID).spellID;
		self:SetSpell(spellID);
	end

	function NodeButtonMixin:SetSquare()
		self.entryType = 1;
		self.IconMask:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Chamfer", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
		self.Icon:Show();
		self.IconMask:Show();
		self.GreenGlow:SetTexCoord(384/1024, 544/1024, 0/1024, 160/1024);
	end

	function NodeButtonMixin:SetCircle()
		self.entryType = 2;
		self.IconMask:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Circle", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
		self.Icon:Show();
		self.IconMask:Show();
		self.GreenGlow:SetTexCoord(544/1024, 704/1024, 0/1024, 160/1024);
	end

	function NodeButtonMixin:SetHex()
		self.entryType = 0;
		self.IconMask:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Hexagon", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
		self.Icon:Show();
		self.IconMask:Show();
		self.GreenGlow:SetTexCoord(704/1024, 864/1024, 0/1024, 160/1024);
		self.Sheen:SetTexCoord(768/1024, 928/1024, 576/1024, 736/1024);
		self.SheenMask:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/Mask-Halo", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
	end

	function NodeButtonMixin:SetVisualState(visualState)
		--0:Disabled  1:Yellow  2:Green

		self.visualState = visualState;
		local disabled = visualState == 0;

		if disabled then
			self.Icon:SetDesaturated(true);
			self.Icon:SetVertexColor(0.8, 0.8, 0.8);
			self.GreenGlow:Hide();
		else
			self.Icon:SetDesaturated(false);
			self.Icon:SetVertexColor(1, 1, 1);
		end

		local left, right, top, bottom;

		if disabled then
			top, bottom = 256, 384;
		elseif visualState == 2 then
			top, bottom = 128, 256;
		else
			top, bottom = 0, 128;
		end

		if self.entryType == 1 then
			left, right = 0, 128;
		elseif self.entryType == 2 then
			left, right = 128, 256;
		elseif self.entryType == 0 then
			left, right = 256, 384;
		end

		self.Border:SetTexCoord(left/1024, right/1024, top/1024, bottom/1024);
	end

	function NodeButtonMixin:CanAfford()
		return self.ownerFrame:CanAffordNode(self.nodeID);
	end

	function NodeButtonMixin:CanPurchaseRank()
		if self.nodeInfo then
			if self.nodeInfo.canPurchaseRank and self:CanAfford() then
				return true;
			elseif #self.nodeInfo.entryIDs > 1 and self.nodeInfo.entryIDsWithCommittedRanks[1] then
				return true;
			end
		end
		return false;
	end

	function NodeButtonMixin:CanRefundRank()
		return self.nodeInfo and self.nodeInfo.canRefundRank;
	end

	function NodeButtonMixin:IsSelectionNode()
		if not self.nodeInfo then
			self.nodeInfo = self.ownerFrame:GetNodeInfo(self.nodeID);
		end
		return self.nodeInfo and self.nodeInfo.type == 2;
	end

	function NodeButtonMixin:Refresh(playAnimation)
		local nodeInfo = self.nodeID and self.ownerFrame:GetNodeInfo(self.nodeID);
		self.nodeInfo = nodeInfo;
		if not nodeInfo then return; end

		if self.isNodeDirty then
			self.isNodeDirty = nil;
			local entryID;

			if self.isFlyoutButton and self.entryChoiceIndex then
				entryID = nodeInfo.entryIDs[self.entryChoiceIndex];
			end

			if (not entryID) and nodeInfo.entryIDsWithCommittedRanks then
				entryID = nodeInfo.entryIDsWithCommittedRanks[1];
			end

			if not entryID then
				entryID = nodeInfo.entryIDs[1];
			end

			self.entryID = entryID;

			if nodeInfo.type == 2 and (not self.isFlyoutButton) then  --Enum.TraitNodeType.Selection
				self:SetHex();
				self.entryIDs = nodeInfo.entryIDs;
			else
				self.entryIDs = nil;
			end

			local entryInfo = self.ownerFrame:GetEntryInfo(entryID);
			self.definitionID = entryInfo.definitionID;
			self.maxRanks = entryInfo.maxRanks;

			if self.entryType ~= 0 then
				if entryInfo.type == 1 then --SpendSquare
					self:SetSquare();
				elseif entryInfo.type == 2 then --SpendCircle
					self:SetCircle();
				end
			end

			local spellID = C_Traits.GetDefinitionInfo(self.definitionID).spellID;
			self:SetSpell(spellID);
		end

		if self.entryIDs then
			self:Refresh_SelectionNode(nodeInfo, playAnimation);
			return
		end

		if self.isFlyoutButton then
			self:Refresh_FlyoutButton(nodeInfo, playAnimation);
			return
		end

		local currentRank = nodeInfo.currentRank or 0;
		local ranksPurchased = nodeInfo.ranksPurchased or 0;

		local isActive = ranksPurchased > 0;
		self.isActive = isActive;

		local visualState;
		local rankText;
		local useGreenGlow = false;

		if self:CanPurchaseRank() then
			visualState = 2;
			useGreenGlow = true;
		elseif not (isActive or currentRank > 0) then
			visualState = 0;
		else
			if self.entryType == 0 then
				if self.selectedEntryID then
					visualState = 1;
				else
					visualState = 2;
				end
			else
				visualState = 1;
			end
		end

		if isActive or currentRank > 0 then
			if self.entryType == 1 then
				rankText = currentRank;
			elseif self.entryType == 2 then
				rankText = currentRank;
			elseif self.entryType == 0 then
				if not self.selectedEntryID then
					useGreenGlow = true;
				end
			end
			self.RankText:SetTextColor(1, 0.82, 0);
		end

		self:SetVisualState(visualState);
		self.RankText:SetText(rankText);
		self.GreenGlow:SetShown(useGreenGlow);
	end

	function NodeButtonMixin:Refresh_SelectionNode(nodeInfo, playAnimation)
		local currentRank = nodeInfo.currentRank or 0;
		local activeEntryID;
		local committedEntryID;
		local rankText;

		local isEntryCommitted = false;
		if nodeInfo.entryIDsWithCommittedRanks then
			local id = nodeInfo.entryIDsWithCommittedRanks[1];
			committedEntryID = id;
			activeEntryID = id;
			isEntryCommitted = id and true;
		end

		if not isEntryCommitted then
			if nodeInfo.entryIDToRanksIncreased then
				for _entryID, totalIncreased in pairs(nodeInfo.entryIDToRanksIncreased) do
					if totalIncreased > 0 then
						activeEntryID = _entryID;
						currentRank = totalIncreased;
						break
					end
				end
			end
		end

		self.selectedEntryID = committedEntryID;

		local entryChanged;
		local visualState;
		local useGreenGlow = false;

		if isEntryCommitted then
			entryChanged = activeEntryID ~= self.entryID;
			self:SetEntry(activeEntryID);
			visualState = 1;
			rankText = currentRank;
			self.RankText:SetTextColor(1, 0.82, 0);
			if self.shouldPlaySheen then
				self.shouldPlaySheen = nil;
				self:PlaySheen();
			end
		else
			entryChanged = activeEntryID ~= self.selectedEntryID;
			self:SetEntry(self.selectedEntryID or activeEntryID or nodeInfo.entryIDs[1]);
			if self:CanPurchaseRank() then
				visualState = 2;
				useGreenGlow = true;
			else
				visualState = 0;
			end
		end

		if visualState ~= 0 and entryChanged then
			if self.shouldPlaySheen then
				self.shouldPlaySheen = nil;
				if playAnimation then
					self:PlaySheen();
				end
			end
		end

		self:SetVisualState(visualState);
		self.RankText:SetText(rankText);
		self.GreenGlow:SetShown(useGreenGlow);
	end

	function NodeButtonMixin:Refresh_FlyoutButton(nodeInfo, playAnimation)
		local currentRank = nodeInfo.currentRank or 0;
		local ranksPurchased = nodeInfo.ranksPurchased or 0;
		local increasedRanks = 0;

		if nodeInfo.entryIDToRanksIncreased then
			for _entryID, totalIncreased in pairs(nodeInfo.entryIDToRanksIncreased) do
				if _entryID == self.entryID then
					if currentRank == 0 then
						currentRank = totalIncreased;
					end
					increasedRanks = totalIncreased;
					break
				end
			end
		end

		local committedEntryID;
		if nodeInfo.entryIDsWithCommittedRanks then
			for _, id in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
				committedEntryID = id;
				if committedEntryID then
					break
				end
			end
		end

		local rankText;
		local visualState;
		local isSelectable = committedEntryID or self:CanPurchaseRank();

		if isSelectable then
			if self.entryID == committedEntryID then
				visualState = 1;
				rankText = currentRank;
			else
				visualState = 2;
				rankText = increasedRanks;
			end
		else
			if currentRank > 0 then
				visualState = 1;
				rankText = currentRank;
			else
				visualState = 0;
				rankText = "";
			end
		end

		self:SetVisualState(visualState);
		self.RankText:SetText(rankText);

		if visualState == 1 then
			self.RankText:SetTextColor(1, 0.82, 0);
		elseif visualState == 2 then
			self.RankText:SetTextColor(0.098, 1.000, 0.098);
		end
	end

	local function AddLine(oldText, newText)
		if oldText then
			return oldText.."\n"..newText
		else
			return newText
		end
	end

	function NodeButtonMixin:ShowTooltip()
		local name = C_Spell.GetSpellName(self.spellID);
		if not name then
			name = RETRIEVING_DATA;
		end

		local nodeInfo = self.ownerFrame:GetNodeInfo(self.nodeID);
		local currentRank = nodeInfo.currentRank or 0;
		local ranksPurchased = nodeInfo.ranksPurchased or 0;

		--Bonus Ranks
		local increasedRanks = nodeInfo.entryIDToRanksIncreased and nodeInfo.entryIDToRanksIncreased[self.entryID] or 0;
		if self.isFlyoutButton then
			if nodeInfo.entryIDsWithCommittedRanks then
				for _, _entryID in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
					if _entryID == self.entryID then
						increasedRanks = nodeInfo.ranksIncreased or 0;
					else
						ranksPurchased = 0;
					end
				end
			end
		else
			increasedRanks = nodeInfo.ranksIncreased or 0;
		end

		local description;
		description = string.format(TALENT_BUTTON_TOOLTIP_RANK_FORMAT, ranksPurchased, nodeInfo.maxRanks);

		if increasedRanks > 0 then
			description = description.." |cff19ff19+"..increasedRanks.."|r";
		end

		local activeEntryID = self.entryID;
		description = AddLine(description, " ");
		description = API.ConvertTooltipInfoToOneString(description, "GetTraitEntry", activeEntryID, currentRank);

		local nextEntryInfo = nodeInfo.nextEntry;  --(self.maxRanks and self.maxRanks > 1) and self.entryType ~= 1 and self.entryID; --self.nodeInfo.nextEntry;  --debug
		if nextEntryInfo and currentRank > 0 then
			description = AddLine(description, " ");
			description = AddLine(description, TALENT_BUTTON_TOOLTIP_NEXT_RANK);
			local nextRank = currentRank + 1;
			description = API.ConvertTooltipInfoToOneString(description, "GetTraitEntry", nextEntryInfo.entryID, nextRank);
		end

		if self.isFlyoutButton then

		end

		local tooltip = GameTooltip;
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		tooltip:SetText(name, 1, 1, 1);
		tooltip:AddLine(description, 1, 1, 1, true);

		local instructionText, r, g, b;

		if self:CanPurchaseRank() then
			r, g, b = 0.098, 1.000, 0.098;
			instructionText = TALENT_BUTTON_TOOLTIP_PURCHASE_INSTRUCTIONS;
		elseif self:CanRefundRank() then
			r, g, b = 0.502, 0.502, 0.502;
			instructionText = TALENT_BUTTON_TOOLTIP_REFUND_INSTRUCTIONS;
		end

		if instructionText then
			tooltip:AddLine(" ");
			if InCombatLockdown() then
				instructionText = addon.L["Error Change Trait In Combat"];
				r, g, b = 1.000, 0.125, 0.125;
			end
			tooltip:AddLine(instructionText, r, g, b, true);
		end

		tooltip:Show();

		self.UpdateTooltip = self.ShowTooltip;
	end

	function NodeButtonMixin:PlaySheen()
		self.AnimSheen:Stop();
		self.AnimSheen:Play();
	end

	function NodeButtonMixin:OnClick(button)
		if InCombatLockdown() then return; end

		if button == "RightButton" then
			if self:CanRefundRank() then
				self.ownerFrame:TryRefundRank(self.nodeID);
			end
		else
			if self:CanPurchaseRank() then
				if self.isFlyoutButton then
					self.ownerFrame:TryPurchaseSelectionNodeByIndex(self.nodeID, self.entryChoiceIndex);
					self.ownerFrame:CloseNodeFlyout();
				elseif self:IsSelectionNode() and false then
					self.ownerFrame:TryPurchaseSelectionNodeByIndex(self.nodeID);
				else
					self.ownerFrame:TryPurchaseRank(self.nodeID);
				end
			end
		end
	end
end


local TraitContainerMixin = {};
do
	function TraitContainerMixin:Init()
		if self.nodeButtonPool then return; end

		local function createObjectFunc()
			local obj = CreateFrame("Button", nil, self, "PlumberTraitNodeButtonTemplate");
			Mixin(obj, NodeButtonMixin);
			obj.ownerFrame = self;
			obj:OnLoad();
			return obj;
		end

		self.nodeButtonPool = API.CreateObjectPool(createObjectFunc);

		local highlight = CreateFrame("Frame", nil, self);
		self.SharedNodeHighlight = highlight;
		highlight:Hide();
		highlight:SetUsingParentLevel(true);
		highlight.Texture = highlight:CreateTexture(nil, "OVERLAY");
		API.DisableSharpening(highlight.Texture);
		highlight.Texture:SetAllPoints(true);
		highlight.Texture:SetTexture(Def.Art);
		highlight.Texture:SetBlendMode("ADD");
	end

	function TraitContainerMixin:SetConfigIDBySystemID(systemID)
		local configID = C_Traits.GetConfigIDBySystemID(systemID);
		self:SetConfigID(configID);
	end

	function TraitContainerMixin:SetConfigID(configID)
		local configInfo = configID and C_Traits.GetConfigInfo(configID) or nil;
		if not configInfo then return; end
		self.configID = configID;

		self.treeID = configInfo.treeIDs[1];
		if not self.treeID then return; end

		local treeNodes = C_Traits.GetTreeNodes(self.treeID);

		local nodeIDs = {};
		local nodePos = {};
		local n = 0;

		for _, nodeID in ipairs(treeNodes) do
			local nodeInfo = self:GetNodeInfo(nodeID);
			if nodeInfo then
				nodePos[nodeID] = {nodeInfo.posX, nodeInfo.posY};
				n = n + 1;
				nodeIDs[n] = nodeID;
			end
		end

		local function SortFunc(a, b)
			-- Currently sort by posY, displays vertical layout horizontally
			if nodePos[a][2] ~= nodePos[b][2] then
				return nodePos[a][2] < nodePos[b][2];
			end

			if nodePos[a][1] ~= nodePos[b][1] then
				return nodePos[a][1] < nodePos[b][1];
			end

			return a < b
		end

		table.sort(nodeIDs, SortFunc);

		self:LoadNodeIDs(nodeIDs);
	end

	function TraitContainerMixin:LoadNodeIDs(nodeIDs)
		self:Init();
		self.nodeButtonPool:ReleaseAll();
		local offsetX = 0;

		for _, nodeID in ipairs(nodeIDs) do
			local nodeButton = self.nodeButtonPool:Acquire();
			nodeButton:SetPoint("LEFT", self, "LEFT", offsetX, 0);
			nodeButton:SetNode(nodeID);
			offsetX = offsetX + Def.ButtonSize + Def.ButtonGap;
		end

		local totalWidth = math.max(Def.ButtonSize, offsetX - Def.ButtonGap);
		self:SetWidth(totalWidth);

		self:Refresh();
	end

	function TraitContainerMixin:Refresh()
		if self.nodeButtonPool then
			for _, nodeButton in self.nodeButtonPool:EnumerateActive() do
				nodeButton:Refresh();
			end
			self:UpdateNodeFlyoutFrame();
		end
	end

	function TraitContainerMixin:HoverNode(nodeButton)
		local f = self.SharedNodeHighlight;
		f:Hide();
		f:ClearAllPoints();
		GameTooltip:Hide();

		if nodeButton then
			f:SetParent(nodeButton);
			f:SetPoint("TOPLEFT", nodeButton.Border, "TOPLEFT", 0, 0);
			f:SetPoint("BOTTOMRIGHT", nodeButton.Border, "BOTTOMRIGHT", 0, 0);
			if nodeButton.entryType == 1 then
				f.Texture:SetTexCoord(0/1024, 128/1024, 384/1024, 512/1024);
			elseif nodeButton.entryType == 2 then
				f.Texture:SetTexCoord(128/1024, 256/1024, 384/1024, 512/1024);
			elseif nodeButton.entryType == 0 then
				f.Texture:SetTexCoord(256/1024, 384/1024, 384/1024, 512/1024);
			end
			f:SetAlpha(1);
			f:Show();

			nodeButton:OnFocused();
		end
	end

	function TraitContainerMixin:GetNodeInfo(nodeID)
		if self.configID then
			return C_Traits.GetNodeInfo(self.configID, nodeID);
		end
	end

	function TraitContainerMixin:GetEntryInfo(entryID)
		if self.configID then
			return C_Traits.GetEntryInfo(self.configID, entryID);
		end
	end

	function TraitContainerMixin:CanAffordNode(nodeID)
		if self.configID and self.treeID and nodeID then
			local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(self.configID, self.treeID, false);
			local costs = C_Traits.GetNodeCost(self.configID, nodeID);
			local idToCost = {};
			if costs and treeCurrencyInfo then
				for _, cost in ipairs(costs) do
					idToCost[cost.ID] = cost.amount;
				end
			else
				return true;
			end

			local idToAmount = {};
			for _, info in ipairs(treeCurrencyInfo) do
				idToAmount[info.traitCurrencyID] = info.quantity;
			end

			for id, required in pairs(idToCost) do
				if (not idToAmount[id]) or (idToAmount[id] < required) then
					return false;
				end
			end

			return true;
		end
	end

	function TraitContainerMixin:TryPurchaseRank(nodeID)
		if self.configID and nodeID then
			CommitUtil:TryPurchaseRank(self.configID, nodeID, self.shouldAutoCommit);
		end
	end

	function TraitContainerMixin:TryPurchaseSelectionNodeByIndex(nodeID, entryChoiceIndex)
		if self.configID and nodeID then
			local entryID;

			local nodeInfo = C_Traits.GetNodeInfo(self.configID, nodeID);
			if nodeInfo and nodeInfo.entryIDs then
				entryID = entryChoiceIndex and nodeInfo.entryIDs[entryChoiceIndex] or nodeInfo.entryIDs[1];
			end

			if entryID then
				CommitUtil:TryPurchaseSelectionNode(self.configID, nodeID, entryID, self.shouldAutoCommit);
			end
		end
	end

	function TraitContainerMixin:TryRefundRank(nodeID)
		if self.configID and nodeID then
			CommitUtil:TryRefundRank(self.configID, nodeID, self.shouldAutoCommit);
		end
	end

	function TraitContainerMixin:SetEnableAutoCommit(shouldAutoCommit)
		self.shouldAutoCommit = shouldAutoCommit;
	end

	function TraitContainerMixin:CloseNodeFlyout()
		if self.NodeFlyoutFrame then
			self.NodeFlyoutFrame:Hide();
		end
	end

	function TraitContainerMixin:IsNodeFlyoutFocused(nodeButton)
		if self.NodeFlyoutFrame then
			if not self.NodeFlyoutFrame:IsVisible() then return end;
			if self.NodeFlyoutFrame:IsMouseOver() then
				return true;
			end

			if self.NodeFlyoutFrame.owner:IsMouseOver() then
				return true;
			end

			if nodeButton then
				if self.NodeFlyoutFrame.owner ~= nodeButton then
					return false;
				end
			end

			for _, button in ipairs(self.flyoutButtonPool:GetActiveObjects()) do
				if button:IsMouseMotionFocus() then
					return true;
				end
			end
		end
	end

	function TraitContainerMixin:UpdateNodeFlyoutFrame()
		if self.NodeFlyoutFrame and self.NodeFlyoutFrame:IsVisible() then
			for _, button in ipairs(self.flyoutButtonPool:GetActiveObjects()) do
				button:Refresh();
			end
		end
	end

	function TraitContainerMixin:ShowNodeFlyout(nodeButton)
		if not nodeButton.entryIDs then return; end

		local f = self.NodeFlyoutFrame;
		if not f then
			f = CreateFrame("Frame", nil, self);
			self.NodeFlyoutFrame = f;
			f:EnableMouse(true);
			f:EnableMouseMotion(true);
			f:SetSize(80, 80);
			f:SetAttribute("nodeignoremime", true);
			f:SetScript("OnLeave", function()
				if not(f:IsMouseOver() or (f.owner and f.owner:IsVisible() and f.owner:IsMouseOver())) then
					self:CloseNodeFlyout();
				end
			end);

			local function FlyoutButton_Create()
				local obj = CreateFrame("Button", nil, f, "PlumberTraitNodeButtonTemplate");
				Mixin(obj, NodeButtonMixin);
				obj.ownerFrame = self;
				obj.isFlyoutButton = true;
				obj:OnLoad();
				local shadow = obj:CreateTexture(nil, "BACKGROUND");
				shadow:SetPoint("CENTER", obj, "CENTER", 0, -8);
				shadow:SetSize(128, 128);
				shadow:SetTexture(Def.Art);
				shadow:SetTexCoord(384/1024, 480/1024, 160/1024, 256/1024);
				return obj
			end
			self.flyoutButtonPool = API.CreateObjectPool(FlyoutButton_Create);
		end

		if f:IsVisible() and f.owner == nodeButton then
			return;
		end

		f:ClearAllPoints();
		self.flyoutButtonPool:Release();

		local buttonSize = Def.ButtonSize;
		local gapH = 4;
		local offsetX = 0;
		local nodeID = nodeButton.nodeID;

		for i, entryID in ipairs(nodeButton.entryIDs) do
			local button = self.flyoutButtonPool:Acquire();
			button.entryChoiceIndex = i;
			button.parentNodeButton = nodeButton;
			button:SetPoint("TOPLEFT", f, "TOPLEFT", offsetX, 0);
			button:SetNode(nodeID);
			button:Refresh();
			button:SetFrameStrata("DIALOG");
			offsetX = offsetX + buttonSize + gapH;
		end

		local totalWidth = offsetX - gapH;
		local bottomPadding = 6;
		f:SetSize(totalWidth, buttonSize + bottomPadding);
		f:SetPoint("BOTTOM", nodeButton, "TOP", 0, -4 -bottomPadding);
		f:SetFrameStrata("DIALOG");
		f.owner = nodeButton;

		local function FlyoutFrame_OnUpdate(_self, elapsed)
			_self.t = _self.t + elapsed;
			local alpha = _self.t * 8;
			if alpha > 1 then
				alpha = 1;
				_self:SetScript("OnUpdate", nil);
			end
			_self:SetAlpha(alpha);
		end

		f:Show();

		f:SetScale(1.6);
		f:SetAlpha(1);
		f.t = 0;
		f:SetScript("OnUpdate", FlyoutFrame_OnUpdate);
	end
end


do
	function CommitUtil:IsCommittingInProcess()
		return self.committingConfigID ~= nil;
	end

	function CommitUtil:StartCommitting(configID)
		if (not configID) and (InCombatLockdown() or self:IsCommittingInProcess()) then
			return;
		end

		self.committingConfigID = configID;
		self.t = 0;
		self:SetScript("OnUpdate", self.OnUpdate_Committing);
		self:SetScript("OnEvent", self.OnEvent);
		self:RegisterEvent("TRAIT_CONFIG_UPDATED");
		self:RegisterEvent("CONFIG_COMMIT_FAILED");

		C_Traits.CommitConfig(configID);
	end

	function CommitUtil:OnCommitFinished()
		local configID = self.committingConfigID;
		self.committingConfigID = nil;
		self:SetScript("OnUpdate", nil);
		self:UnregisterEvent("TRAIT_CONFIG_UPDATED");
		self:UnregisterEvent("CONFIG_COMMIT_FAILED");
		if self.commitResult == 1 then
			--addon.CallbackRegistry:Trigger("TraitSystem.CommitSucceeded", configID);
		elseif self.commitResult == 0 then
			--addon.CallbackRegistry:Trigger("TraitSystem.CommitFailed", configID);
		end
		self.commitResult = nil;
	end

	function CommitUtil:OnUpdate_Committing(elapsed)
		self.t = self.t + elapsed;
		if self.t >= 1 then
			self.t = 0;
			self:SetScript("OnUpdate", nil);
			self.committingConfigID = nil;
		end
	end

	function CommitUtil:OnEvent(event, ...)
		if event == "TRAIT_CONFIG_UPDATED" then
			local configID = ...
			if configID == self.committingConfigID then
				self.commitResult = 1;
			end
		elseif event == "CONFIG_COMMIT_FAILED" then
			local configID = ...
			if configID == self.committingConfigID then
				self.commitResult = 0;
			end
		end

		if self.commitResult then
			self:OnCommitFinished();
		end
	end

	function CommitUtil:TryPurchaseRank(configID, nodeID, autoCommit)
		if self:IsCommittingInProcess() then
			return;
		end

		local success = C_Traits.PurchaseRank(configID, nodeID);
		if success and autoCommit then
			self:StartCommitting(configID);
		end
		return success;
	end

	function CommitUtil:TryPurchaseSelectionNode(configID, nodeID, entryID, autoCommit)
		if self:IsCommittingInProcess() then
			return;
		end

		local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID);
		if nodeInfo then
			local isNewEntryIDValid;

			if nodeInfo.entryIDs then
				for _, _entryID in ipairs(nodeInfo.entryIDs) do
					if _entryID == entryID then
						isNewEntryIDValid = true;
						break
					end
				end
			end

			if not isNewEntryIDValid then return end;

			local canChangeEntry = true;

			if nodeInfo.entryIDsWithCommittedRanks then
				for _, committedEntryID in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
					if committedEntryID == entryID then
						canChangeEntry = false;
						break
					end
				end
			end

			if canChangeEntry then
				local success = C_Traits.SetSelection(configID, nodeID, entryID);
				if success and autoCommit then
					self:StartCommitting(configID);
				end
				return success;
			end
		end
	end

	function CommitUtil:TryRefundRank(configID, nodeID, autoCommit)
		if self:IsCommittingInProcess() then
			return;
		end

		local success = C_Traits.RefundRank(configID, nodeID);
		if success and autoCommit then
			self:StartCommitting(configID);
		end
		return success;
	end
end


function addon.CreateTraitContainer(parent)
	local f = CreateFrame("Frame", nil, parent);
	f:SetSize(Def.ButtonSize, Def.ButtonSize);
	Mixin(f, TraitContainerMixin);
	return f
end
