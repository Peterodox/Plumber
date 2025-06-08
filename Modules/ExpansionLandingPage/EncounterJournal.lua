local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;
local TooltipUpdator = LandingPageUtil.TooltipUpdator;
local GetEncounterProgress = LandingPageUtil.GetEncounterProgress;


local EJ_GetEncounterInfoByIndex = EJ_GetEncounterInfoByIndex;


local JournalInstanceIDs = {
    1296,   --Liberation of Undermine
    1273,   --Nerub-ar Palace
};


local RaidTab;
local EncounterList = {};


local CreateListButton;
do
    local ListButtonMixin = {};

    function ListButtonMixin:OnEnter()
        self:UpdateBackground();
    end

    function ListButtonMixin:OnLeave()
        self:UpdateBackground();
    end

    function ListButtonMixin:OnClick(button)
        if self.isHeader then
            self:ToggleCollapsed();
        else
            RaidTab.AchievementContainer:SetAchievements(LandingPageUtil.GetEncounterAchievements(self.journalEncounterID));
        end
    end

    function ListButtonMixin:ToggleCollapsed()
        if self.dataIndex and EncounterList[self.dataIndex] then
            EncounterList[self.dataIndex].isCollapsed = not EncounterList[self.dataIndex].isCollapsed;
            RaidTab:RefreshList();
        end
    end

    function ListButtonMixin:SetInstance(uiMapID, journalInstanceID, name)
        self.uiMapID = uiMapID;
        self.journalInstanceID = journalInstanceID;
        self:SetHeader();
        self.Name:SetText(name);
        self:HideProgress();
    end

    function ListButtonMixin:SetEncounter(uiMapID, journalEncounterID, name)
        self.uiMapID = uiMapID;
        self.journalEncounterID = journalEncounterID;
        self:SetEntry();

        self.Name:SetPoint("LEFT", self, "LEFT", 10, 0);
        self.Name:SetText(name);

        self:UpdateProgress();
    end

    function ListButtonMixin:HideProgress()
        self.Light1:Hide();
        self.Light2:Hide();
        self.Light3:Hide();
        self.Light4:Hide();
    end

    function ListButtonMixin:UpdateProgress()
        self:HideProgress();
        if (not self.isHeader) and self.uiMapID and self.journalEncounterID then
            local progress = GetEncounterProgress(self.uiMapID, self.journalEncounterID);
            local texture;
            for i, completed in ipairs(progress) do
                texture = self["Light"..i];
                if texture then
                    texture:Show();
                    if completed then
                        texture:SetTexCoord(48/512, 96/512, 208/512, 256/512);
                    else
                        texture:SetTexCoord(96/512, 144/512, 208/512, 256/512);
                    end
                end
            end
        end
    end


    function CreateListButton(parent)
        local f = LandingPageUtil.CreateScrollViewListButton(parent);
        API.Mixin(f, ListButtonMixin);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);

        for i = 1, 4 do
            local texture = f:CreateTexture(nil, "OVERLAY");
            f["Light"..i] = texture;
            texture:SetSize(24, 24);
            texture:SetTexture("Interface/AddOns/Plumber/Art/Frame/ChecklistButton.tga", nil, nil, "TRILINEAR");
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
            self:ToggleTracking();
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
                return
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
                    button.Border:SetTexture("Interface/AddOns/Plumber/Art/Frame/ChecklistButton.tga");
                    button.Border:SetTexCoord(0/512, 96/512, 256/512, 352/512);

                    button.Highlight = button:CreateTexture(nil, "HIGHLIGHT");
                    button.Highlight:SetPoint("CENTER", button, "CENTER", 0, 0);
                    button.Highlight:SetSize(48, 48);
                    button.Highlight:SetTexture("Interface/AddOns/Plumber/Art/Frame/ChecklistButton.tga");
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

        return f
    end
end

local RaidTabMixin = {};
do
    local DynamicEvents = {
        "UPDATE_INSTANCE_INFO",
        "ACHIEVEMENT_EARNED",
        "CONTENT_TRACKING_UPDATE",
    };

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
        elseif event == "ACHIEVEMENT_EARNED" then
            self:UpdateAchievements();
        elseif event == "CONTENT_TRACKING_UPDATE" then
            self.AchievementContainer:UpdateTooltip();
        end
    end

    function RaidTabMixin:GetInstanceData(instanceID)
        --journalInstanceID
        --EJ_DIFFICULTIES

        local name, _, _, _, _, _, dungeonAreaMapID = EJ_GetInstanceInfo(instanceID);
        if not name then return end;

        local difficultyID = DifficultyUtil.ID.PrimaryRaidNormal;
        EJ_SetDifficulty(difficultyID);   --This is essential otherwise "EJ_GetEncounterInfoByIndex" returns nil

        local encounters = {};
        local i = 1;
        local bossName, description, journalEncounterID = EJ_GetEncounterInfoByIndex(i, instanceID);
        local isComplete;

        while journalEncounterID do
            encounters[i] = {
                name = bossName,
                id = journalEncounterID,
                uiMapID = dungeonAreaMapID,
            };
            i = i + 1;
            bossName, description, journalEncounterID = EJ_GetEncounterInfoByIndex(i, instanceID);
        end

        local data = {
            name = name,
            instanceID = instanceID,
            uiMapID = dungeonAreaMapID,
            encounters = encounters,
        };

        return data
    end

    function RaidTabMixin:FullUpdate()
        RequestRaidInfo();

        EncounterList = {};

        local n = 0;

        for _, journalInstanceID in ipairs(JournalInstanceIDs) do
            local data = self:GetInstanceData(journalInstanceID);
            if data then
                local uiMapID = data.uiMapID;
                n = n + 1;
                EncounterList[n] = {dataIndex = n, name = data.name, isCollapsed = false, isHeader = true};
                for _, encounterInfo in ipairs(data.encounters) do
                    n = n + 1;
                    EncounterList[n] = {dataIndex = n, name = encounterInfo.name, journalEncounterID = encounterInfo.id, uiMapID = uiMapID};
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
                            obj:SetInstance(v.uiMapID, v.journalInstanceID, v.name);
                        else
                            obj:SetWidth(entryWidth);
                            obj:SetEncounter(v.uiMapID, v.journalEncounterID, v.name);
                        end
                        obj:UpdateBackground();
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

    function RaidTabMixin:UpdateAchievements()
        self.AchievementContainer:Update();
        print("UpdateAchievements")
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

        local AchievementContainer = CreateAchievementContainer(self);
        self.AchievementContainer = AchievementContainer;
        AchievementContainer:SetSize(192, 48);
        AchievementContainer:SetPoint("TOP", LeftFrame, "TOP", 0, -offsetY);
        offsetY = offsetY + 48 + paragraphGap;

        local Header2 = LandingPageUtil.CreateListCategoryButton(self, LOOT_NOUN);
        Header2:SetPoint("TOP", LeftFrame, "TOP", 0, -offsetY);
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
    }
);