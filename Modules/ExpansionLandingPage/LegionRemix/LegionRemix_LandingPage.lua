local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;
local LandingPageUtil = addon.LandingPageUtil;
local TooltipUpdator = LandingPageUtil.TooltipUpdator;
local GetQuestProgressInfo = API.GetQuestProgressInfo;


local ActivityTab;


local IR_WIDGET_ID = 1737;  --Research tasks taken
local QUESTLINE_ID = 5902;  --Infinite Research


--[[
    lfgDungeonID: https://wago.tools/db2/LFGDungeons
    2844,   --Darkbough
    2845,   --Tormented Guardians
    2846,   --Rift of Aln
    2851,   --Trial of Valor
--]]


local QuestInfoExtra = {
    --Artifact Ability related, show a button for quick switch
    [90115] = {artifactTrackIndex = 1},
    [92439] = {artifactTrackIndex = 2},
    [92441] = {artifactTrackIndex = 3},
    [92440] = {artifactTrackIndex = 4},
    [92442] = {artifactTrackIndex = 5},

    [89644] = {lfgDungeonID = 2844},   --Darkbough, Il'gynoth
    [89665] = {lfgDungeonID = 2845},   --Tormented Guardians, Cenarius
};

local SpecialAssignments = {
    --Not part of the meta quest line. One-off?
    93112, 93113, 93114, 93116, 93117, 93118, 93120,
};

local IgnoredQuests = {
    --There are a few intro quests in the Infinite Research quest line
    [89476] = true,
    [91847] = true,
    [91848] = true,
    [91849] = true,
    [91437] = true,
    [92563] = true,
    [91612] = true,
    [92430] = true,
};


