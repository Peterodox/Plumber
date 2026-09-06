local _, addon = ...
local L = addon.L;
local API = addon.API;


local CreateKeyChordStringUsingMetaKeyState = CreateKeyChordStringUsingMetaKeyState;


local MainFrame;


local WHICH_DUMMY = "PLUMBER_SHARED_POPUP_CONTAINER";

local SharedDialogInfo = {
	text = "",
	hideOnEscape = true,
	--OnHide = function(dialog, data)
		-- InsertedFrame is released by StaticPopup_OnHide, but the dialog is still shown
		-- Hide the dialog otherwise it will be a blank window
	--	StaticPopup_Hide(WHICH_DUMMY, data)
	--end,
};


local StaticPopupMixin = {};
do
	function StaticPopupMixin:Close()
		self:Hide();
	end

	function StaticPopupMixin:Layout()
		local widgetWidth = 240;
		local sidePadding = 8;
		local offsetY = sidePadding;

		self.Text:ClearAllPoints();
		self.Text:SetPoint("TOP", self, "TOP", 0, -offsetY);
		self.Text:SetWidth(widgetWidth);
		offsetY = offsetY + math.ceil(self.Text:GetHeight() or 12);

		if self.EditBox:IsShown() then
			self.EditBox:ClearAllPoints();
			self.EditBox:SetWidth(widgetWidth);
			offsetY = offsetY + 8;
			self.EditBox:SetPoint("TOP", self, "TOP", 0, -offsetY);
			offsetY = offsetY + 24;
		end

		-- Widgets like checkbox are vertically aligned
		if self.topWidget and self.widgetSpanY then
			offsetY = offsetY + 16;
			self.topWidget:ClearAllPoints();
			self.topWidget:SetPoint("TOP", self, "TOP", 0, -offsetY);
			offsetY = offsetY + self.widgetSpanY;
		end

		-- Red buttons like Confirm/Cancel are horizontally aligned
		if self.firstButton and self.buttonSpanX then
			offsetY = offsetY + 16;
			widgetWidth = math.max(widgetWidth, self.buttonSpanX);
			self.firstButton:ClearAllPoints();
			self.firstButton:SetPoint("TOPLEFT", self, "TOP", -0.5 * self.buttonSpanX, -offsetY);
			offsetY = offsetY + self.firstButton:GetHeight();
		end

		local opticalPaddingH = 32;
		self:SetSize(widgetWidth + opticalPaddingH + 2 * sidePadding, offsetY + sidePadding);
	end

	function StaticPopupMixin:OnShow()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
	end

	function StaticPopupMixin:OnHide()
		PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
		StaticPopup_Hide(WHICH_DUMMY, self.data);
	end

	function StaticPopupMixin:OnLoad()
		self.OnLoad = nil;
		self:SetScript("OnLoad", nil);

		local EditBoxBorder = addon.CreateNineSliceFrame(self.EditBox, "NineSlice_GenericBox_Border");
		self.EditBoxBorder = EditBoxBorder;
		EditBoxBorder:CoverParent(-2);
		EditBoxBorder:SetCornerSizeByScale(0.5);
		EditBoxBorder:SetUsingParentLevel(true);
		EditBoxBorder:SetColor(0.5, 0.5, 0.5);


		local function CreateCheckbox()
			return addon.CreateCheckbox(self);
		end
		self.checkboxPool = API.CreateObjectPool(CreateCheckbox);

		local function UIPanelButton_OnEnter(f)
			if f.onEnterCallback then
				f.onEnterCallback(f);
			end
		end

		local function UIPanelButton_OnLeave(f)
			GameTooltip:Hide();
			if f.onLeaveCallback then
				f.onLeaveCallback(f);
			end
		end

		local function CreateUIPanelButton()
			local f = CreateFrame("Button", nil, self, "UIPanelButtonTemplate");
			f:SetScript("OnEnter", UIPanelButton_OnEnter);
			f:SetScript("OnLeave", UIPanelButton_OnLeave);
			return f;
		end
		self.uiPanelButtonPool = API.CreateObjectPool(CreateUIPanelButton);

		self:SetScript("OnShow", self.OnShow);
		self:SetScript("OnHide", self.OnHide);
	end

	function StaticPopupMixin:ReleaseAllWidgets()
		self.firstButton = nil;
		self.buttonSpanX = nil;
		self.topWidget = nil;
		self.widgetSpanY = nil;
		self.Text:Hide();
		self.EditBox:Hide();
		self.checkboxPool:ReleaseAll();
		self.uiPanelButtonPool:ReleaseAll();
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
				if self.copySuccessMessage then
					UIErrorsFrame:AddMessage(self.copySuccessMessage, 124/255, 197/255, 118/255, 1.0, 0);
				end
			end);
		end
	end

	function StaticPopupMixin:Setup(popupInfo)
		self:ReleaseAllWidgets();

		if popupInfo.text then
			self.Text:SetTextColor(1, 1, 1);
			self.Text:SetText(popupInfo.text);
			self.Text:Show();
		end

		if popupInfo.buttons then
			local firstButton, lastButton;
			local buttonSpanX = 0;
			local gap = 10;

			for _, v in ipairs(popupInfo.buttons) do
				local button = self.uiPanelButtonPool:Acquire();
				button:SetWidth(120);
				button:SetText(v.label);
				button.onEnterFunc = v.onEnterFunc;
				button.onLeaveFunc = v.onLeaveFunc;

				button.onEnterCallback = function(f)
					if v.tooltip then
						GameTooltip:SetOwner(f, "ANCHOR_RIGHT", -4, 0);
						if v.tooltipTitle then
							GameTooltip:SetText(v.tooltipTitle, 1, 1, 1, 1, true);
							if type(self.tooltip) == "function" then
								f:AddLine(self.tooltip(), 1, 0.82, 0, true);
							else
								f:AddLine(self.tooltip, 1, 0.82, 0, true);
							end
						else
							GameTooltip:SetText(v.tooltip, 1, 1, 1, 1, true);
						end
					end

					if v.onEnterFunc then
						v.onEnterFunc(f);
					end
				end

				button.onLeaveCallback = v.onLeaveFunc;

				if v.onClickFunc then
					button:SetScript("OnClick", function(f, mouseButton)
						v.onClickFunc(f, mouseButton);
						if v.closePopup then
							self:Hide();
						end
					end);
				elseif v.closePopup then
					button:SetScript("OnClick", function()
						self:Hide();
					end);
				else
					button:SetScript("OnClick", nil);
				end

				if not firstButton then
					firstButton = button;
					buttonSpanX = button:GetWidth();
				else
					buttonSpanX = buttonSpanX + gap + button:GetWidth();
					button:SetPoint("LEFT", lastButton, "RIGHT", gap, 0);
				end

				lastButton = button;
			end

			self.firstButton = firstButton;
			self.buttonSpanX = buttonSpanX;
		end

		if popupInfo.widgets then
			local topWidget, bottomWidget;
			local widgetSpanY = 0;
			local gap = 16;

			for _, v in ipairs(popupInfo.widgets) do
				local widget;
				if v.type == "checkbox" then
					widget = self.checkboxPool:Acquire();
					widget:SetData(
						{
							label = v.label,
							tooltip = v.tooltip,
							dbKey = v.dbKey,
							onClickFunc = v.onClickFunc;
							onEnterFunc = v.onEnterFunc;
							onLeaveFunc = v.onLeaveFunc;
						}
					);
				end

				if widget then
					if not topWidget then
						topWidget = widget;
						widgetSpanY = widget:GetHeight();
					else
						widget:SetPoint("TOP", bottomWidget, "BOTTOM", 0, -gap);
						widgetSpanY = widgetSpanY + gap + widget:GetHeight();
					end
					bottomWidget = widget;
				end
			end

			self.topWidget = topWidget;
			self.widgetSpanY = widgetSpanY;
		end

		self:Layout();
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
	if MainFrame then return; end

	MainFrame = CreateFrame("Frame", nil, UIParent, "PlumberSharedPopupFrameTemplate");
	Mixin(MainFrame, StaticPopupMixin);
	MainFrame:Hide();
	MainFrame:OnLoad();

	Mixin(MainFrame.EditBox, EditBoxMixin);
	MainFrame.EditBox:OnLoad();

	StaticPopupDialogs[WHICH_DUMMY] = SharedDialogInfo;

	--[[ -- This one taints, so we instead add our frame as an InsertedFrame in WoW StaticPopup
	RegisterGameMenuEscHandler(GameMenuEscPriority.Dialog, function()
		if MainFrame:IsShown() then
			MainFrame:Hide();
			return true;
		end
	end);
	--]]
end


local function ShowClipboard(text, copySuccessMessage)
	CreatePopup();

	MainFrame:ClearAllPoints();
	MainFrame:ReleaseAllWidgets();

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
	MainFrame.Text:Show();

	MainFrame:Layout();
	MainFrame:ListenHotkey(true);
	MainFrame:Show();

	SharedDialogInfo.closeButton = true;
	SharedDialogInfo.closeButtonIsHide = true;

	StaticPopup_Show(WHICH_DUMMY, nil, nil, nil, MainFrame);

	MainFrame.copySuccessMessage = copySuccessMessage;
	MainFrame.EditBox:SetFocus();
end
addon.ShowClipboard = ShowClipboard;


local function ShowCustomPopup(popupInfo)
	CreatePopup();

	MainFrame:ClearAllPoints();
	MainFrame:Setup(popupInfo);
	MainFrame:ListenHotkey(false);
	MainFrame:Show();

	SharedDialogInfo.closeButton = nil;
	SharedDialogInfo.closeButtonIsHide = nil;

	StaticPopup_Show(WHICH_DUMMY, nil, nil, nil, MainFrame);
end
addon.ShowCustomPopup = ShowCustomPopup;
