local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;
local LandingPageUtil = addon.LandingPageUtil;
local IS_MOP = addon.IS_MOP;


local MainFrame;


local CreateTabButton;
do  --TabButtonMixin
    local TEXT_OFFSET = 10;
    local BUTTON_HEIGHT = 32;
    local TabButtonMixin = {};

    function TabButtonMixin:OnClick()
        LandingPageUtil.SelectTab(self.tabKey);
        MainFrame:UpdateTabs();
        LandingPageUtil.PlayUISound("SwitchTab");
    end

    function TabButtonMixin:OnEnter()
        self.Name:SetAlpha(1);
        if not self.selected then
            self.Name:SetTextColor(1, 1, 1);
        end

        if self.notificationGetter then
            local tooltipLines = self.notificationGetter(true);
            if tooltipLines and type(tooltipLines) == "table" then
                local tooltip = GameTooltip;
                tooltip:SetOwner(self, "ANCHOR_RIGHT", -8, -4);
                for i, line in ipairs(tooltipLines) do
                    if i == 1 then
                        tooltip:SetText(line, 1, 1, 1, true);
                    else
                        tooltip:AddLine(line, 1, 0.82, 0, true);
                    end
                end
                tooltip:Show();
            end
        end
    end

    function TabButtonMixin:OnLeave()
        self.Name:SetAlpha(0.9);
        self:SetSelected(self.selected);
        GameTooltip:Hide();
    end

    function TabButtonMixin:SetSelected(state)
        self.selected = state;
        if state then
            self.Name:SetTextColor(1, 1, 1);
        else
            self.Name:SetTextColor(1, 0.82, 0);
        end
    end

    function TabButtonMixin:OnMouseDown()
        self.Name:SetPoint("LEFT", self, "LEFT", self.leftOffset or TEXT_OFFSET, -1);
    end

    function TabButtonMixin:OnMouseUp()
        self.Name:SetPoint("LEFT", self, "LEFT", self.leftOffset or TEXT_OFFSET, 0);
    end

    function TabButtonMixin:SetName(name)
        self.Name:SetText(name);
        local width = self.Name:GetWrappedWidth() + 2 * TEXT_OFFSET;
        if width < BUTTON_HEIGHT then
            self.leftOffset = 0.5 * (BUTTON_HEIGHT - width);
            width = BUTTON_HEIGHT;
        else
            self.leftOffset = TEXT_OFFSET;
        end
        self.Name:SetPoint("LEFT", self, "LEFT", self.leftOffset, 0);
        self:SetWidth(width);
        return width
    end

    function TabButtonMixin:ShowGreenDot(state)
        self.GreenDot:SetShown(state);
    end

    function TabButtonMixin:UpdateNotification()
        if self.notificationGetter then
            if self.notificationGetter() then
                self:ShowGreenDot(true);
                return
            end
        end
        self:ShowGreenDot(false);
    end

    function CreateTabButton(parent)
        local button = CreateFrame("Button", nil, parent);
        API.Mixin(button, TabButtonMixin);
        button:SetScript("OnClick", button.OnClick);
        button:SetScript("OnEnter", button.OnEnter);
        button:SetScript("OnLeave", button.OnLeave);
        button:SetScript("OnMouseDown", button.OnMouseDown);
        button:SetScript("OnMouseUp", button.OnMouseUp);
        button:SetSize(BUTTON_HEIGHT, BUTTON_HEIGHT);

        button.Name = button:CreateFontString(nil, "OVERLAY", "PlumberFont_16");
        button.Name:SetPoint("LEFT", button, "LEFT", TEXT_OFFSET, 0);
        button.Name:SetAlpha(0.9);

        button.GreenDot = button:CreateTexture(nil, "OVERLAY");
        button.GreenDot:SetSize(16, 16);
        button.GreenDot:SetPoint("CENTER", button.Name, "TOPRIGHT", 4, 2);
        button.GreenDot:Hide();
        button.GreenDot:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/AlertFrame", nil, nil, "TRILINEAR");
        button.GreenDot:SetTexCoord(0/512, 32/512, 0/512, 32/512);

        return button
    end
end


