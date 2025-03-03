-- Show the info of your target's spell that's being cast

local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;
local GetUnitIDGeneral = API.GetUnitIDGeneral;      --Creature/Pet/GameObject/Vehicle

local IMPORTANT_CAST_TIME = 1000;                   --Important spell (millisecond). No info when the cast/channel time is below this value

local IsInInstance = IsInInstance;                  --Save open world boss unit
local UnitExists = UnitExists;
local UnitIsBossMob = UnitIsBossMob;                --Don't save boss spell
local UnitCastingInfo = UnitCastingInfo;
local UnitChannelInfo = UnitChannelInfo;
local DoesSpellExist = C_Spell.DoesSpellExist;
local tsort = table.sort;
local pairs = pairs;
local ipairs = ipairs;


local CURRENT_UID = nil;
local TOOLTIP_SPELL_ID = true;          --Add spellID to our tooltip (Controlled by PlumberDB.SpellcastingInfoSpellID)


local function GetUnitCastingSpellID(unit)
    local _, spellID;
    _, _, _, _, _, _, _, _, spellID = UnitCastingInfo(unit);
    if not spellID then
        _, _, _, _, _, _, _, spellID = UnitChannelInfo(unit);
    end
    return spellID
end


local SpellDatabase = {};
do
    SpellDatabase.data = {};
    SpellDatabase.sessionData = {};

    function SpellDatabase:AddSpell(uid, spellID)
        if uid and spellID then
            if (not self.sessionData[uid]) then
                self:LoadSessionData(uid);
            end
            self.sessionData[uid][spellID] = true;
        end
    end

    function SpellDatabase:GetSpell(uid)
        local spells;
        local n = 0;

        local sessionData = self.sessionData[uid];
        if sessionData then
            spells = {};
            for spellID in pairs(sessionData) do
                if DoesSpellExist(spellID) then
                    n = n + 1;
                    spells[n] = spellID;
                end
            end
        end

        if self.allData[uid] then
            if not spells then
                spells = {};
            end
            for _, spellID in ipairs(self.allData[uid]) do
                if DoesSpellExist(spellID) then
                    if sessionData and sessionData[spellID] then

                    else
                        n = n + 1;
                        spells[n] = spellID;
                    end
                end
            end
        end

        if n > 0 then
            tsort(spells);
            return spells
        end
    end

    function SpellDatabase:LoadSessionData(uid)
        if self.allData[uid] then
            if not self.sessionData[uid] then
                self.sessionData[uid] = {};
            end

            for _, spellID in ipairs(self.allData[uid]) do
                self.sessionData[uid][spellID] = true;
            end
        else
            self.sessionData[uid] = {};
        end
    end

    function SpellDatabase:LoadDatabase()
        if PlumberStorage and not PlumberStorage.CreatureSpells then
            PlumberStorage.CreatureSpells = {};
        end
        self.allData = PlumberStorage and PlumberStorage.CreatureSpells or {};
    end

    function SpellDatabase:SaveDatabase()
        if self.sessionData and self.allData then
            for uid, v in pairs(self.sessionData) do
                local spells = {};
                local n = 0;
                for spellID in pairs(v) do
                    n = n + 1;
                    spells[n] = spellID;
                end
                self.allData[uid] = spells;
            end
        end
    end
end


