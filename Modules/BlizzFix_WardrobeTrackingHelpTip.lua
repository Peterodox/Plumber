--Hide Interface Shortcuts Help Tip on the Appearance-Items tab

local _, addon = ...


local function EnableModule(state)
    if not state then return end;

    local index = LE_FRAME_TUTORIAL_WARDROBE_TRACKING_INTERFACE;
    if index then
        C_CVar.SetCVarBitfield("closedInfoFrames", index, 1);
    end
end

do
    local L = addon.L;

    local moduleData = {
        dbKey = "BlizzFixWardrobeTrackingTip",
        name = L["ModuleName BlizzFixWardrobeTrackingTip"],
        description = L["ModuleDescription BlizzFixWardrobeTrackingTip"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 3,
        moduleAddedTime = 1705561000,
    };

    addon.ControlCenter:AddModule(moduleData);
end