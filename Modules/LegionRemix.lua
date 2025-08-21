if not C_RemixArtifactUI then return end;

local _, addon = ...
local L = addon.L;
local API = addon.API;


local type = type;
local ipairs = ipairs;


local C_RemixArtifactUI = C_RemixArtifactUI;
local C_Traits = C_Traits;
local GetConfigIDByTreeID = C_Traits.GetConfigIDByTreeID;
local GetTreeCurrencyInfo = C_Traits.GetTreeCurrencyInfo;
local GetNodeInfo = C_Traits.GetNodeInfo;
local GetNodeCost = C_Traits.GetNodeCost;
local GetEntryInfo = C_Traits.GetEntryInfo;
local GetDefinitionInfo = C_Traits.GetDefinitionInfo;
local CanPurchaseRank = C_Traits.CanPurchaseRank;
local PurchaseRank = C_Traits.PurchaseRank;

local InCombatLockdown = InCombatLockdown;


local DataProvider = {};
local EventListener = CreateFrame("Frame");
local CommitUtil = CreateFrame("Frame");


local CURRENCY_ID_IP = 3268;


local function IsCurrencyEnough(numUnspent, costs)
	return (#costs == 0) or costs[1].amount <= numUnspent
end


do	--DataProvider
	DataProvider.traitNameCache = {};

	local TraitData = {
		--{nodeID, entryID, definitionID}
		{108115, 133498, 138284}, --Remix Time
		{108523, 133999, 138785}, --Momentus's Perseverance
		{108180, 133581, 138367}, --Nostwin's Impatience"
		{108873, 134447, 139218}, --Eternus's Ambition
		{108701, 134247, 139023}, --Moratari's Calculation
		{108870, 134444, 139215}, --Erus's Aggression

		{108700, 134246, 139022}, --Limits Unbound
	};

	local ArtifactTracks = {
		{	--1
			{108114, 133497, 138283}, --Call of the Forest
			{108106, 133489, 138275}, --Souls of the Caw
			{108110, 133493, 138279}, --Highmountain Fortitude
			{108120, 133506, 138292}, --Waking Frenzy
			{108121, 133507, 138293}, --Dreamweaving
		},

		{	--2
			{108113, 133496, 138282}, --Twisted Crusade
			{108702, 134248, 139024}, --Touch of Malice
			{108105, 133488, 138274}, --I Am My Scars!
			{108132, 133525, 138311}, --Call of the Legion
			{108975, 134745, 139513}, --Felspike
		},

		{	--3
			{108111, 133494, 138280}, --Naran's Everdisc
			{108102, 133485, 138271}, --Volatile Magics
			{
				{108103, 133486, 138272}, --Arcane Aegis
				{108103, 133508, 138294}, --Arcane Ward
			},
			{108107, 133490, 138276}, --Temporal Retaliation
			{108118, 133504, 138290}, --Arcane Inspiration
		},

		{	--4
			{108112, 133495, 138281}, --Tempest Wrath
			{108108, 133491, 138277}, --Terror From Below
			{
				{108104, 133487, 138273}, --Storm Surger
				{108104, 135715, 140470}, --Brewing Storm
			},
			{108119, 133505, 138291}, --Thunderstruck
			{108699, 134245, 139021}, --Churning Waters
		},

		{	--5
			{108875, 134449, 139220}, --Vindicator's Judgment
			{109265, 135326, 140093}, --Light's Vengeance
			{109260, 135321, 140088}, --Flight of the Val'kyr
			{109262, 135323, 140090}, --Xe'ra's Embrace
			{109272, 135333, 140100}, --Empyreal Orders
		},
	};

	local IncreasableTraits = {
		{108106, 133489, 138275}, --Souls of the Caw
		{108110, 133493, 138279}, --Highmountain Fortitude
		{108702, 134248, 139024}, --Touch of Malice
		{108105, 133488, 138274}, --I Am My Scars!
		{108132, 133525, 138311}, --Call of the Legion ??
		{108102, 133485, 138271}, --Volatile Magics
		{108103, 133486, 138272}, --Arcane Aegis
		{108103, 133508, 138294}, --Arcane Ward
		{108107, 133490, 138276}, --Temporal Retaliation
		{108108, 133491, 138277}, --Terror From Below
		{108104, 133487, 138273}, --Storm Surger
		{108104, 135715, 140470}, --Brewing Storm
		{109265, 135326, 140093}, --Light's Vengeance
	};

	local ArtifactAbilityNodes = {
		--From top to bottom
		--{nodeID, entryID, definitionID}
		{108114, 133497, 133283},
		{108113, 133496, 138282},
		{108111, 133494, 138280},
		{108112, 133495, 138281},
		{108875, 133449, 139220},
	};

	local FinalTraitNodes = {
		--{nodeID, entryID}
		{108121, 133507},
		{108975, 134745},
		{108118, 133504},
		{108699, 134245},
		{109272, 135333},
	};

	local ChoiceNodes = {
		--Artifact Abilities
		[108114] = true,
		[108113] = true,
		[108111] = true,
		[108112] = true,
		[108875] = true,

		--Arcane Shield
		[108107] = true,
		[108118] = true,
	};

	DataProvider.PurchaseRoute_Basic = {
		--{nodeID, entryID, definitionID}
		--entryID and definitionID can be inferred
		{108115, 133498, 138284},	--Remix Time
		{108182, 133583, 138369},	--Prim +1
		{108181, 133582, 138368},	--STA +9
		{108878, 134454, 139225},	--MAST +4
		{108180, 133581, 138367},	--Nostwin's Impatience

		--Purchase all small nodes, go up first
		{108165, 133564, 138350},	--MAST +8
		{108172, 133571, 138357},	--STA +13
		--Down
		{108260, 133691, 138477},	--MAST +8
		{108166, 133565, 138351},	--STA +13
		--Up
		{108523, 133999, 138785},	--Momentus's Perseverance
		{108874, 134448, 139219},	--Prim +2
		{108869, 134443, 139214},	--Prim +2
		--Down
		{108701, 134247, 139023},	--Moratari's Calculation
		{108251, 133682, 138468},	--MAST +8
		{108873, 134447, 139128},	--Eternus's Ambition
		{108868, 134442, 139213},	--Prim +2
		{108169, 133568, 138354},	--STA +13
		--Up
		{108870, 134444, 139215},	--Erus's Aggression
	};

	local function IsValidNodeInfo(nodeInfo)
		--Enum.TraitNodeType: 3 (SubTreeSelection)
		return (nodeInfo) and (nodeInfo.type ~= 3) and (nodeInfo.isVisible) and (nodeInfo.posY >= 0)
	end

	local function IsValidEntry(entryInfo)
		--Enum.TraitNodeEntryType: 3 (SpendSmallCircle)
		return entryInfo.type ~= 3
	end

	local function Debug_SaveTraitInfo(nodeID, entryID, definitionID, name)
		local line = string.format("{%s, %s, %s}, --%s", nodeID, entryID, definitionID, name);
		table.insert(PlumberDevData.RemixArtifact, line);
	end

	function DataProvider:IsChoiceNode(nodeID)
		return ChoiceNodes[nodeID]
	end

	function DataProvider:GetArtifactNodeInfoByIndex(index)
		local v = ArtifactAbilityNodes[index];
		return v[1], v[2], v[3]
	end

	function DataProvider:GetFinalNodeInfoIndex(index)
		local v = FinalTraitNodes[index];
		return v[1], v[2], v[3]
	end

	function DataProvider:GetNodeInfo(nodeID)
		return GetNodeInfo(self:GetCurrentConfigID(), nodeID)
	end

	function DataProvider:GetCost(nodeID)
		local costs = GetNodeCost(self:GetCurrentConfigID(), nodeID);
		if costs and costs[1] then
			return costs[1].amount
		else
			return 0
		end
	end

	function DataProvider:GetActiveArtifactTrackIndex()
		local artifactTrackIndex;

		for index = 1, #ArtifactAbilityNodes do
			local nodeID, entryID, definitionID = self:GetArtifactNodeInfoByIndex(index);
			local nodeInfo = self:GetNodeInfo(nodeID);
			if nodeInfo and nodeInfo.currentRank > 0 then
				artifactTrackIndex = index;
				break
			end
		end
		self.artifactTrackIndex = artifactTrackIndex;

		return artifactTrackIndex
	end

	function DataProvider:GetParagonLevel()
		local nodeID = 108700;
		local nodeInfo = self:GetNodeInfo(nodeID);
		if nodeInfo then
			return nodeInfo.currentRank
		end
		return 0
	end

	function DataProvider:GetTreeInfo()
		if not PlumberDevData then
			PlumberDevData = {};
		end
		PlumberDevData.RemixArtifact = {};

		local itemID = C_RemixArtifactUI.GetCurrArtifactItemID();
		local traitTreeID = C_RemixArtifactUI.GetCurrTraitTreeID();
		local configID = itemID and traitTreeID and C_Traits.GetConfigIDByTreeID(traitTreeID);
		if configID then
			local configInfo = C_Traits.GetConfigInfo(configID);
			local treeID = configInfo.treeIDs[1];
			local nodeIDs = C_Traits.GetTreeNodes(treeID);
			local n = 0;
			for i, nodeID in ipairs(nodeIDs) do
				local nodeInfo = GetNodeInfo(configID, nodeID);	--nodeInfo.ranksincreased
				if IsValidNodeInfo(nodeInfo) then
					for _, entryID in ipairs(nodeInfo.entryIDs) do
						--local entryID = nodeInfo.activeEntry and nodeInfo.activeEntry.entryID or nodeInfo.entryIDs[1];
						local entryInfo = GetEntryInfo(configID, entryID);
						if IsValidEntry(entryInfo)  then	--nodeInfo.canPurchaseRank or nodeInfo.canRefundRank
							local definitionInfo = GetDefinitionInfo(entryInfo.definitionID);
							local spellID = definitionInfo and definitionInfo.spellID;
							local spellInfo = spellID and C_Spell.GetSpellInfo(spellID);
							if spellInfo then
								local icon = spellInfo.iconID or spellInfo.originalIconID;
								local name = spellInfo.name or spellID;
								local rankText = nodeInfo.currentRank.."/"..nodeInfo.maxRanks;
								local ranksIncreased = nodeInfo.ranksIncreased or 0;
								Debug_SaveTraitInfo(nodeID, entryID, entryInfo.definitionID, name);
								print(string.format("|T%s:16:16|t %s  Rank: %s, EntryID: %s", icon, name, rankText, entryID));
								if ranksIncreased > 0 then
									rankText = rankText..string.format("(+%d)", nodeInfo.ranksIncreased);
									local increasedTraitDataList = C_Traits.GetIncreasedTraitData(nodeID, entryID);
									print(nodeID, entryID);
									for _index, increasedTraitData in ipairs(increasedTraitDataList) do
										local r, g, b = C_Item.GetItemQualityColor(increasedTraitData.itemQualityIncreasing);
										local qualityColor = CreateColor(r, g, b, 1);
										local coloredItemName = qualityColor:WrapTextInColorCode(increasedTraitData.itemNameIncreasing);
										local wrapText = true;
										local numPointsIncreased = increasedTraitData.numPointsIncreased;
										print(numPointsIncreased, coloredItemName);
										--GameTooltip_AddColoredLine(tooltip, TALENT_FRAME_INCREASED_RANKS_TEXT:format(numPointsIncreased, coloredItemName), GREEN_FONT_COLOR, wrapText);
									end
								end
							end
						end
					end
				end
			end
		end
	end

	function DataProvider:GetIncreasedTraits()
		local GetIncreasedTraitData = C_Traits.GetIncreasedTraitData;
		local isLoaded = true;
		for _, v in ipairs(IncreasableTraits) do
			local nodeID, entryID, definitionID = v[1], v[2], v[3];
			local increasedTraitDataList = GetIncreasedTraitData(nodeID, entryID);
			if increasedTraitDataList and #increasedTraitDataList > 0 then
				local definitionInfo = GetDefinitionInfo(definitionID);
				local spellID = definitionInfo and definitionInfo.spellID;
				--local spellInfo = spellID and C_Spell.GetSpellInfo(spellID);
				if spellID then
					if C_Spell.IsSpellDataCached(spellID) then
						local spellInfo = C_Spell.GetSpellInfo(spellID);
						local spellName = spellInfo.name;
						local spellIcon = spellInfo.iconID or spellInfo.originalIconID;
						local totalIncreased = 0;
						for _index, increasedTraitData in ipairs(increasedTraitDataList) do
							local r, g, b = C_Item.GetItemQualityColor(increasedTraitData.itemQualityIncreasing);
							local qualityColor = CreateColor(r, g, b, 1);
							local coloredItemName = qualityColor:WrapTextInColorCode(increasedTraitData.itemNameIncreasing);
							local wrapText = true;
							local numPointsIncreased = increasedTraitData.numPointsIncreased;
							totalIncreased = totalIncreased + numPointsIncreased;
							--print(numPointsIncreased, coloredItemName);
							--GameTooltip_AddColoredLine(tooltip, TALENT_FRAME_INCREASED_RANKS_TEXT:format(numPointsIncreased, coloredItemName), GREEN_FONT_COLOR, wrapText);
						end
						print(string.format("+%d |T%s:16:16|t |cffffd100%s|r", totalIncreased, spellIcon, spellName))
					else
						isLoaded = false;
					end
				end
			end
		end
	end

	function DataProvider:UpdateConfigInfo()
		local traitTreeID = C_RemixArtifactUI.GetCurrTraitTreeID() or 1161;
		local configID = GetConfigIDByTreeID(traitTreeID);
		if not configID then return end;

		self.configID = configID;

		local configInfo = C_Traits.GetConfigInfo(configID);
		local treeID = configInfo.treeIDs[1] or 1161;
		self.treeID = treeID;
	end

	function DataProvider:GetCurrentConfigID()
		if not self.configID then
			self:UpdateConfigInfo();
		end
		return self.configID
	end

	function DataProvider:GetCurrentTreeID()
		if not self.treeID then
			self:UpdateConfigInfo();
		end
		return self.treeID
	end

	function DataProvider:GetNumUnspentPower()
		--local treeID = 1161;	--1162
		local configID = self:GetCurrentConfigID();
		if configID then
			local configInfo = C_Traits.GetConfigInfo(configID);
			local treeID = configInfo.treeIDs[1];
			local excludeStagedChanges = false;
			local treeCurrencyInfo = GetTreeCurrencyInfo(configID, treeID, excludeStagedChanges);
			if treeCurrencyInfo and treeCurrencyInfo[1] then
				return treeCurrencyInfo[1].quantity
			end
		end
		return 0
	end

	function DataProvider:GetPurchasableTrait()
		local itemID = C_RemixArtifactUI.GetCurrArtifactItemID();
		local configID = self.configID;
		if not configID then return end;

		local configInfo = C_Traits.GetConfigInfo(configID);
		local treeID = configInfo.treeIDs[1];
		local nodeIDs = C_Traits.GetTreeNodes(treeID);
		local numUnspent = self:GetNumUnspentPower();
		local needMassPurchase;

		if numUnspent < 125 then return end;

		for i, nodeID in ipairs(nodeIDs) do
			local nodeInfo = GetNodeInfo(configID, nodeID);	--nodeInfo.ranksincreased
			if IsValidNodeInfo(nodeInfo) then
				for _, entryID in ipairs(nodeInfo.entryIDs) do
					if CanPurchaseRank(configID, nodeID, entryID) then	--nodeInfo.canPurchaseRank or nodeInfo.canRefundRank
						if numUnspent >= self:GetCost(nodeID) then
							local isSelectionNode = nodeInfo.type == 2;
							return nodeID, entryID, isSelectionNode, needMassPurchase
						end
					end
				end
			end
		end
	end

	function DataProvider:GetTraitName(entryID)
		if self.traitNameCache[entryID] then
			return self.traitNameCache[entryID]
		end

		if not self.configID then return end;

		local entryInfo = GetEntryInfo(self.configID, entryID);
		local definitionInfo = GetDefinitionInfo(entryInfo.definitionID);
		local spellID = definitionInfo and definitionInfo.spellID;
		local spellInfo = spellID and C_Spell.GetSpellInfo(spellID);
		if spellInfo then
			local icon = spellInfo.iconID or spellInfo.originalIconID;
			local name = spellInfo.name or spellID;
			if name then
				self.traitNameCache[entryID] = name;
				return name
			end
		end
	end

	function DataProvider:GetNextTraitForUpgrade(enoughCurrencyOnly)
		local nodeInfo, nodeID, entryID;

		nodeID = 108700;	--Paragon Node
		nodeInfo = self:GetNodeInfo(nodeID);

		if nodeInfo.canPurchaseRank then
			entryID = nodeInfo.entryIDs[1];
		else
			nodeID = nil;
			nodeInfo = nil;
			local activeTrackIndex = self:GetActiveArtifactTrackIndex();
			if activeTrackIndex then
				local trackData = ArtifactTracks[activeTrackIndex];
				for i = 2, #trackData do
					nodeID = trackData[i][1];
					if type(nodeID) == "table" then
						nodeID = nodeID[1];
					end
					nodeInfo = self:GetNodeInfo(nodeID);
					if nodeInfo.canPurchaseRank then
						entryID = nodeInfo.entryIDs[1];
						break
					end
				end
			else
				for _, v in ipairs(self.PurchaseRoute_Basic) do
					nodeID = v[1];
					nodeInfo = self:GetNodeInfo(nodeID);
					if nodeInfo.canPurchaseRank then
						entryID = nodeInfo.entryIDs[1];
						break
					end
				end
			end
		end

		if entryID then
			local cost = self:GetCost(nodeID);
			if enoughCurrencyOnly and self:GetNumUnspentPower() < cost then
				return
			end
			return {
				nodeID = nodeID,
				entryID = entryID,
				cost = cost,
			};
		end
	end

	YEETRX = function()
		DataProvider:GetPurchasableTrait();
	end

	YEETIC = function()
		DataProvider:GetNumUnspentPower();
	end
end


do
	function EventListener:Enable(state)
		if state then
			--self:RegisterEvent("TRAIT_CONFIG_UPDATED");
			--self:RegisterEvent("TRAIT_TREE_CURRENCY_INFO_UPDATED");
			self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
			self:SetScript("OnEvent", self.OnEvent);
		else
			self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
		end
	end

	function EventListener:OnUpdate(elapsed)
		self.t = self.t + elapsed;
		if self.t > 1.0 then
			self.t = 0;
			self:SetScript("OnUpdate", nil);
			--[[
			local unspent = DataProvider:GetNumUnspentPower();
			if unspent then
				print("Unspent:", unspent);
			end
			--]]
			--local nodeID, entryID = DataProvider:GetPurchasableTrait();
			local traitInfo = DataProvider:GetNextTraitForUpgrade(true);
			if traitInfo then
				local traitName = DataProvider:GetTraitName(traitInfo.entryID);
				print("You can upgrade: "..traitName);
				if (not DataProvider:IsChoiceNode()) and not InCombatLockdown() then
					print("Auto upgrade: "..traitName);
					CommitUtil:TryPurchaseToNode(traitInfo.nodeID);
				end
			end
		end
	end

	function EventListener:RequestUpdate()
		self.t = 0;
		self:SetScript("OnUpdate", self.OnUpdate);
	end

	function EventListener:OnEvent(event, ...)
		--TRAIT_CONFIG_UPDATED fires upon initial login for all artifact including the uncollected ones
		if event == "CURRENCY_DISPLAY_UPDATE" then
			--The value we need changes after TRAIT_TREE_CURRENCY_INFO_UPDATED
			local currencyID = ...
			if currencyID == CURRENCY_ID_IP then
				self:RequestUpdate();
			end
		end
	end
end


do	--CommitUtil
	function CommitUtil:SetCommitStarted(configID)
		self:RegisterEvent("TRAIT_CONFIG_UPDATED");
		self:RegisterEvent("CONFIG_COMMIT_FAILED");
		self:SetScript("OnEvent", self.OnEvent);

		self.commitedConfigID = configID;
		self.commitingResult = nil;
		self.t = 0;
		self:SetScript("OnUpdate", self.OnUpdate_Commit);
		C_Traits.CommitConfig(configID);
	end

	function CommitUtil:OnCommitingFinished()
		self.commitedConfigID = nil;
		self:UnregisterEvent("TRAIT_CONFIG_UPDATED");
		self:UnregisterEvent("CONFIG_COMMIT_FAILED");
		if self.commitingResult == 1 then
			print("COMMIT SUCCEEDED");
		elseif self.commitingResult == 0 then
			print("COMMIT FAILED");
		end
	end

	function CommitUtil:OnEvent(event, ...)
		if event == "TRAIT_CONFIG_UPDATED" then
			local configID = ...
			if configID == self.commitedConfigID then
				self.commitingResult = 1;
			end
		elseif event == "CONFIG_COMMIT_FAILED" then
			local configID = ...
			if configID == self.commitedConfigID then
				self.commitingResult = 0;
			end
		end

		if self.commitingResult then
			self:OnCommitingFinished();
		end
	end

	function CommitUtil:IsCommitingInProcess()
		return self.commitedConfigID ~= nil
	end

	function CommitUtil:OnUpdate_Commit(elapsed)
		self.t = self.t + elapsed;
		if self.t >= 2 then	--maximumCommitTime
			self.t = 0;
			self:SetScript("OnUpdate", nil);
			self.commitedConfigID = nil;
		end
	end

	function CommitUtil:OnUpdate_Purchase(elapsed)
		self.t = self.t + elapsed;
		if self.t > 0.016 then
			self.t = 0;
			self:SetScript("OnUpdate", nil);

			local nodeID, entryID, isSelectionNode, needMassPurchase = DataProvider:GetPurchasableTrait();
			if nodeID then
				print(nodeID, DataProvider:GetTraitName(entryID), isSelectionNode and "Choice" or "");
				local success;
				if needMassPurchase then
					success = C_Traits.TryPurchaseToNode(self.configID, nodeID);
				elseif isSelectionNode then
					success = C_Traits.SetSelection(self.configID, nodeID, entryID);
				else
					success = PurchaseRank(self.configID, nodeID);
				end

				if success then
					self.anySuccessPurchase = true;
					self:SetScript("OnUpdate", self.OnUpdate_Purchase);
					return
				end
			end

			if self.anySuccessPurchase then
				self.anySuccessPurchase = nil;
				self:SetCommitStarted(self.configID);
			end
		end
	end

	function CommitUtil:PurchaseAvailableTraits()
		--Unused
		local configID = DataProvider.configID;
		self.configID = configID;
		self.t = 0;
		self:SetScript("OnUpdate", self.OnUpdate_Purchase);
		local nodeID, entryID = DataProvider:GetFinalNodeInfoIndex(1);	--HasMassPurchase, TryPurchaseToNode
		local name = DataProvider:GetTraitName(entryID);
		local success = C_Traits.TryPurchaseToNode(self.configID, nodeID);
		print("TryPurchaseToNode", name, tostring(success));
		self.anySuccessPurchase = success;
	end

	function CommitUtil:TryPurchaseBasicTraits()
		--Select all traits to the left the Artifact abilities
		local configID = DataProvider:GetCurrentConfigID();
		if not configID then return false end;

		local nodeID, entryID;
		local anySuccessPurchase = false;

		for _, v in ipairs(DataProvider.PurchaseRoute_Basic) do
			nodeID = v[1];
			if PurchaseRank(configID, nodeID) then
				anySuccessPurchase = true;
			end
		end

		self.anySuccessPurchase = anySuccessPurchase;

		return true
	end

	function CommitUtil:TryPurchaseToNode(nodeID)
		if self:IsCommitingInProcess() then
			return
		end

		local configID = DataProvider:GetCurrentConfigID();
		local success = C_Traits.TryPurchaseToNode(configID, nodeID);
		if success then
			self.anySuccessPurchase = true;
		end

		if self.anySuccessPurchase then
			self:SetCommitStarted(configID);
		end
	end

	function CommitUtil:TryPurchaseParagon()
		--Limits Unbound
		if self:IsCommitingInProcess() then
			return
		end

		local configID = DataProvider:GetCurrentConfigID();
		local nodeID, entryID = 108700, 134246;
		while PurchaseRank(configID, nodeID) do
			self.anySuccessPurchase = true;
		end
	end

	function CommitUtil:TryPurchaseArtifactTrack(index)
		if self:IsCommitingInProcess() then
			return
		end

		local configID = DataProvider:GetCurrentConfigID();
		local activeTrackIndex = DataProvider:GetActiveArtifactTrackIndex();
		if activeTrackIndex and (activeTrackIndex ~= index) then
			C_Traits.ResetTree(configID, DataProvider:GetCurrentTreeID());
		end

		self:TryPurchaseBasicTraits();

		local nodeID, entryID, definitionID = DataProvider:GetArtifactNodeInfoByIndex(index);

		if configID then
			local costs = GetNodeCost(configID, nodeID);
			local numUnspent = DataProvider:GetNumUnspentPower();
			if IsCurrencyEnough(numUnspent, costs) then
				nodeID, entryID = DataProvider:GetFinalNodeInfoIndex(index);
				local success = C_Traits.TryPurchaseToNode(configID, nodeID);
				if success then
					self.anySuccessPurchase = true;
				end
			else
				print("Insufficient Infinite Power");
			end
		else
			print("Cannot Purchase", DataProvider:GetTraitName(entryID));
		end

		self:TryPurchaseParagon();

		if self.anySuccessPurchase then
			self:SetCommitStarted(configID);
		end
	end

	YEETPC = function(index)
		index = index or 1;
		CommitUtil:TryPurchaseArtifactTrack(index);
	end
end


do	--Debug
	EventRegistry:RegisterCallback("TalentDisplay.TooltipCreated", function(_, node, tooltip)
		local nodeInfo = node.nodeInfo;
		if nodeInfo then
			tooltip:AddLine(" ");

			local nodeID = nodeInfo.ID;
			tooltip:AddDoubleLine("ID", nodeID);
			for _, entryID in ipairs(nodeInfo.entryIDs) do
				tooltip:AddDoubleLine("entryID", entryID);
			end

			if node.entryInfo then
				tooltip:AddDoubleLine("definitionID", node.entryInfo.definitionID);
			end

			tooltip:AddLine(" ");
			tooltip:AddDoubleLine("canPurchaseRank", tostring(nodeInfo.canPurchaseRank));

			local configID = GetConfigIDByTreeID(1161);
			local costs = GetNodeCost(configID, nodeID);
			if (not costs) or #costs == 0 then
				tooltip:AddLine("No Cost");
			else
				for _, cost in ipairs(costs) do
					tooltip:AddDoubleLine("TraitCurrencyID: "..cost.ID, cost.amount);
				end
			end


			tooltip:AddDoubleLine("posX", nodeInfo.posX);
			tooltip:AddDoubleLine("posY", nodeInfo.posY);
			tooltip:AddDoubleLine("nodeInfo.type", nodeInfo.type);
			tooltip:AddDoubleLine("maxRanks", node.maxRanks or "Nil");
		end
		tooltip:Show();
	end);

end


local CurrencyTooltipModule = {};
do	--GameTooltip Infinite Power
	local GameTooltipCurrencyManager = addon.GameTooltipManager:GetCurrencyManager();


	function CurrencyTooltipModule:ProcessData(tooltip, currencyID)
		if self.enabled then
			if currencyID == CURRENCY_ID_IP then
				local numUnspent = DataProvider:GetNumUnspentPower();
				if numUnspent > 0 then
					local traitInfo = DataProvider:GetNextTraitForUpgrade();
					if traitInfo and traitInfo.cost > 0 then
						local diff = traitInfo.cost - numUnspent;
						tooltip:AddLine(" ");
						if diff > 0 then
							diff = BreakUpLargeNumbers(diff);
							tooltip:AddLine(string.format(L["Earn X To Upgrade Y Format"], diff, API.GetCurrencyName(CURRENCY_ID_IP), L["Artifact Weapon"]), 1, 0.82, 0, true);
						else
							tooltip:AddLine(L["New Trait Available"], 0.098, 1.000, 0.098, true);
						end

						return true
					end
				end
			end
		end
		return false
	end

	function CurrencyTooltipModule:GetDBKey()
		return "LegionRemix"
	end

	function CurrencyTooltipModule:SetEnabled(enabled)
		self.enabled = enabled == true
		GameTooltipCurrencyManager:RequestUpdate();
	end

	function CurrencyTooltipModule:IsEnabled()
		return self.enabled == true
	end

	GameTooltipCurrencyManager:AddSubModule(CurrencyTooltipModule);
end


do	--Module Registry
	local function EnableModule(state)
		if state and not DataProvider.isEnabled then
			DataProvider:UpdateConfigInfo();

		elseif not state and DataProvider.isEnabled then

		else
			return
		end

		EventListener:Enable(state);
		CurrencyTooltipModule:SetEnabled(state);
	end

    local moduleData = {
        name = L["ModuleName LegionRemix"],
        dbKey = "LegionRemix",
        description = L["ModuleDescription LegionRemix"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = -1,
        moduleAddedTime = 1755200000,
		timerunningSeason = 2,
    };

    addon.ControlCenter:AddModule(moduleData);
end


--[[
	ArtifactInfo is only obtainable when player Shift Right Click the weapon and keep the UI open!
	/run SocketInventoryItem(16)
	/dump C_RemixArtifactUI.ItemInSlotIsRemixArtifact(16)

	--HasIncreasedRanks, TalentButtonSpendMixin:AddTooltipInfo
	do
		local increasedTraitDataList = C_Traits.GetIncreasedTraitData(self:GetNodeID(), self:GetEntryID());
		for	_index, increasedTraitData in ipairs(increasedTraitDataList) do
			local r, g, b = C_Item.GetItemQualityColor(increasedTraitData.itemQualityIncreasing);
			local qualityColor = CreateColor(r, g, b, 1);
			local coloredItemName = qualityColor:WrapTextInColorCode(increasedTraitData.itemNameIncreasing);
			local wrapText = true;
			GameTooltip_AddColoredLine(tooltip, TALENT_FRAME_INCREASED_RANKS_TEXT:format(increasedTraitData.numPointsIncreased, coloredItemName), GREEN_FONT_COLOR, wrapText);
		end	
	end

	C_Traits.GetTreeCurrencyInfo(configID, treeID, excludeStagedChanges)
	/dump C_Traits.GetConfigIDByTreeID(1161)	--	TraitSystemID: 31
--]]