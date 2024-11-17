local _, addon = ...
local L = addon.L;
local API = addon.API;

local GetContainerNumSlots = C_Container.GetContainerNumSlots;
local GetItemNameByID = C_Item.GetItemNameByID;
local GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID;
local IsWarbandCompleted = C_QuestLog.IsQuestFlaggedCompletedOnAccount;
local GetHyperlink = addon.TooltipAPI.GetHyperlink;
local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards;
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard;
local CursorHasItem = CursorHasItem;

local EL = CreateFrame("Frame");

EL.ItemNameToQuest = {};

function EL:OnEvent(event, ...)
    self[event](self, ...)
end

function EL:DELETE_ITEM_CONFIRM(itemName, qualityID, bonding, questWarn)
    if questWarn == 1 then
        self.pendingItemName = itemName;
        local questID = self:GetQuesIDtByItemName(itemName);
        if questID then
            self:DisplayQuest(questID);
        else
            self:UpdateBagData();
        end
    end
end

function EL:BANKFRAME_OPENED()
    self.isAtBank = true;
end

function EL:BANKFRAME_CLOSED()
    self.isAtBank = false;
end

function EL:TOOLTIP_DATA_UPDATE(dataInstanceID)
    if dataInstanceID == self.dataInstanceID and self.questID then
        self:DisplayQuest(self.questID);
    end
end

function EL:QUEST_DATA_LOAD_RESULT(questID, success)
    if questID == self.questID and success then
        self:DisplayQuest(questID);
    end
end

function EL:CURSOR_CHANGED()
    if not CursorHasItem() then
        self:HideUI();
    end
end

function EL:HideUI()
    self:UnregisterEvent("TOOLTIP_DATA_UPDATE");
    self:UnregisterEvent("CURSOR_CHANGED");
    self.dataInstanceID = nil;
    self.questID = nil;
    self:DisplayTooltip(nil);
end

function EL:EnableModule(state)
    if state then
        self.enabled = true;
        self:RegisterEvent("DELETE_ITEM_CONFIRM");
        self:RegisterEvent("BANKFRAME_OPENED");
        self:RegisterEvent("BANKFRAME_CLOSED");
        self:SetScript("OnEvent", self.OnEvent);
    elseif self.enabled then
        self.enabled = false;
        self:UnregisterEvent("DELETE_ITEM_CONFIRM");
        self:UnregisterEvent("BANKFRAME_OPENED");
        self:UnregisterEvent("BANKFRAME_CLOSED");
        self:SetScript("OnEvent", nil);
        self:HideUI();
    end
end

local CHARACTER_BAGS = {
    0, 1, 2, 3, 4,
};

local BANK_BAGS = {
    -1, 6, 7, 8, 9, 10, 11, 12,
};

function EL:UpdateBags(bags)
    local GetContainerItemQuestInfo = C_Container.GetContainerItemQuestInfo;
    local GetContainerItemID = C_Container.GetContainerItemID;
    local GetItemInfoInstant = C_Item.GetItemInfoInstant;

    --Conundrum:
    --GetContainerItemQuestInfo returns table - increase RAM usage
    --Alternatively we use GetItemInfoInstant(itemID) to find QuestItem

    local _, itemID, classID, subclassID, info;

    for _, bagIndex in ipairs(bags) do
        for slot = 1, GetContainerNumSlots(bagIndex) do
            itemID = GetContainerItemID(bagIndex, slot);
            if itemID then
                _, _, _, _, _, classID, subclassID = GetItemInfoInstant(itemID);
                if classID == 12 then
                    info = GetContainerItemQuestInfo(bagIndex, slot);
                    if info and info.questID then
                        self:StoreItemQuest(itemID, info.questID);
                    end
                end
            end
        end
    end
end

function EL:UpdateBagData()
    self:UpdateBags(CHARACTER_BAGS);
    if self.isAtBank then
        self:UpdateBags(BANK_BAGS);
    end

    local questID = self:GetQuesIDtByItemName(self.pendingItemName);
    if questID then
        self:DisplayQuest(questID);
    end
end

function EL:OnUpdate_UnregisterDynamicEvents(elapsed)
    self.t = self.t + elapsed;
    if self.t > 1.0 then
        self.t = nil;
        self:SetScript("OnUpdate", nil);
        self:UnregisterEvent("TOOLTIP_DATA_UPDATE");
        self:UnregisterEvent("QUEST_DATA_LOAD_RESULT");
    end
end

function EL:ListenDynamicEvents()
    self:RegisterEvent("CURSOR_CHANGED");
    self:RegisterEvent("TOOLTIP_DATA_UPDATE");
    self:RegisterEvent("QUEST_DATA_LOAD_RESULT");
    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate_UnregisterDynamicEvents);
end

