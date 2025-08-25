-- Modifications prevent player from opening Dressing Room during combat


local _, addon = ...
local API = addon.API;
local L = addon.L;


local Loader = CreateFrame("Frame", nil, UIParent);


local AppendItemModelMixin = {};
do
    local Model_ApplyUICamera = Model_ApplyUICamera;
    local After = C_Timer.After;

    function AppendItemModelMixin:OnModelLoaded()
        if ( self.cameraID ) then
            Model_ApplyUICamera(self, self.cameraID);
        end
        self.desaturated = false;

        if not Loader.enabled then return end;

        if Loader.isWeapon then
            return
        end

        Loader:LoadNextModel();
        After(0, function()
            Loader:LoadWidgetVisualInfo(self);
        end);
    end

    function AppendItemModelMixin:SetUnit(unit, blend, useNativeForm)
        if Loader.enabled then
            Loader:QueueModelWidget(self, unit, blend, useNativeForm);
        else
            self.RealSetUnit(self, unit, blend, useNativeForm);
        end
    end


    function AppendItemModelMixin:SetItemAppearance(...)
        --appearanceVisualID, visualID, appearanceVisualSubclass
        if Loader.enabled then
            Loader:RemoveWidgetFromQueue(self);
        end
        self.RealSetItemAppearance(self, ...);
    end

    function AppendItemModelMixin:OnMouseDown(button)
        if (IsModifiedClick("DRESSUP")) and API.CheckAndDisplayErrorIfInCombat() then
            return
        end
        WardrobeItemsModelMixin.OnMouseDown(self, button);
    end
end


