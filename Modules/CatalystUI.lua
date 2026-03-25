-- Allow other UI to support Ctrl-Click to view items in Dressing Rooom
---- ItemInteractionFrame (Blizzard_ItemInteractionUI) Additionally, clicking the input slot (left) will hide the GameTooltip so it doesn't block the flyout


local _, addon = ...
local API = addon.API;


local MODULE_ENABLED;

local SubModules = {};

local function AddSubModule(subModule)
	table.insert(SubModules, subModule);

	subModule.callback = function()
		if not subModule.loaded then
			subModule.loaded = true;
			subModule.Init();
		end
	end
end


local CursorWatcher = CreateFrame("Frame");
do	--Change curosr icon to Inspect
	CursorWatcher:Hide();
	CursorWatcher.checkFuncs = {};
	CursorWatcher.IsControlKeyDown = IsControlKeyDown;

	function CursorWatcher:OnUpdate(elapsed)
		self.t = self.t + elapsed;
		if self.t >= 0.1 then
			self.t = 0;
			self.anyShown = false;
			self.anyItem = false;
			local isShown, hasItem;

			for _, func in ipairs(self.checkFuncs) do
				isShown, hasItem = func();
				if isShown then
					self.anyShown = true;
				end

				if hasItem then
					self.anyItem = true;
					break
				end
			end

			if self.anyItem and IsControlKeyDown() then
				self.cusorChanged = true;
				SetCursor("INSPECT_CURSOR");
			elseif self.cusorChanged then
				self.cusorChanged = nil;
				ResetCursor();
			end

			if not self.anyShown then
				self:SetScript("OnUpdate", nil);
				self:Hide();
			end
		end
	end

	function CursorWatcher:AddCheckFunc(f)
		table.insert(self.checkFuncs, f);
	end

	function CursorWatcher:Start()
		self.t = -0.5;
		self:SetScript("OnUpdate", self.OnUpdate);
		self:Show();
	end
end


local function SharedButton_OnShow()
	if MODULE_ENABLED then
		CursorWatcher:Start();
	end
end


do	--ItemInteractionFrame
	local SubModule = {};
	SubModule.name = "Blizzard_ItemInteractionUI";

	local function GetOutputItemLink()
		local info = C_TooltipInfo.GetItemInteractionItem();
		if info and info.hyperlink then
			return info.hyperlink
		end
	end

	local function OutputSlot_OnClick(self, button)
		if not MODULE_ENABLED then return end;

		if IsModifiedClick() then
			local itemLink = GetOutputItemLink();
			if itemLink then
				if API.CheckAndDisplayErrorIfInCombat() then
					return
				end

				API.HandleModifiedItemClick(itemLink);
			end

			--local itemLocation = ItemInteractionFrame:GetItemLocation();
			--if itemLocation then
				--local itemLink = C_Item.GetItemLink(itemLocation); --This is the input item on the left
			--end
		end
	end

	local function OutputSlot_RefreshIcon()
		if not MODULE_ENABLED then return end;
		if DressUpFrame:IsShown() then
			local itemLink = GetOutputItemLink();
			if itemLink then
				DressUpLink(itemLink);
			end
		end
	end

	function SubModule.Init()
		local key = "ItemInteractionFrame.ItemConversionFrame.ItemConversionOutputSlot";
		local outputSlot = API.GetGlobalObject("ItemInteractionFrame.ItemConversionFrame.ItemConversionOutputSlot");
		if outputSlot then
			outputSlot:HookScript("OnClick", OutputSlot_OnClick);
			outputSlot:HookScript("OnShow", SharedButton_OnShow);
			hooksecurefunc(outputSlot, "RefreshIcon", OutputSlot_RefreshIcon);

			local function IsItemButton()
				local isShown, hasItem;
				if outputSlot:IsVisible() then
					isShown = true;
					hasItem = outputSlot:IsMouseMotionFocus() and ItemInteractionFrame.itemLocation ~= nil
				else
					isShown = false;
					hasItem = false;
				end
				return isShown, hasItem
			end

			CursorWatcher:AddCheckFunc(IsItemButton);

			local inputSlot = API.GetGlobalObject("ItemInteractionFrame.ItemConversionFrame.ItemConversionInputSlot");
			if inputSlot then
				inputSlot:HookScript("OnClick", function()
					GameTooltip:Hide();
				end);
			end
		else
			error("Fail to find: "..key);
		end
	end

	AddSubModule(SubModule);
