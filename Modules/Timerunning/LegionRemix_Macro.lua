local _, addon = ...
local RemixAPI = addon.RemixAPI
if not RemixAPI then return end;


local GetActiveArtifactAbility = RemixAPI.DataProvider.GetActiveArtifactAbility;


addon.CallbackRegistry:Register("TimerunningSeason", function(seasonID)
    if seasonID == 2 then
        local LegionArtifactCommand = {
            command = "lart",
            name = addon.L["Module Category Timerunning"],
            modifyType = "Overwrite",

            events = {
                "TRAIT_CONFIG_UPDATED",
                --"SPELLS_CHANGED",
            },

            writeFunc = function(body)
                local header = "#plumber:lart";
                local icon = 134400;    --This will reset macro icon and change it to spell texture
                local spellID = GetActiveArtifactAbility();
                local text;
                if spellID then
                    local spellName = C_Spell.GetSpellName(spellID);
                    if spellName then
                        text = "#showtooltip "..spellName.."\n/cast "..spellName;
                        return header.."\n"..text, icon
                    end
                end
            end,

            conditionFunc = function ()
                return GetActiveArtifactAbility();
            end,
        };
        addon.AddPlumberMacro(LegionArtifactCommand);
    end
end);