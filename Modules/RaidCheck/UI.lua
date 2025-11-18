
local _, addon = ...
local L = addon.L;
local API = addon.API;
local RaidCheck = addon.RaidCheck;
local DataProvider = RaidCheck.DataProvider;


local GetInstanceInfo = GetInstanceInfo;
local IsLegacyDifficulty = IsLegacyDifficulty;
local IsEncounterComplete = C_RaidLocks.IsEncounterComplete;
local GetInstanceInfoForSelector = API.GetInstanceInfoForSelector;    --See ExpansionLandingPage\API_Encounter.lua
local GetInstanceEncounters = API.GetInstanceEncounters;


local DifficultyAnnouncer = CreateFrame("Frame", nil, UIParent, "PlumberPropagateMouseTemplate");    --Show difficulty when entering the instance
RaidCheck.DifficultyAnnouncer = DifficultyAnnouncer;
local SelectorUI = CreateFrame("Frame", nil, UIParent);             --Show difficulty selector at the entrance
RaidCheck.SelectorUI = SelectorUI;
DifficultyAnnouncer:Hide();
SelectorUI:Hide();


local TOP_OFFSET = -40;


local function SetupFont(fontString, fontHeight)
    local font = GameFontNormal:GetFont();
    fontString:SetFont(font, fontHeight or 14, "OUTLINE");
end


local ColorCodes = {
    "c6c6c6",   --Unfinished Instance
    "f55a4f",   --Red
    "5e5e5e",   --Grey
};


local MapThemes = {
    --1: Blue  2:Green
    [118] = 1,  --Icecrown
    --[646] = 2,  --Broken Shore
    --[885] = 2,  --Antoran Wastes
};


local function CanChangeDifficulty()
    if IsInInstance() then
		return false
	end

	if IsInGroup() and not UnitIsGroupLeader("player") then
		return false
	end

	if IsInGroup(2) then    --LE_PARTY_CATEGORY_INSTANCE
		return false
	end

    return true
end


local function ShowLockoutTooltip(self, instanceName, difficultyName, instanceID, showInstruction)
    local dead = BOSS_DEAD or "Defeated";
    local alive = BOSS_ALIVE or "Available";

    local tooltip = GameTooltip;
    tooltip:SetOwner(self, "ANCHOR_NONE");
    tooltip:SetPoint("TOP", self, "BOTTOM", 0, -6);
    tooltip:AddDoubleLine(instanceName, difficultyName);
    tooltip:SetCustomLineSpacing(4);
    for i, v in ipairs(self.encounters) do
        local hasDefeated = v.dungeonEncounterID and IsEncounterComplete(instanceID, v.dungeonEncounterID, v.difficultyID);
        if i % 5 == 1 then
            tooltip:AddLine(" ");
        end
        if hasDefeated then
            tooltip:AddDoubleLine(v.name, dead, 1, 1, 1, 1, 0.125, 0.125);
        else
            tooltip:AddDoubleLine(v.name, alive,  1, 1, 1, 0.1, 1, 0.1);
        end
    end

    if showInstruction then
        if not CanChangeDifficulty() then
            tooltip:AddLine(" ");
            tooltip:AddLine(L["Cannot Change Difficulty"], 1, 0.125, 0.125, true);
        end
    end

    tooltip:Show();
end


