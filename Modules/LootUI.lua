local _, addon = ...
local API = addon.API;
local CoinUtil = addon.CoinUtil;
local P_Loot = addon.P_Loot;


local MainFrame = P_Loot.MainFrame;
local Defination = P_Loot.Defination;
local Formatter = P_Loot.Formatter;


local LootSlot = LootSlot;
local CloseLoot = CloseLoot;
local LootSlotHasItem = LootSlotHasItem;
local GetLootSlotLink = GetLootSlotLink;
local GetLootSlotType = GetLootSlotType;
local GetLootSlotInfo = GetLootSlotInfo;
local GetNumLootItems = GetNumLootItems;
local IsFishingLoot = IsFishingLoot;

local GetMoney = GetMoney;
local GetItemReagentQualityByItemInfo = C_TradeSkillUI.GetItemReagentQualityByItemInfo;
local GetItemInfoInstant = C_Item.GetItemInfoInstant;
local IsModifiedClick = IsModifiedClick;
local GetCVarBool = C_CVar.GetCVarBool;

local tsort = table.sort;
local pairs = pairs;
local ipairs = ipairs;
local match = string.match;
local tonumber = tonumber;
local CreateFrame = CreateFrame;

local GetReputationChangeFromText = API.GetReputationChangeFromText;


local MAX_ITEM_PER_PAGE = 5;
local EVENT_DURATION = 1.5;     --Unregister ChatMSG x seconds after LOOT_CLOSED
local AUTO_HIDE_DELAY = 3.0;    --Determined by the number of items. From 2.0s to 3.0s


local EL = CreateFrame("Frame");

local MANUAL_MODE = false;      --If true, pause processing chat loot msg and pick up items by clicking it.


local function SortFunc_LootSlot(a, b)
    if a.slotType ~= b.slotType then
        return a.slotType > b.slotType
    end

    if a.questType ~= b.questType then
        return a.questType > b.questType
    end

    if a.quality ~= b.quality then
        return a.quality > b.quality
    end

    if a.name ~= b.name then
        return a.name < b.name
    end

    if a.craftQuality ~= b.craftQuality then
        return a.craftQuality > b.craftQuality
    end

    return a.slotIndex < b.slotIndex
end

local function GetItemCountFromText(text)
    local count = match(text, "x(%d+)$");
    if count then
        return tonumber(count)
    end
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
                if d1.id == d2.id then
                    d1.quantity = d1.quantity + d2.quantity;
                    return true
                end
            end
        end
    end
    return false
end

local function ShouldAutoLoot()
    return GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE")
end


do  --Process Loot Message
    function EL:ProcessMessageItem(text)
        --Do we need to use the whole itemlink?
        local itemID = match(text, "item:(%d+)", 1);
        if itemID then
            itemID = tonumber(itemID);
            if itemID then
                for _, data in ipairs(self.currentLoots) do
                    if not data.looted then
                        if data.slotType == Defination.SLOT_TYPE_ITEM and data.id == itemID then
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

    --[[
    function EL:ProcessMessageItem(text)
        --Debug Override
        local data = {
            name = "The Assembly of the Deeps",
            quantity = 150,
            slotType = Defination.SLOT_TYPE_REP,
            questType = 0,
            quality = 0,
            slotIndex = -1;
            craftQuality = 0,
        };
        MainFrame:QueueDisplayLoot(data);
    end
    --]]

    function EL:ProcessMessageCurrency(text)
        local currencyID = match(text, "currency:(%d+)", 1);
        if currencyID then
            currencyID = tonumber(currencyID);
            if currencyID then
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
            };
            MainFrame:QueueDisplayLoot(data);
        end
    end
end


