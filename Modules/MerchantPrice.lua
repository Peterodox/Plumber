local _, addon = ...
local API = addon.API;

local _G = _G;

local MERCHANT_ITEMS_PER_PAGE = 10;
local BUYBACK_ITEMS_PER_PAGE = 12;
local MAX_MERCHANT_CURRENCIES = 6;
local MERCHANT_FRAME = "MerchantFrame";

local PRICE_FRAME_OFFSET_X = 45;

local GetMerchantNumItems = GetMerchantNumItems;
local GetMerchantItemCostInfo = GetMerchantItemCostInfo;
local GetMerchantItemCostItem = GetMerchantItemCostItem;
local GetNumBuybackItems = GetNumBuybackItems;
local GetBuybackItemInfo = GetBuybackItemInfo;
local GetMoney = GetMoney;

local ceil = math.ceil;
local match = string.match;
local tonumber = tonumber;
local tsort = table.sort;

local ShopUI;
local Controller = CreateFrame("Frame");
local TokenDisplay;
local VendorItemPriceFrame = {};

local GetMerchantItemPrice;
if C_MerchantFrame.GetItemInfo then
    local GetMerchantItemInfo = C_MerchantFrame.GetItemInfo;
    function GetMerchantItemPrice(index)
        local info = GetMerchantItemInfo(index);
        if info then
            return info.price, info.hasExtendedCost
        end
    end
else
    local GetMerchantItemInfo = GetMerchantItemInfo;
    function GetMerchantItemPrice(index)
        local _, price, hasExtendedCost;
        _, _, price, _, _, _, _, hasExtendedCost = GetMerchantItemInfo(index);
        return price, hasExtendedCost
    end
end

local function HideBlizzardUITexture()
    MerchantMoneyInset.Bg:SetTexture(nil);
    MerchantMoneyBgLeft:SetTexture(nil);
    MerchantMoneyBgMiddle:SetTexture(nil);
    MerchantMoneyBgRight:SetTexture(nil);
    MerchantMoneyInset:Hide();

    MerchantExtraCurrencyInset.Bg:SetTexture(nil);
    MerchantExtraCurrencyInset.NineSlice:Hide();
    MerchantExtraCurrencyBgLeft:SetTexture(nil);
    MerchantExtraCurrencyBgMiddle:SetTexture(nil);
    MerchantExtraCurrencyBgRight:SetTexture(nil);
end

local InvisibleContainer = {};
do
    InvisibleContainer.objects = {
        --[GlobalName] = OriginalParent
        ["MerchantMoneyInset"] = MERCHANT_FRAME,
        ["MerchantMoneyBg"] = MERCHANT_FRAME,
        ["MerchantExtraCurrencyInset"] = MERCHANT_FRAME,
        ["MerchantExtraCurrencyBg"] = MERCHANT_FRAME,
        ["MerchantMoneyFrame"] = MERCHANT_FRAME,
    };

    function InvisibleContainer:HideObjects(noChangeItemPrice)
        if not ShopUI then return end;

        if not self.f then
            self.f = CreateFrame("Frame", nil, ShopUI);
            self.f:Hide();
        end

        for name in pairs(self.objects) do
            if _G[name] then
                _G[name]:SetParent(self.f);
            end
        end

        if not noChangeItemPrice then
            local merchantMoney, merchantAltCurrency;

            for i = 1, BUYBACK_ITEMS_PER_PAGE do
                merchantMoney = _G["MerchantItem"..i.."MoneyFrame"];
                merchantAltCurrency = _G["MerchantItem"..i.."AltCurrencyFrame"];
                if merchantMoney then
                    merchantMoney:SetParent(self.f);
                end
                if merchantAltCurrency then
                    merchantAltCurrency:SetParent(self.f);
                end
            end
        end

        self.objectsHidden = true;
    end

    function InvisibleContainer:RestoreObjects()
        if not self.objectsHidden then return end;

        for name, parentName in pairs(self.objects) do
            if _G[name] and _G[parentName] then
                _G[name]:SetParent(_G[parentName]);
            end
        end

        local merchantButton, merchantMoney, merchantAltCurrency;

        for i = 1, BUYBACK_ITEMS_PER_PAGE do
            merchantButton = _G["MerchantItem"..i];
            merchantMoney = _G["MerchantItem"..i.."MoneyFrame"];
            merchantAltCurrency = _G["MerchantItem"..i.."AltCurrencyFrame"];
            if merchantButton then
                if merchantMoney then
                    merchantMoney:SetParent(merchantButton);
                end
                if merchantAltCurrency then
                    merchantAltCurrency:SetParent(merchantButton);
                end
            end
        end
    end

    function InvisibleContainer:HideBlizzardMerchantTokens()
        for i = 1, MAX_MERCHANT_CURRENCIES do
            local tokenButton = _G["MerchantToken"..i];
            if tokenButton then
                tokenButton:Hide();
            end
        end
    end
