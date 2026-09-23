local _, addon = ...
local L = addon.L;
local API = addon.API;
local LootUI = addon.LootUI; ---@class LootUISystem
local Def = LootUI.Defination;
local MainFrame = LootUI.MainFrame;
local FastLoot = LootUI.FastLoot;


local GetCurrencyDisplayInfo = API.GetCurrencyDisplayInfo;
local GetCurrencyIDFromLink = C_CurrencyInfo.GetCurrencyIDFromLink;
local GetCurrencyInfoFromLink = C_CurrencyInfo.GetCurrencyInfoFromLink;
local GetItemInfo = C_Item.GetItemInfo;
local GetItemInfoInstant = C_Item.GetItemInfoInstant;
local GetItemCraftingQuality = API.GetItemCraftingQuality;
local GetItemCountFromText = API.GetItemCountFromText;
local GetMoney = GetMoney;
local GetReputationChangeFromText = API.GetReputationChangeFromText;
local GetLootSlotLink = GetLootSlotLink;
local GetLootSlotType = GetLootSlotType;
local GetLootSlotInfo = GetLootSlotInfo;
local GetNumLootItems = GetNumLootItems;
local LootSlotHasItem = LootSlotHasItem;
local CloseLoot = CloseLoot;
local IsFishingLoot = IsFishingLoot;
local Secret_CanAccess = API.Secret_CanAccess;
local StripHyperlinks = API.StripHyperlinks;
local time = time;


local EventListeners = {};
LootUI.EventListeners = EventListeners;


local OverflowWarningShown = {};    --[currencyID] = true

local ItemIDxQuestTypes = {};   --Cache

local function CreateItemDataFromLink(link, slotIndex, icon, name, quantity, quality, locked, questType)
	local id, _, _, _, texture, classID, subclassID = GetItemInfoInstant(link);
	if not icon then
		icon = texture;
	end

	if questType and questType ~= 0 then
		ItemIDxQuestTypes[id] = questType;
	elseif questType == nil then
		questType = ItemIDxQuestTypes[id];
	end

	local craftQuality = GetItemCraftingQuality(link);

	if not (name and quality) then
		--From chat events. Ignore quest item
		if classID == 12 then
			if (not EventListeners.Primary.lootOpenedTime) or (time() - EventListeners.Primary.lootOpenedTime) > 2 then
				return
			end
		end
		local itemName, _, itemQuality = GetItemInfo(link);
		name = name or itemName;
		quality = quality or itemQuality;
		if craftQuality then
			name = StripHyperlinks(name);
		end
	end

	local hideCount = false;
	if classID == 2 or classID == 4 then
		hideCount = true;
	end

	local data = {
		icon = icon,
		name = name,
		quantity = quantity,
		locked = locked,
		quality = quality or 1,
		id = id,
		slotType = Def.SLOT_TYPE_ITEM,
		slotIndex = slotIndex,
		link = link,
		craftQuality = craftQuality or 0,
		questType = questType or 0,
		looted = false,
		hideCount = hideCount,
		classID = classID or -1,
		subclassID = subclassID or -1,
		overflow = false,
	};

	return data;
end

local function CreateCurrencyDataFromCurrencyID(link, currencyID, slotIndex, icon, name, quantity, quality, locked, questType)
	local itemOverflow;
	local overflow, numOwned, useTotalEarnedForMaxQty, maxQuantity = API.WillCurrencyRewardOverflow(currencyID, quantity);
	if overflow then
		if useTotalEarnedForMaxQty then
			if not OverflowWarningShown[currencyID] then
				OverflowWarningShown[currencyID] = true;
				if maxQuantity and maxQuantity > 0 and addon.GetPersonalData("CurrencyCap:"..currencyID) ~= maxQuantity then
					itemOverflow = true;
					addon.SetPersonalData("CurrencyCap:"..currencyID, maxQuantity);
				end
			end
		else
			itemOverflow = true;
		end
	end

	local data = {
		icon = icon,
		name = name,
		quantity = quantity,
		locked = locked,
		quality = quality or 1,
		id = currencyID,
		slotType = Def.SLOT_TYPE_CURRENCY,
		slotIndex = slotIndex,
		link = link,
		craftQuality = 0,
		questType = questType or 0,
		looted = false,
		hideCount = false,
		classID = -1,
		subclassID = -1,
		overflow = itemOverflow,
	};

	return data;
end

local function CreateMoneyData(link, slotIndex, icon, name, quantity, quality, locked, questType)
	local data = {
		icon = icon,
		name = name,
		quantity = quantity,
		locked = locked,
		quality = quality or 1,
		id = nil,
		slotType = Def.SLOT_TYPE_MONEY,
		slotIndex = slotIndex,
		link = link,
		craftQuality = 0,
		questType = questType or 0,
		looted = false,
		hideCount = false,
		classID = -1,
		subclassID = -1,
		overflow = false,
	};

	return data;