do  --LeftFrame: NextTraitFrame
    local NextTraitFrameMixin = {};

    function NextTraitFrameMixin:Refresh()
        if not self.infoGetter then return end;

        local nextUpgradeInfo = self.infoGetter();
        if not nextUpgradeInfo then return end;

        local currentValue = nextUpgradeInfo.current;
        local maxValue = nextUpgradeInfo.threshold;

        self.ProgressDisplay.ProgressBar:SetValue(currentValue, maxValue);

        if nextUpgradeInfo.nextSpellID then
            local texture = C_Spell.GetSpellTexture(nextUpgradeInfo.nextSpellID);
            self.SpellIcon:SetTexture(texture);
        end


        self.Title:ClearAllPoints();
        self.RankText:ClearAllPoints();
        self.UnlockText:ClearAllPoints();

        if nextUpgradeInfo.nextRank then
            --From top to bottom: X to unlock, Rank 1, Artifact Trait
            self.Title:SetText(nextUpgradeInfo.traitName);
            self.RankText:SetText(L["Rank Format"]:format(nextUpgradeInfo.nextRank));
            self.UnlockText:SetText(nextUpgradeInfo.line1);
            if nextUpgradeInfo.isLocked then    --Requires Lv.80

            end
            self.UnlockText:SetPoint("TOP", self.ProgressDisplay, "BOTTOM", 0, -24);
            --self.RankText:SetPoint("TOP", self.UnlockText, "BOTTOM", 0, -6);
            --self.Title:SetPoint("TOP", self.RankText, "BOTTOM", 0, -6);
            self.Title:SetPoint("TOP", self.UnlockText, "BOTTOM", 0, -6);
            self.Title:SetText(nextUpgradeInfo.line2);
        else
            self.Title:SetText(L["Fully Upgraded"]);
            self.RankText:SetText("");
            self.UnlockText:SetText("");
            self.Title:SetPoint("TOP", self.ProgressDisplay, "BOTTOM", 0, -24);
        end
    end

    function NextTraitFrameMixin:OnShow()
        self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
    end

    function NextTraitFrameMixin:OnHide()
        self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
    end

    function NextTraitFrameMixin:OnEvent(event, ...)
        if event == "CURRENCY_DISPLAY_UPDATE" then
            local currencyID = ...
            if currencyID == 3268 then
                self:RequestUpdate();
            end
        end
    end

    function NextTraitFrameMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.5 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            self:Refresh();
        end
    end

    function NextTraitFrameMixin:RequestUpdate()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    local function CreateNextTraitFrame(parent)
        local f = CreateFrame("Frame", nil, parent);
        API.Mixin(f, NextTraitFrameMixin);
        f:SetScript("OnShow", f.OnShow);
        f:SetScript("OnHide", f.OnHide);
        f:SetScript("OnEvent", f.OnEvent);


        local paddingV = 24;

        local ProgressDisplay = LandingPageUtil.CreateFactionButton(f); --See FactionTab.lua and PlumberLandingPageMajorFactionButtonTemplate
        f.ProgressDisplay = ProgressDisplay;
        ProgressDisplay.alwaysHideRenownLevel = true;
        ProgressDisplay:SetShowRenownLevel(false);
        ProgressDisplay:SetPoint("TOP", f, "TOP", 0, -paddingV);
        ProgressDisplay:SetScale(1.25);
        ProgressDisplay.ProgressBar:SetSwipeColor(244/255, 186/255, 130/255);

        function ProgressDisplay:ShowTooltip()

        end

        function ProgressDisplay.onClickFunc(button)
            if addon.RemixAPI then
                addon.RemixAPI.ToggleArtifactUI();
            end
        end

        --SpellIcon
        local SpellIcon = ProgressDisplay:CreateTexture(nil, "OVERLAY");
        f.SpellIcon = SpellIcon;
        SpellIcon:SetSize(42, 42);
        SpellIcon:SetPoint("CENTER", ProgressDisplay, "CENTER", 0, 0);
        SpellIcon:SetTexCoord(4/64, 60/64, 4/64, 60/64);
        SpellIcon:SetTexture(1413862);

        local IconMask = f:CreateMaskTexture(nil, "OVERLAY");
        IconMask:SetPoint("TOPLEFT", SpellIcon, "TOPLEFT", 0, 0);
        IconMask:SetPoint("BOTTOMRIGHT", SpellIcon, "BOTTOMRIGHT", 0, 0);
        IconMask:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Circle", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        SpellIcon:AddMaskTexture(IconMask);

        local IconOverlay = ProgressDisplay:CreateTexture(nil, "OVERLAY", nil, 2);
        IconOverlay:SetSize(64, 64);
        IconOverlay:SetPoint("CENTER", SpellIcon, "CENTER", 0, 0);
        IconOverlay:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/ExpansionLandingPage");
        IconOverlay:SetTexCoord(544/1024, 672/1024, 256/1024, 384/1024);


        local BackgroundGlow = f:CreateTexture(nil, "BACKGROUND");
        BackgroundGlow:SetSize(256, 256);
        BackgroundGlow:SetPoint("CENTER", ProgressDisplay, "CENTER", 0, 0);
        BackgroundGlow:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/ExpansionLandingPage-BackgroundGlow");
        BackgroundGlow:SetBlendMode("ADD");
        local shrink = 48;
        BackgroundGlow:SetTexCoord(shrink/256, 1-shrink/256, shrink/256, 1-shrink/256);
        BackgroundGlow:SetVertexColor(51/255, 29/255, 17/255);


        local textWidth = 224;
        local firstTextToProgressBar = 24;

        local fs, r, g, b;
        local fontStrings = {};

        for i = 1, 3 do
            fs = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            fontStrings[i] = fs;
            fs:SetWidth(textWidth);
            fs:SetJustifyH("CENTER");
            fs:SetJustifyV("TOP");
            if i == 1 then
                local fontFile = GameFontNormal:GetFont();
                local fontHeight = 14;
                local flags = "";
                fs:SetFont(fontFile, fontHeight, flags);

                fs:SetMaxLines(1);
                if AutoScalingFontStringMixin then
                    API.Mixin(fs, AutoScalingFontStringMixin);
                end
                r, g, b = 0.906, 0.737, 0.576;
            else
                if i == 2 then
                    r, g, b = 0.8, 0.8, 0.8;
                else
                    r, g, b = 0.5, 0.5, 0.5;
                end
            end
            fs:SetTextColor(r, g, b);
        end

        f.Title = fontStrings[1];
        f.RankText = fontStrings[2];
        f.UnlockText = fontStrings[3];

        local frameHeight = paddingV + 1.25 * ProgressDisplay:GetHeight() + firstTextToProgressBar + 14 + 6 + 12 + paddingV + 8;
        f:SetSize(256, frameHeight);

        f.infoGetter = addon.RemixAPI and addon.RemixAPI.GetNextTraitForUpgrade or nil;

        return f, frameHeight
    end
    LandingPageUtil.LegionRemixCreateNextTraitFrame = CreateNextTraitFrame;
