local _, addon = ...
local API = addon.API;
local L = addon.L;
local P_Loot = addon.P_Loot;


local MainFrame = P_Loot.MainFrame;
local Defination = P_Loot.Defination;
local Formatter = P_Loot.Formatter;
local MergeSimilarItems = P_Loot.MergeSimilarItems;


local LootSlot = LootSlot;
local CloseLoot = CloseLoot;
local LootSlotHasItem = LootSlotHasItem;
local GetLootSlotLink = GetLootSlotLink;
local GetLootSlotType = GetLootSlotType;
local GetLootSlotInfo = GetLootSlotInfo;
local GetNumLootItems = GetNumLootItems;
local IsFishingLoot = IsFishingLoot;
local StripHyperlinks = StripHyperlinks;
local time = time;

local GetMoney = GetMoney;
local GetItemCraftingQuality = API.GetItemCraftingQuality;
local GetItemInfoInstant = C_Item.GetItemInfoInstant;
local GetItemInfo = C_Item.GetItemInfo;
local IsModifiedClick = IsModifiedClick;
local GetCVarBool = C_CVar.GetCVarBool;
local GetCurrencyIDFromLink = C_CurrencyInfo.GetCurrencyIDFromLink;
local GetCurrencyInfoFromLink = C_CurrencyInfo.GetCurrencyInfoFromLink;


local tsort = table.sort;
local pairs = pairs;
local ipairs = ipairs;
local match = string.match;
local tonumber = tonumber;
local CreateFrame = CreateFrame;

local GetReputationChangeFromText = API.GetReputationChangeFromText;
local GetItemCountFromText = API.GetItemCountFromText;


