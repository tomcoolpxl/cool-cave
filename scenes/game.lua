local composer = require("composer")
local scene = composer.newScene()

local function onFrame(event)
    -- This represents the 60 FPS heart of the game.
    print("Game Loop Active: " .. event.frame)
end

local function onCollisionSim(event)
    composer.gotoScene("scenes.gameover", { effect = "fade", time = 400 })
    return true
end

function scene:create(event)
    local group = self.view
    
    -- Placeholder avatar
    local avatar = display.newRect(group, 100, display.contentCenterY, 40, 40)
    avatar:setFillColor(0, 1, 0)
    
    -- Background rect to capture taps and simulate "death/collision"
    local bg = display.newRect(group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    bg.isVisible = false
    bg.isHitTestable = true
    bg:addEventListener("tap", onCollisionSim)
end

function scene:show(event)
    if event.phase == "did" then
        Runtime:addEventListener("enterFrame", onFrame)
    end
end

function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("enterFrame", onFrame)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene
