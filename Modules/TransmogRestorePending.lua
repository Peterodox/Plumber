local _, addon = ...
local L = addon.L;
local API = addon.API;

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
		if not optionsInfo then return weaponOptionsPending; end

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
		if not weaponOptionsPending then return; end

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

	--Save all situations-related data (4 id fields) in one string, making it a simple per line row for SavedVariables.
	local function SituationOptionKey(option)
		return string.format("%d,%d,%d,%d", option.situationID, option.specID, option.loadoutID, option.equipmentSetID);
	end

	function EL.CaptureSituationsPending()
		local situationsPending = {
			enabled = C_TransmogOutfitInfo.GetOutfitSituationsEnabled(),
			options = {},
		};

		local situationsData = C_TransmogOutfitInfo.GetUISituationCategoriesAndOptions();
		for _, categoryData in ipairs(situationsData or {}) do
			for _, groupData in ipairs(categoryData.groupData) do
				for _, optionData in ipairs(groupData.optionData) do
					local option = optionData.option;
					situationsPending.options[SituationOptionKey(option)] = C_TransmogOutfitInfo.GetOutfitSituation(option);
				end
			end
		end

		return situationsPending;
	end

	function EL.RestoreSituationsPending(situationsPending)
		if not situationsPending then return; end

		C_TransmogOutfitInfo.SetOutfitSituationsEnabled(situationsPending.enabled);

		--Fetch options live so a deleted loadout or equipment set is skipped, not restored.
		local situationsData = C_TransmogOutfitInfo.GetUISituationCategoriesAndOptions();
		for _, categoryData in ipairs(situationsData or {}) do
			for _, groupData in ipairs(categoryData.groupData) do
				for _, optionData in ipairs(groupData.optionData) do
					local option = optionData.option;
					local value = situationsPending.options[SituationOptionKey(option)];
					if value ~= nil then
						C_TransmogOutfitInfo.UpdatePendingSituation(option, value);
					end
				end
			end
		end
	end
end


