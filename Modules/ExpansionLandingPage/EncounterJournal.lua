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


local RaidTabMixin = {};
do
    function RaidTabMixin:OnShow()
        self:RegisterEvent("UPDATE_INSTANCE_INFO");
        self:FullUpdate();
    end

    function RaidTabMixin:OnHide()
        self:UnregisterEvent("UPDATE_INSTANCE_INFO");
    end

    function RaidTabMixin:OnEvent(event, ...)
        if event == "UPDATE_INSTANCE_INFO" then
            
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
    }
);