local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;


local DataCacheMixin = {};
do
    function DataCacheMixin:GetData(id, key)
        if not self.data[id] then
            self.data[id] = {};
        end
        return self.data[id][key]
    end

    function DataCacheMixin:StoreData(id, key, value)
        if not self.data[id] then
            self.data[id] = {};
        end
        self.data[id][key] = value;
    end
end


local QuestCache = API.CreateFromMixins(DataCacheMixin);
do
    function QuestCache:GetQuestName(questID)
        local name = self:GetData(questID, "name");
        if name then
            return name
        else
            name = API.GetQuestName(questID);
            if name and name ~= "" then
                self:StoreData(questID, "name", name);
                return name
            end
        end
    end
end


local FactionCache = API.CreateFromMixins(DataCacheMixin);
do
    function FactionCache:GetFactionName(factionID)
        local name = self:GetData(factionID, "name");
        if name then
            return name
        else
            local data = C_Reputation.GetFactionDataByID(factionID);
            if data and data.name then
                self:StoreData(factionID, "name", data.name);
                return data.name
            end
        end
    end
end