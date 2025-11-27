local _, addon = ...
local RaidCheck = addon.RaidCheck;


do
    local MODULE_ENABLED = false;

    local function EnableModule(state)
        if state and not MODULE_ENABLED then
            MODULE_ENABLED = true;
        elseif (not state) and MODULE_ENABLED then
            MODULE_ENABLED = false;
            RaidCheck.SelectorUI:HideUI(true);
        else
            return
        end

        RaidCheck.LocationTracker:Enable(state);
        RaidCheck.DifficultyAnnouncer:Enable(state);
    end

    local moduleData = {
        name = addon.L["ModuleName InstanceDifficulty"],
        dbKey = "InstanceDifficulty",
        description = addon.L["ModuleDescription InstanceDifficulty"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1200,
        moduleAddedTime = 1764200000,   --1763100000
        categoryKeys = {"Signature", "Instance"},
    };

    addon.ControlCenter:AddModule(moduleData);
end