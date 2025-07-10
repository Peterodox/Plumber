local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;
local AtlasUtil = addon.AtlasUtil;
local FactionUtil = addon.FactionUtil;
local MajorFactionLayout = FactionUtil.MajorFactionLayout;


local ipairs = ipairs;
local CreateFrame = CreateFrame;
local C_Reputation = C_Reputation;
local C_MajorFactions = C_MajorFactions;


local FactionTab;
local FactionButtons = {};


local FACTION_BUTTON_SIZE = 80;
local FACTION_BUTTON_GAP_H = 20;
local FACTION_BUTTON_GAP_V = 20 + 8;
local SUBFACTION_BUTTON_SIZE = 40;


local function HideTooltip()
    GameTooltip:Hide();
end


local ReputationTooltipScripts = {};
do
    --Derivative of Blizzard ReputationUtil.lua

    function ReputationTooltipScripts.AppendClickInstruction(tooltip, factionID, asBottomLine)
        local text = (FactionUtil:IsFactionWatched(factionID) and L["Instruction Untrack Reputation"]) or L["Instruction Track Reputation"];
        if C_Reputation.IsMajorFaction(factionID) then
            text = L["Instruction Click To View Renown"].."\n"..text;
        end

        if asBottomLine then
            GameTooltip_SetBottomText(tooltip, text, GREEN_FONT_COLOR);
        else
            GameTooltip_AddColoredLine(tooltip, text, GREEN_FONT_COLOR, true);
        end
    end

    function ReputationTooltipScripts.TryAppendAccountReputationLineToTooltip(tooltip, factionID)
        if not tooltip or not factionID or not C_Reputation.IsAccountWideReputation(factionID) then
            return;
        end
        local wrapText = false;
        tooltip:AddLine(REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL, 0.000, 0.800, 1.000, wrapText);  --ACCOUNT_WIDE_FONT_COLOR
    end

    function ReputationTooltipScripts.AppendProgressBar(tooltip, min, max, value)
        GameTooltip_ShowProgressBar(tooltip, min, max, value, REPUTATION_PROGRESS_FORMAT:format(value, max));
    end

    function ReputationTooltipScripts.ShowMajorFactionRenownTooltip(self)
        --Before reaching Paragon
        local factionID = self.factionID;
        local data = C_MajorFactions.GetMajorFactionData(factionID);
        if not data then
            return;
        end

        local tooltip = GameTooltip;
        local callback = GenerateClosure(ReputationTooltipScripts.ShowMajorFactionRenownTooltip, self);

        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        tooltip:SetText(data.name, 1, 1, 1);

        ReputationTooltipScripts.TryAppendAccountReputationLineToTooltip(tooltip, factionID);

        --GameTooltip_AddHighlightLine(tooltip, RENOWN_LEVEL_LABEL:format(data.renownLevel));
        local maxLevel = API.GetMaxRenownLevel(factionID);

        tooltip:AddLine(string.format("%s %d/%d", LANDING_PAGE_RENOWN_LABEL, data.renownLevel, maxLevel), 1, 1, 1);
        local value = data.renownReputationEarned;
        local threshold = data.renownLevelThreshold;
        ReputationTooltipScripts.AppendProgressBar(tooltip, 0, threshold, value);

        tooltip:AddLine(" ");
        --[[
        tooltip:AddLine(MAJOR_FACTION_RENOWN_TOOLTIP_PROGRESS:format(data.name), 1, 0.82, 0, true);
        tooltip:AddLine(" ");
        --]]

        local nextRenownRewards = C_MajorFactions.GetRenownRewardsForLevel(factionID, C_MajorFactions.GetCurrentRenownLevel(factionID) + 1);
        if #nextRenownRewards > 0 then
            RenownRewardUtil.AddRenownRewardsToTooltip(tooltip, nextRenownRewards, callback);
        end

        tooltip:AddLine(" ");
        ReputationTooltipScripts.AppendClickInstruction(tooltip, factionID);

        tooltip:Show();
    end

    function ReputationTooltipScripts.ShowParagonRewardsTooltip(self)
        local tooltip = GameTooltip;

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
                local value = math.fmod(currentValue, threshold);
                -- show overflow if reward is pending
                if hasRewardPending then
                    value = value + threshold;
                end
                ReputationTooltipScripts.AppendProgressBar(tooltip, 0, threshold, value);
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

        ReputationTooltipScripts.AppendClickInstruction(tooltip, factionID, true);

        --tooltip:Show();
        GameTooltip_OnShow(tooltip);    --Recalculating padding

        if rewardQuestID and not API.IsQuestRewardCached(rewardQuestID) then
            self.UpdateTooltip = self.ShowTooltip;
        else
            self.UpdateTooltip = nil;
        end
    end

    function ReputationTooltipScripts.ShowFriendshipReputationTooltip(self)
        local factionID = self.factionID;
        local friendshipData = C_GossipInfo.GetFriendshipReputation(factionID);
        if not friendshipData or friendshipData.friendshipFactionID < 0 then
            return
        end

        local tooltip = GameTooltip;

        tooltip:SetOwner(self, "ANCHOR_RIGHT");

        local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(friendshipData.friendshipFactionID);
        if rankInfo.maxLevel > 0 then
            GameTooltip_SetTitle(tooltip, friendshipData.name.." ("..rankInfo.currentLevel.." / "..rankInfo.maxLevel..")", HIGHLIGHT_FONT_COLOR);
        else
            GameTooltip_SetTitle(tooltip, friendshipData.name, HIGHLIGHT_FONT_COLOR);
        end

        ReputationTooltipScripts.TryAppendAccountReputationLineToTooltip(tooltip, factionID);

        tooltip:AddLine(" ");
        tooltip:AddLine(friendshipData.text, nil, nil, nil, true);

        if friendshipData.nextThreshold then
            local current = friendshipData.standing - friendshipData.reactionThreshold;
            local max = friendshipData.nextThreshold - friendshipData.reactionThreshold;
            local wrapText = true;
            GameTooltip_AddHighlightLine(tooltip, friendshipData.reaction.." ("..current.." / "..max..")", wrapText);
        else
            local wrapText = true;
            GameTooltip_AddHighlightLine(tooltip, friendshipData.reaction, wrapText);
        end

        tooltip:AddLine(" ");
        ReputationTooltipScripts.AppendClickInstruction(tooltip, factionID);

        tooltip:Show();
    end

    function ReputationTooltipScripts.ShowStandardTooltip(self)
        local factionID = self.factionID;
        local factionData = factionID and API.GetReputationProgress(factionID);
        if not factionData then return end;

        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");

        tooltip:SetText(factionData.name, 1, 1, 1);

        ReputationTooltipScripts.TryAppendAccountReputationLineToTooltip(tooltip, factionID);

        tooltip:AddLine(API.GetReputationStandingText(factionData.reaction), 1, 1, 1, true);

        if not factionData.isFull then
            ReputationTooltipScripts.AppendProgressBar(tooltip, 0, factionData.maxValue, factionData.currentValue);
        end

        tooltip:AddLine(" ");
        ReputationTooltipScripts.AppendClickInstruction(tooltip, factionID);

        tooltip:Show();
    end
