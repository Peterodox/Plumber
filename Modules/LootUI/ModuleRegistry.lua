local _, addon = ...
local L = addon.L;
local LootUI = addon.LootUI; ---@class LootUISystem
local Def = LootUI.Defination;
local MainFrame = LootUI.MainFrame;
local EventListeners = LootUI.EventListeners;


local ENABLE_MODULE = false;
local STOCK_UI_MUTED = false;
local IS_RESOLVING_SYSTEM_STATUS = false;


local function ResolveSystemStatus()
	if addon.GetDBBool("LootUI") then
		ENABLE_MODULE = true;

		EventListeners:Enable();

		if MainFrame.Init then
			MainFrame:Init();
		end

		MainFrame:OnUIScaleChanged();

	else
		ENABLE_MODULE = false;

		EventListeners:Disable();
		MainFrame:Disable();
	end

	if ENABLE_MODULE then
		if not STOCK_UI_MUTED then
			STOCK_UI_MUTED = true;
			LootFrame:UnregisterEvent("LOOT_OPENED");
			LootFrame:UnregisterEvent("LOOT_CLOSED");
		end

		if addon.GetDBBool("LootUI_ReplaceDefaultAlert") then
			EventListeners.Primary:ListenAlertSystemEvent(true);
		else
			EventListeners.Primary:ListenAlertSystemEvent(false);
		end
	else
		if STOCK_UI_MUTED then
			STOCK_UI_MUTED = false;
			if not C_AddOns.IsAddOnLoaded("Xloot") then
				LootFrame:RegisterEvent("LOOT_OPENED");
				LootFrame:RegisterEvent("LOOT_CLOSED");
			end
		end

		if not MainFrame.inEditMode then
			MainFrame:Disable();
		end
	end

	LootUI.FastLoot:ResolveSystemStatus();
end

local function TryResolveSystemStatus()
	if not IS_RESOLVING_SYSTEM_STATUS then
		IS_RESOLVING_SYSTEM_STATUS = true;
		C_Timer.After(0, function()
			IS_RESOLVING_SYSTEM_STATUS = false;
			ResolveSystemStatus();
		end);
	end
end
LootUI.TryResolveSystemStatus = TryResolveSystemStatus;

local function SettingChanged_UseStockUI(state, userInput)
	TryResolveSystemStatus();
end
addon.CallbackRegistry:RegisterSettingCallback("LootUI_UseStockUI", SettingChanged_UseStockUI);

local function EnableModule(state)
	TryResolveSystemStatus();
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

local LootUI_ModuleData = {
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
	linkedReason = "LootFrame",
};
addon.ControlCenter:AddModule(LootUI_ModuleData);

local function FastLoot_GetOverrideState()
	if addon.GetDBBool("LootUI") then
		return true;
	end
end

local FastLoot_ModuleData = {
	name = L["ModuleName FastLoot"],
	dbKey = "FastLoot",
	description = L["ModuleDescription FastLoot"],
	descriptionFunc = GetModuleConflictWarning,
	toggleFunc = EnableModule,
	categoryID = 1,
	uiOrder = 0,
	moduleAddedTime = 1727793830,
	categoryKeys = {
		"Loot",
	},
	linkedReason = "LootFrame",
	getOverrideState = FastLoot_GetOverrideState;
};
addon.ControlCenter:AddModule(FastLoot_ModuleData);

-- FastLoot can now be enabled without LootUI.
-- For players who have enabled Plumber LootUI for the auto-loot fix but opted not to use our UI
-- enable the new FastLoot option and disable LootUI.
addon.CallbackRegistry:Register("DBPreload", function(db)
	if db.FastLoot == nil and db.LootUI then
		if db.LootUI_UseStockUI or db.LootUI_WindowHide then
			db.LootUI = false;
			db.FastLoot = true;
		end
	end
end);
