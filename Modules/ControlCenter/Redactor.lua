local _, addon = ...
local API = addon.API;


--local TestText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Quis ipsum suspendisse ultrices gravida.";


local RedactorMixin = {};
do
    function RedactorMixin:AcquireHighlightTexture()
        if not self.texturePool then
            local function Texture_Create()
                local obj = self:CreateTexture(nil, "OVERLAY", nil, 5);
                return obj
            end
            self.texturePool = addon.LandingPageUtil.CreateObjectPool(Texture_Create);
        end

        local texture = self.texturePool:Acquire();

        return texture
    end

    function RedactorMixin:RedactText()
        local fontHeight = self.fontHeight or 12;
        local maxIndex = self.maxIndex;
        local index = 0;
        local fromIndex = 1;
        local toIndex = 0;
        local numTex = 0;
        local lastLeft, lastBottom, lineWidth;
        local complete;

        while index <= maxIndex do
            index = index + 1;
            toIndex = toIndex + 1;
            complete = index == maxIndex;
            if complete then
                toIndex = maxIndex;
            end
            local areas = self.fontString:CalculateScreenAreaFromCharacterSpan(fromIndex, toIndex);
            local screenArea = areas and areas[#areas];
            if screenArea then
                if screenArea.bottom ~= lastBottom or complete then
                    if complete then
                        lastLeft = screenArea.left;
                        lineWidth = screenArea.width;
                        if numTex == 0 then
                            lineWidth = lineWidth + 8;
                        end
                    end

                    if lineWidth then
                        local expand = 0;
                        toIndex = toIndex - 1;
                        fromIndex = toIndex;
                        local highlightTexture = self:AcquireHighlightTexture();
                        highlightTexture:SetColorTexture(self.r, self.g, self.b);
                        numTex = numTex + 1;
                        --highlightTexture:SetPoint("BOTTOMLEFT", self.fontString, "BOTTOMLEFT", lastLeft - expand, lastBottom - expand);
                        highlightTexture:SetPoint("TOPRIGHT", self.fontString, "BOTTOMLEFT", lastLeft + lineWidth + expand, lastBottom + expand + fontHeight);
                        highlightTexture:SetSize(lineWidth + expand, fontHeight + expand);
                        highlightTexture:Show();
                    end
                end

                lineWidth = screenArea.width;
                lastLeft = screenArea.left;
                lastBottom = screenArea.bottom;
            end
        end
    end

    function RedactorMixin:RedactFontString(fontString, fontHeight, text)
        self:SetScript("OnUpdate", nil);
        self.revealed = false;

        if self.texturePool then
            self.texturePool:ReleaseAll();
        end

        self.fontString = fontString;

        if not text then
            text = fontString:GetText();
        end

        self.fontHeight = fontHeight;
        self.maxIndex = string.len(text); --strlenutf8(text);
        self.fromIndex = 1;
        self.toIndex = 0;
        self.index = 0;
        self.t = 0;
        self.numTex = 0;

        self.lineWidth = nil;
        self.lastLeft = nil;
        self.lastBottom = nil;

        local width = fontString:GetWrappedWidth();
        local height = fontString:GetHeight();
        self:SetSize(width, height);
        self:ClearAllPoints();
        self:SetPoint("TOPLEFT", fontString, "TOPLEFT", 0, 0);

        fontString:Hide();
        self:SetScript("OnEnter", nil);
        self:SetScript("OnUpdate", self.OnUpdate_Load);
    end

    function RedactorMixin:SetColor(r, g, b)
        self.r, self.g, self.b = r, g, b;
    end

    function RedactorMixin:OnUpdate_Load()
        self:SetScript("OnUpdate", nil);
        self.fontString:Show();
        self:RedactText();
        self:SetScript("OnEnter", self.OnEnter);
    end

    function RedactorMixin:OnEnter()
        if not self.revealed then
            self.revealed = true;
            self:StartRevealing();
        end
    end

    function RedactorMixin:StartRevealing()
        local total = 0;
        self.objects = {};
        for i, obj in self.texturePool:EnumerateActive() do
            total = total + 1;
            self.objects[i] = obj;
            obj.width = obj:GetWidth();
            obj.delay = -0.25 * i;
        end

        self.total = total;
        if total > 0 and self:IsVisible() then
            self.t = 0;
            self:SetScript("OnUpdate", self.OnUpdate_Reveal);
        else
            self:Hide();
        end
    end

    function RedactorMixin:OnUpdate_Reveal(elapsed)
        local obj;
        local allDone = true;

        for i = 1, self.total do
            obj = self.objects[i];
            if obj.delay < 0 then
                allDone = false;
                obj.delay = obj.delay + elapsed;
            else
                obj.delay = 1;
                if obj.width > 0 then
                    allDone = false;
                    obj.width = obj.width - 200 * elapsed;
                    if obj.width < 1 then
                        obj.width = -1;
                        obj:Hide();
                    else
                        obj:SetWidth(obj.width);
                    end
                end
            end
        end

        if allDone then
            self:SetScript("OnUpdate", nil);
            self:Hide();
        end
    end
end


local function CreateTextRedactor(parent)
    local f = CreateFrame("Frame", nil, parent);
    Mixin(f, RedactorMixin);

    return f
end
addon.CreateTextRedactor = CreateTextRedactor;