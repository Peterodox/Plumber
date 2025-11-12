--Track: Blizzard_HousingTemplates/Blizzard_HousingCatalogFilters.lua


local _, addon = ...
local API = addon.API;


local After = C_Timer.After;


local REF_UNIT = 0.52336;   --Banana Length


local MODULE_ENABLED = false;
local SHOW_REF_MODEL = false;
local MODEL_DB_KEY = "Test_ModuleScaleRef_ShowBanana";


local RefActors = {};
local FooterFrames = {};


local function Round(n)
    return math.floor(n * 1000 + 0.5) / 1000
end

local function ShowRefs(state)
    if state then
        for _, actor in ipairs(RefActors) do
            actor:Show();
        end
    else
        for _, actor in ipairs(RefActors) do
            actor:Hide();
        end
    end
end

local function ToggleRefs()
    SHOW_REF_MODEL = not SHOW_REF_MODEL;
    addon.SetDBValue(MODEL_DB_KEY, SHOW_REF_MODEL, true);
    ShowRefs(SHOW_REF_MODEL);
end

local function GetActorDimensions(actor)
    local bottomX, bottomY, bottomZ, topX, topY, topZ = actor:GetActiveBoundingBox();
    if bottomX and bottomY and bottomZ and topX and topY and topZ then
        local width = topX - bottomX;
        local depth = topY - bottomY;
        local height = topZ - bottomZ;
        return width, depth, height
    end
end

local function OnModelLoadedCallback(self)
    if MODULE_ENABLED then
        After(0, function()
            local scale = self:GetScale();
            local width, depth, height = GetActorDimensions(self);
            if height and self.plumberRefActor then
                self.plumberRefActor:SetScale(scale);
                self.plumberRefActor:SetPosition(0, 0, 0.5 * height);
                if SHOW_REF_MODEL then
                    self.plumberRefActor:Show();
                else
                    self.plumberRefActor:Hide();
                end

                local l = string.format("%.2f", Round(depth / REF_UNIT));
                local w = string.format("%.2f", Round(width / REF_UNIT));
                local h = string.format("%.2f", Round(height / REF_UNIT));
                --print(string.format("%s x %s x %s ba", l, w, h))

                self.plumberRefActor.FooterFrame:SetText(string.format("%s x %s x %s ba", l, w, h));
            end
        end);
    end
end

local function GetDeltaModifierForCameraMode(self, mode)
    if mode == 1 then
        return .008;
    elseif mode == 2 then
        return -.008;   --Reverse Pitch
    elseif mode == 3 then
        return .008;
    elseif mode == 4 then
        return .1;
    elseif mode == 5 then
        return .05;
    elseif mode == 6 then
        return .05;
    elseif mode == 7 then
        return 0.93;
    elseif mode == 8 then
        return 0.93;
    end
    return 0.0;
end


local FooterFrameMixin = {};
do
    local function OnUpdate_FadeIn(self, elapsed)
        self.alpha = self.alpha + 5 * elapsed;
        if self.alpha >= 1 then
            self.alpha = 1;
            self:SetScript("OnUpdate", nil);
        end
        self:SetAlpha(self.alpha)
    end

    local function OnUpdate_FadeOut(self, elapsed)
        self.alpha = self.alpha - 5 * elapsed;
        if self.alpha <= 0.5 then
            self.alpha = 0.5;
            self:SetScript("OnUpdate", nil);
        end
        self:SetAlpha(self.alpha)
    end

    function FooterFrameMixin:SetText(text)
        self.Text:SetText(text);
        local textWidth = self.Text:GetWrappedWidth();

        local fullSize = textWidth;
        local leftOffset = 0.5 * fullSize;
        self.Text:ClearAllPoints();
        self.Text:SetPoint("LEFT", self, "CENTER", -leftOffset, 0);

        self.BananaButton:Show();
        self:SetWidth(fullSize);

        local numButtons = 6;
        local buttonHorizontalPadding = -6;
        self.controlFrame:SetWidth(-2 + (32 + buttonHorizontalPadding) * numButtons - buttonHorizontalPadding);
    end

    function FooterFrameMixin:UpdateButton()

    end

    function FooterFrameMixin:UpdateAlpha()
        self.alpha = self:GetAlpha();
        if self:IsMouseMotionFocus() or self.BananaButton:IsMouseMotionFocus() then
            self:SetScript("OnUpdate", OnUpdate_FadeIn);
        else
            self:SetScript("OnUpdate", OnUpdate_FadeOut);
        end
    end

    function FooterFrameMixin:OnEnter()
        self:UpdateAlpha();
    end

    function FooterFrameMixin:OnLeave()
        self:UpdateAlpha();
    end

    function FooterFrameMixin:OnLoad()
        self:SetAlpha(0.5);
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
    end
