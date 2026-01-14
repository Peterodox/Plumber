local _, addon = ...
local L = addon.L;
local API = addon.API;


local CreateKeyChordStringUsingMetaKeyState = CreateKeyChordStringUsingMetaKeyState;


local MainFrame;


local StaticPopupMixin = {};
do
    function StaticPopupMixin:Close()
        self:Hide();
    end

    function StaticPopupMixin:FindBestPosition()
        self:ClearAllPoints();
        self:SetPoint("TOP", UIParent, "TOP", 0, -135);
    end

    function StaticPopupMixin:Layout()
        local frameWidth = 320;
        local padding = 32;
        local spacing = 8;

        local offsetY = padding;
        local widgetWidth = frameWidth - 2 * padding;

        self.Text:ClearAllPoints();
        self.Text:SetPoint("TOP", self, "TOP", 0, -offsetY);
        self.Text:SetWidth(widgetWidth);
        offsetY = offsetY + math.ceil(self.Text:GetHeight() or 12);

        if self.EditBox:IsShown() then
            self.EditBox:ClearAllPoints();
            self.EditBox:SetWidth(widgetWidth);
            offsetY = offsetY + spacing;
            self.EditBox:SetPoint("TOP", self, "TOP", 0, -offsetY);
            offsetY = offsetY + 24;
        end

        offsetY = offsetY + padding;
        self:SetSize(frameWidth, offsetY);
    end

    function StaticPopupMixin:OnShow()
        API.AddFrameToUISpecialFrames(self, true);
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
    end

    function StaticPopupMixin:OnHide()
        API.AddFrameToUISpecialFrames(self, false);
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
    end

    function StaticPopupMixin:OnLoad()
        self.OnLoad = nil;

        self.CloseButton:SetScript("OnClick", function()
            self:Close();
        end);

        local EditBoxBorder = addon.CreateNineSliceFrame(self.EditBox, "NineSlice_GenericBox_Border");
        self.EditBoxBorder = EditBoxBorder;
        EditBoxBorder:CoverParent(-2);
        EditBoxBorder:SetCornerSizeByScale(0.5);
        EditBoxBorder:SetUsingParentLevel(true);
        EditBoxBorder:SetColor(0.5, 0.5, 0.5);

        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);
    end

    local function KeyListener_OnKeyDown(self, key)
        local keys = CreateKeyChordStringUsingMetaKeyState(key);
        if (keys == "CTRL-C" or key == "COMMAND-C") and MainFrame.EditBox:HasFocus() then
            self:SetScript("OnKeyDown", nil);
            MainFrame:OnCopySuccess();
        end
    end

    function StaticPopupMixin:ListenHotkey(state)
        if state then
            self.KeyListener:SetScript("OnKeyDown", KeyListener_OnKeyDown);
        else
            self.KeyListener:SetScript("OnKeyDown", nil);
        end
    end

    function StaticPopupMixin:OnCopySuccess()
        if not self.copySuccess then
            self.copySuccess = true;
            C_Timer.After(0, function()
                self.copySuccess = nil;
                self:Close();
                UIErrorsFrame:AddMessage(TRANSMOG_OUTFIT_COPY_TO_CLIPBOARD_NOTICE, 124/255, 197/255, 118/255, 1.0, 0);
            end);
        end
    end
end


local EditBoxMixin = {};
do
    function EditBoxMixin:OnEnter()
        self:UpdateVisual();
    end

    function EditBoxMixin:OnLeave()
        self:UpdateVisual();
    end

    function EditBoxMixin:OnShow()
        self:SetFocus();
    end

    function EditBoxMixin:UpdateVisual()
        local a;
        if self:HasFocus() then
            a = 0.8;
        elseif self:IsMouseMotionFocus() then
            a = 0.6;
        else
            a = 0.4;
        end
        MainFrame.EditBoxBorder:SetColor(a, a, a);
    end

    function EditBoxMixin:OnEditFocusGained()
        self:HighlightText();
        self:UpdateVisual();
    end

    function EditBoxMixin:OnEditFocusLost()
        self:UpdateVisual();
        if self.defaultText then
            self:SetText(self.defaultText);
        end
        self:ClearHighlightText();
    end

    function EditBoxMixin:OnTextChanged(userInput)
        if userInput then
            self:ClearFocus();
        end
    end

    function EditBoxMixin:OnEscapePressed()
        self:ClearFocus();
        if C_Transmog.IsAtTransmogNPC() then
            MainFrame:Close();
        end
    end

    function EditBoxMixin:OnCursorChanged()
        if self:HasFocus() then
            self:HighlightText();
        end
    end

    function EditBoxMixin:SetDefaultText(text)
        self.defaultText = text;
        self:SetText(text);
        self:SetCursorPosition(0);
    end

    function EditBoxMixin:OnLoad()
        self.OnLoad = nil;

        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnEditFocusGained", self.OnEditFocusGained);
        self:SetScript("OnEditFocusLost", self.OnEditFocusLost);
        self:SetScript("OnTextChanged", self.OnTextChanged);
        self:SetScript("OnEscapePressed", self.OnEscapePressed);
        self:SetScript("OnCursorChanged", self.OnCursorChanged);
    end
end


local function CreatePopup()
    if MainFrame then return end;

    MainFrame = CreateFrame("Frame", "PlumberSharedStaticPopup", UIParent, "PlumberSharedPopupFrameTemplate");
    Mixin(MainFrame, StaticPopupMixin);
    MainFrame:OnLoad();

    Mixin(MainFrame.EditBox, EditBoxMixin);
    MainFrame.EditBox:OnLoad();
end


local function ShowClipboard(text)
    CreatePopup();
    MainFrame:FindBestPosition();
    MainFrame.EditBox:Show();
    MainFrame.EditBox:SetDefaultText(text);
    local hotkey;
    if IsMacClient and IsMacClient() then
        hotkey = "Command+C";
    else
        hotkey = "Ctrl+C";
    end
    MainFrame.Text:SetText(L["Press Key To Copy Format"]:format(hotkey));
    MainFrame.Text:SetTextColor(0.6, 0.6, 0.6);
    MainFrame:Layout();
    MainFrame:ListenHotkey(true);
    MainFrame:Show();
    MainFrame.EditBox:SetFocus();
end
addon.ShowClipboard = ShowClipboard;