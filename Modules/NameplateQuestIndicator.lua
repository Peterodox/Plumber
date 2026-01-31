local _, addon = ...
local L = addon.L;
local API = addon.API;


local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;
local GetNamePlates = C_NamePlate.GetNamePlates;
local UnitIsRelatedToActiveQuest = C_QuestLog.UnitIsRelatedToActiveQuest;
local GetUnitTooltipInfo = C_TooltipInfo.GetUnit;
local UnitIsPlayer = UnitIsPlayer;
local UnitIsUnit = UnitIsUnit;
local GetInstanceInfo = GetInstanceInfo;
local Secret_CanAccess = API.Secret_CanAccess;
local ipairs = ipairs;


local LineType = {
    QuestObjective = Enum.TooltipDataLineType.QuestObjective,
    QuestTitle = Enum.TooltipDataLineType.QuestTitle,
    QuestPlayer = Enum.TooltipDataLineType.QuestPlayer,
};


local Def = {
    IconSize = 18,
    ShowPartyQuest = false,
    ShowTargetProgress = false,
    ShowProgressOnHover = false,
    TextOutline = false,
    WidgetOffsetX = 0,
    WidgetOffsetY = 0,
    Side = "RIGHT",

    AnchorToHealthBar = true,
    TooltipPostCallAdded = false,
};


local EL = CreateFrame("Frame", nil, UIParent);


local WidgetPool;
local CreateQuestWidget;
local InitializeWidgetPool;
local EditorFrame;
local LoadSettings;
local LastMouseOverWidget;


