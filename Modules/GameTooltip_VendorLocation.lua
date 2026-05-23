-- Kudos to gifLeo (https://github.com/Peterodox/Plumber/issues/426)


local _, addon = ...
local L = addon.L;
local API = addon.API;
local GameTooltipItemManager = addon.GameTooltipManager:GetItemManager();


local SubModule = GameTooltipItemManager:CreateSubModule("TooltipVendorLocation");
local ItemData = {};
local CurrencyData = {};

do
	local CONTENT_TRACKING_ATLAS = "|A:waypoint-mappin-minimap-untracked:16:16:-3:0|a";
	local WARDROBE_TOOLTIP_CYCLE_ARROW_ICON = "|TInterface\\Transmogrify\\transmog-tooltip-arrow:12:11:-1:-1|t";
	local WARDROBE_TOOLTIP_CYCLE_SPACER_ICON = "|TInterface\\Common\\spacer:12:11:-1:-1|t";

	local function AppendName(tooltip, data, isSelected)
		local text;
		local mapName = API.GetMapName(data.uiMapID);
		if data.localizedName then
			if data.area then
				mapName = API.GetZoneName(data.area);
			end
			text = L["NPC Name Location Format"]:format(data.localizedName, mapName);
		elseif data.npc then
			local allowSecret = true;
			local npcName = API.GetAndCacheCreatureName(data.npc, allowSecret) or data.name or string.format("NPC:%s", data.npc);
			text = L["NPC Name Location Format"]:format(npcName, mapName);
		elseif data.area then
			local areaName = API.GetZoneName(data.area);
			text = L["NPC Name Location Format"]:format(areaName, mapName);
		end

		if text then
			if data.label then
				text = data.label..L["Colon With Space"]..text;
			end

			if isSelected == nil then
				tooltip:AddLine(text, 1, 0.82, 0, true);
			else
				if isSelected then
					tooltip:AddLine(WARDROBE_TOOLTIP_CYCLE_ARROW_ICON..text, 1, 0.82, 0, false);
				else
					tooltip:AddLine(WARDROBE_TOOLTIP_CYCLE_SPACER_ICON..text, 0.8, 0.82 * 0.8, 0, false);
				end
			end
		end
	end

	function SubModule:ProcessData(tooltip, itemID)
		self.hasAltMode = nil;
		self.currentData = nil;

		if self.enabled then
			if ItemData[itemID] and not InCombatLockdown() then
				local info = tooltip.processingInfo;
				if not (info and info.getterName == "GetBagItem") then
					return false;
				end

				local data = ItemData[itemID];
				self.currentData = data;

				if data.entries then
					tooltip:AddLine(" ");
					tooltip:AddLine(L["Intruction Swtich Destinations"], 0.8, 0.8, 0.8, false);
					if not data.selectedIndex then
						data.selectedIndex = 1;
					end
					for i, v in ipairs(data.entries) do
						AppendName(tooltip, v, i == data.selectedIndex);
					end
					tooltip:AddLine(" ");

					self.hasAltMode = true;
					self.altModeState = 1;
				else
					tooltip:AddLine(" ");
					if not data.instructionOnly then
						AppendName(tooltip, data);
					end
				end

				tooltip:AddLine(CONTENT_TRACKING_ATLAS..L["Instruction Set Waypoint"], 0.098, 1.000, 0.098, true);

				return true;
			end
		end

		return false;
	end

	function SubModule:HandleAltPressed()
		local data = self.currentData;
		if data and data.entries then
			local selectedIndex = data.selectedIndex or 1;
			selectedIndex = selectedIndex + 1;
			if selectedIndex > #data.entries then
				selectedIndex = 1;
			end
			data.selectedIndex = selectedIndex;
		end
	end

	function SubModule:OnDressUpBagItem(itemID, bagID, slotIndex)
		if ItemData[itemID] then
			if API.CheckAndDisplayErrorIfInCombat() then
				return;
			end

			local v = ItemData[itemID];

			if v.entries then
				local selectedIndex = v.selectedIndex or 1;
				v = v.entries[selectedIndex];
			end

			if v and v.uiMapID then
				C_Map.OpenWorldMap(v.uiMapID);
				API.SetUserWaypoint(v.uiMapID, v.pos[1], v.pos[2]);
			end
		end
	end
end


do
	local function EnableModule(state)
		SubModule:SetEnabled(state);
		if state then
			addon.GameTooltipManager:AddDressUpModule(SubModule);
		end
	end

	local moduleData = {
		name = addon.L["ModuleName TooltipVendorLocation"],
		dbKey = "TooltipVendorLocation",
		description = addon.L["ModuleDescription TooltipVendorLocation"],
		toggleFunc = EnableModule,
		moduleAddedTime = 1778200000,
		categoryKeys = {
			"Inventory",
		},
	};

	addon.ControlCenter:AddModule(moduleData);
end


ItemData = {
	-- [itemID] = {};
	---- name: NPC Name
	---- pos = {x, y}
	---- instructionOnly (optional): if true, only show <Ctrl+Click to set a pin>. Because the npc's name and location are already in the tooltip

	-- MID
	[264882] = {npc = 259722, name = "Andra", pos = {0.418, 0.666}, uiMapID = 2393, instructionOnly = true}, -- Finery Funds
	[267051] = {npc = 255473, name = "Maren Silverwing", pos = {0.48, 0.492}, uiMapID = 2393, instructionOnly = true}, -- Dark Particle
	[259361] = {object = 539047, name = "Abandoned Ritual Skull", localizedName = L["Location Note Inside Cave"], pos = {0.444, 0.436}, uiMapID = 2437}, -- Vile Essence
	[245937] = {npc = 245976, name = "Deminos Darktrance", pos = {0.388, 0.816}, uiMapID = 2444, instructionOnly = true}, -- Void-Tainted Remains
	[248944] = {npc = 249098, name = "Balaak the Twice-Exiled", pos = {0.536, 0.52}, uiMapID = 2444, instructionOnly = true}, -- Ethereal Energy

	-- TWW
	[225557] = {npc = 226205, name = "Cendvin", pos = {0.744, 0.452}, uiMapID = 2248}, -- Sizzling Cinderpollen
	[212493] = {npc = 225166, name = "Middles", pos = {0.4336, 0.352}, uiMapID = 2214, instructionOnly = true}, -- Odd Glob of Wax
	[224642] = {npc = 216164, name = "Gnawbles", pos = {0.436, 0.352}, uiMapID = 2214}, -- Firelight Ruby
	[238920] = {area = 15335, name = "Morgaen\'s Tears", pos = {0.282, 0.56}, uiMapID = 2215}, -- Radiant Emblem of Service
	[227673] = {npc = 226994, name = "Blair Bass", pos = {0.342, 0.716}, uiMapID = 2346}, -- "Gold" Fish
	[233246] = {npc = 234776, name = "Angelo Rustbin", pos = {0.258, 0.381}, uiMapID = 2346, instructionOnly = true}, -- Gunk-Covered Thingy
	[234741] = {entries = { -- Miscellaneous Mechanica
		{npc = 228286, name = "Skedgit Cinderbangs", pos = {0.432, 0.828}, uiMapID = 2346, label = L["ItemType Mounts"]}, -- Skedgit Cinderbangs (Mount)
		{npc = 236411, name = "Ditty Fuzeboy", pos = {0.354, 0.412}, uiMapID = 2346, label = L["ItemType Pets"]}, -- Ditty Fuzeboy (Pet)
	}},
	[245510] = {npc = 245348, name = "Ba\'choso", pos = {0.42, 0.224}, uiMapID = 2371}, -- Loombeast Silk

	-- DF
	[205188] = {npc = 204693, name = "Ponzo", pos = {0.58, 0.538}, uiMapID = 2133}, -- Barter Boulder
	[204715] = {npc = 203602, name = "Spinsoa", pos = {0.558, 0.554}, uiMapID = 2133}, -- Unearthed Fragrant Coin
	[211376] = {npc = 212797, name = "Talisa Whisperbloom", pos = {0.498, 0.62}, uiMapID = 2200}, -- Seedbloom

	-- Class Set Curios
	[249367] = {npc = 254436, name = "Kirana", pos = {0.556, 0.878}, uiMapID = 2424, instructionOnly = true}, -- Chiming Void Curio
	[237602] = {npc = 248304, name = "Acquirer Ba\'theom", pos = {0.42, 0.224}, uiMapID = 2371, instructionOnly = true}, -- Hungering Void Curio
	[228819] = {npc = 231824, name = "Kari Bridgeblaster", localizedName = L["Location Note Second Floor"], pos = {0.439, 0.498}, uiMapID = 2346, area = 15388}, -- Excessively Bejeweled Curio
	[225634] = {npc = 227003, name = "Kir\'xal", pos = {0.566, 0.458}, uiMapID = 2216, instructionOnly = true}, -- Web-Wrapped Curio (City of Threads - Lower)
	[210947] = {npc = 213278, name = "Kirasztia", pos = {0.366, 0.334}, uiMapID = 2200, instructionOnly = true}, -- Flame-Warped Curio
	[206046] = {npc = 205675, name = "Kaitalla", pos = {0.52, 0.256}, uiMapID = 2133, instructionOnly = true}, -- Void-Touched Curio
};

ItemData[204985] = ItemData[205188]; -- Barter Brick
