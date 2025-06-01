local _, addon = ...
local API = addon.API;

local LandingPageUtil = {};
addon.LandingPageUtil = LandingPageUtil;


local TEXTURE_FILE = "Interface/AddOns/Plumber/Art/Frame/ExpansionBorder_TWW";

local CreateFrame = CreateFrame;
local ipairs = ipairs;
local tinsert = table.insert;
local tremove = table.remove;
local IsShiftKeyDown = IsShiftKeyDown;


local function SetupThreeSliceBackground(frame, textureFile, leftOffset, rightOffset)
    if not frame.Left then
        frame.Left = frame:CreateTexture(nil, "BACKGROUND");
    end
    frame.Left:SetPoint("LEFT", frame, "LEFT", leftOffset or 0, 0);
    frame.Left:SetTexture(textureFile);

    if not frame.Right then
        frame.Right = frame:CreateTexture(nil, "BACKGROUND");
    end
    frame.Right:SetPoint("RIGHT", frame, "RIGHT", rightOffset or 0, 0);
    frame.Right:SetTexture(textureFile);

    if not frame.Center then
        frame.Center = frame:CreateTexture(nil, "BACKGROUND");
        frame.Center:SetPoint("TOPLEFT", frame.Left, "TOPRIGHT", 0, 0);
        frame.Center:SetPoint("BOTTOMRIGHT", frame.Right, "BOTTOMLEFT", 0, 0);
    end
    frame.Center:SetTexture(textureFile);
end
API.SetupThreeSliceBackground = SetupThreeSliceBackground;


local ExpansionThemeFrameMixin = {};
do
    function ExpansionThemeFrameMixin:ShowCloseButton(state)
        if state then
            self.pieces[3]:SetTexCoord(518/1024, 646/1024, 48/512, 176/512);
        else
            self.pieces[3]:SetTexCoord(384/1024, 512/1024, 0/512, 128/512);
        end
        self.CloseButton:SetShown(state);
    end

    function ExpansionThemeFrameMixin:SetCloseButtonOwner(frameToClose)
        self.CloseButton.frameToClose = frameToClose;
    end


    function LandingPageUtil.CreateExpansionThemeFrame(parent, expansionID)
        local tex = TEXTURE_FILE;

        local f = addon.CreateNineSliceFrame(parent or UIParent, "ExpansionBorder_TWW");
        f:SetUsingParentLevel(true);
        f:SetCornerSize(64, 64);
        f:SetDisableSharpening(false);
        f:CoverParent(-30);

        local Background = f:CreateTexture(nil, "BACKGROUND");
        f.Background = Background;
        Background:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -4);
        Background:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -4, 4);

        f.pieces[1]:SetTexCoord(0/1024, 128/1024, 0/512, 128/512);
        f.pieces[2]:SetTexCoord(128/1024, 384/1024, 0/512, 128/512);
        f.pieces[3]:SetTexCoord(384/1024, 512/1024, 0/512, 128/512);
        f.pieces[4]:SetTexCoord(0/1024, 128/1024, 128/512, 384/512);
        f.pieces[5]:SetTexCoord(128/1024, 384/1024, 128/512, 384/512);
        f.pieces[6]:SetTexCoord(384/1024, 512/1024, 128/512, 384/512);
        f.pieces[7]:SetTexCoord(0/1024, 128/1024, 384/512, 512/512);
        f.pieces[8]:SetTexCoord(128/1024, 384/1024, 384/512, 512/512);
        f.pieces[9]:SetTexCoord(384/1024, 512/1024, 384/512, 512/512);

        local CloseButton = CreateFrame("Button", nil, f);
        f.CloseButton = CloseButton;
        CloseButton:Hide();
        CloseButton:SetSize(32, 32);
        CloseButton:SetPoint("CENTER", f.pieces[3], "TOPRIGHT", -20.5, -20.5);
        CloseButton.Texture = CloseButton:CreateTexture(nil, "OVERLAY");
        CloseButton.Texture:SetPoint("CENTER", CloseButton, "CENTER", 0, 0);
        CloseButton.Texture:SetSize(24, 24);
        CloseButton.Texture:SetTexture(tex)
        CloseButton.Texture:SetTexCoord(646/1024, 694/1024, 48/512, 96/512);
        CloseButton.Highlight = CloseButton:CreateTexture(nil, "HIGHLIGHT");
        CloseButton.Highlight:SetPoint("CENTER", CloseButton, "CENTER", 0, 0);
        CloseButton.Highlight:SetSize(24, 24);
        CloseButton.Highlight:SetTexture(tex)
        CloseButton.Highlight:SetTexCoord(646/1024, 694/1024, 48/512, 96/512);
        CloseButton.Highlight:SetBlendMode("ADD");
        CloseButton.Highlight:SetAlpha(0.5);

        CloseButton:SetScript("OnClick", function(self)
            if self.frameToClose then
                if self.frameToClose.Close then
                    self.frameToClose:Close();
                else
                    self.frameToClose:Hide();
                end
            end
        end);

        API.Mixin(f, ExpansionThemeFrameMixin);

        return f
    end
