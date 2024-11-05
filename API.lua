local _, addon = ...
local API = addon.API;
local L = addon.L;

local tonumber = tonumber;
local match = string.match;
local format = string.format;
local gsub = string.gsub;
local tinsert = table.insert;
local tremove = table.remove;
local floor = math.floor;
local sqrt = math.sqrt;
local time = time;
local unpack = unpack;
local GetCVarBool = C_CVar.GetCVarBool;
local CreateFrame = CreateFrame;
local securecallfunction = securecallfunction;

local function Nop(...)
end
API.Nop = Nop;

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
        if not list then return end;
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

    local function GetVignetteIDFromGUID(guid)
        local id = match(guid, "Vignette%-0%-%d*%-%d*%-%d*%-(%d*)");
        if id then
            return tonumber(id)
        end
    end
    API.GetVignetteIDFromGUID = GetVignetteIDFromGUID;

    local function GetWaypointFromText(text)
        local uiMapID, x, y = match(text, "|Hworldmap:(%d*):(%d*):(%d*)|h");
        if uiMapID and x and y then
            return tonumber(uiMapID), tonumber(x), tonumber(y)
        end
    end
    API.GetWaypointFromText = GetWaypointFromText;


    local UnitGUID = UnitGUID;

    local function GetUnitCreatureID(unit)
        local guid = UnitGUID(unit);
        if guid then
            return GetCreatureIDFromGUID(guid)
        end
    end
    API.GetUnitCreatureID = GetUnitCreatureID;


    local function GetGlobalObject(objNameKey)
        --Get object via string "FrameName.Key1.Key2"
        local obj = _G;

        for k in string.gmatch(objNameKey, "%w+") do
            obj = obj[k];
            if not obj then
                return
            end
        end

        return obj
    end
    API.GetGlobalObject = GetGlobalObject;
end

do  -- DEBUG
    local function CreateSaveDB(key)
        if not PlumberDevOutput then
            PlumberDevOutput = {};
        end
        if not PlumberDevOutput[key] then
            PlumberDevOutput[key] = {};
        end
    end

    local function SaveLocalizedText(localizedText, englishText)
        local locale = GetLocale();
        CreateSaveDB(locale);
        PlumberDevOutput[locale][localizedText] = englishText or true;
    end
    API.SaveLocalizedText = SaveLocalizedText;

    local function SaveDataUnderKey(key, ...)
        CreateSaveDB(key);
        PlumberDevOutput[key] = {...}
    end
    API.SaveDataUnderKey = SaveDataUnderKey;
end

do  --Math
    local function Clamp(value, min, max)
        if value > max then
            return max
        elseif value < min then
            return min
        end
        return value
    end
    API.Clamp = Clamp;

    local function Lerp(startValue, endValue, amount)
        return (1 - amount) * startValue + amount * endValue;
    end
    API.Lerp = Lerp;

    local function GetPointsDistance2D(x1, y1, x2, y2)
        return sqrt( (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2))
    end
    API.GetPointsDistance2D = GetPointsDistance2D;

    local function Round(n)
        return floor(n + 0.5);
    end
    API.Round = Round;

    local function RoundCoord(n)
        return floor(n * 1000 + 0.5) * 0.001
    end
    API.RoundCoord = RoundCoord;

    local function Saturate(value)
        return Clamp(value, 0.0, 1.0);
    end

    local function DeltaLerp(startValue, endValue, amount, timeSec)
        return Lerp(startValue, endValue, Saturate(amount * timeSec * 60.0));
    end
    API.DeltaLerp = DeltaLerp;
end