local EL = CreateFrame("Frame");
do
    local SpellEvents = {
        "UNIT_SPELLCAST_CHANNEL_START",
        "UNIT_SPELLCAST_START",
        "UNIT_SPELLCAST_SUCCEEDED",         --Instant spells don't trigger START

        --"UNIT_SPELLCAST_CHANNEL_STOP",
        --"UNIT_SPELLCAST_STOP",
        --"UNIT_SPELLCAST_EMPOWER_START",   --Unused by monsters?
        --"UNIT_SPELLCAST_EMPOWER_STOP",
    };

    function EL:OnEvent(event, ...)
        if event == "PLAYER_TARGET_CHANGED" then
            if UnitExists("target") and (self.inInOpenWorld or (not UnitIsBossMob("target"))) then
                CURRENT_UID = GetUnitIDGeneral("target");
                if CURRENT_UID then
                    local spellID = GetUnitCastingSpellID("target");
                    if spellID then
                        SpellDatabase:AddSpell(CURRENT_UID, spellID);
                    end
                end
            else
                CURRENT_UID = nil;
            end
        elseif event == "UNIT_SPELLCAST_START" then
            self:ProcessSpellcast(...);
        elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
            self:ProcessSpellChannel(...);
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            local _, _, spellID = ...
            SpellDatabase:AddSpell(CURRENT_UID, spellID);
        elseif event == "PLAYER_LOGOUT" then
            SpellDatabase:SaveDatabase();
        elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
            self:UpdateInInstance();
        end
    end

    function EL:ListenUnitEvents(unit)
        self.unit = unit;

        for _, event in ipairs(SpellEvents) do
            self:RegisterUnitEvent(event, unit);
        end

        self:RegisterEvent("PLAYER_TARGET_CHANGED");
        self:RegisterEvent("PLAYER_LOGOUT");
        self:RegisterEvent("PLAYER_ENTERING_WORLD");
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA");

        self:SetScript("OnEvent", self.OnEvent);

        self:UpdateInInstance();
        self:OnEvent("PLAYER_TARGET_CHANGED");
    end

    function EL:UnlistenEvents()
        for _, event in ipairs(SpellEvents) do
            self:UnregisterEvent(event);
        end
        self:UnregisterEvent("PLAYER_TARGET_CHANGED");
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        self:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
        --Keep PLAYER_LOGOUT so it saves sessionData
    end

    function EL:ProcessSpellcast(unitTarget, castGUID, spellID)
        --local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellID2 = UnitCastingInfo(self.unit);
        --return self:EvaluateSpell(endTimeMS, startTimeMS, text, texture, spellID or spellID2, notInterruptible);
        SpellDatabase:AddSpell(CURRENT_UID, spellID);
    end

    function EL:ProcessSpellChannel(unitTarget, castGUID, spellID)
        --local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellID2, isEmpowered, numEmpowerStages = UnitChannelInfo(self.unit);
        --return self:EvaluateSpell(endTimeMS, startTimeMS, text, texture, spellID or spellID2, notInterruptible);
        SpellDatabase:AddSpell(CURRENT_UID, spellID);
    end

    function EL:EvaluateSpell(endTimeMS, startTimeMS, text, texture, spellID, notInterruptible)
        --Unused
        if (not spellID) or (endTimeMS - startTimeMS < IMPORTANT_CAST_TIME) then
            return
        end
        return true
    end

    function EL:UpdateInInstance()
        self.inInOpenWorld = not IsInInstance();
    end
end


local SpellBarOverlayMixin = {};
do  --CastingBar / SpellBar
    function SpellBarOverlayMixin:OnEvent(event, ...)
        if self:IsMouseMotionFocus() then
            self:OnEnter();
        end
    end

    function SpellBarOverlayMixin:OnEnter()
        local unit = self:GetParent().unit;
        if not unit then return end;

        local spellID = GetUnitCastingSpellID(unit);

        if spellID then
            GameTooltip:SetOwner(self, "ANCHOR_NONE");
            GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0);
            GameTooltip:SetSpellByID(spellID);
        end

        self:RegisterUnitEvent("UNIT_SPELLCAST_START", unit);
        self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit);
        self:SetScript("OnEvent", self.OnEvent);
    end

    function SpellBarOverlayMixin:OnHide()
        self:UnregisterEvent("UNIT_SPELLCAST_START");
        self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
        self:SetScript("OnEvent", nil);
    end

    function SpellBarOverlayMixin:OnLeave()
        GameTooltip:Hide();
        self:OnHide();
    end

    function SpellBarOverlayMixin:OnLoad()
        self:SetIgnoreParentAlpha(true);
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnHide", self.OnHide);
    end

    function SpellBarOverlayMixin:Release()
        self:Hide();
        self:ClearAllPoints();
        self:SetParent(nil);
    end
end

local function AttachFrameToCastingBar(bar, overlay)
    if not bar then return
       false
    end

    local f;

    if overlay then
        f = overlay;
        f:ClearAllPoints();
        f:SetParent(bar);
    else
        f = CreateFrame("Frame", nil, bar);
        API.Mixin(f, SpellBarOverlayMixin);
        f:OnLoad();
    end

    if bar.Icon and false then
        --We temporarily disable this because we might encounter negative area if the icon is on the right
        f:SetPoint("TOPLEFT", bar.Icon, "TOPLEFT", 0, 0);
    else
        f:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0);
    end
    f:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0);

    return f
end