do
	local TRACKED_EVENTS = {
		"VIEWED_TRANSMOG_OUTFIT_SLOT_REFRESH", -- Queue a transmog change
		"VIEWED_TRANSMOG_OUTFIT_CHANGED", -- Outfit slot switched
		"VIEWED_TRANSMOG_OUTFIT_SITUATIONS_CHANGED", -- Queue a situation change
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

	local function SavePendingToDB()
		if not PlumberDB_PC then return end;

		if EL.PendingSnapshot or EL.PendingSituations then
			--SerializeSnapshot expects a real list, only call it when there's actually a snapshot
			local snapshot = EL.PendingSnapshot and SerializeSnapshot(EL.PendingSnapshot);
			PlumberDB_PC.TransmogRestorePending = {
				snapshot = snapshot,
				shoulderSecondary = EL.PendingShoulderSecondary,
				weaponOptions = EL.PendingWeaponOptions,
				situations = EL.PendingSituations,
				outfitID = EL.PendingOutfitID,
			};
		else
			PlumberDB_PC.TransmogRestorePending = nil;
		end
	end
	EL.SavePendingToDB = SavePendingToDB;

	function EL.LoadPendingFromDB()
		local saved = PlumberDB_PC and PlumberDB_PC.TransmogRestorePending;
		if saved then
			if type(saved.snapshot) == "string" then
				EL.PendingSnapshot = DeserializeSnapshot(saved.snapshot);
			else
				--Older Plumber versions stored a plain table snapshot directly
				EL.PendingSnapshot = saved.snapshot;
			end
			EL.PendingShoulderSecondary = saved.shoulderSecondary;
			EL.PendingWeaponOptions = saved.weaponOptions;
			EL.PendingSituations = saved.situations;
			EL.PendingOutfitID = saved.outfitID;
		end
	end

	local function CapturePending()
		if not EL.enabled then return end;

		local hasTransmogsPending = C_TransmogOutfitInfo.HasPendingOutfitTransmogs();
		if hasTransmogsPending then
			EL.PendingSnapshot = TransmogFrame.CharacterPreview:GetItemTransmogInfoList();
			EL.PendingShoulderSecondary = C_TransmogOutfitInfo.GetSecondarySlotState(SHOULDER_RIGHT);
			EL.PendingWeaponOptions = EL.CaptureWeaponOptionsPending();
		else
			EL.PendingSnapshot = nil;
			EL.PendingShoulderSecondary = nil;
			EL.PendingWeaponOptions = nil;
		end

		local hasSituationsPending = C_TransmogOutfitInfo.HasPendingOutfitSituations();
		EL.PendingSituations = hasSituationsPending and EL.CaptureSituationsPending() or nil;

		--Frame reopens on the active outfit, so remember which one was actually being edited.
		EL.PendingOutfitID = (hasTransmogsPending or hasSituationsPending) and C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID() or nil;

		SavePendingToDB();
	end

	local function RestoreViewedOutfit(outfitID)
		if outfitID == nil then return; end
		if outfitID == C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID() then return; end
		--0 is the equipped-gear view (always valid); other outfits may have been deleted since capture.
		if outfitID == 0 or C_TransmogOutfitInfo.GetOutfitInfo(outfitID) then
			C_TransmogOutfitInfo.ChangeViewedOutfit(outfitID);
		end
	end

	local function ClearPendingState()
		EL.PendingSnapshot = nil;
		EL.PendingShoulderSecondary = nil;
		EL.PendingWeaponOptions = nil;
		EL.PendingSituations = nil;
		EL.PendingOutfitID = nil;
	end

	local function ApplyPendingSnapshot(snapshot, shoulderSecondary, weaponOptions)
		if not snapshot then return; end

		EL.ForceWeaponSlotWidgetRebuild();

		--Must run before ApplySnapshotToPending, toggling this after would wipe the left shoulder's pending value
		EL.RestoreShoulderSecondaryState(shoulderSecondary);
		EL.ApplySnapshotToPending(snapshot);
		--Must run after ApplySnapshotToPending, setting a weapon's appearance resets its sheathe category to Default
		EL.RestoreWeaponOptionsPending(weaponOptions);
	end

	local function RestoreAllPending()
		--Clear early, a write below can retrigger CapturePending mid-call
		local snapshot = EL.PendingSnapshot;
		local shoulderSecondary = EL.PendingShoulderSecondary;
		local weaponOptions = EL.PendingWeaponOptions;
		local situations = EL.PendingSituations;
		local outfitID = EL.PendingOutfitID;
		ClearPendingState();
		EL.SavePendingToDB();

		--Must run first, since Blizzard's OnShow forces the active outfit and switching outfits wipes pending changes.
		RestoreViewedOutfit(outfitID);
		ApplyPendingSnapshot(snapshot, shoulderSecondary, weaponOptions);
		EL.RestoreSituationsPending(situations);
		--If we ever want to notify the user their outfit was restored, this is where it'd happen.
	end

	local function ReapplyPendingOnOutfitSwitch()
		--Nothing pending, or this switch is our own RestoreViewedOutfit call above, already handled.
		if not EL.PendingSnapshot and not EL.PendingSituations then return; end

		local snapshot = EL.PendingSnapshot;
		local shoulderSecondary = EL.PendingShoulderSecondary;
		local weaponOptions = EL.PendingWeaponOptions;
		local situations = EL.PendingSituations;
		ClearPendingState();
		EL.SavePendingToDB();

		--The user already landed on the outfit they picked, just replay the edits onto it.
		ApplyPendingSnapshot(snapshot, shoulderSecondary, weaponOptions);
		EL.RestoreSituationsPending(situations);
	end

	local isHandlingSituationsChanged = false;

	local function OnSituationsChanged()
		--SetOutfitSituationsEnabled/UpdatePendingSituation below re-fire this event, guard against the recursion.
		if isHandlingSituationsChanged then return; end
		isHandlingSituationsChanged = true;

		local wipedTransmogs = EL.PendingSnapshot and not C_TransmogOutfitInfo.HasPendingOutfitTransmogs();
		local wipedSituations = EL.PendingSituations and not C_TransmogOutfitInfo.HasPendingOutfitSituations();

		if not (wipedTransmogs or wipedSituations) then
			CapturePending();
		else
			--Blizzard's own Situations auto-switch can silently discard pending edits, fight back with what we had.
			if wipedTransmogs then
				ApplyPendingSnapshot(EL.PendingSnapshot, EL.PendingShoulderSecondary, EL.PendingWeaponOptions);
			end
			if wipedSituations then
				EL.RestoreSituationsPending(EL.PendingSituations);
			end
		end

		isHandlingSituationsChanged = false;
	end

	local function OnTrackedEvent(_, event)
		if not EL.enabled then return end;

		if event == "VIEWED_TRANSMOG_OUTFIT_CHANGED" then
			ReapplyPendingOnOutfitSwitch();
		elseif event == "VIEWED_TRANSMOG_OUTFIT_SITUATIONS_CHANGED" then
			OnSituationsChanged();
		else
			CapturePending();
		end
	end

	local function TransmogFrame_OnShow()
		if not EL.enabled then return end;

		API.RegisterFrameForEvents(EL, TRACKED_EVENTS);

		if EL.PendingSnapshot or EL.PendingSituations then
			RestoreAllPending();
		end
	end

	local function TransmogFrame_OnHide()
		API.UnregisterFrameForEvents(EL, TRACKED_EVENTS);
	end

	local function OnStaticPopupShown(which, _, _, data)
		if which ~= "TRANSMOG_PENDING_CHANGES" or not EL.enabled then return; end
		local hasPending = C_TransmogOutfitInfo.HasPendingOutfitTransmogs() or C_TransmogOutfitInfo.HasPendingOutfitSituations();
		if not hasPending then return; end

		--Both appearance and situation pending changes now survive an outfit switch, so this warning is stale.
		StaticPopup_Hide(which, data);
		if data and data.confirmCallback then
			data.confirmCallback();
		end
	end

	--Only treat this as an intentional Undo while the frame is open, otherwise OnSituationsChanged
	--would fight back against it and recurse into a stack overflow (oops!). Blizzard also runs these on
	--every close (OnHide), and treating that as intentional too would break restore-on-reopen.
	local function HookExplicitClears()
		local originalClearTransmogs = C_TransmogOutfitInfo.ClearAllPendingTransmogs;
		C_TransmogOutfitInfo.ClearAllPendingTransmogs = function(...)
			if TransmogFrame:IsShown() then
				EL.PendingSnapshot = nil;
				EL.PendingShoulderSecondary = nil;
				EL.PendingWeaponOptions = nil;
				EL.SavePendingToDB();
			end
			return originalClearTransmogs(...);
		end;

		local originalClearSituations = C_TransmogOutfitInfo.ClearAllPendingSituations;
		C_TransmogOutfitInfo.ClearAllPendingSituations = function(...)
			if TransmogFrame:IsShown() then
				EL.PendingSituations = nil;
				EL.SavePendingToDB();
			end
			return originalClearSituations(...);
		end;
	end

	function EL.SnapshotFrame_OnLoad()
		if EL.snapshotHooked then return end;
		EL.snapshotHooked = true;

		EL:SetScript("OnEvent", OnTrackedEvent);
		TransmogFrame:HookScript("OnShow", TransmogFrame_OnShow);
		TransmogFrame:HookScript("OnHide", TransmogFrame_OnHide);
		-- If we decide not to disable/skip the popup, comment/remove this hooksecurefunc below.
		hooksecurefunc("StaticPopup_Show", OnStaticPopupShown);
		HookExplicitClears();

		if TransmogFrame:IsShown() then
			TransmogFrame_OnShow();
		end
	end
end


do
	local function EnableModule(state)
		if state and not EL.enabled then
			EL.enabled = true;
			EL.LoadPendingFromDB();
			addon.CallbackRegistry:RegisterAddOnLoadedCallback("Blizzard_Transmog", EL.SnapshotFrame_OnLoad);
		elseif (not state) and EL.enabled then
			EL.enabled = nil;
			addon.CallbackRegistry:UnregisterAddOnLoadedCallback("Blizzard_Transmog", EL.SnapshotFrame_OnLoad);
			EL.PendingSnapshot = nil;
			EL.PendingShoulderSecondary = nil;
			EL.PendingWeaponOptions = nil;
			EL.PendingSituations = nil;
			EL.PendingOutfitID = nil;
			EL.SavePendingToDB();
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
