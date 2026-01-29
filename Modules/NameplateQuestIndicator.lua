local _, addon = ...


local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;
local GetNamePlates = C_NamePlate.GetNamePlates;
--local UnitIsRelatedToActiveQuest = C_QuestLog.UnitIsRelatedToActiveQuest;
local GetUnitTooltipInfo = C_TooltipInfo.GetUnit;
local UnitIsPlayer = UnitIsPlayer;
local UnitIsUnit = UnitIsUnit;


local LineType = {
    QuestObjective = Enum.TooltipDataLineType.QuestObjective,
    QuestTitle = Enum.TooltipDataLineType.QuestTitle,
    QuestPlayer = Enum.TooltipDataLineType.QuestPlayer,
};


local Def = {
    IconSize = 20,
    ShowPartyProgress = true,
};


local EL = CreateFrame("Frame", nil, UIParent);


local WidgetPool;
local CreateQuestWidget;
local InitializeWidgetPool;


local match = string.match;
local function GetProgressText(str)
    if str then
        local text = match(str, "%d+/%d+");
        if not text then
            text = match(str, "%d+%%");
        end
        return text
    end
end


do  --Widget
    local QuestWidgetMixin = {};
    local PLAYER_NAME = UnitName("player");

    function QuestWidgetMixin:UpdateQuest()
        self.questID = nil;

        if self.unit then
            local tooltipInfo = GetUnitTooltipInfo(self.unit);
            local lines = tooltipInfo and tooltipInfo.lines;

            if lines then
                local l;
                local allCompleted = true;
                local questID;
                local i = 3;
                local numLines = #lines;
                local objectiveText;
                local fromAnotherPlayer;

                while i <= numLines do
                    l = lines[i];
                    if l.type == LineType.QuestTitle then
                        questID = l.id;
                        allCompleted = true;
                        i = i + 1;
                    elseif l.type == LineType.QuestPlayer then
                        local isPlayer = l.leftText == PLAYER_NAME;
                        i = i + 1;
                        l = lines[i];
                        if l then
                            while l and l.type == LineType.QuestObjective do
                                if (not l.completed) and (isPlayer or Def.ShowPartyProgress) then
                                    allCompleted = false;
                                    objectiveText = l.leftText;
                                    if not isPlayer then
                                        fromAnotherPlayer = true;
                                    end
                                    break
                                end
                                i = i + 1;
                                l = lines[i];
                            end
                        end
                    elseif l.type == LineType.QuestObjective then
                        if not l.completed then
                            allCompleted = false;
                            objectiveText = l.leftText;
                            break
                        end
                        i = i + 1;
                    else
                        i = i + 1;
                    end
                end

                self.questID = questID;

                if not allCompleted then
                    local text = GetProgressText(objectiveText);
                    self.ProgressText:SetText(text);
                    self.hasProgress = text ~= nil;

                    if fromAnotherPlayer then
                        --self.Icon:SetTexCoord(0.25, 0.5, 0, 0.25);
                        self.Icon:SetTexCoord(0.5, 1, 0, 0.5);
                        self.ProgressText:SetTextColor(0.67, 0.67, 0.67);
                    else
                        --self.Icon:SetTexCoord(0, 0.25, 0, 0.25);
                        self.Icon:SetTexCoord(0, 0.5, 0.25, 0.75);
                        self.ProgressText:SetTextColor(1, 1, 1);
                    end

                    return
                end
            end
        end

        self.ProgressText:SetText(nil);
        self.Icon:SetTexCoord(0.75, 1, 0.75, 1);
    end

    function QuestWidgetMixin:UpdateTarget()
        if UnitIsUnit("target", self.unit) then
            self:UpdateQuest();
            if self.hasProgress then
                self.Icon:Hide();
                self.ProgressText:Show();
            end
            return true
        end
        self.Icon:Show();
        self.ProgressText:Hide();
        return false
    end

    function QuestWidgetMixin:OnHide()
        self.questID = nil;
        self.unit = nil;
        self:Hide();
        self:ClearAllPoints();
        self:SetParent(EL);
        WidgetPool[self] = false;
    end

    function QuestWidgetMixin:SetOwnerInfo(owner, unit)
        self.unit = unit or owner.unit;
        self.owner = owner;
        if not self:UpdateTarget() then
            self:UpdateQuest();
        end
    end


    function CreateQuestWidget()
        local f = CreateFrame("Frame", nil, EL);
        f:SetSize(Def.IconSize, Def.IconSize);
        Mixin(f, QuestWidgetMixin);
        f:SetScript("OnHide", f.OnHide);

        f.Icon = f:CreateTexture(nil, "OVERLAY");
        f.Icon:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.Icon:SetSize(Def.IconSize, Def.IconSize);
        f.Icon:SetTexture("Interface/AddOns/Plumber/Art/Frame/NameplateQuest.png", nil, nil, "TRILINEAR");
        f.Icon:SetTexCoord(0, 0.25, 0, 0.25);
        addon.API.DisableSharpening(f.Icon);

        f.ProgressText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
        f.ProgressText:SetPoint("LEFT", f, "LEFT", 4, 0);
        f.ProgressText:SetTextColor(1, 1, 1);
        f.ProgressText:Hide();

        WidgetPool[f] = false;

        return f
    end

    function InitializeWidgetPool()
        WidgetPool = {};
    end
