local _, addon = ...
local API = addon.API;
local CoinUtil = addon.CoinUtil;

local LootSlot = LootSlot;
local CloseLoot = CloseLoot;
local LootSlotHasItem = LootSlotHasItem;
local GetLootSlotLink = GetLootSlotLink;
local GetLootSlotType = GetLootSlotType;
local GetLootSlotInfo = GetLootSlotInfo;
local GetNumLootItems = GetNumLootItems;

local GetMoney = GetMoney;
local GetItemReagentQualityByItemInfo = C_TradeSkillUI.GetItemReagentQualityByItemInfo;
local GetItemInfoInstant = C_Item.GetItemInfoInstant;
local GetPhysicalScreenSize = GetPhysicalScreenSize;
local IsModifiedClick = IsModifiedClick;
local GetCVarBool = C_CVar.GetCVarBool;
local InCombatLockdown = InCombatLockdown;

local tsort = table.sort;
local pairs = pairs;
local ipairs = ipairs;
local match = string.match;
local tonumber = tonumber;
local CreateFrame = CreateFrame;

local GetReputationChangeFromText = API.GetReputationChangeFromText;


local SLOT_TYPE_CURRENCY = 3;
local SLOT_TYPE_MONEY= 10;      --Game value is 2, but we sort it to top
local SLOT_TYPE_REP = 9;        --Custom Value
local SLOT_TYPE_ITEM = 1;

local QUEST_TYPE_NEW = 2;
local QUEST_TYPE_ONGOING = 1;

local BASE_FONT_SIZE = 12;      --GameFontNormal

local ICON_SIZE = 32;
local TEXT_BUTTON_HEIGHT = 16;
local ICON_BUTTON_HEIGHT = ICON_SIZE;
local ICON_TEXT_GAP = 8;
local DOT_SIZE = 18;
local COUNT_NAME_GAP = 0.5 * BASE_FONT_SIZE;
local NAME_WIDTH = 16 * BASE_FONT_SIZE;
local BUTTON_WIDTH = ICON_SIZE + ICON_TEXT_GAP + NAME_WIDTH;
local BUTTON_SPACING = 12;
local MAX_ITEM_PER_PAGE = 5;

local EVENT_DURATION = 1.5;     --Unregister ChatMSG x seconds after LOOT_CLOSED
local AUTO_HIDE_DELAY = 3.0;


--QuestType: 0 (not quest item), 1 (activeQuest), 2 (startNewQuest)
local EL = CreateFrame("Frame");
local MainFrame = CreateFrame("Frame");
MainFrame:Hide();
MainFrame:SetAlpha(0);

local MANUAL_MODE = false;      --If true, pause processing chat loot msg and pick up items by clicking it.


local Formatter = {};
do
    Formatter.tostring = tostring;
    Formatter.strlen = string.len;
    local Round = API.Round;

    function Formatter:Init()
        Formatter:CalculateDimensions();

        if not self.DummyFontString then
            self.DummyFontString = MainFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal");
            self.DummyFontString:Hide();
            self.DummyFontString:SetPoint("TOP", UIParent, "BOTTOM", 0, -64);
        end
        local font = GameFontNormal:GetFont();
        self.DummyFontString:SetFont(font, BASE_FONT_SIZE, "");

        self.numberWidths = {};
    end

    function Formatter:CalculateDimensions(fontSize)
        if not fontSize then
            local _;
            _, fontSize = GameFontNormal:GetFont();
        end

        local locale = GetLocale();

        if locale == "zhCN" or locale == "zhTW" then
            fontSize = 0.8 * fontSize;
        end

        BASE_FONT_SIZE = fontSize;
        ICON_SIZE = Round(32/12 * fontSize);
        TEXT_BUTTON_HEIGHT = Round(16/12 * fontSize);
        ICON_BUTTON_HEIGHT = ICON_SIZE;
        ICON_TEXT_GAP = Round(ICON_SIZE / 4);
        DOT_SIZE = Round(1.5 * fontSize);
        COUNT_NAME_GAP = Round(0.5 * BASE_FONT_SIZE);
        NAME_WIDTH = Round(16 * BASE_FONT_SIZE);
        BUTTON_WIDTH = ICON_SIZE + ICON_TEXT_GAP + BASE_FONT_SIZE + COUNT_NAME_GAP + NAME_WIDTH;
    end

    function Formatter:GetNumberWidth(number)
        number = number or 0;
        local digits = self.strlen(self.tostring(number));

        if not self.numberWidths[digits] then
            local text = "+";
            for i = 1, digits do
                text = text .. "8";
            end
            self.DummyFontString:SetText(text);
            self.numberWidths[digits] = Round(self.DummyFontString:GetWidth());
        end

        return self.numberWidths[digits]
    end
