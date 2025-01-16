local _, addon = ...
local L = addon.L;

local OriginalGetItems = C_AccountStore.GetCategoryItems;

local HIDE_COLLECTED = false;
local Magnifier;

local DataProvider = {};
do
    function DataProvider:GetCategoryItems(categoryID, uncollectedOnly)
        if uncollectedOnly then
            if not self.categoryData then
                self:RefreshCategoryData();
            end
            return self.categoryData[categoryID].uncollectedItems
        else
            return OriginalGetItems(categoryID)
        end
    end

    function DataProvider:GetCategoryNumUncollected(categoryID)
        if not self.categoryData then
            self:RefreshCategoryData();
        end
        return self.categoryData[categoryID].numUncollected
    end

    function DataProvider:GetCategoryType(categoryID)
        if not self.categoryData then
            self:RefreshCategoryData();
        end
        return self.categoryData[categoryID].type
    end

    function DataProvider:GetCategoryList(uncollectedOnly)
        if uncollectedOnly then
            if not self.categoryData then
                self:RefreshCategoryData();
            end
            return self.categoryData.uncollectedCategories
        else
            return C_AccountStore.GetCategories(Constants.AccountStoreConsts.PlunderstormStoreFrontID)
        end
    end

    function DataProvider:GetCategoryPrice(categoryID)
        if not self.categoryData then
            self:RefreshCategoryData();
        end
        return self.categoryData[categoryID].price
    end

    function DataProvider:GetFullPurchasePrice()
        if not self.categoryData then
            self:RefreshCategoryData();
        end
        return self.categoryData.totalPrice
    end

    function DataProvider:RefreshCategoryData()
        local storeFrontID = Constants.AccountStoreConsts.PlunderstormStoreFrontID;
        local categories = C_AccountStore.GetCategories(storeFrontID);
        local items, itemInfo, isOwned, n;
        local enum = Enum.AccountStoreItemStatus;
        local totalPrice = 0;

        self.categoryData = {};
        self.categoryData.uncollectedCategories = {};
        self.categoryData.totalPrice = 0;

        for i, categoryID in ipairs(categories) do
            items = OriginalGetItems(categoryID);
            n = 0;
            local uncollectedItems = {};
            local price = 0;
            local categoryInfo = C_AccountStore.GetCategoryInfo(categoryID);
            for _, itemID in ipairs(items) do
                itemInfo = C_AccountStore.GetItemInfo(itemID);
                isOwned = itemInfo and (itemInfo.status == enum.Owned) or (itemInfo.status == enum.Refundable);
                if not isOwned then
                    n = n + 1;
                    uncollectedItems[n] = itemID;
                    price = price + (itemInfo.price or 0);
                end
            end
            self.categoryData[categoryID] = {
                uncollectedItems = uncollectedItems,
                numUncollected = n,
                type = categoryInfo.type,
                price = price,
            };
            totalPrice = totalPrice + price;
            if n > 0 then
                table.insert(self.categoryData.uncollectedCategories, categoryID);
            end
        end

        self.categoryData.totalPrice = totalPrice;
    end

    function DataProvider:GetCurrentCategoryID()
        return AccountStoreFrame.StoreDisplay.categoryID
    end
end


local function NewGetItems(categoryID)
    return DataProvider:GetCategoryItems(categoryID, true)
end

C_AddOns.LoadAddOn("Blizzard_AccountStore");



local function GetTransmogCardModelSceneActor(card)
    local useNativeForm = true;
    local playerRaceName = nil;
    local playerGender = nil;
    local _, raceFilename = UnitRace("player");
    playerRaceName = raceFilename:lower();
    playerGender = UnitSex("player");
    local overrideActorName;
    if playerRaceName == "dracthyr" then
        useNativeForm = false;
        overrideActorName = "dracthyr-alt";
    end
    playerRaceName = playerRaceName and playerRaceName:lower() or overrideActorName;
    return card.ModelScene:GetPlayerActor(nil, playerRaceName, playerGender);
end

