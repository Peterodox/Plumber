-- Right-click a lockbox in your bag to unlock when you are not in combat
-- Game Issue #1: The game prioritizes the Soft Targeting target, so if the player is facing an object (e.g. mailbox, chair), the character will perform Pick Lock on that object
-- Game Issue #2: You'll get a "Invalid Target" error if the targeted lockbox is in the bank. (/use a bank item moves it into your bag)

local _, addon = ...
local _, _, classID = UnitClass("player");
local _, _, raceID = UnitRace("player");
if classID ~= 4 and raceID ~= 37 then return end;


local API = addon.API;
local IsWarningColor = API.IsWarningColor;

local InCombatLockdown = InCombatLockdown;
local IsSpellKnown = IsSpellKnown;
local SpellIsTargeting = SpellIsTargeting;
local GetMouseFocus = API.GetMouseFocus;
local GetSpellInfo = API.GetSpellInfo;
local GetCursorInfo = GetCursorInfo;
local match = string.match;
local IsInteractingWithNpcOfType = (C_PlayerInteractionManager and C_PlayerInteractionManager.IsInteractingWithNpcOfType) or function(type) return false end


local TEXT_LOCKED = LOCKED or "Locked";
local SPELL_ID_PICK_LOCK = ((classID == 4) and 1804) or (312890);    --Rogue: Lock Pick  Mechagnome: Skeleton Pinkie
local SPELL_NAME_PICK_LOCK = nil;   --Localized with GetSpellInfo
local INSTRUCTION_PICK_LOCK = addon.L["Instruction Pick Lock"];
local NOT_TRADED_ITEM_SLOT_INDEX = 7;  --TRADE_ENCHANT_SLOT


local MODULE_ENABLED = false;
local TOOLTIP_CALLBACK_ADDED = false;
local OLD_BAG_ID, OLD_SLOT_ID = nil, nil;


local Processor = CreateFrame("Frame");
local TooltipFrame;
local ActiveActionButton;
local CursorProgressIndicator;


local function HideActionButton()
    if ActiveActionButton then
        ActiveActionButton:Release();
    end
end

local function HideProgressIndicator()
    if CursorProgressIndicator then
        CursorProgressIndicator:ClearWatch();
    end
end

