local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;
local LandingPageUtil = addon.LandingPageUtil;
local TooltipUpdator = LandingPageUtil.TooltipUpdator;
local GetQuestProgressInfo = API.GetQuestProgressInfo;
local RemoveTextBeforeColon = API.RemoveTextBeforeColon;
local GetAchievementInfo = GetAchievementInfo;
local C_TaskQuest_IsActive = C_TaskQuest.IsActive;


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
    [90115] = {artifactTrackIndex = 1, actionIcon = 4667415},
    [92439] = {artifactTrackIndex = 2, actionIcon = 1413862},
    [92441] = {artifactTrackIndex = 3, actionIcon = 6891023},
    [92440] = {artifactTrackIndex = 4, actionIcon = 839979},
    [92442] = {artifactTrackIndex = 5, actionIcon = 1360764},


    --Emerald Nightmare
    [89644] = {lfgDungeonID = 2844},   --Darkbough, Il'gynoth
    [89665] = {lfgDungeonID = 2845},   --Tormented Guardians, Cenarius
    [89676] = {lfgDungeonID = 2846},   --Rift of Aln
    [89680] = {openGroupFinder = true}, --The Emerald Nightmare, Mythic
    [89679] = {openGroupFinder = true}, --The Emerald Nightmare, Heroic
    [89677] = {openGroupFinder = true}, --The Emerald Nightmare, Normal


    --Trial of Valor
    [89681] = {lfgDungeonID = 2851},   --Trial of Valor
    [89597] = {openGroupFinder = true}, --Trial of Valor, Mythic
    [89596] = {openGroupFinder = true}, --Trial of Valor, Heroic
    [89682] = {openGroupFinder = true}, --Trial of Valor, Normal


    --Nighthold
    [89678] = {lfgDungeonID = 2847},   --Arcing Aqueducts
    [89683] = {lfgDungeonID = 2848},   --Royal Athenaeum
    [89693] = {lfgDungeonID = 2849},   --Nightspire
    [89594] = {lfgDungeonID = 2850},   --Betrayer's Rise
    [89600] = {openGroupFinder = true}, --Nighthold, Mythic
    [89599] = {openGroupFinder = true}, --Nighthold, Heroic
    [89598] = {openGroupFinder = true}, --Nighthold, Normal


    --Tomb
    [89604] = {lfgDungeonID = 2835},   --The Gates of Hell
    [89605] = {lfgDungeonID = 2836},   --Wailing Halls
    [89606] = {lfgDungeonID = 2837},   --Chamber of the Avatar
    [89607] = {lfgDungeonID = 2838},   --Deceiver's Fall
    [89603] = {openGroupFinder = true}, --Tomb of Sargeras, Mythic
    [89602] = {openGroupFinder = true}, --Tomb of Sargeras, Heroic
    [89622] = {openGroupFinder = true}, --Tomb of Sargeras, Normal


    --Antorus
    [89466] = {lfgDungeonID = 2821},   --Light's Breach
    [89467] = {lfgDungeonID = 2822},   --Forbidden Descent
    [89590] = {lfgDungeonID = 2823},   --Hope's End
    [89591] = {lfgDungeonID = 2823},   --Seat of the Pantheon
    [89601] = {openGroupFinder = true}, --Antorus, the Burning Throne, Mythic
    [89595] = {openGroupFinder = true}, --Antorus, the Burning Throne, Heroic
    [89592] = {openGroupFinder = true}, --Antorus, the Burning Throne, Normal
};

local SpecialAssignments = {
    --Not part of the meta quest line. One-off?
    93112, 93113, 93114, 93116, 93117, 93118, 93120,

    --Artifact Ability too?
    90115, 92439, 92440, 92441, 92442,
};

