local _, addon = ...
local L = addon.L;
local API = addon.API;
local Mixin = API.Mixin;


local LandingPageUtil = {};
addon.LandingPageUtil = LandingPageUtil;


local TEXTURE_FILE = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/ExpansionBorder_TWW";

local CreateFrame = CreateFrame;
local ipairs = ipairs;
local tinsert = table.insert;
local tremove = table.remove;


local CreateObjectPool;
do  --Object Pool
    local ObjectPoolMixin = {};

    function ObjectPoolMixin:ReleaseAll()
        for _, obj in ipairs(self.activeObjects) do
            obj:Hide();
            obj:ClearAllPoints();
            if self.onRemoved then
                self.onRemoved(obj);
            end
        end

        local tbl = {};
        for k, object in ipairs(self.objects) do
            tbl[k] = object;
        end
        self.unusedObjects = tbl;
        self.activeObjects = {};
    end

    function ObjectPoolMixin:ReleaseObject(object)
        object:Hide();
        object:ClearAllPoints();

        if self.onRemoved then
            self.onRemoved(object);
        end

        local found;
        for k, obj in ipairs(self.activeObjects) do
            if obj == object then
                found = true;
                tremove(self.activeObjects, k);
                break
            end
        end

        if found then
            tinsert(self.unusedObjects, object);
        end
    end

    function ObjectPoolMixin:Acquire()
        local object = tremove(self.unusedObjects);
        if not object then
            object = self.create();
            object.Release = self.Object_Release;
            tinsert(self.objects, object);
        end
        tinsert(self.activeObjects, object);
        if self.onAcquired then
            self.onAcquired(object);
        end
        object:Show();
        return object
    end

    function ObjectPoolMixin:CallMethod(method, ...)
        for _, object in ipairs(self.activeObjects) do
            object[method](object, ...);
        end
    end

    function ObjectPoolMixin:CallMethodByPredicate(predicate, method, ...)
        for _, object in ipairs(self.activeObjects) do
            if predicate(object) then
                object[method](object, ...);
            end
        end
    end

    function ObjectPoolMixin:ProcessActiveObjects(processFunc)
        for _, object in ipairs(self.activeObjects) do
            if processFunc(object) then
                return
            end
        end
    end

    function CreateObjectPool(create, onAcquired, onRemoved)
        local pool = {};
        Mixin(pool, ObjectPoolMixin);

        pool.objects = {};
        pool.activeObjects = {};
        pool.unusedObjects = {};

        pool.create = create;
        pool.onAcquired = onAcquired;
        pool.onRemoved = onRemoved;

        function pool.Object_Release(obj)
            pool:ReleaseObject(obj);
        end

        return pool
    end
    LandingPageUtil.CreateObjectPool = CreateObjectPool;
end


local function CreateThreeSliceTextures(frame, layer, leftKey, centerKey, rightKey, textureFile, leftOffset, rightOffset)
    local Left = frame[leftKey];
    if not Left then
        Left = frame:CreateTexture(nil, layer);
        frame[leftKey] = Left;
    end
    Left:SetPoint("LEFT", frame, "LEFT", leftOffset or 0, 0);
    Left:SetTexture(textureFile);

    local Right = frame[rightKey];
    if not Right then
        Right = frame:CreateTexture(nil, layer);
        frame[rightKey] = Right;
    end
    Right:SetPoint("RIGHT", frame, "RIGHT", rightOffset or 0, 0);
    Right:SetTexture(textureFile);

    local Center = frame[centerKey];
    if not Center then
        Center = frame:CreateTexture(nil, layer);
        frame[centerKey] = Center;
        Center:SetPoint("TOPLEFT", Left, "TOPRIGHT", 0, 0);
        Center:SetPoint("BOTTOMRIGHT", Right, "BOTTOMLEFT", 0, 0);
    end
    Center:SetTexture(textureFile);
end

local function SetupThreeSliceBackground(frame, textureFile, leftOffset, rightOffset)
    CreateThreeSliceTextures(frame, "BACKGROUND", "Left", "Center", "Right", textureFile, leftOffset, rightOffset);
end
API.SetupThreeSliceBackground = SetupThreeSliceBackground;

local function SetupThressSliceHighlight(frame, textureFile, leftOffset, rightOffset)
    CreateThreeSliceTextures(frame, "HIGHLIGHT", "HighlightLeft", "HighlightCenter", "HighlightRight", textureFile, leftOffset, rightOffset);
    local alpha = 0.25;
    frame.HighlightLeft:SetBlendMode("ADD");
    frame.HighlightLeft:SetAlpha(alpha);
    frame.HighlightCenter:SetBlendMode("ADD");
    frame.HighlightCenter:SetAlpha(alpha);
    frame.HighlightRight:SetBlendMode("ADD");
    frame.HighlightRight:SetAlpha(alpha);
end
API.SetupThressSliceHighlight = SetupThressSliceHighlight;


