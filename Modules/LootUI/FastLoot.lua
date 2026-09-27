local _, addon = ...
local L = addon.L;
local LootUI = addon.LootUI; ---@class LootUISystem
local MainFrame = LootUI.MainFrame;


local GetNumLootItems = GetNumLootItems;
local LootSlot = LootSlot;
local LootSlotHasItem = LootSlotHasItem;


local FastLoot = CreateFrame("Frame");
LootUI.FastLoot = FastLoot;


FastLoot.LootSpeedDBKey = "FastLoot_Speed";

FastLoot.LootSpeed = {
	Moderate = 1,
	Maximum = 2,
};

FastLoot.LootSpeedOptions = {
	{value = FastLoot.LootSpeed.Moderate, label = L["LootUI Option Loot Speed Moderate"], tooltip = L["LootUI Option Loot Speed Moderate Tooltip"]},
	{value = FastLoot.LootSpeed.Maximum, label = L["LootUI Option Loot Speed Maximum"], tooltip = L["LootUI Option Loot Speed Maximum Tooltip"]},
};


---Reset everything. Called after LOOT_CLOSED
function FastLoot:ResetFlags()
	self.slotProcessed = nil;
	self.t = nil;
	self:SetScript("OnUpdate", nil);
end

function FastLoot:Start()
	local numItems = GetNumLootItems();
	for slotIndex = 1, numItems do
		if LootSlotHasItem(slotIndex) then
			if not self.slotProcessed then
				self.slotProcessed = {};
			end
			if not self.slotProcessed[slotIndex] then
				self.slotProcessed[slotIndex] = true;
				LootSlot(slotIndex);
			end
		end
	end
end

---@param slotIndex number
---@param flag boolean `true` if LOOT_SLOT_CLEARED. `false` if LOOT_SLOT_CHANGED
function FastLoot:SetSlotFlag(slotIndex, flag)
	if self.slotProcessed then
		self.slotProcessed[slotIndex] = flag;
		if not flag then
			self.t = 0;
			self:SetScript("OnUpdate", self.OnUpdate_RetryFastLoot);
		end
	end
end

function FastLoot:OnUpdate_RetryFastLoot(elapsed)
	self.t = self.t + elapsed;
	if self.t > 0.4 then
		if not MainFrame:IsInMaualModeOrEditMode() then
			self.t = 0;
			self:SetScript("OnUpdate", nil);
			self:Start();
		end
	end
end

function FastLoot:OnEvent(event, ...)
	-- This only works when `LootUI = false` and `FastLoot = true`
	-- When Plumber LootUI is enabled, the EventListener in Controller.lua will handle these events
	self[event](self, ...);
end

local LootEvents = {
	"LOOT_READY",
	"LOOT_OPENED",
	"LOOT_CLOSED",
	"LOOT_SLOT_CHANGED",
	"LOOT_SLOT_CLEARED",
};

function FastLoot:ResolveSystemStatus()
	if addon.GetDBBool("FastLoot") and not addon.GetDBBool("LootUI") then
		if not self.eventRegistered then
			self.eventRegistered = true;
			addon.API.RegisterFrameForEvents(self, LootEvents);
			self:SetScript("OnEvent", self.OnEvent);
		end
	else
		if self.eventRegistered then
			self.eventRegistered = nil;
			addon.API.UnregisterFrameForEvents(self, LootEvents);
			self:SetScript("OnEvent", nil);
			self.t = 0;
			self:SetScript("OnUpdate", nil);
		end
	end

	self:SetLootSpeed(self:GetSelectedLootSpeed());
end

function FastLoot:LOOT_READY(isAutoLoot)
	if isAutoLoot then
		self:Start();
	end
end

function FastLoot:LOOT_OPENED(isAutoLoot)
	if isAutoLoot then
		self:Start();
	end
end

function FastLoot:LOOT_CLOSED()
	self:ResetFlags();
end

function FastLoot:LOOT_SLOT_CHANGED(slotIndex)
	self:SetSlotFlag(slotIndex, false);
end

function FastLoot:LOOT_SLOT_CLEARED(slotIndex)
	self:SetSlotFlag(slotIndex, true);
end

---@alias FastLootSpeed
---| 1 Moderate. Loot on LOOT_OPENED
---| 2 Maximum. Loot on LOOT_READY. Might break other addons.

---@param lootSpeed FastLootSpeed
function FastLoot:SetLootSpeed(lootSpeed)
	self.lootSpeed = lootSpeed;
end
FastLoot:SetLootSpeed(FastLoot.LootSpeed.Maximum);

function FastLoot:GetSelectedLootSpeed()
	local value = addon.GetDBValue(FastLoot.LootSpeedDBKey);
	for _, v in pairs(FastLoot.LootSpeed) do
		if v == value then
			return value;
		end
	end
	return FastLoot.LootSpeed.Maximum;
end
