local _, addon = ...
local RemixAPI = addon.RemixAPI
if not RemixAPI then return end;


local DEBUG_MODE = true;
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
};


local function SetFontStringColor(fontString, key)
    local color = Constants[key];
    fontString:SetTextColor(color[1], color[2], color[3]);
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
        self:HideTooltip();
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
        local isActive = (self.trackIndex == ACTIVE_TRACK_INDEX) and DataProvider:IsNodeActive(self.nodeID);
        self.isActive = isActive;
        local isPurchased;
        local visualState;
        local rankText = "";

        if self.entryIDs then
            local selectedEntryID, saved = DataProvider:GetLastSelectedEntryID(self.nodeID, self.entryIDs);
            if saved then
                self.selectedEntryID = selectedEntryID;
            end
        end

        if DEBUG_MODE then
            if not isActive then
                visualState = 0;
            else
                if self.isFlyoutButton then
                    isPurchased = self.parentNodeButton.entryID == self.entryID;
                    if isPurchased then
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
            if isActive then
                if self.entryType == 1 then
                    rankText = self.maxRanks;   --"1";
                elseif self.entryType == 2 then
                    rankText = self.maxRanks;   --"3";
                elseif self.entryType == 0 then
                    if self.selectedEntryID then
                        self.GreenGlow:Hide();
                    else
                        self.GreenGlow:Show();
                    end
                end
                if self.isFlyoutButton and not isPurchased then
                    rankText = "0";
                    self.RankText:SetTextColor(0.098, 1.000, 0.098);
                else
                    self.RankText:SetTextColor(1, 0.82, 0);
                end
            else

            end
            self.RankText:SetText(rankText);
            return
        end

        local nodeInfo = DataProvider:GetNodeInfo(self.nodeID);
        local currentRank = nodeInfo.currentRank;
        if currentRank >= 1 then
            self.RankText:SetText(tostring(currentRank));
        else
            self.RankText:SetText("");
        end
        self.RankText:SetTextColor(1, 0.82, 0);

        local isEntryCommitted = false;
        local committedEntryID;

        if nodeInfo.entryIDsWithCommittedRanks then
            for _, id in ipairs(nodeInfo.entryIDsWithCommittedRanks) do
                committedEntryID = id;
                isEntryCommitted = true;
                break
            end
        end

        local entryID = committedEntryID or self.entryID;
        local increasedRanks = nodeInfo.entryIDToRanksIncreased and nodeInfo.entryIDToRanksIncreased[entryID] or 0;

        self:SetNodeDisabled(not(increasedRanks > 0 or isEntryCommitted));
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
    end

    function NodeButtonMixin:GetNodeInfo()
        local nodeInfo = {
            currentRank = 1,
            maxRanks = self.maxRanks or 1,
        }
        return nodeInfo
    end

    function NodeButtonMixin:ShowTooltip()
        if self.nodeChoices then
            self.UpdateTooltip = nil;
            return
        end


        local tooltip = GameTooltip;
        tooltip:Hide();
        tooltip:ClearHandlerInfo();
        tooltip:SetOwner(self, "ANCHOR_NONE");
        tooltip:SetPoint("TOPLEFT", MainFrame, "TOPRIGHT", 4, 0);

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


        local function AddLine(oldText, newText)
            return oldText.."\n"..newText
        end

        local text = C_Spell.GetSpellName(spellID);
        if not text then
            text = RETRIEVING_DATA;
        end

        local nodeInfo = self:GetNodeInfo();    --debug

        text = AddLine(text, string.format(TALENT_BUTTON_TOOLTIP_RANK_FORMAT, nodeInfo.currentRank, nodeInfo.maxRanks));


        --Bonus Ranks
        local increasedRanks = nodeInfo.entryIDToRanksIncreased and nodeInfo.entryIDToRanksIncreased[self.entryID] or 0;
        if increasedRanks > 0 then
            local increasedTraitDataList = C_Traits.GetIncreasedTraitData(self.nodeID, self.entryID);
            for	_index, increasedTraitData in ipairs(increasedTraitDataList) do
                local r, g, b = C_Item.GetItemQualityColor(increasedTraitData.itemQualityIncreasing);
                local qualityColor = CreateColor(r, g, b, 1);
                local coloredItemName = qualityColor:WrapTextInColorCode(increasedTraitData.itemNameIncreasing);
                --local wrapText = true;
                --GameTooltip_AddColoredLine(tooltip, TALENT_FRAME_INCREASED_RANKS_TEXT:format(increasedTraitData.numPointsIncreased, coloredItemName), GREEN_FONT_COLOR, wrapText);
                text = AddLine(text, TALENT_FRAME_INCREASED_RANKS_TEXT:format(increasedTraitData.numPointsIncreased, coloredItemName));
            end
        end


        local activeEntryID = self.entryID; 
        local data = C_TooltipInfo.GetTraitEntry(activeEntryID, 1);
        if data and data.lines then
            local lineText;
            for i, line in ipairs(data.lines) do
                lineText = line.leftText;
                if lineText then
                    if line.leftColor then
                        lineText = line.leftColor:WrapTextInColorCode(lineText);
                    end
                    text = AddLine(text, lineText);
                end
                lineText = line.rightText;
                if lineText then
                    if line.rightColor then
                        lineText = line.rightColor:WrapTextInColorCode(lineText);
                    end
                    text = text.."  "..lineText;
                end
            end
        end

        local nextEntryID = (self.maxRanks and self.maxRanks > 1) and self.entryType ~= 1 and self.entryID; --self.nodeInfo.nextEntry;  --debug
        local ranksPurchased = 1;
		if nextEntryID and ranksPurchased > 0 then
            text = AddLine(text, " ");
            text = AddLine(text, TALENT_BUTTON_TOOLTIP_NEXT_RANK);
            local data = C_TooltipInfo.GetTraitEntry(nextEntryID, 1);
            if data and data.lines then
                local lineText;
                for i, line in ipairs(data.lines) do
                    lineText = line.leftText;
                    if lineText then
                        if line.leftColor then
                            lineText = line.leftColor:WrapTextInColorCode(lineText);
                        end
                        text = AddLine(text, lineText);
                    end
                    lineText = line.rightText;
                    if lineText then
                        if line.rightColor then
                            lineText = line.rightColor:WrapTextInColorCode(lineText);
                        end
                        text = text.."  "..lineText;
                    end
                end
            end
		end


        tooltip:Hide();

        local padding = 16;
        local TooltipFrame = MainFrame.TooltipFrame;
        TooltipFrame.Desc:ClearAllPoints();
        TooltipFrame.Desc:SetPoint("TOPLEFT", TooltipFrame, "TOPLEFT", padding, -padding);
        TooltipFrame.Desc:SetText(text);
        local width = TooltipFrame.Desc:GetWrappedWidth();
        local height = TooltipFrame.Desc:GetHeight();
        TooltipFrame:ClearAllPoints();
        TooltipFrame:SetPoint("TOPLEFT", MainFrame, "TOPRIGHT", 4, 0);
        TooltipFrame:SetSize(width + 2*padding, height + 2*padding + 6);
        API.UpdateTextureSliceScale(TooltipFrame.BackgroundFrame.Texture);
        TooltipFrame:Show();
    end

    function NodeButtonMixin:HideTooltip()
        GameTooltip:Hide();
        self.UpdateTooltip = nil;
        if self.spellLoadCancel then
            self.spellLoadCancel();
            self.spellLoadCancel = nil;
        end
        --MainFrame.TooltipFrame:Hide();
    end