end

local function BuildSlotData(slotIndex)
	local _, slotType, craftQuality, id, itemOverflow, classID, subclassID, questType, hideCount;
	local icon, name, quantity, currencyID, quality, locked, isQuestItem, questID, isActive, isCoin = GetLootSlotInfo(slotIndex);   --the last 3 args are not presented in Classic/Cata
	local link = GetLootSlotLink(slotIndex);
	slotType = GetLootSlotType(slotIndex) or 0;
	isCoin = isCoin or slotType == 2;	--Enum.LootSlotType.Money

	local data;

	if isCoin then
		data = CreateMoneyData(link, slotIndex, icon, name, quantity, quality, locked, questType);
	else
		if slotType == Def.SLOT_TYPE_ITEM then
			if questID and not isActive then
				questType = Def.QUEST_TYPE_NEW;
			elseif questID or isQuestItem then  --Quest Required Item doesn't have questID
				questType = Def.QUEST_TYPE_ONGOING;
			end
			data = CreateItemDataFromLink(link, slotIndex, icon, name, quantity, quality, locked, questType);
		elseif currencyID then
			data = CreateCurrencyDataFromCurrencyID(link, currencyID, slotIndex, icon, name, quantity, quality, locked, questType);
		end
	end

	return data;
end

local function ShouldRebuildSlotData(slotIndex, existingData)
	local slotType = GetLootSlotType(slotIndex) or 0;
	local icon, name, quantity, currencyID, quality, locked, isQuestItem, questID, isActive, isCoin = GetLootSlotInfo(slotIndex);
	if isCoin then
		slotType = Def.SLOT_TYPE_MONEY;
	end
	if slotType == existingData.slotType and icon == existingData.icon and quantity == existingData.quantity and quality == existingData.quality then
		return false;
	else
		return true;
	end
end


local MerchantFrame = MerchantFrame;
local MailFrame = MailFrame;
local function IsMerchantFrameVisible()
	--(when alwaysListenLootMsg is true) we don't want to show alert when interacting with vendor or mailbox
	return MailFrame:IsVisible() or MerchantFrame:IsVisible();
end


local function ShouldAutoLoot(isAutoLoot)
	if not isAutoLoot then
		if Def.FORCE_AUTO_LOOT and C_CVar.GetCVarBool("autoLootDefault") and not IsModifiedClick("AUTOLOOTTOGGLE") then
			isAutoLoot = true;
		end
	end
	return isAutoLoot;
end


