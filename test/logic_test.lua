-- test/logic_test.lua
local constants = require("constants")
local random = require("util.random")
local caveGenerator = require("systems.cave_generator")
local validator = require("systems.cave_validator")
local collision = require("systems.collision")

local M = {}

local function assert(condition, message)
    if not condition then
        print("[FAIL] " .. (message or "Assertion failed"))
        return false
    end
    return true
end

function M.run()
    print("--- STARTING LOGIC TESTS ---")
    local allPassed = true

    -- 1. RNG Determinism Test
    print("Test 1: RNG Determinism")
    local rng1 = random.new(12345)
    local val1a = rng1:next()
    local val1b = rng1:next()
    
    local rng2 = random.new(12345)
    local val2a = rng2:next()
    local val2b = rng2:next()
    
    allPassed = allPassed and assert(val1a == val2a, "RNG first value mismatch")
    allPassed = allPassed and assert(val1b == val2b, "RNG second value mismatch")
    
    local rng3 = random.new(99999)
    local val3a = rng3:next()
    allPassed = allPassed and assert(val1a ~= val3a, "RNG different seeds produced same value")

    -- 2. Cave Generator Bounds Test
    print("Test 2: Generator Bounds")
    local gen = caveGenerator.new(12345)
    local chunk = gen:generateChunk(100)
    for i = 1, #chunk do
        local slice = chunk[i]
        allPassed = allPassed and assert(slice.bottomY - slice.topY >= constants.MIN_GAP, "Slice gap < MIN_GAP at " .. i)
        if i > 1 then
            local prev = chunk[i-1]
            local topStep = math.abs(slice.topY - prev.topY)
            local botStep = math.abs(slice.bottomY - prev.bottomY)
            allPassed = allPassed and assert(topStep <= constants.MAX_STEP + 0.1, "Top wall step > MAX_STEP at " .. i)
            allPassed = allPassed and assert(botStep <= constants.MAX_STEP + 0.1, "Bottom wall step > MAX_STEP at " .. i)
        end
    end

    -- 3. Validator Logic Test
    print("Test 3: Validator Reachability")
    -- Trivially feasible straight chunk
    local straightChunk = {}
    for i = 1, 20 do
        table.insert(straightChunk, { topY = 100, bottomY = 400 })
    end
    allPassed = allPassed and assert(validator.check(straightChunk, 250, 0) == true, "Straight chunk marked infeasible")
    
    -- Trivially infeasible chunk (gap smaller than avatar)
    local tightChunk = {}
    for i = 1, 20 do
        table.insert(tightChunk, { topY = 200, bottomY = 210 }) -- Only 10px gap, avatar is 20px
    end
    allPassed = allPassed and assert(validator.check(tightChunk, 205, 0) == false, "Impossible tight chunk marked feasible")

    -- 4. Collision Logic Test
    print("Test 4: Collision Detection")
    local testSlices = {
        { x = constants.PLAYER_X - 10, topY = 100, bottomY = 400 }
    }
    -- Center: safe
    allPassed = allPassed and assert(collision.check(250, testSlices) == false, "False positive collision at center")
    -- Top hit
    allPassed = allPassed and assert(collision.check(100, testSlices) == true, "Failed to detect top wall hit")
    -- Bottom hit
    allPassed = allPassed and assert(collision.check(400, testSlices) == true, "Failed to detect bottom wall hit")

    if allPassed then
        print("--- ALL LOGIC TESTS PASSED ---")
    else
        print("--- LOGIC TESTS FAILED ---")
    end
end

return M
