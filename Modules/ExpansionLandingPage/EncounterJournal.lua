local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;
local GetEncounterProgress = LandingPageUtil.GetEncounterProgress;


local ipairs = ipairs;
local tinsert = table.insert;
local EJ_GetInstanceInfo = EJ_GetInstanceInfo;
local EJ_GetEncounterInfoByIndex = EJ_GetEncounterInfoByIndex;


local JournalInstanceIDs = {
    1296,   --Liberation of Undermine
    1273,   --Nerub-ar Palace
    --1190,   --Debug Castle Nathria
};

if addon.IsToCVersionEqualOrNewerThan(110200) then
    tinsert(JournalInstanceIDs, 1, 1302);   --Manaforge Omega   --debug
end

if addon.IS_MOP then
    JournalInstanceIDs = {
        317,    --Mogu'shan Vaults
        330,    --Heart of Fear
        320,    --Terrace of Endless Spring
    };
end


local RaidTab, LootContainer;
local EncounterList = {};



local function GetPlayerClassName(playerClassID, markYourClass)
    if playerClassID == 0 then
        return ALL_CLASSES
    end

   local info = C_CreatureInfo.GetClassInfo(playerClassID);
   local name = info and info.className or "";

    if markYourClass and playerClassID == LandingPageUtil.GetDefaultPlayerClassID() then
        name = name .."  "..L["Your Class"];
    end

   return name
end


local function IsRaidCollapsed(mapID)
    return addon.GetDBBool("LandingPage_Raid_CollapsedRaid_"..mapID)
end

local function SetRaidCollapsed(mapID, isCollapsed)
    return addon.SetDBValue("LandingPage_Raid_CollapsedRaid_"..mapID, isCollapsed, true)
end


local CreateListButton;
do
    local ListButtonMixin = {};

    function ListButtonMixin:OnEnter()
        self:UpdateVisual();
    end

    function ListButtonMixin:OnLeave()
        self:UpdateVisual();
    end

    function ListButtonMixin:OnClick(button)
        if self.isHeader then
            local isCollapsed = self:ToggleCollapsed();
            if isCollapsed then
                LandingPageUtil.PlayUISound("CheckboxOff");
            else
                LandingPageUtil.PlayUISound("CheckboxOn");
            end
        else
            RaidTab:SelectEncounterByDataIndex(self.dataIndex);
            RaidTab.AchievementContainer:SetAchievements(LandingPageUtil.GetEncounterAchievements(self.journalEncounterID));
            RaidTab.LootContainer:ShowLoot(self.journalInstanceID, self.journalEncounterID);
            LandingPageUtil.PlayUISound("CheckboxOn");
        end
    end

    function ListButtonMixin:ToggleCollapsed()
        if self.dataIndex and EncounterList[self.dataIndex] then
            local isCollapsed = not EncounterList[self.dataIndex].isCollapsed;
            EncounterList[self.dataIndex].isCollapsed = isCollapsed;
            SetRaidCollapsed(EncounterList[self.dataIndex].mapID, isCollapsed);
            RaidTab:RefreshList();
            return isCollapsed
        end
    end

    function ListButtonMixin:SetInstance(mapID, journalInstanceID, name)
        self.mapID = mapID;
        self.journalInstanceID = journalInstanceID;
        self:SetHeader();
        self.Name:SetText(name);
        self:HideProgress();
    end

    function ListButtonMixin:SetEncounter(mapID, journalInstanceID, journalEncounterID, dungeonEncounterID, name)
        self.mapID = mapID;
        self.journalInstanceID = journalInstanceID;
        self.journalEncounterID = journalEncounterID;
        self.dungeonEncounterID = dungeonEncounterID;
        self:SetEntry();

        self.Icon:Hide();
        self.Name:SetText(name);
        self:Layout();

        self:UpdateProgress();
    end

    function ListButtonMixin:HideProgress()
        self.Light1:Hide();
        self.Light2:Hide();
        self.Light3:Hide();
        self.Light4:Hide();
        self.Light5:Hide();
    end

    function ListButtonMixin:UpdateProgress()
        self:HideProgress();
        if (not self.isHeader) and self.mapID and self.dungeonEncounterID then
            local progress = GetEncounterProgress(self.mapID, self.dungeonEncounterID);
            local texture;
            for i, completed in ipairs(progress) do
                texture = self["Light"..i];
                if texture then
                    texture:Show();
                    texture:SetTexture(nil);
                    local filter;
                    if completed then
                        texture:SetTexCoord(48/512, 96/512, 208/512, 256/512);
                        filter = "LINEAR";
                    else
                        texture:SetTexCoord(96/512, 144/512, 208/512, 256/512);
                        filter = "TRILINEAR";
                    end
                    texture:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/ChecklistButton.tga", nil, nil, filter);
                end
            end
        end
    end

    function ListButtonMixin:UpdateSelection()
        self.selected = EncounterList[self.dataIndex] and EncounterList[self.dataIndex].selected;
        self:UpdateVisual();
    end


    function CreateListButton(parent)
        local f = LandingPageUtil.CreateSharedListButton(parent);
        API.Mixin(f, ListButtonMixin);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);

        for i = 1, 5 do
            local texture = f:CreateTexture(nil, "OVERLAY");
            f["Light"..i] = texture;
            texture:SetSize(24, 24);
            texture:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/ChecklistButton.tga", nil, nil, "TRILINEAR");
            texture:SetTexCoord(96/512, 144/512, 208/512, 256/512);
            texture:SetPoint("LEFT", f, "RIGHT", -184 + (i - 1) * 24, 0);
            texture:Hide();
        end

        return f
    end
