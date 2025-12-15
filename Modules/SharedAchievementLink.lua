local _, addon = ...
local API = addon.API;

local SharedAchievementLinkScripts = {};
addon.SharedAchievementLinkScripts = SharedAchievementLinkScripts;


local MountXAchievement = {};
local DecorXAchievement = {};


local LABEL = "Achievement:";
do  --Localize Match Format
    local locale = GetLocale() or "enUS";

    local allLabelText = {
        enUS = "Achievement:",
        deDE = "Erfolg:",
        esES = "Logro:",
        esMX = "Logro:",
        frFR = "Haut fait :",
        itIT = "Impresa:",
        koKR = "업적:",
        ptBR = "Conquista:",
        ruRU = "Достижение:",
        zhCN = "成就：",
        zhTW = "成就：",
    };

    if allLabelText[locale] then
        LABEL = allLabelText[locale];
    end

    allLabelText = nil;
end


do
    local function OnHyperlinkClick(self, link, text, button, fontString, left, bottom, width, height)
        if button == "RightButton" then
            local achievementID = string.match(link, "achievement:(%d+)");
            if achievementID then
                local closedFrameName;
                if MountJournal and MountJournal:IsVisible() then
                    closedFrameName = COLLECTIONS;
                elseif HousingDashboardFrame and HousingDashboardFrame:IsVisible() then
                    closedFrameName = HOUSING_DASHBOARD_FRAMETITLE;
                end

                if closedFrameName then
                    closedFrameName = addon.L["Close Frame Format"]:format(closedFrameName);
                else
                    closedFrameName = "";
                end

                local _, achievementName, _, completed = GetAchievementInfo(achievementID);
                local ContextMenu = {
                    tag = "PlumberHyperlinkAchievementMenu",
                    objects = {
                        {type = "Title", name = achievementName,
                            rightText = completed and ("|cff19ff19"..ACHIEVEMENTFRAME_FILTER_COMPLETED.."|r") or nil,
                        },
                        {type = "Button", name = OBJECTIVES_VIEW_ACHIEVEMENT.." "..closedFrameName,
                            OnClick = function()
                                if not InCombatLockdown() then
                                    OpenAchievementFrameToAchievement(achievementID);
                                end
                            end,

                            IsEnabledFunc = function()
                                return not InCombatLockdown();
                            end,
                        },
                    };
                };

                if not completed then
                    if C_ContentTracking.IsTracking(Enum.ContentTrackingType.Achievement, achievementID) then
                        table.insert(ContextMenu.objects, {
                            type = "Button",
                            name = OBJECTIVES_STOP_TRACKING,
                            OnClick = function()
                                C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, achievementID, Enum.ContentTrackingStopType.Manual);
                                if AchievementFrameAchievements_ForceUpdate then
                                    AchievementFrameAchievements_ForceUpdate();
                                end
                            end,
                        });
                    else
                        table.insert(ContextMenu.objects, {
                            type = "Button",
                            name = TRACK_ACHIEVEMENT,
                            OnClick = function()
                                C_ContentTracking.StartTracking(Enum.ContentTrackingType.Achievement, achievementID);
                                if AchievementFrameAchievements_ForceUpdate then
                                    AchievementFrameAchievements_ForceUpdate();
                                end
                            end,
                        });
                    end
                end

                local menu = addon.API.ShowBlizzardMenu(self, ContextMenu);
                menu:ClearAllPoints();
                menu:SetPoint("TOPLEFT", fontString, "TOPLEFT", left + width, bottom);

                GameTooltip:Hide();

                return
            end
        end

        SetItemRef(link, text, button);
    end

    local function OnHyperlinkEnter(self, link, text, fontString, left, bottom, width, height)
        local tooltip = self.tooltipFrame or GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_PRESERVE");
        tooltip:ClearAllPoints();
        tooltip:SetPoint("BOTTOMLEFT", fontString, "TOPLEFT", left + width, bottom);
        tooltip:SetHyperlink(link);
    end

    local function OnHyperlinkLeave(self)
        if self.tooltipFrame then
            self.tooltipFrame:Hide();
        end
        GameTooltip:Hide();
    end


    SharedAchievementLinkScripts.OnHyperlinkClick = OnHyperlinkClick;
    SharedAchievementLinkScripts.OnHyperlinkEnter = OnHyperlinkEnter;
    SharedAchievementLinkScripts.OnHyperlinkLeave = OnHyperlinkLeave;
