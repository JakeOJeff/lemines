local gen = {}

function gen:create(mines)
    local m = mines

    while m > 0 do
        local randR = love.math.random(1, GRID.w/GRID.size)
        local randC = love.math.random(1, GRID.h/GRID.size)

        if GRID.cells[randR][randC].mine == false then
            GRID.cells[randR][randC].mine = true
            m = m - 1
        end
    end

    for i, v in ipairs(GRID.cells) do
        for j, cell in ipairs(GRID.cells) do
            if not cell.mine then
                self:countMines(cell)
            end
        end
    end
end

function gen:countMines(cell)
    local count = 0
    local function checkSide(factorX, factorY)
        local cC = GRID.cells[cell.r + factorX][cell.c + factorY]
        if cC and cC.mine then
            count = count + 1
        end
    end

    checkSide(-1, -1)
    checkSide(-1, 0)
    checkSide(-1, 1)

    checkSide(1, -1)
    checkSide(1, 0)
    checkSide(1, 1)
end

return gen