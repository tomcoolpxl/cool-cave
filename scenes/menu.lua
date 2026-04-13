-- scenes/menu.lua
-- Phase 1 stub: displays a placeholder label only.
-- Full title screen (tap handler, best score, start prompt) is implemented in Phase 9.

local composer = require("composer")
local scene    = composer.newScene()

function scene:create(event)
    local group = self.view

    local label = display.newText({
        parent   = group,
        text     = "CoolCave",
        x        = display.contentCenterX,
        y        = display.contentCenterY,
        fontSize = 48,
    })
    label:setFillColor(1, 1, 1)
end

scene:addEventListener("create", scene)

return scene
