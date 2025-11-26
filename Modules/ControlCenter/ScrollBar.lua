local _, addon = ...
local API = addon.API;
local ControlCenter = addon.ControlCenter;


local GetCursorPosition = GetCursorPosition;


local ArrowButtonMixin = {};
do
    function ArrowButtonMixin:OnLoad()
        self.OnLoad = nil;

        self:SetScript("OnMouseDown", self.OnMouseDown);
        self:SetScript("OnMouseUp", self.OnMouseUp);
        self:SetScript("OnEnable", self.OnEnable);
        self:SetScript("OnDisable", self.OnDisable);
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);

        self.Highlight:SetAlpha(0.5);
    end

    function ArrowButtonMixin:OnMouseDown(button)
        if not self:IsEnabled() then return end;
        if button == "LeftButton" then
            self.Highlight:SetAlpha(1);
            self:GetParent().ScrollView:OnMouseWheel(self.delta);
            self:GetParent():StartPushingArrow(self.delta);
            addon.LandingPageUtil.PlayUISound("ScrollBarStep");
        end
    end

    function ArrowButtonMixin:OnMouseUp()
        self.Highlight:SetAlpha(0.5);
        self:GetParent():StopUpdating();
        self:GetParent().ScrollView:StopSteadyScroll();
    end

    function ArrowButtonMixin:OnEnable()
        self.Texture:SetVertexColor(1, 1, 1);
        self.Texture:SetDesaturated(false);
    end

    function ArrowButtonMixin:OnDisable()
        self.Texture:SetVertexColor(0.5, 0.5, 0.5);
        self.Texture:SetDesaturated(true);
    end

    function ArrowButtonMixin:OnEnter()
        self:GetParent():UpdateVisual();
    end

    function ArrowButtonMixin:OnLeave()
        self:GetParent():UpdateVisual();
    end
end


local ThumbButtonMixin = {};
do
    function ThumbButtonMixin:OnLoad()
        self.OnLoad = nil;

        self:SetScript("OnMouseDown", self.OnMouseDown);
        self:SetScript("OnMouseUp", self.OnMouseUp);
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnHide", self.OnHide);

        self.HighlightTop:SetAlpha(0.2);
        self.HighlightMiddle:SetAlpha(0.2);
        self.HighlightBottom:SetAlpha(0.2);
    end

    function ThumbButtonMixin:OnMouseDown(button)
        if button == "LeftButton" then
            self.HighlightTop:SetAlpha(0.5);
            self.HighlightMiddle:SetAlpha(0.5);
            self.HighlightBottom:SetAlpha(0.5);
            self:GetParent():StartDraggingThumb();
            self:LockHighlight();
            addon.LandingPageUtil.PlayUISound("ScrollBarThumbDown");
        end
    end

    function ThumbButtonMixin:OnMouseUp(button)
        if button == "LeftButton" then
            self.HighlightTop:SetAlpha(0.2);
            self.HighlightMiddle:SetAlpha(0.2);
            self.HighlightBottom:SetAlpha(0.2);
            self:UnlockHighlight();
            self:GetParent():StopUpdating();
            self:GetParent():UpdateVisual();
        end
    end

    local function Thumb_Expand_OnUpdate(self, elapsed)
        self.capSize = self.capSize + 128 * elapsed;
        if self.capSize >= 16 then
            self.capSize = 16;
            self:SetScript("OnUpdate", nil);
        end
        self.Top:SetSize(self.capSize, self.capSize);
        self.Bottom:SetSize(self.capSize, self.capSize);
    end

    local function Thumb_Shrink_OnUpdate(self, elapsed)
        self.capSize = self.capSize - 128 * elapsed;
        if self.capSize <= 16 then
            self.capSize = 16;
            self:SetScript("OnUpdate", nil);
        end
        self.Top:SetSize(self.capSize, self.capSize);
        self.Bottom:SetSize(self.capSize, self.capSize);
    end

    function ThumbButtonMixin:Expand()
        self.expanded = true;
        self.Top:SetTexCoord(0/512, 32/512, 264/512, 296/512);
        self.Middle:SetTexCoord(0/512, 32/512, 296/512, 360/512);
        self.Bottom:SetTexCoord(0/512, 32/512, 360/512, 392/512);
        self.HighlightTop:SetTexCoord(0/512, 32/512, 264/512, 296/512);
        self.HighlightMiddle:SetTexCoord(0/512, 32/512, 296/512, 360/512);
        self.HighlightBottom:SetTexCoord(0/512, 32/512, 360/512, 392/512);

        self.capSize = self.Top:GetWidth() * 0.5;
        self:SetScript("OnUpdate", Thumb_Expand_OnUpdate);
        Thumb_Expand_OnUpdate(self, 0);
    end

    function ThumbButtonMixin:Shrink()
        self.Top:SetTexCoord(0/512, 32/512, 132/512, 164/512);
        self.Middle:SetTexCoord(0/512, 32/512, 164/512, 228/512);
        self.Bottom:SetTexCoord(0/512, 32/512, 228/512, 260/512);
        self.HighlightTop:SetTexCoord(0/512, 32/512, 132/512, 164/512);
        self.HighlightMiddle:SetTexCoord(0/512, 32/512, 164/512, 228/512);
        self.HighlightBottom:SetTexCoord(0/512, 32/512, 228/512, 260/512);

        self.capSize = self.Top:GetWidth() * 2;
        self:SetScript("OnUpdate", Thumb_Shrink_OnUpdate);
        Thumb_Shrink_OnUpdate(self, 0);
    end

    function ThumbButtonMixin:OnEnter()
        self:GetParent():UpdateVisual();
    end

    function ThumbButtonMixin:OnLeave()
        self:GetParent():UpdateVisual();
    end

    function ThumbButtonMixin:OnHide()
        self:OnMouseUp("LeftButton");
    end
