local composer = require("composer")
local scene = composer.newScene()
local scoreSystem = require("systems.score")
local constants = require("constants")

local scoreLabel
local bestLabel

local function onRestartTap(event)
    composer.gotoScene("scenes.menu", { effect = "fade", time = 400 })
    return true
end

function scene:create(event)
    local group = self.view

    -- Background for tapping
    local bg = display.newRect(group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    bg:setFillColor(unpack(constants.BG_COLOR))
    bg.isHitTestable = true
    bg:addEventListener("tap", onRestartTap)

    local title = display.newText({
        parent = group,
        text = "Game Over",
        x = display.contentCenterX,
        y = display.contentCenterY - 80,
        fontSize = 64,
        font = native.systemFontBold
    })
    title:setFillColor(1, 0, 0)

    scoreLabel = display.newText({
        parent = group,
        text = "Score: 0.0s",
        x = display.contentCenterX,
        y = display.contentCenterY + 20,
        fontSize = 32
    })
    scoreLabel:setFillColor(1, 1, 1)

    bestLabel = display.newText({
        parent = group,
        text = "Best: 0.0s",
        x = display.contentCenterX,
        y = display.contentCenterY + 80,
        fontSize = 24
    })
    bestLabel:setFillColor(1, 0.8, 0)

    local prompt = display.newText({
        parent = group,
        text = "Tap to Restart",
        x = display.contentCenterX,
        y = display.contentCenterY + 160,
        fontSize = 24
    })
    prompt:setFillColor(0.8, 0.8, 0.8)
end

function scene:show(event)
    if event.phase == "will" then
        local params = event.params or {}
        local finalScore = params.score or 0
        local bestScore = params.bestScore or 0

        scoreLabel.text = "Score: " .. scoreSystem.format(finalScore) .. "s"
        bestLabel.text = "Best: " .. scoreSystem.format(bestScore) .. "s"
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene
