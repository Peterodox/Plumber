local _, addon = ...
local RemixAPI = addon.RemixAPI
if not RemixAPI then return end;


local ACTIVE_TRACK_INDEX = 1;


local L = addon.L;
local API = addon.API;
local CallbackRegistry = addon.CallbackRegistry;
local DataProvider = RemixAPI.DataProvider;
local CommitUtil = RemixAPI.CommitUtil;
local Easing_OutQuart = addon.EasingFunctions.outQuart;


local ipairs = ipairs;
local InCombatLockdown = InCombatLockdown;


local TEXTURE_FILE = "Interface/AddOns/Plumber/Art/Timerunning/LegionRemixUI.png";


local MainFrame;


local Constants = {
    NodeSize = 40,
    NodeGap = 4,
    ThreeArrowsSize = 24,

    CardWidth = 732,
    CardHeight = 108,
    CardBGWidth = 768,
    CardBGHeight = 160,
    CardDivWidth = 32,
    CardDivHeight = 96,
    CardScale = 0.8,

    White = {0.88, 0.88, 0.88},
    FelGreenBright = {220/255, 231/255, 96/255},

    HeaderWidth = 444,
    HeaderHeight = 96,
    HeaderBGWidth = 512,
    HeaderBGHeight = 192,
};


local function SetFontStringColor(fontString, key)
    local color = Constants[key];
    fontString:SetTextColor(color[1], color[2], color[3]);
end

local function AddLine(oldText, newText)
    if oldText then
        return oldText.."\n"..newText
    else
        return newText
    end
end

local function SharedFadeIn_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    local alpha = 8 * self.t;
    if alpha > 1 then
        alpha = 1;
        self:SetScript("OnUpdate", nil);
        self.t = 0;
    end
    self:SetAlpha(alpha);
end


