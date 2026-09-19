local _, addon = ...
local L = addon.L;
local API = addon.API;
local CallbackRegistry = addon.CallbackRegistry;
local LootUI = addon.LootUI; ---@class LootUISystem
local Def = LootUI.Defination;
local Formatter = LootUI.Formatter;
local MainFrame = LootUI.MainFrame;
local EventListeners = LootUI.EventListeners;


local SampleItems = {
	{icon = Def.IS_CLASSIC and 135331 or 4622270, name = L["Sample Item 4"], quality = 4, quantity = 1, owned = 99},
	{icon = Def.IS_CLASSIC and 135578 or 463446, name = L["Sample Item 3"], quality = 3, quantity = 20, owned = 99},
	{icon = Def.IS_CLASSIC and 134010 or 4549280, name = L["Sample Item 2"], quality = 2, quantity = 100, owned = 99},
	{icon = Def.IS_CLASSIC and 133980 or 2967113, name = L["Sample Item 1"], quality = 1, quantity = 50, owned = 99},
};

function MainFrame:ShowSampleItems()
	self:ReleaseAll();
	self:SetScript("OnUpdate", nil);

	local itemFrame;
	local activeFrames = {};

	for i, data in ipairs(SampleItems) do
		itemFrame = self:AcquireItemFrame();
		activeFrames[i] = itemFrame;
		itemFrame:SetNameByQuality(data.name, data.quality);
		itemFrame:SetIcon(data.icon);
		itemFrame:SetCount(data);
		itemFrame:Layout();
		itemFrame:SetAlpha(1);
		itemFrame:Show();
		itemFrame:EnableMouseScript();
		if Def.SHOW_ITEM_COUNT then
			itemFrame.IconFrame.Count:SetText("99");
		else
			itemFrame.IconFrame.Count:SetText(nil);
		end
	end

	self.activeFrames = activeFrames;
	self:LayoutActiveFrames();
	self:Show();
	self:SetAlpha(1);
	self:SetBackgroundAlpha(Def.BG_OPACITY);

	self.manualMode = nil;
	self.Header:Hide();
	self.HeaderWidgetContainer:Show();
	self.TakeAllButton:Layout();
	self.TakeAllButton:SetScript("OnKeyDown", nil);
	self:EnableHeaderWidgets(false);
end

function MainFrame:EnterEditMode()
	self.errorMode = nil;
	self.inEditMode = true;
	self:UpdateFrameStrata();
	self:ShowSampleItems();

	if not self.Selection then
		local uiName = L["ModuleName LootUI"];
		local hideLabel = true;
		self.Selection = addon.CreateEditModeSelection(self, uiName, hideLabel);
	end
	self.Selection:ShowHighlighted();
	self.Selection:SetAlpha(1);

	self:LoadPosition();
	self:UnregisterEvent("GLOBAL_MOUSE_UP");
	self:UnregisterEvent("BAG_UPDATE_DELAYED");

	self:ShowOptions(true);

	EventListeners:Disable();
end

function MainFrame:ExitEditMode()
	self.inEditMode = nil;
	self:Disable();
	self:SetAlpha(0);
	self:Hide();
	self:UpdateFrameStrata();
	self:EnableHeaderWidgets(true);

	if self.Selection then
		self.Selection:Hide();
	end

	self:ShowOptions(false);

	LootUI.TryResolveSystemStatus();
end

local function Options_FontSizeSlider_OnValueChanged(value)
	PlumberDB.LootUI_FontSize = value;
	local locale = GetLocale();
	if locale == "zhCN" or locale == "zhTW" then
		value = value + 2;
	end
	Formatter:CalculateDimensions(value);
	C_Timer.After(0, function()
		MainFrame:ShowSampleItems();
	end);
end

local function GetValidFadeOutDelayPerItem(value)
	value = value or 0.25;
	return API.Clamp(value, 0.25, 1.0);
end

local function Options_FadeOutDelaySlider_OnValueChanged(value)
	value = GetValidFadeOutDelayPerItem(value);
	PlumberDB.LootUI_FadeDelayPerItem = value;
	Def.FADE_DELAY_PER_ITEM = value;
end