local ExpansionThemeFrameMixin = {};
do
    function ExpansionThemeFrameMixin:ShowCloseButton(state)
        if state then
            self.pieces[3]:SetTexCoord(518/1024, 646/1024, 48/1024, 176/1024);
        else
            self.pieces[3]:SetTexCoord(384/1024, 512/1024, 0/1024, 128/1024);
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
        Background:SetColorTexture(0.067, 0.040, 0.024);    --0.082, 0.047, 0.027

        f:SetTexture(tex);
        f.pieces[1]:SetTexCoord(0/1024, 128/1024, 0/1024, 128/1024);
        f.pieces[2]:SetTexCoord(128/1024, 384/1024, 0/1024, 128/1024);
        f.pieces[3]:SetTexCoord(384/1024, 512/1024, 0/1024, 128/1024);
        f.pieces[4]:SetTexCoord(0/1024, 128/1024, 128/1024, 384/1024);
        f.pieces[5]:SetTexCoord(128/1024, 384/1024, 128/1024, 384/1024);
        f.pieces[6]:SetTexCoord(384/1024, 512/1024, 128/1024, 384/1024);
        f.pieces[7]:SetTexCoord(0/1024, 128/1024, 384/1024, 512/1024);
        f.pieces[8]:SetTexCoord(128/1024, 384/1024, 384/1024, 512/1024);
        f.pieces[9]:SetTexCoord(384/1024, 512/1024, 384/1024, 512/1024);

        local CloseButton = CreateFrame("Button", nil, f);
        f.CloseButton = CloseButton;
        CloseButton:Hide();
        CloseButton:SetSize(32, 32);
        CloseButton:SetPoint("CENTER", f.pieces[3], "TOPRIGHT", -20.5, -20.5);
        CloseButton.Texture = CloseButton:CreateTexture(nil, "OVERLAY");
        CloseButton.Texture:SetPoint("CENTER", CloseButton, "CENTER", 0, 0);
        CloseButton.Texture:SetSize(24, 24);
        CloseButton.Texture:SetTexture(tex)
        CloseButton.Texture:SetTexCoord(646/1024, 694/1024, 48/1024, 96/1024);
        CloseButton.Highlight = CloseButton:CreateTexture(nil, "HIGHLIGHT");
        CloseButton.Highlight:SetPoint("CENTER", CloseButton, "CENTER", 0, 0);
        CloseButton.Highlight:SetSize(24, 24);
        CloseButton.Highlight:SetTexture(tex)
        CloseButton.Highlight:SetTexCoord(646/1024, 694/1024, 48/1024, 96/1024);
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

        Mixin(f, ExpansionThemeFrameMixin);

        return f
    end
end


local ListCategoryButtonMixin = {};
do
    function ListCategoryButtonMixin:SetName(name)
        self.Name:SetText(name);
    end

    function ListCategoryButtonMixin:SetCollapsible(collapsible)
        self.collapsible = collapsible;
        if collapsible then
            self.Left:SetSize(32, 32);
            self.Left:SetTexCoord(828/1024, 892/1024, 176/1024, 240/1024);
            self.Center:SetTexCoord(758/1024, 910/1024, 48/1024, 112/1024);
        else
            self.Left:SetSize(20, 32);
            self.Left:SetTexCoord(694/1024, 734/1024, 48/1024, 112/1024);
            self.Center:SetTexCoord(734/1024, 910/1024, 48/1024, 112/1024);
        end
        self.MinimizeButton:SetShown(collapsible);
    end

    function ListCategoryButtonMixin:SetCollapsed(isCollapsed, userInput)
        self.isCollapsed = isCollapsed;
        self.MinimizeButton.isCollapsed = isCollapsed;
        self.MinimizeButton:OnMouseUp();
        if userInput then
            if self.onCollapsed then
                self.onCollapsed(isCollapsed);
            end
        end
    end

    local MinimizeButtonMixin = {};

    function MinimizeButtonMixin:OnMouseDown()
        if self.isCollapsed then    --"+"
            self.Texture:SetTexCoord(964/1024, 1012/1024, 184/1024, 232/1024);
        else
            self.Texture:SetTexCoord(964/1024, 1012/1024, 264/1024, 312/1024);
        end
    end

    function MinimizeButtonMixin:OnMouseUp()
        if self.isCollapsed then    --"+"
            self.Texture:SetTexCoord(900/1024, 948/1024, 184/1024, 232/1024);
        else
            self.Texture:SetTexCoord(964/1024, 1012/1024, 120/1024, 168/1024);
        end
    end

    function MinimizeButtonMixin:OnClick()
        self:GetParent():SetCollapsed(not self.isCollapsed, true);
    end

    function LandingPageUtil.CreateListCategoryButton(parent, name)
        local f = CreateFrame("Frame", nil, parent);
        Mixin(f, ListCategoryButtonMixin);
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
        f.Left:SetTexCoord(694/1024, 734/1024, 48/1024, 112/1024);
        f.Right:SetSize(20, 32);
        f.Right:SetTexCoord(910/1024, 950/1024, 48/1024, 112/1024);
        f.Center:SetTexCoord(734/1024, 910/1024, 48/1024, 112/1024);

        if name then
            f:SetName(name);
        end

        local MinimizeButton = CreateFrame("Button", nil, f);
        f.MinimizeButton = MinimizeButton;
        MinimizeButton:Hide();
        Mixin(MinimizeButton, MinimizeButtonMixin);
        MinimizeButton:SetSize(24, 24);
        MinimizeButton:SetPoint("CENTER", f.Left, "CENTER", 0, 0);
        MinimizeButton.Texture = MinimizeButton:CreateTexture(nil, "OVERLAY");
        MinimizeButton.Texture:SetSize(24, 24);
        MinimizeButton.Texture:SetPoint("CENTER", MinimizeButton, "CENTER", 0, 0);
        MinimizeButton.Texture:SetTexture(TEXTURE_FILE);
        MinimizeButton.Highlight = MinimizeButton:CreateTexture(nil, "HIGHLIGHT");
        MinimizeButton.Highlight:SetPoint("CENTER", MinimizeButton, "CENTER", 0, 0);
        MinimizeButton.Highlight:SetSize(48, 48);
        MinimizeButton.Highlight:SetTexture(TEXTURE_FILE);
        MinimizeButton.Highlight:SetTexCoord(892/1024, 956/1024, 256/1024, 320/1024);
        MinimizeButton.Highlight:SetBlendMode("ADD");
        MinimizeButton.Highlight:SetVertexColor(0.4, 0.2, 0.1);
        MinimizeButton:OnMouseUp();
        MinimizeButton:SetScript("OnMouseDown", MinimizeButton.OnMouseDown);
        MinimizeButton:SetScript("OnMouseUp", MinimizeButton.OnMouseUp);
        MinimizeButton:SetScript("OnClick", MinimizeButton.OnClick);

        return f
    end
end


