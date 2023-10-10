local _, addon = ...
local API = addon.API;

local tonumber = tonumber;
local match = string.match;
local format = string.format;
local tinsert = table.insert;
local tremove = table.remove;
local floor = math.floor;
local sqrt = math.sqrt;
local time = time;
local GetCVarBool = C_CVar.GetCVarBool;

do  -- Table
    local function Mixin(object, ...)
        for i = 1, select("#", ...) do
            local mixin = select(i, ...)
            for k, v in pairs(mixin) do
                object[k] = v;
            end
        end
        return object
    end
    API.Mixin = Mixin;

    local function CreateFromMixins(...)
        return Mixin({}, ...)
    end
    API.CreateFromMixins = CreateFromMixins;


    local function RemoveValueFromList(tbl, v)
        for i = 1, #tbl do
            if tbl[i] == v then
                tremove(tbl, i);
                return true
            end
        end
    end
    API.RemoveValueFromList = RemoveValueFromList;


    local function ReverseList(list)
        local tbl = {};
        local n = 0;
        for i = #list, 1, -1 do
            n = n + 1;
            tbl[n] = list[i];
        end
        return tbl
    end
    API.ReverseList = ReverseList;
end

do  -- String
    local function GetCreatureIDFromGUID(guid)
        local id = match(guid, "Creature%-0%-%d*%-%d*%-%d*%-(%d*)");
        if id then
            return tonumber(id)
        end
    end
    API.GetCreatureIDFromGUID = GetCreatureIDFromGUID;
end

do  -- DEBUG

    local function SaveLocalizedText(localizedText, englishText)
        if not PlumberDevOutput then
            PlumberDevOutput = {};
        end

        local locale = GetLocale();
        if not PlumberDevOutput[locale] then
            PlumberDevOutput[locale] = {};
        end

        PlumberDevOutput[locale][localizedText] = englishText or true;
    end

    API.SaveLocalizedText = SaveLocalizedText;
end

do  --Math
    local function GetPointsDistance2D(x1, y1, x2, y2)
        return sqrt( (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2))
    end
    API.GetPointsDistance2D = GetPointsDistance2D;
end

do  -- Color
    local ColorSwatches = {
        SelectionBlue = {12, 105, 216},
        SmoothGreen = {124, 197, 118},
    };

    for _, swatch in pairs(ColorSwatches) do
        swatch[1] = swatch[1]/255;
        swatch[2] = swatch[2]/255;
        swatch[3] = swatch[3]/255;
    end

    local function GetColorByName(colorName)
        if ColorSwatches[colorName] then
            return unpack(ColorSwatches[colorName])
        else
            return 1, 1, 1
        end
    end
    API.GetColorByName = GetColorByName;


    -- Make Rare and Epic brighter (use the color in Narcissus)
    local QualityColors = {};
    QualityColors[3] = CreateColor(105/255, 158/255, 255/255, 1);
    QualityColors[4] = CreateColor(185/255, 83/255, 255/255, 1);

    local function GetItemQualityColor(quality)
        if QualityColors[quality] then
            return QualityColors[quality]
        else
            return ITEM_QUALITY_COLORS[quality].color
        end
    end
    API.GetItemQualityColor = GetItemQualityColor;
end

do
    -- Time
    local D_DAYS = D_DAYS or "%d |4Day:Days;";
    local D_HOURS = D_HOURS or "%d |4Hour:Hours;";
    local D_MINUTES = D_MINUTES or "%d |4Minute:Minutes;";
    local D_SECONDS = D_SECONDS or "%d |4Second:Seconds;";

    local DAYS_ABBR = DAYS_ABBR or "%d |4Day:Days;"
    local HOURS_ABBR = HOURS_ABBR or "%d |4Hr:Hr;";
    local MINUTES_ABBR = MINUTES_ABBR or "%d |4Min:Min;";
    local SECONDS_ABBR = SECONDS_ABBR or "%d |4Sec:Sec;";

    local function SecondsToTime(seconds, abbreviated, useHolidayFormat)
        local intialSeconds = seconds;
        local timeString = "";
        local isComplete = false;
        local days = 0;
        local hours = 0;
        local minutes = 0;

        if seconds >= 86400 then
            days = floor(seconds / 86400);
            timeString = format((abbreviated and DAYS_ABBR) or D_DAYS, days);
            seconds = seconds - days * 86400;
            if useHolidayFormat and days > 2 then
                isComplete = true;
            end
        end

        if (not isComplete) and seconds >= 3600 then
            hours = floor(seconds / 3600);
            if timeString == "" then
                timeString = format((abbreviated and HOURS_ABBR) or D_HOURS, hours);
            else
                timeString = timeString.." "..format((abbreviated and HOURS_ABBR) or D_HOURS, hours);
            end
            seconds = seconds - hours * 3600;
            if useHolidayFormat and (days >= 1) then
                isComplete = true;
            end
        end

        if (not isComplete) and seconds >= 60 then
            minutes = floor(seconds / 60);
            if timeString == "" then
                timeString = format((abbreviated and MINUTES_ABBR) or D_MINUTES, minutes);
            else
                timeString = timeString.." "..format((abbreviated and MINUTES_ABBR) or D_MINUTES, minutes);
            end
            seconds = seconds - minutes * 60;
            if useHolidayFormat then
                isComplete = true;
            end
        end

        if (not isComplete) and seconds > 0 then
            seconds = floor(seconds);
            if timeString == "" then
                timeString = format((abbreviated and SECONDS_ABBR) or D_SECONDS, seconds);
            else
                timeString = timeString.." "..format((abbreviated and SECONDS_ABBR) or D_SECONDS, seconds);
            end
        end

        if useHolidayFormat and intialSeconds < 172800 then
            --WARNING_FONT_COLOR
            timeString = "|cffff4800"..timeString.."|r";
        end

        return timeString
    end
    API.SecondsToTime = SecondsToTime;
