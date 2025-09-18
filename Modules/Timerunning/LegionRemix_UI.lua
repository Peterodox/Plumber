local _, addon = ...
local RemixAPI = addon.RemixAPI
if not RemixAPI then return end;


local DEBUG_MODE= true;


local API = addon.API;
local DataProvider = RemixAPI.DataProvider;
local CommitUtil = RemixAPI.CommitUtil;
local Easing_OutQuart = addon.EasingFunctions.outQuart;

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


local NodeButtonMixin = {};
do
    function NodeButtonMixin:OnLoad()
        self.Border:SetTexture(TEXTURE_FILE);
        self:SetSquare();
        self.Icon:SetTexCoord(4/64, 60/64, 4/64, 60/64);
        self.Border:SetSize(64, 64);
        self.Icon:SetSize(36, 36);
        self.IconMask:SetSize(36, 36);
    end

    function NodeButtonMixin:OnEnter()

    end

    function NodeButtonMixin:OnLeave()

    end

    function NodeButtonMixin:SetSquare()
        self.entryType = 1;
        self.Border:SetTexCoord(0/1024, 128/1024, 0/1024, 128/1024);
        self.IconMask:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Chamfer", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        self.Icon:Show();
        self.IconMask:Show();
        self.RankText:Hide();
    end

    function NodeButtonMixin:SetCircle()
        self.entryType = 2;
        self.Border:SetTexCoord(128/1024, 256/1024, 0/1024, 128/1024);
        self.IconMask:SetTexture("Interface/AddOns/Plumber/Art/BasicShape/Mask-Circle", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        self.Icon:Show();
        self.IconMask:Show();
        self.RankText:Show();
    end

    function NodeButtonMixin:SetHex()
        self:SetSquare();
    end

    function NodeButtonMixin:SetThreeArrows()
        self.Icon:Hide();
        self.IconMask:Hide();
        self.RankText:Hide();
    end

    function NodeButtonMixin:SetSpell(spellID)
        local iconID, originalIconID = C_Spell.GetSpellTexture(spellID);
        self.Icon:SetTexture(originalIconID or iconID);
    end

    function NodeButtonMixin:SetData(nodeID, entryID, definitionID)
        self.nodeID = nodeID;
        self.entryID = entryID;
        self.definitionID = definitionID;
        local spellID = C_Traits.GetDefinitionInfo(definitionID).spellID;
        self:SetSpell(spellID);
        if self.Title then
            local name = C_Spell.GetSpellName(spellID);
            self.Title:SetText(name);
        end
    end

    function NodeButtonMixin:Refresh()
        if DEBUG_MODE then
            self:SetNodeDisabled(self.trackIndex ~= 1);
            if self.trackIndex == 1 and self.entryType == 2 then
                self.RankText:SetText(3);
                self.RankText:SetTextColor(1, 0.82, 0);
            end
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

        --local increasedRanks = nodeInfo.entryIDToRanksIncreased and nodeInfo.entryIDToRanksIncreased[self.entryID] or 0;
        --local increasedTraitDataList = C_Traits.GetIncreasedTraitData(self.nodeID, self.entryID);

        self:SetNodeDisabled(not(nodeInfo.activeRank > 0 or currentRank > 0));
    end

    function NodeButtonMixin:SetNodeDisabled(disabled)
        if disabled then
            self.Icon:SetDesaturated(true);
            self.Icon:SetVertexColor(0.8, 0.8, 0.8);
        else
            self.Icon:SetDesaturated(false);
            self.Icon:SetVertexColor(1, 1, 1);
        end

        if self.entryType == 1 then
            if disabled then
                self.Border:SetTexCoord(384/1024, 512/1024, 0/1024, 128/1024);
            else
                self.Border:SetTexCoord(0/1024, 128/1024, 0/1024, 128/1024);
            end
        elseif self.entryType == 2 then
            if disabled then
                self.Border:SetTexCoord(512/1024, 640/1024, 0/1024, 128/1024);
            else
                self.Border:SetTexCoord(128/1024, 256/1024, 0/1024, 128/1024);
            end
        end
    end
end


local TrackCardMixin = {};
do
    local ANIM_OFFSET_H_BUTTON_HOVER = 12;
    local ANIM_DURATION_BUTTON_HOVER = 0.25;


    local function ActivateButton_OnEnter(self)
        --local card = self:GetParent();
        --card.HoverHighlight:Show();
    end

    local function ActivateButton_OnLeave(self)
        --local card = self:GetParent();
        --card.HoverHighlight:Hide();
    end

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
        self.Background:SetTexCoord(0/1024, 768/1024, 128/1024, 288/1024);
        self.Div:SetTexture(TEXTURE_FILE);
        self.Div:SetTexCoord(992/1024, 1024/1024, 128/1024, 224/1024);
        self.HoverHighlight:SetTexture(TEXTURE_FILE);
        self.HoverHighlight:SetTexCoord(0/1024, 512/1024, 288/1024, 448/1024);

        self.EdgeMask1:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/TrackCardEdgeMask-Left", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        self.EdgeMask2:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/TrackCardEdgeMask-Right", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
        self.EdgeGlow1:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/EdgeGlow");
        self.EdgeGlow1:SetBlendMode("ADD");
        self.EdgeGlow1:SetVertexColor(205/255, 237/255, 59/255);
        self.EdgeGlow2:SetTexture("Interface/AddOns/Plumber/Art/Timerunning/EdgeGlow");
        self.EdgeGlow2:SetBlendMode("ADD");
        self.EdgeGlow2:SetVertexColor(205/255, 237/255, 59/255);

        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);

        --debug
        self.ActivateButton = addon.LandingPageUtil.CreateRedButton(self);
        self.ActivateButton:SetWidth(128);
        self.ActivateButton:SetButtonText(TALENT_SPEC_ACTIVATE);
        self.ActivateButton:SetPoint("TOP", self, "LEFT", 104, -2);
        self.ActivateButton:Hide();
        self.ActivateButton:SetPropagateMouseMotion(true);
        self.ActivateButton.onEnterFunc = ActivateButton_OnEnter;
        self.ActivateButton.onLeaveFunc = ActivateButton_OnLeave;
    end

    function TrackCardMixin:SetVisualState(state)
        -- 1: Active  2: Inactive
        self.visualState = state;
        if state == 1 then
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
            self.Subtitle:Hide();
        end
    end

    function TrackCardMixin:ShowActivateButton(state)
        if state and not self.activateButtonShown then
            self.activateButtonShown = true;
            self.ActivateButton:Show();
            self:ShowHoverVisual();
        elseif (not state) and self.activateButtonShown then
            self.activateButtonShown = nil;
            self.ActivateButton:Hide();
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

        local alpha = 8 * self.t;
        if alpha > 1 then
            alpha = 1;
        end
        self.ActivateButton:SetAlpha(alpha);
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
        self:SetScript("OnUpdate", Anim_ResetButtonCentent_OnUpdate);
    end