end


local function SortFunc_CurrencyType(a, b)
    if a[1] ~= b[1] then
        return a[1] < b[1]
    end

    return a[2] < b[2]
end

function Controller:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0 then
        self:SetScript("OnUpdate", nil);
        self.t = nil;
        self:UpdateShopUI();
    end
end

function Controller:UpdateMoneyChange() --Unused
    if self.playerCopper and self.moneyDirty then
        self.moneyDirty = nil;

        local newCopper = GetMoney();
        local diff = newCopper - self.playerCopper;
        self.playerCopper = newCopper;

        if diff > 0 then
            
        elseif diff < 0 then

        end
    end
end

function Controller:UpdateShopUI()
    if not ShopUI:IsVisible() then return end;

    local buybackMode = ShopUI.selectedTab == 2;    --1 Buy, 2 Buyback

    self.buybackMode = buybackMode;

    if buybackMode then
        self:UpdateBuybackInfo();
    else
        self:UpdateMerchantInfo();
    end

    --self:UpdateMoneyChange();
end

function Controller:SetupTokenDisplay()
    if not TokenDisplay then
        TokenDisplay = addon.CreateTokenDisplay(ShopUI, "CoinBox");
        TokenDisplay.numberFont = "NumberFontNormal";
        TokenDisplay:SetIncludeBank(true);
        TokenDisplay:ShowMoneyFrame(true);
    end
end

function Controller:UpdateMerchantInfo()
    InvisibleContainer:HideBlizzardMerchantTokens();

    local page = ShopUI.page;

    local name, texture, price, stackCount, numAvailable, isPurchasable, isUsable, extendedCost, currencyID, spellID;
    local numCost;
    local itemTexture, itemValue, itemLink;
    local id, currencyType;
    local priceFrame;

    local numMerchantItems = GetMerchantNumItems();
    local fromIndex = (page - 1) * MERCHANT_ITEMS_PER_PAGE;
    local merchantButton;
    local anyGold;
    local altCurreny;

    local playerMoney = GetMoney();

    local buttonIndex = 0;
    local numPages = ceil(numMerchantItems / MERCHANT_ITEMS_PER_PAGE);

    local numItemsThisPage;

    if page < numPages then
        numItemsThisPage = MERCHANT_ITEMS_PER_PAGE;
    else
        numItemsThisPage = numMerchantItems - (numPages - 1) * MERCHANT_ITEMS_PER_PAGE;
    end

    for buttonIndex = numItemsThisPage + 1, MERCHANT_ITEMS_PER_PAGE do
        priceFrame = VendorItemPriceFrame[buttonIndex];
        if priceFrame then
            priceFrame:Hide();
        end
    end

    for i = fromIndex + 1, fromIndex + numItemsThisPage do
        price, extendedCost = GetMerchantItemPrice(i);

        buttonIndex = buttonIndex + 1;
        merchantButton = _G["MerchantItem"..buttonIndex];

        priceFrame = VendorItemPriceFrame[buttonIndex];
        if not priceFrame then
            priceFrame = addon.CreatePriceDisplay(merchantButton);
            VendorItemPriceFrame[buttonIndex] = priceFrame;
            priceFrame:SetPoint("BOTTOMLEFT", merchantButton, "BOTTOMLEFT", PRICE_FRAME_OFFSET_X, 0);
        end

        if price and price > 0 then
            anyGold = true;
        end

        local requiredCurrency;

        if extendedCost then
            numCost = GetMerchantItemCostInfo(i);
            requiredCurrency = {};

            for n = 1, numCost do
                itemTexture, itemValue, itemLink = GetMerchantItemCostItem(i, n);
                --uncached item's link may be nil

                if itemLink then
                    id = match(itemLink, "currency:(%d+)");
                    if id then
                        currencyType = 0;
                    else
                        id = match(itemLink, "item:(%d+)");
                        if id then
                            currencyType = 1;
                        end
                    end

                    if id and currencyType then
                        id = tonumber(id);

                        if not altCurreny then
                            altCurreny = {};
                        end

                        if id and not altCurreny[id] then
                            --assume itemID and currencyID don't accidently overlap
                            altCurreny[id] = currencyType;
                        end

                        requiredCurrency[n] = {currencyType, id, itemValue, itemTexture};
                    end
                else
                    self:RequestUpdate(0.2);
                end
            end
        end

        priceFrame:SetFrameOwner(merchantButton, "BOTTOMLEFT", PRICE_FRAME_OFFSET_X, 0);
        priceFrame:SetMoneyAndAltCurrency(price, requiredCurrency, playerMoney);
    end

    self:SetupTokenDisplay();

    if anyGold or not altCurreny then
        TokenDisplay:ShowMoneyFrame(true);
    else
        TokenDisplay:ShowMoneyFrame(false);
    end

    local tokens = {};
    if altCurreny then
        TokenDisplay.MoneyFrame:SetSimplified(true);

        local n = 0;

        for id, currencyType in pairs(altCurreny) do
            n = n + 1;
            tokens[n] = {currencyType, id};
        end

        tsort(tokens, SortFunc_CurrencyType);
    else
        TokenDisplay.MoneyFrame:SetSimplified(false);
    end

    --TokenDisplay:DisplayCurrencyOnFrame(tokens, ShopUI, "BOTTOMLEFT", 4, 6);
    TokenDisplay:DisplayCurrencyOnFrame(tokens, ShopUI, "BOTTOMRIGHT", -5, 6);
