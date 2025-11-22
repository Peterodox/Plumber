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

        self.Highlight:SetAlpha(0.2);
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
end


local ThumbButtonMixin = {};
do
    function ThumbButtonMixin:OnLoad()
        self.OnLoad = nil;

        self:SetScript("OnMouseDown", self.OnMouseDown);
        self:SetScript("OnMouseUp", self.OnMouseUp);

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
            self:GetParent():StopUpdating();
            self:UnlockHighlight();
        end
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
        SetTexCoord(self.Rail.Middle, 0, 32, 32, 160);
        SetTexCoord(self.Rail.Bottom, 0, 32, 160, 192);

        SetTexCoord(self.Thumb.Top, 0, 32, 208, 240);
        SetTexCoord(self.Thumb.Middle, 0, 32, 240, 304);
        SetTexCoord(self.Thumb.Bottom, 0, 32, 304, 336);
        SetTexCoord(self.Thumb.HighlightTop, 0, 32, 208, 240);
        SetTexCoord(self.Thumb.HighlightMiddle, 0, 32, 240, 304);
        SetTexCoord(self.Thumb.HighlightBottom, 0, 32, 304, 336);

        SetTexCoord(self.UpArrow.Texture, 0, 32, 352, 384);
        SetTexCoord(self.UpArrow.Highlight, 0, 32, 352, 384);
        SetTexCoord(self.DownArrow.Texture, 0, 32, 384, 416);
        SetTexCoord(self.DownArrow.Highlight, 0, 32, 384, 416);
    end

    function ScrollBarMixin:SetTexure(texture)
        local DisableSharpening = API.DisableSharpening;
        for obj in pairs(self.textureObjects) do
            obj:SetTexture(texture);
            --DisableSharpening(obj);
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
    f:SetTexure("Interface/AddOns/Plumber/Art/ControlCenter/SettingsSlider.png");
    f:ShowArrowButtons(true);
    f:UpdateThumbRange();
    f:SetValueByRatio(0);

    f.ScrollView = DebugScrollView;

    return f
end
ControlCenter.CreateScrollBarWithDynamicSize = CreateScrollBarWithDynamicSize;