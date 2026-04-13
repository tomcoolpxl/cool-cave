-- systems/cave_validator.lua
local constants = require("constants")
local math_utils = require("util.math_utils")

local M = {}

--- Checks if a chunk of slices is traversable.
-- This uses a discrete reachability simulation.
-- @param slices The array of slices to check.
-- @param startY The initial Y position.
-- @param startVY The initial vertical velocity.
-- @return true if feasible, false otherwise.
function M.check(slices, startY, startVY)
    -- Initial state set: array of {y, vy}
    -- We discretize the state to keep the set small: round Y to 1px, VY to 0.1px/frame
    local function serialize(y, vy)
        return math.floor(y + 0.5) .. ":" .. math.floor(vy * 10 + 0.5)
    end

    local states = {}
    local startState = { y = startY, vy = startVY }
    states[serialize(startY, startVY)] = startState

    for i = 1, #slices do
        local nextStates = {}
        local nextStatesCount = 0
        local slice = slices[i]
        
        -- Usable gap with safety margin
        local minSafeY = slice.topY + constants.VALIDATION_MARGIN
        local maxSafeY = slice.bottomY - constants.VALIDATION_MARGIN

        for _, state in pairs(states) do
            -- Case 1: Input held (rise)
            local vyH = math_utils.clamp(state.vy + constants.RISE_ACC, constants.MAX_VY_UP, constants.MAX_VY_DOWN)
            local yH = state.y + vyH
            
            if yH >= minSafeY and yH <= maxSafeY then
                local s = serialize(yH, vyH)
                if not nextStates[s] then
                    nextStates[s] = { y = yH, vy = vyH }
                    nextStatesCount = nextStatesCount + 1
                end
            end

            -- Case 2: Input released (fall)
            local vyR = math_utils.clamp(state.vy + constants.FALL_ACC, constants.MAX_VY_UP, constants.MAX_VY_DOWN)
            local yR = state.y + vyR
            
            if yR >= minSafeY and yR <= maxSafeY then
                local s = serialize(yR, vyR)
                if not nextStates[s] then
                    nextStates[s] = { y = yR, vy = vyR }
                    nextStatesCount = nextStatesCount + 1
                end
            end
            
            -- Optional: cap state count to prevent performance issues
            if nextStatesCount > 1000 then break end
        end

        states = nextStates
        
        -- If no states survived, the chunk is infeasible
        if nextStatesCount == 0 then
            return false
        end
    end

    return true
end

return M
