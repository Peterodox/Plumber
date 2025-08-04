local M = {
    AuraWather = false,
    Prof = false,
    CurrencyWatcher = false,
    POI = false,
    Quest = true,
};


local _, addon = ...
local API = addon.API;
local ipairs = ipairs;


local function IsEnabled(key)
    if M[key] then
        API.PrintMessage("DevTool: "..key.." On");
        return true
    end
end

if IsEnabled("AuraWather") then  --Aura Watcher
    local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex;
    local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID;
    local GetSpellInfo = C_Spell.GetSpellInfo;

    local EL = CreateFrame("Frame");
    EL.auraInstances = {};

    local CopiedKeys = {
        "auraInstanceID", "icon", "isBossAura", "isHarmful", "isHelpful", "name", "sourceUnit", "spellId",
    };

    local function CopyAuraInfo(aura)
        local tbl = {};
        for _, k in ipairs(CopiedKeys) do
            tbl[k] = aura[k];
        end
        return tbl
    end

    local function PrintAuraInfo(status, tbl)
        local prefix = " ";

        if status == 1 then
            prefix = "+";
        elseif status == -1 then
            prefix = "-";
        else
            return
        end
        print(string.format("%s |T%s:16:16|t %s (%s)", prefix, tbl.icon, tbl.name, tbl.spellId));
    end

    function EL:UpdateExistingAuras()
        self.auraInstances = {};
        local aura = {};
        local index = 0;
        while aura do
            index = index + 1;
            aura = GetAuraDataByIndex("player", index);
            if aura then
                self.auraInstances[aura.auraInstanceID] = CopyAuraInfo(aura);
                PrintAuraInfo(1, self.auraInstances[aura.auraInstanceID]);
            end
        end
    end

    EL:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_AURA" then
           local unitTarget, updateInfo = ...
            if not updateInfo then return end;

            if updateInfo.addedAuras then
                local tbl;
                for _, aura in ipairs(updateInfo.addedAuras) do
                    tbl = CopyAuraInfo(aura);
                    self.auraInstances[aura.auraInstanceID] = tbl;
                    PrintAuraInfo(1, tbl);
                end
            end

            if updateInfo.removedAuraInstanceIDs then
                local tbl;
                for _, id in ipairs(updateInfo.removedAuraInstanceIDs) do
                    tbl = self.auraInstances[id];
                    if tbl then
                        PrintAuraInfo(-1, tbl);
                        self.auraInstances[id] = nil;
                    end
                end
            end

            if updateInfo.updatedAuraInstanceIDs then
                local aura;
                for _, id in ipairs(updateInfo.updatedAuraInstanceIDs) do
                    aura = GetAuraDataByAuraInstanceID("player", id);
                end
            end
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unitTarget, castGUID, spellID = ...
            local info = GetSpellInfo(spellID);
            if info then
                print(string.format("Cast: |T%s:16:16|t %s (%s)", info.iconID, info.name, info.spellID));
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
            self:UnregisterEvent(event);
            self:UpdateExistingAuras();
        end
    end);

    if false then
        EL:RegisterUnitEvent("UNIT_AURA", "player");
        EL:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
        EL:RegisterEvent("PLAYER_ENTERING_WORLD");
    end
end