-- Primary EventListener
do
	local EL = CreateFrame("Frame");
	EventListeners.Primary = EL;

	EL.msgListeningDuration = 1.5;         --Unregister ChatMSG x seconds after LOOT_CLOSED

	local StaticEvents = {
		"LOOT_OPENED", "LOOT_CLOSED", "LOOT_READY",
		"UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED",
		--"TRANSMOG_COLLECTION_SOURCE_ADDED",
	};

	local LootResponseEvents = {
		"UI_ERROR_MESSAGE",
		"LOOT_BIND_CONFIRM", "LOOT_SLOT_CHANGED", "LOOT_SLOT_CLEARED",
	};

	local AlertSystemEvents;
	if C_EventUtils.IsEventValid("SHOW_LOOT_TOAST") then
		AlertSystemEvents = {
			"SHOW_LOOT_TOAST",
		};
	else
		AlertSystemEvents = {};
	end

	function EL:ListenStaticEvent(state)
		if state then
			API.RegisterFrameForEvents(self, StaticEvents);
		else
			API.UnregisterFrameForEvents(self, StaticEvents);
		end

		if state and addon.GetDBBool("LootUI_ShowAllCurrencyChange") then
			self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
			self:UnregisterEvent("CHAT_MSG_CURRENCY");
		else
			self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
		end
	end

	function EL:ListenLootResponseEvent(state)
		if state then
			API.RegisterFrameForEvents(self, LootResponseEvents);
		else
			API.UnregisterFrameForEvents(self, LootResponseEvents);
		end
	end

	function EL:ListenAlertSystemEvent(state)
		local f = AlertFrame;

		if state then
			if not EventListeners.enabled then return end;

			self.alertSystemMuted = true;
			for _, event in ipairs(AlertSystemEvents) do
				self:RegisterEvent(event);
			end

			if f then
				for _, event in ipairs(AlertSystemEvents) do
					f:UnregisterEvent(event);
				end
			end

			if not MainFrame.inEditMode then
				self:ListenDynamicEvents(true);
			end
		elseif self.alertSystemMuted then
			for _, event in ipairs(AlertSystemEvents) do
				self:UnregisterEvent(event);
			end

			if f then
				for _, event in ipairs(AlertSystemEvents) do
					f:RegisterEvent(event);
				end
			end
		end

		self.alwaysListenLootMsg = state;
	end

	function EL:BuildLootData()
		self.currentLoot = {};
		self.anyLootInSlot = {};
		self.overflowedCurrencies = nil;

		local numItems = GetNumLootItems();
		local index = 0;
		local data;

		for slotIndex = 1, numItems do
			if LootSlotHasItem(slotIndex) then
				index = index + 1;
				data = BuildSlotData(slotIndex);
				self.currentLoot[index] = data;

				if data and data.overflow then
					if not self.overflowedCurrencies then
						self.overflowedCurrencies = {};
					end
					table.insert(self.overflowedCurrencies, {
						id = data.id,
						slotType = Def.SLOT_TYPE_OVERFLOW,
						slotIndex = slotIndex,
						quality = data.quality,
					});
				end
				self.anyLootInSlot[slotIndex] = true;
			else
				self.anyLootInSlot[slotIndex] = false;
			end
		end
	end

	function EL:BuildLootDataAdditive()
		local numItems = GetNumLootItems();
		if numItems <= 0 then return; end
		if numItems ~= self.lastLootCount then
			self:ClearCurrentLootData();
			self.lastLootCount = numItems;
		end

		if not self.currentLoot then
			self.currentLoot = {};
		end
		if not self.anyLootInSlot then
			self.anyLootInSlot = {};
		end

		local index = 0;
		local data;

		for slotIndex = 1, numItems do
			if LootSlotHasItem(slotIndex) then
				--should
				index = index + 1;
				if (not self.currentLoot[slotIndex]) or ShouldRebuildSlotData(slotIndex, self.currentLoot[slotIndex]) then
					data = BuildSlotData(slotIndex);
					self.currentLoot[slotIndex] = data;

					if data and data.overflow then
						if not self.overflowedCurrencies then
							self.overflowedCurrencies = {};
						end
						table.insert(self.overflowedCurrencies, {
							id = data.id,
							slotType = Def.SLOT_TYPE_OVERFLOW,
							slotIndex = slotIndex,
							quality = data.quality,
						});
					end
				end
				self.anyLootInSlot[slotIndex] = true;
			else
				self.anyLootInSlot[slotIndex] = false;
			end
		end
	end

	function EL:ClearCurrentLootData()
		self.currentLoot = nil;
		self.anyLootInSlot = nil;
		self.lastLootCount = nil;
	end

	function LootUI.GetCurrentLoot()
		return EL.currentLoot;
	end

	function LootUI.HasAnyOverflowedCurrency()
		return EL.overflowedCurrencies and #EL.overflowedCurrencies > 0;
	end

	function LootUI.GetAndClearOverflowedCurrency()
		local pseudoLootQueue = {};

		for i, data in ipairs(EL.overflowedCurrencies) do
			pseudoLootQueue[i] = data;
		end

		EL.overflowedCurrencies = nil;

		if #pseudoLootQueue > 0 then
			return pseudoLootQueue;
		end
	end

	function EL:OnLootOpened(isAutoLoot, acquiredFromItem)
		self.lootOpened = true;
		self.dirtySlots = {};
		self:RecordPlayerMoney();
		self.lootOpenedTime = time();

		local useManualMode = not ShouldAutoLoot(isAutoLoot);

		local numItems = GetNumLootItems();

		if numItems == 0 then
			CloseLoot();
			return
		end

		self:ListenDynamicEvents(true);
		self:ListenLootResponseEvent(true);

		if acquiredFromItem then
			PlaySound(SOUNDKIT.UI_CONTAINER_ITEM_OPEN);
		end

		self:BuildLootDataAdditive();

		if useManualMode then
			MainFrame:DisplayPendingLoot();
			self:ListenDynamicEvents(false);
		else
			if MainFrame.errorMode then
				--LOOT_OPENED can keep re-firing after a failed attempt (e.g. bag full), so don't retry LootSlot() here or it'll spam the server (and DC you)
				return
			end

			if MainFrame:IsShown() and MainFrame.manualMode then
				MainFrame:Hide();
				MainFrame:SetAlpha(0);
			end

			self:SetManualMode(useManualMode);

			if not isAutoLoot then
				FastLoot:Start();
			end
		end
	end

	function EL:SetManualMode(state)
		MainFrame:SetManualMode(state);
		if state then
			self:ListenDynamicEvents(false);
			EventListeners.EmptyLootWatcher:StartWatching();
			EventListeners.QueueFrame:WipeQueue();
		else
			self:ListenDynamicEvents(true);
			EventListeners.EmptyLootWatcher:StopWatching();
		end
	end

	function EL:RecordPlayerMoney()
		if not self.playerMoney then
			self.playerMoney = GetMoney();
		end
	end

	function EL:OnLootReady(isAutoLoot)
		-- If we loot too fast, sometimes LOOT_OPENED doesn't fire
		-- Only LOOT_READY and LOOT_CLOSED

		self.lootReady = true;
		self:RecordPlayerMoney();

		if ShouldAutoLoot(isAutoLoot) then
			if (not self.soundEffectPlayed) and IsFishingLoot() then
				self.soundEffectPlayed = true;
				PlaySound(SOUNDKIT.FISHING_REEL_IN);
			end
			self:ListenDynamicEvents(true);
			self:RegisterEvent("UI_ERROR_MESSAGE");
			self:BuildLootDataAdditive();
			FastLoot:Start();
		end
	end

	function EL:OnLootClosed()
		self:RequestUnregisterDynamicEvents();
		self.lootOpened = nil;
		self.lootReady = nil;
		self.anyLootInSlot = nil;
		self.dirtySlots = nil;
		self.soundEffectPlayed = nil;
		self:ClearCurrentLootData();
		CloseLoot();
		if MainFrame.manualMode then
			EventListeners.QueueFrame:WipeQueue();
			MainFrame:ClosePendingLoot();
		end
		MainFrame.errorMode = nil;
		EventListeners.EmptyLootWatcher:StopWatching();
		FastLoot:ResetFlags();
		if self.alwaysListenLootMsg then
			self:ListenDynamicEvents(true);
		end
		self:ListenLootResponseEvent(false);
	end

	function EL:OnUpdate_UnregisterDynamicEvents(elapsed)
		self.t = self.t + elapsed;
		if self.t > self.msgListeningDuration then
			self.t = 0;
			self:SetScript("OnUpdate", nil);
			if not self.alwaysListenLootMsg then
				self:ListenDynamicEvents(false);
			end
		end
	end

	function EL:ListenDynamicEvents(state)
		if state and self:GetScript("OnUpdate") == self.OnUpdate_UnregisterDynamicEvents then
			self.t = 0;
			self:SetScript("OnUpdate", nil);
		end

		if state and not self.dynamicEventsRegistered then
			self.dynamicEventsRegistered = true;

			if not self.playerGUID then
				self.playerGUID = UnitGUID("player"); -- Never secret for "player" it seems
			end

			self:RegisterEvent("CHAT_MSG_LOOT");

			if Def.SHOW_ALL_CURRENCY_CHANGE then
				self:UnregisterEvent("CHAT_MSG_CURRENCY");
			else
				self:RegisterEvent("CHAT_MSG_CURRENCY");
			end

			if not Def.SHOW_ALL_MONEY_CHANGE then
				self:RegisterEvent("PLAYER_MONEY");
			end

		elseif (not state) and self.dynamicEventsRegistered then
			self.dynamicEventsRegistered = nil;
			self:UnregisterEvent("CHAT_MSG_LOOT");
			self:UnregisterEvent("CHAT_MSG_CURRENCY");
			self:UnregisterEvent("PLAYER_MONEY");
			self.playerMoney = nil;
		else
			return;
		end
		--print("ListenDynamicEvents", state);
	end

	function EL:RequestUnregisterDynamicEvents()
		self.t = 0;
		self:SetScript("OnUpdate", self.OnUpdate_UnregisterDynamicEvents);
	end

	function EL:OnUpdate_ProcessSlotChanged(elapsed)
		self.t = self.t + elapsed;
		if self.t > 0.1 then
			self.t = 0;
			self:SetScript("OnUpdate", nil);
			self:ProcessDirtySlots();
		end
	end

	function EL:RequestProcessSlotChanged()
		self.t = 0;
		self:SetScript("OnUpdate", self.OnUpdate_ProcessSlotChanged);
	end

	function EL:ProcessDirtySlots()
		if not self.dirtySlots then return; end

		for slotIndex, dirty in pairs(self.dirtySlots) do
			if dirty then
				self.dirtySlots[slotIndex] = false;
				if LootSlotHasItem(slotIndex) then
					MainFrame:UpdateLootSlotData(slotIndex, BuildSlotData(slotIndex));
				else
					self:OnLootSlotCleared(slotIndex);
				end
			end
		end
	end

	function EL:OnLootSlotChanged(slotIndex)
		if MainFrame.manualMode then
			if self.dirtySlots and slotIndex and not self.dirtySlots[slotIndex] then
				self.dirtySlots[slotIndex] = true;
				self:RequestProcessSlotChanged();
			end
		end

		FastLoot:SetSlotFlag(slotIndex, false);
	end

	function EL:CheckRemainingLoot()
		local anyLeft = false;
		local numItems = GetNumLootItems();
		for slotIndex = 1, numItems do
			if LootSlotHasItem(slotIndex) then
				anyLeft = true;
				break;
			end
		end

		if anyLeft then
			MainFrame:OnErrored();
			self:ListenDynamicEvents(false);
		end
	end

	function EL:OnLootSlotCleared(slotIndex)
		if MainFrame.manualMode then
			if self.anyLootInSlot then
				if self.anyLootInSlot[slotIndex] then
					self.anyLootInSlot[slotIndex] = false;
					MainFrame:SetLootSlotCleared(slotIndex);
				end
			end
		end
		FastLoot:SetSlotFlag(slotIndex, true);
	end

	function EL:OnLootToast(typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lootSource, lessAwesome, isUpgraded, isCorrupted)
		--See Blizzard_FrameXML/Mainline/AlertFrames.lua
		if typeIdentifier == "item" then
			local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink);
			local id, _, _, _, _, classID, subclassID = GetItemInfoInstant(itemLink);
			local hideCount = false;
			local craftQuality = 0;
			if classID == 5 or classID == 7 then
				craftQuality = GetItemCraftingQuality(itemLink);
			elseif classID == 2 or classID == 4 then
				hideCount = true;
			end
			local data = {
				icon = itemTexture,
				name = itemName,
				quantity = quantity,
				locked = false,
				quality = itemRarity,
				id = id,
				slotType = Def.SLOT_TYPE_ITEM,
				slotIndex = -1,
				link = itemLink,
				craftQuality = craftQuality,
				questType = 0,
				looted = true,
				hideCount = hideCount,
				classID = classID,
				subclassID = subclassID,
				overflow = false,
				toast = true,
			};
			LootUI.QueueDisplayLoot(data);
		elseif typeIdentifier == "money" then
			local data = {
				slotType = Def.SLOT_TYPE_MONEY,
				quantity = quantity,
				name = tostring(quantity),
				toast = true,
			};
			LootUI.QueueDisplayLoot(data);
		elseif isPersonal and typeIdentifier == "currency" then
			local currencyID = GetCurrencyIDFromLink(itemLink);
			local currencyInfo = GetCurrencyInfoFromLink(itemLink);
			local data = {
				icon = currencyInfo.iconFileID,
				name = currencyInfo.name,
				quantity = quantity,
				locked = false,
				quality = currencyInfo.quality,
				id = currencyID,
				slotType = Def.SLOT_TYPE_CURRENCY,
				slotIndex = -1,
				link = itemLink,
				craftQuality = 0,
				questType = 0,
				looted = true,
				hideCount = false,
				classID = -1,
				subclassID = -1,
				overflow = false,
				toast = true,
			};
			LootUI.QueueDisplayLoot(data);
		elseif typeIdentifier == "honor" then

		end
	end

	function EL:OnEvent(event, ...)
		--if string.find(event, "LOOT_") then
		--	print(event, GetTimePreciseSec(), ...); -- DEBUG
		--end

		if event == "LOOT_OPENED" then
			self:OnLootOpened(...);
		elseif event == "LOOT_READY" then
			self:OnLootReady(...);
		elseif event == "LOOT_CLOSED" then
			--Usually fire two times in a row. In this case "GetNumLootItems" returns the re-looted value during the first trigger.
			--Can fire only one time if player leaves the corpse fast. And "LOOT_SLOT_CLEARED" won't trigger. Items are fully looted and "GetNumLootItems" returns 0
			self:OnLootClosed();
		elseif event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
			MainFrame:OnUIScaleChanged();
		elseif event == "UI_ERROR_MESSAGE" or event == "LOOT_BIND_CONFIRM" then
			--ERR_INV_FULL, ERR_LOOT_CANT_LOOT_THAT, ERR_LOOT_CANT_LOOT_THAT_NOW, ERR_LOOT_ROLL_PENDING
			if self.lootOpened or self.lootReady then
				local errorType, message = ...
				-- I'm not 100% certain which errorTypes are loot error so let's check everything
				if true or errorType then
					self:CheckRemainingLoot();
				end
			end
		elseif event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_CURRENCY" then
			--This is the most robust way to determine what's been looted.
			--Less responsive and more costly
			if not IsMerchantFrameVisible() then
				if event == "CHAT_MSG_LOOT" then
					if self:IsMessageSenderPlayer(...) then
						self:ProcessMessageItem(...);
					end
				elseif event == "CHAT_MSG_CURRENCY" and not Def.SHOW_ALL_CURRENCY_CHANGE then    --guid is nil. Appear later than other chat events (~0.8s delay)
					self:ProcessMessageCurrency(...);
				end
			end
		elseif event == "PLAYER_MONEY" then
			if not Def.SHOW_ALL_MONEY_CHANGE then
				self:ProcessMoneyFromLoot();
			end
		elseif event == "CURRENCY_DISPLAY_UPDATE" then
			self:OnCurrencyDisplayUpdate(...);
		elseif event == "LOOT_SLOT_CHANGED" then
			--Can happen during AoE Loot
			self:OnLootSlotChanged(...);
		elseif event == "LOOT_SLOT_CLEARED" then
			self:OnLootSlotCleared(...);
		--elseif event == "SHOW_LOOT_TOAST" then
			--not used. When this option is enabled, we'll listen chat loot events all the time instead of after looting
		--    self:OnLootToast(...);
		end
	end

	function EL:ProcessMoneyFromLoot()
		if self.playerMoney then
			local money = GetMoney();
			local delta = money - self.playerMoney;
			if delta > 0 then
				local data = {
					slotType = Def.SLOT_TYPE_MONEY,
					quantity = delta,
					name = tostring(money),
				};
				LootUI.QueueDisplayLoot(data);
			end
			if MainFrame:IsVisible() then
				self.playerMoney = money;
			else
				self.playerMoney = nil;
			end
		end
	end

	function EL:IsMessageSenderPlayer_Retail(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid)
		if Secret_CanAccess(guid) then
			return guid == self.playerGUID
		end
	end
	EL.IsMessageSenderPlayer = EL.IsMessageSenderPlayer_Retail;

	function EL:IsMessageSenderPlayer_Classic(text, _, _, _, playerName)
		--Payloads are different on Classic!
		if not self.playerName then
			self.playerName = UnitName("player");
		end
		return playerName == self.playerName
	end

	if Def.IS_CLASSIC then
		EL.IsMessageSenderPlayer = EL.IsMessageSenderPlayer_Classic;
	end

	local function Debug_LogLootMessage(text)
		if not PlumberDevData.LootMessages then
			PlumberDevData.LootMessages = {};
		end
		table.insert(PlumberDevData.CurrencyMessages, text);
	end


	local tonumber = tonumber;
	local match = string.match;
	local find = string.find;
	local ITEM_CHANGED = L["Item Changed"];

	function EL:ProcessMessageItem(text)
		--Do we need to use the whole itemlink?
		local itemID = match(text, "item:(%d+)", 1);
		if itemID then
			itemID = tonumber(itemID);
			if itemID then
				--Debug_LogLootMessage(text)
				local link, name = match(text, "(|Hitem:.+|h)%[(.+)%]|h");
				if link then
					if not find(text, ITEM_CHANGED) then
						--Ignore item upgrade: Your %s was changed to %s.
						local slotIndex = 0;
						local quantity = GetItemCountFromText(text);
						local data = CreateItemDataFromLink(link, slotIndex, nil, name, quantity);
						if data then
							data.looted = true;
							LootUI.QueueDisplayLoot(data);
						end
					end
				end
			end
		end
	end

	function EL:ProcessMessageCurrency(text)
		if not Secret_CanAccess(text) then return end;

		local currencyID = match(text, "currency:(%d+)", 1);
		if currencyID then
			currencyID = tonumber(currencyID);
			--Debug_LogLootMessage(text)
			if currencyID then
				local link, _name = match(text, "(|Hcurrency:.+|h)%[(.+)%]|h");
				local currencyInfo = link and GetCurrencyInfoFromLink(link);
				if currencyInfo then
					local slotIndex = 0;
					local icon = currencyInfo.iconFileID;
					local name = currencyInfo.name;
					local quantity = GetItemCountFromText(text);
					local quality = currencyInfo.quality;
					local data = CreateCurrencyDataFromCurrencyID(link, currencyID, slotIndex, icon, name, quantity, quality);
					if data then
						data.looted = true;
						LootUI.QueueDisplayLoot(data);
					end
				end
			end
		end
	end

	function EL:ProcessMessageFaction(text)
		if not Secret_CanAccess(text) then return end;
		local factionName, amount = GetReputationChangeFromText(text);
		if factionName then
			if not self.repDummyIndex then
				self.repDummyIndex = 0;
			end
			self.repDummyIndex = self.repDummyIndex - 1;
			local data = {
				name = factionName,
				quantity = amount or 0,
				slotType = Def.SLOT_TYPE_REP,
				questType = 0,
				quality = 0,
				slotIndex = self.repDummyIndex;
				craftQuality = 0,
				classID = -1,
				subclassID = -1,
			};
			LootUI.QueueDisplayLoot(data);
		end
	end


	local ModifiedCurrencyQuantity = {
		--TEMP FIX: The two currencies return 100x the actual value when looted from chests or bodies for some reasons
		[1602] = 0.01,	--Conquest
		[2123] = 0.01,	--Bloody Tokens
	};

	function EL:OnCurrencyDisplayUpdate(currencyID, quantity, quantityChange, quantityGainSource, destroyReason)
		if quantityChange and quantityChange > 0 then
			if self.deferCurrencyChange then
				if not self.currencyCache[currencyID] then
					local info = C_CurrencyInfo.GetCurrencyInfo(currencyID);
					if info then
						self.currencyCache[currencyID] = info.quantity;
					end
				end
				return
			end

			local name, icon, quality = GetCurrencyDisplayInfo(currencyID);
			if name then
				--print(name, currencyID, quantity, quantityChange, quantityGainSource);    --debug

				if quantityChange > 2000 and ModifiedCurrencyQuantity[currencyID] then
					quantityChange = math.floor(quantityChange * 0.01);
				end

				local link = string.format("|Hcurrency:%d|h", currencyID);
				local slotIndex = 0;
				local data = CreateCurrencyDataFromCurrencyID(link, currencyID, slotIndex, icon, name, quantityChange, quality);
				LootUI.QueueDisplayLoot(data);
			end
		end
	end

	function EL:OnLoadingScreenDisabled()
		if API.IsInPvP() then
			self.deferCurrencyChange = true;
			if not self.currencyCache then
				self.currencyCache = {};
			end
		else
			self.deferCurrencyChange = nil;
			if self.currencyCache then
				local tbl = self.currencyCache;
				self.currencyCache = nil;
				if not EventListeners.enabled then return; end

				for currencyID, oldQuantity in pairs(tbl) do
					local info = C_CurrencyInfo.GetCurrencyInfo(currencyID);
					if info then
						local quantityChange = info.quantity - oldQuantity;
						if quantityChange > 0 then
							local link = string.format("|Hcurrency:%d|h", currencyID);
							local slotIndex = 0;
							local data = CreateCurrencyDataFromCurrencyID(link, currencyID, slotIndex, info.iconFileID, info.name, quantityChange, info.quality);
							LootUI.QueueDisplayLoot(data);
						end
					end
				end
			end
		end
	end
	addon.CallbackRegistry:Register("LOADING_SCREEN_DISABLED", EL.OnLoadingScreenDisabled, EL);
