local _, addon = ...
local API = addon.API;
local L = addon.L;
local TooltipFrame = addon.SharedTooltip;

local ENABLE_THIS_MODULE = true;        --DB.BackpackItemTracker
local HIDE_ZERO_COUNT_ITEM = true;      --DB.HideZeroCountItem      Dock items inside a flyout menu
local USE_CONSISE_TOOLTIP = true;       --DB.ConciseTokenTooltip
local TRACK_UPGRADE_CURRENCY = true;    --DB.TrackItemUpgradeCurrency
local INSIDE_SEPARATE_BAG = false;

local MAX_CUSTOM_ITEMS = 6;

local BORDER_SHRINK = 2;
local TRAY_FRAME_HEIGHT_BASE = 16;  --Single Row
local TRAY_FRAME_MIN_WIDTH = 32;
local TRAY_FRAME_MAX_WDITH = 384;
local TRAY_FRAME_WIDTH_THRESHOLD = 240;
local RECEPTOR_MIN_WIDTH = 128;

local TRAY_BUTTON_GAP = 8;
local TRAY_BUTTON_HEIGHT = 20;
local TRAY_FRAME_SIDE_PADDING = 8;

local BAG_FUNC_HOOKED = false;

local FORMAT_ITEM_UNIQUE_MULTIPLE = ITEM_UNIQUE_MULTIPLE or "Unique (%d)";
local PATTERN_UNIQUE_COUNT = string.gsub(FORMAT_ITEM_UNIQUE_MULTIPLE, "[()]", "%%%1");
PATTERN_UNIQUE_COUNT = string.gsub(PATTERN_UNIQUE_COUNT, "%%d", "(%%d+)");

local GetColorizedItemName = API.GetColorizedItemName;

local CursorHasItem = CursorHasItem;
local ClearCursor = ClearCursor;
local GetCursorInfo = GetCursorInfo;
local GetItemCount = GetItemCount;
--local GetItemUniquenessByID = C_Item.GetItemUniquenessByID;     --Only returns True for equipment, not items with Unique (10)
local GetItemIconByID = C_Item.GetItemIconByID;
local GetItemMaxStackSizeByID = C_Item.GetItemMaxStackSizeByID;
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
local GetItemTooltipInfo = C_TooltipInfo.GetItemByID;
local type = type;
local tonumber = tonumber;

local ExcludeFromSave = {};
local CurrentPinnedItems = {};
local HolidayItems = {
    --Holidays:
    lunarfestival = 21100,      --Coin of Ancestry
    loveintheair = 49927,       --Love Token
    noblegarden = 44791,        --Noblegarden Chocolate
    --childrensweek
    midsummer = 23247,          --Burning Blossom
    brewfest = 37829,           --Brewfest Prize Token
    hallowsendend = 33226,      --Tricky Treat
    --winterveil
};

local CrestCurrenies = {
    --Universal Upgrade System (Crests)
    --convert to string for hybrid process
    --CategoryID ~= 142

    --S4 Awakened
    2812,   --Aspect    (M, M6+)
    2809,   --Wyrm      (H, M5)
    2807,   --Drake     (N, M0)
    2806,   --Whelpling (LFR, H)
};

addon.CrestCurrenies = CrestCurrenies;

local EL = CreateFrame("Frame");
EL:RegisterEvent("PLAYER_ENTERING_WORLD");

local UseSpecialTooltip = {};   --item/currency that use a custom tooltip
local InitializeModule;         --will be defined later

local CrestUtil = {};
CrestUtil.watchedCurrrencies = {};

function CrestUtil:GetBestCrestName(colorized)
    local numTiers = #CrestCurrenies;
    local info, currencyID;
    local name;

    for tier = 1, numTiers do
        currencyID = CrestCurrenies[tier];
        info = GetCurrencyInfo(currencyID);
        if info and info.discovered then
            name = info.name;
            if colorized then
                name = API.ColorizeTextByQuality(name, info.quality);
            end
            return name
        end
    end

    name = NONE or "None";
    if colorized then
        name = "|cffffffff"..name.."|r"
    end
    return name
end

function CrestUtil:GetBestCrestForPlayer()
    --return the highest tier
    if not TRACK_UPGRADE_CURRENCY then
        EL:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
        return
    end

    local numTiers = #CrestCurrenies;
    local bestTier = 0;
    local info, currencyID, bestCurrencyID;

    for tier = 1, numTiers do
        currencyID = CrestCurrenies[tier];
        info = GetCurrencyInfo(currencyID);
        if info and info.discovered then
            bestTier = numTiers - tier + 1;
            bestCurrencyID = currencyID;
            break
        end
    end

    self.watchedCurrrencies = {};
    if bestTier < numTiers then
        --if there is an undiscovered tier above the player's best tier, listen to Events for update
        local temp = "";
        for tier = bestTier + 1, numTiers do
            currencyID = CrestCurrenies[tier];
            temp = temp .. " "..currencyID;
            self.watchedCurrrencies[currencyID] = true;
        end
        EL:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
    else
        EL:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
    end

    return bestCurrencyID
end


do
    for _, id in pairs(HolidayItems) do
        ExcludeFromSave[id] = true;
    end

    for _, id in pairs(CrestCurrenies) do
        ExcludeFromSave[ tostring(id) ] = true;
        UseSpecialTooltip[id] = true;
    end
end


local TrackerFrame = CreateFrame("Frame", nil, UIParent);
TrackerFrame.list = {};
TrackerFrame.numCustomItems = 0;
TrackerFrame.isBlizzardBag = true;
TrackerFrame:EnableMouse(true);
TrackerFrame:SetFrameStrata("HIGH");
TrackerFrame:SetFixedFrameStrata(true);
TrackerFrame:Hide();

local SettingsFrame = {};    --frame created on-use

local ItemDataProvider = {};
ItemDataProvider.counts = {};
ItemDataProvider.maxQuantities = {};
ItemDataProvider.bondingTexts = {};
ItemDataProvider.expirationTexts = {};

function ItemDataProvider:GetItemCount(itemID, overwrite)
    if (not self.counts[itemID]) or overwrite then
        self.counts[itemID] = GetItemCount(itemID, true);   --includeBank
    end

    return self.counts[itemID]
end

function ItemDataProvider:HasZeroCountItem()
    return self.hasZero
end

function ItemDataProvider:GetZeroCountItem()
    return self.zeroCountItems
end

function ItemDataProvider:GetOwnedItem()
    return self.ownedItems
end

function ItemDataProvider:UpdateItemCount()
    local count;
    self.zeroCountItems = {};
    self.ownedItems = {};

    local totalZero = 0;
    local totalOwned = 0;

    for _, itemID in ipairs(TrackerFrame.list) do
        count = self:GetItemCount(itemID, true);
        if count == 0 and not ExcludeFromSave[itemID] then
            totalZero = totalZero + 1;
            self.zeroCountItems[totalZero] = itemID;
        else
            totalOwned = totalOwned + 1;
            self.ownedItems[totalOwned] = itemID;
        end
    end

    self.hasZero = totalZero > 0;
end

function ItemDataProvider:CacheItemInfo(id)
    if self.maxQuantities[id] then return end;

    if type(id) == "number" then
        local data = GetItemTooltipInfo(id);
        local maxQuantity;
        if data and data.lines then
            for i, line in ipairs(data.lines) do
                if line.bonding then   --Bonding: 5(BLZ), 6(on-pick-up)
                    if line.bonding == 6 then
                        self.bondingTexts[id] = ITEM_SOULBOUND or "Soulbound";
                    else
                        if line.bonding == 5 then
                            self.bondingTexts[id] = "|cff82c5ff".. (ITEM_BNETACCOUNTBOUND or "Blizzard Account Bound") .."|r";  --BATTLENET_FONT_COLOR
                        else
                            self.bondingTexts[id] = line.leftText;
                        end
                    end
                elseif not maxQuantity then
                    maxQuantity = string.match(line.leftText, PATTERN_UNIQUE_COUNT);
                    if maxQuantity then
                        self.maxQuantities[id] = tonumber(maxQuantity);
                    end
                end
            end

            if not maxQuantity then
                self.maxQuantities[id] = 0;
            end
        end
    else
        local currencyID = tonumber(id);
    end
end

function ItemDataProvider:RequestAllItemData()
    local list = TrackerFrame:CopyUserTrackList();

    for i, id in ipairs(list) do
        if type(id) == "number" then
            GetItemTooltipInfo(id);
        end
    end
end

function ItemDataProvider:CacheAllItems()
    for i, id in ipairs(TrackerFrame.list) do
        self:CacheItemInfo(id);
    end
end

function ItemDataProvider:GetMaxQuantity(itemID)
    self:CacheItemInfo(itemID);
    return self.maxQuantities[itemID] or 0
end

function ItemDataProvider:GetBondingText(itemID)
    self:CacheItemInfo(itemID);
    return self.bondingTexts[itemID]
end

function ItemDataProvider:GetExpirationText(itemID)
    if self.expirationTexts[itemID] then
        local info = self.expirationTexts[itemID];
        if type(info == "function") then
            return info(info)
        else
            return info
        end
    end
end

function ItemDataProvider:SetExpirationText(itemID, stringOrFunc)
    self.expirationTexts[itemID] = stringOrFunc;
end