end


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
            if d1.slotType == SLOT_TYPE_REP then
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
    print(GetCVarBool("autoLootDefault"), IsModifiedClick("AUTOLOOTTOGGLE"))
    return GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE")
end


do  --Loot Table
    function EL:WipeLootTable()
        self.loots = {};
    end

    function EL:ProcessCurrentLootTable()
        --After looting complete
        if self.currentLoots then
            local ICON_TEXT_FORMAT = "|T%s:0:0|t %s";
            for _, data in ipairs(self.currentLoots) do
                local color = ITEM_QUALITY_COLORS[data.quality].color;
                local name = color:WrapTextInColorCode(data.name);
                if data.craftQuality > 0 then
                    name = name.." |cffffd100T"..data.craftQuality.."|r";
                end

                name = name.." x"..data.quantity;

                local text;
                if data.slotType == SLOT_TYPE_MONEY then
                    local rawCopper = CoinUtil:GetCopperFromCoinText(data.name);
                    text = C_CurrencyInfo.GetCoinTextureString(rawCopper);
                else
                    text = ICON_TEXT_FORMAT:format(data.icon, name);
                end
            end
        end

        self.currentLoots = nil;
    end

    function EL:ProcessMessageItem(text)
        --Do we need to use the whole itemlink?
        local itemID = match(text, "item:(%d+)", 1);
        if itemID then
            itemID = tonumber(itemID);
            if itemID then
                for _, data in ipairs(self.currentLoots) do
                    if not data.looted then
                        if data.slotType == 1 and data.id == itemID then
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

    function EL:ProcessMessageCurrency(text)
        local currencyID = match(text, "currency:(%d+)", 1);
        if currencyID then
            currencyID = tonumber(currencyID);
            if currencyID then
                for _, data in ipairs(self.currentLoots) do
                    if not data.looted then
                        if data.slotType == SLOT_TYPE_CURRENCY and data.id == currencyID then
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
            local data = {
                name = factionName,
                quantity = amount or 0,
                slotType = SLOT_TYPE_REP,
                questType = 0,
                quality = 0,
            };
            MainFrame:QueueDisplayLoot(data);
        end
    end
end


