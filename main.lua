wW, wH = love.graphics.getDimensions()

function love.load()
    loadState(100, 20)
end

function loadState(mines, size)
    QUAD = require("quad")
    GRID = require("grid")
    GEN = require("gen")
    AI = require("ai")
    gridInstance = GRID:new(size, size)
    GEN:create(mines)
    GRID.revealAll = false
    AI:load()
end

function love.draw()
    GRID:draw()
end

function love.mousepressed(x, y, button)
    GRID:mousepressed(x, y, button)
end
