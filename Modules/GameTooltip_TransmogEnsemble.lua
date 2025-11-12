local _, addon = ...
local L = addon.L;
local GameTooltipItemManager = addon.GameTooltipManager:GetItemManager();
local ReplaceTooltipLine = addon.GameTooltipManager.ReplaceTooltipLine;
local DeleteLineByMatching = addon.GameTooltipManager.DeleteLineByMatching;


local ALREADY_KNOWN = ITEM_SPELL_KNOWN; --ERR_COSMETIC_KNOWN, Already known, with lowercase k
local PATTERN_PARTIALLY_KNOWN = L["Match Pattern Transmog Set Partially Known"];


local GetItemLearnTransmogSet = C_Item.GetItemLearnTransmogSet;
local GetBaseSetID = C_TransmogSets.GetBaseSetID;
local GetVariantSets = C_TransmogSets.GetVariantSets;
local GetSetInfo = C_TransmogSets.GetSetInfo;
local GetSetPrimaryAppearances = C_TransmogSets.GetSetPrimaryAppearances;


local EnsembleItem = {};
local ItemXSets = {};

local DifficultyNames = {
    PLAYER_DIFFICULTY3,
    PLAYER_DIFFICULTY1,
    PLAYER_DIFFICULTY2,
    PLAYER_DIFFICULTY6,
};


local function ProcessItemTooltip(tooltip, itemID, hyperlink, isDialogueUI)
    --[[ --debug
    local setID = hyperlink and C_Item.GetItemLearnTransmogSet(hyperlink);
    if setID then
        if not ItemXSets[itemID] then
            if not PlumberDevData then
                PlumberDevData = {};
            end
            if not PlumberDevData.ItemXSets then
                PlumberDevData.ItemXSets = {};
            end
            ItemXSets[itemID] = setID;
            local name = C_Item.GetItemInfo(hyperlink);
            print(name, itemID, setID);
            PlumberDevData.ItemXSets[itemID] = string.format("{%s},     --%s", setID, name);
        end
    end
    --]]

    if not hyperlink then return end;

    if EnsembleItem[itemID] then
        --Cache set info
        if not ItemXSets[itemID] then
            local setID = GetItemLearnTransmogSet(hyperlink);
            local baseSetID = GetBaseSetID(setID);
            local baseSetInfo = GetSetInfo(baseSetID);
            local allSetInfo = GetVariantSets(baseSetID);
            local insertBaseSet = true;
            for _, info in ipairs(allSetInfo) do
                if info.setID == baseSetID then
                    insertBaseSet = false;
                    break
                end
            end

            if insertBaseSet then
                table.insert(allSetInfo, baseSetInfo);
            end

            table.sort(allSetInfo, function(a, b)
                if a.uiOrder ~= b.uiOrder then
                    return a.uiOrder < b.uiOrder
                end
                return a.setID < b.setID
            end);

            local tbl = {};
            for i = 1, 4 do
                tbl[i] = allSetInfo[i].setID;
            end
            ItemXSets[itemID] = tbl;
        end

        tooltip:AddLine(" ");

        local allCollected = true;

        for i, setID in ipairs(ItemXSets[itemID]) do
            local appearances = GetSetPrimaryAppearances(setID);
            local numCollected = 0;
            local numTotal = 0;
            for _, v in ipairs(appearances) do
                if v.collected then
                    numCollected = numCollected + 1;
                end
                numTotal = numTotal + 1;
            end
            if numCollected >= numTotal then
                tooltip:AddDoubleLine(DifficultyNames[i], "|TInterface\\AddOns\\Plumber\\Art\\ExpansionLandingPage\\Icons\\CheckmarkGrey:0:0|t", 0.5, 0.5, 0.5, 1, 1, 1);
            else
                allCollected = false;
                tooltip:AddDoubleLine(DifficultyNames[i], numCollected.."/"..numTotal, 1, 1, 1, 1, 1, 1);
            end
        end

        ReplaceTooltipLine(tooltip, ALREADY_KNOWN, nil);
        DeleteLineByMatching(tooltip, PATTERN_PARTIALLY_KNOWN);

        if allCollected then
            tooltip:AddLine(" ");
            tooltip:AddLine(ALREADY_KNOWN, 1, 0.125, 0.125, true);
        end

        return true
    end
    return false
end


local ItemSubModule = {};
do
    function ItemSubModule:ProcessData(tooltip, itemID, itemLink)
        if self.enabled then
            return ProcessItemTooltip(tooltip, itemID, itemLink)
        else
            return false
        end
    end

    function ItemSubModule:GetDBKey()
        return "TooltipTransmogEnsemble"
    end

    function ItemSubModule:SetEnabled(enabled)
        self.enabled = enabled == true;
        GameTooltipItemManager:RequestUpdate();
    end

    function ItemSubModule:IsEnabled()
        return self.enabled == true
    end
end


do
    --local function ProcessItemTooltip_DialogueUI(tooltip, itemID, itemLink)
    --    return ProcessItemTooltip(tooltip, itemID, itemLink, true)
    --end

    local function EnableModule(state)
        ItemSubModule:SetEnabled(state);

        if state then
            GameTooltipItemManager:AddSubModule(ItemSubModule);
        end

        --if DialogueUIAPI and DialogueUIAPI.AddItemTooltipProcessorExternal then
        --    DialogueUIAPI.AddItemTooltipProcessorExternal(ProcessItemTooltip_DialogueUI);
        --end
    end

    local moduleData = {
        name = addon.L["ModuleName TooltipTransmogEnsemble"],
        dbKey = ItemSubModule:GetDBKey(),
        description = addon.L["ModuleDescription TooltipTransmogEnsemble"],
        toggleFunc = EnableModule,
        categoryID = 3,
        uiOrder = 1205,
        moduleAddedTime = 1755200000,
        timerunningSeason = 2,
    };

    addon.ControlCenter:AddModule(moduleData);
end


EnsembleItem = {
--Pattern?: {n+1, n-2, n-1, n}

[241558] = true,     --Ensemble: Eagletalon Battlegear
[241566] = true,     --Ensemble: Vestments of Enveloped Dissonance
[241574] = true,     --Ensemble: Vestment of Second Sight
[241582] = true,     --Ensemble: Vestments of the Purifier
[241449] = true,     --Ensemble: Light's Vanguard Battleplate
[241465] = true,     --Ensemble: Regalia of the Dashing Scoundrel
[241473] = true,     --Ensemble: Bearmantle Battlegear
--[241607] = true,     --Ensemble: Regalia of the Chosen Dead
[241489] = true,     --Ensemble: Runebound Regalia
[241497] = true,     --Ensemble: Radiant Lightbringer Armor
[241505] = true,     --Ensemble: Regalia of the Skybreaker
[241513] = true,     --Ensemble: Fanged Slayer's Armor
[241521] = true,     --Ensemble: Stormheart Raiment
[241529] = true,     --Ensemble: Diabolic Raiment
[241537] = true,     --Ensemble: Regalia of the Arcane Tempest
[241545] = true,     --Ensemble: Battleplate of the Highlord
[241553] = true,     --Ensemble: Regalia of Shackled Elements
[241459] = true,     --Ensemble: Garb of Venerated Spirits
--[241601] = {182},     --Ensemble: Chains of the Chosen Dead
[241562] = true,     --Ensemble: Doomblade Battlegear
[241570] = true,     --Ensemble: Garb of the Astral Warden
[241578] = true,     --Ensemble: Legacy of Azj'aqir
[241586] = true,     --Ensemble: Regalia of Everburning Knowledge
[241445] = true,     --Ensemble: Juggernaut Battlegear
[241453] = true,     --Ensemble: Dreadwake Armor
[241461] = true,     --Ensemble: Serpentstalker Guise
[241469] = true,     --Ensemble: Chi-Ji's Battlegear
[241477] = true,     --Ensemble: Felreaper Vestments
[241485] = true,     --Ensemble: Gilded Seraph's Raiment
[241493] = true,     --Ensemble: Titanic Onslaught Armor
[241501] = true,     --Ensemble: Gravewarden Armaments
[241509] = true,     --Ensemble: Wildstalker Armor
[241517] = true,     --Ensemble: Xuen's Battlegear
[241525] = true,     --Ensemble: Demonbane Armor
[241533] = true,     --Ensemble: Vestments of Blind Absolution
--[241604] = {178},     --Ensemble: Garb of the Chosen Dead
[241549] = true,     --Ensemble: Dreadwyrm Battleplate
--[241597] = {186},     --Ensemble: Funerary Plate of the Chosen Dead
[241481] = true,     --Ensemble: Grim Inquisitor's Regalia
[241541] = true,     --Ensemble: Warplate of the Obsidian Aspect
};