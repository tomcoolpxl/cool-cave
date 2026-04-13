-- systems/collision.lua
local constants = require("constants")

local M = {}

--- Checks for collision between player and active cave slices.
-- @param playerY The current Y position of the player.
-- @param activeSlices The list of currently visible cave slices.
-- @return true if collision detected, false otherwise.
function M.check(playerY, activeSlices)
    local playerTop = playerY - constants.AVATAR_H * 0.5
    local playerBottom = playerY + constants.AVATAR_H * 0.5
    local playerLeft = constants.PLAYER_X - constants.AVATAR_W * 0.5
    local playerRight = constants.PLAYER_X + constants.AVATAR_W * 0.5

    for i = 1, #activeSlices do
        local slice = activeSlices[i]
        
        -- Check if slice horizontally overlaps player
        local sliceLeft = slice.x
        local sliceRight = slice.x + constants.SLICE_WIDTH
        
        if sliceRight > playerLeft and sliceLeft < playerRight then
            -- Check vertical collision with walls
            if playerTop < slice.topY or playerBottom > slice.bottomY then
                return true
            end
        end
    end

    return false
end

return M
