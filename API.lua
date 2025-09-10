local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;

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

    local function CopyTable(tbl)
        --Blizzard TableUtil.lua
        if not tbl then return; end;
        local copy = {};
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                copy[k] = CopyTable(v);
            else
                copy[k] = v;
            end
        end
        return copy;
    end
    API.CopyTable = CopyTable;
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

    local ValidUnitTypes = {
        Creature = true,
        Pet = true,
        GameObject = true,
        Vehicle = true,
    };

    local function GetUnitIDGeneral(unit)
        local guid = UnitGUID(unit);
        if guid then
            local unitType, id = match(guid, "(%a+)%-0%-%d*%-%d*%-%d*%-(%d*)");
            if id and unitType and ValidUnitTypes[unitType] then
                return tonumber(id)
            end
        end
    end
    API.GetUnitIDGeneral = GetUnitIDGeneral;

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

    local function JoinText(delimiter, l, r)
        if l and r then
            return l..delimiter..r
        else
            return l or r
        end
    end
    API.JoinText = JoinText;


    function API.StringTrim(text)
        if text then
            text = gsub(text, "^(%s+)", "");
            text = gsub(text, "(%s+)$", "");
            if text ~= "" then
                return text
            end
        end
    end
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

do  -- Math
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
    local COLOR_RED_BELOW_SECONDS = 43200;

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

    local function SecondsToTime(seconds, abbreviated, partialTime, bakePluralEscapeSequence, colorized)
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
                if partialTime and (minutes >= SHOW_SECOND_BELOW_MINUTES or hours > 0) then
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

        if colorized and partialTime and intialSeconds < COLOR_RED_BELOW_SECONDS and not bakePluralEscapeSequence then
            --WARNING_FONT_COLOR
            timeString = "|cffff4800"..timeString.."|r";
        end

        return timeString
    end
    API.SecondsToTime = SecondsToTime;

    local function SecondsToClock(seconds)
        --Clock: 00:00
        return format("%s:%02d", floor(seconds / 60), floor(seconds % 60))
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
        if not match(durationText, "%d") then return 0 end;

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


    function API.GetItemColor(itemID)
        local quality = C_Item.GetItemQualityByID(itemID) or 1;
        local color = API.GetItemQualityColor(quality);
        if color then
            return color.r, color.g, color.b
        else
            return 1, 1, 1
        end
    end

    local function GetItemSpellID(item)
        local spellName, spellID = GetItemSpell(item);
        return spellID
    end
    API.GetItemSpellID = GetItemSpellID;


    function API.IsToyItem(item)
       return C_ToyBox.GetToyInfo(item) ~= nil
    end


    function API.GetItemSellPrice(item)
        if item then
            local sellPrice = select(11, C_Item.GetItemInfo(item));
            if sellPrice and sellPrice > 0 then
                return sellPrice
            end
        end
    end


    function API.IsMountCollected(mountID)
        local isCollected = select(11, C_MountJournal.GetMountInfoByID(mountID));
        return isCollected
    end


    local InventorySlotName = {
        "HEADSLOT",
        "NECKSLOT",
        "SHOULDERSLOT",
        "SHIRTSLOT",
        "CHESTSLOT",

        "WAISTSLOT",
        "LEGSSLOT",
        "FEETSLOT",
        "WRISTSLOT",
        "HANDSSLOT",

        "FINGER0SLOT_UNIQUE",   --FINGER0SLOT
        "FINGER1SLOT_UNIQUE",   --FINGER1SLOT
        "TRINKET0SLOT_UNIQUE",  --TRINKET0SLOT
        "TRINKET1SLOT_UNIQUE",  --TRINKET1SLOT
        "BACKSLOT",

        "MAINHANDSLOT",
        "SECONDARYHANDSLOT",
        "RANGEDSLOT",
        "TABARDSLOT",
    };

    function API.GetInventorySlotName(slotID)
        local key = InventorySlotName[slotID];
        if key and _G[key] then
            return _G[key]
        else
            return "Slot"..slotID
        end
    end
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


    function API.LoadCreatureNameWithCallback(creatures, callback, fromRequery)
        local failedCreatures;

        if type(creatures) == "table" then
            local name;
            local n = 0;
            for _, creatureID in ipairs(creatures) do
                name = GetCreatureName(creatureID);
                if name and name ~= "" then
                    callback(creatureID, name);
                else
                    if not failedCreatures then
                        failedCreatures = {};
                    end
                    n = n + 1;
                    failedCreatures[n] = creatureID;
                end
            end
        else
            --when creatures is creatureID (number)
            local name = GetCreatureName(creatures);
            if name and name ~= "" then
                callback(creatures, name);
            else
                failedCreatures = creatures;
            end
        end

        if (not fromRequery) and failedCreatures then
            C_Timer.After(1, function()
                API.LoadCreatureNameWithCallback(failedCreatures, callback, true);
            end);
        end
    end
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

do  -- Fade Frame
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

            --Note: if the player enters an unmapped area like The Great Sea then re-enter a regular zone
            --GetBestMapForUnit will still return the continent mapID when ZONE_CHANGED_NEW_AREA triggers
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


    function API.GetPlayerMap()
        return GetBestMapForUnit("player");
    end


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


    function API.GetMapName(uiMapID)
        local info = GetMapInfo(uiMapID);
        if info then
            return info.name
        end
    end
end

do  -- Instance -- Map
    local GetInstanceInfo = GetInstanceInfo;

    local function GetMapID()
        local instanceID = select(8, GetInstanceInfo());
        return instanceID
    end
    API.GetMapID = GetMapID;
end

do  -- Pixel
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

do  -- Easing
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

do  -- Currency
    local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
    local CurrencyDataProvider = CreateFrame("Frame");
    CurrencyDataProvider.names = {};
    CurrencyDataProvider.icons = {};
    CurrencyDataProvider.qualities = {};

    function API.GetCurrencyName(currencyID, colorized)
        local name = CurrencyDataProvider.names[currencyID];
        local quality = colorized and CurrencyDataProvider.qualities[currencyID] or 1;

        if not name then
            local info = GetCurrencyInfo(currencyID);
            name = info and info.name;
            if name then
                CurrencyDataProvider.names[currencyID] = name;
                CurrencyDataProvider.qualities[currencyID] = info.quality;
            else
                name = "Currency:"..currencyID;
                quality = 1;
            end
        end

        if colorized then
            return API.ColorizeTextByQuality(name, quality)
        else
            return name
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
        local overflow = quantity and currencyInfo.maxQuantity > 0 and rewardQuantity + quantity > currencyInfo.maxQuantity;
        return overflow, quantity, currencyInfo.useTotalEarnedForMaxQty, currencyInfo.maxQuantity
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

do  -- Chat Message
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

do  -- Cursor Position
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

    function API.GetScaledCursorPositionForFrame(frame)
        local uiScale = frame:GetEffectiveScale();
        local x, y = GetCursorPosition();
        return x / uiScale, y / uiScale;
    end
end

do  -- TomTom Compatibility
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

do  -- Game UI
    local function IsInEditMode()
        return EditModeManagerFrame and EditModeManagerFrame:IsEditModeActive();
    end
    API.IsInEditMode = IsInEditMode;
end

