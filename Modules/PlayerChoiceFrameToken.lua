-- Show how many to-be-donated items you have on the bottom right of PlayerChoiceFrame

local _, addon = ...

local GetCreatureIDFromGUID = addon.API.GetCreatureIDFromGUID;
local TokenDisplay;
local TimerFrame;


local PlayerChoiceXCurrency = {
    --[choiceID] = {type, id}     --type: 0(currency) 1(item)
    [832] = {1, 220520},    --Radian Echo, Worldsoul Memory: The Worldcarvers
    [838] = {1, 212493},    --
    [841] = {0, 3090},      --Flame-Blessed Iron (Siren Isle Command Map)
};

do  --Radian Echo
    local RadianEcho = {1, 220520};
    local target = PlayerChoiceXCurrency[832];
    PlayerChoiceXCurrency[827] = target;    --Worldsoul Memory: Primal Predators
    PlayerChoiceXCurrency[829] = target;    --Worldsoul Memory: A Wounded Soul
    PlayerChoiceXCurrency[830] = target;    --Worldsoul Memory: Old Gods Forsaken
    PlayerChoiceXCurrency[831] = target;    --Worldsoul Memory: Ancient Explorers
end



local GUIDXCurrency = {};

do

end

local EL = CreateFrame("Frame");

local function HideWigets()
    if TokenDisplay then
        TokenDisplay:HideTokenFrame();
    end
    if TimerFrame then
        TimerFrame:Hide();
        TimerFrame:Clear();
    end
end

local function UpdateChoiceCurrency()
    local f = PlayerChoiceFrame;

    if not (f and f:IsShown() and f.choiceInfo and f.choiceInfo.choiceID and f.choiceInfo.objectGUID) then
        HideWigets();
        return
    end

    local choiceID = f.choiceInfo.choiceID;
    local itemType, tokenInfo;
    --print(choiceID)   --debug
    if PlayerChoiceXCurrency[choiceID] then
        itemType = 0;
        tokenInfo = PlayerChoiceXCurrency[choiceID];
    else
        local creatureID = GetCreatureIDFromGUID(f.choiceInfo.objectGUID);
        if GUIDXCurrency[creatureID] then
            itemType = 0;
            tokenInfo = GUIDXCurrency[creatureID];
        end
    end

    if tokenInfo then
        if not TokenDisplay then
            TokenDisplay = addon.CreateTokenDisplay(f);
        end
        TokenDisplay:DisplayCurrencyOnFrame(tokenInfo, f, "BOTTOM"); --BOTTOMRIGHT
    else
        HideWigets();
    end
end

local function EL_OnUpdate(self, elapsed)
    self:SetScript("OnUpdate", nil);
    UpdateChoiceCurrency();
end



EL:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_CHOICE_UPDATE" then
        self:RegisterEvent("PLAYER_CHOICE_CLOSE");
        self:SetScript("OnUpdate", EL_OnUpdate);
    elseif event == "PLAYER_CHOICE_CLOSE" then
        self:UnregisterEvent(event);
        self:SetScript("OnUpdate", nil);
        HideWigets();
    end
end);

local function EnableModule(state)
    if state then
        EL:RegisterEvent("PLAYER_CHOICE_UPDATE");
        EL:RegisterEvent("PLAYER_CHOICE_CLOSE");
    else
        EL:UnregisterEvent("PLAYER_CHOICE_UPDATE");
        EL:UnregisterEvent("PLAYER_CHOICE_CLOSE");
        HideWigets();
    end
end

do
    local moduleData = {
        name = addon.L["ModuleName PlayerChoiceFrameToken"],
        dbKey = "PlayerChoiceFrameToken",
        description = addon.L["ModuleDescription PlayerChoiceFrameToken"],
        toggleFunc = EnableModule,
        categoryID = 2,
        uiOrder = 5,
        moduleAddedTime = 1718500000,
    };

    addon.ControlCenter:AddModule(moduleData);
end