end

do  -- Item
    local C_Item = C_Item;

    local function GetColorizedItemName(itemID)
        local name = C_Item.GetItemNameByID(itemID);
        local quality = C_Item.GetItemQualityByID(itemID);
    
        if name and quality then
            local color = API.GetItemQualityColor(quality);
            name = color:WrapTextInColorCode(name);
            if GetCVarBool("colorblindMode") then
                name = name.." |cffffffff[".._G[string.format("ITEM_QUALITY%s_DESC", quality)].."]|r";
            end
            return name
        end
    end
    API.GetColorizedItemName = GetColorizedItemName;
end

do  -- Tooltip Parser
    local GetInfoByHyperlink = C_TooltipInfo.GetHyperlink;

    local function GetLineText(lines, index)
        if lines[index] then
            return lines[index].leftText;
        end
    end

    local function GetCreatureName(creatureID)
        if not creatureID then return end;
        local tooltipData = GetInfoByHyperlink("unit:Creature-0-0-0-0-"..creatureID);
        if tooltipData then
            return GetLineText(tooltipData.lines, 1);
        end
    end

    API.GetCreatureName = GetCreatureName;
end

do  -- Holiday
    local CalendarTextureXHolidayKey = {
        --Only the important ones :)
        [235469] = "lunarfestival",
        [235470] = "lunarfestival",
        [235471] = "lunarfestival",

        [235466] = "loveintheair",
        [235467] = "loveintheair",
        [235468] = "loveintheair",

        [235475] = "noblegarden",
        [235476] = "noblegarden",
        [235477] = "noblegarden",

        [235443] = "childrensweek",
        [235444] = "childrensweek",
        [235445] = "childrensweek",

        [235472] = "midsummer",
        [235473] = "midsummer",
        [235474] = "midsummer",

        [235439] = "brewfest",
        [235440] = "brewfest",
        [235441] = "brewfest",
        [235442] = "brewfest",

        [235460] = "hallowsendend",
        [235461] = "hallowsendend",
        [235462] = "hallowsendend",

        [235482] = "winterveil",
        [235483] = "winterveil",
        [235484] = "winterveil",
        [235485] = "winterveil",
    };

    local function GetTimeDifference_Recursion(lhs, rhs, totalDayOffset)
        --Requires Calendar Time (table)
        if not totalDayOffset then
            totalDayOffset = 0;
        end

        local diffYear = rhs.year - lhs.year;
        local diffMonth = rhs.month - lhs.month;
        local diffDay = rhs.monthDay - lhs.monthDay;

        local dayOffset = floor(diffYear * 365 + diffMonth * 30.4 + diffDay * 1 + 0.5);

        if dayOffset ~= 0 then
            totalDayOffset = totalDayOffset + dayOffset;
            local ct = C_DateAndTime.AdjustTimeByDays(lhs, dayOffset);
            GetTimeDifference_Recursion(ct, rhs, totalDayOffset);
        end

        local minuteOffset = (totalDayOffset * 24 + rhs.hour - lhs.hour) * 60 + (rhs.minute - lhs.minute);

        return totalDayOffset, minuteOffset
    end

    local HolidayInfoMixin = {};

    function HolidayInfoMixin:GetRemainingSeconds()
        if self.endTime then
            local presentTime = time();
            return self.endTime - presentTime
        else
            return 0
        end
    end

    function HolidayInfoMixin:GetEndTimeString()
        --MM/DD 00:00
        return self.endTimeString
    end

    function HolidayInfoMixin:GetRemainingTimeString()
        --DD/HH/MM/SS
        local seconds = self:GetRemainingSeconds();
        return API.SecondsToTime(seconds, false, true);
    end

    function HolidayInfoMixin:GetName()
        return self.name
    end

    function HolidayInfoMixin:GetKey()
        return self.key
    end

    local function GetActiveMajorHolidayInfo()
        local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
        local presentDay = currentCalendarTime.monthDay;
        local monthOffset = 0;
        local holidayInfo;
        local holidayKey, holidayName;
        local endTimeString, remainingSeconds;
        local eventEndTimeMixin;    --{}
        local endTime;              --number time()

        for i = 1, C_Calendar.GetNumDayEvents(monthOffset, presentDay) do   --Need to request data first with C_Calendar.OpenCalendar()
            holidayInfo = C_Calendar.GetHolidayInfo(monthOffset, presentDay, i);
            if holidayInfo and holidayInfo.texture and CalendarTextureXHolidayKey[holidayInfo.texture] then
                holidayKey = CalendarTextureXHolidayKey[holidayInfo.texture];
                holidayName = holidayInfo.name;
                if holidayInfo.startTime and holidayInfo.endTime then
                    endTimeString = FormatShortDate(holidayInfo.endTime.monthDay, holidayInfo.endTime.month) .." "..  GameTime_GetFormattedTime(holidayInfo.endTime.hour, holidayInfo.endTime.minute, true);
                    eventEndTimeMixin = holidayInfo.endTime;
                end
                break
            end
        end

        if eventEndTimeMixin then
            local dayOffset, minuteOffset = GetTimeDifference_Recursion(currentCalendarTime, eventEndTimeMixin);
            local presentTime = time();
            remainingSeconds = minuteOffset * 60;
            endTime = presentTime + remainingSeconds;
            if remainingSeconds <= 0 then
                return
            end
        end

        if holidayName then
            local mixin = API.CreateFromMixins(HolidayInfoMixin);

            mixin.name = holidayName;
            mixin.key = holidayKey;
            mixin.endTimeString = endTimeString;
            mixin.endTime = endTime;

            return mixin
        end
    end
    API.GetActiveMajorHolidayInfo = GetActiveMajorHolidayInfo;
