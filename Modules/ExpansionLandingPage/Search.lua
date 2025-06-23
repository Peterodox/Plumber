local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;


--API.GetValidDifficultiesForEncounter(instanceID, encounterID)


local ipairs = ipairs;
local EL = CreateFrame("Frame");


do  --Shared
    local strlen = string.len;
    local StringTrim = API.StringTrim;

    EL.minCharacters = 3;

    function EL:Init()
        local locale = GetLocale();
        if locale == "zhCN" or locale == "zhTW" then
            self.minCharacters = 2;
        end
    end
    EL:Init()

    function EL:GetValidTextForSearch(text)
        text = StringTrim(text);
        local valid = text and strlen(text) >= self.minCharacters;
        return valid, text
    end

    function EL:OnSearchStart()
        self.t = 1;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function EL:OnSearchFinished()
        if self.onSearchFinishedCallbacks then
            for _, callback in ipairs(self.onSearchFinishedCallbacks) do
                callback();
            end
        end
    end

    function EL:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.6 then    --Delay
            self.t = 0;
            self:SetScript("OnUpdate", nil);

            if self.isSearchFinished and (not self.isSearchFinished()) then
                self:SetScript("OnUpdate", self.OnUpdate);
            else
                self:OnSearchFinished();
            end
        end
    end

    function EL:ClearOnSearchFinishedCallbacks()
        self.onSearchFinishedCallbacks = nil;
    end

    function EL:AddOnSearchFinishedCallbacks(callback)
        if not self.onSearchFinishedCallbacks then
            self.onSearchFinishedCallbacks = {};
        end

        for _, cb in ipairs(self.onSearchFinishedCallbacks) do
            if cb == callback then
                return
            end
        end

        table.insert(self.onSearchFinishedCallbacks, callback);
    end
end


