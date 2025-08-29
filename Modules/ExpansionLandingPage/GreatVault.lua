local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;


local C_WeeklyRewards = C_WeeklyRewards;
local GetDetailedItemLevelInfo = C_Item.GetDetailedItemLevelInfo;

local GreatVaultFrame;


local BUTTON_WIDTH, BUTTON_HEIGHT = 64, 32;
local GAP_H = 2;
local GAP_V = 8;


local function ShowGreatVaultUI()
    if API.CheckAndDisplayErrorIfInCombat() then
        return
    end
    WeeklyRewards_ShowUI();
end


local GreatVaultButtonMixin = {};
do
    function GreatVaultButtonMixin:SetUnlockedState()
        self.unlocked = true;
        self.Background:SetTexCoord(700/1024, 828/1024, 112/1024, 176/1024);

        if self:IsRewardAtHighestTier() then
            self.Text:SetTextColor(1, 1, 1);
            self.Background:SetVertexColor(1, 1, 1);
        else
            self.Text:SetTextColor(0.92, 0.92, 0.92);
            self.Background:SetVertexColor(0.67, 0.67, 0.67);
        end
    end

    function GreatVaultButtonMixin:SetLockedState()
        self.unlocked = false;
        self.Background:SetTexCoord(828/1024, 956/1024, 112/1024, 176/1024);
        self.Text:SetTextColor(0.5, 0.5, 0.5);
        self.Text:SetText("0/0");
    end

    function GreatVaultButtonMixin:IsRewardAtHighestTier()
        if not self.info then return end;

        local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(self.info.id);
        local upgradeItemLevel;

        if upgradeItemLink then
            upgradeItemLevel = GetDetailedItemLevelInfo(upgradeItemLink);
        end

        if self.info.type == Enum.WeeklyRewardChestThresholdType.Raid then

        else
            local hasData, nextActivityTierID, nextLevel, nextItemLevel = C_WeeklyRewards.GetNextActivitiesIncrease(self.info.activityTierID, self.info.level);
            if hasData then
				upgradeItemLevel = nextItemLevel;
            end
        end

        return upgradeItemLevel == nil
    end

    function GreatVaultButtonMixin:OnEnter()
        GreatVaultFrame:HighlightButton(self);
        if self.ShowTooltip then
            self:ShowTooltip();
        end
    end

    function GreatVaultButtonMixin:OnLeave()
        GreatVaultFrame:HighlightButton();
        self.UpdateTooltip = nil;
        GameTooltip:Hide();
    end

    function GreatVaultButtonMixin:OnClick()
        ShowGreatVaultUI();
    end

    function GreatVaultButtonMixin:CanShowPreviewItemTooltip()
        return self.unlocked
    end
end


local function CreateButton(parent)
    local f = CreateFrame("Button", nil, parent);
    f:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);
    API.Mixin(f, GreatVaultButtonMixin);

    f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    f.Text:SetPoint("CENTER", f, "CENTER", 0, 0);
    f.Text:SetJustifyH("CENTER");
    f.Text:SetTextColor(1, 1, 1);
    f.Text:SetText("0/0");

    f.Background = f:CreateTexture(nil, "BACKGROUND");
    f.Background:SetAllPoints(true);
    f.Background:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/ExpansionBorder_TWW");
    f.Background:SetTexCoord(700/1024, 828/1024, 112/1024, 176/1024);

    f:SetScript("OnEnter", f.OnEnter);
    f:SetScript("OnLeave", f.OnLeave);
    f:SetScript("OnClick", f.OnClick);

    return f
end




