local _, addon = ...
local L = addon.L;
local API = addon.API;
local Housing = addon.Housing;  --Housing.HouseEditorController


local Handler = Housing.HouseEditorController.CreateModeHandler("AnyMode");


local Counter = CreateFrame("Frame");
do
    Counter.timeSpentInHouseEditor = 0;

    Counter:RegisterEvent("PLAYER_ENTERING_WORLD");

    Counter:SetScript("OnEvent", function(self, event, isInitialLogin)
        self:SetScript("OnEvent", nil);
        self:UnregisterEvent(event);
        if isInitialLogin then
            self.timeSpentInHouseEditor = 1;
            addon.SetDBValue("timeSpentInHouseEditor", 0);
        else
            self.timeSpentInHouseEditor = addon.GetDBValue("timeSpentInHouseEditor") or 1;
        end
    end);

    function Counter:GetTime()
        return API.SecondsToTime(math.floor(self.timeSpentInHouseEditor), true, true);
    end

    function Counter:SaveTime()
        addon.SetDBValue("timeSpentInHouseEditor", math.floor(self.timeSpentInHouseEditor));
    end
end


local ClockUIMixin = {};
do
    local date = date;
    local GetGameTime = GetGameTime;

    local TIME_FORMAT_12 = "%d:%02d";
    local TIME_FORMAT_24 = "%02d:%02d";


    function ClockUIMixin:OnShow()
        self:Refresh();
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
    end

    function ClockUIMixin:OnHide()
        self.t = 0;
        self:SetScript("OnUpdate", nil);
        if self.tooltipUpdator then
            self.tooltipUpdator:Hide();
        end
    end

    function ClockUIMixin:Refresh()
        if C_CVar.GetCVarBool("timeMgrUseLocalTime") then
            self.useLocalTime = true;
            self.UpdateTime = self.UpdateTime_Local;
        else
            self.useLocalTime = nil;
            self.UpdateTime = self.UpdateTime_Server;
        end
        self:SetAnalogMode(addon.GetDBBool("Housing_Clock_AnalogClock"));
        self:UpdateTime();
    end

    function ClockUIMixin:UpdateTime()

    end

    function ClockUIMixin:UpdateTime_Local()
        local hour, minute = tonumber(date("%H")), tonumber(date("%M"));
        self:SetTime(hour, minute);
    end

    function ClockUIMixin:UpdateTime_Server()
        local hour, minute = GetGameTime();
        self:SetTime(hour, minute);
    end

    function ClockUIMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        Counter.timeSpentInHouseEditor = Counter.timeSpentInHouseEditor + elapsed;
        if self.t >= 5 then
            self.t = 0;
            self:UpdateTime();
            Counter:SaveTime();
        end
    end

    function ClockUIMixin:SetTime(hour, minute)
        self:SetTime_Analog(hour, minute);
    end

    function ClockUIMixin:SetTime_Analog(hour, minute)
        --hour, minute = 10, 10;  --debug
        --/script local f = HousingControlsFrame;f:SetPoint("TOP", 0, -160)

        if hour > 12 then
            hour = hour - 12;
        end

        local rad1 = -2 * math.pi * (hour + minute/60) / 12;
        local rad2 = -2 * math.pi * minute/60;
        self.HourHand:SetRotation(rad1);
        self.HourShadow:SetRotation(rad1);
        self.MinuteHand:SetRotation(rad2);
        self.MinuteShadow:SetRotation(rad2);
    end

    function ClockUIMixin:SetTime_Digital(hour, minute)
        --hour, minute = 10, 10;  --debug

        if not self.useMilitaryTime then
            if hour == 0 then
                hour = 12;
            elseif hour > 12 then
                hour = hour - 12;
            end
        end
        self.Digits:SetText(TIME_FORMAT_12:format(hour, minute));
    end

    function ClockUIMixin:ShowTooltip()
        local tooltip = GameTooltip;

        local title;

        local bindingKey = GetBindingText(GetBindingKey("HOUSING_TOGGLEEDITOR"));
        if bindingKey and bindingKey ~= "" then
            title = HOUSING_CONTROLS_EDITOR_BUTTON_EXIT_FMT:format(bindingKey);
        else
            title = HOUSING_CONTROLS_EDITOR_BUTTON_EXIT;
        end

        tooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 2);
        tooltip:SetText(title, 1, 1, 1);

        --GameTime_UpdateTooltip();
        tooltip:AddLine(" ");
        tooltip:AddLine(TIMEMANAGER_TOOLTIP_TITLE, 1, 1, 1);

        if not self.lastTimeText then
            if self.useLocalTime then
                self.lastTimeLabel = TIMEMANAGER_TOOLTIP_LOCALTIME;
                self.lastTimeText = GameTime_GetLocalTime(true);
            else
                self.lastTimeLabel = TIMEMANAGER_TOOLTIP_REALMTIME;
                self.lastTimeText = GameTime_GetGameTime(true);
            end
        end
        tooltip:AddDoubleLine(self.lastTimeLabel, self.lastTimeText, 1, 0.82, 0, 1, 1, 1);

        tooltip:AddLine(" ");
        tooltip:AddLine(L["Time Spent In Editor"], 1, 1, 1);
        tooltip:AddDoubleLine(L["This Session Colon"], Counter:GetTime(), 1, 0.82, 0, 1, 1, 1);

        tooltip:AddLine(" ");
        tooltip:AddLine(L["Right Click Show Settings"], 1, 0.82, 0, true);

        tooltip:Show();
    end

    function ClockUIMixin:OnEnter()
        self.lastTimeText = nil;
        self:ShowTooltip();
        self:UpdateTime();
        if not self.tooltipUpdator then
            local f = CreateFrame("Frame", nil, self);
            self.tooltipUpdator = f;
            f.t = 0;
            f.s = 0;
            f:SetScript("OnUpdate", function(_, elapsed)
                f.t = f.t + elapsed;
                f.s = f.s + elapsed;
                if f.t > 0.2 then
                    f.t = 0;
                    if self:IsMouseMotionFocus() then
                        self:ShowTooltip();
                    else
                        f:Hide();
                    end
                end

                if f.s > 1 then
                    f.s = 0;
                    self.lastTimeText = nil;
                end
            end);
        end
        self.tooltipUpdator:Show();
    end

    function ClockUIMixin:SetAnalogMode(state)
        if state then
            self.isAnalogMode = true;
            self.SetTime = self.SetTime_Analog;
            self.Face:SetTexCoord(0, 128/512, 0, 128/512);
        else
            self.isAnalogMode = false;
            self.SetTime = self.SetTime_Digital;
            self.Face:SetTexCoord(0, 128/512, 128/512, 256/512);
        end
        self.MinuteHand:SetShown(state);
        self.MinuteShadow:SetShown(state);
        self.HourHand:SetShown(state);
        self.HourShadow:SetShown(state);
        self.Digits:SetShown(not state);
        self.useMilitaryTime = C_CVar.GetCVarBool("timeMgrUseMilitaryTime");
    end

    function ClockUIMixin:OnLeave()
        GameTooltip:Hide();
        if self.tooltipUpdator then
            self.tooltipUpdator:Hide();
        end
        Counter:SaveTime();
    end

    local ContextMenu = {
        tag = "PlumbeHouseEditorClock",
        objects = {
            {type = "Title", name = L["Plumber Clock"]},
            {type = "Divider"},

            {type = "Title", name = L["Clock Type"]},
            {type = "Radio", response = "Close",
                IsSelected = function(index)
                    local state = index == 1;
                    return addon.GetDBValue("Housing_Clock_AnalogClock") == state
                end,

                SetSelected = function(index)
                    local state = index == 1;
                    addon.SetDBValue("Housing_Clock_AnalogClock", state);
                    Handler.ClockFrame:Refresh();
                end,

                radios = {
                    L["Clock Type Analog"],
                    L["Clock Type Digital"],
                },
            },

            --[[
            {type = "Divider"},
            {type = "Checkbox", name = L["Auto Learn Traits"], tooltip = L["Auto Learn Traits Tooltip"],
                IsSelected = function()
                    return addon.GetDBBool("LegionRemix_AutoUpgrade");
                end,

                ToggleSelected = function()
                    return addon.FlipDBBool("LegionRemix_AutoUpgrade");
                end,
            },
            --]]
        };
    };

    function ClockUIMixin:ShowContextMenu()
        local menu = API.ShowBlizzardMenu(self, ContextMenu);
        menu:ClearAllPoints();
        menu:SetPoint("TOP", self, "BOTTOM", 0, 0);
    end

    function ClockUIMixin:OnClick(button)
        if button == "RightButton" then
            GameTooltip:Hide();
            self:OnLeave();
            self:ShowContextMenu();
        end
    end
