-- Auto set holiday dungeon as the default selection when opening the PVE frame for the first time
-- We don't check event quest completion or the rewards, dynamically changing the default option is more confusing


local _, addon = ...

local MODULE_ENABLED = false;
local DONE_THIS_SESSION = false;
local SCRIPT_HOOKED = false;


local SpecialDungeons = {
    --[lfgDungeonID] = {condition (questID = number)}

    [288] = true,   --Love is in the Air, The Crown Chemical Co.
    [286] = true,   --Midsummer Fire Festival, The Frost Lord Ahune
    [287] = true,   --Brewfest, Coren Direbrew
    [285] = true,   --Hallow's End, The Headless Horseman

    [744] = true,      --Random Timewalking Dungeon (Burning Crusade)
    [995] = true,      --Random Timewalking Dungeon (Wrath of the Lich King)
    [1146] = true,     --Random Timewalking Dungeon (Cataclysm)
    [1453] = true,     --Random Timewalking Dungeon (Mists of Pandaria)
    [1971] = true,     --Random Timewalking Dungeon (Warlords of Draenor)
    [2274] = true,     --Random Timewalking Dungeon (Legion)
    [2634] = true,     --Random Timewalking Dungeon (Classic)
    [2874] = true,     --Random Timewalking Dungeon (Battle for Azeroth)
    [3076] = true,     --Random Timewalking Dungeon (Shadowlands)
};


local function GetBestDungeon()
    local candidate = {};
    local n = 0;

    local GetLFGRandomDungeonInfo = GetLFGRandomDungeonInfo;
    local IsLFGDungeonJoinable = IsLFGDungeonJoinable;

    for i = 1, GetNumRandomDungeons() do
        local id, name = GetLFGRandomDungeonInfo(i);
        local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);
        if isAvailableForAll then
            if SpecialDungeons[id] then
                n = n + 1;
                candidate[n]= id;
            end
        end
    end

    if n > 0 then
        table.sort(candidate, function(a, b)
            return a < b
        end);
        return candidate[1]
    end
end

local function SelectBestDungeon()
    if DONE_THIS_SESSION or (not MODULE_ENABLED) then
        return
    end
    DONE_THIS_SESSION = true;

    local lfgDungeonID = GetBestDungeon();
    if lfgDungeonID and LFDParentFrame:IsShown() then
        LFDQueueFrame_SetType(lfgDungeonID);
    end
end


do
    local function EnableModule(state)
        if state then
            if not DONE_THIS_SESSION then
                MODULE_ENABLED = true;
                if not SCRIPT_HOOKED then
                    if LFDParentFrame then
                        LFDParentFrame:HookScript("OnShow", SelectBestDungeon);
                    end
                    SCRIPT_HOOKED = true;
                end
            end
        else
            MODULE_ENABLED = false;
        end
    end

    local moduleData = {
        name = addon.L["ModuleName HolidayDungeon"],
        dbKey = "HolidayDungeon",
        description = addon.L["ModuleDescription HolidayDungeon"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1178,
        moduleAddedTime = 1761230000,
    };

    addon.ControlCenter:AddModule(moduleData);
end