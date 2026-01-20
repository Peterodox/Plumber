local _, addon = ...
local L = addon.L;
local API = addon.API;
local JoinText = API.JoinText;


local ControlCenter = {};
addon.ControlCenter = ControlCenter;
ControlCenter.modules = {};
ControlCenter.newDBKeys = {};
ControlCenter.dbKeyXModule = {};
ControlCenter.changelogs = {};


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
    "ActionBar", "Chat", "Collection", "Housing", "Instance", "Inventory", "Loot", "Map", "Profession", "Quest", "UnitFrame", "Old",
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
            end
        end
    end

    for _, moduleData in pairs(self.modules) do
        isForceEnabled = false;
        if (not moduleData.validityCheck) or (moduleData.validityCheck()) then
            enabled = db[moduleData.dbKey] or moduleData.virtual;
            moduleData.isValid = true;

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

            if moduleData.toggleFunc then
                if enabled then
                    moduleData.toggleFunc(enabled);
                end
            else
                moduleData.virtual = true;
            end

            if moduleData.virtual then
                if moduleData.description then
                    moduleData.description = moduleData.description.."\n\n"..L["Always On Module"];
                end
            end

            if enabled and isForceEnabled then
                API.PrintMessage(string.format(L["New Feature Auto Enabled Format"], moduleData.name));     --Todo: click link to view detail |cff71d5ff
            end

            self.dbKeyXModule[moduleData.dbKey] = moduleData;

            if moduleData.minimumTocVersion then
                if not addon.IsToCVersionEqualOrNewerThan(moduleData.minimumTocVersion) then
                    moduleData.tocVersionCheckFailed = true;
                end
            end
        end
    end

    self.newDBKeys = {};


    --NewFeatureMark
    --/run PlumberDB.seenNewFeatureMark = nil
    if not db.seenNewFeatureMark then
        db.seenNewFeatureMark = {};
    end
    self.seenNewFeatureMark = db.seenNewFeatureMark;

    addon.CallbackRegistry:Trigger("ModulesLoaded");
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

        if a.virtual ~= b.virtual then
            return not a.virtual
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
        if data.isValid then
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


function ControlCenter:GetModule(dbKey)
    return dbKey and self.dbKeyXModule[dbKey]
end

function ControlCenter:GetModuleDescription(dbKey)
    if dbKey and self.dbKeyXModule[dbKey] then
        return self.dbKeyXModule[dbKey].description
    end
end