do  --Event Handler
    local STATIC_EVENTS = {
        "LOOT_OPENED", "LOOT_CLOSED", "LOOT_READY",
        "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED",
    };

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

    function EL:ListenSlotEvent(state)
        if state and MANUAL_MODE then
            self:RegisterEvent("LOOT_SLOT_CHANGED");
            self:RegisterEvent("LOOT_SLOT_CLEARED");
        else
            self:UnregisterEvent("LOOT_SLOT_CHANGED");
            self:UnregisterEvent("LOOT_SLOT_CLEARED");
        end
    end

    function EL:OnLootOpened(isAutoLoot, acquiredFromItem)
        self.lootOpened = true;
        self.currentLoots = {};
        self.anyLootInSlot = {};
        self.playerMoney = GetMoney();

        --print("isAutoLoot", isAutoLoot, GetCVarBool("autoLootDefault"), IsModifiedClick("AUTOLOOTTOGGLE"));
        MANUAL_MODE = not isAutoLoot --not ShouldAutoLoot();

        local numItems = GetNumLootItems();

        if numItems == 0 then
           self:ListenSlotEvent(false);
           CloseLoot();
           return
        else
            self:ListenSlotEvent(true);
            self:ListenChatEvents(true);
            if acquiredFromItem then
				PlaySound(SOUNDKIT.UI_CONTAINER_ITEM_OPEN);
			elseif IsFishingLoot() then
				PlaySound(SOUNDKIT.FISHING_REEL_IN);
            end
        end

        local icon, name, quantity, currencyID, quality, locked, isQuestItem, questID, isActive, isCoin;
        local slotType, link, craftQuality, id, _, classID, subclassID, questType, hideCount;
        local index = 0;

        for slotIndex = 1, numItems do
            if LootSlotHasItem(slotIndex) then
                self.anyLootInSlot[slotIndex] = true;
                icon, name, quantity, currencyID, quality, locked, isQuestItem, questID, isActive, isCoin = GetLootSlotInfo(slotIndex);
                quality = quality or 1;
                slotType = GetLootSlotType(slotIndex) or 0;
                link = GetLootSlotLink(slotIndex);

                hideCount = nil;
                questType = nil;
                craftQuality = nil;
                classID, subclassID = nil, nil;

                if isCoin then --Enum.LootSlotType.Money
                    slotType = Defination.SLOT_TYPE_MONEY;  --Sort money to top
                else
                    if slotType == Defination.SLOT_TYPE_ITEM then
                        if link then
                            id, _, _, _, _, classID, subclassID = GetItemInfoInstant(link);
                            if classID == 5 or classID == 7 then
                                craftQuality = GetItemReagentQualityByItemInfo(link);
                            elseif classID == 2 or classID == 4 then
                                hideCount = true;
                            end
                        end

                        if questID and not isActive then
                            questType = Defination.QUEST_TYPE_NEW;
                        elseif questID or isQuestItem then  --Quest Required Item doesn't have questID
                            questType = Defination.QUEST_TYPE_ONGOING;
                        end
                    elseif currencyID then
                        id = currencyID;
                        slotType = Defination.SLOT_TYPE_CURRENCY;
                    end
                end

                craftQuality = craftQuality or 0;
                questType = questType or 0;

                index = index + 1;
                self.currentLoots[index] = {
                    icon = icon,
                    name = name,
                    quantity = quantity,
                    locked = locked,
                    quality = quality,
                    id = id,
                    slotType = slotType,
                    slotIndex = slotIndex,
                    link = link,
                    craftQuality = craftQuality,
                    questType = questType,
                    looted = false,
                    hideCount = hideCount,
                    classID = classID,
                    subclassID = subclassID,
                };
            else
                self.anyLootInSlot[slotIndex] = false;
            end
        end

        if MANUAL_MODE then
            tsort(self.currentLoots, SortFunc_LootSlot);
            MainFrame:DisplayPendingLoot();
        else
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
        self:ListenSlotEvent(false);
        CloseLoot();
        if MainFrame.manualMode then
            MainFrame:ClosePendingLoot();
        end
    end

    function EL:OnUpdate_UnregisterDynamicEvents(elapsed)
        self.t = self.t + elapsed;
        if self.t > EVENT_DURATION then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            self:ListenChatEvents(false);
        end
    end

    function EL:ListenChatEvents(state)
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

    function EL:OnLootSlotChanged(slotIndex)
        --print("SlotChanged", slotIndex);
    end

    function EL:OnLootSlotCleared(slotIndex)
        if self.anyLootInSlot then
            if self.anyLootInSlot[slotIndex] then
                self.anyLootInSlot[slotIndex] = false;
                MainFrame:SetLootSlotCleared(slotIndex);
            end
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
        else
            if MANUAL_MODE then
                if event == "LOOT_SLOT_CHANGED" then
                    --Can happen during AoE Loot
                    self:OnLootSlotChanged(...);
                elseif event == "LOOT_SLOT_CLEARED" then
                    self:OnLootSlotCleared(...);
                end
            else
                if event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_CURRENCY" or event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
                    --This is the most robust way to determine what's been looted.
                    --Less responsive and more costly
                    if self.currentLoots then
                        local guid = select(12, ...);
                        if event == "CHAT_MSG_LOOT" then
                            if guid == self.playerGUID then
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
                        self.playerMoney = money;
                    end
                end
            end
        end
        --print(event, GetTimePreciseSec(), ...)
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
            self.t = 0;
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
            if self.lootQueue then
               self:DisplayNextPage();
            else
                self:TryHide();
            end
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
                if self.lootQueue then
                   self:DisplayNextPage();
                else
                    self:TryHide();
                end
            end
        end
    end

    local function OnUpdate_FadeOut_ThenDisplayNextPage(self, elapsed)
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

    function MainFrame:DisplayNextPage()
        if self.lootQueue and #self.lootQueue > 0 then
            self.anyAlphaChange = true;
            self.isUpdatingPage = true;
            for _, obj in ipairs(self.activeFrames) do
                obj.toAlpha = 0;
                obj.alpha = obj:GetAlpha();
            end
            self:SetScript("OnUpdate", OnUpdate_FadeOut_ThenDisplayNextPage);
        else
            self:TryHide();
        end
    end

    function MainFrame:DisplayLootResult()
        if self.lootQueue then
            if self.Init then
                self:Init();
            end
        else
            self:TryHide();
            return
        end

        self:SetManualMode(false);

        --Merge Data
        local numQueued = #self.lootQueue;

        if numQueued > 1 then
            local foundIndex;
            local index1 = 1;
            local index2 = 2;
            local data1 = self.lootQueue[index1];
            local data2 = self.lootQueue[index2];

            while (data1) do
                while (data2) do
                    if MergeData(data1, data2) then
                        tremove(self.lootQueue, index2);
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
                    end
                end

                if foundIndex then
                    tremove(self.lootQueue, dataIndex);
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
        local fadeIndividualFrame = self:IsShown() and self.alpha > 0.5;
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

                if fadeIndividualFrame then
                    itemFrame.toAlpha = 1;
                    itemFrame.alpha = 0;
                else
                    itemFrame.toAlpha = nil;
                    itemFrame.alpha = 1;
                    itemFrame:SetAlpha(1);
                end

                itemFrame:EnableMouseScript(false);
            end
        end

        local numFrames = (self.activeFrames and #self.activeFrames) or 0;
        local frameWidth, frameHeight;

        local r = (MAX_ITEM_PER_PAGE - numFrames)/MAX_ITEM_PER_PAGE;
        AUTO_HIDE_DELAY = r * 2.0 + (1 - r) * 3.0;

        if numFrames > 0 then
            frameWidth, frameHeight = self:LayoutActiveFrames();
        else
            frameWidth, frameHeight = 192, 32;
        end

        local maxFrameWidth = Formatter.BUTTON_WIDTH + Formatter.BUTTON_SPACING * 2;
        if frameWidth > maxFrameWidth then
            frameWidth = maxFrameWidth;
        end

        self:SetSize(frameWidth, frameHeight);
        self:Reposition();
        local scale = self:GetEffectiveScale();
        self:SetBackgroundSize((frameWidth + Formatter.ICON_BUTTON_HEIGHT) * scale, (frameHeight + Formatter.ICON_BUTTON_HEIGHT) * scale);

        if not multipage then
            self.lootQueue = nil;
        end

        self.t = 0;
        self.toAlpha = 1;

        if self:IsShown() then
            self.anyAlphaChange = true;
            self:SetScript("OnUpdate", OnUpdate_FadeIn_Individual);
        else
            self:SetScript("OnUpdate", OnUpdate_FadeIn_All_ThenHide);
            self:Show();
            self.anyAlphaChange = nil;
        end
    end
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
        if self.manualMode == state then return end

        self.manualMode = state;
        self:ReleaseAll();

        self:HighlightItemFrame(nil);
        if state then
            self.Header:Hide();
            self.TakeAllButton:Show();
            self.BackgroundFrame:SetBackgroundAlpha(0.90);
        else
            self.Header:Show();
            self.TakeAllButton:Hide();
            self.BackgroundFrame:SetBackgroundAlpha(0.50);
        end
    end

    function MainFrame:DisplayPendingLoot()
        if not EL.currentLoots then return end;
        --loots have been sorted so the key is no longer slotIndex

        if self.Init then
            self:Init();
        end

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
            itemFrame:EnableMouseScript(true);
        end

        local _, frameHeight = self:LayoutActiveFrames();

        local frameWidth = Formatter.BUTTON_WIDTH + Formatter.BUTTON_SPACING * 2;
        self:SetSize(frameWidth, frameHeight);
        self:Reposition();
        local scale = self:GetEffectiveScale();
        self:SetBackgroundSize(frameWidth * scale, (frameHeight + Formatter.ICON_BUTTON_HEIGHT) * scale);

        self.t = 0;
        self.toAlpha = 1;
        self.alpha = self:GetAlpha();

        self:SetScript("OnUpdate", OnUpdate_FadeIn);
        self:Show();
    end

    function MainFrame:ClosePendingLoot()
        if not self:IsShown() then return end;
        self.lootQueue = nil;
        self.isUpdatingPage = nil;
        self.alpha = self:GetAlpha();

        if self.activeFrames then
            for _, itemFrame in ipairs(self.activeFrames) do
                itemFrame:EnableMouseScript(false);
            end
        end

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
                slotIndex = itemFrame.data.slotIndex;
                if slotIndex and LootSlotHasItem(slotIndex) then
                    LootSlot(slotIndex);
                end
            end
        end
    end
end


do
    local ENABLE_MODULE = false;

    local function EnableModule(state)
        if state then
            EL:ListenStaticEvent(true);
            EL:SetScript("OnEvent", EL.OnEvent);
            if MainFrame.Init then
                MainFrame:Init();
            end
            MainFrame:OnUIScaleChanged();
            if LootFrame then
                LootFrame:UnregisterEvent("LOOT_OPENED");
                LootFrame:UnregisterEvent("LOOT_CLOSED");
            end
        elseif ENABLE_MODULE then
            ENABLE_MODULE = false;
            EL:ListenStaticEvent(false);
            EL:SetScript("OnEvent", nil);
            EL:SetScript("OnUpdate", nil);
            MainFrame:Disable();

            if LootFrame then
                LootFrame:RegisterEvent("LOOT_OPENED");
                LootFrame:RegisterEvent("LOOT_CLOSED");
            end
        end
    end

    C_Timer.After(0, function ()
        EnableModule(true);
        --[[
        MainFrame:Show();
        MainFrame:SetAlpha(1);
        local frameHeight = 64;
        local frameWidth = Formatter.BUTTON_WIDTH + Formatter.BUTTON_SPACING * 2;
        MainFrame:SetSize(frameWidth, frameHeight);
        MainFrame:Reposition();
        local scale = MainFrame:GetEffectiveScale();
        MainFrame:SetBackgroundSize(frameWidth * scale, (frameHeight + Formatter.ICON_BUTTON_HEIGHT) * scale);
        MainFrame.TakeAllButton:Show();
        --]]
    end)
end