local WorldBosses = {
    --[QuestID] = {Info},   --We get the creature name from achievement

    [43513] = {uiMapID = 680, achievementID = 42637},   --Na'zak the Fiend, Suramar
    [43512] = {uiMapID = 680, achievementID = 42559},   --Ana-Mouz, Suramar

    [43192] = {uiMapID = 630, achievementID = 42527},   --Levantus, Terror of the Deep, Azsuna
    [44287] = {uiMapID = 630, achievementID = 42669},   --Withered J'im, DEADLY: Withered J'im, Azsuna
    [43193] = {uiMapID = 630, achievementID = 42526},   --Calamir, Calamitous Intent, Azsuna

    [43448] = {uiMapID = 650, achievementID = 42542},   --Drugon the Frostblood, The Frozen King, Highmountain

    [42779] = {uiMapID = 641, achievementID = 42659},   --Shar'thos, The Sleeping Corruption, Val'sharah
    [42819] = {uiMapID = 641, achievementID = 42529},   --Humongris, Pocket Wizard, Val'sharah

    [42269] = {uiMapID = 634, achievementID = 42610},   --The Soultakers, Stormheim
    [42270] = {uiMapID = 634, achievementID = 42536},   --Nithogg, Scourge of the Skies, Stormheim

    --Broken Shore bosses use new questIDs
    [91790] = {uiMapID = 646, achievementID = 42643},   --Brutallus, Broken Shore
    [91791] = {uiMapID = 646, achievementID = 42629},   --Malificus, Broken Shore
    [91792] = {uiMapID = 646, achievementID = 42530},   --Si'vash, Broken Shore
    [91789] = {uiMapID = 646, achievementID = 42662},   --Apocron, Broken Shore
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


local function GetInfoFromAchievement(achievementID)
    local _, name, _, completed = GetAchievementInfo(achievementID);
    return name, completed
end


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
        self.UnlockText:ClearAllPoints();

        if nextUpgradeInfo.traitName then
            --From top to bottom: X to unlock, Rank 1, Artifact Trait
            self.Title:SetText(nextUpgradeInfo.traitName);
            self.UnlockText:SetText(nextUpgradeInfo.line1);
            if nextUpgradeInfo.isLocked then    --Requires Lv.80

            end
            self.UnlockText:SetPoint("TOP", self.ProgressDisplay, "BOTTOM", 0, -24);
            self.Title:SetPoint("TOP", self.UnlockText, "BOTTOM", 0, -6);
            self.Title:SetText(nextUpgradeInfo.line2);
            if nextUpgradeInfo.line2 == "" then
                self:RequestUpdate();
            end
        else
            self.Title:SetText(L["Fully Upgraded"]);
            self.UnlockText:SetText("");
            self.Title:SetPoint("TOP", self.ProgressDisplay, "BOTTOM", 0, -24);
        end
    end

    function NextTraitFrameMixin:OnShow()
        self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
        self:RegisterEvent("TRAIT_CONFIG_UPDATED");
        self:Refresh();
    end

    function NextTraitFrameMixin:OnHide()
        self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
        self:UnregisterEvent("TRAIT_CONFIG_UPDATED");
    end

    function NextTraitFrameMixin:OnEvent(event, ...)
        if event == "CURRENCY_DISPLAY_UPDATE" then
            local currencyID = ...
            if currencyID == 3268 then
                self:RequestUpdate();
            end
        elseif event == "TRAIT_CONFIG_UPDATED" then
            self:RequestUpdate();
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
        ProgressDisplay:RegisterForClicks("LeftButtonUp", "RightButtonUp");

        function ProgressDisplay:ShowTooltip()

        end

        function ProgressDisplay.onClickFunc(self, button)
            if button == "RightButton" and IsShiftKeyDown() and (not InCombatLockdown()) then
                SocketInventoryItem(16);
                return
            end

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

        for i = 1, 2 do
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
        f.UnlockText = fontStrings[2];

        local frameHeight = paddingV + 1.25 * ProgressDisplay:GetHeight() + firstTextToProgressBar + 14 + 6 + 12 + paddingV + 8;
        f:SetSize(256, frameHeight);

        f.infoGetter = addon.RemixAPI and addon.RemixAPI.GetNextTraitForUpgrade or nil;

        return f, frameHeight
    end
    LandingPageUtil.LegionRemixCreateNextTraitFrame = CreateNextTraitFrame;
end


local ExecuteButtonMode = {
    Artifact = 1,
    QueueLFG = 2,
    GroupFinder = 3,
    OpenMap = 4,
};

local ExecuteButtonMixin = {};
do  --A button on the right of the ListButton. Perform actions like like changing artifact ability or queue LFR
    local InCombatLockdown = InCombatLockdown;


    function ExecuteButtonMixin:OnEnter()
        self:UpdateVisual();
        self:GetParent():HideTooltip();
        self:GetParent():UpdateVisual();
        self:ShowTooltip();
    end

    function ExecuteButtonMixin:OnLeave()
        self:UpdateVisual();
        GameTooltip:Hide();
        if self:IsVisible() and self:GetParent():IsMouseMotionFocus() then
            self:GetParent():OnEnter();
        else
            self:GetParent():UpdateVisual();
        end
    end

    function ExecuteButtonMixin:UpdateVisual()
        if self.enabled then
            if self:IsMouseMotionFocus() then
                self.Highlight:Show();
                self.Text:SetTextColor(1, 1, 1);
            else
                self.Highlight:Hide();
                self.Text:SetTextColor(1, 0.82, 0);
            end
        else
            self.Highlight:Hide();
            self.Text:SetTextColor(0.5, 0.5, 0.5);
        end
    end

    function ExecuteButtonMixin:ShowTooltip()
        if self.tooltip then
            local tooltip = GameTooltip;
            tooltip:SetOwner(self, "ANCHOR_RIGHT");
            tooltip:SetText(self.tooltip, 1, 0.82, 0, 1, true);
            tooltip:Show();
        elseif self.mode == ExecuteButtonMode.QueueLFG then
            LandingPageUtil.GetQueueStatus();
        else
            GameTooltip:Hide();
        end
    end

    function ExecuteButtonMixin:OnMouseDown()
        if self.enabled then
            PlumberExpansionLandingPage:Lower();
            self.Text:SetPoint("CENTER", self, "CENTER", 0, -1);
        end
    end

    function ExecuteButtonMixin:OnMouseUp()
        self.Text:SetPoint("CENTER", self, "CENTER", 0, 0);
    end

    function ExecuteButtonMixin:OnClick()
        if self.onClickFunc then
            self.onClickFunc();
        end
    end

    function ExecuteButtonMixin:OnDoubleClick()

    end

    function ExecuteButtonMixin:Update()

    end

    function ExecuteButtonMixin:OnHide()
        self:SetScript("OnUpdate", nil);
        self.t = 0;
    end

    function ExecuteButtonMixin:ListenEvents(state)
        if not state then
            if self.hasEvents then
                self.hasEvents = nil;
                self:UnregisterAllEvents();
            end
        end
    end

    function ExecuteButtonMixin:OnEvent(event, ...)
        self:RequestUpdate();
    end

    function ExecuteButtonMixin:RequestUpdate()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function ExecuteButtonMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.2 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            self:Update();
            if self:IsMouseMotionFocus() then
                self:ShowTooltip();
            end
        end
    end

    do  --Actions
        function ExecuteButtonMixin:SetArtifactTrack(artifactTrackIndex)
            self.mode = ExecuteButtonMode.Artifact;
            self.artifactTrackIndex = artifactTrackIndex;
            self:RegisterEvent("TRAIT_CONFIG_UPDATED");
            self.hasEvents = true;
            self.Update = self.UpdateArtifactTrack;
            self:Update();
            self.onClickFunc = function()
                addon.RemixAPI.ActivateArtifactTrack(artifactTrackIndex);
            end
        end

        function ExecuteButtonMixin:UpdateArtifactTrack()
            local index = addon.RemixAPI.GetActiveArtifactTrackIndex();
            if self.artifactTrackIndex and self.artifactTrackIndex ~= index then
                self.enabled = true;
                self.Text:SetText(SWITCH);
                local spellName = addon.RemixAPI.GetArtifactTrackName(self.artifactTrackIndex);
                self.tooltip = L["Click To Switch"]:format(spellName);
            else
                self.enabled = false;
                self.Text:SetText(SPEC_ACTIVE);
                self.tooltip = nil;
            end
            self:UpdateVisual();
        end

        function ExecuteButtonMixin:SetQueueLFG(lfgDungeonID)
            self.mode = ExecuteButtonMode.QueueLFG;
            self.lfgDungeonID = lfgDungeonID;
            self:RegisterEvent("LFG_UPDATE");
            self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE");
            self.hasEvents = true;
            self.Update = self.UpdateQueueLFG;
            self:Update();
            self.onClickFunc = function()
                LandingPageUtil.TryJoinLFG(lfgDungeonID);

                --[[
                    if not RaidFinderFrame:IsVisible() then
                        PVEFrame_ShowFrame("GroupFinderFrame", RaidFinderFrame);
                    end
                    RaidFinderQueueFrame_SetRaid(lfgDungeonID);
                    PlumberExpansionLandingPage:Lower();
                    --]]
                --]]
            end
        end

        function ExecuteButtonMixin:UpdateQueueLFG()
            self.Text:SetText(L["Join Queue"]);
            local disabledReason = LandingPageUtil.GetLFGDisabledReason();
            if disabledReason then
                self.enabled = false;
                self.tooltip = disabledReason;
            elseif LandingPageUtil.IsQueuingDungeon(self.lfgDungeonID) then
                self.enabled = false;
                self.tooltip = nil;
                self.Text:SetText(L["In Queue"]);
            else
                self.enabled = true;
                local raidName = GetLFGDungeonInfo(self.lfgDungeonID);
                self.tooltip = L["Click To Queue"]:format(raidName or RAID);
            end
            self:UpdateVisual();
        end

        function ExecuteButtonMixin:SetGroupFinder()
            self.mode = ExecuteButtonMode.GroupFinder;
            self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED");
            self.hasEvents = true;
            self.Update = self.UpdateGroupFinder;
            self:Update();
            self.onClickFunc = function()
                if not LFGListPVEStub:IsVisible() then
                    if not InCombatLockdown() then
                        PVEFrame_ShowFrame("GroupFinderFrame", LFGListPVEStub);
                    end
                end
            end
        end

        function ExecuteButtonMixin:UpdateGroupFinder()
            self.Text:SetText(DUNGEONS_BUTTON);
            if InCombatLockdown() then
                self.enabled = false;
                self.tooltip = nil;
            else
                self.enabled = true;
                self.tooltip = L["Click to Open Format"]:format(DUNGEONS_BUTTON);
            end
            self:UpdateVisual();
        end

        function ExecuteButtonMixin:SetOpenMap(uiMapID)
            self.mode = ExecuteButtonMode.OpenMap;
            self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED");
            self.hasEvents = true;
            self.Update = self.UpdateOpenMap;
            self:Update();
            self.onClickFunc = function()
                if not InCombatLockdown() then
                    C_Map.OpenWorldMap(uiMapID);
                end
            end
        end

        function ExecuteButtonMixin:UpdateOpenMap()
            self.Text:SetText(SHOW_MAP);
            self.tooltip = nil;
            if InCombatLockdown() then
                self.enabled = false;
            else
                self.enabled = true;
            end
            self:UpdateVisual();
        end
    end
