# Including nodeID, entryID
# https://wago.tools/db2/TraitNode?filter%5BTraitTreeID%5D=1161&page=1
# https://wago.tools/db2/TraitNodeXTraitNodeEntry?page=1
# https://wago.tools/db2/TraitEdge?filter%5BLeftTraitNodeID%5D=108114&page=1


import csv

dataSourcePath = 'G:\\Peter\\NarciUI TWW\\Resources\\'
outPutPath = 'G:\\Peter\\NarciUI TWW\\Python\\'

traitNode = open(dataSourcePath +'TraitNode.11.2.5.63286.csv')
r_traitNode = csv.reader(traitNode)

nodeXEntry = open(dataSourcePath +'TraitNodeXTraitNodeEntry.11.2.5.63286.csv')
r_nodeXEntry = csv.reader(nodeXEntry)

newLuaFile = open(outPutPath +'TraitData.lua', 'w', newline='')
f_LuaFile = csv.writer(newLuaFile)
f_LuaFile.writerow( ['local TraitNodeXEntryDB = {'] )

targetTreeID = '1161'


dict_nodeXEntry = {}
isFirstRow = True
for row in r_nodeXEntry:
    if isFirstRow:
        isFirstRow = False

    else:
        nodeID = row[1]
        entryID = row[2]
        index = row[3]

        if dict_nodeXEntry.get(nodeID) == None:
            dict_nodeXEntry[nodeID] = []
        
        dict_nodeXEntry[nodeID].append(entryID)


isFirstRow = True
numNodes = 0

isNodeRelevant = {}
isEntryRelevant = {}

for row in r_traitNode:
    if isFirstRow:
        isFirstRow = False

    else:
        nodeID = row[0]
        treeID = row[1]
        nodeType = row[4]
        if treeID == targetTreeID :
            numNodes = numNodes + 1
            isNodeRelevant[nodeID] = True
            entryIDs = '{'
            isFirstID = True
            if len(dict_nodeXEntry[nodeID]) == 1:
                _entryID = dict_nodeXEntry[nodeID][0]
                entryIDs = _entryID
                isEntryRelevant[_entryID] = True
            else:
                for _entryID in dict_nodeXEntry[nodeID]:
                    isEntryRelevant[_entryID] = True
                    if not isFirstID:
                        entryIDs = entryIDs + ', '
                    entryIDs = entryIDs + _entryID
                    isFirstID = False
                entryIDs = entryIDs + '}'
            print(entryIDs)

            f_LuaFile.writerow( [ '[' + nodeID + '] = ' + entryIDs, None ] )

print(numNodes)
f_LuaFile.writerow(['}'])




traitNodeEntry = open(dataSourcePath +'TraitNodeEntry.11.2.5.63286.csv')
r_traitNodeEntry = csv.reader(traitNodeEntry)

f_LuaFile.writerow('')
f_LuaFile.writerow( ['local TraitNodeEntryDB = {'] )
isFirstRow = True

for row in r_traitNodeEntry:
    if isFirstRow:
        isFirstRow = False

    else:
        entryID = row[0]
        definitionID = row[1]
        maxRanks = row[2]
        entryType = row[3]
        if isEntryRelevant.get(entryID) == True:
            f_LuaFile.writerow( [ '[' + entryID + '] = {' + definitionID + ', ' + maxRanks + ', ' + entryType + '}', None ] )

f_LuaFile.writerow(['}'])




traitEdge = open(dataSourcePath +'TraitEdge.11.2.5.63286.csv')
r_traitEdge = csv.reader(traitEdge)
isFirstRow = True
nextNodeID = {}

for row in r_traitEdge:
    if isFirstRow:
        isFirstRow = False

    else:
        leftNodeID = row[2]
        rightNodeID = row[3]
        if isNodeRelevant.get(leftNodeID) == True:
            nextNodeID[leftNodeID] = rightNodeID

f_LuaFile.writerow('')
f_LuaFile.writerow( ['local NextNodeDB = {'] )

for leftNodeID, rightNodeID in nextNodeID.items():
    f_LuaFile.writerow( [ '[' + leftNodeID + '] = ' + rightNodeID, None ] )

f_LuaFile.writerow(['}'])