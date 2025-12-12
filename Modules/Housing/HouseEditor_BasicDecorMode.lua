local _, addon = ...
local L = addon.L;
local API = addon.API;
local Housing = addon.Housing;  --Housing.HouseEditorController


local C_HousingDecor = C_HousingDecor;
local GetHoveredDecorInfo = C_HousingDecor.GetHoveredDecorInfo;
local IsHoveringDecor = C_HousingDecor.IsHoveringDecor;
local IsHouseEditorActive = C_HouseEditor.IsHouseEditorActive;
local IsDecorSelected = C_HousingBasicMode.IsDecorSelected;
local GetCatalogDecorInfo = Housing.GetCatalogDecorInfo;


local Handler = Housing.HouseEditorController.CreateModeHandler("BasicDecor");
local DisplayFrame;


local DisplayFrameMixin = {};
do  --UI
    function DisplayFrameMixin:UpdateVisuals()
        --Dummy for HouseEditorInstructionsContainerMixin:CallOnChildrenThenUpdateLayout
    end

    function DisplayFrameMixin:UpdateControl()
        --Dummy for HouseEditorInstructionsContainerMixin:CallOnChildrenThenUpdateLayout
    end

    function DisplayFrameMixin:SetHotkey(instruction, bindingText)
        self.InstructionText:SetText(instruction);

        self.Control.Text:SetText(bindingText);
        self.Control.Text:Show();
        self.Control.Background:Show();
        self.Control.Icon:Hide();

        local textWidth = (self.Control.Text:GetWrappedWidth()) + 20;
        self.Control.Background:SetWidth(textWidth);
        self.Control:SetWidth(textWidth);

        self.InstructionText:ClearAllPoints();
        if textWidth > 50 then
            self.InstructionText:SetPoint("RIGHT", self, "RIGHT", -textWidth - 5, 0);
        else
            self.InstructionText:SetPoint("RIGHT", self, "RIGHT", -55, 0);
        end
    end

    function DisplayFrameMixin:OnLoad()
        self.alpha = 0;
        self:SetAlpha(0);

        self.Control.Icon:SetAtlas("housing-hotkey-icon-leftclick");
        self.Control.Icon:Show();
        self.InstructionText:SetText(HOUSING_DECOR_SELECT_INSTRUCTION);
        self.InstructionText:SetFontObject("GameFontHighlightMedium");  --GameFontHighlightLarge
    end

    local function FadeIn_OnUpdate(self, elapsed)
        self.alpha = self.alpha + 5 * elapsed;
        if self.alpha >= 1 then
            self.alpha = 1;
            self:SetScript("OnUpdate", nil);
        end
        self:SetAlpha(self.alpha);
    end

    local function FadeOut_OnUpdate(self, elapsed)
        self.alpha = self.alpha - 2 * elapsed;
        if self.alpha <= 0 then
            self.alpha = 0;
            self:SetScript("OnUpdate", nil);
        end
        if self.alpha > 1 then
            self:SetAlpha(1);
        else
            self:SetAlpha(self.alpha);
        end
    end

    function DisplayFrameMixin:FadeIn()
        self:SetScript("OnUpdate", FadeIn_OnUpdate);
    end

    function DisplayFrameMixin:FadeOut(delay)
        if delay then
            self.alpha = 2;
        end
        self:SetScript("OnUpdate", FadeOut_OnUpdate);
    end

    function DisplayFrameMixin:SetDecorInfo(decorInstanceInfo)
        self.InstructionText:SetText(decorInstanceInfo.name);
        local decorID = decorInstanceInfo.decorID;
        local entryInfo = GetCatalogDecorInfo(decorID);
        local stored = entryInfo.quantity + entryInfo.remainingRedeemable;
        self.ItemCountText:SetText(stored);
        self.ItemCountText:SetShown(stored > 0);
        self.BudgetValue:SetText(entryInfo.placementCost);
        self.SubFrame:SetShown(Handler.dupeEnabled and stored > 0);
    end
end


