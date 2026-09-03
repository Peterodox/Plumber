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
		[16] = true,    --MainHand, see CaptureWeaponOptionsPending
		[17] = true,    --SecondaryHand, see CaptureWeaponOptionsPending
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
					SetPendingFromSlot(invSlotID, slot, transmogID);
				end
			end
		end
	end

	function EL.RestoreShoulderSecondaryState(enabled)
		if enabled ~= nil then
			C_TransmogOutfitInfo.SetSecondarySlotState(SHOULDER_RIGHT, enabled);
		end
	end

	--Records are {invSlotID, weaponOption, transmogID, illusionID, sheatheCategory}, false marks a field as not captured
	local function CaptureWeaponOptionRecord(invSlotID, slot, weaponOption)
		local transmogID, illusionID, sheatheCategory;

		--hasPending means unsaved, not just currently equipped or already saved
		local appearanceInfo = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(slot, Enum.TransmogType.Appearance, weaponOption);
		if appearanceInfo and appearanceInfo.hasPending then
			transmogID = appearanceInfo.transmogID;
			sheatheCategory = appearanceInfo.sheatheCategory;
		end

		local illusionInfo = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(slot, Enum.TransmogType.Illusion, weaponOption);
		if illusionInfo and illusionInfo.hasPending then
			illusionID = illusionInfo.transmogID;
		end

		if transmogID or illusionID then
			return {invSlotID, weaponOption, transmogID or false, illusionID or false, sheatheCategory or false};
		end
	end

	--Shared so the same capture logic runs for both weaponOptionsInfo and artifactOptionsInfo without duplicating it
	local function CaptureOptionsInfoList(weaponOptionsPending, invSlotID, slot, optionsInfo)
		if not optionsInfo then return weaponOptionsPending end;

		for _, optionInfo in ipairs(optionsInfo) do
			if optionInfo.enabled then
				local record = CaptureWeaponOptionRecord(invSlotID, slot, optionInfo.weaponOption);
				if record then
					weaponOptionsPending = weaponOptionsPending or {};
					table.insert(weaponOptionsPending, record);
				end
			end
		end

		return weaponOptionsPending;
	end

	function EL.CaptureWeaponOptionsPending()
		local weaponOptionsPending;
		for invSlotID, slot in pairs(WEAPON_SLOTS) do
			--Artifact spec options use separate enum values, so they never collide with the weapon options here
			local weaponOptionsInfo, artifactOptionsInfo = C_TransmogOutfitInfo.GetWeaponOptionsForSlot(slot);
			weaponOptionsPending = CaptureOptionsInfoList(weaponOptionsPending, invSlotID, slot, weaponOptionsInfo);
			weaponOptionsPending = CaptureOptionsInfoList(weaponOptionsPending, invSlotID, slot, artifactOptionsInfo);
		end
		return weaponOptionsPending;
	end

	function EL.RestoreWeaponOptionsPending(weaponOptionsPending)
		if not weaponOptionsPending then return end;

		for _, record in ipairs(weaponOptionsPending) do
			local invSlotID, weaponOption, transmogID, illusionID, sheatheCategory = record[1], record[2], record[3], record[4], record[5];
			local slot = WEAPON_SLOTS[invSlotID];

			if transmogID then
				SetPendingFromSlot(invSlotID, slot, transmogID, illusionID, weaponOption);
			elseif illusionID then
				--SetPendingFromSlot already writes the illusion when transmogID is set, this covers illusion-only changes
				local illusionDisplayType = (illusionID == 0) and Enum.TransmogOutfitDisplayType.Unassigned or Enum.TransmogOutfitDisplayType.Assigned;
				C_TransmogOutfitInfo.SetPendingTransmog(slot, Enum.TransmogType.Illusion, weaponOption, illusionID, illusionDisplayType);
			end

			if sheatheCategory then
				C_TransmogOutfitInfo.SetPendingTransmogSheatheCategory(slot, weaponOption, sheatheCategory);
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
				weaponOptions = EL.pendingWeaponOptions,
				outfitID = EL.pendingOutfitID,
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
			EL.pendingWeaponOptions = saved.weaponOptions;
			EL.pendingOutfitID = saved.outfitID;
		end
	end

	local function CaptureSnapshot()
		if not EL.enabled then return end;

		if not C_TransmogOutfitInfo.HasPendingOutfitTransmogs() then
			EL.pendingSnapshot = nil;
			EL.pendingShoulderSecondary = nil;
			EL.pendingWeaponOptions = nil;
			EL.pendingOutfitID = nil;
		else
			EL.pendingSnapshot = TransmogFrame.CharacterPreview:GetItemTransmogInfoList();
			EL.pendingShoulderSecondary = C_TransmogOutfitInfo.GetSecondarySlotState(SHOULDER_RIGHT);
			EL.pendingWeaponOptions = EL.CaptureWeaponOptionsPending();
			--Frame reopens on the active outfit, so remember which one was actually being edited.
			EL.pendingOutfitID = C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID();
		end

		SaveSnapshotToDB();
	end

	local function RestoreViewedOutfit(outfitID)
		if outfitID == nil then return end;
		if outfitID == C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID() then return end;
		--0 is the equipped-gear view (always valid); other outfits may have been deleted since capture.
		if outfitID == 0 or C_TransmogOutfitInfo.GetOutfitInfo(outfitID) then
			C_TransmogOutfitInfo.ChangeViewedOutfit(outfitID);
		end
	end

	local function RestorePendingSnapshot()
		--Clear early, a write below can retrigger CaptureSnapshot mid-call
		local snapshot = EL.pendingSnapshot;
		local shoulderSecondary = EL.pendingShoulderSecondary;
		local weaponOptions = EL.pendingWeaponOptions;
		local outfitID = EL.pendingOutfitID;
		EL.pendingSnapshot = nil;
		EL.pendingShoulderSecondary = nil;
		EL.pendingWeaponOptions = nil;
		EL.pendingOutfitID = nil;
		EL.SaveSnapshotToDB();

		--Must run first, since Blizzard's OnShow forces the active outfit and switching outfits wipes pending changes.
		RestoreViewedOutfit(outfitID);

		EL.ForceWeaponSlotWidgetRebuild();

		--Must run before ApplySnapshotToPending, toggling this after would wipe the left shoulder's pending value
		EL.RestoreShoulderSecondaryState(shoulderSecondary);
		EL.ApplySnapshotToPending(snapshot);
		--Must run after ApplySnapshotToPending, setting a weapon's appearance resets its sheathe category to Default
		EL.RestoreWeaponOptionsPending(weaponOptions);
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
			EL.pendingWeaponOptions = nil;
			EL.pendingOutfitID = nil;
			EL.SaveSnapshotToDB();
		end
	end

	local moduleData = {
		name = L["ModuleName TransmogRaestorePending"],
		dbKey = "TransmogRaestorePending",
		description = L["ModuleDescription TransmogRaestorePending"],
		toggleFunc = EnableModule,
		moduleAddedTime = 1788400000,
		categoryKeys = {"Collection"},
		consultant = 2,
	};

	addon.ControlCenter:AddModule(moduleData);
end
