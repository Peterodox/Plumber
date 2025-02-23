--Drag Reorder Controller


local _, addon = ...
local API = addon.API;
local GetCursorPosition = API.GetScaledCursorPosition;
local ipairs = ipairs;
local tsort = table.sort;
local tinsert = table.insert;
local UIParent = UIParent;


local ReorderControllerMixin = {};

function API.CreateDragReorderController(parent)
    local f = CreateFrame("Frame", nil, parent);
    f.AnimFrame = CreateFrame("Frame", nil, f);
    API.Mixin(f, ReorderControllerMixin);
    return f
end


local function SortFunc_Horizontal(a, b)
    return a.x < b.x
end

local function SortFunc_Horizontal_Target(a, b)
    return a.targetPosition < b.targetPosition
end


function ReorderControllerMixin:SnapshotCursorPosition()
    local x, y = GetCursorPosition();
    self.x, self.y = x, y;
    self.x0, self.y0 = x, y;
end

function ReorderControllerMixin:SnapshotObjectPosition()
    if self.boundary then
        self.boundaryLeft = self.boundary:GetLeft();
        self.boundaryRight = self.boundary:GetRight();
        self.boundaryTop = self.boundary:GetTop();
        self.boundaryBottom = self.boundary:GetBottom();
    end

    if self.objects then
        self.objectPositions = {};
        local x, y;
        for i, object in ipairs(self.objects) do
            x, y = object:GetCenter();
            self.objectPositions[i] = {
                i = i,
                object = object,
                x = x,
            };
        end
    end
end

function ReorderControllerMixin:Stop()
    self:SetScript("OnUpdate", nil);
    self.stage = nil;
    self.x, self.y = 0, 0;
    self.x0, self.y0 = 0, 0;
    self.dx, self.dy = 0, 0;
    self.t = 0;
    self.boundaryLeft, self.boundaryRight, self.boundaryTop, self.boundaryBottom = 0, 0, 0, 0;
    self.oldPositionIndex = nil;
    self.inBoundary = nil;
    self:UnregisterEvent("GLOBAL_MOUSE_UP");
end

function ReorderControllerMixin:OnUpdate_PreDrag(elapsed)
    --Horizontal
    self.x, self.y = GetCursorPosition();
    if (self.x - self.x0) ^ 2 + (self.y - self.y0) ^ 2 >= 8 then
        self:DraggingStart();
    end
end

function ReorderControllerMixin:PreDragStart()
    self.stage = 1;
    self:SnapshotCursorPosition();
    self:SnapshotObjectPosition();
    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate_PreDrag)
end

function ReorderControllerMixin:PreDragEnd()
    self:SetScript("OnUpdate", nil);
    self:Stop();
end

function ReorderControllerMixin:IsInBoundary()
    if self.boundary then
        return not(
        (self.x + self.dx > self.boundaryRight) or (self.x + self.dx + self.draggedObjectWidth < self.boundaryLeft) or
        (self.y + self.dy > self.boundaryTop) or (self.y + self.dy + self.draggedObjectHeight < self.boundaryBottom)
        )
    end
end

function ReorderControllerMixin:OnUpdate_Dragging(elapsed)
    self.x, self.y = GetCursorPosition();
    self.draggedObject:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.x + self.dx, self.y + self.dy);
    self.temp = self:IsInBoundary();
    if self.temp ~= self.inBoundary then
        self.inBoundary = self.temp;
        if self.inBoundary then
            if self.inBoundaryCallback then
                self.inBoundaryCallback();
            end
        else
            if self.outBoundaryCallback then
                self.outBoundaryCallback();
            end
        end
    end

    self.t = self.t + elapsed;
    if self.t > 0.20 then
        self.t = 0;
        self:EvaluateObjectPositions();
    end
end

function ReorderControllerMixin:OnEvent(event, ...)
    if event == "GLOBAL_MOUSE_UP" then
        self:DraggingEnd();
    end
end