do  --Encounter Search
    local EJ_SetSearch = EJ_SetSearch;
    local EJ_ClearSearch = EJ_ClearSearch;
    local EJ_GetNumSearchResults = EJ_GetNumSearchResults;
    local EJ_GetSearchResult = EJ_GetSearchResult;
    local EJ_IsSearchFinished = EJ_IsSearchFinished;
    local EJ_GetInstanceInfo = EJ_GetInstanceInfo;
    local EJ_GetEncounterInfo = EJ_GetEncounterInfo;
    local EJ_GetCreatureInfo = EJ_GetCreatureInfo;
    local EJ_IsValidInstanceDifficulty = EJ_IsValidInstanceDifficulty;


    local function OnSearchFinished_Encounter()
        local total = EJ_GetNumSearchResults();
        local n = 0;
        local results;

        if total > 0 then
            local name, icon;
            local id, stype, difficultyID, instanceID, encounterID;
            local numShown = math.min(total, 100);
            results = {};

            local uniqueEncounters = {};

            for i = 1, numShown do
                name = nil;
                id, stype, difficultyID, instanceID, encounterID = EJ_GetSearchResult(i);

                if stype == 4 then  --EJ_STYPE_INSTANCE
                    name, _, _, icon = EJ_GetInstanceInfo(id);
                elseif stype == 1 then   --EJ_STYPE_ENCOUNTER
                    name = EJ_GetEncounterInfo(id);
                elseif stype == 2 then   --EJ_STYPE_CREATURE
                    local cId, cName, _, cDisplayInfo;
                    for j = 1, 9 do     --MAX_CREATURES_PER_ENCOUNTER
                        cId, cName, _, cDisplayInfo = EJ_GetCreatureInfo(j, encounterID);
                        if cId == id then
                            name = cName;
                            local encounterName = EJ_GetEncounterInfo(encounterID);
                            if encounterName then   --Replace the creature name with encounter name
                                name = encounterName;
                            end
                            break
                        end
                    end
                end

                if name then
                    if encounterID and not uniqueEncounters[encounterID] then
                        uniqueEncounters[encounterID] = true;
                        n = n + 1;
                        results[n] = {
                            name = name,
                            stype = stype,
                            instanceID = instanceID,
                            encounterID = encounterID,
                            isBoss = stype == 1 or stype == 2,
                            isEncounter = stype == 1,
                            isInstance = stype == 4,
                        };
                    end
                end
            end
        end

        if EL.searchResultReceiver then
            EL.searchResultReceiver:OnSearchComplete(results);
        end
    end

    local function OnSearchFinished_Instance()
        local total = EJ_GetNumSearchResults();
        local n = 0;
        local results;

        if total > 0 then
            local name, icon, bossName;
            local _, id, stype, difficultyID, instanceID, encounterID, journalInstanceID, isBoss;
            local numShown = math.min(total, 100);
            results = {};

            local uniqueInstances = {};

            for i = 1, numShown do
                name = nil;
                isBoss = nil;
                bossName = nil;
                id, stype, difficultyID, journalInstanceID, encounterID = EJ_GetSearchResult(i);

                if stype == 4 then  --EJ_STYPE_INSTANCE
                    journalInstanceID = id;
                    name, _, _, icon = EJ_GetInstanceInfo(journalInstanceID);
                elseif stype == 1 then   --EJ_STYPE_ENCOUNTER
                    name, _, _, _, _, journalInstanceID, _, instanceID = EJ_GetEncounterInfo(id);
                    bossName = name;
                    isBoss = true;
                elseif stype == 2 then   --EJ_STYPE_CREATURE
                    local cId, cName, _, cDisplayInfo;
                    for j = 1, 9 do     --MAX_CREATURES_PER_ENCOUNTER
                        cId, cName, _, cDisplayInfo = EJ_GetCreatureInfo(j, encounterID);
                        if cId == id then
                            bossName = cName;
                            _, _, _, _, _, journalInstanceID, _, instanceID = EJ_GetEncounterInfo(encounterID);
                            isBoss = true;
                            break
                        end
                    end
                end

                if isBoss then
                    local instanceName = EJ_GetInstanceInfo(journalInstanceID);
                    if instanceName then   --Show which instance the boss belongs
                        name = instanceName;
                    end
                end

                if name then
                    if journalInstanceID and not uniqueInstances[journalInstanceID] then
                        uniqueInstances[journalInstanceID] = true;
                        n = n + 1;
                        results[n] = {
                            name = name,
                            stype = stype,
                            instanceID = journalInstanceID,
                            encounterID = encounterID,
                            isInstance = true,
                            bossName = bossName,
                        };
                    end
                end
            end
        end

        if EL.searchResultReceiver then
            EL.searchResultReceiver:OnSearchComplete(results);
        end
    end

    function EL:SearchEJ(rawText, callback)
        self.isSearchFinished = EJ_IsSearchFinished;
        self:ClearOnSearchFinishedCallbacks();
        local valid, text = self:GetValidTextForSearch(rawText);

        if valid then
            self:AddOnSearchFinishedCallbacks(callback);
            EJ_SetSearch(text);
            self:OnSearchStart();
        else
            EJ_ClearSearch();
            if EL.searchResultReceiver then
                EL.searchResultReceiver:OnSearchComplete();
            end
        end
    end


    local ReceiverDummy = {};

    function ReceiverDummy:GetBosses(results)
        local tbl;
        if results then
            local n = 0;
            for k, v in ipairs(results) do
                if v.isBoss then
                    n = n + 1;
                    v.instanceName = EJ_GetInstanceInfo(v.instanceID);
                    if not tbl then
                        tbl = {};
                    end
                    tbl[n] = v;
                end
            end
        end
        self.searchResultReceiver:OnSearchComplete(tbl);
    end

    function ReceiverDummy:GetInstances(results)
        local tbl;
        if results then
            local n = 0;
            for k, v in ipairs(results) do
                if v.isInstance then
                    n = n + 1;
                    if not tbl then
                        tbl = {};
                    end
                    tbl[n] = v;
                end
            end
        end
        self.searchResultReceiver:OnSearchComplete(tbl);
    end

    function LandingPageUtil.SearchBoss(rawText, searchResultReceiver)
        EL.searchResultReceiver = ReceiverDummy;
        ReceiverDummy.OnSearchComplete = ReceiverDummy.GetBosses;
        ReceiverDummy.searchResultReceiver = searchResultReceiver;
        EL:SearchEJ(rawText, OnSearchFinished_Encounter);
    end

    function LandingPageUtil.SearchInstance(rawText, searchResultReceiver)
        EL.searchResultReceiver = ReceiverDummy;
        ReceiverDummy.OnSearchComplete = ReceiverDummy.GetInstances;
        ReceiverDummy.searchResultReceiver = searchResultReceiver;
        EL:SearchEJ(rawText, OnSearchFinished_Instance);
    end
end