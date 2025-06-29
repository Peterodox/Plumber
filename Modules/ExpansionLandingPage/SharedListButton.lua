local _, addon = ...
local API = addon.API;
local CallbackRegistry = addon.CallbackRegistry;
local LandingPageUtil = addon.LandingPageUtil;
local SetupThreeSliceBackground = API.SetupThreeSliceBackground;
local CreateFrame = CreateFrame;


local GetItemNameByID = C_Item.GetItemNameByID;


local CreateSharedListButton;
do  --ScrollViewListButton
    local TEXTURE = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/ChecklistButton.tga";

    local SharedListButtonMixin = {};

    function SharedListButtonMixin:SetBackgroundColor(r, g, b)
        self.Left:SetVertexColor(r, g, b);
        self.Right:SetVertexColor(r, g, b);
        self.Center:SetVertexColor(r, g, b);
    end

    function SharedListButtonMixin:UpdateVisual()
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
                --self.Name:SetTextColor(0.8, 0.8, 0.8);
            elseif self.readyForTurnIn then
                self.Name:SetTextColor(0.098, 1.000, 0.098);
            else
                if self.selected then
                    self.Name:SetTextColor(1, 1, 1);
                else
                    self.Name:SetTextColor(0.922, 0.871, 0.761);
                end
            end
        end
    end

    function SharedListButtonMixin:SetHeader()
        self.id = nil;
        self.type = "Header";

        self.isHeader = true;
        self.readyForTurnIn = nil;
        self.flagQuest = nil;
        self.Icon:SetTexture(TEXTURE);
        self.Icon:SetSize(18, 18);
        self.Icon:SetPoint("CENTER", self, "LEFT", 16, 0);
        self.Icon:Show();
        self.Name:SetTextColor(0.6, 0.6, 0.6);
        self.Name:SetWidth(0);
        self.Name:SetMaxLines(1);
        self.Text1:SetText(nil);

        if self.isCollapsed then
            self.Icon:SetTexCoord(0, 48/512, 208/512, 256/512);
        else
            self.Icon:SetTexCoord(0, 48/512, 256/512, 208/512);
        end

        self:Layout();
    end

    function SharedListButtonMixin:SetEntry()
        --Clear Atlas
        self.isHeader = nil;
        self.Icon:SetSize(18, 18);
        self.Icon:SetTexture(nil);
        self.Icon:SetPoint("CENTER", self, "LEFT", 16, 0);
        self.Icon:SetTexCoord(0, 1, 0, 1);
        self.Name:SetTextColor(0.88, 0.88, 0.88);
        self.Name:SetWidth(240);
        self.Name:SetMaxLines(2);
    end

    function SharedListButtonMixin:Layout()
        local textOffset = 10;

        if self.Icon:IsShown() then
            textOffset = textOffset + 22;
        end

        self.Name:SetPoint("LEFT", self, "LEFT", textOffset, 0);
    end


    function CreateSharedListButton(parent)
        local f = CreateFrame("Button", nil, parent);
        f:SetSize(248, 24);

        SetupThreeSliceBackground(f, TEXTURE, -4, 4);
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
        f.Name:SetTextColor(0.88, 0.88, 0.88);
        f.Name:SetJustifyH("LEFT");

        f.Text1 = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        f.Text1:SetPoint("RIGHT", f, "RIGHT", -96, 0);
        f.Text1:SetTextColor(0.88, 0.88, 0.88);
        f.Text1:SetJustifyH("CENTER");

        f.Glow = f:CreateTexture(nil, "BORDER");
        f.Glow:Hide();
        f.Glow:SetTexture(TEXTURE);
        f.Glow:SetTexCoord(0/512, 512/512, 352/512, 416/512);
        f.Glow:SetPoint("LEFT", f.Left, "LEFT", 0, 0);
        f.Glow:SetSize(256, 32);
        f.Glow:SetBlendMode("ADD");
        f.Glow:SetVertexColor(0.5, 0.5, 0.5);

        API.Mixin(f, SharedListButtonMixin);

        return f
    end
    LandingPageUtil.CreateSharedListButton = CreateSharedListButton;
end

