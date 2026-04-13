-- main.lua
-- CoolCave entry point.
-- Initialises Composer and navigates to the title scene.

local composer = require("composer")

-- Run logic tests on startup (can be disabled for production)
local logicTest = require("test.logic_test")
logicTest.run()

composer.gotoScene("scenes.menu")