local PlayUISound;
do
    local PlaySound = PlaySound;

    local SoundEffects = {
        LandingPageOpen = SOUNDKIT.UI_EXPANSION_LANDING_PAGE_OPEN,
        LandingPageClose = SOUNDKIT.UI_EXPANSION_LANDING_PAGE_CLOSE,

        SwitchTab = SOUNDKIT.IG_CHARACTER_INFO_TAB,

        ScrollBarThumbDown = SOUNDKIT.U_CHAT_SCROLL_BUTTON,
        ScrollBarStep = SOUNDKIT.SCROLLBAR_STEP,

        CheckboxOn = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON,
        CheckboxOff = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF,

        DropdownOpen = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON,
        DropdownClose = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF,

        PageOpen = SOUNDKIT.IG_QUEST_LOG_OPEN,
        PageClose = SOUNDKIT.IG_QUEST_LOG_CLOSE,
    };

    function PlayUISound(key)
        if SoundEffects[key] then
            PlaySound(SoundEffects[key])
        end
    end
    LandingPageUtil.PlayUISound = PlayUISound;
end


do  --TabUtil
    local Tabs = {};
    local SelectedTabIndex = 1;
    local SelectedTabKay;

    local function SortFunc_Tab(a, b)
        if a.uiOrder ~= b.uiOrder then
            return a.uiOrder < b.uiOrder
        end
        return a.key < b.key
    end

    function LandingPageUtil.AddTab(tabInfo)
        table.insert(Tabs, tabInfo);
        table.sort(Tabs, SortFunc_Tab);
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
        local valid;
        if tabKey then
            for _, tabInfo in ipairs(Tabs) do
                if tabInfo.key == tabKey then
                    valid = true;
                    break
                end
            end
        end

        if not valid then
            tabKey = Tabs[1].key;
        end

        SelectedTabKay = tabKey;

        for index, tabInfo in ipairs(Tabs) do
            if tabInfo.frame then
                tabInfo.frame:SetShown(tabInfo.key == tabKey);
            end

            if tabInfo.key == tabKey then
                SelectedTabIndex = index;

                if not tabInfo.useCustomLeftFrame then
                    LandingPageUtil.ShowLeftFrame(true);
                end

                LandingPageUtil.DimBackground(tabInfo.dimBackground);

                if tabInfo.onTabSelected then
                    tabInfo.onTabSelected();
                end
            end
        end

        addon.SetDBValue("LandingPage_DefaultTab", tabKey);
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

    function LandingPageUtil.SelectTabByDelta(delta)
        --Prev -1, Next +1
        local index = SelectedTabIndex + (delta > 0 and 1 or -1);
        local numTabs = #Tabs;
        if index < 0 then
            index = numTabs;
        elseif index > numTabs then
            index = 1;
        else
            LandingPageUtil.SelectTabByIndex(index);
            return true
        end
    end
end


