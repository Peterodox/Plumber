local _, addon = ...
local API = addon.API;
local L = addon.L;

local C_Reputation = C_Reputation;
local GetParagonValuesAndLevel = API.GetParagonValuesAndLevel;

local FACTION_FRAME_WIDTH = 60;

local HiddenObjectUtil = {};
do
    local ipairs = ipairs;

    function HiddenObjectUtil:Init()
        if self.frame then return end;

        self.objects = {};
        self.n = 0;
        self.frame = CreateFrame("Frame");
    end

    function HiddenObjectUtil:Release()
        if self.frame then
            self.frame:SetScript("OnUpdate", nil);
        end

        if self.n and self.n > 0 then
            for _, object in ipairs(self.objects) do
                object:Show();
                object:SetAlpha(1);
            end
            self.n = 0;
        end
    end

    function HiddenObjectUtil:AddObject(object)
        if not self.frame then
            self:Init();
        end

        self.n = self.n + 1;
        self.objects[self.n] = object;
    end

    local function FadeOut_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        if self.t < 0 then
            return
        end

        self.alpha = self.alpha - 4*elapsed;
        if self.alpha <= 0 then
            self.alpha = 0;
            self.t = 0;
            self:SetScript("OnUpdate", nil);
        end

        HiddenObjectUtil:SetObjectsAlpha(self.alpha);
    end
    
    function HiddenObjectUtil:SetObjectsAlpha(alpha)
        for _, object in ipairs(self.objects) do
            object:SetAlpha(alpha);
        end
    end

    function HiddenObjectUtil:FadeOutObjects(delay)
        delay = delay or 0;
        self.frame.t = -delay;
        self.frame.alpha = 1;
        self.frame:SetScript("OnUpdate", FadeOut_OnUpdate);
    end
end


local function IsFactionWatched(factionID)
    local factionData = C_Reputation.GetFactionDataByID(factionID);
    return factionData and factionData.isWatched
end


local CreateFactionProgress;
do
    local FactionProgressMixin = {};

    function FactionProgressMixin:SetIconByCreatureDisplayID(creatureDisplayID)
        SetPortraitTextureFromCreatureDisplayID(self.Icon, creatureDisplayID);
    end

    function FactionProgressMixin:SetFaction(factionID)
        self.factionID = factionID;
        self:Update();
    end

    function FactionProgressMixin:Update()
        local isParagon;
        local level, isFull, currentValue, maxValue;

        if C_Reputation.IsFactionParagon(self.factionID) then
            isParagon = true;
            local paragonTimes;
            currentValue, maxValue, paragonTimes = GetParagonValuesAndLevel(self.factionID);
        else
            isParagon = false;
            level, isFull, currentValue, maxValue = API.GetFriendshipProgress(self.factionID);
        end

        self.isParagon = isParagon;

        if isParagon then
            self.ProgressBar:ShowNumber(false);
        else
            self.ProgressBar:ShowNumber(true);
            if isFull then
                self.ProgressBar.ValueText:SetText("");
            else
                self.ProgressBar.ValueText:SetText(level);
            end
        end


        self.ProgressBar:SetValue(currentValue, maxValue);
    end

    function FactionProgressMixin:ShowParagonTooltip()
        local tooltip = EmbeddedItemTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        ReputationParagonFrame_SetupParagonTooltip(self);
        tooltip:Show();

        C_Timer.After(0.25, function()
            if self:IsMouseMotionFocus() then
                tooltip:Hide();
                self:ShowParagonTooltip();
            end
        end);
    end

    function FactionProgressMixin:OnEnter()
        self.ProgressBar.BorderHighlight:Show();

        GameTooltip:Hide();
        EmbeddedItemTooltip:Hide();

        self.UpdateTooltip = nil;
        if self.isParagon then
            self:ShowParagonTooltip();
        else
            local tooltip = GameTooltip;
            ReputationEntryMixin.ShowFriendshipReputationTooltip(self, self.factionID, "ANCHOR_RIGHT", false);
            tooltip:AddLine(" ");
            GameTooltip_AddColoredLine(tooltip, (IsFactionWatched(self.factionID) and L["Instruction Untrack Reputation"]) or L["Instruction Track Reputation"], GREEN_FONT_COLOR);
            tooltip:Show();
        end
    end

    function FactionProgressMixin:OnLeave()
        self.ProgressBar.BorderHighlight:Hide();
        GameTooltip:Hide();
        EmbeddedItemTooltip:Hide();
    end

    function FactionProgressMixin:OnMouseDown(button)
        if button == "LeftButton" and IsShiftKeyDown() then
            local watchedFactionID = (IsFactionWatched(self.factionID) and 0) or self.factionID;
            C_Reputation.SetWatchedFactionByID(watchedFactionID);       --Trigger UPDATE_FACTION
            GameTooltip:Hide();
        end
    end

    function CreateFactionProgress(parent)
        local f = CreateFrame("Frame", nil, parent);
        f:SetSize(FACTION_FRAME_WIDTH, FACTION_FRAME_WIDTH);

        local ProgressBar = addon.CreateRadialProgressBar(f);
        ProgressBar:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.ProgressBar = ProgressBar;

        local Icon = f:CreateTexture(nil, "BACKGROUND");
        Icon:SetPoint("CENTER", f, "CENTER", 0, 0);
        Icon:SetSize(38, 38);
        f.Icon = Icon;

        Mixin(f, FactionProgressMixin);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnMouseDown", f.OnMouseDown);

        return f
    end
