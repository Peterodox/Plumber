local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;
local CreateObjectPool = LandingPageUtil.CreateObjectPool;


local Clamp = API.Clamp;
local DeltaLerp = API.DeltaLerp;
local CreateFrame = CreateFrame;
local ipairs = ipairs;
local IsShiftKeyDown = IsShiftKeyDown;


local CreateScrollBar;
do
    local GetCursorPosition = GetCursorPosition;
    local ScrollBarMixin = {};
    local ArrowButtonMixin = {};
    do
        function ArrowButtonMixin:OnLoad()
            self:SetScript("OnEnter", self.OnEnter);
            self:SetScript("OnLeave", self.OnLeave);
            self:SetScript("OnMouseDown", self.OnMouseDown);
            self:SetScript("OnMouseUp", self.OnMouseUp);
            self:SetScript("OnEnable", self.OnEnable);
            self:SetScript("OnDisable", self.OnDisable);
        end

        function ArrowButtonMixin:OnEnter()

        end

        function ArrowButtonMixin:OnLeave()

        end

        function ArrowButtonMixin:OnMouseDown(button)
            if not self:IsEnabled() then return end;
            if button == "LeftButton" then
                self:SharedOnMouseDown(button);
                self:GetParent():GetScrollView():OnMouseWheel(self.delta);
                self:GetParent():StartPushingArrow(self.delta);
                LandingPageUtil.PlayUISound("ScrollBarStep");
            end
        end

        function ArrowButtonMixin:OnMouseUp(button)
            self:SharedOnMouseUp(button);
            self:GetParent():StopUpdating();
            self:GetParent():GetScrollView():StopSteadyScroll();
        end

        function ArrowButtonMixin:OnEnable()
            self.Texture:SetVertexColor(1, 1, 1);
            self.Texture:SetDesaturated(false);
        end

        function ArrowButtonMixin:OnDisable()
            self.Texture:SetVertexColor(0.5, 0.5, 0.5);
            self.Texture:SetDesaturated(true);
        end
    end


    function ScrollBarMixin:SetValueByRatio(ratio)
        if ratio < 0.001 then
            ratio = 0;
            self.isTop = true;
            self.isBottom = false;
        elseif ratio > 0.999 then
            ratio = 1;
            self.isTop = false;
            self.isBottom = true;
        else
            self.isTop = false;
            self.isBottom = false;
        end

        if self.isTop then
            self.UpArrow:Disable();
        else
            self.UpArrow:Enable();
        end
        if self.isBottom then
            self.DownArrow:Disable();
        else
            self.DownArrow:Enable();
        end

        self.ratio = ratio;
        self.Thumb:SetPoint("TOP", self.Rail, "TOP", 0, -ratio * self.thumbRange);
    end

    function ScrollBarMixin:UpdateThumbRange()
        local railLength = self.Rail:GetHeight();
        local range = API.Round(railLength - self.Thumb:GetHeight());
        self.thumbRange = range;
        self.ratioPerUnit = 1 / range;
    end

    function ScrollBarMixin:SetScrollable(scrollable)
        if scrollable then
            self.Thumb:Show();
            self.UpArrow:Show();
            self.DownArrow:Show();
            self.isTop = self:GetScrollView():IsAtTop();
            self.isBottom = self:GetScrollView():IsAtBottom();
            self:SetAlpha(1);
        else
            self.Thumb:Hide();
            self.UpArrow:Hide();
            self.DownArrow:Hide();
            self.isTop = true;
            self.isBottom = true;
            self:SetAlpha(0.5);
        end
        self.scrollable = scrollable;
        self.UpArrow:SetEnabled(not self.isTop);
        self.DownArrow:SetEnabled(not self.isBottom);
        self:UpdateThumbRange();
    end

    function ScrollBarMixin:StartDraggingThumb()
        self:Snapshot();
        self:UpdateThumbRange();
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate_ThumbDragged);
    end

    function ScrollBarMixin:OnUpdate_ThumbDragged(elapsed)
        self.x, self.y = GetCursorPosition();
        self.x = self.x / self.scale;
        self.y = self.y / self.scale;
        self.dx = self.x - self.x0;
        self.dy = self.y - self.y0;
        self:SetValueByRatio(self.fromRatio - self.dy * self.ratioPerUnit);
        self.ScrollView:SnapToRatio(self.ratio);
    end

    function ScrollBarMixin:Snapshot()
        self.x0, self.y0 = GetCursorPosition();
        self.scale = self:GetEffectiveScale();
        self.x0 = self.x0 / self.scale;
        self.y0 = self.y0 / self.scale;
        self.fromRatio = self.ratio;
    end

    function ScrollBarMixin:StartPushingArrow(delta)
        self:Snapshot();
        self:UpdateThumbRange();
        self.t = 0;
        self.delta = delta or -1;
        self:SetScript("OnUpdate", self.OnUpdate_ArrowPushed);
    end

    function ScrollBarMixin:OnUpdate_ArrowPushed(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.5 then
            self.t = 0;
            self:GetScrollView():SteadyScroll(-self.delta);
        end
    end

    function ScrollBarMixin:StopUpdating()
        self:SetScript("OnUpdate", nil);
        self.t = nil;
        self.x, self.y = nil, nil;
        self.x0, self.y0 = nil, nil;
        self.dx, self.dy = nil, nil;
        self.scale = nil;
    end

    function ScrollBarMixin:ScrollToMouseDownPosition()
        local x, y = GetCursorPosition();
        local scale = self:GetEffectiveScale();
        x, y = x/scale, y/scale;

        local top = self.Rail:GetTop();
        local bottom = self.Rail:GetBottom();

        local ratio;
        if (top - y) < 4 then
            ratio = 0;
        elseif (y - bottom) < 4 then
            ratio = 1;
        else
            ratio = (y - top)/(bottom - top);
        end

        self:GetScrollView():ScrollToRatio(ratio);
    end

    function ScrollBarMixin:GetScrollView()
        return self.ScrollView
    end



    local function TextureButton_SharedOnMouseDown(self, button)
        if self:IsEnabled() and button == "LeftButton" then
            self.Highlight:SetAlpha(0.5);
        end
    end

    local function TextureButton_SharedOnMouseUp(self, button)
        self.Highlight:SetAlpha(0.2);
    end

    local function TextureButton_SetupTexture(self, file, l, r, t, b)
        self.Texture:SetTexture(file);
        self.Highlight:SetTexture(file);
        self.Texture:SetTexCoord(l, r, t, b);
        self.Highlight:SetTexCoord(l, r, t, b);
    end

    local function CreateTextureButton(parent)
        local b = CreateFrame("Button", nil, parent);
        b.Texture = b:CreateTexture(nil, "ARTWORK");
        b.Texture:SetPoint("CENTER", b, "CENTER", 0, 0);
        b.Highlight = b:CreateTexture(nil, "HIGHLIGHT");
        b.Highlight:SetPoint("TOPLEFT", b.Texture, "TOPLEFT", 0, 0);
        b.Highlight:SetPoint("BOTTOMRIGHT", b.Texture, "BOTTOMRIGHT", 0, 0);
        b.Highlight:SetBlendMode("ADD");
        TextureButton_SharedOnMouseUp(b);
        b.SetupTexture = TextureButton_SetupTexture;
        b.SharedOnMouseDown = TextureButton_SharedOnMouseDown;
        b.SharedOnMouseUp = TextureButton_SharedOnMouseUp;
        return b
    end

    function CreateScrollBar(parent)
        local textureFile = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/ExpansionBorder_TWW";

        local f = CreateFrame("Frame", nil, parent);
        f:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, -16);
        f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -4, 16);
        f:SetSize(16, 256);
        f.ScrollView = parent;

        local function CreateArrowButton(delta)
            local b = CreateTextureButton(f);
            b:SetSize(16, 20);
            b.Texture:SetSize(16, 20);
            API.Mixin(b, ArrowButtonMixin);
            b:OnLoad();
            b.delta = delta;

            if delta > 0 then
                b:SetupTexture(textureFile, 64/1024, 96/1024, 616/1024, 656/1024);
            else
                b:SetupTexture(textureFile, 64/1024, 96/1024, 656/1024, 616/1024);
            end

            return b
        end

        f.UpArrow = CreateArrowButton(1);
        f.UpArrow:SetPoint("TOP", f, "TOP", 0, -5);

        f.DownArrow = CreateArrowButton(-1);
        f.DownArrow:SetPoint("BOTTOM", f, "BOTTOM", 0, 5);

        local Rail = CreateFrame("Frame", nil, f);
        f.Rail = Rail;
        Rail:SetPoint("TOP", f, "TOP", 0, -22);
        Rail:SetPoint("BOTTOM", f, "BOTTOM", 0, 22);
        Rail:SetSize(16, 208);
        Rail:SetUsingParentLevel(true);

        Rail.Top = f:CreateTexture(nil, "ARTWORK");
        Rail.Top:SetPoint("TOP", f, "TOP", 0, 6);
        Rail.Top:SetSize(32, 64);
        Rail.Top:SetTexture(textureFile);
        Rail.Top:SetTexCoord(0/1024, 64/1024, 512/1024, 640/1024);

        Rail.Bottom = f:CreateTexture(nil, "ARTWORK");
        Rail.Bottom:SetPoint("BOTTOM", f, "BOTTOM", 0, -6);
        Rail.Bottom:SetSize(32, 64);
        Rail.Bottom:SetTexture(textureFile);
        Rail.Bottom:SetTexCoord(0/1024, 64/1024, 896/1024, 1024/1024);

        Rail.Middle = f:CreateTexture(nil, "ARTWORK");
        Rail.Middle:SetPoint("TOPLEFT", Rail.Top, "BOTTOMLEFT", 0, 0);
        Rail.Middle:SetPoint("BOTTOMRIGHT", Rail.Bottom, "TOPRIGHT", 0, 0);
        Rail.Middle:SetTexture(textureFile);
        Rail.Middle:SetTexCoord(0/1024, 64/1024, 640/1024, 896/1024);

        Rail:SetScript("OnMouseDown", function(_, button)
            if button == "LeftButton" then
                f:ScrollToMouseDownPosition();
                LandingPageUtil.PlayUISound("ScrollBarThumbDown");
            end
        end);

        local Thumb = CreateTextureButton(f);
        f.Thumb = Thumb;
        Thumb:SetSize(16, 64);
        Thumb:SetPoint("TOP", Rail, "TOP", 0, 0);
        Thumb:SetupTexture(textureFile, 64/1024, 96/1024, 512/1024, 616/1024);
        Thumb.Texture:SetSize(16, 52);

        API.Mixin(f, ScrollBarMixin);

        f:UpdateThumbRange();
        f:SetValueByRatio(0);

        Thumb:SetScript("OnMouseDown", function(_, button)
            if button == "LeftButton" then
                f:StartDraggingThumb();
                Thumb:LockHighlight();
                Thumb:SharedOnMouseDown(button);
                LandingPageUtil.PlayUISound("ScrollBarThumbDown");
            end
        end);

        Thumb:SetScript("OnMouseUp", function(_, button)
            f:StopUpdating();
            Thumb:UnlockHighlight();
            Thumb:SharedOnMouseUp(button);
        end);

        return f
    end
