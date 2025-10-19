local _, addon = ...
local API = addon.API;
local MerchantUIUtil = addon.MerchantUIUtil;
local DataProvider = MerchantUIUtil.DataProvider;


local CreateFrame = CreateFrame;


local MainFrame = CreateFrame("Frame", nil, UIParent);
MainFrame:Hide();

local MerchantUI_Load;


local Constants = {
    ItemListButtonWidth = 336,
    ItemListButtonHeight = 48,
    ListSubheaderHeight = 24,

    FrameWidth = 368,
    HeaderHeight = 96,
    FooterHeight = 96,
};


local EL = CreateFrame("Frame");
do
    EL.watchedInteractionType = Enum.PlayerInteractionType.Merchant;
    EL.blizzardMethods = {
        "MerchantFrame_MerchantShow", "MerchantFrame_MerchantClosed",
    };

    function EL:EnableModule(state)
        if state then
            self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW");
            self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE");
            self:SetScript("OnEvent", self.OnEvent);

            MerchantFrame:SetScale(0.001);
            MerchantFrame:UnregisterAllEvents();
        else
            self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW");
            self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE");
            self:HideMerchantUI();

            MerchantFrame:SetScale(1);
            MerchantFrame:RegisterEvent("MERCHANT_UPDATE");
            MerchantFrame:RegisterEvent("GUILDBANK_UPDATE_MONEY");
            MerchantFrame:RegisterEvent("HEIRLOOMS_UPDATED");
            MerchantFrame:RegisterEvent("BAG_UPDATE");
            MerchantFrame:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL");
            MerchantFrame:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player");
        end
    end

    function EL:OnEvent(event, ...)
        if event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
            local interactionType = ...
            if interactionType == self.watchedInteractionType then
                self:ShowMerchantUI();
            end
        elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
            local interactionType = ...
            if interactionType == self.watchedInteractionType then
                self:HideMerchantUI();
            end
        end
    end

    function EL:ShowMerchantUI()
        if MerchantUI_Load then
            MerchantUI_Load();
            MerchantUI_Load = nil;
        end
        MainFrame:Show();
        MainFrame:UpdateAll();
    end

    function EL:HideMerchantUI()
        if MainFrame then
            MainFrame:Hide();
        end
    end
end


