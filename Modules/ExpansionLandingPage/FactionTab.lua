local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;

local C_Reputation = C_Reputation;
local C_MajorFactions = C_MajorFactions;
local GetParagonValuesAndLevel = API.GetParagonValuesAndLevel;


local FactionTab;
local FactionButtons = {};

local OverrideFactionInfo = {
    [2570] = {  --Hallowfall Arathi
        barColor = {244/255, 186/255, 130/255},
    },

    [2590] = {  --Council of Dornogal
        barColor = {56/255, 184/255, 255/255},
    },

    [2594] = {  --The Assembly of the Deeps
        barColor = {254/255, 137/255, 97/255},
    },

    [2600] = {  --The Severed Threads
        barColor = {251/255, 137/255, 119/255},
    },

    [2653] = {  --The Cartels of Undermine
        barColor = {252/255, 138/255, 103/255},
    },

    [2685] = {  --Gallagio Loyalty Rewards Club
        barColor = {163/255, 178/255, 104/255},
    },

    [2688] = {  --Flame's Radiance
        barColor = {178/255, 171/255, 135/255},
    },
};

local MajorFactionLayout = {
    --[row] = {},
    [1] = {
        {factionID = 2688},     --Flame's Radiance
    },

    [2] = {
        {factionID = 2685},     --Gallagio Loyalty Rewards Club
        {factionID = 2653,
            subFactions = {
                {factionID = 2669, iconFileID = 6439629, criteria = function() return C_QuestLog.IsQuestFlaggedCompletedOnAccount(86961) end}, --Darkfuse Solutions unlocked after completed "Diversified Investments"
                {factionID = 2673, iconFileID = 6439627},     --Bilgewater Cartel
                {factionID = 2677, iconFileID = 6439630},     --Steamwheedle Cartel
                {factionID = 2675, iconFileID = 6439628},     --Blackwater Cartel
                {factionID = 2671, iconFileID = 6439631},     --Venture Co.
            },
        },
    },

    [3] = {
        {factionID = 2590},     --Council of Dornogal
        {factionID = 2594},     --The Assembly of the Deeps
        {factionID = 2570},     --Hallowfall Arathi
        {factionID = 2600,
            subFactions = {
                {factionID = 2601, creatureDisplayID = 116208},     --Weaver
                {factionID = 2605, creatureDisplayID = 114775},     --General Anub'azal
                {factionID = 2607, creatureDisplayID = 114268},     --Vizier
            },
        },
    },
};


local FACTION_BUTTON_SIZE = 80;
local FACTION_BUTTON_GAP_H = 20;
local FACTION_BUTTON_GAP_V = 20 + 8;
local SUBFACTION_BUTTON_SIZE = 40;


