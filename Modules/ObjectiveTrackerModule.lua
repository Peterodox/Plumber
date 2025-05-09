-- Unused

local _, addon = ...

do
    --[[
    C_Timer.After(2, function()
        PlumberObjectiveTracker.uiOrder = 128;
        PlumberObjectiveTracker.ignoreInLayout = true;
        ObjectiveTrackerManager:SetModuleContainer(PlumberObjectiveTracker, ObjectiveTrackerFrame);
        --ObjectiveTrackerFrame:RemoveModule(PlumberObjectiveTracker);
    end);
    --]]
    local UIParent = UIParent;
    local f = CreateFrame("Frame", nil, UIParent, "ObjectiveTrackerModuleHeaderTemplate");
    f:Hide();

    function f:SetTitle(title)
        self.Text:SetText(title);
    end
    f:SetTitle("Plumber");

    function f:PlayAddAnimation()
        self.AddAnim:Restart();
    end
    function f:OnToggle()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        f:SetCollapsed(not self.isCollapsed);
    end
    f.MinimizeButton:SetScript("OnClick", function(_, button)
        f:OnToggle();
    end);

    function f:SetCollapsed(collapsed)
        self.isCollapsed = collapsed;
        local normalTexture = self.MinimizeButton:GetNormalTexture();
        local pushedTexture = self.MinimizeButton:GetPushedTexture();
        if collapsed then
            normalTexture:SetAtlas("ui-questtrackerbutton-secondary-expand", true);
            pushedTexture:SetAtlas("ui-questtrackerbutton-secondary-expand-pressed", true);
        else
            normalTexture:SetAtlas("ui-questtrackerbutton-secondary-collapse", true);
            pushedTexture:SetAtlas("ui-questtrackerbutton-secondary-collapse-pressed", true);
        end
    end

    function f:Update()
        local container = ObjectiveTrackerFrame;
        local width = container:GetWidth();
        local left = container:GetLeft();

        self:ClearAllPoints();

        if container.isCollapsed then
            local top = container.NineSlice:GetTop();
            local headerSize = container.Header:GetHeight();
            local gap = 3;
            self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top - gap - headerSize);
        else
            local bottom = container.NineSlice:GetBottom();
            self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, bottom + 2);
        end

        self:SetSize(width, 32);

        f:Show();
    end

    local MainContainer = ObjectiveTrackerFrame;
    if MainContainer then
        MainContainer.NineSlice:HookScript("OnSizeChanged", function()
            f:Update();
        end);

        hooksecurefunc(MainContainer, "SetCollapsed", function(_, collapsed)
            f:Update();
        end);
    end

    --/dump ObjectiveTrackerFrame.isCollapsed
end