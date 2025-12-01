--[[

changelog[versionID] = {
    {
        type = "h1",    --Header
        isNewFeature = false,
        text = string,
    },

    {
        type = "p",    --Paragraph
        subHeader = string,
        text = string,  --If subHeader then return subHeader..": "..text
        bullet = false, --If true, add a bullet point
    },

    {
        type = "Checkbox",    --Checkbox    Create a module toggle, usually right below a header
        dbKey = dbKey,
    },
};


--]]