end


local CreateFactionIconButton;
do
    local FactionIconButtonMixin = {};

    function FactionIconButtonMixin:OnEnter()

    end

    function FactionIconButtonMixin:OnLeave()
        if not self.selected then

        end
    end

    function FactionIconButtonMixin:OnClick()
        if not self.selected then
            if FactionTab:DisplayMajorFactionDetail(self.factionID) then
                LandingPageUtil.PlayUISound("CheckboxOn");
            end
        end
    end

    function FactionIconButtonMixin:OnMouseDown()
        if not self.selected then
            self.FactionIcon:SetPoint("CENTER", self, "CENTER", 0, -1);
        end
    end

    function FactionIconButtonMixin:OnMouseUp()
        self.FactionIcon:SetPoint("CENTER", self, "CENTER", 0, 0);
    end

    function FactionIconButtonMixin:SetFaction(factionID)
        self.factionID = factionID;
        local data = C_MajorFactions.GetMajorFactionData(factionID);
        if data then
            AtlasUtil.SetFactionIcon(self.FactionIcon, factionID);
            AtlasUtil.SetFactionIconHighlight(self.Highlight, factionID);
            self.Highlight:SetAlpha(1);
            self.Highlight:SetVertexColor(1, 0.82, 0);
        end
    end

    function FactionIconButtonMixin:SetSelected(state)
        self.selected = state;
        if state then
            self.FactionIcon:SetVertexColor(1, 1, 1);
        else
            self.FactionIcon:SetVertexColor(0.5, 0.5, 0.5);
        end
    end

    function CreateFactionIconButton(parent)
        local f = CreateFrame("Button", nil, parent);
        f:SetSize(32, 32);
        f.FactionIcon = f:CreateTexture(nil, "OVERLAY");
        f.FactionIcon:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.FactionIcon:SetSize(44, 44);

        f.Highlight = f:CreateTexture(nil, "HIGHLIGHT");
        f.Highlight:SetPoint("TOPLEFT", f.FactionIcon, "TOPLEFT", 0, 0);
        f.Highlight:SetPoint("BOTTOMRIGHT", f.FactionIcon, "BOTTOMRIGHT", 0, 0);

        API.Mixin(f, FactionIconButtonMixin);
        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);
        f:SetScript("OnMouseDown", f.OnMouseDown);
        f:SetScript("OnMouseUp", f.OnMouseUp);

        return f
    end