local NodeButtonMixin = {};
do
    function NodeButtonMixin:OnLoad()
        self.Border:SetTexture(TEXTURE_FILE);
        self.GreenGlow:SetTexture(TEXTURE_FILE);
        self.Sheen:SetTexture(TEXTURE_FILE);
        self:SetSquare();
        self.Icon:SetTexCoord(4/64, 60/64, 4/64, 60/64);
        self.Border:SetSize(64, 64);
        self.Icon:SetSize(36, 36);
        self.IconMask:SetSize(36, 36);
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnDragStart", self.OnDragStart);


        local function AnimSheen_OnPlay()
            self.SheenMask:Show();
            self.Sheen:Show();
        end

        local function AnimSheen_OnStop()
            self.SheenMask:Hide();
            self.Sheen:Hide();
        end

        self.AnimSheen:SetScript("OnPlay", AnimSheen_OnPlay);
        self.AnimSheen:SetScript("OnFinished", AnimSheen_OnStop);
        self.AnimSheen:SetScript("OnStop", AnimSheen_OnStop);
    end

    function NodeButtonMixin:OnEnter()
        MainFrame:HoverNode(self);
    end

    function NodeButtonMixin:OnLeave()
        MainFrame:HideTooltip();
        MainFrame:HoverNode();

        if self.nodeChoices or self.isFlyoutButton then
            if not MainFrame:IsNodeFlyoutFocused(self) then
                MainFrame:CloseNodeFlyout();
            end
        end
    end

    function NodeButtonMixin:OnClick()
        --Only FlyoutButton is clickable
        if not self.isFlyoutButton then return end;

        MainFrame:CloseNodeFlyout();

        local parentNodeButton = self.parentNodeButton;
        if not parentNodeButton then return end;

        local shouldPlaySheen;
        if (parentNodeButton.entryID ~= self.entryID) and parentNodeButton.isActive then
            shouldPlaySheen = true;
        end
        DataProvider:SaveLastSelectedEntryID(self.nodeID, self.entryID);
        parentNodeButton.selectedEntryID = self.entryID;
        parentNodeButton:SetData(self.nodeID, self.entryID, self.definitionID);    --debug
        parentNodeButton:Refresh();
        if shouldPlaySheen then
            parentNodeButton:PlaySheen();
        end
    end

    function NodeButtonMixin:OnFocused()
        self:ShowTooltip();

        if self.nodeChoices then
            MainFrame:ShowNodeFlyout(self);
        end
    end

    function NodeButtonMixin:SetSquare()
        self.entryType = 1;
        self.IconMask:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Chamfer", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        self.Icon:Show();
        self.IconMask:Show();
    end

    function NodeButtonMixin:SetCircle()
        self.entryType = 2;
        self.IconMask:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Circle", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        self.Icon:Show();
        self.IconMask:Show();
    end

    function NodeButtonMixin:SetHex()
        self.entryType = 0;
        self.IconMask:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Hexagon", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        self.Icon:Show();
        self.IconMask:Show();
        self.GreenGlow:SetTexCoord(768/1024, 928/1024, 416/1024, 576/1024);
        self.Sheen:SetTexCoord(768/1024, 928/1024, 576/1024, 736/1024);
        self.SheenMask:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/Mask-Halo", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
    end

    function NodeButtonMixin:SetSpell(spellID)
        local iconID, originalIconID = C_Spell.GetSpellTexture(spellID);
        self.Icon:SetTexture(originalIconID or iconID);
        self.spellID = spellID;
    end

    function NodeButtonMixin:SetData(nodeID, entryID)
        self.nodeID = nodeID;
        local nodeInfo = DataProvider:GetNodeInfo(nodeID);
        if nodeInfo.type == 2 then  --Enum.TraitNodeType.Selection
            self:SetHex();
        end
        self:SetEntry(entryID);
    end

    function NodeButtonMixin:SetEntry(entryID)
        self.entryID = entryID;
        local entryInfo = DataProvider:GetEntryInfo(entryID);
        self.definitionID = entryInfo.definitionID;
        self.maxRanks = entryInfo.maxRanks;

        if self.entryType ~= 0 then
            if entryInfo.type == 1 then --SpendSquare
                self:SetSquare();
            elseif entryInfo.type == 2 then --SpendCircle
                self:SetCircle();
            end
        end

        local spellID = C_Traits.GetDefinitionInfo(self.definitionID).spellID;
        self:SetSpell(spellID);
        if self.Title then
            CallbackRegistry:LoadSpell(spellID, function()
                local name = C_Spell.GetSpellName(spellID);
                self.Title:SetText(name);
            end);
        end
    end

    function NodeButtonMixin:SetNodeChoices(nodeID, entryIDs)
        local entryID = entryIDs[1];   --debug
        self:SetData(nodeID, entryID);
        self.entryIDs = entryIDs;
        self.nodeChoices = {};
        for i = 1, #entryIDs do
            self.nodeChoices[i] = {nodeID, entryIDs[i]}
        end
    end

    function NodeButtonMixin:Refresh()
        if self.entryIDs then
            self:Refresh_SelectionNode();
            return
        end

        local nodeInfo = DataProvider:GetNodeInfo(self.nodeID);
        if not nodeInfo then return end;

        local currentRank = nodeInfo.currentRank or 0;
        local ranksPurchased = nodeInfo.ranksPurchased or 0;
        local committedEntryID;

        if self.isFlyoutButton then
            if nodeInfo.entryIDToRanksIncreased then
                for _entryID, totalIncreased in pairs(nodeInfo.entryIDToRanksIncreased) do
                    if _entryID == self.entryID then
                        if currentRank == 0 then
                            currentRank = totalIncreased;
                        end
                        break
                    end
                end
            end

            local isEntryCommitted = false;
            if nodeInfo.entryIDsWithCommittedRanks then
                for _, id in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
                    committedEntryID = id;
                    isEntryCommitted = true;
                    break
                end
            end
        end

        local isActive = (self.trackIndex == ACTIVE_TRACK_INDEX) and ranksPurchased > 0;
        self.isActive = isActive;
        local isPurchased;
        local visualState;
        local rankText;

        if self.entryIDs then
            --Selection Node
            local isEntryCommitted = false;
            if nodeInfo.entryIDsWithCommittedRanks then
                for _, id in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
                    committedEntryID = id;
                    isEntryCommitted = true;
                    break
                end
            end

            if not isEntryCommitted then
                if nodeInfo.entryIDToRanksIncreased then
                    for _entryID, totalIncreased in pairs(nodeInfo.entryIDToRanksIncreased) do
                        if _entryID == self.entryID then
                            if currentRank == 0 then
                                currentRank = totalIncreased;
                            end
                            break
                        end
                    end
                end
            end

            if committedEntryID then
                self.selectedEntryID = committedEntryID;
            else
                local selectedEntryID, saved = DataProvider:GetLastSelectedEntryID(self.nodeID, self.entryIDs);
                if saved then
                    self.selectedEntryID = selectedEntryID;
                end
            end
        end

        if not (isActive or currentRank > 0) then
            visualState = 0;
        else
            if self.isFlyoutButton then
                isPurchased = committedEntryID == self.entryID;
                if isPurchased or (currentRank > 0 and not isActive) then
                    visualState = 1;
                else
                    visualState = 2;
                end
            else
                if self.entryType == 0 then
                    if self.selectedEntryID then
                        visualState = 1;
                    else
                        visualState = 2;
                    end
                else
                    visualState = 1;
                end
            end
        end

        self:SetVisualState(visualState);

        if isActive or currentRank > 0 then
            if self.entryType == 1 then
                rankText = currentRank;
            elseif self.entryType == 2 then
                rankText = currentRank;
            elseif self.entryType == 0 then
                if self.selectedEntryID then
                    self.GreenGlow:Hide();
                else
                    self.GreenGlow:Show();
                end
            end
            if self.isFlyoutButton and not isPurchased then
                rankText = currentRank;
                if isActive then
                    self.RankText:SetTextColor(0.098, 1.000, 0.098);
                elseif currentRank > 0 then
                    self.RankText:SetTextColor(1, 0.82, 0);
                end
            else
                self.RankText:SetTextColor(1, 0.82, 0);
            end
        else

        end
        self.RankText:SetText(rankText);
    end

    function NodeButtonMixin:Refresh_SelectionNode()
        local nodeInfo = DataProvider:GetNodeInfo(self.nodeID);
        if not nodeInfo then return end;

        local currentRank = nodeInfo.currentRank or 0;
        local ranksPurchased = nodeInfo.ranksPurchased or 0;
        local activeEntryID;
        local committedEntryID;
        local rankText;

        local isEntryCommitted = false;
        if nodeInfo.entryIDsWithCommittedRanks then
            for _, id in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
                committedEntryID = id;
                activeEntryID = id;
                isEntryCommitted = true;
                break
            end
        end

        if not isEntryCommitted then
            if nodeInfo.entryIDToRanksIncreased then
                for _entryID, totalIncreased in pairs(nodeInfo.entryIDToRanksIncreased) do
                    if totalIncreased > 0 then
                        activeEntryID = _entryID;
                        currentRank = totalIncreased;
                        break
                    end
                end
            end
        end

        if committedEntryID then
            self.selectedEntryID = committedEntryID;
        else
            local selectedEntryID, saved = DataProvider:GetLastSelectedEntryID(self.nodeID, self.entryIDs);
            if saved then
                self.selectedEntryID = selectedEntryID;
            end
        end

        local visualState;

        if activeEntryID then
            self:SetEntry(activeEntryID);
            visualState = 1;
            rankText = currentRank;
            self.RankText:SetTextColor(1, 0.82, 0);
        elseif self.selectedEntryID then
            self:SetEntry(self.selectedEntryID);
            visualState = 0;
            rankText = "";
        else
            rankText = "";
            if self.trackIndex == ACTIVE_TRACK_INDEX then
                visualState = 2;
            else
                visualState = 0;
            end
        end
        self:SetVisualState(visualState);
        self.RankText:SetText(rankText);
    end

    function NodeButtonMixin:SetVisualState(visualState)
        --0:Disabled  1:Yellow  2:Green

        self.visualState = visualState;
        local disabled = visualState == 0;

        if disabled then
            self.Icon:SetDesaturated(true);
            self.Icon:SetVertexColor(0.8, 0.8, 0.8);
            self.GreenGlow:Hide();
        else
            self.Icon:SetDesaturated(false);
            self.Icon:SetVertexColor(1, 1, 1);
        end

        if self.entryType == 1 then
            if disabled then
                self.Border:SetTexCoord(384/1024, 512/1024, 0/1024, 128/1024);
            elseif visualState == 2 then
                self.Border:SetTexCoord(0/1024, 128/1024, 128/1024, 256/1024);
            else
                self.Border:SetTexCoord(0/1024, 128/1024, 0/1024, 128/1024);
            end
        elseif self.entryType == 2 then
            if disabled then
                self.Border:SetTexCoord(512/1024, 640/1024, 0/1024, 128/1024);
            elseif visualState == 2 then
                self.Border:SetTexCoord(128/1024, 256/1024, 128/1024, 256/1024);
            else
                self.Border:SetTexCoord(128/1024, 256/1024, 0/1024, 128/1024);
            end
        elseif self.entryType == 0 then
            if disabled then
                self.Border:SetTexCoord(896/1024, 1024/1024, 128/1024, 256/1024);
            elseif visualState == 2 then
                self.Border:SetTexCoord(256/1024, 384/1024, 128/1024, 256/1024);
            else
                self.Border:SetTexCoord(768/1024, 896/1024, 128/1024, 256/1024);
            end
        end
    end

    function NodeButtonMixin:PlaySheen()
        self.AnimSheen:Stop();
        self.AnimSheen:Play();
        PlaySound(SOUNDKIT.UI_CLASS_TALENT_APPLY_COMPLETE);
    end

    function NodeButtonMixin:DebugGetNodeInfo()
        local nodeInfo = {
            currentRank = 0,
            maxRanks = self.maxRanks or 1,
        }
        return nodeInfo
    end

    function NodeButtonMixin:ShowTooltip()
        if self.nodeChoices then
            self.UpdateTooltip = nil;
            return
        end


        local spellID = self.spellID;
        --local overrideSpellID = C_Spell.GetOverrideSpell(spellID);
        --[[
        local spell = Spell:CreateFromSpellID(spellID);
        if not spell:IsSpellDataCached() then
            self.spellLoadCancel = spell:ContinueWithCancelOnSpellLoad(GenerateClosure(self.ShowTooltip, self));
        end
        --]]

        --[[
        local definitionInfo = C_Traits.GetDefinitionInfo(self.definitionID);
        if definitionInfo.overrideSubtext then
            tooltip:AddLine(definitionInfo.overrideSubtext, 1, 1, 1, true);
        end
        if definitionInfo.overrideDescription then
            tooltip:AddLine(definitionInfo.overrideDescription, 1, 1, 1, true);
        end
        --]]


        local name = C_Spell.GetSpellName(spellID);
        if not name then
            name = RETRIEVING_DATA;
        end

        local nodeInfo = DataProvider:GetNodeInfo(self.nodeID) or self:DebugGetNodeInfo();
        local currentRank = nodeInfo.currentRank or 0;
        local ranksPurchased = nodeInfo.ranksPurchased or 0;
        local description;
        description = string.format(TALENT_BUTTON_TOOLTIP_RANK_FORMAT, ranksPurchased, nodeInfo.maxRanks);


        --Bonus Ranks
        --local increasedRanks = nodeInfo.entryIDToRanksIncreased and nodeInfo.entryIDToRanksIncreased[self.entryID] or 0;
        local increasedRanks = nodeInfo.ranksIncreased or 0;
        if increasedRanks > 0 then
            description = description.." |cff19ff19+"..increasedRanks.."|r";
            --[[
            local increasedTraitDataList = C_Traits.GetIncreasedTraitData(self.nodeID, self.entryID);
            for	_index, increasedTraitData in ipairs(increasedTraitDataList) do
                local r, g, b = C_Item.GetItemQualityColor(increasedTraitData.itemQualityIncreasing);
                local qualityColor = CreateColor(r, g, b, 1);
                local coloredItemName = qualityColor:WrapTextInColorCode(increasedTraitData.itemNameIncreasing);
                description = AddLine(description, TALENT_FRAME_INCREASED_RANKS_TEXT:format(increasedTraitData.numPointsIncreased, coloredItemName));
            end
            --]]
        end


        local activeEntryID = self.entryID;
        description = AddLine(description, " ");
        description = API.ConvertTooltipInfoToOneString(description, "GetTraitEntry", activeEntryID, currentRank);

        local nextEntryInfo = nodeInfo.nextEntry  --(self.maxRanks and self.maxRanks > 1) and self.entryType ~= 1 and self.entryID; --self.nodeInfo.nextEntry;  --debug
		if nextEntryInfo and currentRank > 0 then
            description = AddLine(description, " ");
            description = AddLine(description, TALENT_BUTTON_TOOLTIP_NEXT_RANK);
            local nextRank = currentRank + 1;
            description = API.ConvertTooltipInfoToOneString(description, "GetTraitEntry", nextEntryInfo.entryID, nextRank);
		end

        if self.isArtifactAbility then
            if self.trackIndex == ACTIVE_TRACK_INDEX and self.visualState == 0 then
                description = AddLine(description, "\n|cffb1be5f"..L["Artifact Ability Auto Unlock Tooltip"].."|r");
            end
        end

        if self.isFlyoutButton and InCombatLockdown() then
            description = AddLine(description, "\n|cffff2020"..L["Error Change Trait In Combat"].."|r");
        end

        local function updateTooltipFunc()
            self.ShowTooltip(self);
        end

        local icon = self.Icon:GetTexture();
        MainFrame:SetTooltip(self.trackIndex, icon, name, description, updateTooltipFunc);
    end

    function NodeButtonMixin:OnDragStart()
        --debug
        if InCombatLockdown() then
            API.DisplayErrorMessage(L["Error Drag Spell In Combat"]);
            return
        end

        local macroID = RemixAPI.AcquireArtifactAbilityMacro();
        if macroID then
            PickupMacro(macroID);
        else
            C_Spell.PickupSpell(self.spellID);
        end

        if GetCursorInfo() ~= nil then
            MainFrame:OnDraggingSpell(true);
        end
    end