do  --Event Handler
    local STATIC_EVENTS = {
        "LOOT_OPENED", "LOOT_CLOSED",
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

        MANUAL_MODE = not ShouldAutoLoot();

        local numItems = GetNumLootItems();

        if numItems == 0 then
           self:ListenSlotEvent(false);
           CloseLoot();
           return
        else
            self:ListenSlotEvent(true);
            self:ListenChatEvents(true);
        end

        local icon, name, quantity, currencyID, quality, locked, isQuestItem, questID, isActive, isCoin;
        local slotType, link, craftQuality, id, _, classID, subclassID, questType, hideCount;

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

                if isCoin or slotType == 2 then --Enum.LootSlotType.Money
                    slotType = SLOT_TYPE_MONEY;  --Sort money to top
                end

                if slotType == SLOT_TYPE_ITEM then
                    if link then
                        id, _, _, _, _, classID, subclassID = GetItemInfoInstant(link);
                        if classID == 5 or classID == 7 then
                            craftQuality = GetItemReagentQualityByItemInfo(link);
                        elseif classID == 2 or classID == 4 then
                            hideCount = true;
                        end
                    end

                    if questID and not isActive then
                        questType = QUEST_TYPE_NEW;
                    elseif questID or isQuestItem then
                        questType = QUEST_TYPE_ONGOING;
                    end
                elseif currencyID then
                    id = currencyID;
                    slotType = SLOT_TYPE_CURRENCY;
                end

                craftQuality = craftQuality or 0;
                questType = questType or 0;

                self.currentLoots[slotIndex] = {
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
                };
            else
                self.currentLoots[slotIndex] = {};
            end
        end

        tsort(self.currentLoots, SortFunc_LootSlot);

        if MANUAL_MODE then
            print("MANU")
            MainFrame:DisplayPendingLoot();
        else
            for slotIndex = 1, numItems do
                LootSlot(slotIndex);
            end
        end
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
        print(slotIndex);
    end

    function EL:OnLootSlotCleared(slotIndex)
        if self.anyLootInSlot then
            self.anyLootInSlot[slotIndex] = false;
        end
        print(slotIndex);
    end

    function EL:OnEvent(event, ...)
        if event == "LOOT_OPENED" then
            self:OnLootOpened(...);
            print(event, GetTimePreciseSec(), ...)
        elseif event == "LOOT_READY" then
            local isAutoLoot =  ...
        elseif event == "LOOT_CLOSED" then
            print(event, GetTimePreciseSec(), ...)
            --Usually fire two times in a row. In this case "GetNumLootItems" returns the re-looted value during the first trigger.
            --Can fire only one time if player leaves the corpse fast. And "LOOT_SLOT_CLEARED" won't trigger. Items are fully looted and "GetNumLootItems" returns 0
            self:OnLootClosed();
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
                                slotType = SLOT_TYPE_MONEY,
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


local CreateItemFrame;
local ItemFrameMixin = {};
do  --UI LootButton
    function ItemFrameMixin:SetIcon(texture, data)
        self.showIcon = texture ~= nil;
        self.Count:ClearAllPoints();
        self.Text:ClearAllPoints();
        local f = self.IconFrame;
        if texture then
            f.Icon:SetTexture(texture);
            f:SetSize(ICON_SIZE, ICON_SIZE);
            f:SetPoint("LEFT", self, "LEFT", 0, 0);
            f.IconOverlay:SetSize(2*ICON_SIZE, 2*ICON_SIZE);
            self.Count:SetPoint("LEFT", self, "LEFT", ICON_SIZE + ICON_TEXT_GAP, 0);
            self.Text:SetPoint("LEFT", self, "LEFT", ICON_SIZE + ICON_TEXT_GAP, 0);
            self:SetHeight(ICON_BUTTON_HEIGHT);

            if data then
                if data.questType ~= 0 then
                    if data.questType == QUEST_TYPE_NEW then
                        f.IconOverlay:SetTexCoord(0.625, 0.75, 0, 0.125);
                    elseif data.questType == QUEST_TYPE_ONGOING then
                        f.IconOverlay:SetTexCoord(0.75, 0.875, 0, 0.125);
                    end
                    f.IconOverlay:Show();
                    self:SetBorderColor(1, 195/255, 41/255);
                elseif data.craftQuality ~= 0 then
                    f.IconOverlay:SetTexCoord((data.craftQuality - 1) * 0.125, data.craftQuality * 0.125, 0, 0.125);
                    f.IconOverlay:Show();
                else
                    f.IconOverlay:Hide();
                end
            else
                f.IconOverlay:Hide();
            end

            f:Show();
        else
            f:Hide();
            self.Text:SetPoint("LEFT", self, "LEFT", 0, 0);
            self:SetHeight(TEXT_BUTTON_HEIGHT);
        end
    end

    function ItemFrameMixin:SetBorderColor(r, g, b)
        self.IconFrame.Border:SetVertexColor(r, g, b);
    end

    function ItemFrameMixin:SetNameByColor(name, color)
        color = color or API.GetItemQualityColor(1);
        local r, g, b = color:GetRGB();
        self.Text:SetText(name);
        self.Text:SetTextColor(r, g, b);
        self:SetBorderColor(r, g, b);
    end

    function ItemFrameMixin:SetNameByQuality(name, quality)
        self:SetNameByColor(name, API.GetItemQualityColor(quality or 1));
    end

    function ItemFrameMixin:SetData(data)
        if self.data and self.data.quantity ~= 0 then
            data.oldQuantity = self.data.quantity;
            data.quantity = self.data.quantity + data.quantity;
        end

        if data.slotType == SLOT_TYPE_ITEM then
            self:SetItem(data);
        elseif data.slotType == SLOT_TYPE_CURRENCY then
            self:SetCurrency(data);
        elseif data.slotType == SLOT_TYPE_REP then
            self:SetReputation(data);
        end

        self.data = data;
    end

    function ItemFrameMixin:SetCount(data)
        if (not data) or data.hideCount then
            self.Count:Hide();
        else
            local countWidth = Formatter:GetNumberWidth(data.quantity);
            self.Text:ClearAllPoints();
            self.Text:SetPoint("LEFT", self, "LEFT",  ICON_SIZE + ICON_TEXT_GAP + countWidth + COUNT_NAME_GAP, 0);
            if data.oldQuantity then
                self:AnimateItemCount(data.oldQuantity, data.quantity);
                data.oldQuantity = nil;
            else
                self.Count:SetText("+"..data.quantity);
            end
            self.Count:Show();
        end
    end

    function ItemFrameMixin:SetItem(data)
        self:SetNameByQuality(data.name, data.quality);
        self:SetIcon(data.icon, data);
        self:SetCount(data);
    end

    function ItemFrameMixin:SetCurrency(data)
        self:SetNameByQuality(data.name, data.quality);
        self:SetIcon(data.icon);
        self:SetCount(data);
    end

    function ItemFrameMixin:SetReputation(data)
        local name = string.format("%s +%s", data.name, (data.quantity or ""));
        self:SetIcon(nil);
        self:SetCount(nil);
        self.Text:SetText(name);
        self.Text:SetTextColor(0.5, 0.5, 1);
    end

    function ItemFrameMixin:IsSameItem(data)
        if self.data then
            if self.data.slotType == data.slotType then
                if data.slotType == SLOT_TYPE_REP then
                    return self.data.name == data.name
                else
                    return self.data.id == data.id
                end
            end
        end
        return false
    end

    function ItemFrameMixin:UpdatePixel()
        local SCREEN_WIDTH, SCREEN_HEIGHT = GetPhysicalScreenSize();
        self.IconFrame.Border:SetScale(768/SCREEN_HEIGHT);
    end

    function ItemFrameMixin:OnRemoved()
        self.data = nil;
        self:StopAnimating();
    end

    function ItemFrameMixin:AnimateItemCount(oldValue, newValue)
        self.AnimItemCount:Stop();
        if self.Count:IsShown() then
            self.Count:SetText("+"..newValue);
            self.DummyCount:SetText("+"..oldValue);
            self.DummyCount:Show();
            self.AnimItemCount:Play();
        end
    end

    function ItemFrameMixin:OnEnter()
        --Effective during Manual Mode
        if self.data.slotType == SLOT_TYPE_ITEM then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:SetLootItem(self.data.slotIndex);
        elseif self.data.slotType == SLOT_TYPE_CURRENCY then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:SetLootCurrency(self.data.slotIndex);
        end
    end

    function ItemFrameMixin:OnLeave()
        --Effective during Manual Mode
        GameTooltip:Hide();
    end

    function ItemFrameMixin:OnMouseDown()
        LootSlot(self.data.slotIndex);
    end

    function ItemFrameMixin:EnableMouseScript(state)
        if state then
            self:EnableMouse(true);
            self:EnableMouseMotion(true);
        else
            self:EnableMouse(false);
            self:EnableMouseMotion(false);
        end
    end

    local function CreateIconFrame(itemFrame)
        local f = CreateFrame("Frame", nil, itemFrame, "PlumberLootUIIconTemplate");
        f.Border:SetIgnoreParentScale(true);
        f.IconOverlay:SetTexture("Interface/AddOns/Plumber/Art/LootUI/IconOverlay.png");
        itemFrame.IconFrame = f;
        return f
    end

    local function AnimItemCount_OnStop(self)
        self.DummyCount:Hide();
    end

    function CreateItemFrame()
        local f = CreateFrame("Frame", nil, MainFrame, "PlumberLootUIItemFrameTemplate");
        API.Mixin(f, ItemFrameMixin);
        CreateIconFrame(f);
        f:UpdatePixel();

        f.AnimItemCount.DummyCount = f.DummyCount;
        f.AnimItemCount:SetScript("OnStop", AnimItemCount_OnStop);
        f.AnimItemCount:SetScript("OnFinished", AnimItemCount_OnStop);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnMouseDown", f.OnMouseDown);

        f.scriptEnabled = true;
        f:EnableMouseScript(false);

        return f
    end


    function MainFrame:LayoutActiveFrames()
        local height = 0;

        for i, itemFrame in ipairs(self.activeFrames) do
            if i == 1 then
                itemFrame:SetPoint("TOPLEFT", self, "TOPLEFT", BUTTON_SPACING, -BUTTON_SPACING);
            else
                itemFrame:SetPoint("TOPLEFT", self.activeFrames[i - 1], "BOTTOMLEFT", 0, -BUTTON_SPACING);
            end
            height = height + itemFrame:GetHeight() + BUTTON_SPACING;
        end

        local frameHeight = height + BUTTON_SPACING;
        return frameHeight
    end
end


do  --UI Background
    local function OnUpdate_Background(self, elapsed)
        if self.toWidth then
            self.deltaValue = (self.toWidth - self.width) * 4 * elapsed;
            if self.deltaValue > -0.12 and self.deltaValue < 0.12 then
                if self.deltaValue < 0 then
                    self.deltaValue = -0.12;
                else
                    self.deltaValue = 0.12;
                end
            end
            self.width = self.width + self.deltaValue;
            if self.widthDelta > 0 then
                if self.width + 0.5 >= self.toWidth then
                    self.width = self.toWidth;
                    self.toWidth = nil;
                end
            else
                if self.width - 0.5 <= self.toWidth then
                    self.width = self.toWidth;
                    self.toWidth = nil;
                end
            end
        end

        if self.toHeight then
            self.deltaValue = (self.toHeight - self.height) * 4 * elapsed
            if self.deltaValue > -0.12 and self.deltaValue < 0.12 then
                if self.deltaValue < 0 then
                    self.deltaValue = -0.12;
                else
                    self.deltaValue = 0.12;
                end
            end
            self.height = self.height + self.deltaValue;
            if self.heightDelta > 0 then
                if self.height + 0.5 >= self.toHeight then
                    self.height = self.toHeight;
                    self.toHeight = nil;
                end
            else
                if self.height - 0.5 <= self.toHeight then
                    self.height = self.toHeight;
                    self.toHeight = nil;
                end
            end
        end

        if not (self.toWidth or self.toHeight) then
            self:SetScript("OnUpdate", nil);
        end

        self:SetBackgroundSize(self.width, self.height);
    end

    local BackgroundMixin = {};

    function BackgroundMixin:SetBackgroundSize(width, height)
        local lineLenth;

        lineLenth = height + self.lineShrink;
        self.LeftLine:SetSize(self.lineWeight, lineLenth);
        if lineLenth > self.maxLineSize then
            self.LeftLine:SetTexCoord(504/1024, 0.5, 0, 1);
        else
            self.LeftLine:SetTexCoord(504/1024, 0.5, 0, lineLenth/self.maxLineSize);
        end

        lineLenth = width + self.lineShrink;
        self.TopLine:SetSize(lineLenth, self.lineWeight);
        if lineLenth > self.maxLineSize then
            self.TopLine:SetTexCoord(0, 0.5, 504/512, 1);
        else
            self.TopLine:SetTexCoord(0, lineLenth/self.maxLineSize * 0.5, 504/512, 1);
        end

        local bgWidth = width + self.bgExtrude;
        local bgHeight = height + self.bgExtrude;

        local maxSize = (bgWidth > bgHeight and bgWidth) or bgHeight;

        if maxSize > self.maxBgSize then
            local bgScale = maxSize / self.maxBgSize;
            self.Background:SetTexCoord(0.5, 0.5 + 0.5*(bgWidth/bgScale/self.maxBgSize), 0, 1*(bgHeight/bgScale/self.maxBgSize));
            self.MaskRight:SetSize(self.bgMaskSize, maxSize + 2);
            self.MaskBottom:SetSize(maxSize + 2, self.bgMaskSize);
        else
            self.Background:SetTexCoord(0.5, 0.5 + 0.5*(bgWidth/self.maxBgSize), 0, 1*(bgHeight/self.maxBgSize));
            self.MaskRight:SetSize(self.bgMaskSize, self.maxBgSize + 2);
            self.MaskBottom:SetSize(self.maxBgSize + 2, self.bgMaskSize);
        end

        self.Background:SetSize(bgWidth, bgHeight);
        self.width = width;
        self.height = height;
    end

    function BackgroundMixin:SetBackgroundAlpha(alpha)
        self.Background:SetAlpha(alpha);
    end

    function BackgroundMixin:UpdatePixel()
        local scale = 1;
        local px = API.GetPixelForScale(scale, 1);

        local lineOffset = 16*px;
        local bgExtrude = 16*px;
        self.lineWeight = 8*px;
        self.lineShrink = -16*px;
        self.maxLineSize = 504*px;
        self.maxBgSize = 512*px;
        self.bgExtrude = bgExtrude;
        self.bgMaskSize = 64*px;

        self.LeftLine:ClearAllPoints();
        self.LeftLine:SetPoint("TOP", self, "TOPLEFT", 0, lineOffset);
        self.TopLine:ClearAllPoints();
        self.TopLine:SetPoint("LEFT", self, "TOPLEFT", -lineOffset, 0);

        self.LeftLineEnd:SetSize(self.lineWeight, 2*self.lineWeight);
        self.TopLineEnd:SetSize(2*self.lineWeight, self.lineWeight);

        self.Background:ClearAllPoints();
        self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", -bgExtrude, bgExtrude);

        self.MaskRight:ClearAllPoints();
        self.MaskRight:SetPoint("TOPRIGHT", self.Background, "TOPRIGHT", 0, 0);
        self.MaskBottom:ClearAllPoints();
        self.MaskBottom:SetPoint("BOTTOMLEFT", self.Background, "BOTTOMLEFT", 0, 0);
    end

    function BackgroundMixin:AnimateSize(width, height)
        if width > self.width then
            self.widthDelta = 1;
            self.toWidth = width;
        elseif width < self.width then
            self.widthDelta = -1;
            self.toWidth = width;
        end

        if height > self.height then
            self.heightDelta = 1;
            self.toHeight = height;
        elseif height < self.height then
            self.heightDelta = -1;
            self.toHeight = height;
        end

        self:SetScript("OnUpdate", OnUpdate_Background);
    end

    function MainFrame:InitBackground()
        self.InitBackground = nil;

        local f = CreateFrame("Frame", "TTBG", self, "PlumberLootUIBackgroundTemplate");
        self.BackgroundFrame = f;
        API.Mixin(f, BackgroundMixin);
        f:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);

        f:UpdatePixel();
        f:SetBackgroundSize(256, 256);
        f:SetBackgroundAlpha(0.6);

        local file = "Interface/AddOns/Plumber/Art/LootUI/LootUI.png";
        f.Background:SetTexture(file);
        f.TopLine:SetTexture(file);
        f.TopLineEnd:SetTexture(file);
        f.LeftLine:SetTexture(file);
        f.LeftLineEnd:SetTexture(file);
        f.TopLineEnd:SetTexCoord(16/1024, 0, 504/512, 1);
        f.LeftLineEnd:SetTexCoord(504/1024, 0.5, 16/512, 0);

        --[[
        local tt = self:CreateTexture(nil, "BACKGROUND");
        tt:SetAllPoints(true);
        tt:SetColorTexture(1, 0, 0, 0.5);
        --]]
    end

    function MainFrame:SetBackgroundSize(width, height)
        if self:IsShown() then
            self.BackgroundFrame:AnimateSize(width, height);
        else
            self.BackgroundFrame:SetScript("OnUpdate", nil);
            self.BackgroundFrame.toWidth = nil;
            self.BackgroundFrame.toHeight = nil;
            self.BackgroundFrame:SetBackgroundSize(width, height);
        end
    end

    function MainFrame:SetMaxPage(page)
        self.paginationPool:ReleaseAll();
        if page and page > 1 then
            local numDots = page - 1;
            local dot;
            local gap = 0;
            local offsetX = ICON_TEXT_GAP;
            local fromOffsetY = 0.5*(numDots * (DOT_SIZE + gap) - gap);
            for i = 1, numDots do
                dot = self.paginationPool:Acquire();
                dot:SetSize(DOT_SIZE, DOT_SIZE);
                dot:SetPoint("TOPRIGHT", self, "LEFT", -offsetX, fromOffsetY - (i - 1) * (DOT_SIZE + gap));
            end
        end
    end