do  -- Color
    local ColorSwatches = {
        SelectionBlue = {12, 105, 216},
        SmoothGreen = {124, 197, 118},
        WarningRed = {212, 100, 28}, --228, 13, 14  248, 81, 73
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
    local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS;
    local QualityColors = {};
    QualityColors[1] = CreateColor(0.92, 0.92, 0.92, 1);
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


    local function IsWarningColor(r, g, b)
        --Used to determine if the tooltip fontstring is red, which indicates there is a requirement you don't meet
        return (r > 0.99 and r <= 1) and (g > 0.1254 and g < 0.1255) and (b > 0.1254 and b < 0.1255)
    end
    API.IsWarningColor = IsWarningColor;


    local function SetTextColorByGlobal(fontString, colorMixin)
        local r, g, b;
        if colorMixin then
            r, g, b = colorMixin:GetRGB();
        else
            r, g, b = 1, 1, 1;
        end
        fontString:SetTextColor(r, g, b);
    end
    API.SetTextColorByGlobal = SetTextColorByGlobal;
end

do  -- Time
    local D_DAYS = D_DAYS or "%d |4Day:Days;";
    local D_HOURS = D_HOURS or "%d |4Hour:Hours;";
    local D_MINUTES = D_MINUTES or "%d |4Minute:Minutes;";
    local D_SECONDS = D_SECONDS or "%d |4Second:Seconds;";

    local DAYS_ABBR = DAYS_ABBR or "%d |4Day:Days;"
    local HOURS_ABBR = HOURS_ABBR or "%d |4Hr:Hr;";
    local MINUTES_ABBR = MINUTES_ABBR or "%d |4Min:Min;";
    local SECONDS_ABBR = SECONDS_ABBR or "%d |4Sec:Sec;";

    local SHOW_HOUR_BELOW_DAYS = 3;
    local SHOW_MINUTE_BELOW_HOURS = 12;
    local SHOW_SECOND_BELOW_MINUTES = 10;
    local COLOR_RED_BELOW_SECONDS = 172800;

    local function BakePlural(number, singularPlural)
        singularPlural = gsub(singularPlural, ";", "");

        if number > 1 then
            return format(gsub(singularPlural, "|4[^:]*:", ""), number);
        else
            singularPlural = gsub(singularPlural, ":.*", "");
            singularPlural = gsub(singularPlural, "|4", "");
            return format(singularPlural, number);
        end
    end

    local function FormatTime(t, pattern, bakePluralEscapeSequence)
        if bakePluralEscapeSequence then
            return BakePlural(t, pattern);
        else
            return format(pattern, t);
        end
    end

    local function SecondsToTime(seconds, abbreviated, partialTime, bakePluralEscapeSequence)
        --partialTime: Stop processing if the remaining units don't really matter. e.g. to display the remaining time of an event when there are still days left
        --bakePluralEscapeSequence: Convert EcsapeSequence like "|4Sec:Sec;" to its result so it can be sent to chat
        local intialSeconds = seconds;
        local timeString = "";
        local isComplete = false;
        local days = 0;
        local hours = 0;
        local minutes = 0;

        if seconds >= 86400 then
            days = floor(seconds / 86400);
            seconds = seconds - days * 86400;

            local dayText = FormatTime(days, (abbreviated and DAYS_ABBR) or D_DAYS, bakePluralEscapeSequence);
            timeString = dayText;

            if partialTime and days >= SHOW_HOUR_BELOW_DAYS then
                isComplete = true;
            end
        end

        if not isComplete then
            hours = floor(seconds / 3600);
            seconds = seconds - hours * 3600;

            if hours > 0 then
                local hourText = FormatTime(hours, (abbreviated and HOURS_ABBR) or D_HOURS, bakePluralEscapeSequence);
                if timeString == "" then
                    timeString = hourText;
                else
                    timeString = timeString.." "..hourText;
                end

                if partialTime and hours >= SHOW_MINUTE_BELOW_HOURS then
                    isComplete = true;
                end
            else
                if timeString ~= "" and partialTime then
                    isComplete = true;
                end
            end
        end

        if partialTime and days > 0 then
            isComplete = true;
        end

        if not isComplete then
            minutes = floor(seconds / 60);
            seconds = seconds - minutes * 60;

            if minutes > 0 then
                local minuteText = FormatTime(minutes, (abbreviated and MINUTES_ABBR) or D_MINUTES, bakePluralEscapeSequence);
                if timeString == "" then
                    timeString = minuteText;
                else
                    timeString = timeString.." "..minuteText;
                end
                if partialTime and minutes >= SHOW_SECOND_BELOW_MINUTES then
                    isComplete = true;
                end
            else
                if timeString ~= "" and partialTime then
                    isComplete = true;
                end
            end
        end

        if (not isComplete) and seconds > 0 then
            seconds = floor(seconds);
            local secondText = FormatTime(seconds, (abbreviated and SECONDS_ABBR) or D_SECONDS, bakePluralEscapeSequence);
            if timeString == "" then
                timeString = secondText;
            else
                timeString = timeString.." "..secondText;
            end
        end

        if partialTime and intialSeconds < COLOR_RED_BELOW_SECONDS and not bakePluralEscapeSequence then
            --WARNING_FONT_COLOR
            timeString = "|cffff4800"..timeString.."|r";
        end

        return timeString
    end
    API.SecondsToTime = SecondsToTime;

    local function SecondsToClock(seconds)
        --Clock: 00:00
        return format("%s:%02d", math.floor(seconds / 60), math.floor(seconds % 60))
    end
    API.SecondsToClock = SecondsToClock;

    --Unix Epoch is in UTC
    local MonthDays = {
        31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,
    };

    local function IsLeapYear(year)
        return year % 400 == 0 or (year % 4 == 0 and year % 100 ~= 0)
    end

    local function GetFebruaryDays(year)
        if IsLeapYear(year) then
            return 29
        else
            return 28
        end
    end

    local function IsLeftTimeFuture(time1, time2, i)
        if not time1[i] then return false end;

        if time1[i] > time2[i] then
            return true;
        elseif time1[i] == time2[i] then
            return IsLeftTimeFuture(time1, time2, i + 1);
        else
            return false
        end
    end

    local function GetNumDaysToDate(year, month, day)
        local numDays = day;

        for yr = 1, (year -1) do
            if IsLeapYear(yr) then
                numDays = numDays + 366;
            else
                numDays = numDays + 365;
            end
        end

        for m = 1, (month - 1) do
            if m == 2 then
                numDays = numDays + GetFebruaryDays(year);
            else
                numDays = numDays + MonthDays[m];
            end
        end

        return numDays
    end

    local function GetNumSecondsToDate(year, month, day, hour, minute, second)
        hour = hour or 0;
        minute = minute or 0;
        second = second or 0;
        local numDays = GetNumDaysToDate(year, month, day);
        local numSeconds = second;
        numSeconds = numSeconds + numDays * 86400;
        numSeconds = numSeconds + hour * 3600 + minute * 60;
        return numSeconds
    end

    local function ConvertCalendarTime(calendarTime)
        --WoW's CalendarTime See https://warcraft.wiki.gg/wiki/API_C_DateAndTime.GetCurrentCalendarTime
        local year = calendarTime.year;
        local month = calendarTime.month;
        local day = calendarTime.monthDay;
        local hour = calendarTime.hour;
        local minute = calendarTime.minute;
        local second = calendarTime.second or 0;    --the original calendarTime does not contain second

        return {year, month, day, hour, minute, second}
    end

    local function GetCalendarTimeDifference(lhsCalendarTime, rhsCalendarTime)
        --time = {year, month, day, hour, minute, second}
        local time1 = ConvertCalendarTime(lhsCalendarTime);
        local time2 = ConvertCalendarTime(rhsCalendarTime);
        local second1 = GetNumSecondsToDate(unpack(time1));
        local second2 = GetNumSecondsToDate(unpack(time2));
        return second2 - second1
    end
    API.GetCalendarTimeDifference = GetCalendarTimeDifference;


    local function WrapNumberWithBrackets(text)
        text = gsub(text, "%%d%+", "%%d");
        text = gsub(text, "%%d", "%(%%d%+%)");
        return text
    end

    local PATTERN_DAYS = WrapNumberWithBrackets(DAYS_ABBR);
    local PATTERN_HOURS = WrapNumberWithBrackets(HOURS_ABBR);
    local PATTERN_MINUTES = WrapNumberWithBrackets(MINUTES_ABBR);
    local PATTERN_SECONDS = WrapNumberWithBrackets(SECONDS_ABBR);

    local function ConvertTextToSeconds(durationText)
        if not durationText then return 0 end;

        local hours = tonumber(match(durationText, PATTERN_HOURS) or 0);
        local minutes = tonumber(match(durationText, PATTERN_MINUTES) or 0);
        local seconds = tonumber(match(durationText, PATTERN_SECONDS) or 0);

        return 3600 * hours + 60 * minutes + seconds;
    end
    API.TimeLeftTextToSeconds = ConvertTextToSeconds;
end

do  -- Item
    local C_Item = C_Item;
    local GetItemSpell = GetItemSpell;

    local function ColorizeTextByQuality(text, quality, allowColorBlind)
        if not (text and quality) then
            return text
        end

        local color = API.GetItemQualityColor(quality);
        text = color:WrapTextInColorCode(text);
        if allowColorBlind and GetCVarBool("colorblindMode") then
            text = text.." |cffffffff[".._G[format("ITEM_QUALITY%s_DESC", quality)].."]|r";
        end

        return text
    end
    API.ColorizeTextByQuality = ColorizeTextByQuality;

    local function GetColorizedItemName(itemID)
        local name = C_Item.GetItemNameByID(itemID);
        local quality = C_Item.GetItemQualityByID(itemID);

        return ColorizeTextByQuality(name, quality, true);
    end
    API.GetColorizedItemName = GetColorizedItemName;

    local function GetItemSpellID(item)
        local spellName, spellID = GetItemSpell(item);
        return spellID
    end
    API.GetItemSpellID = GetItemSpellID;
end

do  -- Tooltip Parser
    local GetInfoByHyperlink = C_TooltipInfo and C_TooltipInfo.GetHyperlink;

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
        local endTimeString;
        local eventEndTimeMixin;    --{}
        local endTime;              --number time()
        local activeHolidayData;    --{ {holiday1}, {holiday2} }

        for i = 1, C_Calendar.GetNumDayEvents(monthOffset, presentDay) do   --Need to request data first with C_Calendar.OpenCalendar()
            holidayInfo = C_Calendar.GetHolidayInfo(monthOffset, presentDay, i);
            --print(i, holidayInfo.name)
            if holidayInfo and holidayInfo.texture and CalendarTextureXHolidayKey[holidayInfo.texture] then
                holidayKey = CalendarTextureXHolidayKey[holidayInfo.texture];
                holidayName = holidayInfo.name;

                if holidayInfo.startTime and holidayInfo.endTime then
                    endTimeString = FormatShortDate(holidayInfo.endTime.monthDay, holidayInfo.endTime.month) .." "..  GameTime_GetFormattedTime(holidayInfo.endTime.hour, holidayInfo.endTime.minute, true);
                    eventEndTimeMixin = holidayInfo.endTime;
                end

                local isEventActive = true;
                if eventEndTimeMixin then
                    local presentTime = time();
                    local remainingSeconds = API.GetCalendarTimeDifference(currentCalendarTime, eventEndTimeMixin);
                    endTime = presentTime + remainingSeconds;
                    if remainingSeconds <= 0 then
                        isEventActive = false;
                    end
                end
        
                if isEventActive and holidayName then
                    local mixin = API.CreateFromMixins(HolidayInfoMixin);
        
                    mixin.name = holidayName;
                    mixin.key = holidayKey;
                    mixin.endTimeString = endTimeString;
                    mixin.endTime = endTime;
        
                    if not activeHolidayData then
                        activeHolidayData = {};
                    end

                    tinsert(activeHolidayData, mixin);
                end
            end
        end

        return activeHolidayData
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

do  -- Map
    ---- Create Module that will be activated in specific zones:
    ---- 1. Soridormi Auto-report
    ---- 2. Dreamseed

    local C_Map = C_Map;
    local GetMapInfo = C_Map.GetMapInfo;
    local GetBestMapForUnit = C_Map.GetBestMapForUnit;
    local CreateVector2D = CreateVector2D;
    local controller;
    local modules;
    local lastMapID, total;

    local ZoneTriggeredModuleMixin = {};

    ZoneTriggeredModuleMixin.validMaps = {};
    ZoneTriggeredModuleMixin.inZone = false;
    ZoneTriggeredModuleMixin.enabled = true;

    local function DoNothing(arg)
    end

    ZoneTriggeredModuleMixin.enterZoneCallback = DoNothing;
    ZoneTriggeredModuleMixin.leaveZoneCallback = DoNothing;

    function ZoneTriggeredModuleMixin:IsZoneValid(uiMapID)
        return self.validMaps[uiMapID]
    end

    function ZoneTriggeredModuleMixin:SetValidZones(...)
        self.validMaps = {};
        local map;
        for i = 1, select("#", ...) do
            map = select(i, ...);
            if type(map) == "table" then
                for _, uiMapID in ipairs(map) do
                    self.validMaps[uiMapID] = true;
                end
            else
                self.validMaps[map] = true;
            end
        end
    end

    function ZoneTriggeredModuleMixin:PlayerEnterZone(mapID)
        if not self.inZone then
            self.inZone = true;
            self.enterZoneCallback(mapID);
        end

        if mapID ~= self.currentMapID then
            self.currentMapID = mapID;
            self:OnCurrentMapChanged(mapID);
        end
    end

    function ZoneTriggeredModuleMixin:PlayerLeaveZone()
        if self.inZone then
            self.inZone = false;
            self.currentMapID = nil;
            self.leaveZoneCallback();
        end
    end

    function ZoneTriggeredModuleMixin:SetEnterZoneCallback(callback)
        self.enterZoneCallback = callback;
    end

    function ZoneTriggeredModuleMixin:SetLeaveZoneCallback(callback)
        self.leaveZoneCallback = callback;
    end

    function ZoneTriggeredModuleMixin:OnCurrentMapChanged(newMapID)
    end

    function ZoneTriggeredModuleMixin:SetEnabled(state)
        self.enabled = state or false;
        if not self.enabled then
            self:PlayerLeaveZone();
        end
    end

    function ZoneTriggeredModuleMixin:Update()
        if not self.enabled then return end;

        local mapID = GetBestMapForUnit("player");
        if self:IsZoneValid(mapID) then
            self:PlayerEnterZone(mapID);
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
                            modules[i]:PlayerEnterZone(mapID);
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

    local function CreateZoneTriggeredModule(tag)
        local module = {
            tag = tag,
            validMaps = {},
        };

        for k, v in pairs(ZoneTriggeredModuleMixin) do
            module[k] = v;
        end

        AddZoneModules(module);

        return module
    end

    API.CreateZoneTriggeredModule = CreateZoneTriggeredModule;


    --Get Player Coord Less RAM cost
    local UnitPosition = UnitPosition;
    local GetPlayerMapPosition = C_Map.GetPlayerMapPosition;
    local _posY, _posX, _data;
    local lastUiMapID;
    local MapData = {};

    local function CacheMapData(uiMapID)
        if MapData[uiMapID] then return end;

        local instance, topLeft = C_Map.GetWorldPosFromMapPos(uiMapID, {x=0, y=0});
        local width, height = C_Map.GetMapWorldSize(uiMapID);

        if topLeft then
            local top, left = topLeft:GetXY()
            MapData[uiMapID] = {width, height, left, top};
        end
    end

    local function GetPlayerMapCoord_Fallback(uiMapID)
        local position = GetPlayerMapPosition(uiMapID, "player");
        if position then
            return position.x, position.Y
        end
    end

    local function GetPlayerMapCoord(uiMapID)
        _posY, _posX = UnitPosition("player");
        if not (_posX and _posY) then return GetPlayerMapCoord_Fallback(uiMapID) end;

        if uiMapID ~= lastUiMapID then
            lastUiMapID = uiMapID;
            CacheMapData(uiMapID);
        end

        _data = MapData[uiMapID]
        if not _data or _data[1] == 0 or _data[2] == 0 then return GetPlayerMapCoord_Fallback(uiMapID) end;

        return (_data[3] - _posX) / _data[1], (_data[4] - _posY) / _data[2]
    end
    API.GetPlayerMapCoord = GetPlayerMapCoord;


    local function ConvertMapPositionToContinentPosition(uiMapID, x, y, poiID)
        local info = GetMapInfo(uiMapID);
        if not info then return end;

        local continentMapID;   --uiMapID

        while info do
            if info.mapType == Enum.UIMapType.Continent then
                continentMapID = info.mapID;
                break
            elseif info.parentMapID then
                info = GetMapInfo(info.parentMapID);
            else
                return
            end
        end

        if not continentMapID then
            print(string.format("Map %s doesn't belong to any continent.", uiMapID));
        end

        local point = {
            uiMapID = uiMapID,
            position = CreateVector2D(x, y);
        };

        C_Map.SetUserWaypoint(point);

        C_Timer.After(0, function()
            local posVector = C_Map.GetUserWaypointPositionForMap(continentMapID);
            if posVector then
                x, y = posVector:GetXY();
                print(continentMapID, x, y);
                
                if not PlumberDevData then
                    PlumberDevData = {};
                end

                if not PlumberDevData.POIPositions then
                    PlumberDevData.POIPositions = {};
                end
    
                if poiID then
                    x = API.RoundCoord(x);
                    y = API.RoundCoord(y);
                    PlumberDevData.POIPositions[poiID] = {
                        poiID = poiID,
                        uiMapID = uiMapID,
                        continent = continentMapID,
                        x = x,
                        y = y,
                    };
                end

                C_Map.ClearUserWaypoint();
            else
                print("No user waypoint found.")
            end
        end);
    end
    API.ConvertMapPositionToContinentPosition = ConvertMapPositionToContinentPosition;


    --Calculate a list of map positions (cache data) and run callback
    local Converter;

    local function Converter_OnUpdate(self, elapsed)
        self.t = self.t + elapsed;
        if self.t > self.delay then
            if self.t > 1 then  --The delay is always much shorter than 1s, thie line is to prevent error looping
                self.t = nil;
                self:SetScript("OnUpdate", nil);
                return
            end
            self.t = 0;
        else
            return
        end

        self.index = self.index + 1;

        if self.calls[self.index] then
            self.calls[self.index]();
        else
            self:SetScript("OnUpdate", nil);
            self.t = nil;
            self.calls = nil;
            self.index = nil;
            self.oldWaypoint = nil;
            if self.onFinished then
                self.onFinished();
                self.onFinished = nil;
            end
        end
    end

    local function ConvertAndCacheMapPositions(positions, onCoordReceivedFunc, onFinishedFunc)
        --Convert Zone position to Continent position
        if not Converter then
            Converter = CreateFrame("Frame");
            print("Plumber Request ConvertAndCacheMapPositions");
        end

        local MAPTYPE_CONTINENT = Enum.UIMapType.Continent;
        if not MAPTYPE_CONTINENT then
            print("Plumber WoW API Changed");
            return
        end

        local calls, n, oldWaypoint;

        if Converter.t then
            --still processing
            calls = Converter.calls;
            n = #calls;
            oldWaypoint = Converter.oldWaypoint;
        else
            calls = {};
            n = 0;
            oldWaypoint = C_Map.GetUserWaypoint();
            Converter.oldWaypoint = oldWaypoint;
            Converter.index = 0;
        end

        for _, data in ipairs(positions) do
            local info = GetMapInfo(data.uiMapID);
            if info then
                local continentMapID;   --uiMapID

                while info do
                    if info.mapType == MAPTYPE_CONTINENT then
                        continentMapID = info.mapID;
                        break
                    elseif info.parentMapID then
                        info = GetMapInfo(info.parentMapID);
                    else
                        info = nil;
                    end
                end

                if continentMapID then
                    local uiMapID = data.uiMapID;
                    local poiID = data.poiID;

                    local point = {
                        uiMapID = uiMapID,
                        position = CreateVector2D(data.x, data.y);
                    };

                    n = n + 1;
                    local function SetWaypoint()
                        C_Map.SetUserWaypoint(point);
                        Converter.t = 0;
                    end
                    calls[n] = SetWaypoint;

                    n = n + 1;
                    local function ProcessWaypoint()
                        local posVector = C_Map.GetUserWaypointPositionForMap(continentMapID);
                        if posVector then
                            local x, y = posVector:GetXY();
                            local positionData = {
                                uiMapID = uiMapID,
                                continent = continentMapID,
                                x = API.RoundCoord(x),
                                y = API.RoundCoord(y),
                                poiID = poiID,
                            };

                            onCoordReceivedFunc(positionData)
                            C_Map.ClearUserWaypoint();

                            --Debug Save Position
                            --[[
                            if not PlumberDevData then
                                PlumberDevData = {};
                            end
                            if not PlumberDevData.Waypoints then
                                PlumberDevData.Waypoints = {};
                            end
                            PlumberDevData.Waypoints[poiID] = positionData;
                            --]]
                        end
                        Converter.t = 0.033;
                    end
                    calls[n] = ProcessWaypoint;
                end
            end
        end

        Converter.onFinished = function()
            if Converter.oldWaypoint then
                C_Map.SetUserWaypoint(oldWaypoint);
                Converter.oldWaypoint = nil;
            end

            if onFinishedFunc then
                onFinishedFunc();
            end
        end

        Converter.calls = calls;
        Converter.t = 0;
        Converter.delay = -0.1;
        Converter:SetScript("OnUpdate", Converter_OnUpdate);

        return true
    end
    API.ConvertAndCacheMapPositions = ConvertAndCacheMapPositions;

    --[[
    function YeetPos()
        local uiMapID = C_Map.GetBestMapForUnit("player");
        local x, y = GetPlayerMapCoord(uiMapID);
        print(x, y);

        local position = C_Map.GetPlayerMapPosition(uiMapID, "player");
        local x0, y0 = position:GetXY();

        print(x0, y0);
    end
    --]]

    local MARGIN_X = 0.02;
    local MARGIN_Y = MARGIN_X * 1.42;

    local function AreWaypointsClose(userX, userY, preciseX, preciseY)
        --Examine if the left coords (user set) is roughly the same as the precise position
        --We don't calculate the exact distance (e.g. in yards)
        --We assume the user waypoint falls into a square around around their target, cuz manually placed pin cannot reach that precision
        --The margin of Y is larger than that of X, due to map ratio
        return (userX > preciseX - MARGIN_X) and (userX < preciseX + MARGIN_X) and (userY > preciseY - MARGIN_Y) and (userY < preciseY + MARGIN_Y)
    end
    API.AreWaypointsClose = AreWaypointsClose;


    local MAP_PIN_HYPERLINK = MAP_PIN_HYPERLINK or "|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a Map Pin Location";
    local FORMAT_USER_WAYPOINT = "|cffffff00|Hworldmap:%d:%.0f:%.0f|h["..MAP_PIN_HYPERLINK.."]|h|r";    --Message will be blocked by the server if you changing the map pin's name 

    local function CreateWaypointHyperlink(uiMapID, normalizedX, normalizedY)
        if uiMapID and normalizedX and normalizedY then
            return format(FORMAT_USER_WAYPOINT, uiMapID, 10000*normalizedX, 10000*normalizedY);
        end
    end
    API.CreateWaypointHyperlink = CreateWaypointHyperlink;


    local function GetZoneName(areaID)
        return C_Map.GetAreaInfo(areaID) or ("Area:"..areaID)
    end
    API.GetZoneName = GetZoneName;

    local HasActiveDelve = C_DelvesUI and C_DelvesUI.HasActiveDelve or Nop;
    local function IsInDelves()
        --See Blizzard InstanceDifficulty.lua
        local _, _, _, mapID = UnitPosition("player");
        return HasActiveDelve(mapID);
    end
    API.IsInDelves = IsInDelves;
end

do  --Instance --Map
    local GetInstanceInfo = GetInstanceInfo;

    local function GetMapID()
        local instanceID = select(8, GetInstanceInfo());
        return instanceID
    end
    API.GetMapID = GetMapID;
end

do  --Pixel
    local GetPhysicalScreenSize = GetPhysicalScreenSize;

    local function GetPixelForScale(scale, pixelSize)
        local SCREEN_WIDTH, SCREEN_HEIGHT = GetPhysicalScreenSize();
        if pixelSize then
            return pixelSize * (768/SCREEN_HEIGHT)/scale
        else
            return (768/SCREEN_HEIGHT)/scale
        end
    end
    API.GetPixelForScale = GetPixelForScale;

    local function GetPixelForWidget(widget, pixelSize)
        local scale = widget:GetEffectiveScale();
        return GetPixelForScale(scale, pixelSize);
    end
    API.GetPixelForWidget = GetPixelForWidget;
end

do  --Easing
    local EasingFunctions = {};
    addon.EasingFunctions = EasingFunctions;


    local sin = math.sin;
    local cos = math.cos;
    local pow = math.pow;
    local pi = math.pi;

    --t: total time elapsed
    --b: beginning position
    --e: ending position
    --d: animation duration

    function EasingFunctions.linear(t, b, e, d)
        return (e - b) * t / d + b
    end

    function EasingFunctions.outSine(t, b, e, d)
        return (e - b) * sin(t / d * (pi / 2)) + b
    end

    function EasingFunctions.inOutSine(t, b, e, d)
        return -(e - b) / 2 * (cos(pi * t / d) - 1) + b
    end

    function EasingFunctions.outQuart(t, b, e, d)
        t = t / d - 1;
        return (b - e) * (pow(t, 4) - 1) + b
    end

    function EasingFunctions.outQuint(t, b, e, d)
        t = t / d
        return (b - e)* (pow(1 - t, 5) - 1) + b
    end

    function EasingFunctions.inQuad(t, b, e, d)
        t = t / d
        return (e - b) * pow(t, 2) + b
    end
end

do  --Currency
    local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
    local CurrencyDataProvider = CreateFrame("Frame");
    CurrencyDataProvider.cache = {};
    CurrencyDataProvider.icons = {};

    local RelevantKeys = {"name", "quantity", "iconFileID", "maxQuantity", "quality"};

    CurrencyDataProvider:SetScript("OnEvent", function(self, event, currencyID, quantity, quantityChange)
        if currencyID and self.cache[currencyID] then
            self.cache[currencyID] = nil;
        end
    end);

    function CurrencyDataProvider:CacheAndGetCurrencyInfo(currencyID)
        if not self.cache[currencyID] then
            local info = GetCurrencyInfo(currencyID);
            if not info then return end;
            local vital = {};
        end

        if not self.registered then
            self.registered = true;
            self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
        end

        return self.cache[currencyID]
    end

    function CurrencyDataProvider:GetIcon(currencyID)
        if not self.icons[currencyID] then
            self:CacheAndGetCurrencyInfo(currencyID);
        end
    end

    local IGNORED_OVERFLOW_ID = {
        [3068] = true,      --Delver's Journey
        [3143] = true,      --Delver's Journey
    };

    local function WillCurrencyRewardOverflow(currencyID, rewardQuantity)
        if IGNORED_OVERFLOW_ID[currencyID] then
            return false, 0
        end
        local currencyInfo = GetCurrencyInfo(currencyID);
        local quantity = currencyInfo and (currencyInfo.useTotalEarnedForMaxQty and currencyInfo.totalEarned or currencyInfo.quantity);
        return quantity and currencyInfo.maxQuantity > 0 and rewardQuantity + quantity > currencyInfo.maxQuantity, quantity
    end
    API.WillCurrencyRewardOverflow = WillCurrencyRewardOverflow;

    local CoinUtil = {};
    addon.CoinUtil = CoinUtil;

    CoinUtil.patternGold = L["Match Pattern Gold"];
    CoinUtil.patternSilver = L["Match Pattern Silver"];
    CoinUtil.patternCopper = L["Match Pattern Copper"];

    function CoinUtil:GetCopperFromCoinText(coinText)
        local rawCopper = 0;
        local gold = match(coinText, self.patternGold);
        local silver = match(coinText, self.patternSilver);
        local copper = match(coinText, self.patternCopper);

        if gold then
            rawCopper = rawCopper + 10000 * (tonumber(gold) or 0);
        end

        if silver then
            rawCopper = rawCopper + 100 * (tonumber(silver) or 0);
        end

        if copper then
            rawCopper = rawCopper + (tonumber(copper) or 0);
        end

        return rawCopper
    end
end

do  --Chat Message
    --Check if the a rare spawn info has been announced by other players
    local function SearchChatHistory(searchFunc)
        local pool = ChatFrame1 and ChatFrame1.fontStringPool;
        if pool then
            local text, uiMapID, x, y;
            for fontString in pool:EnumerateActive() do
                text = fontString:GetText();
                if text ~= nil then
                    if searchFunc(text) then
                        return true
                    end
                end
            end
        end
        return false
    end
    API.SearchChatHistory = SearchChatHistory;
end

do  --Cursor Position
    local UI_SCALE_RATIO = 1;
    local UIParent = UIParent;
    local EL = CreateFrame("Frame");
    local GetCursorPosition = GetCursorPosition;

    EL:RegisterEvent("UI_SCALE_CHANGED");
    EL:SetScript("OnEvent", function(self, event)
        UI_SCALE_RATIO = 1 / UIParent:GetEffectiveScale();
    end);

    local function GetScaledCursorPosition()
        local x, y = GetCursorPosition();
        return x*UI_SCALE_RATIO, y*UI_SCALE_RATIO
    end
    API.GetScaledCursorPosition = GetScaledCursorPosition;
end

do  --TomTom Compatibility
    local TomTomUtil = {};
    addon.TomTomUtil = TomTomUtil;

    TomTomUtil.waypointUIDs = {};
    TomTomUtil.pauseCrazyArrowUpdate = false;

    local TT;

    function TomTomUtil:IsTomTomAvailable()
        if self.available == nil then
            self.available = (TomTom and TomTom.AddWaypoint and TomTom.RemoveWaypoint and TomTom.SetClosestWaypoint and TomTomCrazyArrow and true) or false
            if self.available then
                TT = TomTom;
            end
        end
        return self.available
    end

    function TomTomUtil:AddWaypoint(uiMapID, x, y, desc, plumberTag, plumberArg1, plumberArg2)
        --x, y: 0-1
        if self:IsTomTomAvailable() then
            plumberTag = plumberTag or "plumber";

            local opts = {
                title = desc or "TomTom Waypoint via Plumber",
                from = "Plumber",
                persistent = false,     --waypoint will not be saved
                crazy = true,
                cleardistance = 8,
                arrivaldistance = 15,
                world = false,          --don't show on WorldMap
                minimap = false,
                plumberTag = plumberTag,
                plumberArg1 = plumberArg1,
                plumberArg2 = plumberArg2,
            };

            local uid = securecallfunction(TT.AddWaypoint, TT, uiMapID, x, y, opts);

            if uid then
                if not self.waypointUIDs[uid] then
                    self.waypointUIDs[uid] = {plumberTag, plumberArg1, plumberArg2};
                end
                return uid
            else
                return
            end
        end
    end

    function TomTomUtil:SelectClosestWaypoint()
        local announceInChat = false;
        securecallfunction(TT.SetClosestWaypoint, TT, announceInChat);
    end

    function TomTomUtil:RemoveWaypoint(uid)
        if self:IsTomTomAvailable() then
            securecallfunction(TT.RemoveWaypoint, TT, uid);
        end
    end

    function TomTomUtil:RemoveWaypointsByTag(tag)
        for uid, data in pairs(self.waypointUIDs) do
            if data[1] == tag then
                self.waypointUIDs[uid] = nil;
                self:RemoveWaypoint(uid);
            end
        end
    end

    function TomTomUtil:RemoveWaypointsByRule(rule)
        for uid, data in pairs(self.waypointUIDs) do
            if rule(unpack(data)) then
                self.waypointUIDs[uid] = nil;
                self:RemoveWaypoint(uid);
            end
        end
    end

    function TomTomUtil:RemoveAllPlumberWaypoints()
        for uid, tag in pairs(self.waypointUIDs) do
            self:RemoveWaypoint(uid);
        end
        self.waypointUIDs = {};
    end

    function TomTomUtil:GetDistanceToWaypoint(uid)
        return securecallfunction(TT.GetDistanceToWaypoint, TT, uid)
    end
end

do  --Game UI
    local function IsInEditMode()
        return EditModeManagerFrame and EditModeManagerFrame:IsEditModeActive();
    end
    API.IsInEditMode = IsInEditMode;
end

do  --Reputation
    local C_Reputation = C_Reputation;
    local C_MajorFactions = C_MajorFactions;
    local GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation;
    local GetFriendshipReputationRanks = C_GossipInfo.GetFriendshipReputationRanks;
    local GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo;
    local GetFactionInfoByID = C_Reputation.GetFactionDataByID;
    local UnitSex = UnitSex;
    local GetText = GetText;

    local function GetFriendshipProgress(factionID)
        local repInfo = factionID and GetFriendshipReputation(factionID);
        if repInfo and repInfo.friendshipFactionID and  repInfo.friendshipFactionID > 0 then
            local currentValue, maxValue;

            if repInfo.nextThreshold then
                currentValue = repInfo.standing - repInfo.reactionThreshold;
                maxValue = repInfo.nextThreshold - repInfo.reactionThreshold;
                if maxValue == 0 then
                    currentValue = 1;
                    maxValue = 1;
                end
            else
                currentValue = 1;
                maxValue = 1;
            end

            local rankInfo = GetFriendshipReputationRanks(repInfo.friendshipFactionID);
            local level = rankInfo.currentLevel;
            local isFull = level >= rankInfo.maxLevel;

            return level, isFull, currentValue, maxValue
        end
    end
    API.GetFriendshipProgress = GetFriendshipProgress;


    local function GetParagonValuesAndLevel(factionID)
        local totalEarned, threshold = GetFactionParagonInfo(factionID);
        if totalEarned and threshold and threshold ~= 0 then
            local paragonLevel = floor(totalEarned / threshold);    --How many times the player has reached paragon
            local currentValue = totalEarned - paragonLevel * threshold;
            return currentValue, threshold, paragonLevel
        end
        return 0, 1, 0
    end
    API.GetParagonValuesAndLevel = GetParagonValuesAndLevel;


    local function GetFactionStatusText(factionID)
        --Derived from Blizzard ReputationFrame_InitReputationRow in ReputationFrame.lua
        if not factionID then return end;
        local p1, description, standingID, barMin, barMax, barValue = GetFactionInfoByID(factionID);

        if type(p1) == "table" then
            standingID = p1.reaction;
            barMin = p1.currentReactionThreshold;
            barMax = p1.nextReactionThreshold;
            barValue = p1.currentStanding;
        end

        local isParagon = C_Reputation.IsFactionParagon(factionID);
        local isMajorFaction = C_Reputation.IsMajorFaction(factionID);
        local repInfo = GetFriendshipReputation(factionID);

        local isCapped;
        local factionStandingtext;  --Revered/Junior/Renown 1
        local cappedAlert;

        if repInfo and repInfo.friendshipFactionID > 0 then --Friendship
            factionStandingtext = repInfo.reaction;

            if repInfo.nextThreshold then
                barMin, barMax, barValue = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing;
            else
                barMin, barMax, barValue = 0, 1, 1;
                isCapped = true;
            end

            local rankInfo = GetFriendshipReputationRanks(repInfo.friendshipFactionID);
            if rankInfo then
                factionStandingtext = factionStandingtext .. string.format(" (Lv. %s/%s)", rankInfo.currentLevel, rankInfo.maxLevel);
            end

        elseif isMajorFaction then
            local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
            if majorFactionData then
                barMin, barMax = 0, majorFactionData.renownLevelThreshold;
                isCapped = C_MajorFactions.HasMaximumRenown(factionID);
                barValue = isCapped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0;
                factionStandingtext = L["Renown Level Label"] .. majorFactionData.renownLevel;

                if isParagon then
                    local totalEarned, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID);
                    if totalEarned and threshold and threshold ~= 0 then
                        local paragonLevel = floor(totalEarned / threshold);
                        local currentValue = totalEarned - paragonLevel * threshold;
                        factionStandingtext = ("|cff00ccff"..L["Paragon Reputation"].."|r %d/%d"):format(currentValue, threshold);
                    end

                    if hasRewardPending then
                        cappedAlert = "|cffff4800"..L["Unclaimed Reward Alert"].."|r";
                    end
                else
                    if isCapped then
                        factionStandingtext = factionStandingtext.." "..L["Level Maxed"];
                    end
                end
            end
        elseif (standingID and standingID > 0) then
            isCapped = standingID == 8;  --MAX_REPUTATION_REACTION
            local gender = UnitSex("player");
		    factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender);    --GetText: Game API that returns localized texts
        end

        local rolloverText; --(0/24000)
        if barValue and barMax and (not isCapped) then
            rolloverText = string.format("(%s/%s)", barValue, barMax);
        end

        local text;

        if factionStandingtext then
            if not text then text = L["Current Colon"] end;
            factionStandingtext = " |cffffffff"..factionStandingtext.."|r";
            text = text .. factionStandingtext;
        end

        if rolloverText then
            if not text then text = L["Current Colon"] end;
            rolloverText = "  |cffffffff"..rolloverText.."|r";
            text = text .. rolloverText;
        end

        if text then
            text = " \n"..text;

            if cappedAlert then
                text = text.."\n"..cappedAlert;
            end
        end

        return text
    end
    API.GetFactionStatusText = GetFactionStatusText;


    local function GetReputationChangeFromText(text)
        local name, amount;
        name, amount = match(text, L["Match Patter Rep 1"]);
        if not name then
            name, amount = match(text, L["Match Patter Rep 2"]);
        end
        if name then
            if amount then
                amount = gsub(amount, ",", "");
                amount = tonumber(amount);
            end
            return name, amount
        end
    end
    API.GetReputationChangeFromText = GetReputationChangeFromText;