do  -- Reputation
    local C_Reputation = C_Reputation;
    local C_MajorFactions = C_MajorFactions;
    local GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation;
    local GetFriendshipReputationRanks = C_GossipInfo.GetFriendshipReputationRanks;
    local GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo or Nop;
    local UnitSex = UnitSex;
    local GetText = GetText;

    local GetFactionDataByID;
    if C_Reputation.GetFactionDataByID then
        GetFactionDataByID = C_Reputation.GetFactionDataByID;
    else    --Classic
        function GetFactionDataByID(factionID)
            local name, description, standingID, barMin, barMax, barValue = GetFactionInfoByID(factionID);
            if name then
                local tbl = {
                    name = name,
                    factionID = factionID,
                    reaction = standingID,
                    currentStanding = barValue,
                    currentReactionThreshold = barMin,
                    nextReactionThreshold = barMax,
                }
                return tbl
            end
        end
    end

    local function GetReputationProgress(factionID)
        if not factionID then return end;

        local level, isFull, currentValue, maxValue, name, reputationType, isUnlocked, reaction;

        local repInfo = GetFriendshipReputation(factionID);
        local paragonRepEarned, paragonThreshold, rewardQuestID, hasRewardPending = GetFactionParagonInfo(factionID);

        if repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID > 0 then
            reputationType = 2;
            name = repInfo.name;
            reaction = repInfo.reaction;
            isUnlocked = true;
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
            level = rankInfo.currentLevel;
            isFull = level >= rankInfo.maxLevel;
        end

        if C_Reputation.IsMajorFaction and C_Reputation.IsMajorFaction(factionID) then
            local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
            if majorFactionData then
                reputationType = 3;
                maxValue = majorFactionData.renownLevelThreshold;
                local isCapped = C_MajorFactions.HasMaximumRenown(factionID);
                currentValue = isCapped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0;
                level = majorFactionData.renownLevel;
                name = majorFactionData.name;
                isUnlocked = majorFactionData.isUnlocked;
            end
        end

        if not reputationType then
            repInfo = GetFactionDataByID(factionID);
            if repInfo then
                reputationType = 1;
                name = repInfo.name;
                isUnlocked = true;

                if repInfo.currentReactionThreshold then
                    currentValue = repInfo.currentStanding - repInfo.currentReactionThreshold;
                    maxValue = repInfo.nextReactionThreshold - repInfo.currentReactionThreshold;
                    if maxValue == 0 then
                        currentValue = 1;
                        maxValue = 1;
                    end
                else
                    currentValue = 1;
                    maxValue = 1;
                end

                local zeroLevel = 4;    --Neutral
                reaction = repInfo.reaction;
                level = reaction - zeroLevel;
                isFull = level >= 8; --TEMP DEBUG
            end
        end

        if C_Reputation.IsFactionParagon and C_Reputation.IsFactionParagon(factionID) then
            isFull = true;
            if paragonRepEarned and paragonThreshold and paragonThreshold ~= 0 then
                local paragonLevel = floor(paragonRepEarned / paragonThreshold);
                currentValue = paragonRepEarned - paragonLevel * paragonThreshold;
                maxValue = paragonThreshold;
                level = paragonLevel;
            end
        end

        if reputationType then
            local tbl = {
                level = level,
                currentValue = currentValue,
                maxValue = maxValue,
                isFull = isFull,
                name = name,
                reputationType = reputationType,    --1:Standard, 2:Friendship
                rewardPending = hasRewardPending,
                isUnlocked = isUnlocked,
                reaction = reaction,
            };

            return tbl
        end
    end
    API.GetReputationProgress = GetReputationProgress;


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


    local function GetReputationStandingText(reaction)
        if type(reaction) == "string" then
            --Friendship
            return reaction
        end
        local gender = UnitSex("player");
        local reputationStandingtext = GetText("FACTION_STANDING_LABEL"..reaction, gender);    --GetText: Game API that returns localized texts
        return reputationStandingtext
    end
    API.GetReputationStandingText = GetReputationStandingText;


    local function GetFactionStatusText(factionID, simplified, showFactionName)
        --Derived from Blizzard ReputationFrame_InitReputationRow in ReputationFrame.lua
        if not factionID then return end;
        local factionName;
        local p1, description, standingID, barMin, barMax, barValue = GetFactionDataByID(factionID);

        if type(p1) == "table" then
            standingID = p1.reaction;
            barMin = p1.currentReactionThreshold;
            barMax = p1.nextReactionThreshold;
            barValue = p1.currentStanding;
            factionName = p1.name;
        else
            factionName = p1;
        end

        local isParagon = C_Reputation.IsFactionParagon and C_Reputation.IsFactionParagon(factionID);
        local isMajorFaction = C_Reputation.IsMajorFaction and C_Reputation.IsMajorFaction(factionID);
        local repInfo = GetFriendshipReputation(factionID);

        local isCapped;
        local factionStandingtext;  --Revered/Junior/Renown 1
        local cappedAlert;
        local isFriendship;

        if repInfo and repInfo.friendshipFactionID > 0 then --Friendship
            isFriendship = true;
            factionStandingtext = repInfo.reaction;

            if repInfo.nextThreshold then
                barMin, barMax, barValue = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing;
            else
                barMin, barMax, barValue = 0, 1, 1;
                isCapped = true;
            end

            local rankInfo = GetFriendshipReputationRanks(repInfo.friendshipFactionID);
            if rankInfo then
                factionStandingtext = factionStandingtext .. format(" (Lv. %s/%s)", rankInfo.currentLevel, rankInfo.maxLevel);
            end

        elseif isMajorFaction then
            local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
            if majorFactionData then
                barMin, barMax = 0, majorFactionData.renownLevelThreshold;
                isCapped = C_MajorFactions.HasMaximumRenown(factionID);
                barValue = isCapped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0;
                factionStandingtext = L["Renown Level Label"] .. majorFactionData.renownLevel;
            end
        elseif (standingID and standingID > 0) then
            isCapped = standingID == 8;  --MAX_REPUTATION_REACTION
		    factionStandingtext = GetReputationStandingText(standingID);
        end

        if isParagon then
            local totalEarned, threshold, rewardQuestID, hasRewardPending = GetFactionParagonInfo(factionID);
            if totalEarned and threshold and threshold ~= 0 then
                local paragonLevel = floor(totalEarned / threshold);
                local currentValue = totalEarned - paragonLevel * threshold;
                --factionStandingtext = ("|cff00ccff"..L["Paragon Reputation"].."|r %d/%d"):format(currentValue, threshold);
                factionStandingtext = "|cff00ccff"..L["Paragon Reputation"].."|r";
                barMin = 0;
                barValue = currentValue;
                barMax = threshold;
            end

            if hasRewardPending then
                cappedAlert = "|cffff4800"..L["Unclaimed Reward Alert"].."|r";
            end
        else
            if isCapped and factionStandingtext then
                factionStandingtext = factionStandingtext.." "..L["Level Maxed"];
            end
        end

        local rolloverText; --(0/24000)
        if barMin and barValue and barMax and (isParagon or (not isCapped)) then
            rolloverText = format("(%s/%s)", barValue - barMin, barMax - barMin);
            if simplified then
                factionStandingtext = isFriendship and repInfo.reaction or factionStandingtext or "";
                return (factionStandingtext.." "..rolloverText), factionName
            end
        end

        local text;

        if factionStandingtext then
            if showFactionName and not text then text = factionName.." "; end;
            if not text then text = L["Current Colon"] end;
            factionStandingtext = " |cffffffff"..factionStandingtext.."|r";
            text = text .. factionStandingtext;
        end

        if rolloverText then
            if showFactionName and not text then text = factionName.." "; end;
            if not text then text = L["Current Colon"] end;
            rolloverText = "  |cffffffff"..rolloverText.."|r";
            text = text .. rolloverText;
        end

        if text then
            if not showFactionName then
                text = " \n"..text;
            end

            if cappedAlert then
                text = text.."\n"..cappedAlert;
            end
        end

        return text, factionName
    end
    API.GetFactionStatusText = GetFactionStatusText;


    local function GetReputationChangeFromText(text)
        local name, amount;
        name, amount = match(text, L["Match Pattern Rep 1"]);
        if not name then
            name, amount = match(text, L["Match Pattern Rep 2"]);
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


    function API.GetMaxRenownLevel(factionID)
        local renownLevelsInfo = C_MajorFactions.GetRenownLevels(factionID);
        if renownLevelsInfo then
            return renownLevelsInfo[#renownLevelsInfo].level
        end
    end
end

do  -- Spell
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

    if C_Spell.GetSpellCooldown then
        API.GetSpellCooldown = C_Spell.GetSpellCooldown;
    else
        local GetSpellCooldown = GetSpellCooldown;
        function API.GetSpellCooldown(spell)
            local startTime, duration, isEnabled, modRate = GetSpellCooldown(spell);
            if startTime ~= nil then
                local tbl = {
                    startTime = startTime,
                    duration = duration,
                    isEnabled = isEnabled,
                    modRate = modRate,
                };
                return tbl
            end
        end
    end

    if C_Spell.GetSpellCharges then
        API.GetSpellCharges = C_Spell.GetSpellCharges;
    else
        local GetSpellCharges = GetSpellCharges;
        function API.GetSpellCharges(spell)
            local currentCharges, maxCharges, cooldownStartTime, cooldownDuration, chargeModRate = GetSpellCharges(spell);
            if currentCharges then
                local tbl = {
                    currentCharges = currentCharges,
                    maxCharges = maxCharges,
                    cooldownStartTime = cooldownStartTime,
                    cooldownDuration = cooldownDuration,
                    chargeModRate = chargeModRate,
                };
                return tbl
            end
        end
    end

    if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
        function API.IsSpellKnown(spellID, isPet)
            local spellBank = isPet and Enum.SpellBookSpellBank.Pet or Enum.SpellBookSpellBank.Player;
            local includeOverrides = false;
            return C_SpellBook.IsSpellInSpellBook(spellID, spellBank, includeOverrides);
        end
    else
        API.IsSpellKnown = C_SpellBook.IsSpellKnown or IsSpellKnownOrOverridesKnown or IsSpellKnown;
    end
end

do  -- System
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

    function API.GetModifierKeyName(key)
        if key and ModifierKeyName[key] then
            return ModifierKeyName[key]
        end
    end


    function API.HandleModifiedItemClick(link, itemLocation)
        if InCombatLockdown() then return false end;

        if IsModifiedClick("CHATLINK") then
            if ( ChatEdit_InsertLink(link) ) then
                return true
            elseif SocialPostFrame and Social_IsShown() then
                Social_InsertLink(link);
                return true
            end
        end

        if IsModifiedClick("DRESSUP") then
            if itemLocation then
                return DressUpItemLocation(itemLocation)
            end
            return DressUpLink(link)
        end
    end


    function API.ToggleBlizzardTokenUIIfWarbandCurrency(currencyID)
        if InCombatLockdown() then return end;

        local info = currencyID and C_CurrencyInfo.GetCurrencyInfo(currencyID);
        if not (info and info.isAccountTransferable) then return end;

        local onlyShow = false;      --If true, don't hide the frame when shown
        ToggleCharacter("TokenFrame", onlyShow);
    end


    function API.AddButtonToAddonCompartment(identifier, name, icon, onClickFunc, onEnterFunc, onLeaveFunc)
        local f = AddonCompartmentFrame;
        if not f then return end;

        for index, addonData in ipairs(f.registeredAddons) do
            if addonData.identifier == identifier then
                return
            end
        end

        local addonData = {
            identifier = identifier,
            text = name,
            icon = icon,
            func = onClickFunc,
            funcOnEnter = onEnterFunc,
            funcOnLeave = onLeaveFunc,
        };

        f:RegisterAddon(addonData)
    end


    function API.RemoveButtonFromAddonCompartment(identifier)
        local f = AddonCompartmentFrame;
        if not f then return end;

        for index, addonData in ipairs(f.registeredAddons) do
            if addonData.identifier == identifier then
                table.remove(f.registeredAddons, index);
                f:UpdateDisplay();
                return
            end
        end
    end


    function API.TriggerExpansionMinimapButtonAlert(text)
        if ExpansionLandingPageMinimapButton then
            ExpansionLandingPageMinimapButton:TriggerAlert(text);
        end
    end

    function API.CloseBossBanner()
        local banner = BossBanner;
        if not banner then return end;

        banner:StopAnimating();
        banner:Hide();
        banner.lootShown = 0;
        banner.pendingLoot = {};

        if banner.baseHeight then
            banner:SetHeight(banner.baseHeight);
        end

        if banner.LootFrames then
            for _, f in ipairs(banner.LootFrames) do
                f:Hide();
            end
        end

        local textureKeys = {
            "BannerTop", "BannerBottom", "BannerMiddle", "BottomFillagree", "SkullSpikes", "RightFillagree", "LeftFillagree",
            "Title", "SubTitle", "FlashBurst", "FlashBurstLeft", "FlashBurstCenter", "RedFlash",
        };

        for _, key in ipairs(textureKeys) do
            if banner[key] then
                banner[key]:SetAlpha(0);
            end
        end

        TopBannerManager_BannerFinished();
    end
end

do  -- Player
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


    function API.IsGreatVaultFeatureAvailable()
        return IsPlayerAtMaxLevel() and C_WeeklyRewards ~= nil;
    end
end

do  -- Scenario
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

do  -- ObjectPool
    local ObjectPoolMixin = {};

    function ObjectPoolMixin:RemoveObject(obj)
        obj:Hide();
        obj:ClearAllPoints();

        if obj.OnRemoved then
            obj:OnRemoved();
        end

        if self.onRemovedFunc then
            self.onRemovedFunc(obj);
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

        if self.onAcquiredFunc then
            self.onAcquiredFunc(obj);
        end

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
    ObjectPoolMixin.Release = ObjectPoolMixin.ReleaseAll;

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

    function ObjectPoolMixin:GetActiveObjects()
        return self.activeObjects
    end

    local function CreateObjectPool(createObjectFunc, onRemovedFunc, onAcquiredFunc)
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
        pool.onRemovedFunc = onRemovedFunc;
        pool.onAcquiredFunc = onAcquiredFunc;

        return pool
    end
    API.CreateObjectPool = CreateObjectPool;
end

do  -- Transmog
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

do  -- Quest
    local GetRegularQuestTitle = C_QuestLog.GetTitleForQuestID or C_QuestLog.GetQuestInfo;
    local RequestLoadQuest = C_QuestLog.RequestLoadQuestByID or Nop;
    local GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID or GetQuestLogIndexByID or Nop;

    local function GetQuestName(questID)
        local questName = C_TaskQuest.GetQuestInfoByQuestID(questID);
        if not questName then
            questName = GetRegularQuestTitle(questID);
        end
        if questName and questName ~= "" then
            return questName
        else
            RequestLoadQuest(questID);
        end
    end
    API.GetQuestName = GetQuestName;

    function API.IsQuestRewardCached(questID)
        --We use this to query Faction Paragon rewards, so numQuestRewards should always > 0
        --May be 0 during the first query

        local numQuestRewards = GetNumQuestLogRewards(questID);
        if numQuestRewards > 0 then
            local getterFunc = GetQuestLogRewardInfo;
            local itemName, itemTexture, quantity, quality, isUsable, itemID;
            for i = 1, numQuestRewards do
                itemName, itemTexture, quantity, quality, isUsable, itemID = getterFunc(i, questID);
                if not itemName then
                    return false
                end
            end
            return true
        else
            return false
        end
    end

    if addon.IS_CLASSIC then
        --Classic
        function API.GetQuestProgressPercent(questID, asText)
            local value, max = 0, 0;
            local questLogIndex = questID and GetLogIndexForQuestID(questID);

            if questLogIndex and questLogIndex ~= 0 then
                local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
                local text, objectiveType, finished, fulfilled, required;
                for objectiveIndex = 1, numObjectives do
                    text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questLogIndex);
                    --print(questID, GetQuestName(questID), numObjectives, finished, fulfilled, required)
                    if objectiveType ~= "spell" and objectiveType ~= "log" then
                        fulfilled, required = match(text, "(%d+)/(%d+)");
                        if not (fulfilled and required) then
                            fulfilled = 0;
                            required = 1;
                        end
                        if fulfilled > required then
                            fulfilled = required;
                        end
                        value = value + fulfilled;
                        max = max + required;
                    end
                end
            else
                return
            end

            if max == 0 then
                value = 0;
                max = 1;
            end

            if asText then
                return floor(100 * value / max).."%"
            else
                return value / max
            end
        end

        function API.GetQuestProgressTexts(questID, hideFinishedObjectives)
            local questLogIndex = questID and GetLogIndexForQuestID(questID);

            if questLogIndex and questLogIndex ~= 0 then
                local texts = {};
                if IsQuestComplete(questID) then
                    texts[1] = QUEST_PROGRESS_TOOLTIP_QUEST_READY_FOR_TURN_IN or ("|cff20ff20"..L["Ready To Turn In Tooltip"].."|r");
                    return texts
                end

                local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
                local text, objectiveType, finished, fulfilled, required;

                for objectiveIndex = 1, numObjectives do
                    text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questLogIndex);
                    text = text or "";
                    if (objectiveType ~= "spell" and objectiveType ~= "log") and ((not finished) or not hideFinishedObjectives) then
                        if finished then
                            tinsert(texts, format("|cff808080- %s|r", text));
                        else
                            tinsert(texts, format("- %s", text));
                        end
                    end
                end

                return texts
            else
                if not C_QuestLog.IsOnQuest(questID) then
                    local texts = {};

                    if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                        texts[1] = format("|cff808080%s|r", QUEST_COMPLETE);
                    else
                        texts[1] = format("|cffff2020%s|r", L["Not On Quest"]);
                        local description = API.GetDescriptionFromTooltip(questID);
                        if description and description ~= QUEST_TOOLTIP_REQUIREMENTS then
                            tinsert(texts, " ");
                            tinsert(texts, description);
                        end
                    end

                    return texts;
                end
            end
        end
    else
        --Retail
        function API.GetQuestProgressPercent(questID, asText)
            --Unify progression text and bar
            --C_QuestLog.GetNumQuestObjectives

            local value, max = 0, 0;
            local questLogIndex = questID and GetLogIndexForQuestID(questID);

            if questLogIndex and questLogIndex ~= 0 then
                local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
                local text, objectiveType, finished, fulfilled, required;
                for objectiveIndex = 1, numObjectives do
                    text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(questID, objectiveIndex, false);
                    --print(questID, GetQuestName(questID), numObjectives, finished, fulfilled, required)
                    if fulfilled > required then
                        fulfilled = required;
                    end

                    if objectiveType == "progressbar" then
                        fulfilled = 0.01 * GetQuestProgressBarPercent(questID);
                        required = 1;
                    else
                        if not finished then
                            if fulfilled == required then
                                --"Complete the scenario Nightfall" fulfilled = required = 1 when accepting the quest
                                fulfilled = 0;
                            end
                        end
                    end
                    value = value + fulfilled;
                    max = max + required;
                end
            else
                return
            end

            if max == 0 then
                value = 0;
                max = 1;
            end

            if asText then
                return floor(100 * value / max).."%"
            else
                return value / max
            end
        end

        function API.GetQuestProgressTexts(questID, hideFinishedObjectives)
            local questLogIndex = questID and GetLogIndexForQuestID(questID);

            if questLogIndex and questLogIndex ~= 0 then
                local texts = {};
                if C_QuestLog.ReadyForTurnIn(questID) then
                    texts[1] = QUEST_PROGRESS_TOOLTIP_QUEST_READY_FOR_TURN_IN;
                    return texts
                end

                local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
                local text, objectiveType, finished, fulfilled, required;

                for objectiveIndex = 1, numObjectives do
                    text, objectiveType, finished, fulfilled, required = GetQuestObjectiveInfo(questID, objectiveIndex, false);
                    text = text or "";
                    if (not finished) or not hideFinishedObjectives then
                        if objectiveType == "progressbar" then
                            fulfilled = GetQuestProgressBarPercent(questID);
                            fulfilled = floor(fulfilled);
                            if finished then
                                tinsert(texts, format("|cff808080- %s%% %s|r", fulfilled, text));
                            else
                                tinsert(texts, format("- %s", text));
                            end
                        else
                            if finished then
                                tinsert(texts, format("|cff808080- %s|r", text));
                            else
                                tinsert(texts, format("- %s", text));
                            end
                        end
                    end
                end

                return texts
            else
                if not C_QuestLog.IsOnQuest(questID) then
                    local texts = {};

                    if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                        texts[1] = format("|cff808080%s|r", QUEST_COMPLETE);
                    else
                        texts[1] = format("|cffff2020%s|r", L["Not On Quest"]);
                        local description = API.GetDescriptionFromTooltip(questID);
                        if description and description ~= QUEST_TOOLTIP_REQUIREMENTS then
                            tinsert(texts, " ");
                            tinsert(texts, description);
                        end
                    end

                    return texts;
                end
            end
        end
    end


    function API.GetQuestRewards(questID)
        --Ignore XP, Money     --GetQuestLogRewardXP()

        local rewards;
        local missingData = false;

        local function SortFunc_QualityID(a, b)
            if a.quality ~= b.quality then
                return a.quality > b.quality
            end

            if a.id ~= b.id then
                return a.id > b.id
            end

            if a.quantity ~= b.quantity then
                return a.quantity > b.quantity
            end

            return true
        end

        if C_QuestLog.GetQuestRewardCurrencies and C_QuestInfoSystem.HasQuestRewardCurrencies(questID) then
            local currencies = {};
            local currencyRewards = C_QuestLog.GetQuestRewardCurrencies(questID);
            local currencyID, quality;
            local info;

            for index, currencyReward in ipairs(currencyRewards) do
                currencyID = currencyReward.currencyID;
                quality = C_CurrencyInfo.GetCurrencyInfo(currencyID).quality;
                info = {
                    name = currencyReward.name,
                    texture = currencyReward.texture,
                    quantity = currencyReward.totalRewardAmount,
                    id = currencyID,
                    questRewardContextFlags = currencyReward.questRewardContextFlags,
                    quality = quality,
                };
                tinsert(currencies, info);
            end

            table.sort(currencies, SortFunc_QualityID);

            if not rewards then
                rewards = {};
            end
            rewards.currencies = currencies;

            if #currencyRewards == 0 then
                missingData = true;
            end
        elseif GetQuestLogRewardCurrencyInfo then
            local numCurrencies = GetNumQuestLogRewardCurrencies(questID) or 0;
            local name, texture, quantity, currencyID, quality;
            local currencies;
            for i = 1, numCurrencies do
                name, texture, quantity, currencyID, quality = GetQuestLogRewardCurrencyInfo(i, questID);
                if name then
                    if not currencies then
                        currencies = {};
                    end
                    local info = {
                        name = name,
                        texture = texture,
                        quantity = quantity,
                        id = currencyID,
                        questRewardContextFlags = 0,
                        quality = quality,
                    };
                    tinsert(currencies, info);
                else
                    missingData = true;
                end
            end

            if currencies then
                table.sort(currencies, SortFunc_QualityID);
                if not rewards then
                    rewards = {};
                end
                rewards.currencies = currencies;
            end
        end

        if C_QuestInfoSystem.GetQuestRewardSpells and C_QuestInfoSystem.HasQuestRewardSpells(questID) then
            local spells = {};
            local spellRewards = C_QuestInfoSystem.GetQuestRewardSpells(questID);
            local info;
            for index, spellID in ipairs(spellRewards) do
                info = C_QuestInfoSystem.GetQuestRewardSpellInfo(questID, spellID);
                info.id = spellID;
                tinsert(spells, info);
            end

            table.sort(spells,
                function(a, b)
                    if a.id ~= b.id then
                        return a.id > b.id
                    end

                    return true
                end
            );

            if not rewards then
                rewards = {};
            end
            rewards.spells = spells;
        end

        local numItems = GetNumQuestLogRewards(questID);

        if numItems > 0 then
            local items = {};
            local name, texture, quantity, quality, isUsable, itemID, itemLevel;
            local info;
            for index = 1, numItems do
                name, texture, quantity, quality, isUsable, itemID, itemLevel = GetQuestLogRewardInfo(index, questID);
                if name and itemID then
                    info = {
                        name = name,
                        texture = texture,
                        quantity = quantity,
                        quality = quality,
                        id = itemID,
                    };
                    tinsert(items, info);
                else
                    missingData = true;
                end
            end

            table.sort(items, SortFunc_QualityID);

            if not rewards then
                rewards = {};
            end
            rewards.items = items;
        end

        local honor = GetQuestLogRewardHonor(questID);
        if honor > 0 then
            if not rewards then
                rewards = {};
            end
            rewards.honor = honor;
        end

        return rewards, missingData
    end

    --[[
    function YeetQuestForMap(uiMapID)
        --Only contains quests with visible marker on the map
        if not uiMapID then
            uiMapID = C_Map.GetBestMapForUnit("player");
        end

        local function PrintQuests(quests)
            if not quests then return end;
            local questID, name;
            for k, v in ipairs(quests) do
                questID = v.questID;
                name = GetQuestName(questID);
                if name then
                    print(questID, name);
                else
                    CallbackRegistry:LoadQuest(questID, function(_questID)
                        print(questID, GetQuestName(questID));
                    end);
                end
            end
        end

        PrintQuests(C_TaskQuest.GetQuestsOnMap(uiMapID));
        print(" ");
        PrintQuests(C_QuestLog.GetQuestsOnMap(uiMapID));
    end
    --]]
