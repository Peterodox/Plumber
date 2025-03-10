-- Show unspent points on the ProfessionsBookFrame
-- Show unspent points on Profession Tooltip

local _, addon = ...
local L = addon.L
local API = addon.API;
local GameTooltipManager = addon.GameTooltipManager:GetSpellManager();


local GetProfessions = GetProfessions;
local GetProfessionInfo = GetProfessionInfo;
local C_ProfSpecs = C_ProfSpecs;
local C_Traits = C_Traits;
local GetSpecTabIDsForSkillLine = C_ProfSpecs.GetSpecTabIDsForSkillLine;
local GetConfigIDForSkillLine = C_ProfSpecs.GetConfigIDForSkillLine;
local GetTabInfo = C_ProfSpecs.GetTabInfo;
local GetSpendCurrencyForPath = C_ProfSpecs.GetSpendCurrencyForPath;
local GetUnlockEntryForPath = C_ProfSpecs.GetUnlockEntryForPath;
local GetTreeCurrencyInfo = C_Traits.GetTreeCurrencyInfo;
local GetEntryInfo = C_Traits.GetEntryInfo;
local GetNodeInfo = C_Traits.GetNodeInfo;
local GetTreeNodes = C_Traits.GetTreeNodes;
local CanPurchaseRank = C_Traits.CanPurchaseRank;
local GetAllProfessionTradeSkillLines = C_TradeSkillUI.GetAllProfessionTradeSkillLines;
local GetProfessionInfoBySkillLineID = C_TradeSkillUI.GetProfessionInfoBySkillLineID;


local EL = CreateFrame("Frame");

local Debug = {};


local function GetPrimaryProfessionID(index)
    local prof = select(index, GetProfessions());
    if prof then
        local subcateogryName = select(11, GetProfessionInfo(prof));
        if not subcateogryName or subcateogryName == "" then return end;

        local info;
        local skillLines = GetAllProfessionTradeSkillLines();

        for i, skillLine in ipairs(skillLines) do
            info = GetProfessionInfoBySkillLineID(skillLine)
            if info and info.professionName == subcateogryName then
                return skillLine, info.professionName
            end
        end
    end
end

local function GetNodeRanks(configID, nodeInfo, nodeID)
    --First tier for the path node is the unlock entry, which we do not want to include in the count. It can have a max ranks of either 0 or 1
    local unlockNodeEntry = GetUnlockEntryForPath(nodeID);
    local nodeEntryInfo = GetEntryInfo(configID, unlockNodeEntry);
    local numUnlockPoints = nodeEntryInfo and nodeEntryInfo.maxRanks or 0;
    local currRank = (nodeInfo.currentRank > 0) and (nodeInfo.currentRank - numUnlockPoints) or nodeInfo.currentRank;
    local maxRank = nodeInfo.maxRanks - numUnlockPoints;
    return currRank, maxRank
end