end


local ListCategoryButtonMixin = {};
do
    function ListCategoryButtonMixin:SetName(name)
        self.Name:SetText(name);
    end


    function LandingPageUtil.CreateListCategoryButton(parent, name)
        local f = CreateFrame("Button", nil, parent);
        API.Mixin(f, ListCategoryButtonMixin);
        f:SetSize(240, 32); --debug

        f.bg = f:CreateTexture(nil, "BACKGROUND");
        f.bg:SetAllPoints(true);
        --f.bg:SetColorTexture(1, 1, 1, 0.2);

        f.Name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Name:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.Name:SetJustifyH("CENTER");
        f.Name:SetTextColor(0.804, 0.667, 0.498);

        SetupThreeSliceBackground(f, TEXTURE_FILE, -3, 3);
        f.Left:SetSize(20, 32);
        f.Left:SetTexCoord(694/1024, 734/1024, 48/512, 112/512);
        f.Right:SetSize(20, 32);
        f.Right:SetTexCoord(910/1024, 950/1024, 48/512, 112/512);
        f.Center:SetTexCoord(734/1024, 910/1024, 48/512, 112/512);

        if name then
            f:SetName(name);
        end

        return f
    end
end


do  --TabUtil
    local Tabs = {};
    local SelectedTabKay;

    function LandingPageUtil.AddTab(tabInfo)
        table.insert(Tabs, tabInfo);
    end

    function LandingPageUtil.AcquireTabFrame(tabContainer, index)
        local tabInfo = Tabs[index];
        if not tabInfo.frame then
            local f = CreateFrame("Frame", nil, tabContainer);
            Tabs[index].frame = f;
            f:SetAllPoints(true);
            f.tabInfo = tabInfo;
            if tabInfo.initFunc then
                tabInfo.initFunc(f);
            end
        end
        return tabInfo.frame
    end

    function LandingPageUtil.EnumerateTabInfo()
        return ipairs(Tabs);
    end

    function LandingPageUtil.GetNumTabs()
        return #Tabs
    end

    function LandingPageUtil.SelectTab(tabKey)
        SelectedTabKay = tabKey;
        for _, tabInfo in ipairs(Tabs) do
            if tabInfo.frame then
                tabInfo.frame:SetShown(tabInfo.key == tabKey);
            end

            if tabInfo.key == tabKey then
                if not tabInfo.useCustomLeftFrame then
                    LandingPageUtil.ShowLeftFrame(true);
                end

                if tabInfo.onTabSelected then
                    tabInfo.onTabSelected();
                end
            end
        end
    end

    function LandingPageUtil.SelectTabByIndex(index)
        local tabKey = Tabs[index] and Tabs[index].key;
        if tabKey then
            LandingPageUtil.SelectTab(tabKey);
        end
    end

    function LandingPageUtil.GetSelectedTabKey()
        return SelectedTabKay
    end