local match = string.match;
local function GetProgressText(str)
    if Secret_CanAccess(str) then
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

    function QuestWidgetMixin:ShowNormalIcon()
        --self.Icon:SetTexCoord(0, 0.25, 0, 0.25);
        self.Icon:SetTexCoord(0, 0.5, 0.25, 0.75);
        self.ProgressText:SetTextColor(1, 1, 1);
    end

    function QuestWidgetMixin:ShowPartyIcon()
        --self.Icon:SetTexCoord(0.25, 0.5, 0, 0.25);
        self.Icon:SetTexCoord(0.5, 1, 0, 0.5);
        self.ProgressText:SetTextColor(0.67, 0.67, 0.67);
    end

    function QuestWidgetMixin:ShowNoQuest()
        self.hasProgress = nil;
        self.ProgressText:SetText(nil);
        self.Icon:SetTexCoord(0.75, 1, 0.75, 1);
    end

    function QuestWidgetMixin:UpdateQuest()
        self.questID = nil;

        if Def.isEditMode then
            self:ShowNormalIcon();
            self.hasProgress = true;
            self.ProgressText:SetText("6/7");
            return
        end

        if self.unit then
            if EL.inInstance then
                self.hasProgress = false;
                self.ProgressText:SetText(nil);
                if UnitIsRelatedToActiveQuest(self.unit) then
                    self:ShowNormalIcon();
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
                    local noSecret = true;

                    while i <= numLines and noSecret do
                        l = lines[i];
                        if l.type == LineType.QuestTitle then
                            questID = l.id;
                            allCompleted = true;
                            i = i + 1;
                        elseif l.type == LineType.QuestPlayer then
                            if Secret_CanAccess(l.leftText) then
                                local isPlayer = l.leftText == PLAYER_NAME;
                                i = i + 1;
                                l = lines[i];
                                if l then
                                    while l and l.type == LineType.QuestObjective and Secret_CanAccess(l.completed) do
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
                            else
                                noSecret = false;
                            end
                        elseif l.type == LineType.QuestObjective then
                            if Secret_CanAccess(l.completed) then
                                if not l.completed then
                                    allCompleted = false;
                                    objectiveText = l.leftText;
                                    break
                                end
                                i = i + 1;
                            else
                                noSecret = false;
                            end
                        else
                            i = i + 1;
                        end
                    end

                    self.questID = questID;

                    if not noSecret then
                        if UnitIsRelatedToActiveQuest(self.unit) then
                            self:ShowNormalIcon();
                        end
                        return
                    end

                    if not allCompleted then
                        local text = (Def.ShowTargetProgress or Def.ShowProgressOnHover) and GetProgressText(objectiveText) or nil;
                        self.ProgressText:SetText(text);
                        self.hasProgress = text ~= nil;

                        if fromAnotherPlayer then
                            self:ShowPartyIcon();
                        else
                            self:ShowNormalIcon();
                        end

                        return
                    end
                end
            end
        end

        self:ShowNoQuest();
    end

    function QuestWidgetMixin:UpdateTarget()
        self.isTarget = nil;

        if not EL.inInstance and Def.ShowTargetProgress then
            local isTarget = UnitIsUnit("target", self.unit);
            if Secret_CanAccess(isTarget) and isTarget then
                self.isTarget = true;
                self:UpdateQuest();
                self:UpdateProgressVisibility();
                return true
            end
        end

        self:UpdateProgressVisibility();

        return false
    end

    function QuestWidgetMixin:UpdateAlpha()
        self.ProgressText:SetAlpha(self.alpha);
        self.Icon:SetAlpha(1 - self.alpha);
    end

    do  --OnUpdate Funcs
        function QuestWidgetMixin:OnUpdate_ShowProgress(elapsed)
            self.alpha = self.alpha + 5 * elapsed;
            self.isFadingIn = true;
            if self.alpha >= 1 then
                self.alpha = 1;
                self.isFadingIn = nil;
                self:SetScript("OnUpdate", nil);
                if self.hideAfterFadingIn then
                    self.hideAfterFadingIn = nil;
                    self:SetScript("OnUpdate", self.OnUpdate_HideProgressAfterDelay);
                end
            end
            self:UpdateAlpha();
        end

        function QuestWidgetMixin:OnUpdate_HideProgress(elapsed)
            self.alpha = self.alpha - 5 * elapsed;
            if self.alpha <= 0 then
                self.alpha = 0;
                self:SetScript("OnUpdate", nil);
                self.ProgressText:Hide();
            end
            self:UpdateAlpha();
        end

        function QuestWidgetMixin:OnUpdate_HideProgressAfterDelay(elapsed)
            self.t = self.t + elapsed;
            if self.t >= 1 then
                self.t = 0;
                self:SetScript("OnUpdate", self.OnUpdate_HideProgress);
            end
        end
    end

    function QuestWidgetMixin:UpdateProgressVisibility(animating)
        self.hideAfterFadingIn = nil;
        if self.hasProgress and (self.isMouseOver or self.isTarget or self.isWorldCursor) then
            if animating then
                self.Icon:Show();
                self.ProgressText:Show();
                self:SetScript("OnUpdate", self.OnUpdate_ShowProgress);
            else
                self.Icon:Hide();
                self.ProgressText:Show();
                self.alpha = 1;
                self:UpdateAlpha();
                self:SetScript("OnUpdate", nil);
            end
        else
            if animating then
                self.Icon:Show();
                self.ProgressText:Show();
                self.t = 0;
                if self.isFadingIn then
                    self.hideAfterFadingIn = true;
                else
                    self:SetScript("OnUpdate", self.OnUpdate_HideProgressAfterDelay);
                end
            else
                self.Icon:Show();
                self.ProgressText:Hide();
                self.alpha = 0;
                self:UpdateAlpha();
                self:SetScript("OnUpdate", nil);
            end
        end
    end

    function QuestWidgetMixin:OnHide()
        self.questID = nil;
        self.unit = nil;
        self.isMouseOver = nil;
        self.isTarget = nil;
        self.isWorldCursor = nil;
        self.alpha = 0;
        self.isFadingIn = nil;
        self.hideAfterFadingIn = nil;
        self:Hide();
        self:ClearAllPoints();
        self.MouseOverFrame:ClearAllPoints();
        self.MouseOverFrame:Hide();
        self.ProgressText:Hide();
        self:SetParent(EL);
        self:SetScript("OnUpdate", nil);
        WidgetPool[self] = false;
    end

    function QuestWidgetMixin:SetOwnerInfo(owner, unit)
        self.unit = unit or owner.unit;
        self.owner = owner;

        self.MouseOverFrame:ClearAllPoints();
        if Def.ShowProgressOnHover then
            self.MouseOverFrame:Show();
            self.MouseOverFrame:SetPoint("TOPLEFT", owner, "TOPLEFT", 0, 0);
            self.MouseOverFrame:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", 0, 0);
        else
            self.MouseOverFrame:Hide();
        end

        if not self:UpdateTarget() then
            self:UpdateQuest();
        end
    end

    function QuestWidgetMixin:SetIconSize(size)
        self:SetWidth(size * 0.5);
        self.Icon:SetSize(size, size);
    end

    function QuestWidgetMixin:UpdateLayout()
        self:SetIconSize(Def.IconSize);
        self.ProgressText:ClearAllPoints();
        if Def.Side == "LEFT" then
            self.ProgressText:SetPoint("RIGHT", self.Ref, "CENTER", 0.25*Def.IconSize, 0);
        else
            self.ProgressText:SetPoint("LEFT", self.Ref, "CENTER", -0.25*Def.IconSize, 0);
        end
        self:UpdateOffset();
    end

    function QuestWidgetMixin:UpdateOffset()
        self.Ref:SetPoint("CENTER", self, "CENTER", Def.WidgetOffsetX, Def.WidgetOffsetY);
    end

    local function MouseOverFrame_OnEnter(self)
        self.parentWidget.isMouseOver = true;
        self.parentWidget:UpdateProgressVisibility(true);
    end

    local function MouseOverFrame_OnLeave(self)
        self.parentWidget.isMouseOver = nil;
        self.parentWidget.isWorldCursor = nil;
        self.parentWidget:UpdateProgressVisibility(true);
    end

    function CreateQuestWidget()
        local f = CreateFrame("Frame", nil, EL);
        Mixin(f, QuestWidgetMixin);
        f:SetSize(16, 16);
        f:SetScript("OnHide", f.OnHide);
        f.alpha = 0;

        local Ref = CreateFrame("Frame", nil, f);
        Ref:SetSize(1, 1);
        Ref:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.Ref = Ref;

        f.Icon = f:CreateTexture(nil, "OVERLAY");
        f.Icon:SetPoint("CENTER", Ref, "CENTER", 0, 0);
        f.Icon:SetSize(Def.IconSize, Def.IconSize);
        f.Icon:SetTexture("Interface/AddOns/Plumber/Art/Frame/NameplateQuest.png", nil, nil, "TRILINEAR");
        f.Icon:SetTexCoord(0, 0.25, 0, 0.25);
        API.DisableSharpening(f.Icon);

        f.ProgressText = f:CreateFontString(nil, "OVERLAY", "PlumberFont_Nameplate_Small");
        f.ProgressText:SetPoint("CENTER", Ref, "CENTER", 0, 0);
        f.ProgressText:SetTextColor(1, 1, 1);
        f.ProgressText:Hide();

        f.MouseOverFrame = CreateFrame("Frame", nil, f, "PlumberPropagateMouseTemplate");
        f.MouseOverFrame:SetScript("OnEnter", MouseOverFrame_OnEnter);
        f.MouseOverFrame:SetScript("OnLeave", MouseOverFrame_OnLeave);
        f.MouseOverFrame.parentWidget = f;

        WidgetPool[f] = false;

        return f
    end

    function InitializeWidgetPool()
        WidgetPool = {};
    end
