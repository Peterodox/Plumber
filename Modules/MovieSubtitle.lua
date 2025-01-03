-- Unused Module

-- Adjust Subtitle Font size, position, etc.
-- "MovieSubtitleFont" is also used by LossOfControlFrame, so we don't modify this FontObject
-- Instead, we SetFont on SubtitlesFrame.Subtitles (type: table) (Currently only one entry "Subtitle1")

-- Default Height: 22, (25 zhCN)

local DEFAULT_SPACING = 0;
local DEFAULT_COLOR = {1, 0.82, 0};
local DEFAULT_FONTSTRING_HEIGHT = 138;


local _, addon = ...
local CUSTOM_FONT_HEIGHT = 16;


local EL = CreateFrame("Frame");

function EL:EnableModule(state)
    if state then
        if (not self.enabled) and (MovieSubtitleFont and SubtitlesFrame and SubtitlesFrame.Subtitles) then
            self.enabled = true;
            if not self.originalFontInfo then
                self.originalFontInfo = {MovieSubtitleFont:GetFont()};
            end
            self:SetFontHeight(CUSTOM_FONT_HEIGHT);
            self:SetFontColor(1, 1, 1);
            self:SetFontSpacing(4);
        end
    else
        if self.enabled then
            self.enabled = nil;
            if self.originalFontInfo then
                self:SubtitleSetFont(self.originalFontInfo[1], self.originalFontInfo[2], self.originalFontInfo[3]);
                self:SetFontColor(DEFAULT_COLOR[1], DEFAULT_COLOR[2], DEFAULT_COLOR[3]);
                self:SetFontSpacing(DEFAULT_SPACING);
                self:SetFontStringHeight(DEFAULT_FONTSTRING_HEIGHT);
            end
        end
    end
end

function EL:ModifySubtitles(method, ...)
    for _, fontString in ipairs(SubtitlesFrame.Subtitles) do
        fontString[method](fontString, ...)
    end
end

function EL:SetFontColor(r, g, b)
    self:ModifySubtitles("SetTextColor", r, g, b);
end

function EL:SetFontSpacing(spacing)
    self:ModifySubtitles("SetSpacing", spacing);
end

function EL:SubtitleSetFont(font, height, flags)
    self:ModifySubtitles("SetFont", font, height, flags);
end

function EL:SetFontStringHeight(height)
    --height is the black bar's height
    self:ModifySubtitles("SetHeight", height);
end

function EL:SetFontHeight(height)
    if height < 10 then
        height = 10;
    end
    self:SubtitleSetFont(self.originalFontInfo[1], height, self.customFlag or self.originalFontInfo[3]);
    self.customHeight = height;
end

function EL:SubtitleSetFlags(flags)
    if not flags then
        flags = "";
    end
    self:SubtitleSetFont(self.originalFontInfo[1], self.customHeight or self.originalFontInfo[2], flags);
    self.customFlag = flags;
end

function EL:ShowBlackBar(state)
    if state then
        local DefaultAspectRatio = {x = 16, y = 9};
        local width = CinematicFrame:GetWidth();
        local height = CinematicFrame:GetHeight();
        local viewableHeight = width * DefaultAspectRatio.y / DefaultAspectRatio.x;
        local blackBarHeight = math.floor((height - viewableHeight) / 2.0);
        
        if blackBarHeight < 40 then
            blackBarHeight = 40;
        end

        if blackBarHeight > 0 then
            if not self.LowerBlackBar then
                self.LowerBlackBar = self:CreateTexture(nil, "BACKGROUND");
                self.LowerBlackBar:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", 0, 0);
                self.LowerBlackBar:SetPoint("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, 0);
                self.LowerBlackBar:SetColorTexture(0, 0, 0);
            end
            self.LowerBlackBar:SetHeight(blackBarHeight);
            self.LowerBlackBar:Show();

            self:SetFontStringHeight(blackBarHeight);
            SubtitlesFrame:AddSubtitle("This is the subtitle.")
            SubtitlesFrame:Show();
        end
    else
        if self.LowerBlackBar then
            self.LowerBlackBar:Hide();
        end
    end
end


function EL:OnEvent(event, ...)
    if event == "SHOW_SUBTITLE" then
        
    end
end

--[[
C_Timer.After(0, function()
    EL:EnableModule(true);
end)
--]]