end


local ArrowsButtonMixin = {};
do
    function ArrowsButtonMixin:OnLoad()
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self.Border:SetTexture(TEXTURE_FILE);
        self:SetTotalRanks(0);
        self.entryType = -1;
    end

    function ArrowsButtonMixin:SetData(leftNodeID)
        self.nodeIDs = {};
        self.entryIDs = {};
        local numEntries = 0;
        for i = 1, 3 do
            local nodeInfo = DataProvider:GetRightNodeInfo(leftNodeID);
            if nodeInfo then
                numEntries = numEntries + 1;
                if not self.firstNodeID then
                    self.firstNodeID = nodeInfo.ID;
                    local entryInfo = DataProvider:GetEntryInfo(nodeInfo.entryID);
                    self.spellID = C_Traits.GetDefinitionInfo(entryInfo.definitionID).spellID;
                end
                self.nodeIDs[numEntries] = nodeInfo.ID;
                self.entryIDs[numEntries] = nodeInfo.entryID;
                leftNodeID = nodeInfo.ID;
            else
                self:Hide();
            end
        end
        self.maxRanks = numEntries;
    end

    function ArrowsButtonMixin:Refresh()
        local totalRanks = 0;
        if self.trackIndex == ACTIVE_TRACK_INDEX then
            for _, nodeID in ipairs(self.nodeIDs) do
                local nodeInfo = DataProvider:GetNodeInfo(nodeID);
                if nodeInfo.entryIDsWithCommittedRanks and #nodeInfo.entryIDsWithCommittedRanks > 0 then
                    totalRanks = totalRanks + 1;
                end

                if DataProvider:IsNodeActive(nodeID) then   --debug
                    totalRanks = totalRanks + 1;
                end
            end
        end
        self:SetTotalRanks(totalRanks);
    end

    function ArrowsButtonMixin:SetupTextureByRanks(texture, totalRanks)
        if totalRanks == 0 then
            texture:SetTexCoord(320/1024, 384/1024, 64/1024, 128/1024);
        elseif totalRanks == 1 then
            texture:SetTexCoord(320/1024, 384/1024, 0/1024, 64/1024);
        elseif totalRanks == 2 then
            texture:SetTexCoord(256/1024, 320/1024, 64/1024, 128/1024);
        else
            texture:SetTexCoord(256/1024, 320/1024, 0/1024, 64/1024);
        end
    end

    function ArrowsButtonMixin:SetTotalRanks(totalRanks)
        self.totalRanks = totalRanks;
        self:SetupTextureByRanks(self.Border, totalRanks);
    end

    function ArrowsButtonMixin:OnEnter()
        MainFrame:HoverNode(self);
    end

    function ArrowsButtonMixin:OnLeave()
        NodeButtonMixin.OnLeave(self);
        MainFrame:HoverNode();
    end

    function ArrowsButtonMixin:OnFocused()
        self:ShowTooltip();
    end

    function ArrowsButtonMixin:ShowTooltip()
        if not self.entryIDs then return end;

        local name = L["Stat Bonuses"];
        local currentRank = self.totalRanks or 0;
        local maxRanks = #self.entryIDs;
        local description = string.format(TALENT_BUTTON_TOOLTIP_RANK_FORMAT, currentRank, maxRanks);
        local lineText;

        description = AddLine(description, " ");

        for index, entryID in ipairs(self.entryIDs) do
            --local desc = C_Spell.GetSpellDescription(self.spellID);
            local tooltipInfo = C_TooltipInfo.GetTraitEntry(entryID, 1);
            if tooltipInfo then
                local line = tooltipInfo.lines and tooltipInfo.lines[2];
                if line and line.leftText then
                    if index > currentRank then
                        lineText = "|cff808080"..line.leftText.."|r";
                    else
                        lineText = "|cffffd100"..line.leftText.."|r";
                    end
                    description = AddLine(description, lineText);
                end
            end
        end

        local function updateTooltipFunc()
            self.ShowTooltip(self);
        end

        MainFrame:SetTooltip(self.trackIndex, nil, name, description, updateTooltipFunc);
    end
end


