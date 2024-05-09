-- TalkingHeadFrame Revamp: Less intrudingIsWorldQuest

local _, addon = ...
local API = addon.API;
local L = addon.L;

local FADE_OUT_AFTER_FINISH = 0.5;
local QUEST_DESCRIPTION_GRADIENT_LENGTH = 30;
local TEXT_WIDTH = 512;
local LINE_SPACING = 2;
local DEFAULT_POSITION_Y = 336;

local SPEECH_FORMAT_GENRIC = "|cffffd100%s: |r%s";
local SPEECH_FORMAT_PVP = "|cffff2020%s: |r%s";

local FadeFrame = API.UIFrameFade;
local Lerp = API.Lerp;
local Round = API.Round;
local strlenutf8 = strlenutf8;
local ceil = math.ceil;
local max = math.max;
local format = string.format;
local PlaySound = PlaySound;
local StopSound = StopSound;
local GetCurrentLineInfo = C_TalkingHead.GetCurrentLineInfo;
local IsWorldQuest = C_QuestLog.IsWorldQuest;
local IsQuestTask = C_QuestLog.IsQuestTask;
local IsInInstance = IsInInstance;
--local SetPortraitTextureFromCreatureDisplayID = SetPortraitTextureFromCreatureDisplayID;

local DB;

local PVP_CREATURE_DISPLAYID = {
    [108418] = true,
};


local NewTalkingHead = CreateFrame("Frame", nil, UIParent);
NewTalkingHead:Hide();
NewTalkingHead:SetFrameStrata("FULLSCREEN");  --LOW
NewTalkingHead:SetFrameLevel(980);
NewTalkingHead:SetSize(TEXT_WIDTH, 32);

--[[cause taint "UIParentBottomManagedFrameTemplate"
NewTalkingHead.layoutIndex = 1208;
NewTalkingHead.hideWhenActionBarIsOverriden = false;
NewTalkingHead.align = "center";
--]]

addon.TalkingHead = NewTalkingHead;


local function SetFontShadow(fontString)
    --Game Bug: Shadow is removed upon SetAlphaGradient
    fontString:SetShadowColor(0, 0, 0, 1);
    fontString:SetShadowOffset(1, -1);
end

local function SetupFontString(fontString)
    fontString:SetJustifyH("CENTER");
    fontString:SetJustifyV("TOP");
    fontString:SetSpacing(LINE_SPACING);
    SetFontShadow(fontString);
end


local function FadeOutAfter_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t >= self.fadeOutDelay then
        self:FadeOutText(true);
    end
end

local function FadeIn_TypeWriter_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    self.fadingProgress = self.fadingProgress + (elapsed * self.gradientCPS);

    self.gradientLength = self.gradientLength + 10 * elapsed;
    if self.gradientLength > QUEST_DESCRIPTION_GRADIENT_LENGTH then
        self.gradientLength = QUEST_DESCRIPTION_GRADIENT_LENGTH;
    end

    if not self.LineText:SetAlphaGradient(self.fadingProgress, self.gradientLength) then
        self:SetScript("OnUpdate", FadeOutAfter_OnUpdate);
        return true
    end

    if self.t < self.backgroundFadeDuration then
        self.Background:SetAlpha(Lerp(0, 1, self.t / self.backgroundFadeDuration));
    end
end

local function FadeIn_InstantText_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    self.fadingProgress = self.fadingProgress + 4*elapsed;

    if self.fadingProgress >= 1 then
        self:SetScript("OnUpdate", FadeOutAfter_OnUpdate);
        self.fadingProgress = 1;
        self.LineText:SetAlpha(1);
        self.Background:SetAlpha(1);
        return true
    end

    self.LineText:SetAlpha(self.fadingProgress);
    self.Background:SetAlpha(self.fadingProgress);
end

local function FadeOut_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0 then
        self.textAlpha = self.textAlpha - 2 * elapsed;
        if self.textAlpha <= 0 then
            self.textAlpha = 0;
            self:Hide();
            self.isFadingOut = false;
            self:SetScript("OnUpdate", nil);
        end
        self.LineText:SetAlpha(self.textAlpha);
        self.Background:SetAlpha(self.textAlpha);
    end
end