do
    function Handler:Init()
        self.Init = nil;

        local container = HouseEditorFrame.BasicDecorModeFrame.Instructions;
        for _, v in ipairs(container.UnselectedInstructions) do
            v:Hide();
        end
        container.UnselectedInstructions = {};

        if not DisplayFrame then
            DisplayFrame = CreateFrame("Frame", nil, container, "PlumberHouseEditorInstructionTemplate");
            DisplayFrame:SetPoint("RIGHT", HouseEditorFrame.BasicDecorModeFrame, "RIGHT", -30, 0);
            Mixin(DisplayFrame, DisplayFrameMixin);
            DisplayFrame:OnLoad();

            local BudgetIcon = DisplayFrame:CreateTexture(nil, "ARTWORK");
            DisplayFrame.BudgetIcon = BudgetIcon;
            BudgetIcon:SetSize(24, 24);
            BudgetIcon:SetTexture("Interface/AddOns/Plumber/Art/Housing/BudgetIcon");
            BudgetIcon:SetTexCoord(0, 0.5, 0, 1);
            BudgetIcon:SetPoint("RIGHT", DisplayFrame.InstructionText, "LEFT", -4, 0);

            local BudgetValue = DisplayFrame:CreateFontString(nil, "OVERLAY");
            DisplayFrame.BudgetValue = BudgetValue;
            BudgetValue:SetFont("Fonts\\FRIZQT__.TTF", 12, "");
            BudgetValue:SetPoint("CENTER", BudgetIcon, "CENTER", 0, -3);
            BudgetValue:SetText(5);
            BudgetValue:SetTextColor(232/255, 215/255, 140/255);


            local SubFrame = CreateFrame("Frame", nil, DisplayFrame, "PlumberHouseEditorInstructionTemplate");
            DisplayFrame.SubFrame = SubFrame;
            SubFrame:SetPoint("TOPRIGHT", DisplayFrame, "BOTTOMRIGHT", 0, 0);
            Mixin(SubFrame, DisplayFrameMixin);
            SubFrame:SetHotkey(L["Duplicate"], Handler:CurrentGetDupeKeyName());
        end

        container.UnselectedInstructions = {DisplayFrame};

        if IsDecorSelected() then
            DisplayFrame:Hide();
        end
    end


    Handler.dynamicEvents = {
        "HOUSE_EDITOR_MODE_CHANGED",    --1 Enum.HouseEditorMode.BasicDecor
        "HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED",
    };

    function Handler:IsEnabled()
        return self.enabled
    end

    function Handler:OnActivated()
        API.RegisterFrameForEvents(self, self.dynamicEvents);
        self:SetScript("OnEvent", self.OnEvent);
        if DisplayFrame then
            DisplayFrame:Show();
        end
        self:LoadSettings();
        self:RequestUpdateHover();
    end

    function Handler:OnDeactivated()
        API.UnregisterFrameForEvents(self, self.dynamicEvents);
        self:UnregisterEvent("MODIFIER_STATE_CHANGED");
        self:UnregisterEvent("HOUSING_STORAGE_ENTRY_UPDATED");
        self:SetScript("OnUpdate", nil);
        self.t = 0;
        self.isUpdating = nil;
        if DisplayFrame then
            DisplayFrame:Hide();
        end
    end

    function Handler:OnEvent(event, ...)
        if event == "HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED" then
            self:OnHoveredTargetChanged(...);
        elseif event == "HOUSE_EDITOR_MODE_CHANGED" then
            self:OnEditorModeChanged();
        elseif event == "MODIFIER_STATE_CHANGED" then
            if not IsHouseEditorActive() then
                self:UnregisterEvent(event);
            end
            self:OnModifierStateChanged(...)
        elseif event == "HOUSING_STORAGE_ENTRY_UPDATED" then
            self:RequestUpdateHover();
        end
    end

    function Handler:OnHoveredTargetChanged(hasHoveredTarget, targetType)
        --HousingBasicModeTargetType: 0 None, 1 Decor, 2 House
        if hasHoveredTarget then
            if not self.isUpdating then
                self.t = 0;
                self.isUpdating = true;
                self:SetScript("OnUpdate", self.OnUpdate);
                self:UnregisterEvent("MODIFIER_STATE_CHANGED");
            end
            self.t = 0;
            self.isUpdating = true;
            self.lastHoveredTargetType = targetType;
        else
            if self.decorInstanceInfo then
                self.decorInstanceInfo = nil;
            end
            if DisplayFrame then
                DisplayFrame:FadeOut(0.5);
            end
        end
    end

    function Handler:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.05 then
            self.t = 0;
            self.isUpdating = nil;
            self:SetScript("OnUpdate", nil);
            self:ProcessHoveredDecor();
        end
    end

    function Handler:RequestUpdateHover()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function Handler:ProcessHoveredDecor()
        self.decorInstanceInfo = nil;
        if IsHoveringDecor() then
            local info = GetHoveredDecorInfo(); --HousingDecorInstanceInfo, see Interface/AddOns/Blizzard_APIDocumentationGenerated/HousingDecorSharedDocumentation.lua
            if info then
                if self.dupeEnabled then
                    self:RegisterEvent("MODIFIER_STATE_CHANGED");
                end
                self.decorInstanceInfo = info;
                if DisplayFrame then
                    DisplayFrame:SetDecorInfo(info);
                    DisplayFrame:FadeIn();
                    self:RegisterEvent("HOUSING_STORAGE_ENTRY_UPDATED");
                end
                return true
            end
        end
        self:UnregisterEvent("MODIFIER_STATE_CHANGED");
        self:UnregisterEvent("HOUSING_STORAGE_ENTRY_UPDATED");

        if DisplayFrame then
            DisplayFrame:FadeOut();
        end
    end

    function Handler:GetHoveredDecorEntryID()
        if not self.decorInstanceInfo then return end;

        local decorID = self.decorInstanceInfo.decorID;
        if decorID then
            local entryInfo = GetCatalogDecorInfo(decorID)
            return entryInfo and entryInfo.entryID
        end
    end

    function Handler:TryDuplicateItem()
        if not self.dupeEnabled then return end;
        if not IsHouseEditorActive() then return end;
        if IsDecorSelected() then return end;

        local entryID = self:GetHoveredDecorEntryID();
        if not entryID then return end;

        --[[
        if (not C_HousingDecor.IsPreviewState() and self.entryInfo.quantity + self.entryInfo.remainingRedeemable <= 0) then
            return;
        end

        if self:IsBundleItem() then
            local numPlaced = self:GetNumDecorPlaced();
            if numPlaced >= self.bundleItemInfo.quantity then
                return;
            end
        end
        --]]

        local decorPlaced = C_HousingDecor.GetSpentPlacementBudget();
        local maxDecor = C_HousingDecor.GetMaxPlacementBudget();
        local hasMaxDecor = C_HousingDecor.HasMaxPlacementBudget();

        if hasMaxDecor and decorPlaced >= maxDecor then
            --StaticPopup_Show("HOUSING_MAX_DECOR_REACHED");
            return
        end

        local function StartPlacing()
            C_HousingBasicMode.StartPlacingNewDecor(entryID);
        end

        StartPlacing();
    end

    function Handler:OnEditorModeChanged()

    end

    function Handler:OnModifierStateChanged(key, down)
        if key == self.dupeKey and down == 0 then
            self:TryDuplicateItem();
        end
    end


    Handler.DuplicateKeyOptions = {
        {name = CTRL_KEY_TEXT, key = "LCTRL"},
        {name = ALT_KEY_TEXT, key = "LALT"},
    };

    function Handler:LoadSettings()
        local dupeEnabled = addon.GetDBBool("Housing_DecorHover_EnableDupe");
        local dupeKeyIndex = addon.GetDBValue("Housing_DecorHover_DuplicateKey");
        self.dupeEnabled = dupeEnabled;

        if (not type(dupeKeyIndex) == "number") and (self.DuplicateKeyOptions[dupeKeyIndex]) then
            dupeKeyIndex = 2;
        end

        self.currentDupeKeyName = self.DuplicateKeyOptions[dupeKeyIndex].name;
        self.dupeKey = self.DuplicateKeyOptions[dupeKeyIndex].key;

        if DisplayFrame and DisplayFrame.SubFrame then
            DisplayFrame.SubFrame:SetHotkey(L["Duplicate"], self:CurrentGetDupeKeyName());
            if not dupeEnabled then
                DisplayFrame.SubFrame:Hide();
            end
        end
    end

    function Handler:CurrentGetDupeKeyName()
        return self.currentDupeKeyName
    end
