-- Extend search results (custom keywords)
-- Could be tainty?


local _, addon = ...


local ipairs = ipairs;
local find = string.find;
local strtrim = strtrim;
local strlenutf8 = strlenutf8;
local GetRecipeItemNameFilter = C_TradeSkillUI.GetRecipeItemNameFilter;
local GetChildProfessionInfo = C_TradeSkillUI.GetChildProfessionInfo;
local GetFilteredRecipeIDs_Old = C_TradeSkillUI.GetFilteredRecipeIDs;
local GetRecipeSchematic = C_TradeSkillUI.GetRecipeSchematic;


local MainFrame;

local Def = {
    UIMinWidth = 210,   --274
    UIMinHeight = 40,
    UIMaxHeight = 100,

    ButtonWidth = 200,
    ButtonHeight = 20,
    ListPaddingV = 4;
};


local ProfessionModule = {};
do  --ProfessionModule
    local NameRecipeIDList;

    local function LoadDyeNames()
        if not NameRecipeIDList then
            NameRecipeIDList = {};
            local GetDyeColorInfo = C_DyeColor.GetDyeColorInfo;
            local n = 0;
            for recipeID, dyeColors in pairs(addon.Housing.GetPigmentRecipes()) do
                for _, dyeColorID in ipairs(dyeColors) do
                    local info = GetDyeColorInfo(dyeColorID);
                    if info and info.name then
                        n = n + 1;
                        NameRecipeIDList[n] = {
                            string.lower(info.name),
                            recipeID,
                        };
                    end
                end
            end
        end
    end

    local function FindPigmentByDyeName(tbl, text)
        text = text and strtrim(text) or "";
        if text ~= "" then
            LoadDyeNames();
            local addedID = {};
            local recipeID;
            local n = #tbl;
            for _, v in ipairs(NameRecipeIDList) do
                if find(v[1], text, 1, true) then
                    recipeID = v[2];
                    if not addedID[recipeID] then
                        addedID[recipeID] = true;
                        n = n + 1;
                        tbl[n] = recipeID;
                    end
                end
            end
        end
    end

    ProfessionModule[3] = FindPigmentByDyeName;     --Alchemy
end


local function GetFilteredRecipeIDs_New()
    local info = GetChildProfessionInfo();
    if info and info.profession and ProfessionModule[info.profession] then
        local tbl = GetFilteredRecipeIDs_Old() or {};
        local text = GetRecipeItemNameFilter(); --already lowercased
        ProfessionModule[info.profession](tbl, text)

        return tbl
    else
        return GetFilteredRecipeIDs_Old()
    end
end

--Dangerous API overwrite!!!
--C_TradeSkillUI.GetFilteredRecipeIDs = GetFilteredRecipeIDs_New;

--local CraftingPage = ProfessionsFrame.CraftingPage;   --MinimizedSearchBox, RecipeList.SearchBox


local function OpenToRecipe(recipeID)
    local recipeInfo = recipeID and C_TradeSkillUI.GetRecipeInfo(recipeID);
    if recipeInfo then
        local skipSelectInList = true;
        ProfessionsFrame.CraftingPage:SelectRecipe(recipeInfo, skipSelectInList);
    end
end

local CreateListButton;
do
    local RecipeListButtonMixin = {};

    function RecipeListButtonMixin:OnClick()
        OpenToRecipe(self.recipeID);
    end

    function RecipeListButtonMixin:OnEnter()
        self:UpdateVisual();
    end

    function RecipeListButtonMixin:OnLeave()
        self:UpdateVisual();
    end

    function RecipeListButtonMixin:UpdateVisual()
        --PROFESSION_RECIPE_COLOR
        if self:IsMouseMotionFocus() then
            self.Label:SetTextColor(1, 1, 1);
        else
            self.Label:SetTextColor(0.886, 0.863, 0.839);
        end
    end

    function RecipeListButtonMixin:SetRecipe(recipeID)
        local info = GetRecipeSchematic(recipeID, false);
        if info then
            self.recipeID = recipeID;
            self.Label:SetText(info.name);
        else
            self.recipeID = nil;
            self.Label:SetText(UNKNOWN);
        end
        self:UpdateVisual();
    end


    function CreateListButton(parent)
        local f = CreateFrame("Button", nil, parent);
        Mixin(f, RecipeListButtonMixin);

        f:SetSize(Def.ButtonWidth, Def.ButtonHeight);
        f.Label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight_NoShadow");
        f.Label:SetJustifyH("LEFT");
        f.Label:SetPoint("LEFT", f, "LEFT", 8, 0);
        f.Label:SetPoint("RIGHT", f, "RIGHT", -16, 0);
        f.Label:SetMaxLines(1);

        f.Highlight = f:CreateTexture(nil, "HIGHLIGHT");
        f.Highlight:SetPoint("CENTER", f, "CENTER", 0, -1);
        f.Highlight:SetAtlas("Professions_Recipe_Hover", true);
        f.Highlight:SetAlpha(0.5);

        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);

        return f
    end
end



