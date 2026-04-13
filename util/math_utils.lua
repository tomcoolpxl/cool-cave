-- util/math_utils.lua
local M = {}

--- Clamps a value between a minimum and maximum range.
-- @param val The value to clamp.
-- @param min The minimum allowed value.
-- @param max The maximum allowed value.
-- @return The clamped value.
function M.clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

--- Linearly interpolates between two values.
-- @param a The start value.
-- @param b The end value.
-- @param t The interpolation factor (0 to 1).
-- @return The interpolated value.
function M.lerp(a, b, t)
    return a + (b - a) * t
end

return M