function NewTalkingHead:SetText(text)
    self.LineText:SetText(text);
    self.LineText:Show();

    local textWidth = self.LineText:GetWrappedWidth();
    local textHeight = self.LineText:GetHeight() - (self.fontHeight + LINE_SPACING);
    local numLines = self.LineText:GetNumLines() + 1;

    self.Background:ClearAllPoints();
    self.Background:SetPoint("CENTER", self, "TOP", 0, -0.5*( numLines*(self.fontHeight + LINE_SPACING) - LINE_SPACING));
    self.Background:SetSize(textWidth + 32, textHeight + 32);

    self:UpdateFrameSize();
end

function NewTalkingHead:FadeInText(speakerName, text, voiceoverDuration, hideName, isFinalLine, displayInfo)
    if not (text and speakerName and voiceoverDuration) then return end;

    if not hideName then
        local speechFormat;
        if displayInfo and PVP_CREATURE_DISPLAYID[displayInfo] then
            speechFormat = SPEECH_FORMAT_PVP;
        else
            speechFormat = SPEECH_FORMAT_GENRIC;
        end
        text = format(speechFormat, speakerName, text);
    end

    local numChars = strlenutf8(text);
    if numChars == 0 or voiceoverDuration == 0 then return end;

    numChars = numChars + 15;
    text = "               \n"..text;

    self:SetText(text);

    self.gradientCPS = ceil(numChars / voiceoverDuration) + 10;
    self.fadingProgress = 0;
    self.backgroundFadeDuration = max(voiceoverDuration - 1, 1);

    self.t = 0;
    self.gradientLength = QUEST_DESCRIPTION_GRADIENT_LENGTH;

    if isFinalLine then
        self.fadeOutDelay = voiceoverDuration + 1;
    else
        self.fadeOutDelay = voiceoverDuration;
    end

    self.isFadingOut = false;

    if self.instantText then
        self.LineText:SetAlpha(0);
        self.Background:SetAlpha(0);
        self:SetScript("OnUpdate", FadeIn_InstantText_OnUpdate);
    else
        self.LineText:SetAlpha(1);
        self.LineText:SetAlphaGradient(0, QUEST_DESCRIPTION_GRADIENT_LENGTH);
        self.Background:SetAlpha(0);
        self:SetScript("OnUpdate", FadeIn_TypeWriter_OnUpdate);
    end

    FadeFrame(self, 0, 1);
end

function NewTalkingHead:FadeOutText(noDelay)
    if self:IsShown() then
        if not self.isFadingOut then
            self.textAlpha = self.LineText:GetAlpha();
            self.t = (noDelay and 0) or -1;
            self:SetScript("OnUpdate", FadeOut_OnUpdate);
        end
    else
        self.isFadingOut = false;
        self.LineText:Hide();
        self.LineText:SetAlpha(0);
        self.textAlpha = 0;
        self:SetScript("OnUpdate", nil);
    end
end

function NewTalkingHead:SetFontHeightByPercentage(percentage)
    if not percentage then
        percentage = 100;
    end

    if percentage < 100 then
        percentage = 100;
    elseif percentage > 120 then
        percentage = 120;
    end

    local font, baseFontHeight = QuestFont:GetFont();
    local fontHeight = Round(percentage * 0.01 * baseFontHeight);

    self.fontHeight = fontHeight;

    local style, gray;
    if DB.TalkingHead_TextOutline then
        style = "OUTLINE";
        gray = 0.898;   --VERY_LIGHT_GRAY_COLOR
    else
        style = "";
        gray = 1;
    end

    self.LineText:SetFont(font, fontHeight, style);
    self.LineText:SetTextColor(gray, gray, gray);
    SetupFontString(self.LineText);

    DB.TalkingHead_FontSize = percentage;
end

function NewTalkingHead:LoadPosition()
    self:ClearAllPoints();
    if DB.TalkingHead_PositionX and DB.TalkingHead_PositionY then
        if DB.TalkingHead_PositionX > 0 then
            self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", DB.TalkingHead_PositionX, DB.TalkingHead_PositionY);
        else
            self:SetPoint("TOP", UIParent, "BOTTOM", 0, DB.TalkingHead_PositionY);
        end
    else
        self:SetPoint("TOP", UIParent, "BOTTOM", 0, DEFAULT_POSITION_Y);
    end
