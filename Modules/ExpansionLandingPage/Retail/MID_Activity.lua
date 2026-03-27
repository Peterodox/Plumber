local _, addon = ...
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;
local ActivityUtil = addon.ActivityUtil;

--C_QuestLog.GetActivePreyQuest()
--/dump C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(7515).barValue
--C_AreaPoiInfo.GetEventsForMap(2537)
--Abun Harandar 8676
--C_AreaPoiInfo.GetEventsForMap(2537)


local AbundantHarvest = {
	poiMap = {
		--On Quel'Thalas map
		--[poiID] = uiMapID
		[8672] = 2395,     --Eversong Enchanting Crypt
		[8671] = 2437,     --Zul'Aman Skinning Den
		[8676] = 2413,     --Harandar Herbalism Grotto
		[8675] = 2405,     --Voidstorm Voidburrow
	},

	continentUiMapID = 2537,
	ticketCurrency = 3376,      --Shard of Dundun
};

local DelvesBonusRepQuestFlags = {
	{questID = 93821, factionID = 2710, accountwide = true},	--Silvermoon
	{questID = 93819, factionID = 2696, accountwide = true},	--Amani
	{questID = 93822, factionID = 2704, accountwide = true},	--Harandar
	{questID = 93820, factionID = 2699, accountwide = true},	--Singularity
};


local GildedStashTracker = {};
do
	GildedStashTracker.spellID = 1216211;
	GildedStashTracker.widgetID = 7591;
	GildedStashTracker.getter = C_UIWidgetManager.GetSpellDisplayVisualizationInfo;
	--/dump C_UIWidgetManager.GetSpellDisplayVisualizationInfo(7591)

	function GildedStashTracker:GetCrestStashTooltip()
		local info = self.getter(self.widgetID);
		if info then
			if info.spellInfo and info.spellInfo.spellID == self.spellID then
				return info.spellInfo.tooltip, info.spellInfo.shownState == 1;
			end
		end
	end

	function GildedStashTracker:GetCrestStashProgess()
		local sourceText, isAccurate = self:GetCrestStashTooltip();
		if sourceText then
			local current, max = string.match(sourceText, "(%d+)/(%d+)");
			if current and max then
				current = tonumber(current);
				max = tonumber(max);
				if max > 0 then
					return current, max, isAccurate;
				end
			end
		end
	end

	function GildedStashTracker:CacheName()
		local name = C_Spell.GetSpellName(self.spellID);
		if name and name ~= "" then
			self.localizedSpellName = name;
		else
			addon.CallbackRegistry:LoadSpell(self.spellID, function()
				self.localizedSpellName = C_Spell.GetSpellName(self.spellID);
			end);
		end
	end
	addon.CallbackRegistry:Register("DBLoaded", GildedStashTracker.CacheName, GildedStashTracker);

	function GildedStashTracker:GetName()
		if not self.localizedSpellName then
			self:CacheName();
		end
		return self.localizedSpellName or "";
	end

	function GildedStashTracker.IsActivityCompleted()
		local current, max = GildedStashTracker:GetCrestStashProgess();
		return current and max and current >= max;
	end
end


