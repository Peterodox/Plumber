local _, addon = ...

local GetFactionStatusText = addon.API.GetFactionStatusText;
local GetFactionGrantedByItem = addon.GetFactionGrantedByItem;
local GetSpellDescription = C_Spell.GetSpellDescription;

local TOOLTIP_DATA_TYPE = Enum.TooltipDataType.Item or 0;

local ENABLE_MODULE = false;

local function TooltipUtil_GetDisplayedItem(tooltip)
    if not ENABLE_MODULE then return end;

    local tooltipData = tooltip.infoList and tooltip.infoList[1] and tooltip.infoList[1].tooltipData;
	if tooltipData and tooltipData.type == TOOLTIP_DATA_TYPE then
		local itemID = tooltipData.id;
        if itemID then
            local factionID = GetFactionGrantedByItem(itemID);
            if factionID then
                local factionStatus = GetFactionStatusText(factionID);
                if factionStatus then
                    tooltip:AddLine(factionStatus);
                end
            end
        end
	end
end




do
    local IS_HOOKED = false;

    local function EnableModule(state)
        if state then
            ENABLE_MODULE = true;
            if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
                if not IS_HOOKED then
                    IS_HOOKED = true;
                    TooltipDataProcessor.AddTooltipPostCall(TOOLTIP_DATA_TYPE, TooltipUtil_GetDisplayedItem);
                end
            end
        else
            ENABLE_MODULE = false;
        end
    end

    local moduleData = {
        name = addon.L["ModuleName TooltipRepTokens"],
        dbKey = "TooltipRepTokens",
        description = addon.L["ModuleDescription TooltipRepTokens"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1111,
        moduleAddedTime = 1726674500,
    };

    addon.ControlCenter:AddModule(moduleData);
end