local function ShowButtonTooltip(owner, itemID, currencyID)
    GameTooltip:Hide();

    if currencyID then
        local tooltip = TooltipFrame;
        if UseSpecialTooltip[currencyID] then
            tooltip:SetOwner(owner, "ANCHOR_RIGHT");
            TooltipFrame:DisplayUpgradeCurrencies();
        else
            tooltip:SetOwner(owner, "ANCHOR_RIGHT");
            tooltip:SetCurrencyByID(currencyID);
            tooltip:Show();
        end
        return
    end


    if USE_CONSISE_TOOLTIP then
        local tooltip = TooltipFrame;
        tooltip:SetOwner(owner, "ANCHOR_RIGHT");

        local itemName = GetColorizedItemName(itemID);
        if itemName then
            tooltip:AddLeftLine(itemName, 1, 1, 1, true, nil, 1);
            local bonding = ItemDataProvider:GetBondingText(itemID);
            if bonding then
                tooltip:AddLeftLine(bonding, 1, 1, 1, true);
            end

            local maxQuantity = ItemDataProvider:GetMaxQuantity(itemID);
            if maxQuantity > 0 then
                tooltip:AddLeftLine(string.format(FORMAT_ITEM_UNIQUE_MULTIPLE, maxQuantity), 1, 1, 1, true);
            end

            local expirationText = ItemDataProvider:GetExpirationText(itemID);
            if expirationText then
                tooltip:AddLeftLine(expirationText, 1, 0.5, 0.25, true);
            end

            local numInBags = GetItemCount(itemID);
            local numTotal = GetItemCount(itemID, true);
            if numInBags ~= numTotal then
                local numInBanks = numTotal - numInBags;
                tooltip:AddLeftLine(BANK, 1, 0.82, 0);
                tooltip:AddRightLine(numInBanks, 1, 1, 1);
            end

            tooltip:Show();
        else
            tooltip:Hide();
        end
        return
    else
        local tooltip = GameTooltip;
        tooltip:SetOwner(owner, "ANCHOR_RIGHT");
        tooltip:SetItemByID(itemID);
        tooltip:Show();
        return
    end
end


local DragUtil = CreateFrame("Frame");
DragUtil.GetCursorPositon = GetCursorPosition;

--[[
function DragUtil.OnUpdate_WatchDragging(self, elapsed)
    --Watch X Offset
    self.t = self.t + elapsed;
    if self.t > 0.016 then
        self.t = 0;
        self.x, self.y = self.GetCursorPositon();
        self.deltaX = self.x - self.fromX;
        if self.deltaX > 4 or self.deltaX < -4 then
            self:SetScript("OnUpdate", nil);
            self:StartDragging();
        end
    end
end
--]]

function DragUtil.OnUpdate_WatchDragging(self, elapsed)
    --Watch Y Offset
    self.t = self.t + elapsed;
    if self.t > 0.016 then
        self.t = 0;
        self.x, self.y = self.GetCursorPositon();
        self.deltaY = self.y - self.fromY;
        if self.deltaY > 4 or self.deltaY < -4 then
            self:SetScript("OnUpdate", nil);
            self:StartDragging();
        end
    end
end

function DragUtil:StartMouseDown(tokenButton)
    self.object = tokenButton;
    self.t = 0;
    self.fromX, self.fromY = self.GetCursorPositon();
    self:SetScript("OnUpdate", self.OnUpdate_WatchDragging);
end

function DragUtil.OnUpdate_OnDragging(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.1 then
        self.t = 0;
        self.x, self.y = self.GetCursorPositon();
        self.x = self.x * self.scaleReciprocal;
        self.y = self.y * self.scaleReciprocal;

        local newIndex;  --move to the left of button #index

        for i = 1, self.numPos do
            if self.y > self.positions[i] then
                newIndex = i;
                break
            end
        end

        if not newIndex then
            newIndex = self.numPos + 1; --to the bottom
        end

        SettingsFrame:SetButtonNewPosition(newIndex);
    end
end

--[[
function DragUtil:StartDragging()
    --Horizontal
    TrackerFrame:StartArranging(self.object);

    --Get position table
    self.positions = {};
    self.numPos = #TrackerFrame.list;
    self.scaleReciprocal = 1 / UIParent:GetEffectiveScale();

    self.fromX, self.fromY = self.GetCursorPositon();
    self.fromX = self.fromX*self.scaleReciprocal;
    self.fromY = self.fromY*self.scaleReciprocal;

    local bagScale = TrackerFrame:GetEffectiveScale();
    local x;

    for i = 1, self.numPos do
        x = TrackerFrame.TrayButtons[i]:GetCenter();
        self.positions[i] = x * self.scaleReciprocal * bagScale;    --When UI Scale is too large, the game may reduce the ContainerFrame's scale, so we need to compensate that
    end

    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate_OnDragging);
end
--]]

function DragUtil:StartDragging()
    SettingsFrame:StartArranging(self.object);

    --Get position table
    self.positions = {};
    self.numPos = #SettingsFrame.customList;
    self.scaleReciprocal = 1 / UIParent:GetEffectiveScale();

    self.fromX, self.fromY = self.GetCursorPositon();
    self.fromX = self.fromX*self.scaleReciprocal;
    self.fromY = self.fromY*self.scaleReciprocal;

    local bagScale = TrackerFrame:GetEffectiveScale();
    local x, y;

    for i = 1, self.numPos do
        x, y = SettingsFrame.ListButtons[i]:GetCenter();
        self.positions[i] = y * self.scaleReciprocal * bagScale;
    end

    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate_OnDragging);
end

function DragUtil:Stop()
    self:SetScript("OnUpdate", nil);
end

function DragUtil:StopArranging()
    self:SetScript("OnUpdate", nil);
    --TrackerFrame:StopArranging();
    SettingsFrame:StopArranging();
end


local function UpdateFrameSize_Modified(self, extraHeight)
    local height = self:CalculateHeight();
    self:SetHeight(height + extraHeight);
end

local function UpdateFrameSize_Callback(self)
    if not TrackerFrame:IsPlacedInsideBag() then
        return
    end
    local extraHeight = TrackerFrame:CalculateHeight();
    UpdateFrameSize_Modified(self, extraHeight);
end

local function UpdateCurrencyFrames_Modified(self, extraHeight)
    local tokenFrame = BackpackTokenFrame;

    if tokenFrame and tokenFrame:IsShown() then
        tokenFrame:ClearAllPoints();
        tokenFrame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 8, 8 + extraHeight);
        tokenFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 8 + extraHeight);
    else
        self.MoneyFrame:ClearAllPoints();
        self.MoneyFrame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 8, 8 + extraHeight);
        self.MoneyFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 8 + extraHeight);
    end
end

local function UpdateCurrencyFrames_Callback(self)
    if not TrackerFrame:IsPlacedInsideBag() then
        return
    end
    local extraHeight = TrackerFrame:CalculateHeight();
    UpdateCurrencyFrames_Modified(self, extraHeight);
end

local function UpdateContainerLayout()
    UpdateFrameSize_Callback(ContainerFrame1);
    UpdateCurrencyFrames_Callback(ContainerFrame1);
    UpdateContainerFrameAnchors()
end

function SettingsFrame.OnChanged(manual)
    local db = PlumberDB;
    if not db then return end;

    HIDE_ZERO_COUNT_ITEM = db.HideZeroCountItem;
    USE_CONSISE_TOOLTIP = db.ConciseTokenTooltip;
    TRACK_UPGRADE_CURRENCY = db.TrackItemUpgradeCurrency;

    local insideSeparateBag = db.TrackerBarInsideSeparateBag;

    if insideSeparateBag then
        if not BAG_FUNC_HOOKED then
            local f = ContainerFrame1;

            if f.UpdateFrameSize then
                hooksecurefunc(f, "UpdateFrameSize", UpdateFrameSize_Callback);
            end

            if f.UpdateCurrencyFrames then
                hooksecurefunc(f, "UpdateCurrencyFrames", UpdateCurrencyFrames_Callback);
            end
        end
    elseif INSIDE_SEPARATE_BAG then
        UpdateFrameSize_Modified(ContainerFrame1, 0);
        UpdateCurrencyFrames_Modified(ContainerFrame1, 0);
        UpdateContainerFrameAnchors()
    end

    INSIDE_SEPARATE_BAG = insideSeparateBag;

    TrackerFrame:RequestUpdate(manual);
end

local function OptionButton_TrackItemUpgradeCurrency_OnClick()
    local db = PlumberDB;
    if not db then return end;

    TRACK_UPGRADE_CURRENCY = db.TrackItemUpgradeCurrency;
    InitializeModule();
end

local function OptionButton_TrackItemUpgradeCurrency_OnEnter(self)
    local tooltip = GameTooltip;
    tooltip:Hide();
    tooltip:SetOwner(self, "ANCHOR_RIGHT");
    tooltip:SetText(L["Track Upgrade Currency"], 1, 1, 1, true);
    tooltip:AddLine(L["Track Upgrade Currency Tooltip"], 1, 0.82, 0, true);

    local currencyName = CrestUtil:GetBestCrestName(true);
    tooltip:AddLine(" ");
    tooltip:AddLine(L["Currently Pinned Colon"].."\n"..currencyName, 1, 0.82, 0, true);
    tooltip:Show();
end

local function OptionButton_InsideBag_OnClick()

end