local AtlasUtil = {};
addon.AtlasUtil = AtlasUtil;
do  --Atlas
    local FACTION_ICONS = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/MajorFactionIcons.png";
    local FACTION_ICONS_COORDS = {
        --[factionID] = {icon l, r, t, b, highlight l, r, t, b}
        [2590] = {0  , 128, 0, 128},      --Council of Dornogal
        [2594] = {128, 256, 0, 128},      --The Assembly of the Deeps
        [2570] = {256, 384, 0, 128},      --Hallowfall Arathi
        [2600] = {384, 512, 0, 128},      --Severed Threads
        [2653] = {512, 640, 0, 128},      --Cartels of Undermine
        [2685] = {640, 768, 0, 128},      --Gallagio Loyalty Rewards Club
        [2688] = {768, 896, 0, 128},      --Flame's Radiance
        [2658] = {896, 1024, 0, 128},     --The K'aresh Trust
        [2736] = {0  , 128, 256, 384},    --Manaforge Vandals Debug
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


local MainDropdownMenu;
local MainContextMenu;
do  --Dropdown Menu
    local SharedMenuMixin = {};
    local MenuButtonMixin = {};

    function MenuButtonMixin:OnEnter()
        self.Text:SetTextColor(1, 1, 1);
        self.parent:HighlightButton(self);
    end

    function MenuButtonMixin:OnLeave()
        self:UpdateVisual();
        self.parent:HighlightButton(nil);
    end

    function MenuButtonMixin:UpdateVisual()
        if self.isHeader then
            self.Text:SetTextColor(0.804, 0.667, 0.498);
            return
        end

        if self:IsEnabled() then
            if self.isDangerousAction then
                self.Text:SetTextColor(1.000, 0.125, 0.125);
            else
                self.Text:SetTextColor(0.922, 0.871, 0.761);
            end
        else
            self.Text:SetTextColor(0.5, 0.5, 0.5);
        end
    end

    function MenuButtonMixin:OnClick(button)
        if self.onClickFunc then
            self.onClickFunc(button);
        end

        if self.closeAfterClick then
            self.parent:HideMenu();
        end
    end

    function MenuButtonMixin:SetLeftText(text)
        self.Text:SetText(text);
    end

    function MenuButtonMixin:SetRightTexture(icon)
        self.RightTexture:SetTexture(icon);
        if icon then
            self.rightOffset = 20;
        else
            self.rightOffset = 4;
        end
    end

    function MenuButtonMixin:SetRegular()
        self.leftOffset = 4;
        self.selected = nil;
        self.isHeader = nil;
        self.LeftTexture:Hide();
        self:Layout();
    end

    function MenuButtonMixin:SetHeader(text)
        self.leftOffset = 4;
        self.selected = nil;
        self.isHeader = true;
        self.LeftTexture:Hide();
        self.Text:SetText(text);
        self:Disable();
        self:Layout();
    end

    function MenuButtonMixin:SetRadio(selected)
        self.leftOffset = 20;
        self.selected = selected;
        self.isHeader = nil;
        self.LeftTexture:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/DropdownMenu", nil, nil, "LINEAR");
        if selected then
            self.LeftTexture:SetTexCoord(32/512, 64/512, 0/512, 32/512);
        else
            self.LeftTexture:SetTexCoord(0/512, 32/512, 0/512, 32/512);
        end
        self.LeftTexture:Show();
        self:Layout();
    end

    function MenuButtonMixin:SetCheckbox(selected)
        self.leftOffset = 20;
        self.selected = selected;
        self.isHeader = nil;
        self.LeftTexture:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/DropdownMenu", nil, nil, "LINEAR");
        if selected then
            self.LeftTexture:SetTexCoord(96/512, 128/512, 0/512, 32/512);
        else
            self.LeftTexture:SetTexCoord(64/512, 96/512, 0/512, 32/512);
        end
        self.LeftTexture:Show();
        self:Layout();
    end

    function MenuButtonMixin:Layout()
        self.Text:SetPoint("LEFT", self, "LEFT", self.paddingH + self.leftOffset, 0);
    end

    function MenuButtonMixin:GetContentWidth()
        return self.Text:GetWrappedWidth() + self.leftOffset + self.rightOffset + 2 * self.paddingH;
    end

    local function CreateMenuButton(parent)
        local f = CreateFrame("Button", nil, parent);
        f:SetSize(240, 24);
        Mixin(f, MenuButtonMixin);
        f.leftOffset = 0;
        f.rightOffset = 0;
        f.paddingH = 8;

        f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Text:SetPoint("LEFT", f, "LEFT", f.paddingH, 0);
        f.Text:SetJustifyH("LEFT");
        f.Text:SetTextColor(0.922, 0.871, 0.761);

        f.LeftTexture = f:CreateTexture(nil, "OVERLAY");
        f.LeftTexture:SetSize(16, 16);
        f.LeftTexture:SetPoint("LEFT", f, "LEFT", f.paddingH, 0);
        f.LeftTexture:Hide();

        f.RightTexture = f:CreateTexture(nil, "OVERLAY");
        f.RightTexture:SetSize(18, 18);
        f.RightTexture:SetPoint("RIGHT", f, "RIGHT", -f.paddingH, 0);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);

        return f
    end


    function SharedMenuMixin:SetSize(width, height)
        if width < 40 then
            width = 40;
        end

        if height < 40 then
            height = 40;
        end

        if self.Frame then
            self.Frame:SetSize(width, height);
        end
    end

    function SharedMenuMixin:SetPaddingV(paddingV)
        self.paddingV = paddingV;
    end

    function SharedMenuMixin:SetContentSize(width, height)
        local padding = 2 * self.paddingV;
        self:SetSize(width, height + padding);
    end

    function SharedMenuMixin:Show()
        if self.Frame then
            self.Frame:Show();
        end
    end

    function SharedMenuMixin:ReleaseAllObjects()
        self.buttonPool:ReleaseAll();
        self.texturePool:ReleaseAll();
    end

    function SharedMenuMixin:HideMenu()
        if self.Frame then
            self.Frame:Hide();
            self.Frame:ClearAllPoints();
            if not self.keepContentOnHide then
                self:ReleaseAllObjects();
            end
        end
    end

    function SharedMenuMixin:SetKeepContentOnHide(keepContentOnHide)
        self.keepContentOnHide = keepContentOnHide;
    end

    function SharedMenuMixin:SetNoAutoHide(noAutoHide)
        self.noAutoHide = noAutoHide;
    end

    function SharedMenuMixin:SetNoContentAlert(text)
        self.useNoContentAlert = text ~= nil;
        if self.NoContentAlert then
            self.NoContentAlert:SetText(text);
        else
            self.noContentAlertText = text;
        end
    end

    function SharedMenuMixin:AnchorToObject(object)
        local f = self.Frame;
        if f then
            f:ClearAllPoints();
            f:SetParent(object);
            f:SetPoint("TOPLEFT", object, "BOTTOMLEFT", 0, -6);
        end
    end

    function SharedMenuMixin:AnchorToCursor(owner, offsetX, offsetY)
        local f = self.Frame;
        if f then
            f:ClearAllPoints();
            f:SetParent(UIParent);
            local x, y = API.GetScaledCursorPosition();
            offsetX = offsetX or 0;
            offsetY = offsetY or 0;
            f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x + offsetX, y + offsetY);
        end
    end

    function SharedMenuMixin:ShowMenu(owner, menuInfo)
        if self.Init then
            self:Init();
        end

        self.buttonPool:ReleaseAll();
        self.owner = owner;

        if not owner then return end;

        if menuInfo and menuInfo.widgets then
            self.NoContentAlert:Hide();

            local f = self.Frame;
            if self.openAtCursorPosition or menuInfo.openAtCursorPosition then
                self:AnchorToCursor(owner, 16, 8);
            else
                self:AnchorToObject(owner);
            end

            local buttonHeight = 24;
            local n = 0;
            local widget;
            local offsetX = 0;
            local offsetY = self.paddingV;
            local contentWidth = ((menuInfo.fitToOwner or self.fitToOwner) and owner:GetWidth()) or 0;
            local contentHeight = 0;
            local widgetWidth;
            local widgets = {};
            local numWidgets = #menuInfo.widgets;

            for _, v in ipairs(menuInfo.widgets) do
                n = n + 1;
                if v.type == "Checkbox" or v.type == "Radio" or v.type == "Button" or v.type == "Header" then
                    widget = self.buttonPool:Acquire();
                    widget:SetRightTexture(v.rightTexture);
                    if numWidgets == 1 then
                        widget:SetPoint("CENTER", f, "CENTER", 0, 0);
                    else
                        widget:SetPoint("TOPLEFT", f, "TOPLEFT", offsetX, -offsetY);
                    end
                    offsetY = offsetY + buttonHeight;
                    contentHeight = contentHeight + buttonHeight;
                    widget.onClickFunc = v.onClickFunc;
                    widget.closeAfterClick = v.closeAfterClick;
                    widget.isDangerousAction = v.isDangerousAction;
                    widget:SetLeftText(v.text);
                    if v.type == "Radio" then
                        widget:SetRadio(v.selected);
                    elseif v.type == "Checkbox" then
                        widget:SetCheckbox(v.selected);
                    elseif v.type == "Header" then
                        widget:SetHeader(v.text);
                    else
                        widget:SetRegular();
                    end
                    widget:UpdateVisual();
                elseif v.type == "Divider" then
                    widget = self.texturePool:Acquire();
                    widget:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/DropdownMenu");
                    widget:SetTexCoord(0/512, 128/512, 32/512, 48/512);
                    widget:SetSize(64, 8);
                    local dividerHeight = 8;
                    local gap = 2;
                    offsetY = offsetY + gap;
                    widget:SetPoint("TOPLEFT", f, "TOPLEFT", offsetX, -offsetY);
                    offsetY = offsetY + dividerHeight + gap;
                    contentHeight = contentHeight + dividerHeight + 2 * gap;
                end
                widget.parent = self;
                widgets[n] = widget;
                if widget.GetContentWidth then
                    widgetWidth = widget:GetContentWidth();
                    if widgetWidth > contentWidth then
                        contentWidth = widgetWidth;
                    end
                end
            end

            contentWidth = API.Round(contentWidth);
            contentHeight = API.Round(contentHeight);

            for _, widget in ipairs(widgets) do
                widget:SetWidth(contentWidth);
            end

            self:SetContentSize(contentWidth, contentHeight);

            f:Show();
            self.visible = true;
        else
            if self.useNoContentAlert then
                self.NoContentAlert:Show();
                local contentWidth = owner:GetWidth();
                local contentHeight = 24;
                contentWidth = API.Round(contentWidth);
                contentHeight = API.Round(contentHeight);
                self:SetContentSize(contentWidth, contentHeight);
                self:AnchorToObject(owner);
                self.Frame:Show();
                self.visible = true;
            end
        end
    end

    function SharedMenuMixin:ToggleMenu(owner, menuInfoGetter)
        if self.owner == owner and (self.Frame and self.Frame:IsShown()) then
            self:HideMenu();
        else
            local menuInfo = (owner.menuInfoGetter and owner.menuInfoGetter()) or (menuInfoGetter and menuInfoGetter()) or nil;
            self:ShowMenu(owner, menuInfo);
        end
    end

    function SharedMenuMixin:Init()
        self.Init = nil;

        local Frame = CreateFrame("Frame", nil, self.parent or UIParent);
        self.Frame = Frame;
        Frame:Hide();
        Frame:SetSize(112, 112);
        Frame:SetFrameStrata("FULLSCREEN_DIALOG");
        Frame:SetFixedFrameStrata(true);
        Frame:EnableMouse(true);
        Frame:EnableMouseMotion(true);
        Frame:SetClampedToScreen(true);
        self:SetPaddingV(6);


        local f = addon.CreateNineSliceFrame(Frame, "ExpansionBorder_TWW");
        Frame.Background = f;
        f:SetUsingParentLevel(true);
        f:SetCornerSize(16, 16);
        f:SetDisableSharpening(false);
        f:CoverParent(0);
        f:SetTexture(TEXTURE_FILE);
        f.pieces[1]:SetTexCoord(512/1024, 544/1024, 320/1024, 352/1024);
        f.pieces[2]:SetTexCoord(544/1024, 736/1024, 320/1024, 352/1024);
        f.pieces[3]:SetTexCoord(736/1024, 768/1024, 320/1024, 352/1024);
        f.pieces[4]:SetTexCoord(512/1024, 544/1024, 352/1024, 544/1024);
        f.pieces[5]:SetTexCoord(544/1024, 736/1024, 352/1024, 544/1024);
        f.pieces[6]:SetTexCoord(736/1024, 768/1024, 352/1024, 544/1024);
        f.pieces[7]:SetTexCoord(512/1024, 544/1024, 544/1024, 576/1024);
        f.pieces[8]:SetTexCoord(544/1024, 736/1024, 544/1024, 576/1024);
        f.pieces[9]:SetTexCoord(736/1024, 768/1024, 544/1024, 576/1024);


        local NoContentAlert = Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        self.NoContentAlert = NoContentAlert;
        NoContentAlert:Hide();
        NoContentAlert:SetPoint("LEFT", Frame, "LEFT", 16, 0);
        NoContentAlert:SetPoint("RIGHT", Frame, "RIGHT", -16, 0);
        NoContentAlert:SetTextColor(0.5, 0.5, 0.5);
        NoContentAlert:SetJustifyH("CENTER");
        if self.noContentAlertText then
            NoContentAlert:SetText(self.noContentAlertText);
        end


        local function MenuButton_Create()
            return CreateMenuButton(Frame);
        end

        local function MenuButton_OnAcquire(obj)
            obj:Enable();
        end

        self.buttonPool = CreateObjectPool(MenuButton_Create, nil, MenuButton_OnAcquire);


        local function Texture_Create()
            local tex = Frame:CreateTexture(nil, "OVERLAY");
            return tex
        end
        self.texturePool = CreateObjectPool(Texture_Create);


        self.Highlight = LandingPageUtil.CreateButtonHighlight(Frame);
        self.Highlight.Texture:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/DropdownMenu");
        self.Highlight.Texture:SetTexCoord(368/512, 512/512, 0/512, 48/512);
        self.Highlight.Texture:SetVertexColor(119/255, 96/255, 74/255);
        self.Highlight.Texture:SetBlendMode("ADD");


        if self.noAutoHide then
            Frame:SetScript("OnShow", function()
                PlayUISound("DropdownOpen");
            end);

            Frame:SetScript("OnHide", function()
                PlayUISound("DropdownClose");
            end);
        else
            Frame:SetScript("OnShow", function()
                Frame:RegisterEvent("GLOBAL_MOUSE_DOWN");
                PlayUISound("DropdownOpen");
            end);

            Frame:SetScript("OnHide", function()
                self:HideMenu();
                Frame:UnregisterEvent("GLOBAL_MOUSE_DOWN");
                PlayUISound("DropdownClose");
            end);

            Frame:SetScript("OnEvent", function()
                if not (Frame:IsMouseOver() or (self.owner and self.owner:IsMouseMotionFocus())) then
                    Frame:Hide();
                end
            end);
        end
    end

    function SharedMenuMixin:HighlightButton(button)
        self.Highlight:Hide();
        self.Highlight:ClearAllPoints();
        if button then
            self.Highlight:SetParent(button);
            self.Highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0);
            self.Highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0);
            self.Highlight:Show();
        end
    end


    local function CreateMenuFrame(parent, obj)
        obj = obj or {};
        Mixin(obj, SharedMenuMixin);
        obj.parent = parent;
        return obj
    end
    LandingPageUtil.CreateMenuFrame = CreateMenuFrame;


    MainDropdownMenu = CreateMenuFrame(UIParent, {name = "MainDropdownMenu"});
    MainDropdownMenu.fitToOwner = true;
    LandingPageUtil.DropdownMenu = MainDropdownMenu;


    MainContextMenu = CreateMenuFrame(UIParent, {name = "MainContextMenu"});
    MainContextMenu.openAtCursorPosition = true;
    LandingPageUtil.MainContextMenu = MainContextMenu;
