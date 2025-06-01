local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;
local LandingPageUtil = addon.LandingPageUtil;
local GetActivityName = LandingPageUtil.GetActivityName;
local ShouldShowActivity = LandingPageUtil.ShouldShowActivity;


local ReadyForTurnIn = C_QuestLog.ReadyForTurnIn;


local ActivityTab;
local SortedActivityData;


local CreateChecklistButton;
do  --Checklist Button
    local TEXTURE = "Interface/AddOns/Plumber/Art/Frame/ChecklistButton.tga";

    local ChecklistButtonMixin = {};

    function ChecklistButtonMixin:OnEnter()
        self:UpdateBackground();
    end

    function ChecklistButtonMixin:OnLeave()
        self:UpdateBackground();
    end

    function ChecklistButtonMixin:OnClick()
        if self.isHeader then
            self:ToggleCollapsed();
        end
    end

    function ChecklistButtonMixin:SetBackgroundColor(r, g, b)
        self.Left:SetVertexColor(r, g, b);
        self.Right:SetVertexColor(r, g, b);
        self.Center:SetVertexColor(r, g, b);
    end


    function ChecklistButtonMixin:UpdateBackground()
        if self:IsMouseMotionFocus() then
            self.Left:SetTexCoord(0/512, 64/512, 128/512, 192/512);
            self.Right:SetTexCoord(448/512, 512/512, 128/512, 192/512);
            self.Center:SetTexCoord(64/512, 448/512, 128/512, 192/512);
            self.Name:SetTextColor(1, 1, 1);
        else
            if self.isOdd then
                self.Left:SetTexCoord(0/512, 64/512, 64/512, 128/512);
                self.Right:SetTexCoord(448/512, 512/512, 64/512, 128/512);
                self.Center:SetTexCoord(64/512, 448/512, 64/512, 128/512);
            else
                self.Left:SetTexCoord(0/512, 64/512, 0/512, 64/512);
                self.Right:SetTexCoord(448/512, 512/512, 0/512, 64/512);
                self.Center:SetTexCoord(64/512, 448/512, 0/512, 64/512);
            end
            if self.isHeader or self.completed then
                self.Name:SetTextColor(0.6, 0.6, 0.6);
            elseif self.readyForTurnIn then
                self.Name:SetTextColor(0.098, 1.000, 0.098);
            else
                self.Name:SetTextColor(0.92, 0.92, 0.92);
            end
        end
    end

    function ChecklistButtonMixin:SetHeader()
        self.id = nil;
        self.type = "Header";

        self.isHeader = true;
        self.readyForTurnIn = nil;
        self.flagQuest = nil;
        self.Icon:SetTexture(TEXTURE);
        self.Name:SetTextColor(0.6, 0.6, 0.6);
        self.Name:SetWidth(0);
        self.Name:SetMaxLines(1);
        self.Text1:SetText(nil);

        if self.isCollapsed then
            self.Icon:SetTexCoord(0, 48/512, 208/512, 256/512);
        else
            self.Icon:SetTexCoord(0, 48/512, 256/512, 208/512);
        end
    end

    function ChecklistButtonMixin:SetEntry()
        --Clear Atlas
        self.isHeader = nil;
        self.Icon:SetTexture(nil);
        self.Icon:SetTexCoord(0, 1, 0, 1);
        self.Name:SetTextColor(0.92, 0.92, 0.92);
        self.Name:SetWidth(240);
        self.Name:SetMaxLines(2);
    end

    function ChecklistButtonMixin:SetActivity(dataIndex, data)
        if not data then
            data = LandingPageUtil.GetActivityData(dataIndex);
        end

        if data then
            self.completed = data.completed;
            self.flagQuest = data.flagQuest or data.questID;

            if self.completed then
                self.Icon:SetAtlas("checkmark-minimal-disabled");
            elseif data.atlas then
                self.Icon:SetAtlas(data.atlas);
            elseif data.icon then
                self.Icon:SetTexCoord(6/64, 58/64, 6/64, 58/64);
                self.Icon:SetTexture(data.icon);
            else
                if not self.isHeader then
                    self.Icon:SetAtlas("questlog-questtypeicon-quest"); --debug
                end
            end

            if data.questID then
                self:SetQuest(data.questID);
            elseif data.itemID then
                self:SetItem(data.itemID);
            else
                self.type = nil;
                self.id = nil;
                self.Name:SetText(GetActivityName(dataIndex));
            end

            self:UpdateProgress();
        end
    end

    function ChecklistButtonMixin:UpdateProgress()
        if self.flagQuest then
            self.readyForTurnIn = ReadyForTurnIn(self.flagQuest);
            if self.readyForTurnIn then
                self.Icon:SetAtlas("QuestTurnin");
            end
        else
            self.readyForTurnIn = nil;
        end

        if self.type == "Quest" then
            if self.readyForTurnIn then
                self.Text1:SetText(nil);
            else
                local percentText = API.GetQuestProgressPercent(self.id, true);
                self.Text1:SetText(percentText);
            end
        else
            self.Text1:SetText(nil);
        end

        self:UpdateBackground();
    end

    function ChecklistButtonMixin:SetQuest(questID)
        self.type = "Quest";
        self.id = questID;

        self.Text1:SetText(nil);

        local name, isLocalized = GetActivityName(self.dataIndex);
        self.Name:SetText(name);
        if not isLocalized then
            CallbackRegistry:LoadQuest(questID, function(_questID)
                if questID == self.id then
                    local name = API.GetQuestName(_questID);
                    LandingPageUtil.StoreQuestActivityName(self.dataIndex, _questID, name);
                    self.Name:SetText(name);
                    self:UpdateProgress();
                end
            end);
        end
    end

    function ChecklistButtonMixin:SetItem(itemID)
        self.type = "Item";
        self.id = itemID;

        self.Text1:SetText(nil);

        local name, isLocalized = GetActivityName(self.dataIndex);
        self.Name:SetText(name);
        if not isLocalized then
            CallbackRegistry:LoadItem(itemID, function(_itemID)
                if _itemID == self.itemID then
                    local name = C_Item.GetItemNameByID(_itemID);
                    LandingPageUtil.StoreItemActivityName(self.dataIndex, _itemID, name);
                    self.Name:SetText(name);
                    self:UpdateProgress();
                end
            end);
        end
    end

    function ChecklistButtonMixin:ToggleCollapsed()
        local v = self.dataIndex and SortedActivityData[self.dataIndex]
        if v then
            v.isCollapsed = not v.isCollapsed;
            ActivityTab:FullUpdate();
        end
    end

    function CreateChecklistButton(parent)
        local f = CreateFrame("Button", nil, parent);
        f:SetSize(248, 24);

        API.SetupThreeSliceBackground(f, TEXTURE, -4, 4);
        f.Left:SetSize(32, 32);
        f.Left:SetTexCoord(0/512, 64/512, 0/512, 64/512);
        f.Right:SetSize(32, 32);
        f.Right:SetTexCoord(448/512, 512/512, 0/512, 64/512);
        f.Center:SetTexCoord(64/512, 448/512, 0/512, 64/512);

        f.Icon = f:CreateTexture(nil, "OVERLAY");
        f.Icon:SetSize(18, 18);
        f.Icon:SetPoint("CENTER", f, "LEFT", 16, 0);

        f.Name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Name:SetPoint("LEFT", f, "LEFT", 32, 0);
        f.Name:SetTextColor(0.92, 0.92, 0.92);
        f.Name:SetJustifyH("LEFT");

        f.Text1 = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Text1:SetPoint("RIGHT", f, "RIGHT", -96, 0);
        f.Text1:SetTextColor(0.92, 0.92, 0.92);
        f.Text1:SetJustifyH("CENTER");

        API.Mixin(f, ChecklistButtonMixin);
        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);

        return f
    end