function ReorderControllerMixin:ConvertObjectAnchors()
    local relativeLeft = self.relativeTo:GetLeft();
    for i, object in ipairs(self.objects) do
        object.anchorDirty = true;
        object.currentPosition = object:GetLeft() - relativeLeft;
        object.targetPosition = object.currentPosition;
    end
end

function ReorderControllerMixin:DraggingStart()
    self.stage = 2;
    self:SnapshotCursorPosition();
    self:RegisterEvent("GLOBAL_MOUSE_UP");
    self:SetScript("OnEvent", self.OnEvent);

    --debug
    local left = self.draggedObject:GetLeft();
    local bottom = self.draggedObject:GetBottom();
    self.draggedObjectWidth, self.draggedObjectHeight = self.draggedObject:GetSize();
    self.dx = left - self.x;
    self.dy = bottom - self.y;
    self.draggedObject:ClearAllPoints();
    self.draggedObject:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom);

    if self.onDragStartCallback then
        self.onDragStartCallback();
    end

    self:SnapshotObjectPosition();
    self:ConvertObjectAnchors();

    self.t = 1;
    self:SetScript("OnUpdate", self.OnUpdate_Dragging);
end

function ReorderControllerMixin:DraggingEnd()
    local inBoundary = self.inBoundary;
    self:Stop();

    if self.objectPositions then
        tsort(self.objects, SortFunc_Horizontal_Target);
        self:RepositionObjects(false);
    end

    if self.onDragEndCallback then
        self.onDragEndCallback(self.draggedObject, not inBoundary);
    end
end

function ReorderControllerMixin:SetDraggedObject(object)
    self.draggedObject = object;
end

function ReorderControllerMixin:GetDraggedObject()
    if self.stage == 2 then
        return self.draggedObject
    end
end

function ReorderControllerMixin:OnMouseUp()
    if self.stage == 1 then
        self:PreDragEnd();
    elseif self.stage == 2 then
        self:DraggingEnd();
    end
end

function ReorderControllerMixin:IsDraggingObject()
    return self.stage == 2
end

function ReorderControllerMixin:SetOnDragStartCallback(onDragStartCallback)
    self.onDragStartCallback = onDragStartCallback;
end

function ReorderControllerMixin:SetOnDragEndCallback(onDragEndCallback)
    self.onDragEndCallback = onDragEndCallback;
end

function ReorderControllerMixin:SetObjects(objects)
    self.objects = objects;
end

function ReorderControllerMixin:SetPlaceholder(placeholder)
    self.placeholder = placeholder;
end

function ReorderControllerMixin:SetBoundary(boundary)
    --boundary is a frame
    self.boundary = boundary;
end

function ReorderControllerMixin:SetInBoundaryCallback(inBoundaryCallback)
    self.inBoundaryCallback = inBoundaryCallback;
end

function ReorderControllerMixin:SetOutBoundaryCallback(outBoundaryCallback)
    self.outBoundaryCallback = outBoundaryCallback;
end

function ReorderControllerMixin:SetAnchorInfo(relativeTo, relativePoint, offsetX, offsetY, objectGapX, objectGapY)
    self.relativeTo = relativeTo;
    self.relativePoint = relativePoint;
    self.relativeX = offsetX;
    self.relativeY = offsetY;
    self.objectGapX = objectGapX;
    self.objectGapY = objectGapY;
end

