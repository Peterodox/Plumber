local _, addon = ...
local API = addon.API;

local GetPlayerFacing = GetPlayerFacing;    --noinstance North = 0, counterclockwise
local PI2 = 2*math.pi;
local RAD5 = 5*180*math.pi;
local deg = math.deg;
local floor = math.floor;


local MainFrame = CreateFrame("Frame", nil, UIParent);
MainFrame:SetSize(32, 32);
MainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
MainFrame.t = 0;

local ArrowTexture = MainFrame:CreateTexture(nil, "OVERLAY");
ArrowTexture:SetAllPoints(true);
ArrowTexture:SetTexture("Interface/AddOns/Plumber/Art/MapPin/DirectionArrow_Angle.png", nil, nil, "LINEAR");

local Title = MainFrame:CreateFontString(nil, "OVERLAY");

local function SetArrowRadian(radian)
    local n = floor( (deg(radian) + 2.5) * 0.2 ) + 1;    -- /5
    if n > 72 then
        n = 1;
    end
    local row = floor(n / 8);
    local col = floor(n % 8);
    if col == 0 then
        col = 8;
        row = row - 1;
    end
    col = col - 1;
    ArrowTexture:SetTexCoord(0.125*col, 0.125*col + 0.125, 0.0625*row, 0.0625*row + 0.0625);
end
SetArrowRadian(0);

MainFrame:SetScript("OnUpdate", function(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.016 then
        self.t = 0;
        self.facing = GetPlayerFacing();
        if self.facing then
            SetArrowRadian(self.facing);
        else

        end
    end
end);


--MainFrame:RegisterEvent("DISPLAY_SIZE_CHANGED");
--MainFrame:RegisterEvent("UI_SCALE_CHANGED");

MainFrame:SetScript("OnEvent", function(self, event, ...)
    local px = API.GetPixelForWidget(self);
    self:SetSize(64*px, 64*px);
end);