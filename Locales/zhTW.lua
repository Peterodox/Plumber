if not (GetLocale() == "zhTW") then return end;

local _, addon = ...
local L = addon.L;




-- !! Do NOT translate the following entries
L["currency-2706"] = "幼龍";
L["currency-2707"] = "飛龍";
L["currency-2708"] = "巨龍";
L["currency-2709"] = "守護巨龍";

L["currency-2914"] = "陳舊";
L["currency-2915"] = "雕刻";
L["currency-2916"] = "符文";
L["currency-2917"] = "鍍金";


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "豐碩探究";
L["Special Assignment"] = "特殊任務";


L["Match Patter Rep 1"] = "戰隊的(.+)聲望提高([%d%,]+)";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Patter Rep 2"] = "你於(.+)的聲望提高了([%d%,]+)";   --FACTION_STANDING_INCREASED