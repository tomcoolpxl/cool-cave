-- systems/score.lua
local M = {}

local getTimer = system and system.getTimer or os.clock -- Fallback for standalone tests

--- Constructor for the score system.
function M.new()
    local self = {}
    
    self.startTime = 0
    self.elapsedTime = 0
    self.isPaused = true

    --- Starts the timer.
    function self:start()
        self.startTime = getTimer()
        self.isPaused = false
    end

    --- Stops the timer and records elapsed time.
    function self:stop()
        if not self.isPaused then
            self.elapsedTime = getTimer() - self.startTime
            self.isPaused = true
        end
    end

    --- Gets current elapsed time in milliseconds.
    -- @return Elapsed time in ms.
    function self:getElapsed()
        if self.isPaused then
            return self.elapsedTime
        else
            return getTimer() - self.startTime
        end
    end

    --- Formats time for display (e.g. "12.3").
    -- @param ms Milliseconds to format.
    -- @return Formatted string.
    function self.format(ms)
        local seconds = ms / 1000
        return string.format("%.1f", seconds)
    end

    return self
end

return M