function SettingsFrame:Init()
    if self.frame then return end;

    local showCloseButton = true;
    local f = addon.CreateHeaderFrame(UIParent, showCloseButton);
    self.frame = f;

    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    f:SetSize(225, 300);
    f:SetTitle(L["ModuleName BackpackItemTracker"]);
    f:Hide();

    f:SetScript("OnHide", function()
        f:Hide();
        DragUtil:Stop();
        self:StopArranging();
    end);

    function SettingsFrame:CloseUI()
        f:Hide();
        PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
    end
    f.CloseUI = SettingsFrame.CloseUI;

    local PADDING = 12;
    local HEADER_HEIGHT = 18;
    local FRAME_MIN_WIDTH = 208;

    local baseFrameLevel = f:GetFrameLevel();

    --Checkboxs
    local options = {
        {dbKey = "HideZeroCountItem", label = L["Hide Not Owned Items"], tooltip = L["Hide Not Owned Items Tooltip"], onClickFunc = SettingsFrame.OnChanged},
        {dbKey = "ConciseTokenTooltip", label = L["Concise Tooltip"], tooltip = L["Concise Tooltip Tooltip"], onClickFunc = SettingsFrame.OnChanged},
        {dbKey = "TrackItemUpgradeCurrency", label = L["Track Upgrade Currency"], onClickFunc = OptionButton_TrackItemUpgradeCurrency_OnClick, onEnterFunc = OptionButton_TrackItemUpgradeCurrency_OnEnter},
    };

    if TrackerFrame.isBlizzardBag and (not C_CVar.GetCVarBool("combinedBags")) then
        table.insert(options, {
            dbKey = "TrackerBarInsideSeparateBag", label = L["Bar Inside The Bag"], tooltip = L["Bar Inside The Bag Tooltip"], onClickFunc = SettingsFrame.OnChanged,
        });
    end

    local BUTTON_HEIGHT = 24;
    local OPTION_GAP_Y = 8;
    local checkbox, checkboxWidth;
    local fullHeight = HEADER_HEIGHT + PADDING;
    local maxButtonWidth = 0;

    for i, data in ipairs(options) do
        checkbox = addon.CreateCheckbox(f);
        checkbox:SetPoint("TOPLEFT", f, "TOPLEFT", PADDING, -fullHeight);
        fullHeight = fullHeight + OPTION_GAP_Y + BUTTON_HEIGHT;
        checkboxWidth = checkbox:SetData(data);
        if checkboxWidth > maxButtonWidth then
            maxButtonWidth = checkboxWidth;
        end

        if data.dbKey and PlumberDB[data.dbKey] then
            checkbox:SetChecked(PlumberDB[data.dbKey]);
        end
    end

    local contentSpan = math.floor( math.max(checkboxWidth, FRAME_MIN_WIDTH - 2*PADDING) + 0.5);
    local frameWidth = contentSpan + 2*PADDING;

    --List of tracked items
    local ICON_SIZE = 12;
    local LIST_BUTTON_HEIGHT = 20;

    local listHeight = LIST_BUTTON_HEIGHT * MAX_CUSTOM_ITEMS;

    self.ListButtons = {};

    local AlertText = f:CreateFontString(nil, "OVERLAY", "GameTooltipTextSmall");
    self.AlertText = AlertText;
    AlertText:Hide();
    AlertText:SetWidth(contentSpan);
    AlertText:SetPoint("CENTER", f, "TOP", 0, -fullHeight -0.5*listHeight);
    AlertText:SetText(L["Tracking List Empty"]);
    AlertText:SetTextColor(0.5, 0.5, 0.5);
    AlertText:SetShadowOffset(1, -1);
    AlertText:SetJustifyH("CENTER");
    AlertText:SetJustifyV("MIDDLE");

    local SelectionTexture = f:CreateTexture(nil, "OVERLAY");
    SelectionTexture:SetSize(frameWidth - 4, LIST_BUTTON_HEIGHT);
    SelectionTexture:SetColorTexture(0.16, 0.16, 0.16);
    SelectionTexture:Hide();

    local function SelectionTexture_SetColorMode(mode)
        if mode == 1 then   --Normal Highlight
            SelectionTexture:SetColorTexture(0.16, 0.16, 0.16);
        elseif mode == 2 then   --OnDrag Highlight
            SelectionTexture:SetColorTexture(0.25, 0.25, 0.25);
        elseif mode == 3 then   --To-be-Deleted
            SelectionTexture:SetColorTexture(0.27, 0.1, 0.1);
        end
    end

    local ActionBlocker = CreateFrame("Frame", nil, f);
    ActionBlocker:SetFrameLevel(baseFrameLevel + 30);
    ActionBlocker:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -HEADER_HEIGHT);
    ActionBlocker:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);
    ActionBlocker:EnableMouse(true);
    ActionBlocker:Hide();

    local function ShowActionBlocker()
        ActionBlocker:Show();
        C_Timer.After(0.5, function()
            ActionBlocker:Hide();
        end);
    end

    local DeleteButton = CreateFrame("Button", nil, f);
    DeleteButton:Hide();
    DeleteButton:SetSize(24, LIST_BUTTON_HEIGHT);
    DeleteButton:SetFrameLevel(baseFrameLevel + 20);
    DeleteButton.RedCross = DeleteButton:CreateTexture(nil, "OVERLAY");
    DeleteButton.RedCross:SetSize(16, 16);
    DeleteButton.RedCross:SetPoint("CENTER", DeleteButton, "RIGHT", -10, 0);
    DeleteButton.RedCross:SetTexture("Interface/AddOns/Plumber/Art/BackpackItemTracker/RedCross");

    local function DeleteButton_SetOwner(listButton)
        DeleteButton:ClearAllPoints();
        DeleteButton:SetPoint("RIGHT", listButton, "RIGHT", 0, 0);
        DeleteButton:Show();
        DeleteButton.owner = listButton;
    end

    function SettingsFrame:HighlightListButton(b)
        if b then
            SelectionTexture:ClearAllPoints();
            SelectionTexture:SetPoint("CENTER", b, "CENTER", 0, 0);
            SelectionTexture:Show();
        else
            SelectionTexture:Hide();
        end

        for i, button in ipairs(self.ListButtons) do
            if button == b then
                button:SetAlpha(1);
            else
                button:SetAlpha(0.8);
            end
        end
    end

    local function TokenListButton_OnEnter(b)
        if not self.isArranging then
            SelectionTexture_SetColorMode(1);
            self:HighlightListButton(b);
            DeleteButton_SetOwner(b);
        end
    end

    local function TokenListButton_OnLeave(b)
        if not self.isArranging then
            self:HighlightListButton();
            if not b:IsMouseOver() then
                DeleteButton:Hide();
            end
        end
    end

    local function TokenListButton_OnMouseDown(b, button)
        if button == "LeftButton" then
            DragUtil:StartMouseDown(b);
        end
    end

    local function TokenListButton_OnMouseUp(b, button)
        if button == "LeftButton" then
            DragUtil:StopArranging();
        end
    end

    local function DeleteButton_OnEnter(b)
        DeleteButton.RedCross:SetVertexColor(1, 1, 1);
        if b.owner then
            TokenListButton_OnEnter(b.owner);
            SelectionTexture_SetColorMode(3);
        end
    end

    local function DeleteButton_OnLeave(b)
        DeleteButton.RedCross:SetVertexColor(0.5, 0.5, 0.5);
        if b.owner then
            TokenListButton_OnLeave(b.owner);
        end
    end

    local function DeleteButton_OnClick(b)
        if b.owner then
            self:DeleteItemByIndex(b.owner.index);
            b:Hide();
            ShowActionBlocker();
            PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
        end
    end

    DeleteButton:SetScript("OnEnter", DeleteButton_OnEnter);
    DeleteButton:SetScript("OnLeave", DeleteButton_OnLeave);
    DeleteButton:SetScript("OnClick", DeleteButton_OnClick);
    DeleteButton_OnLeave(DeleteButton);

    local function CreateTokenListButton()
        local b = CreateFrame("Frame", nil, f);
        b:SetSize(contentSpan, LIST_BUTTON_HEIGHT);

        b.Icon = b:CreateTexture(nil, "ARTWORK");
        b.Icon:SetSize(ICON_SIZE, ICON_SIZE);
        b.Icon:SetPoint("LEFT", b, "LEFT", 0, 0);
        b.Icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375);

        b.Name = b:CreateFontString(nil, "ARTWORK", "GameTooltipTextSmall");
        b.Name:SetJustifyH("LEFT");
        b.Name:SetSize(128, 12);
        b.Name:SetPoint("LEFT", b, "LEFT", ICON_SIZE + 4, 0);
        b.Name:SetMaxLines(1);
        b.Name:SetShadowOffset(1, -1);

        b:SetScript("OnEnter", TokenListButton_OnEnter);
        b:SetScript("OnLeave", TokenListButton_OnLeave);
        b:SetScript("OnMouseDown", TokenListButton_OnMouseDown);
        b:SetScript("OnMouseUp", TokenListButton_OnMouseUp);
        b:SetAlpha(0.8);

        return b
    end

    for i = 1, MAX_CUSTOM_ITEMS do
        self.ListButtons[i] = CreateTokenListButton();
        self.ListButtons[i]:SetPoint("TOPLEFT", f, "TOPLEFT", PADDING, -fullHeight);
        self.ListButtons[i].index = i;

        fullHeight = fullHeight + LIST_BUTTON_HEIGHT;
    end

    f:SetSize(frameWidth, fullHeight + PADDING);
    f:ClearAllPoints();
    f:SetParent(TrackerFrame);
    f:SetPoint("BOTTOMLEFT", TrackerFrame, "TOPLEFT", 0, 4);

    f:SetClampedToScreen(true);
    f:SetFrameStrata("DIALOG");
    f:SetFixedFrameStrata(true);


    function SettingsFrame:StartArranging(listButton)
        self.isArranging = true;
        self.newPositionIndex = nil;
        self.movedButtonIndex = listButton.index;
        self:ShowDragLine(true, listButton);
        self:HighlightListButton(listButton);
        SelectionTexture_SetColorMode(2);
        DeleteButton:Hide();
    end

    function SettingsFrame:ShowDragLine(state, button, alignToBottom)
        if state then
            if not self.DragLine then
                self.DragLine = addon.CreateThreeSliceFrame(f);
                self.DragLine.pieces[1]:SetSize(8, 8);
                self.DragLine.pieces[3]:SetSize(8, 8);
                self.DragLine:SetTexture("Interface/AddOns/Plumber/Art/BackpackItemTracker/DragLine_Horizontal");
                self.DragLine:SetSize(contentSpan + 8, 8);
                self.DragLine:Hide();
            end
            self.DragLine:ClearAllPoints();

            if alignToBottom then
                self.DragLine:SetPoint("CENTER", button, "BOTTOM", 0, 0);
            else
                self.DragLine:SetPoint("CENTER", button, "TOP", 0, 0);
            end
            
            self.DragLine:Show();
        else
            self:StopArranging();
        end
    end

    function SettingsFrame:StopArranging()
        self.isArranging = nil;

        if self.DragLine then
            self.DragLine:Hide();
        end

        self:HighlightListButton();

        if f:IsShown() then
            self:ConfirmNewArrangement();
            for _, b in pairs(self.ListButtons) do
                if b:IsMouseOver() and b:IsShown() then
                    TokenListButton_OnEnter(b);
                    break
                end
            end
        end

        self.newPositionIndex = nil;
    end

    function SettingsFrame:SetButtonNewPosition(buttonIndex)
        if buttonIndex ~= self.newPositionIndex then
            self.newPositionIndex = buttonIndex;
            if self.ListButtons[buttonIndex] then
                self:ShowDragLine(true, self.ListButtons[buttonIndex]);
            else
                self:ShowDragLine(true, self.ListButtons[ self.numActiveButton ], true);
            end
        end
    end

    function SettingsFrame:ConfirmNewArrangement()
        local targetIndex = self.newPositionIndex;
        local fromIndex = self.movedButtonIndex;
        if (targetIndex and fromIndex) and (targetIndex ~= fromIndex) and (targetIndex ~= fromIndex + 1) then
            local list = self.customList;
            local itemID = table.remove(list, fromIndex);

            if targetIndex > fromIndex then
                table.insert(list, targetIndex - 1, itemID);
            else
                table.insert(list, targetIndex, itemID);
            end

            TrackerFrame.list = self.customList;
            TrackerFrame:SaveUserTrackList();
            TrackerFrame:BuildTrackList();
            TrackerFrame:UpdateTray(true);
            self:UpdateListFrame();
        end
    end

    function SettingsFrame:DeleteItemByIndex(listButtonIndex)
        local list = self.customList;
        local itemID = table.remove(list, listButtonIndex);
        TrackerFrame.list = self.customList;
        TrackerFrame:SaveUserTrackList();
        TrackerFrame:BuildTrackList();
        TrackerFrame:UpdateTray(true);
        self:UpdateListFrame();
    end
