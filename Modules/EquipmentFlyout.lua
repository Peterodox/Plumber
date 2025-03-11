-- [Shelved. Players prefer to use PaperDollFrame or Bags to select items] Display a more organized EquipmentFlyout for ItemUpgradeSlot (spend crests to upgrade item)
-- Automatically open PaperDollFrame (This could be an issue for players with low-resolution, limited screen size)


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
--11.1.5: C_Item.GetItemUpgradeInfo


local TierOrder = {
	[L["Upgrade Track 1"] or "Adventurer"] = 1,
	[L["Upgrade Track 2"] or "Explorer"] = 2,
	[L["Upgrade Track 3"] or "Veteran"] = 3,
	[L["Upgrade Track 4"] or "Champion"] = 4,
	[L["Upgrade Track 5"] or "Hero"] = 5,
	[L["Upgrade Track 6"] or "Myth"] = 6,
};


local MainFrame = CreateFrame("Frame");
MainFrame:Hide();


local ItemUtil = CreateFrame("Frame");	--Derivative of Blizzard_FrameXMLUtil/ItemUtil.lua

function ItemUtil.GetContainerNumSlots(bag)
	local currentNumSlots = GetContainerNumSlots(bag);
	local maxNumSlots = currentNumSlots;
	if bag == 0 and not IsAccountSecured() then
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
		for bag = 0, 4 do	--Enum.BagIndex.Backpack = 0
			for slot = 1, ItemUtil.GetContainerNumSlots(bag) do
				if not itemLocation then
					itemLocation = ItemLocation:CreateEmpty();
				end
				itemLocation:SetBagAndSlot(bag, slot);
				if DoesItemExist(itemLocation) then
					if ruleFunc(itemLocation) then
						n = n + 1;
						tbl[n] = itemLocation;
						itemLocation.rawOrder = n;
						itemLocation.fromBag = true;
						itemLocation = nil;
					end
				end
			end
		end
	end

	if rule.inventory then	--equipped by player
		for slot = 1, 19 do	--INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED
			if not itemLocation then
				itemLocation = ItemLocation:CreateEmpty();
			end
			itemLocation:SetEquipmentSlot(slot);
			if DoesItemExist(itemLocation) then
				if ruleFunc(itemLocation) then
					n = n + 1;
					tbl[n] = itemLocation;
					itemLocation.rawOrder = n;
					itemLocation.fromInventory = true;
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
		itemLocation.dataInstanceID = tooltipInfo.dataInstanceID;
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
				tierIndex = TierOrder[tierName],
			};

			itemLocation.levelInfo = levelInfo;

			print(tooltipInfo.lines[1].leftText, levelInfo.itemLevel, levelInfo.tierName, levelInfo.tierCurrent, levelInfo.tierMax);	--debug

			return levelInfo
		end
	end

	ItemUtil:RequestItemLevelInfo(itemLocation);
end

