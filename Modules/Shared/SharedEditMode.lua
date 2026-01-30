local _, addon = ...
local API = addon.API;

local GetMouseFocus = API.GetMouseFocus;


do  --EditModeSelection
    local EditModeSelectionMixin = {};

    function EditModeSelectionMixin:OnDragStart()
        self.parent:OnDragStart();
    end

    function EditModeSelectionMixin:OnDragStop()
        self.parent:OnDragStop();
    end

    function EditModeSelectionMixin:ShowHighlighted()
        --Blue
        if not self.parent:IsShown() then return end;
        self.isSelected = false;
        self.Background:SetTexture("Interface/AddOns/Plumber/Art/Frame/EditModeHighlighted");
        self:Show();
        self.Label:Hide();
    end

    function EditModeSelectionMixin:ShowSelected()
        --Yellow
        if not self.parent:IsShown() then return end;
        self.isSelected = true;
        self.Background:SetTexture("Interface/AddOns/Plumber/Art/Frame/EditModeSelected");
        self:Show();
        GameTooltip:Hide();

        if not self.hideLabel then
            self.Label:Show();
        end
    end

    function EditModeSelectionMixin:OnShow()
        local offset = 8; --API.GetPixelForWidget(self, 6);
        self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", -offset, offset);
        self.Background:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", offset, -offset);
        self:RegisterEvent("GLOBAL_MOUSE_DOWN");
    end

    function EditModeSelectionMixin:OnHide()
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
    end

    function EditModeSelectionMixin:OnEnter()
        if (not self.isSelected) and self.uiName then
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
            GameTooltip:SetText(L["Addon Name Colon"]..self.uiName, 1, 0.82, 0, 1, true);
            GameTooltip:Show();
        end
    end

    function EditModeSelectionMixin:OnLeave()
        GameTooltip:Hide();
    end

    local function IsMouseOverOptionToggle()
        local obj = GetMouseFocus();
        if obj and obj.isPlumberSettingsPanelToggle then
            return true
        else
            return false
        end
    end

    function EditModeSelectionMixin:OnEvent(event, ...)
        if event == "GLOBAL_MOUSE_DOWN" then
            if self:IsShown() and not(self.parent:IsFocused() or IsMouseOverOptionToggle()) then
                self:ShowHighlighted();
                if self.parent.ShowOptions then
                    self.parent:ShowOptions(false);
                end

                if self.parent.ExitEditMode and not API.IsInEditMode() then
                    self.parent:ExitEditMode();
                end
            end
        end
    end

    function EditModeSelectionMixin:OnMouseDown(button)
        self:ShowSelected();
        if self.parent.ShowOptions then
            self.parent:ShowOptions(true);
        end

        if EditModeManagerFrame and EditModeManagerFrame.ClearSelectedSystem then
            EditModeManagerFrame:ClearSelectedSystem();
        end

        if button == "RightButton" then
            if self.parent.OnRightButtonDown then
                self.parent:OnRightButtonDown();
            end
        end
    end


    local function CreateEditModeSelection(parent, uiName, hideLabel)
        local f = CreateFrame("Frame", nil, parent);
        f:Hide();

        local offsetH = parent.selectionOffsetH;
        local offsetTop = parent.selectionOffsetTop;
        local offsetBottom = parent.selectionOffsetBottom;

        if offsetH or offsetTop or offsetBottom then
            offsetH = offsetH or 0;
            f:SetPoint("TOPLEFT", parent, "TOPLEFT", -offsetH, offsetTop or 0);
            f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", offsetH, offsetBottom or 0);
        else
            f:SetAllPoints(true);
        end

        f:SetFrameStrata(parent:GetFrameStrata());
        f:SetToplevel(true);
        f:SetFrameLevel(999);
        f:EnableMouse(true);
        f:RegisterForDrag("LeftButton");
        f:SetIgnoreParentAlpha(true);

        f.Label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium");
        f.Label:SetText(uiName);
        f.Label:SetJustifyH("CENTER");
        f.Label:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.Label:Hide();

        f.Background = f:CreateTexture(nil, "BACKGROUND");
        f.Background:SetTexture("Interface/AddOns/Plumber/Art/Frame/EditModeHighlighted");
        f.Background:SetTextureSliceMargins(16, 16, 16, 16);
        f.Background:SetTextureSliceMode(0);
        f.Background:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
        f.Background:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);

        Mixin(f, EditModeSelectionMixin);

        f:SetScript("OnShow", f.OnShow);
        f:SetScript("OnHide", f.OnHide);
        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnEvent", f.OnEvent);
        f:SetScript("OnMouseDown", f.OnMouseDown);
        f:SetScript("OnDragStart", f.OnDragStart);
        f:SetScript("OnDragStop", f.OnDragStop);

        parent.Selection = f;
        f.parent = parent;
        f.uiName = uiName;
        f.hideLabel = hideLabel;

        return f
    end
    addon.CreateEditModeSelection = CreateEditModeSelection;
