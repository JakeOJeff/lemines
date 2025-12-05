local ai = {}

function ai:load()

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
                pick.revealed = true
                if pick.mine then
                    loadState(mineNum, 20)
                    break
                end
            else
                self:chooseRandom()
            end
        end
    end
end

function ai:chooseRandom()
    local cell = GRID.cells[love.math.random(1, GRID.w / GRID.size)][love.math.random(1, GRID.h / GRID.size)]
    if not cell.revealed then
        cell.revealed = true
        print("MOVE ON:" .. cell.r .. " " .. cell.c)
        for dx = -1, 1 do
            for dy = -1, 1 do
                if not (dx == 0 and dy == 0) then
                    local nr = cell.r + dx
                    local nc = cell.c + dy

                    if GRID.cells[nr] and GRID.cells[nr][nc] then
                        local ncell = GRID.cells[nr][nc]
                        if not ncell.mine and not ncell.revealed then
                            GEN:revealFlood(ncell)
                        end
                    end
                end
            end
        end
    end
end

function ai:assignWeight()
    for i, v in ipairs(GRID.cells) do
        for j, cell in ipairs(v) do
            local s = self:adjacentSum(cell)
            s = s + self:adjacentRevealedCount(cell)
            cell.weight = s
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
    if #unrevealedCells == 0 then
        return nil
    end
    local random = unrevealedCells[love.math.random(1, #unrevealedCells)]
    print("MOVE ON:" .. cell.r .. " " .. cell.c)

    return random
end

function ai:chooseAdjacent()

end

function ai:adjacentSum(cell)
    local sum = 0
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local nr = cell.r + dx
                local nc = cell.c + dy

                if GRID.cells[nr] and GRID.cells[nr][nc] then
                    local ncell = GRID.cells[nr][nc]
                    sum = sum + self:checkSubFlagCount(ncell)
                end
            end
        end
    end
end

function ai:checkSubFlagCount(cell)
    local val = cell.value
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local nr = cell.r + dx
                local nc = cell.c + dy


                if GRID.cells[nr] and GRID.cells[nr][nc] then
                    local ncell = GRID.cells[nr][nc]
                    if ncell.flagged then
                        val = val - 1
                    end
                end
            end
        end
    end

    return val
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
