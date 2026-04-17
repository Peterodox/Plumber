local _, addon = ...
local L = addon.L;
local GameTooltipItemManager = addon.GameTooltipManager:GetItemManager();
local ReplaceTooltipLine = addon.GameTooltipManager.ReplaceTooltipLine;
local ReplaceLineByMatching = addon.GameTooltipManager.ReplaceLineByMatching;
local DeleteLineByMatching = addon.GameTooltipManager.DeleteLineByMatching;


local ALREADY_KNOWN = ITEM_SPELL_KNOWN; --ERR_COSMETIC_KNOWN, Already known, with lowercase k
local PATTERN_PARTIALLY_KNOWN = L["Match Pattern Transmog Set Partially Known"];
local GREY_CHECKMARK = "|TInterface\\AddOns\\Plumber\\Art\\ExpansionLandingPage\\Icons\\CheckmarkGrey:0:0|t";


local ipairs = ipairs;
local GetItemLearnTransmogSet = C_Item.GetItemLearnTransmogSet;
local GetBaseSetID = C_TransmogSets.GetBaseSetID;
local GetVariantSets = C_TransmogSets.GetVariantSets;
local GetSetInfo = C_TransmogSets.GetSetInfo;
local GetSetPrimaryAppearances = C_TransmogSets.GetSetPrimaryAppearances;
local GetSourcesForSlot = C_TransmogSets.GetSourcesForSlot;
local GetAllSetAppearancesByID = C_Transmog.GetAllSetAppearancesByID;
local GetSourceInfo = C_TransmogCollection.GetSourceInfo;
local IsAppearanceCollected = addon.API.IsAppearanceCollected;
--local GetNumCollectedAppearanceSources = addon.API.GetNumCollectedAppearanceSources;


local LegionRaidEnsemble = {};
local ItemXSets = {};
local ItemSubModule = {};


local DifficultyNames = {
	PLAYER_DIFFICULTY3,
	PLAYER_DIFFICULTY1,
	PLAYER_DIFFICULTY2,
	PLAYER_DIFFICULTY6,
};


local CollectionCache = CreateFrame("Frame");
do
	CollectionCache.cache = {};

	function CollectionCache:ListenEvents(state)
		if state then
			if not self.listend then
				self.listend = true;
				self:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED");
				self:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED");
				self:RegisterEvent("TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED");
			end

		else
			if self.listend then
				self.listend = nil;
				self:UnregisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED");
				self:UnregisterEvent("TRANSMOG_COLLECTION_SOURCE_REMOVED");
				self:UnregisterEvent("TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED");
			end
		end
	end

	function CollectionCache:GetData(setID)
		if not self.cache[setID] then
			local setItems = GetAllSetAppearancesByID(setID);
			if setItems then
				local appCol, appTotal = 0, 0;
				local sourceCol, sourceTotal = 0, 0;
				local appearanceIDs = {};
				local sourceInfo;
				for _, v in ipairs(setItems) do
					sourceInfo = GetSourceInfo(v.itemModifiedAppearanceID);
					if sourceInfo and sourceInfo.visualID then
						appearanceIDs[sourceInfo.visualID] = true;
						sourceTotal = sourceTotal + 1;
						if sourceInfo.isCollected then
							sourceCol = sourceCol + 1;
						end
					end
				end

				for appearanceID in pairs(appearanceIDs) do
					appTotal = appTotal + 1;
					if IsAppearanceCollected(appearanceID) then
						appCol = appCol + 1;
					end
				end

				self.cache[setID] = {appCol, appTotal, sourceCol, sourceTotal};
				self:ListenEvents(true);
			end
		end

		local v = self.cache[setID];
		if v then
			return v[1], v[2], v[3], v[4];
		end
	end

	CollectionCache:SetScript("OnEvent", function(self)
		self:ListenEvents(false);
		self.cache = {};
	end);
end


local function SetTooltipCollected(tooltip, leftText)
	tooltip:AddDoubleLine(leftText, GREY_CHECKMARK, 0.5, 0.5, 0.5, 1, 1, 1);
end

local function SetTooltipUncollected(tooltip, leftText, numCollected, numTotal)
	tooltip:AddDoubleLine(leftText, numCollected.."/"..numTotal, 1, 1, 1, 1, 1, 1);
end