end

do  --EditModeSettingsDialog
    local EditModeSettingsDialog;
    local DIALOG_WIDTH = 432;

    local EditModeSettingsDialogMixin = {};

    function EditModeSettingsDialogMixin:Exit()
        self:Hide();
        self:ClearAllPoints();
        self.requireResetPosition = true;
        if self.parent then
            if self.parent.Selection then
                self.parent.Selection:ShowHighlighted();
            end
            if self.parent.ExitEditMode and not API.IsInEditMode() then
                self.parent:ExitEditMode();
            end
            self.parent = nil;
        end
    end

    function EditModeSettingsDialogMixin:ReleaseAllWidgets()
        for _, widget in ipairs(self.activeWidgets) do
            if widget.isCustomWidget then
                widget:Hide();
                widget:ClearAllPoints();
            end
        end
        self.activeWidgets = {};

        self.checkboxPool:ReleaseAll();
        self.sliderPool:ReleaseAll();
        self.uiPanelButtonPool:ReleaseAll();
        self.texturePool:ReleaseAll();
        self.fontStringPool:ReleaseAll();
        self.keybindButtonPool:ReleaseAll();
        self.newFeatureLabelPool:ReleaseAll();
    end

    function EditModeSettingsDialogMixin:Layout()
        local leftPadding = 20;
        local topPadding = 48;
        local bottomPadding = 20;
        local OPTION_GAP_Y = 8;  --consistent with ControlCenter
        local subOptionOffset = 20;
        local height = topPadding;
        local widgetHeight;
        local contentWidth = DIALOG_WIDTH - 2*leftPadding;
        local preOffset, postOffset;

        for order, widget in ipairs(self.activeWidgets) do
            if widget.isGap then
                height = height + 8 + OPTION_GAP_Y;
            else
                if widget.widgetType == "Divider" then
                    preOffset = 2;
                    postOffset = 2;
                elseif widget.widgetType == "Custom" then
                    preOffset = 0;
                    postOffset = 2;
                else
                    preOffset = 0;
                    postOffset = 0;
                end

                height = height + preOffset;
                widget:ClearAllPoints();
                if widget.align and widget.align ~= "left" then
                    if widget.align == "center" then
                        if widget.effectiveWidth then
                            widget:SetPoint("TOPRIGHT", self, "TOPRIGHT", -0.5*(contentWidth - widget.effectiveWidth) - leftPadding, -height);
                        else
                            widget:SetPoint("TOP", self, "TOP", 0, -height);
                        end
                    else
                        widget:SetPoint("TOPRIGHT", self, "TOPRIGHT", -leftPadding, -height);
                    end
                else
                    widget:SetPoint("TOPLEFT", self, "TOPLEFT", leftPadding + (widget.isSubOption and subOptionOffset or 0), -height);
                end
                widgetHeight = API.Round(widget:GetHeight());
                height = height + widgetHeight + OPTION_GAP_Y + postOffset;
                if widget.matchParentWidth then
                    widget:SetWidth(contentWidth);
                end
            end
        end

        height = height - OPTION_GAP_Y + bottomPadding;
        self:SetHeight(height);
    end

    function EditModeSettingsDialogMixin:AcquireWidgetByType(type)
        local widget;

        if type == "Checkbox" then
            widget = self.checkboxPool:Acquire();
        elseif type == "Slider" then
            widget = self.sliderPool:Acquire();
        elseif type == "UIPanelButton" then
            widget = self.uiPanelButtonPool:Acquire();
        elseif type == "Texture" then
            widget = self.texturePool:Acquire();
            widget.matchParentWidth = nil;
        elseif type == "FontString" then
            widget = self.fontStringPool:Acquire();
            widget.matchParentWidth = true;
        elseif type == "Keybind" then
            widget = self.keybindButtonPool:Acquire();
        end

        return widget
    end

    function EditModeSettingsDialogMixin:CreateCheckbox(widgetData)
        local checkbox = self:AcquireWidgetByType("Checkbox");

        checkbox.Label:SetFontObject("GameFontHighlightMedium");    --Fonts in EditMode and Options are different
        checkbox.Label:SetTextColor(1, 1, 1);
        checkbox.useWhiteLabel = true;

        checkbox:SetData(widgetData);
        checkbox:SetChecked(addon.GetDBValue(checkbox.dbKey));

        return checkbox
    end

    function EditModeSettingsDialogMixin:CreateSlider(widgetData)
        local slider = self:AcquireWidgetByType("Slider");

        slider:SetLabel(widgetData.label);
        slider:SetMinMaxValues(widgetData.minValue, widgetData.maxValue);

        if widgetData.valueStep then
            slider:SetObeyStepOnDrag(true);
            slider:SetValueStep(widgetData.valueStep);
        else
            slider:SetObeyStepOnDrag(false);
        end

        if widgetData.formatValueFunc then
            slider:SetFormatValueFunc(widgetData.formatValueFunc);
        elseif widgetData.formatValueMethod then
            slider:SetFormatValueMethod(widgetData.formatValueMethod);
        else
            slider:SetFormatValueFunc(nil);
        end

        slider:SetOnValueChangedFunc(widgetData.onValueChangedFunc);
        slider:SetOnMouseDownFunc(widgetData.onMouseDownFunc);
        slider:SetOnMouseUpFunc(widgetData.onMouseUpFunc);

        slider.tooltip = widgetData.tooltip;
        slider.onEnterFunc = widgetData.onEnterFunc;
        slider.onLeaveFunc = widgetData.onLeaveFunc;
        slider.isDraggingThumb = false;

        if widgetData.dbKey and addon.GetDBValue(widgetData.dbKey) then
            slider:SetValue(addon.GetDBValue(widgetData.dbKey));
        end

        return slider
    end

    function EditModeSettingsDialogMixin:CreateUIPanelButton(widgetData)
        local button = self:AcquireWidgetByType("UIPanelButton");
        button:SetButtonText(widgetData.label);
        button:SetScript("OnClick", widgetData.onClickFunc);
        if (not widgetData.stateCheckFunc) or (widgetData.stateCheckFunc()) then
            button:Enable();
        else
            button:Disable();
        end
        button.matchParentWidth = true;
        return button
    end

    function EditModeSettingsDialogMixin:CreateDivider(widgetData)
        local texture = self:AcquireWidgetByType("Texture");
        texture:SetTexture("Interface/AddOns/Plumber/Art/Frame/Divider_NineSlice");
        texture:SetTextureSliceMargins(48, 4, 48, 4);
        texture:SetTextureSliceMode(0);
        texture:SetHeight(4);
        texture.matchParentWidth = true;
        API.DisableSharpening(texture);
        return texture
    end

    function EditModeSettingsDialogMixin:CreateHeader(widgetData)
        local fontString = self:AcquireWidgetByType("FontString");
        fontString:SetJustifyH("CENTER");
        fontString:SetJustifyV("TOP");
        fontString:SetSpacing(2);
        fontString.matchParentWidth = true;
        fontString:SetText(widgetData.label);
        return fontString
    end

    function EditModeSettingsDialogMixin:CreateKeybindButton(widgetData)
        local button = self:AcquireWidgetByType("Keybind");
        button.dbKey = widgetData.dbKey;
        button.tooltip = widgetData.tooltip;
        button:SetKeyText(addon.GetDBValue(widgetData.dbKey));
        button:SetLabel(widgetData.label);
        return button
    end

    function EditModeSettingsDialogMixin:UpdateWidgetEnabledState(widget)
        if not widget.SetEnabled then return end;
        local enabled = true;
        if widget.shouldEnableOption and not widget.shouldEnableOption() then
            enabled = false;
        end
        if widget.parentDBKey and not addon.GetDBBool(widget.parentDBKey) then
            enabled = false;
        end
        widget:SetEnabled(enabled);
    end

    function EditModeSettingsDialogMixin:SetupOptions(schematic)
        self:ReleaseAllWidgets();
        self:SetTitle(schematic.title);

        if schematic.widgets then
            for order, widgetData in ipairs(schematic.widgets) do
                local widget;
                if (not widgetData.validityCheckFunc) or (widgetData.validityCheckFunc()) then

                    if widgetData.type == "Checkbox" then
                        widget = self:CreateCheckbox(widgetData);
                    elseif widgetData.type == "RadioGroup" then

                    elseif widgetData.type == "Slider" then
                        widget = self:CreateSlider(widgetData);
                    elseif widgetData.type == "UIPanelButton" then
                        widget = self:CreateUIPanelButton(widgetData);
                    elseif widgetData.type == "Divider" then
                        widget = self:CreateDivider(widgetData);
                    elseif widgetData.type == "Header" then
                        widget = self:CreateHeader(widgetData);
                    elseif widgetData.type == "Keybind" then
                        widget = self:CreateKeybindButton(widgetData);
                    elseif widgetData.type == "Custom" then
                        widget = widgetData.onAcquire();
                        if widget then
                            widget:SetParent(self);
                            widget:ClearAllPoints();
                            widget:Show();
                            widget.isCustomWidget = true;
                            widget.align = widgetData.align or "center";
                        end
                    end

                    if widget then
                        table.insert(self.activeWidgets, widget);
                        widget.widgetKey = widgetData.widgetKey;
                        widget.widgetType = widgetData.type;
                        widget.isSubOption = widgetData.isSubOption;
                        self:UpdateWidgetEnabledState(widget);
                        if widgetData.newFeature then
                            local label = self.newFeatureLabelPool:Acquire();
                            label:SetPoint("LEFT", widget.Label, "RIGHT", -12, 0);
                            label:Show();
                        end
                    end
                end
            end
        end
        self:Layout();
    end

    function EditModeSettingsDialogMixin:FindWidget(widgetKey)
        if self.activeWidgets then
            for _, widget in pairs(self.activeWidgets) do
                if widget.widgetKey == widgetKey then
                    return widget
                end
            end
        end
    end

    function EditModeSettingsDialogMixin:OnDragStart()
        self:StartMoving();
    end

    function EditModeSettingsDialogMixin:OnDragStop()
        self:StopMovingOrSizing();
        self:ConvertAnchor();
    end

    function EditModeSettingsDialogMixin:ConvertAnchor()
        --Convert any anchor to the top left
        --so that changing frame height don't affect the positions of most buttons
        local left = self:GetLeft();
        local top = self:GetTop();
        self:ClearAllPoints();
        self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top);
    end

    function EditModeSettingsDialogMixin:SetTitle(title)
        self.Title:SetText(title);
    end

    function EditModeSettingsDialogMixin:IsOwner(parent)
        return parent == self.parent
    end

    function EditModeSettingsDialogMixin:IsFromSchematic(schematic)
        return schematic and self.schematic == schematic;
    end

    function EditModeSettingsDialogMixin:HideOption(parent)
        if (not parent) or self:IsOwner(parent) then
            self:Hide();
        end
    end

    function EditModeSettingsDialogMixin:CloseUI()
        if self:IsShown() then
            self:Exit();
            return true
        end
    end

    function EditModeSettingsDialogMixin:OnHide()
        addon.CallbackRegistry:Trigger("SettingsPanel.ModuleOptionClosed");
    end

    local function SetupSettingsDialog(parent, schematic, forceUpdate)
        if not EditModeSettingsDialog then
            local f = CreateFrame("Frame", nil, UIParent);
            EditModeSettingsDialog = f;
            f:Hide();
            f:SetSize(DIALOG_WIDTH, 350);
            f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
            f:SetMovable(true);
            f:SetClampedToScreen(true);
            f:RegisterForDrag("LeftButton");
            f:SetDontSavePosition(true);
            f:SetFrameStrata("DIALOG");
            f:SetFrameLevel(200);
            f:EnableMouse(true);

            f.activeWidgets = {};
            f.requireResetPosition = true;

            Mixin(f, EditModeSettingsDialogMixin);
            addon.AddModuleOptionExitMethod(f, f.CloseUI);

            f.Border = CreateFrame("Frame", nil, f, "DialogBorderTranslucentTemplate");
            f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButtonNoScripts");
            f.CloseButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0);
            f.CloseButton:SetScript("OnClick", function()
                f:Exit();
            end);
            f.Title = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge");
            f.Title:SetPoint("TOP", f, "TOP", 0, -20);
            f.Title:SetText("Title");

            f:SetScript("OnDragStart", f.OnDragStart);
            f:SetScript("OnDragStop", f.OnDragStop);
            f:SetScript("OnHide", f.OnHide);

            local function CreateCheckbox()
                return addon.CreateCheckbox(f);
            end
            f.checkboxPool = API.CreateObjectPool(CreateCheckbox);

            local function CreateSlider()
                return addon.CreateSlider(f);
            end
            f.sliderPool = API.CreateObjectPool(CreateSlider);

            local function CreateUIPanelButton()
                return addon.CreateUIPanelButton(f);
            end
            f.uiPanelButtonPool = API.CreateObjectPool(CreateUIPanelButton);

            local function CreateTexture()
                return f:CreateTexture(nil, "OVERLAY");
            end
            f.texturePool = API.CreateObjectPool(CreateTexture);

            local function CreateFontString()
                return f:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
            end
            f.fontStringPool = API.CreateObjectPool(CreateFontString);

            local function CreateKeybindButton()
                return addon.CreateKeybindButton(f);
            end
            f.keybindButtonPool = API.CreateObjectPool(CreateKeybindButton);

            local function CreateNewFeatureLabel()
                return CreateFrame("Frame", nil, f, "NewFeatureLabelNoAnimateTemplate");
            end
            f.newFeatureLabelPool = API.CreateObjectPool(CreateNewFeatureLabel);
        end

        if EditModeSettingsDialog:IsShown() and not EditModeSettingsDialog:IsOwner(parent) then
            EditModeSettingsDialog:Exit();
        end

        if (schematic ~= EditModeSettingsDialog.schematic) then
            EditModeSettingsDialog.requireResetPosition = true;
            EditModeSettingsDialog.schematic = schematic;
            EditModeSettingsDialog:ClearAllPoints();
            EditModeSettingsDialog:SetupOptions(schematic);
        elseif forceUpdate then
            EditModeSettingsDialog.schematic = schematic;
            EditModeSettingsDialog:SetupOptions(schematic);
        end

        EditModeSettingsDialog.parent = parent;

        return EditModeSettingsDialog
    end
    addon.SetupSettingsDialog = SetupSettingsDialog;

    local function ToggleSettingsDialog(parent, schematic, forceUpdate)
        if EditModeSettingsDialog and EditModeSettingsDialog:IsShown() and EditModeSettingsDialog:IsOwner(parent) then
            EditModeSettingsDialog:Exit();
        else
            local f = SetupSettingsDialog(parent, schematic, forceUpdate);
            if f then
                f:Show();
                f:ClearAllPoints();
                f:SetPoint("LEFT", UIParent, "CENTER", 256, 0);
                return f
            end
        end
    end
    addon.ToggleSettingsDialog = ToggleSettingsDialog;

    local function UpdateSettingsDialog()
        if EditModeSettingsDialog and EditModeSettingsDialog.activeWidgets then
            for _, widget in ipairs(EditModeSettingsDialog.activeWidgets) do
                EditModeSettingsDialog:UpdateWidgetEnabledState(widget);
            end
        end
    end
    addon.UpdateSettingsDialog = UpdateSettingsDialog;
end
