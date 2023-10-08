local _, addon = ...

local _, _, classID = UnitClass("player");
if classID ~= 11 then return end;

if addon.IsGame_10_2_0 then
    return
end


local SPELL_MOONKIN_FORM = 24858;
local IS_USING_GLYPH = false;   --Glyph Spell ID: 114301
local LAST_FORM_ID;

local MODULE_ENABLED = false;

local GetShapeshiftFormID = GetShapeshiftFormID;
local ModelScene = CharacterModelScene;


local function ShowRegularModel()
    ModelScene:ReleaseAllActors();
    ModelScene:TransitionToModelSceneID(595, 1, 2, true);   --CHARACTER_SHEET_MODEL_SCENE_ID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN
    local actor = ModelScene:GetPlayerActor();
    if actor then
        local hasAlternateForm, inAlternateForm = C_PlayerInfo.GetAlternateFormInfo();
        local sheatheWeapon = GetSheathState() == 1;
        local autodress = true;
        local hideWeapon = false;
        local useNativeForm = not inAlternateForm;
        actor:SetModelByUnit("player", sheatheWeapon, autodress, hideWeapon, useNativeForm);
        actor:SetAnimationBlendOperation(0);
        return actor
    end
end

local function ShowAstralModel()
    local actor = ShowRegularModel();
    if actor then
        actor:SetSpellVisualKit(23368, false);
        actor:SetSpellVisualKit(27440, false);
    end
end

local function UpdatePlayerModel()
    if not MODULE_ENABLED then return end;

    local form = GetShapeshiftFormID();
    if not (form == 31 and IS_USING_GLYPH) then
        return
    end

    ShowAstralModel();
end


local EventListener = CreateFrame("Frame");

EventListener:RegisterEvent("PLAYER_ENTERING_WORLD");
EventListener:RegisterEvent("USE_GLYPH");

EventListener:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "USE_GLYPH" then
        if event == "PLAYER_ENTERING_WORLD" then
            self:UnregisterEvent(event);
        end
        IS_USING_GLYPH = HasAttachedGlyph(SPELL_MOONKIN_FORM);
    elseif event == "UPDATE_SHAPESHIFT_FORM" then
        --Glyph user won't trigger "UNIT_MODEL_CHANGED" when shift between humanoid form and moonkin
        --So we monitor this event instead
        local newForm = GetShapeshiftFormID();
        if (not IS_USING_GLYPH) or (newForm == LAST_FORM_ID) then return end;

        if newForm == nil and LAST_FORM_ID == 31 then
            ShowRegularModel();
        elseif newForm == 31 and LAST_FORM_ID == nil then
            ShowAstralModel();
        end

        LAST_FORM_ID = newForm;
    end
end);


local HAS_HOOK = false;

local function HookFunctions()
    if PaperDollFrame_SetPlayer and ModelScene then
        hooksecurefunc("PaperDollFrame_SetPlayer", UpdatePlayerModel);
    end
    
    if PaperDollFrame then
        if PaperDollFrame:GetScript("OnShow") then
            PaperDollFrame:HookScript("OnShow", function()
                EventListener:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
                LAST_FORM_ID = GetShapeshiftFormID();
            end);
        end
    
        if PaperDollFrame:GetScript("OnHide") then
            PaperDollFrame:HookScript("OnHide", function()
                EventListener:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
            end);
        end
    end
end

local function EnableModule(state)
    if state then
        if not HAS_HOOK then
            HAS_HOOK = true;
            HookFunctions();
        end
        MODULE_ENABLED = true;
    else
        MODULE_ENABLED = false;
    end
end

do
    local _, addon = ...

    local moduleData = {
        name = addon.L["ModuleName DruidModelFix"],
        dbKey = "DruidModelFix",
        description = addon.L["ModuleDescription DruidModelFix"],
        toggleFunc = EnableModule,
    };

    addon.ControlCenter:AddModule(moduleData);
end