end

do  --Fade Frame
    local abs = math.abs;
    local tinsert = table.insert;
    local wipe = wipe;

    local fadeInfo = {};
    local fadingFrames = {};

    local f = CreateFrame("Frame");

    local function OnUpdate(self, elpased)
        local i = 1;
        local frame, info, timer, alpha;
        local isComplete = true;
        while fadingFrames[i] do
            frame = fadingFrames[i];
            info = fadeInfo[frame];
            if info then
                timer = info.timer + elpased;
                if timer >= info.duration then
                    alpha = info.toAlpha;
                    fadeInfo[frame] = nil;
                    if info.alterShownState and alpha <= 0 then
                        frame:Hide();
                    end
                else
                    alpha = info.fromAlpha + (info.toAlpha - info.fromAlpha) * timer/info.duration;
                    info.timer = timer;
                end
                frame:SetAlpha(alpha);
                isComplete = false;
            end
            i = i + 1;
        end

        if isComplete then
            f:Clear();
        end
    end

    function f:Clear()
        self:SetScript("OnUpdate", nil);
        wipe(fadingFrames);
        wipe(fadeInfo);
    end

    function f:Add(frame, fullDuration, fromAlpha, toAlpha, alterShownState, useConstantDuration)
        local alpha = frame:GetAlpha();
        if alterShownState then
            if toAlpha > 0 then
                frame:Show();
            end
            if toAlpha == 0 then
                if not frame:IsShown() then
                    frame:SetAlpha(0);
                    alpha = 0;
                end
                if alpha == 0 then
                    frame:Hide();
                end
            end
        end
        if fromAlpha == toAlpha or alpha == toAlpha then
            if fadeInfo[frame] then
                fadeInfo[frame] = nil;
            end
            return;
        end
        local duration;
        if useConstantDuration then
            duration = fullDuration;
        else
            if fromAlpha then
                duration = fullDuration * (alpha - toAlpha)/(fromAlpha - toAlpha);
            else
                duration = fullDuration * abs(alpha - toAlpha);
            end
        end
        if duration <= 0 then
            frame:SetAlpha(toAlpha);
            if toAlpha == 0 then
                frame:Hide();
            end
            return;
        end
        fadeInfo[frame] = {
            fromAlpha = alpha,
            toAlpha = toAlpha,
            duration = duration,
            timer = 0,
            alterShownState = alterShownState,
        };
        for i = 1, #fadingFrames do
            if fadingFrames[i] == frame then
                return;
            end
        end
        tinsert(fadingFrames, frame);
        self:SetScript("OnUpdate", OnUpdate);
    end

    function f:SimpleFade(frame, toAlpha, alterShownState, speedMultiplier)
        --Use a constant fading speed: 1.0 in 0.25s
        --alterShownState: if true, run Frame:Hide() when alpha reaches zero / run Frame:Show() at the beginning
        speedMultiplier = speedMultiplier or 1;
        local alpha = frame:GetAlpha();
        local duration = abs(alpha - toAlpha) * 0.25 * speedMultiplier;
        if duration <= 0 then
            return;
        end
        
        self:Add(frame, duration, alpha, toAlpha, alterShownState, true);
    end

    function f:Snap()
        local i = 1;
        local frame, info;
        while fadingFrames[i] do
            frame = fadingFrames[i];
            info = fadeInfo[frame];
            if info then
                frame:SetAlpha(info.toAlpha);
            end
            i = i + 1;
        end
        self:Clear();
    end

    local function UIFrameFade(frame, duration, toAlpha, initialAlpha)
        if initialAlpha then
            frame:SetAlpha(initialAlpha);
            f:Add(frame, duration, initialAlpha, toAlpha, true, false);
        else
            f:Add(frame, duration, nil, toAlpha, true, false);
        end
    end

    local function UIFrameFadeIn(frame, duration)
        frame:SetAlpha(0);
        f:Add(frame, duration, 0, 1, true, false);
    end


    API.UIFrameFade = UIFrameFade;       --from current alpha
    API.UIFrameFadeIn = UIFrameFadeIn;   --from 0 to 1