local ItemListButton = {};
do
    local C_Item_GetItemInfo = C_Item.GetItemInfo;
    local BreakUpLargeNumbers = BreakUpLargeNumbers;

    function ItemListButton:OnEnter()
        MainFrame:HighlightItemListButton(self);
        self:ShowTooltip();
    end

    function ItemListButton:ShowTooltip()
        local tooltip = GameTooltip;
        tooltip:ClearHandlerInfo();
        tooltip:SetOwner(self, "ANCHOR_RIGHT", 4, 0);
        tooltip:SetMerchantItem(self.itemIndex);
        tooltip:Show();

        --Cost Info
        local merchantItemInfo = DataProvider:GetItemInfo(self.itemIndex);
        if merchantItemInfo.price > 0 or merchantItemInfo.hasExtendedCost then
            local tooltipInfo = API.CreateAppendTooltipInfo();

            if merchantItemInfo.price > 0 then
                local fontHeight = 14;
                --local lineText = C_CurrencyInfo.GetCoinTextureString(merchantItemInfo.price, fontHeight);
                local lineText = API.GenerateCoinTextureString(merchantItemInfo.price, fontHeight);
                tooltipInfo:AddLine(lineText, 1, 1, 1, false);
            end

            if merchantItemInfo.hasExtendedCost then
                local costInfo = DataProvider:GetMerchantItemCost(self.itemIndex);
                if costInfo then
                    local textIconFormat = "%s |T%s:14:14|t";
                    for i, v in ipairs(costInfo) do
                        --v (table): itemValue, itemTexture, itemLink
                        tooltipInfo:AddLine(textIconFormat:format(BreakUpLargeNumbers(v[1]), v[2]), 1, 1, 1, false);
                    end
                end
            end

            --debug
            local function AddLabelAndValue(label, value)
                tooltipInfo:AddLine(string.format("%s: %s", label, tostring(value)), 1, 1, 1, false);
            end

            tooltipInfo:AddLine(" ");
            AddLabelAndValue("Index", self.itemIndex);
            AddLabelAndValue("ItemID", self.itemInfo.itemID);
            if self.link then
                local itemID, creationContext = C_Item.GetItemCreationContext(self.link);
                if creationContext and creationContext ~= "" then
                    AddLabelAndValue("CreationContext", creationContext);
                end

                if C_Item.IsItemSpecificToPlayerClass(self.link) then
                    AddLabelAndValue("IsItemSpecificToPlayerClass", true);
                end

                if C_Item.IsCosmeticItem(self.link) then
                    AddLabelAndValue("IsCosmeticItem", true);
                end

                local transmogSetID = C_Item.GetItemLearnTransmogSet(self.link);
                if transmogSetID then
                    AddLabelAndValue("TransmogSetID", transmogSetID);
                end

                --[[
                local _, _, unitClassID = UnitClass("player");
                local specIndex = C_SpecializationInfo.GetSpecialization() or 1;
                local specID = C_SpecializationInfo.GetSpecializationInfo(specIndex);
                if C_Item.DoesItemContainSpec(self.link, unitClassID, specID) then  --useless?
                    tooltipInfo:AddLine("DoesItemContainSpec: True", 1, 1, 1, false);
                end
                --]]

            end

            API.DisplayTooltipInfoOnTooltip(tooltip, tooltipInfo);
        end
    end

    function ItemListButton:OnLeave()
        MainFrame:HighlightItemListButton();
        GameTooltip:Hide();
    end

    function ItemListButton:OnClick(button)

    end

    function ItemListButton:OnLoad()
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnClick", self.OnClick);
    end

    function ItemListButton:ClearData()
        self.quality = nil;
        self.link = nil;
        self.itemInfo = nil;
        self.dataInstanceID = nil;
        self.hasRestrictions = nil;
    end

    function ItemListButton:UpdateItemLink()
        self.link = DataProvider:GetMerchantItemLink(self.itemIndex);
        if self.link then
            return true
        else
            MainFrame:RegisterForQualityUpdates();
            return false
        end
    end

    function ItemListButton:UpdateQualityColor()
        if self.quality then return end;

        local quality = self.link and select(3, C_Item_GetItemInfo(self.link)) or nil;
        self.quality = quality;

        local r, g, b;
        if quality then
            r, g, b = DataProvider:GetQualityColor(quality);
        else
            r, g, b = 0.5, 0.5, 0.5;
            MainFrame:RegisterForQualityUpdates();
        end
        self.Label:SetTextColor(r, g, b);

        return quality ~= nil
    end

    function ItemListButton:UpdateRetrievableData()
        if not self.link then
            self:UpdateItemLink();
        end

        if not self.quality then
            self:UpdateQualityColor();
        end
    end

    function ItemListButton:UpdateTooltipInfo()
        self.dataInstanceID = nil;
        self.dataInstanceID, self.hasRestrictions = DataProvider:GetMerchantItemRestrictions(self.itemIndex);
        if self.hasRestrictions then    --self.isPurchasable 
            self.RightIcon:SetTexture("Interface/AddOns/Plumber/Art/MerchantUI/RedAlert.png");
            self.RightIcon:Show();
        else
            self.RightIcon:Hide();
        end
    end

    function ItemListButton:SetDimmed(isDimmed)
        if isDimmed ~= self.isDimmed then
            self.isDimmed = isDimmed;
            if isDimmed then
                self.Icon:SetAlpha(0.5);
                self.Label:SetAlpha(0.6);
            else
                self.Icon:SetAlpha(1);
                self.Label:SetAlpha(1);
            end
        end
    end

    function ItemListButton:RefreshItem()
        local index = self.itemIndex;
        if index then
            local info = DataProvider:GetItemInfo(index);
            if info then
                --price, stackCount, numAvailable, isPurchasable, isUsable, spellID, isQuestStartItem

                if info.currencyID then
                    info.name, info.texture = API.GetCurrencyContainerInfo(info.currencyID, info.numAvailable, info.name, info.texture);
                end

                self.Label:SetText(info.name);
                self.Icon:SetTexture(info.texture);
                self.link = info.link;

                local canAfford = DataProvider:CanAffordMerchantItem(index);
                local isPurchasable = info.isPurchasable;
                self.isPurchasable = isPurchasable;

                if isPurchasable then
                    self.Icon:SetVertexColor(1, 1, 1);
                else
                    self.Icon:SetVertexColor(1, 0.125, 0.125);
                end

                if info.hasExtendedCost then
                    
                end

                self.itemType = self.itemInfo and self.itemInfo.itemType;
                local collectState;
                if self.itemType then
                    collectState = MerchantUIUtil.IsItemCollected(self.itemInfo.itemID, self.itemType)
                end

                local isDimmed = false;
                local needUpdateFromTooltipInfo = true;

                if collectState == true then
                    needUpdateFromTooltipInfo = false;
                    isDimmed = true;
                    self.RightIcon:SetTexture("Interface/AddOns/Plumber/Art/MerchantUI/GreenCheckmark.png");
                    self.RightIcon:Show();
                elseif collectState == false then

                else

                end

                self:SetDimmed(isDimmed);
                self:UpdateRetrievableData();

                if needUpdateFromTooltipInfo then
                    self:UpdateTooltipInfo();
                end
            end
        else
            self:Hide();
        end
    end