end


local ScrollBarMixin = {};
do
    function ScrollBarMixin:OnLoad()
        self.OnLoad = nil;

        Mixin(self.UpArrow, ArrowButtonMixin);
        Mixin(self.DownArrow, ArrowButtonMixin);
        Mixin(self.Thumb, ThumbButtonMixin);
        self.UpArrow:OnLoad();
        self.UpArrow.delta = 1;
        self.DownArrow:OnLoad();
        self.DownArrow.delta = -1;
        self.Thumb:OnLoad();

        self.textureObjects = {};

        local function AddTexture(obj)
            self.textureObjects[obj] = true;
        end

        local function SetTexCoord(obj, x1, x2, y1, y2)
            AddTexture(obj);
            obj:SetTexCoord(x1/512, x2/512, y1/512, y2/512);
        end

        SetTexCoord(self.Rail.Top, 0, 32, 0, 32);
        SetTexCoord(self.Rail.Middle, 0, 32, 32, 96);
        SetTexCoord(self.Rail.Bottom, 0, 32, 96, 128);

        SetTexCoord(self.Thumb.Top, 0, 32, 132, 164);
        SetTexCoord(self.Thumb.HighlightTop, 0, 32, 132, 164);
        SetTexCoord(self.Thumb.Middle, 0, 32, 164, 228);
        SetTexCoord(self.Thumb.HighlightMiddle, 0, 32, 164, 228);
        SetTexCoord(self.Thumb.Bottom, 0, 32, 228, 260);
        SetTexCoord(self.Thumb.HighlightBottom, 0, 32, 228, 260);

        SetTexCoord(self.UpArrow.Texture, 0, 32, 396, 428);
        SetTexCoord(self.UpArrow.Highlight, 0, 32, 396, 428);
        SetTexCoord(self.DownArrow.Texture, 0, 32, 428, 460);
        SetTexCoord(self.DownArrow.Highlight, 0, 32, 428, 460);


        self.Rail:SetScript("OnMouseDown", function(_, button)
            if button == "LeftButton" then
                self:ScrollToMouseDownPosition();
                addon.LandingPageUtil.PlayUISound("ScrollBarThumbDown");
            end
        end);

        self.Rail:SetScript("OnEnter", function()
            self:UpdateVisual();
        end);

        self.Rail:SetScript("OnLeave", function()
            self:UpdateVisual();
        end);
    end

    function ScrollBarMixin:SetTexure(texture)
        for obj in pairs(self.textureObjects) do
            obj:SetTexture(texture);
        end
    end

    function ScrollBarMixin:ShowArrowButtons(showArrows)
        if showArrows == self.showArrows then return end;
        self.showArrows = showArrows;

        self.UpArrow:SetShown(showArrows);
        self.DownArrow:SetShown(showArrows);

        local offsetY;
        if showArrows then
            offsetY = 16;
        else
            offsetY = 0;
        end

        self.Rail:ClearAllPoints();
        self.Rail:SetPoint("TOP", self, "TOP", 0, -offsetY);
        self.Rail:SetPoint("BOTTOM", self, "BOTTOM", 0, offsetY);
    end

    function ScrollBarMixin:SetVisibleExtentPercentage(ratio)
        local height = API.Round(ratio * self.Rail:GetHeight());
        self.Thumb:SetHeight(height);
    end

    function ScrollBarMixin:UpdateVisibleExtentPercentage()
        local range = self.ScrollView:GetScrollRange();
        local viewHeight = self.ScrollView:GetHeight();
        self:SetVisibleExtentPercentage(viewHeight / (viewHeight + range));
        self:UpdateThumbRange();
        self:SetValueByRatio(self.ratio or 0);
    end

    function ScrollBarMixin:OnSizeChanged()

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
            self.isTop = self.ScrollView:IsAtTop();
            self.isBottom = self.ScrollView:IsAtBottom();
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

    function ScrollBarMixin:UpdateVisual()
        if self.Rail:IsMouseMotionFocus() or self.Thumb:IsMouseMotionFocus() or self:IsDraggingThumb() then
            if not self.expanded then
                self.expanded = true;
                self.Thumb:Expand();
            end
        else
            if self.expanded then
                self.expanded = nil;
                self.Thumb:Shrink();
            end
        end
    end

    function ScrollBarMixin:StartDraggingThumb()
        self:Snapshot();
        self:UpdateThumbRange();
        self.t = 0;
        self.isDraggingThumb = true;
        self:SetScript("OnUpdate", self.OnUpdate_ThumbDragged);
    end

    function ScrollBarMixin:IsDraggingThumb()
        return self.isDraggingThumb
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
            self.ScrollView:SteadyScroll(-self.delta);
        end
    end

    function ScrollBarMixin:StopUpdating()
        self:SetScript("OnUpdate", nil);
        self.t = nil;
        self.x, self.y = nil, nil;
        self.x0, self.y0 = nil, nil;
        self.dx, self.dy = nil, nil;
        self.scale = nil;
        self.isDraggingThumb = nil;
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

        self.ScrollView:ScrollToRatio(ratio);
    end

    function ScrollBarMixin:GetScrollView()
        return self.ScrollView
    end
end


local DebugScrollView = {};
do
    function DebugScrollView:ScrollToRatio()

    end

    function DebugScrollView:SnapToRatio()

    end

    function DebugScrollView:OnMouseWheel()
        
    end

    function DebugScrollView:IsAtTop()

    end

    function DebugScrollView:IsAtBottom()

    end

    function DebugScrollView:SteadyScroll()

    end

    function DebugScrollView:StopSteadyScroll()

    end
end


local function CreateScrollBarWithDynamicSize(parent)
    local f = CreateFrame("Frame", nil, parent, "PlumberScrollBarWithDynamicSizeTemplate");

    Mixin(f, ScrollBarMixin);
    f:OnLoad();
    f:SetTexure("Interface/AddOns/Plumber/Art/ControlCenter/SettingsPanelWidget.png");
    f:ShowArrowButtons(true);
    f:UpdateThumbRange();
    f:SetValueByRatio(0);

    f.ScrollView = DebugScrollView;

    return f
end
ControlCenter.CreateScrollBarWithDynamicSize = CreateScrollBarWithDynamicSize;