end

function NewTalkingHead:Init()
    DB = PlumberDB;

    self:LoadPosition();

    local _, fontHeight = QuestFont:GetFont();
    self.baseFontHeight = Round(fontHeight + 0.5);
    self.fontHeight = self.baseFontHeight;

    self.LineText = NewTalkingHead:CreateFontString(nil, "OVERLAY", "QuestFont");
    self.LineText:SetPoint("TOP", self, "TOP", 0, 0);
    self.LineText:SetWidth(TEXT_WIDTH);
    self.LineText:SetAlpha(0);
    self:SetFontHeightByPercentage(DB.TalkingHead_FontSize);

    self.Background = self:CreateTexture(nil, "BACKGROUND");
    self.Background:SetTexture("Interface/AddOns/Plumber/Art/Frame/SubtitleShadow_NineSlice");
    self.Background:SetTextureSliceMargins(30, 30, 30, 30);
    self.Background:SetTextureSliceMode(0);
    self.Background:SetSize(128, 32);
    self.Background:SetPoint("CENTER", self, "TOP", 0, 0);

    --[[
    self.Portrait = self:CreateTexture(nil, "BACKGROUND", nil, -1);
    self.Portrait:SetSize(115, 115);
    self.Portrait:SetPoint("CENTER", self, "CENTER", 0, -6);
    --]]

    self:OnSettingsChanged();

    self.Init = function() end;
end

function NewTalkingHead:EnableTalkingHead()
    if self.enabled then return end;

    if self.blizzardTalkingHeadEnabled == nil then
        self.blizzardTalkingHeadEnabled = TalkingHeadFrame:IsEventRegistered("TALKINGHEAD_REQUESTED");
    end
    TalkingHeadFrame:UnregisterEvent("TALKINGHEAD_REQUESTED");

    self.enabled = true;
    self:Init();

    self:RegisterEvent("TALKINGHEAD_REQUESTED");
    self:RegisterEvent("TALKINGHEAD_CLOSE");
    self:RegisterEvent("LOADING_SCREEN_ENABLED");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");

    self:SetScript("OnEvent", self.OnEvent);

    if not self.editmodeHooked then
        self.editmodeHooked = true;
        EventRegistry:RegisterCallback("EditMode.Enter", self.EnterEditMode, self);
        EventRegistry:RegisterCallback("EditMode.Exit", self.ExitEditMode, self);
    end
end

function NewTalkingHead:DisableTalkingHead()
    if self.enabled then
        if self.blizzardTalkingHeadEnabled then
            TalkingHeadFrame:RegisterEvent("TALKINGHEAD_REQUESTED");
        end
        self.blizzardTalkingHeadEnabled = nil;
        self.enabled = false;

        self:UnregisterEvent("TALKINGHEAD_REQUESTED");
        self:UnregisterEvent("TALKINGHEAD_CLOSE");
        self:UnregisterEvent("SOUNDKIT_FINISHED");
        self:UnregisterEvent("LOADING_SCREEN_ENABLED");
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        self:UnregisterEvent("QUEST_ACCEPTED");
        self:UnregisterEvent("QUEST_TURNED_IN");

        self:OnTalkingHeadClose();
        self:SetScript("OnEvent", nil);
    end
end

function NewTalkingHead:TryDisable()
    --Disable if not used in any other modules
    if not DB then DB = PlumberDB end;
    if DB.TalkingHead_MasterSwitch then return end;

    self:DisableTalkingHead();
end