local function GetProfessionUnspentPoints(index)
    local professionID, progressionName = GetPrimaryProfessionID(index);
    local total = 0;
    local anyPurchasableNode = false;

    if professionID then
        local configID = GetConfigIDForSkillLine(professionID);
        local tabTreeIDs = GetSpecTabIDsForSkillLine(professionID);
        local excludeStagedChangesForCurrencies = false;
        local tabCurrencyCount = {};
        local tabInfo, tabSpendCurrency, treeCurrencyInfo, treeCurrencyInfoMap, currencyInfo, currencyCount;

        for treeOrder, treeID in ipairs(tabTreeIDs) do
            tabInfo = GetTabInfo(treeID);
            tabSpendCurrency = GetSpendCurrencyForPath(tabInfo.rootNodeID);
            if not (tabCurrencyCount[tabSpendCurrency]) then
                treeCurrencyInfo = GetTreeCurrencyInfo(configID, treeID, excludeStagedChangesForCurrencies);
                treeCurrencyInfoMap = {};
                for _, treeCurrency in ipairs(treeCurrencyInfo) do
                    treeCurrencyInfoMap[treeCurrency.traitCurrencyID] = treeCurrency;
                end
                currencyInfo = treeCurrencyInfoMap[tabSpendCurrency];
                currencyCount = currencyInfo and currencyInfo.quantity or 0;
                tabCurrencyCount[tabSpendCurrency] = currencyCount;
                total = total + currencyCount;
            end


            local nodeIDs = GetTreeNodes(treeID);
            local nodeInfo;
            local ranksPurchased, maxRanks;
            local activeEntryID, entryInfo, talentType;
            local totalPurchased = 0;
            local totalMaxRanks = 0;
            local canPurchased = 0;

            for _, nodeID in ipairs(nodeIDs) do
                nodeInfo = GetNodeInfo(configID, nodeID);
                if nodeInfo and nodeInfo.isVisible then
                    activeEntryID = nodeInfo.activeEntry and nodeInfo.activeEntry.entryID or nil;
                    if CanPurchaseRank(configID, nodeID, activeEntryID) then
                        canPurchased = canPurchased + 1;
                        anyPurchasableNode = true;
                    end
                    --[[
                    entryInfo = (activeEntryID ~= nil) and GetEntryInfo(configID, activeEntryID) or nil;
                    talentType = (entryInfo ~= nil) and entryInfo.type or nil;
                    if talentType then
                        ranksPurchased, maxRanks = GetNodeRanks(configID, nodeInfo, nodeID);
                        if maxRanks > 1 then
                            totalMaxRanks = totalMaxRanks + maxRanks;
                            totalPurchased = totalPurchased + ranksPurchased;
                        end
                    end
                    --]]
                end
            end

            --[[
            local diff = totalPurchased - totalMaxRanks;
            if diff ~= 0 then
                print(progressionName, totalPurchased.."/"..totalMaxRanks, "|cffff4800"..diff.."|r", canPurchased);
            else
                print(progressionName, totalPurchased.."/"..totalMaxRanks, canPurchased);
            end
            --]]
        end
    end

    if anyPurchasableNode then
        return total, professionID, progressionName
    end
end

local PointsDisplayMixin = {};
do
    function PointsDisplayMixin:SetPoints(points)
        if points and points > 0 then
            self.points = points;
            if points > 99 then
                points = "99+";
            end
            self.Text:SetText(points);
            self:Show();
        else
            self.points = 0;
            self:Hide();
        end
    end

    function PointsDisplayMixin:OnEnter()
        if not (self.points and self.points > 0) then return end;
        local tooltip = GameTooltip;
        tooltip:SetOwner(self, "ANCHOR_RIGHT");
        tooltip:SetText(PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS, 1, 1, 1, true);
        tooltip:AddLine(L["Unspent Knowledge Tooltip Format"]:format(self.points), 1, 0.82, 0, true);
        tooltip:Show();
    end

    function PointsDisplayMixin:OnLeave()
        GameTooltip:Hide();
    end

    function PointsDisplayMixin:OnLoad()
        self.OnLoad = nil;

        self:SetSize(24, 24);

        self.Background = self:CreateTexture(nil, "ARTWORK");
        self.Background:SetSize(30, 24);
        self.Background:SetPoint("CENTER", self, "CENTER", 0, 0);
        self.Background:SetTexture("Interface/AddOns/Plumber/Art/Delves/Delves-Scenario");
        self.Background:SetTexCoord(0, 60/256, 0, 48/256);

        self.Text = self:CreateFontString(nil, "OVERLAY", "TextStatusBarText");
        self.Text:SetJustifyH("CENTER");
        self.Text:SetPoint("CENTER", self, "CENTER", 0, 0);

        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
    end
end

function EL:UpdateCurrency()
    self:CreateWidgets();

    if self.widgets then
        for i, widget in ipairs(self.widgets) do
            local points = GetProfessionUnspentPoints(i);
            widget:SetPoints(points);
        end
    end
end

