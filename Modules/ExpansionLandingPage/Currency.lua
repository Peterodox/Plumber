local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;
local LandingPageUtil = addon.LandingPageUtil;


local ipairs = ipairs;
local pairs = pairs;
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
local GetItemIconByID = C_Item.GetItemIconByID;
local GetItemCount = C_Item.GetItemCount;
local GetItemNameByID = C_Item.GetItemNameByID;
local BreakUpLargeNumbers = BreakUpLargeNumbers;


local BUTTON_WIDTH, BUTTON_HEIGHT = 240, 24;


local DefaultResources = {
    {currencyID = 3028},    --Restored Coffer Key
    {itemID = 236096, isMinor = false},   --Coffer Key Shard
    {itemID = 235897},      --Radiant Echo
    {currencyID = 3226},    --Market Research
    {currencyID = 2815},    --Resonance Crystals
    {currencyID = 3056},    --Kej
    --{currencyID = 3055},      --Mereldar Derby Mark
    {currencyID = 2803},    --Undercoin
};

local CurrencyButtonMixin = {};
do
    function CurrencyButtonMixin:SetCurrency(currencyID, isMinor)
        self.currencyID = currencyID;
        self.itemID = nil;
        self.buttonDitry = true;
        self:Refresh();
        self:SetShownAsMinor(isMinor);
    end

    function CurrencyButtonMixin:SetItem(itemID, isMinor)
        self.currencyID = nil;
        self.itemID = itemID;
        self.buttonDitry = true;
        self:Refresh();
        self:SetShownAsMinor(isMinor);
    end

    function CurrencyButtonMixin:Refresh()
        local quantity;

        if self.currencyID then
            local info = GetCurrencyInfo(self.currencyID);
            if info then
                quantity = info.quantity;
                if self.buttonDitry then
                    self.buttonDitry = nil;
                    self.Name:SetText(info.name);
                    self.Icon:SetTexture(info.iconFileID);
                end
            else
                return false
            end
        elseif self.itemID then
            quantity = GetItemCount(self.itemID, true, false, true, true);
            if self.buttonDitry then
                self.buttonDitry = nil;
                self.Icon:SetTexture(GetItemIconByID(self.itemID));
                local itemName = GetItemNameByID(self.itemID);
                if itemName then
                    self.Name:SetText(itemName);
                else
                    CallbackRegistry:LoadItem(self.itemID, function(itemID)
                        if self.itemID == itemID then
                            self.Name:SetText(GetItemNameByID(self.itemID));
                            self.Icon:SetTexture(GetItemIconByID(self.itemID));
                        end
                    end);
                end
            end
        else
            return false
        end

        if quantity then
            if quantity > 0 then
                self.Name:SetTextColor(0.92, 0.92, 0.92);
                self.Count:SetTextColor(0.92, 0.92, 0.92);
                self.Count:SetText(BreakUpLargeNumbers(quantity));
            else
                self.Name:SetTextColor(0.5, 0.5, 0.5);
                self.Count:SetTextColor(0.5, 0.5, 0.5);
                self.Count:SetText(0);
            end
            return true
        else
            return false
        end
    end

    function CurrencyButtonMixin:SetShownAsMinor(isMinor)
        self.Name:SetPoint("LEFT", self, "LEFT", (isMinor and 22) or 8, 0);
    end

    function CurrencyButtonMixin:OnEnter()
        GameTooltip:SetOwner(self.Icon, "ANCHOR_RIGHT", 0, 0);
        if self.currencyID then
            GameTooltip:SetCurrencyByID(self.currencyID);
        elseif self.itemID then
            GameTooltip:SetItemByID(self.itemID);
        end
    end

    function CurrencyButtonMixin:OnLeave()
        GameTooltip:Hide();
    end
end

