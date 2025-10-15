-- Add a checkbox to toggle Plumber Elements in Edit Mode

local _, addon = ...
local API = addon.API;
local L = addon.L;


local UIParent = UIParent;
local MainFrame = CreateFrame("Frame", nil, UIParent);
MainFrame:Hide();

local DBKEY_MASTER = "EditModeShowPlumberUI";


local ModuleInfo = {};

local function AddEditModeVisibleModule(moduleData)
    table.insert(ModuleInfo, moduleData);
end
addon.AddEditModeVisibleModule = AddEditModeVisibleModule;

local function UpdateModuleVisibilities()
    local showUI = addon.GetDBBool(DBKEY_MASTER);
    local anyOn;
    for _, moduleData in ipairs(ModuleInfo) do
        if addon.GetDBBool(moduleData.dbKey) then
            anyOn = true;
            if showUI then
                moduleData.enterEditMode();
            else
                moduleData.exitEditMode();
            end
        else
            moduleData.exitEditMode();
        end
    end
    return anyOn
end


function MainFrame:Init()
    self.Init = nil;

    local owner = EditModeManagerFrame;
    if not owner then return end;

    self.owner = owner;

    self.Border = CreateFrame("Frame", nil, self, "DialogBorderTranslucentTemplate");
    self:SetFrameStrata("DIALOG");

    local Checkbox = API.CreateBlizzardCheckButton(self);
    self.Checkbox = Checkbox;
    Checkbox:SetPoint("CENTER", self, "CENTER", 0, 0);
    Checkbox:SetLabel("Plumber");
    Checkbox:SetDBKey(DBKEY_MASTER);

    local function Checkbox_GetTooltip()
        local header = L["Toggle Plumber UI"];
        local desc = L["Toggle Plumber UI Tooltip"];
        local text, name;

        for _, moduleData in ipairs(ModuleInfo) do
            if addon.GetDBBool(moduleData.dbKey) then
                name = "- "..moduleData.name;
                if text then
                    text = text.."\n"..name;
                else
                    text = name;
                end
            end
        end

        if text then
            return header, string.format(desc, text);
        end
    end
    Checkbox:SetTooltip(Checkbox_GetTooltip);

    Checkbox:SetOnCheckedFunc(UpdateModuleVisibilities);


    local width, height = Checkbox:GetSize();
    self:SetSize(width + 32, height + 32);
    self.t = 1;
    self:SetScript("OnUpdate", self.OnUpdate);
    self:SetFrameLevel(owner:GetFrameLevel() + 2);
end

function MainFrame:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.25 then
        self.t = 0;
        self.x = self.owner:GetRight();
        self.y = self.owner:GetTop();
        self.x = self.x - 16;
        self.y = self.y - 104;

        if self.secondaryOwner and self.secondaryOwner:IsShown() then
            local f = EditModeExpandedWarningFrame;
            if f and f:IsShown() then
                self:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, -4);
            else
                self:SetPoint("TOPLEFT", self.secondaryOwner, "BOTTOMLEFT", 0, -4);
            end
        elseif self.owner:IsShown() then
            self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.x, self.y);
            self:ShowModules(true);
        else
            self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, -8);
            self:ShowModules(false);
        end
    end
end

function MainFrame:EnterEditMode()
    if self.Init then
        self:Init();
    end

    if UpdateModuleVisibilities() then
        self.moduleShown = true;
        self.t = 1;
        self:SetScript("OnUpdate", self.OnUpdate);
        self.Checkbox:SetChecked(addon.GetDBBool(DBKEY_MASTER));
        self:Show();
    else
        self:Hide();
    end

    if EditModeManagerExpandedFrame then
        --Addon Compatibility: Edit Mode Expanded (https://github.com/teelolws/EditModeExpanded)
        self.secondaryOwner = EditModeManagerExpandedFrame;
    end
end

function MainFrame:ExitEditMode()
    self:Hide();
    self.t = 0;
    self:SetScript("OnUpdate", nil);
    self:ShowModules(false);
end

function MainFrame:ShowModules(state)
    if state == self.moduleShown then return end;
    self.moduleShown = state;

    if state then
        UpdateModuleVisibilities();
    else
        for _, moduleData in ipairs(ModuleInfo) do
            moduleData.exitEditMode();
        end
    end
end


EventRegistry:RegisterCallback("EditMode.Enter", MainFrame.EnterEditMode, MainFrame);
EventRegistry:RegisterCallback("EditMode.Exit", MainFrame.ExitEditMode, MainFrame);