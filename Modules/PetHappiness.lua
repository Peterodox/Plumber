local _, addon = ...
if not addon.IS_FOREVER then return; end
if not addon.API.IsPlayerClass("HUNTER") then return; end

local L = addon.L;


local SpellFlyout = addon.InsecureSpellFlyout;
local GetBagItemIDsByPredicate = addon.API.GetBagItemIDsByPredicate;
local CanPetEatItem = C_PetInfo.CanPetEatItem;


local Def = {
	FeedPetSpellID = 6991,
	SpellFlyoutTag = "PetFood",
	MaxItems = 12, -- Stop searching after finding this many items
	BuffIconSize = 23,
	BuffIconOffsetX = 25,
	BuffWatchWindow = 25, -- Only enable the AuraContainer for 25 s after casting the spell
};


local HappinessButton = CreateFrame("Button");
HappinessButton:Hide();

function HappinessButton:Attach()
	self:ClearAllPoints();
	local parent = PetFrameHappiness;
	if parent then
		self.enabled = true;
		self:SetParent(parent);
		self:SetPoint("TOPLEFT", parent, "TOPLEFT", -1, 1);
		self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 1, -1);
		self:SetFrameLevel(parent:GetFrameLevel() + 2);
		self:SetScript("OnEnter", self.OnEnter);
		self:SetScript("OnLeave", self.OnLeave);
		self:SetScript("OnClick", self.OnClick);
		self:SetScript("OnEvent", self.OnEvent);
		self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		self:Show();
		self:InitAuraContainer();

		-- Certain UI addons hide Blizzard's Happiness Frame
		-- We could add our button to the Pet's context menu, but it doesn't feel very natural or time-saving
		--self:ModifyMenu();
	else
		self:Detach();
	end
end

function HappinessButton:Detach()
	if not self.enabled then return; end
	self.enabled = false;
	self:ClearAllPoints();
	self:Hide();
	self:UnregisterAllEvents();
	self:SetScript("OnUpdate", nil);
	self:SetScript("OnEvent", nil);
	self:SetEnableAuraContainer(false);
	self:UnregisterEvent("UNIT_HAPPINESS");
	if self.FoodIcon then
		self.FoodIcon:Hide();
	end
end

function HappinessButton:SetEnableAuraContainer(enabled)
	if self.auraTimer then
		self.auraTimer:Cancel();
		self.auraTimer = nil;
	end

	if self.AuraContainer then
		self.AuraContainer:SetEnabled(enabled)
		if enabled then
			self.auraTimer = C_Timer.NewTimer(Def.BuffWatchWindow, function()
				self:SetEnableAuraContainer(false);
			end);
		end
	end
end

function HappinessButton:OnFeedingAnimationFinished()
	self.FoodIcon.Texture:SetTexture(132165);
	self.FoodIcon.AnimBobbing:Play();
	self.FoodIcon.AnimBobbing:SetScript("OnFinished", function()
		self:SetEnableAuraContainer(true);
		self.FoodIcon.alpha = self.FoodIcon:GetAlpha();
		self.FoodIcon:SetScript("OnUpdate", function(obj, elapsed)
			obj.alpha = obj.alpha - 0.5 * elapsed;
			if obj.alpha <= 0 then
				obj.alpha = 0;
				obj:Hide();
				obj:SetScript("OnUpdate", nil);
			end
			obj:SetAlpha(obj.alpha);
		end);
	end);
end

function HappinessButton:OnEnter()
	self:RegisterEvent("UNIT_HAPPINESS");
	self:ShowTooltip();
end

function HappinessButton:OnLeave()
	self:UnregisterEvent("UNIT_HAPPINESS");
	GameTooltip:Hide();
end

function HappinessButton:OnEvent(event, ...)
	if event == "UNIT_HAPPINESS" then
		if self:IsMouseMotionFocus() and not SpellFlyout:IsOwner(self) then
			self:ShowTooltip();
		end
	end
end

function HappinessButton:GetFeedPetSpellName()
	return C_Spell.GetSpellName(Def.FeedPetSpellID) or "Feed Pet";
end

