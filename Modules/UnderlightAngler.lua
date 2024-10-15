-- Fix Underlight Angler traits not showing bug
-- The Cause: Artifact power and link's visiblity is determined by C_ArtifactUI.GetArtifactTier(), it wrongfully returns 0 for Underlight Angler

local _, addon = ...
local GetArtifactItemID = C_ArtifactUI.GetArtifactItemID;


local EL = CreateFrame("Frame");

EL.events = {
    "ARTIFACT_UPDATE",
};

function EL:OnEvent(event, ...)
    if event == "ARTIFACT_UPDATE" then
        local itemID = GetArtifactItemID();
        if (not self.apiModified) and itemID == 133755 then
            self.apiModified = true;
            self.OnEvent = nil;
            self:ListenEvents(false);

            local Old_GetArtifactTier = C_ArtifactUI.GetArtifactTier;

            local function New_GetArtifactTier()
                local itemID = GetArtifactItemID();
                local tier = Old_GetArtifactTier();
                if itemID == 133755 then
                    return math.max(tier, 1)
                else
                    return tier
                end
            end
            C_ArtifactUI.GetArtifactTier = New_GetArtifactTier;


            ArtifactFrame.PerksTab:Refresh();
        end
    end
end

function EL:ListenEvents(state)
    if state then
        if not self.listened then
            self.listened = true;
            for _, event in ipairs(self.events) do
                self:RegisterEvent(event);
            end
            self:SetScript("OnEvent", self.OnEvent);
        end
    elseif self.listened then
        self.listened = nil;
        for _, event in ipairs(self.events) do
            self:UnregisterEvent(event);
        end
        self:SetScript("OnEvent", nil);
    end
end

do
    local function EnableModule(state)
        if state then
            EL:ListenEvents(true);
        else
            EL:ListenEvents(false);
        end
    end

    local moduleData = {
        name = addon.L["ModuleName BlizzFixFishingArtifact"],
        dbKey = "BlizzFixFishingArtifact",
        description = addon.L["ModuleDescription BlizzFixFishingArtifact"],
        toggleFunc = EnableModule,
        categoryID = 2,
        uiOrder = 10,
        moduleAddedTime = 1728990000,
    };

    addon.ControlCenter:AddModule(moduleData);
end

--[[
/script for k, v in pairs(ArtifactFrame.PerksTab.powerIDToPowerButton) do v:Show() end
--]]