end

do
    ---- Create Module that will be activated in specific zones:
    ---- 1. Soridormi Auto-report

    local GetBestMapForUnit = C_Map.GetBestMapForUnit;
    local controller;
    local modules;
    local lastMapID, total;

    local ZoneTriggeredModuleMixin = {};

    ZoneTriggeredModuleMixin.validMaps = {};
    ZoneTriggeredModuleMixin.inZone = false;
    ZoneTriggeredModuleMixin.enabled = true;

    local function DoNothing()
    end

    ZoneTriggeredModuleMixin.enterZoneCallback = DoNothing;
    ZoneTriggeredModuleMixin.leaveZoneCallback = DoNothing;

    function ZoneTriggeredModuleMixin:IsZoneValid(uiMapID)
        return self.validMaps[uiMapID]
    end

    function ZoneTriggeredModuleMixin:SetValidZones(...)
        self.validMaps = {};
        for i = 1, select("#", ...) do
            local uiMapID = select(i, ...);
            self.validMaps[uiMapID] = true;
        end
    end

    function ZoneTriggeredModuleMixin:PlayerEnterZone()
        if not self.inZone then
            self.inZone = true;
            self.enterZoneCallback();
        end
    end

    function ZoneTriggeredModuleMixin:PlayerLeaveZone()
        if self.inZone then
            self.inZone = false;
            self.leaveZoneCallback();
        end
    end

    function ZoneTriggeredModuleMixin:SetEnterZoneCallback(callback)
        self.enterZoneCallback = callback;
    end

    function ZoneTriggeredModuleMixin:SetLeaveZoneCallback(callback)
        self.leaveZoneCallback = callback;
    end

    function ZoneTriggeredModuleMixin:SetEnabled(state)
        self.enabled = state or false;
        if not self.enabled then
            self.inZone = false;
            self:PlayerLeaveZone();
        end
    end

    function ZoneTriggeredModuleMixin:Update()
        if not self.enabled then return end;

        local mapID = GetBestMapForUnit("player");
        if self:IsZoneValid(mapID) then
            self:PlayerEnterZone();
        else
            self:PlayerLeaveZone();
        end
    end

    local function AddZoneModules(module)
        if not controller then
            controller = CreateFrame("Frame");
            modules = {};
            total = 0;

            controller:SetScript("OnEvent", function(f, event, ...)
                local mapID = GetBestMapForUnit("player");

                if mapID and mapID ~= lastMapID then
                    lastMapID = mapID;
                else
                    return
                end

                for i = 1, total do
                    if modules[i].enabled then
                        if modules[i]:IsZoneValid(mapID) then
                            modules[i]:PlayerEnterZone();
                        else
                            modules[i]:PlayerLeaveZone();
                        end
                    end
                end
            end);

            controller:RegisterEvent("ZONE_CHANGED_NEW_AREA");
            controller:RegisterEvent("PLAYER_ENTERING_WORLD");
        end

        table.insert(modules, module);
        total = total + 1;
    end

    local function CreateZoneTriggeredModule()
        local module = {};

        for k, v in pairs(ZoneTriggeredModuleMixin) do
            module[k] = v;
        end

        AddZoneModules(module);

        return module
    end

    API.CreateZoneTriggeredModule = CreateZoneTriggeredModule;
end