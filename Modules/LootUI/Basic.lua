local _, addon = ...
local L = addon.L;
local API = addon.API;


---@class LootUISystem
local LootUI = {};
addon.LootUI = LootUI;


LootUI.Templates = {};
LootUI.QualityColorGetter = API.GetItemQualityColor; -- Can be switched to ColorManager.GetColorDataForItemQuality


LootUI.Defination = {
	-- Constant
	SLOT_TYPE_CURRENCY = 3,
	SLOT_TYPE_CUSTOM = -1,      --Display custom info like a notifaction sent by another module
	SLOT_TYPE_MONEY = 10,       --Game value is 2, but we sort it to top
	SLOT_TYPE_OVERFLOW = 128,   --Display overflown currency
	SLOT_TYPE_REP = 9,          --Custom Value
	SLOT_TYPE_ITEM = 1,

	QUEST_TYPE_NEW = 2,
	QUEST_TYPE_ONGOING = 1,

	IS_CLASSIC = addon.IS_CLASSIC,

	AUTO_LOOT_ENABLE_TOOLTIP = true,


	-- Variable
	BG_OPACITY = 0.5,
	LOOT_UNDER_MOUSE = false,
	SHOW_ITEM_COUNT = false,
	FADE_DELAY_PER_ITEM = 0.2,
	MAX_ITEM_PER_PAGE = 5;
	LOW_FRAME_STRATA = false,
	MERGE_SIMILAR_ITEMS = true,
	SHOW_ALL_CURRENCY_CHANGE = false,
	FORCE_AUTO_LOOT = true,
	USE_MOG_MARKER = true,
	TAKE_ALL_KEY = "E";
	TAKE_ALL_MODIFIER_KEY = nil;	--"LALT"
};


-- The MainFrame is created upfront here. Its methods can be found in MainFrame.lua
local MainFrame = CreateFrame("Frame", "PlumberLootWindow", UIParent);
LootUI.MainFrame = MainFrame;
MainFrame:Hide();


-- Our UI dimensions are determined by the primary fontSize
local Formatter = {};
LootUI.Formatter = Formatter;
do
	Formatter.tostring = tostring;
	Formatter.strlen = string.len;

	function Formatter:Init()
		local fontSize = addon.GetDBValue("LootUI_FontSize");
		Formatter:CalculateDimensions(fontSize);

		if not self.DummyFontString then
			self.DummyFontString = MainFrame:CreateFontString(nil, "BACKGROUND", "PlumberLootUIFont");
			self.DummyFontString:Hide();
			self.DummyFontString:SetPoint("TOP", UIParent, "BOTTOM", 0, -64);
		end
	end

	function Formatter:CalculateDimensions(fontSize)
		if not (type(fontSize) == "number" and fontSize and fontSize >= 10 and fontSize <= 16) then
			fontSize = nil;
		end

		local baseFont = _G.ObjectiveTrackerFont14 or _G.GameTooltipHeader or _G.GameFontNormal;
		local fontFile, defaultFontSize = baseFont:GetFont();
		local normalizedFontSize;

		if not fontSize then
			fontSize = defaultFontSize;
		end

		local Round = API.Round;

		local fontObject = PlumberLootUIFont;
		local fontFlag = "OUTLINE";
		fontObject:SetFont(fontFile, Round(fontSize), fontFlag);
		fontObject:SetShadowOffset(0, 0);

		local locale = GetLocale();
		if locale == "zhCN" or locale == "zhTW" then
			normalizedFontSize = Round(0.8 * fontSize);
		else
			normalizedFontSize = fontSize;
		end

		self.BASE_FONT_SIZE = fontSize;                      --GameFontNormal
		self.ICON_SIZE = Round(32/12 * normalizedFontSize);
		self.TEXT_BUTTON_HEIGHT = Round(16/12 * normalizedFontSize);
		self.ICON_BUTTON_HEIGHT = self.ICON_SIZE;
		self.ICON_TEXT_GAP = Round(self.ICON_SIZE / 4);
		self.DOT_SIZE = Round(1.5 * normalizedFontSize);
		self.COUNT_NAME_GAP = Round(0.5 * normalizedFontSize);
		self.NAME_WIDTH = Round(16 * fontSize);
		self.BUTTON_WIDTH = self.ICON_SIZE + self.ICON_TEXT_GAP + fontSize + self.COUNT_NAME_GAP + self.NAME_WIDTH;
		self.BUTTON_SPACING = 12;
		self.UI_BUTTON_HEIGHT = Round(fontSize + 2 * 12);

		self.numberWidths = {};

		if MainFrame.Header then
			if fontSize < defaultFontSize then
				MainFrame.Header:SetFont(fontFile, fontSize, "");
			else
				MainFrame.Header:SetFont(fontFile, defaultFontSize, "");
			end
		end
	end

	function Formatter:GetNumberWidth(number)
		number = number or 0;
		local digits = self.strlen(self.tostring(number));

		if not self.numberWidths[digits] then
			local text = "+";
			for i = 1, digits do
				text = text .. "8";
			end
			text = text.." ";
			self.DummyFontString:SetText(text);
			self.numberWidths[digits] = API.Round(self.DummyFontString:GetWidth());
		end

		return self.numberWidths[digits];
	end

	function Formatter:GetPixelPerfectScale()
		if not self.pixelPerfectScale then
			local _, screenHeight = GetPhysicalScreenSize();
			self.pixelPerfectScale = 768 / screenHeight;
		end
		return self.pixelPerfectScale;
	end

	function Formatter:PixelPerfectTextureSlice(object)
		object:SetScale(self:GetPixelPerfectScale());
	end

	function Formatter:PixelSizeForScale(pixelSize, objectScale)
		local scale0 = self:GetPixelPerfectScale();
		return pixelSize * scale0 / objectScale;
	end
