local _, addon = ...
local L = addon.L;
local API = addon.API;
local LandingPageUtil = addon.LandingPageUtil;


local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted;
local IsQuestFlaggedCompletedOnAccount = C_QuestLog.IsQuestFlaggedCompletedOnAccount;
local GetQuestClassification = C_QuestInfoSystem.GetQuestClassification;
local IsOnQuest = C_QuestLog.IsOnQuest;
local ReadyForTurnIn = C_QuestLog.ReadyForTurnIn;


local QuestIconAtlas = {
	[Enum.QuestClassification.Normal] = 	"QuestNormal",
	[Enum.QuestClassification.Questline] = 	"QuestNormal",
	[Enum.QuestClassification.Recurring] =	"quest-recurring-available",
	[Enum.QuestClassification.Meta] = 		"quest-wrapper-available",
	[Enum.QuestClassification.Calling] = 	"Quest-DailyCampaign-Available",
	[Enum.QuestClassification.Campaign] = 	"Quest-Campaign-Available",
	[Enum.QuestClassification.Legendary] =	"UI-QuestPoiLegendary-QuestBang",
	[Enum.QuestClassification.Important] =	"importantavailablequesticon",
};

local function GetQuestIcon(questID)
    --return: isAtlas, value

    if ReadyForTurnIn(questID) then
        return true, "QuestTurnin"
    else
        local qc = GetQuestClassification(questID);
        local isOnQuest = IsOnQuest(questID);
        if isOnQuest then
            if qc == 3 or qc == 4 or qc == 5 or qc == 10 then
                --Calling, Meta, Recurring, WorldQuest
                return false, "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png"
            else
                return false, "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressRed.png"
            end
        else
            return true, (QuestIconAtlas[qc] or "QuestNormal")
        end
    end
end
API.GetQuestIcon = GetQuestIcon;


local function GetQuestData(questID)
    local data = {};
    local qc = GetQuestClassification(questID);

    data.questClassification = qc;
    data.isOnQuest = IsOnQuest(questID);
    data.readyForTurnIn = ReadyForTurnIn(questID);
    data.completed = IsQuestFlaggedCompleted(questID);
    data.warbandCompleted = IsQuestFlaggedCompletedOnAccount(questID);

    if data.readyForTurnIn then
        data.iconAtlas = "QuestTurnin";
    else
        if data.isOnQuest then
            if qc == 3 or qc == 4 or qc == 5 or qc == 10 then
                --Calling, Meta, Recurring, WorldQuest
                data.iconFile = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressBlue.png"
            else
                data.iconFile = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressRed.png"
            end
        else
            data.iconAtlas = QuestIconAtlas[qc] or "QuestNormal";
        end
    end

    return data
end
API.GetQuestData = GetQuestData;


local function IsQuestCompleted(questID, checkWarband)
    if IsQuestFlaggedCompleted(questID) then
        return true
    end

    if checkWarband and IsQuestFlaggedCompletedOnAccount(questID) then
        return true
    end
end
API.IsQuestCompleted = IsQuestCompleted;



--Rares
do
    local KnownCreatureFlagQuests = {

        --Ringing  Deeps
        [218393] = 80003,       --Disturbed Earthgorger
        [220265] = 81674,       --Automaxor
        [220266] = 81511,       --Coalesced Monstrosity
        [220267] = 81562,       --Charmonger
        [220268] = 80574,       --Trungal
        [220269] = 80560,       --Cragmund
        [220270] = 80506,       --Zilthara
        [220271] = 80507,       --Terror of the Forge
        [220272] = 81566,       --Deathbound Husk
        [220273] = 81563,       --Rampaging Blight
        [220274] = 80557,       --Aquellion
        [220275] = 80547,       --King Splash
        [220276] = 80505,       --Candleflyer Captain
        [220285] = 81633,       --Lurker of the Deeps
        [220286] = 80536,       --Deepflayer Broodmother
        [220287] = 81485,       --Kelpmire
        [221199] = 81648,       --Hungerer of the Deeps
        [221217] = 81652,       --Spore-infused Shalewing


        --Hallowsfall
        [206184] = 82559,       --Deathpetal
        [206203] = 82557,       --Moth'ethk
        [206514] = 82558,       --Crazed Cabbage Smacker
        [206977] = 82563,       --Parasidious
        [207780] = 82564,       --Finclaw Bloodtide
        [207802] = 81763,       --Beledar's Spawn
        [207803] = 82561,       --Toadstomper
        [207826] = 82566,       --Ravageant
        [214757] = 82560,       --Croakit
        [215805] = 79271,       --Sloshmuck
        [218426] = 80006,       --Ixlorb the Spinner
        [218444] = 80009,       --The Taskmaker
        [218452] = 80010,       --Murkshade
        [218458] = 80011,       --Deepfiend Azellix
        [220771] = 82565,       --Murkspike
        [221179] = 82562,       --Duskshadow
        [221534] = 81756,       --Lytfang the Lost
        [221551] = 81761,       --Grimslice
        [221648] = 81791,       --The Perchfather
        [221668] = 81836,       --Horror of the Shallows
        [221690] = 81849,       --Strength of Beledar
        [221708] = 81853,       --Sir Alastair Purefire
        [221753] = 81880,       --Deathtide
        [221767] = 81881,       --Funglour
        [221786] = 81882,       --Pride of Beledar

    };

    local function IsRareCreatureKilled(creatureID, flagQuestID, accountwide)
        flagQuestID = KnownCreatureFlagQuests[creatureID] or flagQuestID;
        return flagQuestID and (IsQuestFlaggedCompleted(flagQuestID) or (accountwide and IsQuestFlaggedCompletedOnAccount(flagQuestID)))
    end
    API.IsRareCreatureKilled = IsRareCreatureKilled;

    local function GetKnownRareFlagQuest(creatureID)
        return KnownCreatureFlagQuests[creatureID]
    end
    API.GetKnownRareFlagQuest = GetKnownRareFlagQuest;
end