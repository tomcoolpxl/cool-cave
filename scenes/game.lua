local composer = require("composer")
local scene = composer.newScene()
local playerSystem = require("systems.player")
local caveGenerator = require("systems.cave_generator")
local collisionSystem = require("systems.collision")
local trailSystem = require("systems.trail")
local scoreSystem = require("systems.score")
local saveSystem = require("systems.save")
local constants = require("constants")

local player
local generator
local trail
local score
local scoreLabel
local activeSlices = {}
local slicePool = {} -- Pool of {topView, bottomView}
local caveGroup
local trailGroup
local uiGroup

local function getFromPool()
    if #slicePool > 0 then
        return table.remove(slicePool)
    else
        local topView = display.newRect(caveGroup, 0, 0, constants.SLICE_WIDTH, 0)
        local bottomView = display.newRect(caveGroup, 0, 0, constants.SLICE_WIDTH, 0)
        topView:setFillColor(unpack(constants.WALL_COLOR))
        bottomView:setFillColor(unpack(constants.WALL_COLOR))
        topView.anchorY = 1 -- Bottom edge at topY
        bottomView.anchorY = 0 -- Top edge at bottomY
        return { top = topView, bottom = bottomView }
    end
end

local function returnToPool(views)
    views.top.isVisible = false
    views.bottom.isVisible = false
    table.insert(slicePool, views)
end

local function updateSliceViews()
    for i = 1, #activeSlices do
        local slice = activeSlices[i]
        local views = slice.views
        views.top.x = slice.x + constants.SLICE_WIDTH * 0.5
        views.top.y = slice.topY
        views.top.height = slice.topY
        views.top.isVisible = true

        views.bottom.x = slice.x + constants.SLICE_WIDTH * 0.5
        views.bottom.y = slice.bottomY
        views.bottom.height = constants.SCREEN_H - slice.bottomY
        views.bottom.isVisible = true
    end
end

local function onFrame(event)
    if player and not player.isDead then
        player:update()
        
        -- Update trail
        if trail then
            trail:update(player.y)
            trail:render()
        end

        -- Update score label
        if score and scoreLabel then
            scoreLabel.text = "Score: " .. scoreSystem.format(score:getElapsed())
        end

        -- Scroll slices
        local scrollStep = constants.SCROLL_SPEED * constants.FIXED_DT
        for i = #activeSlices, 1, -1 do
            local slice = activeSlices[i]
            slice.x = slice.x - scrollStep
            
            -- Remove off-screen slices
            if slice.x + constants.SLICE_WIDTH < 0 then
                returnToPool(slice.views)
                table.remove(activeSlices, i)
            end
        end

        -- Add new slices if needed
        local lastX = #activeSlices > 0 and activeSlices[#activeSlices].x or 0
        if lastX < constants.SCREEN_W + constants.SLICE_WIDTH then
            local chunk = generator:generateChunk(constants.CHUNK_SIZE)
            for _, slice in ipairs(chunk) do
                -- Adjust new slice X based on current scrolling
                slice.x = lastX + constants.SLICE_WIDTH
                lastX = slice.x
                slice.views = getFromPool()
                table.insert(activeSlices, slice)
            end
        end

        updateSliceViews()

        -- Collision detection
        if collisionSystem.check(player.y, activeSlices) then
            player.isDead = true
            if score then
                score:stop()
                local finalScore = score:getElapsed()
                saveSystem.saveBestTime(finalScore)
                local bestTime = saveSystem.loadBestTime()
                composer.gotoScene("scenes.gameover", { 
                    effect = "fade", 
                    time = 400,
                    params = { score = finalScore, bestScore = bestTime }
                })
            else
                composer.gotoScene("scenes.gameover", { effect = "fade", time = 400 })
            end
        end
    end
end

local function onTouch(event)
    if player then
        return player:handleInput(event)
    end
    return false
end

function scene:create(event)
    local group = self.view
    
    -- Background
    local bg = display.newRect(group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    bg:setFillColor(unpack(constants.BG_COLOR))
    bg.isHitTestable = true
    bg:addEventListener("touch", onTouch)

    -- Cave rendering group
    caveGroup = display.newGroup()
    group:insert(caveGroup)
    
    -- Trail rendering group
    trailGroup = display.newGroup()
    group:insert(trailGroup)

    -- UI group
    uiGroup = display.newGroup()
    group:insert(uiGroup)

    -- Score label
    scoreLabel = display.newText({
        parent = uiGroup,
        text = "Score: 0.0",
        x = 20,
        y = 20,
        font = native.systemFontBold,
        fontSize = 24
    })
    scoreLabel.anchorX = 0
    scoreLabel:setFillColor(1, 1, 1)

    -- Initialize generator
    generator = caveGenerator.new(constants.DEFAULT_SEED)

    -- Initialize the player
    player = playerSystem.new(group)
    
    -- Initialize trail
    trail = trailSystem.new(trailGroup)

    -- Initialize score
    score = scoreSystem.new()
end

function scene:show(event)
    if event.phase == "did" then
        -- Reset generator with the fixed seed for every new run
        generator = caveGenerator.new(constants.DEFAULT_SEED)
        
        -- Clear existing slices
        for _, slice in ipairs(activeSlices) do
            returnToPool(slice.views)
        end
        activeSlices = {}

        -- Generate initial cave to fill screen
        local initialChunk = generator:generateChunk(math.ceil(constants.SCREEN_W / constants.SLICE_WIDTH) + 2)
        for _, slice in ipairs(initialChunk) do
            slice.views = getFromPool()
            table.insert(activeSlices, slice)
        end
        updateSliceViews()
        
        -- Start score
        if score then
            score:start()
        end

        Runtime:addEventListener("enterFrame", onFrame)
    end
end

function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("enterFrame", onFrame)
        if player then
            player:destroy()
            player = nil
        end
        if trail then
            trail:destroy()
            trail = nil
        end
        -- Clear cave slices
        for _, slice in ipairs(activeSlices) do
            returnToPool(slice.views)
        end
        activeSlices = {}
    end
end

function scene:destroy(event)
    -- Clean up pool
    for _, views in ipairs(slicePool) do
        display.remove(views.top)
        display.remove(views.bottom)
    end
    slicePool = {}
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
