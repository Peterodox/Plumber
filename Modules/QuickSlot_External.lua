--Global API for 3rd-party devs

local _, addon = ...
local L = addon.L;
local API = addon.API;
local QuickSlot = addon.QuickSlot;
local GetSpellName = C_Spell.GetSpellName;


--[[--Usage
    --1. Create a ControllerMixin in your code

    ControllerMixin = {
        key = "key",                --Required, (String)    Used as the identifier of your module
        title = "Module Name",      --Optional, (String)    We will show this text next to the QuickSlot button when it is not being mouse-hovered
        showError = false,          --Optional, (Boolean)   If true, Display module registry errors (e.g. another 3rd-party module is using the same key) in the chat window
        spellcastType = 0,          --Optional, (Number)    This determines if we should show our radial cast bar on the button. 0:none  1:Cast  2:Channel
        developerInfo = "",         --Required, (String)    You need to explain this modules's functions. Users can find this info by right-clicking on the QuickSlot buttons
        buttons = {},               --Required, (Table)     Set up the functions of your buttons, see details below
    };

    ControllerMixin.buttons[1] = {
        actionType = "spell",       --Required, (String)    It can be "spell" or "item"
        itemID = itemID,            --          (Number)    Unnecessary if your actionType is "spell"
        spellID = spellID,          --          (Number)    Required if your actionType is "spell". If your action involves spellCasting, you need to set the correct spellID in order see our cast bar
        name = "Custom Name",       --Optional, (String)    Override the item or spell name
        icon = 134400,              --Optional, (Icon)      Override the default icon
        enabled = true,             --Optional, (Boolean)   Set the visual status of the button. If false, the button will appear dark
        onClickFunc = nil,          --Optional, (Function)  If you set a onClickFunc, clicking on the button will run this function instead of use or cast the spell
        tooltipLines = {},          --Optional, (Table)     Display GameTooltip on mouseover. tooltipLines = {line1Text, line2Text, ...}
    };


    --2. Register your ControllerMixin with our API "PlumberAPI_AddQuickSlotController(ControllerMixin)"
    ---- After this, 2 methods will be added to your ControllerMixin:
    ---- ControllerMixin:ShowQuickSlot(forceUpdate)         Used to show the QuickSlot. If you've changed the entries in your Mixin, "forceUpdate" needs to be True
    ---- ControllerMixin:HideQuickSlot()                    Calling this will hide the QuickSlot if it's currently displaying your module




    --Empty Mixin for you to copy

    local ControllerMixin = {
        key = "key",
        title = "Module Name",
        showError = false,
        spellcastType = 0,
        developerInfo = "",
        buttons = {},
    }

    local ButtonData = {
        actionType = "spell",
        itemID = itemID,
        spellID = spellID,
        name = nil,
        icon = nil,
        enabled = nil,
        onClickFunc = nil,
        tooltipLines = nil,
    }

    if PlumberAPI_AddQuickSlotController then
        PlumberAPI_AddQuickSlotController(ControllerMixin)
    end
--]]


--[[--Example
    local ExampleModule = {
        key = "QuickSlotExample01",
        spellcastType = 1,
        developerInfo = "Quick Slot Example.\nShow Hearthstone when you select a friendly unit.",
        buttons = {
            {actionType = "item", itemID = 6948, spellID = 8690},
        },
    };

    local EL = CreateFrame("Frame");
    EL:RegisterEvent("PLAYER_ENTERING_WORLD");
    EL:RegisterEvent("PLAYER_TARGET_CHANGED");
    EL:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_TARGET_CHANGED" then
            if UnitExists("target") and UnitIsFriend("player", "target") then
                ExampleModule:ShowQuickSlot();
            else
                ExampleModule:HideQuickSlot();
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            self:UnregisterEvent(event);
            self:RegisterEvent("PLAYER_TARGET_CHANGED");
            PlumberAPI_AddQuickSlotController(ExampleModule);
        end
    end);
--]]




local CustomControllers = {};
local ControllerMixin = {};

function ControllerMixin:ShowQuickSlot(forceUpdate)
    if forceUpdate then
        QuickSlot.buttonData = nil;
    else
        if QuickSlot.buttonData == self and QuickSlot:IsShown() and (not QuickSlot.isClosing) then
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