local VoidTouchUtil = {};
do
	local ClassXSet = {
		[1] = 5555,
		[2] = 3850,
		[3] = 5553,
		[4] = 3854,
		[5] = 5556,
		[6] = 5551,
		[7] = 3855,
		[8] = 3853,
		[9] = 3848,
		[10]= 5554,
		[11]= 5552,
		[12]= 3858,
		[13]= 3859,
	};

	local ItemXSlot = {
		[264314] = 1,
		[264315] = 3,
		[264316] = 15,
		[264317] = 5,
		[264318] = 9,
		[264319] = 10,
		[264320] = 6,
		[264321] = 7,
		[264322] = 8,
	};

	local Weapons = {
		--[itemSubclass] = {subclassID, itemID1, itemID2},
		{10, 263952, 263954},
		{6, 263950, 273874},
		{8, 263966},
		{7, 263960, 263963},
		{4, 263946, 263956},
		{15, 263942, 263943},
		{13, 263970},
		{14, 263959}, -- Offhand
	};

	function VoidTouchUtil:TryProcessItem(tooltip, itemID)
		if not (itemID == 264323 or ItemXSlot[itemID]) then
			return false;
		end

		local isItemRefTooltip = tooltip:GetName() == "ItemRefTooltip";
		local showExtraInfo = ItemSubModule.altModeEnabled or isItemRefTooltip;

		if itemID == 264323 then
			local typeName, itemAppearanceID;
			local numCollected, numTotal;
			local allCollected = true;

			if showExtraInfo then
				local collectionTexts = {};

				for i, v in pairs(Weapons) do
					numCollected, numTotal = 0, 0;

					if v[1] == 14 then
						typeName = INVTYPE_HOLDABLE;
					else
						typeName = C_Item.GetItemSubClassInfo(2, v[1]);
					end

					for j = 2, #v do
						itemAppearanceID = C_TransmogCollection.GetItemInfo(v[j]);
						if itemAppearanceID and IsAppearanceCollected(itemAppearanceID) then
							numCollected = numCollected + 1;
						else
							allCollected = false;
						end
						numTotal = numTotal + 1;
					end

					if numCollected >= numTotal then
						collectionTexts[i] = {true, typeName};
					else
						collectionTexts[i] = {false, typeName, numCollected, numTotal};
					end
				end

				if not allCollected then
					tooltip:AddLine(" ");
					for _, v in ipairs(collectionTexts) do
						if v[1] then
							SetTooltipCollected(tooltip, v[2]);
						else
							SetTooltipUncollected(tooltip, v[2], v[3], v[4]);
						end
					end
				end
			else
				numCollected, numTotal = 0, 0;
				for i, v in pairs(Weapons) do
					for j = 2, #v do
						itemAppearanceID = C_TransmogCollection.GetItemInfo(v[j]);
						if itemAppearanceID and IsAppearanceCollected(itemAppearanceID) then
							numCollected = numCollected + 1;
						else
							allCollected = false;
						end
						numTotal = numTotal + 1;
					end
				end

				if not allCollected then
					typeName = C_Item.GetItemClassInfo(2);
					tooltip:AddLine(" ");
					SetTooltipUncollected(tooltip, typeName, numCollected, numTotal);
				end
			end

			if not allCollected then
				ItemSubModule.altModeState = showExtraInfo and 1 or 0;
			end

			return true;
		end

		local slotID = ItemXSlot[itemID];
		if not slotID then return false; end

		if not VoidTouchUtil.classID then
			local _;
			VoidTouchUtil.className, _, VoidTouchUtil.classID = UnitClass("player");
		end

		local sources;
		local isPlayerClassCollected;
		local numOtherCollected = 0;
		local numOtherTotal = 0;

		if showExtraInfo then
			local allCollected = true;
			local collectionTexts = {};
			for _classID, setID in ipairs(ClassXSet) do
				sources = GetSourcesForSlot(setID, slotID);
				if sources and sources[1] then
					local isCollected = false;
					for _, source in ipairs(sources) do
						if source.isCollected then
							isCollected = true;
							break
						end
					end

					collectionTexts[_classID] = isCollected;
					if not isCollected then
						allCollected = false;
					end
				end
			end

			if not allCollected then
				local className;
				for _classID, isCollected in ipairs(collectionTexts) do
					className = GetClassInfo(_classID);
					if isCollected then
						SetTooltipCollected(tooltip, className);
					else
						SetTooltipUncollected(tooltip, className, 0, 1);
					end
				end
				ItemSubModule.altModeState = showExtraInfo and 1 or 0;
			end
		else
			for _classID, setID in ipairs(ClassXSet) do
				sources = GetSourcesForSlot(setID, slotID);
				if sources and sources[1] then
					local isCollected = false;
					for _, source in ipairs(sources) do
						if source.isCollected then
							isCollected = true;
							break
						end
					end

					if _classID == VoidTouchUtil.classID then
						if isCollected then
							isPlayerClassCollected = true;
						end
					else
						if isCollected then
							numOtherCollected = numOtherCollected + 1;
						end
						numOtherTotal = numOtherTotal + 1;
					end
				end
			end

			if (not isPlayerClassCollected) or (numOtherCollected < numOtherTotal) then
				tooltip:AddLine(" ");

				if isPlayerClassCollected then
					SetTooltipCollected(tooltip, VoidTouchUtil.className);
				else
					SetTooltipUncollected(tooltip, VoidTouchUtil.className, 0, 1);
				end

				if numOtherCollected >= numOtherTotal then
					SetTooltipCollected(tooltip, L["Other Player Classes"]);
				else
					SetTooltipUncollected(tooltip, L["Other Player Classes"], numOtherCollected, numOtherTotal);
				end

				ItemSubModule.altModeState = showExtraInfo and 1 or 0;
			end
		end

		return true;
	end
