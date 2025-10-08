if not C_RemixArtifactUI then return end;

local _, addon = ...
local L = addon.L;
local API = addon.API;
local CallbackRegistry = addon.CallbackRegistry;


local RemixAPI = {};
addon.RemixAPI = RemixAPI;


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
local GetConfigInfo = C_Traits.GetConfigInfo;
local GetIncreasedTraitData = C_Traits.GetIncreasedTraitData;


local GetInventoryItemID = GetInventoryItemID;
local InCombatLockdown = InCombatLockdown;


local DataProvider = {};
local EventListener = CreateFrame("Frame");
local CommitUtil = CreateFrame("Frame");
local MASTER_ENABLED = false;


RemixAPI.DataProvider = DataProvider;
RemixAPI.CommitUtil = CommitUtil;


local CURRENCY_ID_IP = 3268;	--Infinite Knowledge: 3292
--traitSystemID = 33	--C_Traits.GetConfigIDBySystemID


local function IsCurrencyEnough(numUnspent, costs)
	return (#costs == 0) or costs[1].amount <= numUnspent
end

local function UnequipInventorySlot(slotID)
	--Test, Debug
	if InCombatLockdown() then return end;

	local action = EquipmentManager_UnequipItemInSlot(slotID)
	if action then
		EquipmentManager_RunAction(action)
	end
end


do	--DataProvider
	DataProvider.traitNameCache = {};
	DataProvider.traitSpellCache = {};

	DataProvider.ArtifactTracks = {
		--[index] = {majorNodeID1, majorNodeID2, ...}

		{	--1
			108114, --Call of the Forest
			108106, --Souls of the Caw
			108110, --Highmountain Fortitude
			108120, --Waking Frenzy
			108121, --Dreamweaving
		},

		{	--2
			108113, --Twisted Crusade
			108702, --Touch of Malice
			108105, --I Am My Scars!
			108132, --Call of the Legion
			108975, --Felspike
		},

		{	--3
			108111, --Naran's Everdisc
			108102, --Volatile Magics
			108103, --[Selection] Arcane Aegis / Arcane Ward
			108107, --Temporal Retaliation
			108118, --Arcane Inspiration
		},

		{	--4
			108112, --Tempest Wrath
			108108, --Terror From Below
			108104, --[Selection] Storm Surger / Brewing Storm
			108119, --Thunderstruck
			108699, --Churning Waters
		},

		{	--5
			108875, --Vindicator's Judgment
			109265, --Light's Vengeance
			109260, --Flight of the Val'kyr
			109262, --Xe'ra's Embrace
			109272, --Empyreal Orders
		},
	};

	DataProvider.IncreasableTraits = {
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

	DataProvider.ArtifactAbilitySpells = {
		1233577,
		1237711,
		1233775,
		1233181,
		1251045,
	};

	DataProvider.ChoiceNodes = {
		--Artifact Abilities
		[108114] = true,
		[108113] = true,
		[108111] = true,
		[108112] = true,
		[108875] = true,

		--Arcane Shield, Storm
		[108103] = true,
		[108104] = true,
	};

	DataProvider.ForbiddenNodes = {
		--11.2.5.62687 Bug: If a choice node has rank bonus from equipment, then it cannot be unleaned (cannot Apply Changes)
		[3] = {
			{108103, 133486, 138272}, --Arcane Aegis
			{108103, 133508, 138294}, --Arcane Ward
		},
		[4] = {
			{108104, 133487, 138273}, --Storm Surger
			{108104, 135715, 140470}, --Brewing Storm
		},
	};

	DataProvider.PurchaseRoute_Basic = {
		--{nodeID, entryID, definitionID}
		--entryID and definitionID can be inferred
		108115, --Remix Time
		108182, --Prim +1
		108181, --STA +9
		108878, --SPD +4
		108180, --Nostwin's Impatience

		--Purchase all small nodes, go up first
		108165, --SPD +8
		108172, --STA +13
		--Down
		108260, --SPD +8
		108166, --STA +13
		--Up
		108523, --Momentus's Perseverance
		108874, --Prim +2
		108869, --Prim +2
		--Down
		108701, --Moratari's Calculation
		108251, --SPD +8
		108873, --Eternus's Ambition
		108868, --Prim +2
		108169, --STA +13
		--Up
		108870, --Erus's Aggression
	};

	DataProvider.JewelrySlots = {
		2, 11, 12, 13, 14,
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
		return self.ChoiceNodes[nodeID]
	end

	function DataProvider:GetArtifactNodeInfoByIndex(index)
		local nodeID = self.ArtifactTracks[index][1];
		local entryID = self:GetNodeEntryID(nodeID);
		return nodeID, entryID
	end

	function DataProvider:GetFinalNodeInfoIndex(index)
		local nodeID = self.ArtifactTracks[index][5];
		local entryID = self:GetNodeEntryID(nodeID);
		return nodeID, entryID
	end

	function DataProvider:GetNodeInfo(nodeID)
		local configID = self:GetCurrentConfigID();
		if configID then
			return GetNodeInfo(configID, nodeID)
		end
	end

	function DataProvider:GetEntryInfo(entryID)
		local configID = self:GetCurrentConfigID();
		if configID then
			return GetEntryInfo(configID, entryID)
		end
	end

	function DataProvider:GetCost(nodeID)
		local configID = self:GetCurrentConfigID();
		local costs = configID and GetNodeCost(configID, nodeID);
		if costs and costs[1] then
			return costs[1].amount
		else
			return 0
		end
	end

	function DataProvider:IsNodeActive(nodeID)
		local nodeInfo = self:GetNodeInfo(nodeID);
		if nodeInfo then
			return nodeInfo.currentRank > 0
		end
	end

	function DataProvider:GetArtifactAbilities()
		return self.ArtifactAbilitySpells
	end

	function DataProvider:GetActiveArtifactAbility()
		local IsSpellKnown = API.IsSpellKnown;
		for _, spellID in ipairs(DataProvider.ArtifactAbilitySpells) do
			if IsSpellKnown(spellID) then
				return spellID
			end
		end
	end

	function DataProvider:GetActiveArtifactTrackIndex()
		local artifactTrackIndex;

		for index = 1, #self.ArtifactTracks do
			local nodeID = self:GetArtifactNodeInfoByIndex(index);
			local nodeInfo = self:GetNodeInfo(nodeID);
			if nodeInfo and nodeInfo.currentRank > 0 then
				artifactTrackIndex = index;
				break
			end
		end

		return artifactTrackIndex
	end

	function DataProvider:ShouldChooseArtifactTrack()
		for index = 1, #self.ArtifactTracks do
			local nodeID = self:GetArtifactNodeInfoByIndex(index);
			local nodeInfo = self:GetNodeInfo(nodeID);
			if nodeInfo and nodeInfo.canPurchaseRank then
				return true
			end
		end
	end

	function DataProvider:CanPreActivateArtifactTrack()
		--True if an artifact ability is purchased or can be purchased
		if (self:GetActiveArtifactTrackIndex() ~= nil) then
			return false
		else
			local nodeInfo;
			for _, _nodeID in ipairs(self.PurchaseRoute_Basic) do
				nodeInfo = self:GetNodeInfo(_nodeID);
				if nodeInfo and nodeInfo.canPurchaseRank then
					return true
				end
			end
			return self:ShouldChooseArtifactTrack();
		end
	end

	function DataProvider:GetDefaultArtifactNodeData()
		local trackIndex = self:GetLastArtifactTrackIndexForCurrentSpec() or 1;
		return self:GetArtifactNodeInfoByIndex(trackIndex)
	end

	function DataProvider:GetParagonLevel()
		local nodeID = 108700;
		local nodeInfo = self:GetNodeInfo(nodeID);
		if nodeInfo then
			return nodeInfo.currentRank
		end
		return 0
	end

	function DataProvider:IsForbiddenSelectionNodeOnTracks(activeTrackIndex, newTrackIndex)
		local tbl;
		if (not activeTrackIndex) or (activeTrackIndex == newTrackIndex) then
			tbl = {newTrackIndex};
		else
			tbl = {activeTrackIndex, newTrackIndex};
		end

		for _, artifactTrackIndex in ipairs(tbl) do
			if self.ForbiddenNodes[artifactTrackIndex] then
				for _, v in ipairs(self.ForbiddenNodes[artifactTrackIndex]) do
					local nodeID, entryID = v[1], v[2];
					local nodeInfo = self:GetNodeInfo(nodeID);
					local increasedRanks = nodeInfo.entryIDToRanksIncreased and nodeInfo.entryIDToRanksIncreased[entryID] or 0;
					if increasedRanks > 0 then
						return true
					end
				end
			end
		end

		return false
	end

	function DataProvider:GetItemNameByID(itemID)
		--Cache jewelry name
		if not self.itemNameCache then
			self.itemNameCache = {};
		end

		if not self.itemNameCache[itemID] then
			local itemName = C_Item.GetItemNameByID(itemID);
			if itemName then
				self.itemNameCache[itemID] = itemName;
			end
		end

		return self.itemNameCache[itemID]
	end

	function DataProvider:GetForbiddenSelectionNodeItems()
		local nodeInfo, nodeID, entryID, items;

		for artifactTrackIndex, nodes in pairs(self.ForbiddenNodes) do
			for _, v in ipairs(nodes) do
				nodeID, entryID = v[1], v[2];
				nodeInfo = self:GetNodeInfo(nodeID);
				--local increasedRanks = nodeInfo and nodeInfo.ranksincreased or 0;
				--For choice node, use this
				local increasedRanks = nodeInfo.entryIDToRanksIncreased and nodeInfo.entryIDToRanksIncreased[entryID] or 0;
				if increasedRanks > 0 then
					local increasedTraitDataList = GetIncreasedTraitData(nodeID, entryID);
					for _index, increasedTraitData in ipairs(increasedTraitDataList) do
						local qualityColor = API.GetItemQualityColor(increasedTraitData.itemQualityIncreasing);
						local itemName = increasedTraitData.itemNameIncreasing or "";
						local coloredItemName = qualityColor:WrapTextInColorCode(itemName);
						local slotID = 0;
						local itemID = 0;

						--local numPointsIncreased = increasedTraitData.numPointsIncreased;
						if not items then
							items = {};
						end
						--GetInventoryItemID: itemName to slotName

						for _, _slotID in ipairs(self.JewelrySlots) do
							local _itemID = GetInventoryItemID("player", _slotID);
							if _itemID and itemName == self:GetItemNameByID(_itemID) then
								coloredItemName = string.format("(%s) %s", API.GetInventorySlotName(_slotID), coloredItemName);
								slotID = _slotID;
								itemID = _itemID;
							end
						end

						table.insert(items, {
							slotID = slotID,
							itemID = itemID,
							itemName = itemName,
							coloredItemName = coloredItemName,
						});
					end
				end
			end
		end

		if items then
			table.sort(items, function(a, b)
				if a.slotID ~= b.slotID then
					return a.slotID < b.slotID
				end
				return a.itemName < b.itemName
			end);
		end
		return items
	end

	--[[
	function DataProvider:GetTreeInfo()
		if not PlumberDevData then
			PlumberDevData = {};
		end
		PlumberDevData.RemixArtifact = {};

		local itemID = C_RemixArtifactUI.GetCurrArtifactItemID();
		local traitTreeID = C_RemixArtifactUI.GetCurrTraitTreeID();
		local configID = itemID and traitTreeID and C_Traits.GetConfigIDByTreeID(traitTreeID);
		if configID then
			local configInfo = GetConfigInfo(configID);
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
								--Debug_SaveTraitInfo(nodeID, entryID, entryInfo.definitionID, name);
								print(string.format("|T%s:16:16|t %s  Rank: %s, EntryID: %s", icon, name, rankText, entryID));
								if ranksIncreased > 0 then
									rankText = rankText..string.format("(+%d)", nodeInfo.ranksIncreased);
									local increasedTraitDataList = GetIncreasedTraitData(nodeID, entryID);
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
	--]]

	--[[
	function DataProvider:GetIncreasedTraits()
		local GetIncreasedTraitData = GetIncreasedTraitData;
		local isLoaded = true;
		for _, v in ipairs(self.IncreasableTraits) do
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
	--]]

	function DataProvider:GetIncreasedTraitRankForNodeEntry(nodeID, entryID)
		local totalIncreased = 0;
		local increasedTraitDataList = GetIncreasedTraitData(nodeID, entryID);
		if increasedTraitDataList and #increasedTraitDataList > 0 then
			for	_index, increasedTraitData in ipairs(increasedTraitDataList) do
				totalIncreased = totalIncreased + increasedTraitData.numPointsIncreased;
			end
		end
		return totalIncreased
	end

	function DataProvider:GetIncreasedTraitSpellsAndRanks()
		local n = 0;
		local tbl;
		for _, v in ipairs(self.IncreasableTraits) do
			local nodeID, entryID, definitionID = v[1], v[2], v[3];
			local totalIncreased = self:GetIncreasedTraitRankForNodeEntry(nodeID, entryID);
			if totalIncreased > 0 then
				local definitionInfo = GetDefinitionInfo(definitionID);
				local spellID = definitionInfo and definitionInfo.spellID;
				if not tbl then
					tbl = {};
				end
				n = n + 1;
				tbl[n] = {spellID, totalIncreased};
			end
		end
		return tbl
	end

	function DataProvider:UpdateClassSpecInfo()
		local specIndex = C_SpecializationInfo.GetSpecialization();
		--local itemSpecIndex = C_RemixArtifactUI.GetCurrItemSpecIndex();	--need artifact being equipped

		if specIndex ~= self.specIndex then
			self.specIndex = specIndex;
			local _, name = C_SpecializationInfo.GetSpecializationInfo(specIndex);
			CallbackRegistry:Trigger("LegionRemix.ClassSpecChanged", specIndex);
			if C_RemixArtifactUI then
				C_RemixArtifactUI.ClearRemixArtifactItem();
			end
		end
	end

	function DataProvider:UpdateConfigInfo()
		--traitTreeID is always 1161
		--configID is different for each artifact weawpon

		local traitTreeID = C_RemixArtifactUI.GetCurrTraitTreeID() or 1161;
		local configID = traitTreeID and GetConfigIDByTreeID(traitTreeID);
		if not configID then return end;

		self.configID = configID;

		local configInfo = GetConfigInfo(configID);
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
			local configInfo = GetConfigInfo(configID);
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

		local configInfo = GetConfigInfo(configID);
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

	function DataProvider:GetTraitSpell(entryID)
		if self.traitSpellCache[entryID] then
			return self.traitSpellCache[entryID]
		end

		if not self.configID then return end;

		local entryInfo = GetEntryInfo(self.configID, entryID);
		local definitionInfo = GetDefinitionInfo(entryInfo.definitionID);
		local spellID = definitionInfo and definitionInfo.spellID;
		self.traitSpellCache[entryID] = spellID;
		return spellID
	end

	function DataProvider:GetTraitName(entryID)
		if self.traitNameCache[entryID] then
			return self.traitNameCache[entryID]
		end

		if not self.configID then return end;

		local spellID = self:GetTraitSpell(entryID);
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
		local shouldChooseArtifactTrack;

		nodeID = 108700;	--Paragon Node
		nodeInfo = self:GetNodeInfo(nodeID);

		if nodeInfo.canPurchaseRank then
			entryID = nodeInfo.entryIDs[1];
		else
			nodeID = nil;
			nodeInfo = nil;
			entryID = nil;
			local activeTrackIndex = self:GetActiveArtifactTrackIndex();
			if activeTrackIndex then
				local trackData = self.ArtifactTracks[activeTrackIndex];
				nodeID = trackData[1];
				local _nodeInfo = self:GetNodeInfo(nodeID);
				while _nodeInfo and _nodeInfo.visibleEdges and _nodeInfo.visibleEdges[1] and _nodeInfo.visibleEdges[1].targetNode do
					nodeID = _nodeInfo.visibleEdges[1].targetNode;
					_nodeInfo = self:GetNodeInfo(nodeID);
					if _nodeInfo and _nodeInfo.canPurchaseRank then
						--entryID = _nodeInfo.entryIDs[1];
						entryID = self:GetLastSelectedEntryID(nodeID, _nodeInfo.entryIDs);
						break
					end
				end
				--[[
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
				--]]
			else
				for _, _nodeID in ipairs(self.PurchaseRoute_Basic) do
					nodeInfo = self:GetNodeInfo(_nodeID);
					if nodeInfo.canPurchaseRank then
						entryID = nodeInfo.entryIDs[1];
						nodeID = _nodeID;
						break
					end
				end

				if not entryID then
					if DataProvider:ShouldChooseArtifactTrack() then
						shouldChooseArtifactTrack = true;
						nodeID, entryID = DataProvider:GetDefaultArtifactNodeData();
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
				shouldChooseArtifactTrack = shouldChooseArtifactTrack,
			};
		end
	end

	function DataProvider:GetRequiredAmountBeforeNextUpgrade()
		local traitInfo = self:GetNextTraitForUpgrade();
		if traitInfo and traitInfo.cost >= 0 then
			local numUnspent = self:GetNumUnspentPower();
			local diff = traitInfo.cost - numUnspent;
			return diff
		end
	end

	function DataProvider:GetNextUpgradeInfoForUI()
		local tbl;
		local traitInfo = self:GetNextTraitForUpgrade();
		if traitInfo and traitInfo.cost >= 0 then
			local line1, line2, nextSpellID, nextEntryID, nextRank;
			tbl = {};
			local numUnspent = self:GetNumUnspentPower();
			local diff = traitInfo.cost - numUnspent;
			if diff <= 0 then
				--Diff becomes negative when player receives lots of power at once to upgrade more than 1 trait
				--We will automatically upgrade the second trait after CURRENCY_DISPLAY_UPDATE
				diff = 0;
				line1 = L["Soon To Unlock"];
			else
				line1 = L["Amount Required To Unlock Format"]:format(BreakUpLargeNumbers(diff));
			end
			nextSpellID = self:GetTraitSpell(traitInfo.entryID);
			nextEntryID = traitInfo.entryID;
			local entryInfo = self:GetEntryInfo(traitInfo.entryID);
			if entryInfo then
				if entryInfo.type == 3 then
					--SpendSmallCircle: Stat Bonus
					line2 = C_Spell.GetSpellDescription(nextSpellID);
					if line2 then
						line2 = string.gsub(line2, "[%.。]%s*$", "");
					end
				else
					local nodeInfo = DataProvider:GetNodeInfo(traitInfo.nodeID);
					local maxRanks = entryInfo.maxRanks;
					if maxRanks > 1 then
						nextRank = (nodeInfo and nodeInfo.ranksPurchased or 0) + 1;
					end
				end
			end
			if not line2 then
				line2 = self:GetTraitName(traitInfo.entryID);
			end
			if nextRank and line2 then
				line2 = string.format("|cffb6b6b6%s|r  %s", L["Rank Format"]:format(nextRank), line2);
			end

			tbl = {
				line1 = line1,
				line2 = line2,
				nextSpellID = nextSpellID,
				nextEntryID = nextEntryID,
				nextRank = nextRank,
			}
		end
		return tbl
	end

	function DataProvider:GetLastSelectedEntryID(nodeID, entryIDs)
		--For selection nodes
		local entryID, saved;
		if #entryIDs == 1 then
			entryID = entryIDs[1];
			saved = true;
		else
			if self.playerDB and self.playerDB.lastSelectedEntry then
				local specIndex = C_SpecializationInfo.GetSpecialization() or 1;
				if self.playerDB.lastSelectedEntryBySpec and self.playerDB.lastSelectedEntryBySpec[specIndex] then
					entryID = self.playerDB.lastSelectedEntryBySpec[specIndex][nodeID]
				end
				if not entryID then
					entryID = self.playerDB.lastSelectedEntry[nodeID];
				end
			end
			if entryID then
				local valid = false;
				for _, id in ipairs(entryIDs) do
					if id == entryID then
						valid = true;
						break
					end
				end
				if valid then
					saved = true;
				else
					entryID = nil;
				end
			end

			if not entryID then
				saved = false;
				entryID = entryIDs[2];	--We use the 2nd one to avoid Arcane Aegis, which changes Moving Backward bahavior
			end
		end
		return entryID, saved
	end

	function DataProvider:SaveLastSelectedEntryID(nodeID, entryID)
		if not (nodeID and entryID and self.playerDB) then return end;

		if not self.playerDB.lastSelectedEntry then
			self.playerDB.lastSelectedEntry = {};
		end
		self.playerDB.lastSelectedEntry[nodeID] = entryID;

		local specIndex = C_SpecializationInfo.GetSpecialization() or 1;
		if not self.playerDB.lastSelectedEntryBySpec then
			self.playerDB.lastSelectedEntryBySpec = {};
		end
		if not self.playerDB.lastSelectedEntryBySpec[specIndex] then
			self.playerDB.lastSelectedEntryBySpec[specIndex] = {};
		end
		self.playerDB.lastSelectedEntryBySpec[specIndex][nodeID] = entryID;
	end




	--Saved Variables
	CallbackRegistry:Register("TimerunningSeason", function(seasonID)
		--This happens after PLAYER_ENTERING_WORLD
		if PlumberDB_PC then
			if not PlumberDB_PC.LegionRemix then
				PlumberDB_PC.LegionRemix = {};
			end
			DataProvider.playerDB = PlumberDB_PC.LegionRemix;
		else
			DataProvider.playerDB = {};
		end
		DataProvider:UpdateConfigInfo();
		DataProvider:UpdateClassSpecInfo();
	end);

	function DataProvider:GetLastArtifactTrackIndexForCurrentSpec()
		if not self.playerDB then return end;

		if not self.specIndex then
			self:UpdateClassSpecInfo();
		end

		if self.specIndex then
			local artifactTrackIndex = self.playerDB["spec"..self.specIndex.."artifactTrackIndex"];
			return artifactTrackIndex
		end
	end

	function DataProvider:SetLastArtifactTrackIndexForCurrentSpec(artifactTrackIndex)
		if not self.playerDB then return end;
		if artifactTrackIndex and self.ArtifactTracks[artifactTrackIndex] then
			if not self.specIndex then
				self:UpdateClassSpecInfo();
			end

			if self.specIndex then
				self.playerDB["spec"..self.specIndex.."artifactTrackIndex"] = artifactTrackIndex;
			end
		end
	end

	function DataProvider:SaveLastArtifactTrackIndexForCurrentSpec()
		local artifactTrackIndex = self:GetActiveArtifactTrackIndex();
		self:SetLastArtifactTrackIndexForCurrentSpec(artifactTrackIndex);
	end
end


do
	EventListener.dynamicEvents = {
		"CURRENCY_DISPLAY_UPDATE",
		"REMIX_ARTIFACT_ITEM_SPECS_LOADED",		--return loadSuccessful
		"REMIX_ARTIFACT_UPDATE",				--Seems to only trigger when Shift RightClick artifact weapons
		"ACTIVE_TALENT_GROUP_CHANGED",
		"TRAIT_CONFIG_UPDATED",
	};

	function EventListener:Enable(state)
		if state then
			--self:RegisterEvent("TRAIT_TREE_CURRENCY_INFO_UPDATED");
			API.RegisterFrameForEvents(self, self.dynamicEvents);
			self:SetScript("OnEvent", self.OnEvent);
		else
			API.UnregisterFrameForEvents(self, self.dynamicEvents);
			self:UnregisterEvent("BAG_UPDATE_DELAYED");
			self:UnregisterEvent("PLAYER_REGEN_ENABLED");
		end
	end

	function EventListener:OnUpdate(elapsed)
		self.t = self.t + elapsed;

		if self.specDirty then
			if self.t > 0.5 then
				self.specDirty = nil;
				DataProvider:UpdateClassSpecInfo();
				DataProvider:UpdateConfigInfo();
				CommitUtil:TryPurchaseAllTraits();
			end
		end

		if self.currencyDirty then
			if self.t > 1.0 then
				self.currencyDirty = nil;

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
					if traitInfo.shouldChooseArtifactTrack then
						print("You can choose an Artifact Ability");
						CommitUtil:TryPurchaseToNode(traitInfo.nodeID, true);
					else
						print("You can upgrade: "..traitName);
						if (not DataProvider:IsChoiceNode(traitInfo.nodeID)) then
							if InCombatLockdown() then
								print("We will purchase "..traitName.." after combat");
								CommitUtil:TryPurchaseUpgradeAfterCombat();
							else
								CommitUtil:TryPurchaseToNode(traitInfo.nodeID, true);
							end
						end
					end
				end
			end
		end

		if not (self.specDirty or self.currencyDirty) then
			self.t = 0;
			self:SetScript("OnUpdate", nil);
		end
	end

	function EventListener:RequestUpdate()
		self.t = 0;
		self:SetScript("OnUpdate", self.OnUpdate);
	end

	function EventListener:ListenLeavingCombat()
		if MASTER_ENABLED then
			self:RegisterEvent("PLAYER_REGEN_ENABLED");
		end
	end

	function EventListener:ListenBagUpdateDelayed()
		if MASTER_ENABLED then
			self:RegisterEvent("BAG_UPDATE_DELAYED");
		end
	end

	function EventListener:OnEvent(event, ...)
		--TRAIT_CONFIG_UPDATED fires upon initial login for all artifact including the uncollected ones
		if event == "CURRENCY_DISPLAY_UPDATE" then
			--The value we need changes after TRAIT_TREE_CURRENCY_INFO_UPDATED
			local currencyID = ...
			if currencyID == CURRENCY_ID_IP then
				self.currencyDirty = true;
				self:RequestUpdate();
			end
		else
			print(event, ...);
			if event == "ACTIVE_TALENT_GROUP_CHANGED" then
				self.specDirty = true;
				self:RequestUpdate();
			elseif event == "REMIX_ARTIFACT_UPDATE" then
				DataProvider:UpdateConfigInfo();
				--RemixAPI.ShowArtifactUI();
			elseif event == "BAG_UPDATE_DELAYED" then
				self:UnregisterEvent(event);
				if InCombatLockdown() then
					self:RegisterEvent("PLAYER_REGEN_ENABLED");
				else
					CommitUtil:ReEquipFailedItems();
				end
			elseif event == "PLAYER_REGEN_ENABLED" then
				self:UnregisterEvent(event);
				CommitUtil:ReEquipFailedItems();
			elseif event == "TRAIT_CONFIG_UPDATED" then
				local configID = ...
				if configID == DataProvider.configID then
					CallbackRegistry:Trigger("LegionRemix.ConfigUpdated", configID);
				end
			end
		end
	end
end


do	--CommitUtil
	function CommitUtil:Enable(state)
		if state then
			self:SetScript("OnEvent", self.OnEvent);
		else
			self:UnregisterEvent("TRAIT_CONFIG_UPDATED");
			self:UnregisterEvent("CONFIG_COMMIT_FAILED");
			self:UnregisterEvent("PLAYER_REGEN_ENABLED");
			self:UnregisterEvent("BAG_UPDATE_DELAYED");
		end
	end

	function CommitUtil:SetCommitStarted(configID)
		self:RegisterEvent("TRAIT_CONFIG_UPDATED");
		self:RegisterEvent("CONFIG_COMMIT_FAILED");

		self.commitedConfigID = configID;
		self.commitingResult = nil;
		self.t = 0;
		self:SetScript("OnUpdate", self.OnUpdate_Commit);
		C_Traits.CommitConfig(configID);
	end

	function CommitUtil:OnCommitFinished()
		self.commitedConfigID = nil;
		self:SetScript("OnUpdate", nil);
		self:UnregisterEvent("TRAIT_CONFIG_UPDATED");
		self:UnregisterEvent("CONFIG_COMMIT_FAILED");
		if self.commitingResult == 1 then
			CallbackRegistry:Trigger("LegionRemix.CommitFinished", true);
			DataProvider:SaveLastArtifactTrackIndexForCurrentSpec();
		elseif self.commitingResult == 0 then
			CallbackRegistry:Trigger("LegionRemix.CommitFinished", false);
			print("COMMIT FAILED");
		end
		self.commitingResult = nil;
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
		elseif event == "PLAYER_REGEN_ENABLED" then
			self:UnregisterEvent(event);
			if self.processAfterCombat then
				self.processAfterCombat = nil;
				self:TryPurchaseNextUpgrade();
			end
		elseif event == "BAG_UPDATE_DELAYED" then
			if self.equipItemAfterCommit then
				print("equipItemAfterCommit")
				self.equipItemAfterCommit = nil;
				self:UnregisterEvent(event);
				self:ReEquipItems(self.replacedEquipment);
				self.replacedEquipment = nil;
			end
		end

		if self.commitingResult then
			self:OnCommitFinished();
			if self.equipItemAfterCommit then
				self:RegisterEvent("BAG_UPDATE_DELAYED");
			end
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

	--[[
	function CommitUtil:OnUpdate_Purchase(elapsed)
		self.t = self.t + elapsed;
		if self.t > 0.016 then
			self.t = 0;
			self:SetScript("OnUpdate", nil);

			local nodeID, entryID, isSelectionNode, needMassPurchase = DataProvider:GetPurchasableTrait();
			if nodeID then
				--print(nodeID, DataProvider:GetTraitName(entryID), isSelectionNode and "Choice" or "");
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
	--]]

	function CommitUtil:TryPurchaseBasicTraits()
		--Select all traits to the left the Artifact abilities
		local configID = DataProvider:GetCurrentConfigID();
		if not configID then return false end;

		local anySuccessPurchase = false;

		for _, nodeID in ipairs(DataProvider.PurchaseRoute_Basic) do
			if PurchaseRank(configID, nodeID) then
				anySuccessPurchase = true;
			end
		end

		self.anySuccessPurchase = anySuccessPurchase;

		return true
	end

	function CommitUtil:TryPurchaseToNode(nodeID, autoPurchase)
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
			if autoPurchase then
				local nodeInfo = DataProvider:GetNodeInfo(nodeID);
				local entryID = nodeInfo and nodeInfo.activeEntry and nodeInfo.activeEntry.entryID;
				self:SendRankUpgradeToLootUI(entryID)
			end
		end
	end

	function CommitUtil:TryPurchaseParagon()
		--Limits Unbound
		if self:IsCommitingInProcess() then
			return
		end

		local configID = DataProvider:GetCurrentConfigID();
		if not configID then return end;
		local nodeID, entryID = 108700, 134246;
		--while PurchaseRank(configID, nodeID) do
		--	self.anySuccessPurchase = true;
		--end
		if C_Traits.TryPurchaseToNode(configID, nodeID) then
			--This will purchase to as much as possible
			self.anySuccessPurchase = true;
		end
	end

	function CommitUtil:SetReplacedEquipment(replacedEquipment)
		self.replacedEquipment = replacedEquipment;
		self.equipItemAfterCommit = true;
		for itemID, v in pairs(replacedEquipment) do
			UnequipInventorySlot(v.slotID);
		end
	end

	function CommitUtil:ReEquipItems(replacedEquipment, fromRequery)
		if not replacedEquipment then return end;

		local numPending = 0;
		local itemFound = {};
		for itemID, v in pairs(replacedEquipment) do
			numPending = numPending + 1;
			itemFound[itemID] = false;
		end
		print("numPending", numPending);
		if InCombatLockdown() then
			print("In Combat");
			self.failedItems = API.CopyTable(replacedEquipment);
			EventListener:ListenLeavingCombat();
		else
			local itemID, containerInfo;
			local GetContainerItemID = C_Container.GetContainerItemID;
			local GetContainerItemInfo = C_Container.GetContainerItemInfo;

			local fromIndex = 0;	--BACKPACK_CONTAINER
			local toIndex = 4;		--NUM_TOTAL_EQUIPPED_BAG_SLOTS - 1

			for bag = fromIndex, toIndex do
				for slot = 1, C_Container.GetContainerNumSlots(bag) do
					itemID = GetContainerItemID(bag, slot);
					if (not itemFound[itemID]) and replacedEquipment[itemID] then
						containerInfo = GetContainerItemInfo(bag, slot);
						if containerInfo.isBound and containerInfo.hyperlink == replacedEquipment[itemID].hyperlink then
							itemFound[itemID] = true;
							local invSlot = replacedEquipment[itemID].slotID;

							local action = {};
							action.bag = bag;
							action.slot = slot;
							action.invSlot = invSlot;

							ClearCursor();
							C_Container.PickupContainerItem(action.bag, action.slot);

							if ( not CursorHasItem() ) then
								print("Error PickupContainerItem");
							elseif not C_PaperDollInfo.CanCursorCanGoInSlot(action.invSlot) then
								print("Error CannotGoInSlot");
							elseif IsInventoryItemLocked(action.invSlot) then
								print("Error InventoryItemLocked");
							else
								PickupInventoryItem(action.invSlot);
								numPending = numPending - 1;
							end

							if numPending <= 0 then
								print("Reequip Complete");
								self.failedItems = nil;
								return true
							end
						end
					end
				end
			end

			if numPending > 0 and not fromRequery then
				--Something is wrong
				print("TRY REEQUIP AGAIN");
				self.failedItems = API.CopyTable(replacedEquipment);
				EventListener:ListenBagUpdateDelayed();
			else
				self.failedItems = nil;
			end
		end
	end

	function CommitUtil:ReEquipFailedItems()
		if not self.failedItems then return end;
		self:ReEquipItems(self.failedItems, true);
	end

	function CommitUtil:TryPurchaseArtifactTrack(index)
		if InCombatLockdown() then return end;

		if self:IsCommitingInProcess() then
			return
		end

		local activeTrackIndex = DataProvider:GetActiveArtifactTrackIndex();

		if DataProvider:IsForbiddenSelectionNodeOnTracks(activeTrackIndex, index) then
			local items = DataProvider:GetForbiddenSelectionNodeItems();
			if items then
				print("Unequip these items before changing traits:")
				for _, v in ipairs(items) do
					print(v.slotID, v.coloredItemName);
				end

				--Auto unequip/re-equip
				local total = #items;
				local numFound = 0;
				if CalculateTotalNumberOfFreeBagSlots() > total then
					local itemIDxData = {};
					for _, v in ipairs(items) do
						local hyperlink = GetInventoryItemLink("player", v.slotID);
						if hyperlink then
							numFound = numFound + 1;
							itemIDxData[v.itemID] = {
								hyperlink = hyperlink,
								slotID = v.slotID
							};
						end
					end

					if numFound == total then
						self:SetReplacedEquipment(itemIDxData);
					end
				end
			end
			--return
		end

		local configID = DataProvider:GetCurrentConfigID();

		if activeTrackIndex and (activeTrackIndex ~= index) then
			C_Traits.ResetTree(configID, DataProvider:GetCurrentTreeID());
		end

		self:TryPurchaseBasicTraits();

		local nodeID, entryID = DataProvider:GetArtifactNodeInfoByIndex(index);

		if configID then
			local costs = GetNodeCost(configID, nodeID);
			local numUnspent = DataProvider:GetNumUnspentPower();
			if IsCurrencyEnough(numUnspent, costs) then
				nodeID, entryID = DataProvider:GetFinalNodeInfoIndex(index);
				local success = C_Traits.TryPurchaseToNode(configID, nodeID);
				if success then
					self.anySuccessPurchase = true;
				end
			end
		else
			print("Cannot Purchase", DataProvider:GetTraitName(entryID));
		end

		self:TryPurchaseParagon();

		if self.anySuccessPurchase then
			self:SetCommitStarted(configID);
			return true
		end
	end

	function CommitUtil:TryPurchaseAllTraits()
		--We run this after player changes spec and has unspent power
		local activeTrackIndex = DataProvider:GetActiveArtifactTrackIndex();
		if not activeTrackIndex then
			activeTrackIndex = DataProvider:GetLastArtifactTrackIndexForCurrentSpec() or 1;
		end
		self:TryPurchaseArtifactTrack(activeTrackIndex);

		--Disable tutorial
		if DataProvider.specIndex then
			C_CVar.SetCVarBitfield("closedRemixArtifactTutorialFrames", DataProvider.specIndex, true);
		end
	end

	function CommitUtil:TryPurchaseNextUpgrade()
		local traitInfo = DataProvider:GetNextTraitForUpgrade(true);
		if traitInfo then
			local traitName = DataProvider:GetTraitName(traitInfo.entryID);
			if (not DataProvider:IsChoiceNode(traitInfo.nodeID)) then
				print("Purchasing "..traitName);
				CommitUtil:TryPurchaseToNode(traitInfo.nodeID);
			end
		end
	end

	function CommitUtil:TryPurchaseUpgradeAfterCombat()
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		self.processAfterCombat = true;
	end

	function CommitUtil:SendRankUpgradeToLootUI(entryID)
		if not (entryID and addon.GetDBBool("LootUI")) then return end;

		local spellID;
		local entryInfo = DataProvider:GetEntryInfo(entryID);
		if entryInfo then	--nodeInfo.canPurchaseRank or nodeInfo.canRefundRank
			local definitionInfo = GetDefinitionInfo(entryInfo.definitionID);
			spellID = definitionInfo and definitionInfo.spellID;
		end

		if not spellID then return end;

		local icon = C_Spell.GetSpellTexture(spellID);
		local name = C_Spell.GetSpellName(spellID);

		if name then
			name = string.format("%s\n|cff19ff19%s|r", name, L["Rank Increased"]);
		else
			return
		end

		local data = {
			spellID = spellID,
			icon = icon,
			name = name,
		};
		addon.LootWindow:QueueDisplaySpell(data);
	end


	YEETPC = function(index)
		index = index or 1;
		CommitUtil:TryPurchaseArtifactTrack(index);
	end
end


do	--Debug
	--[[
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
			if configID then
				local costs = GetNodeCost(configID, nodeID);
				if (not costs) or #costs == 0 then
					tooltip:AddLine("No Cost");
				else
					for _, cost in ipairs(costs) do
						tooltip:AddDoubleLine("TraitCurrencyID: "..cost.ID, cost.amount);
					end
				end
			end

			tooltip:AddDoubleLine("posX", nodeInfo.posX);
			tooltip:AddDoubleLine("posY", nodeInfo.posY);
			tooltip:AddDoubleLine("nodeInfo.type", nodeInfo.type);
			tooltip:AddDoubleLine("maxRanks", nodeInfo.maxRanks or "Nil");
			if nodeInfo.visibleEdges and nodeInfo.visibleEdges[1] then
				tooltip:AddDoubleLine("visibleEdges[1].targetNode", nodeInfo.visibleEdges[1].targetNode);
			end
		end
		tooltip:Show();
	end);
	--]]
end


local CurrencyTooltipModule = {};
do	--GameTooltip Infinite Power
	local GameTooltipCurrencyManager = addon.GameTooltipManager:GetCurrencyManager();


	function CurrencyTooltipModule:ProcessData(tooltip, currencyID)
		if self.enabled then
			if currencyID == CURRENCY_ID_IP then
				local diff = DataProvider:GetRequiredAmountBeforeNextUpgrade();
				if diff then
					tooltip:AddLine(" ");
					if diff > 0 then
						diff = BreakUpLargeNumbers(diff);
						tooltip:AddLine(string.format(L["Earn X To Upgrade Y Format"], diff, API.GetCurrencyName(CURRENCY_ID_IP), L["Artifact Weapon"]), 1, 0.82, 0, true);
					else
						tooltip:AddLine(L["New Trait Available"], 0.098, 1.000, 0.098, true);
					end

					return true
				end
			elseif currencyID == 3292 then
				tooltip:AddLine(" ");
				tooltip:AddLine(L["Infinite Knowledge Tooltip"], 0.400, 0.733, 1.00, true);	--BRIGHTBLUE_FONT_COLOR
				return true
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


	local function ExtraTooltipLineGetter()
		local diff = DataProvider:GetRequiredAmountBeforeNextUpgrade();
		if diff then
			if diff > 0 then
				--return "|cffcccccc"..L["Until Next Upgrade Format"]:format(diff).."|r"
			else
				--return "|cff19ff19"..L["New Trait Available"].."|r"
			end
		end
	end
	API.SetExtraTooltipForCurrency(CURRENCY_ID_IP, ExtraTooltipLineGetter);
end


do	--Module Registry
	local function EnableModule(state)
		if state and not MASTER_ENABLED then
			DataProvider:UpdateConfigInfo();
			--UIParent:UnregisterEvent("REMIX_ARTIFACT_UPDATE");
		elseif not state and MASTER_ENABLED then
			--UIParent:RegisterEvent("REMIX_ARTIFACT_UPDATE");
		else
			return
		end

		MASTER_ENABLED = state;
		EventListener:Enable(state);
		CurrencyTooltipModule:SetEnabled(state);
		CommitUtil:Enable(state);
	end

    local moduleData = {
        name = L["ModuleName LegionRemix"],
        dbKey = "LegionRemix",
        description = L["ModuleDescription LegionRemix"],
        toggleFunc = EnableModule,
        categoryID = -1,
        uiOrder = 0,
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
		local increasedTraitDataList = GetIncreasedTraitData(self:GetNodeID(), self:GetEntryID());
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
	/run C_RemixArtifactUI.ClearRemixArtifactItem();	--This reset the active configID to current artifact.


	--C_RemixArtifactUI.GetCurrItemSpecIndex()
	--REMIX_ARTIFACT_ITEM_SPECS_LOADED

	--local success = C_CVar.SetCVarBitfield("closedRemixArtifactTutorialFrames", specIndex, true);

	EventRegistry:TriggerEvent("RemixArtifactFrame.VisibilityUpdated", shown);


	PlaySound(SOUNDKIT.UI_CLASS_TALENT_CLOSE_WINDOW);	SOUNDKIT.UI_CLASS_TALENT_OPEN_WINDOW

	BLZ uses RemixArtifactFrame.Model as background. See RemixArtifactFrameMixin:RefreshBackgroundModel()


	Achievement Category: 15554(Main), 15562
	https://wago.tools/db2/Achievement?filter%5BReward_lang%5D=Infinite%20Knowledge&page=2&sort%5BID%5D=asc
--]]