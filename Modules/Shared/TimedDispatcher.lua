local _, addon = ...

local TimedDispatcher = CreateFrame("Frame");
addon.TimedDispatcher = TimedDispatcher;


local Def = {
	DefaultTooltipDelay = 0.5,
};


local function Callback_ShowTooltipIfFocused(widget)
	if widget and widget.ShowTooltip then
		if widget:IsMouseMotionFocus() then
			widget:ShowTooltip();
		end
	end
end


function TimedDispatcher:OnUpdate(elapsed)
	self.t = self.t + elapsed;
	if self.t >= self.d then
		self.t = 0;
		self:SetScript("OnUpdate", nil);
		if self.callback then
			self.callback(self.widget);
		end
	end
end

function TimedDispatcher:ShowWidgetTooltipAfterDelay(widget, delay)
	self.t = 0;
	self.d = delay or Def.DefaultTooltipDelay;
	self.callback = Callback_ShowTooltipIfFocused;
	self.widget = widget;
	self:SetScript("OnUpdate", self.OnUpdate);
end

function TimedDispatcher:Kill()
	self.t = 0;
	self.widget = nil;
	self:SetScript("OnUpdate", nil);
end