end


local AtlasUtil = {};
addon.AtlasUtil = AtlasUtil;
do  --Atlas
    local FACTION_ICONS = "Interface/AddOns/Plumber/Art/Frame/MajorFactionIcons.png";
    local FACTION_ICONS_COORDS = {
        --[factionID] = {icon l, r, t, b, highlight l, r, t, b}
        [2590] = {0  , 128, 0, 128},      --Council of Dornogal
        [2594] = {128, 256, 0, 128},      --The Assembly of the Deeps
        [2570] = {256, 384, 0, 128},      --Hallowfall Arathi
        [2600] = {384, 512, 0, 128},      --Severed Threads
        [2653] = {512, 640, 0, 128},      --Cartels of Undermine
        [2685] = {640, 768, 0, 128},      --Gallagio Loyalty Rewards Club
        [2688] = {768, 896, 0, 128},      --Flame's Radiance

    };

    local function SetTextureDimension(textureObject, file, width, height, l, r, t, b, useTrilinearFilter)
        if useTrilinearFilter then
            textureObject:SetTexture(file, nil, nil, true);
        else
            textureObject:SetTexture(file);
        end
        textureObject:SetTexCoord(l/width, r/width, t/height, b/height);
    end

    function AtlasUtil.SetFactionIcon(textureObject, factionID)
        --SetAtlas(string.format("majorfactions_icons_%s512", factionData.textureKit))
        local v = FACTION_ICONS_COORDS[factionID];
        if v then
            SetTextureDimension(textureObject, FACTION_ICONS, 1024, 1024, v[1], v[2], v[3], v[4]);
            return true
        end
        return false
    end

    function AtlasUtil.SetFactionIconHighlight(textureObject, factionID)
        local v = FACTION_ICONS_COORDS[factionID];
        if v then
            SetTextureDimension(textureObject, FACTION_ICONS, 1024, 1024, v[1], v[2], v[3] + 128, v[4] + 128, true);
            return true
        end
        return false
    end
end




--[[
do  --SoftTargetName
    local EL = CreateFrame("Frame");

    function EL:OnEvent(event, ...)
        if event == "NAME_PLATE_UNIT_ADDED" then
            local unit = ...
            local nameplate = C_NamePlate.GetNamePlateForUnit(unit);
            if nameplate then
                local f = nameplate.UnitFrame.SoftTargetFrame;
                if f:IsShown() then
                    if not f.SoftTargetFontString then
                        f.SoftTargetFontString = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
                        f.SoftTargetFontString:SetPoint("TOP", f.Icon, "BOTTOM", 0, -4);
                    end
                    f.SoftTargetFontString:SetText(UnitName(unit));
                    f.SoftTargetFontString:Show();

                    local textureFile = f.Icon:GetTexture();
                    --To determine if the interaction is in range:
                    if string.find(string.lower(textureFile), "unable") then
                        f.SoftTargetFontString:SetTextColor(0.5, 0.5, 0.5);
                    else
                        f.SoftTargetFontString:SetTextColor(1, 0.82, 0);
                    end
                    self.softTargetUnit = unit;
                else
                    if f.SoftTargetFontString then
                        f.SoftTargetFontString:Hide();
                    end
                end
            end
        elseif event == "PLAYER_SOFT_INTERACT_CHANGED" then
            local oldTarget, newTarget = ...
            if not newTarget then
                self.softTargetUnit = nil;
            end
            if self.softTargetUnit then
                self:OnEvent("NAME_PLATE_UNIT_ADDED", self.softTargetUnit);
            end
        end
    end

    EL:SetScript("OnEvent", EL.OnEvent);
    EL:RegisterEvent("NAME_PLATE_UNIT_ADDED");
    EL:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED");
end
--]]