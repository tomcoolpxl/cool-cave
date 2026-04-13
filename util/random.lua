-- util/random.lua
local bit = require("bit")

local M = {}

--- Constructor for a new RNG instance.
-- @param seed The seed for the RNG.
-- @return The RNG instance.
function M.new(seed)
    local self = {}
    
    -- Ensure seed is not zero and is a 32-bit integer
    self.state = bit.tobit(seed == 0 and 20250101 or seed)

    --- Generates the next 32-bit random integer.
    -- @return A 32-bit integer.
    function self:nextInt32()
        local x = self.state
        x = bit.bxor(x, bit.lshift(x, 13))
        x = bit.bxor(x, bit.rshift(x, 17))
        x = bit.bxor(x, bit.lshift(x, 5))
        self.state = x
        return x
    end

    --- Generates a random float in [0, 1).
    -- @return A float between 0 (inclusive) and 1 (exclusive).
    function self:next()
        -- Convert to positive float by adding 2^31 if negative, then dividing by 2^32
        -- Or more simply, use bit.tohex and tonumber if bitop is tricky with unsigned
        -- But LuaJIT bit op returns signed.
        -- We can use a mask to get positive values.
        local x = self:nextInt32()
        -- Normalize to [0, 1)
        -- Using 0x7FFFFFFF to get positive, then divide by 0x80000000
        local pos = bit.band(x, 0x7FFFFFFF)
        return pos / 2147483648
    end

    --- Generates a random integer in [min, max].
    -- @param min The minimum value.
    -- @param max The maximum value.
    -- @return An integer between min and max inclusive.
    function self:nextInt(min, max)
        local range = max - min + 1
        return min + math.floor(self:next() * range)
    end

    return self
end

return M