function ControlCenter:GetModuleCategoryName(dbKey)
    local module = self:GetModule(dbKey);
    if module and module.categoryKeys then
        local text;
        for i, cateKey in ipairs(module.categoryKeys) do
            if i == 1 then
                text = self:GetPrimaryCategoryName(cateKey);
            else
                text = text..", "..self:GetPrimaryCategoryName(cateKey);
            end
        end
        return text
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
        if a.virtual ~= b.virtual then
            return not a.virtual
        end

        return a.name < b.name
    end

    function SortFunc.Date(a, b)
        if a.virtual ~= b.virtual then
            return not a.virtual
        end

        if a.moduleAddedTime and b.moduleAddedTime then
            return a.moduleAddedTime > b.moduleAddedTime
        end

        if not(a.moduleAddedTime or b.moduleAddedTime) then
            return a.name < b.name
        end

        return a.moduleAddedTime ~= nil
    end


    local CurrentSortMethod = SortFunc.Alphabet;

    local FilterSortByMethods = {
        SortFunc.Alphabet,
        SortFunc.Date,
    };

    function ControlCenter:ClearFilterCache()
        self.sortedModules = nil;
    end

    function ControlCenter:UpdateCurrentSortMethod()
        local index = PlumberDB and PlumberDB.SettingsPanelFilterIndex;
        index = self:GetValidSortMethodIndex(index);

        if CurrentSortMethod ~= FilterSortByMethods[index] then
            CurrentSortMethod = FilterSortByMethods[index];
            self:ClearFilterCache();
        end

        return index
    end

    function ControlCenter:SetCurrentSortMethod(index)
        if not (index and FilterSortByMethods[index]) then
            index = 1;
        end

        if CurrentSortMethod ~= FilterSortByMethods[index] then
            CurrentSortMethod = FilterSortByMethods[index];
            self.sortedModules = nil;
        end

        if PlumberDB then
            PlumberDB.SettingsPanelFilterIndex = index;
        end
    end

    function ControlCenter:GetValidSortMethodIndex(index)
        if not (index and FilterSortByMethods[index]) then
            index = 1;
        end
        return index
    end

    function ControlCenter:GetNumFilters()
        return #FilterSortByMethods
    end


    function ControlCenter:GetPrimaryCategoryName(categoryKey)
        return L["SC "..categoryKey] or "Unknown"
    end

    function ControlCenter:GetSearchTagName(tag)
        return L["KW "..tag]
    end

    function ControlCenter:UpdateSettingsOpenTime()
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
        return settingsOpenTime, canShowNewTag
    end

    function ControlCenter:IsNewFeatureMarkerSeen(dbKey)
        return self.seenNewFeatureMark[dbKey]
    end

    function ControlCenter:FlagNewFeatureMarkerSeen(dbKey)
        self.seenNewFeatureMark[dbKey] = true;
    end

    function ControlCenter:GetSortedModules()
        if ControlCenter.sortedModules then
            return ControlCenter.sortedModules
        end

        local settingsOpenTime, canShowNewTag = ControlCenter:UpdateSettingsOpenTime();
        local ipairs = ipairs;
        local tinsert = table.insert;
        local tbl = {};
        local numValid = 0;

        local categoryXModule = {};
        local anyNewFeatureInCategory = {};

        for i, data in ipairs(ControlCenter.modules) do
            if data.isValid then
                numValid = numValid + 1;

                if canShowNewTag and data.moduleAddedTime and data.moduleAddedTime > settingsOpenTime then
                    if not ControlCenter:IsNewFeatureMarkerSeen(data.dbKey) then
                        data.isNewFeature = true;
                    end
                end

                if not data.categoryKeys then
                    data.categoryKeys = {"Uncategorized"};
                end

                for _, cateKey in ipairs(data.categoryKeys) do
                    if not categoryXModule[cateKey] then
                        categoryXModule[cateKey] = {};
                    end

                    tinsert(categoryXModule[cateKey], data);

                    if data.isNewFeature then
                        anyNewFeatureInCategory[cateKey] = true;
                    end
                end
            end
        end

        for cateKey, v in pairs(categoryXModule) do
            table.sort(v, CurrentSortMethod);
        end

        local numModules;

        for _, cateKey in ipairs(PrimaryCategory) do
            numModules = categoryXModule[cateKey] and #categoryXModule[cateKey] or 0;
            if numModules > 0 then
                tinsert(tbl, {
                    key = cateKey,
                    categoryName = ControlCenter:GetPrimaryCategoryName(cateKey),
                    modules = categoryXModule[cateKey],
                    anyNewFeature = anyNewFeatureInCategory[cateKey],
                    numModules = numModules,
                });
            end
        end

        ControlCenter.sortedModules = tbl;
        return tbl
    end

    function ControlCenter:GetSearchResult(keyword)
        if not keyword then
            return self:GetSortedModules();
        end

        local settingsOpenTime, canShowNewTag = self:UpdateSettingsOpenTime();
        local lower = string.lower;
        local find = string.find;
        local ipairs = ipairs;
        local tinsert = table.insert;
        local tbl = {};
        local numValid = 0;

        local categoryXModule = {};
        local anyNewFeatureInCategory = {};
        local shownCategory = {};

        keyword = lower(keyword);

        for _, cateKey in ipairs(PrimaryCategory) do
            local categoryName = ControlCenter:GetPrimaryCategoryName(cateKey);
            if categoryName and find(lower(categoryName), keyword, 1, true) then
                shownCategory[cateKey] = true;
            end
        end

        local tagName;

        for i, data in ipairs(ControlCenter.modules) do
            if data.isValid then
                if not data.combinedSearchText then
                    local text = lower(data.name);

                    if data.searchTags then
                        for _, tag in ipairs(data.searchTags) do
                            tagName = self:GetSearchTagName(tag);
                            text = JoinText(" ", text, lower(tagName));
                        end
                    end

                    --Support searching in descriptions?
                    if data.description then
                        text = JoinText(" ", text, lower(data.description));
                    end

                    data.combinedSearchText = text;
                end

                local cateKey = data.categoryKeys and data.categoryKeys[1] or "Uncategorized";
                local matched = shownCategory[cateKey];

                if (not matched) and data.combinedSearchText then
                    if find(data.combinedSearchText, keyword, 1, true) then
                        matched = true;
                    end
                end

                if matched then
                    numValid = numValid + 1;

                    if canShowNewTag and data.moduleAddedTime and data.moduleAddedTime > settingsOpenTime then
                        if not ControlCenter:IsNewFeatureMarkerSeen(data.dbKey) then
                            data.isNewFeature = true;
                        end
                    end

                    if not categoryXModule[cateKey] then
                        categoryXModule[cateKey] = {};
                    end

                    tinsert(categoryXModule[cateKey], data);

                    if data.isNewFeature then
                        anyNewFeatureInCategory[cateKey] = true;
                    end
                end
            end
        end

        for cateKey, v in pairs(categoryXModule) do
            table.sort(v, CurrentSortMethod);
        end

        local numModules;

        for _, cateKey in ipairs(PrimaryCategory) do
            numModules = categoryXModule[cateKey] and #categoryXModule[cateKey] or 0;
            if numModules > 0 then
                tinsert(tbl, {
                    key = cateKey,
                    categoryName = ControlCenter:GetPrimaryCategoryName(cateKey),
                    modules = categoryXModule[cateKey],
                    anyNewFeature = anyNewFeatureInCategory[cateKey],
                    numModules = numModules,
                });
            end
        end

        return tbl
    end

    function ControlCenter:FlagCurrentNewFeatureMarkerSeen()
        local settingsOpenTime, canShowNewTag = self:UpdateSettingsOpenTime();
        for i, data in ipairs(self.modules) do
            if data.isValid then
                data.isNewFeature = nil;
                if canShowNewTag and data.moduleAddedTime and data.moduleAddedTime > settingsOpenTime then
                    self:FlagNewFeatureMarkerSeen(data.dbKey);
                end
            end
        end
        self:ClearFilterCache();
    end

    function ControlCenter:AnyNewFeatureMarker()
        local settingsOpenTime, canShowNewTag = self:UpdateSettingsOpenTime();
        for i, data in ipairs(self.modules) do
            if data.isValid then
                if canShowNewTag and data.moduleAddedTime and data.moduleAddedTime > settingsOpenTime and (not self:IsNewFeatureMarkerSeen(data.dbKey)) then
                    return true
                end
            end
        end
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