function HappinessButton:ShowTooltip(tooltipFrame)
	local happiness, damagePercentage, loyaltyRate = C_PetInfo.GetPetHappiness();
	if happiness and _G["PET_HAPPINESS"..happiness] then
		local tooltip;
		if tooltipFrame then
			tooltip = tooltipFrame;
		else
			tooltip = GameTooltip;
			tooltip:SetOwner(self, "ANCHOR_NONE");
			tooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0);
		end

		tooltip:SetText(_G["PET_HAPPINESS"..happiness], 1, 1, 1);
		tooltip:AddLine(PET_DAMAGE_PERCENTAGE:format(damagePercentage), 1, 0.82, 0, true);
		tooltip:AddLine(loyaltyRate < 0 and LOSING_LOYALTY or GAINING_LOYALTY, 1, 0.82, 0, true);

		local diet = C_PetInfo.GetPetFoodTypes();
		local dietText;
		if diet and #diet > 0 then
			dietText = PET_DIET_TEMPLATE:format(table.concat(diet, PET_FOOD_DELIMIT or ", "));
		else
			dietText = PET_DIET_TEMPLATE:format(NONE);
		end
		tooltip:AddLine(dietText, 1, 1, 1, true);
		tooltip:AddLine(" ");

		if not C_SpellBook.IsSpellKnown(Def.FeedPetSpellID, Enum.SpellBookSpellBank.Player) then
			local spellName = self:GetFeedPetSpellName();
			tooltip:AddLine(L["Not Learned Spell Format"]:format(spellName), 1, 0.82, 0, true);
		elseif not C_Spell.IsSpellUsable(Def.FeedPetSpellID) then
			-- Can be unusable if not learned or in combat
			local spellName = self:GetFeedPetSpellName();
			tooltip:AddLine(L["Not Usable Spell Format"]:format(spellName), 1, 0.125, 0.125, true);
		else
			local itemIDs = GetBagItemIDsByPredicate(CanPetEatItem, 1);
			if itemIDs then
				tooltip:AddLine(L["Instruction Click To Toggle Food Menu"], 0.098, 1, 0.098, true);
			else
				tooltip:AddLine(L["No Available Pet Food Warning"], 0.5, 0.5, 0.5, true);
			end
		end

		tooltip:Show();
	end
end

local function FlyoutButton_PostClick(flyoutButton, mouseButton)
	HappinessButton:SetupFeedingAnimation(flyoutButton);
end

function HappinessButton:SetupFeedingAnimation(flyoutButton)
	local iconFile = flyoutButton.icon;
	if not iconFile then return; end

	local fromX, fromY = flyoutButton:GetCenter();
	local toX, toY = self:GetCenter();

	if not canaccessallvalues(fromX, fromY, toX, toY) then return; end

	local buttonScale = flyoutButton:GetEffectiveScale();
	local selfScale = self:GetEffectiveScale();
	fromX = fromX * buttonScale / selfScale;
	fromY = fromY * buttonScale / selfScale;

	local offsetX = Def.BuffIconOffsetX;
	fromX = fromX - offsetX;
	local x0, y0 = fromX - toX, fromY - toY;
	local iconWidth, iconHeight = flyoutButton.Icon:GetSize();

	local object = self.FoodIcon;

	if not object then
		object = CreateFrame("Frame", nil, self);
		self.FoodIcon = object;
		object:SetFrameLevel(self:GetFrameLevel() + 5);
		object.Texture = object:CreateTexture(nil, "OVERLAY");
		object.Texture:SetAllPoints(object);

		object.AnimBobbing = object.Texture:CreateAnimationGroup();
		local t1 = object.AnimBobbing:CreateAnimation("Translation");
		t1:SetOrder(1);
		t1:SetOffset(0, -3);
		t1:SetDuration(0.05);
		local t2 = object.AnimBobbing:CreateAnimation("Translation");
		t2:SetOrder(2);
		t2:SetOffset(0, 3);
		t2:SetDuration(0.15);
		t2:SetSmoothing("OUT");
	end

	object:ClearAllPoints();
	object:SetSize(iconWidth, iconHeight);
	object:SetAlpha(1);
	object.Texture:SetTexture(iconFile);
	object.AnimBobbing:Stop();

	function object:SetRelativePosition(x, y)
		object:SetPoint("CENTER", HappinessButton, "CENTER", x + offsetX, y);
	end

	object:SetRelativePosition(x0, y0);

	local distance = x0^2 + y0^2;
	object.duration = addon.API.Clamp(math.sqrt(distance)/120, 0.4, 0.6);
	object.fromX = x0;
	object.toX = 0;
	object.fromY = y0;
	object.toY = 0;
	object.fromSize = iconWidth;
	object.toSize = Def.BuffIconSize;
	object.total = 0;

	local linear = addon.EasingFunctions.linear;
	local easeIn = addon.EasingFunctions.inQuad;
	local easeOut = addon.EasingFunctions.outQuad;

	object:SetScript("OnUpdate", function(obj, elapsed)
		obj.total = obj.total + elapsed;

		local px = easeOut(obj.total, obj.fromX, obj.toX, obj.duration);
		local py = easeIn(obj.total, obj.fromY, obj.toY, obj.duration);
		local size = linear(obj.total, obj.fromSize, obj.toSize, obj.duration);

		if obj.total >= obj.duration then
			px = obj.toX;
			py = obj.toY;
			size = obj.toSize;
			obj:SetScript("OnUpdate", nil);
			HappinessButton:OnFeedingAnimationFinished();
		end

		obj:SetRelativePosition(px, py);
		obj:SetSize(size, size);
	end);

	object:Show();
end

