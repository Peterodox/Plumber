local _, addon = ...
local L = addon.L;
local API = addon.API;
local InCombatLockdown = InCombatLockdown;
local CreateFrame = CreateFrame;
local GetCurrentDelvesSeasonNumber = C_DelvesUI.GetCurrentDelvesSeasonNumber;
local IsPlayerAtMaxLevel = API.IsPlayerAtMaxLevel;

local ITEMBUTTON_WIDTH, ITEMBUTTON_HEIGHT = 156, 40;

local GreatVaultFrame = CreateFrame("Frame", nil);


local function HasActiveSeason()
    local season = GetCurrentDelvesSeasonNumber();
    return season and season > 0
end


local GreatVaultItemButtonMixin = {};
do
    function GreatVaultItemButtonMixin:SetVisualLocked()
        if not self.unlocked then return end;
        self.unlocked = false;

        self.Left:SetTexCoord(0, 24/512, 0.125, 0.25);
        self.Center:SetTexCoord(24/512, 134/512, 0.125, 0.25);
        self.Right:SetTexCoord(134/512, 224/512, 0.125, 0.25);

        API.SetTextColorByGlobal(self.Text1, DISABLED_FONT_COLOR);
        API.SetTextColorByGlobal(self.Text2, DISABLED_FONT_COLOR);

        self.Text1:ClearAllPoints();
        self.Text1:SetPoint("LEFT", self, "LEFT", 12, 0);
        self.Text2:SetText("");
    end

    function GreatVaultItemButtonMixin:SetVisualUnlocked()
        if self.unlocked then return end;
        self.unlocked = true;

        self.Left:SetTexCoord(0, 24/512, 0, 0.125);
        self.Center:SetTexCoord(24/512, 134/512, 0, 0.125);
        self.Right:SetTexCoord(134/512, 224/512, 0, 0.125);

        API.SetTextColorByGlobal(self.Text1, NORMAL_FONT_COLOR);
        API.SetTextColorByGlobal(self.Text2, GREEN_FONT_COLOR);

        self.Text1:ClearAllPoints();
        self.Text1:SetPoint("BOTTOMLEFT", self, "LEFT", 12, 1);
    end

    function GreatVaultItemButtonMixin:ShowPreviewItemTooltip()
        local tooltip = GameTooltip;

        tooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
        GameTooltip_SetTitle(tooltip, WEEKLY_REWARDS_CURRENT_REWARD);

        local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(self.id);
        local itemLevel, upgradeItemLevel;

        if itemLink then
            itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink);
        end
        if upgradeItemLink then
            upgradeItemLevel = C_Item.GetDetailedItemLevelInfo(upgradeItemLink);
        end

        if not itemLevel then
            GameTooltip_AddErrorLine(tooltip, RETRIEVING_ITEM_INFO);
            self.UpdateTooltip = self.ShowPreviewItemTooltip;
        else
            self.UpdateTooltip = nil;

            local hasData, nextActivityTierID, nextLevel, nextItemLevel = C_WeeklyRewards.GetNextActivitiesIncrease(self.activityTierID, self.level);
            if hasData then
                upgradeItemLevel = nextItemLevel;
            else
                nextLevel = self.level + 1;
            end

            GameTooltip_AddNormalLine(tooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_WORLD, itemLevel, self.level));

            GameTooltip_AddBlankLineToTooltip(tooltip);
            if upgradeItemLevel then
                GameTooltip_AddColoredLine(tooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
                GameTooltip_AddHighlightLine(tooltip, string.format(WEEKLY_REWARDS_COMPLETE_WORLD, nextLevel));
            else
                GameTooltip_AddColoredLine(tooltip, WEEKLY_REWARDS_MAXED_REWARD, GREEN_FONT_COLOR);
            end
        end

        self:AppendOpenGVInstruction(tooltip);

        tooltip:Show();
    end

    function GreatVaultItemButtonMixin:ShowIncompleteTooltip()
        local tooltip = GameTooltip;

        tooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
        GameTooltip_SetTitle(tooltip, WEEKLY_REWARDS_UNLOCK_REWARD);

        local description;
        if self.index == 2 then
            description = GREAT_VAULT_REWARDS_WORLD_COMPLETED_FIRST;
        elseif self.index == 3 then
            description = GREAT_VAULT_REWARDS_WORLD_COMPLETED_SECOND;
        else
            description = GREAT_VAULT_REWARDS_WORLD_INCOMPLETE;
        end

        local formatRemainingProgress = true;

        if formatRemainingProgress then
            GameTooltip_AddNormalLine(tooltip, description:format(self.progressDelta));
        else
            GameTooltip_AddNormalLine(tooltip, description);
        end

        self:AppendOpenGVInstruction(tooltip);

        tooltip:Show();
    end

    function GreatVaultItemButtonMixin:AppendOpenGVInstruction(tooltip)
        if InCombatLockdown() then return end;
        GameTooltip_AddBlankLineToTooltip(tooltip);
        GameTooltip_AddColoredLine(tooltip, string.format("<%s>", WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS), GREEN_FONT_COLOR);
    end

    function GreatVaultItemButtonMixin:OnEnter()
        if self.unlocked then
            self:ShowPreviewItemTooltip();
        else
            self:ShowIncompleteTooltip();
        end
        GreatVaultFrame:HighlightButton(self);
    end

    function GreatVaultItemButtonMixin:OnLeave()
        GameTooltip:Hide();
        GreatVaultFrame:HighlightButton(nil);
    end

    function GreatVaultItemButtonMixin:OnClick()
        if not InCombatLockdown() then
            WeeklyRewards_ShowUI();
        end
    end
end

local function CreateThreeSliceBackground(f)
    local a = 0.8;  --scale

    f.Left = f:CreateTexture(nil, "BACKGROUND");
    f.Left:SetSize(24*a, 64*a);
    f.Left:SetPoint("LEFT", f, "LEFT", -10*a, 4*a);

    f.Right = f:CreateTexture(nil, "BACKGROUND");
    f.Right:SetSize(90*a, 64*a);
    f.Right:SetPoint("RIGHT", f, "RIGHT", 10*a, 4*a);

    f.Center = f:CreateTexture(nil, "BACKGROUND");
    f.Center:SetPoint("TOPLEFT", f.Left, "TOPRIGHT", 0, 0);
    f.Center:SetPoint("BOTTOMRIGHT", f.Right, "BOTTOMLEFT", 0, 0);

    local textureFile = "Interface/AddOns/Plumber/Art/Delves/DelvesDashboard.png";
    f.Left:SetTexture(textureFile);
    f.Center:SetTexture(textureFile);
    f.Right:SetTexture(textureFile);
end

local function CreateGreatVaultItemButton(parent)
    local f = CreateFrame("Button", nil, parent);
    API.Mixin(f, GreatVaultItemButtonMixin);
    f:SetSize(ITEMBUTTON_WIDTH, ITEMBUTTON_HEIGHT);

    CreateThreeSliceBackground(f);

    f.Text1 = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    f.Text1:SetJustifyH("LEFT");
    f.Text1:SetJustifyV("TOP");
    f.Text1:SetPoint("BOTTOMLEFT", f, "LEFT", 12, 1);

    f.Text2 = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    f.Text2:SetJustifyH("LEFT");
    f.Text2:SetJustifyV("BOTTOM");
    f.Text2:SetPoint("TOPLEFT", f, "LEFT", 12, -1);

    f.Text1:SetText("Tier 8");
    f.Text2:SetText("2/3");

    f:SetVisualUnlocked();

    f:SetScript("OnEnter", f.OnEnter);
    f:SetScript("OnLeave", f.OnLeave);
    f:SetScript("OnClick", f.OnClick);

    return f
end

--[[
    DelvesDashboardFrame.ButtonPanelLayoutFrame.GreatVaultButtonPanel.GreatVaultButton
--]]


do
    function GreatVaultFrame:Init()
        self.Init = nil;

        local parent = API.GetGlobalObject("DelvesDashboardFrame.ButtonPanelLayoutFrame.GreatVaultButtonPanel");
        if not parent then
            print("Plumber: Delves Dashboard couldn't find GreatVaultButtonPanel");
            return
        end

        if parent.GreatVaultButton then
            parent.GreatVaultButton:Hide();
            self.BlizzardGreatVaultButton = parent.GreatVaultButton;
        end

        self.Items = {};

        local ButtonContainer = CreateFrame("Frame", nil, self);
        self.ButtonContainer = ButtonContainer;
        ButtonContainer:SetAllPoints(true);

        local buttonWidth = ITEMBUTTON_WIDTH;
        local buttonHeight = ITEMBUTTON_HEIGHT;
        local gap = 6;
        local numButtons = 3;

        local button;

        for i = 1, numButtons do
            button = CreateGreatVaultItemButton(ButtonContainer);
            self.Items[i] = button;
            button:SetSize(buttonWidth, buttonHeight);
            button:SetPoint("TOP", self, "TOP", 0, (buttonHeight + gap) * (1 - i));
        end

        local errorOffset = 16;

        local ErrorTexture = self:CreateTexture(nil, "BACKGROUND");
        self.ErrorTexture = ErrorTexture;
        ErrorTexture:SetSize(buttonWidth, buttonWidth);
        ErrorTexture:SetPoint("CENTER", self, "CENTER", 0, errorOffset);
        ErrorTexture:SetTexture("Interface/AddOns/Plumber/Art/Delves/DelvesDashboard.png");
        ErrorTexture:SetTexCoord(0.5, 448/512, 0, 192/512);

        local ErrorText = self:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        self.ErrorText = ErrorText;
        ErrorText:SetPoint("CENTER", self, "CENTER", 0, errorOffset);
        ErrorText:SetWidth(buttonWidth - 16);
        ErrorText:SetJustifyH("CENTER");
        ErrorText:SetJustifyV("MIDDLE");
        ErrorText:SetTextColor(0.6, 0.6, 0.6);
        ErrorText:SetSpacing(2);

        self:SetSize(buttonWidth, (buttonHeight + gap) * numButtons - gap);

        self:ClearAllPoints();
        self:SetParent(parent);
        self:SetPoint("BOTTOM", parent, "BOTTOM", 0, 30);

        self:Update();

        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);

        self:ListenEvents(true);
    end

    function GreatVaultFrame:HighlightButton(itemButton)
        if itemButton then
            if not self.ButtonHighlight then
                local f = CreateFrame("Frame", nil, self);
                self.ButtonHighlight = f;
                f:SetSize(ITEMBUTTON_WIDTH, ITEMBUTTON_HEIGHT);
                CreateThreeSliceBackground(f);
                f.Left:SetTexCoord(0, 24/512, 0.25, 0.375);
                f.Center:SetTexCoord(24/512, 134/512, 0.25, 0.375);
                f.Right:SetTexCoord(134/512, 224/512, 0.25, 0.375);
                f.Left:SetBlendMode("ADD");
                f.Center:SetBlendMode("ADD");
                f.Right:SetBlendMode("ADD");
                f:SetAlpha(0.2);
            end
            self.ButtonHighlight:ClearAllPoints();
            self.ButtonHighlight:SetParent(itemButton);
            self.ButtonHighlight:SetPoint("CENTER", itemButton, "CENTER", 0, 0);
            self.ButtonHighlight:Show();
        else
            if self.ButtonHighlight then
                self.ButtonHighlight:Hide();
            end
        end
    end

    local function SortFunc_Index(a, b)
        return a.index < b.index
    end

    function GreatVaultFrame:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t >= 0.2 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            self:Update();
        end
    end

    function GreatVaultFrame:UpdateValidity()
        if not self.isPlayerAtMaxLevel then
            self.isPlayerAtMaxLevel = IsPlayerAtMaxLevel();
        end

        if not self.hasActiveSeason then
            self.hasActiveSeason = HasActiveSeason();
        end

        local error;

        if not self.isPlayerAtMaxLevel then
            local maxLevel = API.GetPlayerMaxLevel();
            error = string.format(DELVES_GREAT_VAULT_ERR_AVAIL_AT_MAX_LEVEL, maxLevel);
        elseif not self.hasActiveSeason then
            error = DELVES_GREAT_VAULT_REQUIRES_ACTIVE_SEASON;
        end

        if error then
            self.ErrorText:Show();
            self.ErrorText:SetText(error);
            self.ErrorTexture:Show();
            self.ButtonContainer:Hide();
            return false
        else
            self.ErrorText:Hide();
            self.ErrorTexture:Hide();
            self.ButtonContainer:Show();
            return true
        end
    end

    function GreatVaultFrame:Update()
        if not self:UpdateValidity() then return end;

        local activities = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World);
        if not activities then return end;

        table.sort(activities, SortFunc_Index);

        local itemLink, upgradeItemLink;
        local itemLevel, upgradeItemLevel;
        local tier;
        local frame, unlocked, progressDelta;
        local requery = false;

        for i, activityInfo in ipairs(activities) do
            itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(activityInfo.id);
            itemLevel, upgradeItemLevel = nil, nil;

            if itemLink then
                itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink);
            end

            if upgradeItemLink then
                upgradeItemLevel = C_Item.GetDetailedItemLevelInfo(upgradeItemLink);
            end

            tier = activityInfo.level;
            progressDelta = activityInfo.threshold - activityInfo.progress;

            frame = self.Items[i];
            if frame then
                frame.activityTierID = activityInfo.activityTierID;
                frame.level = activityInfo.level;
                frame.id = activityInfo.id;
                frame.index = activityInfo.index;

                if progressDelta <= 0 then
                    frame:SetVisualUnlocked();
                    if itemLevel then
                        frame.Text1:SetText(L["Item Level Abbr"].." "..itemLevel);
                    else
                        requery = true;
                        frame.Text1:SetText(L["Item Level Abbr"]);
                    end
                    frame.Text2:SetText(L["Great Vault Tier Format"]:format(tier));
                    frame.progressDelta = 0;
                else
                    frame:SetVisualLocked();
                    frame.Text1:SetText(activityInfo.progress.."/"..activityInfo.threshold);
                    frame.progressDelta = progressDelta;
                end
            end
            --print(activityInfo.progress, "/", activityInfo.threshold, tier, itemLevel, upgradeItemLevel)
        end

        if requery then
            self.t = 0;
            self:SetScript("OnUpdate", self.OnUpdate);
        end
    end

    function GreatVaultFrame:ListenEvents(state)
        if state then
            self:RegisterEvent("CHALLENGE_MODE_COMPLETED");
            self:RegisterEvent("WEEKLY_REWARDS_UPDATE");
        else
            self:UnregisterEvent("CHALLENGE_MODE_COMPLETED");
            self:UnregisterEvent("WEEKLY_REWARDS_UPDATE");
        end
    end

    function GreatVaultFrame:OnShow()
        self:Update();
        self:ListenEvents(true);
    end

    function GreatVaultFrame:OnHide()
        self:ListenEvents(false);
    end
end


local Module = {};
do
    function Module:HookPVEFrame()
        if self.hookedPVEFrame then return end;

        self.hookedPVEFrame = true;
        hooksecurefunc("PVEFrame_ShowFrame", function(sidePanelName, selection)
            if self.isEnabled and (not self.blizzardDashboardLoaded) and sidePanelName == "DelvesDashboardFrame" then
                self.blizzardDashboardLoaded = true;
                C_Timer.After(0, function()
                    GreatVaultFrame:Init();
                end);
            end
        end)
    end

    function Module.EnableModule(state)
        Module.isEnabled = state;

        if state then
            Module:HookPVEFrame();
            if not GreatVaultFrame.Init then
                GreatVaultFrame:Show();
                if GreatVaultFrame.BlizzardGreatVaultButton then
                    GreatVaultFrame.BlizzardGreatVaultButton:Hide();
                end
            end
        else
            GreatVaultFrame:Hide();
            if GreatVaultFrame.BlizzardGreatVaultButton then
                GreatVaultFrame.BlizzardGreatVaultButton:Show();
            end
        end
    end
end

Module.EnableModule(true);  --debug