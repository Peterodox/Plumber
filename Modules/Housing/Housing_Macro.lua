local _, addon = ...
local L = addon.L;
local API = addon.API;
local Housing = addon.Housing;


local IsInsideHouseOrPlot = C_Housing.IsInsideHouseOrPlot;
local IsOnNeighborhoodMap = C_Housing.IsOnNeighborhoodMap;


function IsInHousingZone()
    return IsInsideHouseOrPlot() or IsOnNeighborhoodMap()
end


local Flags = {};


do  --Teleport Home Macro    #plumber:home
    local COMMAND_HOME = "home";    --Teleport Home

    local function WriteFunc_home(body)
        local header = "#plumber:"..COMMAND_HOME;
        local icon = 7252953;
        local body = header.."\n/script if Plumber_TeleportHome then Plumber_TeleportHome() end";
        return body, icon
    end

    local function Generator_home()
        local name = L["Teleport Home"];
        local body, icon = WriteFunc_home();
        if not body then
            body = "#plumber:"..COMMAND_HOME;
            icon = 7252953;
        end
        return name, icon, body
    end

    function Housing.AcquireTeleportHomeMacro()
        return addon.AcquireCharacterMacro(COMMAND_HOME, Generator_home)
    end

    local TeleportHomeCommand = {
        command = COMMAND_HOME,
        name = L["PlumberMacro Housing"],
        modifyType = "Overwrite",

        events = {
            "HOUSE_PLOT_ENTERED",
            "HOUSE_PLOT_EXITED",
        },

        writeFunc = WriteFunc_home,
    };

    addon.CallbackRegistry:Register("DBLoaded", function()
        addon.AddPlumberMacro(TeleportHomeCommand);
    end);
end


do  --Toggle Torch Macro    #plumber:torch
    local COMMAND_TORCH = "torch";    --Teleport Home
    local GetUnitAuraBySpellID = C_UnitAuras.GetUnitAuraBySpellID;

    local ItemInfo = {
        name = "Cave Spelunker's Torch",
        itemID = 224552,
        spellID = 453163,
        icon = 135432,
        litIcon = 135432,
        unlitIcon = 135434,
    };

    function ItemInfo:LoadItemName()
        local _, name = C_ToyBox.GetToyInfo(self.itemID);
        if name then
            self.localizedName = name;
        end
    end
    ItemInfo:LoadItemName();

    function ItemInfo:GetItemName()
        return self.auraName or self.localizedName or self.name
    end

    local function ConditionFunc_torch()
        --Return Action:   true(use torch)   false(cancel torch)

        if IsInHousingZone() then
            local aura = GetUnitAuraBySpellID("player", ItemInfo.spellID);
            if aura then
                if not ItemInfo.auraName then
                    ItemInfo.auraName = aura.name;
                end
                return false
            else
                return true
            end
        else
            return true
        end
    end

    local function WriteFunc_torch(body)
        local header = "#plumber:"..COMMAND_TORCH;
        local icon;
        local body = header;
        if ConditionFunc_torch() then
            body = string.format("%s\n#showtooltip %s\n/use \"item:%s\"", body, ItemInfo:GetItemName(), ItemInfo.itemID);
            icon = ItemInfo.litIcon;
        else
            body = body.."\n/cancelaura "..(ItemInfo.auraName or ItemInfo.localizedName or ItemInfo.name);
            icon = ItemInfo.unlitIcon;
        end
        return body, icon
    end

    local function Generator_torch()
        local name = L["Toggle Torch"];
        local body, icon = WriteFunc_torch();
        if not body then
            body = "#plumber:"..COMMAND_TORCH;
            icon = ItemInfo.icon;
        end
        return name, icon, body
    end


    function Housing.AcquireTorchMacro()
        return addon.AcquireCharacterMacro(COMMAND_TORCH, Generator_torch)
    end

    local ToggleTorchCommand = {
        command = COMMAND_TORCH,
        name = L["PlumberMacro Torch"],
        modifyType = "Overwrite",
        conditionFunc = ConditionFunc_torch,
        events = {
            "HOUSE_PLOT_ENTERED",
            "HOUSE_PLOT_EXITED",
            "UNIT_AURA",
        },
        writeFunc = WriteFunc_torch,
    };

    addon.CallbackRegistry:Register("DBLoaded", function()
        ItemInfo:LoadItemName();
        addon.AddPlumberMacro(ToggleTorchCommand);
    end);
end


local function Blizzard_HousingDashboard_OnLoaded()
    if not Flags.TeleportToHouseButton then
        Flags.TeleportToHouseButton = true;

        if addon.IS_MIDNIGHT then return end;

        local TeleportButton = API.GetGlobalObject("HousingDashboardFrame.HouseInfoContent.ContentFrame.HouseUpgradeFrame.TeleportToHouseButton");
        if TeleportButton then
            TeleportButton:RegisterForDrag("LeftButton");

            TeleportButton:HookScript("OnDragStart", function(self)
                if TeleportButton.Icon then
                    TeleportButton.Icon:SetPoint("CENTER", 0, 0);
                end
                if (not Flags.macroEnabled) or InCombatLockdown() then return end;
                local macroID = Housing.AcquireTeleportHomeMacro();
                if macroID then
                    PickupMacro(macroID);
                end
            end);

            TeleportButton:HookScript("OnEnter", function(self)
                if (not Flags.macroEnabled) or InCombatLockdown() or (API.IsCharacterMarcoFull()) then return end;
                local tooltip = GameTooltip;
                if tooltip:IsShown() and tooltip:GetOwner() == self then
                    tooltip:AddLine(L["Instruction Drag To Action Bar"], 0.098, 1.000, 0.098, true);
                    tooltip:Show();
                end
            end);
        end
    end
end


local function EnableModule(state)
    state = true;   --Always ON

    Housing.RequestUpdateHouseInfo();
    if state then
        Flags.macroEnabled = true;
        local blizzardAddOnName = "Blizzard_HousingDashboard";
        if C_AddOns.IsAddOnLoaded(blizzardAddOnName) then
            Blizzard_HousingDashboard_OnLoaded();
        else
            EventUtil.ContinueOnAddOnLoaded(blizzardAddOnName, Blizzard_HousingDashboard_OnLoaded);
        end
    else
        Flags.macroEnabled = false;
    end
end

local moduleData = {
    name = addon.L["ModuleName Housing_Macro"],
    dbKey ="Housing_Macro",
    description = addon.L["ModuleDescription Housing_Macro"],
    toggleFunc = EnableModule,
    categoryID = 1,
    uiOrder = 1,
    moduleAddedTime = 1764600000,
    virtual = true,
    categoryKeys = {
        "Housing",
    },
    searchTags = {
        "Housing",
    },
};

addon.ControlCenter:AddModule(moduleData);