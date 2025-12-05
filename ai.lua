local ai = {}

function ai:load()
    
end

function ai:beginScout()
    while self:countRevealed() < 5 do
        self:chooseRandom()
    end
end

function ai:chooseRandom()
    local cell = GRID.cells[love.math.random(1, GRID.w/GRID.size)][love.math.random(1, GRID.h/GRID.size)]
    if not cell.revealed then
        cell.revealed = true
        if cell.mine then
            loadState(100, 20)
        end
    end
end

function ai:chooseRandomAdjacent(cell)
    local unrevealedCells = {}
    local function checkSide(dx, dy)
        local nr = cell.r + dx
        local nc = cell.c + dy

        if GRID.cells[nr] and GRID.cells[nr][nc] then
            if not GRID.cells[nr][nc].revealed then
                table.insert(unrevealedCells, GRID.cells[nr][nc])
            end
        end
    end

    checkSide(-1, -1)
    checkSide(0, -1)
    checkSide(1, -1)
    checkSide(-1, 0)

    checkSide(1, 0)
    checkSide(-1, 1)
    checkSide(0, 1)
    checkSide(1, 1)
    
    local random = unrevealedCells(love.math.random(1, #unrevealedCells))
    return random
end

function ai:chooseAdjacent()
    
end

function ai:countRevealed()
    local count = 0
    for i, v in ipairs(GRID.cells) do
        for j, cell in ipairs(v) do
            if cell.revealed then
                count = count + 1
            end
        end
    end

    return count
end

return ai