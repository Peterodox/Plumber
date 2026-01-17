-- New Event in 12.0: FACTION_STANDING_CHANGED (payloads: factionID, updatedStanding)
-- It doesn't show the delta value so we need to cache it


local _, addon = ...


local GetFactionDataByID = C_Reputation.GetFactionDataByID;
local IsMajorFaction = C_Reputation.IsMajorFaction;


local EL = CreateFrame("Frame");
EL.factionCache = {};


function EL:CacheDefaultReputations()
    -- Include major factions and the currently watched faction

    local majorFactions = C_MajorFactions.GetMajorFactionIDs();
    if majorFactions then
        for _, factionID in ipairs(majorFactions) do
            self:CacheMajorFaction(factionID);
        end
    end

    local watchedFactionData = C_Reputation.GetWatchedFactionData();
    if watchedFactionData then
        self:CacheFaction(watchedFactionData.factionID);
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
            end
        end
    end
end

function EL:CacheStandardFaction(factionID)
    if not self.factionCache[factionID] then
        local data = GetFactionDataByID(factionID);
        if data then
            self.factionCache[factionID] = {
                name = data.name,
                reaction = data.reaction,
                standing = data.currentStanding,
            };
        end
    end
end

function EL:CacheFaction(factionID)
    local isMajorFaction = IsMajorFaction(factionID);
    if isMajorFaction then
        self:CacheMajorFaction(factionID);
    else
        self:CacheStandardFaction(factionID);
    end
end

function EL:OnEvent(event, ...)
    if event == "FACTION_STANDING_CHANGED" then
        self:SetFactionStanding(...);
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:CacheDefaultReputations();
    end
end

function EL:SetFactionStanding(factionID, updatedStanding)
    if not self.factionCache[factionID] then
        self:CacheFaction(factionID);
        return
    end

    local info = self.factionCache[factionID];
    if info then
        local delta, newStanding;
        if info.isMajorFaction then
            newStanding = self:CalculateMajorFactionEffectiveStanding(factionID);
        else
            newStanding = updatedStanding;
        end

        if newStanding then
            delta = newStanding - info.standing;
            info.standing = newStanding;
        end

        if delta and delta > 0 then
            addon.LootWindow:QueueDisplayReputation(factionID, info.name, delta);
        end
    end
end

function EL:EnableModule()
    if not self.enabled then
        self.enabled = true;
        if C_EventUtils.IsEventValid("FACTION_STANDING_CHANGED") then
            self:RegisterEvent("FACTION_STANDING_CHANGED");
            self:RegisterEvent("PLAYER_ENTERING_WORLD");
            self:SetScript("OnEvent", self.OnEvent);
        end
    end
end

EL:EnableModule();