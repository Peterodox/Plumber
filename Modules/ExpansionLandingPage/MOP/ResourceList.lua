local _, addon = ...
local LandingPageUtil = addon.LandingPageUtil;
local GetFactionStatusText = addon.API.GetFactionStatusText;


local TillersSubFactions = {
    1277,     --Chee Chee
    1275,     --Ella
    1282,     --Fish Fellreed
    1283,     --Farmer Fung
    1281,     --Gina Mudclaw
    1273,     --Jogu the Drunk
    1279,     --Haohan Mudclaw
    1276,     --Old Hillpaw
    1278,     --Sho
    1280,     --Tina Mudclaw
};

local function AppendTooltip_TillersSubFactions(tooltip)
    local status, factionName;
    local n = 0;
    for _, factionID in ipairs(TillersSubFactions) do
        status, factionName = GetFactionStatusText(factionID, true);
        if status and factionName then
            if n % 5 == 0 then
                tooltip:AddLine(" ");
            end
            n = n + 1;
            tooltip:AddDoubleLine(factionName, status, 1, 0.82, 0, 1, 1, 1);
        end
    end
end


local ResourceList = {
    {currencyID = 697},     --Elder Charm of Good Fortune
    {currencyID = 738},     --Lesser Charm of Good Fortune
    {currencyID = 402},     --Ironpaw Token


    {isHeader = true, name = " "},
    {faction = 1337},       --Klaxxi
    {faction = 1341},       --August Celestials
    {faction = 1269},       --Golden Lotus
    {faction = 1270},       --Shado-Pan
    {faction = 1271},       --Order of the Cloud Serpent
    {faction = 1269},       --Golden Lotus
    {faction = 1302},       --Anglers
    {faction = 1272, appendTooltipFunc = AppendTooltip_TillersSubFactions},       --Tillers

    --[[
    {faction = 1277},     --Chee Chee
    {faction = 1275},     --Ella
    {faction = 1282},     --Fish Fellreed
    {faction = 1283},     --Farmer Fung
    {faction = 1281},     --Gina Mudclaw
    {faction = 1273},     --Jogu the Drunk
    {faction = 1279},     --Haohan Mudclaw
    {faction = 1276},     --Old Hillpaw
    {faction = 1278},     --Sho
    {faction = 1280},     --Tina Mudclaw
    --]]
};
LandingPageUtil.ResourceList = ResourceList;