do	--Tooltip Event
	function ItemUtil:OnUpdate(elapsed)
		self.t = self.t + elapsed;
		if self.t >= 0.2 then
			self.t = 0;

			for dataInstanceID, itemLocation in pairs(self.queuedDataInstanceIDs) do
				if itemLocation and not itemLocation.levelInfo then
					if ItemUtil.GetLevelInfo(itemLocation) then
						self.queuedDataInstanceIDs[dataInstanceID] = nil;
					end
				else
					self.queuedDataInstanceIDs[dataInstanceID] = nil;
				end
			end

			for itemLocation, state in pairs(self.queuedItems) do
				if state and not itemLocation.levelInfo then
					if ItemUtil.GetLevelInfo(itemLocation) then
						self.queuedItems[itemLocation] = nil;
					end
				else
					self.queuedItems[itemLocation] = nil;
				end
			end

			self:CheckCompletion();
		end
	end

	function ItemUtil:ClearRequestItem(itemLocation)
		if self.queuedDataInstanceIDs then
			for dataInstanceID, il in pairs(self.queuedDataInstanceIDs) do
				if il == itemLocation then
					self.queuedDataInstanceIDs[dataInstanceID] = nil;
					break
				end
			end
		end

		if self.queuedItems then
			for il, state in pairs(self.queuedItems) do
				if il == itemLocation then
					self.queuedItems[il] = nil;
					break
				end
			end
		end

		self:CheckCompletion();
	end

	function ItemUtil:RequestItemLevelInfo(itemLocation)
		if not itemLocation.queryTimes then
			itemLocation.queryTimes = 0;
		end

		if itemLocation.queryTimes > 5 then
			self:ClearRequestItem(itemLocation);
			return
		else
			itemLocation.queryTimes = itemLocation.queryTimes + 1;
		end

		if not self.queuedItems then
			self.queuedItems = {};
		end
		if not self.queuedDataInstanceIDs then
			self.queuedDataInstanceIDs = {};
		end

		if itemLocation.dataInstanceID then
			self.queuedDataInstanceIDs[itemLocation.dataInstanceID] = itemLocation;
			if self.queuedItems[itemLocation] then
				self.queuedItems[itemLocation] = nil;
			end
		else
			self.queuedItems[itemLocation] = true;
		end

		self:RegisterEvent("TOOLTIP_DATA_UPDATE");
	end

	function ItemUtil:CheckCompletion()
		local anyEntry;

		if self.queuedDataInstanceIDs then
			for dataInstanceID, itemLocation in pairs(self.queuedDataInstanceIDs) do
				anyEntry = true;
				break
			end
		end

		if self.queuedItems then
			for itemLocation, state in pairs(self.queuedItems) do
				if state then
					anyEntry = true;
					break
				end
			end
		end

		if anyEntry then
			self:OnAllDataReceived();
		end
	end

	function ItemUtil:OnAllDataReceived()
		print("FINISHED");
		self:SetScript("OnUpdate", nil);
		self.t = 0;
		self:UnregisterEvent("TOOLTIP_DATA_UPDATE");
		self.queuedDataInstanceIDs = nil;
		self.queuedItems = nil;
		if ItemUtil.filteredItems and MainFrame:IsShown() then
			MainFrame:DisplayItems(ItemUtil.filteredItems);
		end
	end

	function ItemUtil:OnEvent(event, ...)
		if event == "TOOLTIP_DATA_UPDATE" then
			local dataInstanceID = ...
			if self.queuedDataInstanceIDs and self.queuedDataInstanceIDs[dataInstanceID] then
				local itemLocation = self.queuedDataInstanceIDs[dataInstanceID];
				if ItemUtil.GetLevelInfo(itemLocation) then
					self.queuedDataInstanceIDs[dataInstanceID] = nil;
				end
			elseif self.queuedItems then
				self.t = 0;
			end
		end
	end
end


local SortFuncs = {};
do
	function SortFuncs.TierItemLevel(a, b)
		if a.levelInfo and b.levelInfo then
			local p, q;
			p, q = a.tierIndex, b.tierIndex;
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

			if a.fromInventory ~= b.fromInventory then
				return a.fromInventory
			elseif a.bagID and b.bagID then
				if a.bagID ~= b.bagID then
					return a.bagID < b.bagID
				end
				return a.slotIndex < b.slotIndex
			else
				return a.rawOrder < b.rawOrder
			end
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
		inventory = true,	--equipped
	};

	local items, numItems = ItemUtil.GetItemLocationsByRule(rule);
	local itemLevel, upgradeText;
	local allDataReceived = true;

	for i, itemLocation in ipairs(items) do
		ItemUtil.GetLevelInfo(itemLocation);
		if not itemLocation.levelInfo then
			allDataReceived = false;
		end
	end

	table.sort(items, SortFuncs.TierItemLevel);
	ItemUtil.filteredItems = items;

	if allDataReceived then
		print("|cff19ff19----All Data Received----|r")
		ItemUtil:OnAllDataReceived()
	else
		print("|cffff4800----Incomplete Data----|r")
	end

	return items, allDataReceived
end


local ItemUpgradeModule = {};