function EL:DisplayQuest(questID)
    self.questID = questID;

    local questName;
    local questLogIndex = GetLogIndexForQuestID(questID);
    local tooltipData = GetHyperlink("quest:"..questID);
    self.dataInstanceID = tooltipData and tooltipData.dataInstanceID or nil;
    self:ListenDynamicEvents();

    local tooltipText;
    if tooltipData and tooltipData.lines then
        local colorizedText;
        for i, line in ipairs(tooltipData.lines) do
            if i == 1 then
                questName = line.leftText;
            else
                if line.leftText then
                    if line.leftText ~= " " or tooltipText ~= nil then
                        if line.leftColor then
                            colorizedText = line.leftColor:WrapTextInColorCode(line.leftText);
                        else
                            colorizedText = line.leftText;
                        end

                        if tooltipText then
                            tooltipText = tooltipText.."\n"..colorizedText
                        else
                            tooltipText = colorizedText;
                        end
                    end
                end
            end
        end
    end

    if tooltipText and IsWarbandCompleted(questID) then
        --QUEST_REWARD_CONTEXT_FONT_COLOR   --350000
        tooltipText = tooltipText .. "\n\n".."|cff88aaff"..ACCOUNT_COMPLETED_QUEST_NOTICE.."|r";
    end

    if not questName then
        C_QuestLog.RequestLoadQuestByID(questID);
    end

    --[[
    if questLogIndex then
        --On quest
        local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
        if numObjectives > 0 then
            local str;
            local text, objectiveType, finished;
            local n = 0;
            for i = 1, numObjectives do
                text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogIndex);
                if text then
                    if str then
                        str = str.."\n".."- "..text;
                    else
                        str = "- "..text;
                    end
                end
            end
            --print(str);
        end
    else
        --Not on quest

    end
    --]]

    --Find Static Popup
    local _G = _G;
    local f, popup;

    for i = 1, 3 do
        f = _G["StaticPopup"..i];
        if f and f:IsShown() and f.which == "DELETE_QUEST_ITEM" then
            popup = f;
            break
        end
    end

    if popup then
        self:DisplayTooltip(popup, questName, tooltipText);
    else
        self:DisplayTooltip(nil);
    end
end

function EL:StoreItemQuest(itemID, questID)
    local itemName = GetItemNameByID(itemID);
    if itemName and itemName ~= "" and questID ~= 0 then
        self.ItemNameToQuest[itemName] = questID;
        return true
    end
end

local SIDE_SPACING = 8;
local TITLE_DESC_GAP = 4;
local MAX_TEXT_WIDTH = 256;

function EL:DisplayTooltip(anchorTo, title, description)
    local f = self.Tooltip;
    if title then
        if not f then
            f = CreateFrame("Frame", nil, UIParent);
            self.Tooltip = f;
            local bg = addon.CreateNineSliceFrame(f, "NineSlice_GenericBox_Black");
            bg:SetCornerSize(8);
            bg:SetFrameLevel(f:GetFrameLevel() - 1);
            bg:SetAllPoints(true);

            f.Title = f:CreateFontString(nil, "OVERLAY", "GameTooltipHeaderText");
            f.Title:SetJustifyH("LEFT");
            f.Title:SetJustifyV("TOP");
            f.Title:SetWidth(MAX_TEXT_WIDTH);
            f.Title:SetPoint("TOPLEFT", f, "TOPLEFT", SIDE_SPACING, -SIDE_SPACING);
            f.Title:SetTextColor(1, 0.82, 0);

            f.Desc = f:CreateFontString(nil, "OVERLAY", "GameTooltipText");
            f.Desc:SetJustifyH("LEFT");
            f.Desc:SetJustifyV("TOP");
            f.Desc:SetWidth(MAX_TEXT_WIDTH);
            f.Desc:SetPoint("TOPLEFT", f.Title, "BOTTOMLEFT", 0, -TITLE_DESC_GAP);
        end

        f.Title:SetText(title);
        f.Desc:SetText(description);

        local textHeight = f.Title:GetHeight() + TITLE_DESC_GAP + f.Desc:GetHeight();
        local textWidth = math.max(f.Title:GetWrappedWidth(), f.Desc:GetWrappedWidth());
        f:SetSize(API.Round(textWidth + 2*SIDE_SPACING), API.Round(textHeight + 2*SIDE_SPACING));
        f:Show();
        f:ClearAllPoints();

        local bottom = anchorTo:GetBottom();
        f:SetPoint("TOP", UIParent, "BOTTOM", 0, bottom - 12);
        --f:SetPoint("TOP", anchorTo, "BOTTOM", 0, -12);
    else
        if f then
            f:Hide();
            f:ClearAllPoints();
        end
    end
end

function EL:GetQuesIDtByItemName(itemName)
    if itemName then
        return self.ItemNameToQuest[itemName]
    end
end

do
    local function EnableModule(state)
        if state then
            EL:EnableModule(true);
        else
            EL:EnableModule(false);
        end
    end


    local moduleData = {
        name = L["ModuleName QuestItemDestroyAlert"],
        dbKey = "QuestItemDestroyAlert",
        description = L["ModuleDescription QuestItemDestroyAlert"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1145,
        moduleAddedTime = 1729500000,
    };

    addon.ControlCenter:AddModule(moduleData);
end