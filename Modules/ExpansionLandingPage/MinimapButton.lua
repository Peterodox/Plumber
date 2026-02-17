local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;
local LandingPageUtil = addon.LandingPageUtil;
local GetDBBool = addon.GetDBBool;


PlumberLandingPageMinimapButtonMixin = {};
local ButtonMixin = PlumberLandingPageMinimapButtonMixin;


local EL = CreateFrame("Frame");
local DragController = CreateFrame("Frame", nil, UIParent);
local UIParentContainer = CreateFrame("Frame", nil, UIParent);
local MiniButton;
local MenuSchematc;


local Def = {
    TextureFile = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/LandingButton.png",
    ButtonBaseSize = 36,
    ReLockCountdown = 2,        --After unlocking minimap position, re-lock it after x seconds when the button loses focus
    DragStartThreshold = 8,     --Mouse-down and move this distance to initiate repositioning
};


local Options = {};
local OrderHallUtil = {};
local ButtonManager = {};       --For handling LibDataBroker and LibDBIcon


do  --ButtonMixin
    function ButtonMixin:OnLoad()
        if not MiniButton then
            MiniButton = self;

            --Some minimap addon overrides SetPoint to prevent moving
            --We disable our drag to move feature when this API is modified
            ButtonManager.SetPoint = self.SetPoint;
            ButtonManager.SetParent = self.SetParent;
            ButtonManager.SetSize = self.SetSize;
        end

        local f = self.VisualContainer;
        API.DisableSharpening(f.BaseTexture);
        f.BaseTexture:SetTexture(Def.TextureFile);
        f.BaseTexture:SetTexCoord(0, 0.25, 0, 0.25);
        API.DisableSharpening(f.HighlightTexture);
        f.HighlightTexture:SetTexture(Def.TextureFile);
        f.HighlightTexture:SetTexCoord(0, 0.25, 0.25, 0.5);
        API.DisableSharpening(f.WarningTexture);
        f.WarningTexture:SetTexture(Def.TextureFile);
        f.WarningTexture:SetTexCoord(0.25, 0.5, 0.25, 0.5);

        f = self.InstructionFrame;
        API.DisableSharpening(f.BackgroundCenter);
        f.BackgroundCenter:SetTexture(Def.TextureFile);
        f.BackgroundCenter:SetTexCoord(96/512, 160/512, 0.5, 0.75);
        API.DisableSharpening(f.BackgroundLeft);
        f.BackgroundLeft:SetTexture(Def.TextureFile);
        f.BackgroundLeft:SetTexCoord(0/512, 96/512, 0.5, 0.75);
        API.DisableSharpening(f.BackgroundRight);
        f.BackgroundRight:SetTexture(Def.TextureFile);
        f.BackgroundRight:SetTexCoord(160/512, 256/512, 0.5, 0.75);

        self.MouseoverFrame:SetScript("OnEnter", function()
            self:UpdateVisibility(true);
        end);

        self.MouseoverFrame:SetScript("OnLeave", function()
            self:UpdateVisibility(true);
        end);
    end

    function ButtonMixin:OnEnter()
        if not DragController.stage then
            self.VisualContainer.HighlightTexture:Show();
            self:ShowTooltip();
        end
    end

    function ButtonMixin:OnLeave()
        self.VisualContainer.HighlightTexture:Hide();
        GameTooltip:Hide();
    end

    function ButtonMixin:OnMouseDown()
        self.VisualContainer:SetScale(0.95);
        if self:IsMovable() and self.SetPoint == ButtonManager.SetPoint then
            DragController:SetDraggedObject(self);
        end
    end

    function ButtonMixin:OnMouseUp()
        self.VisualContainer:SetScale(1);
        DragController:Stop();
    end

    function ButtonMixin:OnClick(button)
        if self:CloseContextMenu() and button == "RightButton" then
            return
        end

        if button == "RightButton" then
            self:ShowContextMenu();
            return
        end

        if (not DragController.isDragging) then
            if OrderHallUtil.ToggleGarrisonUI() then
                return
            end

            if Options.GetChoice_PrimaryUI() == 2 then
                OrderHallUtil.ToggleBlizzardJourneys();
            else
                LandingPageUtil.ToggleUI();
            end
        end
    end

    function ButtonMixin:OnHide()
        DragController:Stop();
        DragController.isDragging = nil;
    end

    function ButtonMixin:UpdateResolution()
        local pixel = API.GetTexturePixelSize(self.VisualContainer.BaseTexture);
        if pixel > 96 then
            if self.darkMode then
                self.VisualContainer.BaseTexture:SetTexCoord(288/512, 416/512, 0, 0.25);
            else
                self.VisualContainer.BaseTexture:SetTexCoord(0, 0.25, 0, 0.25);
            end
        elseif pixel > 64 then
            if self.darkMode then
                self.VisualContainer.BaseTexture:SetTexCoord(416/512, 1, 0, 96/512);
            else
                self.VisualContainer.BaseTexture:SetTexCoord(128/512, 224/512, 0, 96/512);
            end
        else
            if self.darkMode then
                self.VisualContainer.BaseTexture:SetTexCoord(224/512, 288/512, 64/512, 128/512);
            else
                self.VisualContainer.BaseTexture:SetTexCoord(224/512, 288/512, 0, 64/512);
            end
        end
    end

    function ButtonMixin:UseDarkMode(state)
        self.darkMode = state;
        self:UpdateResolution();
    end

    function ButtonMixin:OnSizeChanged(width, height)
        local d = math.max(width, height);
        d = API.Round(d);
        self.VisualContainer.BaseTexture:SetSize(64/Def.ButtonBaseSize*d, 64/Def.ButtonBaseSize*d);
        self:UpdateResolution();
    end

    function ButtonMixin:HandlesGlobalMouseEvent(buttonName, event)
        return self:IsMouseMotionFocus()
    end

    function ButtonMixin:ShowTooltip()
        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_LEFT", 4, -2);
        tooltip:SetText(LandingPageUtil.GetModuleNameWithHotkey(), 1, 1, 1);
        tooltip:AddLine(L["LandingButton Tooltip Format"]:format(OrderHallUtil.GetCurrentBestUIName(), 1, 0.82, 0, false));
        tooltip:Show();
    end

    function ButtonMixin:UpdateVisibility(animating)
        self.enabled = ButtonManager:ShouldShowPlumberButton();
        if self.enabled then
            self:Show();
            if GetDBBool("LandingButton_HideWhenIdle") then
                self.MouseoverFrame:Show();
                if self.MouseoverFrame:IsMouseMotionFocus() or (self.shownMenu and self.shownMenu:IsVisible()) or (Options.isSettingsShown) then
                    if animating then
                        self.alpha = self:GetAlpha();
                        self.MouseoverFrame:SetScript("OnUpdate", function(f, elapsed)
                            self.alpha = self.alpha + 8 * elapsed;
                            if self.alpha >= 1 then
                                self.alpha = 1;
                                f:SetScript("OnUpdate", nil);
                            end
                            self:SetAlpha(self.alpha);
                        end);
                    else
                        self:SetAlpha(1);
                        self.MouseoverFrame:SetScript("OnUpdate", nil);
                    end
                else
                    if animating then
                        self.alpha = self:GetAlpha();
                        if self.alpha >= 0.98 then
                            self.alpha = 1;
                            self.t = -1;
                            self:SetAlpha(1);
                            self.MouseoverFrame:SetScript("OnUpdate", function(f, elapsed)
                                self.t = self.t + elapsed;
                                if self.t > 0 then
                                    self.alpha = self.alpha - 4 * elapsed;
                                    if self.alpha <= 0 then
                                        self.alpha = 0;
                                        f:SetScript("OnUpdate", nil);
                                    end
                                    self:SetAlpha(self.alpha);
                                end
                            end);
                        else
                            self.MouseoverFrame:SetScript("OnUpdate", function(f, elapsed)
                                self.alpha = self.alpha - 4 * elapsed;
                                if self.alpha <= 0 then
                                    self.alpha = 0;
                                    f:SetScript("OnUpdate", nil);
                                end
                                self:SetAlpha(self.alpha);
                            end);
                        end
                    else
                        self:SetAlpha(0);
                        self.MouseoverFrame:SetScript("OnUpdate", nil);
                    end
                end
            else
                self:SetAlpha(1);
                self.MouseoverFrame:Hide();
            end
        end
        self:SetShown(self.enabled);
        OrderHallUtil.EnableBlizzardButton(not self.enabled);
    end
