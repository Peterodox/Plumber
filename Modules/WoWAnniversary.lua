-- Mount Mania: Quick Slot, Summon Mount
-- Fashion Frenzy: Leaderboard, Click to Target Player

local _, addon = ...
local API = addon.API;
local L = addon.L;
local GetPlayerMapCoord = API.GetPlayerMapCoord;
local QuickSlot = addon.QuickSlot;
local CreateFrame = CreateFrame;

local EL = CreateFrame("Frame");
local UIParent = UIParent;
local VoteCounter;

--local MOUNT_MANIAC_WIDGET_SET = 1329;       --widgetType: 13 (Enum.UIWidgetVisualizationType.SpellDisplay)
local WIDGET_ID_MOUNT_MANIAC_MOUNT = 6023;      --C_UIWidgetManager.GetSpellDisplayVisualizationInfo(6023).spellInfo.spellID
local WIDGET_ID_MOUNT_MANIAC_ACTIVE = 6339;     --
local WIDGET_ID_FASHION_ACTIVE = 6345;
local SPELL_ID_RIBBON = 452010;

local GetSpellDisplayVisualizationInfo = C_UIWidgetManager.GetSpellDisplayVisualizationInfo;
local GetTextWithStateWidgetVisualizationInfo = C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo;
local GetMountFromSpell = C_MountJournal.GetMountFromSpell;
local GetMountInfoByID = C_MountJournal.GetMountInfoByID;
local GetMountInfoExtraByID = C_MountJournal.GetMountInfoExtraByID;
local GetBuffDataByIndex = C_UnitAuras.GetBuffDataByIndex;
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo;
local time = time;

local QUICKSLOT_NAME = "mount_maniac";


local function IsOnMount(mountSpellID)
    local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex;
    local i = 1;
    local spellID = 0;
    local aura;

    while spellID do
        aura = GetAuraDataByIndex("player", i, "HELPFUL");
        spellID = aura and aura.spellId;
        if spellID then
            if spellID == mountSpellID then
                return true
            end
            i = i + 1;
        else
            break
        end
    end

    return false
end

function EL:UpdateMountButton()
    local widgetInfo = GetSpellDisplayVisualizationInfo(WIDGET_ID_MOUNT_MANIAC_MOUNT);
    if (widgetInfo and widgetInfo.spellInfo and widgetInfo.spellInfo.spellID and widgetInfo.spellInfo.shownState ~= 0) then
        local mountID = GetMountFromSpell(widgetInfo.spellInfo.spellID);
        if mountID then
            local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected = GetMountInfoByID(mountID);
            local _, description, source = GetMountInfoExtraByID(mountID);

            local title, colorizedName;
            local onClickFunc;

            if isCollected then
                title = "|TInterface/AddOns/Plumber/Art/Button/Checkmark-Green-Shadow:16:16:-4:-2|t"..name;
                colorizedName = "|cffffd100"..name.."|r";
                function onClickFunc()
                    if not IsOnMount(spellID) then
                        C_MountJournal.SummonByID(mountID);
                    end
                end
            else
                title = "|TInterface/AddOns/Plumber/Art/Button/RedCross-Shadow:16:16:-4:-2|t"..name;
                colorizedName = "|cff999999"..name.."|r";
                function onClickFunc()

                end
            end

            if description then
                description = "|cffffd100"..description.."|r";
                if not isCollected then
                    description = description.."\n\n|cffff4800"..L["Mount Not Collected"].."|r";
                end
            end

            local tooltipLines = {
                name,
                source,
                description,
            };

            local data = {
                buttons = {
                    {actionType = "spell", spellID = spellID, icon = icon, name = colorizedName, onClickFunc = onClickFunc, enabled = isCollected, tooltipLines = tooltipLines},
                },
                systemName = QUICKSLOT_NAME,
                spellcastType = 1,      --Cast
            };

            QuickSlot:SetButtonData(data);
            QuickSlot:ShowUI();
            QuickSlot:SetHeaderText(title, true);
            QuickSlot:SetDefaultHeaderText(title);

            return true
        else
            return false
        end
    else
        return false
    end
end

