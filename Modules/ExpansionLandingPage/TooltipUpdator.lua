local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;


local iparis = ipairs;


local TooltipUpdator = CreateFrame("Frame");
TooltipUpdator:Hide();
LandingPageUtil.TooltipUpdator = TooltipUpdator;


local function Tooltip_AddRewardLine(tooltip, texture, text, quality, quantity)
    local r, g, b = ColorManager.GetColorDataForItemQuality(quality).color:GetRGB();
    tooltip:AddDoubleLine(string.format("|T%s:%d:%d:%d:%d|t %s", texture, 16, 16, 0, 0, text), quantity, r, g, b, 1, 1, 1);
end


function TooltipUpdator:StopUpdating()
    if self.t then
        self.t = nil;
        self:SetScript("OnUpdate", nil);
    end

    self.keepUpdating = nil;
    self.questID = nil;
    self.headerText = nil;
    self.showProgress = nil;
    self.showRewards = nil;
    self.poiID = nil;
    self.tooltipLines = nil;
    self.tooltipSetter = nil;
    self.entryChildren = nil;
end

function TooltipUpdator:SetFocusedObject(obj)
    self:StopUpdating();
    if obj then
        self.obj = obj;
        self.t = 0.3;
        self:SetParent(obj);
        self:Show();
        self:SetScript("OnUpdate", self.OnUpdate);
    end
end

function TooltipUpdator:SetHeaderText(headerText)
    self.headerText = headerText;
end

function TooltipUpdator:SetQuestID(questID)
    self.questID = questID;
end

function TooltipUpdator:RequestQuestProgress()
    self.showProgress = true;
end

function TooltipUpdator:RequestQuestReward()
    self.showRewards = true;
end

function TooltipUpdator:RequestEventTimer(poiID)
    self.poiID = poiID;
end

function TooltipUpdator:RequestTooltipLines(tooltipLines)
    self.tooltipLines = tooltipLines;
end

function TooltipUpdator:RequestTooltipSetter(tooltipSetter)
    self.tooltipSetter = tooltipSetter;
end

function TooltipUpdator:RequestEntryChildren(entryChildren)
    self.entryChildren = entryChildren;
end

function TooltipUpdator:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0.5 then
        self.t = 0;
        self:SetScript("OnUpdate", nil);
        self.keepUpdating = nil;

        if self.obj and self.obj:IsMouseMotionFocus() and (self.questID or self.tooltipLines or self.entryChildren) then
            local anyContent;
            local questRewards = {};
            local isRetrievingData;
            local tooltipLines = {};
            local hasLineAbove = false;

            if self.questID then
                self.keepUpdating = true;
            end

            if self.showProgress then
                local texts = API.GetQuestProgressTexts(self.questID);
                if texts then
                    anyContent = true;
                    tooltipLines = texts;
                end
                self.keepUpdating = true;
            end

            if self.showRewards then
                local rewards, missingData = API.GetQuestRewards(self.questID);
                if rewards then
                    anyContent = true;
                    if rewards.items then
                        table.insert(questRewards, rewards.items);
                    end
                    if rewards.currencies then
                        table.insert(questRewards, rewards.currencies);
                    end
                end

                if missingData then
                    isRetrievingData = true;
                end

                self.keepUpdating = true;
            end

            if self.tooltipLines then
                anyContent = true;
                local n = #tooltipLines;
                for i, text in ipairs(self.tooltipLines) do
                    tooltipLines[n + i] = text;
                end
            end

            if anyContent and self.headerText then
                local tooltip = GameTooltip;
                --tooltip:SetOwner(self.obj, "ANCHOR_CURSOR_RIGHT", 8, 8);
                tooltip:SetOwner(self.obj, "ANCHOR_NONE");
                tooltip:SetPoint("TOPLEFT", self.obj, "TOPRIGHT", 4, 12);

                tooltip:SetText(self.headerText, 1, 0.82, 0, true);

                if self.entryChildren then
                    for k, v in iparis(self.entryChildren) do
                        local name;
                        if v.questID then
                            name = API.GetQuestName(v.questID) or "";
                            if (v.accountWide and C_QuestLog.IsQuestFlaggedCompletedOnAccount(v.questID)) or (not v.accountWide and C_QuestLog.IsQuestFlaggedCompleted(v.questID)) then
                                tooltip:AddLine("- "..name, 0.251, 0.753, 0.251, false);
                            else
                                tooltip:AddLine("- "..name, 0.5, 0.5, 0.5, false);
                            end
                        end
                    end
                    self.keepUpdating = true;
                    hasLineAbove = true;
                end

                if tooltipLines[1] then
                    hasLineAbove = true;
                    for _, text in ipairs(tooltipLines) do
                        tooltip:AddLine(text, 1, 1, 1, true);
                    end
                end

                if questRewards[1] then
                    if hasLineAbove then
                        tooltip:AddLine(" ");
                    end
                    tooltip:AddLine(QUEST_REWARDS, 1, 0.82, 0);

                    for _, rewards in ipairs(questRewards) do
                        for index, info in ipairs(rewards) do
                            Tooltip_AddRewardLine(tooltip, info.texture, info.name, info.quality, info.quantity);
                        end
                    end
                end

                if self.tooltipSetter then
                    local loaded, keepUpdating = self.tooltipSetter(tooltip);
                    if not loaded then
                        isRetrievingData = true;
                    end
                    if keepUpdating then
                        self.keepUpdating = true;
                    end
                end

                if isRetrievingData then
                    tooltip:AddLine(RETRIEVING_DATA, 0.5, 0.5, 0.5, true);
                    self.keepUpdating = true;
                end

                tooltip:Show();
            end

            if self.keepUpdating then
                self:SetScript("OnUpdate", self.OnUpdate);
            end
        end
    end
end

function TooltipUpdator:OnHide()
    self:StopUpdating();
end