end


do  --Dropdown Button
    local DropdownButtonMixin = {};

    function DropdownButtonMixin:OnEnter()
        self:UpdateVisual();
        local textTruncated = self.Text:IsTruncated();
        if textTruncated or self.tooltip then
            local tooltip = GameTooltip;
            tooltip:SetOwner(self, "ANCHOR_RIGHT");
            tooltip:SetText(self.Text:GetText(), 1, 1, 1, true);
            if self.tooltip then
                tooltip:AddLine(self.tooltip, 1, 0.82, 0, true);
            end
            tooltip:Show();
        end
    end

    function DropdownButtonMixin:OnLeave()
        self:UpdateVisual();
        GameTooltip:Hide();
    end

    function DropdownButtonMixin:OnClick()
        MainDropdownMenu:ToggleMenu(self, self.menuInfo);
    end

    function DropdownButtonMixin:OnMouseDown(button)
        if button == "LeftButton" and self:IsEnabled() then
            self.Arrow:SetTexCoord(828/1024, 892/1024, 256/1024, 320/1024);
            self.Highlight:SetAlpha(0.5);
        end
    end

    function DropdownButtonMixin:OnMouseUp()
        self.Arrow:SetTexCoord(764/1024, 828/1024, 256/1024, 320/1024);
        self.Highlight:SetAlpha(1);
    end

    function DropdownButtonMixin:OnEnable()
        self:UpdateVisual();
        self.Left:SetDesaturated(false);
        self.Center:SetDesaturated(false);
        self.Right:SetDesaturated(false);
        self.Left:SetVertexColor(1, 1, 1);
        self.Center:SetVertexColor(1, 1, 1);
        self.Right:SetVertexColor(1, 1, 1);
    end

    function DropdownButtonMixin:OnDisable()
        self:UpdateVisual();
        self.Text:SetTextColor(0.5, 0.5, 0.5);
        self.Left:SetDesaturated(true);
        self.Center:SetDesaturated(true);
        self.Right:SetDesaturated(true);
        self.Left:SetVertexColor(0.5, 0.5, 0.5);
        self.Center:SetVertexColor(0.5, 0.5, 0.5);
        self.Right:SetVertexColor(0.5, 0.5, 0.5);
    end

    function DropdownButtonMixin:UpdateVisual()
        if self:IsEnabled() then
            if self:IsMouseMotionFocus() then
                self.Text:SetTextColor(1, 1, 1);
            else
                self.Text:SetTextColor(0.922, 0.871, 0.761);
            end
            self.Arrow:SetVertexColor(1, 1, 1);
            self.Arrow:SetDesaturated(false);
        else
            self.Text:SetTextColor(0.5, 0.5, 0.5);
            self.Arrow:SetVertexColor(0.6, 0.6, 0.6);
            self.Arrow:SetDesaturated(true);
        end
    end

    function DropdownButtonMixin:SetText(text)
        self.Text:SetText(text);
    end

    function LandingPageUtil.CreateDropdownButton(parent)
        local f = CreateFrame("Button", nil, parent);
        Mixin(f, DropdownButtonMixin);
        f:SetSize(240, 24);
        f:SetHitRectInsets(-2, -2, -4, -4);

        for i = 1, 2 do
            local setupFunc;
            local prefix;
            if i == 1 then
                setupFunc = SetupThreeSliceBackground;
                prefix = "";
            else
                setupFunc = SetupThressSliceHighlight;
                prefix = "Highlight";
            end
            setupFunc(f, TEXTURE_FILE, -2.5, 2.5);
            f[prefix.."Left"]:SetSize(20, 32);
            f[prefix.."Left"]:SetTexCoord(518/1024, 558/1024, 256/1024, 320/1024);
            f[prefix.."Right"]:SetSize(32, 32);
            f[prefix.."Right"]:SetTexCoord(690/1024, 754/1024, 256/1024, 320/1024);
            f[prefix.."Center"]:SetTexCoord(558/1024, 690/1024, 256/1024, 320/1024);
        end

        f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Text:SetTextColor(1, 1, 1);
        f.Text:SetJustifyH("LEFT");
        f.Text:SetPoint("LEFT", f, "LEFT", 8, 0);
        f.Text:SetPoint("RIGHT", f, "RIGHT", -32, 0);
        f.Text:SetMaxLines(1);

        f.Arrow = f:CreateTexture(nil, "OVERLAY");
        f.Arrow:SetPoint("CENTER", f, "RIGHT", -13.5, 0);
        f.Arrow:SetSize(32, 32);
        f.Arrow:SetTexture(TEXTURE_FILE);
        f.Arrow:SetTexCoord(764/1024, 828/1024, 256/1024, 320/1024);

        f.Highlight = f:CreateTexture(nil, "HIGHLIGHT");
        f.Highlight:SetPoint("CENTER", f, "RIGHT", -13.5, 0);
        f.Highlight:SetSize(48, 48);
        f.Highlight:SetTexture(TEXTURE_FILE);
        f.Highlight:SetTexCoord(892/1024, 956/1024, 256/1024, 320/1024);
        f.Highlight:SetBlendMode("ADD");
        f.Highlight:SetVertexColor(0.4, 0.2, 0.1);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);
        f:SetScript("OnMouseDown", f.OnMouseDown);
        f:SetScript("OnMouseUp", f.OnMouseUp);
        f:SetScript("OnEnable", f.OnEnable);
        f:SetScript("OnDisable", f.OnDisable);

        f:UpdateVisual();

        return f
    end