end

do  -- Tooltip
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


    local function SetTooltipWithPostCall(tooltip, tooltipPostCall, getterName, ...)
        local tooltipInfo = {
            getterName = getterName,
            getterArgs = { ... };
        };
        tooltipInfo.tooltipPostCall = tooltipPostCall;
        tooltip:ProcessInfo(tooltipInfo);
    end
    API.SetTooltipWithPostCall = SetTooltipWithPostCall;


    function API.GetDescriptionFromTooltip(questID)
        if questID then
            local hyperlink = "|Hquest:"..questID.."|h";
            local data = addon.TooltipAPI.GetHyperlink(hyperlink);
            if data then
                return data.lines[3] and data.lines[3].leftText or nil
            end
        end
    end


    local PseudoTooltipInfoMixin = {};
    do
        function PseudoTooltipInfoMixin:AddBlankLine()
            tinsert(self.tooltipData.lines, {
                leftText = " ",
                wrapText = true,
            });
        end

        function PseudoTooltipInfoMixin:AddLine(text, r, g, b, wrapText)
            local color;
            if type(r) == "table" then
                color = r;
            else
                color = CreateColor(r, g, b);
            end
            tinsert(self.tooltipData.lines, {
                leftText = text,
                leftColor = color,
                wrapText = true,
            });
        end

        function PseudoTooltipInfoMixin:AddDoubleLine(leftText, rightText, leftR, leftG, leftB, rightR, rightG, rightB)
            local leftColor, rightColor;
            if type(leftR) == "table" then
                leftColor = leftR;
                rightColor = leftG;
            else
                leftColor = CreateColor(leftR, leftG, leftB);
                rightColor = CreateColor(rightR, rightG, rightB);
            end
            tinsert(self.tooltipData.lines, {
                leftText = leftText,
                leftColor = leftColor,
                rightText = rightText,
                rightColor = rightColor,
            });
        end
    end

    function API.CreateAppendTooltipInfo()
        local info = {};
        info.append = true;
        info.tooltipData = {};
        info.tooltipData.lines = {};
        API.Mixin(info, PseudoTooltipInfoMixin);
        info:AddBlankLine();
        return info
    end


    local TextureInfoTable = {
        width = 14,
        height = 14,
        margin = { left = 0, right = 4, top = 0, bottom = 0 },
        texCoords = { left = 0.0625, right = 0.9375, top = 0.0625, bottom = 0.9375 },
    };

    function API.AddTextureToTooltip(tooltip, texture)
        tooltip:AddTexture(texture, TextureInfoTable);
    end

    function API.AddCraftingReagentToTooltip(tooltip, item, quantityRequired)
        local name = C_Item.GetItemNameByID(item) or ("item:"..item);
        local count = C_Item.GetItemCount(item, true, false, true, true);
        local icon =  C_Item.GetItemIconByID(item);
        local rightText;
        local isRed;

        if quantityRequired then
            rightText = count.."/"..quantityRequired;
            isRed = count < quantityRequired;
        else
            rightText = count;
        end

        if isRed then
            tooltip:AddDoubleLine(name, rightText, 1, 0.125, 0.125, 1, 0.125, 0.125);
        else
            tooltip:AddDoubleLine(name, rightText, 1, 1, 1, 1, 1, 1);
        end

        tooltip:AddTexture(icon, TextureInfoTable);

        return true
    end


    local AdditionalTooltip = {};

    function API.SetExtraTooltipForCurrency(currencyID, line)
        --line: string or function
        AdditionalTooltip[currencyID] = line;
    end

    function API.GetExtraTooltipForCurrency(currencyID)
        local text = AdditionalTooltip[currencyID];
        if type(text) == "function" then
            text = text();
        end
        return text
    end
