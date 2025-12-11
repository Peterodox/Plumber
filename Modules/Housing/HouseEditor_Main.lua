local _, addon = ...
local L = addon.L;
local API = addon.API;
local Housing = addon.Housing;


local Controller = CreateFrame("Frame");
Housing.HouseEditorController = Controller;
Controller.modeHandlers = {};


local IsHouseEditorActive = C_HouseEditor.IsHouseEditorActive;


function Controller.AddSubModule(modeHandler)
    local modeID = Enum.HouseEditorMode[modeHandler.editMode];
    if modeID then
        Controller.modeHandlers[modeID] = modeHandler;
    else
        print("Plumber House Editor: Invalid Mode", modeHandler.editMode);
    end
end

local function Blizzard_HouseEditor_OnLoaded()
    --parentKey="SelectInstruction" inherits="HouseEditorInstructionTemplate" parentArray="UnselectedInstructions"
    --HouseEditorInstructionTemplate, InstructionText

    Controller.blizzardAddOnLoaded = true;

    for modeID, modeHandler in pairs(Controller.modeHandlers) do
        modeHandler:BlizzardHouseEditorLoaded();
    end


    --CustomizeMode
    --local CustomizeModeFrame = HouseEditorFrame.CustomizeModeFrame;
    --hooksecurefunc(CustomizeModeFrame, "ShowDecorInstanceTooltip", CustomizeModeModule.ShowDecorInstanceTooltip);
end

function Controller:InitSubModules()
    local anyEnabled;

    for modeID, modeHandler in pairs(self.modeHandlers) do
        if modeHandler:IsEnabled() then
            anyEnabled = true;
        end
    end

    if anyEnabled then
        self:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED");
        self:RegisterEvent("PLAYER_ENTERING_WORLD");
    else
        self:UnregisterEvent("HOUSE_EDITOR_MODE_CHANGED");
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
    end

    self:UpdateActiveMode();
end

function Controller:IsBlizzardHouseEditorLoaded()
    return self.blizzardAddOnLoaded
end

function Controller:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if not IsHouseEditorActive() then
            self:UnregisterEvent(event);
            self:OnActiveModeChanged();
        end
    elseif event == "HOUSE_EDITOR_MODE_CHANGED" then
        local newMode = ...
        self:OnActiveModeChanged(newMode);
    end
end
Controller:SetScript("OnEvent", Controller.OnEvent);

function Controller:OnActiveModeChanged(newMode)
    if not newMode then newMode = 0 end;

	if self.activeModeHandler then
		if self.activeModeHandler == self.modeHandlers[newMode] then
            return
        end
		self.activeModeHandler:Deactivate();
        self.activeModeHandler = nil;
	end

	if self.modeHandlers[newMode] then
		self.modeHandlers[newMode]:Activate();
        self.activeModeHandler = self.modeHandlers[newMode];
	end
end

function Controller:UpdateActiveMode()
    if C_AddOns.IsAddOnLoaded("Blizzard_HouseEditor") then
        self:OnActiveModeChanged(C_HouseEditor.GetActiveHouseEditorMode());
    end
end

function Controller:RequestUpdate()
    if not self.pauseUpdate then
        self.pauseUpdate = true;
        C_Timer.After(0, function()
            self.pauseUpdate = nil;
            self:InitSubModules();
        end);
    end
end


do  --Create Handler
    local HanlderSharedMixin = {};

    function HanlderSharedMixin:Activate()
        if not self:IsEnabled() then return end;
        if self.activated then return end;
        self.activated = true;

        if self.Init then
            self:Init();
        end

        self:OnActivated();
    end

    function HanlderSharedMixin:Deactivate()
        if not self.activated then return end;
        self.activated = nil;

        self:OnDeactivated();
    end

    function HanlderSharedMixin:OnActivated()
    end

    function HanlderSharedMixin:OnDeactivated()
    end

    local function CreateModeHandler(editMode)
        local handler = CreateFrame("Frame");
        Mixin(handler, HanlderSharedMixin);
        handler.editMode = editMode;
        Controller.AddSubModule(handler);
        return handler
    end
    Controller.CreateModeHandler = CreateModeHandler;
end