end

function Controller:UpdateBuybackInfo()
    local _, buybackPrice;
    local merchantButton;
    local priceFrame;

    local numItems = GetNumBuybackItems();

    for i = 1, BUYBACK_ITEMS_PER_PAGE do
        priceFrame = VendorItemPriceFrame[i];

        if i <= numItems then
            _, _, buybackPrice = GetBuybackItemInfo(i);

            merchantButton = _G["MerchantItem"..i];

            if not priceFrame then
                priceFrame = addon.CreatePriceDisplay(merchantButton);
                VendorItemPriceFrame[i] = priceFrame;
                priceFrame:SetPoint("BOTTOMLEFT", merchantButton, "BOTTOMLEFT", PRICE_FRAME_OFFSET_X, 0);
            end

            priceFrame:SetMoneyAndAltCurrency(buybackPrice);
        else
            if priceFrame then
                priceFrame:Hide();
            end
        end
    end

    self:SetupTokenDisplay();
    TokenDisplay:ShowMoneyFrame(true);
    TokenDisplay.MoneyFrame:SetSimplified(false);
    TokenDisplay:DisplayCurrencyOnFrame(nil, ShopUI, "BOTTOMRIGHT", -5, 6);
end

function Controller:RequestUpdate(delay)
    if not self.t then
        self.t = 0;
    end

    self.t = self.t -(delay or 0);
    if self.t < -0.25 then
        self.t = -0.25;
    end

    self:SetScript("OnUpdate", self.OnUpdate);
end


function Controller:ListenEvents(state)
    if state then
        self:RegisterEvent("BAG_UPDATE");
        self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
        self:RegisterEvent("PLAYER_MONEY");
    else
        self:UnregisterEvent("BAG_UPDATE");
        self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
        self:UnregisterEvent("PLAYER_MONEY");
    end
end

function Controller:OnShow()
    self:ListenEvents(true);
    self.playerCopper = GetMoney();
end

function Controller:OnHide()
    self:ListenEvents(false);
    self:SetScript("OnUpdate", nil);
    self.t = nil;
end

function Controller:OnEvent(event, ...)
    if event == "PLAYER_MONEY" then
        self.moneyDirty = true;
    end

    if self.buybackMode then
        self:RequestUpdate(0);
    else
        self:RequestUpdate(0.2);
    end
end

local function MerchantFrame_Update_Callback()
    if Controller.isEnabled then
        Controller:RequestUpdate();
    end
end

function Controller:EnableModule(state)
    if state then
        if MerchantFrame_Update and _G[MERCHANT_FRAME] then
            self.isEnabled = true;
            ShopUI = _G[MERCHANT_FRAME];
            Controller:SetParent(ShopUI);

            if not self.isHooked then
                self.isHooked = true;
                hooksecurefunc("MerchantFrame_Update", MerchantFrame_Update_Callback);
            end

            local noChangeItemPrice = C_AddOns.IsAddOnLoaded("Krowi_ExtendedVendorUI") or C_AddOns.IsAddOnLoaded("ElvUI_WindTools");
            if noChangeItemPrice then
                Controller.UpdateMerchantInfo = Controller._UpdateMerchantInfo;
                Controller.UpdateBuybackInfo = Controller._UpdateBuybackInfo;
            end

            InvisibleContainer:HideObjects(noChangeItemPrice);

            self:SetScript("OnShow", self.OnShow);
            self:SetScript("OnHide", self.OnHide);
            self:SetScript("OnEvent", self.OnEvent);

            self:Show();

            if self:IsVisible() then
                self:OnShow();
            end
        end
    else
        if self.isEnabled then
            self:Hide();
            self:ListenEvents(false);
            InvisibleContainer:RestoreObjects();

            if TokenDisplay then
                TokenDisplay:Hide();
            end

            for _, priceFrame in pairs(VendorItemPriceFrame) do
                priceFrame:Hide();
            end
        end
    end
end