end


do  --Button Drag Lock / Instructions
    function ButtonMixin:ShowDragInstruction(state)
        self.VisualContainer.WarningTexture:SetShown(state);
        self.InstructionFrame:SetShown(state);
        if state then
            self.VisualContainer.HighlightTexture:Hide();
            GameTooltip:Hide();

            self.InstructionFrame.Text:SetText(L["LandingButton Reposition Tooltip"]);
            local textWidth = self.InstructionFrame.Text:GetWidth();
            local fullWidth = textWidth + 44;
            if fullWidth < 128 then
                fullWidth = 128;
            end
            local sideWidth = 0.5*(fullWidth - 24);
            self.InstructionFrame:SetWidth(fullWidth);
            self.InstructionFrame.BackgroundLeft:SetWidth(sideWidth);
            self.InstructionFrame.BackgroundRight:SetWidth(sideWidth);
        end
    end
end


do  --Button Position/Anchor
    local function MinimapButton_SetAngle(button, radian)
        local x, y = math.cos(radian), math.sin(radian);
        local radialOffset = 6;
        local w = Minimap:GetWidth() / 2 + radialOffset;
        local h = Minimap:GetHeight() / 2 + radialOffset;
        x, y = x*w, y*h;
        button:SetPoint("CENTER", Minimap, "CENTER", x, y);
    end

    DragController.GetCursorPosition = API.GetScaledCursorPosition;
    DragController.IsShiftKeyDown = IsShiftKeyDown;
    DragController.dragStartDistance = Def.DragStartThreshold^2;

    function DragController:SetDraggedObject(object)
        self.draggedObject = object;
        self:PreDragStart();
    end

    function DragController:SnapshotCursorPosition()
        local x, y = self.GetCursorPosition();
        self.x, self.y = x, y;
        self.x0, self.y0 = x, y;
    end

    function DragController:PreDragStart()
        self:SnapshotCursorPosition();
        self.t = 0;
        self.stage = 1;
        self:SetScript("OnUpdate", self.OnUpdate_PreDrag);
    end

    function DragController:OnUpdate_ListenShift(elapsed)
        if self.IsShiftKeyDown() then
            self:SetScript("OnUpdate", nil);
            self:DraggingStart();
        end
    end

    function DragController:OnUpdate_PreDrag(elapsed)
        self.x, self.y = self.GetCursorPosition();
        if (self.x - self.x0) ^ 2 + (self.y - self.y0) ^ 2 >= self.dragStartDistance then
            self.stage = 2;
            self.isDragging = true;
            self:SetScript("OnUpdate", nil);
            local currentTime = time();
            if (not self.IsShiftKeyDown()) and ((not self.lastUnlockTime) or (self.lastUnlockTime and currentTime > self.lastUnlockTime + Def.ReLockCountdown)) then
                self:SetScript("OnUpdate", self.OnUpdate_ListenShift);
                MiniButton:ShowDragInstruction(true);
            else
                self:DraggingStart();
            end
        end
    end

    local function GetMiniButtonRelativePosition()
        local x, y = MiniButton:GetCenter();
        local _x, _y = Minimap:GetCenter();
        if x and y and _x and _y then
            return API.RoundCoord(x - _x), API.RoundCoord(y - _y)
        end
    end

    local function GetMiniButtonAbsolutePosition()
        local x, y = MiniButton:GetCenter();
        if x and y then
            return API.RoundCoord(x), API.RoundCoord(y)
        end
    end

    function DragController:DraggingStart()
        self.lastUnlockTime = time();
        self:SnapshotCursorPosition();

        local x, y = self.draggedObject:GetCenter();
        self.dx = x - self.x;
        self.dy = y - self.y;

        local scalar = UIParent:GetEffectiveScale()/Minimap:GetEffectiveScale();
        local relativeTo = Minimap;
        local fromX, fromY = GetMiniButtonRelativePosition();

        local function SetObjectPosition(dx, dy)
            dx = dx * scalar;
            dy = dy * scalar;
            self.draggedObject:SetPoint("CENTER", relativeTo, "CENTER", fromX + dx, fromY + dy);
        end
        self.SetObjectPosition = SetObjectPosition;

        --MiniButton:ClearAllPoints();
        MiniButton:OnDragStart();

        self.t = 1;
        self.stage = 3;
        self.isDragging = true;
        self:SetScript("OnUpdate", self.OnUpdate_Dragging);
    end

    function DragController:OnUpdate_Dragging(elapsed)
        self.x, self.y = self.GetCursorPosition();
        self.SetObjectPosition(self.x - self.x0, self.y - self.y0);
        self.t = self.t + elapsed;
    end

    function DragController:OnUpdate_PostDragging()
        self:SetScript("OnUpdate", nil);
        self.isDragging = nil;
        if MiniButton:IsMouseMotionFocus() then
            MiniButton:OnEnter();
        end
    end

    function DragController:Stop()
        --Stage1: PreDrag
        --Stage2: ListenShift
        --Stage3: Dragging

        self:SetScript("OnUpdate", nil);
        self.x, self.y = 0, 0;
        self.x0, self.y0 = 0, 0;
        self.dx, self.dy = 0, 0;
        self.t = 0;
        if self.stage == 2 or self.stage == 3 then
            self:SetScript("OnUpdate", self.OnUpdate_PostDragging);
            if self.stage == 3 then
                PlumberDB.LandingButton_Pos_X, PlumberDB.LandingButton_Pos_Y = GetMiniButtonRelativePosition();
                PlumberDB.LandingButton_AbsPos_X, PlumberDB.LandingButton_AbsPos_Y = GetMiniButtonAbsolutePosition();
                MiniButton:UpdatePosition();
                addon.UpdateSettingsDialog();
                self.lastUnlockTime = time();
            end
        end
        self.stage = nil;
        MiniButton:ShowDragInstruction(false);
    end

    function DragController:OnHide()
        self:Stop();
    end
    DragController:SetScript("OnHide", DragController.OnHide);


    function ButtonMixin:OnDragStart()
        self.VisualContainer:SetScale(1);
        self.VisualContainer.HighlightTexture:Hide();
        self:ShowDragInstruction(false);
        GameTooltip:Hide();
        self:CloseContextMenu();
    end

    function ButtonMixin:UpdatePosition()
        self:ClearAllPoints();

        local function IsCoordValid(x, y)
            return x and y and type(x) == "number" and type(y) == "number"
        end

        if GetDBBool("LandingButton_Unaffected") then
            local x, y = PlumberDB.LandingButton_AbsPos_X, PlumberDB.LandingButton_AbsPos_Y;
            if not IsCoordValid(x, y) then
                local _x, _y = PlumberDB.LandingButton_Pos_X, PlumberDB.LandingButton_Pos_Y;
                if not IsCoordValid(_x, _y) then
                    MinimapButton_SetAngle(self, math.rad(-140));
                else
                    self:SetPoint("CENTER", Minimap, "CENTER", _x, _y);
                end
                x, y = GetMiniButtonAbsolutePosition();
                PlumberDB.LandingButton_AbsPos_X = x;
                PlumberDB.LandingButton_AbsPos_Y = y;
                self:ClearAllPoints();
            end

            if x and y then
                self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
            else
                MinimapButton_SetAngle(self, math.rad(-140));
            end
        else
            local x, y = PlumberDB.LandingButton_Pos_X, PlumberDB.LandingButton_Pos_Y;
            if not IsCoordValid(x, y) then
                MinimapButton_SetAngle(self, math.rad(-140));
            else
                self:SetPoint("CENTER", Minimap, "CENTER", x, y);
            end
        end
    end


    do  --So that when Unaffected change from false to true, HidingBar won't throw errors when hovering over the button
        --Because HidingBar use button:GetParent() to find its bar
        UIParentContainer.config = {};

        function UIParentContainer.enter()
        end

        function UIParentContainer.leave()
        end
    end