end


local ArrowsButtonMixin = {};
do
    ArrowsButtonMixin.HideTooltip = NodeButtonMixin.HideTooltip;

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

        local tooltip = GameTooltip;
        tooltip:Hide();
        tooltip:ClearHandlerInfo();
        tooltip:SetOwner(self, "ANCHOR_NONE");
        tooltip:SetPoint("TOPLEFT", MainFrame, "TOPRIGHT", 4, 0);

        tooltip:SetText(L["Stat Bonuses"], 1, 1, 1, true);

        local currentRank = self.totalRanks or 0;
        local maxRanks = #self.entryIDs;

        tooltip:AddLine(string.format(TALENT_BUTTON_TOOLTIP_RANK_FORMAT, currentRank, maxRanks), 1, 1, 1, true);

        for index, entryID in ipairs(self.entryIDs) do
            tooltip:AddLine(" ");
            --local desc = C_Spell.GetSpellDescription(self.spellID);
            local tooltipInfo = C_TooltipInfo.GetTraitEntry(entryID, 1);
            if tooltipInfo then
                local line = tooltipInfo.lines and tooltipInfo.lines[2];
                if line and line.leftText then
                    if index > currentRank then
                        tooltip:AddLine(line.leftText, 0.5, 0.5, 0.5, true);
                    else
                        tooltip:AddLine(line.leftText, 1, 0.82, 00, true);
                    end
                end
            end
        end

        self.UpdateTooltip = self.ShowTooltip;
        tooltip:Show();
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
        if self.trackIndex == DataProvider:GetActiveArtifactTrackIndex() then
            self:Hide();
        elseif inCombat then
            self:Disable();
        elseif CommitUtil:IsCommitingInProcess() then
            self:Disable();
            isLoading = true;
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
            end
        end

        self.isActive = isActive;
    end