function NewTalkingHead:OnTalkingHeadRequested()
    if self.voHandle then
		StopSound(self.voHandle);
		self.voHandle = nil;
	end

    local displayInfo, cameraID, vo, duration, lineNumber, numLines, name, text, isNewTalkingHead, textureKit = GetCurrentLineInfo();

    --print(name, displayInfo, vo, duration)  --Debug

    if displayInfo and displayInfo ~= 0 and duration then
        local success, voHandle = PlaySound(vo, "Talking Head", true, true);
        if success then
            self:RegisterEvent("SOUNDKIT_FINISHED");
            self.voHandle = voHandle;
        end

        --lineNumber start from 0
        local isFinalLine = lineNumber and numLines and (lineNumber + 1 == numLines);

        if self.shouldMuteLine then
            if isFinalLine then
                self.shouldMuteLine = nil;
            else
                self:MuteNextLine(duration);
            end
            return
        end

        if self.hideInInstance and self.inInstance then
            return
        end

        duration = duration - FADE_OUT_AFTER_FINISH;  --reserved for fade-out between line
        local hideName = (lineNumber ~= 0) and (name and name == self.lastName);
        self.lastName = name;

        self:FadeInText(name, text, duration, hideName, isFinalLine, displayInfo);
        --SetPortraitTextureFromCreatureDisplayID(self.Portrait, displayInfo);
    end
end


function NewTalkingHead:FadeOutFrame()
    FadeFrame(self, 0.5, 0);
end

function NewTalkingHead:OnTalkingHeadClose()
    self:FadeOutFrame();
    self.lastName = nil;
end

function NewTalkingHead:CloseImmediately()
    if self.voHandle then
        StopSound(self.voHandle);
    end
    FadeFrame(self, 0, 0);
    self.lastName = nil;
end

local function ShouldMuteText(questID)
    --Sometimes TALKINGHEAD_REQUESTED fires before QUEST_ACCEPTED, and we won't be able to mute it
    --Sira Moonwarden's WQ returns wrong type?
    return questID and (IsWorldQuest(questID) or IsQuestTask(questID))
end

function NewTalkingHead:OnEvent(event, ...)
    if self.isEditing then return end;

    if event == "TALKINGHEAD_REQUESTED" then
        self:OnTalkingHeadRequested();
    elseif event == "TALKINGHEAD_CLOSE" then
        --This event will triggered automatically, not closed by the user
        self:OnTalkingHeadClose();
    elseif event == "SOUNDKIT_FINISHED" then
        self:UnregisterEvent(event);
        local voHandle = ...
        if self.voHandle == voHandle then
            self.voHandle = nil;
        end
    elseif event == "LOADING_SCREEN_ENABLED" then
        self:CloseImmediately();
    elseif event == "PLAYER_ENTERING_WORLD" then
        self.inInstance = IsInInstance();
    elseif event == "QUEST_ACCEPTED" then
        local questID = ...
        if ShouldMuteText(questID) then
            self:MuteNextLine();
        end
    elseif event == "QUEST_TURNED_IN" then
        local questID = ...
        if ShouldMuteText(questID) then
            self:MuteNextLine();
        end
    end
end

function NewTalkingHead:OnSettingsChanged()
    if not DB then DB = PlumberDB; end;
    if not DB then return end;

    if DB.TalkingHead_InstantText then
        self.instantText = true;
    else
        self.instantText = false;
    end

    if DB.TalkingHead_HideInInstance then
        self.hideInInstance = true;
    else
        self.hideInInstance = false;
    end

    if DB.TalkingHead_HideWorldQuest then
        self:RegisterEvent("QUEST_ACCEPTED");
        self:RegisterEvent("QUEST_TURNED_IN");
    else
        self:UnregisterEvent("QUEST_ACCEPTED");
        self:UnregisterEvent("QUEST_TURNED_IN");
        self.shouldMuteLine = nil;
    end
end

---- Edit Mode
function NewTalkingHead:EnterEditMode()
    if not self.enabled then return end;

    self:Init();

    if not self.Selection then
        local uiName = "Simple Talking Head";
        local hideLabel = true;
        self.Selection = addon.CreateEditModeSelection(self, uiName, hideLabel);
    end

    self.isEditing = true;
    self:SetScript("OnUpdate", nil);
    FadeFrame(self, 0, 1);
    self.Selection:ShowHighlighted();

    self:ShowExampleText();
end

function NewTalkingHead:ExitEditMode()
    if self.Selection then
        self.Selection:Hide();
    end
    self:ShowOptions(false);
    self.isEditing = false;
    self:CloseImmediately();
end

local function FadeIn_TypeWriter_NoAutoHide_OnUpdate(self, elapsed)
    if FadeIn_TypeWriter_OnUpdate(self, elapsed) then
        self:SetScript("OnUpdate", nil);
    end