end

do  --Spell
    if true then    --IS_TWW
        local GetSpellInfo_Table = C_Spell.GetSpellInfo;
        local SPELL_INFO_KEYS = {"name", "rank", "iconID", "castTime", "minRange", "maxRange", "spellID", "originalIconID"};
        local function GetSpellInfo_Flat(spellID)
            local info = spellID and GetSpellInfo_Table(spellID);
            if info then
                local tbl = {};
                local n = 0;
                for _, key in ipairs(SPELL_INFO_KEYS) do
                    n = n + 1;
                    tbl[n] = info[key];
                end
                return unpack(tbl)
            end
        end
        API.GetSpellInfo = GetSpellInfo_Flat;
    else
        API.GetSpellInfo = GetSpellInfo;
    end
end

do  --System
    if true then    --IS_TWW
        local GetMouseFoci = GetMouseFoci;

        local function GetMouseFocus()
            local objects = GetMouseFoci();
            return objects and objects[1]
        end
        API.GetMouseFocus = GetMouseFocus;
    else
        API.GetMouseFocus = GetMouseFocus;
    end


    local ModifierKeyName = {
        LSHIFT = "Shift",
        LCTRL = "Ctrl",
        LALT = "Alt",
    };

    if IsMacClient and IsMacClient() then
        --Mac OS
        ModifierKeyName.LCTRL = "Command";
        ModifierKeyName.LALT = "Option";
    end

    ModifierKeyName.RSHIFT = ModifierKeyName.LSHIFT;
    ModifierKeyName.RCTRL = ModifierKeyName.LCTRL;
    ModifierKeyName.RALT = ModifierKeyName.LALT;

    API.GetModifierKeyName = function(key)
        if key and ModifierKeyName[key] then
            return ModifierKeyName[key]
        end
    end