end


local LandingPageMajorFactionButtonMixin = {};
do
    function LandingPageMajorFactionButtonMixin:OnLoad()
        local tex = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/ExpansionLandingPage";

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

        --self.AlertIcon:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/AlertIcon-Green");
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
            AtlasUtil.SetFactionIcon(self.FactionIcon, factionID);
        end

        if factionID or self.parentFactionID then
            r, g, b = FactionUtil:GetProgressBarColor(factionID, self.parentFactionID);
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
        HideTooltip();
    end

    function LandingPageMajorFactionButtonMixin:OnClick(button)
        if self.onClickFunc then
            self.onClickFunc(self, button);
        end
    end

    function LandingPageMajorFactionButtonMixin:ShowTooltip()
        --See Blizzard_UIPanels_Game/ReputationFrame.lua
        self.UpdateTooltip = nil;

        if C_Reputation.IsFactionParagon(self.factionID) then
            ReputationTooltipScripts.ShowParagonRewardsTooltip(self);
        elseif self.reputationType == 2 then    --Friendship
            ReputationTooltipScripts.ShowFriendshipReputationTooltip(self);
        elseif self.reputationType == 3 then    --MajorFaction
            ReputationTooltipScripts.ShowMajorFactionRenownTooltip(self);
        elseif self.reputationType == 1 then    --Standard
            ReputationTooltipScripts.ShowStandardTooltip(self);
        end
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
            self.FactionIcon:SetSize(56, 56);
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


local function FactionButton_OnClickFunc(self, button)
    if button == "LeftButton" and IsShiftKeyDown() then
        local newState = not FactionUtil:IsFactionWatched(self.factionID);
        local watchedFactionID = (newState and self.factionID) or 0;
        C_Reputation.SetWatchedFactionByID(watchedFactionID);       --Trigger UPDATE_FACTION
        HideTooltip();

        if newState then
            LandingPageUtil.PlayUISound("CheckboxOn");
        else
            LandingPageUtil.PlayUISound("CheckboxOff");
        end

        return
    end

    if FactionTab then
        if FactionTab:DisplayMajorFactionDetail(self.factionID) then
            LandingPageUtil.PlayUISound("PageOpen");
        end
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