local function SetupMagnifierForCard(card, itemID)
    Magnifier:ClearAllPoints();
    Magnifier:SetParent(card);
    Magnifier:SetPoint("TOPLEFT", card, "TOPLEFT", 16, -12);
    Magnifier:Show();
    Magnifier:SetFrameLevel(card.ModelScene:GetFrameLevel() + 5);

    Magnifier:SetScript("OnEnter", function()
        card:LockHighlight();
    end);

    Magnifier:SetScript("OnLeave", function()
        card:UnlockHighlight();
        if not card:IsMouseOver() then
            Magnifier:Hide();
        end
    end);

    Magnifier:SetScript("OnClick", function()
        if itemID then
            local link = "item:"..itemID;
            if not InCombatLockdown() then
                HideUIPanel(PVEFrame);
                DressUpLink(link);
            end
        end
    end);
end


local function ModifyCard_TransmogSet(self)
    local itemInfo = self.itemInfo;
    local transmogSetID = itemInfo.transmogSetID;
    local sources = transmogSetID and C_TransmogSets.GetAllSourceIDs(transmogSetID);
    local itemModifiedAppearanceID = sources and #sources == 1 and sources[1];
    local itemID = itemModifiedAppearanceID and C_TransmogCollection.GetSourceItemID(itemModifiedAppearanceID);

    local OnEnter = function()
        if itemID then
            SetupMagnifierForCard(self, itemID);

            local tooltip = GameTooltip;
            tooltip:SetOwner(self, "ANCHOR_RIGHT");
            --tooltip:SetItemByID(itemID);
            local tooltipInfo = {
                getterName = "GetItemByID",
                getterArgs = { itemID },

                linePreCall = function(tooltip, lineData)
                    --if lineData.type ~= 0 then    --debug
                    --    print(lineData.type, lineData.leftText)
                    --end
                    if lineData.type == Enum.TooltipDataLineType.ItemName or lineData.type == Enum.TooltipDataLineType.EquipSlot then
                        return false
                    else
                        return true
                    end
                end,

                tooltipPostCall = function(tooltip)
                    if C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(itemModifiedAppearanceID) then
                        GameTooltip_AddErrorLine(tooltip, ERR_COSMETIC_KNOWN);
                    else
                        tooltip:AddLine(TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN, 0.533, 0.667, 1.000, true);
                    end

                    if itemInfo.description then
                        GameTooltip_AddBlankLineToTooltip(tooltip);
                        GameTooltip_AddNormalLine(tooltip, itemInfo.description);
                        local isOwned = (itemInfo.status == Enum.AccountStoreItemStatus.Owned) or (itemInfo.status == Enum.AccountStoreItemStatus.Refundable);
                        if not isOwned and itemInfo.nonrefundable then
                            GameTooltip_AddBlankLineToTooltip(tooltip);
                            GameTooltip_AddErrorLine(tooltip, ACCOUNT_STORE_NONREFUNDABLE_TOOLTIP);
                        end
                    end
                end
            };
            tooltip:ProcessInfo(tooltipInfo);
        else
            AccountStoreBaseCardMixin.OnEnter(self);
        end
    end
    self:SetScript("OnEnter", OnEnter);
    self.ModelScene:SetScript("OnEnter", function()
		OnEnter();
		self:LockHighlight();
	end);

    local function OnLeave()
        AccountStoreBaseCardMixin.OnLeave(self);
        if (not self:IsMouseOver()) and Magnifier:GetParent() == self then
            Magnifier:Hide();
        end
    end
    self:SetScript("OnLeave", OnLeave);
    self.ModelScene:SetScript("OnLeave", function()
		OnLeave();
		self:UnlockHighlight();
	end);

    --Change default facing
    if itemInfo.transmogSetID then
        local classID, subClassID = select(6, C_Item.GetItemInfoInstant(itemID));
        if classID == 2 then
            local actor = GetTransmogCardModelSceneActor(self);
            if actor then
                actor:SetYaw(0)
            end
        end
    end

    if self:IsMouseOver() then
        OnEnter();
    end
end