end


do  --Order Hall, RightClickMenu
    function OrderHallUtil.ToggleBlizzardJourneys()
        if API.CheckAndDisplayErrorIfInCombat() then return end;
        if not EncounterJournal then
            EncounterJournal_LoadUI();
        end

        local tabID = EncounterJournal.JourneysTab:GetID();
        if EncounterJournal:IsShown() and EncounterJournal.selectedTab == tabID then
            HideUIPanel(EncounterJournal);
        else
            ShowUIPanel(EncounterJournal);
            EJ_ContentTab_Select(tabID);
        end
    end

    function OrderHallUtil.OpenGarrisonReport(garrTypeID)
        if API.CheckAndDisplayErrorIfInCombat() then return end;

        local frame = GarrisonLandingPage;
        if frame then
            HideUIPanel(frame);

            if frame.SoulbindPanel then
                frame.SoulbindPanel:Hide();
            end

            if frame.CovenantCallings then
                frame.CovenantCallings:Hide();
            end

            if frame.ArdenwealdGardeningPanel then
                frame.ArdenwealdGardeningPanel:Hide();
            end
        end

        ShowGarrisonLandingPage(garrTypeID);

        if garrTypeID == Enum.GarrisonType.Type_9_0_Garrison then
            local unlocked = C_CovenantCallings.AreCallingsUnlocked();
            if unlocked and frame and frame.CovenantCallings then
                frame.CovenantCallings:Show();
            end
        end
    end

    function OrderHallUtil.IsAnyMission(garrTypeID)
        local garrFollowerTypeID = GetPrimaryGarrisonFollowerType(garrTypeID);
        local info1 = C_Garrison.GetAvailableMissions(garrFollowerTypeID);
        local info2 = C_Garrison.GetInProgressMissions(garrFollowerTypeID);
        return info1 ~= nil or info2 ~= nil

        --For BFA Mission, the API returns nil if the feature isn't unlocked
    end

    function OrderHallUtil.GetNumCompletedMission(garrTypeID)
        local items = C_Garrison.GetLandingPageItems(garrTypeID);
        local n = 0;
        if items then
            for _, v in ipairs(items) do
                if v.completed or v.isComplete then
                    n = n + 1;
                end
            end
        end
        return n
    end

    function OrderHallUtil.GetMissionTooltip(garrTypeID)
        local numCompleted = OrderHallUtil.GetNumCompletedMission(garrTypeID);
        if numCompleted > 0 then
            return L["Mission Complete Count Format"]:format(numCompleted), 0.098, 1.000, 0.098
        end
    end

    function OrderHallUtil.IsCovenantUnlocked()
        local id = C_Covenants.GetActiveCovenantID();
        if id and id ~= 0 then
            return OrderHallUtil.IsAnyMission(Enum.GarrisonType.Type_9_0_Garrison)
        end
        return false
    end

    local OrderHallButtons = {
        --WoD Garrison
        {type = "Button", name = GARRISON_LANDING_PAGE_TITLE, garrTypeID = Enum.GarrisonType.Type_6_0_Garrison},

        --LEG Class Hall
        {type = "Button", name = ORDER_HALL_LANDING_PAGE_TITLE, garrTypeID = Enum.GarrisonType.Type_7_0_Garrison},

        --BFA Missions
        {type = "Button", name = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, garrTypeID = Enum.GarrisonType.Type_8_0_Garrison},

        --Covenant Sanctum
        {type = "Button", name = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE, garrTypeID = Enum.GarrisonType.Type_9_0_Garrison, IsEnabledFunc = OrderHallUtil.IsCovenantUnlocked},


        --No DF or TWW landing page due to taint
        --{type = "Divider"},

        --{type = "Button", name = DRAGONFLIGHT_LANDING_PAGE_TITLE, OnClick = function() ELPOverride.OpenExpansionLandingPage(LE_EXPANSION_DRAGONFLIGHT) end},
        --{type = "Button", name = WAR_WITHIN_LANDING_PAGE_TITLE, OnClick = function() ELPOverride.OpenExpansionLandingPage(LE_EXPANSION_WAR_WITHIN) end},
    };

    for _, v in ipairs(OrderHallButtons) do
        if v.garrTypeID then
            v.OnClick = function()
                OrderHallUtil.OpenGarrisonReport(v.garrTypeID);
            end

            if not v.IsEnabledFunc then
                v.IsEnabledFunc = function()
                    return OrderHallUtil.IsAnyMission(v.garrTypeID)
                end
            end

            v.DynamicTooltipFunc = function()
                return OrderHallUtil.GetMissionTooltip(v.garrTypeID)
            end

            v.tooltip = v.name;
        end
    end

    local function InitMenuSchematic()
        if MenuSchematc then return end;

        MenuSchematc = {
            tag = "PlumberLandingButtonMenu",
            objects = {};
            onMenuClosedCallback = function()
                MiniButton.shownMenu = nil;
                MiniButton:UpdateVisibility(true);
            end,
        };

        if GetDBBool("LandingButton_SmartExpansion") then
            table.insert(MenuSchematc.objects, {type = "Button", name = L["Abbr NewExpansionLandingPage"],
                OnClick = function()
                    LandingPageUtil.ToggleUI();
                end,
            });

            table.insert(MenuSchematc.objects, {type = "Button", name = JOURNEYS_LABEL,
                OnClick = function()
                    OrderHallUtil.ToggleBlizzardJourneys();
                end,
            });

            table.insert(MenuSchematc.objects, {type = "Divider"});
        else
            --Add a button to open the other UI
            if Options.GetChoice_PrimaryUI() == 2 then
                table.insert(MenuSchematc.objects, {type = "Button", name = L["Abbr NewExpansionLandingPage"],
                    OnClick = function()
                        LandingPageUtil.ToggleUI();
                    end,
                });
            else
                table.insert(MenuSchematc.objects, {type = "Button", name = JOURNEYS_LABEL,
                    OnClick = function()
                        OrderHallUtil.ToggleBlizzardJourneys();
                    end,
                });
            end

            table.insert(MenuSchematc.objects, {type = "Divider"});
        end

        for k, v in ipairs(OrderHallButtons) do
            table.insert(MenuSchematc.objects, v);
        end

        table.insert(MenuSchematc.objects, {type = "Divider"});

        table.insert(MenuSchematc.objects, {type = "Button", name = L["LandingButton Customize"],
            OnClick = function()
                MiniButton:ToggleSettings();
            end,
        });
    end

    function OrderHallUtil.ToggleGarrisonUI()
        if not GetDBBool("LandingButton_SmartExpansion") then
            return
        end

        if GarrisonLandingPage and GarrisonLandingPage:IsShown() and not InCombatLockdown() then
            HideUIPanel(GarrisonLandingPage);
            return true
        end

        local uiMapID = API.GetPlayerContinent();
        if uiMapID then
            if uiMapID == 572 then  --Draenor Garrison
                OrderHallButtons[1].OnClick();
                return true
            elseif uiMapID == 619 then  --Broken Isles, Class Hall
                OrderHallButtons[2].OnClick();
                return true
            elseif uiMapID == 875 or uiMapID == 876 then    --BFA
                OrderHallButtons[3].OnClick();
                return true
            elseif uiMapID == 1550 then
                OrderHallButtons[4].OnClick();
                return true
            end
        end
    end

    function OrderHallUtil.GetCurrentBestUIName()
        if GetDBBool("LandingButton_SmartExpansion") then
            local uiMapID = API.GetPlayerContinent();
            if uiMapID then
                if uiMapID == 572 then
                    return OrderHallButtons[1].name
                elseif uiMapID == 619 then
                    return OrderHallButtons[1].name
                elseif uiMapID == 875 or uiMapID == 876 then
                    return OrderHallButtons[1].name
                elseif uiMapID == 1550 then
                    return OrderHallButtons[1].name
                end
            end
        end

        local selectedIndex = Options.GetChoice_PrimaryUI();
        if selectedIndex == 2 then
            return JOURNEYS_LABEL
        else
            return L["Abbr NewExpansionLandingPage"]
        end
    end

    function OrderHallUtil.EnableBlizzardButton(state)
        local button = ExpansionLandingPageMinimapButton;
        if not button then return end;

        if state and OrderHallUtil.blizzardButtonHidden then
            local GarrisonLandingPageEvents = {
                "GARRISON_SHOW_LANDING_PAGE",
                "GARRISON_HIDE_LANDING_PAGE",
                "GARRISON_BUILDING_ACTIVATABLE",
                "GARRISON_BUILDING_ACTIVATED",
                "GARRISON_ARCHITECT_OPENED",
                "GARRISON_MISSION_FINISHED",
                "GARRISON_MISSION_NPC_OPENED",
                "GARRISON_SHIPYARD_NPC_OPENED",
                "GARRISON_INVASION_AVAILABLE",
                "GARRISON_INVASION_UNAVAILABLE",
                "SHIPMENT_UPDATE",
                "PLAYER_ENTERING_WORLD",
            };
            OrderHallUtil.blizzardButtonHidden = false;
            API.RegisterFrameForEvents(button, GarrisonLandingPageEvents);
            local forceUpdateIcon = true;
            button:RefreshButton(forceUpdateIcon);
        elseif (not state) and not OrderHallUtil.blizzardButtonHidden then
            OrderHallUtil.blizzardButtonHidden = true;
            button:UnregisterAllEvents();
            button:Hide();
        end
    end

    function ButtonMixin:ShowContextMenu()
        GameTooltip:Hide();
        InitMenuSchematic();
        local contextData = {};
        local menu = addon.API.ShowBlizzardMenu(self, MenuSchematc, contextData);
        self.shownMenu = menu;
        menu:ClearAllPoints();
        menu:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 4);
    end

    function ButtonMixin:CloseContextMenu()
        if self.shownMenu then
            self.shownMenu:Hide();
            self.shownMenu = nil;
            return true
        end
    end


    function ButtonManager.OpenContextMenu(widget)
        InitMenuSchematic();
        local contextData = {};
        local menu = addon.API.ShowBlizzardMenu(widget, MenuSchematc, contextData);
        menu:ClearAllPoints();
        menu:SetPoint("TOPLEFT", widget, "BOTTOMRIGHT", 2, -2);
    end