local DifficultyButtonMixin = {};
do
    function DifficultyButtonMixin:OnEnter()
        self:UpdateVisual();
        SelectorUI:HighlightButton(self);
        self:ShowTooltip();
    end

    function DifficultyButtonMixin:OnLeave()
        self:UpdateVisual();
        SelectorUI:HighlightButton(nil);
        self:HideTooltip();
    end

    function DifficultyButtonMixin:OnMouseDown()
        if not self.selected then
            self.ButtonText:SetPoint("CENTER", self, "CENTER", 0, -1);
        end
    end

    function DifficultyButtonMixin:OnMouseUp()
        self.ButtonText:SetPoint("CENTER", self, "CENTER", 0, 0);
    end

    function DifficultyButtonMixin:OnClick()
        if SelectorUI:TrySelectDiffulty(self.difficultyID) then
            SelectorUI.LoadingIndicator:ClearAllPoints();
            SelectorUI.LoadingIndicator:SetPoint("CENTER", self, "CENTER", 0, 0);
            SelectorUI.LoadingIndicator:Show();
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        end
    end

    function DifficultyButtonMixin:SetDifficulty(difficultyID, name)
        self.difficultyID = difficultyID;
        self.name = name;
        self.encounters = GetInstanceEncounters(SelectorUI.journalInstanceID, difficultyID);
        self:UpdateProgress();
        self.ButtonText:SetTextColor(1, 0.82, 0);
        return self.ButtonText:GetWrappedWidth();
    end

    function DifficultyButtonMixin:UpdateVisual()
        if self.selected then
            self.ButtonText:SetTextColor(1, 1, 1);
            self:SetAlpha(1);
        else
            if self:IsMouseMotionFocus() then
                self.ButtonText:SetTextColor(1, 1, 1);
            else
                self.ButtonText:SetTextColor(1, 0.82, 0);
            end
        end
    end


    function DifficultyButtonMixin:UpdateProgress()
        local total = self.encounters and #self.encounters or 0;
        local complete = 0;
        if total > 0 then
            for _, v in ipairs(self.encounters) do
                if v.dungeonEncounterID and IsEncounterComplete(SelectorUI.instanceID, v.dungeonEncounterID, self.difficultyID) then
                    complete = complete + 1;
                end
            end
        end
        local colorIndex;
        if complete < total then
            colorIndex = 1;
        else
            colorIndex = 2;
        end
        self.ButtonText:SetText(string.format("%s  |cff%s(%d/%d)|r", self.name, ColorCodes[colorIndex], complete, total));
    end

    local function ButtonBackground_OnUpdate(self, elapsed)
        local complete;
        local diff = self.toX - self.x;
        local delta = elapsed * 12 * diff;

        if diff >= 0 and (diff < 1 or (self.x + delta >= self.toX)) then
            self.x = self.toX;
            complete = true;
        elseif diff <= 0 and (diff > -1 or (self.x + delta <= self.toX)) then
            self.x = self.toX;
            complete = true;
        else
            self.x = self.x + delta;
        end

        if complete then
            self:SetScript("OnUpdate", nil);
        end

        self:SetPoint("CENTER", self.owner, "CENTER", self.x, 0);
    end

    function DifficultyButtonMixin:UpdateSeleceted(playAnimation)
        self.selected = SelectorUI.selectedDifficulty and self.difficultyID == SelectorUI.selectedDifficulty;
        if self.selected then
            local ButtonBackground = SelectorUI.ButtonBackground;
            ButtonBackground.owner = self;
            if playAnimation then
                local x0 = self:GetCenter();
                local x1 = ButtonBackground:GetCenter();
                if x0 and x1 then
                    ButtonBackground.toX = 0;
                    ButtonBackground.x = x1 - x0;
                    ButtonBackground:ClearAllPoints();
                    ButtonBackground:SetScript("OnUpdate", ButtonBackground_OnUpdate);
                    if math.abs(ButtonBackground.x) < 1 then
                        playAnimation = false;
                    end
                else
                    playAnimation = false;
                end
            end
            if not playAnimation then
                ButtonBackground:ClearAllPoints();
                ButtonBackground:SetPoint("CENTER", self, "CENTER", 0, 0);
                ButtonBackground:SetScript("OnUpdate", nil);
            end
            ButtonBackground:Show();
            self:SetParent(SelectorUI.OpaqueFrame);
            ButtonBackground:SetParent(SelectorUI.OpaqueFrame);
        else
            self:SetParent(SelectorUI.Bar);
        end
        self:UpdateVisual();

        if self:IsMouseMotionFocus() then
            self:ShowTooltip();
        end
    end

    function DifficultyButtonMixin:ShowTooltip()
        ShowLockoutTooltip(self, SelectorUI.instanceName, self.name, SelectorUI.instanceID, true);
    end

    function DifficultyButtonMixin:HideTooltip()
        GameTooltip:Hide();
    end

    function DifficultyButtonMixin:OnLoad()
        self.ButtonText = self:CreateFontString(nil, "OVERLAY");
        SetupFont(self.ButtonText);
        self.ButtonText:SetJustifyH("CENTER");
        self.ButtonText:SetPoint("CENTER", self, "CENTER", 0, 0);

        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnMouseDown", self.OnMouseDown);
        self:SetScript("OnMouseUp", self.OnMouseUp);
        self:SetScript("OnClick", self.OnClick);
    end