end


do
	local function EnableModule(state)
		local registry = addon.CallbackRegistry;
		if state and not MODULE_ENABLED then
			MODULE_ENABLED = true;
			for _, subModule in ipairs(SubModules) do
				registry:RegisterAddOnLoadedCallback(subModule.name, subModule.callback);
			end
		elseif (not state) and MODULE_ENABLED then
			MODULE_ENABLED = false;
			for _, subModule in ipairs(SubModules) do
				registry:UnregisterAddOnLoadedCallback(subModule.name, subModule.callback);
			end
		end
	end

	local moduleData = {
		name = addon.L["ModuleName CatalystUI"],
		dbKey = "CatalystUI",
		description = addon.L["ModuleDescription CatalystUI"],
		toggleFunc = EnableModule,
		categoryID = 3,
		moduleAddedTime = 1774400000,
		categoryKeys = {
			"Collection",
		},
		searchTags = {
			"Transmog",
		},
	};

	addon.ControlCenter:AddModule(moduleData);
end

--[[
do
	local function YeetConveribleItems()
		local filterFunction = C_Item.IsItemConvertibleAndValidForPlayer;
		local tbl = {};
		local n = 0;

		local function ItemLocationCallback(itemLocation)
			if filterFunction(itemLocation) then
				n = n + 1;
				tbl[itemLocation] = C_Item.GetItemLink(itemLocation);
			end
		end

		ItemUtil.IteratePlayerInventoryAndEquipment(ItemLocationCallback);

		local list = {};

		for itemLocation in pairs(tbl) do
			table.insert(list, itemLocation);
		end

		local fromIndex = 1;
		local TestFrame = PlumberTestFrame or CreateFrame("Frame", "PlumberTestFrame", UIParent);

		TestFrame:SetScript("OnUpdate", nil);

		local function TestFrame_OnUpdate(self, elapsed)
			self:SetScript("OnUpdate", nil);
			if list[fromIndex] then
				C_ItemInteraction.SetPendingItem(list[fromIndex]);
			end
		end

		local links = {};

		local function DisplayResult()
			local GetItemUpgradeInfo = C_Item.GetItemUpgradeInfo;

			for _, link in ipairs(links) do
				local info = GetItemUpgradeInfo(link);
				if info then
					print(info.trackStringID, info.trackString, info.currentLevel, string.gsub(link, "^|cn|Q%s:|H", ""), C_TransmogCollection.GetItemInfo(link));
				end
			end
		end

		TestFrame:SetScript("OnEvent", function(self, event, ...)
			if event == "ITEM_CONVERSION_DATA_READY" or event == "ITEM_INTERACTION_ITEM_SELECTION_UPDATED" then
				local itemGUID = ...
				local info = C_TooltipInfo.GetItemInteractionItem();
				--print(event)
				if info and info.hyperlink then
					print(info.hyperlink);
					self:SetScript("OnUpdate", nil);
					table.insert(links, info.hyperlink);

					fromIndex = fromIndex + 1;
					if list[fromIndex] then
						TestFrame_OnUpdate(self);
						--self:SetScript("OnUpdate", TestFrame_OnUpdate);
					else
						self:UnregisterEvent(event);
						C_ItemInteraction.ClearPendingItem();

						DisplayResult();
					end
				end
			end
		end)

		TestFrame:RegisterEvent("ITEM_CONVERSION_DATA_READY");
		TestFrame:RegisterEvent("ITEM_INTERACTION_ITEM_SELECTION_UPDATED");

		C_ItemInteraction.SetPendingItem(list[1]);
	end
end
--]]