local ReputationTooltipScripts = {};
do
    --Derivative of Blizzard ReputationUtil.lua

    function ReputationTooltipScripts.TryAppendAccountReputationLineToTooltip(tooltip, factionID)
        if not tooltip or not factionID or not C_Reputation.IsAccountWideReputation(factionID) then
            return;
        end
        local wrapText = false;
        tooltip:AddLine(REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL, 0.000, 0.800, 1.000, wrapText);  --ACCOUNT_WIDE_FONT_COLOR
    end

    function ReputationTooltipScripts.ShowMajorFactionRenownTooltip(self)
        --Before reaching Paragon

        local data = C_MajorFactions.GetMajorFactionData(self.factionID);
        if not data then
            return;
        end

        local tooltip = GameTooltip;
        local callback = GenerateClosure(ReputationTooltipScripts.ShowMajorFactionRenownTooltip, self);

        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        tooltip:SetText(data.name, 1, 1, 1);

        ReputationTooltipScripts.TryAppendAccountReputationLineToTooltip(tooltip, data.factionID);

        --GameTooltip_AddHighlightLine(tooltip, RENOWN_LEVEL_LABEL:format(data.renownLevel));
        local maxLevel = API.GetMaxRenownLevel(self.factionID);

        tooltip:AddLine(string.format("%s %d/%d", LANDING_PAGE_RENOWN_LABEL, data.renownLevel, maxLevel), 1, 1, 1);
        local value = data.renownReputationEarned;
        local threshold = data.renownLevelThreshold;
        GameTooltip_ShowProgressBar(tooltip, 0, threshold, value, REPUTATION_PROGRESS_FORMAT:format(value, threshold));

        tooltip:AddLine(" ");
        --[[
        tooltip:AddLine(MAJOR_FACTION_RENOWN_TOOLTIP_PROGRESS:format(data.name), 1, 0.82, 0, true);
        tooltip:AddLine(" ");
        --]]

        local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(data.factionID, C_MajorFactions.GetCurrentRenownLevel(data.factionID) + 1);
        if #nextRenownRewards > 0 then
            RenownRewardUtil.AddRenownRewardsToTooltip(tooltip, nextRenownRewards, callback);
        end

        tooltip:AddLine(" ");
        GameTooltip_AddInstructionLine(tooltip, REPUTATION_BUTTON_TOOLTIP_CLICK_INSTRUCTION);

        tooltip:Show();
    end

    function ReputationTooltipScripts.ShowParagonRewardsTooltip(self)
        local tooltip = EmbeddedItemTooltip;

        --AddParagonRewardsToTooltip
        local factionID = self.factionID;
        local factionStandingtext;
        local factionData = C_Reputation.GetFactionDataByID(factionID);
        local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID);
        if reputationInfo and reputationInfo.friendshipFactionID > 0 then
            factionStandingtext = reputationInfo.reaction;
        elseif C_Reputation.IsMajorFaction(factionID) then
            factionStandingtext = MAJOR_FACTION_MAX_RENOWN_REACHED;
        else
            local gender = UnitSex("player");
            factionStandingtext = GetText("FACTION_STANDING_LABEL"..factionData.reaction, gender);
        end
        local currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID);

        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        tooltip:SetText(factionData.name);
        tooltip.factionID = factionID;
        ReputationTooltipScripts.TryAppendAccountReputationLineToTooltip(tooltip, factionID);

        if tooLowLevelForParagon then
            tooltip:AddLine(PARAGON_REPUTATION_TOOLTIP_TEXT_LOW_LEVEL, 1, 0.82, 0, true);
        else
            tooltip:AddLine(factionStandingtext, 1, 1, 1, true);

            if not hasRewardPending and currentValue and threshold then
                local value = mod(currentValue, threshold);
                -- show overflow if reward is pending
                if hasRewardPending then
                    value = value + threshold;
                end
                GameTooltip_ShowProgressBar(tooltip, 0, threshold, value, REPUTATION_PROGRESS_FORMAT:format(value, threshold));
            end

            local description = PARAGON_REPUTATION_TOOLTIP_TEXT:format(factionData.name);
            if hasRewardPending then
                local questIndex = C_QuestLog.GetLogIndexForQuestID(rewardQuestID);
                local text = GetQuestLogCompletionText(questIndex);
                if text and text ~= "" then
                    description = text;
                end
            end
            tooltip:AddLine(" ");
            tooltip:AddLine(description, 1, 0.82, 0, true);

            GameTooltip_AddQuestRewardsToTooltip(tooltip, rewardQuestID);
        end

        GameTooltip_SetBottomText(tooltip, REPUTATION_BUTTON_TOOLTIP_CLICK_INSTRUCTION, GREEN_FONT_COLOR);
        --tooltip:Show();
        GameTooltip_OnShow(tooltip);    --Recalculating padding

        if rewardQuestID and not API.IsQuestRewardCached(rewardQuestID) then
            self.UpdateTooltip = self.ShowTooltip;
        else
            self.UpdateTooltip = nil;
        end

        --debug
        print(factionID)
    end
end


local function NotificationCheck()
    return false
end