end


do  --UI Notification Mode
    local tinsert = table.insert;
    local tremove = table.remove;

    local function OnUpdate_DisplayLootResult(self, elapsed)
        --Set to an independent frame
        self.t = self.t + elapsed;
        if self.t > 0.05 then   --3/60
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

        if self.manualMode then
            self:SetManualMode(false);
        end

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
            if data.slotType == SLOT_TYPE_MONEY then
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
        local frameHeight;

        if numFrames > 0 then
            frameHeight = self:LayoutActiveFrames();
        else
            frameHeight = 32;
        end

        local frameWidth = BUTTON_WIDTH + BUTTON_SPACING * 2;
        self:SetSize(frameWidth, frameHeight);
        self:Reposition();
        local scale = self:GetEffectiveScale();
        self:SetBackgroundSize(frameWidth * scale, (frameHeight + ICON_BUTTON_HEIGHT) * scale);

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

    local function OnUpdate_FadeOut(self, elapsed)
        self.alpha = self.alpha - 4*elapsed;
        if self.alpha <= 0 then
            self.alpha = 0;
            self:SetScript("OnUpdate", nil);
            self:Hide();
        end
        self:SetAlpha(self.alpha);
    end

    function MainFrame:TryHide()
        self.lootQueue = nil;
        self.isUpdatingPage = nil;
        self.alpha = self:GetAlpha();
        self:SetScript("OnUpdate", OnUpdate_FadeOut);
    end

    function MainFrame:Disable()
        if self.timerFrame then
            self.timerFrame:SetScript("OnUpdate", nil);
            self.timerFrame.t = nil;
        end

        self:Hide();
        self:ClearAllPoints();
    end


    function MainFrame:Reposition()
        local viewportWidth, viewportHeight = WorldFrame:GetSize();
        viewportWidth = math.min(viewportWidth, viewportHeight * 16/9);

        local scale = UIParent:GetEffectiveScale();
        self:SetScale(scale);

        local offsetX = math.floor((0.5 - 0.3333) * viewportWidth /scale);

        self:ClearAllPoints();
        self:SetPoint("TOPLEFT", nil, "CENTER", offsetX, 0);
    end

    function MainFrame:Init()
        self.Init = nil;

        Formatter:Init()

        self.itemFramePool = API.CreateObjectPool(CreateItemFrame);


        local function CreatePagniation()
            local texture = self:CreateTexture(nil, "OVERLAY");
            texture:SetTexture("Interface/AddOns/Plumber/Art/LootUI/LootUI.png");
            texture:SetTexCoord(0, 32/1024, 0, 32/512);
            return texture
        end
        self.paginationPool = API.CreateObjectPool(CreatePagniation);


        local MoneyFrame = addon.CreateMoneyDisplay(self, "GameFontNormal");
        self.MoneyFrame = MoneyFrame;
        MoneyFrame:SetHeight(TEXT_BUTTON_HEIGHT);
        MoneyFrame:Hide();
        MoneyFrame.EnableMouseScript = ItemFrameMixin.EnableMouseScript;
        MoneyFrame:SetScript("OnMouseDown", ItemFrameMixin.OnMouseDown);

        function MoneyFrame:SetData(data)
            if self:IsShown() then
                self:SetAmountByDelta(data.quantity, true);     --true: animate
            else
                self:SetAmount(data.quantity);
            end
        end

        function MoneyFrame:IsSameItem(data)
            return data.slotType == SLOT_TYPE_MONEY
        end

        self:InitBackground();

        local Header = self:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        self.Header = Header;
        Header:Hide();
        Header:SetJustifyH("CENTER");
        Header:SetPoint("BOTTOM", self, "TOPLEFT", 0.5 * BUTTON_WIDTH + BUTTON_SPACING, BUTTON_SPACING);
        Header:SetText("Loot Manually")
    end

    function MainFrame:AcquireItemFrame()
        local f = self.itemFramePool:Acquire();
        f.Text:SetWidth(NAME_WIDTH);
        return f
    end

    function MainFrame:ReleaseAll()
        if self.activeFrames then
            self.activeFrames = nil;
            self.itemFramePool:ReleaseAll();
            self.MoneyFrame:Hide();
            self.MoneyFrame:ClearAllPoints();
            self:SetMaxPage(nil);
        end
    end

    function MainFrame:OnHide()
        self:ReleaseAll();
        self:Hide();
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
        self.manualMode = state == true;
        self:ReleaseAll();
        self.Header:SetShown(state);
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
            if data.slotType == SLOT_TYPE_MONEY then
                itemFrame = self.MoneyFrame;
                local rawCopper = CoinUtil:GetCopperFromCoinText(data.name);
                itemFrame.data = data;
                itemFrame:SetAmount(rawCopper);
                itemFrame:Show();
            else
                itemFrame = self:AcquireItemFrame();
                itemFrame:SetData(data);
            end
            activeFrames[i] = itemFrame;
            itemFrame:SetAlpha(1);
            itemFrame.toAlpha = nil;
            itemFrame:EnableMouseScript(true);
        end

        local frameHeight = self:LayoutActiveFrames();

        local frameWidth = BUTTON_WIDTH + BUTTON_SPACING * 2;
        self:SetSize(frameWidth, frameHeight);
        self:Reposition();
        local scale = self:GetEffectiveScale();
        self:SetBackgroundSize(frameWidth * scale, (frameHeight + ICON_BUTTON_HEIGHT) * scale);

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
end


do
    local ENABLE_MODULE = false;

    local function EnableModule(state)
        if state then
            EL:ListenStaticEvent(true);
            EL:SetScript("OnEvent", EL.OnEvent);

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

    EnableModule(true);
end