local ModifyUnitPopupMenu;
do  --UnitPopup / Menu
    local GetSpellTexture = C_Spell.GetSpellTexture;
    local GetSpellName = C_Spell.GetSpellName;

    local ICON_TEXT_GAP = 6;
    local UNIT_MENU_ENABLED = false;
    local MENU_MODIFIED = false;

    local function GetSpellNameForButton(spellID)
        local spellName = GetSpellName(spellID);
        if spellName and spellName ~= "" then
            return spellName, true
        else
            return "SpellID: "..spellID, false
        end
    end

    local function SubmenuButtonResponder(data, menuInputData, menu)
        return 1    --MenuResponse.Open
    end

    local function Menu_OnLeave()
        GameTooltip:Hide();
    end

    function ModifyUnitPopupMenu(state)
        UNIT_MENU_ENABLED = state;

        if state then
            if MENU_MODIFIED then
                return
            else
                MENU_MODIFIED = true;
            end

            if Menu and Menu.ModifyMenu then
                Menu.ModifyMenu("MENU_UNIT_TARGET", function(owner, rootDescription, contextData)
                    if not UNIT_MENU_ENABLED then return end;

                    local uid = GetUnitIDGeneral("target");
                    local spells = uid and SpellDatabase:GetSpell(uid);

                    if spells then
                        rootDescription:CreateDivider();
                        --rootDescription:CreateTitle("Bestiary");

                        local submenu = rootDescription:CreateButton(L["Abilities"]);

                        for _, spellID in ipairs(spells) do
                            local buttonDescription = submenu:CreateButton(spellID);

                            buttonDescription:AddInitializer(function(button, description, menu)
                                local leftTexture = button:AttachTexture();
                                leftTexture:SetPoint("LEFT");
                                leftTexture:SetTexture(GetSpellTexture(spellID));
                                leftTexture:SetSize(16, 16);
                                leftTexture:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375);

                                local fontString = button.fontString;
                                fontString:ClearAllPoints();
                                fontString:SetPoint("LEFT", leftTexture, "RIGHT", ICON_TEXT_GAP, 0);
                                fontString:SetTextColor(1, 1, 1);

                                local name, loaded = GetSpellNameForButton(spellID);
                                fontString:SetText(name);

                                if not loaded then
                                    CallbackRegistry:LoadSpell(spellID, function(id)
                                        if button:IsVisible() and spellID == id then
                                            name = GetSpellNameForButton(spellID);
                                            fontString:SetText(name);
                                            leftTexture:SetTexture(GetSpellTexture(spellID));
                                        end
                                    end);
                                end

                                local width = fontString:GetUnboundedStringWidth() + leftTexture:GetWidth() + ICON_TEXT_GAP;
                                local height = 20;

                                button:SetScript("OnClick", function(button, buttonName)
                                    if buttonName == "LeftButton" and IsModifiedClick("CHATLINK") and (not InCombatLockdown()) then
                                        local link = C_Spell.GetSpellLink(spellID);
                                        ChatEdit_InsertLink(link);
                                    end
                                end);

                                return width, height;
                            end);

                            buttonDescription:SetResponder(SubmenuButtonResponder);

                            buttonDescription:SetOnEnter(function(f)
                                local tooltip = GameTooltip;
                                tooltip:Hide();
                                tooltip:SetOwner(f, "ANCHOR_NONE");
                                tooltip:SetPoint("RIGHT", f, "LEFT", -8, 0);

                                local tooltipPostCall;
                                if TOOLTIP_SPELL_ID then
                                    function tooltipPostCall()
                                        local icon = GetSpellTexture(spellID) or 0;
                                        tooltip:AddLine(" ");
                                        tooltip:AddDoubleLine(L["Spell Colon"].."|cffffffff"..spellID.."|r", L["Icon Colon"].."|cffffffff"..icon.."|r", 1, 0.82, 0, 1, 0.82, 0);
                                    end
                                end

                                local isPet = nil;
                                local showSubtext = true;
                                API.SetTooltipWithPostCall(tooltip, tooltipPostCall, "GetSpellByID", spellID, isPet, showSubtext);
                                tooltip:Show();
                            end);

                            buttonDescription:SetOnLeave(Menu_OnLeave);
                        end
                    end
                end);
            end
        else

        end
    end
end


local AttachedBars = {
    --[GlobalName] = {unit = unit},
    TargetFrameSpellBar = {unit = "target"},
    FocusFrameSpellBar = {unit = "focus"},

    ElvUF_Target_CastBar = {unit = "target"},
    ElvUF_Focus_CastBar = {unit = "focus"},
};


local function EnableModule(state)
    if state then
        SpellDatabase:LoadDatabase();

        local bar;
        for name, data in pairs(AttachedBars) do
            bar = _G[name];
            if bar then
                if not data.overlay then
                    AttachedBars[name].overlay = AttachFrameToCastingBar(bar);
                else
                    AttachFrameToCastingBar(bar, data.overlay);
                end
            end
        end

        EL:ListenUnitEvents("target");
    else
        for name, data in pairs(AttachedBars) do
            if data.overlay then
                data.overlay:Release();
            end
        end

        EL:UnlistenEvents();
    end

    ModifyUnitPopupMenu(state);
    TOOLTIP_SPELL_ID = PlumberDB and PlumberDB.SpellcastingInfoSpellID ~= false;
end


do
    local moduleData = {
        name = L["ModuleName SpellcastingInfo"],
        dbKey = "SpellcastingInfo",
        description = L["ModuleDescription SpellcastingInfo"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1155,
        moduleAddedTime = 1732700000,
    };

    addon.ControlCenter:AddModule(moduleData);
end