end


local function ProcessItemTooltip(tooltip, itemID, hyperlink, isDialogueUI)
	--[[ --debug
	local setID = hyperlink and C_Item.GetItemLearnTransmogSet(hyperlink);
	if setID then
		if not ItemXSets[itemID] then
			if not PlumberDevData then
				PlumberDevData = {};
			end
			if not PlumberDevData.ItemXSets then
				PlumberDevData.ItemXSets = {};
			end
			ItemXSets[itemID] = setID;
			local name = C_Item.GetItemInfo(hyperlink);
			print(name, itemID, setID);
			PlumberDevData.ItemXSets[itemID] = string.format("{%s},     --%s", setID, name);
		end
	end
	--]]

	if VoidTouchUtil:TryProcessItem(tooltip, itemID) then
		return true;
	end

	if not hyperlink then return; end

	local setID = GetItemLearnTransmogSet(hyperlink);
	if setID then
		if LegionRaidEnsemble[itemID] then
			if not ItemXSets[itemID] then
				local baseSetID = GetBaseSetID(setID);
				local baseSetInfo = GetSetInfo(baseSetID);
				local allSetInfo = GetVariantSets(baseSetID);
				local insertBaseSet = true;
				for _, info in ipairs(allSetInfo) do
					if info.setID == baseSetID then
						insertBaseSet = false;
						break
					end
				end

				if insertBaseSet then
					table.insert(allSetInfo, baseSetInfo);
				end

				table.sort(allSetInfo, function(a, b)
					if a.uiOrder ~= b.uiOrder then
						return a.uiOrder < b.uiOrder;
					end
					return a.setID < b.setID;
				end);

				local tbl = {};
				for i = 1, 4 do
					tbl[i] = allSetInfo[i].setID;
				end
				ItemXSets[itemID] = tbl;
			end

			tooltip:AddLine(" ");

			local allCollected = true;

			for i, _setID in ipairs(ItemXSets[itemID]) do
				local appearances = GetSetPrimaryAppearances(_setID);
				local numCollected = 0;
				local numTotal = 0;
				for _, v in ipairs(appearances) do
					if v.collected then
						numCollected = numCollected + 1;
					end
					numTotal = numTotal + 1;
				end
				if numCollected >= numTotal then
					SetTooltipCollected(tooltip, DifficultyNames[i]);
				else
					allCollected = false;
					SetTooltipUncollected(tooltip, DifficultyNames[i], numCollected, numTotal);
				end
			end

			ReplaceTooltipLine(tooltip, ALREADY_KNOWN, nil);
			DeleteLineByMatching(tooltip, PATTERN_PARTIALLY_KNOWN);

			if allCollected then
				tooltip:AddLine(" ");
				tooltip:AddLine(ALREADY_KNOWN, 1, 0.125, 0.125, true);
			end

			return true;
		else
			--Generic Ensembles
			local appCol, appTotal, sourceCol, sourceTotal = CollectionCache:GetData(setID);
			local showItems = C_CVar.GetCVarBool("missingTransmogSourceInItemTooltips");
			if appCol and ((appCol < appTotal) or (showItems and sourceCol < sourceTotal)) then
				local found1, isLastLine1 = ReplaceTooltipLine(tooltip, ALREADY_KNOWN, " ");
				local found2, isLastLine2 = ReplaceLineByMatching(tooltip, PATTERN_PARTIALLY_KNOWN, " ");

				if not (isLastLine1 or isLastLine2) then
					tooltip:AddLine(" ");
				end

				if appCol < appTotal then
					tooltip:AddDoubleLine(L["Collected Appearances"], appCol.."/"..appTotal, 1, 1, 1, 1, 1, 1);
				elseif showItems then
					tooltip:AddDoubleLine(L["Collected Appearances"], appCol.."/"..appTotal, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5); --Show numbers instead of checkmark
				end

				if showItems then
					if sourceCol < sourceTotal and sourceTotal > appTotal then
						tooltip:AddDoubleLine(L["Collected Items"], sourceCol.."/"..sourceTotal, 1, 1, 1, 1, 1, 1);
					end
				end

				return true;
			end
		end
	end
	return false;