function EL:OnUpdate(elapse)
    self.t = self.t + elapse;
    if self.t > 1.0 then
        self.t = 0;
        self:SetScript("OnUpdate", nil);
        EL:UpdateCurrency();
    end
end

function EL:RequestUpdate()
    self.t = 0;
    self:SetScript("OnUpdate", self.OnUpdate);
end

function EL:OnEvent(event, ...)
    self:RequestUpdate();
end

function EL:HookProfessionBook()
    local BlizFrame = ProfessionsBookFrame;
    if BlizFrame then
        BlizFrame:HookScript("OnShow", function()
            if self.enabled then
                EL:ListenEvents(true);
                self:UpdateCurrency();
            end
        end);

        BlizFrame:HookScript("OnHide", function()
            EL:ListenEvents(false);
        end);

        self.blizFrameFound = true;
    else
        Debug.ProfessionsBookFrame = false;
    end
end

function EL:CreateWidgets()
    if not self.blizFrameFound then return end;

    if not self.widgets then
        local BlizFrame = ProfessionsBookFrame;
        if BlizFrame then
            for i = 1, 2 do
                local widget = CreateFrame("Frame", nil, BlizFrame);
                API.Mixin(widget, PointsDisplayMixin);
                widget:OnLoad();
                widget:Hide();
                local buttonName = string.format("PrimaryProfession%dSpellButtonBottom", i);
                local parent = _G[buttonName];
                if parent then
                    widget:SetPoint("RIGHT", parent, "TOPLEFT", 5, -6);
                    widget:SetFrameLevel(parent:GetFrameLevel() + 2);
                else
                    Debug[buttonName] = false;
                end
                if not self.widgets then
                    self.widgets = {};
                end
                self.widgets[i] = widget;
            end
        end
    end
end

function EL:ListenEvents(state)
    if state then
        self:RegisterEvent("TRAIT_TREE_CURRENCY_INFO_UPDATED");   --Trigger 3 times when clicking Apply Knowledge (event without Applying Changes) because 3 specs use the same currency
        self:RegisterEvent("TRAIT_CONFIG_UPDATED");
        self:SetScript("OnEvent", self.OnEvent);
    else
        self:UnregisterEvent("TRAIT_TREE_CURRENCY_INFO_UPDATED");
        self:UnregisterEvent("TRAIT_CONFIG_UPDATED");
        self:SetScript("OnEvent", nil);
    end
end

if ProfessionsBook_LoadUI then
    hooksecurefunc("ProfessionsBook_LoadUI", function()
        if EL.initialized then return end;
        EL.initialized = true;
        EL:HookProfessionBook();
        if EL.enabled and EL.blizFrameFound then
            if ProfessionsBookFrame:IsShown() then
                EL:ListenEvents(true);
                EL:CreateWidgets();
                EL:UpdateCurrency();
            end
        end
    end);
else
    Debug.ProfessionsBook_LoadUI = false;
end

function EL:EnableModule(state)
    if state then
        if self.enabled then return end;
        self.enabled = true;
    else
        if self.enabled then
            self.enabled = false;
            self:ListenEvents(false)
            if self.widgets then
                for _, widget in ipairs(self.widgets) do
                    widget:Hide();
                end
            end
        end
    end
end


