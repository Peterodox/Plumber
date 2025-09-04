-- Replace default gossip icon with Dragonriding course medal
local _, addon = ...

local EL = CreateFrame("Frame");

local match = string.match;
local UnitName = UnitName;

local RACE_TIMES = "^Race Times";
local Timekeepers = {};

local SpecialNPCs = {
    234643,     --Omtroid, Ecological Succession
};

local RankIcons = {
    [1] = "Interface\\AddOns\\Plumber\\Art\\GossipIcons\\Medal_Gold",
    [2] = "Interface\\AddOns\\Plumber\\Art\\GossipIcons\\Medal_Silver",
    [3] = "Interface\\AddOns\\Plumber\\Art\\GossipIcons\\Medal_Bronze",
    [4] = "Interface\\AddOns\\Plumber\\Art\\GossipIcons\\Medal_None",
};

local function IsDragonRacingNPC()
    local name = UnitName("npc");
    return name and Timekeepers[name] == true
end


do
    local locale = GetLocale();

    if locale == "enUS" then
        RACE_TIMES = "^Race Times";
        Timekeepers = {
            ["Grimy Timekeeper"] = true,
            ["Bronze Timekeeper"] = true,
        };

    elseif locale == "esMX" then
        RACE_TIMES = "^Tiempos de la carrera";
        Timekeepers = {
            ["Cronometradora bronce"] = true,
            ["Cronometradora mugrienta"] = true,
            ["Cronometrador bronce"] = true,
            ["Cronometrador mugriento"] = true,
        };

    elseif locale == "ptBR" then
        RACE_TIMES = "^Tempos da Corrida";
        Timekeepers = {
            ["Guarda-tempo Bronze"] = true,
            ["Guarda-tempo Limosa"] = true,
        };

    elseif locale == "deDE" then
        RACE_TIMES = "^Rennzeiten";
        Timekeepers = {
            ["Schmuddelige Zeithüterin"] = true,
            ["Schmuddeliger Zeithüter"] = true,
            ["Bronzezeithüterin"] = true,
            ["Bronzezeithüter"] = true,
        };

    elseif locale == "esES" then
        RACE_TIMES = "^Tiempos de carrera";
        Timekeepers = {
            ["Vigilante del tiempo pringoso"] = true,
            ["Vigilante del tiempo pringosa"] = true,
            ["Vigilante del tiempo bronce"] = true,
        };

    elseif locale == "frFR" then
        RACE_TIMES = "^Temps des courses";
        Timekeepers = {
            ["Chronométreuse crasseuse"] = true,
            ["Chronométreur de bronze"] = true,
            ["Chronométreur crasseux"] = true,
            ["Chronométreuse de bronze"] = true,
        };

    elseif locale == "itIT" then
        RACE_TIMES = "^Tempi della Corsa";
        Timekeepers = {
            ["Custode del Tempo Sporco"] = true,
            ["Custode del Tempo Bronzea"] = true,
            ["Custode del Tempo Sporca"] = true,
            ["Custode del Tempo Bronzeo"] = true,
        };

    elseif locale == "ruRU" then
        RACE_TIMES = "^Время гонки";
        Timekeepers = {
            ["Бронзовая хранительница времени"] = true,
            ["Бронзовый хранитель времени"] = true,
            ["Закопченный хранитель времени"] = true,
            ["Закопченная хранительница времени"] = true,
        };

    elseif locale == "koKR" then
        RACE_TIMES = "^경주 시간";
        Timekeepers = {
            ["꾀죄죄한 시간지기"] = true,
            ["청동 시간지기"] = true,
        };

    elseif locale == "zhTW" then
        RACE_TIMES = "^競賽時間";
        Timekeepers = {
            ["髒兮兮的時空守衛者"] = true,
            ["青銅時空守衛者"] = true,
        };

    elseif locale == "zhCN" then
        RACE_TIMES = "^竞速时间";
        Timekeepers = {
            ["青铜时光守护者"] = true,
            ["满身油渍的时光守护者"] = true,
        };
    end
