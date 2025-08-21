--This system is always active


local _, addon = ...
local API = addon.API;


local WIDGET_VISUAL_TYPE_DELVES = Enum.UIWidgetVisualizationType.ScenarioHeaderDelves or 29;


local GetStepInfo = C_Scenario.GetStepInfo;
local GetScenarioInfo = C_ScenarioInfo.GetScenarioInfo;


local DBManager = {};
do
    --[[
        --Record = {
            uiMapID = number,           --We get the Delves name from uiMapID
            instanceID = instanceID,
            time = number,
            tier = number,
        }    
    --]]

    function DBManager:Init()
        local playerDB = PlumberDB_PC or {};
        if not playerDB.DelvesRecords then
            playerDB.DelvesRecords = {};
        end
        self.records = playerDB.DelvesRecords;

        table.sort(self.records, function(a, b)
            return a.time > b.time
        end);
    end

    function DBManager:SaveRecord(record)
        if not self.records then
            self:Init();
            self:ClearDatedRecords();
        end

        local timeDiff;
        local shouldSave = true;

        for _, v in ipairs(self.records) do
            timeDiff = record.time - v.time;
            if timeDiff < 60 and timeDiff > -60 then
                --Assume you can only complete 1 delve every minute
                shouldSave = false;
            end
            break
        end

        if shouldSave then
            table.insert(self.records, 1, record);
        end
    end

    function DBManager:GetRecords()
        if not self.records then
            self:Init();
        end
        return self.records
    end

    function DBManager:ClearDatedRecords()
        if not self.records then return end;

        local lastResetTime = C_DateAndTime.GetWeeklyResetStartTime();
        if lastResetTime and lastResetTime > 0 then
            local timeThreshold = lastResetTime - 7*86400;
            local records = DBManager:GetRecords();
            local startIndex;

            for i, v in ipairs(records) do
                if v.time < timeThreshold then
                    startIndex = i;
                    break
                end
            end

            if startIndex then
                for i = startIndex, #records do
                    records[i] = nil;
                end
            end
        end
    end
end


local function GetScenarioStatus()
    local info = GetScenarioInfo();
    local inScenario, isComplete;

    if info then
        inScenario = true;
        isComplete = info.isComplete;
    else
        inScenario = false;
        isComplete = false;
    end

    return inScenario, isComplete
end


local function GetCurrentDelvesInfo()
    local name, _, _, _, _, _, _, _, _, _, _, widgetSetID = GetStepInfo();
    if widgetSetID and widgetSetID ~= 0 then
        local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID);
        if widgets then
            for k, v in ipairs(widgets) do
                if v.widgetType == WIDGET_VISUAL_TYPE_DELVES then
                    local widgetInfo = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(v.widgetID);
                    if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
                        local _, _, _, instanceID = UnitPosition("player");
                        local uiMapID = C_Map.GetBestMapForUnit("player");
                        --local stageName = widgetInfo.headerText;    --Delve Name / Treasure Room / Collect Your Reward!
                        local tierText = widgetInfo.tierText;
                        local tier = tonumber(string.match(tierText, "%d+") or 0);
                        local mapName, overrideName;
                        if uiMapID then
                            mapName = API.GetMapName(uiMapID);
                        else
                            overrideName = GetInstanceInfo();
                        end
                        --note: in 11.2 Delves, player can enter a ethereal portal where uiMapID is nil
                        local tbl = {
                            name = mapName,
                            tier = tier,
                            instanceID = instanceID,
                            uiMapID = uiMapID,
                            overrideName = overrideName,
                        };
                        return tbl
                    end
                    break
                end
            end
        end
    end
end


--API Declaration
do
    API.GetScenarioStatus = GetScenarioStatus;
    API.GetCurrentDelvesInfo = GetCurrentDelvesInfo;


    local function AddRecentDelvesRecordsToTooltip(tooltip, threshold)
        local lastResetTime = C_DateAndTime.GetWeeklyResetStartTime();
        if lastResetTime and lastResetTime > 0 then
            local records = DBManager:GetRecords();
            table.sort(records, function(a, b)
                return a.time > b.time
            end);

            local tbl = {};
            local n = 0;

            for i, v in ipairs(records) do
                if v.time > lastResetTime then
                    n = n + 1;
                    tbl[n] = v;
                else
                    break
                end
            end

            table.sort(tbl, function(a, b)
                if a.tier ~= b.tier then
                    return a.tier > b.tier
                end
                return a.time > b.time
            end);

            if n > 0 then
                local maxRuns = threshold or 8;
                local numRuns = math.min(n, maxRuns);
                local tierFormat = "- "..addon.L["Great Vault Tier Format"].."   ".."|cff40c040%s|r";
                local mapName;
                local mapNames = {};

                tooltip:AddLine(" ");
                tooltip:AddLine(WEEKLY_REWARDS_MYTHIC_TOP_RUNS:format(threshold), 1, 1, 1);

                for i, v in ipairs(tbl) do
                    if i > numRuns then
                        break
                    end
                    mapName = v.overrideName or mapNames[v.uiMapID];
                    if (not mapName) and (v.uiMapID) then
                        mapName = API.GetMapName(v.uiMapID);
                        mapNames[v.uiMapID] = mapName;
                    end
                    if not mapName then mapName = UNKNOWN; end;

                    --tooltip:AddDoubleLine(tierFormat:format(v.tier), mapName, 0.098, 1.000, 0.098, 0.098, 1.000, 0.098);
                    tooltip:AddLine(tierFormat:format(v.tier, mapName), 0.098, 1.000, 0.098);
                end

                tooltip:AddLine(" ");
                tooltip:AddLine(addon.L["Delves History Requires AddOn"], 0.5, 0.5, 0.5, true);
            end

            return true
        end
    end
    API.AddRecentDelvesRecordsToTooltip = AddRecentDelvesRecordsToTooltip;
end


local EL = CreateFrame("Frame");
do  --Event Listener
    EL:RegisterEvent("SCENARIO_UPDATE");
    EL:RegisterEvent("PLAYER_ENTERING_WORLD");

    function EL:OnEvent(event, ...)
        --print(event, ...)
        if event == "SCENARIO_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            local inScenario = GetScenarioStatus();
            if inScenario then
                self:RegisterEvent("SCENARIO_COMPLETED");
            else
                self:UnregisterEvent("SCENARIO_COMPLETED");
            end
        elseif event == "SCENARIO_COMPLETED" then
            --When SCENARIO_COMPLETED fires C_Scenario.GetStepInfo returns nil
            --C_ScenarioInfo.GetScenarioInfo briefly marked as isComplete = true, then becomes false on the next SCENARIO_UPDATE
            self:OnScenarioCompleted()
        end
    end
    EL:SetScript("OnEvent", EL.OnEvent);

    function EL:SaveDelvesCompletion()
        local info = GetCurrentDelvesInfo();
        if info then
            local record = {};
            record.uiMapID = info.uiMapID;
            record.instanceID = info.instanceID;
            record.tier = info.tier;
            record.time = time();
            record.overrideName = info.overrideName;
            if DBManager:SaveRecord(record) then
                print(string.format("Tier %d %s Complete", record.tier, API.GetMapName(record.uiMapID)));
            end
        end
    end

    function EL:OnScenarioCompleted()
        self:UnregisterEvent("SCENARIO_COMPLETED");
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function EL:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 2 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            self:SaveDelvesCompletion();
        end
    end
end