end



local RightButtonMixin = {};
do  --A button on the right of the ListButton. Perform actions like like changing artifact ability or queue LFR
    function RightButtonMixin:OnEnter()
        self:GetParent():HideTooltip();
        self:ShowTooltip();
    end

    function RightButtonMixin:OnLeave()
        GameTooltip:Hide();
        if self:IsVisible() and self:GetParent():IsMouseMotionFocus() then
            self:GetParent():OnEnter();
        end
    end

    function RightButtonMixin:ShowTooltip()
        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        tooltip:SetText("Click to queue Darkbough", 1, 0.82, 0, 1, true);
        tooltip:Show();
    end

    function RightButtonMixin:OnMouseDown()
        PlumberExpansionLandingPage:Lower();
    end

    function RightButtonMixin:OnClick()
        if self.onClickFunc then
            self.onClickFunc();
        end
    end
end


local CreateQuestListButton;
do  --List Button
    local QuestIcons = {
        InProgress = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png",
    };

    local ListButtonMixin = {};

    function ListButtonMixin:OnEnter()
        self:UpdateVisual();

        if not self.RightButton:IsMouseMotionFocus() then
            self:ShowTooltip();
        end
    end

    function ListButtonMixin:OnLeave()
        self:UpdateVisual();
        self:HideTooltip();
    end

    function ListButtonMixin:SetDefaultTextColor()
        self.Name:SetTextColor(0.6, 0.6, 0.6);
    end

    function ListButtonMixin:OnRemoved()
        self.Icon:SetSize(18, 18);
        self.Icon:SetTexture(nil);
        self.Icon:SetPoint("CENTER", self, "LEFT", 16, 0);
        self.Icon:SetTexCoord(0, 1, 0, 1);
        self.completed = nil;
        self.readyForTurnIn = nil;
        self.artifactTrackIndex = nil;
        self.RightButton:Hide();
    end

    function ListButtonMixin:SetQuestHeader(questID)
        self:SetWidth(606);
        self.questID = questID;
        local questName = API.GetQuestName(questID);
        if questName then
            local abbrName = string.gsub(questName, ".+[:：]%s*", "");
            if abbrName and abbrName ~= "" then
                questName = abbrName;
            end
        else
            --Objectives are likely unloaded too, so we update everything
            ActivityTab:RequestUpdate();
        end
        self.SetDefaultTextColor = nil;
        self.Name:SetText(questName);
        self.Icon:Show();
        self:Layout();
        self:UpdateVisual();

        if self.completed then
            self.Icon:SetAtlas("checkmark-minimal-disabled");
        elseif self.readyForTurnIn then
            self.Icon:SetAtlas("QuestTurnin");
        else
            self.Icon:SetTexture(QuestIcons.InProgress);
        end

        local rightButtonType;
        local extraInfo = QuestInfoExtra[questID];
        if extraInfo then
            self.artifactTrackIndex = extraInfo.artifactTrackIndex;
            if extraInfo.artifactTrackIndex then
                if not (self.completed or self.readyForTurnIn) then
                    rightButtonType = 1;
                end
            elseif extraInfo.lfgDungeonID then
                rightButtonType = 2;
            elseif extraInfo.premadeGroup then
                rightButtonType = 3;
            end
        end

        self.RightButton.onClickFunc = nil;
        if rightButtonType then
            self.RightButton:Show();
            if rightButtonType == 1 then
                self.RightButton.Text:SetText("Switch");
            elseif rightButtonType == 2 then
                self.RightButton.Text:SetText("Queue");
                local lfgDungeonID = QuestInfoExtra[questID].lfgDungeonID;
                self.RightButton.onClickFunc = function()
                    --[[
                    if not RaidFinderFrame:IsVisible() then
                        PVEFrame_ShowFrame("GroupFinderFrame", RaidFinderFrame);
                    end
                    RaidFinderQueueFrame_SetRaid(lfgDungeonID);
                    PlumberExpansionLandingPage:Lower();
                    --]]

                    if API.CanPlayerQueueLFG() then
                        JoinSingleLFG(LE_LFG_CATEGORY_RF or 3, lfgDungeonID); --Direct approach
                    end
                end
                --RaidFinderQueueFrame_SetRaid
            elseif rightButtonType == 3 then
                self.RightButton.Text:SetText("Group Finder");
            end
        else
            self.RightButton:Hide();
        end
    end

    function ListButtonMixin:SetObjective(objectiveText)
        self.questID = nil;
        self:SetWidth(606 - 44);  --60
        self.Icon:Hide();
        self.SetDefaultTextColor = ListButtonMixin.SetDefaultTextColor;
        if objectiveText then
            objectiveText = "- "..objectiveText;
        end
        self.Name:SetText(objectiveText);
        self:Layout();
        self:UpdateVisual();
    end

    function ListButtonMixin:ShowTooltip()
        TooltipUpdator:SetFocusedObject(self);
        TooltipUpdator:SetHeaderText(self.Name:GetText());
        TooltipUpdator:SetQuestID(self.questID);
        TooltipUpdator:RequestQuestProgress();
        TooltipUpdator:RequestQuestDescription();
        if not self.completed then
            TooltipUpdator:RequestQuestReward();
        end
    end

    function ListButtonMixin:HideTooltip()
        TooltipUpdator:StopUpdating();
        GameTooltip:Hide();
    end


    function CreateQuestListButton(parent)
        local f = LandingPageUtil.CreateSharedListButton(parent);

        API.Mixin(f, ListButtonMixin);
        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);


        local RightButton = CreateFrame("Button", nil, f);
        RightButton:Hide();
        f.RightButton = RightButton;
        API.Mixin(RightButton, RightButtonMixin);
        RightButton:SetSize(64, 25);
        RightButton:SetPoint("RIGHT", f, "RIGHT", 0, 0);

        RightButton.Text = RightButton:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        RightButton.Text:SetPoint("CENTER", RightButton, "CENTER", 0, 0);
        RightButton.Text:SetText("Switch");
        RightButton.Text:SetTextColor(1, 0.82, 0);

        RightButton:SetScript("OnEnter", RightButton.OnEnter);
        RightButton:SetScript("OnLeave", RightButton.OnLeave);
        RightButton:SetScript("OnClick", RightButton.OnClick);
        RightButton:SetScript("OnMouseDown", RightButton.OnMouseDown);

        RightButton:SetPropagateMouseMotion(true);

        return f
    end