end


do  --Button Settings/Customize
    Options.ButtonBaseSizes = {24, 36};

    function Options.GetChoice_PrimaryUI()
        local selectedIndex = addon.GetDBValue("LandingButton_PrimaryUI");
        if selectedIndex ~= 1 and selectedIndex ~= 2 then
            selectedIndex = 1;
        end
        return selectedIndex
    end

    local function GenericWidget_OnClick()
        addon.UpdateSettingsDialog();
        MiniButton:LoadSettings();
    end

    local MenuData_PrimaryUI = {
        tooltip = L["LandingButtonOption PrimaryUI Tooltip"],

        ShouldEnable = function()
            if GetDBBool("LandingButton_ShowButton") then
                return true
            end
        end,

        GetSelectedText = function()
            local selectedIndex = Options.GetChoice_PrimaryUI();
            if selectedIndex == 2 then
                return JOURNEYS_LABEL
            else
                return L["Abbr NewExpansionLandingPage"]
            end
        end,

        MenuInfoGetter = function()
            local tbl = {
                key = "LandingButtonPrimaryUI",
                blizzardTheme = true,
            };

            local widgets = {};
            tbl.widgets = widgets;

            local selectedIndex = Options.GetChoice_PrimaryUI();

            local labels = {
                L["Abbr NewExpansionLandingPage"],
                JOURNEYS_LABEL,
            };

            for index, text in ipairs(labels) do
                table.insert(widgets, {
                    type = "Radio",
                    text = text;
                    closeAfterClick = true,
                    onClickFunc = function()
                        addon.SetDBValue("LandingButton_PrimaryUI", index);
                        GenericWidget_OnClick();
                    end,
                    selected = index == selectedIndex,
                });
            end

            return tbl
        end,
    };

    local function Tooltip_SmartExpansion()
        local tooltipFormat = " \n|cffffffff%s|r\n\n%s";
        local uiName = MenuData_PrimaryUI.GetSelectedText();
        if PlumberDB.LandingButton_SmartExpansion then
            return string.format(tooltipFormat, L["LandingButtonOption SmartExpansion Tooltip 1"], L["LandingButtonOption SmartExpansion Tooltip 2"]:format(uiName))
        else
            return string.format(tooltipFormat, L["LandingButtonOption SmartExpansion Tooltip 2"]:format(uiName), L["LandingButtonOption SmartExpansion Tooltip 1"])
        end
    end

    local function ResetPosition_OnClick()
        PlumberDB.LandingButton_Pos_X = nil;
        PlumberDB.LandingButton_Pos_Y = nil;
        PlumberDB.LandingButton_AbsPos_X = nil;
        PlumberDB.LandingButton_AbsPos_Y = nil;
        MiniButton:LoadSettings();
        addon.UpdateSettingsDialog();
    end

    local function ResetPosition_ShouldEnable()
        if PlumberDB.LandingButton_Pos_X or PlumberDB.LandingButton_Pos_Y or PlumberDB.LandingButton_AbsPos_X or PlumberDB.LandingButton_AbsPos_Y then
            return true
        end

        return false
    end

    local function ShouldShowAppearanceSettings()
        if ButtonManager.isLibDBIconFound and not GetDBBool("LandingButton_Unaffected") then
            return not GetDBBool("LandingButton_UseLibDBIcon")
        else
            return true
        end
    end

    local OPTIONS_SCHEMATIC;

    local function Checkbox_UseLibIcon_OnClick()
        GenericWidget_OnClick();
        addon.SetupSettingsDialog(MiniButton, OPTIONS_SCHEMATIC, true)
    end

    local function Checkbox_UseLibIcon_ShouldShow()
        if GetDBBool("LandingButton_Unaffected") then
            return false
        else
            return ButtonManager.isLibDBIconFound
        end
    end

    OPTIONS_SCHEMATIC = {
        title = L["LandingButton Settings Title"],
        moduleDBKey = "NewExpansionLandingPage",
        widgets = {
            {type = "Checkbox", label = L["LandingButtonOption ShowButton"], onClickFunc = GenericWidget_OnClick, dbKey = "LandingButton_ShowButton"},

            {type = "Divider"},
            {newFeature = true, type = "Checkbox", label = L["LandingButtonOption Unaffected"], onClickFunc = Checkbox_UseLibIcon_OnClick, dbKey = "LandingButton_Unaffected", tooltip = L["LandingButtonOption Unaffected Tooltip"]},
            {newFeature = true, type = "Checkbox", label = L["LandingButtonOption UseLibDBIcon"], onClickFunc = Checkbox_UseLibIcon_OnClick, dbKey = "LandingButton_UseLibDBIcon", tooltip = L["LandingButtonOption UseLibDBIcon Tooltip"], validityCheckFunc = Checkbox_UseLibIcon_ShouldShow, parentDBKey = "LandingButton_ShowButton"};
            {type = "Divider"},

            {type = "Dropdown", label = L["LandingButtonOption PrimaryUI"], menuData = MenuData_PrimaryUI},
            {type = "Checkbox", label = L["LandingButtonOption SmartExpansion"], onClickFunc = GenericWidget_OnClick, dbKey = "LandingButton_SmartExpansion", tooltip = Tooltip_SmartExpansion, keepTooltipAfterClicks = true, parentDBKey = "LandingButton_ShowButton"},

            {type = "Divider", validityCheckFunc = ShouldShowAppearanceSettings},
            {type = "Checkbox", label = L["LandingButtonOption HideWhenIdle"], onClickFunc = GenericWidget_OnClick, dbKey = "LandingButton_HideWhenIdle", tooltip = L["LandingButtonOption HideWhenIdle Tooltip"], parentDBKey = "LandingButton_ShowButton", validityCheckFunc = ShouldShowAppearanceSettings},
            {type = "Checkbox", label = L["LandingButtonOption ReduceSize"], onClickFunc = GenericWidget_OnClick, dbKey = "LandingButton_ReduceSize", parentDBKey = "LandingButton_ShowButton", validityCheckFunc = ShouldShowAppearanceSettings},
            {type = "Checkbox", label = L["LandingButtonOption DarkColor"], onClickFunc = GenericWidget_OnClick, dbKey = "LandingButton_DarkColor", parentDBKey = "LandingButton_ShowButton", validityCheckFunc = ShouldShowAppearanceSettings},

            {type = "Divider", validityCheckFunc = ShouldShowAppearanceSettings},
            {type = "UIPanelButton", label = L["Reset To Default Position"], onClickFunc = ResetPosition_OnClick, stateCheckFunc = ResetPosition_ShouldEnable, widgetKey = "ResetButton", validityCheckFunc = ShouldShowAppearanceSettings},
        },
    };

    local function OnSettingsPanelClosed()
        Options.isSettingsShown = nil;
        ButtonManager:UpdateVisibility();
        CallbackRegistry:UnregisterCallback("SettingsPanel.ModuleOptionClosed", OnSettingsPanelClosed, MiniButton);
    end

    function ButtonMixin:ToggleSettings()
        local OptionFrame = addon.ToggleSettingsDialog(self, OPTIONS_SCHEMATIC, true);
        if OptionFrame then
            OptionFrame:ConvertAnchor();
            if OptionFrame:IsShown() then
                Options.isSettingsShown = true;
                CallbackRegistry:Register("SettingsPanel.ModuleOptionClosed", OnSettingsPanelClosed, MiniButton);
            else
                Options.isSettingsShown = nil;
            end
            ButtonManager:UpdateVisibility();
        end
    end

    function ButtonMixin:LoadSettings()
        MenuSchematc = nil;

        self.darkMode = GetDBBool("LandingButton_DarkColor");

        local size = GetDBBool("LandingButton_ReduceSize") and 26 or 36;

        if GetDBBool("LandingButton_Unaffected") then
            ButtonManager.SetSize(self, size, size);
            ButtonManager.SetParent(self, UIParentContainer);
        else
            self:SetSize(size, size);
            self:SetParent(Minimap);
        end

        C_Timer.After(0, function()
            self:UseDarkMode(self.darkMode);
            self:UpdatePosition();
        end);

        ButtonManager:UpdateVisibility();
    end


    LandingPageUtil.ToggleMinimapSettings = function()
        if MiniButton then
            MiniButton:ToggleSettings();
        end
    end

    LandingPageUtil.UpdateMinimapButtonVisibility = function()
        ButtonManager:UpdateVisibility();
    end


    local function MiniButton_Enable(state)
        MiniButton.VisualContainer:SetShown(state);
        MiniButton:EnableMouse(state);
        MiniButton:SetMouseMotionEnabled(state);
        MiniButton:SetMouseClickEnabled(state);
    end

    CallbackRegistry:Register("EditMode.Enter", function()
        MiniButton_Enable(false);
    end);

    CallbackRegistry:Register("EditMode.Exit", function()
        MiniButton_Enable(true);
    end);