end


-- Item Queue
do
	local QueueFrame = CreateFrame("Frame");
	EventListeners.QueueFrame = QueueFrame;

	local function OnUpdate_DisplayLootResult(self, elapsed)
		--The response should be as swift as possible but we must count for event delay
		self.t = self.t + elapsed;
		if self.t > 0.15 then   --5/60
			self.t = nil;
			self:SetScript("OnUpdate", nil);
			if not MainFrame:IsInMaualModeOrEditMode() then
				MainFrame:DisplayLootResult();
			end
		end
	end

	function QueueFrame:QueueDisplayLoot(lootData)
		if not (lootData and lootData.quantity) then return; end
		if MainFrame:IsInMaualModeOrEditMode() then return; end


		if not self.lootQueue then
			self.lootQueue = {};
		end

		if not lootData.slotIndex then
			lootData.slotIndex = 0;
		end

		table.insert(self.lootQueue, lootData);

		self.t = 0;
		self:SetScript("OnUpdate", OnUpdate_DisplayLootResult);
	end

	function QueueFrame:WipeQueue()
		self.t = 0;
		self:SetScript("OnUpdate", nil);
		self.lootQueue = nil;
	end

	function LootUI.QueueDisplayLoot(data)
		if EventListeners.enabled then
			QueueFrame:QueueDisplayLoot(data);
		end
	end

	function LootUI.QueueDisplaySpell(spellData)
		if not (EventListeners.enabled and spellData.spellID) then return false end;

		local spellID = spellData.spellID;
		local icon = spellData.icon or C_Spell.GetSpellTexture(spellID);
		local name = spellData.name or C_Spell.GetSpellName(spellID);
		local quality = spellData.quality or 1;

		if not name then return end;

		if spellData.subtitle then
			name = string.format("%s\n|cffebebeb%s|r", name, spellData.subtitle);
		end

		local data = {
			slotType = -1,
			id = spellID,
			icon = icon,
			quality = quality,
			quantity = 1,
			name = name,
			hideCount = true,
			showGlow = true,
			tooltipMethod = "SetSpellByID",
			isNotification = true,
			slotIndex = 0,
		};

		LootUI.QueueDisplayLoot(data);
	end


	local function TooltipFunc_Reputation(tooltip, factionID)
		local text, factionName = API.GetFactionStatusText(factionID, true, true);
		if text and factionName then
			tooltip:SetText(factionName, 1, 0.82, 0);
			tooltip:AddLine(text, 1, 1, 1);
			tooltip:Show();
		end
	end

	function LootUI.QueueDisplayReputation(factionID, name, quantity)
		if EventListeners.enabled then
			local data = {
				slotType = Def.SLOT_TYPE_REP,
				id = factionID,
				quality = 1,
				quantity = quantity,
				name = name,
				hideCount = true,
				tooltipFunc = TooltipFunc_Reputation,
				slotIndex = 0,
			};
			LootUI.QueueDisplayLoot(data);
		end
	end

	function LootUI.GetLootQueue()
		return QueueFrame.lootQueue;
	end

	function LootUI.WipeLootQueue()
		QueueFrame:WipeQueue();
	end