if IsEnabled("Prof") then  --Profession Specialization
    local function GetPrimaryProfessionID(index)
        local prof = select(index, GetProfessions());
        if prof then
            local subcateogryName = select(11, GetProfessionInfo(prof));
    
            if not subcateogryName or subcateogryName == "" then return end;
    
            local info;
            local skillLines = C_TradeSkillUI.GetAllProfessionTradeSkillLines();
    
            for i, skillLine in ipairs(skillLines) do
                info = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLine)
                if info and info.professionName == subcateogryName then
                    return skillLine, info.professionName
                end
            end
        end
    end
    
    local function GetNodeRanks(configID, nodeInfo, nodeID)
        --First tier for the path node is the unlock entry, which we do not want to include in the count. It can have a max ranks of either 0 or 1
        local unlockNodeEntry = C_ProfSpecs.GetUnlockEntryForPath(nodeID);
        local nodeEntryInfo = C_Traits.GetEntryInfo(configID, unlockNodeEntry);
        local numUnlockPoints = nodeEntryInfo and nodeEntryInfo.maxRanks or 0;
        local currRank = (nodeInfo.currentRank > 0) and (nodeInfo.currentRank - numUnlockPoints) or nodeInfo.currentRank;
        local maxRank = nodeInfo.maxRanks - numUnlockPoints;
        return currRank, maxRank
    end
    
    function ShowProfessionSpecProgress()
        for i = 1, 2 do
            local professionID, progressionName = GetPrimaryProfessionID(i);
            if professionID then
                local configID = C_ProfSpecs.GetConfigIDForSkillLine(professionID);
                local tabTreeIDs = C_ProfSpecs.GetSpecTabIDsForSkillLine(professionID);
    
                local nodeIDs, nodeInfo;
                local ranksPurchased, maxRanks;
                local activeEntryID, entryInfo, talentType;
                local totalPurchased = 0;
                local totalMaxRanks = 0;
    
                for treeOrder, treeID in ipairs(tabTreeIDs) do
                    nodeIDs = C_Traits.GetTreeNodes(treeID);
                    for _, nodeID in ipairs(nodeIDs) do
                        nodeInfo = C_Traits.GetNodeInfo(configID, nodeID);
                        if nodeInfo and nodeInfo.isVisible then
                            activeEntryID = nodeInfo.activeEntry and nodeInfo.activeEntry.entryID or nil;
                            entryInfo = (activeEntryID ~= nil) and C_Traits.GetEntryInfo(configID, activeEntryID) or nil;
                            talentType = (entryInfo ~= nil) and entryInfo.type or nil;
                            if talentType then
                                ranksPurchased, maxRanks = GetNodeRanks(configID, nodeInfo, nodeID);
                                if maxRanks > 1 then
                                    totalMaxRanks = totalMaxRanks + maxRanks;
                                    totalPurchased = totalPurchased + ranksPurchased;
                                end
                            end
                        end
                    end
                end
    
                local diff = totalPurchased - totalMaxRanks;
                if diff ~= 0 then
                    print(progressionName, totalPurchased.."/"..totalMaxRanks, "|cffff4800"..diff.."|r");
                else
                    print(progressionName, totalPurchased.."/"..totalMaxRanks);
                end
            end
        end
    end
end

if IsEnabled("CurrencyWatcher") then  --Currency Watcher
    local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
    local EL = CreateFrame("Frame");
    local GainSourceName = {};
    local DestroyReasonName = {};

    for k, v in pairs(Enum.CurrencySource) do
        GainSourceName[v] = k;
    end

    for k, v in pairs(Enum.CurrencyDestroyReason) do
        DestroyReasonName[v] = k;
    end

    function EL:OnEvent(event, currencyID, quantity, quantityChange, quantityGainSource, destroyReason)
        local info = currencyID and GetCurrencyInfo(currencyID);
        if info then
            print(info.currencyID, info.name, quantity, "("..quantityChange..")", quantityGainSource, quantityGainSource and GainSourceName[quantityGainSource], destroyReason and DestroyReasonName[destroyReason]);
        end
    end

    EL:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
    EL:SetScript("OnEvent", EL.OnEvent);
end

if IsEnabled("POI") then  --AreaPOI
    function YeetPOI(uiMapID)
        if not uiMapID then
            uiMapID = C_Map.GetBestMapForUnit("player");
        end

        local areaPOIs = C_AreaPoiInfo.GetAreaPOIForMap(uiMapID);
        local delvePOIs = C_AreaPoiInfo.GetDelvesForMap(uiMapID);
        if delvePOIs and #delvePOIs > 0 then
            for _, areaPoiID in ipairs(delvePOIs) do
                table.insert(areaPOIs, areaPoiID);
            end
        end
        local info;

        for i, areaPoiID in ipairs(areaPOIs) do
            info = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID);
            print(i, areaPoiID, info.name);
            if info.iconWidgetSet then
                print("iconWidgetSet:", info.iconWidgetSet);
            end
        end
    end

    function YeetScriptedAnimationEffectInfo(effectID)
        local effects = {};
        local effectDescriptions = C_ScriptedAnimations.GetAllScriptedAnimationEffects();
        local count = #effectDescriptions;
        for i = 1, count do
            if effectID == effectDescriptions[i].id then
               return effectDescriptions[i]
            end
        end
    end
end

if IsEnabled("Quest") then
    local EL = CreateFrame("Frame");

    EL:RegisterEvent("QUEST_ACCEPTED");
    EL:RegisterEvent("QUEST_TURNED_IN");

    EL:SetScript("OnEvent", function(self, event, ...)
        local questID = ...
        print(event, questID, API.GetQuestName(questID));
    end);

end