local ActivateButtonMixin = {};
do
    function ActivateButtonMixin:OnLoad()
        self:SetWidth(128);
        self:SetHitRectInsets(0, 0, -8, -4);
        self:SetButtonText(TALENT_SPEC_ACTIVATE);
        self:Hide();
        self.onEnterFunc = self.OnEnter;
        self.onLeaveFunc = self.OnLeave;
        self:SetScript("OnClick", self.OnClick);
        --self:SetTheme("LEGION");  --Use the default red. Green feels too homogenized
    end

    function ActivateButtonMixin:OnEnter()
        --local card = self:GetParent();
        --card.HoverHighlight:Show();
    end

    function ActivateButtonMixin:OnLeave()
        --local card = self:GetParent();
        --card.HoverHighlight:Hide();
    end

    function ActivateButtonMixin:OnClick()
        MainFrame:TryActivateArtifactTrack(self.trackIndex);
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    end

    function ActivateButtonMixin:SetParentCard(card)
        self:ClearAllPoints();
        self.parentCard = card;
        if card then
            self.trackIndex = card.trackIndex;
            self:SetParent(card);
            self:SetPoint("TOP", card, "LEFT", 104, -2);
            self:SetAlpha(0);
            self.t = 0;
            self:SetScript("OnUpdate", SharedFadeIn_OnUpdate);
            self:Update();
            self:Show();
            self:OnMouseUp();
        else
            self.trackIndex = nil;
            self:SetParent(MainFrame);
            self:Hide();
        end
    end

    function ActivateButtonMixin:IsParentCard(card)
        return self:IsShown() and self.parentCard == card
    end

    function ActivateButtonMixin:Update(inCombat)
        local isLoading;

        if CommitUtil:IsCommitingInProcess() then
            self:Disable();
            isLoading = true;
        elseif self.trackIndex == DataProvider:GetActiveArtifactTrackIndex() or self.trackIndex == ACTIVE_TRACK_INDEX then
            self:Hide();
        elseif inCombat or InCombatLockdown() then
            self:Disable();

        --elseif not DataProvider:CanPreActivateArtifactTrack() then
            --You can't purchase any artifact ability at this moment
            --but we'll save the trackIndex and automatically upgrade when eligible
        --    self:Enable();
        else
            self:Enable();
        end
        self:ShowLoadingIndicator(isLoading);
    end
end


local TrackCardMixin = {};
do
    local ANIM_OFFSET_H_BUTTON_HOVER = 12;
    local ANIM_DURATION_BUTTON_HOVER = 0.25;

    function TrackCardMixin:OnLoad()
        self.titleCenterX = 104;
        self.Div:ClearAllPoints();
        self.Div:SetPoint("CENTER", self, "LEFT", 2 * self.titleCenterX - 2, 0);

        local s = Constants.CardScale;
        self:SetSize(Constants.CardWidth * s, Constants.CardHeight * s);
        self.Background:SetSize(Constants.CardBGWidth * s, Constants.CardBGHeight * s);
        self.Div:SetSize(Constants.CardDivWidth * s, Constants.CardDivHeight * s);
        self.HoverHighlight:SetSize(512 * s, Constants.CardBGHeight * s);

        self.Background:SetTexture(TEXTURE_FILE);
        self.Background:SetTexCoord(0/1024, 768/1024, 256/1024, 416/1024);
        self.Div:SetTexture(TEXTURE_FILE);
        self.Div:SetTexCoord(992/1024, 1024/1024, 256/1024, 352/1024);
        self.HoverHighlight:SetTexture(TEXTURE_FILE);
        self.HoverHighlight:SetTexCoord(0/1024, 512/1024, 288/1024, 448/1024);

        self.ActivateFX:SetTexture(TEXTURE_FILE);
        self.ActivateFX:SetTexCoord(0/1024, 768/1024, 416/1024, 576/1024);
        self.ActivateFXMask:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/Mask-Halo", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");

        self.EdgeMask1:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/TrackCardEdgeMask-Left", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        self.EdgeMask2:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/TrackCardEdgeMask-Right", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        self.EdgeGlow1:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/EdgeGlow");
        self.EdgeGlow1:SetBlendMode("ADD");
        self.EdgeGlow1:SetVertexColor(205/255, 237/255, 59/255);
        self.EdgeGlow2:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/EdgeGlow");
        self.EdgeGlow2:SetBlendMode("ADD");
        self.EdgeGlow2:SetVertexColor(205/255, 237/255, 59/255);

        --self:SetScript("OnEnter", self.OnEnter);
        --self:SetScript("OnLeave", self.OnLeave);
    end

    function TrackCardMixin:SetVisualState(visualState)
        -- 0:Inactive  1:Active
        self.visualState = visualState;
        if visualState == 1 then
            self.Background:SetVertexColor(1, 1, 1);
            self.Background:SetDesaturated(false);
            self.EdgeGlow1:Show();
            self.EdgeGlow2:Show();
            self.AnimEdge:Play();
            self.Title:SetPoint("CENTER", self, "LEFT", self.titleCenterX, ANIM_OFFSET_H_BUTTON_HOVER);
            self.Subtitle:Show();
            self.Subtitle:SetText(SPEC_ACTIVE);
            SetFontStringColor(self.Title, "White");
            SetFontStringColor(self.Subtitle, "FelGreenBright");
        else
            self.Background:SetVertexColor(0.8, 0.8, 0.8);
            self.Background:SetDesaturated(true);
            self.EdgeGlow1:Hide();
            self.EdgeGlow2:Hide();
            self.Title:SetTextColor(0.6, 0.59, 0.49);
            if MainFrame.ActivateButton:IsParentCard(self) then
                self.Title:SetPoint("CENTER", self, "LEFT", self.titleCenterX, ANIM_OFFSET_H_BUTTON_HOVER);
            else
                self.Title:SetPoint("CENTER", self, "LEFT", self.titleCenterX, 0);
            end
            self.Subtitle:Hide();
            self.ActivateFX:Hide();
            self.AnimActivateFX:Stop();
        end
    end

    function TrackCardMixin:ShowActivateButton(state)
        if state and not self.activateButtonShown then
            self.activateButtonShown = true;
            MainFrame.ActivateButton:SetParentCard(self);
            self:ShowHoverVisual();
        elseif (not state) and self.activateButtonShown then
            self.activateButtonShown = nil;
            MainFrame.ActivateButton:SetParentCard();
            self:ResetHoverVisual();
        end
    end

    function TrackCardMixin:OnEnter()
        if self.visualState ~= 1 then
            self:ShowActivateButton(true);
        end
    end

    function TrackCardMixin:OnLeave()
        self:ShowActivateButton(false);
    end

    local function Anim_ShiftButtonCentent_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        local offset;
        if self.t < ANIM_DURATION_BUTTON_HOVER then
            offset = Easing_OutQuart(self.t, 0, ANIM_OFFSET_H_BUTTON_HOVER, ANIM_DURATION_BUTTON_HOVER);
        else
            offset = ANIM_OFFSET_H_BUTTON_HOVER;
            self:SetScript("OnUpdate", nil);
        end
        self.offset = offset;
        self.Title:SetPoint("CENTER", self, "LEFT", self.titleCenterX, offset);
    end

    local function Anim_ResetButtonCentent_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        local offset;
        if self.t < ANIM_DURATION_BUTTON_HOVER then
            offset = Easing_OutQuart(self.t, self.offset, 0, ANIM_DURATION_BUTTON_HOVER);
        else
            offset = 0;
            self:SetScript("OnUpdate", nil);
        end
        self.offset = offset;
        self.Title:SetPoint("CENTER", self, "LEFT", self.titleCenterX, offset);
    end

    function TrackCardMixin:ShowHoverVisual()
        self.t = 0;
        self:SetScript("OnUpdate", Anim_ShiftButtonCentent_OnUpdate);
    end

    function TrackCardMixin:ResetHoverVisual()
        self.t = 0;
        if ACTIVE_TRACK_INDEX == self.trackIndex then
            self:SetScript("OnUpdate", nil);
            self.offset = ANIM_OFFSET_H_BUTTON_HOVER;
            self.Title:SetPoint("CENTER", self, "LEFT", self.titleCenterX, ANIM_OFFSET_H_BUTTON_HOVER);
        else
            if self:IsVisible() then
                self:SetScript("OnUpdate", Anim_ResetButtonCentent_OnUpdate);
            else
                self:SetScript("OnUpdate", nil);
                self.Title:SetPoint("CENTER", self, "LEFT", self.titleCenterX, 0);
            end
        end
    end

    function TrackCardMixin:Refresh(playAnimation)
        for _, obj in ipairs(self.TraitNodes) do
            obj:Refresh();
        end

        local isActive = self.trackIndex == ACTIVE_TRACK_INDEX;
        self:SetVisualState(isActive and 1 or 0);

        if isActive then
            self:SetScript("OnUpdate", nil);
            self.Title:SetPoint("CENTER", self, "LEFT", self.titleCenterX, ANIM_OFFSET_H_BUTTON_HOVER);

            if isActive ~= self.isActive and playAnimation then
                self.ActivateFX:Show();
                self.ActivateFX:SetAlpha(0);
                self.AnimActivateFX:Stop();
                self.AnimActivateFX:Play();
                PlaySound(SOUNDKIT.UI_CLASS_TALENT_LEARN_TALENT)
            end
        end

        self.isActive = isActive;
    end
