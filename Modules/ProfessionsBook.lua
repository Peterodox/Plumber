-- Show unspent points on the ProfessionsBookFrame

local _, addon = ...
local L = addon.L
local API = addon.API;


local GetProfessions = GetProfessions;
local GetProfessionInfo = GetProfessionInfo;
local C_TradeSkillUI = C_TradeSkillUI;
local C_ProfSpecs = C_ProfSpecs;
local C_Traits = C_Traits;


local EL = CreateFrame("Frame");


local function GetPrimaryProfessionID(index)
    local prof = select(index, GetProfessions());
    if prof then
        local subcateogryName = select(11, GetProfessionInfo(prof));
        if not subcateogryName or subcateogryName == "" then return end;

        local info;
        local skillLines = C_TradeSkillUI.GetAllProfessionTradeSkillLines();

        for i, skillLine in ipairs(skillLines) do
            info = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLine)
            if info and info.professionName == subcateogryName then
                return skillLine, info.professionName
            end
        end
    end
end


local function GetProfessionUnspentPoints(index)
    local professionID, progressionName = GetPrimaryProfessionID(index);
    if professionID then
        local configID = C_ProfSpecs.GetConfigIDForSkillLine(professionID);
        local tabTreeIDs = C_ProfSpecs.GetSpecTabIDsForSkillLine(professionID);
        local excludeStagedChangesForCurrencies = false;
        local tabCurrencyCount = {};
        local total = 0;

        for treeOrder, treeID in ipairs(tabTreeIDs) do
            local tabInfo = C_ProfSpecs.GetTabInfo(treeID);
            local tabSpendCurrency = C_ProfSpecs.GetSpendCurrencyForPath(tabInfo.rootNodeID);
            if not (tabCurrencyCount[tabSpendCurrency]) then
                local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configID, treeID, excludeStagedChangesForCurrencies);
                local treeCurrencyInfoMap = {};
                for _, treeCurrency in ipairs(treeCurrencyInfo) do
                    treeCurrencyInfoMap[treeCurrency.traitCurrencyID] = treeCurrency;
                end
                local currencyInfo = treeCurrencyInfoMap[tabSpendCurrency];
                local currencyCount = currencyInfo and currencyInfo.quantity or 0;
                tabCurrencyCount[tabSpendCurrency] = currencyCount;
                total = total + currencyCount;
            end
        end

        return total
    end
end

local PointsDisplayMixin = {};
do
    function PointsDisplayMixin:SetPoints(points)
        if points and points > 0 then
            self.points = points;
            if points > 99 then
                points = 99;
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
    if self.t > 0.5 then
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
    end
end

function EL:CreateWidgets()
    if not self.blizFrameFound then return end;

    if not self.widgets then
        local BlizFrame = ProfessionsBookFrame;
        if BlizFrame then
            self.widgets = {};
            for i = 1, 2 do
                local widget = CreateFrame("Frame", nil, BlizFrame);
                API.Mixin(widget, PointsDisplayMixin);
                widget:OnLoad();
                widget:Hide();
                local parent = _G[string.format("PrimaryProfession%dSpellButtonBottom", i )];
                if parent then
                    widget:SetPoint("RIGHT", parent, "TOPLEFT", 5, -6);
                    widget:SetFrameLevel(parent:GetFrameLevel() + 2);
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
        if EL.enabled and EL.blizFrameFound and ProfessionsBookFrame:IsShown() then
            EL:ListenEvents(true);
            EL:CreateWidgets();
            EL:UpdateCurrency();
        end
    end);
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