local LandingPageMajorFactionButtonMixin = {};
do
    function LandingPageMajorFactionButtonMixin:OnLoad()
        local tex = "Interface/AddOns/Plumber/Art/Frame/ExpansionLandingPage";

        self.Border:SetTexture(tex);
        self.Border:SetTexCoord(0/1024, 200/1024, 0/1024, 216/1024);

        self.BorderHighlight:SetTexture(tex);
        self.BorderHighlight:SetTexCoord(0/1024, 200/1024, 0/1024, 216/1024);

        self.Background:SetTexture(tex);
        self.Background:SetTexCoord(200/1024, 360/1024, 20/1024, 180/1024);

        self.Glow:SetTexture(tex);
        self.Glow:SetTexCoord(0/1024, 200/1024, 416/1024, 616/1024);

        local ProgressBar = self.ProgressBar;

        local lowTexCoords =
        {
            x = 360/1024,
            y = 20/1024,
        };
        local highTexCoords =
        {
            x = 520/1024,
            y = 180/1024,
        };

        ProgressBar:SetSwipeTexture(tex);
        ProgressBar:SetTexCoordRange(lowTexCoords, highTexCoords);
        ProgressBar:SetSwipeColor(56/255, 184/255, 255/255);

        ProgressBar.visualOffset = 0.06;
        API.Mixin(ProgressBar, addon.RadialProgressBarMixin);
        ProgressBar:SetValue(75, 100);

        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnClick", self.OnClick);

        --self.AlertIcon:SetTexture("Interface/AddOns/Plumber/Art/Frame/AlertIcon-Green");
    end

    function LandingPageMajorFactionButtonMixin:SetShowRenownLevel(state)
        if state and not (self.alwaysHideRenownLevel) then
            self.Level:Show();
            self.ProgressBar.visualOffset = 0.06;
            if self.isMinimized then
                self.BorderHighlight:SetTexCoord(544/1024, 672/1024, 0/1024, 128/1024);
                self.Border:SetTexCoord(544/1024, 672/1024, 0/1024, 128/1024);
                self.Border:SetSize(64, 64);
            else
                self.BorderHighlight:SetTexCoord(0/1024, 200/1024, 0/1024, 216/1024);
                self.Border:SetTexCoord(0/1024, 200/1024, 0/1024, 216/1024);
                self.Border:SetSize(100, 108);
            end
        else
            self.Level:Hide();
            self.ProgressBar.visualOffset = 0.02;
            if self.isMinimized then
                self.BorderHighlight:SetTexCoord(544/1024, 672/1024, 128/1024, 256/1024);
                self.Border:SetTexCoord(544/1024, 672/1024, 128/1024, 256/1024);
                self.Border:SetSize(64, 64);
            else
                self.BorderHighlight:SetTexCoord(0/1024, 200/1024, 216/1024, 416/1024);
                self.Border:SetTexCoord(0/1024, 200/1024, 216/1024, 416/1024);
                self.Border:SetSize(100, 100);
            end
        end
    end

    function LandingPageMajorFactionButtonMixin:Refresh()
        local factionID = self.factionID;
        if not factionID then return end;

        local progress = API.GetReputationProgress(factionID);
        if progress then
            self.reputationType = progress.reputationType;
            local currentValue, maxValue;
            if progress.isFull then
                local paragonLevel;
                currentValue, maxValue, paragonLevel = API.GetParagonValuesAndLevel(factionID);
                self:SetShowRenownLevel(false);
            else
                self.Level:SetText(progress.level);
                currentValue, maxValue = progress.currentValue, progress.maxValue;
                self:SetShowRenownLevel(true);
            end

            if progress.rewardPending then
                self.Glow:Show();
                self.Glow.AnimGlow:Play();
                self.ProgressBar:SetValue(100, 100);
                self.AlertIcon:Show();
            else
                self.Glow:Hide();
                self.Glow.AnimGlow:Stop();
                self.ProgressBar:SetValue(currentValue, maxValue);
                self.AlertIcon:Hide();
            end

            if progress.isUnlocked then
                
            else

            end

            if self.elementData then
                self.elementData.name = progress.name;
            end
        else
            self.reputationType = 0;
        end
    end

    function LandingPageMajorFactionButtonMixin:SetParentFactionID(parentFactionID)
        self.parentFactionID = parentFactionID;
    end

    function LandingPageMajorFactionButtonMixin:SetVisualByFaction(factionID)
        local data = C_MajorFactions.GetMajorFactionData(factionID);
        local r, g, b = 1, 1, 1;

        if data then
            self.FactionIcon:SetAtlas(string.format("majorfactions_icons_%s512", data.textureKit));
        end

        if factionID or self.parentFactionID then
            local v = OverrideFactionInfo[factionID] or OverrideFactionInfo[self.parentFactionID];
            if v then
                if v.barColor then
                    r, g, b = v.barColor[1], v.barColor[2], v.barColor[3];
                end
            end
        end

        self.ProgressBar:SetSwipeColor(r, g, b);
    end

    function LandingPageMajorFactionButtonMixin:SetFaction(factionID)
        self.factionID = factionID;
        self:SetVisualByFaction(factionID);
        self:Refresh();
        --For Blizzard Mixin
        self.elementData = {
            factionID = factionID,
        };
    end

    function LandingPageMajorFactionButtonMixin:OnEnter()
        self:ShowTooltip();
    end

    function LandingPageMajorFactionButtonMixin:OnLeave()
        self:HideTooltip();
    end

    function LandingPageMajorFactionButtonMixin:OnClick()
        if self.onClickFunc then
            self.onClickFunc(self);
        end
    end

    function LandingPageMajorFactionButtonMixin:ShowTooltip()
        --See Blizzard_UIPanels_Game/ReputationFrame.lua
        self.UpdateTooltip = nil;

        if C_Reputation.IsFactionParagon(self.factionID) then
            ReputationTooltipScripts.ShowParagonRewardsTooltip(self);
        elseif self.reputationType == 2 then    --Friendship
            local canClickForOptions = true;
            ReputationEntryMixin.ShowFriendshipReputationTooltip(self, self.factionID, "ANCHOR_RIGHT", canClickForOptions);
        elseif self.reputationType == 3 then    --MajorFaction
            ReputationTooltipScripts.ShowMajorFactionRenownTooltip(self);
        elseif self.reputationType == 1 then    --Standard
            ReputationEntryMixin.ShowStandardTooltip(self);
        end
    end

    function LandingPageMajorFactionButtonMixin:HideTooltip()
        GameTooltip:Hide();
        EmbeddedItemTooltip:Hide();
    end

    function LandingPageMajorFactionButtonMixin:SetMinimized(state)
        self.isMinimized = state;
        local lowTexCoords, highTexCoords;
        if self.isMinimized then
            --Subfaction
            self:SetSize(SUBFACTION_BUTTON_SIZE, SUBFACTION_BUTTON_SIZE);
            self.Border:ClearAllPoints();
            self.Border:SetPoint("CENTER", self, "CENTER", 0, 0);
            self.Border:SetSize(64, 64);
            self.Glow:SetSize(96, 96);
            self.AlertIcon:SetSize(24, 24);
            self.Level:SetPoint("CENTER", self, "CENTER", 0, -16);
            self.Level:SetFontObject("GameFontNormalSmall");
            self.FactionIcon:SetSize(30, 30);
            self.Background:SetSize(64, 64);
            self.Background:SetTexCoord(672/1024, 800/1024, 0/1024, 128/1024);
            self.ProgressBar:SetSize(38, 38);
            self.FactionIcon:SetDrawLayer("BACKGROUND", 1);
            lowTexCoords = {x = 824/1024, y = 24/1024};
            highTexCoords = {x = 904/1024, y = 104/1024};
        else
            --Major Faction
            self:SetSize(FACTION_BUTTON_SIZE, FACTION_BUTTON_SIZE);
            self.Border:ClearAllPoints();
            self.Border:SetPoint("TOP", self, "TOP", 0, 10);
            self.Border:SetSize(100, 108);
            self.Glow:SetSize(200, 200);
            self.AlertIcon:SetSize(32, 32);
            self.Level:SetPoint("CENTER", self, "CENTER", 0, -33);
            self.Level:SetFontObject("GameFontNormal");
            self.FactionIcon:SetSize(44, 44);
            self.Background:SetSize(80, 80);
            self.Background:SetTexCoord(200/1024, 360/1024, 20/1024, 180/1024);
            self.ProgressBar:SetSize(80, 80);
            self.FactionIcon:SetDrawLayer("OVERLAY", 0);
            lowTexCoords = {x = 360/1024, y = 20/1024};
            highTexCoords = {x = 520/1024, y = 180/1024};
        end
        self.ProgressBar:SetTexCoordRange(lowTexCoords, highTexCoords);
    end

    function LandingPageMajorFactionButtonMixin:SetIconByFileID(fileID)
        self.FactionIcon:SetTexture(fileID)
    end

    function LandingPageMajorFactionButtonMixin:SetIconByCreatureDisplayID(creatureDisplayID)
        SetPortraitTextureFromCreatureDisplayID(self.FactionIcon, creatureDisplayID);
    end