end


-- Merge similar items (e.g. junks) into one entry
do
	local ItemToGroupID = {};
	local ItemGroupName = {};

	-- Not implemented for now, for these were items from Legion Remix.
	--[[
	local SimilarItemData = {
		{	--Epoch
			items = {242516, 246937, 242515, 242513, 242508, 242501,242510, 242503, 242505, 242502, 242514, 242512, 242506, 242507, 242504, 242509, 242511},
			name = L["Epoch Mementos"],
		},

		{	--Timeless Scroll
			items = {217605, 217606, 217607, 217608, 217730, 217731, 217901, 217928, 217929, 217956},
			name = L["Timeless Scrolls"],
		},
	};

	for groupID, v in ipairs(SimilarItemData) do
		ItemGroupName[groupID] = v.name;
		for _, itemID in ipairs(v.items) do
			ItemToGroupID[itemID] = groupID;
		end
	end
	SimilarItemData = nil;
	--]]

	function LootUI.MergeSimilarItems(d1, d2)
		if not (d1.id and d2.id) then return; end

		local group1 = ItemToGroupID[d1.id];
		local group2 = ItemToGroupID[d2.id];

		if (d1.quality == 0 and d2.quality == 0) or (group1 and group1 == group2) then
			local idToData = {};
			local v;

			if d1.mergedData then
				for _, data in ipairs(d1.mergedData) do
					v = idToData[data.id];
					if v then
						v.quantity = v.quantity + data.quantity;
					else
						idToData[data.id] = data;
					end
				end
			else
				v = idToData[d1.id];
				if v then
					v.quantity = v.quantity + d1.quantity;
				else
					idToData[d1.id] = d1;
				end
			end

			if d2.mergedData then
				for _, data in ipairs(d2.mergedData) do
					v = idToData[data.id];
					if v then
						v.quantity = v.quantity + data.quantity;
					else
						idToData[data.id] = data;
					end
				end
			else
				v = idToData[d2.id];
				if v then
					v.quantity = v.quantity + d2.quantity;
				else
					idToData[d2.id] = d2;
				end
			end

			local n = 0;
			local mergedData = {};

			for id, data in pairs(idToData) do
				n = n + 1;
				mergedData[n] = data;
			end

			d1.mergedData = mergedData;
			d2.mergedData = nil;

			return true;
		else
			return false;
		end
	end

	function LootUI.GetItemGroupID(itemID)
		return ItemToGroupID[itemID];
	end

	function LootUI.GetItemGroupName(itemID)
		return ItemGroupName[itemID];
	end
