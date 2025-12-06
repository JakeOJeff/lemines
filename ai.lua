local ai = {}

function ai:load()
    self.moves = {}
    self.moveQueue = {}       -- queue of pending actions
    self.running = false
    self.delay = 0.18         -- seconds between actions (tweak)
    self.timer = 0
end

-- helper to push an action into the queue
function ai:enqueue(action)
    table.insert(self.moveQueue, action)
end

-- pop front
local function dequeue(q)
    return table.remove(q, 1)
end

-- Start planning the scout but don't execute reveals immediately.
-- This mirrors your original beginScout logic but *enqueues* actions
-- instead of directly mutating cells.
function ai:planScout()
    -- replicate the decision logic, but enqueue actions
    while self:countRevealed() + #self.moveQueue < 4 do
        if self:countRevealed() <= 2 then
            -- chooseRandom should return a cell rather than reveal it
            local cell = self:pickRandomCell()
            if cell then
                self:enqueue({type="reveal", cell=cell})
            end
        else
            local revealed = GEN:revealedCells()
            if #revealed == 0 then
                local cell = self:pickRandomCell()
                if cell then self:enqueue({type="reveal", cell=cell}) end
            else
                local randCell = revealed[love.math.random(1, #revealed)]
                local pick = self:pickRandomAdjacent(randCell)
                if pick then
                    self:enqueue({type="reveal", cell=pick})
                else
                    local cell = self:pickRandomCell()
                    if cell then self:enqueue({type="reveal", cell=cell}) end
                end
            end
        end
    end

    -- After planning reveals, enqueue the follow-up actions you did at end of beginScout
    self:enqueue({type="assignWeight"})
    self:enqueue({type="revealAdjIfFlagged"})
    self:enqueue({type="flagUnrevealed"})
end

-- pickRandomCell returns a valid non-revealed cell (does not mutate it)
function ai:pickRandomCell()
    local tries = 0
    for _ = 1, 200 do
        local r = love.math.random(1, GRID.w / GRID.size)
        local c = love.math.random(1, GRID.h / GRID.size)
        local cell = GRID.cells[r] and GRID.cells[r][c]
        if cell and not cell.revealed then
            return cell
        end
    end
    -- fallback: scan grid for a not revealed cell
    for i,v in ipairs(GRID.cells) do
        for j,cell in ipairs(v) do
            if not cell.revealed then return cell end
        end
    end
    return nil
end

-- pickRandomAdjacent should return a cell (no side-effects)
function ai:pickRandomAdjacent(cell)
    local unrevealed = {}
    local function checkSide(dx, dy)
        local nr = cell.r + dx
        local nc = cell.c + dy
        if GRID.cells[nr] and GRID.cells[nr][nc] then
            local c = GRID.cells[nr][nc]
            if not c.revealed then table.insert(unrevealed, c) end
        end
    end
    checkSide(-1,-1); checkSide(0,-1); checkSide(1,-1)
    checkSide(-1,0);                  checkSide(1,0)
    checkSide(-1,1);  checkSide(0,1); checkSide(1,1)
    if #unrevealed == 0 then return nil end
    return unrevealed[love.math.random(1,#unrevealed)]
end

-- call this to start the step-by-step AI
function ai:startScout()
    if not self.running then
        self:planScout()
        self.running = true
        self.timer = 0
    end
end

-- process the queue over time (call from love.update)
function ai:update(dt)
    if not self.running then return end
    self.timer = self.timer + dt
    if self.timer < self.delay then return end
    self.timer = self.timer - self.delay

    local action = dequeue(self.moveQueue)
    if not action then
        self.running = false
        return
    end

    if action.type == "reveal" then
        local cell = action.cell
        if not cell.revealed then
            cell.revealed = true
            print("[AI] reveal " .. cell.r .. " " .. cell.c)
            table.insert(self.moves, {cell.r, cell.c})
            -- run your existing reveal logic (flood reveal etc.)
            if not cell.mine then
                GEN:revealFlood(cell)
            else
                -- handle mine (game over)
                loadState(mineNum, gameSize)
            end
        end

    elseif action.type == "assignWeight" then
        print("[AI] assign weights")
        self:assignWeight()

    elseif action.type == "revealAdjIfFlagged" then
        print("[AI] reveal adjacent if flagged")
        self:revealAdjIfFlagged()

    elseif action.type == "flagUnrevealed" then
        print("[AI] flag unrevealed")
        self:flagUnrevealed()
    end
end

-- keep your helper functions but rename some uses to the new pick* APIs, for example:
function ai:assignWeight()
    for i, v in ipairs(GRID.cells) do
        for j, cell in ipairs(v) do
            cell.weight = cell.revealed and 0 or self:adjacentSum(cell)
        end
    end
end


function ai:chooseRandomAdjacent(cell)
    local unrevealedCells = {}
    local function checkSide(dx, dy)
        local nr = cell.r + dx
        local nc = cell.c + dy

        if GRID.cells[nr] and GRID.cells[nr][nc] then
            if not GRID.cells[nr][nc].revealed then
                table.insert(unrevealedCells, GRID.cells[nr][nc])
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
    if #unrevealedCells == 0 then
        return nil
    end
    local random = unrevealedCells[love.math.random(1, #unrevealedCells)]
    print("[RAND ADJ] MOVE ON:" .. cell.r .. " " .. cell.c)
    table.insert(self.moves, {cell.r, cell.c})

    return random
end

function ai:revealAdjIfFlagged()
    for i, v in ipairs(GRID.cells) do
        for j, cell in ipairs(v) do
            if cell.value == self:countAdjFlag(cell) then
                print("[FLAG-REV] MOVE ON:" .. cell.r .. " " .. cell.c)
                table.insert(self.moves, {cell.r, cell.c})

                GEN:revealNearby(cell)
            end
        end
    end
end

function ai:adjacentSum(cell)
    local sum = 0
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local nr = cell.r + dx
                local nc = cell.c + dy

                if GRID.cells[nr] and GRID.cells[nr][nc] then
                    local ncell = GRID.cells[nr][nc]
                    if ncell.revealed then
                        sum = sum + 1
                        sum = sum + self:checkSubFlagCount(ncell)
                    end

                end
            end
        end
    end
    return sum
end

function ai:checkSubFlagCount(cell)
    local val = cell.value
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local nr = cell.r + dx
                local nc = cell.c + dy

                if GRID.cells[nr] and GRID.cells[nr][nc] then
                    local ncell = GRID.cells[nr][nc]
                    if ncell.flagged then
                        val = val - 1
                    end
                end
            end
        end
    end

    return val
end
function ai:countAdjFlag(cell)
    local val = 0
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local nr = cell.r + dx
                local nc = cell.c + dy

                if GRID.cells[nr] and GRID.cells[nr][nc] then
                    local ncell = GRID.cells[nr][nc]
                    if ncell.flagged then
                        val = val + 1
                    end
                end
            end
        end
    end

    return val
end

function ai:flagUnrevealed()
    for i, v in ipairs(GRID.cells) do
        for j, cell in ipairs(v) do
            if not cell.revealed then
                -- assuming its a mine and flagging its
                cell.flagged = true
            end
        end
    end
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
