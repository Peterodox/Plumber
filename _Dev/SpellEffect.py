import csv

dataSourcePath = 'G:\\Peter\\PlumberAddon\\SpellEffectFaction\\'
outPutPath = 'G:\\Peter\\PlumberAddon\\SpellEffectFaction\\'

itemData = open(dataSourcePath +'SpellEffect_11_2_0.csv')
r_itemData = csv.reader(itemData)


spellFactions = {}
isFirstRow = True
for row in r_itemData:
    if isFirstRow:
        isFirstRow = False
    else:
        effect = row[4]
        point = row[23]
        factionID = row[25]
        spellID = row[35]
        
        if effect == '103':
            spellFactions[ spellID ] = factionID



newLua = open(outPutPath + 'SpellFaction.lua', 'w', newline='')
f_Lua = csv.writer(newLua)
f_Lua.writerow( ['local SpellFaction = {'] )


numUniqueID = 0
for spellID, factionID in spellFactions.items():
    f_Lua.writerow( [ '[' + spellID + '] = ' +  factionID, None] )
    numUniqueID += 1


print(numUniqueID)
f_Lua.writerow(['}'])
