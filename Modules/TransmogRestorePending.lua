local _, addon = ...
local L = addon.L;
local API = addon.API;

local EL = CreateFrame("Frame");
local SHOULDER_RIGHT = Enum.TransmogOutfitSlot.ShoulderRight;
local WEAPON_SLOTS = {
	[16] = Enum.TransmogOutfitSlot.WeaponMainHand,
	[17] = Enum.TransmogOutfitSlot.WeaponOffHand,
};

--True if two appearance snapshots match.
local function SameAppearance(liveInfo, recordedInfo)
	return liveInfo.appearanceID == recordedInfo.appearanceID
		and liveInfo.secondaryAppearanceID == recordedInfo.secondaryAppearanceID;
end


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

	--Right always wins, left mirrors it while separated unless left was set independently.
	--Once merged, right and left can share the same slot, so writing left too would override right back.
	function EL.ReapplyShoulderAppearance(transmogInfo, isSeparated)
		local transmogID = transmogInfo.appearanceID;
		SetPendingFromSlot(3, SHOULDER_RIGHT, transmogID);
		if isSeparated then
			local secondaryAppearanceID = transmogInfo.secondaryAppearanceID;
			if secondaryAppearanceID == 0 then
				--0 means the left shoulder was never set independently, mirror the right
				secondaryAppearanceID = transmogID;
			end
			SetPendingFromSlot(3, Enum.TransmogOutfitSlot.ShoulderLeft, secondaryAppearanceID);
		end
	end

	--Only replays the tracked pendingSlots, not the whole outfit.
	--Always writes, since right after switching outfits the character preview hasn't caught up yet.
	function EL.ApplySnapshotToPending(itemTransmogInfoList, pendingSlots)
		for invSlotID, transmogInfo in ipairs(itemTransmogInfoList) do
			if pendingSlots[invSlotID] then
				if invSlotID == 3 then
					EL.ReapplyShoulderAppearance(transmogInfo, true);
				else
					local slot = C_TransmogOutfitInfo.GetTransmogOutfitSlotFromInventorySlot(invSlotID - 1);
					SetPendingFromSlot(invSlotID, slot, transmogInfo.appearanceID);
				end
			end
		end
	end

	local function SlotHasPending(slot)
		local info = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(slot, Enum.TransmogType.Appearance, Enum.TransmogOutfitSlotOption.None);
		return info and info.hasPending;
	end

	--Which invSlotIDs have an unsaved change.
	--A slot stays tracked while its value still matches what we last set, even once Blizzard stops calling it pending.
	function EL.CapturePendingSlots(liveList, previousSnapshot, previousSlots)
		local pendingSlots = {};
		local shoulderSecondary;
		for invSlotID = 1, 19 do
			if not IgnoredInvSlots[invSlotID] then
				local hasPending;
				if invSlotID == 3 then
					--Either shoulder counts, the left one is its own slot only while separate shoulders are on
					hasPending = SlotHasPending(SHOULDER_RIGHT) or SlotHasPending(Enum.TransmogOutfitSlot.ShoulderLeft);
					if hasPending then
						--Only capture when fresh, a switch briefly resets this and reading it then would lose our value
						shoulderSecondary = C_TransmogOutfitInfo.GetSecondarySlotState(SHOULDER_RIGHT);
					end
				else
					local slot = C_TransmogOutfitInfo.GetTransmogOutfitSlotFromInventorySlot(invSlotID - 1);
					hasPending = slot and SlotHasPending(slot);
				end

				if hasPending then
					pendingSlots[invSlotID] = true;
				elseif previousSlots and previousSlots[invSlotID] then
					local liveInfo = liveList[invSlotID];
					local recordedInfo = previousSnapshot and previousSnapshot[invSlotID];
					if liveInfo and recordedInfo and SameAppearance(liveInfo, recordedInfo) then
						pendingSlots[invSlotID] = true;
					end
				end
			end
		end
		return pendingSlots, shoulderSecondary;
	end

	function EL.RestoreShoulderSecondaryState(enabled)
		if enabled ~= nil then
			C_TransmogOutfitInfo.SetSecondarySlotState(SHOULDER_RIGHT, enabled);
		end
	end

	local function FindPreviousWeaponOption(previousWeaponOptions, invSlotID, weaponOption)
		for _, record in ipairs(previousWeaponOptions or {}) do
			if record[1] == invSlotID and record[2] == weaponOption then
				return record;
			end
		end
	end

	--Records are {invSlotID, weaponOption, transmogID, illusionID, sheatheCategory}, false marks a field as not captured.
	--previous keeps a value tracked the same way EL.CapturePendingSlots does.
	local function CaptureWeaponOptionRecord(invSlotID, slot, weaponOption, previous)
		local transmogID, illusionID, sheatheCategory;

		local appearanceInfo = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(slot, Enum.TransmogType.Appearance, weaponOption);
		if appearanceInfo then
			if appearanceInfo.hasPending then
				transmogID = appearanceInfo.transmogID;
				sheatheCategory = appearanceInfo.sheatheCategory;
			elseif previous and previous[3] and appearanceInfo.transmogID == previous[3] then
				transmogID = previous[3];
				sheatheCategory = appearanceInfo.sheatheCategory;
			end
		end

		local illusionInfo = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(slot, Enum.TransmogType.Illusion, weaponOption);
		if illusionInfo then
			if illusionInfo.hasPending then
				illusionID = illusionInfo.transmogID;
			elseif previous and previous[4] and illusionInfo.transmogID == previous[4] then
				illusionID = previous[4];
			end
		end

		if transmogID or illusionID then
			return {invSlotID, weaponOption, transmogID or false, illusionID or false, sheatheCategory or false};
		end
	end

	--Shared so the same capture logic runs for both weaponOptionsInfo and artifactOptionsInfo without duplicating it
	local function CaptureOptionsInfoList(weaponOptionsPending, previousWeaponOptions, invSlotID, slot, optionsInfo)
		if not optionsInfo then return weaponOptionsPending; end

		for _, optionInfo in ipairs(optionsInfo) do
			if optionInfo.enabled then
				local previous = FindPreviousWeaponOption(previousWeaponOptions, invSlotID, optionInfo.weaponOption);
				local record = CaptureWeaponOptionRecord(invSlotID, slot, optionInfo.weaponOption, previous);
				if record then
					weaponOptionsPending = weaponOptionsPending or {};
					table.insert(weaponOptionsPending, record);
				end
			end
		end

		return weaponOptionsPending;
	end

	function EL.CaptureWeaponOptionsPending(previousWeaponOptions)
		local weaponOptionsPending;
		for invSlotID, slot in pairs(WEAPON_SLOTS) do
			--Artifact spec options use separate enum values, so they never collide with the weapon options here
			local weaponOptionsInfo, artifactOptionsInfo = C_TransmogOutfitInfo.GetWeaponOptionsForSlot(slot);
			weaponOptionsPending = CaptureOptionsInfoList(weaponOptionsPending, previousWeaponOptions, invSlotID, slot, weaponOptionsInfo);
			weaponOptionsPending = CaptureOptionsInfoList(weaponOptionsPending, previousWeaponOptions, invSlotID, slot, artifactOptionsInfo);
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
		"VIEWED_TRANSMOG_OUTFIT_SECONDARY_SLOTS_CHANGED", -- Separate shoulders toggled
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

	--EL.PendingSlots is a set of invSlotIDs, saved and loaded as a simple comma-joined list.
	local function SerializePendingSlots(pendingSlots)
		local list = {};
		for invSlotID in pairs(pendingSlots) do
			table.insert(list, invSlotID);
		end
		if #list == 0 then return nil; end
		table.sort(list);
		return table.concat(list, ",");
	end

	local function DeserializePendingSlots(str)
		local pendingSlots = {};
		if str then
			for token in str:gmatch("[^,]+") do
				pendingSlots[tonumber(token)] = true;
			end
		end
		return pendingSlots;
	end

	local function SavePendingToDB()
		if not PlumberDB_PC then return end;

		--Saved on its own, separate from pending edits, so it survives even with nothing pending.
		PlumberDB_PC.TransmogRestoreLastOutfit = EL.LastViewedOutfitID;

		if EL.PendingSnapshot or EL.PendingSituations then
			--SerializeSnapshot expects a real list, only call it when there's actually a snapshot
			local snapshot = EL.PendingSnapshot and SerializeSnapshot(EL.PendingSnapshot);
			PlumberDB_PC.TransmogRestorePending = {
				snapshot = snapshot,
				shoulderSecondary = EL.PendingShoulderSecondary,
				weaponOptions = EL.PendingWeaponOptions,
				situations = EL.PendingSituations,
				pendingSlots = EL.PendingSlots and SerializePendingSlots(EL.PendingSlots),
			};
		else
			PlumberDB_PC.TransmogRestorePending = nil;
		end
	end
	EL.SavePendingToDB = SavePendingToDB;

	function EL.LoadPendingFromDB()
		EL.LastViewedOutfitID = PlumberDB_PC and PlumberDB_PC.TransmogRestoreLastOutfit;

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
			--Older Plumber versions didn't record this, better to restore nothing than the whole outfit
			EL.PendingSlots = EL.PendingSnapshot and DeserializePendingSlots(saved.pendingSlots);
		end
	end

	local isRestoringPending = false;

	local function CapturePending()
		if not EL.enabled or isRestoringPending then return end;

		local liveList = TransmogFrame.CharacterPreview:GetItemTransmogInfoList();
		--Kept even when nothing's pending, so the separate-shoulders fix has a value to fall back to.
		EL.LiveShoulderInfo = liveList[3];
		--Tracked even when nothing's pending, so later checks can tell if the outfit actually changed.
		EL.LastViewedOutfitID = C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID();
		local pendingSlots, shoulderSecondary = EL.CapturePendingSlots(liveList, EL.PendingSnapshot, EL.PendingSlots);
		local weaponOptions = EL.CaptureWeaponOptionsPending(EL.PendingWeaponOptions);
		local hasTransmogsPending = next(pendingSlots) ~= nil or weaponOptions ~= nil;

		if hasTransmogsPending then
			EL.PendingSnapshot = liveList;
			EL.PendingSlots = pendingSlots;
			EL.PendingWeaponOptions = weaponOptions;
			if shoulderSecondary ~= nil then
				EL.PendingShoulderSecondary = shoulderSecondary;
			end
		else
			EL.PendingSnapshot = nil;
			EL.PendingSlots = nil;
			EL.PendingWeaponOptions = nil;
			EL.PendingShoulderSecondary = nil;
		end

		local hasSituationsPending = C_TransmogOutfitInfo.HasPendingOutfitSituations();
		EL.PendingSituations = hasSituationsPending and EL.CaptureSituationsPending() or nil;

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

	local function GetShoulderSlotFrame(isSeparated)
		local slot = isSeparated and Enum.TransmogOutfitSlot.ShoulderLeft or SHOULDER_RIGHT;
		return TransmogFrame.CharacterPreview:GetSlotFrame(slot, Enum.TransmogType.Appearance);
	end

	--Slot frames get released and recreated on every outfit switch, so track the slot enum instead of the frame.
	local function OnSlotSelected(_, slotFrame)
		local transmogLocation = slotFrame and slotFrame.slotData and slotFrame.slotData.transmogLocation;
		EL.LastSelectedSlot = transmogLocation and transmogLocation:GetSlot();
	end

	--Always reselects explicitly, Blizzard can clear the left shoulder before our pending restore re-separates it.
	local function ReselectShoulderOnOutfitSwitch()
		if EL.LastSelectedSlot ~= Enum.TransmogOutfitSlot.ShoulderLeft then return; end

		local slotFrame = GetShoulderSlotFrame(true) or GetShoulderSlotFrame(false);
		if slotFrame then
			TransmogFrame:SelectSlot(slotFrame, true);
		end
	end

	local function ApplyPendingSnapshot(snapshot, pendingSlots, shoulderSecondary, weaponOptions)
		if not snapshot then return; end

		EL.ForceWeaponSlotWidgetRebuild();

		--Must run before ApplySnapshotToPending, toggling this after would wipe the left shoulder's pending value
		EL.RestoreShoulderSecondaryState(shoulderSecondary);
		EL.ApplySnapshotToPending(snapshot, pendingSlots or {});
		--Must run after ApplySnapshotToPending, setting a weapon's appearance resets its sheathe category to Default
		EL.RestoreWeaponOptionsPending(weaponOptions);
	end

	local function RestoreAllPending()
		--Nothing is cleared first, the carry-forward check needs the old values while replaying.
		--isRestoringPending blocks our own writes from being treated as new edits until the real one lands.
		isRestoringPending = true;
		--With nothing pending, Blizzard's own default outfit is fine as is.
		if EL.PendingSnapshot then
			RestoreViewedOutfit(EL.LastViewedOutfitID);
		end
		ApplyPendingSnapshot(EL.PendingSnapshot, EL.PendingSlots, EL.PendingShoulderSecondary, EL.PendingWeaponOptions);
		EL.RestoreSituationsPending(EL.PendingSituations);
		isRestoringPending = false;
		--If we ever want to notify the user their outfit was restored, this is where it'd happen.
	end

	local function ReapplyPendingOnOutfitSwitch()
		--Tracked even when nothing's pending, so later checks can tell if the outfit actually changed.
		EL.LastViewedOutfitID = C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID();
		if EL.PendingSnapshot or EL.PendingSituations then
			isRestoringPending = true;
			--The user already landed on the outfit they picked, just replay the edits onto it.
			ApplyPendingSnapshot(EL.PendingSnapshot, EL.PendingSlots, EL.PendingShoulderSecondary, EL.PendingWeaponOptions);
			EL.RestoreSituationsPending(EL.PendingSituations);
			isRestoringPending = false;
		end
		ReselectShoulderOnOutfitSwitch();
	end

	local isHandlingSituationsChanged = false;

	--HasPendingOutfitTransmogs reads false once a tracked slot just happens to match its outfit.
	--So the wipe check below compares actual values instead of trusting that flag.
	local function PendingStillApplied()
		if EL.PendingSnapshot and EL.PendingSlots then
			local liveList = TransmogFrame.CharacterPreview:GetItemTransmogInfoList();
			for invSlotID in pairs(EL.PendingSlots) do
				local liveInfo = liveList[invSlotID];
				local recordedInfo = EL.PendingSnapshot[invSlotID];
				if not (liveInfo and recordedInfo and SameAppearance(liveInfo, recordedInfo)) then
					return false;
				end
			end
		end

		if EL.PendingWeaponOptions then
			for _, record in ipairs(EL.PendingWeaponOptions) do
				local invSlotID, weaponOption, transmogID, illusionID = record[1], record[2], record[3], record[4];
				local slot = WEAPON_SLOTS[invSlotID];
				if transmogID then
					local info = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(slot, Enum.TransmogType.Appearance, weaponOption);
					if not (info and info.transmogID == transmogID) then return false; end
				end
				if illusionID then
					local info = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(slot, Enum.TransmogType.Illusion, weaponOption);
					if not (info and info.transmogID == illusionID) then return false; end
				end
			end
		end

		return true;
	end

	local function OnSituationsChanged()
		--Restores below re-fire this event, guard against the recursion.
		if isHandlingSituationsChanged then return; end
		isHandlingSituationsChanged = true;

		local wipedTransmogs = (EL.PendingSnapshot or EL.PendingWeaponOptions) and not PendingStillApplied();
		--Situations only need fighting back when the outfit just changed, not on a same-outfit toggle.
		local isOutfitSwitch = EL.LastViewedOutfitID and EL.LastViewedOutfitID ~= C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID();
		local wipedSituations = isOutfitSwitch and EL.PendingSituations and not C_TransmogOutfitInfo.HasPendingOutfitSituations();

		if not (wipedTransmogs or wipedSituations) then
			CapturePending();
		else
			isRestoringPending = true;
			if wipedTransmogs then
				ApplyPendingSnapshot(EL.PendingSnapshot, EL.PendingSlots, EL.PendingShoulderSecondary, EL.PendingWeaponOptions);
			end
			if wipedSituations then
				EL.RestoreSituationsPending(EL.PendingSituations);
			end
			isRestoringPending = false;
		end

		isHandlingSituationsChanged = false;
	end

	--Blizzard doesn't carry the shoulder appearance across this toggle.
	--Uses EL.LiveShoulderInfo instead of a fresh read, which could already show the same reset.
	local function FixShoulderSecondaryToggle()
		if EL.LiveShoulderInfo then
			local isSeparated = C_TransmogOutfitInfo.GetSecondarySlotState(SHOULDER_RIGHT);
			EL.ReapplyShoulderAppearance(EL.LiveShoulderInfo, isSeparated);
		end

		--Re-merging shoulders clears the left shoulder slot selection, which then defaults to head.
		--Re-select the right shoulder instead.
		if not TransmogFrame.CharacterPreview:GetSelectedSlotData() then
			local rightSlotFrame = GetShoulderSlotFrame(false);
			if rightSlotFrame then
				TransmogFrame:SelectSlot(rightSlotFrame, true);
			end
		end
	end

	local function OnTrackedEvent(_, event)
		--Our own writes fire these same events, and so can Blizzard's close sequence before OnHide unregisters us.
		--A stray capture in either case would look like everything just got reverted.
		if not EL.enabled or isRestoringPending or not TransmogFrame:IsShown() then return end;

		if event == "VIEWED_TRANSMOG_OUTFIT_CHANGED" then
			ReapplyPendingOnOutfitSwitch();
		elseif event == "VIEWED_TRANSMOG_OUTFIT_SITUATIONS_CHANGED" then
			OnSituationsChanged();
		elseif event == "VIEWED_TRANSMOG_OUTFIT_SECONDARY_SLOTS_CHANGED" then
			FixShoulderSecondaryToggle();
		else
			CapturePending();
		end
	end

	local function TransmogFrame_OnShow()
		if not EL.enabled then return end;

		API.RegisterFrameForEvents(EL, TRACKED_EVENTS);
		RestoreAllPending();
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

	--Only treated as a real Undo while the frame is open, otherwise OnSituationsChanged fights back into a stack overflow (oops!).
	--Blizzard also calls these on every close, so treating that the same way would break restore-on-reopen.
	local function HookExplicitClears()
		local originalClearTransmogs = C_TransmogOutfitInfo.ClearAllPendingTransmogs;
		C_TransmogOutfitInfo.ClearAllPendingTransmogs = function(...)
			if TransmogFrame:IsShown() then
				EL.PendingSnapshot = nil;
				EL.PendingSlots = nil;
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

		--A save commits pending changes permanently, our carry-forward tracking would otherwise keep them marked pending forever.
		local originalCommitAllPending = C_TransmogOutfitInfo.CommitAndApplyAllPending;
		C_TransmogOutfitInfo.CommitAndApplyAllPending = function(...)
			if TransmogFrame:IsShown() then
				EL.PendingSnapshot = nil;
				EL.PendingSlots = nil;
				EL.PendingShoulderSecondary = nil;
				EL.PendingWeaponOptions = nil;
				EL.PendingSituations = nil;
				EL.SavePendingToDB();
			end
			return originalCommitAllPending(...);
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
		hooksecurefunc(TransmogFrame, "SelectSlot", OnSlotSelected);
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
			EL.PendingSlots = nil;
			EL.PendingShoulderSecondary = nil;
			EL.PendingWeaponOptions = nil;
			EL.PendingSituations = nil;
			EL.LastViewedOutfitID = nil;
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