end


local CreateAchievementContainer;
do
    local BUTTON_SIZE = 40;

    local AchievementButtonMixin = {};

    function AchievementButtonMixin:OnEnter()
        self:ShowAchievementTooltip();
    end

    function AchievementButtonMixin:OnLeave()
        GameTooltip:Hide();
    end

    function AchievementButtonMixin:OnClick(button)
		if ( IsModifiedClick("CHATLINK") ) then
			local achievementLink = GetAchievementLink(self.achievementID);
			if achievementLink then
				local handled = ChatEdit_InsertLink(achievementLink);
				if ( not handled and SocialPostFrame and Social_IsShown() ) then
                    handled = true;
					Social_InsertLink(achievementLink);
				end

                if handled then
                    return
                end
			end
		end

        if IsModifiedClick("QUESTWATCHTOGGLE") then
            if self:ToggleTracking() then
                LandingPageUtil.PlayUISound("CheckboxOn");
            else
                LandingPageUtil.PlayUISound("CheckboxOff");
            end
        end
    end

    function AchievementButtonMixin:SetAchievement(achievementID)
        self.achievementID = achievementID;

        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe = GetAchievementInfo(achievementID);
        self.Icon:SetTexture(icon);
        self.completed = completed;

        if completed then
            self.Icon:SetVertexColor(1, 1, 1);
            self.Icon:SetDesaturation(0);
            self.Border:SetTexCoord(0/512, 96/512, 256/512, 352/512);
        else
            self.Icon:SetVertexColor(0.8, 0.8, 0.8);
            self.Icon:SetDesaturation(1);
            self.Border:SetTexCoord(96/512, 192/512, 256/512, 352/512);
        end
    end

    function AchievementButtonMixin:ShowAchievementTooltip()
        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        --tooltip:SetAchievementByID(self.achievementID);

        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe = GetAchievementInfo(self.achievementID);
        tooltip:SetText(name, 1, 0.82, 0, true);

        if completed then
            tooltip:AddLine(ACHIEVEMENTFRAME_FILTER_COMPLETED, 0.098, 1.000, 0.098, true);
        else
            tooltip:AddLine(ACHIEVEMENTFRAME_FILTER_INCOMPLETE, 0.5, 0.5, 0.5, true);
        end

        tooltip:AddLine(" ");
        tooltip:AddLine(description, 1, 1, 1, true);

        if not completed then
            local numCriteria =  GetAchievementNumCriteria(id);
            if numCriteria > 0 then
                tooltip:AddLine(" ");
                local lineText;
                for i = 1, numCriteria do
                    local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(id, i);

                    if criteriaType == 8 and assetID then     --Meta, CRITERIA_TYPE_ACHIEVEMENT
                        _, lineText = GetAchievementInfo(assetID);
                    elseif bit.band(flags, 1) == 1 then     --EVALUATION_TREE_FLAG_PROGRESS_BAR = 1
                        criteriaString = criteriaString or "";
                        lineText = quantity.."/"..reqQuantity.." "..criteriaString;
                    else    --TextStrings
                        lineText = criteriaString;
                    end

                    lineText = "- "..lineText;

                    if completed then
                        tooltip:AddLine(lineText, 0.251, 0.753, 0.251, true);
                    else
                        tooltip:AddLine(lineText, 0.5, 0.5, 0.5, true);
                    end
                end
            end

            tooltip:AddLine(" ");
            if self:IsAchievementTracked() then
                tooltip:AddLine(L["Instruction Untrack Achievement"], 0.098, 1.000, 0.098, true);
            else
                tooltip:AddLine(L["Instruction Track Achievement"], 0.098, 1.000, 0.098, true);
            end
        end

        tooltip:Show();
    end

    if C_ContentTracking then
        --Retail
        function AchievementButtonMixin:IsAchievementTracked()
            local id = self.achievementID;
            local trackType = Enum.ContentTrackingType.Achievement;
            local trackedIDs = C_ContentTracking.GetTrackedIDs(trackType) or {};

            for _, _id in ipairs(trackedIDs) do
                if id == _id then
                    return true
                end
            end

            return false
        end

        function AchievementButtonMixin:ToggleTracking()
            local id = self.achievementID;
            local trackType = Enum.ContentTrackingType.Achievement;

            local trackedIDs = C_ContentTracking.GetTrackedIDs(trackType) or {};

            for _, _id in ipairs(trackedIDs) do
                if id == _id then
                    C_ContentTracking.StopTracking(trackType, id, Enum.ContentTrackingStopType.Manual);
                    return false
                end
            end

            if #trackedIDs >= Constants.ContentTrackingConsts.MaxTrackedAchievements then
                UIErrorsFrame:AddMessage(format(ACHIEVEMENT_WATCH_TOO_MANY, Constants.ContentTrackingConsts.MaxTrackedAchievements), 1.0, 0.1, 0.1, 1.0);
                return
            end

            local _, _, _, completed, _, _, _, _, _, _, _, isGuild, wasEarnedByMe = GetAchievementInfo(id)
            if (completed and isGuild) or wasEarnedByMe then
                UIErrorsFrame:AddMessage(ERR_ACHIEVEMENT_WATCH_COMPLETED, 1.0, 0.1, 0.1, 1.0);
                return
            end

            local trackingError = C_ContentTracking.StartTracking(trackType, id);
            if trackingError then
                ContentTrackingUtil.DisplayTrackingError(trackingError);
            else
                return true
            end
        end
    else
        --Classic
        function AchievementButtonMixin:IsAchievementTracked()
            local id = self.achievementID;
            local trackedIDs = {GetTrackedAchievements()};

            for _, _id in ipairs(trackedIDs) do
                if id == _id then
                    return true
                end
            end

            return false
        end

        function AchievementButtonMixin:ToggleTracking()
            local id = self.achievementID;
            local trackedIDs = {GetTrackedAchievements()}
            local result;

            for _, _id in ipairs(trackedIDs) do
                if id == _id then
                    RemoveTrackedAchievement(id);
                    result = false;
                end
            end

            if result == nil then
                if #trackedIDs >= Constants.ContentTrackingConsts.MaxTrackedAchievements then
                    UIErrorsFrame:AddMessage(format(ACHIEVEMENT_WATCH_TOO_MANY, Constants.ContentTrackingConsts.MaxTrackedAchievements), 1.0, 0.1, 0.1, 1.0);
                    return
                end

                local _, _, _, completed, _, _, _, _, _, _, _, isGuild, wasEarnedByMe = GetAchievementInfo(id)
                if (completed and isGuild) or wasEarnedByMe then
                    UIErrorsFrame:AddMessage(ERR_ACHIEVEMENT_WATCH_COMPLETED, 1.0, 0.1, 0.1, 1.0);
                    return
                end

                AddTrackedAchievement(id);
                result = true;
            end

            if not InCombatLockdown() then
                --This is not event-driven in Classic
                WatchFrame_Update();
            end

            return result
        end
    end




    local AchievementContainerMixin = {};

    function AchievementContainerMixin:SetAchievements(achievements)
        self.achievements = achievements;

        for _, button in ipairs(self.buttons) do
            button:Hide();
            button:ClearAllPoints();
        end

        if achievements then
            self.AlertText:Hide();

            local gap = 8;
            local button;
            local numButtons = #achievements;
            local halfSpan = 0.5 * (numButtons * (BUTTON_SIZE + gap) - gap);

            for i, achievementID in ipairs(achievements) do
                button = self.buttons[i];
                if not button then
                    button = CreateFrame("Button", nil, self);
                    API.Mixin(button, AchievementButtonMixin);
                    self.buttons[i] = button;

                    button:SetScript("OnEnter", button.OnEnter);
                    button:SetScript("OnLeave", button.OnLeave);
                    button:SetScript("OnClick", button.OnClick);

                    button:SetSize(BUTTON_SIZE, BUTTON_SIZE);

                    button.Icon = button:CreateTexture(nil, "ARTWORK");
                    button.Icon:SetPoint("CENTER", button, "CENTER", 0, 0);
                    button.Icon:SetSize(36, 36);
                    button.Icon:SetTexCoord(4/64, 60/64, 4/64, 60/64);

                    button.Border = button:CreateTexture(nil, "OVERLAY");
                    button.Border:SetPoint("CENTER", button, "CENTER", 0, 0);
                    button.Border:SetSize(48, 48);
                    button.Border:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/ChecklistButton.tga");
                    button.Border:SetTexCoord(0/512, 96/512, 256/512, 352/512);

                    button.Highlight = button:CreateTexture(nil, "HIGHLIGHT");
                    button.Highlight:SetPoint("CENTER", button, "CENTER", 0, 0);
                    button.Highlight:SetSize(48, 48);
                    button.Highlight:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/ChecklistButton.tga");
                    button.Highlight:SetTexCoord(96/512, 192/512, 256/512, 352/512);
                    button.Highlight:SetBlendMode("ADD");
                end

                button:SetPoint("LEFT", self, "CENTER", -halfSpan + (i - 1) * (BUTTON_SIZE + gap), 0);
                button:SetAchievement(achievementID);
                button:Show();
            end
        else
            self.AlertText:Show();
        end
    end

    function AchievementContainerMixin:Update()
        self:SetAchievements(self.achievements);
    end

    function AchievementContainerMixin:UpdateTooltip()
        for _, button in ipairs(self.buttons) do
            if button:IsMouseMotionFocus() then
                button:OnEnter();
            end
        end
    end


    function CreateAchievementContainer(parent)
        local f = CreateFrame("Frame", nil, parent);
        API.Mixin(f, AchievementContainerMixin);
        f:SetSize(208, 48);
        f.buttons = {};

        local AlertText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.AlertText = AlertText;
        AlertText:SetWidth(208);
        AlertText:SetPoint("CENTER", f, "CENTER", 0, 0);
        AlertText:SetText(L["No Data"]);
        AlertText:SetTextColor(0.5, 0.5, 0.5);

        return f
    end