function EL:IsEventActive(widgetID)
    local info = GetTextWithStateWidgetVisualizationInfo(widgetID);
    if info and info.shownState ~= 0 and info.enabledState ~= 0 then
        return true
    end
    return false
end

function EL:GetPlayerEventArea()
    self.playerX, self.playerY = GetPlayerMapCoord(71);
    if self.playerX and self.playerY then
        if self.playerX > 0.6266 and self.playerY > 0.5122 and self.playerX < 0.6352 and self.playerY < 0.5197 then
            return 1    --Mount Maniac
        --elseif self.playerX > 0.6370 and self.playerY > 0.5107 and self.playerX < 0.6432 and self.playerY < 0.5233 then
        --    return 2    --Story Time (No addon for this)
        elseif self.playerX > 0.6317 and self.playerY > 0.4808 and self.playerX < 0.6378 and self.playerY < 0.4977 then
            return 3    --Fashion Frenzy
        end
    end
    return nil
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

function EL:ListenCombatLog(state)
    if state then
        if not self.combatListened then
            self.combatListened = true;
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
        end
    else
        if self.combatListened then
            self.combatListened = false;
            self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
        end
    end
end

function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.5 then
        self.t = 0;
        self.eventIndex = self:GetPlayerEventArea();
        if self.eventIndex == 1 then
            self:ShowVoteCounter(false);
            self:ListenCombatLog(false);
            if self:IsEventActive(WIDGET_ID_MOUNT_MANIAC_ACTIVE) then
                self:ShowQuickSlot(true);
            else
                self:ShowQuickSlot(false);
            end
        elseif self.eventIndex == 2 then
            self:ShowVoteCounter(false);
            self:ListenCombatLog(false);
            self:ShowQuickSlot(false);
        elseif self.eventIndex == 3 then
            self:ListenCombatLog(self:IsEventActive(WIDGET_ID_FASHION_ACTIVE));
            self:ShowQuickSlot(false);
        else
            self:ListenCombatLog(false);
            self:ShowVoteCounter(false);
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

function EL:ProcessCombatLog(timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName)
    if subevent ~= "SPELL_CAST_SUCCESS" then return end;

    if spellID == SPELL_ID_RIBBON then
        self:ShowVoteCounter(true);
        VoteCounter:AddEntry(destGUID, destName);
    end
end

function EL:OnEvent(event, ...)
    if event == "UPDATE_UI_WIDGET" then
        local widgetInfo = ...
        if widgetInfo.widgetID == WIDGET_ID_MOUNT_MANIAC_MOUNT then
            self:UpdateMountButton();
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:ProcessCombatLog( CombatLogGetCurrentEventInfo() );
    end
end

function EL:ListenEvents(state)
    if state then
        --self:RegisterEvent("UPDATE_UI_WIDGET");
        --self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
        self:SetScript("OnEvent", self.OnEvent);
        self:WatchPlayerLocation(true);
    else
        self:UnregisterEvent("UPDATE_UI_WIDGET");
        self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
        self:SetScript("OnEvent", nil);
        self:WatchPlayerLocation(false);
    end
end

--[[
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
--]]


