-- systems/player.lua
local constants = require("constants")
local math_utils = require("util.math_utils")

local M = {}

--- Constructor for the player object.
-- @param group The display group to insert the player into.
-- @return The player object.
function M.new(group)
    local self = {}

    -- Initial state
    self.y = constants.SCREEN_H * 0.5
    self.vy = 0
    self.isHeld = false
    self.isDead = false

    -- Visuals
    self.view = display.newRect(group, constants.PLAYER_X, self.y, constants.AVATAR_W, constants.AVATAR_H)
    self.view:setFillColor(unpack(constants.AVATAR_COLOR))

    --- Updates the player kinematics.
    -- This uses a fixed timestep (FIXED_DT) for deterministic behavior.
    function self:update()
        if self.isDead then return end

        -- Acceleration based on input
        local acc = self.isHeld and constants.RISE_ACC or constants.FALL_ACC
        
        -- Update velocity
        self.vy = self.vy + acc
        
        -- Clamp velocity
        self.vy = math_utils.clamp(self.vy, constants.MAX_VY_UP, constants.MAX_VY_DOWN)
        
        -- Update position
        self.y = self.y + self.vy
        
        -- Keep within screen bounds (until cave collision is implemented)
        self.y = math_utils.clamp(self.y, 0, constants.SCREEN_H)

        -- Update display position
        self.view.y = self.y
    end

    --- Input handler for touch/mouse events.
    function self:handleInput(event)
        if self.isDead then return end
        
        if event.phase == "began" then
            self.isHeld = true
        elseif event.phase == "ended" or event.phase == "cancelled" then
            self.isHeld = false
        end
        return true
    end

    --- Clean up the player.
    function self:destroy()
        if self.view then
            display.remove(self.view)
            self.view = nil
        end
    end

    return self
end

return M
