local _, addon = ...


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