local CreateRenownItemButton;
do
    local RenownItemButtonMixin = {};

    function RenownItemButtonMixin:GreyOut(state)
        if state then
            self.RewardIcon:SetDesaturated(true);
            self.RewardIcon:SetVertexColor(0.8, 0.8, 0.8);
            self.Name:SetTextColor(0.6, 0.6, 0.6);
        else
            self.RewardIcon:SetDesaturated(false);
            self.RewardIcon:SetVertexColor(1, 1, 1);
            self.Name:SetTextColor(0.922, 0.871, 0.761);
        end
    end

    function RenownItemButtonMixin:SetRewardInfo(info)
        self.RewardIcon:SetTexture(info.icon);
        self.Name:SetText(info.name);
        self.name = info.name;
        self.description = info.description;
        self.isAccountUnlock = info.isAccountUnlock;
        self:GreyOut(self.locked);

        --The following fields always seem to be nil
        self.type, self.id = nil, nil;
        if info.itemID then
            self.type = "item";
            self.id = info.itemID;
        elseif info.spellID then
            self.type = "spell";
            self.id = info.spellID;
        elseif info.mountID then
            self.type = "mount";
            self.id = info.mountID;
        elseif info.transmogID then
            self.type = "transmog";
            self.id = info.transmogID;
        elseif info.transmogSetID then
            self.type = "transmogSet";
            self.id = info.transmogSetID;
        elseif info.transmogIllusionSourceID then
            self.type = "illusion";
            self.id = info.transmogIllusionSourceID;
        elseif info.titleMaskID then
            self.type = "title";
            self.id = info.titleMaskID;
        end
    end

    function RenownItemButtonMixin:OnEnter()
        FactionTab:HighlightButton(self);

        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        tooltip:SetText(self.name, 1, 1, 1);
        if self.isAccountUnlock then
            tooltip:AddLine(RENOWN_REWARD_ACCOUNT_UNLOCK_LABEL, 0.000, 0.800, 1.000, true);  --ACCOUNT_WIDE_FONT_COLOR
            tooltip:AddLine(" ");
        end
        tooltip:AddLine(self.description, 1, 0.82, 0, true);
        tooltip:Show();

        if not self.locked then
            self.Name:SetTextColor(1, 1, 1);
        end
    end

    function RenownItemButtonMixin:OnLeave()
        FactionTab:HighlightButton(nil);
        HideTooltip();
        self:GreyOut(self.locked);
    end

    function CreateRenownItemButton(parent)
        local f = CreateFrame("Button", nil, parent);
        f:SetSize(256, 32);

        f.RewardIcon = f:CreateTexture(nil, "ARTWORK");
        f.RewardIcon:SetSize(30, 30);
        f.RewardIcon:SetPoint("LEFT", f, "LEFT", 2, 0);
        f.RewardIcon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375);

        local mask = f:CreateMaskTexture(nil, "ARTWORK");
        mask:SetSize(32, 32);
        mask:SetPoint("CENTER", f.RewardIcon, "CENTER", 0, 0);
        mask:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Chamfer.tga", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        f.RewardIcon:AddMaskTexture(mask);

        f.ItemBorder = f:CreateTexture(nil, "OVERLAY");
        f.ItemBorder:SetSize(40, 40);
        f.ItemBorder:SetPoint("CENTER", f.RewardIcon, "CENTER", 0, 0);
        f.ItemBorder:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/ItemBorder");
        f.ItemBorder:SetTexCoord(80/512, 160/512, 0/512, 80/512);
        API.DisableSharpening(f.ItemBorder);

        f.Name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Name:SetPoint("LEFT", f, "LEFT", 40, 0);
        f.Name:SetJustifyH("LEFT");
        f.Name:SetTextColor(0.92, 0.92, 0.92);
        f.Name:SetMaxLines(2);
        f.Name:SetWidth(216);

        API.Mixin(f, RenownItemButtonMixin);
        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);

        return f
    end
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
        local focus = self:IsMouseOver() and API.GetMouseFocus();

        self.factionDirty = nil;
        for _, button in ipairs(FactionButtons) do
            button:Refresh();
            if button == focus then
                if button:IsMouseMotionFocus() and button.onClickFunc then
                    button:OnEnter();
                end
            end
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
        if self:IsViewingFactionDetail() then
            self:UpdateRewardsList(true);
        end
    end

    function FactionTabMixin:OnHide()
        self.t = nil;
        self:SetScript("OnUpdate", nil);
        API.UnregisterFrameForEvents(self, DynamicEvents);
        self:StopAnimating();
    end

    function FactionTabMixin:OnEvent(event, ...)
        if event == "UPDATE_FACTION" or event == "QUEST_TURNED_IN" or event == "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" or event == "MAJOR_FACTION_UNLOCKED" then
            local updateRewards = event == "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" or event == "MAJOR_FACTION_UNLOCKED";
            self:RequestFullUpdate(updateRewards);
        elseif event == "GLOBAL_MOUSE_UP" then
            local button = ...
            if button == "RightButton" and self:IsMouseOver() and not self.isOverview then
                self:DisplayOverview();
                LandingPageUtil.PlayUISound("PageClose");
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

            if self.rewardsDirty then
                self.rewardsDirty = nil;
                if self:IsViewingFactionDetail() then
                    local retainPosition = true;
                    self:UpdateRewardsList(retainPosition);
                end
            end
        end
    end

    function FactionTabMixin:RequestFullUpdate(updateRewards)
        self.factionDirty = true;
        if updateRewards then
            self.rewardsDirty = true;
        end
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function FactionTabMixin:DisplayOverview()
        if self.isOverview then return end;

        self.isOverview = true;
        self.selectedFactionID = nil;
        LandingPageUtil.ShowLeftFrame(true);
        self.OverviewFrame:Show();
        if self.DetailFrame then
            self.DetailFrame:Hide();
        end
    end

    function FactionTabMixin:DisplayMajorFactionDetail(factionID)
        if not C_Reputation.IsMajorFaction(factionID) then return false end;

        self.isOverview = false;
        self.selectedFactionID = factionID;
        LandingPageUtil.ShowLeftFrame(false);
        self.OverviewFrame:Hide();
        self:InitDetailFrame();
        self.DetailFrame:Show();
        self:UpdateLeftWidgets();
        self:UpdateRightSection();

        return true
    end

    function FactionTabMixin:IsViewingFactionDetail()
        return not self.isOverview
    end

    function FactionTabMixin:InitDetailFrame()
        if self.DetailFrame then return end;

        local DetailFrame = CreateFrame("Frame", nil, self);
        self.DetailFrame = DetailFrame;
        DetailFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8);
        DetailFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 8);
        --DetailFrame:SetHyperlinksEnabled(true);


        do  --LeftSection
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
            BackgroundGlow:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/ExpansionLandingPage-BackgroundGlow");
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
                    --Faction Name
                    fs:SetPoint("TOP", ProgressDisplay, "BOTTOM", 0, -24);
                    fs:SetSpacing(2);
                    r, g, b = 0.906, 0.737, 0.576;

                    --Mouseover faction name to show faction description
                    local LeftNameArea = CreateFrame("Frame", nil, DetailFrame);
                    self.LeftNameArea = LeftNameArea;
                    LeftNameArea:SetPoint("TOPLEFT", fs, "TOPLEFT", 0, 4);
                    LeftNameArea:SetPoint("BOTTOMRIGHT", fs, "BOTTOMRIGHT", 0, -4);
                    LeftNameArea:SetScript("OnEnter", function()
                        local factionID = self.selectedFactionID;
                        local factionData = factionID and C_Reputation.GetFactionDataByID(factionID);
                        if factionData and factionData.description then
                            local tooltip = GameTooltip;
                            tooltip:SetOwner(LeftNameArea, "ANCHOR_RIGHT");
                            tooltip:SetText(factionData.name, 1, 1, 1);
                            tooltip:AddLine(factionData.description, 1, 0.82, 0, true);
                            tooltip:Show();
                        end
                    end);
                    LeftNameArea:SetScript("OnLeave", function()
                        HideTooltip();
                    end);
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


            --Create a List of FactionIconButtons
            local button;
            local buttons = {};
            self.FactionIconButtons = buttons;
            local gap = 0;
            local iconButtonSize = 42;
            local iconsPerRow = 5;
            local factionList = {};
            for row, rowInfo in ipairs(MajorFactionLayout) do
                for _, factionInfo in ipairs(rowInfo) do
                    table.insert(factionList, factionInfo.factionID);
                end
            end

            local numFactions = #factionList;
            local numRows = math.ceil(numFactions / iconsPerRow);
            local iconsLastRow = numFactions + (1 - numRows) * iconsPerRow;
            local spanLastRow = iconsLastRow * (iconButtonSize + gap) - gap;
            local spanFullRow = iconsPerRow * (iconButtonSize + gap) - gap;
            local row, col = 1, 0;
            local fromY = 416;  --432
            local offsetX, spanX;

            for i, factionID in ipairs(factionList) do
                button = CreateFactionIconButton(DetailFrame);
                button:SetSize(iconButtonSize, iconButtonSize);
                table.insert(buttons, button);
                col = col + 1;
                if col > iconsPerRow then
                    col = 1;
                    row = row + 1;
                    fromY = fromY + iconButtonSize + gap;
                end
                if row >= numRows then
                    spanX = spanLastRow;
                else
                    spanX = spanFullRow;
                end
                offsetX = -0.5 * spanX + (col - 1) * (iconButtonSize + gap);
                button:SetPoint("TOPLEFT", LeftFrame, "TOP", offsetX, -fromY);
                button:SetFaction(factionID);
            end
        end


        do  --RightSection
            local RenownItemScrollView = API.CreateScrollView(DetailFrame);
            self.RenownItemScrollView = RenownItemScrollView;
            RenownItemScrollView:SetAllPoints(true);
            RenownItemScrollView:OnSizeChanged();
            RenownItemScrollView:SetStepSize(48);
            RenownItemScrollView:SetBottomOvershoot(48);
            RenownItemScrollView:EnableMouseBlocker(true);

            local ButtonHighlight = LandingPageUtil.CreateButtonHighlight(RenownItemScrollView);
            ButtonHighlight:SetSize(288, 36);

            function self:HighlightButton(renownItemButton)
                ButtonHighlight:Hide();
                ButtonHighlight:ClearAllPoints();
                if renownItemButton then
                    ButtonHighlight:SetParent(renownItemButton);
                    ButtonHighlight:SetPoint("CENTER", renownItemButton, "CENTER", 0, 0);
                    ButtonHighlight:Show();
                end
            end

            local function ShowFocusedButtonTooltip()

            end
            RenownItemScrollView:SetOnScrollStopCallback(ShowFocusedButtonTooltip);


            local function RenownItemButton_Create()
                return CreateRenownItemButton(RenownItemScrollView)
            end

            local function RenownItemButton_OnRemoved(button)
                button.name = nil;
                button.description = nil;
                button.isAccountUnlock = nil;
                button.type = nil;
                button.id = nil;
            end

            RenownItemScrollView:AddTemplate("Item", RenownItemButton_Create, nil, RenownItemButton_OnRemoved);


            local function Divider_Create()
                local divider = RenownItemScrollView:CreateTexture(nil, "ARTWORK");
                divider:SetSize(512, 16);
                divider:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/Divider-H-Shadow");
                divider:SetAlpha(0.1);
                return divider
            end

            RenownItemScrollView:AddTemplate("Divider", Divider_Create);


            local function LevelText_Create()
               local fs = RenownItemScrollView:CreateFontString(nil, "OVERLAY", "PlumberFont_16");
               fs:SetTextColor(1, 1, 1, 0.2);
               fs:SetJustifyH("RIGHT");
               return fs
            end

            RenownItemScrollView:AddTemplate("LevelText", LevelText_Create);
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
                local nextLevelFormat = progress.isFull and L["Until Paragon Reward Format"] or L["Until Next Level Format"];
                ProgressDisplay.Text3:SetText(nextLevelFormat:format(maxValue - currentValue));
                ProgressDisplay.Text3:SetTextColor(0.5, 0.5, 0.5);
            end
        end

        if self.FactionIconButtons then
            for _, button in ipairs(self.FactionIconButtons) do
                button:SetSelected(button.factionID == factionID);
            end
        end
    end

    function FactionTabMixin:UpdateRewardsList(retainPosition, scrollToFirstLockedReward)
        local factionID = self.selectedFactionID;
        local renownLevelsInfo = C_MajorFactions.GetRenownLevels(factionID);
        local rewards;

        local function SortFunc_UIOrder(a, b)
            if a.uiOrder and b.uiOrder and (a.uiOrder ~= b.uiOrder) then
                return a.uiOrder < b.uiOrder
            else
                return a.name < b.name
            end
        end

        local content = {};
        local n = 0;
        local gapSameTie = 8;
        local offsetY = 16;
        local buttonHeight = 32;
        local numLevels = #renownLevelsInfo;
        local top, bottom;
        local firstLockedIndex;

        if renownLevelsInfo then
            for k, v in ipairs(renownLevelsInfo) do
                rewards = C_MajorFactions.GetRenownRewardsForLevel(factionID, v.level)
                table.sort(rewards, SortFunc_UIOrder);
                for index, rewardInfo in ipairs(rewards) do
                    n = n + 1;
                    top = offsetY;
                    bottom = offsetY + buttonHeight + gapSameTie;
                    content[n] = {
                        dataIndex = n,
                        templateKey = "Item",
                        setupFunc = function(obj)
                            obj.locked = v.locked;
                            obj:SetRewardInfo(rewardInfo);
                        end,
                        top = top,
                        bottom = bottom,
                    };

                    if v.locked and (not firstLockedIndex) then
                        firstLockedIndex = n - 1;
                    end

                    if index == 1 then
                        n = n + 1;
                        top = offsetY + 0.5*(#rewards*(buttonHeight + gapSameTie) - gapSameTie);
                        content[n] = {
                            dataIndex = n,
                            templateKey = "LevelText",
                            setupFunc = function(obj)
                                obj:SetText(v.level);
                                if v.locked then
                                    obj:SetAlpha(0.2);
                                else
                                    obj:SetAlpha(0.6);
                                end
                            end,
                            top = top,
                            bottom = top + 16,
                            offsetX = -164,
                            point = "CENTER",
                        };
                    end

                    offsetY = bottom;
                end

                if k ~= numLevels then
                    n = n + 1;
                    top = offsetY;
                    bottom = offsetY + 16 + 1*gapSameTie;
                    content[n] = {
                        dataIndex = n,
                        templateKey = "Divider",
                        top = top,
                        bottom = bottom,
                    };
                    offsetY = bottom;
                end
            end
        end

        self.RenownItemScrollView:SetContent(content, retainPosition);

        if scrollToFirstLockedReward then
            firstLockedIndex = firstLockedIndex or n;
            self.RenownItemScrollView:SnapToContent(firstLockedIndex);
        end
    end

    function FactionTabMixin:UpdateRightSection()
        self:UpdateRewardsList(false, true);
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
                    local widget = CreateFactionButton(OverviewFrame, true);
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

local function NotificationCheck(asTooltip)
    if asTooltip then
        local factionIDs = FactionUtil:GetFactionsWithRewardPending();
        if factionIDs then
            local tooltipLines = {};
            local n = 1;
            tooltipLines[n] = L["Paragon Reward Available"];
            for _, factionID in ipairs(factionIDs) do
                n = n + 1;
                tooltipLines[n] = "- "..(FactionUtil:GetFactionName(factionID) or "");
            end
            return tooltipLines
        end
    else
        return FactionUtil:IsAnyParagonRewardPending()
    end
end

local function FactionTab_OnSelected()
    if FactionTab then
        FactionTab:DisplayOverview();
    end
end

LandingPageUtil.AddTab(
    {
        key = "faction",
        name = L["Factions"],
        uiOrder = 1,
        initFunc = CreateFactionTab,
        notificationGetter = NotificationCheck,
        useCustomLeftFrame = true,
        onTabSelected = FactionTab_OnSelected,
    }
);