end


do  --Event Listener
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
            if Def.Side == "LEFT" then
                local relativeTo = UnitFrame.ClassificationFrame;
                if relativeTo:IsShown() then    --Could this be protected?
                    widget:SetPoint("RIGHT", relativeTo, "LEFT", -1, 0);
                else
                    relativeTo = UnitFrame.HealthBarsContainer.healthBar;
                    widget:SetPoint("RIGHT", relativeTo, "LEFT", -2, 0);
                end
            else
                local relativeTo = UnitFrame.AurasFrame.CrowdControlListFrame;
                widget:SetPoint("LEFT", relativeTo, "RIGHT", -4, 0);
            end
        else
            if Def.Side == "LEFT" then
                widget:SetPoint("RIGHT", UnitFrame, "LEFT", 0, 0);
            else
                widget:SetPoint("LEFT", UnitFrame, "RIGHT", 0, 0);
            end
        end

        widget:UpdateLayout();
        widget:Show();
        WidgetPool[widget] = true;
    end

    function EL:UpdateAllNameplates()
        for widget, shown in pairs(WidgetPool) do
            if shown then
                widget:Hide();
            end
        end

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

    function EL:UpdateWidgetOffset()
        for widget, shown in pairs(WidgetPool) do
            if shown then
                widget:UpdateOffset();
            end
        end
    end

    function EL:ResetWidgetOffset()
        Def.WidgetOffsetX = 0;
        Def.WidgetOffsetY = 0;
        addon.SetDBValue("NameplateQuest_WidgetOffsetX", 0);
        addon.SetDBValue("NameplateQuest_WidgetOffsetY", 0);
        self:UpdateWidgetOffset();
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


