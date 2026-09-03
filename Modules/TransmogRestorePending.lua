local _, addon = ...
local L = addon.L;

local EL = CreateFrame("Frame");
local SHOULDER_RIGHT = Enum.TransmogOutfitSlot.ShoulderRight;
local WEAPON_SLOTS = {
	[16] = Enum.TransmogOutfitSlot.WeaponMainHand,
	[17] = Enum.TransmogOutfitSlot.WeaponOffHand,
};


do
	local IgnoredInvSlots = {
		[2] = true,     --Neck
		[11] = true,    --Finger1
		[12] = true,    --Finger2
		[13] = true,    --Trinket1
		[14] = true,    --Trinket2
		[18] = true,    --Ranged
	};

	local function SetPendingFromSlot(invSlotID, slot, transmogID, illusionID, weaponOption)
		local option = weaponOption or Enum.TransmogOutfitSlotOption.None;
		local transmogType, displayType;

		if illusionID then
			--Illusions get their own pending entry, separate from the appearance
			transmogType = Enum.TransmogType.Illusion;
			displayType = (illusionID == 0) and Enum.TransmogOutfitDisplayType.Unassigned or Enum.TransmogOutfitDisplayType.Assigned;
			C_TransmogOutfitInfo.SetPendingTransmog(slot, transmogType, option, illusionID, displayType);
		end

		transmogType = Enum.TransmogType.Appearance;

		local isHiddenVisual = C_TransmogCollection.IsAppearanceHiddenVisual(transmogID) or transmogID == 0;
		if isHiddenVisual then
			displayType = Enum.TransmogOutfitDisplayType.Hidden;
			if transmogID == 0 then
				--0 isn't a usable appearance id for Hidden, resolve a real one
				transmogID = addon.TransmogUtil.GetHiddenSourceIDForSlot(invSlotID) or transmogID;
			end
		else
			displayType = Enum.TransmogOutfitDisplayType.Assigned;
		end

		if slot and transmogID then
			C_TransmogOutfitInfo.SetPendingTransmog(slot, transmogType, option, transmogID, displayType);
		end
	end

	function EL.ApplySnapshotToPending(itemTransmogInfoList)
		for invSlotID, transmogInfo in ipairs(itemTransmogInfoList) do
			if not IgnoredInvSlots[invSlotID] then
				local transmogID = transmogInfo.appearanceID;

				if invSlotID == 3 then
					local secondaryAppearanceID = transmogInfo.secondaryAppearanceID;
					SetPendingFromSlot(invSlotID, SHOULDER_RIGHT, transmogID);
					if secondaryAppearanceID == 0 then
						--0 means the left shoulder was never set independently, mirror the right
						secondaryAppearanceID = transmogID;
					end
					SetPendingFromSlot(invSlotID, Enum.TransmogOutfitSlot.ShoulderLeft, secondaryAppearanceID);
				else
					local slot = C_TransmogOutfitInfo.GetTransmogOutfitSlotFromInventorySlot(invSlotID - 1);
					local illusionID, weaponOption;
					if invSlotID == 16 or invSlotID == 17 then
						--Weapon slots must be written under the equipped weapon's option, or SetPendingTransmog silently does nothing
						illusionID = transmogInfo.illusionID;
						weaponOption = slot and C_TransmogOutfitInfo.GetEquippedSlotOptionFromTransmogSlot(slot);
					end
					SetPendingFromSlot(invSlotID, slot, transmogID, illusionID, weaponOption);
				end
			end
		end
	end

	function EL.RestoreShoulderSecondaryState(enabled)
		if enabled ~= nil then
			C_TransmogOutfitInfo.SetSecondarySlotState(SHOULDER_RIGHT, enabled);
		end
	end

	local function GetWeaponSheatheCategory(slot, weaponOption)
		if not slot or not weaponOption or weaponOption == Enum.TransmogOutfitSlotOption.None then return nil end;

		local slotInfo = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(slot, Enum.TransmogType.Appearance, weaponOption);
		return slotInfo and slotInfo.sheatheCategory;
	end

	function EL.CaptureWeaponSheatheCategories()
		local sheatheCategories;
		for invSlotID, slot in pairs(WEAPON_SLOTS) do
			local weaponOption = C_TransmogOutfitInfo.GetEquippedSlotOptionFromTransmogSlot(slot);
			local category = GetWeaponSheatheCategory(slot, weaponOption);
			if category then
				sheatheCategories = sheatheCategories or {};
				sheatheCategories[invSlotID] = category;
			end
		end
		return sheatheCategories;
	end

	function EL.RestoreWeaponSheatheCategories(sheatheCategories)
		if not sheatheCategories then return end;

		for invSlotID, slot in pairs(WEAPON_SLOTS) do
			local category = sheatheCategories[invSlotID];
			if category then
				--Must match the equipped weapon's current option, or SetPendingTransmogSheatheCategory silently does nothing
				local weaponOption = C_TransmogOutfitInfo.GetEquippedSlotOptionFromTransmogSlot(slot);
				if weaponOption and weaponOption ~= Enum.TransmogOutfitSlotOption.None then
					C_TransmogOutfitInfo.SetPendingTransmogSheatheCategory(slot, weaponOption, category);
				end
			end
		end
	end

	function EL.ForceWeaponSlotWidgetRebuild()
		--Toggling shoulder secondary state forces a weapon slot widget rebuild, working around a Blizzard display
		--bug where the widget caches the wrong option (e.g. 1H for an equipped 2H) on first build. Must run first.
		local liveSecondary = C_TransmogOutfitInfo.GetSecondarySlotState(SHOULDER_RIGHT);
		C_TransmogOutfitInfo.SetSecondarySlotState(SHOULDER_RIGHT, not liveSecondary);
		C_TransmogOutfitInfo.SetSecondarySlotState(SHOULDER_RIGHT, liveSecondary);
	end
