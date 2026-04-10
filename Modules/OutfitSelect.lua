local _, addon = ...
local L = addon.L;
local API = addon.API;
local SetSpellCooldown = addon.CooldownUtil.SetSpellCooldown;


local Def = {
	MainKeys = {
		"HelpPlateButton", "CharacterPreview", "WardrobeCollection", "Bg",
	},

	ChildKeys = {
		"SaveOutfitButton", "MoneyFrame", "PurchaseOutfitButton", "DividerBar",
	},

	OutfitCollection = {
		MaximizedHeight = 860,
		MinimizedHeight = 776,
		BackgroundAlpha = 0.6,
	},

	MainFrame = {
		MaximizedWidth = 1618,
		MaximizedHeight = 883,

		MinimizedWidth = 314,
		MinimizedHeight = 800,
	},

	ClickHandlerName = "PLMR_OUTFIT",
	MacroIcon = 2869702,
	PlumberMacroCommand = "outfit",

	DefaultOffsetX = -480,
	DefaultOffsetY = 0,

	FrameName = "PlumberOutfitSelectFrame",

	OutfitEntry = {
		IconButtonWidth = 36,
		TextButtonWidth = 192,
		IconTextGap = 8,
		FrameGap = 12,
	},

	TextureFile = "Interface/AddOns/Plumber/Art/Frame/TransmogUI.png",

	equipOutfitSpellID = Constants.TransmogOutfitDataConsts.EQUIP_TRANSMOG_OUTFIT_MANUAL_SPELL_ID,

	SecureButttonPrivateKey = "EquipOutfit",
};


local EL = CreateFrame("Frame");
local Mod = {};
local AcquireOutfitMacro;
local ClickHandler;
local ExtraFrame;
local CreateExtraFrame;
local RepositionFrame;
local CreateRepositionFrame;


local IS_12_0_5 = C_TransmogOutfitInfo.ChangeToOutfit ~= nil;
local ToggleOutfitSelectFrame;	--For 12.0.5+


do  -- DragButton On TransmogFrame
	local DragButton;

	local DragButtonMixin = {};

	function DragButtonMixin:OnEnter()
		self.Text:SetTextColor(1, 1, 1);

		local tooltip = GameTooltip;
		tooltip:SetOwner(self.Text, "ANCHOR_RIGHT", 6, 0);
		tooltip:SetText(L["Quick Access Outfit Button"], 1, 1, 1);
		tooltip:AddLine(L["Quick Access Outfit Button Tooltip"], 1, 0.82, 0, true);

		if not addon.CanPickupOrCreateCommand("outfit") then
			tooltip:AddLine(" ");
			tooltip:AddLine(L["No Slot For New Character Macro Alert"], 1, 0.125, 0.125, true);
		end

		tooltip:Show();
	end

	function DragButtonMixin:OnLeave()
		GameTooltip:Hide();
		self.Text:SetTextColor(1, 0.82, 0);
	end

	function DragButtonMixin:SetIconAndText(icon, text)
		local iconSize = 16;
		local gap = 6;

		self.Icon:SetSize(iconSize, iconSize);
		self.Text:ClearAllPoints();
		self.Text:SetPoint("LEFT", self.Icon, "RIGHT", gap, 0);

		self.Icon:SetTexture(icon);
		self.Text:SetText(text);

		local contentWidth = API.Round(iconSize + gap + self.Text:GetWrappedWidth());
		local buttonWidth = math.max(240, contentWidth);
		self:SetWidth(buttonWidth);
		self.Icon:SetPoint("LEFT", self, "LEFT", 0.5*(buttonWidth - contentWidth), 0);
	end

	function DragButtonMixin:OnDragStart()
		if API.CheckAndDisplayErrorIfInCombat() then
			return
		end

		local macroID = AcquireOutfitMacro();
		if macroID then
			PickupMacro(macroID);
		end
	end

	function CreateExtraFrame(parent)
		local f = CreateFrame("Frame", nil, parent);
		ExtraFrame = f;
		f:SetSize(308, 34);
		f:SetFrameLevel(128);

		local alpha = 0.5;

		local Left = f:CreateTexture(nil, "OVERLAY");
		Left:SetSize(40, 12);
		Left:SetTexture(Def.TextureFile);
		Left:SetTexCoord(0, 80/512, 0, 24/512);
		Left:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0);

		local Right = f:CreateTexture(nil, "OVERLAY");
		Right:SetSize(40, 12);
		Right:SetTexture(Def.TextureFile);
		Right:SetTexCoord(160/512, 240/512, 0, 24/512);
		Right:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);

		local Center = f:CreateTexture(nil, "OVERLAY");
		Center:SetSize(40, 12);
		Center:SetTexture(Def.TextureFile);
		Center:SetTexCoord(80/512, 160/512, 0, 24/512);
		Center:SetPoint("TOPLEFT", Left, "TOPRIGHT", 0, 0);
		Center:SetPoint("BOTTOMRIGHT", Right, "BOTTOMLEFT", 0, 0);

		API.DisableSharpening(Left);
		API.DisableSharpening(Right);
		API.DisableSharpening(Center);

		Left:SetAlpha(alpha);
		Right:SetAlpha(alpha);
		Center:SetAlpha(alpha);


		DragButton = CreateFrame("Button", nil, f);
		DragButton:SetSize(240, 30);
		DragButton:SetPoint("CENTER", f, "CENTER", 16, 0);
		DragButton.Icon = DragButton:CreateTexture(nil, "OVERLAY");
		DragButton.Text = DragButton:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		Mixin(DragButton, DragButtonMixin);
		DragButton:SetIconAndText(Def.MacroIcon, L["Quick Access Outfit Button"]);
		DragButton:SetScript("OnEnter", DragButton.OnEnter);
		DragButton:SetScript("OnLeave", DragButton.OnLeave);
		DragButton:SetScript("OnDragStart", DragButton.OnDragStart);
		DragButton:RegisterForDrag("LeftButton");

		f:SetPoint("TOPLEFT", TransmogFrame, "TOPLEFT", 4, -21);
	end
