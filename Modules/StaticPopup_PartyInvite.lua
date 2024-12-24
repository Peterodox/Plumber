local _, addon = ...
local L = addon.L;
local GetDBBool = addon.GetDBBool;
local StaticPopupUtil = addon.StaticPopupUtil;
local JoinText = addon.API.JoinText;
local match = string.match;

local POPUP_PARTY = "PARTY_INVITE";
local FACTION_A = FACTION_ALLIANCE or "Alliance";
local FACTION_H = FACTION_HORDE or "Horde";
local EL = CreateFrame("Frame");
--[[
local Portrait = EL:CreateTexture("TTT")
Portrait:SetSize(40, 40);
Portrait:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
Portrait:SetColorTexture(1, 1, 1);
--]]

local WhoButton;
local GuildInviteWidget;
local function WhoButton_Hide()
    if WhoButton and WhoButton:IsVisible() then
        WhoButton:Hide();
    end
end

function EL:OnEvent(event, ...)
    if event == "PARTY_INVITE_REQUEST" then
        self:PARTY_INVITE_REQUEST(...);
    elseif event == "GUILD_INVITE_REQUEST" then
        self:GUILD_INVITE_REQUEST(...);
    end
end

function EL:GUILD_INVITE_REQUEST(inviter, guildName, guildAchievementPoints, oldGuildName, isNewGuild, tabardInfo)
    if not self.pauseUpdate then
        self.pauseUpdate = true;
        C_Timer.After(0, function()
            self.pauseUpdate = nil;

            if not (GuildInviteFrame and GuildInviteFrame:IsVisible()) then
                --Not a StaticPopup, see GuildInviteFrame.lua 
                return
            end

            if not GuildInviteWidget then
                GuildInviteWidget = addon.CreateSimpleTooltip(GuildInviteFrame);
                GuildInviteWidget:SetPoint("BOTTOM", GuildInviteFrame, "TOP", 0, 4);
                GuildInviteWidget:SetScript("OnHide", function()
                    GuildInviteWidget:Hide();
                end);
            end

            local NORMAL_TEXT = "|TInterface\\AddOns\\Plumber\\Art\\GossipIcons\\MagnifyingGlass:0:0:0:-4:32:32:0:32:0:32:128:128:128|t |cffffd200"..L["Click To Search Player"].."|r";
            local HIGHLIGHTED_TEXT = "|TInterface\\AddOns\\Plumber\\Art\\GossipIcons\\MagnifyingGlass:0:0:0:-4:32:32:0:32:0:32:255:255:255|t |cffffffff"..L["Click To Search Player"].."|r";

            local tooltipFrame = GuildInviteWidget;
            tooltipFrame:SetText(NORMAL_TEXT);
            tooltipFrame:Show();

            local function WhoButton_OnEnter()
                tooltipFrame:SetText(HIGHLIGHTED_TEXT);
            end

            local function WhoButton_OnLeave()
                tooltipFrame:SetText(NORMAL_TEXT);
            end

            local function WhoButton_OnClick(f)
                local name = inviter;
                f:SetScript("OnLeave", nil);
                f:Hide();
                tooltipFrame:SetText("|cff808080"..L["Searching Player In Progress"].."|r");
                f:RegisterEvent("WHO_LIST_UPDATE");
                f:SetScript("OnEvent", function(_, event)
                    f:UnregisterEvent(event);
                    f:SetScript("OnEvent", nil);
                    if not (WhoFrame and WhoFrame:IsVisible()) then
                        C_FriendList.SetWhoToUi(false);
                    end
                    if not tooltipFrame:IsVisible() then return end;
                    local numWhos = C_FriendList.GetNumWhoResults();
                    if numWhos > 0 then
                        local info = C_FriendList.GetWhoInfo(1);
                        if info then
                            local text = string.format("Level %d %s %s - %s", info.level, info.raceStr, info.classStr, info.area);
                            if text then
                                tooltipFrame:SetText("|cffffff00"..text.."|r");
                            end
                        end
                    else
                        tooltipFrame:SetText(L["Player Not Found"]);
                    end
                end);
                C_FriendList.SetWhoToUi(true);
                local whoFormat = "n-\"%s\" g-\"%s\"";
                C_FriendList.SendWho(string.format(whoFormat, name, guildName));
            end

            if not WhoButton then
                WhoButton = CreateFrame("Button", nil, tooltipFrame);
                WhoButton:SetScript("OnHide", function(f)
                    f:Hide();
                    f:ClearAllPoints();
                    f:SetParent(nil);
                end)
            end

            WhoButton:SetScript("OnEnter", WhoButton_OnEnter);
            WhoButton:SetScript("OnLeave", WhoButton_OnLeave);
            WhoButton:SetScript("OnClick", WhoButton_OnClick);

            WhoButton:SetParent(tooltipFrame);
            local w, h = tooltipFrame:GetSize();
            WhoButton:SetSize(w, h);
            WhoButton:SetPoint("CENTER", tooltipFrame, "CENTER", 0, 0);
            WhoButton:SetFrameLevel(tooltipFrame:GetFrameLevel() + 1);
            WhoButton:Show();
        end);
    end