end

do  --Player
    local function GetPlayerMaxLevel()
        local serverExpansionLevel = GetServerExpansionLevel();
		local maxLevel = GetMaxLevelForExpansionLevel(serverExpansionLevel);
        return maxLevel or 80
    end
    API.GetPlayerMaxLevel = GetPlayerMaxLevel;

    local function IsPlayerAtMaxLevel()
        local maxLevel = GetPlayerMaxLevel();
        local playerLevel = UnitLevel("player");
        return playerLevel >= maxLevel
    end
    API.IsPlayerAtMaxLevel = IsPlayerAtMaxLevel;
end

do  --Scenario
    --[[
    local SCENARIO_DELVES = addon.L["Scenario Delves"] or "Delves";

    local GetScenarioInfo = C_ScenarioInfo.GetScenarioInfo;

    local function IsInDelves()
        local scenarioInfo = GetScenarioInfo();
        return scenarioInfo and scenarioInfo.name == SCENARIO_DELVES
    end
    API.IsInDelves = IsInDelves;
    --]]
end

do  --ObjectPool
    local ObjectPoolMixin = {};

    function ObjectPoolMixin:RemoveObject(obj)
        obj:Hide();
        obj:ClearAllPoints();

        if obj.OnRemoved then
            obj:OnRemoved();
        end
    end

    function ObjectPoolMixin:RecycleObject(obj)
        local isActive;

        for i, activeObject in ipairs(self.activeObjects) do
            if activeObject == obj then
                tremove(self.activeObjects, i);
                isActive = true;
                break
            end
        end

        if isActive then
            self:RemoveObject(obj);
            self.numUnused = self.numUnused + 1;
            self.unusedObjects[self.numUnused] = obj;
        end
    end

    function ObjectPoolMixin:CreateObject()
        local obj = self.createObjectFunc();
        tinsert(self.objects, obj);
        obj.Release = self.Object_Release;
        return obj
    end

    function ObjectPoolMixin:Acquire()
        local obj;

        if self.numUnused > 0 then
            obj = tremove(self.unusedObjects, self.numUnused);
            self.numUnused = self.numUnused - 1;
        end

        if not obj then
            obj = self:CreateObject();
        end

        tinsert(self.activeObjects, obj);
        obj:Show();

        return obj
    end

    function ObjectPoolMixin:ReleaseAll()
        if #self.activeObjects == 0 then return end;

        for _, obj in ipairs(self.activeObjects) do
            self:RemoveObject(obj);
        end

        self.activeObjects = {};
        self.unusedObjects = {};

        for index, obj in ipairs(self.objects) do
            self.unusedObjects[index] = obj;
        end

        self.numUnused = #self.objects;
    end

    function ObjectPoolMixin:GetTotalObjects()
        return #self.objects
    end

    function ObjectPoolMixin:CallAllObjects(method, ...)
        for i, obj in ipairs(self.objects) do
            obj[method](obj, ...);
        end
    end

    function ObjectPoolMixin:Object_Release()
        --Override
    end

    local function CreateObjectPool(createObjectFunc)
        local pool = {};
        API.Mixin(pool, ObjectPoolMixin);

        local function Object_Release(f)
            pool:RecycleObject(f);
        end
        pool.Object_Release = Object_Release;

        pool.objects = {};
        pool.activeObjects = {};
        pool.unusedObjects = {};
        pool.numUnused = 0;
        pool.createObjectFunc = createObjectFunc;

        return pool
    end
    API.CreateObjectPool = CreateObjectPool;
