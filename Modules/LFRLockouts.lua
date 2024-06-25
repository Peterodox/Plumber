-- Update gossip icon for LFR NPC's based off of weekly lockouts
local _, addon = ...

-- debug command:
-- /run for i = 1, #GossipFrame.gossipOptions do local k = GossipFrame.gossipOptions[i] print(k.name .. " = " .. k.gossipOptionID) end
local lockoutData = {
    [4] = {
        [967] = { -- dragon soul
            [42612] = 4, -- hagara the stormbinder
            [42613] = 8 -- madness of deathwing
        }
    },
    [5] = {
        [996] = { -- terrace of endless spring
            [42624] = 4
        },
        [1008] = { -- mogu'shan vaults
            [42620] = 3, -- gara'jal the spiritbinder
            [42621] = 6 -- will of the emperor
        },
        [1009] = { -- heart of fear
            [42622] = 3, -- garalon
            [42623] = 6 -- grand empress shek'zeer
        },
        [1098] = { -- throne of thunder
            [42625] = 3, -- council of elders
            [42626] = 6, -- ji-kun
            [42627] = 9, -- dark animus
            [42628] = 12 -- lei shen
        },
        [1136] = { -- siege of orgrimmar
            [42629] = 4, -- sha of pride
            [42630] = 8, -- general nazgrim
            [42631] = 11, -- thok the bloodthirsty
            [42632] = 14, -- garrosh hellscream
        }
    },
    [6] = {
        [1228] = { -- highmaul
            [44390] = 4, -- brackenspore
            [44391] = 6, -- ko'ragh
            [44392] = 7 -- imperator mar'gok
        },
        [1205] = { -- blackrock foundary
            [44393] = 7, -- the blast furnace
            [44394] = 8, -- kromog
            [44395] = 9, -- the iron maidens
            [44396] = 10 -- blackhand
        },
        [1448] = { -- hellfire citadel
            [44397] = 3, -- kormrok
            [44398] = 6, -- gorefiend
            [44399] = 11, -- tyrant velhari
            [44400] = 12, -- mannoroth
            [44401] = 13 -- archimonde
        }
    },
    [7] = { -- legion
        [1520] = { -- emerald nightmare
            [37110] = 2, -- ilgynoth is 2nd encounter
            [37111] = 6, -- cenarius
            [37112] = 8 -- xavius
        },
        [1530] = { -- nighthold
            [37113] = 3, -- triliax
            [37114] = 6, -- high botanist tel'arn WRONG KROSUS
            [37115] = 9, -- grand magistrix elisande
            [37116] = 10 -- gul'dan
        },
        [1648] = { -- trial of valor
            [37117] = 3 -- helya
        },
        [1676] = { -- tomb of sargeras
            [37118] = 5, -- mistress sassz'ine
            [37119] = 6, -- the desolate host
            [37120] = 8, -- fallen avatar
            [37121] = 9 -- kil'jaeden
        },
        [1712] = { -- antorus
            [37122] = 4, -- antoran high command
            [37123] = 6, -- imonar the soulhunter
            [37124] = 9, -- the coven of shivarra
            [37125] = 11 -- argus the unmaker
        }
    },
    [8] = { -- bfa
        [1861] = { -- uldir
            [52303] = 3, -- fetid devourer
            [52304] = 6, -- zul, reborn
            [52305] = 8 -- g'huun
        },
        [2070] = { -- battle of dazar'alor
            [52309] = 3, -- grong, the revenant
            [52310] = 6, -- king rastakhan
            [52311] = 9 -- lady jaina proudmoore
        },
        [2096] = { -- crucible of storms
            [52312] = 2
        },
        [2164] = { -- the eternal palace
            [52313] = 3, -- radiance of azshara
            [52314] = 6, -- the queen's court
            [52315] = 8, -- queen azshara
        },
        [2217] = { -- ny'alotha
            [52316] = 3, -- the prophet skitra
            [52317] = 10, -- ra'den the despoiled
            [52318] = 8, -- il'gynoth, corruption reborn
            [52319] = 12 -- n'zoth the corruptor
        }
    },
    [9] = { -- shadowlands
        [2296] = { -- castle nathria
            [110020] = 6, -- lady inerva darkvein
            [110037] = 7, -- the council of blood
            [110036] = 9, -- stone legion generals
            [110035] = 10, -- sire denathrius
        },
        [2450] = { -- sanctum of domination
            [110034] = 3, -- the nine
            [110033] = 6, -- painsmith raznal
            [110032] = 9, -- kel'thuzad
            [110031] = 10, -- sylvanas windrunner
        },
        [2481] = { -- sepulcher of the first ones
            [110030] = 6, -- lihuvim, principal architect
            [110029] = 7, -- halondrus
            [110028] = 10, -- rygelon
            [110027] = 11, -- the jailer
        }
    },
    [10] = { -- dragonflight

    }
}

local expansionNpc = {
    [80675] = 4, -- auridormi
    [80633] = 5, -- lorewalker han
    [94870] = 6, -- seer kazal
    [111246] = 7, -- archmage timear
    [177193] = 8, -- kiku
    [205959] = 9, -- taefuck
}

local EventFrame = CreateFrame("Frame")

local function EventFrame_OnEvent(self, event, ...)
    if event == "GOSSIP_SHOW" then
        -- first, get NPC ID
        local npcGuid = UnitGUID("npc")
        local npcId = nil
        if npcGuid ~= nil then
            npcId = tonumber(select(3, UnitGUID("npc"):find("Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")))
        end

        -- sanity check
        if npcId == nil then return end
        if expansionNpc[npcId] == nil then return end

        local expansion = expansionNpc[npcId]

        local f = GossipFrame
        if not (f:IsShown() and f.gossipOptions) then return end

        local gossipData = {}
        for i = 1, GetNumSavedInstances() do
            local _, _, _, difficultyId, locked, _, _, isRaid, _, _, _, _, _, instanceId = GetSavedInstanceInfo(i)
            -- difficultyId = 7 is legacy LFR, difficultyId = 17 is modern LFR
            -- check if it's a raid that's locked
            if (difficultyId == 7 or difficultyId == 17) and locked == true and isRaid == true and lockoutData[expansion][instanceId] ~= nil then
                local tbl = lockoutData[expansion][instanceId]
                for gossipId, encounterIndex in pairs(tbl) do
                    -- loop through every gossip ID <-> encounter index pair to see if we've killed that specific end boss
                    local _, _, isKilled, _ = GetSavedInstanceEncounterInfo(i, encounterIndex)
                    gossipData[gossipId] = isKilled
                end
            end
        end

        -- loop through every gossip option
        for i = 1, #f.gossipOptions do
            -- check it has a valid ID
            local id = f.gossipOptions[i].gossipOptionID
            if gossipData[id] ~= nil then
                -- if true, this is a locked instance - show different icon
                if gossipData[id] == true then
                    f.gossipOptions[i].icon = "Interface\\AddOns\\Plumber\\Art\\GossipIcons\\Lockout_Locked"
                end
            end
        end

        f:Update()
    end
end

local function EnableModule(state)
    if state then
        EventFrame:RegisterEvent("GOSSIP_SHOW")
        EventFrame:SetScript("OnEvent", EventFrame_OnEvent)
    else
        EventFrame:UnregisterEvent("GOSSIP_SHOW")
    end
end

local L = addon.L

addon.ControlCenter:AddModule({
    name = L["ModuleName LFRLockouts"],
    dbKey = "LFRLockouts",
    description = L["ModuleDescription LFRLockouts"],
    toggleFunc = EnableModule,
    categoryID = 2,
    uiOrder = 2
})