end

function EL:PARTY_INVITE_REQUEST(name, tank, healer, damage, isXRealm, allowMultipleRoles, inviterGUID, isQuestSessionActive)
    self.lastGUID = nil;

    if (tank or healer or damage or isQuestSessionActive) then
        return
    end

    self.lastGUID = inviterGUID;

    --[[
    if string.find(name, "%-") then
        name = string.gsub(name, "%-.+", "");
    end
    print(name)
    SetPortraitTexture(Portrait, name)  --Doesn't seem to work on characters with -ServerName
    --]]

    if not self.pauseUpdate then
        self.pauseUpdate = true;
        WhoButton_Hide();
        C_Timer.After(0, function()
            self.pauseUpdate = nil;
            self:ProcessLastInviter();
        end);
    end
end

local function FormatLevelText(level)
    return "|cffffd200"..string.format(TOOLTIP_UNIT_LEVEL, level).."|r";
end

local function FormatSubtext(spec, race, faction)
    local subtext = spec;
    local lineBreak = false;
    if GetDBBool("PartyInviter_Race") and race then
        race = "|cffcccccc"..race.."|r";
        lineBreak = true;
        subtext = JoinText("\n", subtext, race);
    end
    if GetDBBool("PartyInviter_Faction") and faction then
        if faction == FACTION_A then
            faction = "|cff009cde"..faction.."|r";
        elseif faction == FACTION_H then
            faction = "|cffee6159"..faction.."|r";
        else
            faction = nil;
        end
        if faction then
            if lineBreak then
                subtext = JoinText("  ", subtext, faction);
            else
                subtext = JoinText("\n", subtext, faction);
            end
        end
    end
    return subtext
end

function EL:GetPlayerInfoFromTooltip(guid)
    local data = C_TooltipInfo.GetHyperlink("unit:"..guid);
    if data and data.lines then
        local level, spec, faction, classColorString, subtext;
        --local playerLocation  = PlayerLocation:CreateFromGUID(guid);
        --local className, classFilename = C_PlayerInfo.GetClass(playerLocation);
        local className, classFilename, race = GetPlayerInfoByGUID(guid);
        if classFilename then
            classColorString = RAID_CLASS_COLORS[classFilename].colorStr;
        end

        for i, line in ipairs(data.lines) do
            if i == 1 then

            elseif i == 2 then  --Race is on the same line
                level = match(line.leftText, "%d+");
                if level then
                    level = tonumber(level);
                    if level and level > 0 then
                        level = FormatLevelText(level);
                    else
                        level = nil;
                    end
                end
            elseif i == 3 then
                if className and classColorString then
                    if match(line.leftText, className) then
                        spec = "|c"..classColorString..line.leftText.."|r";
                    end
                end
            elseif i == 4 then
                faction = line.leftText;
                if faction == FACTION_A then
                    faction = "|cff009cde"..faction.."|r";
                elseif faction == FACTION_H then
                    faction = "|cffee6159"..faction.."|r";
                else
                    faction = nil;
                end
            end
        end

        subtext = FormatSubtext(spec, race, faction);

        return level, subtext, data.dataInstanceID
    end
end

