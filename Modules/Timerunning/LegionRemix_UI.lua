local _, addon = ...
local RemixAPI = addon.RemixAPI
if not RemixAPI then return end;


local API = addon.API;
local DataProvider = RemixAPI.DataProvider;
local CommitUtil = RemixAPI.CommitUtil;

local TEXTURE_FILE = "Interface/AddOns/Plumber/Art/Timerunning/LegionRemixUI.png";


local MainFrame;


local Constants = {
    NodeSize = 40,
    NodeGap = 4,
    ThreeArrowsSize = 24,
};


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


local function InitArtifactUI()
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
    local activeTrackIndex = DataProvider:GetActiveArtifactTrackIndex();

    for index, trackData in ipairs(DataProvider.ArtifactTracks) do
        numEntries = #trackData;
        offsetX = 0;
        offsetY =  (1 - index) * (buttonSize + gapV);
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
            
            local button = CreateFrame("Button", nil, f, "PlumberLegionRemixNodeTemplate");
            API.Mixin(button, NodeButtonMixin);
            button:OnLoad();
            
            button:SetPoint("LEFT", f, "TOPLEFT", offsetX, offsetY);
            if entryType == 0 then
                button:SetHex();
            elseif entryType == 1 then
                button:SetSquare();
            else
                button:SetCircle();
            end

            offsetX = offsetX + buttonSize + gapH;

            if i ~= numEntries then
                local arrow = CreateFrame("Button", nil, f, "PlumberLegionRemixThreeArrowsTemplate");
                arrow.Texture:SetTexture(TEXTURE_FILE);
                arrow.Texture:SetTexCoord(256/1024, 320/1024, 0/1024, 64/1024);
                arrow:SetPoint("LEFT", f, "TOPLEFT", offsetX, offsetY);
                offsetX = offsetX + Constants.ThreeArrowsSize + gapH;
                if index == activeTrackIndex then
                    arrow.Texture:SetTexCoord(256/1024, 320/1024, 0/1024, 64/1024)
                else
                    arrow.Texture:SetTexCoord(320/1024, 384/1024, 64/1024, 128/1024)
                end
            end

            if i == 1 then
                local title = f:CreateFontString(nil, "OVERLAY", "ObjectiveTrackerHeaderFont");
                title:SetSize(240, 16);
                title:SetPoint("RIGHT", button, "LEFT", -buttonSize, 0);
                title:SetJustifyH("CENTER");
                button.Title = title;
                title:SetTextColor(0.6, 0.59, 0.49);
            end

            button:SetData(nodeID, entryID, definitionID)
            button:Refresh();
        end
    end

    local height = 5 * (buttonSize + gapV) - gapV;
    f:SetSize(buttonSize, height);
end

local function ShowArtifactUI()
    if not MainFrame then
        InitArtifactUI();
    end
    MainFrame:Show();
end
RemixAPI.ShowArtifactUI = ShowArtifactUI;