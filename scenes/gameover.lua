local composer = require("composer")
local scene = composer.newScene()

local function onRestartTap(event)
    composer.gotoScene("scenes.menu", { effect = "fade", time = 400 })
    return true
end

function scene:create(event)
    local group = self.view

    local label = display.newText({
        parent   = group,
        text     = "Game Over",
        x        = display.contentCenterX,
        y        = display.contentCenterY,
        fontSize = 48,
    })
    label:setFillColor(1, 0, 0)

    local bg = display.newRect(group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    bg.isVisible = false
    bg.isHitTestable = true
    bg:addEventListener("tap", onRestartTap)
end

scene:addEventListener("create", scene)

return scene
