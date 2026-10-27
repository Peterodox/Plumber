local _, addon = ...
local GameTooltipItemManager = addon.GameTooltipManager:GetItemManager();

local GetFactionStatusText = addon.API.GetFactionStatusText;
local GetFactionGrantedByItem = addon.GetFactionGrantedByItem;

local MODULE_DB_KEY = "TooltipRepTokens";


local ItemSubModule = GameTooltipItemManager:CreateSubModule(MODULE_DB_KEY)
do
	function ItemSubModule:ProcessData(tooltip, itemID)
		if self.enabled then
			local factionID = GetFactionGrantedByItem(itemID);
			if factionID then
				if type(factionID) == "table" then
					tooltip:AddLine(" ");
					local showFactionName = true;
					for _, id in ipairs(factionID) do
						local factionStatus = GetFactionStatusText(id, nil, showFactionName);
						if factionStatus then
							tooltip:AddLine(factionStatus);
						end
					end
					return true
				else
					local factionStatus = GetFactionStatusText(factionID);
					if factionStatus then
						tooltip:AddLine(factionStatus);
						return true
					end
				end

			end
			return false
		else
			return false
		end
	end
end


local EdgeCaseManager = {};
do
	local GetFactionGrantedByCurrency = C_CurrencyInfo.GetFactionGrantedByCurrency;
	local GetQuestOfferCurrencyInfo = C_QuestOffer.GetQuestRewardCurrencyInfo;
	local GetQuestLogCurrencyInfo = C_QuestLog.GetQuestRewardCurrencyInfo;
	local GetMerchantItemID = GetMerchantItemID;
	local GetMerchantItemInfo = C_MerchantFrame.GetItemInfo;

	local SpellXFaction = {
		[1320747] = 2710, -- Silvermoon Court Voucher
		[1320744] = 2696, -- Amani Tribe Voucher
		[1320745] = 2704, -- Hara'ti Voucher
		[1320729] = 2699, -- Singularity Voucher
		[1320749] = 2772, -- Zul'jarra's Forces Voucher
	}

	local function AddFactionStatusToTooltip(tooltip, factionID)
		if factionID then
			local factionStatus = GetFactionStatusText(factionID);
			if factionStatus then
				tooltip:AddLine(factionStatus);
				tooltip:Show();
			end
		end
	end

	local function SetupTooltipByCurrency(tooltip, currencyID)
		local factionID = GetFactionGrantedByCurrency(currencyID);
		AddFactionStatusToTooltip(tooltip, factionID);
	end

	function EdgeCaseManager:SetEnabled(state)
		self.enabled = state;
		if state then
			if not self.hooked then
				self.hooked = true;

				hooksecurefunc(GameTooltip, "SetQuestLogCurrency", function(tooltip, type, id)
					if not self.enabled then return end;
					local questID = QuestMapFrame.DetailsFrame.questID;
					if questID then
						local isChoice = type == "choice";
						local info = GetQuestLogCurrencyInfo(questID, id, isChoice);
						if info and info.currencyID then
							SetupTooltipByCurrency(tooltip, info.currencyID);
						end
					end
				end);

				hooksecurefunc(GameTooltip, "SetQuestCurrency", function(tooltip, type, id)
					if not self.enabled then return end;
					local info = GetQuestOfferCurrencyInfo(type, id);
					if info and info.currencyID then
						SetupTooltipByCurrency(tooltip, info.currencyID);
					end
				end);

				-- 12.1.5: Use "Aqir Research Token" to purchase a spell
				-- We could use GameTooltipSpellHandler but it will process every spell
				hooksecurefunc(GameTooltip, "SetMerchantItem", function(tooltip, index)
					if not self.enabled then return end;
					if (not index) or (GetMerchantItemID(index ) ~= nil) then return; end

					local info = GetMerchantItemInfo(index);
					if info and info.spellID then
						AddFactionStatusToTooltip(tooltip, SpellXFaction[info.spellID]);
					end
				end);
			end
		end
	end
end


do
	local function EnableModule(state)
		ItemSubModule:SetEnabled(state);
		EdgeCaseManager:SetEnabled(state);
		if state then
			GameTooltipItemManager:AddSubModule(ItemSubModule);
		end
	end

	local moduleData = {
		name = addon.L["ModuleName "..MODULE_DB_KEY],
		dbKey = MODULE_DB_KEY,
		description = addon.L["ModuleDescription "..MODULE_DB_KEY],
		toggleFunc = EnableModule,
		categoryID = 3,
		uiOrder = 1111,
		moduleAddedTime = 1726674500,
		categoryKeys = {
			"Inventory",
		},
		searchTags = {
			"Tooltip",
		},
	};

	addon.ControlCenter:AddModule(moduleData);
end