end


local CreateLootContainer;
do
    local LootButtonMixin = {};

    function LootButtonMixin:SetItemInfo(itemInfo)
        self.itemID = itemInfo.itemID;
        self.itemLink = itemInfo.link;

        if not (itemInfo.link and itemInfo.name) then
            self.Icon:SetTexture(134400);
            self.Name:SetText(nil);
            self.Border:SetVertexColor(0.5, 0.5, 0.5);
            RaidTab:RequestLootData();
            return
        end

        self.Icon:SetTexture(itemInfo.icon);
        self.Name:SetText(itemInfo.name);

        --local hexColor = itemInfo.itemQuality or "ffffffff";
        local quality = C_Item.GetItemQualityByID(itemInfo.link) or 1;
        local color = ColorManager.GetColorDataForItemQuality(quality);
        local r, g, b = color.r, color.g, color.b;
        self.Name:SetTextColor(r, g, b);
        self.Border:SetVertexColor(r, g, b);

        local slot = itemInfo.slot;
        if itemInfo.handError then
            if slot then
                slot = INVALID_EQUIPMENT_COLOR:WrapTextInColorCode(slot);
            end
		end
        if slot == "" then
            slot = nil;
        end

        local armorType = itemInfo.armorType;
        if itemInfo.weaponTypeError then
            if armorType then
                armorType = INVALID_EQUIPMENT_COLOR:WrapTextInColorCode(armorType);
            end
        end
        if armorType == "" then
            armorType = nil;
        end

        local subtext;
        if slot then
            subtext = slot;
        end
        if armorType then
            if subtext then
                subtext = subtext.."  "..armorType;
            else
                subtext = armorType;
            end
        end

        if not subtext then
            local _, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID = C_Item.GetItemInfoInstant(self.itemID);
            if classID == 15 and subClassID == 0 then
                --Tier Tokens
            else
                subtext = itemSubType;
            end
        end

        self.LeftText:SetText(subtext);
    end

    function LootButtonMixin:OnEnter()
        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        tooltip:SetHyperlink(self.itemLink);
        RaidTab.LootContainer:HighlightButton(self);
    end

    function LootButtonMixin:OnLeave()
        GameTooltip:Hide();
        RaidTab.LootContainer:HighlightButton(nil);
    end

    function LootButtonMixin:OnClick()
        if API.HandleModifiedItemClick(self.itemLink) then
            return
        end
    end

    local function CreateLootButton(parent)
        local f = CreateFrame("Button", nil, parent);
        f:SetSize(208, 32);
        API.Mixin(f, LootButtonMixin);

        f.Border = f:CreateTexture(nil, "OVERLAY");
        f.Border:SetPoint("CENTER", f, "LEFT", 16, 0);
        f.Border:SetSize(40, 40);
        f.Border:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/ChecklistButton.tga");
        f.Border:SetTexCoord(192/512, 272/512, 264/512, 344/512);

        f.Icon = f:CreateTexture(nil, "ARTWORK");
        f.Icon:SetPoint("CENTER", f, "LEFT", 16, 0);
        f.Icon:SetSize(30, 30);
        f.Icon:SetTexCoord(4/64, 60/64, 4/64, 60/64)

        f.Name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Name:SetPoint("TOPLEFT", f, "TOPLEFT", 40, -2);
        f.Name:SetMaxLines(1);
        f.Name:SetWidth(176);
        f.Name:SetTextColor(0.88, 0.88, 0.88);
        f.Name:SetJustifyH("LEFT");

        f.LeftText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
        f.LeftText:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 40, 2);
        f.LeftText:SetMaxLines(1);
        f.LeftText:SetWidth(176);
        f.LeftText:SetTextColor(0.6, 0.6, 0.6);
        f.LeftText:SetJustifyH("LEFT");

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);

        return f
    end



    local LootContainerMixin = {};


    function LootContainerMixin:ShowLoot(journalInstanceID, journalEncounterID)
        self.journalInstanceID = journalInstanceID;
        self.journalEncounterID = journalEncounterID;

        RaidTab.lootDirty = nil;

        for _, button in ipairs(self.buttons) do
            button:Hide();
            button:ClearAllPoints();
        end

        API.SelectInstanceAndEncounter(journalInstanceID, journalEncounterID);

        local difficultyID = self.difficultyID or LandingPageUtil:GetDefaultRaidDifficulty();
        self.difficultyID = difficultyID;
        EJ_SetDifficulty(difficultyID);
        self.DifficultyDropdown:SetText(LandingPageUtil.GetDifficultyName(difficultyID));

        local playerClassID = self.playerClassID or LandingPageUtil:GetDefaultPlayerClassID();
        self.playerClassID = playerClassID;
        EJ_SetLootFilter(playerClassID, 0);
        self.ClassDropdown:SetText(GetPlayerClassName(playerClassID));

        C_EncounterJournal.SetSlotFilter(Enum.ItemSlotFilterType.NoFilter);


        local numLoots = EJ_GetNumLoot();

        if numLoots > 0 then
            self.DifficultyDropdown:Show();
            self.ClassDropdown:Show();
            self.AlertText:Hide();

            local items = {};
            local veryRareLoot = {};
            local extremelyRareLoot = {};
            local perPlayerLoot = {};

            for i = 1, numLoots do
                local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i);
                if itemInfo then
                    if not (itemInfo.link and itemInfo.name) then
                        self.ScrollView:Hide();
                        RaidTab:RequestLootData();
                        return
                    end
                    itemInfo.uiOrder = i;
                    if itemInfo.displayAsPerPlayerLoot then
                        tinsert(perPlayerLoot, itemInfo);
                    elseif itemInfo.displayAsExtremelyRare then
                        tinsert(extremelyRareLoot, itemInfo);
                    elseif itemInfo.displayAsVeryRare then
                        tinsert(veryRareLoot, itemInfo);
                    else
                        tinsert(items, itemInfo);
                    end
                end
            end

            local function TryInsertItems(headerTitle, tbl)
                if #tbl > 0 then
                    tinsert(items, {
                        isHeader = true,
                        text = headerTitle,
                    });

                    for _, itemInfo in ipairs(tbl) do
                        tinsert(items, itemInfo);
                    end
                end
            end

            TryInsertItems(EJ_ITEM_CATEGORY_VERY_RARE, veryRareLoot);
            TryInsertItems(EJ_ITEM_CATEGORY_EXTREMELY_RARE, extremelyRareLoot);
            TryInsertItems(BONUS_LOOT_TOOLTIP_TITLE, perPlayerLoot);

            local n = 0;
            local content = {};
            local offsetY = 4;
            local buttonHeight = 32;
            local gap = 8;
            local top, bottom;
            local objectHeight;

            for k, itemInfo in ipairs(items) do
                n = n + 1;
                top = offsetY;
                if itemInfo.isHeader then
                    objectHeight = 16;
                    bottom = offsetY + objectHeight + gap;
                    content[n] = {
                        templateKey = "HeaderTitle",
                        setupFunc = function(obj)
                            obj:SetText(itemInfo.text);
                        end,
                        top = top,
                        bottom = bottom,
                        offsetX = -8,
                    };
                else
                    objectHeight = buttonHeight;
                    bottom = offsetY + objectHeight + gap;
                    content[n] = {
                        templateKey = "LootButton",
                        setupFunc = function(obj)
                            obj:SetItemInfo(itemInfo);
                        end,
                        top = top,
                        bottom = bottom,
                        offsetX = -8,
                    };
                end
                offsetY = bottom;
            end

            local retainPosition = false;
            self.ScrollView:Show();
            self.ScrollView:SetContent(content, retainPosition);
        else
            self.DifficultyDropdown:Hide();
            self.ClassDropdown:Hide();
            self.AlertText:Show();
            self.AlertText:SetText(L["No Data"]);
            self.ScrollView:Hide();
            self.ScrollView:SetContent(nil);
        end
    end

    function LootContainerMixin:SetDifficulty(difficultyID)
        difficultyID = difficultyID or self.difficultyID or LandingPageUtil.GetDefaultRaidDifficulty();
        self.difficultyID = difficultyID;
        addon.SetDBValue("EncounterJournalDifficulty", difficultyID);
        self:Refresh();
    end

    function LootContainerMixin:SetPlayerClass(playerClassID)
        playerClassID = playerClassID or self.playerClassID or LandingPageUtil.GetDefaultPlayerClassID();
        self.playerClassID = playerClassID;
        self:Refresh();
    end

    function LootContainerMixin:Refresh()
        if self.journalInstanceID and self.journalEncounterID then
            self:ShowLoot(self.journalInstanceID, self.journalEncounterID);
        end
    end

    function LootContainerMixin:HighlightButton(button)
        self.Highlight:Hide();
        self.Highlight:ClearAllPoints();
        if button then
            self.Highlight:SetParent(button);
            self.Highlight:SetPoint("CENTER", button, "CENTER", 0, 0);
            self.Highlight:Show();
        end
    end

    local function DropdownMenuInfoGetter_Difficulty()
        local tbl = {
            key = "EncounterJournalDifficultyDropdownMenu",
        };
        local widgets = {};
        tbl.widgets = widgets;

        for i, difficultyID in ipairs(LandingPageUtil.RaidDifficulties) do
            widgets[i] = {
                type = "Radio",
                text = LandingPageUtil.GetDifficultyName(difficultyID),
                selected = difficultyID == LootContainer.difficultyID,
                closeAfterClick = true,
                onClickFunc = function()
                    LootContainer:SetDifficulty(difficultyID);
                end,
            };
        end

        return tbl
    end

    local function DropdownMenuInfoGetter_PlayerClass()
        local tbl = {
            key = "EncounterJournalClassDropdownMenu",
        };
        local widgets = {};
        tbl.widgets = widgets;

        local playerClassList = LandingPageUtil.PlayerClassList;
        local n = 0;

        for i = 0, #playerClassList do
            local playerClassID;
            if i == 0 then
                playerClassID = 0;
            else
                playerClassID = playerClassList[i];
            end

            n = n + 1;
            widgets[n] = {
                type = "Radio",
                text = GetPlayerClassName(playerClassID, true),
                selected = playerClassID == LootContainer.playerClassID,
                closeAfterClick = true,
                onClickFunc = function()
                    LootContainer:SetPlayerClass(playerClassID);
                end,
            };
        end

        return tbl
    end

    function CreateLootContainer(parent)
        if LootContainer then return LootContainer end;

        local f = CreateFrame("Frame", nil, parent);
        LootContainer = f;

        f.difficultyID = LandingPageUtil.GetDefaultRaidDifficulty();
        f.playerClassID = LandingPageUtil.GetDefaultPlayerClassID();

        local frameWidth = 260;
        f:SetWidth(frameWidth);

        f.buttons = {};
        API.Mixin(f, LootContainerMixin);

        local AlertText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.AlertText = AlertText;
        AlertText:SetPoint("CENTER", f, "CENTER", 0, 0);
        AlertText:SetWidth(208);
        AlertText:SetText(L["No Raid Boss Selected"]);
        AlertText:SetTextColor(0.5, 0.5, 0.5);

        f.Highlight = CreateFrame("Frame", nil, f);
        f.Highlight:Hide();
        f.Highlight:SetUsingParentLevel(true);
        f.Highlight:SetSize(232, 40);
        local tex = f.Highlight:CreateTexture(nil, "BACKGROUND");
        tex:SetAllPoints(true);
        tex:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/HorizontalButtonHighlight");
        tex:SetBlendMode("ADD");
        tex:SetVertexColor(51/255, 29/255, 17/255);


        local ScrollView = LandingPageUtil.CreateScrollViewForTab(f);
        ScrollView:Hide();
        ScrollView:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -40);
        ScrollView:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8);
        ScrollView:OnSizeChanged();
        ScrollView:SetAlwaysShowScrollBar(false);
        ScrollView:SetSmartClipsChildren(true);
        ScrollView:SetStepSize(60);
        ScrollView:UseBoundaryGradient(true);
        ScrollView:SetBoundaryGradientSize(40);

        local function LootButton_Create()
            return CreateLootButton(ScrollView)
        end

        local function LootButton_OnAcquired(button)

        end
        local function LootButton_OnRemoved(button)

        end

        ScrollView:AddTemplate("LootButton", LootButton_Create, LootButton_OnAcquired, LootButton_OnRemoved);


        local function HeaderTitle_Create()
            local fs = ScrollView:CreateFontString(nil, "OVERLAY", "GameFontNormal");
            fs:SetSize(208, 16);
            fs:SetTextColor(0.8, 0.8, 0.8);
            return fs
        end

        ScrollView:AddTemplate("HeaderTitle", HeaderTitle_Create);


        --Dropdowns
        local buttonWidth = math.floor(frameWidth * 0.5 - 16);
        local DifficultyDropdown = LandingPageUtil.CreateDropdownButton(f);
        f.DifficultyDropdown = DifficultyDropdown;
        DifficultyDropdown:SetWidth(buttonWidth);
        DifficultyDropdown:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -6);
        DifficultyDropdown.menuInfoGetter = DropdownMenuInfoGetter_Difficulty;
        DifficultyDropdown:Hide();

        local ClassDropdown = LandingPageUtil.CreateDropdownButton(f);
        f.ClassDropdown = ClassDropdown;
        ClassDropdown:SetWidth(buttonWidth);
        ClassDropdown:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -6);
        ClassDropdown.menuInfoGetter = DropdownMenuInfoGetter_PlayerClass;
        ClassDropdown:Hide();

        return f
    end