end

function SettingsFrame:UpdateListFrame()
    if not self.ListButtons then return end;

    --Doesn't include items tracked by default
    self.customList = TrackerFrame:CopyUserTrackList();
    local itemID;
    local numActiveButton = 0;

    for i = 1, MAX_CUSTOM_ITEMS do
        itemID = self.customList[i];
        if itemID then
            numActiveButton = numActiveButton + 1;
            if itemID ~= self.ListButtons[i].itemID then
                self.ListButtons[i].Icon:SetTexture(GetItemIconByID(itemID));
                self.ListButtons[i].Name:SetText(GetColorizedItemName(itemID));
                self.ListButtons[i]:Show();
            end
        else
            self.ListButtons[i]:Hide();
        end
        self.ListButtons[i].itemID = itemID;
    end

    self.numActiveButton = numActiveButton;
    self.AlertText:SetShown(numActiveButton == 0);
end

function SettingsFrame:ShowUI()
    self:Init();
    if not self.frame:IsShown() then
        self.frame:Show();
        self:UpdateListFrame();
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    end
end

function SettingsFrame:ToggleUI()
    if (not self.frame) or (not self.frame:IsShown()) then
        self:ShowUI();
    else
        self:CloseUI();
    end
end

do
    --Tray Button: [itemCount][itemIcon]
    TrackerFrame.TrayButtons = {};

    local ICON_SIZE = 12;
    local TEXT_ICON_GAP = 2;

    local TrayButtonMixin = {};

    function TrayButtonMixin:OnLoad()
        self.Icon = self:CreateTexture(nil, "ARTWORK");
        self.Icon:SetSize(ICON_SIZE, ICON_SIZE);
        self.Icon:SetPoint("RIGHT", self, "RIGHT", 0, 0);
        self.Icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375);

        self.Count = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
        self.Count:SetJustifyH("RIGHT");
        self.Count:SetPoint("RIGHT", self.Icon, "LEFT", -TEXT_ICON_GAP, 0);

        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnClick", self.OnClick);
        self:SetScript("OnDragStart", self.OnDragStart);

        self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
        self:RegisterForDrag("LeftButton");
        self:SetSize(TRAY_BUTTON_HEIGHT, TRAY_BUTTON_HEIGHT);
    end

    function TrayButtonMixin:OnEnter()
        if TrackerFrame.isArranging then return end;
        ShowButtonTooltip(self, self.itemID, self.currencyID);
        --TrackerFrame:HighlightTrayButton(self);
    end

    function TrayButtonMixin:OnLeave()
        GameTooltip:Hide();
        TooltipFrame:Hide();
        if TrackerFrame.isArranging then return end;
        --TrackerFrame:HighlightTrayButton();
    end

    function TrayButtonMixin:OnClick(button)
        if button == "LeftButton" then
            if IsShiftKeyDown() then
                TrackerFrame:SearchItemByID(self.itemID);
            else

            end
        elseif button == "RightButton" then
            SettingsFrame:ToggleUI();
            GameTooltip:Hide();
        end
    end

    function TrayButtonMixin:OnDragStart(button)
        SettingsFrame:ShowUI();
    end

    function TrayButtonMixin:UpdateAndRetureWidth()
        local width = math.floor(self.Count:GetWrappedWidth() + TEXT_ICON_GAP + ICON_SIZE + 0.5);
        self:SetWidth(width);
        self.width = width;
        return width
    end

    function TrayButtonMixin:SetItem(itemID)
        local anyChange;

        if itemID ~= self.itemID then
            anyChange = true;
            self.itemID = itemID;
            self.Icon:SetTexture( GetItemIconByID(itemID) );
        end
        self.currencyID = nil;

        local count = ItemDataProvider:GetItemCount(itemID);
        if count ~= self.lastCount then
            self.lastCount = count;
            anyChange = true;
            self.Count:SetText(count);

            if count > 0 then
                local maxQuantity = ItemDataProvider:GetMaxQuantity(itemID);
                if maxQuantity > 0 and count >= maxQuantity then
                    self.Count:SetTextColor(1.000, 0.282, 0.000);   --WARNING_FONT_COLOR
                else
                    self.Count:SetTextColor(1, 1, 1);
                end
            else
                self.Count:SetTextColor(0.5, 0.5, 0.5);
            end

        end

        if anyChange then
            return self:UpdateAndRetureWidth();
        else
            return self.width
        end
    end

    function TrayButtonMixin:SetCurrency(currencyID)
        local anyChange;

        if currencyID ~= self.currencyID then
            anyChange = true;
            self.currencyID = currencyID;
        end
        self.itemID = nil;

        local info = currencyID and GetCurrencyInfo(currencyID);

        if not info then
            self.Count:SetText("??");
            self.Icon:SetTexture(134400);
            return self:UpdateAndRetureWidth();
        end

        local count = info.quantity or 0;

        self.Icon:SetTexture(info.iconFileID);
        if count ~= self.lastCount then
            self.lastCount = count;
            anyChange = true;
            self.Count:SetText(count);

            if count > 0 then
                local maxQuantity = info.maxQuantity;
                if maxQuantity > 0 and count >= maxQuantity then
                    self.Count:SetTextColor(0.251, 0.753, 0.251);   --DIM_GREEN_FONT_COLOR
                else
                    self.Count:SetTextColor(1, 1, 1);
                end
            else
                self.Count:SetTextColor(0.5, 0.5, 0.5);
            end
        end

        if anyChange then
            return self:UpdateAndRetureWidth();
        else
            return self.width
        end
    end

    function TrayButtonMixin:SetToken(id)
        if type(id) == "number" then
            return self:SetItem(id);
        else
            return self:SetCurrency( tonumber(id) );
        end
    end

    function TrackerFrame:AcquireTrayButton(i)
        if not self.TrayButtons[i] then
            local b = CreateFrame("Button", nil, self);
            b.index = i;
            API.Mixin(b, TrayButtonMixin);
            b:SetFrameLevel(self:GetFrameLevel() + 1);
            b:Hide();
            b:OnLoad();
            b:ClearAllPoints();
            if i == 1 then
                b:SetPoint("LEFT", self, "LEFT", TRAY_FRAME_SIDE_PADDING, 0);
            else
                b:SetPoint("LEFT", self.TrayButtons[i - 1], "RIGHT", TRAY_BUTTON_GAP, 0);
            end
            self.TrayButtons[i] = b;
        end
        return self.TrayButtons[i];
    end

    function TrackerFrame:HighlightTrayButton(button)
        if button then
            if not self.ButtonHighlight then
                self.ButtonHighlight = self:CreateTexture(nil, "OVERLAY", nil, -1);
                self.ButtonHighlight:SetColorTexture(0.35, 0.35, 0.35);
            end
            self.ButtonHighlight:ClearAllPoints();
            self.ButtonHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", -4, -3);
            self.ButtonHighlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, 3);
            self.ButtonHighlight:Show();

        elseif self.ButtonHighlight then
            self.ButtonHighlight:Hide();
        end
    end

    function TrackerFrame:ShowDragLine(state, button, alignToRight)
        if state then
            if not self.DragLine then
                self.DragLine = self:CreateTexture(nil, "OVERLAY", nil, 5);
                self.DragLine:SetSize(8, 32);
                self.DragLine:SetTexture("Interface/AddOns/Plumber/Art/BackpackItemTracker/DragLine_Vertical");
                API.DisableSharpening(self.DragLine);
            end
            self.DragLine:ClearAllPoints();

            if alignToRight then
                self.DragLine:SetPoint("CENTER", button, "RIGHT", 4, 0);
            else
                self.DragLine:SetPoint("CENTER", button, "LEFT", -4, 0);
            end

            self.DragLine:Show();
        else
            self:StopArranging();
        end
    end

    function TrackerFrame:StartArranging(button)
        self.isArranging = true;
        self.newPositionIndex = nil;
        self.movedButtonIndex = button.index;
        self:ShowDragLine(true, button);
        self:HighlightTrayButton(button);
    end

    function TrackerFrame:StopArranging()
        self.isArranging = nil;
        self:HighlightTrayButton();
        if self.DragLine then
            self.DragLine:Hide();
        end

        self:ConfirmNewArrangement();
        self.newPositionIndex = nil;

        if self:IsShown() then
            for _, b in pairs(self.TrayButtons) do
                if b:IsMouseOver() and b:IsShown() then
                    b:OnEnter();
                    break
                end
            end
        end
    end

    function TrackerFrame:SetButtonNewPosition(buttonIndex)
        if buttonIndex ~= self.newPositionIndex then
            self.newPositionIndex = buttonIndex;
            if buttonIndex == -1 then
                self.DragLine:Hide();
            else
                if self.TrayButtons[buttonIndex] then
                    self:ShowDragLine(true, self.TrayButtons[buttonIndex]);
                else
                    self:ShowDragLine(true, self.TrayButtons[ #self.TrayButtons ], true);
                end
            end
        end
    end

    function TrackerFrame:ConfirmNewArrangement()
        local targetIndex = self.newPositionIndex;
        local fromIndex = self.movedButtonIndex;
        if (targetIndex and fromIndex) and (targetIndex ~= fromIndex) and (targetIndex ~= fromIndex + 1) then
            local itemID = table.remove(self.list, fromIndex);

            if targetIndex == -1 then
                --remove item
            else
                if self.list[targetIndex] then
                    table.insert(self.list, targetIndex, itemID);
                else
                    table.insert(self.list, itemID);
                end
            end

            self:SaveUserTrackList();
            self:BuildTrackList();
            self:UpdateTray(true);
        end
    end
end

do
    --Create main UI objects

    --local parent = ContainerFrameCombinedBags.MoneyFrame; --ContainerFrameCombinedBags.MoneyFrame;
    local parent = UIParent;

    local f = TrackerFrame;
    f:SetParent(parent);

    f:Hide();
    f:SetSize(TRAY_FRAME_MIN_WIDTH, TRAY_FRAME_HEIGHT_BASE);
    --f:SetPoint("LEFT", parent, "LEFT", 0, 0);
    f:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -64);    --child of UIParent

    local bg = addon.CreateNineSliceFrame(f, "NineSlice_GenericBox"); --addon.CreateThreeSliceFrame(f, "GenericBox");
    bg:SetCornerSize(8);
    f.Background = bg;
    bg:SetFrameLevel(f:GetFrameLevel() - 1);
    bg:SetPoint("TOPLEFT", f, "TOPLEFT", BORDER_SHRINK, -BORDER_SHRINK);
    bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -BORDER_SHRINK, BORDER_SHRINK);

    local border = addon.CreateNineSliceFrame(f, "NineSlice_GenericBox_Border"); --addon.CreateThreeSliceFrame(f, "WhiteBorderBlackBackdrop");
    border:SetCornerSize(8);
    f.Border = border;
    local r, g, b = API.GetColorByName("SmoothGreen");
    border:SetColor(r, g, b);
    border:SetFrameLevel(f:GetFrameLevel() + 10);
    border:Hide();
    border:SetSize(16, 16 - 2*BORDER_SHRINK);
    border:SetPoint("CENTER", f, "CENTER", 0, 0);

    border.Instruction = border:CreateFontString(nil, "OVERLAY", "GameTooltipTextSmall");
    border.Instruction:SetJustifyH("CENTER");
    border.Instruction:SetPoint("CENTER", border, "CENTER", 0, 0);
    border.Instruction:SetTextColor(1, 1, 1);

    border.PlusSign = border:CreateTexture(nil, "OVERLAY");
    border.PlusSign:SetSize(16, 16);
    border.PlusSign:SetPoint("CENTER", border, "CENTER", 0, 0);
    border.PlusSign:Hide();
    border.PlusSign:SetTexture("Interface/AddOns/Plumber/Art/BackpackItemTracker/PlusSign");

    local glow = f:CreateTexture(nil, "BORDER", nil, -1);
    border.Glow = glow;
    glow:Hide();
    glow:SetSize(160, 64);
    glow:SetPoint("CENTER", border, "CENTER", 0, 0);
    glow:SetTexture("Interface/AddOns/Plumber/Art/Frame/ThreeSliceFrameGlowDispersive");
    glow:SetVertexColor(9/255, 89/255, 57/255);
    glow:SetBlendMode("ADD");
    glow:SetAlpha(0);


    --ThreeDotButton (items with 0 count dock here)
    local tdb = CreateFrame("Frame", nil, f);
    tdb:Hide();
    f.ThreeDotButton = tdb;
    tdb:SetSize(24, 20);
    tdb:SetPoint("RIGHT", f, "RIGHT", 0, 0);
    tdb.Icon = tdb:CreateTexture(nil, "OVERLAY");
    tdb.Icon:SetSize(16, 16);
    tdb.Icon:SetPoint("CENTER", tdb, "CENTER", 0, 0);
    tdb.Icon:SetTexture("Interface/AddOns/Plumber/Art/BackpackItemTracker/ThreeDot");
    API.DisableSharpening(tdb.Icon);

    --show a list of zero item on drop-up menu
    local function ThreeDotButton_OnEnter(self)
        GameTooltip:Hide();
        TooltipFrame:Hide();

        tdb.Icon:SetVertexColor(0.8, 0.8, 0.8);

        TooltipFrame:SetOwner(tdb, "ANCHOR_RIGHT");
        TooltipFrame:AddCenterLine(L["Not Found"], 1, 0.82, 0);

        local text, icon;
        for i, itemID in ipairs(ItemDataProvider:GetZeroCountItem()) do
            text = GetColorizedItemName(itemID);

            if text then
                icon = GetItemIconByID(itemID);

                if icon then
                    text = string.format("|T%s:0:0:0:-1:64:64:4:60:4:60|t %s", icon, text);
                end

                TooltipFrame:AddLeftLine(text, 1, 1, 1);
            end
        end

        TooltipFrame:Show();
    end

    local function ThreeDotButton_OnLeave(self)
        tdb.Icon:SetVertexColor(0.5, 0.5, 0.5);
        TooltipFrame:Hide();
    end

    local function ThreeDotButton_OnMouseUp(self)
        SettingsFrame:ToggleUI();
        TooltipFrame:Hide();
    end

    ThreeDotButton_OnLeave(tdb);
    tdb:SetScript("OnEnter", ThreeDotButton_OnEnter);
    tdb:SetScript("OnLeave", ThreeDotButton_OnLeave);
    tdb:SetScript("OnMouseUp", ThreeDotButton_OnMouseUp);