end


local CreateQuestListButton;
do  --List Button
    local QuestIcons = {
        InProgress = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png",
        Boss = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/TrackerType-Boss.png",
    };

    local ListButtonMixin = {};

    function ListButtonMixin:OnEnter()
        self:UpdateVisual();

        if not self.ExecuteButton:IsMouseMotionFocus() then
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
        self.ExecuteButton:Hide();
        self.ExecuteButton:UnregisterAllEvents();
    end

    function ListButtonMixin:MuteExecuteButton()
        self.ExecuteButton:ListenEvents(false);
    end

    function ListButtonMixin:ShouldShowHighlight()
        return self:IsMouseMotionFocus() or self.ExecuteButton:IsMouseMotionFocus()
    end

    function ListButtonMixin:SetQuestHeader(questID)
        self:SetWidth(606);
        self.questID = questID;

        local overrideName, achievementID;
        local extraInfo = QuestInfoExtra[questID];
        if extraInfo then
            achievementID = extraInfo.achievementID;
        end
        self.achievementID = achievementID;

        local highPriority;
        if achievementID then
            local name, completed = GetInfoFromAchievement(achievementID);
            overrideName = name;
            if not completed then
                highPriority = true;
            end
            if extraInfo.uiMapID then
                local mapName = API.GetMapName(extraInfo.uiMapID);
                if overrideName and mapName then
                    overrideName = overrideName..", "..mapName;
                end
            end
        end

        local questName = overrideName or API.GetQuestName(questID);
        if questName then
            local abbrName = RemoveTextBeforeColon(questName) or questName;
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

        local checkExecuteButton;

        if self.completed then
            self.Icon:SetAtlas("checkmark-minimal-disabled");
        elseif self.readyForTurnIn then
            self.Icon:SetAtlas("QuestTurnin");
        else
            checkExecuteButton = true;
            if extraInfo and extraInfo.isBoss then
                self.Icon:SetTexture(QuestIcons.Boss);
            else
                self.Icon:SetTexture(QuestIcons.InProgress);
            end
        end

        local buttonMode;
        self.ExecuteButton.onClickFunc = nil;

        if checkExecuteButton and extraInfo and not (self.completed or self.readyForTurnIn) then
            if extraInfo.artifactTrackIndex then
                buttonMode = ExecuteButtonMode.Artifact;
            elseif extraInfo.lfgDungeonID then
                buttonMode = ExecuteButtonMode.QueueLFG;
            elseif extraInfo.openGroupFinder then
                buttonMode = ExecuteButtonMode.GroupFinder;
            elseif extraInfo.openMap and extraInfo.uiMapID then
                buttonMode = ExecuteButtonMode.OpenMap;
            end
        end

        if buttonMode then
            if buttonMode == ExecuteButtonMode.Artifact then
                self.ExecuteButton:SetArtifactTrack(extraInfo.artifactTrackIndex);
            elseif buttonMode == ExecuteButtonMode.QueueLFG then
                local lfgDungeonID = QuestInfoExtra[questID].lfgDungeonID;
                self.ExecuteButton:SetQueueLFG(lfgDungeonID);
            elseif buttonMode == ExecuteButtonMode.GroupFinder then
                self.ExecuteButton:SetGroupFinder();
            elseif buttonMode == ExecuteButtonMode.OpenMap then
                self.ExecuteButton:SetOpenMap(extraInfo.uiMapID);
            end
            self.ExecuteButton:Show();
        else
            self.ExecuteButton:Hide();
        end

        self:ShowGlow(highPriority);
    end

    function ListButtonMixin:SetObjective(objectiveText)
        self.questID = nil;
        self.achievementID = nil;
        self:SetWidth(606 - 44);  --60
        self.Icon:Hide();
        self.SetDefaultTextColor = ListButtonMixin.SetDefaultTextColor;
        if objectiveText then
            objectiveText = "- "..objectiveText;
        end
        self.Name:SetText(objectiveText);
        self:Layout();
        self:UpdateVisual();
        self:ShowGlow(false);
    end

    function ListButtonMixin:ShowTooltip()
        TooltipUpdator:SetFocusedObject(self);
        TooltipUpdator:SetHeaderText(self.Name:GetText());
        TooltipUpdator:SetQuestID(self.questID);
        TooltipUpdator:RequestQuestProgress();
        TooltipUpdator:RequestQuestDescription();
        TooltipUpdator:RequestAchievementID(self.achievementID);
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


        local buttonWidth = 120;
        local eb = CreateFrame("Button", nil, f);
        f.ExecuteButton = eb;
        eb:Hide();
        API.Mixin(eb, ExecuteButtonMixin);
        eb:SetSize(buttonWidth, 25);
        eb:SetPoint("RIGHT", f, "RIGHT", 0, 0);

        local bg1 = eb:CreateTexture(nil,  "BACKGROUND");
        bg1:SetSize(32, 32);
        bg1:SetPoint("LEFT", eb, "LEFT", -24, 0);
        local bg2 = eb:CreateTexture(nil,  "BACKGROUND");
        bg2:SetHeight(32);
        bg2:SetPoint("LEFT", bg1, "RIGHT", 0, 0);
        bg2:SetPoint("RIGHT", f, "RIGHT", 0, 0);
        local file = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/ChecklistButton.tga";
        bg1:SetTexture(file);
        bg2:SetTexture(file);
        bg1:SetTexCoord(0, 64/512, 416/512, 480/512);
        bg2:SetTexCoord(64/512, 192/512, 416/512, 480/512);

        eb.Highlight = eb:CreateTexture(nil,  "ARTWORK");
        eb.Highlight:Hide();
        eb.Highlight:SetSize(96, 32);
        eb.Highlight:SetTexture(file);
        eb.Highlight:SetBlendMode("ADD");
        eb.Highlight:SetAlpha(0.1);
        eb.Highlight:SetTexCoord(232/512, 424/512, 416/512, 480/512);
        eb.Highlight:SetPoint("LEFT", eb, "LEFT", -24, 0);

        eb.Text = eb:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        eb.Text:SetWidth(buttonWidth - 12);
        eb.Text:SetMaxLines(1);
        eb.Text:SetPoint("CENTER", eb, "CENTER", 0, 0);
        eb.Text:SetTextColor(1, 0.82, 0);

        --eb.Icon = eb:CreateTexture(nil, "OVERLAY");
        --eb.Icon:SetSize(18, 18);
        --eb.Icon:SetPoint("CENTER", eb, "CENTER", 0, 0);

        eb:SetScript("OnEnter", eb.OnEnter);
        eb:SetScript("OnLeave", eb.OnLeave);
        eb:SetScript("OnClick", eb.OnClick);
        eb:SetScript("OnDoubleClick", eb.OnDoubleClick);
        eb:SetScript("OnMouseDown", eb.OnMouseDown);
        eb:SetScript("OnMouseUp", eb.OnMouseUp);
        eb:SetScript("OnHide", eb.OnHide);
        eb:SetScript("OnEvent", eb.OnEvent);

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
        self.ScrollView:CallObjectMethod("ListButton", "MuteExecuteButton");
    end

    function ActivityTabMixin:OnEvent(event, ...)
        self:RequestUpdate();
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
        local hideFinishedObjectives = true;

        local buttonHeight = 24;
        local gap = 4;
        local offsetY = 2;
        local top, bottom;

        local index = 0;
        local m = 0;
        local numCompleted = 0;
        local numReadyForTurnIn = 0;
        local extraInfo;

        local highPriorityIndexOffset = -1000;

        for i, questID in ipairs(QuestIDList) do
            if not IgnoredQuests[questID] then
                index = i;
                extraInfo = QuestInfoExtra[questID];
                local progressInfo = GetQuestProgressInfo(questID, hideFinishedObjectives);


                showActivity = progressInfo.isOnQuest or (progressInfo.isComplete and showCompleted);

                if extraInfo and extraInfo.isTaskQuest and (not progressInfo.isComplete) and C_TaskQuest_IsActive(questID)  then
                    showActivity = true;
                    index = i + highPriorityIndexOffset;
                end

                if extraInfo and extraInfo.shownIfOnQuest and not progressInfo.isOnQuest then
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

                local objectives = progressInfo.objectives;
                if objectives and #objectives > 0 then
                    for i = 1, #objectives do
                        n = n + 1;
                        local isOdd = n % 2 == 0;
                        top = offsetY;
                        bottom = offsetY + buttonHeight + gap;
                        offsetY = bottom;
                        content[n] = {
                            templateKey = "ListButton",
                            setupFunc = function(obj)
                                obj.isOdd = isOdd;
                                obj:SetObjective(objectives[i].text);
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

        local retainPosition;
        if showCompleted ~= self.showCompleted then
            self.showCompleted = showCompleted;
            retainPosition = false;
        else
            retainPosition = true;
        end

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
        ScrollView:SetShowNoContentAlert(true);

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
            if QuestInfoExtra[questID] then
                QuestInfoExtra[questID].shownIfOnQuest = true;
            else
                QuestInfoExtra[questID] = {
                    shownIfOnQuest = true,
                };
            end
        end

        for questID, info in pairs(WorldBosses) do
            table.insert(QuestIDList, questID);
            info.openMap = true;
            info.isTaskQuest = true;
            info.isBoss = true;
            QuestInfoExtra[questID] = info;
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
        786,    --Nighthold
        875,    --Tomb
        946,    --Antorus
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


                --Set EncounterJournal epansion to Legion
                hooksecurefunc(C_EncounterJournal, "InitalizeSelectedTier", function()
                    --This API reset selected tier to Current Season, see EncounterJournal_OnShow
                    EJ_SelectTier(7)
                end);
            end
        end
    end);
end