end


local ScrollViewMixin = {};

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
    f.scrollTarget = 0;
    f.range = 0;
    f.viewportSize = 0;
    f.blendSpeed = 0.15;

    f:SetStepSize(32);
    f:SetBottomOvershoot(0);

    f:SetScript("OnMouseWheel", f.OnMouseWheel);
    f:SetScript("OnHide", f.OnHide);

    f.ScrollBar = CreateScrollBar(f);
    f.ScrollBar:SetFrameLevel(f:GetFrameLevel() + 10);
    f.ScrollBar:UpdateThumbRange();

    return f
end
API.CreateScrollView = CreateScrollView;


do  --ScrollView Basic Content Render
    function ScrollViewMixin:GetScrollTarget()
        return self.scrollTarget
    end

    function ScrollViewMixin:GetOffset()
        return self.offset
    end

    function ScrollViewMixin:SetOffset(offset)
        self.offset = offset;
        self.ScrollRef:SetPoint("TOP", self, "TOP", 0, offset);

        if self.scrollable then
            self.ScrollBar:SetValueByRatio(offset/self.range);
        else
            self.ScrollBar:SetValueByRatio(0);
        end
    end

    function ScrollViewMixin:UpdateView(useScrollTarget)
        local top = (useScrollTarget and self.scrollTarget) or self.offset;
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
                    local nextIndex = dataIndex + 1;
                    v = self.content[nextIndex];
                    if v then
                        if v.top <= bottom then
                            toDataIndex = nextIndex;
                        end
                    end
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

    function ScrollViewMixin:OnSizeChanged(forceUpdate)
        --We call this manually
        self.viewportSize = API.Round(self:GetHeight());
        if forceUpdate then
            self.ScrollBar:UpdateThumbRange();
            self:SetContent(self.content);
            --self:SnapTo(self.offset or 0);
        end
    end

    function ScrollViewMixin:OnMouseWheel(delta)
        if (delta > 0 and self.scrollTarget <= 0) or (delta < 0 and self.scrollTarget >= self.range) then
            return
        end

        local a = IsShiftKeyDown() and 2 or 1;
        self:ScrollBy(-self.stepSize * a * delta);
    end

    function ScrollViewMixin:SetStepSize(stepSize)
        self.stepSize = stepSize;
    end

    function ScrollViewMixin:SetScrollRange(range)
        if range < 0 then
            range = 0;
        end

        self.range = range;

        local scrollable = range > 0;

        if (not scrollable) and self.smartClipsChildren then
            self:SetClipsChildren(false);
            self:SetScript("OnMouseWheel", nil);
        else
            self:SetClipsChildren(true);
            self:SetScript("OnMouseWheel", self.OnMouseWheel);
        end

        if (not scrollable) and self.scrollable then
            self:ScrollToTop();
        end

        self.scrollable = scrollable;
        self.ScrollBar:SetScrollable(self.scrollable);
        self.ScrollBar:SetShown(scrollable or self.alwaysShowScrollBar);

        if self.useBoundaryGradient then
            if scrollable then
                self.BottomGradient:Show();
            else
                self.BottomGradient:Hide();
            end
        end
    end

    function ScrollViewMixin:IsScrollable()
        return self.scrollable
    end

    function ScrollViewMixin:SetContent(content, retainPosition)
        self.content = content or {};

        if #self.content > 0 then
            local range = content[#self.content].bottom - self.viewportSize;
            if range > 0 then
                range = range + self.bottomOvershoot;
            end
            self:SetScrollRange(range);
        else
            self:SetScrollRange(0);
        end
        self:ReleaseAllObjects();

        if retainPosition then
            local offset = self.scrollTarget;
            if (not self.allowOvershoot) and offset > self.range then
                offset = self.range;
            end
            self.scrollTarget = offset;
        else
            self.scrollTarget = 0;
        end
        self:SnapToScrollTarget();
    end
end

do  --ScrollView ObjectPool
    function ScrollViewMixin:AddTemplate(templateKey, create, onAcquired, onRemoved)
        self.pools[templateKey] = CreateObjectPool(create, onAcquired, onRemoved);
    end

    function ScrollViewMixin:AcquireObject(templateKey)
        return self.pools[templateKey]:Acquire();
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
end

do  --ScrollView Smooth Scroll
    function ScrollViewMixin:StopScrolling()
        if self.MouseBlocker then
            self.MouseBlocker:Hide();
        end

        if self.isScrolling or self.isSteadyScrolling then
            self.recycleTimer = 0;
            self.isScrolling = nil;
            self.isSteadyScrolling = nil;
            self:SetScript("OnUpdate", nil);
            self:UpdateView(true);
            self:OnScrollStop();
        end
    end

    function ScrollViewMixin:SnapToScrollTarget()
        self.recycleTimer = 0;
        self:SetOffset(self.scrollTarget);
        self.isScrolling = true;
        self:StopScrolling();
    end

    function ScrollViewMixin:OnUpdate_Easing(elapsed)
        self.isScrolling = true;
        self.offset = DeltaLerp(self.offset, self.scrollTarget, self.blendSpeed, elapsed);

        if (self.offset - self.scrollTarget) > -0.4 and (self.offset - self.scrollTarget) < 0.4 then
            self.offset = self.scrollTarget;
            self:SnapToScrollTarget();
            return
        end

        self.recycleTimer = self.recycleTimer + elapsed;
        if self.recycleTimer > 0.033 then
            self.recycleTimer = 0;
            self:UpdateView();
        end

        self:SetOffset(self.offset);
    end

    function ScrollViewMixin:OnUpdate_SteadyScroll(elapsed)
        self.isScrolling = true;
        self.offset = self.offset + self.scrollSpeed * elapsed;

        if self.offset < 0 then
            self.offset = 0;
            self.isSteadyScrolling = nil;
        elseif self.offset > self.range then
            self.offset = self.range;
            self.isSteadyScrolling = nil;
        elseif self.scrollSpeed < 4 and self.scrollSpeed > -4 then
            self.isSteadyScrolling = nil;
        else
            self.isSteadyScrolling = true;
        end

        self.scrollTarget = self.offset;

        if not self.isSteadyScrolling then
            self:StopScrolling();
        end

        self.recycleTimer = self.recycleTimer + elapsed;
        if self.recycleTimer > 0.033 then
            self.recycleTimer = 0;
            self:UpdateView();
        end

        self:SetOffset(self.offset);
    end

    function ScrollViewMixin:SteadyScroll(strengh)
        --For Joystick: strengh -1 ~ +1

        if strengh > 0.8 then
            self.scrollSpeed = 80 + 600 * (strengh - 0.8);
        elseif strengh < -0.8 then
            self.scrollSpeed = -80 + 600 * (strengh + 0.8);
        else
            self.scrollSpeed = 100 * strengh
        end

        if not self.isSteadyScrolling then
            self.recycleTimer = 0;
            self:SetScript("OnUpdate", self.OnUpdate_SteadyScroll);
            self:OnScrollStart();
        end
    end

    function ScrollViewMixin:StopSteadyScroll()
        if self.isSteadyScrolling then
            self:StopScrolling();
        end
    end


    function ScrollViewMixin:SnapTo(value)
        --No Easing
        value = Clamp(value, 0, self.range);
        self:SetOffset(value);
        self.scrollTarget = value;
        self.isScrolling = true;
        self:StopScrolling();
    end

    function ScrollViewMixin:ScrollTo(value)
        --Easing
        value = Clamp(value, 0, self.range);
        self.isSteadyScrolling = nil;
        if value ~= self.scrollTarget then
            self.scrollTarget = value;
            self.recycleTimer = 0;
            self:SetScript("OnUpdate", self.OnUpdate_Easing);
            self:OnScrollStart();
        end
    end

    function ScrollViewMixin:ScrollBy(deltaValue)
        self:ScrollTo(self:GetScrollTarget() + deltaValue);
    end
end

do  --ScrollView Scroll Behavior
    function ScrollViewMixin:ScrollToTop()
        self:ScrollTo(0);
    end

    function ScrollViewMixin:ScrollToBottom()
        self:ScrollTo(self.range);
    end

    function ScrollViewMixin:ScrollToRatio(ratio)
        ratio = Clamp(ratio, 0, 1);
        self:ScrollTo(self.range * ratio);
    end

    function ScrollViewMixin:ResetScroll()
        self:SnapTo(0);
    end

    function ScrollViewMixin:SnapToBottom()
        self:SnapTo(self.range);
    end

    function ScrollViewMixin:SnapToRatio(ratio)
        ratio = Clamp(ratio, 0, 1);
        self:SnapTo(self.range * ratio);
    end

    function ScrollViewMixin:ScrollToContent(contentIndex)
        if contentIndex < 1 then contentIndex = 1 end;

        if self.content[contentIndex] then
            self:ScrollTo(self.content[contentIndex].top);
        end
    end

    function ScrollViewMixin:SnapToContent(contentIndex)
        if contentIndex < 1 then contentIndex = 1 end;

        if contentIndex == 1 then
            self:ResetScroll();
            return
        end

        if self.content[contentIndex] then
            self:SnapTo(self.content[contentIndex].top);
        end
    end

    function ScrollViewMixin:SetBottomOvershoot(bottomOvershoot)
        self.bottomOvershoot = bottomOvershoot;
    end

    function ScrollViewMixin:EnableMouseBlocker(state)
        self.useMouseBlocker = state;
        if state then
            if not self.MouseBlocker then
                local f = CreateFrame("Frame", nil, self);
                self.MouseBlocker = f;
                f:Hide();
                f:SetAllPoints(true);
                f:EnableMouse(true);
                f:EnableMouseMotion(true);
            end
        else
            if self.MouseBlocker then
                self.MouseBlocker:Hide();
            end
        end
    end

    function ScrollViewMixin:SetSmartClipsChildren(state)
        --If true, SetClipsChildren(false)
        --This affects texture rendering
        self.smartClipsChildren = state;
    end

    function ScrollViewMixin:SetAllowOvershootAfterRangeChange(state)
        --If the entries are collapsible, the header button's position may change with scroll range
        --If true, the button will retain its position until scroll
        self.allowOvershoot = state;
    end

    function ScrollViewMixin:SetAlwaysShowScrollBar(state)
        --If false, hide the scroll bar when it's not scrollable
        self.alwaysShowScrollBar = state;
    end

    function ScrollViewMixin:IsAtTop()
        if self.scrollable then
            return self.offset < 0.1
        else
            return true
        end
    end

    function ScrollViewMixin:IsAtBottom()
        if self.scrollable then
            return self.offset > self.range - 0.1;
        else
            return true
        end
    end

    function ScrollViewMixin:ResetScrollBarPosition()
        self.ScrollBar:ClearAllPoints();
        self.ScrollBar:SetPoint("TOPRIGHT", self, "TOPRIGHT", -1, -1);
        self.ScrollBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1);
    end

    function ScrollViewMixin:SetScrollBarOffsetY(top, bottom)
        top = top or -16;
        bottom = bottom or 16;
        self.ScrollBar:ClearAllPoints();
        self.ScrollBar:SetPoint("TOPRIGHT", self, "TOPRIGHT", -4, top);
        self.ScrollBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, bottom);
    end

    function ScrollViewMixin:UseBoundaryGradient(state)
        self.useBoundaryGradient = state;

        if state and not self.BottomGradient then
            local BottomGradient = CreateFrame("Frame", nil, self:GetParent());
            self.BottomGradient = BottomGradient;
            BottomGradient:SetSize(224, self.boundaryGradientSize or 40);
            BottomGradient:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 6, -1);
            BottomGradient:SetPoint("BOTTOMRIGHT", self.ScrollBar, "BOTTOMLEFT", -1, -1);
            local tex = BottomGradient:CreateTexture(nil, "OVERLAY");
            tex:SetAllPoints(true);
            local topColor = CreateColor(0.082, 0.047, 0.027, 0);
            local bottomColor = CreateColor(0.082, 0.047, 0.027, 1)
            tex:SetColorTexture(1, 1, 1);
            tex:SetGradient("VERTICAL", bottomColor, topColor);
            BottomGradient:SetFrameLevel(self:GetFrameLevel() + 2);
        end

        if self.BottomGradient then
            self.BottomGradient:SetShown(state);
        end
    end

    function ScrollViewMixin:SetBoundaryGradientSize(size)
        --size(height) is usually (buttonHeight + gap)
        self.boundaryGradientSize = size;
        if self.BottomGradient then
            self.BottomGradient:SetHeight(size);
        end
    end
