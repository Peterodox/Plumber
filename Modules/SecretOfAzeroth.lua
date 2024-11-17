--Show Toy Quick Slot in quest area when the buff is missing and the quest is incomplete

local _, addon = ...
local API = addon.API;
local QuickSlot = addon.QuickSlot;
local QuestAreaTrigger = addon.QuestAreaTrigger;

local QUICKSLOT_NAME = "secret_of_azeroth";

local QuestData = {
    [84363] = { --Tweasure Hunt

    };
}

local function OnQuestAreaChanged(questID, isInside)
    print(API.GetQuestName(questID), questID, isInside);
    if isInside then
        
    else

    end
end

for questID in pairs(QuestData) do
    QuestAreaTrigger:AddAreaChangedCallback(questID, OnQuestAreaChanged);
end