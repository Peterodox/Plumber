local _, addon = ...
if not (addon.HousingDataProvider and C_Item.IsDecorItem) then return end;


local L = addon.L;
local GameTooltipItemManager = addon.GameTooltipManager:GetItemManager();
local HousingDataProvider = addon.HousingDataProvider;
local IsDecorItem = C_Item.IsDecorItem;
local InCombatLockdown = InCombatLockdown;
local IsShiftKeyDown = IsShiftKeyDown;


local function ProcessItemTooltip(tooltip, itemID, itemLink, isDialogueUI)
    if IsDecorItem(itemID) then
        local modelFileID = HousingDataProvider:GetDecorModelFileIDByItem(itemID);
        if modelFileID then
            if not InCombatLockdown() then
                tooltip:AddLine(" ");
                if IsShiftKeyDown() then
                    tooltip:AddDoubleLine("ModelFileID", modelFileID, 1, 0.82, 0, 1, 1, 1);
                    tooltip:AddLine(" ");
                end
                tooltip:AddLine(L["Instruction View In Dressing Room"], 0.098, 1.000, 0.098, true);
                return true
            end
        else
            if HousingDataProvider:IsLoadingData() then
                tooltip:AddLine(L["Data Loading In Progress"], 0.5, 0.5, 0.5, true);
            end
        end
    end
    return false
end


local ItemSubModule = {};
do
    function ItemSubModule:ProcessData(tooltip, itemID)
        if self.enabled then
            return ProcessItemTooltip(tooltip, itemID)
        else
            return false
        end
    end

    function ItemSubModule:GetDBKey()
        return "TooltipHousing"
    end

    function ItemSubModule:SetEnabled(enabled)
        self.enabled = enabled == true;
        GameTooltipItemManager:RequestUpdate();
    end

    function ItemSubModule:IsEnabled()
        return self.enabled == true
    end
end


do  --Preview In Dressing Room
    --OrbitCameraMixin:GetDeltaModifierForCameraMode
    local function GetDeltaModifierForCameraMode(self, mode)
        if mode == 1 then
            return .008;
        elseif mode == 2 then
            return -.008;   --Reverse Pitch
        elseif mode == 3 then
            return .008;
        elseif mode == 4 then
            return .1;
        elseif mode == 5 then
            return .05;
        elseif mode == 6 then
            return .05;
        elseif mode == 7 then
            return 0.93;
        elseif mode == 8 then
            return 0.93;
        end
        return 0.0;
    end

    local function ResetBackground()
        --local _, raceFilename = UnitRace("player");
        local _, classFilename = UnitClass("player");
        DressUpFrame.ModelBackground:SetAtlas("dressingroom-background-"..classFilename);
    end

    local function DressUpLink_Callback(link)
        if (not ItemSubModule:IsEnabled()) or InCombatLockdown() then return end;

        local itemID = link and C_Item.GetItemInfoInstant(link);
        if itemID and IsDecorItem(itemID) then
            local modelFileID = HousingDataProvider:GetDecorModelFileIDByItem(itemID);
            if modelFileID then
                local frame = DressUpFrame;
                if not frame:IsShown() then
                    ShowUIPanel(frame);
                end

                frame.ModelScene:ClearScene();
                frame.ModelScene:SetViewInsets(0, 0, 0, 0);
                frame.ModelScene:ReleaseAllActors();
                local forceSceneChange = true;
	            frame.ModelScene:TransitionToModelSceneID(Constants.HousingCatalogConsts.HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);
                frame.ModelBackground:SetColorTexture(0.05, 0.05, 0.05);
                frame.OutfitDetailsPanel:Hide();

                local actor = frame.ModelScene:GetActorByTag("decor");
                if actor then
                    actor:SetPreferModelCollisionBounds(true);
                    actor:SetModelByFileID(modelFileID);
                end

                local activeCamera = frame.ModelScene:GetActiveCamera();
                if activeCamera then
                    activeCamera.GetDeltaModifierForCameraMode = GetDeltaModifierForCameraMode;
                    activeCamera:SetLeftMouseButtonYMode(ORBIT_CAMERA_MOUSE_MODE_PITCH_ROTATION, true);
                end
            end
        end
    end

    hooksecurefunc("DressUpLink", DressUpLink_Callback);
    DressUpFrame.ResetButton:HookScript("OnClick", ResetBackground);
end


do
    local function ProcessItemTooltip_DialogueUI(tooltip, itemID, itemLink)
        return ProcessItemTooltip(tooltip, itemID, itemLink, true)
    end

    local function EnableModule(state)
        ItemSubModule:SetEnabled(state);
        if state then
            GameTooltipItemManager:AddSubModule(ItemSubModule);
        end

        --if DialogueUIAPI and DialogueUIAPI.AddItemTooltipProcessorExternal then
        --    DialogueUIAPI.AddItemTooltipProcessorExternal(ProcessItemTooltip_DialogueUI);
        --end
    end

    local moduleData = {
        name = addon.L["ModuleName TooltipHousing"],
        dbKey = ItemSubModule:GetDBKey(),
        description = addon.L["ModuleDescription TooltipHousing"],
        toggleFunc = EnableModule,
        categoryID = 3,
        uiOrder = 2000,
        moduleAddedTime = 1755200000,
    };

    addon.ControlCenter:AddModule(moduleData);
end