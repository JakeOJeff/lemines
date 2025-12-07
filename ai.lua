local ai = {}

function ai:load()
    self.moves = {}
end

function ai:beginScout()
    while self:countRevealed() < 4 do
        if self:countRevealed() <= 2 then
            self:chooseRandom()
        else
            local revealed = GEN:revealedCells()
            if #revealed == 0 then
                self:chooseRandom()
            end

            local randCell = revealed[love.math.random(1, #revealed)]
            local pick = self:chooseRandomAdjacent(randCell)

            if pick then
                GEN:revealNearby(pick)
                if pick.mine then
                    loadState(mineNum, 20)
                    break
                end
            else
                self:chooseRandom()
            end
        end
    end
    self:assignWeight()
    -- self:revealAdjIfFlagged()
    -- self:flagUnrevealed()
    self:flagHighest()
    self:floodRevealedValues()
end

function ai:chooseRandom()
    local cell = GRID.cells[love.math.random(1, GRID.w / GRID.size)][love.math.random(1, GRID.h / GRID.size)]
    if not cell.revealed then
        GEN:revealNearby(cell)
        print("[RAND] MOVE ON:" .. cell.r .. " " .. cell.c)
        table.insert(self.moves, { cell.r, cell.c })


        for _, ncell in ipairs(GRID:getNeighbors(cell)) do
            if not ncell.mine and not ncell.revealed then
                GEN:revealFlood(ncell)
            end
        end
    end
end

function ai:assignWeight()
    GRID:iterate(function(cell)
        cell.weight = cell.revealed and 0 or self:adjacentSum(cell)
    end)
end

function ai:chooseRandomAdjacent(cell)
    local unrevealedCells = {}

    for _, ncell in ipairs(GRID:getNeighbors(cell)) do
        if not ncell.revealed then
            table.insert(unrevealedCells, ncell)
        end
    end
    if #unrevealedCells == 0 then
        return nil
    end
    local random = unrevealedCells[love.math.random(1, #unrevealedCells)]

    print("[RAND ADJ] MOVE ON:" .. cell.r .. " " .. cell.c)
    table.insert(self.moves, { cell.r, cell.c })

    return random
end

-- function ai:revealAdjIfFlagged()
--     GRID:iterate(function(cell)
--         if cell.value == self:countAdjFlag(cell) then
--             print("[FLAG-REV] MOVE ON:" .. cell.r .. " " .. cell.c)
--             table.insert(self.moves, { cell.r, cell.c })

--             GEN:revealNearby(cell)
--         end
--     end)
-- end

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

function ai:adjacentSum(cell)
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

-- function ai:countAdjFlag(cell)
--     local val = 0

--     for _, ncell in ipairs(GRID:getNeighbors(cell)) do
--         if ncell.flagged then
--             val = val + 1
--         end
--     end

--     return val
-- end

-- function ai:flagUnrevealed()
--     GRID:iterate(function(cell)
--         if not cell.revealed then
--             cell.flagged = true
--         end
--     end)
-- end

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