end


local ActivityTabMixin = {};    --Track Infinite Research
do
    local QuestIDList = {};     --Populated by C_QuestLine.GetQuestLineQuests

    local DynamicEvents = {
        "QUEST_LOG_UPDATE",
        "QUEST_REMOVED",
        "QUEST_ACCEPTED",
        "QUEST_TURNED_IN",
    };

    function ActivityTabMixin:OnShow()
        self:FullUpdate();
        API.RegisterFrameForEvents(self, DynamicEvents);
        self:SetScript("OnEvent", self.OnEvent);
    end

    function ActivityTabMixin:OnHide()
        self.t = nil;
        self:SetScript("OnUpdate", nil);
        self:SetScript("OnEvent", nil);
        API.UnregisterFrameForEvents(self, DynamicEvents);
    end

    local function SortFunc_PrioritizeNotFinished(a, b)
        if a.isComplete ~= b.isComplete then
            return b.isComplete
        end

        if a.readyForTurnIn ~= b.readyForTurnIn then
            return b.readyForTurnIn
        end

        return a.index < b.index
    end

    function ActivityTabMixin:FullUpdate()
        local sortedQuestList = {};
        local content = {};
        local n = 0;

        local showCompleted = not addon.GetDBBool("LandingPage_Activity_HideCompleted");
        local showActivity = true;
        local hideFinishedObjectives = true;   --debug

        local buttonHeight = 24;
        local gap = 4;
        local offsetY = 2;
        local top, bottom;

        local m = 0;
        local numCompleted = 0;
        local numReadyForTurnIn = 0;

        for index, questID in ipairs(QuestIDList) do
            if not IgnoredQuests[questID] then
                local progressInfo = GetQuestProgressInfo(questID, hideFinishedObjectives);


                showActivity = progressInfo.isOnQuest or (progressInfo.isComplete and showCompleted);

                if QuestInfoExtra[questID] and QuestInfoExtra[questID].shownIfOnQuest and not progressInfo.isOnQuest then
                    --Hide one-off quests
                    showActivity = false;
                else
                    if progressInfo.isComplete then
                        numCompleted = numCompleted + 1;
                    end
                end

                if progressInfo.readyForTurnIn then
                    numReadyForTurnIn = numReadyForTurnIn + 1;
                end

                if showActivity then
                    m = m + 1;
                    sortedQuestList[m] = {
                        index = index,
                        questID = questID,
                        progressInfo = progressInfo,
                        isComplete = progressInfo.isComplete or false,
                        readyForTurnIn = progressInfo.readyForTurnIn or false,
                    };
                end
            end
        end

        if m > 0 then
            --Has something to show
            table.sort(sortedQuestList, SortFunc_PrioritizeNotFinished);

            for _, v in ipairs(sortedQuestList) do
                local questID = v.questID;
                local progressInfo = v.progressInfo;
                n = n + 1;
                local isOdd = n % 2 == 0;
                top = offsetY;
                bottom = offsetY + buttonHeight + gap;
                offsetY = bottom;
                content[n] = {
                    templateKey = "ListButton",
                    setupFunc = function(obj)
                        obj.isOdd = isOdd;
                        obj.completed = progressInfo.isComplete;
                        obj.readyForTurnIn = progressInfo.readyForTurnIn;
                        obj:SetQuestHeader(questID);
                    end,
                    top = top,
                    bottom = bottom,
                };

                if progressInfo.numObjectives and progressInfo.numObjectives > 0 then
                    for i = 1, progressInfo.numObjectives do
                        n = n + 1;
                        local isOdd = n % 2 == 0;
                        top = offsetY;
                        bottom = offsetY + buttonHeight + gap;
                        offsetY = bottom;
                        content[n] = {
                            templateKey = "ListButton",
                            setupFunc = function(obj)
                                obj.isOdd = isOdd;
                                obj:SetObjective(progressInfo.objectives[i].text);
                            end,
                            top = top,
                            bottom = bottom,
                        };
                    end
                end
            end
        else
            --Nothing to show
        end

        local retainPosition = false;
        self.ScrollView:Show();
        self.ScrollView:SetContent(content, retainPosition);

        self.Checkbox_HideCompleted:SetFormattedText(numCompleted);
        self.TaskCounter:Update();

        self.numReadyForTurnIn = numReadyForTurnIn;
        CallbackRegistry:Trigger("LandingPage.UpdateNotification", "activity");
    end

    function ActivityTabMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t >= 0.5 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            self:FullUpdate();
        end
    end

    function ActivityTabMixin:RequestUpdate()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function ActivityTabMixin:Init()
        self.Init = nil;

        local headerWidgetOffsetY = -10;


        --Hide Completed Checkbox
        local Checkbox_HideCompleted = LandingPageUtil.CreateCheckboxButton(self);
        self.Checkbox_HideCompleted = Checkbox_HideCompleted;
        Checkbox_HideCompleted:SetPoint("TOPRIGHT", self, "TOPRIGHT", -52, headerWidgetOffsetY);
        Checkbox_HideCompleted:SetText(L["Filter Hide Completed Format"], true);
        Checkbox_HideCompleted.dbKey = "LandingPage_Activity_HideCompleted";
        Checkbox_HideCompleted.textFormat = L["Filter Hide Completed Format"];
        Checkbox_HideCompleted.useDarkYellowLabel = true;
        Checkbox_HideCompleted:UpdateChecked();
        CallbackRegistry:RegisterSettingCallback("LandingPage_Activity_HideCompleted", self.FullUpdate, self);


        --Tasks Taken
        local TaskCounter = LandingPageUtil.CreateWidgetDisplay(self, IR_WIDGET_ID);
        self.TaskCounter = TaskCounter;
        TaskCounter:SetPoint("TOPLEFT", self, "TOPLEFT", 58, headerWidgetOffsetY);


        --ScrollView
        local ScrollView = LandingPageUtil.CreateScrollViewForTab(self, -32);
        self.ScrollView = ScrollView;
        ScrollView:SetScrollBarOffsetY(-4);

        local function ListButton_Create()
            return CreateQuestListButton(ScrollView)
        end

        local function ListButton_OnAcquired(button)

        end
        local function ListButton_OnRemoved(button)
            button:OnRemoved();
        end

        ScrollView:AddTemplate("ListButton", ListButton_Create, ListButton_OnAcquired, ListButton_OnRemoved);


        QuestIDList = C_QuestLine.GetQuestLineQuests(QUESTLINE_ID) or {};
        for _, questID in ipairs(SpecialAssignments) do
            table.insert(QuestIDList, questID);
            QuestInfoExtra[questID] = {
                shownIfOnQuest = true,
            };
        end
    end