local AcquireDragController;
do  --DragController (TODO: wrap into an API)
    local DragController;
    local DragControllerMixin = {};

    local GetCursorPosition = API.GetScaledCursorPosition;
    local Clamp = API.Clamp;

    function DragControllerMixin:SetDraggedObject(object)
        self.draggedObject = object;
    end

    function DragControllerMixin:SnapshotCursorPosition()
        local x, y = GetCursorPosition();
        self.x, self.y = x, y;
        self.x0, self.y0 = x, y;
    end

    function DragControllerMixin:PreDragStart()
        self:SnapshotCursorPosition();
        self.t = 0;
        self.stage = 1;
        self:SetScript("OnUpdate", self.OnUpdate_PreDrag);
    end

    function DragControllerMixin:OnUpdate_PreDrag(elapsed)
        self.x, self.y = GetCursorPosition();
        if (self.x - self.x0) ^ 2 + (self.y - self.y0) ^ 2 >= 8 then
            self:DraggingStart();
        end
    end

    function DragControllerMixin:DraggingStart()
        self:SnapshotCursorPosition();

        local x, y = self.draggedObject:GetCenter();
        self.dx = x - self.x;
        self.dy = y - self.y;

        --Boundary (Temp Hack)
        local safeOffset = 24;
        local left = EditorFrame:GetLeft();
        local right = EditorFrame:GetRight();
        local top = EditorFrame:GetTop();
        local bottom = EditorFrame:GetBottom();
        local dxMin = left - x + safeOffset;
        local dxMax = right - x - safeOffset;
        local dyMin = bottom - y + safeOffset;
        local dyMax = top - y - safeOffset;

        local point, relativeTo, relativePoint, fromX, fromY = self.draggedObject:GetPoint(1);
        local scalar = 1.0;

        local function SetObjectPosition(dx, dy)
            dx = dx * scalar;
            dy = dy * scalar;

            dx = Clamp(dx, dxMin, dxMax);
            dy = Clamp(dy, dyMin, dyMax);

            self.draggedObject:SetPoint(point, relativeTo, relativePoint, fromX + dx, fromY + dy);
            Def.WidgetOffsetX = fromX + dx;
            Def.WidgetOffsetY = fromY + dy;
        end
        self.SetObjectPosition = SetObjectPosition;

        if self.onDragStartCallback then
            self.onDragStartCallback();
        end

        self.t = 1;
        self.stage = 2;
        self:SetScript("OnUpdate", self.OnUpdate_Dragging);
    end

    function DragControllerMixin:OnUpdate_Dragging(elapsed)
        self.x, self.y = GetCursorPosition();
        self.SetObjectPosition(self.x - self.x0, self.y - self.y0);
        self.t = self.t + elapsed;
        if self.t > 0.016 then
            self.t = 0;
            EL:UpdateWidgetOffset();
        end
    end

    function DragControllerMixin:Stop()
        self:SetScript("OnUpdate", nil);
        self.x, self.y = 0, 0;
        self.x0, self.y0 = 0, 0;
        self.dx, self.dy = 0, 0;
        self.t = 0;
        if self.stage == 2 then
            addon.SetDBValue("NameplateQuest_WidgetOffsetX", Def.WidgetOffsetX);
            addon.SetDBValue("NameplateQuest_WidgetOffsetY", Def.WidgetOffsetY);
        end
        self.stage = nil;
    end

    function DragControllerMixin:OnHide()
        self:Stop();
    end

    function AcquireDragController(parent)
        if DragController then return DragController end;

        local f = CreateFrame("Frame", nil, parent);
        DragController = f;
        Mixin(f, DragControllerMixin);
        f:SetScript("OnHide", f.OnHide);

        return DragController
    end
end