function HappinessButton:OnClick()
	self:ToggleFlyout(self);
	addon.LandingPageUtil.PlayUISound(SpellFlyout:IsShown() and "DropdownOpen" or "DropdownClose");
end

function HappinessButton:ToggleFlyout(owner)
	if SpellFlyout:IsOwner() then
		SpellFlyout:Hide();
	else
		local itemIDs = GetBagItemIDsByPredicate(CanPetEatItem, Def.MaxItems);
		if itemIDs then
			local spellName = self:GetFeedPetSpellName();
			local actions = {};
			local extraTooltip = "|cff19ff19"..L["Instruction Click To Feed Food"].."|r";
			local n = 0;
			for i, itemID in ipairs(itemIDs) do
				for j = 1, 1 do
					n = n + 1;
					actions[n] = {
						actionType = "item",
						id = itemID,
						icon = C_Item.GetItemIconByID(itemID),
						macroText = string.format("/cast %s\n/use \"item:%d\"", spellName, itemID);
						--macroText = "/cast "..spellName; -- for testing
						usable = true,
						extraTooltip = extraTooltip,
					};
				end
			end

			SpellFlyout:SetActions(Def.SpellFlyoutTag, actions);
			SpellFlyout:SetFlyoutButtonPostClickCallback(FlyoutButton_PostClick);
			SpellFlyout:ToggleFlyout(owner, "TOP");

			GameTooltip:Hide();
		else
			SpellFlyout:Hide();
		end
	end

	if owner then
		if self:IsMouseMotionFocus() and not SpellFlyout:IsShown() then
			self:ShowTooltip();
		end
	end
end

function HappinessButton:InitAuraContainer()
	if self.AuraContainer then return; end

	local AuraContainer = CreateFrame("AuraContainer", nil, self, "CustomAuraContainerTemplate");
	self.AuraContainer = AuraContainer;
	AuraContainer:SetSize(1, 1);
	AuraContainer:SetPoint("LEFT", self, "RIGHT", 0, 0);
	AuraContainer:SetUnit("pet");

	local slotKey = "FeedingBuff";
	local options = {
		candidateFilters = {
			includeSpellIDs = {
				[1539] = true,
			},
		},

		initializeFrame = function(button)
			button:SetSize(Def.BuffIconSize, Def.BuffIconSize);
			button:SetPoint("CENTER", self, "CENTER", Def.BuffIconOffsetX, 0);

			button.Icon = button:CreateTexture(nil, "OVERLAY")
			button.Icon:SetAllPoints(button)
			button:SetIcon(button.Icon);

			local Cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate");
			Cooldown:SetHideCountdownNumbers(true);
			Cooldown:SetReverse(true);
			button:SetDurationCooldown(Cooldown);

			self.AuraButton = button;
		end,
	};

	AuraContainer:AddAuraSlot(slotKey, "HELPFUL|PLAYER", options);
	AuraContainer:SetEnabled(false);
end

function HappinessButton:ModifyMenu()
	if self.menuModified then return; end
	self.menuModified = true;

	local function OnMenuOpen(owner, rootDescription, contextData)
		if (not self.enabled) or C_Secrets.ShouldUnitStatsBeSecret() then return; end

		local happiness, damagePercentage, loyaltyRate = C_PetInfo.GetPetHappiness();
		if not (happiness and _G["PET_HAPPINESS"..happiness]) then return; end

		rootDescription:CreateDivider();
		rootDescription:CreateTitle(_G["PET_HAPPINESS"..happiness]);

		local function OnClick()
			HappinessButton:ToggleFlyout();
		end

		local button = rootDescription:CreateButton(HappinessButton:GetFeedPetSpellName(), OnClick);

		button:SetTooltip(function(tooltip, elementDescription)
			HappinessButton:ShowTooltip(tooltip);
		end);
	end

	Menu.ModifyMenu("MENU_UNIT_PET", OnMenuOpen);
end

do
	local function EnableModule(state)
		if state then
			HappinessButton:Attach();
		else
			HappinessButton:Detach();
		end
	end

	local function GetExtraDescription()
		if not (PetFrameHappiness and PetFrameHappiness:IsVisible()) then
			local happiness = C_PetInfo.GetPetHappiness();
			local warningText;
			if not happiness then
				warningText = SPELL_FAILED_NO_PET;
			else
				warningText = L["Blizzard PetFrameHappiness Not Found Error"];
			end
			return "|cffd4641c"..warningText.."|r";
		end
	end

	local moduleData = {
		name = L["ModuleName PetFoodMenu"],
		dbKey = "PetFoodMenu",
		description = L["ModuleDescription PetFoodMenu"],
		descriptionFunc = GetExtraDescription,
		toggleFunc = EnableModule,
		moduleAddedTime = 1794200000,
		categoryKeys = {"Inventory"},
	};

	addon.ControlCenter:AddModule(moduleData);
end