end


function TrackerFrame:UpdateAnchor(forceUpdate)
    --When using CombinedBags, default to MoneyFrame, until it becomes to wide and we will put it under the ContainerUI
    local useCombinedBags = C_CVar.GetCVarBool("combinedBags");
    local anchorMode;

    local parent;

    if useCombinedBags then
        if self:GetWidth() < TRAY_FRAME_WIDTH_THRESHOLD then
            anchorMode = 1;
        else
            anchorMode = 2;
        end
    else
        anchorMode = 3;
    end

    if (anchorMode == self.anchorMode) and (not forceUpdate) then return end;
    self.anchorMode = anchorMode;

    self:ClearAllPoints();
    self.Border:ClearAllPoints();

    if anchorMode == 3 then
        --Anchor to Backpack
        self.Background:Show();
        parent = ContainerFrame1;
        self:SetParent(parent);

        if self:IsPlacedInsideBag() then
            self:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 8, 8);
            self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -8, 8);
            self.Border:SetPoint("TOPLEFT", self.Background, "TOPLEFT", 0, 0);
            self.Border:SetPoint("BOTTOMRIGHT", self.Background, "BOTTOMRIGHT", 0, 0);
        else
            self:SetPoint("TOPRIGHT", parent, "BOTTOMLEFT", -12, -4);
            self.Border:SetPoint("RIGHT", self, "RIGHT", -BORDER_SHRINK, 0);
        end
    else
        parent = ContainerFrameCombinedBags;
        self:SetParent(parent)
        self.Border:SetPoint("LEFT", self, "LEFT", BORDER_SHRINK, 0);
        if anchorMode == 1 then
            --Anchor to MonenyFrame
            self.Background:Hide();
            self:SetPoint("LEFT", parent.MoneyFrame, "LEFT", 0, 0);
        elseif anchorMode == 2 then
            --Anchor to CombinedBag BottomLeft
            self.Background:Show();
            self:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 8, -4);
        end
    end
end

function TrackerFrame:GetSaveTable()
    local db = PlumberDB;

    if db then
        if not db.BackpackTrackedItems then
            db.BackpackTrackedItems = {};
        end

        for k, v in pairs(db.BackpackTrackedItems) do
            if type(v) ~= "number" then
                db.BackpackTrackedItems = {};
                break
            end
        end

        return db.BackpackTrackedItems
    else
        return {}
    end
end

function TrackerFrame:CopyUserTrackList()
    local tbl = {};

    for i, v in ipairs( self:GetSaveTable() ) do
        tbl[i] = v;
    end

    return tbl
end

function TrackerFrame:SaveUserTrackList()
    local tbl = {};
    local n = 0;
    for i, id in ipairs(self.list) do
        if not ExcludeFromSave[id] then
            n = n + 1;
            tbl[n] = id;
        end
    end

    if PlumberDB then
        PlumberDB.BackpackTrackedItems = tbl;
    end
end

function TrackerFrame:IsTrackingAnyItems()
    return self.anyTracking == true
end

function TrackerFrame:UpdateState()
    self.anyTracking = #self.list > 0;

    local n = 0;
    for i, id in ipairs(self.list) do
        if not ExcludeFromSave[id] then
            n = n + 1;
        end
    end
    self.numCustomItems = n;
end

function TrackerFrame:CanTrackMoreItems()
    return self.numCustomItems < MAX_CUSTOM_ITEMS
end

function TrackerFrame:IsTrackedItem(itemID)
    for _, id in ipairs(self.list) do
        if itemID == id then
            return true
        end
    end

    return false
end

function TrackerFrame:AddTrackItem(itemID, toTop)
    if (not self:IsTrackedItem(itemID)) and self:CanTrackMoreItems() then
        if toTop then
            table.insert(self.list, 1, itemID);
        else
            table.insert(self.list, itemID);
        end
        return true
    end
end


function TrackerFrame:IsReceptorFocused()
    return self.Receptor:IsMouseOver()
end

function TrackerFrame:ShowBorder(colorName)
    local r, g, b = API.GetColorByName(colorName);
    self.Border:SetColor(r, g, b);
    self.Border:Show();
end

function TrackerFrame:HideBorderAndGlow()
    self.Border:Hide();
    self.Border.Glow:Hide();
    self.Border.Glow:SetAlpha(0);
end

local function Glow_Show_OnUpdate(self, elapsed)
    self.alpha = self.alpha + 2*elapsed;
    if self.alpha > 1 then
        self.alpha = 1;
        self:SetScript("OnUpdate", nil);
    end
    self.Glow:SetAlpha(self.alpha);
end

local function Glow_Hide_OnUpdate(self, elapsed)
    self.alpha = self.alpha - 5*elapsed;
    if self.alpha < 0 then
        self.alpha = 0;
        self:SetScript("OnUpdate", nil);
        self.Glow:Hide();
    end
    self.Glow:SetAlpha(self.alpha);
end

function TrackerFrame:ShowGlow()
    self.Border.alpha = self.Border.Glow:GetAlpha();
    self.Border:SetScript("OnUpdate", Glow_Show_OnUpdate);
    self.Border.Glow:Show();
end

function TrackerFrame:HideGlow()
    if self.Border.Glow:IsShown() then
        self.Border.alpha = self.Border.Glow:GetAlpha();
        self.Border:SetScript("OnUpdate", Glow_Hide_OnUpdate);
    end
