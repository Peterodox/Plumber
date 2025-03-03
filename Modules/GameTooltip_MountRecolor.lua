local _, addon = ...
local GameTooltipItemManager = addon.GameTooltipManager:GetItemManager();
local TOOLTIP_TEXT_1 = addon.L["Color Applied"];

local GetMountInfoExtraByID = C_MountJournal.GetMountInfoExtraByID;

local ItemIDXInfo = {
    --[itemID] = {displayID, textureIndex}

    [233493] = {126133, 1},     --Teal
    [233494] = {126134, 2},     --Muddy Brown
    [233495] = {126135, 3},     --Inky Black
    [233497] = {126136, 4},     --Kaja'Cola Bright Green
    --No 233496
    [233498] = {126137, 5},     --Storminfused Pale Blue
    [233499] = {126138, 6},     --Royal Purple
    [233500] = {126139, 7},     --Crimson Red
    [233501] = {126140, 8},     --Sandy
};

local TextureInfo_Snapdragon_Base = {
    file = "Interface/AddOns/Plumber/Art/Tooltip/PrismaticSnapdragon.jpg",
    width = 236,        --4:3 (FontString Max Width)
    height = 177,
    anchor = 0,         --Enum.TooltipTextureAnchor.LeftTop
    region = 0,         --Enum.TooltipTextureRelativeRegion.LeftLine
    verticalOffset = 0,
    margin = {left = 0, right = -4, top = 0, bottom = 4},
    texCoords = {left = 0, right = 320/1024, top = 0, bottom = 240/1024},
    vertexColor = {r = 1, g = 1, b = 1, a = 1},
};

local ItemSubModule = {};

function ItemSubModule:ProcessData(tooltip, itemID)
    if self.enabled then
        local info = ItemIDXInfo[itemID];
        if info then
            local currentDisplayID = GetMountInfoExtraByID(2469);   --Prismatic Snapdragon
            local isCurrentChoice = currentDisplayID == info[1];
            local row = math.ceil(info[2] / 3);
            local col = info[2] - 3 * (row - 1);

            TextureInfo_Snapdragon_Base.margin.bottom = isCurrentChoice and 4 or 0;
            TextureInfo_Snapdragon_Base.texCoords.left = (col - 1) * 320/1024;
            TextureInfo_Snapdragon_Base.texCoords.right = col * 320/1024;
            TextureInfo_Snapdragon_Base.texCoords.top = (row - 1) * 240/1024;
            TextureInfo_Snapdragon_Base.texCoords.bottom = row * 240/1024;

            tooltip:AddLine(" ");
            tooltip:AddLine(" ");   --Texture is added to the beginning of the last line
            tooltip:AddTexture(TextureInfo_Snapdragon_Base.file, TextureInfo_Snapdragon_Base);

            if isCurrentChoice then
                tooltip:AddLine(TOOLTIP_TEXT_1);
            end

            return true
        end
    end
    return false
end

function ItemSubModule:GetDBKey()
    return "TooltipSnapdragonTreats"
end

function ItemSubModule:SetEnabled(enabled)
    self.enabled = enabled == true
    GameTooltipItemManager:RequestUpdate();
end

function ItemSubModule:IsEnabled()
    return self.enabled == true
end

do
    local function EnableModule(state)
        if state then
            ItemSubModule:SetEnabled(true);
            GameTooltipItemManager:AddSubModule(ItemSubModule);
        else
            ItemSubModule:SetEnabled(false);
        end
    end

    local moduleData = {
        name = addon.L["ModuleName TooltipSnapdragonTreats"],
        dbKey = ItemSubModule:GetDBKey(),
        description = addon.L["ModuleDescription TooltipSnapdragonTreats"],
        toggleFunc = EnableModule,
        categoryID = 3,
        uiOrder = 1150,
        moduleAddedTime = 1726674500,
    };

    addon.ControlCenter:AddModule(moduleData);
end