end


do  --ButtonManager
    ButtonManager.dataObjectName = "PlumberLandingButton";
    ButtonManager.showPumberButton = true;

    function ButtonManager:ShouldShowPlumberButton()
        return self.showPumberButton
    end

    function ButtonManager:UpdateVisibility()
        if GetDBBool("LandingButton_ShowButton") and GetDBBool("NewExpansionLandingPage") then
            if self.isLibDBIconFound then
                if GetDBBool("LandingButton_UseLibDBIcon") and not GetDBBool("LandingButton_Unaffected") then
                    self:ShowLibIcon();
                else
                    self:HideLibDBIcon();
                end
            else
                self.showPumberButton = true;
            end
        else
            self:HideLibDBIcon();
            self.showPumberButton = false;
        end

        if MiniButton then
            MiniButton:UpdateVisibility();
        end
    end

    function ButtonManager.OnLeftClick(widget)
        if OrderHallUtil.ToggleGarrisonUI() then
            return
        end

        if Options.GetChoice_PrimaryUI() == 2 then
            OrderHallUtil.ToggleBlizzardJourneys();
        else
            LandingPageUtil.ToggleUI();
        end
    end

    function ButtonManager:InitLibIcon()
        if self.isLibDBIconFound ~= nil then return end;

        if LibStub then
            if C_AddOns.IsAddOnLoaded("HidingBar") then
                --Avoid showing 3 buttons by default (1 from ours, and 2 from libs)
                --Button visibility will be handled by this addon
                self.isLibDBIconFound = false;
                return
            end


            local silent = true;
            local LibDataBroker = LibStub("LibDataBroker-1.1", silent);
            local LibDBIcon = LibStub:GetLibrary("LibDBIcon-1.0", silent);

            if LibDataBroker then
                if (addon.GetDBValue("LandingButton_UseLibDBIcon") == nil) or (addon.GetDBValue("LandingButton_UseLibDBIcon_LibCheckFlag1") == nil) then
                    local mapAddOns = {"LeatrixPlus", "SexyMap", "BasicMinimap"};
                    for _, addonName in ipairs(mapAddOns) do
                        if C_AddOns.IsAddOnLoaded(addonName) then
                            addon.SetDBValue("LandingButton_UseLibDBIcon", true);
                            addon.SetDBValue("LandingButton_UseLibDBIcon_LibCheckFlag1", true);
                            break
                        end
                    end
                end

                local Plumber_LDB = LibDataBroker:NewDataObject(self.dataObjectName, {
                    type = "launcher",
                    text = L["Abbr NewExpansionLandingPage"],
                    icon = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/LandingButtonIcon-32",
                    OnClick = function(f, button)
                        if button == "RightButton" then
                            self.OpenContextMenu(f);
                            return
                        end
                        self.OnLeftClick(f);
                    end,
                });

                function Plumber_LDB:OnEnter()
                    ButtonMixin.ShowTooltip(self);
                end

                function Plumber_LDB:OnLeave()
                    GameTooltip:Hide();
                end

                if LibDBIcon then
                    self.isLibDBIconFound = true;

                    if not PlumberDB.LibDBIconDB then
                        PlumberDB.LibDBIconDB = {
                            showInCompartment = false,
                            minimapPos = 225,
                        };
                    end

                    LibDBIcon:Register(self.dataObjectName, Plumber_LDB, PlumberDB.LibDBIconDB);

                    self.SetLibButtonShown = function(state)
                        if state and not self.libButtonShown then
                            self.libButtonShown = true;
                            LibDBIcon:Show(self.dataObjectName);
                        elseif not state then
                            self.libButtonShown = false;
                            LibDBIcon:Hide(self.dataObjectName);
                        end
                    end
                end
            end
        end

        if not self.isLibDBIconFound then
            self.isLibDBIconFound = false;
        end
    end

    function ButtonManager:ShowLibIcon()
        if self.SetLibButtonShown then
            self.SetLibButtonShown(true);
            self.showPumberButton = false;
        end
    end

    function ButtonManager:HideLibDBIcon()
        if self.SetLibButtonShown then
            self.SetLibButtonShown(false);
            self.showPumberButton = true;
        end
    end