end

do  --Transmog
    local GetItemInfo = C_TransmogCollection.GetItemInfo;
    local PlayerKnowsSource = C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance;

    local function IsUncollectedTransmogByItemInfo(itemInfo)
        --C_TransmogCollection.PlayerHasTransmogByItemInfo isn't reliable
        local visualID, sourceID =GetItemInfo(itemInfo);
        if sourceID and sourceID ~= 0 and (not PlayerKnowsSource(sourceID)) then
            return true
        end
    end
    API.IsUncollectedTransmogByItemInfo = IsUncollectedTransmogByItemInfo

    if not addon.IsToCVersionEqualOrNewerThan(40000) then
        API.IsUncollectedTransmogByItemInfo = Nop;
    end
end

do  --Quest
    local function GetQuestName(questID)
        local questName = C_TaskQuest.GetQuestInfoByQuestID(questID);
        if not questName then
            questName = C_QuestLog.GetTitleForQuestID(questID);
            if questName and questName ~= "" then
                return questName
            else
                C_QuestLog.RequestLoadQuestByID(questID);
            end
        end
        return questName
    end
    API.GetQuestName = GetQuestName;
end

do  --Tooltip
    if C_TooltipInfo then
        addon.TooltipAPI = C_TooltipInfo;
    else
        --For Classic where C_TooltipInfo doesn't exist:

        local TooltipAPI = {};
        local CreateColor = CreateColor;
        local TOOLTIP_NAME = "PlumberClassicVirtualTooltip";
        local TP = CreateFrame("GameTooltip", TOOLTIP_NAME, nil, "GameTooltipTemplate");
        local UIParent = UIParent;

        TP:SetOwner(UIParent, 'ANCHOR_NONE');
        TP:SetClampedToScreen(false);
        TP:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, -128);
        TP:Show();
        TP:SetScript("OnUpdate", nil);


        local UpdateFrame = CreateFrame("Frame");

        local function UpdateTooltipInfo_OnUpdate(self, elapsed)
            self.t = self.t + elapsed;
            if self.t > 0.2 then
                self.t = 0;
                self:SetScript("OnUpdate", nil);
                addon.CallbackRegistry:Trigger("SharedTooltip.TOOLTIP_DATA_UPDATE", 0);
            end
        end

        function UpdateFrame:OnItemChanged(numLines)
            self.t = 0;
            self.numLines = numLines;
            self:SetScript("OnUpdate", UpdateTooltipInfo_OnUpdate);
        end

        local function GetTooltipHyperlink()
            local name, link = TP:GetItem();
            if link then
                return link
            end

            name, link = TP:GetSpell();
            if link then
                return "spell:"..link
            end
        end

        local function GetTooltipTexts()
            local numLines = TP:NumLines();
            if numLines == 0 then return end;

            local tooltipData = {};
            tooltipData.dataInstanceID = 0;

            local addItemLevel;
            local itemLink = GetTooltipHyperlink();

            if itemLink then
                if itemLink ~= TP.hyperlink then
                    UpdateFrame:OnItemChanged(numLines);
                end

                if API.IsEquippableItem(itemLink) then
                    addItemLevel = API.GetItemLevel(itemLink);
                end
            end

            TP.hyperlink = itemLink;
            tooltipData.hyperlink = itemLink;

            local lines = {};
            local n = 0;

            local fs, text;
            for i = 1, numLines do
                if i == 2 and addItemLevel then
                    n = n + 1;
                    lines[n] = {
                        leftText = L["Format Item Level"]:format(addItemLevel);
                        leftColor = CreateColor(1, 0.82, 0),
                    };
                end

                fs = _G[TOOLTIP_NAME.."TextLeft"..i];
                if fs then
                    n = n + 1;

                    local r, g, b = fs:GetTextColor();
                    text = fs:GetText();
                    local lineData = {
                        leftText = text,
                        leftColor = CreateColor(r, g, b),
                        rightText = nil,
                        wrapText = true,
                        leftOffset = 0,
                    };

                    fs = _G[TOOLTIP_NAME.."TextRight"..i];
                    if fs then
                        text = fs:GetText();
                        if text and text ~= "" then
                            r, g, b = fs:GetTextColor();
                            lineData.rightText = text;
                            lineData.rightColor = CreateColor(r, g, b);
                        end
                    end

                    lines[n] = lineData;
                end
            end

            local sellPrice = API.GetItemSellPrice(itemLink);
            if sellPrice then
                n = n + 1;
                lines[n] = {
                    leftText = "",  --this will be ignored by our tooltip
                    price = sellPrice,
                };
            end

            tooltipData.lines = lines;
            return tooltipData
        end

        do
            local accessors = {
                SetItemByID = "GetItemByID",
                SetCurrencyByID = "GetCurrencyByID",
                SetQuestItem = "GetQuestItem",
                SetQuestCurrency = "GetQuestCurrency",
                SetSpellByID = "GetSpellByID",
                SetItemByGUID = "GetItemByGUID",
                SetHyperlink = "GetHyperlink",
            };

            for accessor, getterName in pairs(accessors) do
                if TP[accessor] then
                    local function GetterFunc(...)
                        TP:ClearLines();
                        TP:SetOwner(UIParent, "ANCHOR_PRESERVE");
                        TP[accessor](TP, ...);
                        return GetTooltipTexts();
                    end

                    TooltipAPI[getterName] = GetterFunc;
                end
            end
        end

        addon.TooltipAPI = TooltipAPI;
    end
