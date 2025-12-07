local gen = {}

function gen:create(mines)
    local m = mines

    while m > 0 do
        local randR = love.math.random(1, GRID.w / GRID.size)
        local randC = love.math.random(1, GRID.h / GRID.size)

        if GRID.cells[randR][randC].mine == false then
            GRID.cells[randR][randC].mine = true
            m = m - 1
        end
    end

    GRID:iterate(function(cell)
        if not cell.mine then
            cell.value = self:countMines(cell)
        end
    end)
end

function gen:countMines(cell)
    local count = 0

    for _, ncell in ipairs(GRID:getNeighbors(cell)) do
        if ncell.mine then
            count = count + 1
        end
    end
    return count
end

function gen:countFlagged(cell)
    local count = 0

    for _, ncell in ipairs(GRID:getNeighbors(cell)) do
        if ncell.flagged then
            count = count + 1
        end
    end

    return count
end

function gen:revealedCells()
    local tab = {}

    GRID:iterate(function(cell)
        if cell.revealed then
            table.insert(tab, cell)
        end
    end)
    return tab
end

function gen:revealFlood(cell)
    if cell.revealed then
        return
    end

    cell.revealed = true

    if cell.value > 0 then
        return
    end

    for _, ncell in ipairs(GRID:getNeighbors(cell)) do
        if not ncell.revealed and not ncell.flagged then
            table.insert(AI.moves, { ncell.r, ncell.c })
            self:revealFlood(ncell)
        end
    end
end

function gen:revealNearby(cell)
    for _, ncell in ipairs(GRID:getNeighbors(cell)) do
        if ncell and not ncell.revealed and not ncell.flagged then
            if ncell.value == 0 then
                self:revealFlood(ncell)
            else
                ncell.revealed = true
            end
        end
    end
end

return gen
