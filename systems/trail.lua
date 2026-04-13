-- systems/trail.lua
local constants = require("constants")

local M = {}

function M.new(group)
    local self = {}
    
    self.group = display.newGroup()
    group:insert(self.group)
    
    self.pool = {}
    self.active = {} -- List of {view, x, y}
    
    -- Pre-allocate blocks
    for i = 1, constants.TRAIL_LENGTH do
        local block = display.newRect(self.group, 0, 0, constants.TRAIL_BLOCK_SIZE, constants.TRAIL_BLOCK_SIZE)
        block:setFillColor(unpack(constants.TRAIL_COLOR))
        block.isVisible = false
        table.insert(self.pool, block)
    end

    local frameCount = 0

    --- Updates and scrolls the trail.
    -- @param playerY The current player Y position.
    function self:update(playerY)
        frameCount = frameCount + 1
        
        -- Scroll active blocks
        local scrollStep = constants.SCROLL_SPEED * constants.FIXED_DT
        for i = #self.active, 1, -1 do
            local item = self.active[i]
            item.x = item.x - scrollStep
            
            -- Recycle if off-screen
            if item.x + constants.TRAIL_BLOCK_SIZE < 0 then
                item.view.isVisible = false
                table.insert(self.pool, item.view)
                table.remove(self.active, i)
            end
        end
        
        -- Add new sample every few frames or every frame based on TRAIL_SPACING
        if frameCount % (constants.TRAIL_SPACING or 2) == 0 then
            if #self.pool > 0 then
                local view = table.remove(self.pool)
                view.isVisible = true
                table.insert(self.active, {
                    view = view,
                    x = constants.PLAYER_X,
                    y = playerY
                })
            else
                -- If pool is empty, recycle oldest active
                local item = table.remove(self.active, 1)
                item.x = constants.PLAYER_X
                item.y = playerY
                table.insert(self.active, item)
            end
        end
    end

    --- Renders/positions the active blocks.
    function self:render()
        for i = 1, #self.active do
            local item = self.active[i]
            item.view.x = item.x
            item.view.y = item.y
        end
    end

    --- Clean up the trail.
    function self:destroy()
        if self.group then
            display.remove(self.group)
            self.group = nil
        end
        self.active = {}
        self.pool = {}
    end

    return self
end

return M