end


local TraitTooltipMixin = {};
do
    local TraitTooltipFrame;

    function TraitTooltipMixin:OnHide()
        self:Hide();
        self.alpha = 0;
        self.t = 0;
        self:SetAlpha(0);
        self:SetScript("OnUpdate", nil);
        self.updateTooltipFunc = nil;
        self.owner = nil;
    end

    function TraitTooltipMixin:SetTooltipSpell(spellID)
        local name = C_Spell.GetSpellName(spellID);
        if not name then
            name = RETRIEVING_DATA;
        end
        --local description = API.ConvertTooltipInfoToOneString(nil, "GetSpellByID", spellID);
        local description = C_Spell.GetSpellDescription(spellID);
        local icon = C_Spell.GetSpellTexture(spellID);
        local function updateTooltipFunc()
            if self:IsVisible() then
                self:SetTooltipSpell(spellID);
            end
        end
        self:SetTooltip(icon, name, description, updateTooltipFunc);
    end

    function TraitTooltipMixin:SetTooltipTrait(entryID, rank)
        rank = rank or 1;
        local spellID = DataProvider:GetTraitSpell(entryID);
        local name = DataProvider:GetTraitName(entryID);
        if not name then
            name = RETRIEVING_DATA;
        end
        local description = API.ConvertTooltipInfoToOneString(nil, "GetTraitEntry", entryID, rank);
        local icon = C_Spell.GetSpellTexture(spellID);
        local function updateTooltipFunc()
            if self:IsVisible() then
                self:SetTooltipTrait(entryID, rank);
            end
        end
        self:SetTooltip(icon, name, description, updateTooltipFunc);
    end

    function Tooltip_Show_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.5 then
            self.t = 0;
            if self.updateTooltipFunc then
                self.updateTooltipFunc(self);
            else
                self:SetScript("OnUpdate", nil);
            end
        end

        if self.isFading then
            self.alpha = self.alpha + 8 * elapsed;
            if self.alpha > 1 then
                self.alpha = 1;
                self.isFading = nil;
            end
            self:SetAlpha(self.alpha);
        end
    end

    function TraitTooltipMixin:SetTooltip(icon, header, description, updateTooltipFunc)
        local padding = 20;

        self.Icon:SetTexture(icon);
        self.Header:SetText(header);
        self.Desc:SetText(description);
        self.updateTooltipFunc = updateTooltipFunc;
        self.t = 0;

        local width = math.max(self.Header:GetWrappedWidth(), self.Desc:GetWrappedWidth());
        local height = self.Header:GetHeight() + 4 + self.Desc:GetHeight();

        self:SetSize(width + 2*padding, height + 2*padding + 6);
        API.UpdateTextureSliceScale(self.BackgroundFrame.Texture);
        self:SetScript("OnUpdate", Tooltip_Show_OnUpdate);
        self.isFading = true;
        self:SetFrameStrata("TOOLTIP");
    end

    local function Tooltip_FadeOut_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        if self.t >= 0 then
            self.t = 0;
            self.alpha = self.alpha - 5 * elapsed;
            if self.alpha < 0 then
                self.alpha = 0;
                self:SetScript("OnUpdate", nil);
            end
            self:SetAlpha(self.alpha);
        end
    end

    function TraitTooltipMixin:HideTooltip(fadeOut)
        self.updateTooltipFunc = nil;
        if fadeOut then
            if self:IsVisible() then
                self.t = 0;
                if self.alpha >= 0.99 then
                    self.t = -0.2;
                else
                    self.t = 0;
                end
                self:SetScript("OnUpdate", Tooltip_FadeOut_OnUpdate);
            end
        else
            self:Hide();
        end
    end

    function TraitTooltipMixin:SetOwner(owner)
        self.owner = owner;
    end

    function RemixAPI.GetTraitTooltipFrame()
        if not TraitTooltipFrame then
            local f = CreateFrame("Frame", nil, UIParent, "PlumberLegionRemixTooltipTemplate");
            TraitTooltipFrame = f;
            API.Mixin(f, TraitTooltipMixin);
            f.alpha = 0;
            f:SetAlpha(0);
            f.Icon:SetDesaturation(0.2);
            f.Icon:SetVertexColor(0.8, 0.8, 0.8);
            f:SetScript("OnHide", f.OnHide);
        end
        return TraitTooltipFrame
    end

    function RemixAPI.HideTraitTooltipFrame(fadeOut)
        if TraitTooltipFrame then
            TraitTooltipFrame:HideTooltip(fadeOut);
        end
    end
end