local GreatVaultFrameMixin = {};
do
    local Layout = {
        Enum.WeeklyRewardChestThresholdType.Raid,           --RAIDS
        Enum.WeeklyRewardChestThresholdType.Activities,     --DUNGEONS
        Enum.WeeklyRewardChestThresholdType.World,          --WORLD
    };

    local DynamicEvents = {
        "WEEKLY_REWARDS_UPDATE",
        "CHALLENGE_MODE_COMPLETED",
        "CHALLENGE_MODE_MAPS_UPDATE",
    };

    function GreatVaultFrameMixin:Refresh()
        local function SortFunc_Index(a, b)
            return a.index < b.index
        end

        local activities, activityInfo;
        local itemLink, upgradeItemLink;
        local itemLevel, upgradeItemLevel;
        local progressDelta;
        local button;
        local n = 0;

        for row, type in ipairs(Layout) do
            activities = C_WeeklyRewards.GetActivities(type);
            if activities then
                table.sort(activities, SortFunc_Index);
                for i = 1, 3 do
                    n = n + 1;
                    activityInfo = activities[i];
                    if activityInfo then
                        itemLevel, upgradeItemLevel, itemLink = nil, nil, nil;

                        if row == 3 then
                            itemLevel = API.GetDelvesGreatVaultItemLevel(activityInfo.level);
                        end

                        if not itemLevel then
                            itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(activityInfo.id);
                        end

                        if itemLink then
                            --itemLink is "" when the reward is not earned
                            --can be "[]" when the data isn't fully loaded
                            itemLevel = GetDetailedItemLevelInfo(itemLink);
                        end

                        progressDelta = activityInfo.threshold - activityInfo.progress;

                        button = self.buttons[n];
                        button.info = activityInfo;

                        if progressDelta <= 0 then
                            button:SetUnlockedState();
                            button.Text:SetText(itemLevel);
                            button.progressDelta = 0;
                            if not itemLevel then
                                self:RequestFullUpdate();
                            end
                        else
                            button:SetLockedState();
                            button.Text:SetText(string.format("%s/%s", activityInfo.progress, activityInfo.threshold));
                            button.progressDelta = progressDelta;
                        end
                    else
                        --No activityInfo
                    end
                end
            end
        end

        self:TryShowChestAlert();
    end

    function GreatVaultFrameMixin:RequestFullUpdate()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function GreatVaultFrameMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.2 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            self:Refresh();
        end
    end

    function GreatVaultFrameMixin:HighlightButton(button)
        self.Highlight:Hide();
        self.Highlight:ClearAllPoints();
        if button then
            self.Highlight:SetParent(button);
            self.Highlight:SetPoint("CENTER", button, "CENTER", 0, 0);
            self.Highlight:Show();
        end
    end

    function GreatVaultFrameMixin:OnHide()
        self:SetScript("OnUpdate", nil);
        API.UnregisterFrameForEvents(self, DynamicEvents);
    end

    function GreatVaultFrameMixin:OnShow()
        API.RegisterFrameForEvents(self, DynamicEvents);
        self:Refresh();
    end

    function GreatVaultFrameMixin:OnEvent(event, ...)
        if event == "WEEKLY_REWARDS_UPDATE" then
            self:Refresh();
        elseif event == "CHALLENGE_MODE_COMPLETED" then
            C_MythicPlus.RequestMapInfo();
        elseif event == "CHALLENGE_MODE_MAPS_UPDATE" then
            local tooltipOwner = GameTooltip:GetOwner();
            if tooltipOwner then
                for i = 4, 6 do
                    local frame = self.buttons[i];
                    if frame == tooltipOwner then
                        if frame:CanShowPreviewItemTooltip() then
                            frame:ShowPreviewItemTooltip();
                        end
                        break
                    end
                end
            end
        end
    end

    function GreatVaultFrameMixin:TryShowChestAlert()
        if C_WeeklyRewards.HasAvailableRewards() then
            self.ClaimChestAlert:Show();
            self.ClaimChestAlert.AnimSwirl:Play();
            self.ButtonContainer:Hide();
        else
            self.ClaimChestAlert:Hide();
            self.ClaimChestAlert.AnimSwirl:Stop();
            self.ButtonContainer:Show();
        end
    end
end


