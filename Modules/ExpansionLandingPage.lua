local _, addon = ...
local API = addon.API;
local L = addon.L;

local C_Reputation = C_Reputation;
local C_MajorFactions = C_MajorFactions;
local GetParagonValuesAndLevel = API.GetParagonValuesAndLevel;

local FACTION_FRAME_WIDTH = 60;

local MajorFactionListOverride = {};
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

    function FactionProgressMixin:SetIconByFileID(fileID)
        self.Icon:SetTexture(fileID)
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
            self.reputationType = 2;    --Friendship
        else
            isParagon = false;
            local info = API.GetReputationProgress(self.factionID);
            level, isFull, currentValue, maxValue = info.level, info.isFull, info.currentValue, info.maxValue;
            self.factionName = info.name;
            self.reputationType = info.reputationType;
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
        self.currentValue = currentValue;
        self.maxValue = maxValue;
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
            tooltip:SetOwner(self, "ANCHOR_RIGHT");
            if self.reputationType == 2 then
                ReputationEntryMixin.ShowFriendshipReputationTooltip(self, self.factionID, "ANCHOR_RIGHT", false);
            elseif self.reputationType == 1 then
                GameTooltip_SetTitle(tooltip, self.factionName);
                if C_Reputation.IsAccountWideReputation(self.factionID) then
                    local wrapText = false;
	                GameTooltip_AddColoredLine(tooltip, REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL, ACCOUNT_WIDE_FONT_COLOR, wrapText);
                end
                tooltip:AddLine(API.GetFactionStatusText(self.factionID, 1, 1, 1, true));
            else
                tooltip:Hide();
                return
            end
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

        API.Mixin(f, FactionProgressMixin);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnMouseDown", f.OnMouseDown);

        return f
    end
    addon.CreateFactionProgress = CreateFactionProgress;
end


