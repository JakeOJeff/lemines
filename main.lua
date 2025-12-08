wW, wH = love.graphics.getDimensions()

function love.load()
    mineNum = 50
    gameSize = 20
    scrollVal = 0
    loadState(mineNum, gameSize)
end

function loadState(mines, size)
    QUAD = require("quad")
    GRID = require("grid")
    GEN = require("gen")
    AI = require("ai")
    gridInstance = GRID:new(size, size)
    GEN:create(mines)
    AI:load()
    GRID.revealAll = false
end

function love.update(dt)

end

function love.draw()
    GRID:draw()
    local hoverCell = GRID:hover()
    if hoverCell then
        love.graphics.print(hoverCell.r .. "," .. hoverCell.c.."\n B-Click Y-Flag", 20, 20)
    end
    local len = #AI.moves
    for i = 1, 4 do
        local idx = len - 4 + i
        if idx >= 1 and idx <= len then
            local move = AI.moves[idx]
            if move then
                love.graphics.print(move[1] .. "," .. move[2], 20, 40 + (10 * i))
            end
        end
    end
end

function love.mousepressed(x, y, button)
    GRID:mousepressed(x, y, button)
end

function love.keypressed(key)
    if key == "e" then
        AI:beginScout()
    elseif key == "r" then
        loadState(mineNum, gameSize)
    elseif key == "q" then
        for i, v in ipairs(GRID.cells) do
            for j, cell in ipairs(v) do
                cell.flagged = false
                cell.revealed = false
                cell.weight = 0
            end
        end
    end
end