function EL:ProcessLastInviter()
    if not (self.lastGUID) then return end;
    local level, subtext, dataInstanceID = self:GetPlayerInfoFromTooltip(self.lastGUID);
    if level then
        local text;
        if subtext then
            text = JoinText("  ", level, subtext);
        else
            text = level;
        end

        if StaticPopupUtil:ShowSimpleTooltip(POPUP_PARTY, text, nil, "TOP") then
            StaticPopupUtil:AddTooltipInfoCallback(dataInstanceID, function ()
                EL:ProcessLastInviter();
            end)
        end
    end
end

function EL:EnableModule(state)
    if state then
        self.enabled = true;
        self:RegisterEvent("PARTY_INVITE_REQUEST");
        self:RegisterEvent("GUILD_INVITE_REQUEST");
        self:SetScript("OnEvent", self.OnEvent);
    elseif self.enabled then
        self.enabled = nil;
        self:UnregisterEvent("PARTY_INVITE_REQUEST");
        self:UnregisterEvent("GUILD_INVITE_REQUEST");
        self:SetScript("OnEvent", nil);
        StaticPopupUtil:HidePopupWidget(POPUP_PARTY);
    end
end


local OptionToggle_OnClick;
do  --Options
    local DemoFrame;
    local OptionFrame;

    local function DemoFrame_ShowSearch()
        local icon = "|TInterface\\AddOns\\Plumber\\Art\\GossipIcons\\MagnifyingGlass:0:0:0:-4:32:32:0:32:0:32:128:128:128|t ";
        DemoFrame:SetText(icon..L["Click To Search Player"]);
    end

    local function DemoFrame_Update()
        local primaryTalentTree = GetSpecialization();
        local unit = "player";
        local level = UnitLevel(unit);
        local classDisplayName, class = UnitClass(unit);
        local classColorString = RAID_CLASS_COLORS[class].colorStr;

        local spec, _;
        if primaryTalentTree then
            _, spec = GetSpecializationInfo(primaryTalentTree, nil, nil, nil, UnitSex(unit));
        end
        if spec and spec ~= "" then
            spec = spec.." "..classDisplayName;
        else
            spec = classDisplayName;
        end
        spec = "|c"..classColorString..spec.."|r";

        local race = UnitRace(unit);
        local faction = UnitFactionGroup(unit);
        local levelText = FormatLevelText(level);
        local subtext = FormatSubtext(spec, race, faction);
        DemoFrame:SetText(JoinText("  ", levelText, subtext));
    end

    local function Checkbox_OnClick()
        if OptionFrame then
            DemoFrame_Update();
            OptionFrame:Layout();
        end
    end

    local function AcquireDemoFrame()
        if not DemoFrame then
            DemoFrame = addon.CreateSimpleTooltip(nil);
        end
        DemoFrame_Update();
        return DemoFrame
    end

    local OPTIONS_SCHEMATIC = {
        title = L["ModuleName PartyInviterInfo"],
        widgets = {
            {type = "Header", label = L["Additional Info"]};
            {type = "Checkbox", label = L["Race"] , onClickFunc = Checkbox_OnClick, dbKey = "PartyInviter_Race", tooltip = nil},
            {type = "Checkbox", label = L["Faction"], onClickFunc = Checkbox_OnClick, dbKey = "PartyInviter_Faction", tooltip = nil},

            {type = "Divider"},
            {type = "Custom", onAcquire = AcquireDemoFrame, align = "center"},
        },
    };

    function OptionToggle_OnClick(self, button)
        OptionFrame = addon.ToggleSettingsDialog(self, OPTIONS_SCHEMATIC);
        if OptionFrame then
            OptionFrame:ConvertAnchor();
        end
    end
end


do
    local function EnableModule(state)
        EL:EnableModule(state)
    end

    local moduleData = {
        name = L["ModuleName PartyInviterInfo"],
        dbKey = "PartyInviterInfo",
        description = L["ModuleDescription PartyInviterInfo"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1146,
        moduleAddedTime = 1735040000,
        optionToggleFunc = OptionToggle_OnClick,
    };

    addon.ControlCenter:AddModule(moduleData);
end


--[[    --Other events don't return playerGUID
    TRADE_REQUEST: name
    GUILD_INVITE_REQUEST: inviter, guildName, guildAchievementPoints, oldGuildName, isNewGuild, tabardInfo


    C_FriendList.SendWho #hardware input
--]]