local MAX_ITEM_PER_PAGE = 5;
local EVENT_DURATION = 1.5;         --Unregister ChatMSG x seconds after LOOT_CLOSED
local AUTO_HIDE_DELAY = 3.0;        --Determined by the number of items. From 2.0s to 3.0s
local BG_OPACITY = 0.5;             --Base Alpha: 0.9 (This parameter doesn't affect Manual Mode due to readability concern) / Opacity


local EL = CreateFrame("Frame");
local EventGenerator = CreateFrame("Frame");


local ENABLE_MODULE = false;
local IS_CLASSIC = not addon.IsToCVersionEqualOrNewerThan(110000);
local ITEM_CHANGED = L["Item Changed"];


-- User Settings
local FORCE_AUTO_LOOT = true;
local AUTO_LOOT_ENABLE_TOOLTIP = true;
local FADE_DELAY_PER_ITEM = 0.25;
local REPLACE_LOOT_ALERT = true;
local LOOT_UNDER_MOUSE = false;
local USE_STOCK_UI = false;
local MERGE_SIMILAR_ITEMS = true;
local LOW_FRAME_STRATA = false;
------------------

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

local OverflowWarningShown = {};    --[currencyID] = true

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


local function MergeData(d1, d2)
    if d1 and d2 then
        if d1.slotType == d2.slotType then
            if d1.slotType == Defination.SLOT_TYPE_REP then
                if d1.name == d2.name then
                    d1.quantity = d1.quantity + d2.quantity;
                    return true
                end
            else
                if (d1.id == d2.id) and (not d1.mergedData) and (not d2.mergedData) then
                    if (d1.quantity == d2.quantity) and (d1.toast ~= d2.toast) then
                        d1.toast = true;
                    else
                        d1.quantity = d1.quantity + d2.quantity;
                    end
                    return true
                elseif MERGE_SIMILAR_ITEMS then
                    return MergeSimilarItems(d1, d2)
                end
            end
        end
    end
    return false
end


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
            if (not EL.lootOpenedTime) or (time() - EL.lootOpenedTime) > 2 then
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
        slotType = Defination.SLOT_TYPE_ITEM,
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

    return data
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
        slotType = Defination.SLOT_TYPE_CURRENCY,
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

    return data
end

local function CreateMoneyData(link, slotIndex, icon, name, quantity, quality, locked, questType)
    local data = {
        icon = icon,
        name = name,
        quantity = quantity,
        locked = locked,
        quality = quality or 1,
        id = nil,
        slotType = Defination.SLOT_TYPE_MONEY,
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

    return data
end


local MerchantFrame = MerchantFrame;
local MailFrame = MailFrame;
local function IsMerchantFrameVisible()
    --(when alwaysListenLootMsg is true) we don't want to show alert when interacting with vendor or mailbox
    return MailFrame:IsVisible() or MerchantFrame:IsVisible()
end


do  --Process Loot Message
    function EL:IsMessageSenderPlayer_Retail(text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid)
        return guid == self.playerGUID
    end
    EL.IsMessageSenderPlayer = EL.IsMessageSenderPlayer_Retail;

    function EL:IsMessageSenderPlayer_Classic(text, _, _, _, playerName)
        --Payloads are different on Classic!
        if not self.playerName then
            self.playerName = UnitName("player");
        end
        return playerName == self.playerName
    end

    if IS_CLASSIC then
        EL.IsMessageSenderPlayer = EL.IsMessageSenderPlayer_Classic;
    end

    local function Debug_LogLootMessage(text)
        if not PlumberDevData.LootMessages then
            PlumberDevData.LootMessages = {};
        end
        table.insert(PlumberDevData.CurrencyMessages, text);
    end

    function EL:ProcessMessageItem(text)
        --Do we need to use the whole itemlink?
        local itemID = match(text, "item:(%d+)", 1);
        if itemID then
            itemID = tonumber(itemID);
            if itemID then
                --Debug_LogLootMessage(text)
                if self.alwaysListenLootMsg then
                    local link, name = match(text, "(|Hitem:.+|h)%[(.+)%]|h");
                    if link then
                        if not string.find(text, ITEM_CHANGED) then
                            --Ignore item upgrade: Your %s was changed to %s.
                            local slotIndex = 0;
                            local quantity = GetItemCountFromText(text);
                            local data = CreateItemDataFromLink(link, slotIndex, nil, name, quantity);
                            if data then
                                data.looted = true;
                                MainFrame:QueueDisplayLoot(data);
                            end
                        end
                    end
                else
                    for _, data in ipairs(self.currentLoots) do
                        if not data.looted then
                            if data.slotType == Defination.SLOT_TYPE_ITEM and data.id == itemID then
                                data.looted = true;
                                local quantity = GetItemCountFromText(text);
                                if quantity then
                                    data.quantity = quantity;
                                end
                                if AUTO_LOOT_ENABLE_TOOLTIP then
                                    local link = match(text, "|H(item[:%d]+)|h", 1);
                                    if link then
                                        data.link = link;
                                    end
                                end
                                MainFrame:QueueDisplayLoot(data);
                            end
                        end
                    end
                end
            end
        end
    end

    function EL:ProcessMessageCurrency(text)
        local currencyID = match(text, "currency:(%d+)", 1);
        if currencyID then
            currencyID = tonumber(currencyID);
            --Debug_LogLootMessage(text)
            if currencyID then
                if self.alwaysListenLootMsg then
                    local link, name = match(text, "(|Hcurrency:.+|h)%[(.+)%]|h");
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
                            MainFrame:QueueDisplayLoot(data);
                        end
                    end
                else
                    for _, data in ipairs(self.currentLoots) do
                        if not data.looted then
                            if data.slotType == Defination.SLOT_TYPE_CURRENCY and data.id == currencyID then
                                data.looted = true;
                                local count = GetItemCountFromText(text);
                                if count then
                                    data.quantity = count;
                                end
                                MainFrame:QueueDisplayLoot(data);
                            end
                        end
                    end
                end
            end
        end
    end

    function EL:ProcessMessageFaction(text)
        local factionName, amount = GetReputationChangeFromText(text);
        if factionName then
            if not self.repDummyIndex then
                self.repDummyIndex = 0;
            end
            self.repDummyIndex = self.repDummyIndex - 1;
            local data = {
                name = factionName,
                quantity = amount or 0,
                slotType = Defination.SLOT_TYPE_REP,
                questType = 0,
                quality = 0,
                slotIndex = self.repDummyIndex;
                craftQuality = 0,
                classID = -1,
                subclassID = -1,
            };
            MainFrame:QueueDisplayLoot(data);
        end
    end
end


do  --Event Handler
    local STATIC_EVENTS = {
        "LOOT_OPENED", "LOOT_CLOSED", "LOOT_READY",
        "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED",
        --"TRANSMOG_COLLECTION_SOURCE_ADDED",
    };

    local ALERT_SYSTEM_EVENTS;
    if IS_CLASSIC then
        ALERT_SYSTEM_EVENTS = {};
    else
        ALERT_SYSTEM_EVENTS = {
            "SHOW_LOOT_TOAST",
        };
    end

    function EL:ListenStaticEvent(state)
        if state then
            for _, event in ipairs(STATIC_EVENTS) do
                EL:RegisterEvent(event);
            end
        else
            for _, event in ipairs(STATIC_EVENTS) do
                EL:UnregisterEvent(event);
            end
        end
    end

    function EL:ListenAlertSystemEvent(state)
        local f = AlertFrame;

        if state then
            if not self.enabled then return end;

            self.alertSystemMuted = true;
            for _, event in ipairs(ALERT_SYSTEM_EVENTS) do
                self:RegisterEvent(event);
            end

            if f then
                for _, event in ipairs(ALERT_SYSTEM_EVENTS) do
                    f:UnregisterEvent(event);
                end
            end

            if not self.inEditMode then
                self:ListenDynamicEvents(true);
            end
        elseif self.alertSystemMuted then
            for _, event in ipairs(ALERT_SYSTEM_EVENTS) do
                self:UnregisterEvent(event);
            end

            if f then
                for _, event in ipairs(ALERT_SYSTEM_EVENTS) do
                    f:RegisterEvent(event);
                end
            end
        end

        self.alwaysListenLootMsg = state;
    end


    local function BuildSlotData(slotIndex)
        local _, slotType, craftQuality, id, itemOverflow, classID, subclassID, questType, hideCount;
        local icon, name, quantity, currencyID, quality, locked, isQuestItem, questID, isActive, isCoin = GetLootSlotInfo(slotIndex);   --the last 3 args are not presented in Classic/Cata
        local link = GetLootSlotLink(slotIndex);
        slotType = GetLootSlotType(slotIndex) or 0;
        isCoin = isCoin or slotType == 2;

        local data;

        if isCoin then --Enum.LootSlotType.Money
            data = CreateMoneyData(link, slotIndex, icon, name, quantity, quality, locked, questType);
        else
            if slotType == Defination.SLOT_TYPE_ITEM then
                if questID and not isActive then
                    questType = Defination.QUEST_TYPE_NEW;
                elseif questID or isQuestItem then  --Quest Required Item doesn't have questID
                    questType = Defination.QUEST_TYPE_ONGOING;
                end
                data = CreateItemDataFromLink(link, slotIndex, icon, name, quantity, quality, locked, questType);
            elseif currencyID then
                data = CreateCurrencyDataFromCurrencyID(link, currencyID, slotIndex, icon, name, quantity, quality, locked, questType);
            end
        end

        return data
    end

    function EL:BuildLootData()
        self.currentLoots = {};
        self.anyLootInSlot = {};
        self.overflowCurrencies = nil;

        local numItems = GetNumLootItems();
        local index = 0;
        local data;

        for slotIndex = 1, numItems do
            if LootSlotHasItem(slotIndex) then
                index = index + 1;
                data = BuildSlotData(slotIndex);
                self.currentLoots[index] = data;

                if data and data.overflow then
                    if not self.overflowCurrencies then
                        self.overflowCurrencies = {};
                    end
                    table.insert(self.overflowCurrencies, {
                        id = data.id,
                        slotType = Defination.SLOT_TYPE_OVERFLOW,
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

    function EL:OnLootOpened(isAutoLoot, acquiredFromItem)
        self.lootOpened = true;
        self.dirtySlots = {};
        self.playerMoney = GetMoney();
        self.lootOpenedTime = time();

        --print("isAutoLoot", isAutoLoot, GetCVarBool("autoLootDefault"), IsModifiedClick("AUTOLOOTTOGGLE"));
        local useManualMode;
        if FORCE_AUTO_LOOT and GetCVarBool("autoLootDefault") then
            useManualMode = (not isAutoLoot) and IsModifiedClick("AUTOLOOTTOGGLE");     --Need hold down the Modifier Key until the window appears
        else
            useManualMode = not isAutoLoot;
        end

        local numItems = GetNumLootItems();

        if numItems == 0 then
           CloseLoot();
           return
        end

        if USE_STOCK_UI then
            if not isAutoLoot and not useManualMode then
                --When game sends conflicting signals
                for slotIndex = 1, numItems do
                    LootSlot(slotIndex);
                end
            end
            return
        end

        self:ListenDynamicEvents(true);
        self:RegisterEvent("UI_ERROR_MESSAGE");
        self:RegisterEvent("LOOT_BIND_CONFIRM");
        self:RegisterEvent("LOOT_SLOT_CHANGED");
        self:RegisterEvent("LOOT_SLOT_CLEARED");
        if acquiredFromItem then
            PlaySound(SOUNDKIT.UI_CONTAINER_ITEM_OPEN);
        elseif IsFishingLoot() then
            PlaySound(SOUNDKIT.FISHING_REEL_IN);
        end

        self:BuildLootData();

        if useManualMode then
            tsort(self.currentLoots, SortFunc_LootSlot);
            MainFrame:DisplayPendingLoot();
        else
            if MainFrame:IsShown() and MainFrame.manualMode and not MainFrame.errorMode then
                MainFrame:Hide();
                MainFrame:SetAlpha(0);
                MainFrame:SetManualMode(false);
            end
            MainFrame.manualMode = false;

            for slotIndex = 1, numItems do
                LootSlot(slotIndex);
            end
        end
    end

    function EL:OnLootReady(isAutoLoot)
        --print("LootReady", isAutoLoot);
    end

    function EL:OnLootClosed()
        self:RequestUnregisterDynamicEvents();
        self.lootOpened = false;
        self.anyLootInSlot = nil;
        self.dirtySlots = nil;
        CloseLoot();
        if MainFrame.manualMode then
            MainFrame:ClosePendingLoot();
        end
        MainFrame.errorMode = nil;
        self:UnregisterEvent("UI_ERROR_MESSAGE");
        self:UnregisterEvent("LOOT_BIND_CONFIRM");
        self:UnregisterEvent("LOOT_SLOT_CHANGED");
        self:UnregisterEvent("LOOT_SLOT_CLEARED");
    end

    function EL:OnUpdate_UnregisterDynamicEvents(elapsed)
        self.t = self.t + elapsed;
        if self.t > EVENT_DURATION then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            if not self.alwaysListenLootMsg then
                self:ListenDynamicEvents(false);
            end
        end
    end

    function EL:ListenDynamicEvents(state)
        if state then
            if not self.playerGUID then
                self.playerGUID = UnitGUID("player");
            end
            self:RegisterEvent("CHAT_MSG_LOOT");
            self:RegisterEvent("CHAT_MSG_CURRENCY");
            self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE");
            self:RegisterEvent("PLAYER_MONEY");
            self.t = 0;
            self:SetScript("OnUpdate", nil);
        else
            self:UnregisterEvent("CHAT_MSG_LOOT");
            self:UnregisterEvent("CHAT_MSG_CURRENCY");
            self:UnregisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE");
            self:UnregisterEvent("PLAYER_MONEY");
        end
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
        if not self.dirtySlots then return end;

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
    end

    function EL:OnUpdate_CheckRemainingLoot(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.05 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            self:CheckRemainingLoot();
        end
    end

    function EL:CheckRemainingLoot()
        local anyLeft = false;
        local numItems = GetNumLootItems();
        for slotIndex = 1, numItems do
            if LootSlotHasItem(slotIndex) then
                anyLeft = true
                break
            end
        end

        if anyLeft and self.lootOpened then
            MainFrame:OnErrored();
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
        else
            --self.t = 0;
            --self:SetScript("OnUpdate", self.OnUpdate_CheckRemainingLoot);
        end
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
                slotType = Defination.SLOT_TYPE_ITEM,
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
            MainFrame:QueueDisplayLoot(data);
        elseif typeIdentifier == "money" then
            local data = {
                slotType = Defination.SLOT_TYPE_MONEY,
                quantity = quantity,
                name = tostring(quantity),
                toast = true,
            };
            MainFrame:QueueDisplayLoot(data);
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
                slotType = Defination.SLOT_TYPE_CURRENCY,
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
            MainFrame:QueueDisplayLoot(data);
        elseif typeIdentifier == "honor" then

        end
    end

    function EL:OnEvent(event, ...)
        if event == "LOOT_OPENED" then
            self:OnLootOpened(...);
        elseif event == "LOOT_READY" then
            local isAutoLoot =  ...
            self:OnLootReady(...);
        elseif event == "LOOT_CLOSED" then
            --Usually fire two times in a row. In this case "GetNumLootItems" returns the re-looted value during the first trigger.
            --Can fire only one time if player leaves the corpse fast. And "LOOT_SLOT_CLEARED" won't trigger. Items are fully looted and "GetNumLootItems" returns 0
            self:OnLootClosed();
        elseif event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
            MainFrame:OnUIScaleChanged();
        elseif event == "UI_ERROR_MESSAGE" or event == "LOOT_BIND_CONFIRM" then
            --ERR_INV_FULL, ERR_LOOT_CANT_LOOT_THAT, ERR_LOOT_CANT_LOOT_THAT_NOW, ERR_LOOT_ROLL_PENDING
            if self.lootOpened then
                local errorType, message = ...
                if errorType == 3 or true then
                    MainFrame:OnErrored(errorType);
                end
            end
        elseif event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_CURRENCY" or event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
            --This is the most robust way to determine what's been looted.
            --Less responsive and more costly
            if (not IsMerchantFrameVisible()) and (self.currentLoots) then
                if event == "CHAT_MSG_LOOT" then
                    if self:IsMessageSenderPlayer(...) then
                        self:ProcessMessageItem(...);
                    end
                elseif event == "CHAT_MSG_CURRENCY" then    --guid is nil. Appear later than other chat events (~0.8s delay)
                    self:ProcessMessageCurrency(...);
                elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
                    self:ProcessMessageFaction(...);
                end
            end
        elseif event == "PLAYER_MONEY" then
            if self.playerMoney then
                local money = GetMoney();
                local delta = money - self.playerMoney;
                if delta > 0 then
                    local data = {
                        slotType = Defination.SLOT_TYPE_MONEY,
                        quantity = delta,
                        name = tostring(money),
                    };
                    MainFrame:QueueDisplayLoot(data);
                end
                if MainFrame:IsVisible() then
                    self.playerMoney = money;
                else
                    self.playerMoney = nil;
                end
            end
        elseif event == "LOOT_SLOT_CHANGED" then
            --Can happen during AoE Loot
            self:OnLootSlotChanged(...);

        elseif event == "LOOT_SLOT_CLEARED" then
            self:OnLootSlotCleared(...);
        --elseif event == "SHOW_LOOT_TOAST" then
            --not used. When this option is enabled, we'll listen chat loot events all the time instead of after looting
        --    self:OnLootToast(...);
        end
        --print(event, GetTimePreciseSec(), ...)  --
    end
end


do  --UI Notification Mode
    local tinsert = table.insert;
    local tremove = table.remove;

    local function OnUpdate_DisplayLootResult(self, elapsed)
        --Set to an independent frame
        --The response should be as swift as possible but we must count for event delay
        self.t = self.t + elapsed;
        if self.t > 0.15 then   --5/60
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            MainFrame:DisplayLootResult();
        end
    end

    local function OnUpdate_FadeIn_All_ThenHide(self, elapsed)
        if self.toAlpha then
            self.alpha = self.alpha + 8*elapsed;
            if self.alpha > 1 then
                self.alpha = 1;
                self.toAlpha = nil;
            end
            self:SetAlpha(self.alpha);
        end

        self.t = self.t + elapsed;
        if self.t >= AUTO_HIDE_DELAY then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            self:DisplayNextPage();
        end
    end

    local function OnUpdate_FadeIn_Individual(self, elapsed)
        if self.anyAlphaChange then
            self.anyAlphaChange = nil;
            if self.activeFrames then
                for _, obj in ipairs(self.activeFrames) do
                    if obj.toAlpha then
                        self.anyAlphaChange = true;
                        obj.alpha = obj.alpha + 8*elapsed;
                        if obj.alpha > 1 then
                            obj.alpha = 1;
                            obj.toAlpha = nil;
                        end
                        obj:SetAlpha(obj.alpha);
                    end
                end
            end
        end

        if self.toAlpha then
            self.alpha = self.alpha + 8*elapsed;
            if self.alpha > 1 then
                self.alpha = 1;
                self.toAlpha = nil;
            end
            self:SetAlpha(self.alpha);
        end

        if not (self.anyAlphaChange or self.toAlpha) then
            self.t = self.t + elapsed;
            if self.t >= AUTO_HIDE_DELAY then
                self.t = 0;
                self:SetScript("OnUpdate", nil);
                self:DisplayNextPage();
            end
        end
    end

    local function OnUpdate_FadeOut_ThenDisplayNextPage(self, elapsed)
        if self.isFocused then return end;

        if self.anyAlphaChange then
            self.anyAlphaChange = nil;
            for _, obj in ipairs(self.activeFrames) do
                if obj.toAlpha then
                    self.anyAlphaChange = true;
                    obj.alpha = obj.alpha - 8*elapsed;
                    if obj.alpha <= 0 then
                        obj.alpha = 0;
                        obj.toAlpha = nil;
                    end
                    obj:SetAlpha(obj.alpha);
                end
            end
        end

        if not self.anyAlphaChange then
            self.isUpdatingPage = nil;
            self:SetScript("OnUpdate", nil);
            self:ReleaseAll();
            self:DisplayLootResult();
        end
    end

    function MainFrame:QueueDisplayLoot(lootData)
        if not (lootData and lootData.quantity) then return end;
        if self.manualMode then return end;

        if not self.timerFrame then
            self.timerFrame = CreateFrame("Frame");
        end

        if not self.lootQueue then
            self.lootQueue = {};
        end

        tinsert(self.lootQueue, lootData);

        self.timerFrame.t = 0;
        self.timerFrame:SetScript("OnUpdate", OnUpdate_DisplayLootResult);
    end

    function MainFrame:StopQueue()
        if self.timerFrame then
            self.timerFrame:SetScript("OnUpdate", nil);
        end
        self.lootQueue = nil;
    end

    function MainFrame:DisplayNextPage()
        if (self.lootQueue and #self.lootQueue > 0) or (EL.overflowCurrencies and #EL.overflowCurrencies > 0) then
            self.anyAlphaChange = true;
            self.isUpdatingPage = true;
            for _, obj in ipairs(self.activeFrames) do
                obj.toAlpha = 0;
                obj.alpha = obj:GetAlpha();
            end
            self:SetScript("OnUpdate", OnUpdate_FadeOut_ThenDisplayNextPage);
            return true
        else
            self:TryHide();
            return false
        end
    end

    function MainFrame:DisplayLootResult()
        local overflowWarning;
        local anyNotification;  --Other Plumber module may use this as notification (e.g. auto-selected trait)

        if self.lootQueue then
            overflowWarning = false;
        else
            if self:DisplayOverflowCurrencies() then
                overflowWarning = true;
            else
                self:TryHide();
                return
            end
        end

        self:SetManualMode(false);

        --Merge Data
        local numQueued = #self.lootQueue;

        if numQueued > 1 then
            local index1 = 1;
            local index2 = 2;
            local data1 = self.lootQueue[index1];
            local data2 = self.lootQueue[index2];

            while (data1) do
                while (data2) do
                    if MergeData(data1, data2) then
                        tremove(self.lootQueue, index2);
                        numQueued = numQueued - 1;
                    else
                        index2 = index2 + 1;
                    end
                    data2 = self.lootQueue[index2];
                end
                index1 = index1 + 1;
                index2 = index1 + 1;
                data1 = self.lootQueue[index1];
                data2 = self.lootQueue[index2];
            end
        end

        local itemFrame;
        local numExisting = self.activeFrames and #self.activeFrames or 0;

        if numExisting > 0 then
            local foundIndex;
            local dataIndex = 1;
            local data = self.lootQueue[dataIndex];

            while (data) do
                foundIndex = nil;
                for i, object in ipairs(self.activeFrames) do
                    if object:IsSameItem(data) then
                        foundIndex = i;
                        object:SetData(data);
                        break
                    elseif MERGE_SIMILAR_ITEMS and data.slotType == Defination.SLOT_TYPE_ITEM and object.data and MergeSimilarItems(object.data, data) then
                        foundIndex = i;
                        object:SetMergedItem(object.data);
                        break
                    end
                end

                if foundIndex then
                    tremove(self.lootQueue, dataIndex);
                    numQueued = numQueued - 1;
                else
                    dataIndex = dataIndex + 1;
                end
                data = self.lootQueue[dataIndex];
            end
        end

        local numTotal = numQueued + numExisting;
        self:SetMaxPage(math.ceil(numTotal / MAX_ITEM_PER_PAGE));

        if self.isUpdatingPage then
            return
        end

        tsort(self.lootQueue, SortFunc_LootSlot);

        self.alpha = self:GetAlpha();
        local fadeIndividualFrame = self:IsShown() and self.alpha > 0.25;
        local multipage = numTotal > MAX_ITEM_PER_PAGE;
        local lootThisPage;

        if multipage then
            self.isUpdatingPage = true;
            lootThisPage = {};
            local numThisPage = MAX_ITEM_PER_PAGE - numExisting;
            for i = 1, numThisPage do
                lootThisPage[i] = tremove(self.lootQueue, 1);
            end
        else
            lootThisPage = self.lootQueue;
        end

        local enableState = AUTO_LOOT_ENABLE_TOOLTIP and 2 or 0;

        for i, data in ipairs(lootThisPage) do
            if data.slotType == Defination.SLOT_TYPE_MONEY then
                self.MoneyFrame:SetData(data);
                self.MoneyFrame:Show();
                itemFrame = self.MoneyFrame;
            else
                itemFrame = self:AcquireItemFrame();
                itemFrame:SetData(data);
            end

            if itemFrame then
                if not self.activeFrames then
                    self.activeFrames = {};
                end
                local n = #self.activeFrames;
                n = n + 1;
                self.activeFrames[n] = itemFrame;
                itemFrame:EnableMouseScript(enableState);
                itemFrame.hasItem = true;
            end

            if data.isNotification then
                anyNotification = true;
            end
        end

        local numFrames = (self.activeFrames and #self.activeFrames) or 0;

        if numFrames > 0 then
            if overflowWarning then
                AUTO_HIDE_DELAY = 4.0 + numFrames * FADE_DELAY_PER_ITEM;
                self.Header:SetText(L["Reach Currency Cap"]);
            else
                AUTO_HIDE_DELAY = 2.0 + numFrames * FADE_DELAY_PER_ITEM;
                if anyNotification then
                    AUTO_HIDE_DELAY = AUTO_HIDE_DELAY + 2.0;
                end
                self.Header:SetText(L["You Received"]);
            end

            self:LayoutActiveFrames();

            if not multipage then
                self.lootQueue = nil;
            end

            self.t = 0;
            self.toAlpha = 1;

            if fadeIndividualFrame then
                self.anyAlphaChange = true;
                self:SetScript("OnUpdate", OnUpdate_FadeIn_Individual);

                for _, itemFrame in ipairs(self.activeFrames) do
                    itemFrame.toAlpha = 1;
                    itemFrame.alpha = itemFrame:GetAlpha();
                end
            else
                self:SetScript("OnUpdate", OnUpdate_FadeIn_All_ThenHide);
                self:Show();
                self.anyAlphaChange = nil;

                for _, itemFrame in ipairs(self.activeFrames) do
                    itemFrame.toAlpha = nil;
                    itemFrame.alpha = 1;
                    itemFrame:SetAlpha(1);
                end
            end
        else
            self:TryHide(true);
        end

        self:RegisterEvent("GLOBAL_MOUSE_UP");
    end

    function MainFrame:DisplayOverflowCurrencies()
        if EL.overflowCurrencies then
            if not self.lootQueue then
                local pseudoLootQueue = {};

                for i, data in ipairs(EL.overflowCurrencies) do
                    pseudoLootQueue[i] = data;
                end

                self.lootQueue = pseudoLootQueue;
            end

            EL.overflowCurrencies = nil;

            return true
        else
            return false
        end
    end

    function MainFrame:OnHide()
        if self.manualMode then
            CloseLoot();
        end
        if self:IsShown() then return end;  --Due to hiding UIParent
        self:ReleaseAll();
        self.isFocused = false;
        self.manualMode = nil;
        self:StopQueue();
        self:UnregisterEvent("GLOBAL_MOUSE_UP");
        self:UnregisterEvent("BAG_UPDATE_DELAYED");
        EL.playerMoney = nil;
    end
    MainFrame:SetScript("OnHide", MainFrame.OnHide);
end


do  --UI Manually Pickup Mode
    local function OnUpdate_FadeOut_DisableMotion(self, elapsed)
        self.alpha = self.alpha - 8*elapsed;
        if self.alpha <= 0 then
            self.alpha = 0;
            self:SetScript("OnUpdate", nil);
            self:Hide();
        end
        self:SetAlpha(self.alpha);
    end

    local function OnUpdate_FadeIn(self, elapsed)
        self.alpha = self.alpha + 8*elapsed;
        if self.alpha >= 1 then
            self.alpha = 1;
            self.toAlpha = nil;
            self:SetScript("OnUpdate", nil);
        end
        self:SetAlpha(self.alpha);
    end

    function MainFrame:SetManualMode(state)
        state = state == true;
        if state or self.manualMode then
            self:ReleaseAll();
            self:StopQueue();
        elseif (not state) and self.manualMode then
            self:ReleaseAll();
        end
        self.manualMode = state;
        self:HighlightItemFrame(nil);
        if state then
            self.Header:Hide();
            self.HeaderWidgetContainer:Show();
            self:SetBackgroundAlpha(1);
            self.isFocused = false;
            if LOOT_UNDER_MOUSE then
                self:PositionUnderMouse();
            end

            EL:ListenDynamicEvents(false);
            EventGenerator:WatchLootCleared();
        else
            self.Header:Show();
            self.HeaderWidgetContainer:Hide();
            self:SetBackgroundAlpha(BG_OPACITY);
            if LOOT_UNDER_MOUSE then
                self:LoadPosition();
            end
            EventGenerator:Stop();
        end
        self:EnableMouseScript(state);
        self:AddToUISpecialFrames(state);
    end

    function MainFrame:DisplayPendingLoot()
        if not EL.currentLoots then return end;
        --loots have been sorted so the key is no longer slotIndex

        self:SetManualMode(true);

        local itemFrame;
        local activeFrames = {};
        self.activeFrames = activeFrames;

        for i, data in ipairs(EL.currentLoots) do
            itemFrame = self:AcquireItemFrame();
            itemFrame:SetData(data);
            activeFrames[i] = itemFrame;
            itemFrame:SetAlpha(1);
            itemFrame.toAlpha = nil;
            itemFrame:EnableMouseScript(1);
            itemFrame.hasItem = true;
        end

        local fixedFrameWidth = true;
        self:LayoutActiveFrames(fixedFrameWidth);

        self.t = 0;
        self.toAlpha = 1;
        self.alpha = self:GetAlpha();

        self:SetScript("OnUpdate", OnUpdate_FadeIn);
        self:Show();
        self:RegisterEvent("GLOBAL_MOUSE_UP");
    end

    function MainFrame:ClosePendingLoot()
        if not self:IsShown() then return end;
        self.lootQueue = nil;
        self.isUpdatingPage = nil;
        self.alpha = self:GetAlpha();

        if self.activeFrames then
            for _, itemFrame in ipairs(self.activeFrames) do
                itemFrame:EnableMouseScript();
            end
        end

        self:EnableMouseScript(false);

        self:SetScript("OnUpdate", OnUpdate_FadeOut_DisableMotion);
    end

    function MainFrame:LootAllItems()
        local numItems = GetNumLootItems();
        if numItems > 0 then
            for slotIndex = 1, numItems do
                if LootSlotHasItem(slotIndex) then
                    LootSlot(slotIndex);
                end
            end
        end
    end

    function MainFrame:LootAllItemsSorted()
        if self.activeFrames then
            local slotIndex;
            for _, itemFrame in ipairs(self.activeFrames) do
                if itemFrame.data then
                    slotIndex = itemFrame.data.slotIndex;
                    if slotIndex and LootSlotHasItem(slotIndex) then
                        LootSlot(slotIndex);
                    end
                end
            end
        end
    end


    local function OnUpdate_FadeIn_ThenHideLootedFrames(self, elapsed)
        self.alpha = self.alpha + 8*elapsed;
        if self.alpha >= 1 then
            self.alpha = 1;
            self.toAlpha = nil;
            self.t = self.t + elapsed;
            if self.t > 0.5 then
                self.t = 0;
                self:SetScript("OnUpdate", nil);
                if self.lootedFrames then
                    for i, itemFrame in ipairs(self.lootedFrames) do
                        itemFrame:PlaySlideOutAnimation((i - 1) * 0.1);
                    end
                    self.lootedFrames = nil;
                end
                if self.lootErrorCallback then
                    self.lootErrorCallback(self);
                    self.lootErrorCallback = nil;
                end
            end
        else
            self.t = 0;
        end
        self:SetAlpha(self.alpha);
    end

    local function MainFrame_DisplayUnlootedItems(self)
        if not EL.currentLoots then return end;

        self:ReleaseAll();

        local itemFrame, slotIndex;
        local activeFrames = {};
        local n = 0;

        self.activeFrames = activeFrames;

        for i, data in ipairs(EL.currentLoots) do
            slotIndex = data.slotIndex;
            if LootSlotHasItem(slotIndex) then
                itemFrame = self:AcquireItemFrame();
                itemFrame:SetData(data);
                n = n + 1;
                activeFrames[n] = itemFrame;
                itemFrame:SetAlpha(1);
                itemFrame.toAlpha = nil;
                itemFrame:EnableMouseScript(1);
                itemFrame.hasItem = true;

                if self.anyLootInSlot then
                    if self.anyLootInSlot[slotIndex] then
                        self.anyLootInSlot[slotIndex] = true;
                    end
                end
            end
        end

        local fixedFrameWidth = true;
        self:LayoutActiveFrames(fixedFrameWidth);
    end

    function MainFrame:OnErrored(errorType)
        if self.errorMode then return end;
        self.errorMode = true;

        if not EL.currentLoots then return end;
        --loots have been sorted so the key is no longer slotIndex

        self:SetManualMode(true);
        self:StopQueue();

        local itemFrame, slotIndex;
        local activeFrames = {};
        local lootedFrames = {};
        local n = 0;

        self.activeFrames = activeFrames;
        self.lootedFrames = lootedFrames;

        for i, data in ipairs(EL.currentLoots) do
            if LootSlotHasItem(data.slotIndex) then
                data.looted = false;
            else
                data.looted = true;
            end
        end

        tsort(EL.currentLoots, SortFunc_LootSlot);

        for i, data in ipairs(EL.currentLoots) do
            itemFrame = self:AcquireItemFrame();
            itemFrame:SetData(data);
            activeFrames[i] = itemFrame;
            itemFrame:SetAlpha(1);
            itemFrame.toAlpha = nil;
            slotIndex = data.slotIndex;
            if LootSlotHasItem(slotIndex) then
                itemFrame:EnableMouseScript(1);
                itemFrame.hasItem = true;
            else
                itemFrame:EnableMouseScript();
                itemFrame.hasItem = nil;
                n = n + 1;
                lootedFrames[n] = itemFrame;

                if self.anyLootInSlot then
                    if self.anyLootInSlot[slotIndex] then
                        self.anyLootInSlot[slotIndex] = false;
                    end
                end
            end
        end

        local fixedFrameWidth = true;
        self:LayoutActiveFrames(fixedFrameWidth);

        self.t = 0;
        self.toAlpha = 1;
        self.alpha = self:GetAlpha();

        if n > 0 then
            self.lootErrorCallback = function()
                self.t = 0;
                local delay = n * 0.1 + 0.25;
                self:SetScript("OnUpdate", function(_, elapsed)
                    self.t = self.t + elapsed;
                    if self.t > delay then
                        self:SetScript("OnUpdate", nil);
                        MainFrame_DisplayUnlootedItems(self);
                    end
                end);
            end
        else
            self.lootErrorCallback = nil;
        end

        self:SetScript("OnUpdate", OnUpdate_FadeIn_ThenHideLootedFrames);
        self:Show();
        self:RegisterEvent("GLOBAL_MOUSE_UP");
    end
end


do  --Edit Mode
    local SHOW_ITEM_COUNT = false;

    local SAMPLE_ITEMS = {
        {icon = IS_CLASSIC and 135331 or 4622270, name = L["Sample Item 4"], quality = 4, quantity = 1, owned = 99},
        {icon = IS_CLASSIC and 135578 or 463446, name = L["Sample Item 3"], quality = 3, quantity = 20, owned = 99},
        {icon = IS_CLASSIC and 134010 or 4549280, name = L["Sample Item 2"], quality = 2, quantity = 100, owned = 99},
        {icon = IS_CLASSIC and 133980 or 2967113, name = L["Sample Item 1"], quality = 1, quantity = 50, owned = 99},
    };

    function MainFrame:ShowSampleItems()
        if self.timerFrame then
            self.timerFrame:SetScript("OnUpdate", nil);
            self.timerFrame.t = nil;
        end
        self:ReleaseAll();
        self:SetScript("OnUpdate", nil);

        local itemFrame;
        local activeFrames = {};

        for i, data in ipairs(SAMPLE_ITEMS) do
            itemFrame = self:AcquireItemFrame();
            activeFrames[i] = itemFrame;
            itemFrame:SetNameByQuality(data.name, data.quality);
            itemFrame:SetIcon(data.icon);
            itemFrame:SetCount(data);
            itemFrame:Layout();
            itemFrame:SetAlpha(1);
            itemFrame:Show();
            itemFrame:EnableMouseScript();
            if SHOW_ITEM_COUNT then
                itemFrame.IconFrame.Count:SetText("99");
            else
                itemFrame.IconFrame.Count:SetText(nil);
            end
        end

        self.activeFrames = activeFrames;
        self:LayoutActiveFrames();
        self:Show();
        self:SetAlpha(1);
        self:SetBackgroundAlpha(BG_OPACITY);

        self.manualMode = nil;
        self.Header:Hide();
        self.HeaderWidgetContainer:Show();
        self.TakeAllButton:Layout();
        self.TakeAllButton:SetScript("OnKeyDown", nil);
        self:EnableHeaderWidgets(false);
    end

    function MainFrame:EnterEditMode()
        EL:ListenStaticEvent(false);
        EL.overflowCurrencies = nil;

        self.errorMode = nil;
        self.inEditMode = true;
        self:UpdateFrameStrata();
        self:ShowSampleItems();

        if not self.Selection then
            local uiName = "Loot Window";
            local hideLabel = true;
            self.Selection = addon.CreateEditModeSelection(self, uiName, hideLabel);
        end
        self.Selection:ShowHighlighted();
        self.Selection:SetAlpha(1);

        self:LoadPosition();
        self:UnregisterEvent("GLOBAL_MOUSE_UP");
        self:UnregisterEvent("BAG_UPDATE_DELAYED");

        EventGenerator:Stop();
    end

    function MainFrame:ExitEditMode()
        if ENABLE_MODULE then
            EL:ListenStaticEvent(true);
        end

        self.inEditMode = nil;
        self:Disable();
        self:SetAlpha(0);
        self:Hide();
        self:UpdateFrameStrata();
        self:EnableHeaderWidgets(true);

        if self.Selection then
            self.Selection:Hide();
        end

        self:ShowOptions(false);
    end

    local function Options_FontSizeSlider_OnValueChanged(value)
        PlumberDB.LootUI_FontSize = value;
        local locale = GetLocale();
        if locale == "zhCN" or locale == "zhTW" then
            value = value + 2;
        end
        Formatter:CalculateDimensions(value);
        C_Timer.After(0, function()
            MainFrame:ShowSampleItems();
        end);
    end

    local function GetValidFadeOutDelayPerItem(value)
        value = value or 0.25;
        return API.Clamp(value, 0.25, 1.0);
    end

    local function Options_FadeOutDelaySlider_OnValueChanged(value)
        value = GetValidFadeOutDelayPerItem(value);
        PlumberDB.LootUI_FadeDelayPerItem = value;
        FADE_DELAY_PER_ITEM = value;
    end

    local function GetValidItemsPerPage(value)
        value = math.floor(value or 5);
        value = API.Clamp(value, 5, 8);
        return value
    end

    local function Options_ItemsPerPageSlider_OnValueChanged(value)
        value = GetValidItemsPerPage(value);
        PlumberDB.LootUI_ItemsPerPage = value;
        MAX_ITEM_PER_PAGE = value;
    end

    local function Options_OpacitySlider_OnValueChanged(value)
        value = API.Clamp(value, 0, 1);
        if value < 0.01 then
            value = 0;
        end
        BG_OPACITY = value;
        PlumberDB.LootUI_BackgroundAlpha = value;
        MainFrame:SetBackgroundAlpha(BG_OPACITY);
    end

    local function Options_OpacitySlider_OnMouseDown()
        if MainFrame.Selection then
            MainFrame.Selection:SetAlpha(0);
        end
    end

    local function Options_OpacitySlider_OnMouseUp(slider)
        if MainFrame.Selection and (not slider:IsMouseMotionFocus()) then
            MainFrame.Selection:SetAlpha(1);
        end
    end

    local function Options_ForceAutoLoot_OnClick(self, state)
        if state then
            FORCE_AUTO_LOOT = true;
        else
            FORCE_AUTO_LOOT = false;
        end
    end

    local function Options_ForceAutoLoot_ValidityCheck()
        return GetCVarBool("autoLootDefault")
    end

    local function Options_UseHotkey_OnClick(self, state)

    end

    local function Options_ResetPosition_OnClick(self)
        self:Disable();
        PlumberDB.LootUI_PositionX = nil;
        PlumberDB.LootUI_PositionY = nil;
        MainFrame:LoadPosition();
    end

    local function Options_ResetPosition_ShouldEnable(self)
        if PlumberDB.LootUI_PositionX and PlumberDB.LootUI_PositionY then
            return true
        else
            return false
        end
    end

    local function Tooltip_ManualLootInstruction()
        local key = GetModifiedClick("AUTOLOOTTOGGLE");
        key = key or "NONE";
        return L["Manual Loot Instruction Format"]:format(key)
    end

    local function Tooltip_GrowDirection()
        local tooltipFormat = " \n|cffffffff%s|r\n\n%s";
        if PlumberDB.LootUI_GrowUpwards then
            return string.format(tooltipFormat, L["LootUI Option Grow Direction Tooltip 1"], L["LootUI Option Grow Direction Tooltip 2"])
        else
            return string.format(tooltipFormat, L["LootUI Option Grow Direction Tooltip 2"], L["LootUI Option Grow Direction Tooltip 1"])
        end
    end

    local function Options_GrowDirection_OnClick(self)
        MainFrame:LoadPosition();
    end

    local function Validation_TransmogInvented()
        return addon.IsToCVersionEqualOrNewerThan(40000)
    end

    local function Validation_IsRetail()
        return addon.IsToCVersionEqualOrNewerThan(110000)
    end

    local OPTIONS_SCHEMATIC = {
        title = L["EditMode LootUI"],
        widgets = {
            {type = "Slider", label = L["Font Size"], minValue = 10, maxValue = 16, valueStep = 2, onValueChangedFunc = Options_FontSizeSlider_OnValueChanged, formatValueMethod = "Decimal1", dbKey = "LootUI_FontSize"},
            {type = "Slider", label = L["LootUI Option Fade Delay"], minValue = 0.25, maxValue = 1.0, valueStep = 0.25, onValueChangedFunc = Options_FadeOutDelaySlider_OnValueChanged, formatValueMethod = "Decimal2", dbKey = "LootUI_FadeDelayPerItem"},
            {type = "Slider", label = L["LootUI Option Items Per Page"], minValue = 5, maxValue = 8, valueStep = 1, onValueChangedFunc = Options_ItemsPerPageSlider_OnValueChanged, dbKey = "LootUI_ItemsPerPage", tooltip = L["LootUI Option Items Per Page Tooltip"]},
            {type = "Slider", label = L["LootUI Option Background Opacity"], minValue = 0.0, maxValue = 1.0, valueStep = 0.1, onValueChangedFunc = Options_OpacitySlider_OnValueChanged,
                formatValueMethod = "Percentage", dbKey = "LootUI_BackgroundAlpha", tooltip = L["LootUI Option Background Opacity Tooltip"],
                onMouseDownFunc = Options_OpacitySlider_OnMouseDown, onMouseUpFunc = Options_OpacitySlider_OnMouseUp, onEnterFunc = Options_OpacitySlider_OnMouseDown, onLeaveFunc = Options_OpacitySlider_OnMouseUp},
            {type = "Checkbox", label = L["LootUI Option Owned Count"], onClickFunc = nil, dbKey = "LootUI_ShowItemCount"},
            {type = "Checkbox", label = L["LootUI Option New Transmog"], onClickFunc = nil, dbKey = "LootUI_NewTransmogIcon", tooltip = L["LootUI Option New Transmog Tooltip"]:format("|TInterface/AddOns/Plumber/Art/LootUI/NewTransmogIcon:0:0|t"), validityCheckFunc = Validation_TransmogInvented},
            {type = "Checkbox", label = L["LootUI Option Custom Quality Color"], tooltip = L["LootUI Option Custom Quality Color Tooltip"], onClickFunc = nil, dbKey = "LootUI_UseCustomColor", validityCheckFunc = function() return C_ColorOverrides and ColorManager and ColorManager.GetColorDataForItemQuality ~= nil end},
            {type = "Checkbox", label = L["LootUI Option Grow Direction"], tooltip = Tooltip_GrowDirection, onClickFunc = Options_GrowDirection_OnClick, dbKey = "LootUI_GrowUpwards", keepTooltipAfterClicks = true},
            {type = "Checkbox", label = L["LootUI Option Combine Items"], tooltip = L["LootUI Option Combine Items Tooltip"], onClickFunc = nil, dbKey = "LootUI_CombineItems"},
            {type = "Checkbox", label = L["LootUI Option Low Frame Strata"], tooltip = L["LootUI Option Low Frame Strata Tooltip"], onClickFunc = nil, dbKey = "LootUI_LowFrameStrata"},
            {type = "Divider"},
            {type = "Checkbox", label = L["LootUI Option Force Auto Loot"], onClickFunc = Options_ForceAutoLoot_OnClick, validityCheckFunc = Options_ForceAutoLoot_ValidityCheck, dbKey = "LootUI_ForceAutoLoot", tooltip = L["LootUI Option Force Auto Loot Tooltip"], tooltip2 = Tooltip_ManualLootInstruction},
            {type = "Checkbox", label = L["LootUI Option Loot Under Mouse"], onClickFunc = nil, dbKey = "LootUI_LootUnderMouse", tooltip = L["LootUI Option Loot Under Mouse Tooltip"]},
            {type = "Checkbox", label = L["LootUI Option Replace Default"], onClickFunc = nil, dbKey = "LootUI_ReplaceDefaultAlert", tooltip = L["LootUI Option Replace Default Tooltip"], validityCheckFunc = Validation_IsRetail},
            {type = "Checkbox", label = L["LootUI Option Use Hotkey"], onClickFunc = Options_UseHotkey_OnClick, dbKey = "LootUI_UseHotkey", tooltip = L["LootUI Option Use Hotkey Tooltip"]},
            {type = "Keybind", label = L["Take All"], dbKey = "LootUI_HotkeyName", tooltip = L["LootUI Option Use Hotkey Tooltip"], defaultKey = "E"},

            {type = "Divider"},
            {type = "Checkbox", label = L["LootUI Option Use Default UI"], onClickFunc = nil, dbKey = "LootUI_UseStockUI", tooltip = L["LootUI Option Use Default UI Tooltip"], tooltip2 = Tooltip_ManualLootInstruction},

            {type = "Divider"},
            {type = "UIPanelButton", label = L["Reset To Default Position"], onClickFunc = Options_ResetPosition_OnClick, stateCheckFunc = Options_ResetPosition_ShouldEnable, widgetKey = "ResetButton"},
        }
    };


    function MainFrame:ShowOptions(state)
        if state then
            local forceUpdate = true;
            self.OptionFrame = addon.SetupSettingsDialog(self, OPTIONS_SCHEMATIC, forceUpdate);
            self.OptionFrame:Show();
            if self.OptionFrame.requireResetPosition then
                self.OptionFrame.requireResetPosition = false;
                self.OptionFrame:ClearAllPoints();
                local top = self:GetTop();
                local left = self:GetLeft();
                self.OptionFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left + 288, top + 64);
            end
        else
            if self.OptionFrame then
                self.OptionFrame:HideOption(self);
            end

            if not API.IsInEditMode() then
                self:Hide();
            end
        end
    end

    function MainFrame:OnDragStart()
        self:SetMovable(true);
        self:SetDontSavePosition(true);
        self:StartMoving();
    end

    function MainFrame:OnDragStop()
        local DB = PlumberDB;
        self:StopMovingOrSizing();

        local left = self:GetLeft();
        local top = DB.LootUI_GrowUpwards and self:GetBottom() or self:GetTop();

        left = API.Round(left);
        top = API.Round(top);

        --Convert anchor and save position
        DB.LootUI_PositionX = left;
        DB.LootUI_PositionY = top;

        self:LoadPosition();

        if self.OptionFrame and self.OptionFrame:IsOwner(self) then
            local button = self.OptionFrame:FindWidget("ResetButton");
            if button then
                button:Enable();
            end
        end
    end

    function MainFrame:UpdateSampleItems()
        if self:IsShown() and self.inEditMode then
            self:ShowSampleItems();
        end
    end

    --Callback Registery
    local function SettingChanged_ShowItemCount(state, userInput)
        SHOW_ITEM_COUNT = state;
        if userInput then
            MainFrame:UpdateSampleItems();
        end
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_ShowItemCount", SettingChanged_ShowItemCount);

    local function SettingChanged_FadeDelayPerItem(value, userInput)
        FADE_DELAY_PER_ITEM = GetValidFadeOutDelayPerItem(value);
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_FadeDelayPerItem", SettingChanged_FadeDelayPerItem);

    local function SettingChanged_ItemsPerPage(value, userInput)
        MAX_ITEM_PER_PAGE = GetValidItemsPerPage(value);
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_ItemsPerPage", SettingChanged_ItemsPerPage);

    local function SettingChanged_BackgroundAlpha(value, userInput)
        Options_OpacitySlider_OnValueChanged(value or 0.5);
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_BackgroundAlpha", SettingChanged_BackgroundAlpha);

    local function SettingChanged_ReplaceDefaultAlert(state, userInput)
        REPLACE_LOOT_ALERT = state;
        if REPLACE_LOOT_ALERT and addon.GetDBBool("LootUI") then
            EL:ListenAlertSystemEvent(true);
        else
            EL:ListenAlertSystemEvent(false);
        end
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_ReplaceDefaultAlert", SettingChanged_ReplaceDefaultAlert);

    local function SettingChanged_LootUnderMouse(state, userInput)
        LOOT_UNDER_MOUSE = state;
        if userInput then
            if not LOOT_UNDER_MOUSE then
                MainFrame:LoadPosition();
            end
        end
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_LootUnderMouse", SettingChanged_LootUnderMouse);

    local function SettingChanged_CombineItems(state, userInput)
        MERGE_SIMILAR_ITEMS = state;
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_CombineItems", SettingChanged_CombineItems);

    local function SettingChanged_LowFrameStrata(state, userInput)
        LOW_FRAME_STRATA = state;
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_LowFrameStrata", SettingChanged_LowFrameStrata);
end


do  --Dynamic Frame Strata
    local IsInteractingWithNpcOfType = C_PlayerInteractionManager.IsInteractingWithNpcOfType;

    function MainFrame:UpdateFrameStrata()
        if IsInteractingWithNpcOfType(40) then
            --Lower frame strata when using Scrapping Machine so our window appear behind bag UI
            self:SetFrameStrata("LOW");
        else
            if self.inEditMode then
                self:SetFrameStrata("HIGH");
            elseif LOW_FRAME_STRATA and not self.manualMode then
                self:SetFrameStrata("MEDIUM");
                self:Lower();
            else
                self:SetFrameStrata("DIALOG");
            end
        end
    end
end


do  --EventGenerator
    function EventGenerator:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.5 then
            self.t = 0;
            if GetNumLootItems() <= 0 then
                self:SetScript("OnUpdate", nil);
                EL:OnEvent("LOOT_CLOSED");
            end
        end
    end

    function EventGenerator:WatchLootCleared()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function EventGenerator:Stop()
        self.t = 0;
        self:SetScript("OnUpdate", nil);
    end
end


do  --Module Registry
    local STOCK_UI_MUTED = false;

    local function SettingChanged_UseStockUI(state, userInput)
        USE_STOCK_UI = state == true;
        local f = LootFrame;
        if USE_STOCK_UI then
            if f then
                if STOCK_UI_MUTED then
                    STOCK_UI_MUTED = false;
                    if not C_AddOns.IsAddOnLoaded("Xloot") then
                        f:RegisterEvent("LOOT_OPENED");
                        f:RegisterEvent("LOOT_CLOSED");
                    end
                end
            end

            if not MainFrame.inEditMode then
                MainFrame:Disable();
            end

            EL:ListenAlertSystemEvent(false);
        else
            if addon.GetDBBool("LootUI") then
                if f then
                    if not STOCK_UI_MUTED then
                        STOCK_UI_MUTED = true;
                        f:UnregisterEvent("LOOT_OPENED");
                        f:UnregisterEvent("LOOT_CLOSED");
                    end
                end

                if REPLACE_LOOT_ALERT then
                    EL:ListenAlertSystemEvent(true);
                end
            end
        end
    end
    addon.CallbackRegistry:RegisterSettingCallback("LootUI_UseStockUI", SettingChanged_UseStockUI);

    local function EnableModule(state)
        if state then
            ENABLE_MODULE = true;
            EL.enabled = true;
            EL.currentLoots = {};
            EL:ListenStaticEvent(true);
            EL:SetScript("OnEvent", EL.OnEvent);

            if MainFrame.Init then
                MainFrame:Init();
            end

            MainFrame:OnUIScaleChanged();

            if addon.GetDBBool("LootUI_ReplaceDefaultAlert") and (not addon.GetDBBool("LootUI_UseStockUI")) then
                EL:ListenAlertSystemEvent(true);
            else
                EL:ListenAlertSystemEvent(false);
            end

            if addon.GetDBBool("LootUI_UseStockUI") then
                SettingChanged_UseStockUI(true);
            else
                SettingChanged_UseStockUI(false);
            end
        elseif ENABLE_MODULE then
            ENABLE_MODULE = false;
            EL.enabled = false;
            EL:ListenStaticEvent(false);
            EL:ListenDynamicEvents(false);
            EL:SetScript("OnEvent", nil);
            EL:SetScript("OnUpdate", nil);
            MainFrame:Disable();

            EL:ListenAlertSystemEvent(false);
            SettingChanged_UseStockUI(true);
        end
    end


    local function OptionToggle_OnClick(self, button)
        if MainFrame.OptionFrame and MainFrame.OptionFrame:IsShown() and (MainFrame.OptionFrame:IsOwner(self) or MainFrame.OptionFrame:IsOwner(MainFrame)) then
            MainFrame:ShowOptions(false);
            MainFrame:ExitEditMode();
        else
            MainFrame:EnterEditMode();
            MainFrame:ShowOptions(true);
        end
    end

    local moduleData = {
        name = addon.L["ModuleName LootUI"],
        dbKey = "LootUI",
        description = addon.L["ModuleDescription LootUI"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 0,
        moduleAddedTime = 1727793830,
        optionToggleFunc = OptionToggle_OnClick,

        visibleInEditMode = true,
        enterEditMode = function()
            MainFrame:EnterEditMode();
        end,
        exitEditMode = function()
            MainFrame:ExitEditMode();
        end,
    };

    addon.ControlCenter:AddModule(moduleData);
end


do  --Use Loot UI as Notification Center
    function MainFrame:QueueDisplaySpell(spellData)
        if not spellData.spellID then return false end;

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
		};

		self:QueueDisplayLoot(data);
    end
end