local function GetValidItemsPerPage(value)
	value = math.floor(value or 5);
	value = API.Clamp(value, 5, 8);
	return value
end

local function Options_ItemsPerPageSlider_OnValueChanged(value)
	value = GetValidItemsPerPage(value);
	PlumberDB.LootUI_ItemsPerPage = value;
	Def.MAX_ITEM_PER_PAGE = value;
end

local function Options_OpacitySlider_OnValueChanged(value)
	value = API.Clamp(value, 0, 1);
	if value < 0.01 then
		value = 0;
	end
	Def.BG_OPACITY = value;
	PlumberDB.LootUI_BackgroundAlpha = value;
	MainFrame:SetBackgroundAlpha(Def.BG_OPACITY);
end

local function Options_OpacitySlider_OnMouseDown()
	if MainFrame.Selection then
		MainFrame.Selection:SetAlpha(0);
	end
end

local function Options_OpacitySlider_OnMouseUp(slider)
	if MainFrame.Selection and (not slider:IsMouseMotionFocus()) then
		MainFrame.Selection:SetAlpha(1);
	end
end

local function Options_ForceAutoLoot_ValidityCheck()
	return C_CVar.GetCVarBool("autoLootDefault");
end

local function Options_ResetPosition_OnClick(self)
	self:Disable();
	PlumberDB.LootUI_PositionX = nil;
	PlumberDB.LootUI_PositionY = nil;
	MainFrame:LoadPosition();
end

local function Options_ResetPosition_ShouldEnable(self)
	if PlumberDB.LootUI_PositionX and PlumberDB.LootUI_PositionY then
		return true
	else
		return false
	end
end

local function Tooltip_ManualLootInstruction()
	local key = GetModifiedClick("AUTOLOOTTOGGLE");
	key = key or "NONE";
	return L["Manual Loot Instruction Format"]:format(key)
end

local function Tooltip_GrowDirection()
	local tooltipFormat = " \n|cffffffff%s|r\n\n%s";
	if PlumberDB.LootUI_GrowUpwards then
		return string.format(tooltipFormat, L["LootUI Option Grow Direction Tooltip 1"], L["LootUI Option Grow Direction Tooltip 2"])
	else
		return string.format(tooltipFormat, L["LootUI Option Grow Direction Tooltip 2"], L["LootUI Option Grow Direction Tooltip 1"])
	end
end

local function Options_GrowDirection_OnClick(self)
	MainFrame:LoadPosition();
end

local function Validation_TransmogInvented()
	return addon.IsToCVersionEqualOrNewerThan(40000)
end

local function Validation_IsRetail()
	return addon.IsToCVersionEqualOrNewerThan(110000)
end

local function Tooltip_HideWindow()
	if addon.GetDBBool("LootUI_UseStockUI") then
		return "|cffff4800"..L["LootUI Option Hide Window Tooltip 2"].."|r";
	end
end

local function Tooltip_ShowReputation()
	local tooltip = L["LootUI Option Show Reputation Tooltip"];
	if not C_EventUtils.IsEventValid("FACTION_STANDING_CHANGED") then
		tooltip = tooltip.."\n\n|cffd4641c"..L["Module Wrong Game Version"].."|r";
	end
	return tooltip
end

