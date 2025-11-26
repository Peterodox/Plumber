-- Ping player arrow when opening the map and switching minized/maxized mode
-- Game Default Behavior: Ping the arrow when MapChanged
-- Is "UnitPositionFrame" susceptible to taint?


local _, addon = ...
local PinController = addon.MapPinController;
local WorldMapFrame = WorldMapFrame;


local Processor = {};
Processor.dbKey = "WorldMapPin_PlayerPing";
Processor.shouldChangeTexture = true;


function Processor:OnMapChanged(uiMapID, mapScale)
    local changeTexture = self.shouldChangeTexture;
    if changeTexture then
        self.shouldChangeTexture = nil;
    end

    for pin in (WorldMapFrame:EnumeratePinsByTemplate("GroupMembersPinTemplate")) do
        --pin:StartPlayerPing(2, 0.25);
        pin:StartPlayerPing(2.75, 0.5);

        if changeTexture then
            pin:SetPlayerPingTexture(Enum.PingTextureType.Center, "Interface/AddOns/Plumber/Art/MapPin/UI-Minimap-Ping-Center", 32, 32);    --"Interface\\minimap\\UI-Minimap-Ping-Center", 32, 32
            pin:SetPlayerPingTexture(Enum.PingTextureType.Expand, "Interface/AddOns/Plumber/Art/MapPin/UI-Minimap-Ping-Expand", 64, 64);    --"Interface\\minimap\\UI-Minimap-Ping-Expand", 32, 32
            pin:SetPlayerPingTexture(Enum.PingTextureType.Rotation, "Interface/AddOns/Plumber/Art/MapPin/UI-Minimap-Ping-Rotate", 128, 128);  --"Interface\\minimap\\UI-Minimap-Ping-Rotate", 70, 70
        end
    end
end

function Processor:OnModifiderStateChanged()
    self:OnMapChanged();
end

--[[
function Processor:OnCanvasScaleChanged(scale)
    if not scale then scale = WorldMapFrame.ScrollContainer.targetScale end;
    if (not scale) or scale == 0 then return end;

    local baseScale;
    if WorldMapFrame.isMaximized then
        baseScale = 0.8;
    else
        baseScale = 0.65;
    end
    local pingScale = baseScale / scale;

    for pin in (WorldMapFrame:EnumeratePinsByTemplate("GroupMembersPinTemplate")) do
        pin:SetPlayerPingScale(pingScale);
    end
end
--]]

PinController:AddMapProcessor(Processor);


do
    local function EnableModule(state)
        PinController:RequestLoadSettings();
    end

    local moduleData = {
        name = addon.L["ModuleName PlayerPing"],
        dbKey = Processor.dbKey,
        description = addon.L["ModuleDescription PlayerPing"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1102,
        moduleAddedTime = 1761240000,
        categoryKeys = {"Map"},
    };

    addon.ControlCenter:AddModule(moduleData);
end