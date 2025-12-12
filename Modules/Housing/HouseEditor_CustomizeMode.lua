local _, addon = ...
local L = addon.L;
local API = addon.API;
local Housing = addon.Housing;


local tsort = table.sort;
local C_HousingCustomizeMode = C_HousingCustomizeMode;
local IsHoveringDecor = C_HousingCustomizeMode.IsHoveringDecor;
local GetHoveredDecorInfo = C_HousingCustomizeMode.GetHoveredDecorInfo;
local GetDyeColorInfo = C_DyeColor.GetDyeColorInfo;
local GetSwatchMarkup = Housing.GetSwatchMarkup;


local Handler = Housing.HouseEditorController.CreateModeHandler("Customize");


local function SortFunc_DyeSlots(a, b)
    return a.orderIndex < b.orderIndex
end


local Instructions = {};
Instructions.IsModifierPressed = IsControlKeyDown;


local CustomizeModeCallbacks = {};
do
    local function CreateTooltipLineWithSwatch(text, dyeSlots, numSlots)
        tsort(dyeSlots, SortFunc_DyeSlots);
        local line = text.." ";
        local colorID;
        local iconMarkup;
        numSlots = numSlots or #dyeSlots;
        for i = 1, numSlots do
            colorID = dyeSlots[i] and dyeSlots[i].dyeColorID or 0;
            iconMarkup = GetSwatchMarkup(colorID);
            line = line .. iconMarkup;
        end
        return line
    end

    function CustomizeModeCallbacks.ShowDecorInstanceTooltip(modeFrame, decorInstanceInfo)
        Handler.currentDyeInfo = nil;
        Handler:UnregisterEvent("GLOBAL_MOUSE_UP");

        if not Handler:IsCustomizableDecor(decorInstanceInfo) then
            return
        end

        local tooltip = GameTooltip;
        if tooltip:GetOwner() == modeFrame then
            local anyNewLine;
            local numSlots = decorInstanceInfo.dyeSlots and #decorInstanceInfo.dyeSlots or 0;
            if numSlots > 0 then
                --HousingDecorDyeSlot
                if Handler:IsDecorDyeCopied(decorInstanceInfo) then
                    --tooltip:AddLine(CreateTooltipLineWithSwatch("Dyes Copied", decorInstanceInfo.dyeSlots), 0.5, 0.5, 0.5);
                    tooltip:AddDoubleLine(L["Dyes Copied"], CreateTooltipLineWithSwatch("", decorInstanceInfo.dyeSlots), 0.5, 0.5, 0.5, 1, 1, 1);
                else
                    --tooltip:AddLine(CreateTooltipLineWithSwatch("Right Click to Copy Dyes", decorInstanceInfo.dyeSlots), 1, 0.82, 0);
                    tooltip:AddDoubleLine(Instructions.CopyDye, CreateTooltipLineWithSwatch("", decorInstanceInfo.dyeSlots), 1, 0.82, 0, 1, 1, 1);
                    if Handler.lastDyeSlots then
                        --tooltip:AddLine(CreateTooltipLineWithSwatch("Ctrl Click to Apply Dyes", Handler.lastDyeSlots), 1, 0.82, 0);
                        tooltip:AddDoubleLine(Instructions.ApplyDye, CreateTooltipLineWithSwatch("", Handler.lastDyeSlots, numSlots), 1, 0.82, 0, 1, 1, 1);
                    end
                end
                anyNewLine = true;
                Handler:RegisterEvent("GLOBAL_MOUSE_UP");
            end

            if anyNewLine then
                tooltip:Show();
            end
        end
    end

    function CustomizeModeCallbacks.ShowSelectedDecorInfo()
        local info = C_HousingCustomizeMode.GetSelectedDecorInfo();
        if info and info.canBeCustomized then
            --print(GetTimePreciseSec())
        end
    end

    local function DyeSlotFrameSwatch_OnClick(self, button)
        if IsModifiedClick("CHATLINK") and self.dyeColorInfo and self.dyeColorInfo.itemID then
            --local link = string.format("|cffffffff|H:item:%d:0:|h[%s]|h|r", self.dyeColorInfo.itemID, self.dyeColorInfo.name);
            local _, link = C_Item.GetItemInfo(self.dyeColorInfo.itemID)
            if ChatEdit_InsertLink(link) then

            end
        end
    end

    function CustomizeModeCallbacks.DyePaneSetDecorInfo(self, decorInstanceInfo)
        for dyeSlotFrame in self.dyeSlotPool:EnumerateActive() do
            if dyeSlotFrame.dyeSlotInfo and dyeSlotFrame.CurrentSwatch.dyeColorInfo then
                dyeSlotFrame.Label:SetPoint("LEFT", dyeSlotFrame, "LEFT", 52, 0);
                dyeSlotFrame.Label:SetSpacing(2);
                dyeSlotFrame.Label:SetHeight(32);
                dyeSlotFrame.Label:SetText(dyeSlotFrame.CurrentSwatch.dyeColorInfo.name);
            end

            if not dyeSlotFrame.hookedByPlumber then
                dyeSlotFrame.hookedByPlumber = true;
                dyeSlotFrame.CurrentSwatch:HookScript("OnClick", DyeSlotFrameSwatch_OnClick);
            end
        end
    end