end


local function InitArtifactUI()
    local baseFrameLevel = 20;
    local CreateFrame = CreateFrame;

    local frameName = "PlumberRemixArtifactUI";
    local f = CreateFrame("Frame", frameName, UIParent, "PlumberRemixArtifactUITemplate");
    MainFrame = f;
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    table.insert(UISpecialFrames, frameName);


    --Artifact Abilities
    local buttonSize = Constants.NodeSize;
    local gapV = Constants.NodeSize;
    local gapH = Constants.NodeGap;

    local offsetX = 0;
    local offsetY = 0;

    local numEntries, entryType;
    local nodeID, entryID, definitionID;
    local activeTrackIndex = DEBUG_MODE and 1 or DataProvider:GetActiveArtifactTrackIndex();

    local cardWidth = Constants.CardWidth * Constants.CardScale;
    local cardHeight = Constants.CardHeight * Constants.CardScale;
    local cardGap = 8;

    for index, trackData in ipairs(DataProvider.ArtifactTracks) do
        numEntries = #trackData;
        offsetX = 226;
        offsetY =  (1 - index) * (cardHeight + cardGap);

        local card = CreateFrame("Frame", nil, f, "PlumberLegionRemixCardTemplate");
        API.Mixin(card, TrackCardMixin);
        card:OnLoad();
        card:SetPoint("TOP", f, "TOP", 0, offsetY);
        card:SetFrameLevel(baseFrameLevel - index);

        for i, v in ipairs(trackData) do
            if type(v[1]) == "table" then
                entryType = 0;   --Hex
                v = v[1];   --debug
            else
                if i == 1 then
                    entryType = 1;  --Square
                else
                    entryType = 2;  --Circle
                end
            end
            nodeID, entryID, definitionID = v[1], v[2], v[3];

            local button = CreateFrame("Button", nil, card, "PlumberLegionRemixNodeTemplate");
            API.Mixin(button, NodeButtonMixin);
            button.trackIndex = index;
            button:OnLoad();

            button:SetPoint("LEFT", card, "LEFT", offsetX, 0);
            if entryType == 0 then
                button:SetHex();
            elseif entryType == 1 then
                button:SetSquare();
            else
                button:SetCircle();
            end

            offsetX = offsetX + buttonSize + gapH;

            if i ~= numEntries then
                local arrow = CreateFrame("Button", nil, card, "PlumberLegionRemixThreeArrowsTemplate");
                arrow.Texture:SetTexture(TEXTURE_FILE);
                arrow.Texture:SetTexCoord(256/1024, 320/1024, 0/1024, 64/1024);
                arrow:SetPoint("LEFT", card, "LEFT", offsetX, 0);
                offsetX = offsetX + Constants.ThreeArrowsSize + gapH;
                if index == activeTrackIndex then
                    arrow.Texture:SetTexCoord(256/1024, 320/1024, 0/1024, 64/1024)
                else
                    arrow.Texture:SetTexCoord(320/1024, 384/1024, 64/1024, 128/1024)
                end
            end

            if i == 1 then
                button.Title = card.Title;
                local x = card.Div:GetCenter();
                --print(card:GetLeft() - x);
            end

            button:SetData(nodeID, entryID, definitionID)
            button:Refresh();
        end

        card:SetVisualState(index == 1 and 1 or 2);
    end

    local height = 5 * (cardHeight + cardGap) - cardGap;
    f:SetSize(cardWidth, height);
end

local function ShowArtifactUI()
    if not MainFrame then
        InitArtifactUI();
    end
    MainFrame:Show();
end
RemixAPI.ShowArtifactUI = ShowArtifactUI;

YEET_ShowArtifactUI = ShowArtifactUI;