local MainFrameMixin = {};
do
    local DynamicEvents = {
        "PLAYER_REGEN_ENABLED",
        "PLAYER_REGEN_DISABLED",
        "CURRENCY_DISPLAY_UPDATE",
        "TRAIT_TREE_CHANGED",
    };

    function MainFrameMixin:OnShow()
        API.RegisterFrameForEvents(self, DynamicEvents);
        CallbackRegistry:Register("LegionRemix.CommitFinished", self.OnCommitFinished, self);
        CallbackRegistry:Register("LegionRemix.ConfigUpdated", self.RequestUpdate, self);
        self:Refresh();
        self:SetScript("OnEvent", self.OnEvent);
        PlaySound(SOUNDKIT.UI_EXPANSION_LANDING_PAGE_OPEN);
    end

    function MainFrameMixin:OnHide()
        API.UnregisterFrameForEvents(self, DynamicEvents);
        CallbackRegistry:UnregisterCallback("LegionRemix.CommitFinished", self.OnCommitFinished, self);
        CallbackRegistry:UnregisterCallback("LegionRemix.ConfigUpdated", self.RequestUpdate, self);
        self:UpdateCardFocus();
        self:CloseNodeFlyout();
        self:SetScript("OnEvent", nil);
        self:SetScript("OnUpdate", nil);
        self:OnDraggingSpell(false);
        PlaySound(SOUNDKIT.UI_EXPANSION_LANDING_PAGE_CLOSE);
    end

    function MainFrameMixin:UpdateHeader()
        local HeaderFrame = self.HeaderFrame;
        if HeaderFrame then
            local nextUpgradeInfo = DataProvider:GetNextUpgradeInfoForUI();
            if nextUpgradeInfo then
                HeaderFrame.Text1:SetText(nextUpgradeInfo.line1);
                HeaderFrame.Text1:SetTextColor(0.6, 0.6, 0.6);
                HeaderFrame.Text2:SetText(nextUpgradeInfo.line2);
                HeaderFrame.Text2:SetTextColor(177/255, 190/255, 95/255);
            else
                HeaderFrame.Text1:SetText("");
                HeaderFrame.Text2:SetText("");
            end
        end
    end

    function MainFrameMixin:ShowHeaderTooltip()
        local nextUpgradeInfo = DataProvider:GetNextUpgradeInfoForUI();
        if nextUpgradeInfo then
            local TooltipFrame = RemixAPI.GetTraitTooltipFrame();
            TooltipFrame:SetTooltipTrait(nextUpgradeInfo.nextEntryID, nextUpgradeInfo.nextRank);
            TooltipFrame:SetOwner(self);
            TooltipFrame:SetParent(self);
            TooltipFrame:ClearAllPoints();
            TooltipFrame:SetPoint("TOPLEFT", MainFrame, "TOPRIGHT", 4, 0);
            TooltipFrame:SetFrameStrata("TOOLTIP");
            TooltipFrame:Show();
        end
    end

    function MainFrameMixin:OnEvent(event, ...)
        if event == "PLAYER_REGEN_ENABLED" then
            self.ActivateButton:Update();
        elseif event == "PLAYER_REGEN_DISABLED" then
            self.ActivateButton:Update(true);
        elseif event == "CURRENCY_DISPLAY_UPDATE" then
            local currencyID = ...
            if currencyID == 3268 then
                if not self.isUpdatingHeader then
                    self.isUpdatingHeader = true;
                    C_Timer.After(0.2, function()
                        self.isUpdatingHeader = nil;
                        self:UpdateHeader();
                    end);
                end
            end
        elseif event == "TRAIT_CONFIG_UPDATED" then
            local configID = ...
            self:RequestUpdate();
        elseif event == "CURSOR_CHANGED" then
            if self.isDraggingSpell then
                if not GetCursorInfo() then
                    self:OnDraggingSpell(false);
                end
            end
        end
    end

    function MainFrameMixin:Refresh(playAnimation)
        ACTIVE_TRACK_INDEX = DataProvider:GetActiveArtifactTrackIndex() or DataProvider:GetLastArtifactTrackIndexForCurrentSpec();
        for _, card in ipairs(self.TrackCards) do
            card:Refresh(playAnimation);
        end
        self.ActivateButton:Update();
        self:UpdateNodeFlyoutFrame();
        self:UpdateHeader();
        --self:DebugSaveAllNodes();
    end

    function MainFrameMixin:OnUpdate_UpdateAfterDelay(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.2 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            self:Refresh();
        end
    end

    function MainFrameMixin:RequestUpdate()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate_UpdateAfterDelay);
    end

    function MainFrameMixin:DebugSaveAllNodes()
        local trackNodes = {};
        for i, card in ipairs(self.TrackCards) do
            local nodes = {};
            trackNodes[i] = nodes;
            for _, obj in ipairs(card.TraitNodes) do
                if obj.nodeID then
                    table.insert(nodes, obj.nodeID);
                end
                if obj.nodeIDs then
                    for _, nodeID in ipairs(obj.nodeIDs) do
                        table.insert(nodes, nodeID);
                    end
                end
            end
        end
        PlumberDevData.RemixArtifactTrackNodes = trackNodes;
    end

    function MainFrameMixin:TryActivateArtifactTrack(trackIndex)
        if InCombatLockdown() or CommitUtil:IsCommitingInProcess() then
            --Activate button shouldn't be clickable in this scenario
            return
        end

        self.ActivateButton:Disable();
        DataProvider:SetLastArtifactTrackIndexForCurrentSpec(trackIndex);
        if not CommitUtil:TryPurchaseArtifactTrack(trackIndex) then
            if DataProvider:CanPreActivateArtifactTrack() then
                self:OnCommitFinished(true);
            end
        end
        self.ActivateButton:Update();
    end

    function MainFrameMixin:HoverNode(nodeButton)
        local f = self.SharedNodeHighlight;
        f:Hide();
        f:ClearAllPoints();
        self.NodeFocusSolver:SetFocus(nodeButton);
        if nodeButton then
            f:SetParent(nodeButton);
            f:SetPoint("TOPLEFT", nodeButton.Border, "TOPLEFT", 0, 0);
            f:SetPoint("BOTTOMRIGHT", nodeButton.Border, "BOTTOMRIGHT", 0, 0);
            if nodeButton.entryType == 1 then
                f.Texture:SetTexCoord(640/1024, 768/1024, 0/1024, 128/1024);
            elseif nodeButton.entryType == 2 then
                f.Texture:SetTexCoord(768/1024, 896/1024, 0/1024, 128/1024);
            elseif nodeButton.entryType == 0 then
                f.Texture:SetTexCoord(896/1024, 1024/1024, 0/1024, 128/1024);
            elseif nodeButton.entryType == -1 then
                --f.Texture:SetTexCoord(768/1024, 832/1024, 128/1024, 192/1024);
                nodeButton:SetupTextureByRanks(f.Texture, nodeButton.totalRanks);
            end
            f.t = 0;
            f:SetAlpha(0);
            f:SetScript("OnUpdate", SharedFadeIn_OnUpdate);
            f:Show();
        end
    end

    function MainFrameMixin:UpdateNodeFlyoutFrame()
        if self.NodeFlyoutFrame and self.NodeFlyoutFrame:IsVisible() then
            for _, button in ipairs(self.flyoutButtonPool:GetActiveObjects()) do
                button:Refresh();
            end
        end
    end

    function MainFrameMixin:ShowNodeFlyout(nodeButton)
        if not nodeButton.nodeChoices then return end;

        local f = self.NodeFlyoutFrame;
        if not f then
            f = CreateFrame("Frame", nil, self);
            self.NodeFlyoutFrame = f;
            f:EnableMouse(true);
            f:EnableMouseMotion(true);
            f:SetSize(80, 80);

            f:SetScript("OnLeave", function()
                if not(f:IsMouseOver() or (f.owner and f.owner:IsVisible() and f.owner:IsMouseOver())) then
                    MainFrame:CloseNodeFlyout();
                end
            end);

            local function FlyoutButton_Create()
                local button = CreateFrame("Button", nil, f, "PlumberLegionRemixNodeTemplate");
                API.Mixin(button, NodeButtonMixin);
                button.isFlyoutButton = true;
                button:OnLoad();
                button:SetScript("OnClick", button.OnClick);
                local shadow = button:CreateTexture(nil, "BACKGROUND");
                shadow:SetPoint("CENTER", button, "CENTER", 0, -8);
                shadow:SetSize(128, 128);
                shadow:SetTexture(TEXTURE_FILE);
                shadow:SetTexCoord(768/1024, 896/1024, 256/1024, 384/1024);
                return button
            end
            self.flyoutButtonPool = API.CreateObjectPool(FlyoutButton_Create);
        end

        if f:IsVisible() and f.owner == nodeButton then
            return
        end

        f:ClearAllPoints();
        self.flyoutButtonPool:Release();

        local buttonSize = Constants.NodeSize;
        local gapH = Constants.NodeGap;
        local offsetX = 0;

        for i, v in ipairs(nodeButton.nodeChoices) do
            local button = self.flyoutButtonPool:Acquire();
            button:SetData(v[1], v[2], v[3]);
            button.trackIndex = nodeButton.trackIndex;
            button.parentNodeButton = nodeButton;
            button:SetPoint("TOPLEFT", f, "TOPLEFT", offsetX, 0);
            button:SetCircle();
            button:Refresh();
            offsetX = offsetX + buttonSize + gapH;
        end

        local totalWidth = offsetX - gapH;
        local bottomPadding = 6;
        f:SetSize(totalWidth, buttonSize + bottomPadding);
        f:SetPoint("BOTTOM", nodeButton, "TOP", 0, -10 -bottomPadding);
        f:SetFrameStrata("DIALOG");
        f.owner = nodeButton;

        local duration = 0.2;
        local function FlyoutFrame_OnUpdate(self, elapsed)
            self.t = self.t + elapsed;
            local scale;
            if self.t < duration then
                scale = Easing_OutQuart(self.t, 1.0, 1.6, duration);
            else
                scale = 1.6;
                self:SetScript("OnUpdate", nil);
            end
            self:SetScale(scale);

            local alpha = self.t * 8;
            if alpha > 1 then
                alpha = 1;
            end
            self:SetAlpha(alpha);
        end

        f:Show();

        f:SetScale(1.0);
        f:SetAlpha(0);
        f.t = 0;
        f:SetScript("OnUpdate", FlyoutFrame_OnUpdate);
    end

    function MainFrameMixin:CloseNodeFlyout()
        if self.NodeFlyoutFrame then
            self.NodeFlyoutFrame:Hide();
            self.NodeFlyoutFrame:ClearAllPoints();
        end
    end

    function MainFrameMixin:IsNodeFlyoutFocused(nodeButton)
        if self.NodeFlyoutFrame then
            if not self.NodeFlyoutFrame:IsVisible() then return end;
            if self.NodeFlyoutFrame:IsMouseOver() then
                return true
            end

            if self.NodeFlyoutFrame.owner:IsMouseOver() then
                return true
            end

            if nodeButton then
                if not self.NodeFlyoutFrame.owner == nodeButton then
                    return false
                end
            end

            for _, button in ipairs(self.flyoutButtonPool:GetActiveObjects()) do
                if button:IsMouseMotionFocus() then
                    return true
                end
            end
        end
        return false
    end

    function MainFrameMixin:UpdateCardFocus()
        local focusedCard;

        if self:IsVisible() then
            if self.NodeFlyoutFrame and self.NodeFlyoutFrame:IsVisible() then
                if self.NodeFlyoutFrame:IsMouseOver() then
                    focusedCard = self.NodeFlyoutFrame.owner.parentCard;
                end
            end

            if not focusedCard then
                for _, card in ipairs(self.TrackCards) do
                    if card:IsMouseOver() then
                        focusedCard = card;
                        break
                    end
                end
            end
        end

        for _, card in ipairs(self.TrackCards) do
            if card ~= focusedCard then
                card:OnLeave();
            end
        end

        if focusedCard then
            focusedCard:OnEnter();
        end
    end

    function MainFrameMixin:OnCommitFinished(success)
        local playAnimation;
        if success then
            playAnimation = true;
        else

        end
        self:Refresh(playAnimation);
    end

    function MainFrameMixin:SetTooltip(row, icon, header, description, updateTooltipFunc)
        local f = self.TooltipFrame;
        f:SetTooltip(icon, header, description, updateTooltipFunc);
        f:SetOwner(self);
        f:ClearAllPoints();
        f:SetPoint("TOPLEFT", MainFrame, "TOPRIGHT", 4, (1 - row) * 94.4);
        f:SetFrameStrata("TOOLTIP");
        f:SetParent(self);
        f:Show();
    end



    function MainFrameMixin:HideTooltip()
        self.TooltipFrame:HideTooltip(true);
    end

    function MainFrameMixin:OnDraggingSpell(isDraggingSpell)
        self.isDraggingSpell = isDraggingSpell;
        if isDraggingSpell then
            self:RegisterEvent("CURSOR_CHANGED");
            self:SetFrameStrata("LOW");
            self:SetToplevel(false);
        else
            self:UnregisterEvent("CURSOR_CHANGED");
            self:SetFrameStrata("MEDIUM");
            self:SetToplevel(true);
        end
    end
