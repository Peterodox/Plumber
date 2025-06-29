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


function LandingPageUtil.CreateItemUpgradeFrame(parent)
    if ItemUpgradeFrame then return ItemUpgradeFrame end;

    local f = CreateFrame("Frame", nil, parent);
    ItemUpgradeFrame = f;

    local n = 0;
    local buttons = {};

    local ItemUpgradeConstant = addon.ItemUpgradeConstant;

    for i, currencyID in ipairs(ItemUpgradeConstant.Crests) do
        n = n + 1;
        local button = CreateButton(parent);
        buttons[n] = button;
        button:SetPoint("TOPRIGHT", f, "TOPRIGHT", (1 - i) * BUTTON_WIDTH, 0);
        button.currencyID = currencyID;
        button.displayedMax = 999;
    end

    local button = CreateButton(parent);
    table.insert(buttons, button);
    button:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
    button.currencyID = ItemUpgradeConstant.BaseCurrencyID;

    local width = 5.5 * BUTTON_WIDTH;
    local height = BUTTON_HEIGHT;

    f:SetSize(width, height);

    API.Mixin(f, ItemUpgradeFrameMixin);
    f.buttons = buttons;

    return f, height
end