end


local SubheaderFrameMixin = {};
do  --SubheaderFrameMixin
    function SubheaderFrameMixin:OnEnter()
        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT", 4, 0);
        local className = C_Item.GetItemClassInfo(self.classID);
        local subClassName = C_Item.GetItemSubClassInfo(self.classID, self.subClassID);
        tooltip:SetText(string.format("%s: %s", self.classID, className), 1, 1, 1);
        tooltip:AddLine(string.format("%s: %s", self.subClassID, subClassName), 1, 1, 1);
        tooltip:Show();
    end

    function SubheaderFrameMixin:OnLeave()
        GameTooltip:Hide();
    end
end


do  --MerchantUI
    local MerchantUIMixin = {};

    function MerchantUIMixin:UpdateAll()
        self:UpdateBuyItems();
    end

    function MerchantUIMixin:UpdateRetrievableData()
        self.ScrollView:CallObjectMethod("ItemListButton", "UpdateRetrievableData");
    end

    function MerchantUIMixin:UpdateItemByDataInstanceID(dataInstanceID)
        self.ScrollView:ProcessActiveObjects("ItemListButton", function(obj)
            if obj.dataInstanceID == dataInstanceID then
                obj:UpdateTooltipInfo();
            end
        end);
    end

    function MerchantUIMixin:UpdateBuyItems()
        self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");

        local ScrollView = self.ScrollView;
        ScrollView:ReleaseAllObjects();

        local list = DataProvider:GetSortedBuyList()

        if #list > 0 then
            local content = {};
            local n = 0;
            local gap = 0;
            local paddingV = 4;
            local buttonHeight = Constants.ItemListButtonHeight;
            local subheaderHeight = Constants.ItemListButtonHeight;
            local offsetX = -16;
            local offsetY = paddingV;

            local top, bottom;

            for i, v in ipairs(list) do
                n = n + 1;
                top = offsetY;

                if v.isSubheader then
                    top = top;
                    bottom = offsetY + subheaderHeight + gap;
                    content[n] = {
                        templateKey = "Subheader",
                        setupFunc = function(obj)
                            obj.Label:SetText(v.text);
                            obj.classID = v.classID;
                            obj.subClassID = v.subClassID;
                        end,
                        top = top,
                        bottom = bottom,
                        offsetX = offsetX,
                    };
                else
                    bottom = offsetY + buttonHeight + gap;
                    content[n] = {
                        templateKey = "ItemListButton",
                        setupFunc = function(obj)
                            obj.itemIndex = v.itemIndex;
                            obj.itemInfo = v;
                            obj:RefreshItem();
                        end,
                        top = top,
                        bottom = bottom,
                        offsetX = offsetX,
                    };
                end

                offsetY = bottom;
            end

            local retainPosition = true;
            ScrollView:SetContent(content, retainPosition);
        else
            ScrollView:SetContent({});
        end
    end

    function MerchantUIMixin:RegisterForQualityUpdates()
        if not self.qualityUpdateRegistered then
            self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
        end
    end

    function MerchantUIMixin:UnregisterForQualityUpdates()
        if self.qualityUpdateRegistered then
            self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
        end
    end

    function MerchantUIMixin:OnShow()
        self:RegisterEvent("MERCHANT_UPDATE");
        self:RegisterEvent("TOOLTIP_DATA_UPDATE");
    end

    function MerchantUIMixin:OnHide()
        self.ScrollView:SetContent(nil);
        self:UnregisterForQualityUpdates();
        self:UnregisterEvent("MERCHANT_UPDATE");
        self:UnregisterEvent("TOOLTIP_DATA_UPDATE");
        self:HighlightItemListButton(nil);
    end

    function MerchantUIMixin:OnEvent(event, ...)
        if event == "MERCHANT_UPDATE" then
            self:UpdateAll();
            print(event);
        elseif event == "GET_ITEM_INFO_RECEIVED" then
            self:UnregisterForQualityUpdates();
            self:UpdateRetrievableData();
            print(event);
        elseif event == "TOOLTIP_DATA_UPDATE" then
            local dataInstanceID = ...
            if dataInstanceID then
                self:UpdateItemByDataInstanceID(dataInstanceID);
            end
        end
    end

    function MerchantUIMixin:HighlightItemListButton(button)
        local HL = self.ItemListButtonHighlight;
        HL:Hide();
        HL:ClearAllPoints();
        if button then
            HL:SetParent(button);
            local offset = 4;
            HL:SetPoint("TOPLEFT", button, "TOPLEFT", 0, offset);
            HL:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, -offset);
            HL:Show();
        end
    end

    function MerchantUI_Load()
        local f = CreateFrame("Frame", nil, UIParent);
        MainFrame = f;
        f:Hide();
        API.Mixin(f, MerchantUIMixin);
        --f:SetSize(336, 444);
        f:SetPoint("LEFT", UIParent, "LEFT", 0, 0);
        f:SetSize(Constants.FrameWidth, UIParent:GetHeight());
        f:SetFrameStrata("HIGH");
        f:SetToplevel(true);
        f:EnableMouse(true);
        f:SetScript("OnEvent", f.OnEvent);
        f:SetScript("OnShow", f.OnShow);
        f:SetScript("OnHide", f.OnHide);


        local Background = f:CreateTexture(nil, "BACKGROUND");
        Background:SetAllPoints(true);
        Background:SetColorTexture(0, 0, 0, 0.9);


        local ScrollView = API.CreateScrollView(f);
        f.ScrollView = ScrollView;
        ScrollView:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -Constants.HeaderHeight);
        ScrollView:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, Constants.FooterHeight);
        ScrollView:OnSizeChanged();
        ScrollView:SetStepSize(Constants.ItemListButtonHeight * 2);
        ScrollView:SetBottomOvershoot(Constants.ItemListButtonHeight);
        ScrollView:EnableMouseBlocker(true);


        local HL = CreateFrame("Frame", nil, ScrollView);
        f.ItemListButtonHighlight = HL;
        HL:Hide();
        HL:SetUsingParentLevel(true);
        HL.Background = HL:CreateTexture(nil, "BACKGROUND", nil, 1);
        HL.Background:SetAllPoints(true);
        HL.Background:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/HorizontalButtonHighlight");
        HL.Background:SetBlendMode("ADD");
        HL.Background:SetVertexColor(0.25, 0.25, 0.25);


        local function ItemListButton_Create()
            local obj = CreateFrame("Button", nil, ScrollView, "PlumberMerchantUIListButtonTemplate");
            API.Mixin(obj, ItemListButton);
            obj:SetSize(Constants.ItemListButtonWidth, Constants.ItemListButtonHeight);
            obj:OnLoad();
            return obj
        end

        local function ItemListButton_OnAcquired(obj)
            obj.dataInstanceID = nil;
            obj.RightIcon:Hide();
        end

        local function ItemListButton_OnRemoved(obj)
            obj:ClearData();
        end

        ScrollView:AddTemplate("ItemListButton", ItemListButton_Create, ItemListButton_OnAcquired, ItemListButton_OnRemoved);


        local function Subheader_Create()
            local obj = CreateFrame("Frame", nil, ScrollView);
            obj:SetSize(Constants.ItemListButtonWidth, Constants.ItemListButtonHeight);

            local fs = obj:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            fs:SetSpacing(2);
            obj.Label = fs;
            fs:SetSize(208, 16);
            fs:SetTextColor(0.8, 0.8, 0.8);
            fs:SetJustifyH("CENTER");
            fs:SetPoint("CENTER", obj, "CENTER", 0, -4);

            API.Mixin(obj, SubheaderFrameMixin);
            obj:SetScript("OnEnter", obj.OnEnter);
            obj:SetScript("OnLeave", obj.OnLeave);

            return obj
        end

        ScrollView:AddTemplate("Subheader", Subheader_Create);
    end
end


EL:EnableModule(true);  --debug