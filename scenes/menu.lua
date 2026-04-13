-- scenes/menu.lua
-- Phase 1 stub: displays a placeholder label only.
-- Full title screen (tap handler, best score, start prompt) is implemented in Phase 9.

local composer = require("composer")
local scene = composer.newScene()
local saveSystem = require("systems.save")
local scoreSystem = require("systems.score")
local constants = require("constants")

local bestScoreLabel

local function onStartTap(event)
    composer.gotoScene("scenes.game", { effect = "crossFade", time = 400 })
    return true
end

function scene:create(event)
    local group = self.view

    -- Background for tapping
    local bg = display.newRect(group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    bg:setFillColor(unpack(constants.BG_COLOR))
    bg.isHitTestable = true 
    bg:addEventListener("tap", onStartTap)

    local title = display.newText({
        parent = group,
        text = "CoolCave",
        x = display.contentCenterX,
        y = display.contentCenterY - 60,
        fontSize = 64,
        font = native.systemFontBold
    })
    title:setFillColor(1, 1, 1)

    local prompt = display.newText({
        parent = group,
        text = "Tap to Start",
        x = display.contentCenterX,
        y = display.contentCenterY + 40,
        fontSize = 32
    })
    prompt:setFillColor(0.8, 0.8, 0.8)

    bestScoreLabel = display.newText({
        parent = group,
        text = "Best Time: 0.0s",
        x = display.contentCenterX,
        y = display.contentCenterY + 120,
        fontSize = 24
    })
    bestScoreLabel:setFillColor(1, 0.8, 0)
end

function scene:show(event)
    if event.phase == "will" then
        local bestTime = saveSystem.loadBestTime()
        bestScoreLabel.text = "Best Time: " .. scoreSystem.format(bestTime) .. "s"
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene
