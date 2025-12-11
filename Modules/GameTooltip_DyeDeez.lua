local _, addon = ...
local L = addon.L;
local GameTooltipItemManager = addon.GameTooltipManager:GetItemManager();
local GetSwatchMarkup = addon.Housing.GetSwatchMarkup;
local GetDyesByPigmentItemID = addon.Housing.GetDyesByPigmentItemID;


local ItemSubModule = {};



local function ProcessItemTooltip(tooltip, itemID, itemLink)
    local dyes = GetDyesByPigmentItemID(itemID);
    if dyes then
        local isItemRefTooltip = tooltip:GetName() == "ItemRefTooltip";
        local showExtraInfo = ItemSubModule.altModeEnabled or isItemRefTooltip;

        if showExtraInfo then
            local lineText, numOwned;
            local r, g, b;
            for i, dyeColorID in ipairs(dyes) do
                lineText, numOwned = GetSwatchMarkup(dyeColorID, nil, true);
                if i % 5 == 1 then
                    tooltip:AddLine(" ");
                end
                --tooltip:AddLine(lineText, 1, 0.82, 0);
                if numOwned > 0 then
                    r, g, b = 1, 1, 1;
                else
                    r, g, b = 0.4, 0.4, 0.4;    --Darker than 0.5. Showing zeros as line guide
                end
                tooltip:AddDoubleLine(lineText, numOwned, 1, 0.82, 0, r, g, b);
            end

            if not isItemRefTooltip then
                tooltip:AddLine(" ");
                tooltip:AddLine(L["Instruction Show Less Info"], 0.000, 0.800, 1.000, true);
            end

        elseif not isItemRefTooltip then
            tooltip:AddLine(" ");
            tooltip:AddLine(L["Instruction Show More Info"], 0.000, 0.800, 1.000, true);
        end


        return true
    end
    return false
end


do  --ItemSubModule
    ItemSubModule.hasAltMode = true;

    function ItemSubModule:ProcessData(tooltip, itemID)
        if self.enabled then
            return ProcessItemTooltip(tooltip, itemID)
        else
            return false
        end
    end

    function ItemSubModule:GetDBKey()
        return "TooltipDyeDeez"
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
    local function EnableModule(state)
        ItemSubModule:SetEnabled(state);
        if state then
            GameTooltipItemManager:AddSubModule(ItemSubModule);
        end
    end

    local moduleData = {
        name = addon.L["ModuleName TooltipDyeDeez"],
        dbKey = ItemSubModule:GetDBKey(),
        description = addon.L["ModuleDescription TooltipDyeDeez"],
        toggleFunc = EnableModule,
        categoryID = 3,
        uiOrder = 2000,
        moduleAddedTime = 1755200000,
		categoryKeys = {
			"Housing", "Profession",
		},
        searchTags = {
            "Tooltip", "Housing",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end