end


local function CreateMainUI()
    local baseFrameLevel = 20;
    local headerHeight = 64;
    local CreateFrame = CreateFrame;

    local frameName = "PlumberRemixArtifactUI";
    local f = CreateFrame("Frame", frameName, UIParent, "PlumberRemixArtifactUITemplate");
    f:Hide();
    f:SetToplevel(true);
    MainFrame = f;
    API.Mixin(f, MainFrameMixin);
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    table.insert(UISpecialFrames, frameName);


    local TrackCards = {};
    MainFrame.TrackCards = TrackCards;


    local SharedNodeHighlight = CreateFrame("Frame", nil, f);
    f.SharedNodeHighlight = SharedNodeHighlight;
    SharedNodeHighlight:Hide();
    SharedNodeHighlight:SetUsingParentLevel(true);
    SharedNodeHighlight.Texture = SharedNodeHighlight:CreateTexture(nil, "OVERLAY");
    SharedNodeHighlight.Texture:SetAllPoints(true);
    SharedNodeHighlight.Texture:SetTexture(TEXTURE_FILE);
    SharedNodeHighlight.Texture:SetBlendMode("ADD");


    local NodeFocusSolver = API.CreateFocusSolver(f);
    f.NodeFocusSolver = NodeFocusSolver;
    NodeFocusSolver:SetDelay(0.2);


    local CardFocusSolver = CreateFrame("Frame", nil, f);
    f.CardFocusSolver = CardFocusSolver;
    CardFocusSolver.t = 0;
    CardFocusSolver:SetScript("OnUpdate", function(self, elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.1 then
            self.t = 0;
            MainFrame:UpdateCardFocus();
        end
    end);


    --Artifact Abilities
    local buttonSize = Constants.NodeSize;
    local gapH = Constants.NodeGap;

    local offsetX = 0;
    local offsetY = headerHeight;

    local numEntries;
    ACTIVE_TRACK_INDEX = DataProvider:GetActiveArtifactTrackIndex();

    local cardWidth = Constants.CardWidth * Constants.CardScale;
    local cardHeight = Constants.CardHeight * Constants.CardScale;
    local cardGap = 8;

    for index, trackData in ipairs(DataProvider.ArtifactTracks) do
        numEntries = #trackData;
        offsetX = 226;
        offsetY =  (1 - index) * (cardHeight + cardGap);

        local card = CreateFrame("Frame", nil, f, "PlumberLegionRemixCardTemplate");
        TrackCards[index] = card;
        API.Mixin(card, TrackCardMixin);
        card:OnLoad();
        card:SetPoint("TOP", f, "TOP", 0, offsetY);
        card:SetFrameLevel(baseFrameLevel - index);
        card.trackIndex = index;
        card.TraitNodes = {};

        for i, nodeID in ipairs(trackData) do
            local button = CreateFrame("Button", nil, card, "PlumberLegionRemixNodeTemplate");
            API.Mixin(button, NodeButtonMixin);
            button.trackIndex = index;
            button.parentCard = card;
            button:OnLoad();
            table.insert(card.TraitNodes, button);
            button:SetPoint("LEFT", card, "LEFT", offsetX, 0);

            if i == 1 then
                button.Title = card.Title;
                button.isArtifactAbility = true;
                button:RegisterForDrag("LeftButton");
                --local x = card.Div:GetCenter();
                --print(card:GetLeft() - x);
            end

            local entryID = DataProvider:GetNodeEntryID(nodeID);
            if type(entryID) == "table" then
                button:SetNodeChoices(nodeID, entryID);
            else
                button:SetData(nodeID, entryID);
            end

            offsetX = offsetX + buttonSize + gapH;

            if i ~= numEntries then
                local arrow = CreateFrame("Button", nil, card, "PlumberLegionRemixThreeArrowsTemplate");
                API.Mixin(arrow, ArrowsButtonMixin);
                arrow.trackIndex = index;
                table.insert(card.TraitNodes, arrow);
                arrow:OnLoad();
                arrow:SetData(nodeID);
                arrow:SetPoint("LEFT", card, "LEFT", offsetX, 0);
                offsetX = offsetX + Constants.ThreeArrowsSize + gapH;
            end
        end
    end


    local ActivateButton = addon.LandingPageUtil.CreateRedButton(f);
    ActivateButton:Hide();
    f.ActivateButton = ActivateButton;
    API.Mixin(ActivateButton, ActivateButtonMixin);
    ActivateButton:OnLoad();


    local TooltipFrame = RemixAPI.GetTraitTooltipFrame(f);
    f.TooltipFrame = TooltipFrame;


    local HeaderFrame = CreateFrame("Frame", nil, f);
    f.HeaderFrame = HeaderFrame;
    HeaderFrame:SetSize(Constants.HeaderWidth * Constants.CardScale, Constants.HeaderHeight * Constants.CardScale);
    HeaderFrame:SetPoint("BOTTOM", f, "TOP", 0, -4);

    HeaderFrame.Background = HeaderFrame:CreateTexture(nil, "BACKGROUND");
    HeaderFrame.Background:SetSize(Constants.HeaderBGWidth * Constants.CardScale, Constants.HeaderBGHeight * Constants.CardScale);
    HeaderFrame.Background:SetPoint("CENTER", HeaderFrame, "CENTER", 0, 0);
    HeaderFrame.Background:SetTexture(TEXTURE_FILE);
    HeaderFrame.Background:SetTexCoord(0/1024, 512/1024, 576/1024, 768/1024);
    HeaderFrame.Background:SetAlpha(1);

    HeaderFrame.Text1 = HeaderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    HeaderFrame.Text1:SetPoint("BOTTOM", HeaderFrame, "CENTER", 0, 4);
    HeaderFrame.Text1:SetJustifyH("CENTER");
    HeaderFrame.Text2 = HeaderFrame:CreateFontString(nil, "OVERLAY", "ObjectiveTrackerHeaderFont");
    HeaderFrame.Text2:SetPoint("TOP", HeaderFrame, "CENTER", 0, 0);
    HeaderFrame.Text2:SetJustifyH("CENTER");

    HeaderFrame.MouseoverFrame = CreateFrame("Frame", nil, HeaderFrame);
    HeaderFrame.MouseoverFrame:SetPoint("CENTER", HeaderFrame, "CENTER", 0, 2);
    HeaderFrame.MouseoverFrame:SetSize(4 * buttonSize, buttonSize);
    HeaderFrame.MouseoverFrame:SetScript("OnEnter", function()
        MainFrame:ShowHeaderTooltip();
    end);
    HeaderFrame.MouseoverFrame:SetScript("OnLeave", function()
        MainFrame:HideTooltip();
    end);


    local function CreateTextBackground(parent, fontString, height, extensionX)
        local bg = parent:CreateTexture(nil, "BACKGROUND", nil, 2);
        bg:SetTexture("Interface/AddOns/Plumber/Art/Frame/NameplateTextShadow");
        bg:SetTextureSliceMargins(40, 24, 40, 24);
        bg:SetTextureSliceMode(0);
        bg:SetHeight(height);
        local offsetY = 0;
        bg:SetPoint("LEFT", fontString, "LEFT", -extensionX, offsetY);
        bg:SetPoint("RIGHT", fontString, "RIGHT", extensionX, offsetY);
        bg:SetAlpha(0.5);
        return bg
    end
    HeaderFrame.Text1.Background = CreateTextBackground(HeaderFrame, HeaderFrame.Text1, 46, 18);
    HeaderFrame.Text2.Background = CreateTextBackground(HeaderFrame, HeaderFrame.Text2, 54, 20);


    local CardBackground = f:CreateTexture(nil, "BACKGROUND", nil, 1);
    CardBackground:SetPoint("CENTER", TrackCards[3], "CENTER", 0, 0);
    CardBackground:SetTexture(TEXTURE_FILE);
    CardBackground:SetTexCoord(704/1024, 1, 768/1024, 1);
    CardBackground:SetAlpha(0.6);
    local s = 2.1;
    CardBackground:SetSize(320 * s, 256 * s);


    local CloseButton = CreateFrame("Button", nil, f);
    local scale = 1.2;
    CloseButton:SetSize(24*scale, 24*scale);
    CloseButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, 48);
    CloseButton.Background = CloseButton:CreateTexture(nil, "BACKGROUND");
    CloseButton.Background:SetSize(64*scale, 48*scale);
    CloseButton.Background:SetPoint("CENTER", CloseButton, "CENTER", 0, 0);
    CloseButton.Background:SetTexture(TEXTURE_FILE);
    CloseButton.Background:SetTexCoord(512/1024, 640/1024, 576/1024, 672/1024);

    local NormalTexture = CloseButton:CreateTexture(nil, "OVERLAY");
    CloseButton:SetNormalTexture(NormalTexture);
    NormalTexture:SetTexture(TEXTURE_FILE);
    NormalTexture:SetTexCoord(640/1024, 688/1024, 576/1024, 624/1024);

    local PushedTexture = CloseButton:CreateTexture(nil, "OVERLAY");
    CloseButton:SetPushedTexture(PushedTexture);
    PushedTexture:SetTexture(TEXTURE_FILE);
    PushedTexture:SetTexCoord(640/1024, 688/1024, 624/1024, 672/1024);

    local HighlightTexture = CloseButton:CreateTexture(nil, "OVERLAY");
    CloseButton:SetHighlightTexture(HighlightTexture);
    HighlightTexture:SetTexture(TEXTURE_FILE);
    HighlightTexture:SetTexCoord(688/1024, 736/1024, 576/1024, 624/1024);
    HighlightTexture:SetBlendMode("ADD");

    CloseButton:SetScript("OnClick", function()
        MainFrame:Hide();
    end);


    local height = 5 * (cardHeight + cardGap) - cardGap + headerHeight;
    f:SetSize(cardWidth, height);
    f:SetScript("OnHide", f.OnHide);
    f:SetScript("OnShow", f.OnShow);
end

local function ShowArtifactUI()
    if not MainFrame then
        CreateMainUI();
        MainFrame:Hide();
    end
    MainFrame:Show();
end
RemixAPI.ShowArtifactUI = ShowArtifactUI;


local function ToggleArtifactUI()
    if MainFrame then
        MainFrame:SetShown(not MainFrame:IsShown());
    else
        ShowArtifactUI();
    end
end
RemixAPI.ToggleArtifactUI = ToggleArtifactUI;