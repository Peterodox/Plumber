-- Suppress the alert message "Someone has declined the invite. You have been returned to the front of the queue."
-- Symptom: Three events (LFG_PROPOSAL_SHOW, CHAT_MSG_SYSTEM, LFG_PROPOSAL_FAILED) fire at the same time
-- Fix: Check the delta time between LFG_PROPOSAL_SHOW and LFG_PROPOSAL_FAILED

local _, addon = ...

local ALERT_MESSAGE = ERR_LFG_PROPOSAL_FAILED;

local GetTime = GetTime;


local EL = CreateFrame("Frame");

function EL:Enable()
    if self.enabled then return end;
    self.enabled = true;

    self:RegisterEvent("LFG_PROPOSAL_SHOW");
    self:RegisterEvent("LFG_PROPOSAL_DONE");
    self:RegisterEvent("LFG_PROPOSAL_FAILED");
    self:RegisterEvent("LFG_PROPOSAL_SUCCEEDED");
    self:RegisterEvent("UI_INFO_MESSAGE");

    self:SetScript("OnEvent", self.OnEvent);

    _G.ERR_LFG_PROPOSAL_FAILED = nil;
end

function EL:Disable()
    if not self.enabled then return end;
    self.enabled = nil;

    self:UnregisterEvent("LFG_PROPOSAL_SHOW");
    self:UnregisterEvent("LFG_PROPOSAL_DONE");
    self:UnregisterEvent("LFG_PROPOSAL_FAILED");
    self:UnregisterEvent("LFG_PROPOSAL_SUCCEEDED");
    self:UnregisterEvent("UI_INFO_MESSAGE");

    self:SetScript("OnEvent", nil);

    _G.ERR_LFG_PROPOSAL_FAILED = ALERT_MESSAGE;
end

function EL:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.1 then
        self.t = 0;
        self:SetScript("OnUpdate", nil);
        if self.intentionallyDeclined then
            self.intentionallyDeclined = nil;
        else
            UIErrorsFrame:CheckAddMessage(ALERT_MESSAGE, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b, 1.0);
        end
    end
end

function EL:RequestUpdate()
    self.t = 0;
    self:SetScript("OnUpdate", nil);
end

function EL:OnEvent(event, ...)
    if event == "LFG_PROPOSAL_SHOW" then
        self.lastUpdate = GetTime();
    elseif event == "LFG_PROPOSAL_FAILED" then
        local current = GetTime();
        if self.lastUpdate and current - self.lastUpdate >= 0.5 then
            self:RequestUpdate();
        end
    elseif event == "LFG_PROPOSAL_DONE" or event == "LFG_PROPOSAL_SUCCEEDED" then
        self.lastUpdate = GetTime();
    elseif event == "UI_INFO_MESSAGE" then
        local messageType = ...
        if messageType == 824 or messageType == 825 then
            self.intentionallyDeclined = true;
        end
    end
end


do
    local function EnableModule(state)
        if state then
            EL:Enable();
        else
            EL:Disable();
        end
    end

    local moduleData = {
        name = addon.L["ModuleName LegionRemix_LFGSpam"],
        dbKey = "LegionRemix_LFGSpam",
        description = addon.L["ModuleDescription LegionRemix_LFGSpam"],
        toggleFunc = EnableModule,
        categoryID = -1,
        uiOrder = 8,
        moduleAddedTime = 1762300000,
        timerunningSeason = 2,
		categoryKeys = {
			"Current",
		},
    };

    addon.ControlCenter:AddModule(moduleData);
end