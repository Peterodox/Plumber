local _, addon = ...
local L = addon.L;
local API = addon.API;
local InCombatLockdown = InCombatLockdown;
local CreateFrame = CreateFrame;
local GetCurrentDelvesSeasonNumber = C_DelvesUI.GetCurrentDelvesSeasonNumber;
--local IsDelveInProgress = C_PartyInfo.IsDelveInProgress;
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
        API.DisplayDelvesGreatVaultTooltip(self, tooltip, self.index, self.level, self.id, self.progressDelta)
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

        tooltip:Show();
    end

    function GreatVaultItemButtonMixin:AppendOpenGVInstruction(tooltip)
        if InCombatLockdown() then return end;
        GameTooltip_AddBlankLineToTooltip(tooltip);
        GameTooltip_AddColoredLine(tooltip, string.format("<%s>", WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS), GREEN_FONT_COLOR);
    end

    function GreatVaultItemButtonMixin:OnEnter()
        GreatVaultFrame:HighlightButton(self);
        self:ShowPreviewItemTooltip();
        API.AddRecentDelvesRecordsToTooltip(GameTooltip, self.threshold);
        --self:AppendOpenGVInstruction(GameTooltip);
        GameTooltip:Show();
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


local CrestProgressBarMixin = {};
do  --Gilded Stash: 3 per week, 7 Gilded Crests each
    local CREST_SPELL = 1216211;

    local WidgetIDs = {
        --Search in UiWidget https://wago.tools/db2/UiWidget?filter%5BWidgetTag%5D=delveDifficultyScaling&filter%5BOrderIndex%5D=6&page=1&sort%5BWidgetTag%5D=asc
        --WidgetTag = delveDifficultyScaling, OrderIndex = 6
        6659,
        6718,
        6719,
        6720,
        6721,
        6722,
        6723,
        6724,
        6725,
        6726,
        6727,
        6728,
        6729,
        6794,
        7193,
    };

    local KeyWidgets = {};
    for _, widgetID in ipairs(WidgetIDs) do
        KeyWidgets[widgetID] = true;
    end

    local Getter = C_UIWidgetManager.GetSpellDisplayVisualizationInfo;

    local function GetCrestStashTooltip()
        --This widget info is only available in Khaz Algar, outside Delves
        local info;
        for _, widgetID in ipairs(WidgetIDs) do
            info = Getter(widgetID);
            if info then
                if info.spellInfo and info.spellInfo.spellID == CREST_SPELL and info.spellInfo.shownState == 1 then
                    --print(widgetID, info.shownState, info.enabledState, info.spellInfo.shownState)
                    return info.spellInfo.tooltip
                end
            end
        end
    end

    local function GetCrestStashProgess()
        local sourceText = GetCrestStashTooltip();
        if sourceText then
            local current, max = string.match(sourceText, "(%d+)/(%d+)");
            if current and max then
                current = tonumber(current);
                max = tonumber(max);
                if max > 0 then
                    return current, max
                end
            end
        end
    end


    function CrestProgressBarMixin:OnLoad()
        local title = C_Spell.GetSpellName(CREST_SPELL);
        if not title then
            C_Timer.After(0.25, function()
                title = C_Spell.GetSpellName(CREST_SPELL);
                self.Title:SetText(title);
            end);
        end
        self.Title:SetText(title);
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);
        self:SetScript("OnEvent", self.OnEvent);
        if self:IsVisible() then
            self:OnShow();
        end
    end

    function CrestProgressBarMixin:OnShow()
        self:RegisterEvent("UPDATE_UI_WIDGET");
        self:RegisterEvent("ACTIVE_DELVE_DATA_UPDATE");
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    end

    function CrestProgressBarMixin:OnHide()
        self:UnregisterEvent("UPDATE_UI_WIDGET");
        self:UnregisterEvent("ACTIVE_DELVE_DATA_UPDATE");
        self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
    end

    function CrestProgressBarMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            self:Update();
        end
    end

    function CrestProgressBarMixin:RequestUpdate()
        self.t = -0.5;
        self:SetScript("OnUpdate", self.OnUpdate);
    end


    function CrestProgressBarMixin:OnEvent(event, ...)
        if event == "UPDATE_UI_WIDGET" then
            local widgetInfo = ...
            if widgetInfo.widgetID and KeyWidgets[widgetInfo.widgetID] then
                self:RequestUpdate();
            end
        elseif event == "ACTIVE_DELVE_DATA_UPDATE" or event == "ZONE_CHANGED_NEW_AREA" then
            self:RequestUpdate();
        end
    end

    function CrestProgressBarMixin:OnEnter()
        local tooltipText = GetCrestStashTooltip();
        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        local title = C_Spell.GetSpellName(CREST_SPELL);
        tooltip:SetText(title, 1, 1, 1);
        if tooltipText then
            tooltipText = string.gsub(tooltipText, title.."%c+", "");

            tooltip:AddLine(L["Delve Crest Stash Requirement"], 1, 0.82, 0, true);
            tooltip:AddLine(" ");
            tooltip:AddLine(tooltipText, 1, 0.82, 0, true);
            --tooltip:SetSpellByID(CREST_SPELL);    --wrong progress number

            local info = C_CurrencyInfo.GetCurrencyInfo(addon.ItemUpgradeConstant.DelveWeeklyStashCurrencyID);
            if info then    --Add total and season max
                tooltip:AddLine(" ");
                local r, g, b = C_Item.GetItemQualityColor(info.quality);
                tooltip:AddLine(info.name, r, g, b, true);
                tooltip:AddLine(L["Total Colon"].." |cffffffff"..(info.quantity or 0).."|r", 1, 0.82, 0);
                local maxQuantity = info.useTotalEarnedForMaxQty and info.maxQuantity or 0;
                if maxQuantity > 0 then
                    local totalEarned = info.totalEarned or 0;
                    local quantityText = ("|cffffd100"..L["Season Maximum Colon"].."|r ")..(totalEarned.."/"..maxQuantity);
                    if totalEarned >= maxQuantity then
                        tooltip:AddLine(quantityText, 1, 0.282, 0, true);
                    else
                        tooltip:AddLine(quantityText, 1, 1, 1, true);
                    end
                end
            end
        else
            tooltip:AddLine(L["Delve Crest Stash No Info"], 1, 0.1, 0.1, true);
        end
        tooltip:Show();
    end

    function CrestProgressBarMixin:OnLeave()
        GameTooltip:Hide();
    end

    function CrestProgressBarMixin:Update()
        local current, max = GetCrestStashProgess();

        if current then
            self.Title:SetTextColor(1, 1, 1);
            self.Texture:SetDesaturated(false);
            self.Texture:SetVertexColor(1, 1, 1);
        else
            self.Title:SetTextColor(0.5, 0.5, 0.5);
            self.Texture:SetDesaturated(true);
            self.Texture:SetVertexColor(0.8, 0.8, 0.8);
            if self.initialzed then
               return
            end
        end

        if current == 1 then
            self.Texture:SetTexCoord(0, 224/512, 224/512, 256/512);
        elseif current == 2 then
            self.Texture:SetTexCoord(0, 224/512, 256/512, 288/512);
        elseif current == 3 then
            self.Texture:SetTexCoord(0, 224/512, 288/512, 320/512);
        else
            self.Texture:SetTexCoord(0, 224/512, 192/512, 224/512);
        end

        self.initialzed = true;
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

        self.hiddenBlizzardFrames = {};

        if parent.GreatVaultButton then
            parent.GreatVaultButton:Hide();
            table.insert(self.hiddenBlizzardFrames, parent.GreatVaultButton);
        end

        if parent.PanelDescription then
            parent.PanelDescription:Hide();
            table.insert(self.hiddenBlizzardFrames, parent.PanelDescription);
        end

        if parent.PanelTitle then
            parent.PanelTitle:Hide();
            table.insert(self.hiddenBlizzardFrames, parent.PanelTitle);
        end

        local NewPanelTitle = self:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
        if AutoScalingFontStringMixin then
            API.Mixin(NewPanelTitle, AutoScalingFontStringMixin);
            NewPanelTitle:SetWidth(ITEMBUTTON_WIDTH);
            NewPanelTitle.minLineHeight = 10;
            NewPanelTitle:SetMaxLines(1);
        end
        NewPanelTitle:SetHeight(32);
        NewPanelTitle:SetPoint("TOP", self, "TOP", 0, 0);
        NewPanelTitle:SetText(PVP_WEEKLY_REWARD);

        self.Items = {};

        local ButtonContainer = CreateFrame("Frame", nil, self);
        self.ButtonContainer = ButtonContainer;
        ButtonContainer:SetAllPoints(true);

        local buttonWidth = ITEMBUTTON_WIDTH;
        local buttonHeight = ITEMBUTTON_HEIGHT;
        local gap = 6;
        local numButtons = 3;
        local fromOffsetY = -34;
        local button;

        for i = 1, numButtons do
            button = CreateGreatVaultItemButton(ButtonContainer);
            self.Items[i] = button;
            button.index = i;
            button:SetSize(buttonWidth, buttonHeight);
            button:SetPoint("TOP", self, "TOP", 0, fromOffsetY + (buttonHeight + gap) * (1 - i));
        end


        local CrestProgressBar = CreateFrame("Frame", nil, ButtonContainer);
        self.CrestProgressBar = CrestProgressBar;
        local barWidth = 174;
        CrestProgressBar:SetSize(barWidth, barWidth * 32/244);
        CrestProgressBar.Texture = CrestProgressBar:CreateTexture(nil, "ARTWORK");
        CrestProgressBar.Texture:SetAllPoints(true);
        CrestProgressBar.Texture:SetTexture("Interface/AddOns/Plumber/Art/Delves/DelvesDashboard.png");
        API.Mixin(CrestProgressBar, CrestProgressBarMixin);
        CrestProgressBar:SetPoint("BOTTOM", self, "BOTTOM", 0, 2);
        CrestProgressBar.Title = CrestProgressBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
        CrestProgressBar.Title:SetPoint("BOTTOM", CrestProgressBar, "TOP", 0, 4);
        CrestProgressBar.Title:SetJustifyH("CENTER");
        CrestProgressBar:OnLoad();


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

        self:SetSize(buttonWidth, (buttonHeight + gap) * numButtons - gap + 98);

        self:ClearAllPoints();
        self:SetParent(parent);
        self:SetPoint("TOP", parent, "TOP", 0, -29);

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
            --[[
            itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(activityInfo.id);
            itemLevel, upgradeItemLevel = nil, nil;

            if itemLink then
                itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink);
            end

            if upgradeItemLink then
                upgradeItemLevel = C_Item.GetDetailedItemLevelInfo(upgradeItemLink);
            end
            --]]

            tier = activityInfo.level;
            itemLevel = API.GetDelvesGreatVaultItemLevel(activityInfo.level);
            progressDelta = activityInfo.threshold - activityInfo.progress;

            frame = self.Items[i];
            if frame then
                frame.activityTierID = activityInfo.activityTierID;
                frame.level = activityInfo.level;
                frame.id = activityInfo.id;
                frame.index = activityInfo.index;
                frame.threshold = activityInfo.threshold;

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

        self.CrestProgressBar:Update();

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
        if state then
            if not Module.isEnabled then
                Module.isEnabled = true;
                Module:HookPVEFrame();
                if not GreatVaultFrame.Init then
                    GreatVaultFrame:Show();
                    if GreatVaultFrame.hiddenBlizzardFrames then
                        for _, obj in ipairs(GreatVaultFrame.hiddenBlizzardFrames) do
                            obj:Hide();
                        end
                    end
                else
                    local panel = DelvesDashboardFrame;
                    if panel and panel:IsShown() then
                        GreatVaultFrame:Init();
                    end
                end
            end
        else
            if Module.isEnabled then
                Module.isEnabled = false;
                GreatVaultFrame:Hide();
                if GreatVaultFrame.hiddenBlizzardFrames then
                    for _, obj in ipairs(GreatVaultFrame.hiddenBlizzardFrames) do
                        obj:Show();
                    end
                end
            end
        end
    end
end




do
    local moduleData = {
        name = addon.L["ModuleName Delves_Dashboard"],
        dbKey = "Delves_Dashboard",
        description = addon.L["ModuleDescription Delves_Dashboard"],
        toggleFunc = Module.EnableModule,
        categoryID = 1,
        uiOrder = 1104,
        moduleAddedTime = 1724100000,
    };

    addon.ControlCenter:AddModule(moduleData);
end