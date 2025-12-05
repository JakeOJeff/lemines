local ai = {}

function ai:load()
    
end

function ai:beginScout()
    local revealedCount = self:countRevealed()
    while revealedCount < 5 do
        if revealedCount <= 2 then
            self:chooseRandom()
        else

        end
    end
end

function ai:chooseRandom()
    local cell = GRID.cells[love.math.random(1, GRID.w/GRID.size)][love.math.random(1, GRID.h/GRID.size)]
    if not cell.revealed then
        cell.revealed = true
        if cell.mine then
            return
        end


    end
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