end


do  -- Drag to repostion TransmogFrame (For Minimized Mode)
	local RepositionFrameMixin = {};

	function RepositionFrameMixin:OnDragStart()
		if InCombatLockdown() then return end;

		self.isDragging = true;
		self:RegisterEvent("PLAYER_REGEN_DISABLED");
		self:SetScript("OnEvent", self.OnEvent);

		if self.isFrameMovable == nil then
			self.isFrameMovable = TransmogFrame:IsMovable();
		end

		TransmogFrame:SetClampedToScreen(true);
		TransmogFrame:SetMovable(true);
		TransmogFrame:StartMoving(true);
	end

	function RepositionFrameMixin:OnDragStop()
		self:StopDragging();
	end

	function RepositionFrameMixin:OnHide()
		self:Hide();
		if self.isDragging then
			self:StopDragging();
		end
	end

	function RepositionFrameMixin:StopDragging()
		self.isDragging = nil;
		self:UnregisterEvent("PLAYER_REGEN_DISABLED");
		self:SetScript("OnEvent", nil);
		TransmogFrame:SetMovable(self.isFrameMovable);

		if not InCombatLockdown() then
			TransmogFrame:StopMovingOrSizing();
			local x0, y0 = UIParent:GetCenter();
			local x1, y1 = TransmogFrame:GetCenter();
			if x0 and y0 and x1 and y1 then
				local x = API.Round(x1 - x0);
				local y = API.Round(y1 - y0);
				ClickHandler:SetFramePosition(x, y);
				PlumberDB.TransmogOutfitSelect_Position = {x, y};
			end
		end
	end

	function RepositionFrameMixin:OnEvent()
		self:StopDragging();
	end

	function RepositionFrameMixin:OnEnter()
		if not InCombatLockdown() then
			SetCursor("Interface/CURSOR/UI-Cursor-Move.blp");
		end
	end

	function RepositionFrameMixin:OnLeave()
		ResetCursor();
	end

	function CreateRepositionFrame(parent)
		local f = CreateFrame("Button", nil, parent);
		RepositionFrame = f;

		f:SetSize(Def.MainFrame.MinimizedWidth - 48, 24);
		f:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0);
		f:SetFrameLevel(parent.NineSlice:GetFrameLevel() + 1);

		Mixin(f, RepositionFrameMixin);
		f:SetScript("OnDragStart", f.OnDragStart);
		f:SetScript("OnDragStop", f.OnDragStop);
		f:SetScript("OnHide", f.OnHide);
		f:SetScript("OnEnter", f.OnEnter);
		f:SetScript("OnLeave", f.OnLeave);
		f:RegisterForDrag("LeftButton");
	end
