--Add a search box to the AddonList

local _, addon = ...

local GetAddOnInfo = C_AddOns.GetAddOnInfo;
local StripHyperlinks = StripHyperlinks;
local sub = string.sub;
local find = string.find;
local lower = string.lower;

local AddonDataProvider = {};

function AddonDataProvider:LoadNames()
    if self.dict then return end;

    self.dict = {};
    self.names = {};
    self.total = C_AddOns.GetNumAddOns();

    local name, firstLetter;
    local lastLetter;
    local letterRange = 0;

    for i = 1, self.total do
        name = GetAddOnInfo(i);
        name = StripHyperlinks(name);

        firstLetter = sub(lower(name), 1, 1);
        
        if lastLetter and firstLetter ~= lastLetter then
            self.dict[lastLetter][2] = letterRange;
            letterRange = 0;
        end
        letterRange = letterRange + 1;

        if not self.dict[firstLetter] then
            self.dict[firstLetter] = {i};
        end

        lastLetter = firstLetter;

        self.names[i] = name;
    end
end

function AddonDataProvider:FindIndexByName(name)
    self:LoadNames();

    name = lower(name);
    local firstLetter = sub(name, 1, 1);

    if self.dict[firstLetter] then
        local from, range = self.dict[firstLetter][1], self.dict[firstLetter][2];
        local to = (range and from + range) or self.total;
        for i = from, to do
            if find(lower(self.names[i]), name) then
                print(self.names[i])
                return i
            end
        end
    end

end

function ScrollToAddOnName(name)
    local index = AddonDataProvider:FindIndexByName(name);
    if index then
        local alignment = 0;    --ScrollBoxConstants.AlignBegin
        local noInterpolation = true;
        AddonList.ScrollBox:ScrollToElementDataIndex(index, alignment, noInterpolation);
        return true
    end
end