local ai = {}

function ai:load()
    self.moves = {}
end

function ai:beginScout()
    if not GRID:hitMine() then
        while GRID:countRevealed() < 2 do
            self:chooseRandom()
            self:checkIfRevealedMine()
        end
        self:assignWeight()

        self:flagHighest()
        self:floodRevealedValues()
    end
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
        if cell.revealed or cell.flagged then
            cell.weight = 0
        else
            cell.weight = self:adjacentWeight(cell)
        end
    end)
end

function ai:checkIfRevealedMine()
    local hit = false
    GRID:iterate(function(cell)
        if cell.revealed and cell.mine then
            hit = true
            cell.hitMine = true
        end
    end)
    return hit
end

function ai:flagHighest()
    local cell = self:findHighestWeight()
    if not cell or cell.weight <= 0 then return false end

    cell.flagged = true
    return true
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
        if not cell.revealed and not cell.flagged and cell.weight and cell.weight > highest then
            highest = cell.weight
            highestCell = cell
        end
    end)
    return highestCell
end

function ai:adjacentWeight(cell)
    if cell.revealed or cell.flagged then return 0 end
    local weight = 0

    for _, ncell in ipairs(GRID:getNeighbors(cell)) do
        if ncell.revealed and ncell.value > 0 then
            local remaining = ncell.value - GEN:countFlagged(ncell)
            if remaining > 0 then
                weight = weight + remaining
            end
        end
    end
    return weight
end

return ai