local OPTIONS_SCHEMATIC = {
	title = L["Addon Name Colon"]..L["ModuleName LootUI"],
	moduleDBKey = "LootUI",
	widgets = {
		{type = "Slider", label = L["Font Size"], minValue = 10, maxValue = 16, valueStep = 2, onValueChangedFunc = Options_FontSizeSlider_OnValueChanged, formatValueMethod = "Decimal1", dbKey = "LootUI_FontSize"},
		{type = "Slider", label = L["LootUI Option Fade Delay"], minValue = 0.25, maxValue = 1.0, valueStep = 0.25, onValueChangedFunc = Options_FadeOutDelaySlider_OnValueChanged, formatValueMethod = "Decimal2", dbKey = "LootUI_FadeDelayPerItem"},
		{type = "Slider", label = L["LootUI Option Items Per Page"], minValue = 5, maxValue = 8, valueStep = 1, onValueChangedFunc = Options_ItemsPerPageSlider_OnValueChanged, dbKey = "LootUI_ItemsPerPage", tooltip = L["LootUI Option Items Per Page Tooltip"]},
		{type = "Slider", label = L["LootUI Option Background Opacity"], minValue = 0.0, maxValue = 1.0, valueStep = 0.1, onValueChangedFunc = Options_OpacitySlider_OnValueChanged,
			formatValueMethod = "Percentage", dbKey = "LootUI_BackgroundAlpha", tooltip = L["LootUI Option Background Opacity Tooltip"],
			onMouseDownFunc = Options_OpacitySlider_OnMouseDown, onMouseUpFunc = Options_OpacitySlider_OnMouseUp, onEnterFunc = Options_OpacitySlider_OnMouseDown, onLeaveFunc = Options_OpacitySlider_OnMouseUp},
		{type = "Checkbox", label = L["LootUI Option Owned Count"], onClickFunc = nil, dbKey = "LootUI_ShowItemCount"},
		{type = "Checkbox", label = L["LootUI Option New Transmog"], onClickFunc = nil, dbKey = "LootUI_NewTransmogIcon", tooltip = L["LootUI Option New Transmog Tooltip"]:format("|TInterface/AddOns/Plumber/Art/LootUI/NewTransmogIcon:0:0|t"), validityCheckFunc = Validation_TransmogInvented},
		{type = "Checkbox", label = L["LootUI Option Custom Quality Color"], tooltip = L["LootUI Option Custom Quality Color Tooltip"], onClickFunc = nil, dbKey = "LootUI_UseCustomColor", validityCheckFunc = function() return ColorManager and ColorManager.GetColorDataForItemQuality ~= nil end},
		{type = "Checkbox", label = L["LootUI Option Grow Direction"], tooltip = Tooltip_GrowDirection, onClickFunc = Options_GrowDirection_OnClick, dbKey = "LootUI_GrowUpwards", keepTooltipAfterClicks = true},
		{type = "Checkbox", label = L["LootUI Option Combine Items"], tooltip = L["LootUI Option Combine Items Tooltip"], onClickFunc = nil, dbKey = "LootUI_CombineItem"},
		{type = "Checkbox", label = L["LootUI Option Low Frame Strata"], tooltip = L["LootUI Option Low Frame Strata Tooltip"], onClickFunc = nil, dbKey = "LootUI_LowFrameStrata"},
		{type = "Checkbox", label = L["LootUI Option Hide Title"], tooltip = L["LootUI Option Hide Title Tooltip"], onClickFunc = nil, dbKey = "LootUI_HideTitle"},

		{type = "Divider"},
		{newFeature = true, type = "Checkbox", label = L["LootUI Option Show Reputation"], tooltip = Tooltip_ShowReputation, onClickFunc = nil, dbKey = "LootUI_ShowReputation", validityCheckFunc = Validation_IsRetail},
		{newFeature = true, type = "Checkbox", label = L["LootUI Option Show All Money"], tooltip = L["LootUI Option Show All Money Tooltip"], onClickFunc = nil, dbKey = "LootUI_ShowAllMoneyChange"},
		{newFeature = true, type = "Checkbox", label = L["LootUI Option Show All Currency"], tooltip = L["LootUI Option Show All Currency Tooltip"], onClickFunc = nil, dbKey = "LootUI_ShowAllCurrencyChange"},
		{type = "Checkbox", label = L["LootUI Option Replace Default"], onClickFunc = nil, dbKey = "LootUI_ReplaceDefaultAlert", tooltip = L["LootUI Option Replace Default Tooltip"], validityCheckFunc = Validation_IsRetail},

		{type = "Divider"},
		{type = "Checkbox", label = L["LootUI Option Force Auto Loot"], onClickFunc = nil, validityCheckFunc = Options_ForceAutoLoot_ValidityCheck, dbKey = "LootUI_ForceAutoLoot", tooltip = L["LootUI Option Force Auto Loot Tooltip"], tooltip2 = Tooltip_ManualLootInstruction},
		{type = "Checkbox", label = L["LootUI Option Loot Under Mouse"], onClickFunc = nil, dbKey = "LootUI_LootUnderMouse", tooltip = L["LootUI Option Loot Under Mouse Tooltip"]},
		{type = "Checkbox", label = L["LootUI Option Use Hotkey"], onClickFunc = nil, dbKey = "LootUI_UseHotkey", tooltip = L["LootUI Option Use Hotkey Tooltip"]},
		{type = "Keybind", label = L["Take All"], dbKey = "LootUI_HotkeyName", tooltip = L["LootUI Option Use Hotkey Tooltip"], defaultKey = "E"},

		{type = "Divider"},
		{type = "Checkbox", label = L["LootUI Option Use Default UI"], onClickFunc = nil, dbKey = "LootUI_UseStockUI", tooltip = L["LootUI Option Use Default UI Tooltip"], tooltip2 = Tooltip_ManualLootInstruction},
		{type = "Checkbox", label = L["LootUI Option Hide Window"], onClickFunc = nil, dbKey = "LootUI_WindowHide", tooltip = L["LootUI Option Hide Window Tooltip"], tooltip2 = Tooltip_HideWindow},

		{type = "Divider"},
		{type = "UIPanelButton", label = L["Reset To Default Position"], onClickFunc = Options_ResetPosition_OnClick, stateCheckFunc = Options_ResetPosition_ShouldEnable, widgetKey = "ResetButton"},
	}
};