end

do  -- AsyncCallback
    local AsyncCallback = CreateFrame("Frame");

    --LoadQuestAPI is not available in 60 Classic
    --In this case we will run all callbacks when the time is up
    AsyncCallback.WoWAPI_LoadQuest = C_QuestLog.RequestLoadQuestByID;
    AsyncCallback.WoWAPI_LoadItem = C_Item.RequestLoadItemDataByID;
    AsyncCallback.WoWAPI_LoadSpell = C_Spell.RequestLoadSpellData;

    local CreatureNameCache = {};

    function AsyncCallback:RunAllCallbacks(list)
        for id, callbacks in pairs(list) do
            for _, callbackInfo in ipairs(callbacks) do
                if (callbackInfo.oneTime and not callbackInfo.processed) or (callbackInfo.oneTime == false) then
                    callbackInfo.processed = true;
                    callbackInfo.func(id);
                end
            end
        end
    end

    function AsyncCallback:OnEvent(event, ...)
        local id, success = ...
        local list;

        if event == "QUEST_DATA_LOAD_RESULT" then
            list = self.questCallbacks;
        elseif event == "ITEM_DATA_LOAD_RESULT" then
            list = self.itemCallbacks;
        elseif event == "SPELL_DATA_LOAD_RESULT" then
            list = self.spellCallbacks;
        end

        if list and id and success then
            if list[id] then
                for _, callbackInfo in ipairs(list[id]) do
                    if (callbackInfo.oneTime and not callbackInfo.processed) or (callbackInfo.oneTime == false) then
                        callbackInfo.processed = true;
                        callbackInfo.func(id);
                    end
                end
            end
        end

        self.t = 0;
    end
    AsyncCallback:SetScript("OnEvent", AsyncCallback.OnEvent);

    function AsyncCallback:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.5 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);

            if self.questCallbacks then
                if self.LoadQuest then
                    self:UnregisterEvent("QUEST_DATA_LOAD_RESULT");
                end
                if self.runCallbackAfter then
                    self:RunAllCallbacks(self.questCallbacks);
                end
                self.questCallbacks = nil;
            end

            if self.itemCallbacks then
                if self.LoadItem then
                    self:UnregisterEvent("ITEM_DATA_LOAD_RESULT");
                end
                self:RunAllCallbacks(self.itemCallbacks);
                self.itemCallbacks = nil;
            end

            if self.spellCallbacks then
                if self.LoadSpell then
                    self:UnregisterEvent("SPELL_DATA_LOAD_RESULT");
                end
                self:RunAllCallbacks(self.spellCallbacks);
                self.spellCallbacks = nil;
            end

            if self.creatureCallbacks then
                for id, callbacks in pairs(self.creatureCallbacks) do
                    local name = API.GetCreatureName(id);
                    if name and name ~= "" then
                        CreatureNameCache[id] = name;
                    else
                        name = nil;
                    end
                    if name then
                        for _, callbackInfo in ipairs(callbacks) do
                            if not callbackInfo.processed then
                                callbackInfo.processed = true;
                                callbackInfo.func(id, name);
                            end
                        end
                    end
                end
                self.creatureCallbacks = nil;
            end
        end
    end

    function AsyncCallback:AddCallback(key, id, callback, oneTime)
        if not self[key] then
            self[key] = {};
        end

        if not self[key][id] then
            self[key][id] = {};
        end

        if oneTime == nil then
            oneTime = true;
        end

        local callbackInfo = {
            func = callback,
            oneTime = oneTime,
            processed = false,
        };

        tinsert(self[key][id], callbackInfo);
    end


    function CallbackRegistry:LoadQuest(id, callback, oneTime)
        AsyncCallback:AddCallback("questCallbacks", id, callback, oneTime);
        if AsyncCallback.WoWAPI_LoadQuest then
            AsyncCallback:RegisterEvent("QUEST_DATA_LOAD_RESULT");
            AsyncCallback.WoWAPI_LoadQuest(id);
        else
            AsyncCallback.runCallbackAfter = true;
        end
        AsyncCallback.t = 0;
        AsyncCallback:SetScript("OnUpdate", AsyncCallback.OnUpdate);
    end

    function CallbackRegistry:LoadItem(id, callback, oneTime)
        AsyncCallback:AddCallback("itemCallbacks", id, callback, oneTime);
        if AsyncCallback.WoWAPI_LoadItem then
            AsyncCallback:RegisterEvent("ITEM_DATA_LOAD_RESULT");
            AsyncCallback.WoWAPI_LoadItem(id);
        else
            AsyncCallback.runCallbackAfter = true;
        end
        AsyncCallback.t = 0;
        AsyncCallback:SetScript("OnUpdate", AsyncCallback.OnUpdate);
    end

    function CallbackRegistry:LoadSpell(id, callback, oneTime)
        AsyncCallback:AddCallback("spellCallbacks", id, callback, oneTime);
        if AsyncCallback.WoWAPI_LoadSpell then
            AsyncCallback:RegisterEvent("SPELL_DATA_LOAD_RESULT");
            AsyncCallback.WoWAPI_LoadSpell(id);
        else
            AsyncCallback.runCallbackAfter = true;
        end
        AsyncCallback.t = 0;
        AsyncCallback:SetScript("OnUpdate", AsyncCallback.OnUpdate);
    end

    function CallbackRegistry:LoadCreature(id, callback)
        --Usually used to get npc name
        AsyncCallback:AddCallback("creatureCallbacks", id, callback);
        AsyncCallback.t = 0;
        AsyncCallback:SetScript("OnUpdate", AsyncCallback.OnUpdate);
    end


    function API.GetAndCacheCreatureName(creatureID)
        if CreatureNameCache[creatureID] then
            return CreatureNameCache[creatureID]
        end
        local name = API.GetCreatureName(creatureID);
        if name and name ~= "" then
            CreatureNameCache[creatureID] = name;
        else
            name = nil;
        end
        return name
    end
