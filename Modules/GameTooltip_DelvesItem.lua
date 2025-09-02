local _, addon = ...
local L = addon.L;
local AddTextureToTooltip = addon.API.AddTextureToTooltip;
local GameTooltipItemManager = addon.GameTooltipManager:GetItemManager();
local WeeklyRewardsConstant = addon.WeeklyRewardsConstant;


local DataProvider = {};
do
    DataProvider.DelvesNemesisSummonItem = 248017;  --Shrieking Quartz

    function DataProvider:Init()
        self.Init = nil;

        self.Chests1 = {};
        self.Chests2 = {};

        for _, itemID in ipairs(WeeklyRewardsConstant.MajorChests) do
            self.Chests1[itemID] = true;
        end

        for _, itemID in ipairs(WeeklyRewardsConstant.MinorChests) do
            self.Chests2[itemID] = true;
        end
    end

    function DataProvider:SetWeeklyKeyTooltip(tooltip, isDialogueUI)
        local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted;
        local n = 0;
        for _, questID in ipairs(WeeklyRewardsConstant.CofferKeyFlags) do
            if IsQuestFlaggedCompleted(questID) then
                n = n + 1;
            end
        end
        tooltip:AddLine(" ");
        if n >= 4 then
            tooltip:AddLine(L["Weekly Cap Reached"], 0.5, 0.5, 0.5);
        else
            tooltip:AddDoubleLine(L["Restored Coffer Key"], string.format("%d/%d", n, 4), 1, 1, 1, 1, 1, 1);
            if isDialogueUI then
                tooltip:AddTexture(4622270);
            else
                AddTextureToTooltip(tooltip, 4622270);
            end
        end
    end

    function DataProvider:SetWeeklyShardTooltip(tooltip, isDialogueUI)
        local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted;
        local n = 0;
        for _, questID in ipairs(WeeklyRewardsConstant.CofferKeyShardFlags) do
            if IsQuestFlaggedCompleted(questID) then
                n = n + 1;
            end
        end
        tooltip:AddLine(" ");
        if n >= 4 then
            tooltip:AddLine(L["Weekly Cap Reached"], 0.5, 0.5, 0.5);
        else
            tooltip:AddDoubleLine(string.format("%s x50", L["Coffer Key Shard"], 50), string.format("%d/%d", n, 4), 1, 1, 1, 1, 1, 1);
            if isDialogueUI then
                tooltip:AddTexture(133016);
            else
                AddTextureToTooltip(tooltip, 133016);
            end
        end
    end

    function DataProvider:SetNemesisSummonItem(tooltip)
        local flagQuest = 86371;
        if C_QuestLog.IsQuestFlaggedCompleted(flagQuest) then
            local rewardItemID = 233071;    --Delver's Bounty
            local itemName = C_Item.GetItemNameByID(rewardItemID);
            if not itemName then
                itemName = "item:"..rewardItemID;
            end
            tooltip:AddLine(" ");
            tooltip:AddLine(string.format(L["You Have Received Weekly Item Format"], itemName), 0.5, 0.5, 0.5, true);
            return true
        end
    end
end


local function ProcessItemTooltip(tooltip, itemID, itemLink, isDialogueUI)
    if DataProvider.Chests1[itemID] then
        DataProvider:SetWeeklyKeyTooltip(tooltip, isDialogueUI);
        return true
    elseif DataProvider.Chests2[itemID] then
        DataProvider:SetWeeklyShardTooltip(tooltip, isDialogueUI);
        return true
    elseif itemID == DataProvider.DelvesNemesisSummonItem then
        return DataProvider:SetNemesisSummonItem(tooltip);
    end
    return false
end


local ItemSubModule = {};
do
    function ItemSubModule:ProcessData(tooltip, itemID)
        if self.enabled then
            return ProcessItemTooltip(tooltip, itemID)
        else
            return false
        end
    end

    function ItemSubModule:GetDBKey()
        return "TooltipDelvesItem"
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
    local function ProcessItemTooltip_DialogueUI(tooltip, itemID, itemLink)
        return ProcessItemTooltip(tooltip, itemID, itemLink, true)
    end

    local function EnableModule(state)
        if DataProvider.Init then
            DataProvider:Init();
        end

        ItemSubModule:SetEnabled(state);
        if state then
            GameTooltipItemManager:AddSubModule(ItemSubModule);
        end

        if DialogueUIAPI and DialogueUIAPI.AddItemTooltipProcessorExternal then
            DialogueUIAPI.AddItemTooltipProcessorExternal(ProcessItemTooltip_DialogueUI);
        end
    end

    local moduleData = {
        name = addon.L["ModuleName TooltipDelvesItem"],
        dbKey = ItemSubModule:GetDBKey(),
        description = addon.L["ModuleDescription TooltipDelvesItem"],
        toggleFunc = EnableModule,
        categoryID = 3,
        uiOrder = 1200,
        moduleAddedTime = 1755200000,
    };

    addon.ControlCenter:AddModule(moduleData);
end