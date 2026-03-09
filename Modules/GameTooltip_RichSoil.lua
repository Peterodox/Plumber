local _, addon = ...
local L = addon.L;
local GameTooltipWorldObjectManager = addon.GameTooltipManager:GetWorldObjectManager();
local QuickSlot = addon.QuickSlot;
local GetMouseFocus = addon.API.GetMouseFocus;
local Secret_CanAccess = addon.API.Secret_CanAccess;
local GetItemCount = C_Item.GetItemCount;


local OBJECT_NAME = L["GameObject Rich Soil"];

local SupportedMap = {
    [2395] = true,  --Eversong Woods
    [2413] = true,  --Harandar
    [2437] = true,  --Zul'Aman
    [2536] = true,  --Atal'Aman
};

local ItemNameColor = {r = 1, g = 0.82, b = 0};

local QuickSlotData = {
    buttons = {
        {itemID = 237500, spellID = 1224758, actionType = "item", overrideColor = ItemNameColor},   --Primal
        {itemID = 237499, spellID = 1224759, actionType = "item", overrideColor = ItemNameColor},   --Wild
        {itemID = 237498, spellID = 1224738, actionType = "item", overrideColor = ItemNameColor},   --Glowing
        {itemID = 237497, spellID = 1223244, actionType = "item", overrideColor = ItemNameColor},   --Resilient Seed
    },
    systemName = "ResilientSeeds",
    spellcastType = 2,      --Channel
};


local function DoesPlayerHaveSeeds()
    for _, v in ipairs(QuickSlotData.buttons) do
        if GetItemCount(v.itemID) > 0 then
            return true
        end
    end
end

local function IsHerbalism(index)
    if index then
        local skillLine1 = select(7, GetProfessionInfo(index));
        if skillLine1 == 182 then
            return true
        end
    end
end

local function IsPlayerHerbalist()
    local prof1, prof2 = GetProfessions();
    return IsHerbalism(prof1) or IsHerbalism(prof2)
end


local EL = CreateFrame("Frame");
do
    EL.GetTime = GetTime;

    EL.AutoCloseEvents = {
        PLAYER_IS_GLIDING_CHANGED = true,
        PLAYER_STARTED_MOVING = true,
        LOOT_OPENED = true,
    }

    function EL:SetEnabled(state)
        if state then
            self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
            self:SetScript("OnEvent", self.OnEvent);
            self:UpdateZone();
        else
            self.isConditionMet = false;
            self:ListenAutoCloseEvents(false);
            self:ListenMouseEvent(false);
        end
    end

    function EL:UpdateZone(uiMapID)
        if not uiMapID then
            self.t = 0;
            self:SetScript("OnUpdate", self.OnUpdate);
            return
        end

        if (uiMapID and SupportedMap[uiMapID]) and IsPlayerHerbalist() then
            self.isConditionMet = true;
        else
            self.isConditionMet = false;
            self:ListenMouseEvent(false);
        end
    end

    function EL:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 2 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            self:UpdateZone(C_Map.GetBestMapForUnit("player"));
        end
    end

    function EL:OnEvent(event, ...)
        if event == "GLOBAL_MOUSE_DOWN" then
            local button = ...
            if button == "LeftButton" then
                local t = self.GetTime();
                if self.lastTime and t - self.lastTime < 0.5 then
                    self:ProcessDoubleClick();
                end
                self.lastTime = t;
            end
        elseif event == "ZONE_CHANGED_NEW_AREA" then
            self:UpdateZone();
        elseif self.AutoCloseEvents[event] then
            self:ShowQuickSlot(false);
        end
    end

    function EL:ListenMouseEvent(state)
        if state and (not self.listened) then
            self.listened = true;
            self:RegisterEvent("GLOBAL_MOUSE_DOWN");
        elseif (not state) and self.listened then
            self.listened = nil;
            self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
        end
    end

    function EL:ListenAutoCloseEvents(state)
        if state then
            for event in pairs(self.AutoCloseEvents) do
                self:RegisterEvent(event);
            end
        else
            for event in pairs(self.AutoCloseEvents) do
                self:UnregisterEvent(event);
            end
        end
    end

    function EL:ProcessDoubleClick()
        if GetMouseFocus() == nil then
            local isGliding = C_PlayerInfo.GetGlidingInfo();
            if isGliding then
                return
            end
            local info = C_TooltipInfo.GetWorldCursor();
            if info and info.lines and info.lines[1] and Secret_CanAccess(info.lines[1].leftText) then
                if info.lines[1].leftText == OBJECT_NAME then
                    self:ShowQuickSlot(true);
                end
            end
        else
            self:ListenMouseEvent(false);
        end
    end

    function EL:ShowQuickSlot(state)
        if state then
            self:ListenAutoCloseEvents(true);
            QuickSlot:SetButtonData(QuickSlotData);
            QuickSlot:ShowUI();
            QuickSlot:SetHeaderText("", true);
            QuickSlot:SetDefaultHeaderText("");
        else
            self:ListenAutoCloseEvents(false);
            QuickSlot:RequestCloseUI(QuickSlotData.systemName);
        end
    end
end


local SubModule = GameTooltipWorldObjectManager:CreateSubModule("TooltipRichSoil");
do
    function SubModule:ProcessData(tooltip, name)
        if self.enabled and EL.isConditionMet then
            if name == OBJECT_NAME then
                if DoesPlayerHaveSeeds() then
                    tooltip:AddLine(L["Instruction Show Resilient Seeds"], 0.1, 1, 0.1, true);
                    EL:ListenMouseEvent(true);
                else
                    tooltip:AddLine(L["No Resilient Seed"], 0.5, 0.5, 0.5, true);
                    EL:ListenMouseEvent(false);
                end
                return true
            else
                EL:ListenMouseEvent(false);
            end

            return false
        else
            return false
        end
    end
end


do
    local function AlertForNonHerbalist()
        if not IsPlayerHerbalist() or true then
            return "|cffd4641c"..UNIT_SKINNABLE_HERB.."|r"
        end
    end

    local function EnableModule(state)
        EL:SetEnabled(state);
        SubModule:SetEnabled(state);
    end

    local moduleData = {
        name = addon.L["ModuleName TooltipRichSoil"],
        dbKey = "TooltipRichSoil",
        description = addon.L["ModuleDescription TooltipRichSoil"],
        descriptionFunc = AlertForNonHerbalist,
        toggleFunc = EnableModule,
        moduleAddedTime = 1773000000,
		categoryKeys = {
			"Profession",
		},
        searchTags = {
            "Tooltip",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end