end


local OptionToggle_OnClick;
do  --Options
    local function InfoGetter_DecorHoverSettings()
        local tbl = {
            key = "DecorHoverSettings",
            independent = true,
        };

        local widgets = {
            {type = "Header", text = L["ModuleName Housing_DecorHover"]},
        };

        local dupeEnabled = addon.GetDBBool("Housing_DecorHover_EnableDupe");

        table.insert(widgets, {type = "Checkbox", text = L["Enable Duplicate"], tooltip = L["Enable Duplicate tooltip"], refreshAfterClick = true,
            selected = dupeEnabled,
            onClickFunc = function()
                addon.FlipDBBool("Housing_DecorHover_EnableDupe");
                Handler:LoadSettings();
            end,
        });

        table.insert(widgets, {type = "Divider"});
        table.insert(widgets, {type = "Header", text = L["Duplicate Decor Key"]});

        local selectedIndex = addon.GetDBValue("Housing_DecorHover_DuplicateKey") or 2;

        for k, v in ipairs(Handler.DuplicateKeyOptions) do
            table.insert(widgets, {
                type = "Radio",
                text = v.name;
                closeAfterClick = true,
                onClickFunc = function()
                    addon.SetDBValue("Housing_DecorHover_DuplicateKey", k, true);
                    Handler:LoadSettings();
                end,
                selected = k == selectedIndex,
                disabled = not dupeEnabled,
            });
        end

        tbl.widgets = widgets;
        return tbl
    end

    function OptionToggle_OnClick(self)
        addon.LandingPageUtil.DropdownMenu:ToggleMenu(self, InfoGetter_DecorHoverSettings);
    end
end


do
    local function EnableModule(state)
        Handler:SetEnabled(state);
    end

    local moduleData = {
        name = L["ModuleName Housing_DecorHover"],
        dbKey ="Housing_DecorHover",
        description = L["ModuleDescription Housing_DecorHover"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1,
        moduleAddedTime = 1764600000,
        optionToggleFunc = OptionToggle_OnClick,
        categoryKeys = {
            "Housing",
        },
        searchTags = {
            "Housing",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end