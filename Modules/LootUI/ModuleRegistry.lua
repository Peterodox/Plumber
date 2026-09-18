local _, addon = ...
local L = addon.L;
local LootUI = addon.LootUI; ---@class LootUISystem
local Def = LootUI.Defination;
local MainFrame = LootUI.MainFrame;
local EventListeners = LootUI.EventListeners;


local ENABLE_MODULE = false;
local STOCK_UI_MUTED = false;


local function SettingChanged_UseStockUI(state, userInput)
	Def.USE_STOCK_UI = state == true;
	local f = LootFrame;
	if Def.USE_STOCK_UI then
		if f then
			if STOCK_UI_MUTED then
				STOCK_UI_MUTED = false;
				if not C_AddOns.IsAddOnLoaded("Xloot") then
					f:RegisterEvent("LOOT_OPENED");
					f:RegisterEvent("LOOT_CLOSED");
				end
			end
		end

		if not MainFrame.inEditMode then
			MainFrame:Disable();
		end

		EventListeners.Primary:ListenAlertSystemEvent(false);
	else
		if addon.GetDBBool("LootUI") then
			if f then
				if not STOCK_UI_MUTED then
					STOCK_UI_MUTED = true;
					f:UnregisterEvent("LOOT_OPENED");
					f:UnregisterEvent("LOOT_CLOSED");
				end
			end

			if addon.GetDBBool("LootUI_ReplaceDefaultAlert") then
				EventListeners.Primary:ListenAlertSystemEvent(true);
			end
		end
	end
end
addon.CallbackRegistry:RegisterSettingCallback("LootUI_UseStockUI", SettingChanged_UseStockUI);

local function EnableModule(state)
	if state then
		ENABLE_MODULE = true;

		EventListeners:Enable();

		if MainFrame.Init then
			MainFrame:Init();
		end

		MainFrame:OnUIScaleChanged();

		if addon.GetDBBool("LootUI_UseStockUI") then
			SettingChanged_UseStockUI(true);
		else
			SettingChanged_UseStockUI(false);
		end

	elseif ENABLE_MODULE then
		ENABLE_MODULE = false;

		EventListeners:Dsiable();
		MainFrame:Disable();
		SettingChanged_UseStockUI(true);
	end
end

local function EnterEditMode()
	MainFrame:EnterEditMode();
end

local function ExitEditMode()
	MainFrame:ExitEditMode();
end

local function OptionToggle_OnClick(self, button)
	if MainFrame.OptionFrame and MainFrame.OptionFrame:IsShown() and (MainFrame.OptionFrame:IsOwner(self) or MainFrame.OptionFrame:IsOwner(MainFrame)) then
		ExitEditMode();
	else
		EnterEditMode();
	end
end

local function GetModuleConflictWarning()
	local names = {
		"SpeedyAutoLoot", "XLoot",
	};

	local name;

	for _, addonName in ipairs(names) do
		if C_AddOns.IsAddOnLoaded(addonName) then
			name = addonName;
			break
		end
	end

	if LeaPlusDB and LeaPlusDB.FasterLooting == "On" then
		name = "Leatrix Plus: Faster auto loot";
	end

	if name then
		return string.format("|cffd4641c%s\n\n- %s|r", L["Generic Addon Conflict"], name);
	end
end

local moduleData = {
	name = L["ModuleName LootUI"],
	dbKey = "LootUI",
	description = L["ModuleDescription LootUI"],
	descriptionFunc = GetModuleConflictWarning,
	toggleFunc = EnableModule,
	categoryID = 1,
	uiOrder = 0,
	moduleAddedTime = 1727793830,
	optionToggleFunc = OptionToggle_OnClick,
	hasMovableWidget = true,
	visibleInEditMode = true,
	enterEditMode = EnterEditMode,
	exitEditMode = ExitEditMode,
	categoryKeys = {
		"Signature", "Loot",
	},
};

addon.ControlCenter:AddModule(moduleData);
