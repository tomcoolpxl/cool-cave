-- systems/cave_generator.lua
local constants = require("constants")
local math_utils = require("util.math_utils")
local random = require("util.random")
local validator = require("systems.cave_validator")

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

    --- Generates a safe, straight-corridor fallback chunk.
    -- @param count The number of slices to generate.
    -- @return An array of slice records.
    function self:generateFallbackChunk(count)
        local slices = {}
        local centerY = constants.SCREEN_H * 0.5
        local gap = constants.FALLBACK_GAP
        
        for i = 1, count do
            local topY = centerY - gap * 0.5
            local bottomY = centerY + gap * 0.5
            table.insert(slices, { x = self.currentX, topY = topY, bottomY = bottomY })
            self.currentX = self.currentX + constants.SLICE_WIDTH
        end
        self.lastCenterY = centerY
        self.lastGap = gap
        return slices
    end

    --- Generates a chunk of slices, validated for feasibility.
    -- @param count The number of slices to generate.
    -- @return An array of slice records { x, topY, bottomY }.
    function self:generateChunk(count)
        local retries = 0
        local chunkSlices = {}
        
        while retries < constants.MAX_GEN_RETRIES do
            -- Save state in case we need to retry
            local savedRNGState = self.rng.state
            local savedX = self.currentX
            local savedCenterY = self.lastCenterY
            local savedGap = self.lastGap
            
            chunkSlices = {}
            for i = 1, count do
                local step = self.rng:nextInt(-constants.MAX_STEP, constants.MAX_STEP)
                local centerY = self.lastCenterY + step
                local minCenter = constants.SCREEN_H * 0.5 - constants.CENTER_DRIFT_MAX
                local maxCenter = constants.SCREEN_H * 0.5 + constants.CENTER_DRIFT_MAX
                centerY = math_utils.clamp(centerY, minCenter, maxCenter)
                
                local gap = constants.MIN_GAP
                local topY = centerY - gap * 0.5
                local bottomY = centerY + gap * 0.5
                
                table.insert(chunkSlices, { x = self.currentX, topY = topY, bottomY = bottomY })
                self.currentX = self.currentX + constants.SLICE_WIDTH
                self.lastCenterY = centerY
                self.lastGap = gap
            end
            
            -- Validate the chunk (using middle velocity of 0 as starting point)
            if validator.check(chunkSlices, savedCenterY, 0) then
                return chunkSlices
            else
                -- Restore state for retry
                retries = retries + 1
                self.rng.state = savedRNGState
                self.currentX = savedX
                self.lastCenterY = savedCenterY
                self.lastGap = savedGap
            end
        end
        
        -- Fallback if all retries fail
        return self:generateFallbackChunk(count)
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
