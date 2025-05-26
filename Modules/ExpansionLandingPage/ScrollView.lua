local _, addon = ...
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;


local Clamp = API.Clamp;
local DeltaLerp = API.DeltaLerp;
local CreateFrame = CreateFrame;
local ipairs = ipairs;
local tinsert = table.insert;
local tremove = table.remove;
local IsShiftKeyDown = IsShiftKeyDown;


local CraeteObjectPool;
do
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

    function CraeteObjectPool(create, onAcquired, onRemoved)
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

    function ScrollViewMixin:OnSizeChanged()
        --We call this manually
        self.viewportSize = API.Round(self:GetHeight());
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
            local offset = self.scrollTarget;
            if offset > self.range then
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
        self.pools[templateKey] = CraeteObjectPool(create, onAcquired, onRemoved);
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
            self:StopScrolling();
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

    function ScrollViewMixin:ResetScroll()
        self:SnapTo(0);
    end

    function ScrollViewMixin:SnapToBottom()
        self:SnapTo(self.range);
    end

    function ScrollViewMixin:ScrollToContent(contentIndex)
        if contentIndex < 1 then contentIndex = 1 end;

        if self.content[contentIndex] then
            self:ScrollTo(self.content[contentIndex].top);
        end
    end

    function ScrollViewMixin:SnapToContent(contentIndex)
        if contentIndex < 1 then contentIndex = 1 end;

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
                f:SetFrameStrata("FULLSCREEN_DIALOG");
                f:EnableMouse(true);
                f:EnableMouseMotion(true);
            end
        else
            if self.MouseBlocker then
                self.MouseBlocker:Hide();
            end
        end
    end
end

do  --ScrollView Callback
    function ScrollViewMixin:OnHide()
        self:StopScrolling();

        if self.onHideCallback then
            self.onHideCallback();
        end
    end

    function ScrollViewMixin:SetOnHideCallback(onHideCallback)
        self.onHideCallback = onHideCallback;
    end

    function ScrollViewMixin:OnScrollStart()
        if self.useMouseBlocker then
            self.MouseBlocker:Show();
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