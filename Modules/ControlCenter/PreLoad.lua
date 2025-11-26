local _, addon = ...
local L = addon.L;
local API = addon.API;


local ControlCenter = {};
addon.ControlCenter = ControlCenter;
ControlCenter.modules = {};
ControlCenter.newDBKeys = {};
ControlCenter.dbKeyXModule = {};


local CategoryDefinition = {
    --[categoryIndex] = {key = string},
    --The key must match the keys in the localization

    [-2] = {key = "Beta"},

    [-1] = {key = "Timerunning"},

    [0] = {key = "Unknown"},    --Used during development


    [1] = {key = "General"},
    [2] = {key = "NPC Interaction"},
    [3] = {key = "Tooltip"},
    [4] = {key = "Class"},
    [5] = {key = "Reduction"},


    [1002] = {key = "Dragonflight", defaultCollapsed = true},

    [1208] = {key = "Plumber"},
};


local PrimaryCategory = {
    "Signature", "Current",
    "ActionBar", "Chat", "Collection", "Instance", "Inventory", "Loot", "Map", "Profession", "Quest", "UnitFrame", "Old",
    "Uncategorized",
};


function ControlCenter:InitializeModules()
    --Initial Enable/Disable Modules
    local db = PlumberDB;
    local enabled, isForceEnabled;

    local timerunningSeason = API.GetTimerunningSeason();

    for _, moduleData in pairs(self.modules) do
        if moduleData.timerunningSeason and moduleData.timerunningSeason ~= timerunningSeason then
            moduleData.validityCheck = function()
                return false
            end;
        end
    end

    for _, moduleData in pairs(self.modules) do
        isForceEnabled = false;
        if (not moduleData.validityCheck) or (moduleData.validityCheck()) then
            enabled = db[moduleData.dbKey];

            if (not enabled) and (self.newDBKeys[moduleData.dbKey]) then
                enabled = true;
                isForceEnabled = true;
                db[moduleData.dbKey] = true;
            end

            if moduleData.requiredDBValues then
                for dbKey, value in pairs(moduleData.requiredDBValues) do
                    if db[dbKey] ~= nil and db[dbKey] ~= value then
                        enabled = false;
                    end
                end
            end

            moduleData.toggleFunc(enabled);

            if enabled and isForceEnabled then
                API.PrintMessage(string.format(L["New Feature Auto Enabled Format"], moduleData.name));     --Todo: click link to view detail |cff71d5ff
            end

            self.dbKeyXModule[moduleData.dbKey] = moduleData;
        end
    end

    self.newDBKeys = {};
end

function ControlCenter:AddModule(moduleData)
    --moduleData = {name = ModuleName, dbKey = PlumberDB[key], description = string, toggleFunc = function, validityCheck = function, categoryID = number, uiOrder = number}

    if not moduleData.categoryID then
        moduleData.categoryID = 0;
        moduleData.uiOrder = 0;
        print("Plumber Debug:", moduleData.name, "No Category");
    end

    table.insert(self.modules, moduleData);

    if moduleData.visibleInEditMode then
        addon.AddEditModeVisibleModule(moduleData);
    end
end

function ControlCenter:GetCategoryName(id)
    local key = CategoryDefinition[id] and CategoryDefinition[id].key;
    return key and L["Module Category "..key] or "Unknown Category"
end

function ControlCenter:GetValidModules()
    if self.validModules then
        return self.validModules
    end


    local settingsOpenTime = PlumberDB.settingsOpenTime;
    local canShowNewTag;
    if settingsOpenTime then
        canShowNewTag = true;
    else
        settingsOpenTime = 0;
        canShowNewTag = false;
    end
    settingsOpenTime = settingsOpenTime - 7 * 86400;    --NewFeatureMark gone after 7 days
    PlumberDB.settingsOpenTime = time()


    local function SortFunc_Module(a, b)
        if a.categoryID ~= b.categoryID then
            return a.categoryID < b.categoryID
        end

        if a.uiOrder ~= b.uiOrder then
            return a.uiOrder < b.uiOrder
            --should be finished here
        else
            if (a.categoryID == b.categoryID) and (a ~= b) then
                --print("Plumber: Duplicated Module uiOrder", a.uiOrder, a.name, b.name);   --debug
            end
        end

        return a.name < b.name
    end

    table.sort(self.modules, SortFunc_Module);

    local validModules = {};
    local lastCategoryID;
    local numCate = 0;
    local numValid = 0;
    local subModules;

    for i, data in ipairs(self.modules) do
        if (not data.validityCheck) or (data.validityCheck()) then
            numValid = numValid + 1;
            if data.categoryID ~= lastCategoryID then
                lastCategoryID = data.categoryID;
                numCate = numCate + 1;
                validModules[numCate] = {
                    categoryID = lastCategoryID,
                    categoryName = self:GetCategoryName(lastCategoryID);
                    subModules = {},
                };
                subModules = validModules[numCate].subModules;
            end

            if canShowNewTag and data.moduleAddedTime and data.moduleAddedTime > settingsOpenTime then
                data.isNewFeature = true;
            end

            table.insert(subModules, data);
        end
    end

    self.validModules = validModules;
    return validModules
