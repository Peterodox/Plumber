--[[

changelog[versionID] = {
    {
        type = "date",
        versionText = "1.8.1",
        timestamp = 1764700000,
    },

    {
        type = "h1",    --Header
        isNewFeature = false,
        text = string,
        dbKey = dbKey,  --(Optional) Show the module's category
    },

    {
        type = "Checkbox",    --Checkbox    Create a module toggle, usually right below a header
        dbKey = dbKey,
    },

    {
        type = "p",    --Paragraph
        subHeader = string,
        text = string,  --If subHeader then return subHeader..": "..text
        bullet = false, --(Optional) If true, add a bullet point
    },

    {
        type = "img",   --Show preview image
        dbKey = dbKey,
    },

    {
        type = "tocVersionCheck",
        minimumTocVersion = 110207,
        breakpoint = false,     --(Optional) If true, the changelog will stop here
    },

    {
        type = "br",    --Line-break
    },
};

--]]