local function CreateButton(parent)
    local f = CreateFrame("Button", nil, parent);
    f:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);
    API.Mixin(f, CurrencyButtonMixin);

    f.Icon = f:CreateTexture(nil, "OVERLAY");
    f.Icon:SetSize(20, 20);
    f.Icon:SetPoint("RIGHT", f, "RIGHT", -8, 0);

    f.Count = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    f.Count:SetPoint("RIGHT", f, "RIGHT", -32, 0);
    f.Count:SetJustifyH("RIGHT");
    f.Count:SetTextColor(1, 1, 1);
    f.Count:SetText("0");

    f.Name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    f.Name:SetPoint("LEFT", f, "LEFT", 8, 0);
    f.Name:SetPoint("RIGHT", f.Count, "LEFT", -20, 0);
    f.Name:SetJustifyH("LEFT");
    f.Name:SetTextColor(1, 1, 1);
    f.Name:SetText("0/0");
    f.Name:SetMaxLines(1);

    f.Background = f:CreateTexture(nil, "BACKGROUND");
    f.Background:SetAllPoints(true);

    f:SetScript("OnEnter", f.OnEnter);
    f:SetScript("OnLeave", f.OnLeave);

    return f
end


local CurrencyListMixin = {};
do
    function CurrencyListMixin:Refresh()
        --This refresh everything
        --Individual currency update is driven by events

        local currencyXButton;
        local itemXButton;

        for _, button in ipairs(self.buttons) do
            button:Refresh();
            if button.currencyID then
                if not currencyXButton then
                    currencyXButton = {};
                end
                currencyXButton[button.currencyID] = button;
            elseif button.itemID then
                if not itemXButton then
                    itemXButton = {};
                end
                itemXButton[button.itemID] = button;
            end
        end

        local itemUpgradeButtons = LandingPageUtil.GetItemUpgradeButtons();
        if itemUpgradeButtons then
            for _, button in ipairs(itemUpgradeButtons) do
                button:Refresh();
                if not currencyXButton then
                    currencyXButton = {};
                end
                currencyXButton[button.currencyID] = button;
            end
        end

        self.currencyXButton = currencyXButton;
        self.itemXButton = itemXButton;

        if self:IsVisible() then
            if currencyXButton then
                self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
            end

            if itemXButton then
                self:RegisterEvent("BAG_UPDATE_DELAYED");
            end
        end
    end

    function CurrencyListMixin:GetActiveWidgets()
        local tbl = {};
        local n = 0;
        for _, button in ipairs(self.buttons) do
            if button.currencyID or button.itemID then
                n = n + 1;
                tbl[n] = button;
            end
        end
        return tbl
    end

    function CurrencyListMixin:OnShow()
        self:Refresh();
    end

    function CurrencyListMixin:OnHide()
        self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
        self:UnregisterEvent("BAG_UPDATE_DELAYED");
        self.currencyXButton = nil;
        self.itemXButton = nil;
    end

    function CurrencyListMixin:OnEvent(event, ...)
        if event == "CURRENCY_DISPLAY_UPDATE" then
            local currencyID = ...
            if self.currencyXButton then
                if self.currencyXButton[currencyID] then
                    self.currencyXButton[currencyID]:Refresh();
                end
            end
        elseif event == "BAG_UPDATE_DELAYED" then
            if self.itemXButton then
                for itemID, button in pairs(self.itemXButton) do
                    button:Refresh();
                end
            end
        end
    end
end


function LandingPageUtil.CreateCurrencyList(parent)
    local f = CreateFrame("Frame", nil, parent);
    API.Mixin(f, CurrencyListMixin);
    f:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);

    local buttons = {};
    local n = 0;
    local button;
    local visualOffsetY = 4;

    for _, v in ipairs(DefaultResources) do
        n = n + 1;
        button = CreateButton(f);
        buttons[n] = button;
        if v.currencyID then
            button:SetCurrency(v.currencyID, v.isMinor);
        elseif v.itemID then
            button:SetItem(v.itemID, v.isMinor);
        end
        button:SetPoint("TOP", f, "TOP", 0, visualOffsetY + (1 - n) * BUTTON_HEIGHT);
    end

    f.buttons = buttons;

    local height = n * BUTTON_HEIGHT;
    if n > 0 then
        f:SetHeight(height);
    end

    f:SetScript("OnShow", f.OnShow);
    f:SetScript("OnHide", f.OnHide);
    f:SetScript("OnEvent", f.OnEvent);

    return f, height
end