end


-- Money Change Listener
do
	local MoneyListener = CreateFrame("Frame");
	EventListeners.MoneyListener = MoneyListener;

	local IsInteractingWithNpcOfType = C_PlayerInteractionManager.IsInteractingWithNpcOfType;

	function MoneyListener:OnSettingsChanged()
		if addon.GetDBBool("LootUI") and addon.GetDBBool("LootUI_ShowAllMoneyChange") then
			self:RegisterEvent("PLAYER_MONEY");
			self:SetScript("OnEvent", self.OnEvent);
			self.playerMoney = GetMoney();
		else
			self:UnregisterEvent("PLAYER_MONEY");
			self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE");
			self:SetScript("OnEvent", nil);
			self.playerMoney = nil;
		end
	end

	function MoneyListener:OnEvent(event, ...)
		if event == "PLAYER_MONEY" then
			self.t = - 0.2;
			self:SetScript("OnUpdate", self.OnUpdate);
		elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
			self.t = -0.8;
			self:SetScript("OnUpdate", self.OnUpdate);
		end
	end

	MoneyListener.interactionTypes = {
		--Enum.PlayerInteractionType
		3, 4,   --Gossip, QuestGiver
		8, 10,  --Banker, GuildBanker
		5, 12,  --Merchant, Vendor
		17,     --MailInfo
	};

	function MoneyListener:IsInteracting()
		--Defer and merge changes when interacting with certain NPCs
		for _, id in ipairs(self.interactionTypes) do
			if IsInteractingWithNpcOfType(id) then
				return true;
			end
		end
		return false;
	end

	function MoneyListener:OnUpdate(elapsed)
		self.t = self.t + elapsed;
		if self.t >= 0 then
			self.t = 0;
			self:SetScript("OnUpdate", nil);
			if self:IsInteracting() then
				self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE");
			else
				self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE");
				self:ProcessMoneyFromAllSources();
			end
		end
	end

	function MoneyListener:ProcessMoneyFromAllSources()
		local money = GetMoney();
		if self.playerMoney then
			local delta = money - self.playerMoney;
			if delta > 0 then
				local data = {
					slotType = Def.SLOT_TYPE_MONEY,
					quantity = delta,
					name = tostring(money),
					slotIndex = 0,
				};
				LootUI.QueueDisplayLoot(data);
			end
		end
		self.playerMoney = money;
	end