end


do  --Red Button
    local RedButtonMixin = {};

    function RedButtonMixin:SetButtonText(text)
        self.ButtonText:SetText(text);
    end

    function RedButtonMixin:UpdateVisual()
        local isFocused = self:IsMouseMotionFocus();
        local top;
        if self.buttonState == 1 then
            if isFocused then
                top = 576;
            else
                top = 448;
            end
        elseif self.buttonState == 2 then
            if isFocused then
                top = 704;
            else
                top = 640;
            end
        elseif self.buttonState == 3 then
            top = 512;
        end
        local bottom = top + 64;
        self.Left:SetTexCoord(768/1024, 800/1024, top/1024, bottom/1024);
        self.Right:SetTexCoord(972/1024, 1004/1024, top/1024, bottom/1024);
        self.Center:SetTexCoord(800/1024, 972/1024, top/1024, bottom/1024);

        if self.buttonState == 3 then
            self.ButtonText:SetTextColor(0.5, 0.5, 0.5);
        else
            if isFocused then
                self.ButtonText:SetTextColor(1, 1, 1);
            else
                self.ButtonText:SetTextColor(0.922, 0.871, 0.761);
            end
        end

        if self.buttonState == 2 then
            self.ButtonText:SetPoint("CENTER", 2, -2);
        else
            self.ButtonText:SetPoint("CENTER", 0, 0);
        end
    end

    function RedButtonMixin:OnMouseDown()
        if self:IsEnabled() then
            self.buttonState = 2;
            self:UpdateVisual();
        end
    end

    function RedButtonMixin:OnMouseUp()
        self.buttonState = self:IsEnabled() and 1 or 3;
        self:UpdateVisual();
    end

    function RedButtonMixin:OnEnter()
        self:UpdateVisual();
    end

    function RedButtonMixin:OnLeave()
        self:UpdateVisual();
    end

    function RedButtonMixin:OnEnable()
        self.buttonState = 1;
        self:UpdateVisual();
    end

    function RedButtonMixin:OnDisable()
        self.buttonState = 3;
        self:UpdateVisual();
    end

    function RedButtonMixin:OnClick(button)

    end

    local function CreateRedButton(parent)
        local f = CreateFrame("Button", nil, parent);
        Mixin(f, RedButtonMixin);

        f.buttonState = 1;
        f:SetSize(240, 24);

        f.ButtonText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.ButtonText:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.ButtonText:SetJustifyH("CENTER");
        f.ButtonText:SetTextColor(0.922, 0.871, 0.761);

        SetupThreeSliceBackground(f, TEXTURE_FILE, -2.5, 2.5);
        f.Left:SetSize(16, 32);
        f.Left:SetTexCoord(768/1024, 800/1024, 448/1024, 512/1024);
        f.Right:SetSize(16, 32);
        f.Right:SetTexCoord(972/1024, 1004/1024, 448/1024, 512/1024);
        f.Center:SetTexCoord(800/1024, 972/1024, 448/1024, 512/1024);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnMouseDown", f.OnMouseDown);
        f:SetScript("OnMouseUp", f.OnMouseUp);
        f:SetScript("OnEnable", f.OnEnable);
        f:SetScript("OnDisable", f.OnDisable);
        f:SetScript("OnClick", f.OnClick);

        return f
    end
    LandingPageUtil.CreateRedButton = CreateRedButton;