end


do
    function Handler:Init()
        --CustomizeMode
        self.Init = nil;

        local CustomizeModeFrame = HouseEditorFrame.CustomizeModeFrame;
        self.parentFrame = CustomizeModeFrame;
        self.DyePane = self.parentFrame.DecorCustomizationsPane;
        self.DyePopout = DyeSelectionPopout;


        hooksecurefunc(CustomizeModeFrame, "ShowDecorInstanceTooltip", CustomizeModeCallbacks.ShowDecorInstanceTooltip);
        --hooksecurefunc(CustomizeModeFrame, "ShowSelectedDecorInfo", CustomizeModeCallbacks.ShowSelectedDecorInfo);
        hooksecurefunc(self.DyePane, "SetDecorInfo", CustomizeModeCallbacks.DyePaneSetDecorInfo);


        --Fixed an issue where tooltip doesn't update when closing DyePane while the cursor hovers on the same decor
        self.DyePane:HookScript("OnHide", function()
            Handler:TriggerCursorBlocker();
        end);


        self.CursorBlocker = CreateFrame("Button", nil, self.parentFrame);
        self.CursorBlocker:SetSize(8, 8);
        self.CursorBlocker:Hide();


        --Save Hide Unavailable State
        self.DyePopout.ShowOnlyOwned:SetChecked(addon.GetDBBool("Housing_DyePopout_ShowOnlyOwned") or false);
        self.DyePopout.ShowOnlyOwned:HookScript("OnClick", function(self)
            addon.SetDBValue("Housing_DyePopout_ShowOnlyOwned", self:GetChecked());
        end);
    end

    function Handler:IsEnabled()
        return self.enabled or true --debug
    end

    function Handler:OnActivated()
        self:LoadSettings();
        self:SetScript("OnEvent", self.OnEvent);
    end

    function Handler:OnDeactivated()
        self:SetScript("OnEvent", nil);
        self:UnregisterEvent("GLOBAL_MOUSE_UP");
        self.CursorBlocker:Hide();
        self.currentDyeInfo = nil;
        self.lastDyeSlots = nil;
        self.lastDyeInfo = nil;
    end


    function Handler:LoadSettings()
        Instructions.CopyDye = L["InstructionFormat Right Click"]:format(L["Copy Dyes"]);
        Instructions.ApplyDye = L["InstructionFormat Ctrl Left Click"]:format(L["Preview Dyes"]);   --L["Apply Dyes"]
        Instructions.IsModifierPressed = IsControlKeyDown;
    end

    function Handler:OnEvent(event, ...)
        if event == "GLOBAL_MOUSE_UP" then
            self:OnGlobalMouseUp(...);
        end
    end

    function Handler:OnGlobalMouseUp(button)
        if button == "RightButton" then
            self:TryCopyDecorDyes();
        elseif button == "LeftButton" and Instructions.IsModifierPressed() then
            self:TryPasteCustomization();
        end
    end

    function Handler:IsCustomizableDecor(decorInstanceInfo)
        if decorInstanceInfo and (not decorInstanceInfo.isLocked) and decorInstanceInfo.canBeCustomized then
            return decorInstanceInfo.dyeSlots and #decorInstanceInfo.dyeSlots
        end
    end

    function Handler:TryCopyDecorDyes()
        if IsHoveringDecor() then
            local decorInstanceInfo = GetHoveredDecorInfo();
            if self:IsCustomizableDecor(decorInstanceInfo) then
                self.lastDyeInfo = {};
                self.lastDyeSlots = decorInstanceInfo.dyeSlots;
                tsort(self.lastDyeSlots, SortFunc_DyeSlots);

                for i, v in ipairs(self.lastDyeSlots) do
                    self.lastDyeInfo[i] = v.dyeColorID or 0;
                end

                if self.parentFrame then
                    GameTooltip:Hide();
                    self.parentFrame:OnDecorHovered();
                end

                if C_HousingCustomizeMode.IsDecorSelected() then
                    local openedInfo = C_HousingCustomizeMode.GetSelectedDecorInfo();
                    if self:IsCustomizableDecor(openedInfo) then
                        self:TryPasteCustomization();
                    end
                end
            end
        end
    end

    function Handler:IsDecorDyeCopied(decorInstanceInfo)
        if self.lastDyeInfo then
            local dyeSlots = decorInstanceInfo.dyeSlots;
            tsort(dyeSlots, SortFunc_DyeSlots);
            for i, v in ipairs(dyeSlots) do
                if not (v.dyeColorID and self.lastDyeInfo[i] == v.dyeColorID) then
                    return false
                end
            end
            return true
        end
    end

    function Handler:TriggerCursorBlocker()
        if not self.blockerShown then
            local x, y = InputUtil.GetCursorPosition(self.parentFrame)
            self.CursorBlocker:ClearAllPoints();
            self.CursorBlocker:SetPoint("CENTER", self.parentFrame, "BOTTOMLEFT", x, y);
            self.CursorBlocker:Show();
            self.blockerShown = true;
            C_Timer.After(0.0, function()
                self.blockerShown = nil;
                self.CursorBlocker:Hide();
            end);
        end
    end

    function Handler:TryPasteCustomization()
        --print(GetTimePreciseSec(), "Paste")


        if not self.lastDyeInfo then return end;

        local info = C_HousingCustomizeMode.GetSelectedDecorInfo();
        if info and info.canBeCustomized then
            local dyeSlots = info.dyeSlots;
            tsort(dyeSlots, SortFunc_DyeSlots);

            local anyDiff = false;
            local savedColorID;
            for i, v in ipairs(dyeSlots) do
                savedColorID = self.lastDyeInfo[i] or 0;
                if savedColorID ~= v.dyeColorID then
                    anyDiff = true;
                    v.dyeColorID = savedColorID;
                    if savedColorID == 0 then
                        savedColorID = nil;
                    end
                    C_HousingCustomizeMode.ApplyDyeToSelectedDecor(v.ID, savedColorID);
                end
            end

            local autoApply = false;
            if anyDiff and autoApply then
                local anyChanges = C_HousingCustomizeMode.CommitDyesForSelectedDecor();
                if anyChanges then
                    PlaySound(SOUNDKIT.HOUSING_CUSTOMIZE_DYE_APPLY_CHANGED);
                    C_HousingCustomizeMode.CancelActiveEditing();
                    self:TriggerCursorBlocker();
                end
            end
        end
    end
end


do
    local function EnableModule(state)
        Handler:SetEnabled(state);
    end

    local moduleData = {
        name = L["ModuleName Housing_CustomizeMode"],
        dbKey ="Housing_CustomizeMode",
        description = L["ModuleDescription Housing_CustomizeMode"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1,
        moduleAddedTime = 1765500000,
        categoryKeys = {
            "Housing",
        },
        searchTags = {
            "Housing",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end