function ReorderControllerMixin:EvaluateObjectPositions()
    local targetLeft = self.x + self.dx;
    local targetRight = targetLeft + self.draggedObjectWidth;
    local targetY = self.y + self.dy + 0.5 * self.draggedObjectHeight;
    local newPositionIndex;

    for i, info in ipairs(self.objectPositions) do
        if targetLeft < info.x then
            newPositionIndex = i;
            break
        else
            if self.objectPositions[i + 1] then
                if targetRight < self.objectPositions[i + 1].x then
                    newPositionIndex = i;
                    break
                end
            else
                newPositionIndex = #self.objectPositions;
            end
        end
    end

    if newPositionIndex ~= self.oldPositionIndex then
        self.oldPositionIndex = newPositionIndex;
        local draggedObjectInfo;
        for i, info in ipairs(self.objectPositions) do
            if info.object == self.draggedObject then
                draggedObjectInfo = table.remove(self.objectPositions, i);
                break
            end
        end

        tinsert(self.objectPositions, newPositionIndex, draggedObjectInfo);

        local gap = self.objectGapX or 0;
        local offsetX = 0;
        local obj, newX;
        local relativeLeft = self.relativeTo:GetLeft();

        for i, info in ipairs(self.objectPositions) do
            obj = info.object;
            newX = self.relativeX + offsetX;
            if obj ~= self.draggedObject then
                --obj:ClearAllPoints();
                --obj:SetPoint("LEFT", self.relativeTo, self.relativePoint, newX, self.relativeY);
                obj.x = relativeLeft + newX + 0.5*obj:GetWidth();
            else
                obj.x = self.x + self.dx + 0.5 * self.draggedObjectWidth;
                if self.placeholder then
                    self.placeholder:ClearAllPoints();
                    self.placeholder:SetPoint("LEFT", self.relativeTo, self.relativePoint, newX, self.relativeY);
                end
            end
            obj.targetPosition = newX;
            offsetX = offsetX + obj:GetWidth() + gap;
        end

        tsort(self.objectPositions, SortFunc_Horizontal);

        self:RepositionObjects(true);
    end
end

local function AnimPosition_OnUpdate(self, elapsed)
    local complete = true;
    local diff;
    local delta;
    local widget;

    for i = 1, self.numWidgets do
        widget = self.widgets[i];
        if widget.currentPosition then
            diff = widget.targetPosition - widget.currentPosition;
            if diff ~= 0 then
                delta = elapsed * 16 * diff;
                if diff >= 0 and (diff < 1 or (widget.currentPosition + delta >= widget.targetPosition)) then
                    widget.currentPosition = widget.targetPosition;
                    complete = complete and true;
                elseif diff <= 0 and (diff > -1 or (widget.currentPosition + delta <= widget.targetPosition)) then
                    widget.currentPosition = widget.targetPosition;
                    complete = complete and true;
                else
                    widget.currentPosition = widget.currentPosition + delta;
                    complete = false;
                end

                if widget.anchorDirty then
                    widget.anchorDirty = nil;
                    widget:ClearAllPoints();
                end

                widget:SetPoint("LEFT", self.relativeTo, "LEFT", widget.currentPosition, 0);
            end
        else
            if widget.anchorDirty then
                widget.anchorDirty = nil;
                widget:ClearAllPoints();
            end
            widget:SetPoint("LEFT", self.relativeTo, "LEFT", widget.targetPosition, 0);
            widget.currentPosition = widget.targetPosition;
        end
    end

    if complete then
        self:SetScript("OnUpdate", nil);
    end
end

function ReorderControllerMixin:RepositionObjects(animate)
    if animate then
        local relativeLeft = self.relativeTo:GetLeft();
        local left;
        local n = 0;
        local objects = {};

        for _, object in ipairs(self.objects) do
            if object ~= self.draggedObject then
                n = n + 1;
                objects[n] = object;
                left = object:GetLeft();
                object.currentPosition = left - relativeLeft;
                object.anchorDirty = true;
            end
        end

        self.AnimFrame.relativeTo = self.relativeTo;
        self.AnimFrame.widgets = objects;
        self.AnimFrame.numWidgets = n;

        self.AnimFrame:SetScript("OnHide", function()
            self.AnimFrame:SetScript("OnUpdate", nil);
        end);
        self.AnimFrame:SetScript("OnUpdate", AnimPosition_OnUpdate);
    else
        self.AnimFrame:SetScript("OnUpdate", nil);
        for _, object in ipairs(self.objects) do
            object:ClearAllPoints();
            object:SetPoint("LEFT", self.relativeTo, "LEFT", object.targetPosition, 0);
            object.currentPosition = object.targetPosition;
        end
    end
end