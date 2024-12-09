local _, addon = ...
local GameTooltipItemManager = addon.GameTooltipItemManager;

local GetFactionStatusText = addon.API.GetFactionStatusText;
local GetFactionGrantedByItem = addon.GetFactionGrantedByItem;

local ItemSubModule = {};

function ItemSubModule:ProcessItem(tooltip, itemID)
    if self.enabled then
        local factionID = GetFactionGrantedByItem(itemID);
        if factionID then
            local factionStatus = GetFactionStatusText(factionID);
            if factionStatus then
                tooltip:AddLine(factionStatus);
                return true
            end
        end
        return false
    else
        return false
    end
end

function ItemSubModule:GetDBKey()
    return "TooltipRepTokens"
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
        name = addon.L["ModuleName TooltipRepTokens"],
        dbKey = ItemSubModule:GetDBKey(),
        description = addon.L["ModuleDescription TooltipRepTokens"],
        toggleFunc = EnableModule,
        categoryID = 3,
        uiOrder = 1111,
        moduleAddedTime = 1726674500,
    };

    addon.ControlCenter:AddModule(moduleData);
end