end


do  -- Outfit Macro    #plumber:outfit
	local function WriteFunc_outfit(body)
		local header = "#plumber:"..Def.PlumberMacroCommand;
		local icon = Def.MacroIcon;
		local macro = "/click "..Def.ClickHandlerName;
		body = header.."\n"..macro;
		return body, icon
	end

	local function Generator_outfit()
		local name = L["Outfit Collection"];
		local body, icon = WriteFunc_outfit();
		if not body then
			body = "#plumber:"..Def.PlumberMacroCommand;
			icon = Def.MacroIcon;
		end
		return name, icon, body
	end

	function AcquireOutfitMacro()
		return addon.AcquireCharacterMacro(Def.PlumberMacroCommand, Generator_outfit);
	end

	local OutfitCommand = {
		command = Def.PlumberMacroCommand,
		name = L["PlumberMacro Outfit"],
		modifyType = "Overwrite",
		writeFunc = WriteFunc_outfit,
	};

	addon.AddPlumberMacro(OutfitCommand);
end


do  -- Blizzard Frame Modification
	local function SetWidgetShown(state)
		local f = TransmogFrame;

		for _, key in ipairs(Def.MainKeys) do
			f[key]:SetShown(state);
		end

		for _, key in ipairs(Def.ChildKeys) do
			f.OutfitCollection[key]:SetShown(state);
		end
	end

	function Mod.Transmog_OnLoad()
		if Mod.loaded then return end;
		Mod.loaded = true;

		TransmogFrame:HookScript("OnShow", Mod.SwitchMode);
		if TransmogFrame:IsShown() then
			Mod.SwitchMode();
		end
	end

	function Mod.MinimizeTransmogUI()
		SetWidgetShown(false);
		TransmogFrame.OutfitCollection.Background:SetAlpha(Def.OutfitCollection.BackgroundAlpha);
		TransmogFrame.OutfitCollection:SetHeight(Def.OutfitCollection.MinimizedHeight);
		TransmogFrame:SetSize(Def.MainFrame.MinimizedWidth, Def.MainFrame.MinimizedHeight);

		if not InCombatLockdown() then
			TransmogFrame:SetClampedToScreen(true);
		end

		if ExtraFrame then
			ExtraFrame:Hide();
		end

		if not RepositionFrame then
			CreateRepositionFrame(TransmogFrame);
		end
		RepositionFrame:Show();

		EL:ListenEvents(true);
	end

	function Mod.MaximizeTransmogUI()
		SetWidgetShown(true);
		TransmogFrame.OutfitCollection.Background:SetAlpha(1);
		TransmogFrame.OutfitCollection:SetHeight(Def.OutfitCollection.MaximizedHeight);
		TransmogFrame:SetSize(Def.MainFrame.MaximizedWidth, Def.MainFrame.MaximizedHeight);

		if not ExtraFrame then
			CreateExtraFrame(TransmogFrame);
		end
		ExtraFrame:Show();

		if RepositionFrame then
			RepositionFrame:Hide();
		end

		EL:ListenEvents(false);
	end

	function Mod.SwitchMode()
		if C_Transmog.IsAtTransmogNPC() then
			Mod.MaximizeTransmogUI();
		else
			Mod.MinimizeTransmogUI();
		end
	end
end


