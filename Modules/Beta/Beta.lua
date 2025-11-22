--local _, addon = ...


do  --XML
    --[[
        smoothScaling="true"
    --]]
end


do  --Retired Modules/Features


    --[[ Likely
        -- SpellcastInfo (Completely)
        -- SoftTargetName: Cast Bar, Name Color
    --]]


    --[[ Unsure
        -- Plumber Macro: EditMacro() protected (64124)
    --]]
end


do  --Decore API
    --[[
        C_Item.IsDecorItem (ItemType: 20)


        HousingModelPreviewMixin:PreviewCatalogEntryInfo(catalogEntryInfo)  Structure: HousingCatalogEntryInfo


        local modelSceneID = catalogEntryInfo.uiModelSceneID or Constants.HousingCatalogConsts.HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT;
	    local actor = self.ModelScene:GetActorByTag("decor");
		if actor then
			actor:SetPreferModelCollisionBounds(true);
			actor:SetModelByFileID(catalogEntryInfo.asset);
		end


        local entryInfo = C_HousingCatalog.GetCatalogEntryInfo(entryID);
        local shouldShowOption = entryInfo and entryInfo.quantity > 0 or false;

        BaseHousingCatalogEntryTemplate
    --]]
end


do  --Transmog API
    --Interface/AddOns/Blizzard_APIDocumentationGenerated/TransmogItemsDocumentation.lua
    --https://sourcegraph.com/github.com/Gethe/wow-ui-source@beta/-/blob/Interface/AddOns/Blizzard_APIDocumentationGenerated/TransmogItemsDocumentation.lua

    --C_TooltipInfo.GetOutfit

    --Blizzard_Transmog/Blizzard_Transmog.lua

    --C_TransmogOutfitInfo

    --C_TransmogOutfitInfo.ChangeDisplayedOutfit(outfitID, Enum.TransmogSituationTrigger.Manual, toggleLock, allowRemoveOutfit);


    local AB = CreateFrame("Button", nil, UIParent);
    AB:SetSize(40, 40);
    AB:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
    AB.BG = AB:CreateTexture(nil, "BACKGROUND");
    AB.BG:SetAllPoints(true);
    AB.BG:SetColorTexture(1, 0, 0, 0.5);
    AB:Show();
    
    AB:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonDown", "RightButtonUp");

    --[[
    AB:SetAttribute("type1", "function");
    AB:SetAttribute("_function", function()
        print("CLICK")
        local toggleLock = false;
        local allowRemoveOutfit = false;
        C_TransmogOutfitInfo.ChangeDisplayedOutfit(2, Enum.TransmogSituationTrigger.Manual, toggleLock, allowRemoveOutfit);
    end);
    --]]

    --AB:SetAttribute("type1", "action");
    --AB:SetAttribute("action", 45);

    --1247917: Clear Transmog

    --/script local f=TransmogFrame;f:SetAttribute("UIPanelLayout-area", "left");f:SetAttribute("UIPanelLayout-width", 200)
end


do  --Color API
    --C_ColorUtil
end


do  --Housing APIs
    --HouseEditorUIDocumentation
    --HousingBasicModeUIDocumentation.lua
        --C_HousingBasicMode
    --HousingExpertModeUIDocumentation.lua

    --GetHoveredDecorInfo
end


do  --Quest API
    --GetQuestLogRewardFavor
    --GetActivePreyQuest
end

