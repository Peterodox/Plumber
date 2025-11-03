local _, addon = ...
local LandingPageUtil = addon.LandingPageUtil;


local GetLFGQueuedList = GetLFGQueuedList;
local GetLFGProposal = GetLFGProposal;
local GetLFGRoleUpdate = GetLFGRoleUpdate;
local GetPartyLFGID = GetPartyLFGID;
local GetLFGCategoryForID = GetLFGCategoryForID;
local GetLFGQueueStats = GetLFGQueueStats;
local GetLFGMode = GetLFGMode;


local LE_LFG_CATEGORY_RF = LE_LFG_CATEGORY_RF or 3;


--[[
    LE_LFG_CATEGORY_LFD = 1,    --LOOKING_FOR_DUNGEON
    LE_LFG_CATEGORY_LFR = 2,    --LOOKING_FOR_RAID
    LE_LFG_CATEGORY_RF = 3,     --RAID_FINDER
    LE_LFG_CATEGORY_SCENARIO = 4,   --SCENARIOS

    LFG_QUEUE_STATUS_UPDATE
    LFG_UPDATE ?
--]]


--Use cache for getting LFG info

local EL = CreateFrame("Frame");


function EL:OnEvent(event, ...)
    self.t = 1;
end

function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.2 then
        self.t = 0;
        self:SetScript("OnUpdate", nil);
        self:ClearCache();
    end
end

function EL:ClearCache()
    self.queuedList = nil;
    self:ListenEvents(false);
end

function EL:ListenEvents(state)
    if state == self.state then return end;
    self.state = state;

    if state then
        self:SetScript("OnEvent", self.OnEvent);
        self:RegisterEvent("LFG_UPDATE");
        self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE");
    else
        self:SetScript("OnEvent", nil);
        self:UnregisterEvent("LFG_UPDATE");
        self:UnregisterEvent("LFG_QUEUE_STATUS_UPDATE");
    end
end

function EL:FullUpdate()
    local category = LE_LFG_CATEGORY_RF;

    local queuedList = GetLFGQueuedList(category);
    self.queuedList = queuedList;

    local proposalExists, id, typeID, subtypeID, name, texture, role, hasResponded, totalEncounters, completedEncounters, numMembers, isLeader, isHoliday, proposalCategory = GetLFGProposal();
	if proposalCategory == category then
		queuedList[id] = true;
	end

	local roleCheckInProgress, slots, members, roleUpdateCategory, roleUpdateID = GetLFGRoleUpdate();
	if roleUpdateCategory == category then
		queuedList[roleUpdateID] = true;
	end

	local partySlot = GetPartyLFGID();
	if partySlot and GetLFGCategoryForID(partySlot) == category then
		queuedList[partySlot] = true;
	end

    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate);
    self:ListenEvents(true);
end

do  --Dungeon Finder
    --[[
    function YeetJoinableDungeons()
        for i = 1, GetNumRandomDungeons() do
            local id, name = GetLFGRandomDungeonInfo(i);
            local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id);
            if isAvailableForAll then
                print(id, name);
            end
        end
    end
    --]]
end

do  --"Public" Method
    function LandingPageUtil.IsQueuingDungeon(lfgDungeonID)
        if not EL.queuedList then
            EL:FullUpdate();
        end
        if EL.queuedList then
            return EL.queuedList[lfgDungeonID]
        end
    end

    function LandingPageUtil.GetLFGDisabledReason()
        local lfgListDisabled;
        if C_LFGList.HasActiveEntryInfo() then
            lfgListDisabled = CANNOT_DO_THIS_WHILE_LFGLIST_LISTED;
        elseif C_PartyInfo.IsCrossFactionParty() then
            lfgListDisabled = CROSS_FACTION_RAID_DUNGEON_FINDER_ERROR;
        end
        return lfgListDisabled
    end

    function LandingPageUtil.TryJoinLFG(lfgDungeonID)
        if C_LFGList.HasActiveEntryInfo() or C_PartyInfo.IsCrossFactionParty() then
            return false
        end

        if not LandingPageUtil.IsQueuingDungeon(lfgDungeonID) then
            local category = LE_LFG_CATEGORY_RF;
            ClearAllLFGDungeons(category);
            SetLFGDungeon(category, lfgDungeonID);
            JoinSingleLFG(category, lfgDungeonID);

            return true
        end
    end

    function LandingPageUtil.GetQueueStatus()
        if not EL.queuedList then
            EL:FullUpdate();
        end
        if not EL.queuedList then return end;

        local category = LE_LFG_CATEGORY_RF;
        local activeID = select(18, GetLFGQueueStats(category));
        local mode, submode;

        for queueID in pairs(EL.queuedList) do
            mode, submode = GetLFGMode(category, queueID);
            if mode then
                if mode ~= "queued" and mode ~= "listed" and mode ~= "suspended" then
                    activeID = queueID;
                    break
                elseif not activeID then
                    activeID = queueID;
                    break
                end
            end
        end

        if not activeID then return end;

        --TO-DO: Show queue progress
        local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS, instanceType, instanceSubType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats(category, activeID);
        --print(instanceName, averageWait, queuedTime);
        --print(tankNeeds, healerNeeds, dpsNeeds, totalTanks, totalHealers, totalDPS);

        --tankNeeds: remaining number
    end
end