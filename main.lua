wW, wH = love.graphics.getDimensions()

function love.load()
    GRID = require("grid")
    gridInstance = GRID:new(30, 20)
end

function love.draw()
    GRID:draw()
end

function love.mousepressed(x, y, button)
    GRID:mousepressed(x, y, button)
end