end




local function GetAchievementNameFromText(sourceText)
    local name = string.match(sourceText, LABEL.."%s*|r([^|]+)|n");
    if not name then
        name = string.match(sourceText, LABEL.."|r ([^|]+)|n");
    end
    if name and name ~= "" then
        name = strtrim(name);
        return name;
    end
end


local function ModifySourceText()
    local mountID = MountJournal.selectedMountID;
    if not mountID then return end;

    local achievementID = MountXAchievement[mountID];
    if achievementID and achievementID ~= 0 then
        local _, name = GetAchievementInfo(achievementID);
        name = string.gsub(name, "%-", "%%-");
        name = string.gsub(name, "%!", "%%!");
        name = string.gsub(name, "%(", "%%(");
        name = string.gsub(name, "%)", "%%)");

        local fontString = API.GetGlobalObject("MountJournal.MountDisplay.InfoButton.Source");
        --local text = fontString:GetText();
        local _, _, text = C_MountJournal.GetMountInfoExtraByID(mountID);
        local count = 0;
        local link = GetAchievementLink(achievementID);

        text, count = string.gsub(text, name, link);

        if count == 0 then
            local overrideName = GetAchievementNameFromText(text);
            if overrideName then
                text, count = string.gsub(text, overrideName, link);
            end
        end

        if count > 0 then
            fontString:SetText(text);
        end
    end
end


local EL = CreateFrame("Frame");
do
    function EL:OnAchievementSearchStart(mountID)
        self.storedTable = MountXAchievement;
        self.storedKey = mountID;
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
        self:RegisterEvent("ACHIEVEMENT_SEARCH_UPDATED");
        if self.t then
            self:SetScript("OnEvent", self.OnEvent);
        end
    end

    function EL:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.05 then
            self.t = 0;
            self:SetScript("OnUpdate", nil);
            self:UnregisterEvent("ACHIEVEMENT_SEARCH_UPDATED");
        end
    end

    function EL:OnEvent(event, ...)
        self:UnregisterEvent(event);
        local n = GetNumFilteredAchievements();
        if n > 0 then
            local achievementID = GetFilteredAchievementID(1);

            if self.storedTable and self.storedKey then
                self.storedTable[self.storedKey] = achievementID;
            end

            if self.storedTable == MountXAchievement then
                ModifySourceText();
            end
        end
    end
end


local function Callback_UpdateMountDisplay()
    local mountID = MountJournal.selectedMountID;
    if not mountID then return end;

    if not MountXAchievement[mountID] then
        MountXAchievement[mountID] = 0;
        local _, _, sourceText = C_MountJournal.GetMountInfoExtraByID(mountID);
        local name = GetAchievementNameFromText(sourceText);
        if name then
            EL:OnAchievementSearchStart(mountID);
            SetAchievementSearchString(name);
        end
    end

    ModifySourceText();
end


local function ModifyMountJournalSource()
    local InfoButton = API.GetGlobalObject("MountJournal.MountDisplay.InfoButton");

    if not (InfoButton and InfoButton.Source and MountJournal_UpdateMountDisplay) then
        return
    end

    hooksecurefunc("MountJournal_UpdateMountDisplay", Callback_UpdateMountDisplay);

    InfoButton:SetScript("OnHyperlinkClick", SharedAchievementLinkScripts.OnHyperlinkClick);
    InfoButton:SetScript("OnHyperlinkEnter", SharedAchievementLinkScripts.OnHyperlinkEnter);
    InfoButton:SetScript("OnHyperlinkLeave", SharedAchievementLinkScripts.OnHyperlinkLeave);

    SetAchievementSearchString("");

    C_Timer.After(0.2, function()
        Callback_UpdateMountDisplay();
    end);
end


local function OnLoad_Blizzard_Collections()
    C_Timer.After(0, ModifyMountJournalSource);
end
EventUtil.ContinueOnAddOnLoaded("Blizzard_Collections", OnLoad_Blizzard_Collections);