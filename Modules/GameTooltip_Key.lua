local _, addon = ...
local L = addon.L;
local API = addon.API;

local GetMapID = API.GetMapID;
local StripHyperlinks = StripHyperlinks;
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
local GetItemName = C_Item.GetItemNameByID;
local GetItemCount = C_Item.GetItemCount;
local GetItemIcon = C_Item.GetItemIconByID;
local find = string.find;
local GetMinimapZoneText = GetMinimapZoneText;

local KEY_QUANTITY_FORMAT = "%d / %d |T%s:16:16|t";

local POSTCALL_ADDED = false;
local MODULE_ENABLED = false;
local IN_VALID_ZONE = false;

local NAME_KEYS = {
    --Name = {type, id, requiredQuantity}     --type: 0(currency) 1(item) (get object name from itemID)
    ["Delve Chest 1 Rare"] = {0, 3028, 1, 228942},
};

for _, data in pairs(NAME_KEYS) do
    if data[4] then
        GetItemName(data[4]);
    end
end

local DOOR = L["GameObject Door"];

local ZONE_DOORS = {
    --Some objects have genric names like "door"
    --We use the minimap zone text to determine if it's the door we want
};

local SUPPORTED_MAPS = {};

do
    local DELVE_INSTANCE = {
        2664,
        2679,
        2680,
        2681,
        2682,
        2683,
        2684,
        2685,
        2686,
        2687,
        2688,
        2689,
        2690,
        2767,
    };

    for _, mapID in ipairs(DELVE_INSTANCE) do
        SUPPORTED_MAPS[mapID] = true;
    end
end


local EL = CreateFrame("Frame");

local REQUEST_COUNTER = 0;

local function LocalizeNames()
    REQUEST_COUNTER = REQUEST_COUNTER + 1;
    if REQUEST_COUNTER > 3 then
        return
    end

    local ZskeraVault = {
        72953, 72954, 72955,
    };

    local ZskeraVaultKey = {1, 202196, 1};

    local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID;
    local reload = false;

    for _, questID in ipairs(ZskeraVault) do
        local name = GetTitleForQuestID(questID);
        if name and name ~= "" then
            ZONE_DOORS[name] = ZskeraVaultKey;
        else
            reload = true;
        end
    end

    if reload then
        C_Timer.After(0.25, function()
            LocalizeNames();
        end);
    end

    if MODULE_ENABLED and IN_VALID_ZONE then
        EL:UpdateZone();
    end
end


local function Post_GetWorldCursor(tooltip, tooltipData)
    if not (MODULE_ENABLED and IN_VALID_ZONE) then return end;

    local name = tooltipData.lines and tooltipData.lines[1] and tooltipData.lines[1].leftText;
    if name and name ~= "" then
        name = StripHyperlinks(name);

        if NAME_KEYS[name] then
            local data = NAME_KEYS[name];
            local type = data[1];
            local id = data[2];
            local numRequired = data[3];
            local keyName, numOwned, icon;

            if type == 0 then
                local currencyInfo = GetCurrencyInfo(id);
                if currencyInfo then
                    keyName = currencyInfo.name;
                    numOwned = currencyInfo.quantity;
                    icon = currencyInfo.iconFileID;
                end
            elseif type == 1 then
                keyName = GetItemName(id)
                numOwned = GetItemCount(id);
                icon = GetItemIcon(id);
            end

            if numOwned then
                if numOwned < numRequired then
                    tooltip:AddDoubleLine(keyName, string.format(KEY_QUANTITY_FORMAT, numRequired, numOwned, icon), 1.000, 0.125, 0.125, 1.000, 0.125, 0.125);
                else
                    tooltip:AddDoubleLine(keyName, string.format(KEY_QUANTITY_FORMAT, numRequired, numOwned, icon));
                end

                tooltip:Show();
            end
        end
    end
end




EL:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_MAP_CHANGED" then
        local oldMapID, newMapID = ...
        self:UpdateZone(newMapID);
    end
end);

function EL:UpdateZone(newMapID)
    local mapID = newMapID or GetMapID();
    if mapID and SUPPORTED_MAPS[mapID] then
        IN_VALID_ZONE = true;
    else
        IN_VALID_ZONE = false;
    end
end




local function EnableModule(state)
    if state then
        MODULE_ENABLED = true;

        if not POSTCALL_ADDED then
            POSTCALL_ADDED = true;
            if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
                local tooltipType = 4;  --World Object
                TooltipDataProcessor.AddTooltipPostCall(tooltipType, Post_GetWorldCursor);
            else
                print("Plumber: WoW API Changed (TooltipDataProcessor.AddTooltipPostCall)");
            end

            for localeKey, data in pairs(NAME_KEYS) do
                local name = GetItemName(228942) or L[localeKey];
                if name then
                    NAME_KEYS[name] = data;
                end
            end

            LocalizeNames();
            --]]
        end

        EL:RegisterEvent("PLAYER_MAP_CHANGED");
        EL:UpdateZone();
    else
        MODULE_ENABLED = false;
        EL:UnregisterEvent("PLAYER_MAP_CHANGED");
    end
end

do
    local moduleData = {
        name = addon.L["ModuleName TooltipChestKeys"],
        dbKey = "TooltipChestKeys",
        description = addon.L["ModuleDescription TooltipChestKeys"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1110,
        moduleAddedTime = 1718500000,
    };

    addon.ControlCenter:AddModule(moduleData);
end