end


local ActivityTabMixin = {};
do
    local DynamicEvents = {
        "QUEST_LOG_UPDATE",
        "QUEST_REMOVED",
        "QUEST_ACCEPTED",
        "QUEST_TURNED_IN",
    };

    function ActivityTabMixin:FullUpdate()
        self.fullUpdate = nil;

        local content = {};
        local n = 0;
        local buttonHeight = 24;
        local gap = 4;
        local offsetY = 16;

        local entryWidth = 544;
        local headerWidth = entryWidth + 62;

        local top, bottom;
        local showActivity, showGroup;

        SortedActivityData = LandingPageUtil.GetSortedActivity();

        for k, v in ipairs(SortedActivityData) do
            if v.isHeader then
                showActivity = true;
                showGroup = not v.isCollapsed;
            else
                showActivity = showGroup and ShouldShowActivity(v);
            end

            if showActivity then
                n = n + 1;
                local isOdd = n % 2 == 0;
                top = offsetY;
                bottom = offsetY + buttonHeight + gap;
                content[n] = {
                    templateKey = "ChecklistButton",
                    setupFunc = function(obj)
                        obj.dataIndex = v.dataIndex;
                        obj.isOdd = isOdd;
                        if v.isHeader then
                            obj:SetWidth(headerWidth);
                            obj.isCollapsed = v.isCollapsed;
                            obj:SetHeader();
                        else
                            obj:SetWidth(entryWidth);
                            obj:SetEntry();
                        end
                        obj:SetActivity(v.dataIndex, v);
                    end,
                    top = top,
                    bottom = bottom,
                };
                offsetY = bottom;
            end
        end

        local retainPosition = true;
        self.ScrollView:SetContent(content, retainPosition)
    end

    function ActivityTabMixin:OnShow()
        self:FullUpdate();
        API.RegisterFrameForEvents(self, DynamicEvents);
        self:SetScript("OnEvent", self.OnEvent);
    end

    function ActivityTabMixin:OnHide()
        self.t = nil;
        self:SetScript("OnUpdate", nil);
        API.UnregisterFrameForEvents(self, DynamicEvents);
        self:SetScript("OnEvent", nil);
        self:StopAnimating();
    end

    function ActivityTabMixin:OnEvent(event, ...)
        if event == "QUEST_LOG_UPDATE" then
            self:RequestUpdate();
        elseif event == "QUEST_REMOVED" or event == "QUEST_ACCEPTED" or event == "QUEST_TURNED_IN" then
            self:RequestUpdate(true);
        end
    end

    function ActivityTabMixin:InitChecklist()
        local ScrollView = API.CreateScrollView(self);
        self.ScrollView = ScrollView;
        ScrollView:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8);
        ScrollView:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 8);
        ScrollView:OnSizeChanged();
        ScrollView:SetStepSize(56);
        ScrollView:SetBottomOvershoot(28);
        ScrollView:EnableMouseBlocker(true);
        ScrollView:SetAllowOvershootAfterRangeChange(true);


        local function ChecklistButton_Create()
            return CreateChecklistButton(ScrollView)
        end

        local function ChecklistButton_OnAcquired(button)

        end
        local function ChecklistButton_OnRemoved(button)

        end

        ScrollView:AddTemplate("ChecklistButton", ChecklistButton_Create, ChecklistButton_OnAcquired, ChecklistButton_OnRemoved);
    end

    function ActivityTabMixin:UpdateScrollViewContent()
        if self.ScrollView then
            self.ScrollView:CallObjectMethod("ChecklistButton", "UpdateProgress");
        end
    end

    function ActivityTabMixin:RequestUpdate(fullUpdate)
        self.t = 0;
        self:SetScript("OnUpdate", self.OnUpdate);
        if fullUpdate then
            self.fullUpdate = true;
        end
    end

    function ActivityTabMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed;
        if self.t >= 0.2 then
            self.t = nil;
            self:SetScript("OnUpdate", nil);
            if self.fullUpdate then
                self:FullUpdate();
            else
                self:UpdateScrollViewContent();
            end
        end
    end
end

local function CreateActivityTab(f)
    ActivityTab = f;
    API.Mixin(f, ActivityTabMixin);
    f:InitChecklist();

    f:SetScript("OnShow", f.OnShow);
    f:SetScript("OnHide", f.OnHide);
    f:SetScript("OnEvent", f.OnEvent);
end


LandingPageUtil.AddTab(
    {
        key = "activity",
        name = "Activities",
        uiOrder = 2,
        initFunc = CreateActivityTab,
    }
);