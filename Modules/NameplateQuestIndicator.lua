local _, addon = ...
local L = addon.L;


local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;
local GetNamePlates = C_NamePlate.GetNamePlates;
local UnitIsRelatedToActiveQuest = C_QuestLog.UnitIsRelatedToActiveQuest;
local GetUnitTooltipInfo = C_TooltipInfo.GetUnit;
local UnitIsPlayer = UnitIsPlayer;
local UnitIsUnit = UnitIsUnit;
local GetInstanceInfo = GetInstanceInfo;


local LineType = {
    QuestObjective = Enum.TooltipDataLineType.QuestObjective,
    QuestTitle = Enum.TooltipDataLineType.QuestTitle,
    QuestPlayer = Enum.TooltipDataLineType.QuestPlayer,
};


local Def = {
    IconSize = 18,
    ShowPartyQuest = true,
    ShowTargetProgress = false,
    AnchorToHealthBar = true,
    Align = "right",
};


local EL = CreateFrame("Frame", nil, UIParent);


local WidgetPool;
local CreateQuestWidget;
local InitializeWidgetPool;
local EditorFrame;
local LoadSettings;


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
            if EL.inInstance then
                self.hasProgress = false;
                self.ProgressText:SetText(nil);
                if UnitIsRelatedToActiveQuest(self.unit) then
                    self.Icon:SetTexCoord(0, 0.5, 0.25, 0.75);
                    return
                end
            else
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
                                    if (not l.completed) and (isPlayer or Def.ShowPartyQuest) then
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
                        local text = Def.ShowTargetProgress and GetProgressText(objectiveText) or nil;
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
        end

        self.ProgressText:SetText(nil);
        self.Icon:SetTexCoord(0.75, 1, 0.75, 1);
    end

    function QuestWidgetMixin:UpdateTarget()
        if UnitIsUnit("target", self.unit) and Def.ShowTargetProgress then
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

    function QuestWidgetMixin:SetOrientation(orientation)
        if orientation ~= self.orientation then
            self.orientation = orientation;
            self.ProgressText:ClearAllPoints();
            if orientation == "left" then
                self.ProgressText:SetPoint("RIGHT", self, "RIGHT", -2, 0);
            else
                self.ProgressText:SetPoint("LEFT", self, "LEFT", 0, 0);
            end
        end
    end

    function QuestWidgetMixin:SetIconSize(size)
        self:SetWidth(size * 0.5);
        self.Icon:SetSize(size, size);
    end

    function QuestWidgetMixin:UpdateLayout()
        self:SetIconSize(Def.IconSize);
    end


    function CreateQuestWidget()
        local f = CreateFrame("Frame", nil, EL);
        f:SetSize(16, 16);
        Mixin(f, QuestWidgetMixin);
        f:SetScript("OnHide", f.OnHide);

        f.Icon = f:CreateTexture(nil, "OVERLAY");
        f.Icon:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.Icon:SetSize(Def.IconSize, Def.IconSize);
        f.Icon:SetTexture("Interface/AddOns/Plumber/Art/Frame/NameplateQuest.png", nil, nil, "TRILINEAR");
        f.Icon:SetTexCoord(0, 0.25, 0, 0.25);
        addon.API.DisableSharpening(f.Icon);

        f:SetIconSize(Def.IconSize);

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
        widget:ClearAllPoints();

        if Def.AnchorToHealthBar then
            local relativeTo = UnitFrame.AurasFrame.CrowdControlListFrame;
            --local relativeTo = UnitFrame.HealthBarsContainer.healthBar;
            widget:SetPoint("LEFT", relativeTo, "RIGHT", -2, 0);
            widget:SetOrientation("right");
        else
            widget:SetPoint("RIGHT", UnitFrame, "LEFT", 0, 0);
            widget:SetOrientation("left");
        end

        widget:UpdateLayout();
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
        elseif event == "PLAYER_ENTERING_WORLD" then
            self:UpdateZone();
        end
    end

    function EL:UpdateAnchorForAddOns()
        local addonNames = {"Platynator", "Plater"};

        for _, name in ipairs(addonNames) do
            if C_AddOns.IsAddOnLoaded(name) then
                Def.AnchorToHealthBar = false;
                break
            end
        end
    end

    local DangerousInstanceType = {
        party = true,
        raid = true,
        arena = true,
        pvp = true,
    };

    function EL:UpdateZone()
        local _, instanceType = GetInstanceInfo();
        local inInstance = instanceType and DangerousInstanceType[instanceType] or false;
        self.inInstance = inInstance;
        self:UnregisterEvent("UNIT_QUEST_LOG_CHANGED");

        if (not inInstance) and Def.ShowTargetProgress then
            self:RegisterEvent("PLAYER_TARGET_CHANGED");
        else
            self:UnregisterEvent("PLAYER_TARGET_CHANGED");
        end

        if (not inInstance) and Def.ShowPartyQuest then
            self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
            self:RegisterEvent("GROUP_ROSTER_UPDATE");
        else
            self:RegisterUnitEvent("UNIT_QUEST_LOG_CHANGED", "player");
            self:UnregisterEvent("GROUP_ROSTER_UPDATE");
        end
    end