end

function ControlCenter:GetModuleDescription(dbKey)
    if dbKey and self.dbKeyXModule[dbKey] then
        return self.dbKeyXModule[dbKey].description
    end
end


do  --Our SuperTracking system is unused
    function ControlCenter:ShouldShowNavigatorOnDreamseedPins()
        return PlumberDB.Navigator_Dreamseed and not PlumberDB.Navigator_MasterSwitch
    end

    function ControlCenter:EnableSuperTracking()
        --PlumberDB.Navigator_MasterSwitch = true;
        --local SuperTrackFrame = addon.GetSuperTrackFrame();
        --SuperTrackFrame:TryEnableByModule();
    end
end


do  --Settings Panel Revamp
    local SortFunc = {};

    function SortFunc.Alphabet(a, b)
        return a.name < b.name
    end

    function ControlCenter:GetPrimaryCategoryName(categoryKey)
        return L["SC "..categoryKey] or "Unknown"
    end

    function ControlCenter:GetNewSortedModules()
        if self.sortedModules then
            return self.sortedModules
        end


        local settingsOpenTime = PlumberDB.settingsOpenTime;
        local canShowNewTag;
        if settingsOpenTime then
            canShowNewTag = true;
        else
            settingsOpenTime = 0;
            canShowNewTag = false;
        end
        settingsOpenTime = settingsOpenTime - 7 * 86400;    --NewFeatureMark gone after 7 days
        PlumberDB.settingsOpenTime = time()


        local tinsert = table.insert;
        local tbl = {};
        local numValid = 0;

        local categoryXModule = {};

        for i, data in ipairs(self.modules) do
            if (not data.validityCheck) or (data.validityCheck()) then
                numValid = numValid + 1;

                if canShowNewTag and data.moduleAddedTime and data.moduleAddedTime > settingsOpenTime then
                    data.isNewFeature = true;
                end

                if not data.categoryKeys then
                    data.categoryKeys = {"Uncategorized"};
                end

                for _, cateKey in ipairs(data.categoryKeys) do
                    if not categoryXModule[cateKey] then
                        categoryXModule[cateKey] = {};
                    end

                    tinsert(categoryXModule[cateKey], data);
                end
            end
        end

        for cateKey, v in pairs(categoryXModule) do
            table.sort(v, SortFunc.Alphabet);
        end

        for _, cateKey in ipairs(PrimaryCategory) do
            if categoryXModule[cateKey] and #categoryXModule[cateKey] > 0 then
                tinsert(tbl, {
                    key = cateKey,
                    categoryName = self:GetPrimaryCategoryName(cateKey),
                    modules = categoryXModule[cateKey],
                });
            end
        end

        self.sortedModules = tbl;
        return tbl
    end
end


do  --Option: Always Enable New Features
    addon.CallbackRegistry:Register("NewDBKeysAdded", function(newDBKeys)
        ControlCenter.newDBKeys = newDBKeys;
    end);

    local function ToggleFunc_EnableNewByDefault(state)

    end

    local moduleData = {
        name = L["ModuleName EnableNewByDefault"],
        dbKey = "EnableNewByDefault",
        description = L["ModuleDescription EnableNewByDefault"],
        toggleFunc = ToggleFunc_EnableNewByDefault,
        categoryID = 1208,
        uiOrder = 1,
    };

    --ControlCenter:AddModule(moduleData);
end