local MajorFactionButtonMod = {};
MajorFactionButtonMod.Containers = {};
do
    local SubFactionData = {
        --[MajorFactionID] = {SubFactionID, iconType (1:CreatureDisplayID, 2:TextureFileID)}
        [2600] = {  --2600 The Severed Threads
            {2601, 1, 116208},     --Weaver
            {2605, 1, 114775},     --General Anub'azal
            {2607, 1, 114268},     --Vizier
        },

        [2653] = {  --2653 The Cartels of Undermine  --interface/icons/inv_1115_reputationcurrencies_
            {2669, 2, 6439629, criteria = function() return C_QuestLog.IsQuestFlaggedCompletedOnAccount(86961) end}, --Darkfuse Solutions unlocked after completed "Diversified Investments"
            {2673, 2, 6439627},     --Bilgewater Cartel 6383479
            {2677, 2, 6439630},     --Steamwheedle Cartel 6383482
            {2675, 2, 6439628},     --Blackwater Cartel 6383480
            {2671, 2, 6439631},     --Venture Co. 6383483
        },
    };

    function MajorFactionButtonMod:GetFactionButton(factionID)
        local LandingOverlay = ExpansionLandingPage.Overlay.WarWithinLandingOverlay;
        if not LandingOverlay then return end;

        local ScrollBox = LandingOverlay.MajorFactionList.ScrollBox;
        local dataProvider = ScrollBox:GetDataProvider();

        local dataIndex, foundElementData = dataProvider:FindByPredicate(function(elementData)
            return elementData.factionID == factionID;
        end)

        local view = ScrollBox:GetView();
        local frame = foundElementData and view:FindFrame(foundElementData);

        return frame
    end

    function MajorFactionButtonMod:ModifyFactionButtons()
        HiddenObjectUtil:Release();
        local frame, container;
        for factionID, subFactions in pairs(SubFactionData) do
            frame = self:GetFactionButton(factionID)
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

                container = self.Containers[factionID];
                if not container then
                    container = CreateFrame("Frame", nil, button);
                    self.Containers[factionID] = container;
                    container:SetSize(100, barSize);
                    container.widgets = {};

                    local scrollOverlay = ExpansionLandingPage.Overlay.WarWithinLandingOverlay.ScrollFadeOverlay;
                    container.scrollOverlay = scrollOverlay;
                end

                local n = 0;
                local subFactionID;
                local widget;

                for i, data in ipairs(subFactions) do
                    if (not data.criteria) or (data.criteria()) then
                        n = n + 1;
                        widget = container.widgets[n];
                        if not widget then
                            widget = CreateFactionProgress(container);
                            container.widgets[n] = widget;
                            widget:SetPoint("LEFT", container, "LEFT", (n - 1) * (barSize + barGap), 0);
                            widget:SetHitRectInsets(shrinkAll, shrinkAll, shrinkTop, 0);     --hopefully reduce our influence on the FactionButton
                        end
                        subFactionID = data[1];
                        if widget.factionID ~= subFactionID then
                            widget:SetFaction(subFactionID);
                            if data[2] == 1 then
                                widget:SetIconByCreatureDisplayID(data[3]);
                            else
                                widget:SetIconByFileID(data[3]);
                            end
                        else
                            widget:Update();
                        end
                        widget:Show();
                    end
                end

                container:SetSize(-barGap + rightPadding + (barSize + barGap) * n, barSize);
                container:EnableMouse(true);
                container:SetHitRectInsets(shrinkAll, 0, shrinkTop, 0);
                container:ClearAllPoints();
                container:SetParent(button);
                container:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -5);
                container.scrollOverlay:Hide();
                container:Show();

                if n > 4 then
                    container:SetScale(0.8);
                else
                    container:SetScale(1);
                end

                for i, widget in ipairs(container.widgets) do
                    if i > n then
                        widget:Hide();
                    end
                    if widget:IsMouseMotionFocus() then
                        widget:OnEnter();
                    end
                end
            else
                self:HideFactionWidgets(factionID);
            end
        end
    end

    function MajorFactionButtonMod:SetupSubFaction(majorFactionButton)
        local UnlockedState = majorFactionButton.UnlockedState;

        if majorFactionButton.plumberLastFactionID and self.Containers[majorFactionButton.plumberLastFactionID]:GetParent() == UnlockedState then
            self:HideFactionWidgets(majorFactionButton.plumberLastFactionID);
        end
        majorFactionButton.plumberLastFactionID = nil;

        local factionID = majorFactionButton.factionID;
        if not (factionID and SubFactionData[factionID]) then
            return
        end

        majorFactionButton.plumberLastFactionID = factionID;

        local subFactions = SubFactionData[factionID];
        local barSize = FACTION_FRAME_WIDTH;
        local barGap = 0;
        local rightPadding = 8;
        local shrinkTop = 8;
        local shrinkAll = 4;

        local container = self.Containers[factionID];
        if not container then
            container = CreateFrame("Frame", nil, UnlockedState);
            self.Containers[factionID] = container;
            container:SetSize(100, barSize);
            container.widgets = {};

            local scrollOverlay = ExpansionLandingPage.Overlay.WarWithinLandingOverlay.ScrollFadeOverlay;
            container.scrollOverlay = scrollOverlay;
        end

        local n = 0;
        local subFactionID;
        local widget;

        for i, data in ipairs(subFactions) do
            if (not data.criteria) or (data.criteria()) then
                n = n + 1;
                widget = container.widgets[n];
                if not widget then
                    widget = CreateFactionProgress(container);
                    container.widgets[n] = widget;
                    widget:SetPoint("LEFT", container, "LEFT", (n - 1) * (barSize + barGap), 0);
                    widget:SetHitRectInsets(shrinkAll, shrinkAll, shrinkTop, 0);     --hopefully reduce our influence on the FactionButton
                end
                subFactionID = data[1];
                if widget.factionID ~= subFactionID then
                    widget:SetFaction(subFactionID);
                    if data[2] == 1 then
                        widget:SetIconByCreatureDisplayID(data[3]);
                    else
                        widget:SetIconByFileID(data[3]);
                    end
                else
                    widget:Update();
                end
                widget:Show();
            end
        end

        container:SetSize(-barGap + rightPadding + (barSize + barGap) * n, barSize);
        container:EnableMouse(true);
        container:SetHitRectInsets(shrinkAll, 0, shrinkTop, 0);
        container:ClearAllPoints();
        container:SetParent(UnlockedState);
        container:SetPoint("BOTTOMRIGHT", UnlockedState, "BOTTOMRIGHT", 1, -5);
        container.scrollOverlay:Hide();
        container:Show();

        if n > 4 then
            container:SetScale(0.8);
        else
            container:SetScale(1);
        end

        for i, widget in ipairs(container.widgets) do
            if i > n then
                widget:Hide();
            end
            if widget:IsMouseMotionFocus() then
                widget:OnEnter();
            end
        end
    end

    function MajorFactionButtonMod:HideFactionWidgets(factionID)
        local container = self.Containers[factionID];
        if container then
            container:Hide();
            container:ClearAllPoints();
            container.scrollOverlay:Show();
        end
    end

    function MajorFactionButtonMod:HideAllWidgets()
        for factionID, container in pairs(self.Containers) do
            container:Hide();
            container:ClearAllPoints();
            container.scrollOverlay:Show();
        end
    end

    function MajorFactionButtonMod:OnOverlayChanged()
        if not self.factionEventListener then
            local LandingOverlay = ExpansionLandingPage and ExpansionLandingPage.Overlay and ExpansionLandingPage.Overlay.WarWithinLandingOverlay;
            if LandingOverlay then
                --LandingOverlay may not be loaded in some cases
                --e.g. Player logged in pre-TWW area

                local factionEventListener = CreateFrame("Frame", nil, LandingOverlay);
                self.factionEventListener = factionEventListener;

                factionEventListener:SetScript("OnShow", function()
                    if not self.needChecked then
                        self.needChecked = true;
                        if MajorFactionListOverride:IsModificationNeeded() then
                            self.listNeedModified = true;
                        end
                    end

                    if self.listNeedModified and (not self.refreshModified) and LandingOverlay.MajorFactionList then
                        self.refreshModified = true;

                        MajorFactionListOverride.OnLoad(LandingOverlay.MajorFactionList.ScrollBox);

                        LandingOverlay.MajorFactionList.Refresh = MajorFactionListOverride.RefreshList;
                        LandingOverlay.MajorFactionList:Refresh();
                    end
                end);
            end
        end

        if self.factionEventListener then
            self:WatchOverlayChanged(false);
        end
    end

    function MajorFactionButtonMod:WatchOverlayChanged(state)
        if state and not self.factionEventListener then
            EventRegistry:RegisterCallback("ExpansionLandingPage.OverlayChanged", self.OnOverlayChanged, self);
        else
            EventRegistry:UnregisterCallback("ExpansionLandingPage.OverlayChanged", self);
        end
    end

    function MajorFactionButtonMod.EnableModule(state)
        --ExpansionLandingPage is not loaded when this file is loaded

        local self = MajorFactionButtonMod;
        self:WatchOverlayChanged(state);

        if state then
            self:OnOverlayChanged();
            if self.factionEventListener then
                self.factionEventListener:Show();
            end
        else
            if self.factionEventListener then
                self.factionEventListener:Hide();
            end
            self:HideAllWidgets();
        end
    end