end

do  -- Container Item Processor
    local GetItemCount = C_Item.GetItemCount;
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

    function API.DoesItemReallyExist(item)
        local a = item and GetItemInfoInstant(item);
        return a ~= nil
    end

    function API.IsItemContextToken(item)
        local _, _, _, _, _, classID, subClassID = GetItemInfoInstant(item);
        return classID == 5 and subClassID == 2
    end
end

do  -- Chat Message
    local ADDON_ICON = "|TInterface\\AddOns\\Plumber\\Art\\Logo\\PlumberLogo32:0:0|t";
    local function PrintMessage(msg)
        if not msg then
            msg = "";
        end
        print(ADDON_ICON.." |cffb8c8d1Plumber:|r "..msg);
    end
    API.PrintMessage = PrintMessage;

    function API.DisplayErrorMessage(msg)
        if not msg then return end;
        local messageType = 0;
        UIErrorsFrame:TryDisplayMessage(messageType, (ADDON_ICON.." |cffb8c8d1Plumber:|r ")..msg, RED_FONT_COLOR:GetRGB());
    end

    function API.CheckAndDisplayErrorIfInCombat()
        if InCombatLockdown() then
            API.DisplayErrorMessage(L["Error Show UI In Combat"]);
            return true
        else
            return false
        end
    end
