local _, addon = ...
local L = addon.L;
local API = addon.API;

local match = string.match;

local GetChannelInfoFromIdentifier = C_ChatInfo.GetChannelInfoFromIdentifier;
local LeaveChannelByLocalID = LeaveChannelByLocalID;
local LeaveChannelByName = LeaveChannelByName;
local GetNumDisplayChannels = GetNumDisplayChannels;

local STATIC_POPUP_WHICH = "PLUMBER_AUTO_LEAVE_CHANNEL_CONFIRMATION";

local ANY_AUTO_LEAVE_CHANNEL = false;


local ChatOptions = CreateFrame("Frame");

ChatOptions.unleavableChannel = {
    [32] = true,    --Newcomer Chat
    [35] = true,    --War Within Test Discussion

    --Chromie Time
    [36] = true,
    [37] = true,
    [38] = true,
    [39] = true,
    [40] = true,
    [41] = true,
};

function ChatOptions:GetContextMenuChatTarget()
    return self.chatTarget
end

function ChatOptions:Hook()
    if self.isHooked then return end;
    self.isHooked = true;

    if ChatChannelDropdown_Show then
        hooksecurefunc("ChatChannelDropdown_Show", function(chatFrame, chatType, chatTarget, chatName)
            self.chatTarget = chatTarget;
        end);
    end

    if Menu and Menu.ModifyMenu then
        Menu.ModifyMenu("MENU_CHAT_FRAME_CHANNEL", function(owner, rootDescription, contextData)
            if not self.enabled then return end;

            --local info = localID and C_ChatInfo.GetChannelInfoFromIdentifier(localID);    --Data not immediately available
            --if not (info and (info.channelType == 0 or info.channelType == 1)) then return end;     --Enum.PermanentChatChannelType

            local isInit = true;
            local canLeaveChannel = false;

            if isInit or canLeaveChannel then
                rootDescription:CreateDivider();

                local buttonDescription;

                --Leave Button
                buttonDescription = rootDescription:CreateButton(L["Chat Leave"], function(...)
                    local localID = ChatOptions:GetContextMenuChatTarget();
                    if ChatOptions:CanLeaveChannel() then
                        LeaveChannelByLocalID(localID);
                    end
                end);

                buttonDescription:AddInitializer(function(button, description, menu)
                    local fontString = button.fontString;
                    fontString:SetText(L["Chat Leave"]);
                    fontString:SetTextColor(0.5, 0.5, 0.5);
                    button:Disable();

                    if isInit then
                        --Due to function calling order the chatTarget is available after menu is created
                        C_Timer.After(0, function()
                            if button:IsVisible() then
                                canLeaveChannel = ChatOptions:CanLeaveChannel();
                                if canLeaveChannel then
                                    fontString:SetTextColor(1.000, 0.282, 0.000);
                                    button:Enable();
                                end
                            end
                        end);
                    end
                end)

                --Leave On All Characters
                buttonDescription = rootDescription:CreateButton(L["Chat Leave All Characters"], function(...)
                    local localID = ChatOptions:GetContextMenuChatTarget();
                    if ChatOptions:CanLeaveChannel() then
                        local info = GetChannelInfoFromIdentifier(localID);
                        if info and info.zoneChannelID then
                            local channelID =info.zoneChannelID;
                            local name = info.shortcut or info.name;
                            if channelID and name then
                                local data = {
                                    text = L["Chat Auto Leave Alert Format"]:format(name);
                                    callback = function()
                                        LeaveChannelByName(info.shortcut);
                                        ChatOptions:SetAutoLeaveChannel(channelID, true);
                                    end;
                                };

                                ChatOptions:SetupStaticPopup();
                                StaticPopup_Show(STATIC_POPUP_WHICH, nil, nil, data);
                            end
                        end
                    end
                end);

                buttonDescription:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_SetTitle(tooltip, L["Chat Leave All Characters"]);
                    GameTooltip_AddNormalLine(tooltip, L["Chat Leave All Characters Tooltip"]);
                end);

                buttonDescription:AddInitializer(function(button, description, menu)
                    local fontString = button.fontString;
                    fontString:SetText(L["Chat Leave All Characters"]);
                    fontString:SetTextColor(0.5, 0.5, 0.5);
                    button:Disable();

                    if isInit then
                        --Due to function calling order the chatTarget is available after menu is created
                        C_Timer.After(0, function()
                            if button:IsVisible() then
                                canLeaveChannel = ChatOptions:CanLeaveChannel();
                                if canLeaveChannel then
                                    fontString:SetTextColor(1.000, 0.282, 0.000);
                                    button:Enable();
                                end
                            end
                        end);
                    end
                end)
            end
        end);
    end
end

function ChatOptions:SetupStaticPopup()
    if self.popupInserted then return end;
    self.popupInserted = true;
    if StaticPopupDialogs then
        StaticPopupDialogs[STATIC_POPUP_WHICH] = {
            text = "",		-- supplied dynamically.
            button1 = YES or "Yes",
            button2 = NO or "No",
            OnShow = function(self, data)
                self.text:SetText(data.text);
                if data.showAlert then
                    self.AlertIcon:Show();
                end
            end,
            OnAccept = function(self, data)
                data.callback();
            end,
            OnCancel = function(self, data)
                local cancelCallback = data and data.cancelCallback or nil;
                if cancelCallback ~= nil then
                    cancelCallback();
                end
                self:Hide();
            end,
            hideOnEscape = 1,
            timeout = 0,
            whileDead = 1,
            wide = 1,
            showAlert = 1,
        };
    end
end

