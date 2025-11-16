local _, addon = ...
if addon.IS_MIDNIGHT then return end;


local L = addon.L;
local API = addon.API;


local D = {};


local BlizzardTransmogUtil = _G.TransmogUtil;
local TransmogUtil = {};
addon.TransmogUtil = TransmogUtil;


local GetAppearanceSources = C_TransmogCollection.GetAppearanceSources;


local function ShouldAcceptDressUp(frame)
	local parentFrame = frame.parentFrame;
	if parentFrame == nil then
		return;
	end

	if parentFrame.ShouldAcceptDressUp then
		return parentFrame:ShouldAcceptDressUp();
	end

	return parentFrame:IsShown();
end

local function GetDressUpFrame()
	if ShouldAcceptDressUp(SideDressUpFrame) then
		return SideDressUpFrame
	elseif ShouldAcceptDressUp(TransmogAndMountDressupFrame) then
		return TransmogAndMountDressupFrame
	else
		return DressUpFrame
	end
end


local HiddenVisuals = {
    --[slotID] = visualID (appearanceID) --sourceID (modifiedAppearanceID)
    [1] = 29124,    --77344
    [3] = 24531,    --77343
    [5] = 40282,    --104602
    [4] = 33155,    --83202
    [19]= 33156,    --83203
    [9] = 40284,    --104604
    [10]= 37207,    --94331
    [6] = 33252,    --84233
    [7] = 42568,    --198608
    [8] = 40283,    --104603
};

local function GetHiddenSourceIDForSlot(slotID)
    local visualID = HiddenVisuals[slotID]
    local sources = visualID and GetAppearanceSources(visualID);
    if sources and sources[1] then
        return sources[1].sourceID
    end
end
TransmogUtil.GetAppearanceSources = GetAppearanceSources;


local function PopupateInfoListWithHiddenVisuals(itemTransmogInfoList)
    for slotID, itemTransmogInfo in ipairs(itemTransmogInfoList) do
        if itemTransmogInfo.appearanceID == 0 then
            local hiddenVisualID = GetHiddenSourceIDForSlot(slotID);
            if hiddenVisualID then
                itemTransmogInfo.appearanceID = hiddenVisualID;
            end
        end
    end
end
TransmogUtil.PopupateInfoListWithHiddenVisuals = PopupateInfoListWithHiddenVisuals;




local function DressUpItemTransmogInfoList_Callback(itemTransmogInfoList, showOutfitDetails, forcePlayerRefresh)
    if not D.enabled then return end;

    PopupateInfoListWithHiddenVisuals(itemTransmogInfoList);

    local frame = WardrobeTransmogFrame;
    if frame and frame:IsVisible() and C_Transmog.IsAtTransmogNPC() then
        if (not InCombatLockdown()) and DressUpFrame:IsShown() then
            HideUIPanel(DressUpFrame);
        end

        local _, _, classID = UnitClass("player");
        local GetAppearanceSourceInfo = C_TransmogCollection.GetAppearanceSourceInfo;
        local GetValidAppearanceSourcesForClass = C_TransmogCollection.GetValidAppearanceSourcesForClass;
        local category, visualID, sources;
        local numFound = 0;
        local numTotal = 0;
        local categoryXSourceID = {};
        local itemModifiedAppearanceID;

        for slotID, itemTransmogInfo in ipairs(itemTransmogInfoList) do
            if itemTransmogInfo.appearanceID and itemTransmogInfo.appearanceID ~= 0 then
                numTotal = numTotal + 1;
                itemModifiedAppearanceID = itemTransmogInfo.appearanceID;
                category, visualID = GetAppearanceSourceInfo(itemModifiedAppearanceID);
                sources = visualID and GetValidAppearanceSourcesForClass(visualID, classID);
                if sources then
                    for _, v in ipairs(sources) do
                        if v.isCollected then
                            numFound = numFound + 1;
                            if categoryXSourceID[v.categoryID] then
                                --print("DUPE", v.categoryID, v.name);
                            else
                                categoryXSourceID[v.categoryID] = v.sourceID;
                            end
                            itemTransmogInfo.transmogCategoryID = v.categoryID;
                            itemTransmogInfo.foundVisualID = v.sourceID;
                            --print("name", v.name, itemTransmogInfo.appearanceID)
                            break
                        end
                    end
                end
            end
        end

        local pendingType = Enum.TransmogPendingType.Apply;
        local SetPending = C_Transmog.SetPending;

        for _, slotButton in ipairs(frame.SlotButtons) do
            if slotButton:IsShown() and slotButton.transmogLocation then
                local slotID = slotButton.transmogLocation.slotID;
                local info = slotID and itemTransmogInfoList[slotID];
                if info and info.foundVisualID then
                    local newPendingInfo = BlizzardTransmogUtil.CreateTransmogPendingInfo(pendingType, info.foundVisualID, info.transmogCategoryID);
                    if newPendingInfo then
                        SetPending(slotButton.transmogLocation, newPendingInfo);
                    end
                end
            end
        end

        local diff = numTotal - numFound;
        if diff > 0 then
            API.PrintMessage(L["Missing Appearances Format"]:format(diff));     --TRANSMOGRIFY_STYLE_UNCOLLECTED
        end

        return
    else
        frame = nil;
    end

    if not frame then frame = GetDressUpFrame() end;
    if not frame then return end;

    local playerActor = frame.ModelScene:GetPlayerActor();
    if not playerActor or not itemTransmogInfoList then
        return
    end

    playerActor:Undress();

    local mainHandSlot = INVSLOT_MAINHAND;

    for slotID, itemTransmogInfo in ipairs(itemTransmogInfoList) do
        local ignoreChildItems = slotID ~= mainHandSlot;
        playerActor:SetItemTransmogInfo(itemTransmogInfo, slotID, ignoreChildItems);
    end
