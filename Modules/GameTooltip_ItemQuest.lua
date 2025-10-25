local _, addon = ...
local L = addon.L;
local API = addon.API;
local IsShiftKeyDown = IsShiftKeyDown;
local InCombatLockdown = InCombatLockdown;
local GameTooltipItemManager = addon.GameTooltipManager:GetItemManager();
local GetContainerItemQuestInfo = C_Container.GetContainerItemQuestInfo;
local GetItemInfoInstant = C_Item.GetItemInfoInstant;


local TextureInfoTable = {
    width = 14,
    height = 14,
    margin = { left = 0, right = 0, top = 0, bottom = 0 },
    texCoords = { left = 0, right = 1, top = 0, bottom = 1 },
};


local ItemSubModule = {};
do
    local function DressUpItemLocation_Callback(itemLocation)
        if (not ItemSubModule:IsEnabled()) or InCombatLockdown() then return end;

        if itemLocation and itemLocation.bagID and itemLocation.slotIndex then
            --Verifiy the IDs and see if they match the current tooltip
            --In case DressUpItemLocation is called from an unaccounted source
            local itemQuestInfo = GetContainerItemQuestInfo(itemLocation.bagID, itemLocation.slotIndex);
            if itemQuestInfo and itemQuestInfo.questID then
                local tooltip = GameTooltip;
                local info = tooltip:IsShown() and tooltip.processingInfo;
                if info and info.getterName == "GetBagItem" and info.getterArgs and (itemLocation.bagID == info.getterArgs[1]) and (itemLocation.slotIndex == info.getterArgs[2]) then
                    if C_QuestLog.GetLogIndexForQuestID(itemQuestInfo.questID) then
                        C_Map.OpenWorldMap();
                        QuestMapFrame_ShowQuestDetails(itemQuestInfo.questID);
                    end
                end
            end
        end
    end

    function ItemSubModule:ProcessData(tooltip, itemID)
        --Added Info:
        -- Quest Title
        -- IsOnQuest, ReadyForTurnIn
        -- Descriptions
        -- Extra info when pressing SHIFT
        -- Ctrl+Click Instruction


        if self.enabled then
            local _, _, _, _, _, classID, subClassID = GetItemInfoInstant(itemID);
            if classID == 12 then
                local info = tooltip.processingInfo;
                if info and info.getterName == "GetBagItem" and info.getterArgs then
                    local bag, slot = info.getterArgs[1], info.getterArgs[2];
                    if bag and slot then
                        local itemQuestInfo = GetContainerItemQuestInfo(bag, slot);
                        local questID = itemQuestInfo and itemQuestInfo.questID;
                        if questID then
                            --isQuestItem (false for item that starts a quest), questID, isActive
                            local title = API.GetQuestName(questID);
                            local desc = API.GetDescriptionFromTooltip(questID);
                            if title then
                                tooltip:AddLine(" ");
                                tooltip:AddLine(title, 1, 0.82, 0, true);
                                tooltip:AddTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/TrackerType-Quest.png", TextureInfoTable);

                                local progressAdded = true;
                                if C_QuestLog.IsOnQuest(questID) then
                                    if C_QuestLog.ReadyForTurnIn(questID) then
                                        tooltip:AddLine(QUEST_WATCH_QUEST_READY, 0.098, 1.000, 0.098, true);
                                    else
                                        tooltip:AddLine(QUEST_TOOLTIP_ACTIVE, 0.098, 1.000, 0.098, true);
                                    end
                                else
                                    if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                                        tooltip:AddLine(QUEST_COMPLETE, 0.5, 0.5, 0.5, true);
                                    else
                                        progressAdded = false;
                                    end
                                end

                                if desc then
                                    if progressAdded then
                                        tooltip:AddLine(" ");
                                    end
                                    tooltip:AddLine(desc, 1, 1, 1, true);
                                end

                                if IsShiftKeyDown() then
                                    tooltip:AddLine(" ");
                                    tooltip:AddDoubleLine("QuestID", questID, 1, 0.82, 0, 1, 1, 1);
                                end

                                if C_QuestLog.GetLogIndexForQuestID(questID) and not InCombatLockdown() then
                                    tooltip:AddLine(" ");
                                    tooltip:AddLine(L["Instruction Show In Quest Log"], 0.098, 1.000, 0.098, true);
                                end

                                return true
                            end
                        end
                    end
                end
            end
        else
            return false
        end
    end

    function ItemSubModule:GetDBKey()
        return "TooltipItemQuest"
    end

    function ItemSubModule:SetEnabled(enabled)
        self.enabled = enabled == true;
        GameTooltipItemManager:RequestUpdate();
        if not self.functionHooked then
            self.functionHooked = true;
            hooksecurefunc("DressUpItemLocation", DressUpItemLocation_Callback);
        end
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
        name = addon.L["ModuleName TooltipItemQuest"],
        dbKey = ItemSubModule:GetDBKey(),
        description = addon.L["ModuleDescription TooltipItemQuest"],
        toggleFunc = EnableModule,
        categoryID = 3,
        uiOrder = 1200,
        moduleAddedTime = 1755200000,
    };

    addon.ControlCenter:AddModule(moduleData);
end