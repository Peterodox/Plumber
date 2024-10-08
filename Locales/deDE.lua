if not (GetLocale() == "deDE") then return end;

local _, addon = ...
local L = addon.L;


--Rare/Location Announcement
L["Seed Color Epic"] = "Violett";   --Using GlobalStrings as defaults


--Generic
L["Number Thousands"] = "K";        --15K  15,000
L["Number Millions"] = " Mio.";     --1.5M 1,500,000


-- !! Do NOT translate the following entries
L["currency-2706"] = "Welpen";
L["currency-2707"] = "Drachen";
L["currency-2708"] = "Wyrms";
L["currency-2709"] = "Aspekts";

L["currency-2914"] = "Verwittertes";
L["currency-2915"] = "Geschnitztes";
L["currency-2916"] = "Runenverziertes";
L["currency-2917"] = "Vergoldetes";


L["Delve Chest 1 Rare"] = "Großzügiger Kasten";


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "Großzügige Tiefe";
L["Special Assignment"] = "Spezialauftrag";


L["Match Patter Rep 1"] = "Der Ruf der Kriegsmeute bei der Fraktion '(.+)' hat sich um ([%d%,]+) verbessert";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Patter Rep 2"] = "Euer Ruf bei der Fraktion '(.+)' hat sich um ([%d%,]+) verbessert";   --FACTION_STANDING_INCREASED