end

local function CreateActivityTab(f)
    ActivityTab = f;
    API.Mixin(f, ActivityTabMixin);
    f:Init();

    f:SetScript("OnShow", f.OnShow);
    f:SetScript("OnHide", f.OnHide);
    f:SetScript("OnEvent", f.OnEvent);
end


local EncounterTabInfo = {  --Encounter / Raids
    showLoot = false,

    JournalInstanceIDs = {
        768,    --Emerald Nightmare
        861,    --Trial of Valor
    },
};


local function NotificationCheck(asTooltip)
    if not ActivityTab then return end;

    local numReadyForTurnIn = ActivityTab.numReadyForTurnIn or 0;
    if numReadyForTurnIn > 0 then
        if asTooltip then
            local tooltipLines = {
                QUEST_WATCH_QUEST_READY,
            };
            return tooltipLines
        else
            return true
        end
    end
end

do
    local EL = CreateFrame("Frame");
    EL:RegisterEvent("PLAYER_ENTERING_WORLD");
    EL:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            self:UnregisterEvent(event);
            if API.GetTimerunningSeason() == 2 then
                LandingPageUtil.DeleteTab("faction");

                LandingPageUtil.ReplaceTab(
                    {
                        key = "activity",
                        name = L["Activities"],
                        uiOrder = 1,
                        initFunc = CreateActivityTab,
                        dimBackground = true,
                        notificationGetter = NotificationCheck,
                    }
                );

                C_QuestLine.GetQuestLineQuests(QUESTLINE_ID);
                CallbackRegistry:Trigger("LandingPage.SetEncounterTabInfo", EncounterTabInfo);
            end
        end
    end);
end