local SetupFuncs = {};
do
	local WIDGET_TYPE = 2;

	local PROGRESS_FORMAT = "%s: %s/%s";

	--[[
	function YeetPreyWidget()
		local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(1843);
		local progressText;
		if widgets then
			for _, widget in ipairs(widgets) do
				if widget.widgetType == WIDGET_TYPE then
					local info = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widget.widgetID);
					if info and info.text and info.barValue and info.barMax then
						progressText = PROGRESS_FORMAT:format(info.text, info.barValue, info.barMax);
						print(widget.widgetID, progressText)
					end
				end
			end
		end
	end
	--]]

	function SetupFuncs.HuntTable(listButton)
		local activeQuestID = C_QuestLog.GetActivePreyQuest();
		if activeQuestID then
			listButton:SetQuest(activeQuestID);
			listButton.flagQuest = activeQuestID;
			listButton.completed = C_QuestLog.IsQuestFlaggedCompleted(activeQuestID);
			return
		end

		local progressText;
		local activeWidgetFound = false;
		local widgetSetID = 1843;
		local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID);
		if widgets then
			for _, widget in ipairs(widgets) do
				--debug
				--[[
				local widgetTypeName;
				for k, v in pairs(Enum.UIWidgetVisualizationType) do
					if widget.widgetType == v then
						widgetTypeName = k;
						break
					end
				end
				print(widget.widgetID, widget.widgetType, widgetTypeName);
				--]]

				if widget.widgetType == WIDGET_TYPE then
					local info = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widget.widgetID);
					if info and (not progressText) and info.text and info.barValue and info.barMax then
						progressText = PROGRESS_FORMAT:format(info.text, info.barValue, info.barMax);
						if info.shownState == 1 then
							activeWidgetFound = true;
						end
					end
					if (not activeWidgetFound) and info and info.shownState == 1 then
						progressText = PROGRESS_FORMAT:format(info.text, info.barValue, info.barMax);
						activeWidgetFound = true;
						break
					end
				end
			end
		end

		if progressText then
			if not activeWidgetFound then
				progressText = "*"..progressText;
			end
		else
			progressText = L["Prey No Data"];
		end

		listButton.Name:SetText(progressText);
	end

	function SetupFuncs.GetPreyHeader()
		local mapName;
		local activeQuestID = C_QuestLog.GetActivePreyQuest();
		if activeQuestID then
			local uiMapID = GetQuestUiMapID(activeQuestID);
			if uiMapID then
				mapName = addon.API.GetMapName(uiMapID);
			end
		end

		if mapName then
			return L["Prey System"].." - "..mapName
		else
			return L["Prey System"]
		end
	end


	local PreyTargetQuests = {
		Normal = {},
		Hard = {},
		Nightmare = {},
	};

	function SetupFuncs.BuildPreyTargetQuests()
		local tinsert = table.insert;
		local tbl;
		for questID, info in pairs(addon.PreyQuestData) do
			if info[1] == 1 then
				tbl = PreyTargetQuests.Normal;
			elseif info[1] == 2 then
				tbl = PreyTargetQuests.Hard;
			elseif info[1] == 3 then
				tbl = PreyTargetQuests.Nightmare;
			end
			tinsert(tbl, questID);
		end
	end


	local function GetUnlockedPreyDifficulties()
		local level = C_MajorFactions.GetCurrentRenownLevel(2764);
		if level then
			if level >= 4 then
				return {"Nightmare", "Hard", "Normal"}
			elseif level >= 1 then
				return {"Hard", "Normal"}
			end
		end
		return {"Normal"}
	end

	function SetupFuncs.KillCount(listButton)
		local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted;
		local difficulties = GetUnlockedPreyDifficulties();
		local text;

		for _, k in ipairs(difficulties) do
			local difficultyName = L["Prey Difficulty "..k];
			local numCompleted = 0;
			for _, questID in ipairs(PreyTargetQuests[k]) do
				if IsQuestFlaggedCompleted(questID) then
					numCompleted = numCompleted + 1;
				end
			end

			local progressText = string.format("|W%s/4 %s|w", numCompleted, difficultyName);
			if text then
				text = text.."    "..progressText;
			else
				text = progressText;
			end
		end

		listButton.Name:SetText(text);
	end

	function SetupFuncs.DefeatedPreyTooltip(tooltip)
		local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted;
		local GetQuestName = addon.API.GetQuestName;
		local difficulties = GetUnlockedPreyDifficulties();
		local loaded = true;

		for _, k in ipairs(difficulties) do
			local difficultyName = L["Prey Difficulty "..k];
			local anyComplete;

			tooltip:AddLine(" ");
			tooltip:AddLine(difficultyName, 1, 0.82, 0, false);

			for _, questID in ipairs(PreyTargetQuests[k]) do
				if IsQuestFlaggedCompleted(questID) then
					anyComplete = true;
					local questName = GetQuestName(questID);
					if questName then
						tooltip:AddLine("|TInterface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/CheckmarkGrey:0:0|t "..questName, 0.5, 0.5, 0.5, false);
					else
						loaded = false;
					end
				end
			end

			if not anyComplete then
				tooltip:AddLine(NONE, 0.5, 0.5, 0.5, false);
			end
		end

		return loaded
	end


	local function GetActiveAbundance()
		local pois = C_AreaPoiInfo.GetEventsForMap(AbundantHarvest.continentUiMapID);
		if pois then
			for _, poiID in ipairs(pois) do
				if AbundantHarvest.poiMap[poiID] then
					return poiID, AbundantHarvest.poiMap[poiID]
				end
			end
		end
	end

	function SetupFuncs.ShouldShowAbundance()
		return GetActiveAbundance() ~= nil
	end

	function SetupFuncs.AbundanceEvent(listButton)
		local activePoiID, activeUiMapID = GetActiveAbundance();

		if activePoiID then
			local info = C_AreaPoiInfo.GetAreaPOIInfo(AbundantHarvest.continentUiMapID, activePoiID);
			local mapName = addon.API.GetMapName(activeUiMapID);
			listButton.Name:SetText(mapName.." "..info.name);
			listButton.tooltipWidgetSet = info.tooltipWidgetSet;
		else
			--Normally it won't come to this
			listButton.Name:SetText(L["Abundance No Data"]);
		end
	end

	function SetupFuncs.AbundanceTooltip(tooltip)
		local loaded, keepUpdating = true, false;
		local activePoiID, activeUiMapID = GetActiveAbundance();

		if activePoiID then
			local info = C_AreaPoiInfo.GetAreaPOIInfo(AbundantHarvest.continentUiMapID, activePoiID);
			if info.tooltipWidgetSet then
				local anyChange, isRetrievingData = addon.API.AddWidgetSetToTooltip(tooltip, info.tooltipWidgetSet);
				if anyChange and isRetrievingData then
					keepUpdating = true;
				end
				return loaded, keepUpdating
			end
		end

		tooltip:AddLine(L["Abundance No Data"], 0.5, 0.5, 0.5, false);

		return loaded, keepUpdating
	end


	function SetupFuncs.WeeklyBonusRenown(tooltip)
		ActivityUtil.TooltipFuncs.WeeklyBonusRenown(tooltip, DelvesBonusRepQuestFlags);
		return true
	end


	function SetupFuncs.GildedStashEntry(listButton)
		local name = GildedStashTracker:GetName();
		local current, max, isAccurate = GildedStashTracker:GetCrestStashProgess();
		if not (current and max) then
			current, max = "?", 4;
		else
			listButton.completed = current >= max;
		end
		listButton.Name:SetText(string.format("%s/%s %s", current, max, name));
	end

	function SetupFuncs.GildedStashTooltip(tooltip)
		local description, isAccurate = GildedStashTracker:GetCrestStashTooltip();
		if description then
			tooltip:AddLine(L["Delve Crest Stash Requirement"], 1, 1, 1, true);
			tooltip:AddLine(" ");
			tooltip:AddLine(description, 1, 0.82, 0, true);
			if not isAccurate then
				tooltip:AddLine(" ");
				tooltip:AddLine(L["Delve Crest Stash Old Data"], 0.5, 0.5, 0.5, true);
			end
		else
			tooltip:AddLine(L["Delve Crest Stash No Info"], 1, 0.1, 0.1, true);
		end
		return true;
	end