end


local MajorFactionButtonMod = {};
do
    local SPIDER_DATA = {
        --factionID, creatureDisplayID
        {2601, 116208},     --Weaver
        {2605, 114775},     --General Anub'azal
        {2607, 114268},     --Vizier
    };

    function MajorFactionButtonMod:GetFactionButton(factionID)
        local parent = ExpansionLandingPage.Overlay.WarWithinLandingOverlay;
        if not parent then return end;

        local ScrollBox = parent.MajorFactionList.ScrollBox;
        local dataProvider = ScrollBox:GetDataProvider();

        local dataIndex, foundElementData = dataProvider:FindByPredicate(function(elementData)
            return elementData.factionID == factionID;   --The Severed Threads
        end)

        local view = ScrollBox:GetView();
        local frame = foundElementData and view:FindFrame(foundElementData);

        return frame
    end

    function MajorFactionButtonMod:ModifyFactionButton_Web()
        HiddenObjectUtil:Release();

        local frame = self:GetFactionButton(2600);      --The Severed Threads
        local container = self.WidgetContainer_Web;

        if frame then
            local button = frame.UnlockedState;

            --HiddenObjectUtil:AddObject(button.Title);
            --HiddenObjectUtil:AddObject(button.RenownLevel);
            --HiddenObjectUtil:FadeOutObjects(1);

            local barSize = FACTION_FRAME_WIDTH;
            local barGap = 0;
            local rightPadding = 8;
            local shrinkTop = 8;
            local shrinkAll = 4;

            if not container then
                container = CreateFrame("Frame", nil, button);
                self.WidgetContainer_Web = container;
                container:SetSize(100, barSize);
                self.widgets_Web = {};

                for i, data in ipairs(SPIDER_DATA) do
                    local f = CreateFactionProgress(container);
                    self.widgets_Web[i] = f;
                    f:SetFaction(data[1]);
                    f:SetIconByCreatureDisplayID(data[2]);
                    f:SetPoint("LEFT", container, "LEFT", (i - 1) * (barSize + barGap), 0);
                    f:SetHitRectInsets(shrinkAll, shrinkAll, shrinkTop, 0);     --hopefully reduce our influence on the FactionButton
                end

                container:SetSize(-barGap + rightPadding + (barSize + barGap) * #SPIDER_DATA, barSize);
                container:EnableMouse(true);
                container:SetHitRectInsets(shrinkAll, 0, shrinkTop, 0);

                local scrollOverlay = ExpansionLandingPage.Overlay.WarWithinLandingOverlay.ScrollFadeOverlay;
                container.scrollOverlay = scrollOverlay;
            else
                for i, widget in ipairs(self.widgets_Web) do
                    widget:Update();
                    if widget:IsMouseMotionFocus() then
                        widget:OnEnter();
                    end
                end
            end

            container:ClearAllPoints();
            container:SetParent(button);
            container:SetPoint("RIGHT", button, "RIGHT", 0, -32);
            container.scrollOverlay:Hide();
            container:Show();
        else
            self:HideWidgets();
        end
    end

    function MajorFactionButtonMod:HideWidgets()
        local container = self.WidgetContainer_Web;
        if container then
            container:Hide();
            container:ClearAllPoints();
            container.scrollOverlay:Show();
        end
    end

    function MajorFactionButtonMod.EnableModule(state)
        --ExpansionLandingPage is not loaded when this file is loaded

        local self = MajorFactionButtonMod;
        local container = self.WidgetContainer_Web;

        if state then
            if not self.factionEventListener then
                local factionEventListener = CreateFrame("Frame", nil, ExpansionLandingPage.Overlay.WarWithinLandingOverlay);
                self.factionEventListener = factionEventListener;

                factionEventListener:SetScript("OnShow", function()
                    factionEventListener:RegisterEvent("UPDATE_FACTION");
                    factionEventListener:RegisterEvent("MAJOR_FACTION_UNLOCKED");
                    MajorFactionButtonMod:ModifyFactionButton_Web()
                end);

                factionEventListener:SetScript("OnHide", function()
                    factionEventListener:UnregisterEvent("UPDATE_FACTION");
                    factionEventListener:UnregisterEvent("MAJOR_FACTION_UNLOCKED");
                end);

                factionEventListener:SetScript("OnEvent", function(_, event, ...)
                    if not self.pauseUpdate then
                        self.pauseUpdate = true;
                        C_Timer.After(0.05, function()
                            self.pauseUpdate = nil;
                            MajorFactionButtonMod:ModifyFactionButton_Web()
                        end);
                    end
                end);
            end
            self.factionEventListener:Show();
        else
            if self.factionEventListener then
                self.factionEventListener:Hide();
            end

            if container then
                self:HideWidgets();
            end
        end
    end
end




do
    local moduleData = {
        name = addon.L["ModuleName ExpansionLandingPage"],
        dbKey = "ExpansionLandingPage",
        description = addon.L["ModuleDescription ExpansionLandingPage"],
        toggleFunc = MajorFactionButtonMod.EnableModule,
        categoryID = 1,
        uiOrder = 1100,
        moduleAddedTime = 1720340000,
    };

    addon.ControlCenter:AddModule(moduleData);
end