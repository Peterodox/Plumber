local _, addon = ...
local L = addon.L;
local API = addon.API;


local MODULE_ENABLED = false;
local CALLBACK_REGISTERED = false;


local Backups = {};

local ModifiedStaticPopupInfo = {
    CONFIRM_PURCHASE_NONREFUNDABLE_ITEM = {
        --Added a brief delay, make the warning text stand out

        text = L["CONFIRM_PURCHASE_NONREFUNDABLE_ITEM"],

        OnAcceptDelayExpired = function(dialog, data)
            dialog:GetButton1():SetText(YES);
        end,

        acceptDelay = 1.2,
    },


    ITEM_INTERACTION_CONFIRMATION_DELAYED = {
        --Reduce delay by half
        --Load after Blizzard_ItemInteractionUI
        acceptDelay = 2.5,
    },
};


local function ModifyDialogs()
    local StaticPopupDialogs = StaticPopupDialogs;
    local originalInfo;

    for which, info in pairs(ModifiedStaticPopupInfo) do
        originalInfo = StaticPopupDialogs[which];
        if originalInfo then
            if not Backups[which] then
                Backups[which] = {};
                for k, v in pairs(info) do
                    if originalInfo[k] ~= nil then
                        Backups[which][k] = originalInfo[k];
                    else
                        Backups[which][k] = "nil";
                    end
                end
            end

            for k, v in pairs(info) do
                originalInfo[k] = v;
            end
        end
    end
end

local function RestoreDialogs()
    local StaticPopupDialogs = StaticPopupDialogs;

    for which, info in pairs(Backups) do
        for k, v in pairs(info) do
            if v == "nil" then
                StaticPopupDialogs[which][k] = nil;
            else
                StaticPopupDialogs[which][k] = v;
            end
        end
    end
end

local function EnableModule(state)
    if state and not MODULE_ENABLED then
        MODULE_ENABLED = true;
        ModifyDialogs();
        if not CALLBACK_REGISTERED then
            CALLBACK_REGISTERED = true;
            EventUtil.ContinueOnAddOnLoaded("Blizzard_ItemInteractionUI", function()
                ModifyDialogs();
            end);
        end
    elseif (not state) and MODULE_ENABLED then
        MODULE_ENABLED = false;
        RestoreDialogs();
    end
end


do
    local moduleData = {
        name = addon.L["ModuleName StaticPopup_Confirm"],
        dbKey = "StaticPopup_Confirm",
        description = addon.L["ModuleDescription StaticPopup_Confirm"],
        toggleFunc = EnableModule,
        categoryID = 2,
        uiOrder = 30,
        moduleAddedTime = 1761400000,
    };

    addon.ControlCenter:AddModule(moduleData);
end