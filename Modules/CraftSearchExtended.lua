-- Extend search results (custom keywords)


local _, addon = ...
local API = addon.API;


local ipairs = ipairs;
local find = string.find;
local strtrim = strtrim;
local strlenutf8 = strlenutf8;
local GetRecipeItemNameFilter = C_TradeSkillUI.GetRecipeItemNameFilter;
local GetChildProfessionInfo = C_TradeSkillUI.GetChildProfessionInfo;
local GetFilteredRecipeIDs_Old = C_TradeSkillUI.GetFilteredRecipeIDs;
local GetRecipeSchematic = C_TradeSkillUI.GetRecipeSchematic;


local MODULE_ENABLED = false;
local MainFrame;

local Def = {
    UIMinWidth = 240,   --274
    UIMinHeight = 40,
    UIMaxHeight = 100,

    ButtonWidth = 230,
    ButtonHeight = 20,
    ListPaddingV = 4;

    ResultFormat = "%s, |cff808080%s|r",
};


local ProfessionModule = {};
do  --ProfessionModule
    local NameRecipeIDList_Alchemy;
    local NameRecipeIDList_Inscription;


    local function LoadDyeNames(profession)
        local GetDyePigmentName = addon.Housing.GetDyePigmentName;
        local GetDyeColorInfo = C_DyeColor.GetDyeColorInfo;
        local tbl = {};
        local n = 0;

        local UtilityFontString = MainFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight_NoShadow");
        UtilityFontString:SetJustifyH("LEFT");
        UtilityFontString:SetPoint("TOP", UIParent, "BOTTOM", 0, -4);

        for recipeID, dyeColors in pairs(addon.Housing.GetPigmentRecipes(profession)) do
            local schematic = GetRecipeSchematic(recipeID, false);
            local recipeName = schematic.name;
            for _, dyeColorID in ipairs(dyeColors) do
                local info = GetDyeColorInfo(dyeColorID);
                if info and info.name then
                    local colorName = info.name;
                    local pigmentName = GetDyePigmentName(dyeColorID) or recipeName;
                    local labelText = Def.ResultFormat:format(pigmentName, colorName);
                    UtilityFontString:SetText(labelText);
                    local buttonWidth = 20 + math.ceil(UtilityFontString:GetWrappedWidth());
                    n = n + 1;
                    tbl[n] = {
                        string.lower(colorName),
                        recipeID,
                        labelText,
                        buttonWidth,
                    };
                end
            end
        end

        return tbl
    end

    local function FindPigmentByDyeName(tbl, text, sourceList)
        text = text and strtrim(text) or "";
        if text ~= "" then
            local addedID = {};
            local recipeID;
            local n = #tbl;
            for _, v in ipairs(sourceList) do
                if find(v[1], text, 1, true) then
                    recipeID = v[2];
                    if not addedID[recipeID] then
                        addedID[recipeID] = true;
                        n = n + 1;
                        tbl[n] = {recipeID, v[3], v[4]};
                    end
                end
            end
        end
    end


    local function FindPigment_Alchemy(tbl, text)
        if not NameRecipeIDList_Alchemy then
            NameRecipeIDList_Alchemy = {};
            NameRecipeIDList_Alchemy = LoadDyeNames("Alchemy");
        end
        FindPigmentByDyeName(tbl, text, NameRecipeIDList_Alchemy);
    end
    ProfessionModule[3] = FindPigment_Alchemy;

    local function FindPigment_Inscription(tbl, text)
        if not NameRecipeIDList_Inscription then
            NameRecipeIDList_Inscription = {};
            NameRecipeIDList_Inscription = LoadDyeNames("Inscription");
        end
        FindPigmentByDyeName(tbl, text, NameRecipeIDList_Inscription);
    end
    ProfessionModule[13] = FindPigment_Inscription;
end


do  --Deprecated Global API Overwrite
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

    --C_TradeSkillUI.GetFilteredRecipeIDs = GetFilteredRecipeIDs_New;
end


