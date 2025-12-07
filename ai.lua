local ai = {}

function ai:load()
    self.moves = {}
end

function ai:beginScout()
    while self:countRevealed() < 2 do
        self:chooseRandom()
        if self:checkIfRevealedMine() then loadState(mineNum, gameSize) end
    end
    self:assignWeight()

    self:flagHighest()
    self:floodRevealedValues()
end

function ai:chooseRandom()
    local cell = GRID.cells[love.math.random(1, GRID.w / GRID.size)][love.math.random(1, GRID.h / GRID.size)]
    if not cell.revealed then
        GEN:revealNearby(cell)
        print("[RAND] MOVE ON:" .. cell.r .. " " .. cell.c)
        table.insert(self.moves, { cell.r, cell.c })
    end
end

function ai:assignWeight()
    GRID:iterate(function(cell)
        cell.weight = cell.revealed and 0 or self:adjacentWeight(cell)
    end)
end

function ai:checkIfRevealedMine()
    local hit = false
    GRID:iterate(function(cell)
        if cell.revealed and cell.mine then
            hit = true
        end
    end)
    return hit
end




function ai:flagHighest()
    local cell = self:findHighestWeight()
    if cell then
        cell.flagged = true
    end
end

function ai:floodRevealedValues()
    GRID:iterate(function(cell)
        if cell.revealed and GEN:countFlagged(cell) == cell.value then
            GEN:revealNearby(cell)
        end
    end)
end

function ai:findHighestWeight()
    local highest = 0
    local highestCell = nil
    GRID:iterate(function(cell)
        if cell.weight > highest then
            highest = cell.weight
            highestCell = cell
        end
    end)
    return highestCell
end

function ai:adjacentWeight(cell)
    local sum = 0

    for _, ncell in ipairs(GRID:getNeighbors(cell)) do
        if ncell.revealed then
            sum = sum + 1
            sum = sum + self:checkSubFlagCount(ncell)
        end
    end
    return sum
end

function ai:checkSubFlagCount(cell)
    local val = cell.value

    for _, ncell in ipairs(GRID:getNeighbors(cell)) do
        if ncell.flagged then
            val = val - 1
        end
    end

    return val
end


function ai:countRevealed()
    local count = 0

    GRID:iterate(function(cell)
        if cell.revealed then
            count = count + 1
        end
    end)

    return count
end

return ai