end

function TrackerFrame:ShowGreenLight()
    self:ShowBorder("SmoothGreen");
    self:ShowGlow();
    self.Border.Instruction:SetText("");
    self.Border.PlusSign:Show();
end

function TrackerFrame:HighlightSelection()
    self:ShowBorder("SelectionBlue");
    self:HideGlow();
    self.Border.Instruction:SetText(L["Instruction Track Item"]);
    self.Border.PlusSign:Hide();
end

local function GetCursorItemID()
    local infoType, id = GetCursorInfo();
    if infoType == "item" then
        return id
    end
end

local function CanItemBeTracked(itemID)
    local stackSize = itemID and GetItemMaxStackSizeByID(itemID)
    return stackSize and stackSize > 1
end

do
    -- Receptor process the cursor item
    local f = CreateFrame("Frame", nil, TrackerFrame);
    f:Hide();
    TrackerFrame.Receptor = f;
    f:SetPoint("TOPLEFT", TrackerFrame.Border, "TOPLEFT", 0, 4);      --Slightly increase its hitrect so users don't drop the item into the gap between BagUI and or frame and show Destroy Item dialogue
    f:SetPoint("BOTTOMRIGHT", TrackerFrame.Border, "BOTTOMRIGHT", 0, -4);

    local function TokenTray_Receptor_OnEnter(self)
        if CursorHasItem() then
            TrackerFrame:ShowGreenLight();
        end
    end

    local function TokenTray_Receptor_OnLeave(self)
        if CursorHasItem() then
            TrackerFrame:HighlightSelection();
        end
    end

    local function TokenTray_Receptor_ReceiveCursorItem(self)
        if CursorHasItem() then
            local itemID = GetCursorItemID();
            ClearCursor();

            local success = TrackerFrame:AddTrackItem(itemID);
            if success then
                TrackerFrame:UpdateState();
                TrackerFrame:UpdateTray();
                TrackerFrame:SaveUserTrackList();
                SettingsFrame:UpdateListFrame();
            end
        end
    end

    local function TokenTray_Receptor_ShowWarning(self)
        GameTooltip:Hide();
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
        GameTooltip:AddLine(string.format(L["Item Track Too Many"], MAX_CUSTOM_ITEMS), 1.000, 0.282, 0.000, true);
        GameTooltip:Show();
    end

    local function TokenTray_Receptor_HideWarning(self)
        GameTooltip:Hide();
    end

    function TrackerFrame:SetToReceptorMode()
        self:Show();
        f:Show();
        f:SetFrameLevel(self:GetFrameLevel() + 20);
        f:SetScript("OnEnter", TokenTray_Receptor_OnEnter);
        f:SetScript("OnLeave", TokenTray_Receptor_OnLeave);
        f:SetScript("OnMouseDown", TokenTray_Receptor_ReceiveCursorItem);
        f:SetScript("OnReceiveDrag", TokenTray_Receptor_ReceiveCursorItem);
    end

    function TrackerFrame:SetToWarningMode()
        self:Show();
        f:Show();
        f:SetFrameLevel(self:GetFrameLevel() + 20);
        f:SetScript("OnEnter", TokenTray_Receptor_ShowWarning);
        f:SetScript("OnLeave", TokenTray_Receptor_HideWarning);
        f:SetScript("OnMouseDown", nil);
        f:SetScript("OnReceiveDrag", nil);
    end
end

function TrackerFrame:SetToDisplayMode()
    self.Receptor:Hide();
    self:HideBorderAndGlow();
end

local function TrackerFrame_OnUpdate_Request(self, elapsed)
    self.delay = self.delay + elapsed;
    if self.delay > 0 then
        self:SetScript("OnUpdate", nil);
        TrackerFrame:UpdateTray(self.manualRequset);
        self.manualRequset = nil;
    end
end

function TrackerFrame:RequestUpdate(manual)
    self.delay = -0.1;
    self.manualRequset = manual;
    self:SetScript("OnUpdate", TrackerFrame_OnUpdate_Request);
end

local function TokenTray_OnShow(self)
    self:SetToDisplayMode();
    self:RegisterEvent("CURSOR_CHANGED");
    self:RegisterEvent("BAG_UPDATE");
end

local function TokenTray_OnHide(self)
    self:UnregisterEvent("CURSOR_CHANGED");
    self:UnregisterEvent("BAG_UPDATE");
end

local function TokenTray_OnEvent(self, event, ...)
    if event == "CURSOR_CHANGED" then
        if CursorHasItem() and CanItemBeTracked( GetCursorItemID() ) then
            if TrackerFrame:CanTrackMoreItems() then
                TrackerFrame:SetToReceptorMode();
                if TrackerFrame:IsReceptorFocused() then
                    TrackerFrame:ShowGreenLight();
                else
                    TrackerFrame:HighlightSelection();
                end
            else
                TrackerFrame:SetToWarningMode();
            end
        else
            TrackerFrame:SetToDisplayMode();
        end
    elseif event == "BAG_UPDATE" then
        TrackerFrame:RequestUpdate();
    end
end

local function TrackerFrame_OnMouseUp(self, button)
    if button == "RightButton" and self:IsVisible() and self:IsMouseOver() then
        SettingsFrame:ToggleUI();
    end
end

TrackerFrame:SetScript("OnShow", TokenTray_OnShow);
TrackerFrame:SetScript("OnHide", TokenTray_OnHide);
TrackerFrame:SetScript("OnEvent", TokenTray_OnEvent);
TrackerFrame:SetScript("OnMouseUp", TrackerFrame_OnMouseUp);


function TrackerFrame:GetTrackList()
    if HIDE_ZERO_COUNT_ITEM then
        return ItemDataProvider:GetOwnedItem();
    else
        return self.list
    end
end

function TrackerFrame:IsPlacedInsideBag()
    local f = ContainerFrame1;
    return f and f:IsShown() and INSIDE_SEPARATE_BAG and self.isBlizzardBag == true
end

function TrackerFrame:UpdateTray(manual)
    ItemDataProvider:UpdateItemCount();

    local list = self:GetTrackList();
    local numItems = #list;

    local fullWidth = 0;
    local button, width;
    local itemID, wasTracked;

    if manual then
        --Fade in new items
        wasTracked = {};
        for k, button in ipairs(self.TrayButtons) do
            itemID = button.itemID or button.currencyID;
            if itemID then
                wasTracked[itemID] = true;
            end
        end
    end

    --Layout
    if self:IsPlacedInsideBag() then
        self.placedInsideBag = true;
        local paddingX = 6;
        local paddingY = 2;
        local buttonHeight = 16;

        local maxRowWidth = ContainerFrame1:GetWidth() - 2*8 - 1*paddingX;
        local rowWidth = 0;
        local numRows = 1;
        local offsetX = paddingX;
        local offsetY = paddingY;
        local buttonGapY = 0;

        for i = 1, numItems do
            button = self:AcquireTrayButton(i);
            button:Show();
            button:SetHeight(buttonHeight);
            itemID = list[i];
            width = button:SetToken(itemID);
            rowWidth = rowWidth + width + TRAY_BUTTON_GAP;
            if rowWidth > maxRowWidth then
                numRows = numRows + 1;
                offsetX = paddingX;
                offsetY = offsetY + buttonGapY + buttonHeight;
                rowWidth = offsetX + width + TRAY_BUTTON_GAP;
            end
            itemID = tonumber(itemID);
            if manual and not wasTracked[itemID] then
                API.UIFrameFadeIn(button, 0.5);
            end

            button:ClearAllPoints();
            button:SetPoint("TOPLEFT", self, "TOPLEFT", offsetX, -offsetY);
            offsetX = offsetX + width + TRAY_BUTTON_GAP;
        end

        --UpdateHeight

        if HIDE_ZERO_COUNT_ITEM and ItemDataProvider:HasZeroCountItem() then
            self.ThreeDotButton:Show();

            if rowWidth + TRAY_BUTTON_GAP + 20 > maxRowWidth then
                numRows = numRows + 1;
                offsetX = TRAY_FRAME_SIDE_PADDING;
                offsetY = offsetY + buttonGapY + buttonHeight;
            end

            self.ThreeDotButton:ClearAllPoints();
            self.ThreeDotButton:SetPoint("TOPLEFT", self, "TOPLEFT", offsetX, -offsetY);
            self.ThreeDotButton:SetHeight(16);
        else
            self.ThreeDotButton:Hide();
        end

        local height;
        if numRows == 1 then
            height = TRAY_FRAME_HEIGHT_BASE;
        else
            height = numRows * (buttonGapY + buttonHeight) - buttonGapY + 2*paddingY;
        end
        self:SetHeight(height);

        if height ~= self.effectiveHeight then
            self.effectiveHeight = height;
            C_Timer.After(0.0, function()
                UpdateContainerLayout();    --Safe?
                self:UpdateAnchor(true);
            end);
        end

    else
        local resetPoint = false;
        if self.placedInsideBag then
            self.placedInsideBag = nil;
            self.effectiveHeight = 0;
            resetPoint = true;
        end

        for i = 1, numItems do
            button = self:AcquireTrayButton(i);
            button:Show();
            itemID = list[i];
            width = button:SetToken(itemID);
            fullWidth = fullWidth + width;
            itemID = tonumber(itemID);
            if manual and not wasTracked[itemID] then
                API.UIFrameFadeIn(button, 0.5);
            end
            
            if resetPoint then
                button:SetHeight(TRAY_BUTTON_HEIGHT);
                button:ClearAllPoints();
                if i == 1 then
                    button:SetPoint("LEFT", self, "LEFT", TRAY_FRAME_SIDE_PADDING, 0);
                else
                    button:SetPoint("LEFT", self.TrayButtons[i - 1], "RIGHT", TRAY_BUTTON_GAP, 0);
                end
            end
        end

        if resetPoint then
            self.ThreeDotButton:ClearAllPoints();
            self.ThreeDotButton:SetPoint("RIGHT", self, "RIGHT", 0, 0);
            self.ThreeDotButton:SetHeight(TRAY_BUTTON_HEIGHT);
            self:SetHeight(TRAY_FRAME_HEIGHT_BASE);

            C_Timer.After(0.01, function()
                self:UpdateAnchor(true);
            end);
        end

        --UpdateWidth
        fullWidth = fullWidth + 2*TRAY_FRAME_SIDE_PADDING + (numItems - 1)*TRAY_BUTTON_GAP;

        if HIDE_ZERO_COUNT_ITEM and ItemDataProvider:HasZeroCountItem() then
            self.ThreeDotButton:Show();
            fullWidth = fullWidth + 16;
        else
            self.ThreeDotButton:Hide();
        end

        if fullWidth < TRAY_FRAME_MIN_WIDTH then
            fullWidth = TRAY_FRAME_MIN_WIDTH;
        elseif fullWidth > TRAY_FRAME_MAX_WDITH then
            fullWidth = TRAY_FRAME_MAX_WDITH;
        end

        self:SetWidth(fullWidth);
        self.Border:SetWidth(math.max(fullWidth, RECEPTOR_MIN_WIDTH));
    end

    self:UpdateAnchor();

    for i = numItems + 1, #self.TrayButtons do
        self.TrayButtons[i]:Hide();
        self.TrayButtons[i].itemID = nil;
        self.TrayButtons[i].currencyID = nil;
    end