local function ModifyLayout()
    --Increase header height to fit our checkbox
    local MainFrame = AccountStoreFrame;


    Magnifier = CreateFrame("Button", nil, MainFrame);
    Magnifier:SetSize(24, 24);
    Magnifier:SetPoint("TOP", MainFrame, "TOP", 0, 0);
    local atlas = "communities-icon-searchmagnifyingglass";
    Magnifier:SetNormalAtlas(atlas);
    Magnifier:SetHighlightAtlas(atlas, "ADD");
    Magnifier:Hide();


    local INSET_TOP_OFFSET = -50;
    MainFrame.LeftInset:SetPoint("TOPLEFT", 4, INSET_TOP_OFFSET);
    MainFrame.RightInset:SetPoint("TOPRIGHT", -6, INSET_TOP_OFFSET);
    MainFrame.CategoryList:SetPoint("TOPLEFT", 12, INSET_TOP_OFFSET - 8);
    MainFrame.StoreDisplay:SetPoint("TOPLEFT", MainFrame.CategoryList, "TOPRIGHT", 28 - 12, 4);


    --CategoryList ScrollFrame Behavior
    local highlightWidth = 170;
    MainFrame.CategoryList:SetWidth(174);    --162
    local view = MainFrame.CategoryList.ScrollBox:GetView();
    view:SetPadding(4, 0, 0, 0, 0, 0);
    MainFrame.CategoryList.ScrollBar:SetHideIfUnscrollable(true);
    MainFrame.CategoryList.SelectionHighlight:SetWidth(highlightWidth);

    view:SetElementInitializer("AccountStoreCategoryTemplate", function(button, elementData)
        button:SetCategory(elementData.categoryID);
        --
        --button:SetWidth(192);
        if not button.PlumberItemCount then
            local hl = button:GetHighlightTexture();
            hl:SetWidth(highlightWidth);

            local textOffsetY = 3;

            button.PlumberItemCount = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
            button.PlumberItemCount:SetPoint("RIGHT", button, "RIGHT", -12, textOffsetY);
            button.PlumberItemCount:SetJustifyH("RIGHT");
            button.PlumberItemCount:SetTextColor(0.851, 0.710, 0.435);

            button.Text:SetPoint("LEFT", 36, textOffsetY);
        end

        local count = DataProvider:GetCategoryNumUncollected(elementData.categoryID);
        if count > 0 and HIDE_COLLECTED then
            button.PlumberItemCount:SetText(count);
        else
            button.PlumberItemCount:SetText(nil);
        end
    end);

    MainFrame.CategoryList:OnStoreFrontSet(Constants.AccountStoreConsts.PlunderstormStoreFrontID);
    --Increase frame height so we don't need to scroll the category
    MainFrame:SetHeight(568);   --537


    --Store Display / ItemRack
    hooksecurefunc(MainFrame.StoreDisplay, "SetPage", function(f, page)
        local rack = f.currentItemRack;
        if f.categoryID and rack then
            --print(rack.maxCards)
            --AccountStoreBaseCardMixin:OnEnter
            local categoryType = DataProvider:GetCategoryType(f.categoryID);
            local modifyFunc;

            if categoryType == Enum.AccountStoreCategoryType.TransmogSet then
                modifyFunc = ModifyCard_TransmogSet;
            end

            if modifyFunc then
                C_Timer.After(0, function()
                    local pool = rack.cardPool;
                    for obj in pool:EnumerateActive() do
                        modifyFunc(obj);
                    end
                end)
            end
        end
    end);


    --Default to naked
    Enum.AccountStoreItemFlag.DisplayDefaultArmor = 256;


    local Notification = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    Notification:Hide();
    Notification:SetWidth(524);
    Notification:SetPoint("CENTER", MainFrame.StoreDisplay, "CENTER", 0, 24);
    Notification:SetJustifyH("CENTER");


    --Add Checkbox to show uncollected only
    local Checkbox = CreateFrame("Frame", nil, MainFrame, "ResizeCheckButtonTemplate");
    Checkbox:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", -36, -24);
    Checkbox.labelFont = "GameFontNormal";
    Checkbox.disabledLabelFont = "GameFontDisable";
    Checkbox:UpdateLabelFont();
    Checkbox:SetLabelText(AUCTION_HOUSE_FILTER_UNCOLLECTED_ONLY);
    Checkbox:SetFrameLevel(MainFrame.NineSlice:GetFrameLevel() + 1);
    local labelWidth = Checkbox.Label:GetWrappedWidth() + 2;
    Checkbox.Button:SetHitRectInsets(0, -labelWidth, 0, 0);

    local function Checkbox_Toggle(state)
        if state then
            C_AccountStore.GetCategoryItems = NewGetItems;
        else
            C_AccountStore.GetCategoryItems = OriginalGetItems;
        end
        addon.SetDBValue("Plunderstore_HideCollected", state);
        HIDE_COLLECTED = state;

        local categoryID = DataProvider:GetCurrentCategoryID();
        MainFrame.StoreDisplay.categoryID = -1;

        local categories = DataProvider:GetCategoryList(HIDE_COLLECTED);
        local dataProvider = CreateDataProviderWithAssignedKey(categories, "categoryID");
	    MainFrame.CategoryList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
        MainFrame.CategoryList.SelectionHighlight:Hide();
        EventRegistry:TriggerEvent("AccountStore.CategorySelected", categoryID);

        if #categories > 0 then
            MainFrame.StoreDisplay.currentItemRack:Show();
            Notification:Hide();
        else
            MainFrame.StoreDisplay.currentItemRack:Hide();
            Notification:SetText(L["Store Item Fully Collected"]);
            Notification:Show();
        end
    end
    Checkbox:SetCallback(Checkbox_Toggle);

    local initialState = addon.GetDBBool("Plunderstore_HideCollected");
    local isUserInput = true;
    Checkbox:SetControlChecked(initialState, isUserInput);


    local EventListener = CreateFrame("Frame", nil, MainFrame);

    local function EventListener_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.2 then
            self.t = 0;
            DataProvider.categoryData = nil;
            Checkbox_Toggle(addon.GetDBBool("Plunderstore_HideCollected"));
        end
    end

    function EventListener:RequestUpdate()
        self.t = 0;
        self:SetScript("OnUpdate", EventListener_OnUpdate);
    end

    EventListener:SetScript("OnEvent", function(event)
        if event == "ACCOUNT_STORE_ITEM_INFO_UPDATED" then
            EventListener:RequestUpdate();
        end
    end);
    EventListener:RegisterEvent("ACCOUNT_STORE_ITEM_INFO_UPDATED");


    --Change currency display to show token needed to buy all item
    MainFrame.StoreDisplay.Footer.CurrencyAvailable:SetScript("OnEnter", function(onEnterSelf)
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(onEnterSelf, "ANCHOR_RIGHT");
		local accountStoreCurrencyID = C_AccountStore.GetCurrencyIDForStore(Constants.AccountStoreConsts.PlunderstormStoreFrontID);
		if accountStoreCurrencyID then
			AccountStoreUtil.AddCurrencyTotalTooltip(tooltip, accountStoreCurrencyID);
            local currencyInfo = C_AccountStore.GetCurrencyInfo(accountStoreCurrencyID);
            local ownedAmount = currencyInfo and currencyInfo.amount;
            local totalPrice = DataProvider:GetFullPurchasePrice();
            local deficit = totalPrice - ownedAmount;
            if deficit > 0 then
                tooltip:AddLine(" ");
                tooltip:AddLine(string.format(L["Store Full Purchase Price Format"], BreakUpLargeNumbers(deficit)), 1, 0.82, 0, true);
            end
			tooltip:Show();
		end
	end);
end


do
    local FRAME_MODIFIED = false;
    local DummyOwner = {};
    local function Callback(_, state)
        if state and not FRAME_MODIFIED then
            FRAME_MODIFIED = true;
            EventRegistry:UnregisterCallback("AccountStore.ShownState", DummyOwner);
            ModifyLayout();
        end
    end


    local function EnableModule(state)
        if state then
            if not FRAME_MODIFIED then
                EventRegistry:RegisterCallback("AccountStore.ShownState", Callback, DummyOwner);
            end
        else
            EventRegistry:UnregisterCallback("AccountStore.ShownState", DummyOwner);
        end
    end

    local moduleData = {
        name = addon.L["ModuleName Plunderstore"],
        dbKey = "Plunderstore",
        description = addon.L["ModuleDescription Plunderstore"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1165,
        moduleAddedTime = 1737020000,
    };

    addon.ControlCenter:AddModule(moduleData);
end