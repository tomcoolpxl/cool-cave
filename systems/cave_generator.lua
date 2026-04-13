-- systems/cave_generator.lua
local constants = require("constants")
local math_utils = require("util.math_utils")
local random = require("util.random")

local M = {}

--- Constructor for the cave generator.
-- @param seed The seed for the RNG.
-- @return The generator instance.
function M.new(seed)
    local self = {}
    
    self.rng = random.new(seed or constants.DEFAULT_SEED)
    self.currentX = 0
    self.lastCenterY = constants.SCREEN_H * 0.5
    self.lastGap = constants.MIN_GAP

    --- Generates a chunk of slices.
    -- @param count The number of slices to generate.
    -- @return An array of slice records { x, topY, bottomY }.
    function self:generateChunk(count)
        local slices = {}
        
        for i = 1, count do
            -- Drift centerline
            local step = self.rng:nextInt(-constants.MAX_STEP, constants.MAX_STEP)
            local centerY = self.lastCenterY + step
            
            -- Clamp centerline drift
            local minCenter = constants.SCREEN_H * 0.5 - constants.CENTER_DRIFT_MAX
            local maxCenter = constants.SCREEN_H * 0.5 + constants.CENTER_DRIFT_MAX
            centerY = math_utils.clamp(centerY, minCenter, maxCenter)
            
            -- Keep gap at MIN_GAP for now, could be varied later
            local gap = constants.MIN_GAP
            
            local topY = centerY - gap * 0.5
            local bottomY = centerY + gap * 0.5
            
            -- Create slice record
            local slice = {
                x = self.currentX,
                topY = topY,
                bottomY = bottomY
            }
            
            table.insert(slices, slice)
            
            -- Update state for next slice
            self.currentX = self.currentX + constants.SLICE_WIDTH
            self.lastCenterY = centerY
            self.lastGap = gap
        end
        
        return slices
    end

    --- Resets the generator state.
    -- @param seed Optional new seed.
    function self:reset(seed)
        self.rng = random.new(seed or constants.DEFAULT_SEED)
        self.currentX = 0
        self.lastCenterY = constants.SCREEN_H * 0.5
        self.lastGap = constants.MIN_GAP
    end

    return self
end

return M