end

function TrackerFrame:CalculateHeight()
    if self.effectiveHeight then
        return self.effectiveHeight + 3;
    else
        return TRAY_FRAME_HEIGHT_BASE
    end
end

local function GetSearchBox()
    return _G["BagItemSearchBox"]
end

function TrackerFrame:SearchItemByID(itemID)
    if itemID then
        local box = GetSearchBox();
        if box and box:IsVisible() then
            local currentText = box:GetText();
            local itemName = C_Item.GetItemNameByID(itemID) or "";
            if currentText ~= "" and string.find(string.lower(itemName), string.lower(currentText)) then
                box:SetText("");
            else
                box:SetText(itemName);
            end
        end
    end
end

function TrackerFrame:OnBagOpen()
    if (not ENABLE_THIS_MODULE) or self.isOpen then return end;
    self.isOpen = true;

    if self:IsTrackingAnyItems() then
        self:UpdateTray();
    end
end

function TrackerFrame:OnBagClose()
    if self.isOpen then
        self.isOpen = false;
    else
        return
    end
end

function TrackerFrame:BuildTrackList()
    --Pin top the top: Holiday Token
    self.list = TrackerFrame:CopyUserTrackList();
    for _, itemID in ipairs(CurrentPinnedItems) do
        table.insert(self.list, 1, itemID);
    end

    TrackerFrame:UpdateState();
end

local function TrackerFrame_Update_OnShow(self)
    --for bag addons that don't trigger EventRegistry, the TrackerFrame with be parented to the bag addon itself and update OnShow
    TokenTray_OnShow(self);
    if self:IsTrackingAnyItems() then
        self:UpdateTray();
    end
end


local RepositionUtil = {};

RepositionUtil.minYSize = TRAY_FRAME_HEIGHT_BASE + 4;

function RepositionUtil:Start()
    if not self.f then
        self.f = CreateFrame("Frame", nil, TrackerFrame);
        self.f:Hide();
        self.f:SetScript("OnHide", function(f)
            f:Hide();
        end);

        local function OnUpdate(f, elapsed)
            f.t = f.t + elapsed;
            if f.t > 0.1 then
                f.t = 0;
                self:UpdateAnchor();
            end
        end

        self.f:SetScript("OnUpdate", OnUpdate);
    end

    self.f.t = 0;
    self.f:Show();
end

function RepositionUtil:UpdateAnchor()
    self.x = self.parent:GetLeft();
    self.y = self.parent:GetBottom();
    local anchorMode;

    if (not self.x) or (not self.y) or (self.y > self.minYSize) then
        anchorMode = 1;
    else
        if self.x > TRAY_FRAME_MAX_WDITH then
            anchorMode = 2;
        else
            anchorMode = 3;
        end
    end
    if anchorMode ~= self.anchorMode then
        self:SetAnchorMode(anchorMode);
    end
end

function RepositionUtil:Stop()
    if self.f then
        self.f:Hide();
    end
end

function RepositionUtil:SetAnchorMode(id)
    self.anchorMode = id;

    local f = TrackerFrame;
    f:ClearAllPoints();
    f.Border:ClearAllPoints();

    if id == 1 then
        --Bellow bag, align to Left
        f:SetPoint("TOPLEFT", self.parent, "BOTTOMLEFT", 1, -2);
        f.Border:SetPoint("LEFT", f, "LEFT", BORDER_SHRINK, 0);
    elseif id == 2 then
        --Left of bottom-left, align to Right
        f:SetPoint("BOTTOMRIGHT", self.parent, "BOTTOMLEFT", -2, 2);
        f.Border:SetPoint("RIGHT", f, "RIGHT", -BORDER_SHRINK, 0);
    elseif id == 3 then
        --Right of bottom-right, align to Left
        f:SetPoint("BOTTOMLEFT", self.parent, "BOTTOMRIGHT", 2, 2);
        f.Border:SetPoint("LEFT", f, "LEFT", BORDER_SHRINK, 0);
    end
end

function TrackerFrame:ParentTo_Bagnon()
    --Changes to Bagnon 10.2.15: Frame Struture Changed, Bottom Left of the Bag becomes DataBroker

    local parent = BagnonInventory1;
    if not parent then
        local frameInQuestion = BagnonContainerItem1 and BagnonContainerItem1:GetParent() and BagnonContainerItem1:GetParent():GetParent() and BagnonContainerItem1:GetParent():GetParent():GetParent();
        if frameInQuestion and frameInQuestion.Title then
            parent = frameInQuestion;
        end
    end

    if not parent then return end;

    self.isBlizzardBag = false;
    self.Background:Show();
    self:SetParent(parent);
    self:SetScript("OnShow", TrackerFrame_Update_OnShow);
    self:Show();
    self:SetClampedToScreen(true);

    RepositionUtil.parent = parent;
    RepositionUtil:UpdateAnchor();

    local header = parent.Title;

    if header then
        if header:GetScript("OnMouseDown") then
            header:HookScript("OnMouseDown", function()
                RepositionUtil:Start();
            end);
        end

        if header:GetScript("OnMouseUp") then
            header:HookScript("OnMouseUp", function()
                RepositionUtil:Stop();
            end);
        end
    end
end

function TrackerFrame:ParentTo_AdiBags()
    local parent = AdiBagsContainer1;

    if not parent then return end;

    self.isBlizzardBag = false;
    self.Background:Show();
    self:SetParent(parent);
    self:SetScript("OnShow", TrackerFrame_Update_OnShow);
    self:Show();
    self:SetClampedToScreen(true);

    RepositionUtil.parent = parent;
    C_Timer.After(0.5, function()
        --anchor not available on-created
        RepositionUtil:UpdateAnchor();

        local header = AdiBagsBagAnchor1;

        if header then
            if header:GetScript("OnMouseDown") then
                header:HookScript("OnMouseDown", function()
                    RepositionUtil:Start();
                end);
            end

            if header:GetScript("OnMouseUp") then
                header:HookScript("OnMouseUp", function()
                    RepositionUtil:Stop();
                end);
            end
        end
    end);
end

function TrackerFrame:ParentTo_ArkInventory()
    local parent = ARKINV_Frame1;

    if not parent then return end;

    self.isBlizzardBag = false;
    self.Background:Show();
    self:SetParent(parent);
    self:SetScript("OnShow", TrackerFrame_Update_OnShow);
    self:Show();
    self:SetClampedToScreen(true);

    RepositionUtil.parent = parent;
    RepositionUtil:UpdateAnchor();

    if parent.StartMoving then
        hooksecurefunc(parent, "StartMoving", function(_)
            RepositionUtil:Start();
        end);
    end

    if parent.StopMovingOrSizing then
        hooksecurefunc(parent, "StopMovingOrSizing", function(_)
            RepositionUtil:Stop();
        end);
    end
end

function TrackerFrame:ParentTo_ElvUI()
    local parent = ElvUI_ContainerFrame;

    if not parent then return end;

    self.isBlizzardBag = false;
    self.Background:Show();
    self:SetParent(parent);
    self:SetScript("OnShow", TrackerFrame_Update_OnShow);
    self:Show();
    self:SetClampedToScreen(true);

    RepositionUtil.parent = parent;
    RepositionUtil:UpdateAnchor();

    if parent.StartMoving then
        hooksecurefunc(parent, "StartMoving", function(_)
            RepositionUtil:Start();
        end);
    end

    if parent.StopMovingOrSizing then
        hooksecurefunc(parent, "StopMovingOrSizing", function(_)
            RepositionUtil:Stop();
        end);
    end
end

function TrackerFrame:ParentTo_NDui()
    local parent = NDui_BackpackBag;

    if not parent then return end;

    self.isBlizzardBag = false;
    self.Background:Show();
    self:SetParent(parent);
    self:SetScript("OnShow", TrackerFrame_Update_OnShow);
    self:Show();
    self:SetClampedToScreen(true);

    RepositionUtil.parent = parent;
    RepositionUtil:UpdateAnchor();

    if parent.StartMoving then
        hooksecurefunc(parent, "StartMoving", function(_)
            RepositionUtil:Start();
        end);
    end

    if parent.StopMovingOrSizing then
        hooksecurefunc(parent, "StopMovingOrSizing", function(_)
            RepositionUtil:Stop();
        end);
    end
end

function TrackerFrame:ParentTo_LiteBag()
    local parent = LiteBagBackpack;

    if not parent then return end;

    self.isBlizzardBag = false;
    self.Background:Show();
    self:SetParent(parent);
    self:SetScript("OnShow", TrackerFrame_Update_OnShow);
    self:Show();
    self:SetClampedToScreen(true);

    RepositionUtil.parent = parent;
    RepositionUtil:UpdateAnchor();

    if parent.StartMoving then
        hooksecurefunc(parent, "StartMoving", function(_)
            RepositionUtil:Start();
        end);
    end

    if parent.StopMovingOrSizing then
        hooksecurefunc(parent, "StopMovingOrSizing", function(_)
            RepositionUtil:Stop();
        end);
    end
end

