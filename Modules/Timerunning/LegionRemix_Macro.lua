local _, addon = ...
local RemixAPI = addon.RemixAPI
if not RemixAPI then return end;


local GetActiveArtifactAbility = RemixAPI.DataProvider.GetActiveArtifactAbility;
local GetSpellName = C_Spell.GetSpellName;

local COMMAND_LART = "lart";    --Legion Artifact
local UNKNOWN = addon.L["Spell Not Known"];

local function WriteFunc_lart(body)
    local header = "#plumber:"..COMMAND_LART;
    local icon = 134400;    --This will reset macro icon and change it to spell texture
    local spellID = GetActiveArtifactAbility();
    local text;
    if spellID then
        local spellName = GetSpellName(spellID);
        if spellName then
            text = "#showtooltip "..spellName.."\n/cast "..spellName;
            return header.."\n"..text, icon
        end
    else
        text = "#"..UNKNOWN;
        return header.."\n"..text, icon
    end
end

addon.CallbackRegistry:Register("TimerunningSeason", function(seasonID)
    if seasonID == 2 then
        local LegionArtifactCommand = {
            command = COMMAND_LART,
            name = addon.L["Artifact Ability"],
            modifyType = "Overwrite",

            events = {
                "TRAIT_CONFIG_UPDATED",
                --"SPELLS_CHANGED",
            },

            writeFunc = WriteFunc_lart,

            conditionFunc = function ()
                return GetActiveArtifactAbility();
            end,
        };
        addon.AddPlumberMacro(LegionArtifactCommand);
    end
end);

local function Generator_lart()
    local name = addon.L["Artifact Ability"];
    local body, icon = WriteFunc_lart();
    if not body then
        body = "#plumber:"..COMMAND_LART;
        icon = 134400;
    end
    return name, icon, body
end

function RemixAPI.AcquireArtifactAbilityMacro()
    return addon.AcquireCharacterMacro(COMMAND_LART, Generator_lart)
end