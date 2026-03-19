local _, addon = ...
local API = addon.API;

local C_UIWidgetManager = C_UIWidgetManager;


if not(C_UIWidgetManager and Enum.UIWidgetVisualizationType) then
	function API.GetWidgetText(widgetType, widgetID, includeHidden)

	end

	function API.AddWidgetSetToTooltip(tooltip, widgetSetID)
		return false
	end
end


local VisualInfoGetter = {};
do
	local tbl = {
		--IconAndText = C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo,
		StatusBar = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo,
		TextWithState = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo,
		HorizontalCurrencies = C_UIWidgetManager.GetHorizontalCurrenciesWidgetVisualizationInfo,
		Spacer = C_UIWidgetManager.GetSpacerVisualizationInfo,
		ItemDisplay = C_UIWidgetManager.GetItemDisplayVisualizationInfo,
	};

	for key, func in pairs(tbl) do
		local widgetType = Enum.UIWidgetVisualizationType[key];
		if widgetType then
			VisualInfoGetter[widgetType] = func;
		end
	end

	tbl = nil;
end


local function JoinText(delimiter, leftText, rightText)
	if leftText then
		if rightText then
			return leftText..delimiter..rightText
		else
			return leftText
		end
	elseif rightText then
		return rightText
	end
end

local function SortFunc_OrderIndex(a, b)
	if a.orderIndex and b.orderIndex and a.orderIndex ~= b.orderIndex then
		return a.orderIndex < b.orderIndex
	end
	return false
end


local Enum_State = Enum.WidgetEnabledState;
local function GetTextColorForEnabledState(enabledState)
	--See Blizzard_UIWidgets/Mainline/Blizzard_UIWidgetTemplateBase.lua?L117

	if not enabledState then
		return NORMAL_FONT_COLOR
	end

	if enabledState == Enum_State.Disabled then
		return DISABLED_FONT_COLOR
	elseif enabledState == Enum_State.Red then
		return RED_FONT_COLOR
	elseif enabledState == Enum_State.White then
		return HIGHLIGHT_FONT_COLOR
	elseif enabledState == Enum_State.Green then
		return GREEN_FONT_COLOR
	elseif enabledState == Enum_State.Artifact then
		return ARTIFACT_GOLD_COLOR
	elseif enabledState == Enum_State.Black then
		return BLACK_FONT_COLOR
	elseif enabledState == Enum_State.BrightBlue then
		return BRIGHTBLUE_FONT_COLOR
	else
		return NORMAL_FONT_COLOR
	end
end

local function GetWidgetText(widgetType, widgetID, includeHidden)
	if VisualInfoGetter[widgetType] then
		local loaded = true;
		local info = VisualInfoGetter[widgetType](widgetID);
		if info and (info.shownState == 1 or includeHidden) then
			if widgetType == 22 then
				--Spacer Type
				return " ", HIGHLIGHT_FONT_COLOR, info.orderIndex
			end

			local text;

			if info.barMax and info.barMax > 0 and info.barValue then
				text = info.barValue.."/"..info.barMax;
			end

			if info.currencies then
				for _, v in ipairs(info.currencies) do
					text = JoinText(" ", text, string.format("|T%s:0:0|t %s", v.iconFileID, v.text));
				end
			end

			if info.itemInfo and info.itemInfo.itemID then
				local itemName, _, quality, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(info.itemInfo.itemID);
				itemName = info.itemInfo.overrideItemName or itemName;
				if itemName then
					text = JoinText(" ", text, string.format("|T%s:0:0|t %s", itemTexture, API.ColorizeTextByQuality(itemName, quality)));
				else
					loaded = false;
				end
			end

			if info.text and info.text ~= "" then
				text = JoinText(": ", text, info.text);
			end

			return text, GetTextColorForEnabledState(info.enabledState), info.orderIndex, loaded
		end
	else
		--print("Unsupported Widget: ", widgetType, widgetID);
	end
end
API.GetWidgetText = GetWidgetText;


local function AddWidgetSetToTooltip(tooltip, widgetSetID)
	local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID);
	if widgets then
		local text, color, orderIndex, loaded;
		local isRetrievingData = false;
		local tbl = {};
		local n = 0;

		for _, widget in ipairs(widgets) do
			text, color, orderIndex, loaded = GetWidgetText(widget.widgetType, widget.widgetID);
			if text then
				n = n + 1;
				tbl[n] = {
					text = text,
					color = color,
					orderIndex = orderIndex,
				};

				if not loaded then
					isRetrievingData = true;
				end
			end
		end

		if n > 0 then
			table.sort(tbl, SortFunc_OrderIndex);
			local r, g, b;
			for _, v in ipairs(tbl) do
				if v.color then
					r, g, b = v.color:GetRGB();
				else
					r, g, b = 1, 1, 1;
				end
				tooltip:AddLine(v.text, r, g, b, true);
			end
		end

		return n > 0, isRetrievingData
	end
end
API.AddWidgetSetToTooltip = AddWidgetSetToTooltip;
