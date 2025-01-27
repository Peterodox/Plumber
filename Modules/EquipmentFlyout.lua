--Display a more organized EquipmentFlyout for ItemUpgradeSlot (spend crests to upgrade item)


local _, addon = ...
local API = addon.API;
local L = addon.L;


local PATTERN_ILVL = L["Match Pattern Item Level"];
local PATTERN_UPGRADE = L["Match Pattern Item Upgrade Tooltip"];


local match = string.match;
local ipairs = ipairs;
local tonumber = tonumber;
local GetContainerNumSlots = C_Container.GetContainerNumSlots;
local DoesItemExist = C_Item.DoesItemExist;
local ItemLocation = ItemLocation;
local CanUpgradeItem = C_ItemUpgrade.CanUpgradeItem;
local GetItemLink = C_Item.GetItemLink;
local TooltipInfp_GetBagItem = C_TooltipInfo.GetBagItem;
local TooltipInfp_GetInventoryItem = C_TooltipInfo.GetInventoryItem;


local ItemUtil = {};	--Derivative of Blizzard_FrameXMLUtil/ItemUtil.lua

function ItemUtil.GetContainerNumSlots(bag)
	local currentNumSlots = GetContainerNumSlots(bag);
	local maxNumSlots = currentNumSlots;
	if bag == Enum.BagIndex.Backpack and not IsAccountSecured() then
		maxNumSlots = currentNumSlots + 4;
	end
	return maxNumSlots, currentNumSlots
end

function ItemUtil.IterateBagSlots(bag, callback)
	local itemLocation = ItemLocation:CreateEmpty();
	for slot = 1, ItemUtil.GetContainerNumSlots(bag) do
		itemLocation:SetBagAndSlot(bag, slot);
		if DoesItemExist(itemLocation) then
			if callback(itemLocation) then
				return true
			end
		end
	end
	return false
end

function ItemUtil.IterateInventorySlots(firstSlot, lastSlot, callback)
	local itemLocation = ItemLocation:CreateEmpty();
	for slot = firstSlot, lastSlot do
		itemLocation = ItemLocation:SetEquipmentSlot(slot);
		if DoesItemExist(itemLocation) then
			if callback(itemLocation) then
				return
			end
		end
	end
end

function ItemUtil.GetItemLocationsByRule(rule)
	--rule = {ruleFunc = function, bag = boolean, inventory = boolean}
	local ruleFunc = rule.ruleFunc;
	local tbl = {};

	local itemLocation;
	local n = 0;

	if rule.bag then
		for bag = Enum.BagIndex.Backpack, NUM_TOTAL_BAG_FRAMES do
			for slot = 1, ItemUtil.GetContainerNumSlots(bag) do
				if not itemLocation then
					itemLocation = ItemLocation:CreateEmpty();
				end
				itemLocation:SetBagAndSlot(bag, slot);
				if DoesItemExist(itemLocation) then
					if ruleFunc(itemLocation) then
						itemLocation.fromBag = true;
						n = n + 1;
						tbl[n] = itemLocation;
						itemLocation = nil;
					end
				end
			end
		end
	end

	if rule.inventory then	--equipped by player
		for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
			if not itemLocation then
				itemLocation = ItemLocation:CreateEmpty();
			end
			itemLocation:SetEquipmentSlot(slot);
			if DoesItemExist(itemLocation) then
				if ruleFunc(itemLocation) then
					itemLocation.fromInventory = true;
					n = n + 1;
					tbl[n] = itemLocation;
					itemLocation = nil;
				end
			end
		end
	end

	return tbl, n
end

function ItemUtil.GetLevelInfo(itemLocation)
	--Expansive call
	local tooltipInfo;

	if itemLocation.fromBag then
		tooltipInfo = TooltipInfp_GetBagItem(itemLocation:GetBagAndSlot());
	else
		tooltipInfo = TooltipInfp_GetInventoryItem("player", itemLocation:GetEquipmentSlot(), true);	--unit, slot, hideUselessStats
	end

	if tooltipInfo and tooltipInfo.lines then
		--Name, (Season Difficulty), Item Level, Upgrade Level
		local itemLevel, tierName, tierCurrent, tierMax;
		for i = 2, 4 do
			if not itemLevel then
				itemLevel = match(tooltipInfo.lines[i].leftText, PATTERN_ILVL);
			end
			if not tierName then
				tierName, tierCurrent, tierMax = match(tooltipInfo.lines[i].leftText, PATTERN_UPGRADE);
			end
		end
		if itemLevel and tierName then
			local levelInfo = {
				itemLevel = tonumber(itemLevel),
				tierName = tierName,
				tierCurrent = tonumber(tierCurrent),
				tierMax = tonumber(tierMax),
			};
			return levelInfo
		end
	end
end


local SortFuncs = {};
do
	local TierOrder = {
		[L["Upgrade Track 1"] or "Adventurer"] = 1,
		[L["Upgrade Track 2"] or "Explorer"] = 2,
		[L["Upgrade Track 3"] or "Veteran"] = 3,
		[L["Upgrade Track 4"] or "Champion"] = 4,
		[L["Upgrade Track 5"] or "Hero"] = 5,
		[L["Upgrade Track 6"] or "Myth"] = 6,
	};

	function SortFuncs.TierItemLevel(a, b)
		if a.levelInfo and b.levelInfo then
			local p, q;
			p, q = TierOrder[a.levelInfo.tierName], TierOrder[b.levelInfo.tierName];
			if p and q and (p ~= q) then
				return p > q
			end
			p, q = a.levelInfo.itemLevel, b.levelInfo.itemLevel;
			if p ~= q then
				return p > q
			end

			p, q = a.levelInfo.tierCurrent, b.levelInfo.tierCurrent;
			if p ~= q then
				return p > q
			end

			if a.bagID ~= b.bagID then
				return a.bagID < b.bagID
			end

			return a.slotIndex < b.slotIndex
		else
			return a.levelInfo or b.levelInfo
		end
	end
end


function ItemUtil.GetItemsForUpgrade()
	local rule = {
		ruleFunc = function(itemLocation)
			return CanUpgradeItem(itemLocation)
		end,
		bag = true,
		inventory = false,
	};

	local items, numItems = ItemUtil.GetItemLocationsByRule(rule);
	local itemLevel, upgradeText;

	for i, itemLocation in ipairs(items) do
		itemLocation.levelInfo = ItemUtil.GetLevelInfo(itemLocation);
	end

	table.sort(items, SortFuncs.TierItemLevel);

	for i, itemLocation in ipairs(items) do
		if itemLocation.levelInfo then
			print(itemLocation.levelInfo.itemLevel, itemLocation.levelInfo.tierName, itemLocation.levelInfo.tierCurrent, itemLocation.levelInfo.tierMax);
		end
	end

	return items
end


--function TTTT()
--	ItemUtil.GetItemsForUpgrade()
--end


do
	local CustomLink = {};

	CustomLink.typeName = "Test";
	CustomLink.colorCode = "66bbff";	--LINK_FONT_COLOR

	function CustomLink.callback(arg1, arg2, arg3)
		print(arg1, arg2, arg3);
	end

	API.AddCustomLinkType(CustomLink.typeName, CustomLink.callback, CustomLink.colorCode);

	function CustomLink.GenerateLink(arg1, arg2, arg3)
		return API.GenerateCustomLink(CustomLink.typeName, L["Click To See Details"], arg1, arg2, arg3);
	end
end