do
    PlumberExpansionLandingPageMixin = {};

    function PlumberExpansionLandingPageMixin:OnLoad()
        self.OnLoad = nil;
        MainFrame = self;

        local NineSlice;

        NineSlice = LandingPageUtil.CreateExpansionThemeFrame(self.LeftSection, 10);
        self.LeftSection.NineSlice = NineSlice;

        NineSlice = LandingPageUtil.CreateExpansionThemeFrame(self.RightSection, 10);
        self.RightSection.NineSlice = NineSlice;

        NineSlice:ShowCloseButton(true);
        NineSlice:SetCloseButtonOwner(self);

        if not IS_MOP then
            NineSlice.Background:SetAtlas("thewarwithin-landingpage-background", false);
            local a = 0.25;
            NineSlice.Background:SetVertexColor(a, a, a);
        end

        local Divider = LandingPageUtil.CreateMajorDivider(self.RightSection.Header);
        Divider:SetPoint("LEFT", self.RightSection.Header, "BOTTOMLEFT", 32, 0);
        Divider:SetPoint("RIGHT", self.RightSection.Header, "BOTTOMRIGHT", -32, 0);

        self:InitTabButtons();
        --self:InitLeftSection();

        table.insert(UISpecialFrames, self:GetName());

        LandingPageUtil.SelectTabByIndex(1);

        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);


        --Events triggerd in ModuleRegistry.lua
        CallbackRegistry:Register("ParagonRewardReady", self.RequestUpdateTabButtons, self);
        CallbackRegistry:Register("ParagonRewardQuestTurnedIn", self.RequestUpdateTabButtons, self);
    end

    addon.CallbackRegistry:Register("DBLoaded", function(db)
        local tabKey = addon.GetDBValue("LandingPage_DefaultTab");
        LandingPageUtil.SelectTab(tabKey);
    end);

    addon.CallbackRegistry:Register("TimerunningSeason", function(seasonID)
        if seasonID == 2 then
            MainFrame.isLegionRemix = true;
        end
    end);


    function PlumberExpansionLandingPageMixin:OnShow()
        if self.InitLeftSection then
            self:InitLeftSection();
        end

        self:UpdateTabs();    --The selected tab will be created here
        LandingPageUtil.PlayUISound("LandingPageOpen");
        if not self:IsUserPlaced() then
            self:ResetPosition();
        end
    end

    function PlumberExpansionLandingPageMixin:OnHide()
        LandingPageUtil.PlayUISound("LandingPageClose");
        LandingPageUtil.MainContextMenu:HideMenu();
    end

    function PlumberExpansionLandingPageMixin:InitTabButtons()
        if not self.TabButtons then
            self.TabButtons = {};
        end

        for _, button in ipairs(self.TabButtons) do
            button:Hide();
        end

        local button;
        local buttonWidth;
        local totalWidth = 46;
        local buttonContainer = self.RightSection.Header;

        for i, tabInfo in LandingPageUtil.EnumerateTabInfo() do
            button = self.TabButtons[i];
            if not button then
                button = CreateTabButton(buttonContainer);
                self.TabButtons[i] = button;
            end
            button.tabKey = tabInfo.key;
            button.notificationGetter = tabInfo.notificationGetter;
            buttonWidth = API.Round(button:SetName(tabInfo.name));
            button:ClearAllPoints();
            button:SetPoint("LEFT", buttonContainer, "LEFT", totalWidth, -12);
            totalWidth = totalWidth + buttonWidth + 0;
        end

        self:UpdateTabButtons();


        local function Header_OnMouseWheel(_, delta)
            --Scroll up will go the left tab
            LandingPageUtil.SelectTabByDelta(-delta);
            self:UpdateTabs();
        end
        buttonContainer:SetScript("OnMouseWheel", Header_OnMouseWheel);
    end

    function PlumberExpansionLandingPageMixin:UpdateTabButtons()
        local selectedTabKey = LandingPageUtil.GetSelectedTabKey();
        for _, button in ipairs(self.TabButtons) do
            button:SetSelected(button.tabKey == selectedTabKey);
            button:UpdateNotification();
        end
    end

    function PlumberExpansionLandingPageMixin:RequestUpdateTabButtons()
        if self.TabButtons and self:IsVisible() then
            self:UpdateTabButtons();
        end
    end

    function PlumberExpansionLandingPageMixin:UpdateTabs()
        self:UpdateTabButtons();

        local selectedTabKey = LandingPageUtil.GetSelectedTabKey();
        local tabContainer = self.RightSection.TabContainer;

        for i, tabInfo in LandingPageUtil.EnumerateTabInfo() do
            if tabInfo.key == selectedTabKey then
                if not tabInfo.frame then
                    local f = LandingPageUtil.AcquireTabFrame(tabContainer, i);
                    if f.OnShow then
                        f:OnShow();
                    end
                end
                break
            end
        end
    end

    function PlumberExpansionLandingPageMixin:InitLeftSection()
        self.InitLeftSection = nil;

        local categories = {
            {name = L["Great Vault"], frameGetter = LandingPageUtil.CreateGreatVaultFrame, validate = API.IsGreatVaultFeatureAvailable},
            {name = L["Item Upgrade"], frameGetter = LandingPageUtil.CreateItemUpgradeFrame},
            {name = L["Resources"], frameGetter = LandingPageUtil.CreateCurrencyList},
        };

        if self.isLegionRemix then
            table.remove(categories, 1);
            table.remove(categories, 1);
        end

        local numCategories = #categories;

        local offsetY = 16;
        local relativeTo = self.LeftSection;
        local container = self.LeftSection.DefaultFrame;
        local categoryButtonHeight = 32;
        local lineGap = 8;
        local paragraphGap = 8;

        for k, v in ipairs(categories) do
            if (not v.validate) or (v.validate and v.validate()) then
                local categoryButton = LandingPageUtil.CreateListCategoryButton(container, v.name);
                categoryButton:SetPoint("TOP", relativeTo, "TOP", 0, -offsetY);
                offsetY = offsetY + categoryButtonHeight;
                if v.frameGetter then
                    offsetY = offsetY + lineGap;
                    local frame, height = v.frameGetter(container);
                    frame:SetPoint("TOP", relativeTo, "TOP", 0, -offsetY);
                    offsetY = offsetY + height;
                    if k == numCategories then
                        frame:SetPoint("BOTTOM", relativeTo, "BOTTOM", 0, 16);
                    end
                    frame:Refresh();
                end
                offsetY = offsetY + paragraphGap;
            end
        end
    end

    function PlumberExpansionLandingPageMixin:ShowLeftFrame(state)
        self.LeftSection.DefaultFrame:SetShown(state);
    end
    function LandingPageUtil.ShowLeftFrame(state)
        MainFrame:ShowLeftFrame(state);
    end

    function PlumberExpansionLandingPageMixin:DimBackground(state)
        if IS_MOP then
            self.LeftSection.NineSlice.Background:SetAlpha(0.8);
            self.RightSection.NineSlice.Background:SetAlpha(0.8);
            self:EnableMouse(false);
            --self:EnableDynamicTransparency(true);
            return
        end
        local a = state and 0.25 or 0.4;
        self.RightSection.NineSlice.Background:SetVertexColor(a, a, a);
    end
    function LandingPageUtil.DimBackground(state)
        MainFrame:DimBackground(state);
    end

    function PlumberExpansionLandingPageMixin:ToggleUI()
        self:SetShown(not self:IsShown());
    end

    function PlumberExpansionLandingPageMixin:ResetPosition()
        self:ClearAllPoints();
        if IS_MOP then
            self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -116);
        else
            self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 64, -150);
        end
    end

    function PlumberExpansionLandingPageMixin:EnableDynamicTransparency(state)
        local events = {
            "PLAYER_STARTED_LOOKING",
            "PLAYER_STARTED_MOVING",
            "PLAYER_STARTED_TURNING",
            "PLAYER_STOPPED_LOOKING",
            "PLAYER_STOPPED_MOVING",
            "PLAYER_STOPPED_TURNING",
        };

        if state and not self.TransparencyListener then
            local f = CreateFrame("Frame", nil, self);
            self.TransparencyListener = f;
            f:Hide();
            f.t = 0;

            f:SetScript("OnShow", function()
                API.RegisterFrameForEvents(f, events);
            end);

            f:SetScript("OnHide", function()
                API.UnregisterFrameForEvents(f, events);
            end);

            f:SetScript("OnEvent", function(_, event, ...)
                local alpha;
                if IsMouselooking() or IsPlayerMoving() then
                    alpha = 0.2;
                else
                    alpha = 0.8;
                end
                self.RightSection.NineSlice.Background:SetAlpha(alpha);
            end);

            f:SetScript("OnUpdate", function(_, elapsed)
                f.t = f.t + elapsed;
                if f.t > 0.25 then
                    f.t = 0;
                    f._isMouseOver = self:IsMouseOver();
                    if f.isMouseOver ~= f._isMouseOver then
                        f.isMouseOver = f._isMouseOver;
                    end
                end
            end);
        end

        if state then
            self.TransparencyListener:Show();
        else
            if self.TransparencyListener then
                self.TransparencyListener:Hide();
            end
        end

        self:EnableMouse(false);
    end
end