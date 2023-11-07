-- Show how many to-be-donated items you have on the bottom right of PlayerChoiceFrame

local _, addon = ...

if not addon.IsGame_10_2_0 then
    return
end

local API = addon.API;
local GetCreatureIDFromGUID = API.GetCreatureIDFromGUID;
local TokenDisplay;
local TimerFrame;

--[[
local PlayerChoiceXCurrency = {
    [723] = 2650,       --Dreamseed (Ysera's Clover): Plump Dreamseed, Emerald Dewdrop  --widgetSetID 918, buttonID: 2314, 2315         --object:208633
    [732] = 2650,       --Dreamseed (Singing Weedling): Gigantic Dreamseed, Emerald Dewdrop  --widgetSetID 873, buttonID: 2286, 2287    --object:208635
    [741] = 2650,       --Dreamseed (Lofty Lupin)
    [749] = 2650,       --Dreamseed (Viridescent Sprout)    --widgetSetID 936, buttonID: 2331, 2332 (changed after reload)
    [769] = 2650,       --Dreamseed (outdoor): Gigantic Dreamseed, Emerald Dewdrop
    [782] = 2650,       --Dreamseed: Emerald Dewdrop
    [783] = 2650,       --Dreamseed: Emerald Dewdrop
    [784] = 2650,       --Dreamseed: Emerald Dewdrop
};
--]]

local GUIDXCurrency = {};

do
    local DreamseedBloom = {
        211142, 211143, 211120, 208463, 208633,
        208635, 211091, 211126, 211130, 211219,
        211091, 211221,
    };

    for _, creatureID in ipairs(DreamseedBloom) do
        GUIDXCurrency[creatureID] = 2650;   --Emerald Dewdrop
    end
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

    local creatureID = GetCreatureIDFromGUID( f.choiceInfo.objectGUID );

    if GUIDXCurrency[creatureID] then
        if not TokenDisplay then
            TokenDisplay = addon.CreateTokenDisplay(UIParent);
        end
        TokenDisplay:DisplayCurrencyOnFrame(f, "BOTTOMRIGHT", GUIDXCurrency[creatureID]);
        local remainingTime, fullTime = API.GetActiveDreamseedGrowthTimes();
        if remainingTime and fullTime then
            if not TimerFrame then
                TimerFrame = addon.CreateTimerFrame(TokenDisplay);
                TimerFrame:SetReverse(true);
                TimerFrame:SetStyle(2);
                TimerFrame:SetWidth(192);
                TimerFrame:SetBarColor(218/255, 218/255, 34/255)
                TimerFrame:UpdateMaxBarFillWidth();
            end
            TimerFrame:SetPoint("BOTTOM", f, "BOTTOM", 0, 236);
            --print(remainingTime, fullTime)
            TimerFrame:Show();
            TimerFrame:SetTimes(fullTime - remainingTime, fullTime);
        end
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
        EL:SetScript("OnUpdate", nil);
        HideWigets();
    end
end

do
    local moduleData = {
        name = addon.L["ModuleName PlayerChoiceFrameToken"],
        dbKey = "PlayerChoiceFrameToken",
        description = addon.L["ModuleDescription PlayerChoiceFrameToken"],
        toggleFunc = EnableModule,
    };

    addon.ControlCenter:AddModule(moduleData);
end