do
    Loader.delayBetweenLoading = 0.1;
    Loader.queue = {};
    Loader.queuedModels = {};

    local tremove = table.remove;


    local ModelLayoutOptions = {
        --{row, col}
        {2, 3},     --Addon Default
        {2, 4},
        {3, 3},
        {3, 4},
        {3, 5},
        {3, 6},     --Game Default
    };

    function Loader:ClearQueue()
        self.t = 0;
        self:SetScript("OnUpdate", nil);
        self.queue = {};
        self.queuedModels = {};
    end

    function Loader:LoadNextModel()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function Loader:RemoveWidgetFromQueue(widget)
        if self.queuedModels[widget] then
            self.queuedModels[widget] = nil;
            for i, widgetInfo in ipairs(self.queue) do
                if widgetInfo.widget == widget then
                    tremove(self.queue, i);
                    return
                end
            end
        end
    end

    function Loader:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > self.delayBetweenLoading then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            local widgetInfo = tremove(self.queue, 1);
            if widgetInfo then
                local widget = widgetInfo.widget;
                self.queuedModels[widget] = nil;
                if widget:IsVisible() then
                    widget.RealSetUnit(widget, widgetInfo.unit, widgetInfo.blend, widgetInfo.useNativeForm);
                else
                    self:SetScript("OnUpdate", self.OnUpdate);
                end
            end
        end
    end

    function Loader:QueueModelWidget(widget, unit, blend, useNativeForm)
        self:RemoveWidgetFromQueue(widget);

        local index = self.queuedModels[widget];

        if not index then
            index = #self.queue + 1;
            self.queuedModels[widget] = index;
        end

        widget:ClearModel();

        self.queue[index] = {
            widget = widget,
            unit = unit,
            blend = blend,
            useNativeForm = useNativeForm,
        };

        self:LoadNextModel();
    end

    function Loader:LoadWidgetVisualInfo(model)
        local visualInfo = model.visualInfo;
        if not (visualInfo and model:IsVisible()) then return end;

        local f = WardrobeCollectionFrame.ItemsCollectionFrame;
        local canDisplayVisuals = f.transmogLocation and f.transmogLocation:IsIllusion() or visualInfo.canDisplayOnPlayer;
        if not f.activeCategory then return end;
        local _, isWeapon = C_TransmogCollection.GetCategoryInfo(f.activeCategory);
		local isArmor = not isWeapon;

        if ( not canDisplayVisuals ) then
            if ( isArmor ) then
                model:UndressSlot(f.transmogLocation:GetSlotID());
            end
        elseif ( isArmor ) then
            local sourceID = f:GetAnAppearanceSourceFromVisual(visualInfo.visualID, nil);
            model:TryOn(sourceID);
        end
    end

    function Loader:Init()
        self.Init = nil;

        local parentFrame = WardrobeCollectionFrame;
        local appearanceTab = parentFrame and parentFrame.ItemsCollectionFrame;
        if not appearanceTab then return end;

        local Mixin = Mixin;

        for i, model in ipairs(appearanceTab.Models) do
            model.RealSetUnit = model.SetUnit;
            model.RealSetItemAppearance = model.SetItemAppearance;
            Mixin(model, AppendItemModelMixin);
            model:SetScript("OnModelLoaded", AppendItemModelMixin.OnModelLoaded);
            model:SetScript("OnMouseDown", AppendItemModelMixin.OnMouseDown);
        end

        local processed = false;
        parentFrame:HookScript("OnKeyDown", function(self, key)
            if (not processed) and (key == "ESCAPE" and not InCombatLockdown()) then
                processed = true;
                self:SetPropagateKeyboardInput(true);
            end
        end)

        if not InCombatLockdown() then
            parentFrame:SetPropagateKeyboardInput(true);
        end


        hooksecurefunc(appearanceTab, "SetActiveCategory", function(f, category)
            if category then
                local _, isWeapon = C_TransmogCollection.GetCategoryInfo(category);
                if isWeapon or (appearanceTab.transmogLocation and appearanceTab.transmogLocation:IsIllusion()) then
                    Loader.isWeapon = true;
                else
                    Loader.isWeapon = false;
                end
            else    --Illusion
                Loader.isWeapon = true;
            end
            self.activeCategory = category;
        end);


        self.lastPages = {};

        local function SaveCurrentPage(lastPage)
            local category = appearanceTab.activeCategory or -1;  --illusion has no category
            lastPage = lastPage or 1;
            self.lastPages[category] = lastPage;
        end

        local function PagingFrameChangePageCallback(f)
            SaveCurrentPage(f.currentPage);
        end

        hooksecurefunc(appearanceTab.PagingFrame, "NextPage", PagingFrameChangePageCallback);
        hooksecurefunc(appearanceTab.PagingFrame, "PreviousPage", PagingFrameChangePageCallback);


        hooksecurefunc(appearanceTab.PagingFrame, "SetMaxPages", function(f, maxPages)
            --print("maxPages", maxPages)
        end);




        --Override WardrobeItemsCollectionMixin.ResetPage
        do
            local function ItemsCollectionFrame_ResetPage(self)
                local category = appearanceTab.activeCategory or -1;
                local page = Loader.enabled and Loader.lastPages[category] or 1;
                local selectedVisualID = NO_TRANSMOG_VISUAL_ID;
                if ( C_TransmogCollection.IsSearchInProgress(self:GetParent():GetSearchType()) ) then
                    self.resetPageOnSearchUpdated = true;
                else
                    if ( self.jumpToVisualID ) then
                        selectedVisualID = self.jumpToVisualID;
                        self.jumpToVisualID = nil;
                    elseif ( self.jumpToLatestAppearanceID and not C_Transmog.IsAtTransmogNPC() ) then
                        selectedVisualID = self.jumpToLatestAppearanceID;
                        self.jumpToLatestAppearanceID = nil;
                    end
                end
                if ( selectedVisualID and selectedVisualID ~= NO_TRANSMOG_VISUAL_ID ) then
                    local visualsList = self:GetFilteredVisualsList();
                    for i = 1, #visualsList do
                        if ( visualsList[i].visualID == selectedVisualID ) then
                            page = CollectionWardrobeUtil.GetPage(i, self.PAGE_SIZE);
                            break;
                        end
                    end
                end
                self.PagingFrame:SetCurrentPage(page);
                self:UpdateItems();
            end

            function appearanceTab:ResetPage()
                if ( C_TransmogCollection.IsSearchInProgress(self:GetParent():GetSearchType()) ) then
                    self.resetPageOnSearchUpdated = true;
                end

                if not self.pendingResetPage then
                    self.pendingResetPage = true;
                    C_Timer.After(0, function()
                        self.pendingResetPage = nil;
                        if self:IsVisible() then
                            ItemsCollectionFrame_ResetPage(self);
                        end
                    end);
                end
            end
        end

        --When you are already viewing the corresponding category, click the slot button again to go to page 1
        do
            local function ItemsCollectionSlotButtonMixin_OnClick(self, button)
                if self.SelectedTexture:IsShown() then
                    if appearanceTab.PagingFrame:GetCurrentPage() >= 1 then
                        SaveCurrentPage(1);
                        appearanceTab:ResetPage();
                    end
                    return
                else
                    WardrobeItemsCollectionSlotButtonMixin.OnClick(self, button);
                end
            end

            if appearanceTab.SlotsFrame and appearanceTab.SlotsFrame.Buttons then
                for _, button in ipairs(appearanceTab.SlotsFrame.Buttons) do
                    button:SetScript("OnClick", ItemsCollectionSlotButtonMixin_OnClick);
                end
            end
        end

        self:HookIntoMenu();

        self:LoadSettings();
    end

    function Loader:LoadSettings(userInput)
        local values = ModelLayoutOptions;
        local optionIndex = addon.GetDBValue("AppearanceTab_ModelCount");
        if not (optionIndex and values[optionIndex]) then
            optionIndex = 1;
        end
        self.modelLayoutOptionIndex = optionIndex;
        self:SetRowAndCol(values[optionIndex][1], values[optionIndex][2], userInput);
    end

    function Loader:SetRowAndCol(numRow, numCol, userInput)
        local gapH, gapV = 16, 24;
        local modelWidth, modelHeight = 78, 104;
        local pageSize = numRow * numCol;

        local appearanceTab = WardrobeCollectionFrame.ItemsCollectionFrame;

        appearanceTab.NUM_ROWS = numRow;
        appearanceTab.NUM_COLS = numCol;
        appearanceTab.PAGE_SIZE = pageSize;

        local fromOffsetY = -92;
        local fromOffsetX = -math.floor(0.5 * (numCol * (modelWidth + gapH) - gapH));
        local row = 0;
        local col = 0;

        for i, model in ipairs(appearanceTab.Models) do
            if i > pageSize then
                model:Hide();
                model:ClearModel();
            else
                col = col + 1;
                if col > numCol then
                    col = 1;
                    row = row + 1;
                end
                model:ClearAllPoints();
                model:SetPoint("TOPLEFT", appearanceTab, "TOP", fromOffsetX + (col - 1) * (modelWidth + gapH), fromOffsetY - row * (modelHeight + gapV));
            end
        end

        if userInput and appearanceTab:IsVisible() then
            local reloadSlot = appearanceTab:GetActiveSlot();
            if reloadSlot then
                self:ClearQueue();
                for i, model in ipairs(appearanceTab.Models) do
                    model:ClearModel();
                    model.visualInfo = nil;
                    model:Reload(reloadSlot);
                end
            end
            if appearanceTab.filteredVisualsList then
                appearanceTab.PagingFrame:SetMaxPages(math.ceil(#appearanceTab.filteredVisualsList / appearanceTab.PAGE_SIZE));
            end
            appearanceTab:ResetPage();
        end
    end

    function Loader:OnEvent(event, addOnName)
        if addOnName == "Blizzard_Collections" then
            self:UnregisterEvent(event);
            self:SetScript("OnEvent", nil);
            if self.Init then
                self:Init();
            end
        end
    end

    function Loader:HookIntoMenu()
        if not self.isMenuHooked then
            self.isMenuHooked = true;
        else
            return
        end

        self.isMenuHooked = true;

        if Menu and Menu.ModifyMenu then
            Menu.ModifyMenu("MENU_WARDROBE_FILTER", function(owner, rootDescription, contextData)
                if not Loader.enabled then return end;

                rootDescription:CreateDivider();
                rootDescription:CreateTitle("Plumber");

                local submenu = rootDescription:CreateButton(L["Model Layout"]);

                local function IsSelected(index)
                    return index == Loader.modelLayoutOptionIndex;
                end

                local function SetSelected(index)
                    addon.SetDBValue("AppearanceTab_ModelCount", index, true);
                    Loader:LoadSettings(true);
                    return (MenuResponse and MenuResponse.Refresh) or 2
                end

                for index, v in ipairs(ModelLayoutOptions) do
                    local text = string.format("%s x %s", v[1], v[2]);
                    submenu:CreateRadio(text, IsSelected, SetSelected, index);
                end
            end);
        end
    end

    function Loader:EnableModule(state)
        if state and not self.enabled then
            self.enabled = true;
            if self.Init then
                if C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
                    self:Init();
                else
                    self:RegisterEvent("ADDON_LOADED");
                    self:SetScript("OnEvent", self.OnEvent);
                end
            else
                self:LoadSettings(true);
            end
        elseif (not state) and self.enabled then
            self.enabled = nil;
            self:UnregisterEvent("ADDON_LOADED");
            self:SetScript("OnEvent", nil);
            if not self.Init then
                self:SetRowAndCol(3, 6);
            end
        end
    end
end




local function EnableModule(state)
    Loader:EnableModule(state);
end


do
    local moduleData = {
        name = L["ModuleName AppearanceTab"],
        dbKey = "AppearanceTab",
        description = L["ModuleDescription AppearanceTab"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1180,
        moduleAddedTime = 1755200000,
    };

    addon.ControlCenter:AddModule(moduleData);
end