end


local RaidTabMixin = {};
do
    local DynamicEvents = {
        "UPDATE_INSTANCE_INFO",
        "BOSS_KILL",
        "ACHIEVEMENT_EARNED",
        --"EJ_LOOT_DATA_RECIEVED",
    };

    if C_EventUtils.IsEventValid("CONTENT_TRACKING_UPDATE") then
        table.insert(DynamicEvents, "CONTENT_TRACKING_UPDATE");
    else
        table.insert(DynamicEvents, "TRACKED_ACHIEVEMENT_LIST_CHANGED");
    end

    function RaidTabMixin:OnShow()
        API.RegisterFrameForEvents(self, DynamicEvents);
        LandingPageUtil.ShowLeftFrame(false);
        self:FullUpdate();
    end

    function RaidTabMixin:OnHide()
        API.UnregisterFrameForEvents(self, DynamicEvents);
    end

    function RaidTabMixin:OnEvent(event, ...)
        if event == "UPDATE_INSTANCE_INFO" then
            self:UpdateScrollViewContent();
        elseif event == "BOSS_KILL" then
            RequestRaidInfo();
        elseif event == "ACHIEVEMENT_EARNED" then
            self:UpdateAchievements();
        elseif event == "CONTENT_TRACKING_UPDATE" or event == "TRACKED_ACHIEVEMENT_LIST_CHANGED" then
            self.AchievementContainer:UpdateTooltip();
        end
    end

    function RaidTabMixin:GetInstanceData(journalInstanceID)
        --journalInstanceID
        --EJ_DIFFICULTIES

        local name, _, _, _, _, _, _, _, _, mapID = EJ_GetInstanceInfo(journalInstanceID);
        if not name then return end;

        local difficultyID = LandingPageUtil.GetBaseRaidDifficulty();
        EJ_SetDifficulty(difficultyID);   --This is essential otherwise "EJ_GetEncounterInfoByIndex" returns nil

        local encounters = {};
        local i = 1;
        local bossName, description, journalEncounterID, _, _, _, dungeonEncounterID = EJ_GetEncounterInfoByIndex(i, journalInstanceID);    --No dungeonEncounterID in Classic

        while journalEncounterID do
            if not dungeonEncounterID then
                dungeonEncounterID = LandingPageUtil.GetDungeonEncounteID(journalEncounterID);
            end

            encounters[i] = {
                name = bossName,
                id = journalEncounterID,
                mapID = mapID,
                dungeonEncounterID = dungeonEncounterID,
            };
            i = i + 1;
            bossName, description, journalEncounterID, _, _, _, dungeonEncounterID = EJ_GetEncounterInfoByIndex(i, journalInstanceID);
        end

        local data = {
            name = name,
            instanceID = journalInstanceID,
            mapID = mapID,
            encounters = encounters,
        };

        return data
    end

    function RaidTabMixin:FullUpdate()
        RequestRaidInfo();

        EncounterList = {};

        local n = 0;
        local selectedJournalEncounterID = self.selectedJournalEncounterID or -1;

        for _, journalInstanceID in ipairs(JournalInstanceIDs) do
            local data = self:GetInstanceData(journalInstanceID);
            if data then
                local mapID = data.mapID;
                n = n + 1;
                EncounterList[n] = {dataIndex = n, name = data.name, isCollapsed = IsRaidCollapsed(mapID), isHeader = true, journalInstanceID = journalInstanceID, mapID = mapID};
                for _, encounterInfo in ipairs(data.encounters) do
                    n = n + 1;
                    EncounterList[n] = {dataIndex = n, name = encounterInfo.name, journalEncounterID = encounterInfo.id, dungeonEncounterID = encounterInfo.dungeonEncounterID, mapID = mapID, journalInstanceID = journalInstanceID, };
                    if encounterInfo.id == selectedJournalEncounterID then
                        EncounterList[n].selected = true;
                    end
                end
            end
        end

        self:RefreshList();
    end

    function RaidTabMixin:RefreshList()
        local content = {};
        local n = 0;
        local buttonHeight = 24;
        local gap = 4;
        local offsetY = 16;

        local entryWidth = 544;
        local headerWidth = entryWidth + 62;

        local top, bottom;
        local showEntry, showGroup;

        for k, v in ipairs(EncounterList) do
            if v.isHeader then
                showEntry = true;
                showGroup = not v.isCollapsed;
            else
                showEntry = showGroup;
            end

            if showEntry then
                n = n + 1;
                local isOdd = n % 2 == 0;
                top = offsetY;
                bottom = offsetY + buttonHeight + gap;
                content[n] = {
                    templateKey = "ListButton",
                    setupFunc = function(obj)
                        obj.dataIndex = v.dataIndex;
                        obj.isOdd = isOdd;
                        if v.isHeader then
                            obj:SetWidth(headerWidth);
                            obj.isCollapsed = v.isCollapsed;
                            obj:SetInstance(v.mapID, v.journalInstanceID, v.name);
                        else
                            obj:SetWidth(entryWidth);
                            obj:SetEncounter(v.mapID, v.journalInstanceID, v.journalEncounterID, v.dungeonEncounterID, v.name);
                        end
                        obj:UpdateSelection();
                    end,
                    top = top,
                    bottom = bottom,
                };
                offsetY = bottom;
            end
        end

        local retainPosition = true;
        self.ScrollView:SetContent(content, retainPosition);
    end

    function RaidTabMixin:UpdateScrollViewContent()
        if self.ScrollView then
            self.ScrollView:CallObjectMethod("ListButton", "UpdateProgress");
        end
    end

    function RaidTabMixin:UpdateScrollViewSelection()
        if self.ScrollView then
            self.ScrollView:CallObjectMethod("ListButton", "UpdateSelection");
        end
    end

    function RaidTabMixin:UpdateAchievements()
        if self.AchievementContainer then
            self.AchievementContainer:Update();
        end
    end

    function RaidTabMixin:SelectEncounterByDataIndex(dataIndex)
        for i, v in ipairs(EncounterList) do
            v.selected = nil;
        end

        if dataIndex and EncounterList[dataIndex] then
            EncounterList[dataIndex].selected = true;
            self.selectedDataIndex = dataIndex;
            self.selectedJournalEncounterID = EncounterList[dataIndex].journalEncounterID;
        else
            self.selectedDataIndex = nil;
            self.selectedJournalEncounterID = nil;
        end

        RaidTab:UpdateScrollViewSelection();
    end

    function RaidTabMixin:Init()
        local ScrollView = LandingPageUtil.CreateScrollViewForTab(self);

        local function ListButton_Create()
            return CreateListButton(ScrollView)
        end

        local function ListButton_OnAcquired(button)

        end
        local function ListButton_OnRemoved(button)

        end

        ScrollView:AddTemplate("ListButton", ListButton_Create, ListButton_OnAcquired, ListButton_OnRemoved);


        --Init LeftSection
        local offsetY = 16;
        local categoryButtonHeight = 32;
        local lineGap = 8;
        local paragraphGap = 8;

        local LeftFrame = PlumberExpansionLandingPage.LeftSection;
        local Header1 = LandingPageUtil.CreateListCategoryButton(self, ACHIEVEMENTS);
        Header1:SetPoint("TOP", LeftFrame, "TOP", 0, -offsetY);
        offsetY = offsetY + categoryButtonHeight + lineGap;
        Header1:SetCollapsible(true);

        local header1Bottom = offsetY;
        local achvContainerHeight = 48;

        local AchievementContainer = CreateAchievementContainer(self);
        self.AchievementContainer = AchievementContainer;
        AchievementContainer:SetSize(192, achvContainerHeight);
        AchievementContainer:SetPoint("TOP", LeftFrame, "TOP", 0, -offsetY);
        offsetY = offsetY + achvContainerHeight + paragraphGap;

        local header2Top = offsetY;

        local Header2 = LandingPageUtil.CreateListCategoryButton(self, LOOT_NOUN);
        Header2:SetPoint("TOP", LeftFrame, "TOP", 0, -header2Top);
        offsetY = offsetY + categoryButtonHeight + lineGap;

        LootContainer = CreateLootContainer(self);
        self.LootContainer = LootContainer;
        LootContainer:SetPoint("TOP", Header2, "BOTTOM", 0, - lineGap + 8);
        LootContainer:SetPoint("BOTTOM", LeftFrame, "BOTTOM", 0, 12);
        LootContainer.ScrollView:ResetScrollBarPosition();
        LootContainer.ScrollView:OnSizeChanged();
        LootContainer.ScrollView:SetBottomOvershoot(40);

        Header1.onCollapsed = function(isCollapsed)
            if isCollapsed then
                AchievementContainer:Hide();
                Header2:SetPoint("TOP", LeftFrame, "TOP", 0, -header1Bottom);
            else
                AchievementContainer:Show();
                Header2:SetPoint("TOP", LeftFrame, "TOP", 0, -header2Top);
            end
            LootContainer.ScrollView:OnSizeChanged(true);
            addon.SetDBValue("LandingPage_Raid_CollapsedAchievement", isCollapsed);
        end

        local isAchievementCollapsed = addon.GetDBBool("LandingPage_Raid_CollapsedAchievement");
        Header1:SetCollapsed(isAchievementCollapsed, true)
    end

    --Frame Update
    function RaidTabMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t >= 0.2 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);

            if self.lootDirty then
                self.LootContainer:Refresh();
            end
        end
    end

    function RaidTabMixin:StartUpdating()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function RaidTabMixin:RequestLootData()
        self.lootDirty = true;
        self:StartUpdating();
    end
end


local function CreateRaidTab(f)
    RaidTab = f;
    API.Mixin(f, RaidTabMixin);
    f:Init();
    f:SetScript("OnShow", f.OnShow);
    f:SetScript("OnHide", f.OnHide);
    f:SetScript("OnEvent", f.OnEvent);
end

LandingPageUtil.AddTab(
    {
        key = "raid",
        name = L["Raids"],
        uiOrder = 3,
        initFunc = CreateRaidTab,
        useCustomLeftFrame = true,
        dimBackground = true,
    }
);