local _, addon = ...
local L = addon.L;
local API = addon.API;
local Housing = addon.Housing;


local EL = CreateFrame("Frame");
EL.watchedType = Enum.HousingItemToastType.Decor or 3;


local function OpenCatalogFrameToEntry(decorID)
    local info = Housing.GetCatalogDecorInfo(decorID);

    if not HousingDashboardFrame then
        C_AddOns.LoadAddOn("Blizzard_HousingDashboard");
    end

    ShowUIPanel(HousingDashboardFrame);
    HousingDashboardFrame:SetTab(HousingDashboardFrame.catalogTab);
    C_Timer.After(0.5, function()
        HousingDashboardFrame.CatalogContent.PreviewFrame:PreviewCatalogEntryInfo(info);
    end);
end

local function PreviewHousingDecorID(decorID)
    HousingFramesUtil.PreviewHousingDecorID(decorID);
end


function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.2 then
        self.t = 0;
        self:SetScript("OnUpdate", nil);
        self:UnregisterEvent("HOUSE_DECOR_ADDED_TO_CHEST");
    end
end

function EL:OnEvent(event, ...)
    if event == "NEW_HOUSING_ITEM_ACQUIRED" then
        local itemType, itemName, icon = ...
        if itemType == self.watchedType then
            self:WatchItem(itemName);
        end
    elseif event == "HOUSE_DECOR_ADDED_TO_CHEST" then
        self:OnHouseDecorAdded(...);
    end
end

function EL:WatchItem(itemName)
    if not itemName then return end;

    if not self.nameXDecor then
        self.nameXDecor = {};
    end

    if self.nameXDecor[itemName] and self.nameXDecor[itemName] ~= 0 then
        return
    else
        self.nameXDecor[itemName] = 0;
    end

    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate);
    self:RegisterEvent("HOUSE_DECOR_ADDED_TO_CHEST");
end

function EL:OnHouseDecorAdded(decorGUID, decorID)
    local name = C_HousingDecor.GetDecorName(decorID);
    if name and self.nameXDecor then
        if self.nameXDecor[name] and self.nameXDecor[name] == 0 then
            self.nameXDecor[name] = decorID;
        end
    end
end

function EL:GetDecorIDByName(name)
    if self.nameXDecor and self.nameXDecor[name] and self.nameXDecor[name] ~= 0 then
        return self.nameXDecor[name]
    end
end


local HookedAlert = {};

local function AlertFrame_OnClick(self, button)
    if not EL.enabled then return end;

    if button == "LeftButton" then
        if API.CheckAndDisplayErrorIfInCombat() then
            return
        end
        local name = self.DecorName:GetText();
        local decorID = EL:GetDecorIDByName(name);
        if decorID then
            PreviewHousingDecorID(decorID);
        end
    end
end


local function EnableModule(state)
    if state and not EL.enabled then
        EL.enabled = true;
        EL:SetScript("OnEvent", EL.OnEvent);
        EL:RegisterEvent("NEW_HOUSING_ITEM_ACQUIRED");

        if not EL.systemHooked then
            EL.systemHooked = true;
            local AlertSystem = HousingItemEarnedAlertFrameSystem;
            if AlertSystem and AlertSystem.setUpFunction then
                hooksecurefunc(AlertSystem, "setUpFunction", function(frame, rewardData)  --HousingItemEarnedAlertFrameSystem_SetUp
                    if (EL.enabled) and not HookedAlert[frame] then
                        HookedAlert[frame] = true;
                        frame:HookScript("OnClick", AlertFrame_OnClick);
                    end
                end);
            end
        end
    elseif (not state) and EL.enabled then
        EL.enabled = nil;

        EL:UnregisterEvent("NEW_HOUSING_ITEM_ACQUIRED");
        EL:UnregisterEvent("HOUSE_DECOR_ADDED_TO_CHEST");
    end
end


do
    local moduleData = {
        name = L["ModuleName Housing_ItemAcquiredAlert"],
        dbKey ="Housing_ItemAcquiredAlert",
        description = L["ModuleDescription Housing_ItemAcquiredAlert"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1,
        moduleAddedTime = 1766000000,
		categoryKeys = {
			"Housing",
		},
        searchTags = {
            "Housing",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end