do  --Vote Counter
    local MAX_ENTRY_PER_PAGE = 10;
    local BUTTON_WIDTH = 192;
    local BUTTON_HEIGHT = 24;
    local PADDING_V = 6;
    local OFFSET_H = 10;
    local ACTION_BUTTON_KEY = "Anniversary";

    local ipairs = ipairs;
    local pairs = pairs;

    local VoteCounterMixin = {};
    local EntryButtonMixin = {};
    local FocusSolver;
    local DragWatcher;

    local GetScaledCursorPosition = API.GetScaledCursorPosition;

    function EL:ShowVoteCounter(state)
        if state then
            if not self.counterShown then
                self.counterShown = true;

                if not VoteCounter then
                    VoteCounter = addon.CreateNineSliceFrame(UIParent, "Menu_Black"); --CreateFrame("Frame", nil, UIParent);
                    VoteCounter:Hide();
                    API.Mixin(VoteCounter, VoteCounterMixin);
                    VoteCounter.tsort = table.sort;
                    VoteCounter.gsub = string.gsub;
                    VoteCounter.playerGUID = UnitGUID("player");
                    VoteCounter:SetWidth(BUTTON_WIDTH);
                    VoteCounter:SetFrameStrata("HIGH");
                    VoteCounter:SetClampedToScreen(true);
                    VoteCounter:SetClampRectInsets(-4, 4, 4, -4);
                    VoteCounter:EnableMouseMotion(true);
                    VoteCounter:EnableMouse(true);

                    local Highlight = VoteCounter:CreateTexture(nil, "ARTWORK", nil, 2);
                    VoteCounter.Highlight = Highlight;
                    Highlight:Hide();
                    Highlight:SetColorTexture(1, 1, 1, 0.1);
                    Highlight:SetSize(BUTTON_WIDTH - 4, BUTTON_HEIGHT);

                    local Title = VoteCounter:CreateFontString(nil, "OVERLAY", "GameFontNormal");
                    VoteCounter.Title = Title;
                    Title:SetJustifyH("LEFT");
                    Title:SetPoint("LEFT", VoteCounter, "TOPLEFT", OFFSET_H, -0.5*PADDING_V -0.5*BUTTON_HEIGHT);
                    Title:SetText(L["Voting Result Header"]);
                    Title:SetTextColor(0.5, 0.5, 0.5);

                    local Divider = VoteCounter:CreateTexture(nil, "OVERLAY");
                    VoteCounter.Divider = Divider;
                    Divider:SetTexture("Interface/AddOns/Plumber/Art/Frame/Divider_NineSlice");
                    Divider:SetTextureSliceMargins(48, 4, 48, 4);
                    Divider:SetTextureSliceMode(0);
                    Divider:SetHeight(4);
                    API.DisableSharpening(Divider);
                    Divider:SetWidth(BUTTON_WIDTH);
                    Divider:SetPoint("CENTER", VoteCounter, "TOP", 0, -PADDING_V -BUTTON_HEIGHT);

                    local ExpandCollapseButton = addon.CreateExpandCollapseButton(VoteCounter);
                    VoteCounter.ExpandCollapseButton = ExpandCollapseButton;
                    ExpandCollapseButton:SetPoint("RIGHT", VoteCounter, "TOPRIGHT", -0.5*PADDING_V, -0.5*PADDING_V -0.5*BUTTON_HEIGHT);

                    local function CreateEntryButton()
                        local f = CreateFrame("Frame", nil, VoteCounter);
                        f:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);
                        f.Name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
                        f.Name:SetPoint("LEFT", f, "LEFT", OFFSET_H, 0);
                        f.Name:SetJustifyH("LEFT");
                        f.Count = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
                        f.Count:SetPoint("RIGHT", f, "RIGHT", -OFFSET_H, 0);
                        f.Count:SetJustifyH("RIGHT");
                        f.Count:SetTextColor(1, 1, 1);
                        API.Mixin(f, EntryButtonMixin);
                        f:OnLoad();
                        return f
                    end

                    VoteCounter.entryButtonPool = API.CreateObjectPool(CreateEntryButton);


                    FocusSolver = CreateFrame("Frame", nil, VoteCounter);

                    function FocusSolver:OnUpdate(elapsed)
                        self.t = self.t + elapsed;
                        if self.t > 0.05 then
                            self.t = nil;
                            self:SetScript("OnUpdate", nil);
                            if self.object and self.object:IsShown() and self.object:IsMouseOver() then
                                self.object:OnFocused();
                            end
                        end
                    end

                    function FocusSolver:SetFocus(object)
                        self.object = object;
                        if object then
                            if not self.t then
                                self:SetScript("OnUpdate", self.OnUpdate);
                            end
                            self.t = 0;
                        else
                            self:SetScript("OnUpdate", nil);
                            self.t = nil;
                        end
                    end

                    function FocusSolver:IsLastFocus(itemFrame)
                        return self.object and self.object == itemFrame
                    end


                    DragWatcher = CreateFrame("Frame", nil, VoteCounter);

                    function DragWatcher:OnHide()
                        self:SetScript("OnUpdate", nil);
                        self.t = nil;
                        if self.isDragging then
                            self.isDragging = nil;
                            VoteCounter:SavePosition();
                        end
                    end
                    DragWatcher:SetScript("OnHide", DragWatcher.OnHide);

                    function DragWatcher:StartWatching()
                        self.t = 0;
                        self.x0 , self.y0 = GetScaledCursorPosition();
                        self:SetScript("OnUpdate", self.OnUpdate_PreDrag);
                    end

                    function DragWatcher:OnUpdate_PreDrag(elapsed)
                        self.t = self.t + elapsed;

                        if self.t > 0.016 then
                            self.t = 0;
                            self._x , self._y = GetScaledCursorPosition();
                            self.delta = (self._x - self.x0)^2 + (self._y - self.y0)^2;
                            if self.delta >= 25 then
                                self:StartDragging();
                            end
                        end
                    end

                    function DragWatcher:StartDragging()
                        self.isDragging = true;
                        self.t = 0;
                        self.x0 , self.y0 = GetScaledCursorPosition();
                        self.fromX = VoteCounter:GetLeft();
                        self.fromY = VoteCounter:GetTop();
                        VoteCounter:ClearAllPoints();
                        self:SetScript("OnUpdate", self.OnUpdate_OnDrag);
                    end

                    function DragWatcher:OnUpdate_OnDrag(elapsed)
                        self.t = self.t + elapsed;
                        if self.t > 0.008 then
                            self.t = 0;
                            self._x , self._y = GetScaledCursorPosition();
                            VoteCounter:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.fromX + (self._x - self.x0), self.fromY + (self._y - self.y0));
                        end
                    end

                    VoteCounter:Reset();
                    VoteCounter:ToggleExpanded(addon.GetDBValue("VotingResultsExpanded"));
                    VoteCounter:LoadPosition();

                    VoteCounter:SetScript("OnShow", VoteCounter.OnShow);
                    VoteCounter:SetScript("OnHide", VoteCounter.OnHide);
                    VoteCounter:SetScript("OnEvent", VoteCounter.OnEvent);
                end

                VoteCounter:Show();
            end
        else
            if self.counterShown then
                self.counterShown = false;
                VoteCounter:Hide();
                VoteCounter:Reset();
            end
        end
    end


    function EntryButtonMixin:SetData(data)
        if data.isPlayer then
            if self.isPlayer ~= true then
                self.isPlayer = true;
                self.Name:SetText(UNIT_YOU or "You");
                self.Name:SetTextColor(0.510, 0.773, 1.000);
            end
        else
            if self.isPlayer ~= false then
                self.isPlayer = false;
                self.Name:SetTextColor(1, 1, 1);
            end
        end
        self.characterName = data.name;
    end

    function EntryButtonMixin:OnLoad()
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
    end

    function EntryButtonMixin:OnEnter()
        VoteCounter:HighlightButton(self);
    end

    function EntryButtonMixin:OnLeave()
        if not self:IsMouseOver() then
            VoteCounter:HighlightButton(nil);
        end
    end

    function EntryButtonMixin:OnFocused()
        if not self.characterName then return end;
        local sab = addon.AcquireSecureActionButton(ACTION_BUTTON_KEY);
        if sab then
            sab:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);
            sab:SetPoint("CENTER", self, "CENTER", 0, 0);
            sab:SetAttribute("type1", "macro");     --Any Mouseclick
            local macroText = "/tar "..self.characterName;
            sab:SetMacroText(macroText);
            sab:RegisterForClicks("LeftButtonDown", "LeftButtonUp");
            sab:SetFrameStrata("DIALOG");
            sab:SetFixedFrameStrata(true);
            sab:SetParent(self);
            sab:Show();

            sab:SetScript("OnLeave", function()
                sab:Release();
                VoteCounter:HighlightButton(nil);
            end);
        end
    end


    function VoteCounterMixin:HighlightButton(button)
        self.Highlight:Hide();
        self.Highlight:ClearAllPoints();
        if button then
            self.Highlight:SetPoint("CENTER", button, "CENTER", 0, 0);
            self.Highlight:Show();
        end
        FocusSolver:SetFocus(button);
    end

    function VoteCounterMixin:GetTimeStamp()
        if not self.baseTime then
            self.baseTime = time();
        end
        return time() - self.baseTime
    end

    function VoteCounterMixin:AddEntry(guid, name)
        if self.guidData[guid] then
            self.guidData[guid].count = self.guidData[guid].count + 1;
            self.guidData[guid].timestamp = self:GetTimeStamp();
        else
            local data = {count = 1, name = name, timestamp = self:GetTimeStamp(), guid = guid};
            self.guidData[guid] = data;
            self.n = self.n + 1;
            self.entries[self.n] = data;

            if guid == self.playerGUID then
                data.isPlayer = true;
            end
        end
        self:RequestUpdate();
    end

    function VoteCounterMixin:LoadPosition()
        self:ClearAllPoints();
        local DB = PlumberDB;
        if DB and DB.VoteCounter_PositionX and DB.VoteCounter_PositionY then
            self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", DB.VoteCounter_PositionX, DB.VoteCounter_PositionY);
        else
            local viewportWidth, viewportHeight = WorldFrame:GetSize();
            viewportWidth = math.min(viewportWidth, viewportHeight * 16/9);
            local scale = UIParent:GetEffectiveScale();
            local offsetX = math.floor(0.35 * viewportWidth /scale);
            local offsetY = 292;
            self:SetPoint("TOPLEFT", nil, "CENTER", offsetX, offsetY);
        end
    end

    function VoteCounterMixin:SavePosition()
        local DB = PlumberDB;
        DB.VoteCounter_PositionX = API.Round(self:GetLeft());
        DB.VoteCounter_PositionY = API.Round(self:GetTop());
    end

    local function SortFunc_Player(a, b)
        if a.count ~= b.count then
            return a.count > b.count
        end

        if a.timestamp ~= b.timestamp then
            return a.timestamp < b.timestamp
        end

        return a.name < b.name
    end

    function VoteCounterMixin:OnUpdate_UpdateEntries(elapsed)
        self.t = self.t + elapsed;
        if self.t >= 1 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            self:UpdateEntries();
        end
    end

    function VoteCounterMixin:RequestUpdate()
        if not self.expanded then return end;
        if not self.t then
            self.t = 0;
            self:SetScript("OnUpdate", self.OnUpdate_UpdateEntries);
        end
    end

    function VoteCounterMixin:UpdateEntries()
        if self.n > 0 then
            self.tsort(self.entries, SortFunc_Player);
        end
        self:Layout();
    end

    function VoteCounterMixin:Layout()
        local playerFound;
        local button;
        local numButtons = 0;

        for _, button in pairs(self.guidButton) do
            button.used = false;
        end

        local fromOffset = PADDING_V + BUTTON_HEIGHT + PADDING_V;

        for i, data in ipairs(self.entries) do
            if i > MAX_ENTRY_PER_PAGE then
                break
            elseif i >= MAX_ENTRY_PER_PAGE and not playerFound then
                if self.guidData[self.playerGUID] then
                    data = self.guidData[self.playerGUID];
                end
            end

            if data.isPlayer then
                playerFound = true;
            end

            button = self.guidButton[data.guid];
            if button then
                
            else
                button = self.entryButtonPool:Acquire();
                if data.isPlayer then
                    button.Name:SetText(UNIT_YOU or "You");
                else
                    button.Name:SetText(self.gsub(data.name, "(%-.+)", ""));
                end
                button.fullName = data.name;
                self.guidButton[data.guid] = button;
                button:SetData(data);
            end
            button.Count:SetText(data.count);
            button.used = true;
            button:SetPoint("TOP", self, "TOP", 0, (1 - i) * BUTTON_HEIGHT -fromOffset);
            numButtons = numButtons + 1;
        end

        for _, button in pairs(self.guidButton) do
            if not button.used then
                button:Release();
            end
        end

        if numButtons > 0 then
            self:SetHeight(fromOffset + numButtons * BUTTON_HEIGHT + PADDING_V);
        else
            self:SetHeight(PADDING_V + BUTTON_HEIGHT);
        end
    end

    function VoteCounterMixin:Reset()
        self.entryButtonPool:ReleaseAll();
        self.entries = {};
        self.guidData = {};
        self.guidButton = {};
        self.n = 0;
        self:SetScript("OnUpdate", nil);
        self.t = nil;
        if self.expanded then
            self:SetHeight(PADDING_V + BUTTON_HEIGHT + PADDING_V);
        end
        FocusSolver:SetFocus(nil);
    end

    function VoteCounterMixin:OnEvent(event)
        if not self:IsShown() then
            self:UnregisterEvent(event);
            return
        end

        if event == "GLOBAL_MOUSE_DOWN" then
            if self:IsMouseOver() then
                DragWatcher:StartWatching();
            end
        elseif event == "GLOBAL_MOUSE_UP" then
            DragWatcher:OnHide();
        end
    end

    function VoteCounterMixin:OnShow()
        self:RegisterEvent("GLOBAL_MOUSE_DOWN");
        self:RegisterEvent("GLOBAL_MOUSE_UP");
    end

    function VoteCounterMixin:OnHide()
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
        self:UnregisterEvent("GLOBAL_MOUSE_UP");
    end

    function VoteCounterMixin:ToggleExpanded(newState)
        if newState == nil then
            newState = not self.expanded;
        end

        self.expanded = newState;
        self.ExpandCollapseButton:SetExpanded(newState);

        if newState then
            self.Divider:Show();
            self:UpdateEntries();
        else
            self.entryButtonPool:ReleaseAll();
            self.guidButton = {};
            self:SetHeight(PADDING_V + BUTTON_HEIGHT);
            self.Divider:Hide();
            FocusSolver:SetFocus(nil);
        end

        addon.SetDBValue("VotingResultsExpanded", newState);
    end

    do  --Debug
        --[[
        C_Timer.After(1, function()
            function VoteCounterMixin:AddPlayerEntry()
                self:AddEntry(self.playerGUID, UnitName("player"))
            end
            EL:ShowVoteCounter(true);
            VoteCounter:AddPlayerEntry();
            for i = 1, MAX_ENTRY_PER_PAGE do
                local name = "Player"..i;
                local guid = "p"..i;
                if i == 0 then
                    guid = "Player-5765-000FC25A";
                    name = "Naughordespy-Vyranoth";
                end
                for j = 1, math.random(1, 20) do
                    VoteCounter:AddEntry(guid, name);
                end
            end
            VT = VoteCounter;
        end)
        --]]
    end
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
                    EL:ShowQuickSlot(false);
                    EL:ShowVoteCounter(false);
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
            EL:ShowVoteCounter(false);
            EL:ListenCombatLog(false);
        end
    end

    local function ValidityCheck()
        if addon.IsToCVersionEqualOrNewerThan(110005) then
            return true
        end

        return time() > 1729400000
    end

    local function OptionToggle_OnClick(self, button)
        if EL:IsEventActive(WIDGET_ID_MOUNT_MANIAC_ACTIVE) then
            return
        end

        if QuickSlot:IsShown() then
            QuickSlot:EnableEditMode(false);
        else
            local function Nop()
            end
            local name = L["ModuleName WoWAnniversary"];
            local icon = 132261;
            local data = {
                buttons = {
                    {actionType = "spell", spellID = 0, icon = icon, name = name, onClickFunc = Nop, enabled = true},
                },
                systemName = QUICKSLOT_NAME,
                spellcastType = 1,
            };

            QuickSlot:SetButtonData(data);
            QuickSlot:ShowUI();
            QuickSlot:SetHeaderText(name, true);
            QuickSlot:SetDefaultHeaderText(name);
            QuickSlot:EnableEditMode(true);
            QuickSlot:CloseUIAfterEditing();
        end
    end

    local moduleData = {
        name = L["ModuleName WoWAnniversary"],
        dbKey = "WoWAnniversary",
        description = L["ModuleDescription WoWAnniversary"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1150,
        moduleAddedTime = 1729500000,
        validityCheck = ValidityCheck,
        optionToggleFunc = OptionToggle_OnClick,
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