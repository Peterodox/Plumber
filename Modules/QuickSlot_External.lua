--Global API for 3rd-party devs

local _, addon = ...
local L = addon.L;
local API = addon.API;
local QuickSlot = addon.QuickSlot;
local GetSpellName = C_Spell.GetSpellName;


local CustomControllers = {};

local ControllerMixin = {};

do  --ControllerMixin
--[[
    ControllerMixin = {
        key = "key",
        title = "Module Name",
        showError = false,
        spellcastType = 0,      --1:Cast  2:Channel
        developerInfo = "What does this module do. Developed by Whom";
        buttons = {
            {actionType = "spell", spellID = 0, icon = 134400, name = "Custom Name", onClickFunc = Nop, enabled = true},
            {actionType = "item", itemID = 208067, spellID = 417645},
        },
    };
--]]

    function ControllerMixin:ShowQuickSlot(forceUpdate)
        if forceUpdate then
            QuickSlot.buttonData = nil;
        else
            if QuickSlot.buttonData == self and QuickSlot:IsShown() then
                return
            end
        end
        QuickSlot:SetButtonData(self);
        QuickSlot:ShowUI();
        QuickSlot:SetHeaderText(self.title, true);
        QuickSlot:SetDefaultHeaderText(self.title);
    end

    function ControllerMixin:HideQuickSlot()
        QuickSlot:RequestCloseUI(self.key);
    end
end

local function AddQuickSlotController(controller)
    local showError = controller.showError or false;

    if CustomControllers[controller] ~= nil then
        if showError then
            API.PrintMessage(L["QuickSlot Error 1"]);
        end
        return false
    end

    local valid = true;
    local requiredKeys = {
        "key", "buttons", "developerInfo",
    };

    for _, k in ipairs(requiredKeys) do
        if not controller[k] then
            valid = false;
            API.PrintMessage(L["QuickSlot Error 2"]:format(k));
        end
    end

    if not valid then return end;

    for c in pairs(CustomControllers) do
        if c.key == controller.key then
            API.PrintMessage(L["QuickSlot Error 3"]:format(controller.key));
            return false
        end
    end

    CustomControllers[controller] = true;
    API.Mixin(controller, ControllerMixin);
    controller.systemName = controller.key;

    for _, v in ipairs(controller.buttons) do
        if v.spellID then   --Cache
            GetSpellName(v.spellID);
        end
    end

    return true
end

PlumberAPI_AddQuickSlotController = AddQuickSlotController;


do
    --[[
    local TestModule = {
        key = "key",
        title = nil,
        showError = true,
        spellcastType = 1,
        developerInfo = "What does this module do. Developed by Whom",
        buttons = {
            {actionType = "spell", spellID = 2061, icon = nil, name = "Custom Name", onClickFunc = nil, enabled = true},
            {actionType = "item", itemID = 208067, spellID = 417645},
        },
    };

    PlumberAPI_AddQuickSlotController(TestModule);


    local EL = CreateFrame("Frame");
    EL:RegisterEvent("PLAYER_TARGET_CHANGED");
    EL:SetScript("OnEvent", function()
        if UnitExists("target") and UnitIsFriend("player", "target") then
            TestModule:ShowQuickSlot();
        else
            TestModule:HideQuickSlot();
        end
    end);
    --]]
end