local function OpenToRecipe(recipeID)
    local recipeInfo = recipeID and C_TradeSkillUI.GetRecipeInfo(recipeID);
    if recipeInfo then
        C_TradeSkillUI.SetRecipeItemNameFilter(recipeInfo.name);
        C_Timer.After(0, function()
            C_TradeSkillUI.OpenRecipe(recipeID);    --This API find recipe on the Filtered list!
        end);
    end

    --ProfessionsUtil.OpenProfessionFrameToRecipe(recipeID);  --Taint after clicking Minimize button
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

    function RecipeListButtonMixin:SetRecipe(recipeID, labelText)
        local info = GetRecipeSchematic(recipeID, false);
        if info then
            self.recipeID = recipeID;
            self.Label:SetText(labelText);
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
        f.Label:SetPoint("RIGHT", f, "RIGHT", -12, 0);
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
        local maxButtonWidth = 160;

        for _, v in ipairs(recipeIDs) do
            if v[3] > maxButtonWidth then
                maxButtonWidth = v[3];
            end
        end

        for _, v in ipairs(recipeIDs) do
            top = offsetY;
            bottom = top + Def.ButtonHeight;
            local recipeID = v[1];
            local matchedWord = v[2];

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
                    obj:SetWidth(maxButtonWidth);
                    obj:SetRecipe(recipeID, matchedWord);
                end
            };
            offsetY = bottom;
        end

        if self:DockToBestSearchBox() then
            self:Show();
            self:AdjustFrameLevel();
        end

        local frameWidth = maxButtonWidth;
        if n > 4 then
            frameWidth = frameWidth + 12;
        end

        local height = n * Def.ButtonHeight + 2 * Def.ListPaddingV + 4;
        self:SetSize(frameWidth, math.min(height, Def.UIMaxHeight));

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
                self.hasStickyFocus = f.HasStickyFocus ~= nil;
                if self.hasStickyFocus then --MinimizedSearchBox
                    self:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", f.plumberMenuOffsetX, 4);
                else
                    self:SetPoint("BOTTOMLEFT", f, "TOPLEFT", f.plumberMenuOffsetX, 4);
                end
                self:Show();
                return true
            end
        end
    end

    function SearchSuggestionUIMixin:SetSearchBoxText(text)
        for _, f in ipairs(self.searchBoxes) do
            if f:IsVisible() then
                f:SetText(text);
                return
            end
        end
    end

    function SearchSuggestionUIMixin:OnEnterPressed()
        if self:IsVisible() then
            if self.firstRecipeID then
                if self.hasStickyFocus then
                    local list = GetFilteredRecipeIDs_Old();
                    if list and #list > 1 then
                        return
                    end
                end
                OpenToRecipe(self.firstRecipeID);
            end
        end
    end
end


local function SearchBox_OnTextChanged(self, userInput)
    if MainFrame and MODULE_ENABLED then
        MainFrame:RequestUpdate();
    end
end

local function SearchBox_OnEnterPressed(self, userInput)
    if MainFrame and MODULE_ENABLED then
        MainFrame:OnEnterPressed();
    end
end

local function HookSearchBox(searchBox, offsetX)
    if searchBox then
        searchBox:HookScript("OnTextChanged", SearchBox_OnTextChanged);
        searchBox.plumberMenuOffsetX = offsetX;
        table.insert(MainFrame.searchBoxes, searchBox);
        searchBox:HookScript("OnEnterPressed", SearchBox_OnEnterPressed);
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


    local ScrollView = API.CreateScrollView(MainFrame, ScrollBar);
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


    MainFrame:SetScript("OnShow", SearchBox_OnTextChanged);
end




local function Blizzard_Professions_OnLoaded()
    if MainFrame then return end;

    CreateUI();

    local CraftingPage = ProfessionsFrame.CraftingPage;

    HookSearchBox(CraftingPage.RecipeList.SearchBox, -3);
    HookSearchBox(CraftingPage.MinimizedSearchBox, -38);    --Avoide Maximize/Close buttons

    MainFrame:SetParent(CraftingPage);
    MainFrame:SetFrameStrata("HIGH");
    MainFrame:SetFixedFrameStrata(true);
end



do  --Module Registry
    local DummyOwner = {};

    local function EnabledModule(state)
        MODULE_ENABLED = state;
        if state then
            local blizzardAddonName = "Blizzard_Professions";
            if C_AddOns.IsAddOnLoaded(blizzardAddonName) then
                Blizzard_Professions_OnLoaded();
            else
                if not DummyOwner.callbackAdded then
                    DummyOwner.callbackAdded = true;
                    EventUtil.ContinueOnAddOnLoaded("Blizzard_Professions", Blizzard_Professions_OnLoaded);
                end
            end

            EventRegistry:RegisterCallback("ProfessionsFrame.Minimized", SearchBox_OnTextChanged, DummyOwner);
        else
            EventRegistry:UnregisterCallback("ProfessionsFrame.Minimized", DummyOwner);
            HideUI();
        end
    end

    local moduleData = {
        name = addon.L["ModuleName CraftSearchExtended"],
        dbKey = "CraftSearchExtended",
        description = addon.L["ModuleDescription CraftSearchExtended"],
        categoryID = 1,
        uiOrder = 1,
        toggleFunc = EnabledModule,
        moduleAddedTime = 1765500000,
		categoryKeys = {
			"Profession",
		},
        searchTags = {
            "Housing",
        },
    };

    addon.ControlCenter:AddModule(moduleData);
end