local _, addon = ...
local L = addon.L;
local API = addon.API;


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
};


local EL = CreateFrame("Frame");
local Mod = {};
local AcquireOutfitMacro;
local ClickHandler;
local ExtraFrame;
local CreateExtraFrame;
local RepositionFrame;
local CreateRepositionFrame;


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

        local file = "Interface/AddOns/Plumber/Art/Frame/TransmogUI.png";
        local alpha = 0.5;

        local Left = f:CreateTexture(nil, "OVERLAY");
        Left:SetSize(40, 12);
        Left:SetTexture(file);
        Left:SetTexCoord(0, 80/512, 0, 24/512);
        Left:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0);

        local Right = f:CreateTexture(nil, "OVERLAY");
        Right:SetSize(40, 12);
        Right:SetTexture(file);
        Right:SetTexCoord(160/512, 240/512, 0, 24/512);
        Right:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);

        local Center = f:CreateTexture(nil, "OVERLAY");
        Center:SetSize(40, 12);
        Center:SetTexture(file);
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
        local body = header.."\n"..macro;
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


do  --Module Registry
    local function EnableModule(state)
        if state and not EL.enabled then
            EL.enabled = true;
            if C_AddOns.IsAddOnLoaded("Blizzard_Transmog") then
                Mod.Transmog_OnLoad();
            else
                if not EL.hooked then
                    EL.hooked = true;
                    EventUtil.ContinueOnAddOnLoaded("Blizzard_Transmog", Mod.Transmog_OnLoad);
                end
            end

        elseif (not state) and EL.enabled then
            EL.enabled = nil;
            if TransmogFrame then
                Mod.MaximizeTransmogUI();
            end
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
