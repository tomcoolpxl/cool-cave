-- test/bit.lua
-- Pure Lua implementation of bitwise operations for testing in environments without bitop/LuaJIT
local M = {}

function M.tobit(x)
    x = x % 4294967296
    if x >= 2147483648 then x = x - 4294967296 end
    return x
end

function M.bxor(a, b)
    local res, c = 0, 1
    a, b = a % 4294967296, b % 4294967296
    while a > 0 or b > 0 do
        local ra, rb = a % 2, b % 2
        if ra ~= rb then res = res + c end
        a, b, c = math.floor(a / 2), math.floor(b / 2), c * 2
    end
    return M.tobit(res)
end

function M.lshift(a, disp)
    return M.tobit(a * (2 ^ disp))
end

function M.rshift(a, disp)
    a = a % 4294967296
    return math.floor(a / (2 ^ disp))
end

function M.band(a, b)
    local res, c = 0, 1
    a, b = a % 4294967296, b % 4294967296
    while a > 0 and b > 0 do
        local ra, rb = a % 2, b % 2
        if ra == 1 and rb == 1 then res = res + c end
        a, b, c = math.floor(a / 2), math.floor(b / 2), c * 2
    end
    return res
end

return M