end


local MainFrameMixin = {};
do
    local DynamicEvents = {
        "PLAYER_REGEN_ENABLED",
        "PLAYER_REGEN_DISABLED",
    };

    function MainFrameMixin:OnShow()
        API.RegisterFrameForEvents(self, DynamicEvents);
        CallbackRegistry:Register("LegionRemix.CommitFinished", self.OnCommitFinished, self);
        self:Refresh();
        self:SetScript("OnEvent", self.OnEvent);
    end

    function MainFrameMixin:OnHide()
        API.UnregisterFrameForEvents(self, DynamicEvents);
        CallbackRegistry:UnregisterCallback("DEBUG_TRAIT_CONFIG_UPDATED", self.OnCommitFinished, self);
        self:UpdateCardFocus();
        self:CloseNodeFlyout();
        self:SetScript("OnEvent", nil);
    end

    function MainFrameMixin:OnEvent(event, ...)
        if event == "PLAYER_REGEN_ENABLED" then
            self.ActivateButton:Update();
        elseif event == "PLAYER_REGEN_DISABLED" then
            self.ActivateButton:Update(true);
        end
        print(event, ...)
    end

    function MainFrameMixin:Refresh(playAnimation)
        ACTIVE_TRACK_INDEX = DataProvider:GetActiveArtifactTrackIndex();
        for _, card in ipairs(self.TrackCards) do
            card:Refresh(playAnimation);
        end
        self.ActivateButton:Update();
        --self:DebugSaveAllNodes();
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
        if InCombatLockdown() then return end;  --Activate button shouldn't be clickable
        self.ActivateButton:Disable();
        CommitUtil:TryPurchaseArtifactTrack(trackIndex);
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
end


local function InitArtifactUI()
    local baseFrameLevel = 20;
    local CreateFrame = CreateFrame;

    local frameName = "PlumberRemixArtifactUI";
    local f = CreateFrame("Frame", frameName, UIParent, "PlumberRemixArtifactUITemplate");
    f:Hide();
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
    local offsetY = 0;

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
                local x = card.Div:GetCenter();
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

    local height = 5 * (cardHeight + cardGap) - cardGap;
    f:SetSize(cardWidth, height);
    f:SetScript("OnHide", f.OnHide);
    f:SetScript("OnShow", f.OnShow);


    local ActivateButton = addon.LandingPageUtil.CreateRedButton(f);
    ActivateButton:Hide();
    f.ActivateButton = ActivateButton;
    API.Mixin(ActivateButton, ActivateButtonMixin);
    ActivateButton:OnLoad();

    local TooltipFrame = CreateFrame("Frame", nil, f, "PlumberLegionRemixTooltipTemplate");
    f.TooltipFrame = TooltipFrame;
    TooltipFrame:Hide();
end

local function ShowArtifactUI()
    if not MainFrame then
        InitArtifactUI();
        MainFrame:Hide();
    end
    MainFrame:Show();
end
RemixAPI.ShowArtifactUI = ShowArtifactUI;

YEET_ShowArtifactUI = ShowArtifactUI;