end


local function HookDressUpFunctions()
    if D.functionsHooked then return end;
    D.functionsHooked = true;

    if DressUpItemTransmogInfoList then
        hooksecurefunc("DressUpItemTransmogInfoList", DressUpItemTransmogInfoList_Callback);
    end
end


local function AddCopyButtonToDropdowns()
    if D.menuModified then return end;
    D.menuModified = true;


    --SpecDropdown
    Menu.ModifyMenu("MENU_TRANSMOG", function(owner, rootDescription, contextData)
        if not D.enabled then return end;

        local f = WardrobeTransmogFrame;
        local playerActor = f and f.ModelScene and f.ModelScene:GetPlayerActor();
        local itemTransmogInfoList = playerActor and playerActor:GetItemTransmogInfoList();
        local slashCommand = itemTransmogInfoList and BlizzardTransmogUtil.CreateOutfitSlashCommand(itemTransmogInfoList);

        if slashCommand then
            rootDescription:CreateDivider();
            rootDescription:CreateTitle("Plumber");

            local function CopyButton_OnClick()
                addon.ShowClipboard(slashCommand);
            end

            local button1 = rootDescription:CreateButton(L["Copy To Clipboard"], CopyButton_OnClick);
            button1:SetTooltip(function(tooltip, elementDescription)
                tooltip:SetText(L["Copy To Clipboard"], 1, 1, 1);
                tooltip:AddLine(L["Copy Current Outfit Tooltip"], 1, 0.82, 0, true);
            end);
        end
    end);


    --WardrobeSetsTransmogModelMixin:OnMouseUp(), Blizzard_Wardrobe_Sets
    Menu.ModifyMenu("MENU_WARDROBE_SETS_MODEL_FILTER", function(owner, rootDescription, contextData)
        if not D.enabled then return end;

        local f = WardrobeCollectionFrame and WardrobeCollectionFrame.SetsTransmogFrame;
        if not (f and f:IsVisible()) then
            f = BetterWardrobeCollectionFrame and BetterWardrobeCollectionFrame.SetsTransmogFrame;
            if not (f and f:IsVisible()) then
                f = nil;
            end
        end

        local activeModel;

        if f and f.Models then
            for _, model in ipairs(f.Models) do
                if model:IsMouseOver() then
                    if model:IsObjectType("DressUpModel") then
                        activeModel = model;
                    end
                    break
                end
            end
        end

        local slashCommand;
        if activeModel then
            local itemTransmogInfoList = activeModel:GetItemTransmogInfoList();
            slashCommand = itemTransmogInfoList and BlizzardTransmogUtil.CreateOutfitSlashCommand(itemTransmogInfoList);
        end

        if slashCommand then
            rootDescription:CreateDivider();

            local function CopyButton_OnClick()
                addon.ShowClipboard(slashCommand);
                C_Timer.After(0, function()
                    GameTooltip:Hide();
                end);
            end

            local button1 = rootDescription:CreateButton(L["Copy To Clipboard"], CopyButton_OnClick);
            button1:SetTooltip(function(tooltip, elementDescription)
                tooltip:SetText(L["Copy To Clipboard"], 1, 1, 1);
                tooltip:AddLine(L["Copy Current Outfit Tooltip"], 1, 0.82, 0, true);
            end);
        end
    end);
end




do
    local function EnableModule(state)
        if state and not D.enabled then
            D.enabled = true;
            HookDressUpFunctions();
            AddCopyButtonToDropdowns();
        elseif (not state) and D.enabled then
            D.enabled = nil;
        end
    end

    local moduleData = {
        name = addon.L["ModuleName TransmogChatCommand"],
        dbKey = "TransmogChatCommand",
        description = addon.L["ModuleDescription TransmogChatCommand"],
        toggleFunc = EnableModule,
        categoryID = 1,
        uiOrder = 1205,
        moduleAddedTime = 1763100000,
    };

    addon.ControlCenter:AddModule(moduleData);
end




--/script Transmog_LoadUI();ShowUIPanel(TransmogFrame)