function ChatOptions:CanLeaveChannel()
    local localID = self:GetContextMenuChatTarget();
    if not localID then return false end;

    local info = GetChannelInfoFromIdentifier(localID);
    return info and (info.channelType == 0 or info.channelType == 1) and (info.zoneChannelID and (not self.unleavableChannel[info.zoneChannelID]))
end

function ChatOptions:GetCurrentChannelName()
    local localID = self:GetContextMenuChatTarget();
    if localID then
        local info = GetChannelInfoFromIdentifier(localID);
        return info and info.name
    end
end


local CustomLink = {};
do
    CustomLink.typeName = "rejoinchat";
    CustomLink.colorCode = "ffd100";

    function CustomLink.callback(channelID, shortcut)
        channelID = channelID and tonumber(channelID);
        if channelID and ChatOptions:ShouldAutoLeaveChannel(channelID) and shortcut then
            ChatOptions:SetAutoLeaveChannel(channelID, false);
            API.PrintMessage(string.format(L["Chat Auto Leave Cancel Format"], shortcut));
        end
    end

    API.AddCustomLinkType(CustomLink.typeName, CustomLink.callback, CustomLink.colorCode);

    function CustomLink.GenerateLink(channelName, channelID, shortcut)
        local link = API.GenerateCustomLink(CustomLink.typeName, L["Click To Disable"], channelID, shortcut);
        if link then
            return string.format(L["Auto Leave Channel Format"], channelName).."  "..link
        end
    end
end


function ChatOptions:ShouldAutoLeaveChannel(channelID)
    return self.channelsToLeave and self.channelsToLeave[channelID] == true
end

function ChatOptions:AutoLeaveChannels()
    local channelsToLeave;

    if self.channelsToLeave then
        local info, channelID, name, shortcut;
        for localID = 1, GetNumDisplayChannels() do
            info = GetChannelInfoFromIdentifier(localID);
            if info then
                channelID = info.zoneChannelID;
                if channelID and self.channelsToLeave[channelID] then
                    if not channelsToLeave then
                        channelsToLeave = {};
                    end
                    table.insert(channelsToLeave, {
                        name = info.name or "Unknown",
                        shortcut = info.shortcut or "",
                        channelID = channelID,
                        localID = localID;
                    });
                end
            end
        end
    end

    if channelsToLeave then
        print(" ");
        for _, info in ipairs(channelsToLeave) do
            API.PrintMessage(CustomLink.GenerateLink(info.name, info.channelID, info.shortcut));
            LeaveChannelByName(info.shortcut);
        end
        print(" ");
    end
end

function ChatOptions:OnUpdate(elapsed)
    self.t = self.t + elapsed;
    if self.t < 1.0 then return end;
    self.t = 0;
    self:SetScript("OnUpdate", nil);
    self:AutoLeaveChannels();
end

function ChatOptions:RequestUpdateChannels()
    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate);
end

function ChatOptions:UpdateAutoLeave()
    ANY_AUTO_LEAVE_CHANNEL = false;

    for _, state in pairs(self.channelsToLeave) do
        if state then
            ANY_AUTO_LEAVE_CHANNEL = true;
            break
        end
    end

    if ANY_AUTO_LEAVE_CHANNEL then
        self:RegisterEvent("CHANNEL_UI_UPDATE");

        if not self.callbackRegistered then
            self.callbackRegistered = true;
            EventRegistry:RegisterCallback("SetItemRef", function(_, link, text, button, chatFrame)
                if ANY_AUTO_LEAVE_CHANNEL and link then
                    local channelID, shortcut = match(link, "plumber:rejoinchat:(%d+):([^:]+)");
                    channelID = channelID and tonumber(channelID);
                    if channelID and self:ShouldAutoLeaveChannel(channelID) then
                        self:SetAutoLeaveChannel(channelID, false);
                        API.PrintMessage(string.format(L["Chat Auto Leave Cancel Format"], shortcut));
                    end
                end
            end);
        end
    else
        self:UnregisterEvent("CHANNEL_UI_UPDATE");
    end
end

function ChatOptions:SetAutoLeaveChannel(channelID, shouldLeave)
    if not self.channelsToLeave then return end;

    self.channelsToLeave[channelID] = shouldLeave;
    self:UpdateAutoLeave();
    self:RequestUpdateChannels();
end

function ChatOptions:LoadSettings()
    if not PlumberDB then
        self.channelsToLeave = {};
        return
    end

    local tbl = {};
    if PlumberDB.AutoLeaveChatChannels then
        for channelID, state in pairs(PlumberDB.AutoLeaveChatChannels) do
            if state then
                tbl[channelID] = true;
            end
        end
    end

    PlumberDB.AutoLeaveChatChannels = tbl;
    self.channelsToLeave = PlumberDB.AutoLeaveChatChannels;
    self:UpdateAutoLeave();
end

function ChatOptions:OnEvent(event, ...)
    if event == "CHANNEL_UI_UPDATE" then
        self:RequestUpdateChannels();
    end
end

local function EnableModule(state)
    local self = ChatOptions;
    self:SetScript("OnUpdate", nil);
    if state then
        self.enabled = true;
        self:SetScript("OnEvent", self.OnEvent);
        self:Hook();
        self:LoadSettings();
        self:RequestUpdateChannels();
    elseif self.enabled then
        self.enabled = false;
        self:SetScript("OnEvent", nil);
        ANY_AUTO_LEAVE_CHANNEL = false;
        self:UnregisterEvent("CHANNEL_UI_UPDATE");
    end
end


do
    local moduleData = {
        name = L["ModuleName ChatOptions"],
        dbKey = "ChatOptions",
        description = L["ModuleDescription ChatOptions"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1160,
        moduleAddedTime = 1732700000,
    };

    addon.ControlCenter:AddModule(moduleData);
end