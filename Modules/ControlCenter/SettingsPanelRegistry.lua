local _, addon = ...
local L = addon.L;
local API = addon.API;


local MainFrame = addon.ControlCenter.SettingsPanel;

local BlizzardPanel = CreateFrame("Frame", nil, UIParent);
BlizzardPanel:Hide();


if Settings then
    local category = Settings.RegisterCanvasLayoutCategory(BlizzardPanel, "Plumber");
    Settings.RegisterAddOnCategory(category);

    BlizzardPanel:SetScript("OnShow", function(self)
        MainFrame:Hide();
        MainFrame:SetParent(BlizzardPanel);
        MainFrame:ClearAllPoints();
        MainFrame:SetPoint("TOPLEFT", self, "TOPLEFT", -10, 6);
        --MainFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
        MainFrame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0);
        MainFrame:ShowUI("blizzard");
    end);

    BlizzardPanel:SetScript("OnHide", function(self)
        self:Hide();
        MainFrame:Hide();
    end);

    --local bg = BlizzardPanel:CreateTexture(nil, "BACKGROUND");
    --bg:SetAllPoints(true);
    --bg:SetColorTexture(1, 0, 0, 0.5);
end


do  --Press Escape to close
    local CloseDummy = CreateFrame("Frame", "PlumberSettingsPanelSpecialFrame", UIParent);
    CloseDummy:Hide();
    table.insert(UISpecialFrames, CloseDummy:GetName());

    CloseDummy:SetScript("OnHide", function()
        if MainFrame:HandleEscape() then
            CloseDummy:Show();
        end
    end);

    MainFrame:HookScript("OnShow", function()
        if MainFrame.mode == "standalone" then
            CloseDummy:Show();
        end
    end);

    MainFrame:HookScript("OnHide", function()
        CloseDummy:Hide();
    end);
end


do  --Globals, AddOn Compartment
    local function Plumber_ToggleSettings()
        if BlizzardPanel:IsShown() then return end;

        if MainFrame:IsShown() then
            MainFrame:Hide();
        else
            MainFrame:ClearAllPoints();
            MainFrame:SetParent(UIParent);
            MainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
            MainFrame:ShowUI();
        end
    end
    _G.Plumber_ToggleSettings = Plumber_ToggleSettings;


    local IDENTIFIER = "PlumberSettings";

    local function AddonCompartment_OnClick()
        Plumber_ToggleSettings();
    end

    local function AddonCompartment_OnEnter(menuButton)
        local tooltip = GameTooltip;
        tooltip:SetOwner(menuButton, "ANCHOR_NONE");
        tooltip:SetPoint("TOPRIGHT", menuButton, "TOPLEFT", -12, 0);
        tooltip:SetText(L["Module Category Plumber"], 1, 1, 1);
        tooltip:AddLine(L["Click To Show Settings"], 1, 0.82, 0, true);
        tooltip:Show();
    end

    local function AddonCompartment_OnLeave(menuButton)
        GameTooltip:Hide();
    end

    API.AddButtonToAddonCompartment(IDENTIFIER, L["Module Category Plumber"], "Interface/AddOns/Plumber/Art/Logo/PlumberLogo64", AddonCompartment_OnClick, AddonCompartment_OnEnter, AddonCompartment_OnLeave);


    API.CreateSlashCommand(Plumber_ToggleSettings, "plumber");


    local EL = CreateFrame("Frame");

    function EL:RequestShowChangelog()
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function EL:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 2 then
            self.t = 0;
            if not(SplashFrame and SplashFrame:IsShown()) then
                self:SetScript("OnUpdate", nil);
                if not MainFrame:IsShown() then
                    Plumber_ToggleSettings();
                    MainFrame:ShowTab("ChangelogTab");
                end
            end
        end
    end

    addon.CallbackRegistry:Register("ShowChangelog", function()
        EL:RequestShowChangelog();
    end);
end