do  --Generic Checklist Button
    local ChecklistButtonMixin = {};

    function ChecklistButtonMixin:OnEnter()
        self:UpdateVisual();
    end

    function ChecklistButtonMixin:OnLeave()
        self:UpdateVisual();
    end

    function ChecklistButtonMixin:OnClick(button)

    end

    function ChecklistButtonMixin:UpdateProgress()
        self.completed = nil;
        self.readyForTurnIn = nil;
        self.Text1:SetText(nil);

        if self.updateProgressFunc then
            self.updateProgressFunc(self);
        end
        self:UpdateVisual();
    end

    function ChecklistButtonMixin:UpdateProgress_Quest()
        local data = API.GetQuestData(self.id);
        if data then
            if  data.completed or (self.data.warband and data.warbandCompleted) then
                self.Icon:SetAtlas("checkmark-minimal-disabled");
                self.completed = true;
            else
                self.readyForTurnIn = data.readyForTurnIn;
                if data.iconAtlas then
                    self.Icon:SetAtlas(data.iconAtlas);
                else
                    self.Icon:SetTexture(data.iconFile);
                end

                if data.isOnQuest then
                    if self.readyForTurnIn then

                    else
                        local percentText = API.GetQuestProgressPercent(self.id, true);
                        self.Text1:SetText(percentText);
                    end
                end
            end
        end
    end

    function ChecklistButtonMixin:UpdateProgress_Item()

    end

    function ChecklistButtonMixin:UpdateProgress_Rare()
        if API.IsRareCreatureKilled(self.id, self.data.flagQuest, self.data.warband) then
            self.completed = true;
            self.Icon:SetAtlas("checkmark-minimal-disabled");
        else
            self.Icon:SetTexture("Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/TrackerType-Rare.png");
        end
    end

    function ChecklistButtonMixin:SetData(data)
        self.data = data;

        if not data then
            self.type = nil;
            self.Name:SetText(nil);
            return
        end

        if data.localizedName then
            self.loaded = true;
            self.Name:SetText(data.localizedName);
        else
            self.loaded = false;
           self.Name:SetText(data.name);
        end

        self.type = data.type;

        if data.isHeader then
            self.updateProgressFunc = nil;
        end

        if self.type == "Quest" then
            self:SetQuest(data.id);
        elseif self.type == "Item" then
            self:SetItem(data.id);
        elseif self.type == "Rare" then
            self:SetRareCreature(data.id, data.flagQuest);
        end

        self:UpdateProgress();
    end

    function ChecklistButtonMixin:SetQuest(questID)
        self.type = "Quest";
        self.id = questID;
        self.updateProgressFunc = self.UpdateProgress_Quest;

        if not self.loaded then
            CallbackRegistry:LoadQuest(questID, function(_questID)
                if questID == self.id and self.type == "Quest" then
                    self.loaded = true;
                    local name = API.GetQuestName(_questID);
                    self.data.localizedName = name;
                    self.Name:SetText(name);
                    self:UpdateProgress();
                    if self:IsMouseMotionFocus() then
                        self:OnEnter();
                    end
                end
            end);
        end
    end

    function ChecklistButtonMixin:SetItem(itemID)
        self.type = "Item";
        self.id = itemID;
        self.updateProgressFunc = self.UpdateProgress_Item;

        if not self.loaded then
            CallbackRegistry:LoadItem(itemID, function(_itemID)
                if _itemID == self.id and self.type == "Item" then
                    self.loaded = true;
                    local name = GetItemNameByID(_itemID);
                    self.data.localizedName = name;
                    self.Name:SetText(name);
                    self:UpdateProgress();
                end
            end);
        end
    end

    function ChecklistButtonMixin:SetRareCreature(creatureID, flagQuest)
        self.type = "Rare";
        self.id = creatureID;
        self.updateProgressFunc = self.UpdateProgress_Rare;
        self.flagQuest = flagQuest;

        if not self.loaded then
            local name = API.GetAndCacheCreatureName(creatureID);
            if name then
                self.loaded = true;
                self.data.localizedName = name;
                self.Name:SetText(name);
            else
                CallbackRegistry:LoadCreature(creatureID, function(_creatureID, _name)
                    if _creatureID == self.id and self.type == "Rare" then
                        self.loaded = true;
                        self.data.localizedName = _name;
                        self.Name:SetText(_name);
                    end
                end);
            end
        end
    end

    function ChecklistButtonMixin:ToggleCollapsed()

    end

    function ChecklistButtonMixin:DisplayTooltip()

    end

    function ChecklistButtonMixin:ShowGlow(showGlow)
        self.Glow:SetShown(showGlow);
    end

    local function CreateChecklistButton(parent)
        local f = CreateSharedListButton(parent);

        API.Mixin(f, ChecklistButtonMixin);
        f:SetScript("OnEnter", f.OnEnter);
        f:SetScript("OnLeave", f.OnLeave);
        f:SetScript("OnClick", f.OnClick);

        return f
    end
    LandingPageUtil.CreateChecklistButton = CreateChecklistButton;
end