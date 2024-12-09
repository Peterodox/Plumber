local _, addon = ...
local GameTooltipItemManager = {};
addon.GameTooltipItemManager = GameTooltipItemManager;

local TOOLTIP_DATA_TYPE = Enum.TooltipDataType and Enum.TooltipDataType.Item or 0;

local NO_MODULE_ENABLED = true;
local IS_HOOKED = false;


local function TooltipUtil_GetDisplayedItem(tooltip)
    if NO_MODULE_ENABLED then return end;

    local tooltipData = tooltip.infoList and tooltip.infoList[1] and tooltip.infoList[1].tooltipData;
	if tooltipData and tooltipData.type == TOOLTIP_DATA_TYPE then
		local itemID = tooltipData.id;
        if itemID then
            GameTooltipItemManager:CallSubModules(tooltip, itemID);
        end
	end
end


do
    local ipairs = ipairs;

    GameTooltipItemManager.modules = {};

    function GameTooltipItemManager:AddSubModule(module)
        for _, m in ipairs(self.modules) do
            if m == module then
                return
            end
        end
        table.insert(self.modules, module);
    end

    function GameTooltipItemManager:CallSubModules(tooltip, itemID)
        for _, m in ipairs(self.modules) do
            if m:ProcessItem(tooltip, itemID) then
                self.anyChange = true;
            end
        end
        if self.anyChange then
            tooltip:Show();
        end
    end

    function GameTooltipItemManager:InitSubModules()
        NO_MODULE_ENABLED = true;

        for _, m in ipairs(self.modules) do
            if m:IsEnabled() then
                NO_MODULE_ENABLED = false;
            end
        end

        if not NO_MODULE_ENABLED then
            if not IS_HOOKED then
                IS_HOOKED = true;
                if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
                    TooltipDataProcessor.AddTooltipPostCall(TOOLTIP_DATA_TYPE, TooltipUtil_GetDisplayedItem);
                else
                    print("Plumber AddOn Alert: WoW\'s TooltipDataProcessor methods changed.")
                end
            end
        end
    end

    function GameTooltipItemManager:RequestUpdate()
        if not self.pauseUpdate then
            self.pauseUpdate = true;
            C_Timer.After(0, function()
                self.pauseUpdate = nil;
                self:InitSubModules();
            end);
        end
    end
end


do  --ItemSubModuleMixin
--[[
    local ItemSubModule = {};

    function ItemSubModule:ProcessItem(tooltip, itemID)
        if self.enabled then

        else
            return false
        end
    end

    function ItemSubModule:GetDBKey()
        return "dbkey"
    end

    function ItemSubModule:SetEnabled(enabled)
        self.enabled = enabled == true
        GameTooltipItemManager:RequestUpdate();
    end

    function ItemSubModule:IsEnabled()
        return self.enabled == true
    end
--]]
end