wW, wH = love.graphics.getDimensions()

function love.load()
    loadState(500, 20)
end

function loadState(mines, size)
    GRID = require("grid")
    GEN = require("gen")
    QUAD = require("quad")
    gridInstance = GRID:new(size, size)
    GEN:create(mines)
        GRID.revealAll = true

end

function love.draw()
    GRID:draw()
end

function love.mousepressed(x, y, button)
    GRID:mousepressed(x, y, button)
end