end


do  --Custom List Insert
    --expansionFilter = LE_EXPANSION_WAR_WITHIN
    local ForceShownFactions = {
        --[majorFactionID] = true
        [2685] = true,
    };

    local FactionDataOverride = {
        [2685] = {
            uiPriority = 15.5,      --Gallagio Loyalty Rewards Club (15 is Cartels of Undermine)
        },
        [2688] = {
            uiPriority = 16.5,      --Flame's Radiance (0 by default, intentional?)
        },
    };

    local FactionAtlasOverride = {
        [2685] = "thewarwithin-landingpage-renownbutton-rocket",
    };



    local UnlockedStateMixinOverride = {};
    function UnlockedStateMixinOverride:OnClick(button)
        if API.CheckAndDisplayErrorIfInCombat() then
            return
        end
        MajorFactionButtonUnlockedStateMixin.OnClick(self, button);
    end

    function UnlockedStateMixinOverride:RefreshUnlockState(majorFactionData)
        --Override ProgressBar to display Paragon

        self.Title:SetText(majorFactionData.name or "");
        self.Title:SetPoint("BOTTOMLEFT", self.RenownProgressBar, "RIGHT", 8, 0);

        local factionID = majorFactionData.factionID;
        C_Reputation.RequestFactionParagonPreloadRewardData(factionID);


        local isCapped = C_MajorFactions.HasMaximumRenown(factionID);
        local isParagon = C_Reputation.IsFactionParagon(factionID);
        local currentValue = isCapped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0;
        local maxValue = majorFactionData.renownLevelThreshold;
        local hasRewardPending;

        if isParagon then
            local totalEarned, threshold, rewardQuestID;
            totalEarned, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID);
            if totalEarned and threshold and threshold ~= 0 then
                local paragonLevel = math.floor(totalEarned / threshold);
                currentValue = totalEarned - paragonLevel * threshold;
                maxValue = threshold;
            end

            if hasRewardPending then
                currentValue = maxValue;
                self.RenownLevel:SetText(L["Reward Available"]);
            else
                self.RenownLevel:SetText(L["Paragon Reputation"]);
            end
        else
            self.RenownLevel:SetText(MAJOR_FACTION_BUTTON_RENOWN_LEVEL:format(majorFactionData.renownLevel or 0));
        end

        if hasRewardPending then
            self.RenownLevel:SetTextColor(0.098, 1.000, 0.098);
        else
            self.RenownLevel:SetTextColor(1, 0.82, 0);
        end

        self.RenownProgressBar:UpdateBar(currentValue, maxValue);
        self.RenownProgressBar:Show();

        MajorFactionButtonMod:SetupSubFaction(self:GetParent());
    end


    function MajorFactionListOverride:IsModificationNeeded()
        for majorFactionID in pairs(ForceShownFactions) do
            if C_MajorFactions.IsMajorFactionHiddenFromExpansionPage(majorFactionID) then
                return true
            end
        end
        return false
    end

    function MajorFactionListOverride:RefreshList()
        local factionList = {};

        local majorFactionIDs = C_MajorFactions.GetMajorFactionIDs(self.expansionFilter);
        for index, majorFactionID in ipairs(majorFactionIDs) do
            if (not C_MajorFactions.IsMajorFactionHiddenFromExpansionPage(majorFactionID)) or ForceShownFactions[majorFactionID] then
                local majorFactionData = C_MajorFactions.GetMajorFactionData(majorFactionID);
                table.insert(factionList, majorFactionData);
                if FactionDataOverride[majorFactionID] then
                    for k, v in pairs(FactionDataOverride[majorFactionID]) do
                        majorFactionData[k] = v;
                    end
                end
            end
        end

        local function MajorFactionSort(faction1, faction2)
            if faction1.uiPriority ~= faction2.uiPriority then
                return faction1.uiPriority > faction2.uiPriority;
            end

            return strcmputf8i(faction1.name, faction2.name) < 0;
        end
        table.sort(factionList, MajorFactionSort);

        MajorFactionButtonMod:HideAllWidgets();

        local dataProvider = CreateDataProvider(factionList);
        self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
        self.ScrollBar:SetShown(self.ScrollBox:HasScrollableExtent());
    end

    function MajorFactionListOverride:OnLoad()
        local view = self:GetView();
        view:SetElementInitializer("MajorFactionButtonTemplate", function(button, majorFactionData)
            button.UnlockedState:SetScript("OnClick", UnlockedStateMixinOverride.OnClick);
            button.UnlockedState.Refresh = UnlockedStateMixinOverride.RefreshUnlockState;
            button:Init(majorFactionData);

            local factionID = button.factionID;
            if button.isUnlocked then
                button.UnlockedState:SetSelected(factionID == self.selectedFactionID);
            end

            if factionID and FactionAtlasOverride[factionID] then
                button.UnlockedState.Background:SetAtlas(FactionAtlasOverride[factionID]);
            end
        end);
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