function Processor:OnUpdate_ProcessAfter(elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0.0 then
        self:SetScript("OnUpdate", nil);
        self:ProcessItem();
    end
end

function Processor:OnUpdate_CheckOwnerVisibility(elapsed)
    self.t = self.t + elapsed;
    if self.t >= 0.05 then
        self.t = 0;
        if (not self.owner) or (not self.owner:IsVisible()) then
            self:SetScript("OnUpdate", nil);
            HideActionButton();
            HideProgressIndicator();
        end
    end
end

function Processor:OnEvent(event, ...)
    if event == "CURSOR_CHANGED" then   --Unused Event
        HideActionButton();
        self:UnregisterEvent(event);
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local _, _, spellID = ...
        if spellID == SPELL_ID_PICK_LOCK then
            self:UnregisterEvent(event);
            local bag, slot = OLD_BAG_ID, OLD_SLOT_ID;
            HideActionButton();
            OLD_BAG_ID, OLD_SLOT_ID = bag, slot;    --Item doesn't change status imediately so we pause our processing
            C_Timer.After(1, function()
                OLD_BAG_ID, OLD_SLOT_ID = nil, nil;
            end);
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        self:UnregisterEvent(event);
        self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
        self:SetScript("OnUpdate", nil);
        OLD_BAG_ID, OLD_SLOT_ID = nil, nil;
    elseif event == "TRADE_TARGET_ITEM_CHANGED" then
        local tradeSlotIndex = ...
        if tradeSlotIndex == NOT_TRADED_ITEM_SLOT_INDEX then
            HideActionButton();
        end
    end
end

Processor:SetScript("OnEvent", Processor.OnEvent);

function Processor:Initiate(customDelay)
    if customDelay then
        self.t = -customDelay;
    else
        self.t = 0;
    end
    self:SetScript("OnUpdate", self.OnUpdate_ProcessAfter);
end

local function IsPlayerInteracingBank()
    --Merchant is checked by another function
    --Banker, GuildBanker, MailInfo, CharacterBanker, AccountBanker
    return IsInteractingWithNpcOfType(8) or IsInteractingWithNpcOfType(10) or IsInteractingWithNpcOfType(17) or IsInteractingWithNpcOfType(67) or IsInteractingWithNpcOfType(68)
end

local function ShouldShowOverlay()
    return (not InCombatLockdown()) and (not GetCursorInfo()) and (not SpellIsTargeting()) and IsSpellKnown(SPELL_ID_PICK_LOCK) and (not(MerchantFrame and MerchantFrame:IsShown()))
end

local function GetUnlockSpellName()
    if not SPELL_NAME_PICK_LOCK then
        SPELL_NAME_PICK_LOCK = GetSpellInfo(SPELL_ID_PICK_LOCK);
    end
    return SPELL_NAME_PICK_LOCK or ""
end


-- Copied from SharedTooltipTemplates.lua to prevent potential issues
local function GameTooltip_AddColoredLine(tooltip, text, color, wrap, leftOffset)
	local r, g, b = color:GetRGB();
	if wrap == nil then
		wrap = true;
	end
	tooltip:AddLine(text, r, g, b, wrap, leftOffset);
end

local function GameTooltip_AddColoredDoubleLine(tooltip, leftText, rightText, leftColor, rightColor, wrap, leftOffset)
	local leftR, leftG, leftB = leftColor:GetRGB();
	local rightR, rightG, rightB = rightColor:GetRGB();
	if wrap == nil then
		wrap = true;
	end
	tooltip:AddDoubleLine(leftText, rightText, leftR, leftG, leftB, rightR, rightG, rightB, wrap, leftOffset);
end

local function AddLineDataText(tooltip, lineData, matchLineFunc)
    local leftText = lineData.leftText;
	local leftColor = lineData.leftColor or NORMAL_FONT_COLOR;
	local wrapText = lineData.wrapText or false;
	local rightText = lineData.rightText;
	local leftOffset = lineData.leftOffset;
	if rightText then
		local rightColor = lineData.rightColor or NORMAL_FONT_COLOR;
		GameTooltip_AddColoredDoubleLine(tooltip, leftText, rightText, leftColor, rightColor, wrapText, leftOffset);
	elseif leftText then
		GameTooltip_AddColoredLine(tooltip, leftText, leftColor, wrapText, leftOffset);
        if matchLineFunc then
            return matchLineFunc(leftText);
        end
	end
end
-- End of the copy


local function ActionButton_Bag_OnEnter(self)
    if self.bag and self.slot then
        TooltipFrame:Hide();

        --[[
        --This noticeably affects RAM count, so we use another way to display info
        local tooltipInfo = {
			getterName = "GetBagItem",
			getterArgs = {self.bag, self.slot, calledByPlumber = true};
		};
        TooltipFrame:ProcessInfo(tooltipInfo);
        --]]

        local tooltipData = C_TooltipInfo.GetBagItem(self.bag, self.slot);
        if not tooltipData then return end;

        TooltipFrame:SetOwner(self, "ANCHOR_LEFT");

        --for i, lineData in ipairs(tooltipData.lines) do
        --    AddLineDataText(TooltipFrame, lineData);
        --end
        TooltipFrame:SetBagItem(self.bag, self.slot);

        TooltipFrame:AddLine(INSTRUCTION_PICK_LOCK, 0.400, 0.733, 1.000, true);    --Use a different color to distinguish it from other <Action> text in Pure Green
        TooltipFrame:Show();
    end
end

local PATTERN_ITEM_PROPOSED_ENCHANT;
do
    PATTERN_ITEM_PROPOSED_ENCHANT = string.gsub((ITEM_PROPOSED_ENCHANT or "Will receive %s."), "%.", "%%.");
    PATTERN_ITEM_PROPOSED_ENCHANT = string.gsub(PATTERN_ITEM_PROPOSED_ENCHANT, "%%s", "(%.+)");
    --print(PATTERN_ITEM_PROPOSED_ENCHANT)
end

local function MatchProposedEnchantText(text)
    local enchantName = match(text, PATTERN_ITEM_PROPOSED_ENCHANT);
    if enchantName then
        return enchantName
    end
end

local function ActionButton_Trade_OnEnter(self)
    TooltipFrame:Hide();

    local tooltipData = C_TooltipInfo.GetTradeTargetItem(NOT_TRADED_ITEM_SLOT_INDEX);
    if not tooltipData then return end;

    TooltipFrame:SetOwner(self, "ANCHOR_RIGHT");

    local matchedText;
    local enchantTextFound = false;

    for i, lineData in ipairs(tooltipData.lines) do
        matchedText = AddLineDataText(TooltipFrame, lineData, MatchProposedEnchantText);
        if not enchantTextFound then
            enchantTextFound = matchedText ~= nil;
        end
    end

    if not enchantTextFound then
        TooltipFrame:AddLine(INSTRUCTION_PICK_LOCK, 0.400, 0.733, 1.000, true);
    end

    TooltipFrame:Show();
end

local function ActionButton_OnHideCallback(self)
    Processor:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    Processor:UnregisterEvent("PLAYER_REGEN_DISABLED");
    Processor:UnregisterEvent("TRADE_TARGET_ITEM_CHANGED");
    Processor:SetScript("OnUpdate", nil);
end

local function ActionButton_OnLeave(self)
    OLD_BAG_ID = nil;
    OLD_SLOT_ID = nil;

    TooltipFrame:Hide();
    self:Release();
    HideProgressIndicator();
end

local function SetupActionButton(bag, slot, tradeItem)
    if not ShouldShowOverlay() then return end;

    if not tradeItem then
        --When mouseover a lockbox in your bag while trading with another player
        --We don't create our ActionButton. By default, right-click put items in trade
        if IsInteractingWithNpcOfType(1) then
            return
        end
    end

    local privateKey = "RogueLockpick";
    local ActionButton = addon.AcquireSecureActionButton(privateKey);

    ActionButton:SetSize(37, 37);
    ActionButton:SetPassThroughButtons("LeftButton");
    ActionButton:SetFrameStrata("FULLSCREEN_DIALOG");
    ActionButton:SetFixedFrameStrata(true);
    ActionButton:RegisterForClicks("RightButtonDown", "RightButtonUp");
    ActionButton.bag = bag;
    ActionButton.slot = slot;

    ActionButton:SetScript("OnLeave", ActionButton_OnLeave);
    ActionButton.onHideCallback = ActionButton_OnHideCallback;

    ActionButton:ShowDebugHitRect(false);

    local spellName = GetUnlockSpellName();
    local macroText;
    if tradeItem then
        macroText = string.format("/cast %s\r/click TradeRecipientItem%sItemButton", spellName, NOT_TRADED_ITEM_SLOT_INDEX);
        ActionButton:SetScript("OnEnter", ActionButton_Trade_OnEnter);
    else
        macroText = string.format("/cast %s\r/use %s %s", spellName, bag, slot);
        ActionButton:SetScript("OnEnter", ActionButton_Bag_OnEnter);
    end
    ActionButton:SetAttribute("type2", "macro");
    ActionButton:SetMacroText(macroText);

    if not ActionButton.Highlight then
        local hl = ActionButton:CreateTexture(nil, "HIGHLIGHT");
        ActionButton.Highlight = hl;
        hl:SetAllPoints(true);
        hl:SetTexture("Interface/AddOns/Plumber/Art/Button/Highlight-Square-Inner");
        hl:SetBlendMode("ADD");
    end

    return ActionButton
end

local function IsMouseoverItemLocked()
    local line2 = TooltipFrame.TextLeft2;
    if line2 and line2:GetText() == TEXT_LOCKED then
        local r, g, b = line2:GetTextColor();
        if not IsWarningColor(r, g, b) then
            return true
        end
    end
end

local function IsMouseOverObjectItemButton(object)
    return object.GetBagID ~= nil
end

local function SetupButtonAndTooltip(bag, slot, tradeItem)
    local mouseoverObject = GetMouseFocus();
    if mouseoverObject and IsMouseOverObjectItemButton(mouseoverObject) then
        local button = SetupActionButton(bag, slot, tradeItem);
        ActiveActionButton = button;

        if not button then return end;


        local x, y = mouseoverObject:GetCenter();
        local scale = mouseoverObject:GetEffectiveScale();
        local w, h = mouseoverObject:GetSize();

        button:ClearAllPoints();
        button:SetSize(w, h);
        button:SetScale(scale);
        button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
        button:SetIgnoreParentScale(true);
        button:SetParent(UIParent);
        button:Show();

        Processor:StartWatchingOwner(mouseoverObject);

        if not CursorProgressIndicator then
            CursorProgressIndicator = addon.AcquireCursorProgressIndicator();
        end

        CursorProgressIndicator:ClearAllPoints();
        CursorProgressIndicator:SetIgnoreParentScale(true);
        CursorProgressIndicator:SetScale(scale);
        CursorProgressIndicator:SetParent(UIParent);
        CursorProgressIndicator:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y);
        CursorProgressIndicator:WatchSpell(SPELL_ID_PICK_LOCK);
    end
