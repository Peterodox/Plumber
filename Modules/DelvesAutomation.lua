local _, addon = ...
local API = addon.API;


local EL = CreateFrame("Frame");

function EL:PLAYER_IN_DELVES(inDelves)
    if inDelves then
        self:RegisterEvent("PLAYER_CHOICE_UPDATE");
    else
        self:UnregisterEvent("PLAYER_CHOICE_UPDATE");
    end
end

function EL:OnEvent(event, ...)
    if event == "PLAYER_CHOICE_UPDATE" then
        local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo();
        if not choiceInfo then return end;

        if choiceInfo.options and #choiceInfo.options == 1 then
            local optionInfo = choiceInfo.options[1];
            if not (optionInfo.buttons and #optionInfo.buttons == 1 and optionInfo.spellID) then return end;
            local header = optionInfo.header;
            local spellID = optionInfo.spellID;
            local responseID = optionInfo.buttons[1].id;
            local quality = (optionInfo.rarity or 0) + 1; --Enum.PlayerChoiceRarity is ItemQuality -1
            C_PlayerChoice.SendPlayerChoiceResponse(responseID);
            C_PlayerChoice.OnUIClosed();
            if addon.GetDBBool("LootUI") then
                local data = {
                    spellID = spellID,
                    name = header,
                    quality = quality,
                    subtitle = addon.L["Power Borrowed"],
                }
                addon.LootWindow:QueueDisplaySpell(data);
            end
            local text = string.format("|Hspell:%d:0|h[%s]|h", spellID, header);
            local msg = string.format("|cffffd100%s|r %s", addon.L["Auto Select"], ColorManager.GetFormattedStringForItemQuality(text, quality));
            API.PrintMessage(msg);
        end
    end
end

function EL.EnableModule(state)
    if state then
        addon.CallbackRegistry:Register("PLAYER_IN_DELVES", EL.PLAYER_IN_DELVES, EL);
        EL:SetScript("OnEvent", EL.OnEvent);
        if API.IsInDelves() then
            EL:PLAYER_IN_DELVES(true);
        end
    else
        addon.CallbackRegistry:UnregisterCallback("PLAYER_IN_DELVES", EL.PLAYER_IN_DELVES, EL);
        EL:UnregisterEvent("PLAYER_CHOICE_UPDATE");
        EL:SetScript("OnEvent", nil);
    end
end

do  --Module Registry
    local moduleData = {
        name = addon.L["ModuleName Delves_Automation"],
        dbKey = "Delves_Automation",
        description = addon.L["ModuleDescription Delves_Automation"],
        toggleFunc = EL.EnableModule,
        categoryID = 2,
        uiOrder = 25,
        moduleAddedTime = 1758032000,
    };

    addon.ControlCenter:AddModule(moduleData);
end