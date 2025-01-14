local _, addon = ...
local GameTooltipItemManager = {};
addon.GameTooltipItemManager = GameTooltipItemManager;

local C_TooltipInfo = C_TooltipInfo;
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

local ItemIconInfoTable = {
    width = 24,
    height = 24,
    margin = { left = 0, right = 4, top = 0, bottom = 0 },
    --texCoords = { left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375 },
    verticalOffset = 6;
};

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

    function GameTooltipItemManager:AppendTooltipInfo(tooltip, method, arg1, arg2, arg3, arg4)
        if C_TooltipInfo[method] then
            local tooltipData = C_TooltipInfo[method](arg1, arg2, arg3, arg4);
            if tooltipData then
                tooltip:AddLine(" ");
                for i, lineData in ipairs(tooltipData.lines) do
                    tooltip:AddLineDataText(lineData);
                end
            end
        end
    end

    function GameTooltipItemManager:AppendItemInfo(tooltip, itemID)
        local tooltipData = C_TooltipInfo.GetItemByID(itemID);
        if tooltipData then
            tooltip:AddLine(" ");
            for i, lineData in ipairs(tooltipData.lines) do
                tooltip:AddLineDataText(lineData);
                if i == 1 then
                    local icon = C_Item.GetItemIconByID(itemID);
                    tooltip:AddTexture(icon, ItemIconInfoTable);
                end
            end
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