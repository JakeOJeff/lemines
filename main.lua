wW, wH = love.graphics.getDimensions()

function love.load()
    mineNum = 50
    gameSize = 20
    scrollVal = 0
    font = love.graphics.newFont("font.ttf",24)
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
    love.graphics.setFont(font)
    local hoverCell = GRID:hover()
    if hoverCell then
        love.graphics.print(hoverCell.r .. ":" .. hoverCell.c.."\nB-Click Y-Flag", 20, 20)
    end
    local len = #AI.moves
    for i = 1, 4 do
        local idx = len - 4 + i
        if idx >= 1 and idx <= len then
            local move = AI.moves[idx]
            if move then
                love.graphics.print(move[1] .. ":" .. move[2], 20, font:getHeight() * 2 + (font:getHeight() * i))
            end
        end
    end
    love.graphics.print("| E - AI Scout \n| R - Restart \n| Q - Clear Flags", 20, wH - 100)
    local topText = "Mines: "..(mineNum - GRID:countFlagged()).." | Size: "..gameSize.."x"..gameSize.."\nModel Win Rate: ".. (GRID:countFlagged()/mineNum * 100).."%\nStatus: "..(GRID:checkComplete() and "Complete" or (GRID:hitMine() and "Game Lost" or "In Progress"))
    love.graphics.print(topText, wW/2 - font:getWidth(topText)/2, 20)
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
