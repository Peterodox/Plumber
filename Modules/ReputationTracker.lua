-- New Event in 12.0: FACTION_STANDING_CHANGED (payloads: factionID, updatedStanding)
-- It doesn't show the delta value so we need to cache it


local _, addon = ...


local InCombatLockdown = InCombatLockdown;
local GetInstanceInfo = GetInstanceInfo;
local GetFactionDataByID = C_Reputation.GetFactionDataByID;
local IsMajorFaction = C_Reputation.IsMajorFaction;
local GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation;


local EL = CreateFrame("Frame");
EL.factionCache = {};

EL.staticEvents = {
    "FACTION_STANDING_CHANGED",
    "PLAYER_ENTERING_BATTLEGROUND",
    "PLAYER_ENTERING_WORLD",
};

EL.factionRemap = {
    -- When one of Severed Threads rep changes, it triggers the major faction standing changed 3 times
    [2600] = {2601, 2605, 2607},
};

function EL:CacheDefaultReputations()
    -- Include major factions and the currently watched faction

    local factions = {
        2601, 2605, 2607, 2669, 2673, 2677, 2675, 2671,
    };

    local majorFactions = C_MajorFactions.GetMajorFactionIDs();
    if majorFactions then
        for _, factionID in ipairs(majorFactions) do
            table.insert(factions, factionID);
        end
    end

    local watchedFactionData = C_Reputation.GetWatchedFactionData();
    if watchedFactionData then
        table.insert(factions, watchedFactionData.factionID);
    end

    local delvesFactionID = C_DelvesUI.GetDelvesFactionForSeason();
    if delvesFactionID then
        table.insert(factions, delvesFactionID);
    end

    for _, factionID in ipairs(factions) do
        self:CacheFaction(factionID);
    end
end

function EL:CalculateMajorFactionEffectiveStanding(factionID)
    local data = C_MajorFactions.GetMajorFactionRenownInfo(factionID);
    if data then
        local threshold = 2500; --Assumption
        local value = data.renownLevel * threshold + data.renownReputationEarned;

        if C_MajorFactions.HasMaximumRenown(factionID) then
            local extra = C_Reputation.GetFactionParagonInfo(factionID);
            value = value + (extra or 0);
        end

        return value
    end
end

function EL:TryAddParagonStanding(factionID, baseStanding)
    if not baseStanding then return end;
    if C_Reputation.IsFactionParagon(factionID) then
        local extra = C_Reputation.GetFactionParagonInfo(factionID);
        return baseStanding + extra;
    end
    return baseStanding
end

function EL:CacheMajorFaction(factionID)
    if not self.factionCache[factionID] then
        local data = C_MajorFactions.GetMajorFactionData(factionID);
        if data then
            local standing = self:CalculateMajorFactionEffectiveStanding(factionID);
            if standing then
                self.factionCache[factionID] = {
                    name = data.name,
                    standing = standing,
                    isMajorFaction = true,
                };
                --print(factionID, data.name, standing)
            end
        end
    end
end

function EL:CacheStandardFaction(factionID)
    if not self.factionCache[factionID] then
        local data = GetFactionDataByID(factionID);
        if data then
            local standing = self:TryAddParagonStanding(factionID, data.currentStanding);
            self.factionCache[factionID] = {
                name = data.name,
                standing = standing,
            };
            --print(factionID, data.name, standard)
        end
    end
end

function EL:CacheFriendshipFaction(factionID)
    if not self.factionCache[factionID] then
        local data = GetFriendshipReputation(factionID);
        if data then
            local standing = self:TryAddParagonStanding(factionID, data.standing);
            self.factionCache[factionID] = {
                name = data.name,
                standing = standing,
                isFriendship = true,
            };
            --print(factionID, data.name, standing)
        end
    end
end

