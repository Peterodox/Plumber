local _, addon = ...
local LandingPageUtil = addon.LandingPageUtil; ---@class LandingPageUtil


---@class ResourceListEntry
---@field currencyID number? This entry is a currency
---@field itemID number? This entry is an item
---@field hasWeeklyCap boolean? If true, check the currency's weekly cap and colorize it if applicable
---@field shownIfOwned boolean? Valid if quantity > 0
---@field uiMapID number|table? Valid if on specific maps
---@field shownInDelves boolean? Valid if in a delve
---@field conditionFunc function? A custom function to determine if the entry is valid
---@field appendTooltipFunc function? Append extra info to the tooltip
---@field usableItemID number? Right-click to use an item by ID
---@field criteriaFunc function? A custom function to determine if the "usable item" should be used
---@field hidden boolean? Ignore this entry if true
---@field isMinor boolean? Unused. If true, there will be extra padding to the left of the name
---@field isHeader boolean? Classic Only. This entry is a header
---@field name string? The header's name
---@field faction number? This entry is a reputation bar


--Greedy Emissary Events
--[[
local IsBaseSetCollected = C_TransmogSets.IsBaseSetCollected;

local IsSetCollected;
local HellstoneTransmogSets = {
	4567, 4566, 4571, 4562, 4563, 4570, 4565, 4574, 4572, 4568, 4569, 4573, 4564,
};

local function HasUncollectedSets()
	local collected;
	if not IsSetCollected then
		IsSetCollected = {};
		for _, transmogSetID in ipairs(HellstoneTransmogSets) do
			collected = IsBaseSetCollected(transmogSetID);
			if not collected then
				IsSetCollected[transmogSetID] = false;
			end
		end
	end

	local anyUncollected;
	for transmogSetID in pairs(IsSetCollected) do
		collected = IsBaseSetCollected(transmogSetID);
		if collected then
			IsSetCollected[transmogSetID] = nil;
		else
			anyUncollected = true;
		end
	end
	return anyUncollected
end

local function ShowUncollectedSets(tooltip)
	if HasUncollectedSets() then
		local total = 0;
		for transmogSetID in pairs(IsSetCollected) do
			total = total + 1;
		end
		tooltip:AddLine(addon.L["Uncollected Set Counter Format"]:format(total), CONTEXT_FEEDBACK_COLOR);
		return true
	end
end
--]]


local function CreateCurrencyQuantityCriteria(currencyID, numRequired)
	return function()
		local info = C_CurrencyInfo.GetCurrencyInfo(currencyID);
		return info and info.quantity and info.quantity >= numRequired;
	end
end


do  --MID
	---@type ResourceListEntry[]
	local ResourceList = {
		{itemID = 273000},		--Corrosive Soul
		{currencyID = 3448},	--Corrosive Coin
		{currencyID = 3028},    --Restored Coffer Key
		{currencyID = 3310, hasWeeklyCap = true, usableItemID = 267291, criteriaFunc = CreateCurrencyQuantityCriteria(3310, 100)},	--Coffer Key Shard. Use [Coffer Key Glue]
		{currencyID = 3316},    --Voidlight Marl
		{currencyID = 3363, shownIfOwned = true},	--Community Coupons
		{currencyID = 3405, shownIfOwned = true},	--Field Accolade

		{itemID = 242241, uiMapID = 2395},   		--Latent Arcana
		{itemID = 246951, uiMapID = 2405},   		--Stormarion Core
		{currencyID = 3546, uiMapID = {2509, 2512}, shownIfOwned = true},		--Coiled Filament

		{currencyID = 3392},	--Remnant of Anguish
		{currencyID = 2803},	--Undercoin

		{currencyID = 3379, shownIfOwned = true},   --Brimming Arcana
		{currencyID = 3376, hasWeeklyCap = true},   --Shard of Dundun
		{currencyID = 3377, shownIfOwned = true},   --Unalloyed Abundance

		{currencyID = 1602, shownIfOwned = true},   --Conquest
		{currencyID = 1792, shownIfOwned = true},   --Honor
		{currencyID = 2123, shownIfOwned = true},   --Bloody Tokens
		{currencyID = 2797, shownIfOwned = true},   --Trophy of Strife
	};

	local function AddEntry(key, id, shownIfOwned, hasWeeklyCap)
		table.insert(ResourceList, 1, {
			[key] = id;
			shownIfOwned = shownIfOwned,
			hasWeeklyCap = hasWeeklyCap,
		});
	end

	if addon.ItemUpgradeConstant.CatalystCurrencyID then
		AddEntry("currencyID", addon.ItemUpgradeConstant.CatalystCurrencyID, true);
	end

	AddEntry("currencyID", 3418, nil, true);	--Nebulous Voidcore (Bonus Rolls) Changed to a new token in Season 2?

	LandingPageUtil.AddExpansionData(12, "resource", ResourceList);
end


do  --TWW
	local ResourceList = {
		{currencyID = 3269, shownIfOwned = true},
		{currencyID = 3028},    --Restored Coffer Key
		{itemID = 245653, isMinor = false},   --Coffer Key Shard
		{itemID = addon.ItemUpgradeConstant.RadiantEchoItemID},      --Radiant Echo

		{currencyID = 1602, shownIfOwned = true},    --Conquest
		{currencyID = 1792, shownIfOwned = true},    --Honor

		{currencyID = 3149, shownIfOwned = true},    --Displaced Corrupted Mementos
		{currencyID = 2815},    --Resonance Crystals
		{currencyID = 3218},    --Empty Kaja'Cola Can
		{currencyID = 3226, shownIfOwned = true},    --Market Research
		{currencyID = 3090, shownIfOwned = true},    --Flame-Blessed Iron
		{currencyID = 3056},    --Kej
		--{currencyID = 3055},      --Mereldar Derby Mark
		{currencyID = 2803},    --Undercoin

		---{isHeader = true, name = PVP},
		{currencyID = 2123, shownIfOwned = true},    --Bloody Tokens
		{currencyID = 2797, shownIfOwned = true},    --Trophy of Strife

		--{currencyID = 3309, conditionFunc = HasUncollectedSets, appendTooltipFunc = ShowUncollectedSets},    --Hellstone Shard (Greedy Emissary)
	};

	LandingPageUtil.AddExpansionData(11, "resource", ResourceList);
end