do	--Item Upgrade Frame
	local INTERACTION_TYPE = Enum.PlayerInteractionType.ItemUpgrade;

	function MainFrame:OnShow()
		if not InCombatLockdown() then
			C_Timer.After(0, function()	--Crucial for PaperDollFrame layout
				ToggleCharacter("PaperDollFrame", true);	--Show PaperDollFrame when opening ItemUpgradeFrame
			end)

			--ItemUtil.GetItemsForUpgrade();	--debug
		end
	end
	MainFrame:SetScript("OnShow", MainFrame.OnShow);

	function MainFrame:OnHide()
		ItemUtil.filteredItems = nil;
		self:ReleaseItemButtons();
		if not InCombatLockdown() then
			HideUIPanel(CharacterFrame);
		end
	end
	MainFrame:SetScript("OnHide", MainFrame.OnHide);

	function MainFrame:OnEvent(event, ...)
		if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
			local interactionType = ...;
			if interactionType == INTERACTION_TYPE then
				if not self.hooked then
					C_Timer.After(0, function()
						if (not self.hooked) and ItemUpgradeFrame then
							self.hooked = true;
							self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW");

							ItemUpgradeFrame:HookScript("OnShow", function()
								MainFrame:Show();
							end);
							ItemUpgradeFrame:HookScript("OnHide", function()
								MainFrame:Hide();
							end);

							if ItemUpgradeFrame:IsShown() then
								MainFrame:Show();
							else
								MainFrame:Hide();
							end
						end
					end);
				end
			end
		end
	end

	function MainFrame:DisplayItems(items)
		if self.itemButtonPool then
			self:ReleaseItemButtons();
		else
			local function createObjectFunc()
				return CreateFrame("Button", nil, self, "PlumberEquipmentFlyoutItemButton");
			end
			self.itemButtonPool = API.CreateObjectPool(createObjectFunc);
		end

		local perRow = 5;
		local x, y = 0, 0;
		local button;

		--debug
		self:ClearAllPoints();
		self:SetSize(8, 8);
		self:SetPoint("TOPLEFT", UIParent, "CENTER", -96, 96);

		local scale = API.GetPixelForScale(1);
		local buttonSize = 68 * scale;
		local buttonGap = 4 * scale;	--6

		for i, itemLocation in ipairs(items) do
			button = self.itemButtonPool:Acquire();
			button:SetItem(itemLocation);
			button:SetPoint("TOPLEFT", self, "TOPLEFT", x * (buttonSize + buttonGap), -y * (buttonSize + buttonGap));
			button:SetEffectiveScale(scale);
			x = x + 1;
			if x >= perRow then
				x = 0;
				y = y + 1;
			end
		end

		local numCol = math.min(perRow, #items);
		local numRow = y + 1;
		self:SetSize((buttonSize + buttonGap) * numCol - buttonGap, (buttonSize + buttonGap) * numRow - buttonGap);

		--self:SetScale(API.GetPixelForScale(1));
	end

	function MainFrame:ReleaseItemButtons()
		if self.itemButtonPool then
			self.itemButtonPool:ReleaseAll();
		end
	end


	function ItemUpgradeModule.Enable(state)
		if state and not ItemUpgradeModule.enabled then
			ItemUpgradeModule.enabled = true;
			if not MainFrame.hooked then
				MainFrame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW");
			end
			MainFrame:SetScript("OnEvent", MainFrame.OnEvent);
		elseif (not state) and ItemUpgradeModule.enabled then
			ItemUpgradeModule.enabled = false;
			MainFrame:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW");
			MainFrame:SetScript("OnEvent", nil);
		end
	end

	ItemUpgradeModule.Enable(true);
end


do	--ItemButton
	local GetItemIcon = C_Item.GetItemIcon;		--Use itemLocation
	local GetItemQuality = C_Item.GetItemQuality;
	local GetItemQualityColor = C_Item.GetItemQualityColor;


	PlumberEquipmentFlyoutItemButtonMixin = {};

	function PlumberEquipmentFlyoutItemButtonMixin:OnLoad()
		local texture = "Interface/AddOns/Plumber/Art/Frame/EquipmentFlyout";
		self.Border:SetTexture(texture);
		self.Border:SetTexCoord(0, 80/512, 0, 80/512);
		self.Overlay:SetTexture(texture);
		self.Overlay:SetTexCoord(80/512, 160/512, 0, 80/512);
		self.TierIcon:SetTexture(texture);
		self.TierIcon:SetTexCoord(0, 0.0001, 0, 0.0001);
	end

	function PlumberEquipmentFlyoutItemButtonMixin:SetItem(itemLocation)
		self.Icon:SetTexture(GetItemIcon(itemLocation));
		self.itemLocation = itemLocation;

		local quality = GetItemQuality(itemLocation) or 1;
		local r, g, b = GetItemQualityColor(quality);
		self.Overlay:SetVertexColor(r, g, b);
		--self.Text:SetText(itemLocation.levelInfo.itemLevel);

		local info = itemLocation.levelInfo;
		self.Text:SetText(string.format("%s/%s", info.tierCurrent, info.tierMax));
		local ti = info.tierIndex;
		self.TierIcon:SetTexCoord((ti - 1) * 64/512, ti * 64/512, 80/512, 144/512);
	end

	function PlumberEquipmentFlyoutItemButtonMixin:ClearItem()
		self.Icon:SetTexture(nil);
		self.Text:SetText(nil);
		self.itemLocation = nil;
	end

	function PlumberEquipmentFlyoutItemButtonMixin:OnRemoved()
		self:ClearItem();
	end

	function PlumberEquipmentFlyoutItemButtonMixin:SetEffectiveScale(scale)
		self:SetSize(68 * scale, 68 * scale);
		self.Border:SetSize(80 * scale, 80 * scale);
		self.Overlay:SetSize(80 * scale, 80 * scale);
		self.Icon:SetSize(64 * scale, 64 * scale);
		self.TierIcon:SetSize(64 * scale, 64 * scale);
		self.TierIcon:SetPoint("CENTER", self, "CENTER", -4*scale, 4*scale);
	end
end