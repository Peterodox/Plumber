local _, addon = ...
local GameTooltipManager = {};
addon.GameTooltipManager = GameTooltipManager;

local After = C_Timer.After;
local C_TooltipInfo = C_TooltipInfo;
local GetItemIconByID = C_Item.GetItemIconByID;
local gsub = string.gsub;


local ItemIconInfoTable = {
    width = 24,
    height = 24,
    margin = { left = 0, right = 4, top = 0, bottom = 0 },
    --texCoords = { left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375 },
    verticalOffset = 6;
};


local HandlerMixin = {};
do
    local ipairs = ipairs;

    function HandlerMixin:AddSubModule(module)
        for _, m in ipairs(self.modules) do
            if m == module then
                return
            end
        end
        table.insert(self.modules, module);
    end

    function HandlerMixin:CallSubModules(tooltip, itemID)
        for _, m in ipairs(self.modules) do
            if m:ProcessData(tooltip, itemID) then
                self.anyChange = true;
            end
        end
        if self.anyChange then
            tooltip:Show();
        end
    end

    function HandlerMixin:InitSubModules()
        self.noModuleEnabled = true;

        for _, m in ipairs(self.modules) do
            if m:IsEnabled() then
                self.noModuleEnabled = false;
            end
        end

        if not self.noModuleEnabled then
            if not self.postCallAdded then
                self.postCallAdded = true;
                if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
                    TooltipDataProcessor.AddTooltipPostCall(self.tooltipDataType, self.ProcessDisplayedData);
                else
                    print("Plumber AddOn Alert: WoW\'s TooltipDataProcessor methods changed.")
                end
            end
        end
    end

    function HandlerMixin:RequestUpdate()
        if not self.pauseUpdate then
            self.pauseUpdate = true;
            After(0, function()
                self.pauseUpdate = nil;
                self:InitSubModules();
            end);
        end
    end

    function HandlerMixin:AppendTooltipInfo(tooltip, method, arg1, arg2, arg3, arg4)
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

    function HandlerMixin:AppendItemInfo(tooltip, itemID)
        local tooltipData = C_TooltipInfo.GetItemByID(itemID);
        if tooltipData then
            tooltip:AddLine(" ");
            for i, lineData in ipairs(tooltipData.lines) do
                tooltip:AddLineDataText(lineData);
                if i == 1 then
                    local icon = GetItemIconByID(itemID);
                    tooltip:AddTexture(icon, ItemIconInfoTable);
                end
            end
        end
    end

    function HandlerMixin:DebugAddField(tooltip, tbl, field, label, enumLookup)
        local leftText, rightText;
        if label then
            leftText = string.format("- %s: %s", label, field);
        else
            leftText = field;
        end

        local value = tbl[field];

        if value and enumLookup then
            for k, v in pairs(Enum[enumLookup]) do
                if v == value then
                    rightText = string.format("%s (%s)", value, k);
                    break
                end
            end
        else
            rightText = value;
        end

        if type(rightText) == "boolean" then
            self:DebugPrintBool(tooltip, leftText, rightText);
        else
            if rightText then
                tooltip:AddDoubleLine(leftText, rightText, 1, 0.82, 0, 1, 1, 1);
            else
                tooltip:AddDoubleLine(leftText, tostring(rightText), 1, 0.82, 0, 1, 0.125, 0.125);
            end
        end

    end

    function HandlerMixin:DebugPrintBool(tooltip, leftText, bool)
        if bool then
            tooltip:AddDoubleLine(leftText, tostring(bool), 1, 0.82, 0, 0.098, 1.000, 0.098);
        else
            tooltip:AddDoubleLine(leftText, tostring(bool), 1, 0.82, 0, 1, 0.125, 0.125);
        end
    end
end


do  --GameTooltipManager
    GameTooltipManager.handlers = {};

    function GameTooltipManager:GetHandler(tooltipDataType, useLeftTextAsArgument)
        if not self.handlers[tooltipDataType] then
            local handler = {};
            self.handlers[tooltipDataType] = handler;
            addon.API.Mixin(handler, HandlerMixin);

            handler.modules = {};
            handler.tooltipDataType = tooltipDataType;
            handler.noModuleEnabled = true;

            if useLeftTextAsArgument then
                function handler.ProcessDisplayedData(tooltip)
                    local tooltipData = tooltip.infoList and tooltip.infoList[1] and tooltip.infoList[1].tooltipData;
                    if tooltipData and tooltipData.type == tooltipDataType then
                        local leftText = tooltipData.lines and tooltipData.lines[1] and tooltipData.lines[1].leftText;
                        if leftText then
                            leftText = gsub(leftText, "|T.+|t", "");
                            leftText = gsub(leftText, "%\n.+", "");
                            leftText = gsub(leftText, "|cff%w%w%w%w%w%w", "");
                            leftText = gsub(leftText, "|r", "");
                        end
                        handler:CallSubModules(tooltip, leftText);
                    end
                end
            else
                function handler.ProcessDisplayedData(tooltip)
                    local tooltipData = tooltip.infoList and tooltip.infoList[1] and tooltip.infoList[1].tooltipData;
                    if tooltipData and tooltipData.type == tooltipDataType then
                        local arg1 = tooltipData.id;
                        if arg1 then
                            handler:CallSubModules(tooltip, arg1);
                        end
                    end
                end
            end
        end
        return self.handlers[tooltipDataType]
    end

    function GameTooltipManager:GetItemManager()
        return self:GetHandler(0)   ----Enum.TooltipDataType.Item
    end

    function GameTooltipManager:GetSpellManager()
        return self:GetHandler(1)   ----Enum.TooltipDataType.Spell
    end

    function GameTooltipManager:GetCurrencyManager()
        return self:GetHandler(5)   ----Enum.TooltipDataType.Currency
    end

    function GameTooltipManager:GetMinimapManager()
        local useLeftTextAsArgument = true;
        return self:GetHandler(21, useLeftTextAsArgument)   ----Enum.TooltipDataType.MinimapMouseover
    end
end


do  --SubModuleMixin
--[[
    local SubModule = {};

    function SubModule:ProcessData(tooltip, itemID)
        if self.enabled then

        else
            return false
        end
    end

    function SubModule:GetDBKey()
        return "dbkey"
    end

    function SubModule:SetEnabled(enabled)
        self.enabled = enabled == true
        GameTooltipManager:RequestUpdate();
    end

    function SubModule:IsEnabled()
        return self.enabled == true
    end
--]]
end