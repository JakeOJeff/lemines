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

    for i, v in ipairs(GRID.cells) do
        for j, cell in ipairs(v) do
            if not cell.mine then
                cell.value = self:countMines(cell)
            end
        end
    end
end

function gen:countMines(cell)
    local count = 0
    local function checkSide(dx, dy)
        local nr = cell.r + dx
        local nc = cell.c + dy

        if GRID.cells[nr] and GRID.cells[nr][nc] then
            if GRID.cells[nr][nc].mine then
                count = count + 1
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
    return count
end

function gen:countFlagged(cell)
    local count = 0
    local function checkSide(dx, dy)
        local nr = cell.r + dx
        local nc = cell.c + dy

        if GRID.cells[nr] and GRID.cells[nr][nc] then
            if GRID.cells[nr][nc].flagged then
                count = count + 1
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
    return count
end

function gen:revealedCells()
    local tab = {}
    for i, v in ipairs(GRID.cells) do
        for j, cell in ipairs(v) do
            if cell.revealed then
                table.insert(tab, cell)
            end
        end
    end
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

    for dx = -1, 1 do
        for dy = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local nr = cell.r + dx
                local nc = cell.c + dy

                if GRID.cells[nr] and GRID.cells[nr][nc] then
                    local ncell = GRID.cells[nr][nc]
                    if not ncell.mine and not ncell.revealed then
                        print("MOVE ON:" .. cell.r .. " " .. cell.c)
                        table.insert(AI.moves, {cell.r, cell.c})

                        self:revealFlood(ncell)
                    end
                end
            end
        end
    end
end

function gen:revealNearby(cell)
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local nr = cell.r + dx
                local nc = cell.c + dy

                local ncell = GRID.cells[nr] and GRID.cells[nr][nc]
                if ncell and not ncell.mine and not ncell.revealed then
                    self:revealFlood(ncell)
                end
            end
        end
    end
end
return gen