end


do
	local SNAPSHOT_EVENTS = {
		"VIEWED_TRANSMOG_OUTFIT_SLOT_REFRESH", -- Queue a transmog change
	};

	--Piggyback on Blizzard's /customset format to store this as a string instead of a nested table.
	--CreateCustomSetSlashCommand ignores the mixin methods on the list entries, so passing it straight through works.
	local function SerializeSnapshot(itemTransmogInfoList)
		local createFunc = TransmogUtil and TransmogUtil.CreateCustomSetSlashCommand;
		local slashCommand = createFunc and createFunc(itemTransmogInfoList);
		--Strip the "/customset " prefix, ParseCustomSetSlashCommand only wants the "v1 ..." part
		return slashCommand and slashCommand:match("^/customset (.+)$");
	end

	local function DeserializeSnapshot(str)
		local parseFunc = TransmogUtil and TransmogUtil.ParseCustomSetSlashCommand;
		return parseFunc and parseFunc(str);
	end

	local function SaveSnapshotToDB()
		if not PlumberDB_PC then return end;

		if EL.pendingSnapshot then
			PlumberDB_PC.TransmogRestorePending = {
				snapshot = SerializeSnapshot(EL.pendingSnapshot),
				shoulderSecondary = EL.pendingShoulderSecondary,
				sheatheCategories = EL.pendingSheatheCategories,
			};
		else
			PlumberDB_PC.TransmogRestorePending = nil;
		end
	end
	EL.SaveSnapshotToDB = SaveSnapshotToDB;

	function EL.LoadSnapshotFromDB()
		local saved = PlumberDB_PC and PlumberDB_PC.TransmogRestorePending;
		if saved then
			if type(saved.snapshot) == "string" then
				EL.pendingSnapshot = DeserializeSnapshot(saved.snapshot);
			else
				--Older Plumber versions stored a plain table snapshot directly
				EL.pendingSnapshot = saved.snapshot;
			end
			EL.pendingShoulderSecondary = saved.shoulderSecondary;
			EL.pendingSheatheCategories = saved.sheatheCategories;
		end
	end

	local function CaptureSnapshot()
		if not EL.enabled then return end;

		if not C_TransmogOutfitInfo.HasPendingOutfitTransmogs() then
			EL.pendingSnapshot = nil;
			EL.pendingShoulderSecondary = nil;
			EL.pendingSheatheCategories = nil;
		else
			EL.pendingSnapshot = TransmogFrame.CharacterPreview:GetItemTransmogInfoList();
			EL.pendingShoulderSecondary = C_TransmogOutfitInfo.GetSecondarySlotState(SHOULDER_RIGHT);
			EL.pendingSheatheCategories = EL.CaptureWeaponSheatheCategories();
		end

		SaveSnapshotToDB();
	end

	local function RestorePendingSnapshot()
		--Clear early, a write below can retrigger CaptureSnapshot mid-call
		local snapshot = EL.pendingSnapshot;
		local shoulderSecondary = EL.pendingShoulderSecondary;
		local sheatheCategories = EL.pendingSheatheCategories;
		EL.pendingSnapshot = nil;
		EL.pendingShoulderSecondary = nil;
		EL.pendingSheatheCategories = nil;
		EL.SaveSnapshotToDB();

		EL.ForceWeaponSlotWidgetRebuild();

		--Must run before ApplySnapshotToPending, toggling this after would wipe the left shoulder's pending value
		EL.RestoreShoulderSecondaryState(shoulderSecondary);
		EL.ApplySnapshotToPending(snapshot);
		--Must run after ApplySnapshotToPending, setting a weapon's appearance resets its sheathe category to Default
		EL.RestoreWeaponSheatheCategories(sheatheCategories);
		--If we ever want to notify the user their outfit was restored, this is where it'd happen.
	end

	local function OnSnapshotEvent()
		if not EL.enabled then return end;

		CaptureSnapshot();
	end

	local function TransmogFrame_OnShow()
		if not EL.enabled then return end;

		for _, event in ipairs(SNAPSHOT_EVENTS) do
			EL:RegisterEvent(event);
		end

		if EL.pendingSnapshot then
			RestorePendingSnapshot();
		end
	end

	local function TransmogFrame_OnHide()
		EL:UnregisterAllEvents();
	end

	function EL.SnapshotFrame_OnLoad()
		if EL.snapshotHooked then return end;
		EL.snapshotHooked = true;

		EL:SetScript("OnEvent", OnSnapshotEvent);
		TransmogFrame:HookScript("OnShow", TransmogFrame_OnShow);
		TransmogFrame:HookScript("OnHide", TransmogFrame_OnHide);

		if TransmogFrame:IsShown() then
			TransmogFrame_OnShow();
		end
	end
end


do
	local function EnableModule(state)
		if state and not EL.enabled then
			EL.enabled = true;
			EL.LoadSnapshotFromDB();
			addon.CallbackRegistry:RegisterAddOnLoadedCallback("Blizzard_Transmog", EL.SnapshotFrame_OnLoad);
		elseif (not state) and EL.enabled then
			EL.enabled = nil;
			addon.CallbackRegistry:UnregisterAddOnLoadedCallback("Blizzard_Transmog", EL.SnapshotFrame_OnLoad);
			EL.pendingSnapshot = nil;
			EL.pendingShoulderSecondary = nil;
			EL.pendingSheatheCategories = nil;
			EL.SaveSnapshotToDB();
		end
	end

	local moduleData = {
		name = L["ModuleName TransmogRestorePending"],
		dbKey = "TransmogRaestorePending",
		description = L["ModuleDescription TransmogRestorePending"],
		toggleFunc = EnableModule,
		moduleAddedTime = 1788399603,
		categoryKeys = {"Collection"},
	};

	addon.ControlCenter:AddModule(moduleData);
end
