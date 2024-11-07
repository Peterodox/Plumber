local _, addon = ...

local GetHealthPercent = C_VignetteInfo.GetHealthPercent;
if not GetHealthPercent then return end;

local GetVignetteInfo = C_VignetteInfo.GetVignetteInfo;
local GetVignettes = C_VignetteInfo.GetVignettes;

local function TTT()
    --Enum.VignetteType

    local info, healthPct
    local vignetteGUIDs = GetVignettes();

    for i, vignetteGUID in ipairs(vignetteGUIDs) do
        info = GetVignetteInfo(vignetteGUID);
        if info then
            print(info.name, info.vignetteID, info.type);
            if info.type == 0 then
                healthPct = GetHealthPercent(info.vignetteGUID);
                print(healthPct)    --(v57361) Always nil
            end
        end
    end
end