end


do  --Event Listener
    function EL:GetUnitQuestObjectiveFromTooltip(unit)
        local tooltipInfo = GetUnitTooltipInfo(unit);
        local lines = tooltipInfo and tooltipInfo.lines;
        if lines then
            local line;
            for i = 3, #lines do
                line = lines[i];
                if line.type == LineType.QuestObjective and not line.completed then
                    return GetProgressText(line.leftText);
                end
            end
        end
    end

    function EL:UpdateNameplateForUnit(unit)
        if not unit then return end;
        if UnitIsPlayer(unit) then return end;

        local nameplate = GetNamePlateForUnit(unit);
        if nameplate and not nameplate:IsForbidden() then
            self:AttachQuestMarkerToNameplate(nameplate, unit);
        end
    end

    function EL:AttachQuestMarkerToNameplate(nameplate, unit)
        local UnitFrame = nameplate.UnitFrame;
        if not UnitFrame then return end;

        local widget = UnitFrame.PlumberQuestIndicator;

        if not widget then
            widget = CreateQuestWidget();
            UnitFrame.PlumberQuestIndicator = widget;
        end

        widget:SetOwnerInfo(UnitFrame, unit);
        widget:SetParent(nameplate);
        widget:UpdateQuest();

        if UnitFrame.HealthBarsContainer and UnitFrame.HealthBarsContainer:IsShown() and UnitFrame.HealthBarsContainer.healthBar then
            widget:SetPoint("LEFT", UnitFrame.HealthBarsContainer.healthBar, "RIGHT", 0, 0);
        else
            widget:SetPoint("LEFT", UnitFrame, "RIGHT", 0, 0);
        end

        widget:Show();
        WidgetPool[widget] = true;
    end

    function EL:UpdateAllNameplates()
        local nameplates = GetNamePlates(false);
        if nameplates then
            for _, nameplate in ipairs(nameplates) do
                if nameplate.UnitFrame then
                    self:UpdateNameplateForUnit(nameplate.UnitFrame.unit);
                end
            end
        end
    end

    local pairs = pairs;

    function EL:UpdateQuestWidgets()
        for widget, shown in pairs(WidgetPool) do
            if shown then
                widget:UpdateQuest();
            end
        end
    end

    function EL:OnTargetChanged()
        for widget, shown in pairs(WidgetPool) do
            if shown then
                widget:UpdateTarget();
            end
        end
    end

    function EL:RequestUpdateQuest()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function EL:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.2 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            self:UpdateQuestWidgets();
        end
    end

    function EL:OnEvent(event, ...)
        if event == "NAME_PLATE_UNIT_ADDED" then
            self:UpdateNameplateForUnit(...);
        elseif event == "PLAYER_TARGET_CHANGED" then
            self:OnTargetChanged();
        elseif event == "UNIT_QUEST_LOG_CHANGED" or event == "GROUP_ROSTER_UPDATE" then
            self:RequestUpdateQuest();
        end
    end
end


function EL:EnableModule(state)
    if state then
        self.enabled = true;
        if not WidgetPool then
            InitializeWidgetPool();
        end
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
        self:RegisterEvent("PLAYER_TARGET_CHANGED");
        self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
        self:RegisterEvent("GROUP_ROSTER_UPDATE");
        self:SetScript("OnEvent", self.OnEvent);
        self:UpdateAllNameplates();
    elseif self.enabled then
        self.enabled = nil;
        if WidgetPool then
            for widget in pairs(WidgetPool) do
                widget:Hide();
            end
        end
        self:UnregisterEvent("NAME_PLATE_UNIT_ADDED");
        self:UnregisterEvent("PLAYER_TARGET_CHANGED");
        self:UnregisterEvent("UNIT_QUEST_LOG_CHANGED");
        self:UnregisterEvent("GROUP_ROSTER_UPDATE");
        self:SetScript("OnEvent", nil);
        self:SetScript("OnUpdate", nil);
    end
end


do
    local moduleData = {
        name = addon.L["ModuleName NameplateQuest"],
        dbKey = "NameplateQuest",
        description = addon.L["ModuleDescription NameplateQuest"],
        toggleFunc = function(state)
            EL:EnableModule(state)
        end,
        moduleAddedTime = 1769700000,
        categoryKeys = {
            "UnitFrame",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end
