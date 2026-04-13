local composer = require("composer")
local scene = composer.newScene()
local playerSystem = require("systems.player")
local constants = require("constants")

local player -- Declare the player instance

local function onFrame(event)
    -- Update the player each frame
    if player then
        player:update()
    end
end

local function onTouch(event)
    -- Pass touch events to the player system
    if player then
        return player:handleInput(event)
    end
    return false
end

-- Temporary function to simulate death for testing until Phase 6
local function onSimulateDeath(event)
    composer.gotoScene("scenes.gameover", { effect = "fade", time = 400 })
    return true
end

function scene:create(event)
    local group = self.view
    
    -- Background to capture touch events
    local bg = display.newRect(group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    bg:setFillColor(unpack(constants.BG_COLOR))
    bg.isHitTestable = true
    bg:addEventListener("touch", onTouch)
    
    -- Instructions for simulate death (Phase 2 legacy)
    local label = display.newText({
        parent = group,
        text = "Tap once to simulate death (Phase 2 stub)",
        x = display.contentCenterX,
        y = 30,
        font = native.systemFont,
        fontSize = 14
    })
    label:addEventListener("tap", onSimulateDeath)

    -- Initialize the player
    player = playerSystem.new(group)
end

function scene:show(event)
    if event.phase == "did" then
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
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene
