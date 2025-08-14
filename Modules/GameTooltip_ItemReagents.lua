local _, addon = ...
local L = addon.L;
local GameTooltipItemManager = addon.GameTooltipManager:GetItemManager();
local AddTextureToTooltip = addon.API.AddTextureToTooltip;


local floor = math.floor;
local GetItemSpell = C_Item.GetItemSpell;
local GetRecipeSchematic = C_TradeSkillUI.GetRecipeSchematic;
local GetItemNameByID = C_Item.GetItemNameByID;
local GetItemIconByID = C_Item.GetItemIconByID;
local GetItemCount = C_Item.GetItemCount;
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
local GetItemInfoInstant = C_Item.GetItemInfoInstant;
local IsShiftKeyDown = IsShiftKeyDown;


local ItemReagentCache = {};
local ItemRecipeIDCache = {};   --Debug
local QuantityOverride = {};


local ItemSubModule = {};

function ItemSubModule:ProcessData(tooltip, itemID)
    if self.enabled then
        if ItemReagentCache[itemID] == nil then
            local _, _, _, _, _, classID = GetItemInfoInstant(itemID);
            local _, spellID = GetItemSpell(itemID);
            if spellID and classID ~= 8 then    --ItemEnhancement: Enchant Scroll
                local schematic = GetRecipeSchematic(spellID, false);
                if schematic and schematic.reagentSlotSchematics then
                    local recipeID = schematic.recipeID;
                    ItemRecipeIDCache[itemID] = recipeID;
                    local numReagents = 0;
                    local reagents = {};
                    local reagentItemID;
                    local tbl;
                    for k, v in ipairs(schematic.reagentSlotSchematics) do
                        if v.required and v.reagents and v.reagents[1] and (v.reagents[1].itemID or v.reagents[1].currencyID) then
                            numReagents = numReagents + 1;
                            reagentItemID = v.reagents[1].itemID;
                            tbl = {};
                            tbl.quantityRequired = v.quantityRequired or 1;
                            if reagentItemID then
                                tbl.itemID = reagentItemID;
                                if QuantityOverride[recipeID] and QuantityOverride[recipeID][reagentItemID] then
                                    tbl.quantityRequired = QuantityOverride[recipeID][reagentItemID];
                                end
                            else
                                tbl.currencyID = v.reagents[1].currencyID;
                            end
                            reagents[numReagents] = tbl;
                        end
                    end

                    if numReagents > 0 then
                        local info = {};
                        info.reagents = reagents;
                        info.spellID = spellID;
                        if schematic.outputItemID then
                            info.outputItemID = schematic.outputItemID;
                        end
                        ItemReagentCache[itemID] = info;
                    else
                        ItemReagentCache[itemID] = false;
                    end
                else
                    ItemReagentCache[itemID] = false;
                end
            else
                ItemReagentCache[itemID] = false;
            end
        end

        if ItemReagentCache[itemID] then
            tooltip:AddLine(" ");
            local info = ItemReagentCache[itemID];
            local name, count, quantityText, icon, maxOutput, numOuput;
            local requireUpdate;
            local isMultipleReagent = #info.reagents > 1;
            for k, v in ipairs(info.reagents) do
                if v.itemID then
                    name = GetItemNameByID(v.itemID);
                    if (not name) or name == "" then
                        requireUpdate = true;
                        name = "Item: "..v.itemID;
                    end
                    count = GetItemCount(v.itemID, true, false, true, true);
                    icon = GetItemIconByID(v.itemID)
                    if isMultipleReagent and v.itemID == itemID then
                        name = "* "..name;
                    end
                elseif v.currencyID then
                    local currencyInfo = GetCurrencyInfo(v.currencyID);
                    if currencyInfo then
                        name = currencyInfo.name;
                        count = currencyInfo.quantity;
                        icon = currencyInfo.iconFileID;
                    end
                end

                if name then
                    quantityText = count.."/"..v.quantityRequired;
                    if count >= v.quantityRequired then
                        tooltip:AddDoubleLine(name, quantityText, 1, 1, 1, 1, 1, 1);
                        numOuput = floor(count / v.quantityRequired);
                        if maxOutput then
                            if numOuput < maxOutput then
                                maxOutput = numOuput;
                            end
                        else
                            maxOutput = numOuput;
                        end
                    else
                        tooltip:AddDoubleLine(name, quantityText, 1, 0.125, 0.125, 1, 0.125, 0.125);
                        maxOutput = 0;
                    end
                    AddTextureToTooltip(tooltip, icon);
                end
            end

            if info.outputItemID and IsShiftKeyDown() then
                name = GetItemNameByID(info.outputItemID);
                if (not name) or name == "" then
                    requireUpdate = true;
                end
                GameTooltipItemManager:AppendItemInfo(tooltip, info.outputItemID);
            end

            if maxOutput and maxOutput > 1 and info.outputItemID then
                tooltip:AddLine(" ");
                tooltip:AddLine(string.format(L["Can Create Multiple Item Format"], maxOutput), 1, 0.82, 0, true);
            end

            if requireUpdate and tooltip.RefreshDataNextUpdate then
                tooltip:RefreshDataNextUpdate();
            end

            --debug
            --[[
            if true then
                --/dump C_TradeSkillUI.GetRecipeSchematic(428667, false).reagentSlotSchematics
                tooltip:AddLine(" ");

                local _, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID = C_Item.GetItemInfoInstant(itemID);
                local idFormat = "%s |cffffffff%s|r";
                tooltip:AddDoubleLine("ItemID", itemID, 1, 0.82, 0, 1, 1, 1);
                tooltip:AddDoubleLine("SpellID", info.spellID, 1, 0.82, 0, 1, 1, 1);
                tooltip:AddDoubleLine(idFormat:format(itemType, classID), idFormat:format(itemSubType, subClassID));
                GameTooltipItemManager:DebugPrintBool(tooltip, "IsConsumableItem", C_Item.IsConsumableItem(itemID));
                GameTooltipItemManager:DebugPrintBool(tooltip, "IsUsableItem", C_Item.IsUsableItem(itemID));

                local schematic = GetRecipeSchematic(info.spellID, false);
                GameTooltipItemManager:DebugAddField(tooltip, schematic, "name");
                GameTooltipItemManager:DebugAddField(tooltip, schematic, "recipeID");
                GameTooltipItemManager:DebugAddField(tooltip, schematic, "recipeType", nil, "TradeskillRecipeType");
                GameTooltipItemManager:DebugAddField(tooltip, schematic, "quantityMin");
                GameTooltipItemManager:DebugAddField(tooltip, schematic, "quantityMax");
                GameTooltipItemManager:DebugAddField(tooltip, schematic, "isRecraft");
                GameTooltipItemManager:DebugAddField(tooltip, schematic, "hasCraftingOperationInfo");
                GameTooltipItemManager:DebugAddField(tooltip, schematic, "outputItemID");

                for k, v in ipairs(schematic.reagentSlotSchematics) do
                    tooltip:AddLine(" ");
                    GameTooltipItemManager:DebugAddField(tooltip, v, "reagentType", k, "CraftingReagentType");
                    GameTooltipItemManager:DebugAddField(tooltip, v, "dataSlotType", k, "TradeskillSlotDataType");
                    GameTooltipItemManager:DebugAddField(tooltip, v, "quantityRequired", k);
                end
            end
            --]]

            return true
        end

        return false
    else
        return false
    end
