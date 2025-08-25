local _, addon = ...
local GameTooltipItemManager = addon.GameTooltipManager:GetItemManager();

local GetFactionStatusText = addon.API.GetFactionStatusText;
local GetFactionGrantedByItem = addon.GetFactionGrantedByItem;


local ItemSubModule = {};
do
    function ItemSubModule:ProcessData(tooltip, itemID)
        if self.enabled then
            local factionID = GetFactionGrantedByItem(itemID);
            if factionID then
                if type(factionID) == "table" then
                    tooltip:AddLine(" ");
                    local showFactionName = true;
                    for _, id in ipairs(factionID) do
                        local factionStatus = GetFactionStatusText(id, nil, showFactionName);
                        if factionStatus then
                            tooltip:AddLine(factionStatus);
                        end
                    end
                    return true
                else
                    local factionStatus = GetFactionStatusText(factionID);
                    if factionStatus then
                        tooltip:AddLine(factionStatus);
                        return true
                    end
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
        self.enabled = enabled == true;
        GameTooltipItemManager:RequestUpdate();
    end

    function ItemSubModule:IsEnabled()
        return self.enabled == true
    end
end


local GameTooltipQuestCurrencyManager = {};
do
    local GetFactionGrantedByCurrency = C_CurrencyInfo.GetFactionGrantedByCurrency;
    local GetQuestOfferCurrencyInfo = C_QuestOffer.GetQuestRewardCurrencyInfo;
    local GetQuestLogCurrencyInfo = C_QuestLog.GetQuestRewardCurrencyInfo;

    local function SetupTooltipByCurrency(tooltip, currencyID)
        local factionID = GetFactionGrantedByCurrency(currencyID);
        if factionID then
            local factionStatus = GetFactionStatusText(factionID);
            if factionStatus then
                tooltip:AddLine(factionStatus);
                tooltip:Show();
            end
        end
    end

    function GameTooltipQuestCurrencyManager:SetEnabled(state)
        self.enabled = state;
        if state then
            if not self.hooked then
                self.hooked = true;

                hooksecurefunc(GameTooltip, "SetQuestLogCurrency", function(tooltip, type, id)
                    if not self.enabled then return end;
                    local questID = QuestMapFrame.DetailsFrame.questID;
                    if questID then
                        local isChoice = type == "choice";
                        local info = GetQuestLogCurrencyInfo(questID, id, isChoice);
                        if info and info.currencyID then
                            SetupTooltipByCurrency(tooltip, info.currencyID);
                        end
                    end
                end);

                hooksecurefunc(GameTooltip, "SetQuestCurrency", function(tooltip, type, id)
                    if not self.enabled then return end;
                    local info = GetQuestOfferCurrencyInfo(type, id);
                    if info and info.currencyID then
                        SetupTooltipByCurrency(tooltip, info.currencyID);
                    end
                end);
            end
        end
    end
end


do
    local function EnableModule(state)
        ItemSubModule:SetEnabled(state);
        GameTooltipQuestCurrencyManager:SetEnabled(state);
        if state then
            GameTooltipItemManager:AddSubModule(ItemSubModule);
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