end

local function FadeIn_InstantText_NoAutoHide_OnUpdate(self, elapsed)
    if FadeIn_InstantText_OnUpdate(self, elapsed) then
        self:SetScript("OnUpdate", nil);
    end
end

function NewTalkingHead:ShowExampleText(animate)
    local exampleText = format(SPEECH_FORMAT_GENRIC, "The Speaker", "Time is an illusion that helps things make sense. So we are always living in the present tense.");
    self:SetText("               \n"..exampleText);
    self.LineText:SetAlpha(1);

    if animate then
        self.fadingProgress = 0;
        self.t = 0;
        if self.instantText then
            self:SetScript("OnUpdate", FadeIn_InstantText_NoAutoHide_OnUpdate);
        else
            local numChars = strlenutf8(exampleText);
            local voiceoverDuration = 3;
            self.gradientCPS = ceil(numChars / voiceoverDuration) + 10;
            self.fadingProgress = 0;
            self.backgroundFadeDuration = max(voiceoverDuration - 1, 1);
            self.gradientLength = QUEST_DESCRIPTION_GRADIENT_LENGTH;
            self:SetScript("OnUpdate", FadeIn_TypeWriter_NoAutoHide_OnUpdate);
        end
    end
end

function NewTalkingHead:IsFocused()
    return (self:IsShown() and self:IsMouseOver()) or (self.OptionFrame and self.OptionFrame:IsShown() and self.OptionFrame:IsMouseOver())
end


local function Options_FontSizeSlider_OnValueChanged(value)
    NewTalkingHead:SetFontHeightByPercentage(value);
    NewTalkingHead:UpdateFrameSize();
end

local function Options_FontSizeSlider_FormatValue(value)
    return format("%.0f%%", value);
end

local function Options_InstantText_OnClick(self, state)
    NewTalkingHead:OnSettingsChanged();
    NewTalkingHead:ShowExampleText(true);
end

local function Options_TextOutline_OnClick(self, state)
    NewTalkingHead:SetFontHeightByPercentage(DB.TalkingHead_FontSize);
end

local function Options_HideInInstance_OnClick(self, state)
    NewTalkingHead:OnSettingsChanged();
end

local function Options_HideWorldQuest_OnClick(self, state)
    NewTalkingHead:OnSettingsChanged();
end

local function Options_ResetPosition_ShouldEnable(self)
    if DB.TalkingHead_PositionX and DB.TalkingHead_PositionY then
        return true
    else
        return false
    end
end

local function Options_ResetPosition_OnClick(self)
    self:Disable();
    DB.TalkingHead_PositionX = nil;
    DB.TalkingHead_PositionY = nil;
    NewTalkingHead:LoadPosition();
end

local OPTIONS_SCHEMATIC = {
    title = L["EditMode TalkingHead"],
    widgets = {
        {type = "Checkbox", label = L["TalkingHead Option InstantText"], onClickFunc = Options_InstantText_OnClick, dbKey = "TalkingHead_InstantText"},
        {type = "Checkbox", label = L["TalkingHead Option TextOutline"], onClickFunc = Options_TextOutline_OnClick, dbKey = "TalkingHead_TextOutline"},
        {type = "Slider", label = L["Font Size"], minValue = 100, maxValue = 120, valueStep = 10, onValueChangedFunc = Options_FontSizeSlider_OnValueChanged, formatValueFunc = Options_FontSizeSlider_FormatValue,  dbKey = "TalkingHead_FontSize"},

        {type = "Divider"},
        {type = "Header", label = L["TalkingHead Option Condition Header"]};
        {type = "Checkbox", label = L["TalkingHead Option Condition Instance"] , onClickFunc = Options_HideInInstance_OnClick, dbKey = "TalkingHead_HideInInstance", tooltip = L["TalkingHead Option Condition Instance Tooltip"]},
        {type = "Checkbox", label = L["TalkingHead Option Condition WorldQuest"], onClickFunc = Options_HideWorldQuest_OnClick, dbKey = "TalkingHead_HideWorldQuest", tooltip = L["TalkingHead Option Condition WorldQuest Tooltip"]},

        {type = "Divider"},
        {type = "UIPanelButton", label = L["Reset To Default Position"], onClickFunc = Options_ResetPosition_OnClick, stateCheckFunc = Options_ResetPosition_ShouldEnable, widgetKey = "ResetButton"},
    }
};