end


do	--ItemSubModule
	ItemSubModule.hasAltMode = true;

	function ItemSubModule:ProcessData(tooltip, itemID, itemLink)
		if self.enabled then
			return ProcessItemTooltip(tooltip, itemID, itemLink)
		else
			return false
		end
	end

	function ItemSubModule:GetDBKey()
		return "TooltipTransmogEnsemble"
	end

	function ItemSubModule:SetEnabled(enabled)
		self.enabled = enabled == true;
		GameTooltipItemManager:RequestUpdate();
	end

	function ItemSubModule:IsEnabled()
		return self.enabled == true
	end
end


do
	--local function ProcessItemTooltip_DialogueUI(tooltip, itemID, itemLink)
	--    return ProcessItemTooltip(tooltip, itemID, itemLink, true)
	--end

	local function EnableModule(state)
		ItemSubModule:SetEnabled(state);

		if state then
			GameTooltipItemManager:AddSubModule(ItemSubModule);
		end

		--if DialogueUIAPI and DialogueUIAPI.AddItemTooltipProcessorExternal then
		--    DialogueUIAPI.AddItemTooltipProcessorExternal(ProcessItemTooltip_DialogueUI);
		--end
	end

	local moduleData = {
		name = addon.L["ModuleName TooltipTransmogEnsemble"],
		dbKey = ItemSubModule:GetDBKey(),
		description = addon.L["ModuleDescription TooltipTransmogEnsemble"],
		toggleFunc = EnableModule,
		categoryID = 3,
		uiOrder = 1205,
		moduleAddedTime = 1755200000,
		categoryKeys = {
			"Collection",
		},
		searchTags = {
			"Tooltip", "Transmog",
		},
	};

	addon.ControlCenter:AddModule(moduleData);
end


LegionRaidEnsemble = {
--Pattern?: {n+1, n-2, n-1, n}

[241558] = true,     --Ensemble: Eagletalon Battlegear
[241566] = true,     --Ensemble: Vestments of Enveloped Dissonance
[241574] = true,     --Ensemble: Vestment of Second Sight
[241582] = true,     --Ensemble: Vestments of the Purifier
[241449] = true,     --Ensemble: Light's Vanguard Battleplate
[241465] = true,     --Ensemble: Regalia of the Dashing Scoundrel
[241473] = true,     --Ensemble: Bearmantle Battlegear
--[241607] = true,     --Ensemble: Regalia of the Chosen Dead
[241489] = true,     --Ensemble: Runebound Regalia
[241497] = true,     --Ensemble: Radiant Lightbringer Armor
[241505] = true,     --Ensemble: Regalia of the Skybreaker
[241513] = true,     --Ensemble: Fanged Slayer's Armor
[241521] = true,     --Ensemble: Stormheart Raiment
[241529] = true,     --Ensemble: Diabolic Raiment
[241537] = true,     --Ensemble: Regalia of the Arcane Tempest
[241545] = true,     --Ensemble: Battleplate of the Highlord
[241553] = true,     --Ensemble: Regalia of Shackled Elements
[241459] = true,     --Ensemble: Garb of Venerated Spirits
--[241601] = {182},     --Ensemble: Chains of the Chosen Dead
[241562] = true,     --Ensemble: Doomblade Battlegear
[241570] = true,     --Ensemble: Garb of the Astral Warden
[241578] = true,     --Ensemble: Legacy of Azj'aqir
[241586] = true,     --Ensemble: Regalia of Everburning Knowledge
[241445] = true,     --Ensemble: Juggernaut Battlegear
[241453] = true,     --Ensemble: Dreadwake Armor
[241461] = true,     --Ensemble: Serpentstalker Guise
[241469] = true,     --Ensemble: Chi-Ji's Battlegear
[241477] = true,     --Ensemble: Felreaper Vestments
[241485] = true,     --Ensemble: Gilded Seraph's Raiment
[241493] = true,     --Ensemble: Titanic Onslaught Armor
[241501] = true,     --Ensemble: Gravewarden Armaments
[241509] = true,     --Ensemble: Wildstalker Armor
[241517] = true,     --Ensemble: Xuen's Battlegear
[241525] = true,     --Ensemble: Demonbane Armor
[241533] = true,     --Ensemble: Vestments of Blind Absolution
--[241604] = {178},     --Ensemble: Garb of the Chosen Dead
[241549] = true,     --Ensemble: Dreadwyrm Battleplate
--[241597] = {186},     --Ensemble: Funerary Plate of the Chosen Dead
[241481] = true,     --Ensemble: Grim Inquisitor's Regalia
[241541] = true,     --Ensemble: Warplate of the Obsidian Aspect
};