function MainFrame:ShowOptions(state)
	if state then
		local forceUpdate = true;
		self.OptionFrame = addon.SetupSettingsDialog(self, OPTIONS_SCHEMATIC, forceUpdate);
		self.OptionFrame:Show();
		if self.OptionFrame.requireResetPosition then
			self.OptionFrame.requireResetPosition = false;
			self.OptionFrame:ClearAllPoints();
			local top = self:GetTop();
			local left = self:GetLeft();
			self.OptionFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left + 288, top + 64);
		end
	else
		if self.OptionFrame then
			self.OptionFrame:HideOption(self);
		end

		if not API.IsInEditMode() then
			self:Hide();
		end
	end
end

function MainFrame:OnDragStart()
	self:SetMovable(true);
	self:SetDontSavePosition(true);
	self:StartMoving();
end

function MainFrame:OnDragStop()
	local DB = PlumberDB;
	self:StopMovingOrSizing();

	local left = self:GetLeft();
	local top = DB.LootUI_GrowUpwards and self:GetBottom() or self:GetTop();

	left = API.Round(left);
	top = API.Round(top);

	--Convert anchor and save position
	DB.LootUI_PositionX = left;
	DB.LootUI_PositionY = top;

	self:LoadPosition();

	if self.OptionFrame and self.OptionFrame:IsOwner(self) then
		local button = self.OptionFrame:FindWidget("ResetButton");
		if button then
			button:Enable();
		end
	end
end

function MainFrame:UpdateSampleItems()
	if self:IsShown() and self.inEditMode then
		self:ShowSampleItems();
	end
end


-- Callback Registery
local function SettingChanged_ShowItemCount(state, userInput)
	Def.SHOW_ITEM_COUNT = state;
	if userInput then
		MainFrame:UpdateSampleItems();
	end
end
CallbackRegistry:RegisterSettingCallback("LootUI_ShowItemCount", SettingChanged_ShowItemCount);

local function SettingChanged_FadeDelayPerItem(value, userInput)
	Def.FADE_DELAY_PER_ITEM = GetValidFadeOutDelayPerItem(value);
end
CallbackRegistry:RegisterSettingCallback("LootUI_FadeDelayPerItem", SettingChanged_FadeDelayPerItem);

local function SettingChanged_ItemsPerPage(value, userInput)
	Def.MAX_ITEM_PER_PAGE = GetValidItemsPerPage(value);
end
CallbackRegistry:RegisterSettingCallback("LootUI_ItemsPerPage", SettingChanged_ItemsPerPage);

local function SettingChanged_BackgroundAlpha(value, userInput)
	Options_OpacitySlider_OnValueChanged(value or 0.5);
end
CallbackRegistry:RegisterSettingCallback("LootUI_BackgroundAlpha", SettingChanged_BackgroundAlpha);