end


local BananaButtonMixin = {};
do
    function BananaButtonMixin:OnEnter()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText("Toggle Banana");
        GameTooltip:Show();
        self:GetParent():UpdateAlpha();
    end

    function BananaButtonMixin:OnLeave()
        GameTooltip:Hide();
        self:GetParent():UpdateAlpha();
    end

    function BananaButtonMixin:OnClick()
        ToggleRefs();
    end

    function BananaButtonMixin:OnMouseDown()
        self.Icon:SetPoint("CENTER", 1, -1);
    end

    function BananaButtonMixin:OnMouseUp()
        self.Icon:SetPoint("CENTER", 0, 0);
    end

    function BananaButtonMixin:OnShow()
        self:Update();
    end

    function BananaButtonMixin:Update()
        if SHOW_REF_MODEL then
            self.Icon:SetVertexColor(1, 1, 1);
            self.Icon:SetDesaturated(false);
        else
            self.Icon:SetVertexColor(0.72, 0.72, 0.72);
            self.Icon:SetDesaturated(true);
        end
    end

    function BananaButtonMixin:OnLoad()
        self.Icon:SetTexture("Interface/AddOns/Plumber/Art/Button/BananaButton.png");
        self.Icon:SetTexCoord(0, 48/128, 0, 48/128);

        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnClick", self.OnClick);
        self:SetScript("OnMouseDown", self.OnMouseDown);
        self:SetScript("OnMouseUp", self.OnMouseUp);
        self:SetScript("OnShow", self.OnShow);

        addon.CallbackRegistry:RegisterSettingCallback(MODEL_DB_KEY, self.Update, self);
        self:Update();
    end
end


local function ModelScene_OnUpdate(self, elapsed)
	if self.activeCamera then
		local yawDirection = self.yawDirection;
		local increment = self.increment;
		if yawDirection == "left" then
			self.activeCamera:AdjustYaw(-1, 0, increment);  --AdjustYaw(-1, -1, increment)
		elseif yawDirection == "right" then
			self.activeCamera:AdjustYaw(1, 0, increment);   --AdjustYaw(1, 1, increment)
		end

		self.activeCamera:OnUpdate(elapsed);
	end
end