local AcquireEditorFrame;
do  --Editor
    local MarkerWidget;    --Drag this to reposition marker


    local HitAreaMixin = {};

    function HitAreaMixin:OnMouseDown(button)
        self.isDragging = true;
        self:LockHighlight();
        self:UpdateVisual();
        if button == "LeftButton" then
            local controller = AcquireDragController(self);
            controller:SetDraggedObject(self:GetParent());
            controller:PreDragStart();
        else
            EL:ResetWidgetOffset();
            LoadSettings();
        end
    end

    function HitAreaMixin:OnMouseUp()
        self.isDragging = false;
        self:UnlockHighlight();
        self:UpdateVisual();
        local controller = AcquireDragController(self);
        controller:Stop();
    end

    function HitAreaMixin:OnUpdate()

    end

    function HitAreaMixin:UpdateVisual()
        if self.isDragging then
            self.Border:SetVertexColor(1, 0.82, 0, 1);
        else
            self.Border:SetVertexColor(0.294, 0.721, 0.914, 0.72);
        end
    end

    function HitAreaMixin:OnLoad()
        self:UpdateVisual();
        self:SetScript("OnHide", self.OnHide);
        self:SetScript("OnMouseDown", self.OnMouseDown);
        self:SetScript("OnMouseUp", self.OnMouseUp);
    end


    local MarkerWidgetMixin = {};

    function MarkerWidgetMixin:UpdateIconSize()
        local iconSize = Def.IconSize;
        local visualOffset = 8;
        self.Icon:SetSize(iconSize, iconSize);
        self:SetSize(0.5 * iconSize + visualOffset, iconSize);

        local size = math.max(iconSize, 24);
        self.HitArea:SetSize(size, size);
    end

    function MarkerWidgetMixin:UpdateBaseAnchor()
        self:ClearAllPoints();
        if Def.Side == "LEFT" then
            MarkerWidget:SetPoint("RIGHT", self.relativeTo, "LEFT", Def.WidgetOffsetX, Def.WidgetOffsetY);
            self.nodes[1]:Hide();
            self.nodes[2]:Show();
        else
            MarkerWidget:SetPoint("LEFT", self.relativeTo, "RIGHT", Def.WidgetOffsetX, Def.WidgetOffsetY);
            self.nodes[1]:Show();
            self.nodes[2]:Hide();
        end
    end


    local EditorFrameMixin = {};

    function EditorFrameMixin:OnShow()
        Def.isEditMode = true;
        EL:UpdateAllNameplates();
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
        self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
        self:SetScript("OnEvent", self.OnEvent);
        self:CheckNameplates();
        self:Update();
    end

    function EditorFrameMixin:OnHide()
        Def.isEditMode = nil;
        self.t = 0;
        self:UnregisterEvent("NAME_PLATE_UNIT_ADDED");
        self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED");
        self:SetScript("OnUpdate", nil);
        self:SetScript("OnEvent", nil);

        if EL.enabled then
            EL:UpdateAllNameplates();
        end
    end

    function EditorFrameMixin:OnEvent(event, ...)
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function EditorFrameMixin:CheckNameplates()
        local anyNameplate = false;
        local nameplates = GetNamePlates(false);
        if nameplates and #nameplates > 0 then
            anyNameplate = true;
        end

        if anyNameplate ~= self.anyNameplate then
            self.anyNameplate = anyNameplate;
            self.InstructionFrame:SetShown(not anyNameplate);
            self.PreviewFrame:SetShown(anyNameplate);
        end
    end

    function EditorFrameMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t >= 0.1 then
            self.t = 0;
            self:CheckNameplates();
        end
    end

    function EditorFrameMixin:Update()
        self.MarkerWidget:UpdateIconSize();
        self.MarkerWidget:UpdateBaseAnchor();
    end

    function AcquireEditorFrame()
        if EditorFrame then return EditorFrame end;

        local texture = "Interface/AddOns/Plumber/Art/Frame/NameplateQuestEditor.png";
        local textureScale = 0.75;

        local f = CreateFrame("Frame");
        EditorFrame = f;
        Mixin(f, EditorFrameMixin);
        f:SetSize(384, 192);

        f.Background = f:CreateTexture(nil, "BACKGROUND");
        f.Background:SetAllPoints(true);
        f.Background:SetTexture(texture);
        f.Background:SetTexCoord(0, 0.5, 64/512, 192/512);


        f.InstructionFrame = CreateFrame("Frame", nil, f);

        local fs1 = f.InstructionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        fs1:SetJustifyH("CENTER");
        fs1:SetSpacing(4);
        fs1:SetPoint("TOPLEFT", f, "TOPLEFT", 32, 0);
        fs1:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -32, 0);
        fs1:SetTextColor(0.5, 0.5, 0.5);
        fs1:SetText(L["NameplateQuest Instruction Find Nameplate"]);


        f.PreviewFrame = CreateFrame("Frame", nil, f);
        f.PreviewFrame:EnableMouse(true);
        f.PreviewFrame:EnableMouseMotion(true);
        f.PreviewFrame:SetAllPoints(true);

        local BarTexture = f.PreviewFrame:CreateTexture(nil, "ARTWORK");
        BarTexture:SetSize(256*textureScale, 48*textureScale);
        BarTexture:SetPoint("CENTER", f, "CENTER", 0, 0);
        BarTexture:SetTexture(texture);
        BarTexture:SetTexCoord(0, 0.5, 0, 48/512);

        local Bar = f.PreviewFrame:CreateTexture(nil, "OVERLAY");
        Bar:SetSize(192*textureScale, 24*textureScale);
        Bar:SetPoint("CENTER", f, "CENTER", 0, 0);

        MarkerWidget = CreateFrame("Frame", nil, f.PreviewFrame);
        EditorFrame.MarkerWidget = MarkerWidget;
        Mixin(MarkerWidget, MarkerWidgetMixin);
        MarkerWidget.Icon = MarkerWidget:CreateTexture(nil, "OVERLAY");
        MarkerWidget.Icon:SetTexture("Interface/AddOns/Plumber/Art/Frame/NameplateQuest.png", nil, nil, "TRILINEAR");
        MarkerWidget.Icon:SetTexCoord(0, 0.5, 0.25, 0.75);
        MarkerWidget.Icon:SetPoint("CENTER", MarkerWidget, "CENTER", 0, 0);
        API.DisableSharpening(MarkerWidget.Icon);

        MarkerWidget.HitArea = CreateFrame("Button", nil, MarkerWidget);
        MarkerWidget.HitArea:SetPoint("CENTER", MarkerWidget, "CENTER", 0, 0);
        Mixin(MarkerWidget.HitArea, HitAreaMixin);

        local Border = MarkerWidget.HitArea:CreateTexture(nil, "HIGHLIGHT");
        MarkerWidget.HitArea.Border = Border;
        Border:SetTexture("Interface/AddOns/Plumber/Art/LootUI/IconBorder-Square.png");
        Border:SetTextureSliceMode(0);
        Border:SetTextureSliceMargins(4, 4, 4, 4);
        Border:SetAllPoints(true);

        MarkerWidget.HitArea:OnLoad();
        MarkerWidget.relativeTo = Bar;


        local nodeFrameLevel = MarkerWidget.HitArea:GetFrameLevel() + 10;
        local nodes = {};
        MarkerWidget.nodes = nodes;

        for i = 1, 2 do
            nodes[i] = addon.CreateEditModeControlNode(f.PreviewFrame);
            nodes[i]:SetFrameLevel(nodeFrameLevel);
            if i == 1 then
                nodes[i]:SetPoint("RIGHT", Bar, "LEFT", 0, 0);
                nodes[i].onClickFunc = function()
                    addon.SetDBValue("NameplateQuest_Side", "LEFT");
                    EL:ResetWidgetOffset();
                    LoadSettings();
                end
            else
                nodes[i]:SetPoint("LEFT", Bar, "RIGHT", 0, 0);
                nodes[i].onClickFunc = function()
                    addon.SetDBValue("NameplateQuest_Side", "RIGHT");
                    EL:ResetWidgetOffset();
                    LoadSettings();
                end
            end
        end

        MarkerWidget:UpdateIconSize();
        MarkerWidget:UpdateBaseAnchor();


        f:SetScript("OnShow", f.OnShow);
        f:SetScript("OnHide", f.OnHide);
        f:OnShow();

        return EditorFrame
    end