end


do
    local GetItemCount = C_Item.GetItemCount
    local GetContainerNumSlots = C_Container.GetContainerNumSlots;
    local GetContainerItemID = C_Container.GetContainerItemID;
    local GetItemInfoInstant = C_Item.GetItemInfoInstant;
    local GetBagItem = C_TooltipInfo and C_TooltipInfo.GetBagItem;

    local function GetItemBagPosition(itemID)
        local count = GetItemCount(itemID); --unused arg2: Include banks
        if count and count > 0 then
            for bagID = 0, 4 do
                for slotID = 1, GetContainerNumSlots(bagID) do
                    if(GetContainerItemID(bagID, slotID) == itemID) then
                        return bagID, slotID
                    end
                end
            end
        end
    end
    API.GetItemBagPosition = GetItemBagPosition;

    local Processor = CreateFrame("Frame");
    local ITEM_OPENABLE = ITEM_OPENABLE or "<Right Click to Open>";
    local OPENABLE_ITEM = {};

    local function IsItemOpenable(item)
        local itemID, _, _, _, _, classID, subClassID = GetItemInfoInstant(item);
        if OPENABLE_ITEM[itemID] ~= nil then
            return OPENABLE_ITEM[itemID]
        end

        if classID == 15 and subClassID == 4 then
            local bag, slot = GetItemBagPosition(itemID);
            if bag and slot then
                local tooltipData = GetBagItem(bag, slot);
                if tooltipData then
                    local lines = tooltipData.lines;
                    local leftText = lines[#lines].leftText;
                    if leftText and leftText == ITEM_OPENABLE then
                        OPENABLE_ITEM[itemID] = true;
                        return true
                    else
                        OPENABLE_ITEM[itemID] = false;
                    end
                end
            end
        end
        return false
    end

    function Processor:OnUpdate_Queue(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.1 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            local itemID;
            local anyMatch;

            for bagID = 0, 4 do
                for slotID = 1, GetContainerNumSlots(bagID) do
                    itemID = GetContainerItemID(bagID, slotID);
                    if self.queue[itemID] ~= nil then
                        if self.queue[itemID].bagPosition == nil then
                            anyMatch = true;
                            self.queue[itemID].bagPosition = {bagID, slotID};
                            if OPENABLE_ITEM[itemID] == nil then
                                GetBagItem(bagID, slotID);
                            end
                        end
                    end
                end
            end

            if anyMatch then
                self:SetScript("OnUpdate", self.OnUpdate_Tooltip);
            end
        end
    end

    function Processor:OnUpdate_Tooltip(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.1 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            local tooltipData;
            local lines;
            local leftText;
            local openable;
            local bag, slot;
            for itemID, v in pairs(self.queue) do
                if v.bagPosition then
                    bag = v.bagPosition[1];
                    slot = v.bagPosition[2];
                    tooltipData = GetBagItem(bag, slot);

                    if OPENABLE_ITEM[itemID] then
                        openable = true;
                    else
                        openable = false;
                        if tooltipData then
                            lines = tooltipData.lines;
                            leftText = lines[#lines].leftText;
                            openable = leftText and leftText == ITEM_OPENABLE
                            OPENABLE_ITEM[itemID] = openable;
                        end
                    end

                    if openable then
                        for callback in pairs(v) do
                            if callback ~= "bagPosition" then
                                callback(bag, slot)
                            end
                        end
                    end
                end
            end

            self.queue = nil;
        end
    end

    function API.InquiryOpenableItem(itemID, callback)
        --Pre-exclude invalid item types

        if OPENABLE_ITEM[itemID] == false then
            return false
        end

        if not Processor.queue then
            Processor.queue = {};
        end

        if not Processor.queue[itemID] then
            Processor.queue[itemID] = {};
        end

        callback = callback or Nop;

        Processor.queue[itemID][callback] = true;

        Processor.t = 0;
        Processor:SetScript("OnUpdate", Processor.OnUpdate_Queue);
    end
end


--[[
local DEBUG = CreateFrame("Frame");
DEBUG:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player");
DEBUG:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player");
DEBUG:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");

DEBUG:SetScript("OnEvent", function(self, event, ...)
    print(event);
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local name, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo("player");
        self.endTime = endTime;
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local t = GetTime();
        t = t * 1000;
        if self.endTime then
            local diff = t - self.endTime;
            if diff < 200 and diff > -200 then
                print("Natural Complete")
            else
                print("Interrupted")
            end
        end
    end
end);
--]]