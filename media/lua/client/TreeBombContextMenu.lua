if isServer() then return end

globalRadius = 10

local function activateTreeBomb(p, item)
    local x = getPlayer():getX()
    local y = getPlayer():getY()

    local square

    local didAThingFlag = false

    for xOffset = -globalRadius, globalRadius do
        for yOffset = -globalRadius, globalRadius do
            square = getCell():getGridSquare(x + xOffset, y + yOffset, 0)
            local objects = square:getObjects()

            for index = 0, objects:size() - 1 do
                local NatureThing = objects:get(index)
                if instanceof(NatureThing, "IsoTree") then
                    NatureThing:Damage(1000000)
                    didAThingFlag = true
                end

                if NatureThing and NatureThing:getProperties() and NatureThing:getProperties():Is(IsoFlagType.canBeRemoved) then
                    square:transmitRemoveItemFromSquare(NatureThing)
                    didAThingFlag = true
                end

                if NatureThing and NatureThing:getProperties() and NatureThing:getProperties():Is(IsoFlagType.canBeCut) then
                    square:transmitRemoveItemFromSquare(NatureThing)
                    didAThingFlag = true
                end
            end
        end
    end

    if didAThingFlag then
        getSoundManager():PlaySound("treebomb", false, 1)
    end
end

local function getTreeBombRadius(p, item)
    return globalRadius
end

local function setTreeBombRadius(p, item, radius)
    globalRadius = radius
end

local function AddTreeBombContextMenu(p, context, items)
    local item

    if #items > 1 then return; end

    local playerObject = getPlayer()

    if not instanceof(items[1], "InventoryItem") then
        item = items[1].items[1]
    else
        item = items[1]
    end

    if item:getType() ~= "TreeBomb" then return end

    context:addOption("Activate", playerObject, activateTreeBomb, item)
    local radiusMenuParent = context:addOption("Set Radius")
    local radiusMenuChild = ISContextMenu:getNew(context)
    context:addSubMenu(radiusMenuParent, radiusMenuChild)

    local currentRadius = "Current Radius: " .. globalRadius:toString()

    radiusMenuChild:addOption(currentRadius)
    radiusMenuChild:addOption("10", playerObject, setTreeBombRadius, item, 10)
    radiusMenuChild:addOption("20", playerObject, setTreeBombRadius, item, 20)
    radiusMenuChild:addOption("50", playerObject, setTreeBombRadius, item, 50)
end

local function AddPlacedTreeBombContextMenu(p, context, items)
    local item = nil

    for _, object in ipairs(items) do
        if instanceof(object, "IsoObject") and object:getSprite() and object:getSprite():getProperties() and (object:getSprite():getProperties():Val("CustomName") == "Tree Bomb") then
            item = object
            break
        end
    end

    if not item then return end

    local playerObject = getPlayer()

    context:addOption("Activate", playerObject, activateTreeBomb, item)
    local radiusMenuParent = context:addOption("Set Radius")
    local radiusMenuChild = ISContextMenu:getNew(context)
    context:addSubMenu(radiusMenuParent, radiusMenuChild)

    local currentRadius = "Current Radius: " .. globalRadius:toString()

    radiusMenuChild:addOption(currentRadius)
    radiusMenuChild:addOption("10", playerObject, setTreeBombRadius, item, 10)
    radiusMenuChild:addOption("20", playerObject, setTreeBombRadius, item, 20)
    radiusMenuChild:addOption("50", playerObject, setTreeBombRadius, item, 50)
end

local firstUpdate = true

local function OnPlayerUpdate(p)
    if firstUpdate and p == getPlayer() then
        firstUpdate = false
        Events.OnFillInventoryObjectContextMenu.Add(AddTreeBombContextMenu)
    end
end

-- Events.OnFillWorldObjectContextMenu.Add(AddPlacedTreeBombContextMenu)
Events.OnPlayerUpdate.Add(OnPlayerUpdate)