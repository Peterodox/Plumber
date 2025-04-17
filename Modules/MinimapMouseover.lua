local _, addon = ...

local InCombatLockdown = InCombatLockdown;
local GetCVarBool = C_CVar.GetCVarBool;

local TooltipManager = addon.GameTooltipManager:GetMinimapManager();

local MinimapOverlay = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate");
MinimapOverlay:Hide();
MinimapOverlay:SetFrameStrata("MEDIUM");
MinimapOverlay:SetPropagateMouseMotion(true);
MinimapOverlay:SetPropagateMouseClicks(true);
MinimapOverlay:RegisterForClicks("AnyDown");
MinimapOverlay:RegisterForClicks("AnyUp");

local function Dummy()
end

local Methods = {
    "SetParent", "GetParent", "SetScale", "SetPoint", "GetPoint", "ClearAllPoints",
    "Show", "Hide", "SetShown";
};

for _, method in ipairs(Methods) do
    MinimapOverlay["_"..method] = MinimapOverlay[method];
    MinimapOverlay[method] = Dummy;
end


local SubModule = {};

function SubModule:ProcessData(tooltip, leftText)
    if self.enabled then
        if leftText ~= self.lastLeftText then
            self.lastLeftText = leftText;
            MinimapOverlay:SetTargetName(leftText);
        end
        return true
    else
        return false
    end
end

function SubModule:GetDBKey()
    return "MinimapMouseover"
end

function SubModule:SetEnabled(enabled)
    self.enabled = enabled == true;
    self.lastLeftText = nil;
    TooltipManager:RequestUpdate();

    if enabled then
        self:RequestSetupOverlay();
        MinimapOverlay:SetScript("OnEvent", MinimapOverlay.OnEvent);
        MinimapOverlay:RegisterEvent("PLAYER_REGEN_ENABLED");
        MinimapOverlay:RegisterEvent("PLAYER_REGEN_DISABLED");
    else
        self:RequestRemoveOverlay();
        MinimapOverlay:SetScript("OnEvent", nil);
        MinimapOverlay:UnregisterEvent("PLAYER_REGEN_ENABLED");
        MinimapOverlay:UnregisterEvent("PLAYER_REGEN_DISABLED");
    end
end

function SubModule:IsEnabled()
    return self.enabled == true
end

function SubModule:SetupOverlay()
    if self.overlayAdded then return end;
    self.overlayAdded = true;
    local parent = Minimap;
    MinimapOverlay:_SetParent(parent);
    MinimapOverlay:_SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0);
    MinimapOverlay:_SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0);
    MinimapOverlay:_Show();
end

function SubModule:RequestSetupOverlay()
    MinimapOverlay.inCombat = InCombatLockdown();
    if self.overlayAdded then return end;

    if MinimapOverlay.inCombat then
        MinimapOverlay.needSetup = true;
        MinimapOverlay.needRemoval = false;
    else
        self:SetupOverlay();
    end
end

function SubModule:RemoveOverlay()
    if not self.overlayAdded then return end;
    self.overlayAdded = false;
    MinimapOverlay:_SetParent(UIParent);
    MinimapOverlay:_ClearAllPoints();
    MinimapOverlay:_Hide();
end

function SubModule:RequestRemoveOverlay()
    if not self.overlayAdded then return end;
    if InCombatLockdown() then
        MinimapOverlay.needRemoval = true;
        MinimapOverlay.needSetup = false;
    else
        self:RemoveOverlay();
    end
end


do  --Overlay
    MinimapOverlay.inCombat = true;

    function MinimapOverlay:SetTargetName(targetName)
        if self.inCombat then
            self.pendingTargetName = targetName;
            return
        else
            self.pendingTargetName = nil;
        end
        self.targetName = targetName;

        local clickType = "alt-type*";
        local macroText;

        if targetName then
            macroText = "/tar "..targetName;
            self:UpdateClicks();
        else

        end

        self:SetAttribute(clickType, "macro");
        self:SetAttribute("macrotext", macroText);
    end

    function MinimapOverlay:UpdateClicks()
        local useKeyDown = GetCVarBool("ActionButtonUseKeyDown");
        if useKeyDown ~= self.useKeyDown then
            local btn1, btn2;
            if useKeyDown then
                btn1, btn2 = "LeftButtonDown", "RightButtonDown";
            else
                btn1, btn2 = "LeftButtonUp", "RightButtonUp";
            end
            self:RegisterForClicks(btn1, btn2);
        end
    end

    function MinimapOverlay:OnEvent(event, ...)
        if event == "PLAYER_REGEN_ENABLED" then
            self.inCombat = false;
            SubModule:RequestSetupOverlay();
            if self.pendingTargetName then
                self:SetTargetName(self.pendingTargetName);
            end
        elseif event == "PLAYER_REGEN_DISABLED" then
            self.inCombat = true;
            if self.targetName then
                self.targetName = nil;
                self:SetAttribute("macrotext", nil);
            end
            SubModule:RequestRemoveOverlay();
        end
    end
end


do
    local function EnableModule(state)
        if state then
            SubModule:SetEnabled(true);
            TooltipManager:AddSubModule(SubModule);
        else
            SubModule:SetEnabled(false);
        end
    end

    local moduleData = {
        name = addon.L["ModuleName MinimapMouseover"],
        dbKey = SubModule:GetDBKey(),
        description = addon.L["ModuleDescription MinimapMouseover"],
        toggleFunc = EnableModule,
        categoryID = 2,
        uiOrder = 20,
        moduleAddedTime = 1744100000,
    };

    addon.ControlCenter:AddModule(moduleData);
end