end

function Processor:StartWatchingOwner(itemButton)
    self.owner = itemButton;
    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate_CheckOwnerVisibility);
    self:RegisterEvent("PLAYER_REGEN_DISABLED");
    self:RegisterEvent("TRADE_TARGET_ITEM_CHANGED");
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
end

function Processor:ProcessItem()
    if InCombatLockdown() or IsPlayerInteracingBank() then return end;

    local info = TooltipFrame.processingInfo;
    if info and TooltipFrame:IsVisible() then
        if info.getterArgs and not info.getterArgs.calledByPlumber then
            if info.getterName == "GetBagItem" then
                local bag, slot = info.getterArgs[1], info.getterArgs[2];
                if bag and slot then
                    if IsMouseoverItemLocked() then
                        SetupButtonAndTooltip(bag, slot);
                        return
                    end
                end
            elseif info.getterName == "GetTradeTargetItem" then
                local tradeSlotIndex = info.getterArgs[1];
                if tradeSlotIndex and tradeSlotIndex == NOT_TRADED_ITEM_SLOT_INDEX then
                    if IsMouseoverItemLocked() then
                        SetupButtonAndTooltip(nil, nil, true);
                        return
                    end
                end
            end
        end
    end
end

function Processor:StopAll()
    HideActionButton();
    HideProgressIndicator();
    ActionButton_OnHideCallback();
