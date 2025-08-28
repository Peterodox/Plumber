local _, addon = ...
local RemixAPI = addon.RemixAPI
if not RemixAPI then return end;


local DataProvider = RemixAPI.DataProvider;
local CommitUtil = RemixAPI.CommitUtil;


local MainFrame;


local function InitArtifactUI()
    local CreateFrame = CreateFrame;

    local frameName = "PlumberRemixArtifactUI";
    local f = CreateFrame("Frame", frameName, UIParent, "PlumberRemixArtifactUITemplate");
    MainFrame = f;
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    table.insert(UISpecialFrames, frameName);


    --Artifact Abilities
    local buttonSize = 40;
    for index, spellID in ipairs(DataProvider:GetArtifactAbilities()) do
        local button = CreateFrame("Button", nil, f, "TalentButtonCircleTemplate");
        button.Icon:SetTexture(C_Spell.GetSpellTexture(spellID));
        button:SetPoint("TOP", f, "TOP", 0, (1 - index) * buttonSize);
        button.artifactTrackIndex = index;
        button:SetVisualState(TalentButtonUtil.BaseVisualState.Normal);
    end

    f:SetSize(40 * 5);
end

local function ShowArtifactUI()
    if not MainFrame then
        InitArtifactUI();
    end
    MainFrame:Show();
end
RemixAPI.ShowArtifactUI = ShowArtifactUI;