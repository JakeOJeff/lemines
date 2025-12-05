local grid = {}
-- * TODO 
function grid:new(w, h)
    self.size = 20
    self.w = self.size * w
    self.h = self.size * h

    self.x = wW / 2 - self.w / 2
    self.y = wH / 2 - self.h / 2

    self.cells = {}
    for i = 1, w do
        self.cells[i] = {}
        for j = 1, h do
            self.cells[i][j] = {
                revealed = false,
                mine = false,
                value = 0,
                r = i,
                c = j
            }
        end
    end

    QUAD:generateNums()

end

function grid:draw()
    for i, v in ipairs(self.cells) do
        for j, cell in ipairs(v) do

            love.graphics.rectangle("line", self.x + (i - 1) * self.size, self.y + (j - 1) * self.size, self.size,
                self.size)
            if cell.mine then
                love.graphics.draw(spritesheet, QUAD.bombs[1], self.x + (i - 1) * self.size, self.y + (j - 1) * self.size)
            end
            love.graphics.setColor(1, 1, 1)
            if not cell.mine  then
                -- love.graphics.print(cell.value, self.x + (i - 1) * self.size, self.y + (j - 1) * self.size)
                local q = QUAD.nums[cell.value]
                if q and cell.value > 0 then
                    love.graphics.draw(spritesheet, q, self.x + (i - 1) * self.size, self.y + (j - 1) * self.size)
                else
                    love.graphics.draw(spritesheet,  QUAD.nums[9], self.x + (i - 1) * self.size, self.y + (j - 1) * self.size)
                end
            end
        end
    end
end

function grid:hover()
    local mx, my = love.mouse.getPosition()

    for i, v in ipairs(self.cells) do
        for j, cell in ipairs(v) do
            local cellX = self.x + (i - 1) * self.size
            local cellY = self.y + (j - 1) * self.size

            if mx >= cellX and mx <= cellX + self.size and my >= cellY and my <= cellY + self.size then
                return self.cells[i][j]
            end
        end
    end
end

function grid:mousepressed(x, y, button)
    if button == 1 then
        local cell = self:hover()
        if cell then
            cell.revealed = true
        end
    end
end

return grid