end

do  -- Custom Hyperlink ItemRef

    --[[--Example
        local CustomLink = {};
    
        CustomLink.typeName = "Test";
        CustomLink.colorCode = "66bbff";	--LINK_FONT_COLOR
    
        function CustomLink.callback(arg1, arg2, arg3)
            print(arg1, arg2, arg3);
        end
    
        API.AddCustomLinkType(CustomLink.typeName, CustomLink.callback, CustomLink.colorCode);
    
        function CustomLink.GenerateLink(arg1, arg2, arg3)
            return API.GenerateCustomLink(CustomLink.typeName, L["Click To See Details"], arg1, arg2, arg3);
        end
    --]]

    local CustomLinkUtil = {};

    function API.AddCustomLinkType(typeName, callback, colorCode)
        CustomLinkUtil[typeName] = {
            callback = callback,
            colorCode = colorCode,
        };
    end

    function API.GenerateCustomLink(typeName, displayedText, ...)
        if CustomLinkUtil[typeName] then
            if not CustomLinkUtil.registered then
                CustomLinkUtil.registered = true;
                EventRegistry:RegisterCallback("SetItemRef", function(_, link, text, button, chatFrame)
                    if link then
                        local _typeName, subText = match(link, "plumber:([^:]+):([^|]+)");
                        if _typeName and CustomLinkUtil[_typeName] then
                            local args = {};
                            for arg in string.gmatch(subText, "[^:]+") do
                                tinsert(args, arg);
                            end
                            CustomLinkUtil[_typeName].callback(unpack(args));
                        end
                    end
                end);
            end

            --|cffxxxxxx|Htype:payload|h[text]|h|r
            local args = {...};
            local link = "|Haddon:plumber:"..typeName;

            for i, v in ipairs(args) do
                link = link..":"..v;
            end

            link = format("|cff%s%s|h[%s]|h|r", CustomLinkUtil[typeName].colorCode or "ffd100", link, displayedText);

            return link
        end
    end
