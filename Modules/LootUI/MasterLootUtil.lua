local _, addon = ...
local LootUI = addon.LootUI; ---@class LootUISystem

local IS_PLAYER_MASTER_LOOTER = false;


function LootUI.IsMasterLooter()
	return IS_PLAYER_MASTER_LOOTER;
end

function LootUI.UpdateMasterLooter()
	-- Override
end


local LOOT_METHOD_MASTER = Enum.LootMethod.Masterlooter;
local IS_MASTER_LOOT_AVAILABLE = false;

if C_PartyInfo.GetAvailableLootMethods then
	for _, method in ipairs(C_PartyInfo.GetAvailableLootMethods()) do
		if method == LOOT_METHOD_MASTER then
			IS_MASTER_LOOT_AVAILABLE = true;
			break;
		end
	end

	IS_MASTER_LOOT_AVAILABLE = IS_MASTER_LOOT_AVAILABLE and C_EventUtils.IsEventValid("OPEN_MASTER_LOOT_LIST");
end

if not IS_MASTER_LOOT_AVAILABLE then return; end

local UnitIsUnit = UnitIsUnit;
local GetLootMethod = C_PartyInfo.GetLootMethod;

local function UpdateMasterLooter()
	local method, masterLootPartyID, masterLooterRaidID = GetLootMethod();
	local isPlayerMasterLooter = false;
	if method == LOOT_METHOD_MASTER then
		local unit;
		if masterLooterRaidID then
			unit = "raid"..masterLooterRaidID;
		elseif masterLootPartyID then
			if masterLootPartyID == 0 then
				isPlayerMasterLooter = true;
			else
				unit = "party"..masterLootPartyID;
			end
		end
		if unit and UnitIsUnit(unit, "player") then
			isPlayerMasterLooter = true;
		end
	end

	if isPlayerMasterLooter ~= IS_PLAYER_MASTER_LOOTER then
		IS_PLAYER_MASTER_LOOTER = isPlayerMasterLooter;
		LootUI.TryResolveSystemStatus();
	end
end
LootUI.UpdateMasterLooter = UpdateMasterLooter;

local EL = CreateFrame("Frame");
EL:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
EL:SetScript("OnEvent", function(self, event, ...)
	UpdateMasterLooter();
end);