end

do  --ScrollView Callback
    function ScrollViewMixin:OnHide()
        self:StopScrolling();

        if self.onHideCallback then
            self.onHideCallback();
        end

        if self.ScrollBar then
            self.ScrollBar:StopUpdating();
        end
    end

    function ScrollViewMixin:SetOnHideCallback(onHideCallback)
        self.onHideCallback = onHideCallback;
    end

    function ScrollViewMixin:OnScrollStart()
        if self.useMouseBlocker then
            self.MouseBlocker:Show();
            self.MouseBlocker:SetFrameLevel(self:GetFrameLevel() + 4);
        end

        if self.onScrollStartCallback then
            self.onScrollStartCallback();
        end
    end

    function ScrollViewMixin:SetOnScrollStartCallback(onScrollStartCallback)
        self.onScrollStartCallback = onScrollStartCallback;
    end

    function ScrollViewMixin:OnScrollStop()
        if self.useMouseBlocker then
            self.MouseBlocker:Hide();
        end

        if self.onScrollStopCallback then
            self.onScrollStopCallback();
        end
    end

    function ScrollViewMixin:SetOnScrollStopCallback(onScrollStopCallback)
        self.onScrollStopCallback = onScrollStopCallback;
    end
end

do  --ScrollView Content Update
    function ScrollViewMixin:CallObjectMethod(templateKey, method, ...)
        self.pools[templateKey]:CallMethod(method, ...);
    end

    function ScrollViewMixin:CallObjectMethodByPredicate(templateKey, predicate, method, ...)
        self.pools[templateKey]:CallMethodByPredicate(predicate, method, ...);
    end

    function ScrollViewMixin:ProcessActiveObjects(templateKey, processFunc)
        self.pools[templateKey]:ProcessActiveObjects(processFunc)
    end
end

do  --Create ScrollView in Tab
    local function CreateScrollViewForTab(tab, offsetY)
        if tab.ScrollView then return end;

        offsetY = offsetY or 0;

        local ScrollView = API.CreateScrollView(tab);
        tab.ScrollView = ScrollView;
        ScrollView:SetPoint("TOPLEFT", tab, "TOPLEFT", 8, -8 + offsetY);
        ScrollView:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -8, 8);
        ScrollView:OnSizeChanged();
        ScrollView:SetStepSize(56);
        ScrollView:SetBottomOvershoot(28);
        ScrollView:EnableMouseBlocker(true);
        ScrollView:SetAllowOvershootAfterRangeChange(true);
        ScrollView:SetAlwaysShowScrollBar(true);

        return ScrollView
    end
    LandingPageUtil.CreateScrollViewForTab = CreateScrollViewForTab;
end