do
    local function EnableModule(state)
        EL:EnableModule(state);
    end

    local moduleData = {
        name = addon.L["ModuleName ProfessionsBook"],
        dbKey = "ProfessionsBook",
        description = addon.L["ModuleDescription ProfessionsBook"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1170,
        moduleAddedTime = 1740755000,
    };

    addon.ControlCenter:AddModule(moduleData);
end


do  --User-end Debugging    /run PlumberDebug()
    local function PlumberDebug()
        local n = 0;

        local function Print(...)
            n = n + 1;
            print("|cffa0a0a0"..n.."|r", ...)
        end

        for i = 1, 2 do
            local points, id, name = GetProfessionUnspentPoints(i);
            if id then
                Print(string.format("%s (%s)  Unspent Knowledge: %s", name, id, points));
            else
                Print(string.format("|cffff2020Profession #%d not found|r", i));
            end
        end

        if not ProfessionsBookFrame then
            local hotkey = GetBindingKey("TOGGLEPROFESSIONBOOK") or NOT_BOUND or "Not Bound";
            Print(string.format("|cffff2020ProfessionsBookFrame not found. Make sure you have opened Profession Book once. (Default hotkey: %s)|r", hotkey));
        end

        if not (EL.widgets and #EL.widgets == 2) then
            Print("|cffff2020Widgets not found|r");
        end

        for k, v in pairs(Debug) do
            if v then
                Print("|cffff2020"..k.."|r", tostring(v));
            else
                Print(k, tostring(v));
            end
        end
    end

    --_G.PlumberDebug = PlumberDebug;
end




do  --Tooltip Module
    local SubModule = CreateFrame("Frame");

    function SubModule:ProcessData(tooltip, spellID)
        if self.enabled then
            --tooltip:AddLine(spellID);
            if self.isDirty then
                self:UpdateProfessionInfo();
            end

            if spellID == self.profSpell1 then
                if not self.unspentPoints1 then
                    self.unspentPoints1 = GetProfessionUnspentPoints(1) or 0;
                end
                if self.unspentPoints1 > 0 then
                    tooltip:AddLine(" ");
                    tooltip:AddLine(L["Available Knowledge Format"]:format(self.unspentPoints1), 1, 0.82, 0, true);
                end
            elseif spellID == self.profSpell2 then
                if not self.unspentPoints2 then
                    self.unspentPoints2 = GetProfessionUnspentPoints(2) or 0;
                end
                if self.unspentPoints2 > 0 then
                    tooltip:AddLine(" ");
                    tooltip:AddLine(L["Available Knowledge Format"]:format(self.unspentPoints2), 1, 0.82, 0, true);
                end
            end

            return false
        else
            return false
        end
    end

    function SubModule:GetDBKey()
        return "TooltipProfessionKnowledge"
    end

    function SubModule:SetEnabled(enabled)
        self.enabled = enabled == true
        GameTooltipManager:RequestUpdate();
        if enabled then
            self:SetScript("OnEvent", self.OnEvent);
            self:UpdateProfessionInfo();
        else
            self:SetScript("OnEvent", nil);
            self:UnregisterAllEvents();
        end
    end

    function SubModule:IsEnabled()
        return self.enabled == true
    end


    function SubModule:UpdateProfessionInfo()
        self.profSpell1 = nil;
        self.profSpell2 = nil;
        self.unspentPoints1 = nil;
        self.unspentPoints2 = nil;
        self.isDirty = false;

        for i = 1, 2 do
            local info = API.GetProfessionSpellInfo(i);
            if info and info.spellID then
                self["profSpell"..i] = info.spellID;
            end
        end

        self:RegisterEvent("SKILL_LINES_CHANGED");
        self:RegisterEvent("TRAIT_CONFIG_UPDATED");
        self:RegisterEvent("TRAIT_TREE_CURRENCY_INFO_UPDATED");
    end

    function SubModule:OnEvent(event, ...)
        if event == "SKILL_LINES_CHANGED" then
            self.isDirty = true;
            self:UnregisterEvent(event);
        else
            self.isDirty = true;
            self.unspentPoints1 = nil;
            self.unspentPoints2 = nil;
            self:UnregisterEvent(event);
        end
    end

    local function EnableModule(state)
        if state then
            SubModule:SetEnabled(true);
            GameTooltipManager:AddSubModule(SubModule);
        else
            SubModule:SetEnabled(false);
        end
    end

    local moduleData = {
        name = addon.L["ModuleName TooltipProfessionKnowledge"],
        dbKey = SubModule:GetDBKey(),
        description = addon.L["ModuleDescription TooltipProfessionKnowledge"],
        toggleFunc = EnableModule,
        categoryID = 3,
        uiOrder = 1152,
        moduleAddedTime = 1736940000,
    };

    addon.ControlCenter:AddModule(moduleData);
end