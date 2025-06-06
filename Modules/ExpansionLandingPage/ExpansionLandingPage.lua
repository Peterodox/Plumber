local _, addon = ...
local API = addon.API;
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;


local MainFrame;


local CreateTabButton;
do  --TabButtonMixin
    local TEXT_OFFSET = 8;
    local BUTTON_HEIGHT = 32;
    local TabButtonMixin = {};

    function TabButtonMixin:OnClick()
        LandingPageUtil.SelectTab(self.tabKey);
        MainFrame:InitTabs();
    end

    function TabButtonMixin:OnEnter()
        self.Name:SetAlpha(1);
        if not self.selected then
            self.Name:SetTextColor(1, 1, 1);
        end
    end

    function TabButtonMixin:OnLeave()
        self.Name:SetAlpha(0.9);
        self:SetSelected(self.selected);
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
        return button
    end
end


do
    PlumberExpansionLandingPageMixin = {};

    function PlumberExpansionLandingPageMixin:OnLoad()
        self.OnLoad = nil;
        MainFrame = self;

        local NineSlice;
        local borderOffset = -30;

        NineSlice = LandingPageUtil.CreateExpansionThemeFrame(self.LeftSection, 10);
        self.LeftSection.NineSlice = NineSlice;
        NineSlice.Background:SetColorTexture(0.082, 0.047, 0.027);

        NineSlice = LandingPageUtil.CreateExpansionThemeFrame(self.RightSection, 10);
        self.RightSection.NineSlice = NineSlice;
        NineSlice.Background:SetAtlas("thewarwithin-landingpage-background", false);
        NineSlice:ShowCloseButton(true);
        NineSlice:SetCloseButtonOwner(self);
        local a = 0.4;
        NineSlice.Background:SetVertexColor(a, a, a);

        local tex = "Interface/AddOns/Plumber/Art/Frame/ExpansionBorder_TWW";

        self.RightSection.Header.DividerLeft:SetTexture(tex);
        self.RightSection.Header.DividerLeft:SetTexCoord(0.5, 634/1024, 0, 48/512);
        self.RightSection.Header.DividerRight:SetTexture(tex);
        self.RightSection.Header.DividerRight:SetTexCoord(634/1024, 1, 0, 48/512);

        self:InitTabButtons();
        self:InitLeftSection();

        table.insert(UISpecialFrames, self:GetName());

        LandingPageUtil.SelectTabByIndex(1);

        self:SetScript("OnShow", self.OnShow);
    end




    function PlumberExpansionLandingPageMixin:OnShow()
        self:InitTabs();    --The selected tab will be created here
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
        local totalWidth = 48;
        local buttonContainer = self.RightSection.Header;

        for i, tabInfo in LandingPageUtil.EnumerateTabInfo() do
            button = self.TabButtons[i];
            if not button then
                button = CreateTabButton(buttonContainer);
                self.TabButtons[i] = button;
            end
            button.tabKey = tabInfo.key;
            buttonWidth = API.Round(button:SetName(tabInfo.name));
            button:ClearAllPoints();
            button:SetPoint("LEFT", buttonContainer, "LEFT", totalWidth, -12);
            totalWidth = totalWidth + buttonWidth + 0;
        end

        self:UpdateTabButtons();
    end

    function PlumberExpansionLandingPageMixin:UpdateTabButtons()
        local selectedTabKey = LandingPageUtil.GetSelectedTabKey();
        for _, button in ipairs(self.TabButtons) do
            button:SetSelected(button.tabKey == selectedTabKey);
        end
    end

    function PlumberExpansionLandingPageMixin:InitTabs()
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
        local categories = {
            {name = "Great Vault", frameGetter = LandingPageUtil.CreateGreatVaultFrame, validate = API.IsPlayerAtMaxLevel},
            {name = "Item Upgrade", frameGetter = LandingPageUtil.CreateItemUpgradeFrame},
            {name = "Resources", frameGetter = LandingPageUtil.CreateCurrencyList},
        };

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

    function PlumberExpansionLandingPageMixin:ToggleUI()
        self:SetShown(not self:IsShown());
    end
end