end


local ActivityData = {
		--Enable After S1
	{isHeader = true, name = "Delves", localizedName = DELVES_LABEL, categoryID = 10000,
		entries = {
			{name = "A Gnawing Void of Curiosity", questID = 93784, isWeeklyQuest = true, accountwide = true},
			{name = "Trovehunter\'s Bounty", itemID = 252415, flagQuest = 86371, icon = 1064187, tooltipItem = 252415},
			{name = "Coffer Key Shard", currencyID = 3310, icon = 133016, removeIconBorder = true},
			{name = "Bonus Renowns", label = L["Bountiful Delves Rep Label"], icon = 3726261, tooltipSetter = SetupFuncs.WeeklyBonusRenown, children = DelvesBonusRepQuestFlags},
			{name = "Gilded Stash", icon = 5872049, removeIconBorder = true, setupFunc = SetupFuncs.GildedStashEntry, tooltipSetter = SetupFuncs.GildedStashTooltip, conditions = GildedStashTracker},

			--{name = "Coffer Keys", label = L["Restored Coffer Key"], questClassification = 5, tooltipSetter = ActivityUtil.TooltipFuncs.WeeklyRestoredCofferKey, icon = 4622270, removeIconBorder = true,
			--    children = ActivityUtil.CreateChildrenFromQuestList(addon.WeeklyRewardsConstant.CofferKeyFlags),
			--},

			--{name = "Coffer Key Shards", label = L["Coffer Key Shard"], questClassification = 5, tooltipSetter = ActivityUtil.TooltipFuncs.WeeklyCofferKeyShard, icon = 133016, removeIconBorder = true,
			--    children = ActivityUtil.CreateChildrenFromQuestList(addon.WeeklyRewardsConstant.CofferKeyShardFlags),
			--},
		},
	},

	{isHeader = true, name = "Prey", localizedName = L["Prey System"], categoryID = 120000, nameGetter = SetupFuncs.GetPreyHeader,
		entries = {
			{name = "Kill Count", icon = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/Checklist.png", sortToTop = true, setupFunc = SetupFuncs.KillCount, tooltipHeader = L["Defeated Prey"], tooltipSetter = SetupFuncs.DefeatedPreyTooltip},
			{name = "Hunt Table", icon = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressPrey.png", sortToTop = true, setupFunc = SetupFuncs.HuntTable, removeSharedPrefix = true},
		},
	},

	{isHeader = true, name = "Silvermoon Court", factionID = 2710, categoryID = 2710, uiMapID = 2395,
		entries = {
			{name = "Favor of the Court", questID = 89289, isWeeklyQuest = true, uiMapID = 2395, sortToTop = true},
			{name = L["QuestName Runestone"], localizedName = L["QuestName Runestone"], isWeeklyQuest = true, uiMapID = 2395, sortToTop = true, useActiveQuestTitle = true,
				questPool = {
					{name = "Fortify the Runestones: Magisters", questID = 90573, isWeeklyQuest = true, uiMapID = 2395},
					{name = "Fortify the Runestones: Blood Knights", questID = 90574, isWeeklyQuest = true, uiMapID = 2395},
					{name = "Fortify the Runestones: Farstriders", questID = 90575, isWeeklyQuest = true, uiMapID = 2395},
					{name = "Fortify the Runestones: Shades of the Row", questID = 90576, isWeeklyQuest = true, uiMapID = 2395},
				},
			},
			{name = "Saltheril\'s Favor", itemID = 238987, icon = 237281, removeIconBorder = true, tooltipItem = 238987, uiMapID = 2395, shownIfOwned = true, tooltip = L["Item Expire Alert Weekly"]},
		},
		questLines = {5841},
	},

	{isHeader = true, name = "Amani Tribe", factionID = 2696, categoryID = 2696, uiMapID = 2437,
		entries = {
			{name = "Abundant Offerings", questID = 89507, isWeeklyQuest = true, sortToTop = true},
			{name = "Abundance", icon = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/Abundance.png", shouldShow = SetupFuncs.ShouldShowAbundance, setupFunc = SetupFuncs.AbundanceEvent, tooltipSetter = SetupFuncs.AbundanceTooltip},
		},
	},

	{isHeader = true, name = "Harandar", factionID = 2704, categoryID = 2704, uiMapID = 2413,
		entries = {
			{name = "Lost Legends", questID = 89268, isWeeklyQuest = true, uiMapID = 2413, sortToTop = true},

			--{name = L["QuestName HarandarRelic"], localizedName = L["QuestName HarandarRelic"], isWeeklyQuest = true, uiMapID = 2413, sortToTop = true, useActiveQuestTitle = true,
			--	questPool = {
					{name = "Wey'nan's Ward", questID = 88993, isWeeklyQuest = true, uiMapID = 2413, shownIfOnQuest = true},
					{name = "The Cauldron of Echoes", questID = 88994, isWeeklyQuest = true, uiMapID = 2413, shownIfOnQuest = true},
					{name = "The Echoless Flame", questID = 88996, isWeeklyQuest = true, uiMapID = 2413, shownIfOnQuest = true},
					{name = "Russula's Outreach", questID = 88997, isWeeklyQuest = true, uiMapID = 2413, shownIfOnQuest = true},
					{name = "Aln'hara's Bloom", questID = 88995, isWeeklyQuest = true, uiMapID = 2413, shownIfOnQuest = true},
			--	},
			--},

			{name = "WANTED: Dionaea's Thorntusks", questID = 92013, uiMapID = 2413, shownIfActive = true},
			{name = "WANTED: Gelatonius", questID = 91970, uiMapID = 2413, shownIfActive = true},
			{name = "WANTED: Gorebarb's Pincers", questID = 92012, uiMapID = 2413, shownIfActive = true},
			{name = "WANTED: Hellebora's Thorn", questID = 91980, uiMapID = 2413, shownIfActive = true},
			{name = "WANTED: Muckmire's Choking Vines", questID = 91998, uiMapID = 2413, shownIfActive = true},
			{name = "WANTED: Slewstalk's Stalks", questID = 92010, uiMapID = 2413, shownIfActive = true},
			{name = "WANTED: Toadshade's Petals", questID = 91982, uiMapID = 2413, shownIfActive = true},
		},
	},

	{isHeader = true, name = "The Singularity", factionID = 2699, categoryID = 2699, uiMapID = 2405,
		entries = {
			{name = "Stormarion Assault", isWeeklyQuest = true, questID = 90962, uiMapID = 2405, sortToTop = true}, --This Weekly World Quest seems to only appear on the map when you are in the surrounding area
			{name = "Stand Your Ground", questID = 94581, uiMapID = 2405, shownIfOnQuest = true},    --Replace the quest above after completion

			--The following quests reward no rep but Stormarion Core
			{name = "Darkness Unmade", questID = 91700, uiMapID = 2405, shownIfOnQuest = true},  --Kill 2 Rare creatures
			{name = "Harvesting the Void", questID = 86810, uiMapID = 2405, shownIfOnQuest = true},
			{name = "Hidey-Hole", questID = 92407, uiMapID = 2405, shownIfOnQuest = true},
		},
	},

	{isHeader = true, name = "Slayer's Duellum", factionID = 2770, categoryID = 2770, uiMapID = 2444,
		entries = {
			{name = "Preparing for Battle", questID = 89354, isWeeklyQuest = true, uiMapID = 2444, sortToTop = true},
		},
	},
};

local function GetActivityEntries(categoryID)
	for k, v in ipairs(ActivityData) do
		if v.categoryID == categoryID then
			return v.entries
		end
	end
end


do  --Add Prey Quests
	local PreyWorldQuests = {
		--C_QuestLine.GetQuestLineQuests(5954)
		91458,
		91523,
		91590,
		91591,
		91592,
		91594,
		91595,
		91596,
		91207,
		91601,
		91602,
		91604,
	};

	local target = GetActivityEntries(120000);
	local n = #target;

	for _, questID in ipairs(PreyWorldQuests) do
		n = n + 1;
		target[n] = {
			name = L["Prey System"],
			questID = questID,
			shownIfActive = true,
			removeSharedPrefix = true,
		};
	end

	SetupFuncs.BuildPreyTargetQuests();
end


LandingPageUtil.AddExpansionData(12, "activity", ActivityData);


local DynamicQuestMaps = {
	[2393] = "map2393",     --Silvermoon
	--[2413] = "map2413",     --Harandar
};
LandingPageUtil.AddExpansionData(12, "activityQuestMap", DynamicQuestMaps);