end


local OptionToggle_OnClick;
do  --Options
    local Options = {
        IconSize = {16, 18, 20, 22, 24, 28, 32};
    };

    local function OnTooltipSetUnit(tooltip)
        if EL.inInstance or not Def.ShowProgressOnHover then return end;

        if LastMouseOverWidget then
            LastMouseOverWidget.isWorldCursor = nil;
            LastMouseOverWidget:UpdateProgressVisibility(true)
        end

		local _, unit = tooltip:GetUnit();

        if Secret_CanAccess(unit) then
            for widget, shown in pairs(WidgetPool) do
                if shown then
                    if widget.unit == unit then
                        LastMouseOverWidget = widget;
                        widget.isWorldCursor = true;
                        widget:UpdateProgressVisibility(true);
                        break
                    end
                end
            end
        end
	end

    function LoadSettings()
        local sizeIndex = addon.GetDBValue("NameplateQuest_IconSize");
        if not (sizeIndex and Options.IconSize[sizeIndex]) then
            sizeIndex = 2;
        end
        local size = Options.IconSize[sizeIndex]
        Def.IconSize = size;


        local dbKeys = {"ShowPartyQuest", "ShowTargetProgress", "ShowProgressOnHover", "TextOutline"};
        for _, dbKey in ipairs(dbKeys) do
            Def[dbKey] = addon.GetDBBool("NameplateQuest_"..dbKey);
        end


        local addonNames = {"Platynator", "Plater"};

        for _, name in ipairs(addonNames) do
            if C_AddOns.IsAddOnLoaded(name) then
                Def.AnchorToHealthBar = false;
                if not PlumberDB.NameplateQuest_Side then
                    PlumberDB.NameplateQuest_Side = "LEFT";
                end
                break
            end
        end

        Def.Side = addon.GetDBValue("NameplateQuest_Side") == "LEFT" and "LEFT" or "RIGHT";


        Def.WidgetOffsetX = addon.GetDBValue("NameplateQuest_WidgetOffsetX") or 0;
        Def.WidgetOffsetY = addon.GetDBValue("NameplateQuest_WidgetOffsetY") or 0;


        local fontFile, fontHeight = GameFontNormalSmall:GetFont();
        local nameplateFont = PlumberFont_Nameplate_Small;
        if Def.TextOutline then
            nameplateFont:SetFont(fontFile, fontHeight, "OUTLINE");
        else
            nameplateFont:SetFont(fontFile, fontHeight, "");
        end


        if Def.ShowProgressOnHover and not Def.TooltipPostCallAdded then
            Def.TooltipPostCallAdded = true;
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit);
        end


        EL:UpdateZone();
        EL:UpdateAllNameplates();

        if EditorFrame and EditorFrame:IsShown() then
            EditorFrame:Update();
        end
    end

    local function Checkbox_OnClick()
        addon.UpdateSettingsDialog();
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

    local function Options_TextOutline_ShouldEnable()
        return addon.GetDBBool("NameplateQuest_ShowTargetProgress") or addon.GetDBBool("NameplateQuest_ShowProgressOnHover")
    end

    local OPTIONS_SCHEMATIC = {
        title = L["ModuleName NameplateQuest"],
        widgets = {
            {type = "Custom", onAcquire = AcquireEditorFrame, align = "center"},
            {type = "Divider"},
            {type = "Slider", label = L["Icon Size"], minValue = 1, maxValue = #Options.IconSize, valueStep = 1, onValueChangedFunc = Options_IconSizeSlider_OnValueChanged, formatValueFunc = Options_IconSizeSlider_FormatValue, dbKey = "NameplateQuest_IconSize"},
            {type = "Checkbox", label = L["NameplateQuest ShowPartyQuest"], onClickFunc = Checkbox_OnClick, dbKey = "NameplateQuest_ShowPartyQuest", tooltip = Tooltip_ShowPartyQuest, restrictionInstance = true},
            {type = "Checkbox", label = L["NameplateQuest ShowTargetProgress"], onClickFunc = Checkbox_OnClick, dbKey = "NameplateQuest_ShowTargetProgress", tooltip = L["NameplateQuest ShowTargetProgress Tooltip"], restrictionInstance = true},
            {type = "Checkbox", label = L["NameplateQuest ShowProgressOnHover"], onClickFunc = Checkbox_OnClick, dbKey = "NameplateQuest_ShowProgressOnHover", tooltip = L["NameplateQuest ShowProgressOnHover Tooltip"], restrictionInstance = true},
            {type = "Checkbox", label = L["TalkingHead Option TextOutline"], onClickFunc = Checkbox_OnClick, dbKey = "NameplateQuest_TextOutline", shouldEnableOption = Options_TextOutline_ShouldEnable},
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
        moduleAddedTime = 1769800000,
        optionToggleFunc = OptionToggle_OnClick,
        hasMovableWidget = true,
        categoryKeys = {
            "UnitFrame",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end
