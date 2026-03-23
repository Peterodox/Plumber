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
	CursorWatcher.frames = {};
	CursorWatcher.IsControlKeyDown = IsControlKeyDown;

	function CursorWatcher:OnUpdate(elapsed)
		self.t = self.t + elapsed;
		if self.t >= 0.1 then
			self.t = 0;
			self.anyShown = false;
			self.anyMouseover = false;

			for _, f in ipairs(self.frames) do
				if (not self.anyMouseover) and f:IsMouseMotionFocus() then
					self.anyMouseover = true;
				end

				if f:IsVisible() then
					self.anyShown = true;
				end
			end

			if self.anyMouseover and IsControlKeyDown() then
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

	function CursorWatcher:AddFrame(f)
		table.insert(self.frames, f);
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
			CursorWatcher:AddFrame(outputSlot);

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
		name = addon.L["ModuleName TryOnItem"],
		dbKey = "TryOnItem",
		description = addon.L["ModuleDescription TryOnItem"],
		toggleFunc = EnableModule,
		categoryID = 3,
		moduleAddedTime = 1755200000,
		categoryKeys = {
			"Collection",
		},
		searchTags = {
			"Transmog",
		},
	};

	addon.ControlCenter:AddModule(moduleData);
end
