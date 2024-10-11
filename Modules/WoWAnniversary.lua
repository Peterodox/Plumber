-- Mount Mania: Quick Slot, Summon Mount

local _, addon = ...
local API = addon.API;
local GetPlayerMapCoord = API.GetPlayerMapCoord;
local QuickSlot = addon.QuickSlot;


local EL = CreateFrame("Frame");


--local MOUNT_MANIAC_WIDGET_SET = 1329;       --widgetType: 13 (Enum.UIWidgetVisualizationType.SpellDisplay)
local WIDGET_ID_MOUNT_MANIAC_MOUNT = 6023;      --C_UIWidgetManager.GetSpellDisplayVisualizationInfo(6023).spellInfo.spellID
local WIDGET_ID_MOUNT_MANIAC_ACTIVE = 6339;     --

local GetSpellDisplayVisualizationInfo = C_UIWidgetManager.GetSpellDisplayVisualizationInfo;
local GetTextWithStateWidgetVisualizationInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo;
local GetMountFromSpell = C_MountJournal.GetMountFromSpell;
local GetMountInfoByID = C_MountJournal.GetMountInfoByID;

local QUICKSLOT_NAME = "mount_maniac";

function EL:UpdateMountButton()
    local widgetInfo = GetSpellDisplayVisualizationInfo(WIDGET_ID_MOUNT_MANIAC_MOUNT);
    if (widgetInfo and widgetInfo.spellInfo and widgetInfo.spellInfo.spellID and widgetInfo.spellInfo.shownState ~= 0) then
        local mountID = GetMountFromSpell(widgetInfo.spellInfo.spellID);
        if mountID then
            local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected = GetMountInfoByID(mountID);

            local title, colorizedName;
            if isCollected then
                title = "|TInterface/AddOns/Plumber/Art/Button/Checkmark-Green-Shadow:16:16:-4:-2|t"..name;
                colorizedName = "|cffffd100"..name.."|r";
            else
                title = "|TInterface/AddOns/Plumber/Art/Button/RedCross-Shadow:16:16:-4:-2|t"..name;
                colorizedName = "|cff999999"..name.."|r";
            end

            local data = {
                buttons = {
                    {actionType = "spell", spellID = spellID, icon = icon, name = colorizedName, macroText = "/cast "..name, enabled = isCollected},
                },
                systemName = QUICKSLOT_NAME,
                spellcastType = 1,      --Cast
            };

            QuickSlot:SetButtonData(data);
            QuickSlot:ShowUI();
            QuickSlot:SetHeaderText(title, true);
            QuickSlot:SetDefaultHeaderText(name);

            return true
        else
            return false
        end
    else
        return false
    end
end

function EL:IsMountEventActive()
    local info = GetTextWithStateWidgetVisualizationInfo(WIDGET_ID_MOUNT_MANIAC_ACTIVE);
    if info and info.shownState ~= 0 and info.enabledState ~= 0 then
        return true
    end
    return false
end

function EL:IsPlayerInMountEventArea()
    self.playerX, self.playerY = GetPlayerMapCoord(71);
    if self.playerX and self.playerY then
        if self.playerX > 0.6266 and self.playerY > 0.5122 and self.playerX < 0.6352 and self.playerY < 0.5197 then
            return true
        end
    end
    return false
end


function EL:ShowQuickSlot(state)
    if state then
        if not self.slotShown then
            if self:UpdateMountButton() then
                self.slotShown = true;
            end
            self:RegisterEvent("UPDATE_UI_WIDGET");
        end
    else
        if self.slotShown then
            self.slotShown = false;
            QuickSlot:RequestCloseUI(QUICKSLOT_NAME);
            self:UnregisterEvent("UPDATE_UI_WIDGET");
        end
    end
end

function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.5 then
        self.t = 0;
        if self:IsPlayerInMountEventArea() and self:IsMountEventActive() then
            self:ShowQuickSlot(true);
        else
            self:ShowQuickSlot(false);
        end
    end
end

function EL:WatchPlayerLocation(state)
    if state then
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    else
        self.t = 0;
        self:SetScript("OnUpdate", nil);
    end
end

function EL:OnEvent(event, ...)
    if event == "UPDATE_UI_WIDGET" then
        local widgetInfo = ...
        if widgetInfo.widgetID == WIDGET_ID_MOUNT_MANIAC_MOUNT then
            self:UpdateMountButton();
        end
    end
end

function EL:ListenEvents(state)
    if state then
        --self:RegisterEvent("UPDATE_UI_WIDGET");
        self:SetScript("OnEvent", self.OnEvent);
        self:WatchPlayerLocation(true);
    else
        self:UnregisterEvent("UPDATE_UI_WIDGET");
        self:SetScript("OnEvent", nil);
        self:WatchPlayerLocation(false);
    end
end

local function Debug_GetActiveEvent()
    local widgetSetID = C_UIWidgetManager.GetTopCenterWidgetSetID()
    local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID);
    for _, widget in pairs(widgets) do
        if widget.widgetType == 8 then
            local info = GetTextWithStateWidgetVisualizationInfo(widget.widgetID);
            if info and info.shownState ~= 0 and info.enabledState ~= 0 then
                print(widget.widgetID, info.text);
            end
        end
    end
end

local function Debug_GetPlayerCoord()
    print(GetPlayerMapCoord(71));
end


do
    local ZoneTriggerModule;

    local function EnableModule(state)
        if state then
            if not ZoneTriggerModule then
                local module = API.CreateZoneTriggeredModule("anniversary");
                ZoneTriggerModule = module;
                module:SetValidZones(71);   --Tanaris

                local function OnEnterZoneCallback()
                    EL:ListenEvents(true);
                end

                local function OnLeaveZoneCallback()
                    EL:ListenEvents(false);
                end

                module:SetEnterZoneCallback(OnEnterZoneCallback);
                module:SetLeaveZoneCallback(OnLeaveZoneCallback);
            end
            ZoneTriggerModule:SetEnabled(true);
            ZoneTriggerModule:Update();
        else
            if ZoneTriggerModule then
                ZoneTriggerModule:SetEnabled(false);
            end
            EL:ListenEvents(false);
            EL:ShowQuickSlot(false);
        end
    end

    EnableModule(true);



    local function ValidityCheck()
        if addon.IsToCVersionEqualOrNewerThan(110005) then
            return true
        end

        return time() > 1729400000
    end


    local moduleData = {
        name = addon.L["ModuleName WoWAnniversary"],
        dbKey = "WoWAnniversary",
        description = addon.L["ModuleDescription WoWAnniversary"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1150,
        moduleAddedTime = 1729500000,
        validityCheck = ValidityCheck,
    };

    addon.ControlCenter:AddModule(moduleData);
end


--[[
    --6337 Mount Mania (15 min)
    --6338 Mount Mania (5 min)
    --6339 Mount Mania (active)

    --6340 Story Time (15 min)
    --6341 Story Time (5 min)
    --6342 Story Time (active)

    --6343 Fashion Frenzy (15 min)
    --6344 Fashion Frenzy (5 min)
    --6345 Fashion Frenzy (active)
--]]