end


do  --Button Highlight
    local function CreateButtonHighlight(parent)
        local f = CreateFrame("Frame", nil, parent);
        f:Hide();
        f:SetUsingParentLevel(true);
        f:SetSize(232, 40);
        local tex = f:CreateTexture(nil, "BACKGROUND");
        f.Texture = tex;
        tex:SetAllPoints(true);
        tex:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/HorizontalButtonHighlight");
        tex:SetBlendMode("ADD");
        tex:SetVertexColor(51/255, 29/255, 17/255);
        return f
    end
    LandingPageUtil.CreateButtonHighlight = CreateButtonHighlight;
end


do  --Checkbox Button
    local CheckboxButtonMixin = {};

    function CheckboxButtonMixin:OnEnter()
        self:UpdateVisual();
    end

    function CheckboxButtonMixin:OnLeave()
        self:UpdateVisual();
    end

    function CheckboxButtonMixin:UpdateVisual()
        if self:IsEnabled() then
            if self:IsMouseMotionFocus() then
                self.Label:SetTextColor(1, 1, 1);
            else
                if self.useDarkYellowLabel then
                    self.Label:SetTextColor(1, 0.82, 0);
                else
                    self.Label:SetTextColor(0.922, 0.871, 0.761);
                end
            end
        else
            self.Label:SetTextColor(0.5, 0.5, 0.5);
        end
    end

    function CheckboxButtonMixin:OnClick()
        if self.dbKey then
            local checked = not addon.GetDBBool(self.dbKey);
            addon.SetDBValue(self.dbKey, checked, true);
            self:SetChecked(checked, true);
        end

        if self.onClickFunc then
            self.checked = not self.checked;
            self.onClickFunc(self, self.checked);
            self:UpdateChecked(true);
        end
    end

    function CheckboxButtonMixin:SetChecked(state, userInput)
        self.checked = state;
        if state then
            self.Texture:SetTexCoord(828/1024, 892/1024, 320/1024, 384/1024);
            if userInput then
                PlayUISound("CheckboxOn");
            end
        else
            self.Texture:SetTexCoord(764/1024, 828/1024, 320/1024, 384/1024);
            if userInput then
                PlayUISound("CheckboxOff");
            end
        end
    end

    function CheckboxButtonMixin:UpdateChecked(userInput)
        if self.dbKey then
            local checked = addon.GetDBBool(self.dbKey);
            self:SetChecked(checked, userInput);
        elseif self.getCheckedFunc then
            local checked = self.getCheckedFunc(self);
            self:SetChecked(checked, userInput);
        end
    end

    function CheckboxButtonMixin:SetText(text, changeWidth)
        self.Label:SetText(text);
        if changeWidth then
            local width = API.Round(26 + self.Label:GetWrappedWidth());
            self:SetWidth(width);
        end
    end

    function CheckboxButtonMixin:OnEnable()
        self.Texture:SetDesaturated(false);
        self.Texture:SetVertexColor(1, 1, 1);
        self:UpdateVisual();
    end

    function CheckboxButtonMixin:OnDisable()
        self.Texture:SetDesaturated(true);
        self.Texture:SetVertexColor(0.6, 0.6, 0.6);
        self:UpdateVisual();
    end

    function CheckboxButtonMixin:SetFormattedText(text)
        if self.textFormat then
            self:SetText(string.format(self.textFormat, text));
        else
            self:SetText(text);
        end
    end

    function CheckboxButtonMixin:ClearCallbacks()
        self.dbKey = nil;
        self.getCheckedFunc = nil;
    end

    function CheckboxButtonMixin:SetGetCheckedFunc(getCheckedFunc)
        self.getCheckedFunc = getCheckedFunc;
        if getCheckedFunc then
            self:UpdateChecked();
        end
    end

    function CheckboxButtonMixin:SetOnClickFunc(onClickFunc)
        self.onClickFunc = onClickFunc;
    end

    function LandingPageUtil.CreateCheckboxButton(parent)
        local f = CreateFrame("Button", nil, parent);
        f:SetSize(24, 24);
        Mixin(f, CheckboxButtonMixin);

        f.Texture = f:CreateTexture(nil, "OVERLAY");
        f.Texture:SetSize(32, 32);
        f.Texture:SetPoint("CENTER", f, "LEFT", 10, 0);
        f.Texture:SetTexture(TEXTURE_FILE);
        f:SetChecked(false);

        f.Highlight = f:CreateTexture(nil, "HIGHLIGHT");
        f.Highlight:SetSize(32, 32);
        f.Highlight:SetPoint("CENTER", f.Texture, "CENTER", 0, 0);
        f.Highlight:SetTexture(TEXTURE_FILE);
        f.Highlight:SetTexCoord(892/1024, 956/1024, 320/1024, 384/1024);
        f.Highlight:SetBlendMode("ADD");
        f.Highlight:SetAlpha(0.5);

        f.Label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Label:SetJustifyH("LEFT");
        f.Label:SetPoint("LEFT", f, "LEFT", 26, 0);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);
        f:SetScript("OnEnable", f.OnEnable);
        f:SetScript("OnDisable", f.OnDisable);

        return f
    end