end

function ItemSubModule:GetDBKey()
    return "TooltipItemReagents"
end

function ItemSubModule:SetEnabled(enabled)
    self.enabled = enabled == true
    GameTooltipItemManager:RequestUpdate();
end

function ItemSubModule:IsEnabled()
    return self.enabled == true
end

do
    local function EnableModule(state)
        if state then
            ItemSubModule:SetEnabled(true);
            GameTooltipItemManager:AddSubModule(ItemSubModule);
        else
            ItemSubModule:SetEnabled(false);
        end
    end

    local moduleData = {
        name = addon.L["ModuleName TooltipItemReagents"],
        dbKey = ItemSubModule:GetDBKey(),
        description = addon.L["ModuleDescription TooltipItemReagents"],
        toggleFunc = EnableModule,
        categoryID = 3,
        uiOrder = 10,
        moduleAddedTime = 1736940000,
    };

    addon.ControlCenter:AddModule(moduleData);
end




do  --QuantityOverride
    --[recipeID] = {[itemID] = quantityRequired}

    QuantityOverride[404592] = {
        [204340] = 30,   --Torn Recipe Scrap
    };

    QuantityOverride[428667] = {
        [211297] = 2,   --Fractured Spark TWW S1
    };

    QuantityOverride[467635] = {
        [230905] = 2,   --Fractured Spark TWW S2
    };

    QuantityOverride[468717] = {
        [231757] = 2,   --Fractured Spark TWW S3
    };
end