end


local function TooltipCall_SetInventoryItem(tooltip, ...)
    if not MODULE_ENABLED then return end;

    local info = tooltip.processingInfo;
    if info then
        if info.getterName == "GetBagItem" then
            Processor:Initiate();
        end
    end
end

local function TooltipCall_SetTradeTargetItem(tooltip, ...)
    if not MODULE_ENABLED then return end;

end

local function Tooltip_OnSetBagItem(tooltip, bag, slot)
    if not MODULE_ENABLED then return end;

    if bag == OLD_BAG_ID and slot == OLD_SLOT_ID then
        return
    end

    OLD_BAG_ID = bag;
    OLD_SLOT_ID = slot;

    local info = tooltip.processingInfo;
    if info then
        if info.getterName == "GetBagItem" then
            Processor:Initiate();
        end
    end
end

local function Tooltip_OnSetTradeTargetItem(tooltip, tradeSlotIndex)
    if not MODULE_ENABLED then return end;

    if tradeSlotIndex == NOT_TRADED_ITEM_SLOT_INDEX then
        Processor:Initiate();
    end
end


local function AddTooltipPostCall()
    if TOOLTIP_CALLBACK_ADDED then return end;
    TOOLTIP_CALLBACK_ADDED = true;

    local tooltip = GameTooltip;

    if tooltip.SetBagItem then
        hooksecurefunc(tooltip, "SetBagItem", Tooltip_OnSetBagItem);
    end

    if tooltip.SetTradeTargetItem then
        hooksecurefunc(tooltip, "SetTradeTargetItem", Tooltip_OnSetTradeTargetItem);
    end
end

local function EnableModule(state)
    if state then
        MODULE_ENABLED = true;
        TooltipFrame = GameTooltip;
        AddTooltipPostCall();
        GetUnlockSpellName();
    else
        MODULE_ENABLED = false;
        Processor:StopAll();
    end
end

do
    local moduleData = {
        name = addon.L["ModuleName HandyLockpick"],
        dbKey = "HandyLockpick",
        description = addon.L["ModuleDescription HandyLockpick"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 100,
    };

    addon.ControlCenter:AddModule(moduleData);
end