end


-- Empty Loot Watcher
do
	-- After LOOT_OPENED, check if there is any loot every 1 s
	-- If not, triggers a LOOT_CLOSED to close the MainFrame as a failsafe

	local EmptyLootWatcher = CreateFrame("Frame");
	EventListeners.EmptyLootWatcher = EmptyLootWatcher;

	function EmptyLootWatcher:OnUpdate(elapsed)
		self.t = self.t + elapsed;
		if self.t > 1.0 then
			self.t = 0;
			if GetNumLootItems() <= 0 then
				self:SetScript("OnUpdate", nil);
				EventListeners.Primary:OnEvent("LOOT_CLOSED");
			end
		end
	end

	function EmptyLootWatcher:StartWatching()
		self.t = 0;
		self:SetScript("OnUpdate", self.OnUpdate);
	end

	function EmptyLootWatcher:StopWatching()
		self.t = 0;
		self:SetScript("OnUpdate", nil);
	end
end


function EventListeners:Enable()
	self.enabled = true;

	self.Primary:ListenStaticEvent(true);
	self.Primary:SetScript("OnEvent", self.Primary.OnEvent);

	self.MoneyListener:OnSettingsChanged();
	FastLoot:ResetFlags();
end

function EventListeners:Disable()
	self.enabled = false;

	self.Primary.currentLoot = nil;
	self.Primary.playerMoney = nil;
	self.Primary.overflowedCurrencies = nil;
	self.Primary:ListenStaticEvent(false);
	self.Primary:ListenDynamicEvents(false);
	self.Primary:ListenLootResponseEvent(false);
	self.Primary:ListenAlertSystemEvent(false);
	self.Primary:SetScript("OnEvent", nil);
	self.Primary:SetScript("OnUpdate", nil);

	self.MoneyListener:OnSettingsChanged();
	self.EmptyLootWatcher:StopWatching();
	self.QueueFrame:WipeQueue();
	FastLoot:ResetFlags();
end