end

do  -- 11.0 Menu Formatter
    function API.ShowBlizzardMenu(ownerRegion, schematic, contextData)
        contextData = contextData or {};

        local menu = MenuUtil.CreateContextMenu(ownerRegion, function(ownerRegion, rootDescription)
            rootDescription:SetTag(schematic.tag, contextData);

            for _, info in ipairs(schematic.objects) do
                local elementDescription;
                if info.type == "Title" then
                    elementDescription = rootDescription:CreateTitle();
                    elementDescription:AddInitializer(function(f, description, menu)
                        f.fontString:SetText(info.name);
                    end);
                elseif info.type == "Divider" then
                    elementDescription = rootDescription:CreateDivider();
                elseif info.type == "Spacer" then
                    elementDescription = rootDescription:CreateSpacer();
                elseif info.type == "Button" then
                    elementDescription = rootDescription:CreateButton(info.name, info.OnClick);
                elseif info.type == "Checkbox" then
                    elementDescription = rootDescription:CreateCheckbox(info.name, info.IsSelected, info.ToggleSelected);
                end

                if info.IsEnabledFunc then
                    local enabled = info.IsEnabledFunc();
                    elementDescription:SetEnabled(enabled);
                end

                if info.tooltip then
                    elementDescription:SetTooltip(function(tooltip, elementDescription)
                        --GameTooltip_AddInstructionLine(tooltip, "Test Tooltip Instruction");
                        --GameTooltip_AddErrorLine(tooltip, "Test Tooltip Colored Line");
                        if info.DynamicTooltipFunc then
                            local text, r, g, b = info.DynamicTooltipFunc();
                            if text then
                                GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                                tooltip:AddLine(text, r, g, b, true);
                            end
                        else
                            GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                            GameTooltip_AddNormalLine(tooltip, info.tooltip);
                        end
                    end);
                end

                if info.rightText or info.rightTexture then
                    local rightText;
                    if type(info.rightText) == "function" then
                        rightText = info.rightText();
                    else
                        rightText = info.rightText;
                    end
                    elementDescription:AddInitializer(function(button, description, menu)
                        local rightWidth = 0;

                        if info.rightTexture then
                            local iconSize = 18;
                            local rightTexture = button:AttachTexture();
                            rightTexture:SetSize(iconSize, iconSize);
                            rightTexture:SetPoint("RIGHT");
                            rightTexture:SetTexture(info.rightTexture);
                            rightWidth = rightWidth + iconSize;
                            rightWidth = 20;
                        end

                        local fontString = button.fontString;
                        fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB());

                        local fontString2;
                        if info.rightText then
                            fontString2 = button:AttachFontString();
                            fontString2:SetHeight(20);
                            fontString2:SetPoint("RIGHT", button, "RIGHT", 0, 0);
                            fontString2:SetJustifyH("RIGHT");
                            fontString2:SetText(rightText);
                            fontString2:SetTextColor(0.5, 0.5, 0.5);
                            rightWidth = fontString2:GetWrappedWidth() + 20;
                        end

                        local width = fontString:GetWrappedWidth() + rightWidth;
                        local height = 20;

                        return width, height;
                    end);
                end
            end
        end);

        if schematic.onMenuClosedCallback then
            menu:SetClosedCallback(schematic.onMenuClosedCallback);
        end

        return menu
    end
end

do  -- Slash Commands
    local SlashCmdUtil = {};
    SlashCmdUtil.functions = {};
    SlashCmdUtil.alias = "plmr";
    SlashCmdUtil.cmdID = {
        DrawerMacro = 1,
    };

    function SlashCmdUtil.Process(input)
        if input and type(input) == "string" then
            input = " "..input;
            local token;
            local args = {};
            for arg in string.gmatch(input, "%s+([%S]+)") do
                if not token then
                    token = arg;
                else
                    tinsert(args, arg);
                end
            end

            if token and SlashCmdUtil.functions[token] then
                SlashCmdUtil.functions[token](unpack(args));
            end
        end
    end

    function SlashCmdUtil.CreateSlashCommand(func, alias1, alias2)
        local name = "PLUMBERCMD";
        if alias1 then
            _G["SLASH_"..name.."1"] = "/"..alias1;
        end
        if alias2 then
            _G["SLASH_"..name.."2"] = "/"..alias2;
        end
        SlashCmdList[name] = func;
    end

    function API.AddSlashSubcommand(name, func)
        if not SlashCmdUtil.cmdID[name] then return end;

        if not SlashCmdUtil.cmdAdded then
            SlashCmdUtil.CreateSlashCommand(SlashCmdUtil.Process, SlashCmdUtil.alias);
        end

        local token = tostring(SlashCmdUtil.cmdID[name]);
        SlashCmdUtil.functions[token] = func;
    end

    function API.GetSlashSubcommand(name)
        if SlashCmdUtil.cmdID[name] then
            return string.format("/%s %s", SlashCmdUtil.alias, SlashCmdUtil.cmdID[name]);
        end
    end
end

do  -- Macro Util
    local WoWAPI = {
        IsPlayerSpell = IsPlayerSpell,
        PlayerHasToy = PlayerHasToy or Nop,
        GetItemCount = C_Item.GetItemCount,
        GetItemCraftedQualityByItemInfo = C_TradeSkillUI and C_TradeSkillUI.GetItemCraftedQualityByItemInfo or Nop,
        GetItemReagentQualityByItemInfo = C_TradeSkillUI and C_TradeSkillUI.GetItemReagentQualityByItemInfo or Nop,
        --IsConsumableItem = C_Item.IsConsumableItem or Nop,    --This is not what we thought it is
        GetItemInfoInstant = C_Item.GetItemInfoInstant,
        FindPetIDByName = C_PetJournal and C_PetJournal.FindPetIDByName or Nop,
        GetPetInfoBySpeciesID = C_PetJournal and C_PetJournal.GetPetInfoBySpeciesID or Nop,
    };

    function API.CanPlayerPerformAction(actionType, arg1, arg2)
        if actionType == "spell" then
            return API.IsSpellKnown(arg1) or WoWAPI.IsPlayerSpell(arg1)
        elseif actionType == "item" then
            if API.IsToyItem(arg1) then
                return WoWAPI.PlayerHasToy(arg1)
            else
                local _, _, _, _, _, classID, subClassID = WoWAPI.GetItemInfoInstant(arg1);

                --always return true for conumable items in case player needs to restock
                --if classID == 0 then
                --    return true
                --end
                local isConsumable = classID == 0;

                local count = WoWAPI.GetItemCount(arg1, true, true, true, true);
                return count > 0, isConsumable
            end
        end

        return true     --always return true for unrecognized action
    end

    function API.GetItemCraftingQuality(item)
        local quality = WoWAPI.GetItemCraftedQualityByItemInfo(item);
        if not quality then
            quality = WoWAPI.GetItemReagentQualityByItemInfo(item);
        end
        return quality
    end

    function API.GetPetNameAndUsability(speciesID, checkUsability)
        local name = WoWAPI.GetPetInfoBySpeciesID(speciesID);
        if checkUsability then
            local _, petGUID = WoWAPI.FindPetIDByName(name);
            return name, petGUID ~= nil
        else
            return name
        end
    end