function LandingPageUtil.CreateGreatVaultFrame(parent)
    C_AddOns.LoadAddOn("Blizzard_WeeklyRewards");
    local BlizzardMixin = WeeklyRewardsActivityMixin;

    local f = CreateFrame("Frame", nil, parent);
    GreatVaultFrame = f;

    local ButtonContainer = CreateFrame("Frame", nil, f);
    f.ButtonContainer = ButtonContainer;

    local offsetX = 0;
    local offsetY = 0;
    local n = 0;
    local buttons = {};
    f.buttons = buttons;

    local inheritMethods = {
        "ShowPreviewItemTooltip",
        "ShowIncompleteTooltip",
        "IsCompletedAtHeroicLevel",
        "AddTopRunsToTooltip",
        "AddRaidCompletionInfoToGameTooltip",
        "GetRaidName",
        "HandlePreviewWorldRewardTooltip",
        "HandlePreviewRaidRewardTooltip",
        "HandlePreviewMythicRewardTooltip",
        "HandlePreviewPvPRewardTooltip",
    };

    local function ShowTooltip(self)
        local tooltip = GameTooltip;

        if self.info.type == Enum.WeeklyRewardChestThresholdType.World then
            tooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
            API.DisplayDelvesGreatVaultTooltip(self, tooltip, self.col, self.info.level, self.info.id, self.progressDelta);
            if API.AddRecentDelvesRecordsToTooltip(tooltip, self.info.threshold) then
                tooltip:Show();
            end
        else
            BlizzardMixin.OnEnter(self);
        end

        if tooltip:IsShown() and tooltip:GetOwner() == self then
            tooltip:ClearAllPoints();
            tooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", -4, -4);
        end
    end

    for row = 1, 3 do
        for col = 1, 3 do
            n = n + 1;
            local button = CreateButton(ButtonContainer);
            buttons[n] = button;
            button.id = n;
            button.col = col;
            button:SetPoint("TOPLEFT", f, "TOPLEFT", offsetX, -offsetY);
            offsetX = offsetX + BUTTON_WIDTH + GAP_H;
            if BlizzardMixin then
                for _, method in ipairs(inheritMethods) do
                    button[method] = BlizzardMixin[method];
                end
                button.ShowTooltip = ShowTooltip;
            end
        end
        offsetX = 0;
        offsetY = offsetY + BUTTON_HEIGHT + GAP_V;
    end

    local width = 3 * (BUTTON_WIDTH + GAP_H) - GAP_H;
    local height = 3 * (BUTTON_HEIGHT + GAP_V) - GAP_V;

    f:SetSize(width, height);

    API.Mixin(f, GreatVaultFrameMixin);
    f:SetScript("OnShow", f.OnShow);
    f:SetScript("OnHide", f.OnHide);
    f:SetScript("OnEvent", f.OnEvent);

    local Highlight = CreateFrame("Frame", nil, f);
    f.Highlight = Highlight;
    Highlight:Hide();
    Highlight:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);
    Highlight.Texture = Highlight:CreateTexture(nil, "OVERLAY");
    Highlight.Texture:SetAllPoints(true);
    Highlight.Texture:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/ExpansionBorder_TWW");
    Highlight.Texture:SetTexCoord(700/1024, 828/1024, 176/1024, 240/1024);
    Highlight.Texture:SetBlendMode("ADD");


    --Notify player of unclaimed chest
    local ClaimChestAlert = CreateFrame("Button", nil, f);
    f.ClaimChestAlert = ClaimChestAlert;
    ClaimChestAlert:Hide();
    ClaimChestAlert:SetAllPoints(true);

    local chestTex = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/GreatVault";
    local ChestIcon = ClaimChestAlert:CreateTexture(nil, "OVERLAY");
    ChestIcon:SetSize(64, 64);
    ChestIcon:SetPoint("TOP", f, "TOP", 0, -9);
    ChestIcon:SetTexture(chestTex);
    ChestIcon:SetTexCoord(0/512, 128/512, 0/512, 128/512);
    local ChestSwirl = ClaimChestAlert:CreateTexture(nil, "ARTWORK");
    ChestSwirl:SetSize(64, 64);
    ChestSwirl:SetPoint("CENTER", ChestIcon, "CENTER", 0, 0);
    ChestSwirl:SetTexture(chestTex);
    ChestSwirl:SetTexCoord(128/512, 256/512, 0/512, 128/512);
    local ag = ChestSwirl:CreateAnimationGroup();
    local r = ag:CreateAnimation("Rotation");
    r:SetDegrees(-360);
    r:SetDuration(4);
    ag:SetLooping("REPEAT");
    ClaimChestAlert.AnimSwirl = ag;


    local AlertText = ClaimChestAlert:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    ClaimChestAlert.AlertText = AlertText;
    AlertText:SetWidth(208);
    AlertText:SetJustifyH("CENTER");
    AlertText:SetJustifyV("BOTTOM")
    AlertText:SetPoint("BOTTOM", f, "BOTTOM", 0, 16);
    AlertText:SetText(WEEKLY_REWARDS_UNCLAIMED_TITLE);
    AlertText:SetTextColor(0.098, 1.000, 0.098);

    ClaimChestAlert:SetScript("OnEnter", function()
        local tooltip = GameTooltip;
        tooltip:SetOwner(ChestIcon, "ANCHOR_RIGHT");
        tooltip:SetText(GREAT_VAULT_REWARDS, 1, 1, 1);
        tooltip:AddLine(WEEKLY_REWARDS_UNCLAIMED_TEXT, 1, 0.82, 0, true);
        tooltip:Show();
    end);

    ClaimChestAlert:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);

    ClaimChestAlert:SetScript("OnClick", function()
        ShowGreatVaultUI();
    end);

    return f, height
end