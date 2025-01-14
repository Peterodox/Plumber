local _, addon = ...
local GameTooltipItemManager = addon.GameTooltipItemManager;

local GetItemSpell = C_Item.GetItemSpell;
local GetRecipeSchematic = C_TradeSkillUI.GetRecipeSchematic;
local GetItemNameByID = C_Item.GetItemNameByID;
local GetItemIconByID = C_Item.GetItemIconByID;
local GetItemCount = C_Item.GetItemCount;
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
local GetItemInfoInstant = C_Item.GetItemInfoInstant;
local IsShiftKeyDown = IsShiftKeyDown;

local ItemReagentCache = {};
local ItemSubModule = {};

local TextureInfoTable = {
    width = 14,
    height = 14,
    margin = { left = 0, right = 4, top = 0, bottom = 0 },
    texCoords = { left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375 },
};

function ItemSubModule:ProcessItem(tooltip, itemID)
    if self.enabled then
        if ItemReagentCache[itemID] == nil then
            local _, _, _, _, _, classID = GetItemInfoInstant(itemID);
            local _, spellID = GetItemSpell(itemID);
            if spellID and classID ~= 8 then    --ItemEnhancement: Enchant Scroll
                local schematic = GetRecipeSchematic(spellID, false);
                if schematic and schematic.reagentSlotSchematics then
                    local numReagents = 0;
                    local reagents = {};

                    for k, v in ipairs(schematic.reagentSlotSchematics) do
                        if v.required and v.reagents and v.reagents[1] and (v.reagents[1].itemID or v.reagents[1].currencyID) then
                            numReagents = numReagents + 1;
                            reagents[numReagents] = {
                                quantityRequired = v.quantityRequired or 1,
                                itemID = v.reagents[1].itemID,
                                currencyID = v.reagents[1].currencyID,
                            };
                        end
                    end

                    if numReagents > 0 then
                        local info = {};
                        info.reagents = reagents;
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
            local name, count, quantityText, icon;
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
                    else
                        tooltip:AddDoubleLine(name, quantityText, 1, 0.125, 0.125, 1, 0.125, 0.125);
                    end
                    tooltip:AddTexture(icon, TextureInfoTable);
                end
            end

            if info.outputItemID and IsShiftKeyDown() then
                name = GetItemNameByID(info.outputItemID);
                if (not name) or name == "" then
                    requireUpdate = true;
                end
                GameTooltipItemManager:AppendItemInfo(tooltip, info.outputItemID);
            end

            if requireUpdate and tooltip.RefreshDataNextUpdate then
                tooltip:RefreshDataNextUpdate();
            end

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
        moduleAddedTime = 1726674500,
    };

    addon.ControlCenter:AddModule(moduleData);
end