end


local function UpdateGossipIcons_Default(ranks)
    local f = GossipFrame;

    if not (f:IsShown() and f.gossipOptions) then return end;

    for i = 1, #ranks do
        if f.gossipOptions[i] then
            f.gossipOptions[i].icon = RankIcons[ranks[i]];
        end
    end

    f:Update();
end

local function UpdateGossipIcons_Immersion(ranks)
    local f = ImmersionFrame;

    if not (f and f:IsShown() and f.TitleButtons and f.TitleButtons.Active) then return end;

    local numActive = #f.TitleButtons.Active;
    if numActive ~= #ranks then return end;

    for i, button in ipairs(f.TitleButtons.Active) do
        button:SetIcon( RankIcons[ranks[i]] );
    end
end

local UpdateGossipIcons = UpdateGossipIcons_Default;


local function ProcessLines(...)
    local n = select('#', ...);
    local i = 1;
    local line, medal;
    local ranks = {};
    local k = 1;
    local rankID;

    while i < n do
        line = select(i, ...);

        if match(line, "[Cc][Ff][Ff][Ff][Ff][Dd]100") then  --title: Normal, Advanced, Reverse, etc.
            i = i + 1;  --player record follows the title
            line = select(i, ...);
            medal = match(line, "medal%-small%-(%a+)");
            if medal then
                if medal == "gold" then
                    rankID = 1;
                elseif medal == "silver" then
                    rankID = 2;
                elseif medal == "bronze" then
                    rankID = 3;
                else
                    rankID = 4;
                end
            else
                --No Attempts
                rankID = 4;
                i = i + 1;  --Gold time follows player record (if not reached gold)
            end
            ranks[k] = rankID;
            k = k + 1;
        end
        i = i + 1;
    end

    if k == 1 then
        EL:QueryAuraTooltipInto();
    else
        UpdateGossipIcons(ranks);
        EL:QueryAuraTooltipInto();    --Sometimes the tooltip data is partial so we keep querying x times
    end
end

local function ProcessAuraByAuraInstanceID(auraInstanceID)
    local info = C_TooltipInfo.GetUnitBuffByAuraInstanceID("player", auraInstanceID);
    if info and info.lines and info.lines[2] then
        EL:WatchDataInstanceID(info.dataInstanceID);
        ProcessLines( string.split("\r", info.lines[2].leftText) );
    else
        --Tooltip data not ready
        EL:QueryAuraTooltipInto(auraInstanceID)
    end
end