end


-- Determine if item is "Rare" and derserve a Glow animating
do
	local RareItems = {
		--[210796] = true,    --debug
		[224025] = true,    --Crackling Shard
	};

	local TertiaryStats = {
		--"ITEM_MOD_STAMINA_SHORT", -- debug
		"ITEM_MOD_CR_LIFESTEAL_SHORT",
		"ITEM_MOD_CR_AVOIDANCE_SHORT",
		"ITEM_MOD_CR_SPEED_SHORT",
		"ITEM_MOD_CR_STURDINESS_SHORT",
	};

	local ItemStatExclusion = {
		-- Items that come with tertiaries
		[251783] = "ITEM_MOD_CR_SPEED_SHORT",	-- Lost Idol of the Hash'ey
		[262754] = "ITEM_MOD_CR_SPEED_SHORT",	-- Void Pearl of Haste
	};

	---Determine if is the lootData contains rare item
	---@return boolean? isRare
	---@return string? itemSubtitle Show the bonus tertiary stat name
	function LootUI.IsRareItem(data)
		if RareItems[data.id] then
			return true;
		elseif data.classID == 15 and (data.subclassID == 2 or data.subclassID == 5) then
			-- CompanionPet/Mount
			return true;
		elseif data.classID == 17 then
			-- Battlepet
			return true;
		elseif (data.classID == 2 or data.classID == 4) and data.link and C_Item.GetItemStats then
			-- Equipment with tertiary stats. Retail only.
			local stats = C_Item.GetItemStats(data.link);
			if stats then
				local excludeStat = ItemStatExclusion[data.id];
				for _, k in ipairs(TertiaryStats) do
					if stats[k] and k ~= excludeStat then
						local subtitle = _G[k];
						return true, subtitle;
					end
				end
			end
		end
	end
end


-- SortFunc for lootData
do
	local CLASS_SORT_ORDER = {
		[0] = 0,    --Consumable
		[1] = 1,    --Container
		[2] = 90,   --Weapon
		[3] = 3,    --Gem
		[4] = 80,   --Armor
		[5] = 5,    --Reagent
		[6] = 6,    --Projectile
		[7] = 7,    --Tradegoods
		[8] = 8,    --ItemEnhancement
		[9] = 9,    --Recipe
		[10] = 10,  --CurrencyTokenObsolete
		[11] = 11,  --Quiver
		[12] = 99,  --Quest Item
		[13] = 13,  --Key
		[14] = 14,  --PermanentObsolete
		[15] = 15,  --Miscellaneous
		[16] = 16,  --Glyph
		[17] = 17,  --Battlepet
		[18] = 18,  --WoWToken
		[19] = 19,  --Profession
	};

	local function SortFunc_LootSlot(a, b)
		if a.looted ~= b.looted then
			return b.looted
		end

		if a.slotType ~= b.slotType then
			return a.slotType > b.slotType
		end

		if a.questType ~= b.questType then
			return a.questType > b.questType
		end

		if a.quality ~= b.quality then
			return a.quality > b.quality
		end

		if (a.classID ~= b.classID) and (CLASS_SORT_ORDER[a.classID] and CLASS_SORT_ORDER[b.classID]) and (CLASS_SORT_ORDER[a.classID] ~= CLASS_SORT_ORDER[b.classID]) then
			return CLASS_SORT_ORDER[a.classID] > CLASS_SORT_ORDER[b.classID]
		end

		if a.name ~= b.name then
			return a.name < b.name
		end

		if a.craftQuality ~= b.craftQuality then
			return a.craftQuality > b.craftQuality
		end

		return a.slotIndex < b.slotIndex
	end

	LootUI.SortFunc_LootSlot = SortFunc_LootSlot;
end