end

do  --Professions
    --/dump ProfessionsBook_GetSpellBookItemSlot(GetMouseFoci()[1]) --Used on ProfessionsBookFrame SpellButton

    local GetProfessions = GetProfessions;
    local GetProfessionInfo = GetProfessionInfo;
    local GetSpellBookItemType = (C_SpellBook and C_SpellBook.GetSpellBookItemType) or GetSpellBookItemInfo;

    function API.GetProfessionSpellInfo(professionOrderIndex)
        local prof1, prof2, archaeology, fishing, cooking = GetProfessions();
        local index;

        if professionOrderIndex == 2 then
            index = prof2;
        else
            index = prof1;
        end

        if not index then return end;

        local name, texture, rank, maxRank, numSpells, spellOffset, skillLine, rankModifier, specializationIndex, specializationOffset, skillLineName = GetProfessionInfo(index);
        if not spellOffset then return end;

        local buttonID = 1;     --PrimaryProfessionSpellButtonBottom
        local slotIndex = spellOffset + buttonID;
        local activeSpellBank = 0;  --Enum.SpellBookSpellBank.Player
        local itemType, actionID, spellID = GetSpellBookItemType(slotIndex, activeSpellBank);

        --Classic
        if not spellID then
            spellID = actionID;
        end

        local tbl = {
            spellID = spellID,
            texture = texture,
            name = name,
            slotIndex = slotIndex,
            activeSpellBank = activeSpellBank,
            skillLine = skillLine,
        };

        return tbl
    end

    if C_TradeSkillUI and C_TradeSkillUI.OpenTradeSkill then
        --Retail
        function API.OpenProfessionFrame(professionOrderIndex)
            local info = API.GetProfessionSpellInfo(professionOrderIndex);
            if info then
                local currBaseProfessionInfo = C_TradeSkillUI.GetBaseProfessionInfo();
                if (not currBaseProfessionInfo) or (currBaseProfessionInfo.professionID ~= info.skillLine) then
                    C_TradeSkillUI.OpenTradeSkill(info.skillLine);
                    --C_SpellBook.CastSpellBookItem(info.slotIndex, info.activeSpellBank);
                else
                    C_TradeSkillUI.CloseTradeSkill();
                end
            end
        end
    else
        --Classic
        function API.OpenProfessionFrame(professionOrderIndex)
            local info = API.GetProfessionSpellInfo(professionOrderIndex);
            if info then
                CastSpell(info.slotIndex, "professions");
            end
        end
    end
    PlumberGlobals.OpenProfessionFrame = API.OpenProfessionFrame;
end

do  --Addon Skin
    local AddOnSkinHandler = {
        ElvUI = {
            global = "ElvUI",
            root = function() local E = ElvUI[1]; return E:GetModule("Skins") end,
            handlerKey = {
                editbox = "HandleEditBox";
            };
        },
    };

    function API.SetupSkinExternal(object)
        local objectType = object:GetObjectType();
        objectType = string.lower(objectType);

        for addOnName, v in pairs(AddOnSkinHandler) do
            if _G[v.global] then
                local root = v.root();
                if v.handlerKey[objectType] then
                    root[v.handlerKey[objectType]](root, object);
                    return true, addOnName
                end
            end
        end
    end
end

do  --FrameUtil
    function API.RegisterFrameForEvents(frame, events)
        for i, event in ipairs(events) do
            frame:RegisterEvent(event);
        end
    end

    function API.UnregisterFrameForEvents(frame, events)
        for i, event in ipairs(events) do
            frame:UnregisterEvent(event);
        end
    end
end

do  --Locale-dependent API
    local locale = GetLocale();
    if locale == "ruRU" then
        function API.GetItemCountFromText(text)
            --"r%s*[xх](%d+)" doesn't work
            local count = match(text, "r%s*x(%d+)");
            if not count then
                count = match(text, "r%s*х(%d+)");
            end
            if count then
                return tonumber(count)
            else
                return 1
            end
        end
    elseif locale == "zhCN" or locale == "zhTW" then
        function API.GetItemCountFromText(text)
            local count = match(text, "r%s*x(%d+)");
            if count then
                return tonumber(count)
            else
                return 1
            end
        end
    elseif locale == "frFR" then
        function API.GetItemCountFromText(text)
            local count = match(text, "|r[%s ]*x(%d+)");
            if count then
                return tonumber(count)
            else
                return 1
            end
        end
    else
        function API.GetItemCountFromText(text)
            local count = match(text, "|r%s*x(%d+)");
            if count then
                return tonumber(count)
            else
                return 1
            end
        end
    end
end

do  --Delves
    function API.DisplayDelvesGreatVaultTooltip(owner, tooltip, index, level, id, progressDelta)
        --Set the tooltip owner prior to this
        --for Delves, level is the tier number


        if level == 0 then
            GameTooltip_SetTitle(tooltip, WEEKLY_REWARDS_UNLOCK_REWARD);

            local description;

            if index == 2 then
                description = GREAT_VAULT_REWARDS_WORLD_COMPLETED_FIRST;
            elseif index == 3 then
                description = GREAT_VAULT_REWARDS_WORLD_COMPLETED_SECOND;
            else
                description = GREAT_VAULT_REWARDS_WORLD_INCOMPLETE;
            end

            local formatRemainingProgress = true;

            if formatRemainingProgress then
                GameTooltip_AddNormalLine(tooltip, description:format(progressDelta));
            else
                GameTooltip_AddNormalLine(tooltip, description);
            end
        else
            GameTooltip_SetTitle(tooltip, WEEKLY_REWARDS_CURRENT_REWARD);


            --[[
            --This default method is unreliable since 11.2.0, so we hardcode itemlevel
            local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(id);
            local itemLevel, upgradeItemLevel;

            if itemLink then
                itemLevel = C_Item.GetDetailedItemLevelInfo(itemLink);
            end
            if upgradeItemLink then
                upgradeItemLevel = C_Item.GetDetailedItemLevelInfo(upgradeItemLink);
            end
            --]]

            local itemLevel = API.GetDelvesGreatVaultItemLevel(level);

            local nextLevel = level + 1;
            local upgradeItemLevel = API.GetDelvesGreatVaultItemLevel(nextLevel);

            if level > 0 and itemLevel then
                GameTooltip_AddNormalLine(tooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_WORLD, itemLevel, level));
            end

            GameTooltip_AddBlankLineToTooltip(tooltip);

            if level == 0 or (upgradeItemLevel and upgradeItemLevel > itemLevel) then
                GameTooltip_AddColoredLine(tooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
                GameTooltip_AddHighlightLine(tooltip, string.format(WEEKLY_REWARDS_COMPLETE_WORLD, nextLevel));
            else
                GameTooltip_AddColoredLine(tooltip, WEEKLY_REWARDS_MAXED_REWARD, GREEN_FONT_COLOR);
            end
        end

        tooltip:Show();
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