function EL:CacheFaction(factionID)
    local isMajorFaction = IsMajorFaction(factionID);
    if isMajorFaction then
        self:CacheMajorFaction(factionID);
    else
        local data = GetFriendshipReputation(factionID);
        if data and data.friendshipFactionID > 0 then
            self:CacheFriendshipFaction(factionID);
        else
            self:CacheStandardFaction(factionID);
        end
    end
end

function EL:OnEvent(event, ...)
    if event == "FACTION_STANDING_CHANGED" then
        self:SetFactionStanding(...);
    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_ENTERING_BATTLEGROUND" then
        self:RequestUpdate();
    end
end

function EL:SetFactionStanding(factionID, updatedStanding)
    if not self.factionCache[factionID] then
        self:CacheFaction(factionID);
        return
    end

    if self.factionRemap[factionID] then
        for _, _factionID in ipairs(self.factionRemap[factionID]) do
            self:SetFactionStanding(_factionID);
        end
    end

    local info = self.factionCache[factionID];
    if info then
        if self.suppressed then
            self.factionDirty[factionID] = true;
            return
        end

        if InCombatLockdown() then
            self.factionDirty[factionID] = true;
            self:RegisterEvent("PLAYER_REGEN_ENABLED");
            return
        end

        self.factionDirty[factionID] = nil;

        local delta, newStanding;
        if info.isMajorFaction then
            newStanding = self:CalculateMajorFactionEffectiveStanding(factionID);
        elseif info.isFriendship then
            if not updatedStanding then
                local data = GetFriendshipReputation(factionID);
                updatedStanding = data and data.standing;
                updatedStanding = self:TryAddParagonStanding(factionID, updatedStanding);
            end
            newStanding = updatedStanding;
        else
            if not updatedStanding then
                local data = GetFactionDataByID(factionID);
                updatedStanding = data and data.currentStanding;
                updatedStanding = self:TryAddParagonStanding(factionID, updatedStanding);
            end
            newStanding = updatedStanding;
        end

        if newStanding then
            delta = newStanding - info.standing;
            info.standing = newStanding;
        end

        --print(factionID, info.name, newStanding, delta);

        if delta and delta > 0 then
            addon.LootWindow:QueueDisplayReputation(factionID, info.name, delta);
        end
    end
end

function EL:RequestUpdate()
    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate);
end

function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t > 1 then
        self.t = 0;
        self:SetScript("OnUpdate", nil);

        local _, instanceType = GetInstanceInfo();
        if instanceType == "arena" or instanceType == "pvp" then
            self.suppressed = true;
            return
        else
            self.suppressed = nil;
        end

        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED");
            return
        else
            self:UnregisterEvent("PLAYER_REGEN_ENABLED");
        end

        for factionID in pairs(self.factionDirty) do
            self.factionDirty[factionID] = nil;
            self:SetFactionStanding(factionID);
        end
    end
end

function EL:RequestCacheReputations()
    C_Timer.After(1, function()
        if self.enabled then
            self:CacheDefaultReputations();
        end
    end);
end

function EL:EnableModule()
    if not self.enabled then
        self.enabled = true;
        self.factionCache = {};
        self.factionDirty = {};
        if C_EventUtils.IsEventValid("FACTION_STANDING_CHANGED") then
            self:RequestCacheReputations();
            self:RequestUpdate();
            addon.API.RegisterFrameForEvents(self, self.staticEvents);
            self:SetScript("OnEvent", self.OnEvent);
        end
    end
end

function EL:DisableModule()
    if self.enabled then
        self.enabled = nil;
        if C_EventUtils.IsEventValid("FACTION_STANDING_CHANGED") then
            addon.API.UnregisterFrameForEvents(self, self.staticEvents);
            self:UnregisterEvent("PLAYER_REGEN_ENABLED");
            self:SetScript("OnEvent", nil);
            self:SetScript("OnUpdate", nil);
        end
    end
end

addon.CallbackRegistry:RegisterCallback("SettingChanged.LootUI_ShowReputation", function(state)
    if state then
        EL:EnableModule();
    else
        EL:DisableModule();
    end
end);