function NewTalkingHead:CreateOptions()
    self.OptionFrame = addon.SetupSettingsDialog(self, OPTIONS_SCHEMATIC);
end

function NewTalkingHead:ShowOptions(state)
    if state then
        self:CreateOptions();
        self.OptionFrame:Show();
        if self.OptionFrame.requireResetPosition then
            self.OptionFrame.requireResetPosition = false;
            self.OptionFrame:ClearAllPoints();
            self.OptionFrame:SetPoint("LEFT", UIParent, "CENTER", TEXT_WIDTH * 0.5, 0);
        end
    else
        if self.OptionFrame then
            self.OptionFrame:Hide();
        end
        if not API.IsInEditMode() then
            self:CloseImmediately();
        end
    end
end

function NewTalkingHead:ToggleOptions()
    self:ShowOptions( self.OptionFrame and self.OptionFrame:IsShown() );
    NewTalkingHead:EnterEditMode()
end

function NewTalkingHead:OnDragStart()
    self:SetMovable(true);
    self:SetDontSavePosition(true);
    self:SetClampedToScreen(true);
    self:StartMoving();
end

function NewTalkingHead:OnDragStop()
    self:StopMovingOrSizing();

    local centerX = self:GetCenter();
    local uiCenter = UIParent:GetCenter();
    local left = self:GetLeft();
    local top = self:GetTop();

    left = Round(left);
    top = Round(top);

    self:ClearAllPoints();

    --Convert anchor and save position
    if math.abs(uiCenter - centerX) <= 48 then
        --Snap to centeral line
        self:SetPoint("TOP", UIParent, "BOTTOM", 0, top);
        DB.TalkingHead_PositionX = -1;

    else
        self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top);
        DB.TalkingHead_PositionX = left;
    end
    DB.TalkingHead_PositionY = top;

    if self.OptionFrame then
        local button = self.OptionFrame:FindWidget("ResetButton");
        if button then
            button:Enable();
        end
    end
end

function NewTalkingHead:UpdateFrameSize()
    local height = (self.LineText:GetHeight() or 0) + self.fontHeight;
    self:SetHeight(height);
end

local MuteDelay;
local function MuteDelay_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > self.duration then
        self.t = nil;
        self:SetScript("OnUpdate", nil);
        NewTalkingHead.shouldMuteLine = nil;
    end
end

function NewTalkingHead:MuteNextLine(duration)
    --Sound is still played, just no text
    --Doesn't always work when you accept multiple WQ at the same location
    if not MuteDelay then
        MuteDelay = CreateFrame("Frame");
    end
    if (not duration) or duration <= 0.5 then
        duration = 0.5;
    end
    if MuteDelay.t then
        MuteDelay.duration = (MuteDelay.duration or 0) + duration + 0.5;
    else
        MuteDelay.t = 0;
        MuteDelay.duration = duration;
    end
    MuteDelay:SetScript("OnUpdate", MuteDelay_OnUpdate);
    self.shouldMuteLine = true;
end



do
    local function EnableModule(state)
        if state then
            NewTalkingHead:EnableTalkingHead();
        else
            NewTalkingHead:DisableTalkingHead();
        end
    end

    local function OptionToggle_OnClick(self, button)
        if NewTalkingHead.OptionFrame and NewTalkingHead.OptionFrame:IsShown() then
            NewTalkingHead:ShowOptions(false);
            NewTalkingHead:ExitEditMode();
        else
            NewTalkingHead:EnterEditMode();
            NewTalkingHead:ShowOptions(true);
        end
    end

    local moduleData = {
        name = addon.L["ModuleName TalkingHead"],
        dbKey = "TalkingHead_MasterSwitch",
        description = addon.L["ModuleDescription TalkingHead"],
        toggleFunc = EnableModule,
        categoryID = 2,
        uiOrder = 3,
        moduleAddedTime = 1704423300,
        optionToggleFunc = OptionToggle_OnClick,
    };

    addon.ControlCenter:AddModule(moduleData);
end