end


local AcquireEditorFrame;
do  --Editor
    local EditorFrameMixin = {};

    function EditorFrameMixin:OnShow()
        self:Update();
    end

    function EditorFrameMixin:OnHide()
        self.t = 0;
        self:SetScript("OnUpdate", nil);
    end

    function EditorFrameMixin:OnUpdate(elapsed)

    end

    function EditorFrameMixin:Update()

    end

    function AcquireEditorFrame()
        if not EditorFrame then
            EditorFrame = CreateFrame("Frame");
            Mixin(EditorFrame, EditorFrameMixin);
            EditorFrame:SetSize(192, 96);

            EditorFrame:SetScript("OnShow", EditorFrame.OnShow);
            EditorFrame:SetScript("OnHide", EditorFrame.OnHide);
            EditorFrame:OnShow();
        end

        return EditorFrame
    end
end


local OptionToggle_OnClick;
do  --Options
    local Options = {
        IconSize = {16, 18, 20, 22, 24, 28, 32};
    };

    function LoadSettings()
        local sizeIndex = addon.GetDBValue("NameplateQuest_IconSize");
        if not (sizeIndex and Options.IconSize[sizeIndex]) then
            sizeIndex = 2;
        end
        local size = Options.IconSize[sizeIndex]
        Def.IconSize = size;


        Def.ShowPartyQuest = addon.GetDBBool("NameplateQuest_ShowPartyQuest");
        Def.ShowTargetProgress = addon.GetDBBool("NameplateQuest_ShowTargetProgress");

        EL:UpdateZone();
        EL:UpdateAllNameplates();

        if EditorFrame and EditorFrame:IsShown() then
            EditorFrame:Update();
        end
    end

    local function Checkbox_OnClick()
        LoadSettings();
    end

    local function Tooltip_ShowPartyQuest()
        local icon = "|TInterface/AddOns/Plumber/Art/Frame/NameplateQuest.png:24:24:0:0:128:128:32:64:0:32|t";
        return L["NameplateQuest ShowPartyQuest Tooltip"]:format(icon);
    end


    local function Options_IconSizeSlider_FormatValue(value)
        return Options.IconSize[value] or Def.IconSize
    end

    local function Options_IconSizeSlider_OnValueChanged(value)
        addon.SetDBValue("NameplateQuest_IconSize", value);
        LoadSettings();
    end

    local OPTIONS_SCHEMATIC = {
        title = L["ModuleName NameplateQuest"],
        widgets = {
            {type = "Custom", onAcquire = AcquireEditorFrame, align = "center"},
            {type = "Slider", label = L["Icon Size"], minValue = 1, maxValue = #Options.IconSize, valueStep = 1, onValueChangedFunc = Options_IconSizeSlider_OnValueChanged, formatValueFunc = Options_IconSizeSlider_FormatValue, dbKey = "NameplateQuest_IconSize"},
            {type = "Checkbox", label = L["NameplateQuest ShowPartyQuest"], onClickFunc = Checkbox_OnClick, dbKey = "NameplateQuest_ShowPartyQuest", tooltip = Tooltip_ShowPartyQuest, restrictionInstance = true},
            {type = "Checkbox", label = L["NameplateQuest ShowTargetProgress"], onClickFunc = Checkbox_OnClick, dbKey = "NameplateQuest_ShowTargetProgress", tooltip = L["NameplateQuest ShowTargetProgress Tooltip"], restrictionInstance = true},
            {type = "Checkbox", label = L["NameplateQuest ProgressTextAlignToCenter"], onClickFunc = Checkbox_OnClick, dbKey = "NameplateQuest_ProgressTextAlignToCenter"},
        },
    };

    function OptionToggle_OnClick(self, button)
        OptionFrame = addon.ToggleSettingsDialog(self, OPTIONS_SCHEMATIC);
        if OptionFrame then
            OptionFrame:ConvertAnchor();
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
        self:RegisterEvent("PLAYER_ENTERING_WORLD");
        self:SetScript("OnEvent", self.OnEvent);
        self:UpdateAnchorForAddOns();
        LoadSettings();
    elseif self.enabled then
        self.enabled = nil;
        self.inInstance = nil;
        if WidgetPool then
            for widget in pairs(WidgetPool) do
                widget:Hide();
            end
        end
        self:UnregisterEvent("NAME_PLATE_UNIT_ADDED");
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
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
        optionToggleFunc = OptionToggle_OnClick,
        hasMovableWidget = true,
        categoryKeys = {
            "UnitFrame",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end