do  --For some Merchant UI addon users we only update the token frame
    function Controller:GetShopPage()
        return ShopUI.page or 1
    end

    function Controller:GetMaxItemsPerPage()
        --Some addons may change this global
        return _G.MERCHANT_ITEMS_PER_PAGE or MERCHANT_ITEMS_PER_PAGE;
    end

    function Controller:_UpdateMerchantInfo()
        InvisibleContainer:HideBlizzardMerchantTokens();

        local page = self:GetShopPage();

        local name, texture, price, stackCount, numAvailable, isPurchasable, isUsable, extendedCost, currencyID, spellID;
        local numCost;
        local itemTexture, itemValue, itemLink;
        local id, currencyType;
        local itemPerPage = self:GetMaxItemsPerPage();
        local numMerchantItems = GetMerchantNumItems();
        local fromIndex = (page - 1) * itemPerPage;
        local anyGold;
        local altCurreny;

        local playerMoney = GetMoney();

        local buttonIndex = 0;
        local numPages = ceil(numMerchantItems / itemPerPage);

        local numItemsThisPage;

        if page < numPages then
            numItemsThisPage = itemPerPage;
        else
            numItemsThisPage = numMerchantItems - (numPages - 1) * itemPerPage;
        end

        for i = fromIndex + 1, fromIndex + numItemsThisPage do
            price, extendedCost = GetMerchantItemPrice(i);

            buttonIndex = buttonIndex + 1;

            if price and price > 0 then
                anyGold = true;
            end

            local requiredCurrency;

            if extendedCost then
                numCost = GetMerchantItemCostInfo(i);
                requiredCurrency = {};

                for n = 1, numCost do
                    itemTexture, itemValue, itemLink = GetMerchantItemCostItem(i, n);
                    --uncached item's link may be nil

                    if itemLink then
                        id = match(itemLink, "currency:(%d+)");
                        if id then
                            currencyType = 0;
                        else
                            id = match(itemLink, "item:(%d+)");
                            if id then
                                currencyType = 1;
                            end
                        end

                        if id and currencyType then
                            id = tonumber(id);

                            if not altCurreny then
                                altCurreny = {};
                            end

                            if id and not altCurreny[id] then
                                --assume itemID and currencyID don't accidently overlap
                                altCurreny[id] = currencyType;
                            end

                            requiredCurrency[n] = {currencyType, id, itemValue, itemTexture};
                        end
                    else
                        self:RequestUpdate(0.2);
                    end
                end
            end
        end

        self:SetupTokenDisplay();

        if anyGold or not altCurreny then
            TokenDisplay:ShowMoneyFrame(true);
        else
            TokenDisplay:ShowMoneyFrame(false);
        end

        local tokens = {};
        if altCurreny then
            TokenDisplay.MoneyFrame:SetSimplified(true);

            local n = 0;

            for id, currencyType in pairs(altCurreny) do
                n = n + 1;
                tokens[n] = {currencyType, id};
            end

            tsort(tokens, SortFunc_CurrencyType);
        else
            TokenDisplay.MoneyFrame:SetSimplified(false);
        end

        TokenDisplay:DisplayCurrencyOnFrame(tokens, ShopUI, "BOTTOMRIGHT", -5, 6);
    end

    function Controller:_UpdateBuybackInfo()
        self:SetupTokenDisplay();
        TokenDisplay:ShowMoneyFrame(true);
        TokenDisplay.MoneyFrame:SetSimplified(false);
        TokenDisplay:DisplayCurrencyOnFrame(nil, ShopUI, "BOTTOMRIGHT", -5, 6);
    end
end


do
    local function EnableModule(state)
        Controller:EnableModule(state);
    end

    local moduleData = {
        name = addon.L["ModuleName MerchantPrice"],
        dbKey = "MerchantPrice",
        description = addon.L["ModuleDescription MerchantPrice"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 6,
        moduleAddedTime = 1719566000,
    };

    addon.ControlCenter:AddModule(moduleData);
end




--[[
function Debug_ShowCurrentMerchantItemList()
    SetMerchantFilter(1);   --All

    local numMerchantItems = GetMerchantNumItems();

    local currencyID;
    local itemID;
    local output, lineText;
    local numCost, itemTexture, itemValue, itemLink, currencyName;

    for i = 1, numMerchantItems do
        local info = C_MerchantFrame.GetItemInfo(i);
        itemID = GetMerchantItemID(i);
        numCost = GetMerchantItemCostInfo(i);

        for n = 1, numCost do
            itemTexture, itemValue, itemLink, currencyName = GetMerchantItemCostItem(i, n);
            currencyID = info.currencyID or string.match(itemLink, "currency:(%d+)");
        end

        currencyID = currencyID or "";
        lineText = strjoin(", ", info.name, itemID, info.price, currencyID);

        if i == 1 then
            output = lineText;
        else
            output = output .. "\n" .. lineText;
        end
    end

    API.PrintTextToClipboard(output);
end
--]]