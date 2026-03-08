local _, addon = ...
local L = addon.L;
local LandingPageUtil = addon.LandingPageUtil;
local ActivityUtil = addon.ActivityUtil;

--C_QuestLog.GetActivePreyQuest()
--/dump C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(7515).barValue


local SetupFuncs = {};
do
    local WIDGET_TYPE = 2;

    local PROGRESS_FORMAT = "%s: %s/%s";

    --[[
    function YeetPreyWidget()
        local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(1843);
        local progressText;
        if widgets then
            for _, widget in ipairs(widgets) do
                if widget.widgetType == WIDGET_TYPE then
                    local info = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widget.widgetID);
                    if info and info.text and info.barValue and info.barMax then
                        progressText = PROGRESS_FORMAT:format(info.text, info.barValue, info.barMax);
                        print(widget.widgetID, progressText)
                    end
                end
            end
        end
    end
    --]]

    function SetupFuncs.PreyProgress(listButton)
        local activeQuestID = C_QuestLog.GetActivePreyQuest();
        if activeQuestID then
            listButton:SetQuest(activeQuestID);
            listButton.flagQuest = activeQuestID;
            listButton.completed = C_QuestLog.IsQuestFlaggedCompleted(activeQuestID);
            return
        end

        local progressText;
        local activeWidgetFound = false;
        local widgetSetID = 1843;
        local widgets = C_UIWidgetManager.GetAllWidgetsBySetID(widgetSetID);
        if widgets then
            for _, widget in ipairs(widgets) do
                --debug
                --[[
                local widgetTypeName;
                for k, v in pairs(Enum.UIWidgetVisualizationType) do
                    if widget.widgetType == v then
                        widgetTypeName = k;
                        break
                    end
                end
                print(widget.widgetID, widget.widgetType, widgetTypeName);
                --]]

                if widget.widgetType == WIDGET_TYPE then
                    local info = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(widget.widgetID);
                    if info and (not progressText) and info.text and info.barValue and info.barMax then
                        progressText = PROGRESS_FORMAT:format(info.text, info.barValue, info.barMax);
                        if info.shownState == 1 then
                            activeWidgetFound = true;
                        end
                    end
                    if (not activeWidgetFound) and info and info.shownState == 1 then
                        progressText = PROGRESS_FORMAT:format(info.text, info.barValue, info.barMax);
                        activeWidgetFound = true;
                        break
                    end
                end
            end
        end

        if progressText then
            if not activeWidgetFound then
                progressText = "*"..progressText;
            end
        else
            progressText = L["Prey No Data"];
        end

        listButton.Icon:Hide();
        listButton.Name:SetText(progressText);
    end

    function SetupFuncs.GetPreyHeader()
        local mapName;
        local activeQuestID = C_QuestLog.GetActivePreyQuest();
        if activeQuestID then
            local uiMapID = GetQuestUiMapID(activeQuestID);
            if uiMapID then
                mapName = addon.API.GetMapName(uiMapID);
            end
        end

        if mapName then
            return L["Prey System"].." - "..mapName
        else
            return L["Prey System"]
        end
    end
end


local ActivityData = {  --Constant
    --questClassification: 5 is recurring

    --[[
    {isHeader = true, name = "Delves", localizedName = DELVES_LABEL, categoryID = 10000,
        entries = {
            {name = "The Key to Success", questID = 84370, isWeeklyQuest = true, accountwide = true},
            {name = "Delver\'s Bounty", itemID = 233071, flagQuest = 86371, icon = 1064187, conditions = ActivityUtil.Conditions.DelversBounty},

            {name = "Coffer Keys", label = L["Restored Coffer Key"], questClassification = 5, tooltipSetter = ActivityUtil.TooltipFuncs.WeeklyRestoredCofferKey, icon = 4622270, useItemIcon = true,
                children = ActivityUtil.CreateChildrenFromQuestList(addon.WeeklyRewardsConstant.CofferKeyFlags),
            },

            {name = "Coffer Key Shards", label = L["Coffer Key Shard"], questClassification = 5, tooltipSetter = ActivityUtil.TooltipFuncs.WeeklyCofferKeyShard, icon = 133016, useItemIcon = true,
                children = ActivityUtil.CreateChildrenFromQuestList(addon.WeeklyRewardsConstant.CofferKeyShardFlags),
            },
        }
    },
    --]]

    {isHeader = true, name = "Prey", localizedName = L["Prey System"], categoryID = 120000, nameGetter = SetupFuncs.GetPreyHeader,
        entries = {
            {name = "Prey Progress", icon = "Interface/AddOns/Plumber/Art/ExpansionLandingPage/Icons/InProgressPrey.png", sortToTop = true, setupFunc = SetupFuncs.PreyProgress, removeSharedPrefix = true},
        },
    },

    {isHeader = true, name = "Silvermoon Court", factionID = 2710, categoryID = 2710, uiMapID = 2395,
        entries = {
            {name = L["QuestName Runestone"], localizedName = L["QuestName Runestone"], isWeeklyQuest = true, sortToTop = true,
                questPool = {
                    {name = "Fortify the Runestones: Magisters", questID = 90573, isWeeklyQuest = true, uiMapID = 2395, sortToTop = true},
                    {name = "Fortify the Runestones: Blood Knights", questID = 90574, isWeeklyQuest = true, uiMapID = 2395, sortToTop = true},
                    {name = "Fortify the Runestones: Farstriders", questID = 90575, isWeeklyQuest = true, uiMapID = 2395, sortToTop = true},
                    {name = "Fortify the Runestones: Shades of the Row", questID = 90576, isWeeklyQuest = true, uiMapID = 2395, sortToTop = true},
                },
            },

            --{name = "Weekly Delve", localizedName = L["Bountiful Delve"], isDelveReputation = true, flagQuest = 83317, accountwide = true},
        },
        questLines = {5841},
    },
};


do  --Add Prey Quests
    local PreyWorldQuests = {
        --C_QuestLine.GetQuestLineQuests(5954)
        91458,
        91523,
        91590,
        91591,
        91592,
        91594,
        91595,
        91596,
        91207,
        91601,
        91602,
        91604,
    };

    local target = ActivityData[1].entries;
    local n = #target;

    for _, questID in ipairs(PreyWorldQuests) do
        n = n + 1;
        target[n] = {
            name = L["Prey System"],
            questID = questID,
            shownIfActive = true,
            removeSharedPrefix = true,
        };
    end

    --[[    ???
        92392 (#1)
    --]]
end


LandingPageUtil.AddExpansionData(12, "activity", ActivityData);


local DynamicQuestMaps = {
    [2393] = "map2393",     --Silvermoon
};
LandingPageUtil.AddExpansionData(12, "activityQuestMap", DynamicQuestMaps);