end


local function FactionButton_OnClickFunc(self)
    if FactionTab then
        FactionTab:DisplayMajorFactionDetail(self.factionID);
    end
end


local function CreateFactionButton(parent, clickable)
    local f = CreateFrame("Button", nil, parent, "PlumberLandingPageMajorFactionButtonTemplate");
    API.Mixin(f, LandingPageMajorFactionButtonMixin);
    f:OnLoad();
    table.insert(FactionButtons, f);

    if clickable then
        f.onClickFunc = FactionButton_OnClickFunc;
    end

    return f
end


local FactionTabMixin = {};
do
    local DynamicEvents = {
        "UPDATE_FACTION",
        "MAJOR_FACTION_RENOWN_LEVEL_CHANGED",
        "MAJOR_FACTION_UNLOCKED",
        "QUEST_TURNED_IN",
        "GLOBAL_MOUSE_UP",
    };

    function FactionTabMixin:Refresh()
        self.factionDirty = nil;
        for _, button in ipairs(FactionButtons) do
            button:Refresh();
        end

        self:UpdateLeftWidgets();
    end

    function FactionTabMixin:GetFactionButtonByID(factionID)
        for _, button in ipairs(FactionButtons) do
            if factionID == button.factionID then
                return button
            end
        end
    end

    function FactionTabMixin:OnShow()
        self:Refresh();
        API.RegisterFrameForEvents(self, DynamicEvents);
        LandingPageUtil.ShowLeftFrame(self.isOverview);
    end

    function FactionTabMixin:OnHide()
        self.t = nil;
        self:SetScript("OnUpdate", nil);
        API.UnregisterFrameForEvents(self, DynamicEvents);
        self:StopAnimating();
    end

    function FactionTabMixin:OnEvent(event, ...)
        if event == "UPDATE_FACTION" or event == "QUEST_TURNED_IN" or event == "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" or event == "MAJOR_FACTION_UNLOCKED" then
            self:RequestFullUpdate();
        elseif event == "GLOBAL_MOUSE_UP" then
            local button = ...
            if button == "RightButton" and self:IsMouseOver() and not self.isOverview then
                self:DisplayOverview();
            end
        end
    end

    function FactionTabMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t >= 0.2 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            if self.factionDirty then
                self.factionDirty = nil;
                self:Refresh();
            end
        end
    end

    function FactionTabMixin:RequestFullUpdate()
        self.factionDirty = true;
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function FactionTabMixin:DisplayOverview()
        self.isOverview = true;
        self.selectedFactionID = nil;
        LandingPageUtil.ShowLeftFrame(true);
        self.OverviewFrame:Show();
        if self.DetailFrame then
            self.DetailFrame:Hide();
        end
    end

    function FactionTabMixin:DisplayMajorFactionDetail(factionID)
        if not C_Reputation.IsMajorFaction(factionID) then return end;

        self.isOverview = false;
        self.selectedFactionID = factionID;
        LandingPageUtil.ShowLeftFrame(false);
        self.OverviewFrame:Hide();
        self:InitDetailFrame();
        self.DetailFrame:Show();
        self:UpdateLeftWidgets();
    end

    function FactionTabMixin:InitDetailFrame()
        if self.DetailFrame then return end;

        local DetailFrame = CreateFrame("Frame", nil, self);
        self.DetailFrame = DetailFrame;
        DetailFrame:SetAllPoints(true);

        local LeftFrame = PlumberExpansionLandingPage.LeftSection;
        local LeftHeader = LandingPageUtil.CreateListCategoryButton(DetailFrame, MAJOR_FACTION_LIST_TITLE);
        LeftHeader:SetPoint("TOP", LeftFrame, "TOP", 0, -16);

        local ProgressDisplay = CreateFactionButton(DetailFrame);
        self.LeftProgressDisplay = ProgressDisplay;
        ProgressDisplay.alwaysHideRenownLevel = true;
        ProgressDisplay:SetShowRenownLevel(false);
        ProgressDisplay:SetPoint("TOP", LeftFrame, "TOP", 0, -72);
        ProgressDisplay:SetScale(1.25);
        ProgressDisplay:EnableMouse(false);
        ProgressDisplay:EnableMouse(false);

        local BackgroundGlow = DetailFrame:CreateTexture(nil, "BACKGROUND");
        BackgroundGlow:SetSize(256, 256);
        BackgroundGlow:SetPoint("CENTER", ProgressDisplay, "CENTER", 0, 0);
        BackgroundGlow:SetTexture("Interface/AddOns/Plumber/Art/Frame/ExpansionLandingPage-BackgroundGlow");
        BackgroundGlow:SetBlendMode("ADD");
        local shrink = 48;
        BackgroundGlow:SetTexCoord(shrink/256, 1-shrink/256, shrink/256, 1-shrink/256);
        BackgroundGlow:SetVertexColor(51/255, 29/255, 17/255);


        --Create texts below LeftProgressDisplay (FactionName, Level, Rep until next level)
        local textWidth = 224;
        local textFonts = {
            "PlumberFont_16", "GameFontNormal", "GameFontNormal";
        };

        local fs, r, g, b;
        for i = 1, 3 do
            fs = DetailFrame:CreateFontString(nil, "OVERLAY", textFonts[i]);
            ProgressDisplay["Text"..i] = fs;
            fs:SetWidth(textWidth);
            fs:SetJustifyH("CENTER");
            fs:SetJustifyV("TOP");
            if i == 1 then
                fs:SetPoint("TOP", ProgressDisplay, "BOTTOM", 0, -24);
                fs:SetSpacing(2);
                r, g, b = 0.906, 0.737, 0.576;
            else
                fs:SetPoint("TOP", ProgressDisplay["Text"..(i - 1)], "BOTTOM", 0, -6);
                if i == 2 then
                    r, g, b = 0.8, 0.8, 0.8;
                else
                    r, g, b = 0.5, 0.5, 0.5;
                end
            end
            fs:SetTextColor(r, g, b);
        end
    end

    function FactionTabMixin:UpdateLeftWidgets()
        if not (self.LeftProgressDisplay and self.selectedFactionID) then return end;

        local ProgressDisplay = self.LeftProgressDisplay;
        local factionID = self.selectedFactionID;
        local progress = API.GetReputationProgress(factionID);

        ProgressDisplay:SetVisualByFaction(factionID);

        if progress then
            local currentValue, maxValue;

            ProgressDisplay.Text1:SetText(progress.name);

            if progress.isFull then
                local paragonLevel;
                currentValue, maxValue, paragonLevel = API.GetParagonValuesAndLevel(factionID);
                ProgressDisplay.Text2:SetText(L["Paragon Reputation"]);
            else
                local maxLevel = API.GetMaxRenownLevel(factionID);
                currentValue, maxValue = progress.currentValue, progress.maxValue;
                ProgressDisplay.Text2:SetText(string.format("%s %d/%d", LANDING_PAGE_RENOWN_LABEL, progress.level, maxLevel))
            end

            if progress.rewardPending then
                ProgressDisplay.ProgressBar:SetValue(100, 100);
                ProgressDisplay.Text3:SetText(L["Reward Available"]);
                ProgressDisplay.Text3:SetTextColor(0.098, 1.000, 0.098);
            else
                ProgressDisplay.ProgressBar:SetValue(currentValue, maxValue);
                ProgressDisplay.Text3:SetText(L["Until Next Level Format"]:format(maxValue - currentValue));
                ProgressDisplay.Text3:SetTextColor(0.5, 0.5, 0.5);
            end
        end
    end