do  --SecureHandler
	ClickHandler = CreateFrame("Button", Def.ClickHandlerName, nil, "SecureHandlerClickTemplate");
	ClickHandler:RegisterForClicks("AnyUp");
	ClickHandler:SetFrameRef("UIParent", UIParent);
	ClickHandler:SetSize(1, 1);

	local HANDLER_ONCLICK = [=[
		local frame = self:GetFrameRef("TransmogFrame");
		if not frame then return end;

		local show = (not frame:IsShown()) and not PlayerInCombat();
		if show then
			local UIParent = self:GetFrameRef("UIParent");
			frame:ClearAllPoints();
			frame:SetPoint("CENTER", UIParent, "CENTER", %d, %d);
			frame:Show();
		else
			frame:Hide();
		end
	]=];

	function ClickHandler:SetFramePosition(x, y)
		if type(x) == "number" and type(y) == "number" then
			self:SetAttribute("_onclick", HANDLER_ONCLICK:format(x, y));
		end
	end

	ClickHandler:SetFramePosition(Def.DefaultOffsetX, Def.DefaultOffsetY);

	ClickHandler:SetScript("PreClick", function(self)
		if API.CheckAndDisplayErrorIfInCombat() then
			return
		end

		if IS_12_0_5 then
			ToggleOutfitSelectFrame();
			return;
		end

		if not TransmogFrame then
			Transmog_LoadUI();
		end

		if TransmogFrame then
			Mod.Transmog_OnLoad();

			self:SetScript("PreClick", function()
				if API.CheckAndDisplayErrorIfInCombat() then
					return
				end
			end);

			self:SetFrameRef("TransmogFrame", TransmogFrame);
		end
	end);

	function ClickHandler:InitializePosition()
		local db = PlumberDB.TransmogOutfitSelect_Position;
		if db and db[1] and db[2] then
			ClickHandler:SetFramePosition(db[1], db[2]);
		end
	end

	ClickHandler:SetScript("OnEvent", function(self, event)
		--Load Initial Position
		if event == "PLAYER_ENTERING_WORLD" then
			self:UnregisterEvent(event);
			if InCombatLockdown() then
				self:RegisterEvent("PLAYER_REGEN_ENABLED");
			else
				self:SetScript("OnEvent", nil);
				self:InitializePosition();
			end
		elseif event == "PLAYER_REGEN_ENABLED" then
			self:UnregisterEvent(event);
			self:SetScript("OnEvent", nil);
			self:InitializePosition();
		end
	end);

	ClickHandler:RegisterEvent("PLAYER_ENTERING_WORLD");
end


do  --EL Event Listener
	function EL:OnEvent(event, ...)
		if event == "PLAYER_REGEN_DISABLED" then
			self:ListenEvents(false);
			if TransmogFrame then
				TransmogFrame:Hide();
			end
		end
	end

	function EL:OnKeyDown(key)
		if InCombatLockdown() then
			self:ListenEvents(false);
			return
		end

		local valid;
		if key == "ESCAPE" then
			valid = true;
			self:ListenEvents(false);
			if TransmogFrame then
				TransmogFrame:Hide();
			end
		end

		self:SetPropagateKeyboardInput(not valid);
	end

	function EL:ListenEvents(state)
		if state then
			self:RegisterEvent("PLAYER_REGEN_DISABLED");
			self:SetScript("OnEvent", self.OnEvent);
			self:SetScript("OnKeyDown", self.OnKeyDown);
		else
			self:UnregisterEvent("PLAYER_REGEN_DISABLED");
			self:SetScript("OnEvent", nil);
			self:SetScript("OnKeyDown", nil);
		end
	end
end


do	--OutfitEntryMixin
	PlumberOutfitSelectOutfitEntryMixin = {};

	function PlumberOutfitSelectOutfitEntryMixin:OnLoad()
		self.Icon = self.IconButton.Icon;
		self.Border = self.IconButton.Border;
		self.BorderHighlight = self.IconButton.BorderHighlight;
		self.Background = self.TextButton.Background;
		self.Name = self.TextButton.Name;

		if not Def.OutfitEntryWidth then
			Def.OutfitEntryWidth = 	Def.OutfitEntry.IconButtonWidth + Def.OutfitEntry.IconTextGap + Def.OutfitEntry.TextButtonWidth;
		end
		self:SetWidth(Def.OutfitEntryWidth);

		self.Border:SetTexture(Def.TextureFile);
		self.Border:SetTexCoord(0, 96/512, 32/512, 128/512);
		self.BorderHighlight:SetTexture(Def.TextureFile);
		self.BorderHighlight:SetTexCoord(0, 96/512, 32/512, 128/512);

		self.Background:SetTexture(Def.TextureFile);
		self.Background:SetTexCoord(96/512, 1, 32/512, 128/512);

		self.IconButton:SetScript("OnDragStart", function()
			self:PickupOutfit();
		end);

		self.IconButton:SetScript("OnEnter", function()
			self:ShowTooltip();
			self:SetupActionButton();
		end);

		self.IconButton:SetScript("OnLeave", function()
			GameTooltip:Hide();
		end);

		self.IconButton.Cooldown:SetHideCountdownNumbers(true);
	end

	function PlumberOutfitSelectOutfitEntryMixin:OnShow()
		self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
		self:UpdateCooldown();
	end

	function PlumberOutfitSelectOutfitEntryMixin:OnHide()
		self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	end

	function PlumberOutfitSelectOutfitEntryMixin:OnEvent()
		self:UpdateCooldown();
	end

	function PlumberOutfitSelectOutfitEntryMixin:SetActive(selected)
		self.selected = selected;
		if selected then
			self.Border:SetTexCoord(0, 96/512, 128/512, 224/512);
			self.Background:SetTexCoord(96/512, 1, 128/512, 224/512);
			--self.BorderHighlight:SetAlpha(0);
			self.Name:SetTextColor(1, 1, 1);
		else
			self.Border:SetTexCoord(0, 96/512, 32/512, 128/512);
			self.Background:SetTexCoord(96/512, 1, 32/512, 128/512);
			--self.BorderHighlight:SetAlpha(1);
			self.Name:SetTextColor(1, 0.82, 0);
		end
	end

	function PlumberOutfitSelectOutfitEntryMixin:PickupOutfit()
		local outfitID = self.outfitID;
		if (not outfitID) and self.GetElementData then
			local elementData = self:GetElementData();
			outfitID = elementData and elementData.outfitID;
		end
		if outfitID then
			C_TransmogOutfitInfo.PickupOutfit(outfitID);
		end
	end

	function PlumberOutfitSelectOutfitEntryMixin:ShowTooltip()
		if self.spellID then
			GameTooltip:SetOwner(self.IconButton, "ANCHOR_RIGHT");
			GameTooltip:SetSpellByID(self.spellID);
			return;
		end

		local elementData = self:GetElementData();
		if not (elementData and elementData.outfitID) then
			return;
		end

		GameTooltip:SetOwner(self.IconButton, "ANCHOR_RIGHT");
		GameTooltip:SetOutfit(elementData.outfitID);
	end

	function PlumberOutfitSelectOutfitEntryMixin:UpdateCooldown()
		SetSpellCooldown(self.IconButton.Cooldown, self.spellID or Def.equipOutfitSpellID, true);
	end

	function PlumberOutfitSelectOutfitEntryMixin:SetupActionButton()
		local index;

		if self.spellID then
			index = 0;
		else
			local elementData = self:GetElementData();
			index = elementData and elementData.index;
			if not index then return; end
		end

		local propagateMouseMotion = true;
		local actionButton = addon.AcquireSecureActionButton(Def.SecureButttonPrivateKey, propagateMouseMotion);

		if actionButton then
			actionButton:SetParent(self.IconButton);
			actionButton:CoverParent();

			if index == 0 then
				actionButton:SetClearOutfit();
			else
				actionButton:SetEquipOutfit(index);
			end

			actionButton:RegisterForDrag("LeftButton");
			actionButton:SetScript("OnDragStart", function()
				self:PickupOutfit();
			end);

			actionButton:Show();

			return true;
		end
	end

	function PlumberOutfitSelectOutfitEntryMixin:UpdateLocked(outfitID)
		local isLockedOutfit = C_TransmogOutfitInfo.IsLockedOutfit(outfitID);
		self.IconButton.OverlayLocked:SetShown(isLockedOutfit);
		self.IconButton.OverlayLocked:ShowAutoCastEnabled(isLockedOutfit);
	end

	function PlumberOutfitSelectOutfitEntryMixin:Init(elementData)
		--[[
		self.IconButton:SetScript("OnClick", function(_button, buttonName)
			local toggleLock = false;

			if buttonName == "RightButton" then
				toggleLock = true;
			end
		end);
		--]]

		self.Icon:SetTexture(elementData.icon);
		self.Name:SetText(elementData.name);
		self:SetActive(elementData.isActive);
		self:UpdateLocked(elementData.outfitID);

		--[[
		local situationText = "";
		if elementData.situationCategories then
			for index, situationCategory in ipairs(elementData.situationCategories) do
				situationText = situationText..situationCategory;

				if index ~= #elementData.situationCategories then
					situationText = situationText..TRANSMOG_SITUATION_CATEGORY_LIST_SEPARATOR;
				end
			end
		end
		--]]
	end
