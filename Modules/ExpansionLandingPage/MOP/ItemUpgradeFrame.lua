local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;
local CreateButton = LandingPageUtil.CreateItemUpgradeButton;


local BUTTON_WIDTH, BUTTON_HEIGHT = 36, 40;
local ItemUpgradeFrame;


local ItemUpgradeFrameMixin = {};
do
    function ItemUpgradeFrameMixin:Refresh()
        for _, button in ipairs(self.buttons) do
            button:Refresh();
        end
    end

    function ItemUpgradeFrameMixin:GetActiveWidgets()
        return self.buttons
    end

    function LandingPageUtil.GetItemUpgradeButtons()
        if ItemUpgradeFrame then
            return ItemUpgradeFrame:GetActiveWidgets()
        end
    end
end


local Currencies = {
    395,    --Justice Points
    396,    --Valor Points
    Constants.CurrencyConsts.CLASSIC_HONOR_CURRENCY_ID,     --Honor 1901
    Constants.CurrencyConsts.CONQUEST_POINTS_CURRENCY_ID,   --Conquests 390
};

function LandingPageUtil.CreateItemUpgradeFrame(parent)
    if ItemUpgradeFrame then return ItemUpgradeFrame end;

    local f = CreateFrame("Frame", nil, parent);
    ItemUpgradeFrame = f;

    local n = 0;
    local buttons = {};

    local ItemUpgradeConstant = addon.ItemUpgradeConstant;
    local spanX = 4.5 * BUTTON_WIDTH;
    local offsetX = 0;

    for i, currencyID in ipairs(Currencies) do
        n = n + 1;
        local button = CreateButton(parent);
        buttons[n] = button;
        button:SetPoint("TOPLEFT", f, "TOPLEFT", offsetX, 0);
        offsetX = offsetX + BUTTON_WIDTH;
        if i == 2 then
            offsetX = offsetX + 0.5 * BUTTON_WIDTH;
        end
        button.currencyID = currencyID;
        button.displayedMax = 999;
    end

    local button = CreateButton(parent);
    table.insert(buttons, button);
    button:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
    button.currencyID = ItemUpgradeConstant.BaseCurrencyID;

    local width = spanX;
    local height = BUTTON_HEIGHT;

    f:SetSize(width, height);

    API.Mixin(f, ItemUpgradeFrameMixin);
    f.buttons = buttons;

    return f, height
end