end


do  --IconTextButton
    local BasicIconTextButtonMixin = {};

    function BasicIconTextButtonMixin:OnMouseDown()
        if self:IsEnabled() then
            self.Content:SetPoint("LEFT", self, "LEFT", 0, -1);
        end
    end

    function BasicIconTextButtonMixin:OnMouseUp()
        self.Content:SetPoint("LEFT", self, "LEFT", 0, 0);
    end

    function BasicIconTextButtonMixin:OnEnter()
        self:UpdateVisual();
    end

    function BasicIconTextButtonMixin:OnLeave()
        self:UpdateVisual();
    end

    function BasicIconTextButtonMixin:OnEnable()
        self:UpdateVisual();
    end

    function BasicIconTextButtonMixin:OnDisable()
        self:UpdateVisual();
    end

    function BasicIconTextButtonMixin:UpdateVisual()
        if self:IsEnabled() then
            if self:IsMouseMotionFocus() then
                self.Label:SetTextColor(1, 1, 1);
            else
                if self.useDarkYellowLabel then
                    self.Label:SetTextColor(1, 0.82, 0);
                else
                    self.Label:SetTextColor(0.922, 0.871, 0.761);
                end
            end
        else
            self.Label:SetTextColor(0.5, 0.5, 0.5);
        end
    end

    function BasicIconTextButtonMixin:SetTexture(texture, left, right, top, bottom)
        self.Icon:SetTexture(texture);
        self.Icon:SetTexCoord(left or 0, right or 1, top or 0, bottom or 1);
        self.Highlight:SetTexture(texture);
        self.Highlight:SetTexCoord(left or 0, right or 1, top or 0, bottom or 1);
    end

    function BasicIconTextButtonMixin:SetText(text, changeWidth)
        self.Label:SetText(text);
        if changeWidth then
            local textWidth = math.max(24, API.Round(self.Label:GetWrappedWidth()));
            self:SetWidth(textWidth + 24);
        end
    end

    function LandingPageUtil.CreateBasicIconTextButton(parent)
        local f = CreateFrame("Button", nil, parent);
        f:SetSize(48, 24);
        Mixin(f, BasicIconTextButtonMixin);

        f.Content = CreateFrame("Frame", nil, f);
        f.Content:SetSize(24, 24);
        f.Content:SetPoint("LEFT", f, "LEFT", 0, 0);
        f.Content:SetUsingParentLevel(true);

        f.Icon = f:CreateTexture(nil, "OVERLAY");
        f.Icon:SetSize(32, 32);
        f.Icon:SetPoint("CENTER", f.Content, "LEFT", 8, 0);

        f.Label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Label:SetJustifyH("LEFT");
        f.Label:SetPoint("LEFT", f.Content, "LEFT", 24, 0);

        f.Highlight = f:CreateTexture(nil, "HIGHLIGHT");
        f.Highlight:SetPoint("TOPLEFT", f.Icon, "TOPLEFT", 0, 0);
        f.Highlight:SetPoint("BOTTOMRIGHT", f.Icon, "BOTTOMRIGHT", 0, 0);
        f.Highlight:SetBlendMode("ADD");

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnMouseDown", f.OnMouseDown);
        f:SetScript("OnMouseUp", f.OnMouseUp);

        return f
    end
end


do  --MajorDivider
    function LandingPageUtil.CreateMajorDivider(parent)
        local f = CreateFrame("Frame", nil, parent);
        f:SetSize(128, 4);
        f.Left = f:CreateTexture(nil, "OVERLAY");
        f.Left:SetSize(64, 24);
        f.Left:SetPoint("LEFT", f, "LEFT", 0, 0);
        f.Right = f:CreateTexture(nil, "OVERLAY");
        f.Right:SetSize(64, 24);
        f.Right:SetPoint("LEFT", f.Left, "RIGHT", 0, 0);
        f.Right:SetPoint("RIGHT", f, "RIGHT", 0, 0);

        local tex = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/ExpansionBorder_TWW";

        f.Left:SetTexture(tex);
        f.Left:SetTexCoord(0.5, 634/1024, 0, 48/1024);
        f.Right:SetTexture(tex);
        f.Right:SetTexCoord(634/1024, 1, 0, 48/1024);

        return f
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