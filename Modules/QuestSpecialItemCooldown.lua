-- Show Quest Special Item's cooldown on the cursor (WoW sometimes change your cursor to the quest item if it can be used on the hovered unit)
-- Unused (IsQuestLogSpecialItemInRange isn't reliable)
-- E.g. "Marmoni in Distress" IsQuestLogSpecialItemInRange return nil for Marmoni but positive for the drakes


local _, addon = ...


local MODULE_ENABLED = true;
local ANY_QUEST_ITEM = true;

local GetCursorPosition = GetCursorPosition;
local IsQuestLogSpecialItemInRange = IsQuestLogSpecialItemInRange;
local GetQuestLogSpecialItemCooldown = GetQuestLogSpecialItemCooldown;      --nil when no QuestItem
local GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID;

local CooldownFrame = CreateFrame("Cooldown", nil, UIParent, "PlumberCursorCooldownTemplate");
CooldownFrame:ClearAllPoints();
CooldownFrame:SetSize(64, 64);
CooldownFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", 0, 0);
CooldownFrame:Hide();
CooldownFrame.t = 0;
CooldownFrame.t1 = 0;
CooldownFrame.anchorTo = UIParent;

local CooldownFrameSize = {
    [-1] = 64,
    [0] = 64,
    [1] = 96,
    [2] = 128,
    [3] = 192,
    [4] = 256,
};

CooldownFrame:SetScript("OnShow", function(self)
    self.scale = self.anchorTo:GetEffectiveScale();
    local cursorSizeIndex = C_CVar.GetCVar("cursorSizePreferred") or 0;
    cursorSizeIndex = tonumber(cursorSizeIndex);
    local frameSize = CooldownFrameSize[cursorSizeIndex] or CooldownFrameSize[0];
    self:SetSize(frameSize, frameSize);
    self.offset = frameSize / 8;
    self:RegisterEvent("CURSOR_CHANGED");
end);

CooldownFrame:SetScript("OnHide", function(self)
    self:UnregisterEvent("CURSOR_CHANGED");
end);

CooldownFrame:SetScript("OnUpdate", function(self, elapsed)
    self.t = self.t + elapsed;
    self.t1 = self.t1 + elapsed;

    if self.t > 0.008 then
        self.t = 0;
        self.x, self.y = GetCursorPosition();
        self:SetPoint("CENTER", self.anchorTo, "BOTTOMLEFT", (self.x + self.offset)/self.scale, (self.y - self.offset)/self.scale);
    end

    if self.t1 > 0.2 then
        self.t1 = 0;
        self:UpdateQuestLogItem();
    end
end);

CooldownFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "CURSOR_CHANGED" then
        self:UpdateQuestLogItem();
    end
end);

CooldownFrame:SetFrameStrata("TOOLTIP");

function CooldownFrame:UpdateQuestLogItem()
    if not self.questLogIndex then
        self:Hide();
        return
    end

    local status = IsQuestLogSpecialItemInRange(self.questLogIndex, "mouseover");
    print(self.questLogIndex, status)
    if status then
        if status == 1 then
            local start, duration, enable = GetQuestLogSpecialItemCooldown(self.questLogIndex);
            print(start, duration, enable)
            if enable == 1 and start and start > 0 and duration and duration > 0 then
                self:SetCooldown(start, duration);
                return
            end
        end
    else
        self:Hide();
    end
end

local function Post_GetWorldCursor(tooltip, tooltipData)
    if MODULE_ENABLED and ANY_QUEST_ITEM and tooltipData.lines then
        local questLogIndex;
        for i, line in ipairs(tooltipData.lines) do
            if i > 1 then
                if line.type == 17 then         --Enum.TooltipDataLineType.QuestTitle  (id = QuestID, leftText = QuestName)
                    if line.id then
                        questLogIndex = GetLogIndexForQuestID(line.id);
                        CooldownFrame.questLogIndex = questLogIndex;
                        CooldownFrame:UpdateQuestLogItem();
                        return
                    end
                --elseif line.type == 8 then      --Enum.TooltipDataLineType.QuestObjective  (completed = boolean)

                end
            end
        end
        CooldownFrame:Hide();
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Object, Post_GetWorldCursor);
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, Post_GetWorldCursor);


--[[
    GetQuestLogSpecialItemCooldown
    GetQuestLogSpecialItemInfo
    Enum.TooltipDataLineType
--]]