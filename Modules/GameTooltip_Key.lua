local _, addon = ...
local L = addon.L;
local API = addon.API;
local GameTooltipWorldObjectManager = addon.GameTooltipManager:GetWorldObjectManager();

local GetMapID = API.GetMapID;
local StripHyperlinks = API.StripHyperlinks;
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
local GetItemName = C_Item.GetItemNameByID;
local GetItemCount = C_Item.GetItemCount;
local GetItemIcon = C_Item.GetItemIconByID;

local KEY_QUANTITY_FORMAT = "%d / %d |T%s:16:16|t";

local NAME_KEYS = {
    --Name = {type, id, requiredQuantity}     --type: 0(currency) 1(item) (get object name from itemID)
    ["Delve Chest 1 Rare"] = {0, 3028, 1, 228942},
};

for _, data in pairs(NAME_KEYS) do
    if data[4] then
        GetItemName(data[4]);
    end
end

local SUPPORTED_MAPS = {};

do
    local DELVE_INSTANCE = {    --/dump GetInstanceInfo()
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
        2815,
        2826,
        2803,
    };

    for _, mapID in ipairs(DELVE_INSTANCE) do
        SUPPORTED_MAPS[mapID] = true;
    end
end


local SubModule = GameTooltipWorldObjectManager:CreateSubModule("TooltipChestKeys");
do
    function SubModule:ProcessData(tooltip, name)
        if self.enabled and self.inValidZone then
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
                        tooltip:AddDoubleLine(keyName, string.format(KEY_QUANTITY_FORMAT, numOwned, numRequired, icon), 1.000, 0.125, 0.125, 1.000, 0.125, 0.125);
                    else
                        tooltip:AddDoubleLine(keyName, string.format(KEY_QUANTITY_FORMAT, numOwned, numRequired, icon));
                    end
                    return true
                end
            end

            return false
        else
            return false
        end
    end
end


local EL = CreateFrame("Frame");

EL:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_MAP_CHANGED" then
        local oldMapID, newMapID = ...
        self:UpdateZone(newMapID);
    end
end);

function EL:UpdateZone(newMapID)
    local mapID = newMapID or GetMapID();
    if mapID and SUPPORTED_MAPS[mapID] then
        SubModule.inValidZone = true;
    else
        SubModule.inValidZone = false;
    end
end


local function EnableModule(state)
    SubModule:SetEnabled(state);

    if state then
        for localeKey, data in pairs(NAME_KEYS) do
            local name = GetItemName(228942) or L[localeKey];
            if name then
                NAME_KEYS[name] = data;
            end
        end
        EL:RegisterEvent("PLAYER_MAP_CHANGED");
        EL:UpdateZone();
    else
        EL:UnregisterEvent("PLAYER_MAP_CHANGED");
    end
end

do
    local moduleData = {
        name = addon.L["ModuleName TooltipChestKeys"],
        dbKey = "TooltipChestKeys",
        description = addon.L["ModuleDescription TooltipChestKeys"],
        toggleFunc = EnableModule,
        categoryID = 3,
        uiOrder = 1110,
        moduleAddedTime = 1718500000,
		categoryKeys = {
			"Instance",
		},
        searchTags = {
            "Tooltip",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end