local function SettingChanged_ReplaceDefaultAlert(state, userInput)
	if state and addon.GetDBBool("LootUI") and not addon.GetDBBool("LootUI_UseStockUI") then
		EventListeners.Primary:ListenAlertSystemEvent(true);
	else
		EventListeners.Primary:ListenAlertSystemEvent(false);
	end
end
CallbackRegistry:RegisterSettingCallback("LootUI_ReplaceDefaultAlert", SettingChanged_ReplaceDefaultAlert);

local function SettingChanged_LootUI_ForceAutoLoot(state, userInput)
	Def.FORCE_AUTO_LOOT = state;
end
CallbackRegistry:RegisterSettingCallback("LootUI_ForceAutoLoot", SettingChanged_LootUI_ForceAutoLoot);

local function SettingChanged_LootUnderMouse(state, userInput)
	Def.LOOT_UNDER_MOUSE = state;
	if userInput then
		if not Def.LOOT_UNDER_MOUSE then
			MainFrame:LoadPosition();
		end
	end
end
CallbackRegistry:RegisterSettingCallback("LootUI_LootUnderMouse", SettingChanged_LootUnderMouse);

local function SettingChanged_CombineItems(state, userInput)
	Def.MERGE_SIMILAR_ITEMS = state;
end
CallbackRegistry:RegisterSettingCallback("LootUI_CombineItem", SettingChanged_CombineItems);

local function SettingChanged_LowFrameStrata(state, userInput)
	Def.LOW_FRAME_STRATA = state;
end
CallbackRegistry:RegisterSettingCallback("LootUI_LowFrameStrata", SettingChanged_LowFrameStrata);

local function SettingChanged_WindowDisabled(state, userInput)
	Def.HIDE_PLUMBER_LOOT_UI = state;
end
CallbackRegistry:RegisterSettingCallback("LootUI_WindowHide", SettingChanged_WindowDisabled);

local function SettingChanged_ShowAllMoneyChange(state, userInput)
	Def.SHOW_ALL_MONEY_CHANGE = state;
	EventListeners.MoneyListener:OnSettingsChanged();
end
CallbackRegistry:RegisterSettingCallback("LootUI_ShowAllMoneyChange", SettingChanged_ShowAllMoneyChange);

local function SettingChanged_ShowAllCurrencyChange(state, userInput)
	Def.SHOW_ALL_CURRENCY_CHANGE = state;
end
CallbackRegistry:RegisterSettingCallback("LootUI_ShowAllCurrencyChange", SettingChanged_ShowAllCurrencyChange);

local function SettingChanged_NewTransmogIcon(state, userInput)
	Def.USE_MOG_MARKER = state;
end
addon.CallbackRegistry:RegisterSettingCallback("LootUI_NewTransmogIcon", SettingChanged_NewTransmogIcon);

local function SettingChanged_UseHotkey(state, userInput)
	Def.USE_HOTKEY = state;
	if userInput then
		local button = MainFrame.TakeAllButton;
		if button then
			button:UpdateHotKey();
		end
	end
end
addon.CallbackRegistry:RegisterSettingCallback("LootUI_UseHotkey", SettingChanged_UseHotkey);

local function SettingChanged_HotkeyName(value, userInput)
	if not (value and type("value") == "string") then
		value = nil;
	end
	Def.TAKE_ALL_KEY = value;
	if API.GetModifierKeyName(value) ~= nil then
		Def.TAKE_ALL_MODIFIER_KEY = value;
	else
		Def.TAKE_ALL_MODIFIER_KEY = nil;
	end

	if userInput then
		local button = MainFrame.TakeAllButton;
		if button then
			button:UpdateHotKey();
		end
	end
end
addon.CallbackRegistry:RegisterSettingCallback("LootUI_HotkeyName", SettingChanged_HotkeyName);

local function SettingChanged_UseCustomColor(state, userInput)
	if state and ColorManager.GetColorDataForItemQuality then
		LootUI.QualityColorGetter = ColorManager.GetColorDataForItemQuality;
	else
		LootUI.QualityColorGetter = API.GetItemQualityColor;
	end
	if userInput then
		MainFrame:UpdateSampleItems();
	end
end
addon.CallbackRegistry:RegisterSettingCallback("LootUI_UseCustomColor", SettingChanged_UseCustomColor);