local function EL_OnUpdate(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.25 then
        self.t = 0;
        self.queryTimes = self.queryTimes + 1;
        self:SetScript("OnUpdate", nil);

        if self.auraInstanceID then
            ProcessAuraByAuraInstanceID(self.auraInstanceID);
            --print("Delayed Process")
        end
    end
end

function EL:ResetQueryCounter()
    self.queryTimes = 0;
end

function EL:QueryAuraTooltipInto(auraInstanceID)
    if self.queryTimes >= 3 then
        self:PostDataFullyRetrieved();
        return
    end

    self.t = 0;
    if auraInstanceID then
        self.auraInstanceID = auraInstanceID;
    end
    self:SetScript("OnUpdate", EL_OnUpdate);
end

function EL:PostDataFullyRetrieved()
    self.auraInstanceID = nil;
    self:UnregisterEvent("UNIT_AURA");
    self:UnregisterEvent("GOSSIP_CLOSED");
    self:SetScript("OnUpdate", nil);
end

function EL:WatchDataInstanceID(dataInstanceID)
    self.dataInstanceID = dataInstanceID;
    if dataInstanceID then
        self:RegisterUnitEvent("TOOLTIP_DATA_UPDATE");
    end
end



local function ProcessFunc(auraInfo)
    if auraInfo.icon == 237538 then
        --API.SaveLocalizedText(auraInfo.name);
        if string.find(auraInfo.name, RACE_TIMES) then
            ProcessAuraByAuraInstanceID(auraInfo.auraInstanceID);
            return true
        end
    end
end


function EL:UpdateRaceTimesFromAura()
    local unit = "player";
    local filter = "HELPFUL";
    local usePackedAura = true;

    AuraUtil.ForEachAura(unit, filter, nil, ProcessFunc, usePackedAura);
end


local function EL_OnEvent(self, event, ...)
    if event == "GOSSIP_SHOW" then
        if IsDragonRacingNPC() then
            self:RegisterUnitEvent("UNIT_AURA", "player");
            self:RegisterEvent("GOSSIP_CLOSED");
            EL:ResetQueryCounter();
            EL:UpdateRaceTimesFromAura();
        end
        --API.SaveLocalizedText(UnitName("npc"));
    elseif event == "GOSSIP_CLOSED" then
        self:PostDataFullyRetrieved();

    elseif event == "UNIT_AURA" then
        EL:UpdateRaceTimesFromAura();

    elseif event == "TOOLTIP_DATA_UPDATE" then
        local dataInstanceID = ...
        if dataInstanceID == self.dataInstanceID then
            EL:UpdateRaceTimesFromAura();
        end
    end
end


local TEMP_RANKS;

local function SetStorylineDialogButtonIcon(...)
    if not TEMP_RANKS then return end;

    local button;
    for i = 1, select("#", ...) do
        button = select(i, ...);
        if button.icon and TEMP_RANKS[i] then
            button.icon:SetTexture(RankIcons[TEMP_RANKS[i]])
        end
    end
end

local function UdpateGossipIcons_Storyline(ranks)
    TEMP_RANKS = ranks;
    C_Timer.After(1, function()
        if Storyline_DialogChoicesScrollFrame:IsVisible() then
            SetStorylineDialogButtonIcon(Storyline_DialogChoicesScrollFrame.container:GetChildren());
        end
    end)
end

local function OnCreatureNameReceived(creatureID, creatureName)
    if creatureName and creatureName ~= "" then
        Timekeepers[creatureName] = true;
    end
end

function EL:EnableModule()
    self:RegisterEvent("GOSSIP_SHOW");
    self:SetScript("OnEvent", EL_OnEvent);


    --Find compatible addons
    local IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded;

    if IsAddOnLoaded("Immersion") then
        UpdateGossipIcons = UpdateGossipIcons_Immersion;
    elseif IsAddOnLoaded("Storyline") then
        if Storyline_DialogChoicesScrollFrame and Storyline_DialogChoicesScrollFrame.container then
            UpdateGossipIcons = UdpateGossipIcons_Storyline;
        end
    end

    addon.API.LoadCreatureNameWithCallback(SpecialNPCs, OnCreatureNameReceived);
end

function EL:DisableModule()
    self:UnregisterEvent("GOSSIP_SHOW");
    self:UnregisterEvent("GOSSIP_CLOSED");
    self:UnregisterEvent("UNIT_AURA");
    self:UnregisterEvent("TOOLTIP_DATA_UPDATE");
    self.dataInstanceID = nil;
end

local function EnableModule(state)
    if state then
        EL:EnableModule();
    else
        EL:DisableModule();
    end
end


do
    local L = addon.L;

    local defaultIcon = "|TInterface/AddOns/Plumber/Art/GossipIcons/GossipIcon:16:16:0:0|t";
    local newIcon = "|TInterface/AddOns/Plumber/Art/GossipIcons/Medal_Gold:16:16:0:0|t";
    local description = string.format(L["ModuleDescription GossipFrameMedal Format"], defaultIcon, newIcon);

    local moduleData = {
        name = L["ModuleName GossipFrameMedal"],
        dbKey = "GossipFrameMedal",
        description = description,
        toggleFunc = EnableModule,
        categoryID = 2,
        uiOrder = 1,
    };

    addon.ControlCenter:AddModule(moduleData);
end