local SearchSuggestionUIMixin = {};
do
    function SearchSuggestionUIMixin:RequestUpdate()
        self.UpdateFrame.t = 0;
        self.UpdateFrame:SetScript("OnUpdate", self.OnUpdate);
    end

    function SearchSuggestionUIMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t > 0.05 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            MainFrame:ShowResult();
        end
    end

    function SearchSuggestionUIMixin:ShowResult()
        self.firstRecipeID = nil;
        local info = GetChildProfessionInfo();
        if info and info.profession and ProfessionModule[info.profession] then
            local recipeIDs = {};
            local text = GetRecipeItemNameFilter(); --already lowercased
            if strlenutf8(text) > 1 then
                ProfessionModule[info.profession](recipeIDs, text);
                if #recipeIDs > 0 then
                    self:DisplayList(recipeIDs);
                    return
                end
            end
        end
        self:Hide();
    end

    function SearchSuggestionUIMixin:DisplayList(recipeIDs)
        local top, bottom;
        local n = 0;
        local offsetY = Def.ListPaddingV;
        local content = {};

        for _, recipeID in ipairs(recipeIDs) do
            top = offsetY;
            bottom = top + Def.ButtonHeight;
            n = n + 1;
            if n == 1 then
                self.firstRecipeID = recipeID;
            end
            content[n] = {
                dataIndex = n,
                templateKey = "ListButton",
                top = top,
                bottom = bottom,
                point = "TOPLEFT",
                relativePoint = "TOPLEFT",
                offsetX = 1,
                setupFunc = function(obj)
                    obj:SetRecipe(recipeID);
                end
            };
            offsetY = bottom;
        end

        if self:DockToBestSearchBox() then
            self:Show();
            self:AdjustFrameLevel();
            local height = n * Def.ButtonHeight + 2 * Def.ListPaddingV + 4;
            self:SetHeight(math.min(height, Def.UIMaxHeight));
        end

        self.ScrollView:OnSizeChanged();
        self.ScrollView:SetContent(content);
    end

    function SearchSuggestionUIMixin:AdjustFrameLevel()
        local baseLevel = 200;
        self:SetFrameLevel(baseLevel);
        self.Background:SetFrameLevel(baseLevel);
        self.ScrollView:SetFrameLevel(baseLevel + 10);
        self.ScrollBar:SetFrameLevel(baseLevel + 15);
    end

    function SearchSuggestionUIMixin:DockToBestSearchBox()
        for _, f in ipairs(self.searchBoxes) do
            if f:IsVisible() then
                self:ClearAllPoints();
                self:SetPoint("BOTTOMLEFT", f, "TOPLEFT", f.plumberMenuOffsetX, 4);
                self:Show();
                self.plumberEnableEnter = f.plumberEnableEnter;
                return true
            end
        end
    end

    function SearchSuggestionUIMixin:OnEnterPressed()
        if self:IsVisible() and self.plumberEnableEnter then
            if self.firstRecipeID then
                OpenToRecipe(self.firstRecipeID);
            end
        end
    end
end


local function HideUI()
    if MainFrame then
        MainFrame:Hide();
        MainFrame:ClearAllPoints();
    end
end

local function CreateUI()
    if MainFrame then return end;

    MainFrame = CreateFrame("Frame", nil, UIParent);
    Mixin(MainFrame, SearchSuggestionUIMixin);
    MainFrame:Hide();
    MainFrame:SetSize(Def.UIMinWidth, Def.UIMaxHeight);
    MainFrame.searchBoxes = {};

    MainFrame.UpdateFrame = CreateFrame("Frame");

    MainFrame.Background = addon.CreateNineSliceFrame(MainFrame, "NineSlice_DarkBrownBox");
    MainFrame.Background:SetCornerSize(8);
    MainFrame.Background:CoverParent(0);


    local ScrollBar = addon.ControlCenter.CreateScrollBarWithDynamicSize(MainFrame);
    ScrollBar:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", 0, -2)
    ScrollBar:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 2);
    MainFrame.ScrollBar = ScrollBar;
    ScrollBar:UpdateThumbRange();


    local ScrollView = addon.API.CreateScrollView(MainFrame, ScrollBar);
    MainFrame.ScrollView = ScrollView;
    ScrollBar.ScrollView = ScrollView;
    ScrollView:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 0, -2);
    ScrollView:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 2);
    ScrollView:SetStepSize(Def.ButtonHeight * 2);
    ScrollView:OnSizeChanged();
    ScrollView:SetBottomOvershoot(Def.ListPaddingV);


    local function ListButton_Create()
        local obj = CreateListButton(ScrollView);
        return obj
    end

    ScrollView:AddTemplate("ListButton", ListButton_Create);
end


local function SearchBox_OnTextChanged(self, userInput)
    MainFrame:RequestUpdate();
end

local function SearchBox_OnEnterPressed(self, userInput)
    MainFrame:OnEnterPressed();
end

local function HookSearchBox(searchBox, offsetX, hookEnter)
    if searchBox then
        searchBox:HookScript("OnTextChanged", SearchBox_OnTextChanged);
        searchBox.plumberMenuOffsetX = offsetX;
        table.insert(MainFrame.searchBoxes, searchBox);

        if hookEnter then
            searchBox:HookScript("OnEnterPressed", SearchBox_OnEnterPressed);
        end
        searchBox.plumberEnableEnter = hookEnter;
    end
end

local function Blizzard_Professions_OnLoaded()
    CreateUI();

    local CraftingPage = ProfessionsFrame.CraftingPage;

    HookSearchBox(CraftingPage.RecipeList.SearchBox, -3, true);
    HookSearchBox(CraftingPage.MinimizedSearchBox, -40);    --Avoide Maximize/Close buttons

    CraftingPage:HookScript("OnHide", function()
        HideUI();
    end);

    MainFrame:SetParent(CraftingPage);
    MainFrame:SetFrameStrata("HIGH");
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_Professions", Blizzard_Professions_OnLoaded);