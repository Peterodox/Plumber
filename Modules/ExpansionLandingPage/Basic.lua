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

        f.Left = f:CreateTexture(nil, "BACKGROUND");
        f.Left:SetPoint("LEFT", f, "LEFT", -3, 0);
        f.Left:SetSize(20, 32);
        f.Left:SetTexCoord(694/1024, 734/1024, 48/512, 112/512);
        f.Right = f:CreateTexture(nil, "BACKGROUND");
        f.Right:SetPoint("RIGHT", f, "RIGHT", 3, 0);
        f.Right:SetSize(20, 32);
        f.Right:SetTexCoord(910/1024, 950/1024, 48/512, 112/512);
        f.Center = f:CreateTexture(nil, "BACKGROUND");
        f.Center:SetPoint("TOPLEFT", f.Left, "TOPRIGHT", 0, 0);
        f.Center:SetPoint("BOTTOMRIGHT", f.Right, "BOTTOMLEFT", 0, 0);
        f.Center:SetTexCoord(734/1024, 910/1024, 48/512, 112/512);

        local tex = TEXTURE_FILE;
        f.Left:SetTexture(tex);
        f.Right:SetTexture(tex);
        f.Center:SetTexture(tex);

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


do  --ScrollFrame
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

    local function CraeteObjectPool(create, onAcquired, onRemoved)
        local pool = {};
        API.Mixin(pool, ObjectPoolMixin);

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


    local ScrollViewMixin = {};

    function ScrollViewMixin:SetOffset(offset)
        self.offset = offset;
        self.toOffset = offset;
        self.ScrollRef:SetPoint("TOP", self, "TOP", 0, offset);
        self:UpdateView();
    end

    function ScrollViewMixin:ScrollToTop()
        self:SetOffset(0);
    end

    function ScrollViewMixin:ScrollToBottom()
        self:SetOffset(self.range);
    end

    function ScrollViewMixin:AddTemplate(templateKey, create, onAcquired, onRemoved)
        self.pools[templateKey] = CraeteObjectPool(create, onAcquired, onRemoved);
    end

    function ScrollViewMixin:ReleaseAllObjects()
        self.indexedObjects = {};
        for templateKey, pool in pairs(self.pools) do
            pool:ReleaseAll();
        end
    end

    function ScrollViewMixin:GetDebugCount()
        local total = 0;
        local active = 0;
        local unused = 0;
        for templateKey, pool in pairs(self.pools) do
            total = total + #pool.objects;
            active = active + #pool.activeObjects;
            unused = unused + #pool.unusedObjects;
        end
        print(total, active, unused);
    end

    function ScrollViewMixin:OnSizeChanged()
        self.viewportSize = API.Round(self:GetHeight());
    end

    function ScrollViewMixin:AcquireObject(templateKey)
        return self.pools[templateKey]:Acquire();
    end

    function ScrollViewMixin:UpdateView()
        local top = self.offset;
        local bottom = self.offset + self.viewportSize;
        local fromDataIndex;
        local toDataIndex;

        for dataIndex, v in ipairs(self.content) do
            if not fromDataIndex then
                if v.top >= top or v.bottom >= top then
                    fromDataIndex = dataIndex;
                end
            end

            if not toDataIndex then
                if (v.top <= bottom and v.bottom >= bottom) or (v.top >= bottom) then
                    toDataIndex = dataIndex;
                    break
                end
            end
        end
        toDataIndex = toDataIndex or #self.content;

        for dataIndex, obj in pairs(self.indexedObjects) do
            if dataIndex < fromDataIndex or dataIndex > toDataIndex then
                obj:Release();
                self.indexedObjects[dataIndex] = nil;
            end
        end

        local obj;
        local contentData;

        if fromDataIndex then
            for dataIndex = fromDataIndex, toDataIndex do
                if self.indexedObjects[dataIndex] then

                else
                    contentData = self.content[dataIndex];
                    obj = self:AcquireObject(contentData.templateKey);
                    if obj then
                        if contentData.setupFunc then
                            contentData.setupFunc(obj);
                        end
                        obj:SetPoint(contentData.point or "TOP", self.ScrollRef, "TOP", contentData.offsetX or 0, -contentData.top);
                        self.indexedObjects[dataIndex] = obj;
                    end
                end
            end
        end
    end

    function ScrollViewMixin:OnMouseWheel(delta)
        if (delta > 0 and self.toOffset <= 0) or (delta < 0 and self.toOffset >= self.range) then
            return
        end

        local a = IsShiftKeyDown() and 2 or 1;
        self.toOffset = self.toOffset - self.stepSize * a * delta;

        if self.toOffset < 0 then
            self.toOffset = 0;
        elseif self.toOffset > self.range then
            self.toOffset = self.range;
        end

        self:SetOffset(self.toOffset);
    end

    function ScrollViewMixin:SetStepSize(stepSize)
        self.stepSize = stepSize;
    end

    function ScrollViewMixin:SetScrollRange(range)
        if range < 0 then
            range = 0;
        end
        self.range = range;

        if range > 0 then
            self:SetClipsChildren(true);
            self:SetScript("OnMouseWheel", self.OnMouseWheel);
        else
            self:SetClipsChildren(false);
            self:SetScript("OnMouseWheel", nil);
        end
    end

    function ScrollViewMixin:SetContent(content, retainPosition)
        self.content = content or {};
    
        if #self.content > 0 then
            local range = content[#self.content].bottom - self.viewportSize + self.bottomOvershoot;
            self:SetScrollRange(range);
        else
            self:SetScrollRange(0);
        end
        self:ReleaseAllObjects();

        if retainPosition then
            local offset = self.toOffset;
            if offset > self.range then
                offset = self.range;
            end
            self:SetOffset(offset);
        else
            self:ScrollToTop();
        end
    end

    function ScrollViewMixin:SetBottomOvershoot(bottomOvershoot)
        self.bottomOvershoot = bottomOvershoot;
    end

    local function CreateScrollView(parent)
        local f = CreateFrame("Frame", nil, parent);
        API.Mixin(f, ScrollViewMixin);
        f:SetClipsChildren(true);

        f.ScrollRef = CreateFrame("Frame", nil, f);
        f.ScrollRef:SetSize(4, 4);
        f.ScrollRef:SetPoint("TOP", f, "TOP", 0, 0);

        f.pools = {};
        f.content = {};
        f.indexedObjects = {};
        f.offset = 0;
        f.toOffset = 0;
        f.range = 0;
        f.viewportSize = 0;
        f:SetStepSize(32);
        f:SetBottomOvershoot(0);

        f:SetScript("OnMouseWheel", f.OnMouseWheel);

        return f
    end
    API.CreateScrollView = CreateScrollView;
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