end


do	--12.0.5 Change
	local MainFrame;

	local OutfitSelectFrameMixin = {};

	function OutfitSelectFrameMixin:OnShow()
		self:RegisterEvent("TRANSMOG_OUTFITS_CHANGED");
		self:RegisterEvent("TRANSMOG_DISPLAYED_OUTFIT_CHANGED");
		self:RegisterEvent("PLAYER_REGEN_DISABLED");
		self:SetScript("OnKeyDown", self.OnKeyDown);
		self:RefreshList(true);
	end

	function OutfitSelectFrameMixin:OnHide()
		self:UnregisterEvent("TRANSMOG_OUTFITS_CHANGED");
		self:UnregisterEvent("TRANSMOG_DISPLAYED_OUTFIT_CHANGED");
		self:UnregisterEvent("PLAYER_REGEN_DISABLED");
		self:SetScript("OnKeyDown", nil);
		addon.HideSecureActionButton(Def.SecureButttonPrivateKey);
	end

	function OutfitSelectFrameMixin:OnEvent(event, ...)
		if event == "TRANSMOG_OUTFITS_CHANGED" or event == "TRANSMOG_DISPLAYED_OUTFIT_CHANGED" then
			self:RefreshList();
		elseif event == "PLAYER_REGEN_DISABLED" then
			self:Hide();
		end
	end

	function OutfitSelectFrameMixin:RefreshList(scrollToActive)
		local dataProvider = CreateDataProvider();
		local outfitsInfo = C_TransmogOutfitInfo.GetOutfitsInfo();
		local activeDataIndex;

		if outfitsInfo then
			local activeOutfitID = C_TransmogOutfitInfo.GetActiveOutfitID();
			for index, outfitInfo in ipairs(outfitsInfo) do
				local outfitData = {
					outfitID = outfitInfo.outfitID,
					name = outfitInfo.name,
					situationCategories = outfitInfo.situationCategories,
					icon = outfitInfo.icon,
					isActive = outfitInfo.outfitID == activeOutfitID,
					index = index,
				};

				if outfitInfo.outfitID == activeOutfitID then
					activeDataIndex = index;
				end

				dataProvider:Insert(outfitData);
			end
		end

		self.OutfitList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
		self.ClearTransmogFrame:SetActive(C_TransmogOutfitInfo.IsEquippedGearOutfitDisplayed());
		self.ClearTransmogFrame:UpdateLocked(self.ClearTransmogFrame.outfitID);

		if scrollToActive and activeDataIndex then
			local alignment = ScrollBoxConstants.AlignNearest;	--AlignBegin
			local offset = 0;
			local noInterpolation = true;
			self.OutfitList.ScrollBox:ScrollToElementDataIndex(activeDataIndex, alignment, offset, noInterpolation);
		end
	end

	function OutfitSelectFrameMixin:OnKeyDown(key)
		if InCombatLockdown() then
			self:Hide();
			self:SetScript("OnKeyDown", nil);
			return;
		end

		local valid;

		if key == "ESCAPE" then
			valid = true;
			self:Hide();
		end

		self:SetPropagateKeyboardInput(not valid);
	end

	local function OutfitSelectFrame_Show()
		if not MainFrame then
			local f = CreateFrame("Frame", Def.FrameName, UIParent, "Plumber_OutfitSelectFrameTemplate");
			MainFrame = f;
			Mixin(f, OutfitSelectFrameMixin);
			f:Hide();

			f:SetPortraitTextureSizeAndOffset(38, -5, -1);
			f:SetTitleOffsets(35);
			f:SetPortraitTextureRaw(Def.TextureFile);
			f:SetPortraitTexCoord(8/512, 88/512, 232/512, 312/512);
			f:SetTitle(TRANSMOGRIFY);
			f:SetBackgroundColor(CreateColor(0, 0, 0, 0.6));
			f:SetToplevel(true);

			f.TitleContainer:EnableMouse(true);
			f.TitleContainer:RegisterForDrag("LeftButton");
			f.TitleContainer:SetHitRectInsets(0, 32, 0, 0);

			f.TitleContainer:SetScript("OnDragStart", function()
				f:StartMoving();
			end);

			f.TitleContainer:SetScript("OnDragStop", function()
				f:StopMovingOrSizing();
			end);

			f.TitleContainer:SetScript("OnEnter", function()
				SetCursor("Interface/CURSOR/UI-Cursor-Move.blp");
			end);

			f.TitleContainer:SetScript("OnLeave", function()
				ResetCursor();
			end);


			local frameGap = Def.OutfitEntry.FrameGap;
			local layoutSize = Def.OutfitEntry.IconButtonWidth + frameGap;
			local listHeight = 10 * layoutSize - frameGap;
			f.OutfitList:SetHeight(listHeight);
			f:SetHeight(96 + listHeight + 24);

			f.OutfitList.DividerTop:SetTexture(Def.TextureFile);
			f.OutfitList.DividerTop:SetTexCoord(128/512, 1, 224/512, 232/512);
			f.OutfitList.DividerBottom:SetTexture(Def.TextureFile);
			f.OutfitList.DividerBottom:SetTexCoord(128/512, 1, 224/512, 232/512);

			local spellID = 1247917;
			local spellIcon = C_Spell.GetSpellTexture(spellID);
			local ctf = f.ClearTransmogFrame;
			ctf.spellID = spellID;
			ctf.outfitID = 0;
			ctf.Icon:SetTexture(spellIcon);
			ctf.Name:SetText(TRANSMOG_SHOW_EQUIPPED_GEAR);
			ctf.Name:ClearAllPoints();
			ctf.Name:SetPoint("LEFT", ctf.IconButton, "RIGHT", Def.OutfitEntry.IconTextGap + 2, 0);
			ctf.Name:SetPoint("RIGHT", f, "RIGHT", -Def.OutfitEntry.IconTextGap, 0);
			ctf.Name:SetMaxLines(2);
			ctf.Background:SetTexture(nil);

			local view = CreateScrollBoxListLinearView();

			view:SetElementInitializer("Plumber_OutfitSelectOutfitEntryTemplate", function(frame, elementData)
				frame:Init(elementData);
			end);

			local padV = frameGap;
			local padLeft = 20;
			local padRight = 0;
			local spacing = frameGap;
			view:SetPadding(padV, padV, padLeft, padRight, spacing);	--top, bottom, left, right, spacing
			view:SetElementStretchDisabled(true);

			ScrollUtil.InitScrollBoxListWithScrollBar(f.OutfitList.ScrollBox, f.OutfitList.ScrollBar, view);
			ScrollUtil.AddResizableChildrenBehavior(f.OutfitList.ScrollBox);

			f:SetScript("OnShow", f.OnShow);
			f:SetScript("OnHide", f.OnHide);
			f:SetScript("OnEvent", f.OnEvent);
		end

		MainFrame:Show();
		MainFrame:Raise();
	end

	function ToggleOutfitSelectFrame()
		if MainFrame and MainFrame:IsShown() then
			MainFrame:Hide();
		else
			OutfitSelectFrame_Show();
		end
	end
end


do  --Module Registry
	local function EnableModule(state)
		if state and not EL.enabled then
			EL.enabled = true;
			addon.CallbackRegistry:RegisterAddOnLoadedCallback("Blizzard_Transmog", Mod.Transmog_OnLoad);
		elseif (not state) and EL.enabled then
			EL.enabled = nil;
			if TransmogFrame then
				Mod.MaximizeTransmogUI();
			end
			addon.CallbackRegistry:UnregisterAddOnLoadedCallback("Blizzard_Transmog", Mod.Transmog_OnLoad);
		end
	end

	local moduleData = {
		name = L["ModuleName TransmogOutfitSelect"],
		dbKey = "TransmogOutfitSelect",
		description = L["ModuleDescription1 TransmogOutfitSelect"].."\n\n"..L["ModuleDescription2 TransmogOutfitSelect"],
		toggleFunc = EnableModule,
		moduleAddedTime = 1769000000,
		categoryKeys = {"Collection"},
	};

	if addon.IS_MIDNIGHT then
		addon.ControlCenter:AddModule(moduleData);
	end
end