function TrackerFrame:ParentTo_Baganator()
    local parent = Baganator_SingleViewBackpackViewFrame;

    if not parent then return end;

    self.isBlizzardBag = false;
    self.Background:Show();
    self:SetParent(parent);
    self:SetScript("OnShow", TrackerFrame_Update_OnShow);
    self:Show();
    self:SetClampedToScreen(false);
    self:ClearAllPoints();

    local anchorTo = Baganator_SingleViewBackpackViewFrame;

    local function Callback_AllocateBags()
        if anchorTo.lastBagDetails then
            local numButtons = anchorTo.lastBagDetails.special and #anchorTo.lastBagDetails.special or 0;
            local fromOffset = 0;
            local iconButtonWidth = 32;
            local buttonSpacing = 5;
            local offset = (numButtons) * (iconButtonWidth + buttonSpacing) + fromOffset;
            if anchorTo.BagLive then
                self:ClearAllPoints();
                self:SetPoint("LEFT", anchorTo.BagLive, "LEFT", offset, 0);
                self:SetPoint("BOTTOM", anchorTo, "BOTTOM", 0, 9);
            end
        end
    end

    if anchorTo then
        if anchorTo.AllocateBags then
            hooksecurefunc(Baganator_SingleViewBackpackViewFrame, "AllocateBags", Callback_AllocateBags)
        end
        self:SetPoint("LEFT", anchorTo, "BOTTOMLEFT", 54, 17);
        self.Border:SetPoint("LEFT", self, "LEFT", BORDER_SHRINK, 0);
    else
        self:Hide();
    end
end

function TrackerFrame:ParentTo_BetterBags()
    local parent = BetterBagsBagBackpack;

    if not parent then return end;

    self.isBlizzardBag = false;
    self.Background:Show();
    self:SetParent(parent);
    self:SetScript("OnShow", TrackerFrame_Update_OnShow);
    self:Show();
    self:SetClampedToScreen(false);

    RepositionUtil.parent = parent;
    self:ClearAllPoints();
    self.Border:ClearAllPoints();

    self.Border:SetPoint("LEFT", self, "LEFT", BORDER_SHRINK, 0);

    local anchorOutside = true;
    if anchorOutside then
        self:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -2);
    else
        self:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 4, 5);
    end
end

local GetAddOnSearchBox = {
    Bagnon = function()
        if not (BagnonInventory1 and BagnonInventory1.SearchFrame and BagnonInventory1.searchToggle) then return end;
        local toggle = BagnonInventory1.searchToggle;
        if not toggle:GetChecked() then
            toggle:Click();
        end
        return BagnonInventory1.SearchFrame
    end,

    AdiBags = function() return _G["AdiBagsContainer1SearchBox"] end,

    ArkInventory = function() return _G["ARKINV_Frame1SearchFilter"] end,

    ElvUI = function() return _G["ElvUI_ContainerFrameEditBox"] end,

    NDui = function()
        local box = NDui_BackpackBag.Search;
        if box then
            box:Show();
        end
        return box
    end,

    Baganator = function()
        local bagFarme = Baganator_SingleViewBackpackViewFrame;
        return bagFarme and bagFarme.SearchBox
    end,
};


local function DoesNothing()
end

local function AnchorToCompatibleAddOn()
    local IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded;
    if IsAddOnLoaded("Bagnon") then
        if Bagnon and Bagnon.Frames and Bagnon.Frames.Toggle then
            local bagHook = false;
            hooksecurefunc(Bagnon.Frames, "Toggle", function(_, label)
                if label == "inventory" then
                    if not bagHook then
                        bagHook = true;
                        TrackerFrame.UpdateAnchor = DoesNothing;
                        TrackerFrame:ParentTo_Bagnon();
                        GetSearchBox = GetAddOnSearchBox.Bagnon;
                    end
                end
            end);
        end
    elseif IsAddOnLoaded("AdiBags") then
        local AdiBags = LibStub('AceAddon-3.0'):GetAddon("AdiBags");
        if AdiBags and AdiBags.CreateContainerFrame then
            local bagHook = false;
            hooksecurefunc(AdiBags, "CreateContainerFrame", function(_, bagName, isBank)
                if not bagHook then
                    if bagName == "Backpack" then
                        bagHook = true;
                        TrackerFrame.UpdateAnchor = DoesNothing;
                        TrackerFrame:ParentTo_AdiBags();
                        GetSearchBox = GetAddOnSearchBox.AdiBags;
                    end
                end
            end);
        end
    elseif IsAddOnLoaded("ArkInventory") then
        local bagFrame = ARKINV_Frame1;
        if bagFrame then
            TrackerFrame.UpdateAnchor = DoesNothing;
            TrackerFrame:ParentTo_ArkInventory();
            TrackerFrame:SetScale(1.2);
            GetSearchBox = GetAddOnSearchBox.ArkInventory;
        end
    elseif IsAddOnLoaded("LiteBag") then
        local bagFrame = LiteBagBackpack;
        if bagFrame then
            TrackerFrame.UpdateAnchor = DoesNothing;
            TrackerFrame:ParentTo_LiteBag();
            --This addon is using stock searchbox
        end
    elseif IsAddOnLoaded("Baganator") then
        --Baganator is being actively developed
        --Available space (width) is affected by Bag Columns, we ignore it for now
        local bagFrame = Baganator_SingleViewBackpackViewFrame;
        if bagFrame then
            TrackerFrame.UpdateAnchor = DoesNothing;
            TrackerFrame:ParentTo_Baganator();
            GetSearchBox = GetAddOnSearchBox.Baganator;
        end
    elseif IsAddOnLoaded("BetterBags") then --New Adibags(Still WIP)
        local bagFrame = BetterBagsBagBackpack;     --WTF is this name
        if bagFrame then
            TrackerFrame.UpdateAnchor = DoesNothing;
            TrackerFrame:ParentTo_BetterBags();
            --GetSearchBox = GetAddOnSearchBox.BetterBags;  --No Search Bar yet
        end
    elseif IsAddOnLoaded("ElvUI") then
        local bagFrame = ElvUI_ContainerFrame;
        if bagFrame then
            TrackerFrame.UpdateAnchor = DoesNothing;
            TrackerFrame:ParentTo_ElvUI();
            GetSearchBox = GetAddOnSearchBox.ElvUI;
        end
    elseif IsAddOnLoaded("NDui") then
        local bagFrame = NDui_BackpackBag;
        if bagFrame then
            TrackerFrame.UpdateAnchor = DoesNothing;
            TrackerFrame:ParentTo_NDui();
            GetSearchBox = GetAddOnSearchBox.NDui;
        end
    end

    AnchorToCompatibleAddOn = nil;
end

local function RegisterBag()
    EventRegistry:RegisterCallback("ContainerFrame.OpenAllBags", TrackerFrame.OnBagOpen, TrackerFrame);
    EventRegistry:RegisterCallback("ContainerFrame.CloseAllBags", TrackerFrame.OnBagClose, TrackerFrame);
    RegisterBag = nil;
end




local function OnModuleEnabled()
    ENABLE_THIS_MODULE = true;

    TrackerFrame:BuildTrackList();
    TrackerFrame:Show();
    if RegisterBag then
        RegisterBag();
    end
    SettingsFrame.OnChanged();

    EL:RegisterEvent("USE_COMBINED_BAGS_CHANGED");
    EL:RegisterEvent("CURRENCY_DISPLAY_UPDATE");

    if AnchorToCompatibleAddOn then
        AnchorToCompatibleAddOn();
    end
end

local function OnModuleDisabled()
    ENABLE_THIS_MODULE = false;
    TrackerFrame:Hide();

    EL:UnregisterEvent("USE_COMBINED_BAGS_CHANGED");
    EL:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
end

function InitializeModule()
    CurrentPinnedItems = {};

    local trackCrests = true;
    if trackCrests then
        local bestCurrencyID = CrestUtil:GetBestCrestForPlayer();
        if bestCurrencyID then
            table.insert(CurrentPinnedItems, 1, tostring(bestCurrencyID));
        end
    end

    local HolidayInfo = API.GetActiveMajorHolidayInfo();
    if HolidayInfo then
        for _, info in ipairs(HolidayInfo) do
            local key = info:GetKey();
            local itemID = HolidayItems[key];
            if itemID then
                table.insert(CurrentPinnedItems, 1, itemID);
                --[[
                local expirationText = info:GetEndTimeString();
                if expirationText then
                    expirationText = string.format(L["Holiday Ends Format"], expirationText);
                end
                --]]
                local function GetExpirationTextFunc()
                    local expirationText = info:GetRemainingTimeString();
                    local ENDS_IN_FORMAT = BRAWL_TOOLTIP_ENDS or "Ends in %s";
                    return string.format(ENDS_IN_FORMAT, expirationText);
                end
                ItemDataProvider:SetExpirationText(itemID, GetExpirationTextFunc);
            end
        end
    end

    if ENABLE_THIS_MODULE then
        ItemDataProvider:CacheAllItems();
        OnModuleEnabled();
    end
end

function CrestUtil:ProcessCurrencyUpdate(currencyID)
    if currencyID and self.watchedCurrrencies[currencyID] then
        InitializeModule();
    end
end

local function EL_OnUpdate_OneShot(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 0 then
        self:SetScript("OnUpdate", nil);
        if self.callback then
            self.callback(self);
        end
    end
end

EL:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent(event);

        local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
        C_Calendar.SetAbsMonth(currentCalendarTime.month, currentCalendarTime.year);
        C_Calendar.OpenCalendar();

        ItemDataProvider:RequestAllItemData();
        self.t = -2;
        self.callback = InitializeModule;
        self:SetScript("OnUpdate", EL_OnUpdate_OneShot);
    elseif event == "USE_COMBINED_BAGS_CHANGED" then
        self.delay = -0.1;
        self:SetScript("OnUpdate", TrackerFrame_OnUpdate_Request);
    elseif event == "CURRENCY_DISPLAY_UPDATE" then
        local currencyID = ...
        CrestUtil:ProcessCurrencyUpdate(currencyID);
    end
end);


local function EnableModule(state)
    if state then
        OnModuleEnabled();
    else
        OnModuleDisabled();
    end
end


do
    local moduleData = {
        name = L["ModuleName BackpackItemTracker"],
        dbKey = "BackpackItemTracker",
        description = L["ModuleDescription BackpackItemTracker"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1,
    };

    addon.ControlCenter:AddModule(moduleData);
end
