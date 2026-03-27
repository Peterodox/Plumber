local _, addon = ...
local L = addon.L;
local FormatLabelAndText = addon.API.FormatLabelAndText;


local MODULE_ENABLED = false;

local PreyTargetListAchivements = {42701, 42702, 42703};

local PreyQuestData = addon.PreyQuestData;

local Def = {
	IconSize = 48,
	DifficultyIcon = "Interface/AddOns/Plumber/Art/MapPin/PreyQuestDifficulty.png",
	Difficulty1 = L["Prey Difficulty Normal"],
	Difficulty2 = L["Prey Difficulty Hard"],
	Difficulty3 = L["Prey Difficulty Nightmare"],
};


local GetAchievementCriteriaInfoByID = GetAchievementCriteriaInfoByID;
local EnumeratePins;
local ModifiedPins = {};


local function SetupIcon(pin, method, ...)
	pin.Icon[method](pin.Icon, ...)
	pin.IconHighlight[method](pin.IconHighlight, ...)
end

local function SetupPin(pin)
	if not MODULE_ENABLED then return; end

	local questID = pin.questID;

	if questID and PreyQuestData[questID] then
		local difficulty, criteriaID = PreyQuestData[questID][1], PreyQuestData[questID][2];
		local _, _, completed = GetAchievementCriteriaInfoByID(PreyTargetListAchivements[difficulty], criteriaID);

		local l, r, t, b;

		if completed == nil or completed then
			t, b = 0, 0.25;
		else
			t, b = 0.25, 0.5;
		end

		if difficulty == 1 then
			l, r = 0, 0.25;
		elseif difficulty == 2 then
			l, r = 0.25, 0.5;
		else
			l, r = 0.5, 0.75;
		end

		SetupIcon(pin, "SetTexture", Def.DifficultyIcon);
		SetupIcon(pin, "SetTexCoord", l, r, t, b);
		SetupIcon(pin, "SetSize", Def.IconSize, Def.IconSize);

		if not completed then
			pin.description = string.format("%s\n\n%s", FormatLabelAndText(LFG_LIST_DIFFICULTY, Def["Difficulty"..difficulty]), L["Prey Target Has Achievement"]);
		end

		ModifiedPins[pin] = true;
	end
end

local function ResetPinTexture(pin)
	SetupIcon(pin, "SetTexture", nil);
	SetupIcon(pin, "SetTexCoord", 0, 1, 0, 1);
	--SetupIcon(pin, "SetSize", Def.IconSize, Def.IconSize);
end

local function RestoreAllPins()
	for pin, changed in pairs(ModifiedPins) do
		if changed then
			ModifiedPins[pin] = nil;
			ResetPinTexture(pin);
		end
	end
end


local function Callback_RefreshAllData(dataProvider, fromOnShow)
	if fromOnShow then return; end

	for pin in EnumeratePins() do
		SetupPin(pin);
	end
end

--local function Callback_RemoveAllData(dataProvider)
--end

local function OnBlizzardUILoaded()
	if not Def.loaded then
		Def.loaded = true;
	else
		return;
	end

	local map = addon.API.GetGlobalObject("CovenantMissionFrame.MapTab");
	local dataProviders = map and map.dataProviders;
	local found;

	if dataProviders then
		for dataProvider in pairs(dataProviders) do
			if dataProvider.AddQuest and dataProvider.RefreshAllData and dataProvider.RemoveAllData then
				found = true;
				hooksecurefunc(dataProvider, "RefreshAllData", Callback_RefreshAllData);
				--hooksecurefunc(dataProvider, "RemoveAllData", Callback_RemoveAllData);

				function EnumeratePins()
					return map:EnumeratePinsByTemplate("AdventureMap_QuestOfferPinTemplate");
				end
			end
		end
	end

	if not found then
		error("Fail to find AdventureMap_QuestOfferDataProviderMixin in CovenantMissionFrame.MapTab.dataProviders");
	end
end


do
	local function EnableModule(state)
		if state and not MODULE_ENABLED then
			MODULE_ENABLED = true;
			addon.CallbackRegistry:RegisterAddOnLoadedCallback("Blizzard_GarrisonUI", OnBlizzardUILoaded);
		elseif (not state) and MODULE_ENABLED then
			MODULE_ENABLED = false;
			addon.CallbackRegistry:UnregisterAddOnLoadedCallback("Blizzard_GarrisonUI", OnBlizzardUILoaded);
			RestoreAllPins();
		end
	end

	local moduleData = {
		name = L["ModuleName HuntTable"],
		dbKey = "HuntTable",
		description = L["ModuleDescription HuntTable"],
		toggleFunc = EnableModule,
		moduleAddedTime = 1774400000,
		categoryKeys = {
			"Quest",
		},
	};

	addon.ControlCenter:AddModule(moduleData);
end
