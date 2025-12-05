local _, addon = ...
local L = addon.L;
local API = addon.API;
local Housing = addon.Housing;


local C_HousingDecor = C_HousingDecor;
local GetHoveredDecorInfo = C_HousingDecor.GetHoveredDecorInfo;
local IsHoveringDecor = C_HousingDecor.IsHoveringDecor;
local GetActiveHouseEditorMode = C_HouseEditor.GetActiveHouseEditorMode;
local IsHouseEditorActive = C_HouseEditor.IsHouseEditorActive;
local GetCatalogEntryInfoByRecordID = C_HousingCatalog.GetCatalogEntryInfoByRecordID;
local IsDecorSelected = C_HousingBasicMode.IsDecorSelected;


local DisplayFrame;


local function GetCatalogDecorInfo(decorID, tryGetOwnedInfo)
    --Enum.HousingCatalogEntryType.Decor
    tryGetOwnedInfo = true;
    return GetCatalogEntryInfoByRecordID(1, decorID, tryGetOwnedInfo)
end


local EL = CreateFrame("Frame");


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
        self.SubFrame:SetShown(stored > 0);
    end


    --[[
        RotateControlFrame.String
        C_HousingBasicMode.RotateDecor(1)   --Top-down, counter-clockwise 15 degrees
    --]]
end

local function Blizzard_HouseEditor_OnLoaded()
    --parentKey="SelectInstruction" inherits="HouseEditorInstructionTemplate" parentArray="UnselectedInstructions"
    --HouseEditorInstructionTemplate, InstructionText

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


        local SubFrame = CreateFrame("Frame", nil, DisplayFrame, "PlumberHouseEditorInstructionTemplate");
        DisplayFrame.SubFrame = SubFrame;
        SubFrame:SetPoint("TOPRIGHT", DisplayFrame, "BOTTOMRIGHT", 0, 0);
        Mixin(SubFrame, DisplayFrameMixin);
        SubFrame:SetHotkey("Duplicate", "Ctrl");
    end

    container.UnselectedInstructions = {DisplayFrame};

    if IsDecorSelected() then
        DisplayFrame:Hide();
    end
end


do  --Event Listener
    EL.dynamicEvents = {
        "HOUSE_EDITOR_MODE_CHANGED",    --1 Enum.HouseEditorMode.BasicDecor
        "HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED",
    };
    function EL:SetEnabled(state)
        if state and not self.enabled then
            self.enabled = true;
            API.RegisterFrameForEvents(self, self.dynamicEvents);
            self:SetScript("OnEvent", self.OnEvent);
            local blizzardAddOnName = "Blizzard_HouseEditor";
            if C_AddOns.IsAddOnLoaded(blizzardAddOnName) then
                Blizzard_HouseEditor_OnLoaded();
            else
                EventUtil.ContinueOnAddOnLoaded(blizzardAddOnName, Blizzard_HouseEditor_OnLoaded);
            end
        elseif (not state) and self.enabled then
            self.enabled = nil;
            API.UnregisterFrameForEvents(self, self.dynamicEvents);
            self:UnregisterEvent("MODIFIER_STATE_CHANGED");
        end
    end

    function EL:OnEvent(event, ...)
        if event == "HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED" then
            self:OnHoveredTargetChanged(...);
        elseif event == "HOUSE_EDITOR_MODE_CHANGED" then
            self:OnEditorModeChanged(...);
        elseif event == "MODIFIER_STATE_CHANGED" then
            self:OnModifierStateChanged(...)
        end
    end

    function EL:OnHoveredTargetChanged(hasHoveredTarget, targetType)
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

    function EL:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.1 then
            self.t = 0;
            self.isUpdating = nil;
            self:SetScript("OnUpdate", nil);
            self:ProcessHoveredDecor();
        end
    end

    function EL:ProcessHoveredDecor()
        self.decorInstanceInfo = nil;
        if IsHoveringDecor() then
            local info = GetHoveredDecorInfo(); --HousingDecorInstanceInfo, see Interface/AddOns/Blizzard_APIDocumentationGenerated/HousingDecorSharedDocumentation.lua
            if info then
                self:RegisterEvent("MODIFIER_STATE_CHANGED");
                self.decorInstanceInfo = info;
                if DisplayFrame then
                    DisplayFrame:SetDecorInfo(info);
                    DisplayFrame:FadeIn();
                end
                return true
            end
        end
        self:UnregisterEvent("MODIFIER_STATE_CHANGED");

        if DisplayFrame then
            DisplayFrame:FadeOut();
        end
    end

    function EL:GetHoveredDecorEntryID()
        if not self.decorInstanceInfo then return end;

        local decorID = self.decorInstanceInfo.decorID;
        if decorID then
            local entryInfo = GetCatalogDecorInfo(decorID)
            return entryInfo and entryInfo.entryID
        end
    end

    function EL:TryDuplicateItem()
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

    function EL:OnEditorModeChanged()

    end

    function EL:OnModifierStateChanged(key, down)
        if key == "LCTRL" and down == 0 then
            self:TryDuplicateItem();
        end
    end


    EL:SetEnabled(true);
end