end


do
    function Handler:Init()
        self.Init = nil;

        local f = CreateFrame("Button", nil, HousingControlsFrame.OwnerControlFrame, "PlumberPropagateMouseClicksTemplate");
        f:Hide();
        f:SetFrameLevel(100);
        f:RegisterForClicks("RightButtonUp");
        self.ClockFrame = f;
        f:SetSize(72, 72);
        f:SetPoint("CENTER", HousingControlsFrame.OwnerControlFrame.HouseEditorButton, "CENTER", 0, 0);
        Mixin(f, ClockUIMixin);

        local textureFile = "Interface/AddOns/Plumber/Art/Housing/ClockUI.png";
        f.Face = f:CreateTexture(nil, "BACKGROUND");
        f.Face:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.Face:SetSize(64, 64);
        f.Face:SetTexture(textureFile, nil, nil, "LINEAR");
        f.Face:SetTexCoord(0, 128/512, 0, 128/512);

        local filter = "TRILINEAR";    --LINEAR TRILINEAR

        local function CreateHand(textureSubLevel, l, r, offsetY)
            local hand = f:CreateTexture(nil, "OVERLAY", nil, textureSubLevel);
            API.DisableSharpening(hand);
            hand:SetSize(8, 64);
            hand:SetPoint("CENTER", f, "CENTER", 0, offsetY);
            hand:SetTexture(textureFile, nil, nil, filter);
            hand:SetTexCoord(l/512, r/512, 0, 128/512);
            return hand
        end

        f.MinuteHand = CreateHand(4, 128, 144, 0);
        f.HourHand = CreateHand(3, 144, 160, 0);
        f.MinuteShadow = CreateHand(0, 160, 176, -2);
        f.HourShadow = CreateHand(0, 176, 192, -2);

        f.Digits = f:CreateFontString(nil, "OVERLAY", nil, 1);
        f.Digits:SetFont("Fonts\\ARIALN.TTF", 18, "");
        f.Digits:SetShadowOffset(2, -3);
        f.Digits:SetShadowColor(0, 0, 0);
        f.Digits:SetTextColor(224/255, 210/255, 184/255);
        f.Digits:SetPoint("CENTER", f, "CENTER", 0, 0);
        f.Digits:Hide();

        f:SetScript("OnShow", f.OnShow);
        f:SetScript("OnHide", f.OnHide);
        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);

        f:Refresh();
        f:Show();
    end


    Handler.dynamicEvents = {

    };

    function Handler:OnActivated()
        API.RegisterFrameForEvents(self, self.dynamicEvents);
        self:SetScript("OnEvent", self.OnEvent);
        if self.ClockFrame then
            self.ClockFrame:Show();
        end
    end

    function Handler:OnDeactivated()
        API.UnregisterFrameForEvents(self, self.dynamicEvents);
        if self.ClockFrame then
            self.ClockFrame:Hide();
        end
        Counter:SaveTime();
    end

    function Handler:OnEvent(event, ...)

    end

    function Handler:LoadSettings()

    end