local function SharedPreviewFrame_OnLoad(previewFrame)
    local modelScene = previewFrame.ModelScene;

    local tag = "decor";
    local actor = modelScene:GetActorByTag(tag);
    if not actor then return end;


    --NEW_ACTOR = ModelScene:CreateActor(nil, "PlumberHousingDecorActorTemplate");
    --ModelScene.tagToActor[tag] = NEW_ACTOR;
    actor:SetOnModelLoadedCallback(OnModelLoadedCallback);


    local refActor = modelScene:CreateActor();
    refActor:SetModelByFileID(528752);
    refActor:SetYaw(math.pi * 0.5);
    refActor:Hide();
    actor.plumberRefActor = refActor;
    table.insert(RefActors, refActor);


    if previewFrame.PreviewCatalogEntryInfo then
        hooksecurefunc(previewFrame, "PreviewCatalogEntryInfo", function()
            refActor:Hide();
        end);
    end

    if previewFrame.ClearPreviewData then
        hooksecurefunc(previewFrame, "ClearPreviewData", function()
            refActor:Hide();
        end);
    end

    modelScene:SetScript("OnUpdate", ModelScene_OnUpdate);


    local activeCamera = modelScene:GetActiveCamera();
    if activeCamera then
        activeCamera.GetDeltaModifierForCameraMode = GetDeltaModifierForCameraMode;
        activeCamera:SetLeftMouseButtonYMode(ORBIT_CAMERA_MOUSE_MODE_PITCH_ROTATION, true);
    end


    local controlFrame = previewFrame.ModelSceneControls;
    controlFrame:SetPoint("BOTTOM", 0, 8);


    local FooterFrame = CreateFrame("Frame", nil, modelScene);
    FooterFrame:SetSize(24, 32);
    FooterFrame:SetPoint("BOTTOM", previewFrame, "BOTTOM", 0, 32);
    Mixin(FooterFrame, FooterFrameMixin);
    FooterFrame:OnLoad();
    table.insert(FooterFrames, FooterFrame);
    FooterFrame.controlFrame = controlFrame;
    refActor.FooterFrame = FooterFrame;

    FooterFrame.Text = FooterFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    FooterFrame.Text:SetPoint("LEFT", FooterFrame, "LEFT", 0, 0);

    local BananaButton = CreateFrame("Button", nil, FooterFrame, "PlumberModelSceneControlButtonTemplate");
    FooterFrame.BananaButton = BananaButton;
    BananaButton:SetPoint("LEFT", controlFrame.resetButton, "RIGHT", -2, 0);
    BananaButton:Hide();
    Mixin(BananaButton, BananaButtonMixin);
    BananaButton:OnLoad();
end

local function HousingDashboard_OnLoad()
    local modelScene = API.GetGlobalObject("HousingDashboardFrame.CatalogContent.PreviewFrame.ModelScene");
    if not modelScene then return end;
    SharedPreviewFrame_OnLoad(HousingDashboardFrame.CatalogContent.PreviewFrame);
end

local function HousingModelPreview_OnLoad()
    local modelScene = API.GetGlobalObject("HousingModelPreviewFrame.ModelPreview.ModelScene");
    if not modelScene then return end;
    SharedPreviewFrame_OnLoad(HousingModelPreviewFrame.ModelPreview);
end


local BlizzardAddOns = {
    {name = "Blizzard_HousingDashboard", callback = HousingDashboard_OnLoad},
    {name = "Blizzard_HousingModelPreview", callback = HousingModelPreview_OnLoad},
};


do
    local function EnableModule(state)
        SHOW_REF_MODEL = addon.GetDBBool(MODEL_DB_KEY);
        if state then
            for _, v in ipairs(BlizzardAddOns) do
                if not v.registered then
                    v.registered = true;
                    if C_AddOns.IsAddOnLoaded(v.name) then
                        v.callback();
                    else
                        EventUtil.ContinueOnAddOnLoaded(v.name, v.callback);
                    end
                end
            end
            for _, frame in ipairs(FooterFrames) do
                frame:Show();
            end
            MODULE_ENABLED = true;
        else
            MODULE_ENABLED = false;
            ShowRefs(false);
            for _, frame in ipairs(FooterFrames) do
                frame:Hide();
            end
        end
    end

    local moduleData = {
        name = "Decor Catalog: Banana For Scale",
        dbKey ="Test_ModuleScaleRef",
        description = "- Add a size reference (a banana) to the decor preview window, allowing you to gauge the size of the objects.\n\n- Also allow you to change the camera pitch by holding down the Left Button and moving vertically.",
        toggleFunc = EnableModule,
        categoryID = -2,
        uiOrder = 1,
        moduleAddedTime = 1762900000,
    };

    addon.ControlCenter:AddModule(moduleData);
end




--[[
PlumberHousingDecorActorMixin = CreateFromMixins(ModelSceneActorMixin);
do
    function PlumberHousingDecorActorMixin:OnModelLoaded()
        print("LOADED")
    end
end
--]]