end


do  --SelectorUI
    local BUTTON_WIDTH = 32 * 4;
    local BAR_IDLE_ALPHA = 0.5;

    function SelectorUI:Init()
        self.Init = nil;
        local texture = "Interface/AddOns/Plumber/Art/RaidCheck/DifficultySelector.png";
        local barTextureHeight = 48;


        self:SetSize(96, 64);
        self:SetPoint("TOP", UIParent, "TOP", 0, TOP_OFFSET);
        self:SetAlpha(0);
        self:SetFrameStrata("HIGH");


        local OpaqueFrame = CreateFrame("Frame", nil, self);
        self.OpaqueFrame = OpaqueFrame;

        local Bar = CreateFrame("Frame", nil, self);
        self.Bar = Bar;
        Bar:SetSize(128, barTextureHeight);
        Bar:SetPoint("BOTTOM", self, "BOTTOM", 0, 0);
        Bar:SetAlpha(BAR_IDLE_ALPHA);


        local disableSharpenging = true;
        local BarBGs = API.CreateThreeSliceTextures(Bar, "BORDER", 20, barTextureHeight, 0, texture, disableSharpenging);
        self.BarBGs = BarBGs;
        BarBGs[1]:SetTexCoord(0/1024, 40/1024, 0/1024, 96/1024);
        BarBGs[2]:SetTexCoord(40/1024, 216/1024, 0/1024, 96/1024);
        BarBGs[3]:SetTexCoord(216/1024, 256/1024, 0/1024, 96/1024);


        local Shadow = Bar:CreateTexture(nil, "BACKGROUND");
        Shadow:SetTexture(texture);
        Shadow:SetTexCoord(768/1024, 1024/1024, 0/1024, 256/1024)
        Shadow:SetPoint("CENTER", self, "CENTER", 0, 0);
        Shadow:SetSize(1200, 400);
        Shadow:SetAlpha(0.65);


        local Title = OpaqueFrame:CreateFontString(nil, "OVERLAY");
        self.Title = Title;
        SetupFont(Title);
        Title:SetJustifyH("CENTER");
        Title:SetPoint("TOP", self, "TOP", 0, 0);
        Title:SetTextColor(0.9, 0.81, 0.67);    --AREA_NAME_FONT_COLOR
        --Title:SetShadowOffset(1, -1);


        local TitleButton = CreateFrame("Button", nil, self);
        self.TitleButton = TitleButton;
        TitleButton:SetPoint("CENTER", Title, "CENTER", 0, 0);
        TitleButton:SetSize(96, 24)
        TitleButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(TitleButton, "ANCHOR_RIGHT");
            GameTooltip:SetText(ADVENTURE_JOURNAL, 1, 1, 1);
            GameTooltip:Show();
        end);
        TitleButton:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end);
        TitleButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
        TitleButton:SetScript("OnClick", function()
            self:OpenEncounterJournal();
        end);


        local ButtonBackground = CreateFrame("Frame", nil, Bar);
        self.ButtonBackground = ButtonBackground;
        ButtonBackground:SetUsingParentLevel(true);
        ButtonBackground:SetSize(BUTTON_WIDTH, 32);
        local ButtonBGs = API.CreateThreeSliceTextures(ButtonBackground, "ARTWORK", 16, barTextureHeight, 6, texture, disableSharpenging);
        self.ButtonBGs = ButtonBGs;
        ButtonBGs[1]:SetTexCoord(264/1024, 296/1024, 0/1024, 96/1024);
        ButtonBGs[2]:SetTexCoord(296/1024, 392/1024, 0/1024, 96/1024);
        ButtonBGs[3]:SetTexCoord(392/1024, 424/1024, 0/1024, 96/1024);
        ButtonBackground:SetPoint("CENTER", Bar, "CENTER", 0, 0);


        local ButtonHighlight = Bar:CreateTexture(nil, "OVERLAY");
        self.ButtonHighlight = ButtonHighlight;
        ButtonHighlight:SetSize(BUTTON_WIDTH, barTextureHeight);
        ButtonHighlight:SetTexture(texture);
        ButtonHighlight:SetTexCoord(432/1024, 560/1024, 0/1024, 96/1024);
        ButtonHighlight:SetBlendMode("ADD");
        ButtonHighlight:SetAlpha(0.5);
        ButtonHighlight:Hide();


        local function DifficultyButton_Create()
            local obj = CreateFrame("Button", nil, Bar);
            obj:SetSize(BUTTON_WIDTH, 32);
            Mixin(obj, DifficultyButtonMixin);
            obj:OnLoad();
            return obj
        end

        local function DifficultyButton_OnAcquire(obj)
            obj:OnMouseUp();
        end

        local difficultyButtonPool = addon.LandingPageUtil.CreateObjectPool(DifficultyButton_Create, DifficultyButton_OnAcquire);
        self.difficultyButtonPool = difficultyButtonPool;


        local MotionFrame = CreateFrame("Frame", nil, self, "PlumberPropagateMouseTemplate");
        self.MotionFrame = MotionFrame;
        MotionFrame:SetSize(640, 128);
        MotionFrame:SetPoint("CENTER", self, "CENTER", 0, 0);
        MotionFrame:SetFrameLevel(10);
        MotionFrame:SetScript("OnEnter", function()
            self:BarFadeIn();
        end);
        MotionFrame:SetScript("OnLeave", function()
            self:BarFadeOut();
        end);


        local LoadingIndicator = CreateFrame("Frame", nil, OpaqueFrame, "PlumberLoadingIndicatorTemplate");
        self.LoadingIndicator = LoadingIndicator;
        LoadingIndicator.autoHide = true;
        LoadingIndicator:Hide();
        LoadingIndicator:SetFrameLevel(20);


        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);
        self:SetScript("OnEvent", self.OnEvent);
    end

    function SelectorUI:OnShow()
        self:RegisterEvent("PLAYER_DIFFICULTY_CHANGED");
        self:RegisterEvent("UPDATE_INSTANCE_INFO");
        self:RegisterEvent("GROUP_ROSTER_UPDATE");
        self:RegisterEvent("PARTY_LEADER_CHANGED");
    end

    function SelectorUI:OnHide()
        self:UnregisterEvent("PLAYER_DIFFICULTY_CHANGED");
        self:UnregisterEvent("UPDATE_INSTANCE_INFO");
        self:UnregisterEvent("GROUP_ROSTER_UPDATE");
        self:UnregisterEvent("PARTY_LEADER_CHANGED");
        if self.LoadingIndicator then
            self.LoadingIndicator:Hide();
        end
        if self.OpaqueFrame then
            self.OpaqueFrame.t = 0;
            self.OpaqueFrame:SetScript("OnUpdate", nil);
        end
    end

    function SelectorUI:OnEvent(event, ...)
        if event == "PLAYER_DIFFICULTY_CHANGED" then
            self:UpdateDifficulty(true);
        elseif event == "UPDATE_INSTANCE_INFO" then
            self:UpdateInstanceProgress();
        elseif event == "GROUP_ROSTER_UPDATE" or event == "PARTY_LEADER_CHANGED" then
            self:RequestUpdate();
        end
    end

    local function FadeIn_OnUpdate(self, elapsed)
        self.alpha = self.alpha + 5 * elapsed;
        if self.alpha >= 1 then
            self:SetScript("OnUpdate", nil);
            self.alpha = 1;
        end
        self:SetAlpha(self.alpha);
    end

    local function FadeOut_OnUpdate(self, elapsed)
        self.alpha = self.alpha - 2 * elapsed;
        if self.alpha <= 0 then
            self:SetScript("OnUpdate", nil);
            self.alpha = 0;
            self:Hide();
        end
        self:SetAlpha(self.alpha);
    end

    local function BarFadeOut_OnUpdate(self, elapsed)
        self.alpha = self.alpha - 2 * elapsed;
        if self.alpha <= BAR_IDLE_ALPHA then
            self:SetScript("OnUpdate", nil);
            self.alpha = BAR_IDLE_ALPHA;
        end
        self:SetAlpha(self.alpha);
    end

    function SelectorUI:HideUI(instant)
        self.shown = false;
        if self:IsShown() then
            if instant then
                self:Hide();
                self:SetAlpha(0);
            else
                self.alpha = self:GetAlpha();
                self:SetScript("OnUpdate", FadeOut_OnUpdate);
            end
        else
            self:SetAlpha(0);
        end
    end

    function SelectorUI:BarFadeIn()
        self.Bar.alpha = self.Bar:GetAlpha();
        self.Bar:SetScript("OnUpdate", FadeIn_OnUpdate);
    end

    function SelectorUI:BarFadeOut()
        self.Bar.alpha = self.Bar:GetAlpha();
        self.Bar:SetScript("OnUpdate", BarFadeOut_OnUpdate);
    end

    function SelectorUI:ShowInstance(journalInstanceID, uiMapID)
        if journalInstanceID ~= self.journalInstanceID then
            local themeID = uiMapID and MapThemes[uiMapID] or 0;

            self.journalInstanceID = journalInstanceID;
            local instanceInfo = GetInstanceInfoForSelector(journalInstanceID);
            self.isRaid = instanceInfo.isRaid;
            self.instanceID = instanceInfo.instanceID;
            local difficulties = instanceInfo and instanceInfo.difficulties;
            if difficulties and #difficulties > 0 then
                if self.Init then
                    self:Init();
                end

                self:SetTheme(themeID);

                self.fallbackDifficultyID = difficulties[#difficulties].difficultyID;
                self.isValidDifficulty = {};
                self.instanceName = instanceInfo.name;
                self.Title:SetText(instanceInfo.name);
                self.TitleButton:SetWidth(math.max(API.Round(self.Title:GetWrappedWidth() + 8), BUTTON_WIDTH));

                self.difficultyButtonPool:ReleaseAll();
                local buttonGap = 4;
                local sidePadding = 20;
                local textWidth = 0;
                local maxTextWidth = 0;

                for i, v in ipairs(difficulties) do
                    local button = self.difficultyButtonPool:Acquire();
                    textWidth = button:SetDifficulty(v.difficultyID, v.text);
                    if textWidth > maxTextWidth then
                        maxTextWidth = textWidth;
                    end
                    self.isValidDifficulty[v.difficultyID] = true;
                end

                local buttonWidth = math.max(API.Round(maxTextWidth + 32), BUTTON_WIDTH);
                local barWidth = 2 * sidePadding + #difficulties * (buttonWidth + buttonGap) - buttonGap;
                self.Bar:SetWidth(barWidth);
                self.ButtonBackground:SetWidth(buttonWidth);
                self.ButtonHighlight:SetWidth(buttonWidth);
                self.MotionFrame:SetWidth(barWidth + 64);

                for i, obj in self.difficultyButtonPool:EnumerateActive() do
                    obj:SetPoint("LEFT", self.Bar, "LEFT", sidePadding + (i - 1) * (buttonWidth + buttonGap), 0);
                    obj:SetWidth(buttonWidth);
                end

                self.isLegacyRaid = instanceInfo.isLegacyRaid;

                self:UpdateDifficulty(false);
                self.hasInstanceData = true;
            else
                if self.difficultyButtonPool then
                    self.difficultyButtonPool:ReleaseAll();
                end
                self:HideUI();
                self.hasInstanceData = nil;
                self.isValidDifficulty = {};
                return
            end
        end

        if (not self.shown) and self.hasInstanceData then
            self.shown = true;
            self.alpha = self:GetAlpha();
            self:SetScript("OnUpdate", FadeIn_OnUpdate);
            self:UpdateDifficulty(false);
            self:UpdateInstanceProgress();
            RequestRaidInfo();
            self:Show();
        end
    end

    function SelectorUI:SetTheme(themeID)
        if themeID == self.themeID then return end;
        self.themeID = themeID;
        if self.Init then return end;

        local top = (themeID * 96)/1024;
        local bottom = ((themeID + 1) * 96)/1024;
        self.BarBGs[1]:SetTexCoord(0/1024, 40/1024, top, bottom);
        self.BarBGs[2]:SetTexCoord(40/1024, 216/1024, top, bottom);
        self.BarBGs[3]:SetTexCoord(216/1024, 256/1024, top, bottom);
        self.ButtonBGs[1]:SetTexCoord(264/1024, 296/1024, top, bottom);
        self.ButtonBGs[2]:SetTexCoord(296/1024, 392/1024, top, bottom);
        self.ButtonBGs[3]:SetTexCoord(392/1024, 424/1024, top, bottom);
        self.ButtonHighlight:SetTexCoord(432/1024, 560/1024, top, bottom);
    end

    function SelectorUI:UpdateDifficulty(playAnimation)
        if self.difficultyButtonPool then
            self.ButtonBackground:Hide();
            self.ButtonBackground:SetParent(self.Bar);
            self.LoadingIndicator:Hide();

            local selectedDifficulty;
            if self.isRaid then
                local difficultyID1, difficultyID2 = DataProvider:GetRaidDifficultyID();
                if self.isLegacyRaid then
                    selectedDifficulty = difficultyID2;
                else
                    selectedDifficulty = difficultyID1;
                end
            else
                selectedDifficulty = DataProvider:GetDungeonDifficultyID();
            end
            self.selectedDifficulty = selectedDifficulty;

            self.difficultyButtonPool:CallMethod("UpdateSeleceted", playAnimation);
        end
    end

    function SelectorUI:UpdateInstanceProgress()
        if self.difficultyButtonPool then
            self.difficultyButtonPool:CallMethod("UpdateProgress");
        end
    end

    local function UpdateFrame_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        if self.t >= 0.5 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            SelectorUI:UpdateDifficulty(true);
        end
    end

    function SelectorUI:RequestUpdate()
        self.OpaqueFrame.t = 0;
        self.OpaqueFrame:SetScript("OnUpdate", UpdateFrame_OnUpdate);
    end

    function SelectorUI:TrySelectDiffulty(difficultyID)
        if difficultyID == self.selectedDifficulty then return end;

        GameTooltip:Hide();

        local canChange = CanChangeDifficulty();

        if self.isRaid then
            if IsLegacyDifficulty(difficultyID) then
                SetLegacyRaidDifficultyID(difficultyID);
            else
                SetRaidDifficultyID(difficultyID);
            end
        else
            self.isLegacyRaid = nil;
            SetDungeonDifficultyID(difficultyID);
        end

        return true and canChange
    end

    function SelectorUI:HighlightButton(button)
        self.ButtonHighlight:Hide();
        self.ButtonHighlight:ClearAllPoints();
        if button then
            self.ButtonHighlight:SetPoint("CENTER", button, "CENTER", 0, 0);
            self.ButtonHighlight:Show();
        end
    end

    function SelectorUI:OpenEncounterJournal()
        if not API.CheckAndDisplayErrorIfInCombat() then
            if not EncounterJournal_OpenJournal then
                C_AddOns.LoadAddOn("Blizzard_EncounterJournal");
            end
            if EncounterJournal_OpenJournal then
                local difficultyID = self.selectedDifficulty;
                if not self.isValidDifficulty[difficultyID] then
                    difficultyID = self.fallbackDifficultyID;
                end
                EncounterJournal_OpenJournal(difficultyID, self.journalInstanceID);
            end
        end
    end
end

--name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
--DifficultyUtil.GetDifficultyName6


do  --DifficultyAnnouncer
    DifficultyAnnouncer:SetFrameStrata("HIGH");
    local UpdateFrame;

    function DifficultyAnnouncer:Init()
        self.Init = nil;

        self:SetSize(128, 32);
        self:SetPoint("TOP", UIParent, "TOP", 0, TOP_OFFSET);
        self:SetFrameStrata("HIGH");

        local Text1 = self:CreateFontString(nil, "OVERLAY");
        self.Text1 = Text1;
        SetupFont(Text1, 12);
        Text1:SetJustifyH("CENTER");
        Text1:SetPoint("TOP", self, "TOP", 0, 0);
        Text1:SetTextColor(0.9, 0.81, 0.67);

        local Text2 = self:CreateFontString(nil, "OVERLAY");
        self.Text2 = Text2;
        Text2:SetJustifyH("CENTER");
        SetupFont(Text2, 16);
        Text2:SetPoint("TOP", Text1, "BOTTOM", 0, -4);


        --[[
        local Banner = self:CreateTexture(nil, "ARTWORK");
        self.Banner = Banner;
        local bannerHeight = 48;
        local bannerRatio = 6;
        Banner:SetSize(bannerRatio * bannerHeight, 48);
        Banner:SetPoint("CENTER", self, "CENTER", 0, 0);
        Banner:SetTexCoord(0, 0.7617187, 0, 0.65625);

        local offsetH = 0.1;
        local coordV = (0.7617187 - 2 * offsetH)/bannerRatio/2;
        Banner:SetTexCoord(offsetH, 0.7617187 - offsetH, 0.65625/2 - coordV, 0.65625/2 + coordV)
        --]]


        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnMouseDown", self.OnMouseDown);
    end

    function DifficultyAnnouncer:Enable(state)
        if state then
            --self:RegisterEvent("RAID_INSTANCE_WELCOME");
            self:RegisterEvent("LOADING_SCREEN_DISABLED");
            self:SetScript("OnEvent", self.OnEvent);
            if not UpdateFrame then
                UpdateFrame = CreateFrame("Frame");
            end
        else
            self.instanceID = nil;
            self:Hide();
            --self:UnregisterEvent("RAID_INSTANCE_WELCOME");
            self:UnregisterEvent("LOADING_SCREEN_DISABLED");
            if UpdateFrame then
                UpdateFrame:SetScript("OnUpdate", nil);
            end
            self:SetScript("OnUpdate", nil);
        end
    end

    function DifficultyAnnouncer:OnEvent(event, ...)
        if event == "RAID_INSTANCE_WELCOME" then
            self:RequestUpdate();
        elseif event == "LOADING_SCREEN_DISABLED" then
            self:RequestUpdate();
        elseif event == "PLAYER_ENTERING_WORLD" then
            self:RequestUpdate();
        elseif event == "UPDATE_INSTANCE_INFO" then
            self:UpdateProgress();
        end
    end

    function DifficultyAnnouncer:OnShow()
        self:RegisterEvent("UPDATE_INSTANCE_INFO");
    end

    function DifficultyAnnouncer:OnHide()
        self:UnregisterEvent("UPDATE_INSTANCE_INFO");
        self.focused = false;
    end

    local function UpdateFrame_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        if self.t > 1 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            DifficultyAnnouncer:Refresh();
        end
    end

    function DifficultyAnnouncer:RequestUpdate()
        UpdateFrame.t = 0;
        UpdateFrame:SetScript("OnUpdate", UpdateFrame_OnUpdate);
    end

    local function FadeOut_OnUpdate(self, elapsed)
        self.alpha = self.alpha - 2 * elapsed;
        if self.alpha <= 0 then
            self:SetScript("OnUpdate", nil);
            self.alpha = 0;
            self:Hide();
        end
        self:SetAlpha(self.alpha);
    end

    function DifficultyAnnouncer:OnUpdate(elapsed)
        if not self.focused then
            self.t = self.t + elapsed;
        end
        if self.t > 4 then
            self.t = 0;
            self.alpha = self:GetAlpha();
            self:SetScript("OnUpdate", FadeOut_OnUpdate);
        end
    end

    function DifficultyAnnouncer:Refresh()
        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo();
        if instanceID == self.instanceID then
            return
        end

        if difficultyID and difficultyID > 0 and instanceID and instanceType and (instanceType == "raid" or instanceType == "party" or instanceType == "scenario") then
            --local difficultyName = API.GetRaidDifficultyString(difficultyID);
            self.instanceName = name;
            self.difficultyName = difficultyName;
            self.instanceID = instanceID;
            self.difficultyID = difficultyID;
            if self.Init then
                self:Init();
            end
            self.Text1:SetText(name);
            self.Text2:SetText(difficultyName);

            local journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(instanceID);
            if journalInstanceID then
                --EJ_SelectInstance(journalInstanceID);
                --local instanceName, description, bgImage, _, loreImage, buttonImage, dungeonAreaMapID, _, _, mapID, covenantID = EJ_GetInstanceInfo();
                --self.Banner:SetTexture(loreImage);
                self.encounters = GetInstanceEncounters(journalInstanceID, difficultyID);
            else
                self.encounters = nil;
            end

            RequestRaidInfo();
            self:UpdateProgress();
            self:SetAlpha(1);
            self:Show();
            self:StartHideCountdown();
        else
            self.difficultyName = nil;
            self.instanceID = nil;
            self:Hide();
            self.encounters = nil;
        end
    end

    function DifficultyAnnouncer:UpdateProgress()
        if self.encounters and self.difficultyName then
            local complete = 0;
            local total = #self.encounters;
            for _, v in ipairs(self.encounters) do
                if v.dungeonEncounterID and IsEncounterComplete(self.instanceID, v.dungeonEncounterID, self.difficultyID) then
                    complete = complete + 1;
                end
            end

            local colorIndex;
            if complete < total then
                colorIndex = 1;
            else
                colorIndex = 2;
            end
            self.Text2:SetText(string.format("%s  |cff%s(%d/%d)|r", self.difficultyName, ColorCodes[colorIndex], complete, total));
        end
    end

    function DifficultyAnnouncer:OnEnter()
        if self.encounters then
            ShowLockoutTooltip(self, self.instanceName, self.difficultyName, self.instanceID);
        end
        self.focused = true;
    end

    function DifficultyAnnouncer:OnLeave()
        GameTooltip:Hide();
        self.focused = false;
    end

    function DifficultyAnnouncer:OnMouseDown(button)
        if button == "RightButton" then
            self:Hide();
            if UpdateFrame then
                UpdateFrame:SetScript("OnUpdate", nil);
            end
        end
    end

    function DifficultyAnnouncer:StartHideCountdown()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    addon.CallbackRegistry:RegisterSettingCallback("InstanceDifficulty", function(state, userInput)
        if state and userInput then
            DifficultyAnnouncer:Refresh();
        end
    end);
end