end


local OptionToggle_OnClick;
do  --Options
    local function InfoGetter_ClockSettings()
        local tbl = {
            key = "HouseEditorClockSettings",
            independent = true,
        };

        local widgets = {
            {type = "Header", text = L["Plumber Clock"]},
            {type = "Divider"},
            {type = "Header", text = L["Clock Type"]},
        };

        local selectedIndex = addon.GetDBBool("Housing_Clock_AnalogClock") and 1 or 2;

        local clockTypeOptions = {
            {name = L["Clock Type Analog"]},
            {name = L["Clock Type Digital"]},
        };

        for index, v in ipairs(clockTypeOptions) do
            table.insert(widgets, {
                type = "Radio",
                text = v.name;
                closeAfterClick = true,
                onClickFunc = function()
                    addon.SetDBValue("Housing_Clock_AnalogClock", index == 1, true);
                    Handler:LoadSettings();
                end,
                selected = index == selectedIndex,
            });
        end

        tbl.widgets = widgets;
        return tbl
    end

    function OptionToggle_OnClick(self)
        addon.LandingPageUtil.DropdownMenu:ToggleMenu(self, InfoGetter_ClockSettings);
    end
end


do
    local function EnableModule(state)
        Handler:SetEnabled(state);
    end

    local moduleData = {
        name = L["ModuleName Housing_Clock"],
        dbKey ="Housing_Clock",
        description = L["ModuleDescription Housing_Clock"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1,
        moduleAddedTime = 1765900000,
        optionToggleFunc = OptionToggle_OnClick,
        categoryKeys = {
            "Housing",
        },
        searchTags = {
            "Housing",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end