end

local function CreateFactionTab(factionTab)
    --local majorFactionIDs = C_MajorFactions.GetMajorFactionIDs(10);

    API.Mixin(factionTab, FactionTabMixin);
    FactionTab = factionTab;
    factionTab:SetScript("OnShow", factionTab.OnShow);
    factionTab:SetScript("OnHide", factionTab.OnHide);
    factionTab:SetScript("OnEvent", factionTab.OnEvent);

    local OverviewFrame = CreateFrame("Frame", nil, factionTab);
    factionTab.OverviewFrame = OverviewFrame;
    factionTab.isOverview = true;

    local offsetX;
    local offsetY = 0;
    local maxSpanX = 0;
    local maxSpanY = #MajorFactionLayout * (FACTION_BUTTON_SIZE + FACTION_BUTTON_GAP_V) - FACTION_BUTTON_GAP_V;

    for row, rowInfo in ipairs(MajorFactionLayout) do
        offsetX = 0;
        for _, factionInfo in ipairs(rowInfo) do
            local f = CreateFactionButton(OverviewFrame, true);
            local majorFactionID = factionInfo.factionID;
            f:SetMinimized(false);
            f:SetPoint("TOPLEFT", OverviewFrame, "TOPLEFT", offsetX, offsetY);
            f:SetFaction(majorFactionID);

            if factionInfo.subFactions then
                offsetX = offsetX + FACTION_BUTTON_SIZE + 0.5 * FACTION_BUTTON_GAP_H;
                local childOffsetY = offsetY - 0.5 * (FACTION_BUTTON_SIZE - SUBFACTION_BUTTON_SIZE);
                for _, v in ipairs(factionInfo.subFactions) do
                    local widget = CreateFactionButton(OverviewFrame);
                    widget:SetMinimized(true);
                    widget:SetPoint("TOPLEFT", OverviewFrame, "TOPLEFT", offsetX, childOffsetY);
                    offsetX = offsetX + 0.5 * (FACTION_BUTTON_SIZE + FACTION_BUTTON_GAP_H);
                    widget:SetParentFactionID(majorFactionID);
                    widget:SetFaction(v.factionID);
                    if v.creatureDisplayID then
                        widget:SetIconByCreatureDisplayID(v.creatureDisplayID);
                    else
                        widget:SetIconByFileID(v.iconFileID);
                    end
                end
                offsetX = offsetX + 0.5 * FACTION_BUTTON_GAP_H;
            else
                offsetX = offsetX + (FACTION_BUTTON_SIZE + FACTION_BUTTON_GAP_H);
            end

        end
        local spanX = offsetX - FACTION_BUTTON_GAP_H;
        if spanX > maxSpanX then
            maxSpanX = spanX;
        end
        offsetY = offsetY - (FACTION_BUTTON_SIZE + FACTION_BUTTON_GAP_V);
    end

    local TabContainer = factionTab:GetParent();
    OverviewFrame:ClearAllPoints();
    OverviewFrame:SetSize(maxSpanX, maxSpanY);
    OverviewFrame:SetPoint("TOPLEFT", TabContainer, "TOPLEFT", 0.5*(TabContainer:GetWidth() - maxSpanX), -0.5*(TabContainer:GetHeight() - maxSpanY));
end


LandingPageUtil.AddTab(
    {
        key = "faction",
        name = "Factions",
        uiOrder = 1,
        initFunc = CreateFactionTab,
        notificationGetter = NotificationCheck,
        useCustomLeftFrame = true,
    }
);