end


do  --Event Listener
    function EL:OnEvent(event, ...)
        if MiniButton then
            if event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
                MiniButton:UpdateResolution();
            elseif event == "PLAYER_ENTERING_WORLD" then
                self:UnregisterEvent(event);
                ButtonManager:InitLibIcon()
                MiniButton:LoadSettings();
            end
        end
    end
    EL:SetScript("OnEvent", EL.OnEvent);

    local StaticEvents = {
        "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED", "PLAYER_ENTERING_WORLD",
        "GARRISON_HIDE_LANDING_PAGE", "GARRISON_SHOW_LANDING_PAGE",
    };

    API.RegisterFrameForEvents(EL, StaticEvents);
end


do  --Debug
    local function ResetSettings()
        local defaults = {
            LandingButton_ShowButton = true,
            LandingButton_Unaffected = false,
            LandingButton_PrimaryUI = 1,
            LandingButton_SmartExpansion = false,
            LandingButton_ReduceSize = false,
            LandingButton_DarkColor = false,
            LandingButton_HideWhenIdle = false,
            LandingButton_UseLibDBIcon = "nil",
            LandingButton_UseLibDBIcon_LibCheckFlag1 = "nil",
            LandingButton_Pos_X = "nil",
            LandingButton_Pos_Y = "nil",
            LandingButton_AbsPos_X = "nil",
            LandingButton_AbsPos_Y = "nil",
        };

        for dbKey, value in pairs(defaults) do
            if value == "nil" then
                value = nil;
            end
            addon.SetDBValue(dbKey, value);
        end
    end
end
