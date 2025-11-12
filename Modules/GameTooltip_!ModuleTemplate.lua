local _, addon = ...
local L = addon.L;
local GameTooltipItemManager = addon.GameTooltipManager:GetItemManager();



local function ProcessItemTooltip(tooltip, itemID, itemLink, isDialogueUI)
    return false
end


local ItemSubModule = {};
do
    function ItemSubModule:ProcessData(tooltip, itemID, hyperlink)
        if self.enabled then
            return ProcessItemTooltip(tooltip, itemID, hyperlink)
        else
            return false
        end
    end

    function ItemSubModule:GetDBKey()
        return "Tooltip_ModuleName"
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
        name = addon.L["ModuleName Tooltip_ModuleName"],
        dbKey = ItemSubModule:GetDBKey(),
        description = addon.L["ModuleDescription Tooltip_ModuleName"],
        toggleFunc = EnableModule,
        categoryID = 3,
        uiOrder = 1200,
        moduleAddedTime = 1755200000,
    };

    addon.ControlCenter:AddModule(moduleData);
end