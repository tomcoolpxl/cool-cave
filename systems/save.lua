-- systems/save.lua
local json = require("json")
local M = {}

local filename = "saveData.json"
local filePath = system.pathForFile(filename, system.DocumentsDirectory)

--- Loads the save data from the disk.
-- @return The loaded table or an empty table if the file doesn't exist.
local function loadData()
    local file = io.open(filePath, "r")
    if not file then
        return {}
    end

    local contents = file:read("*a")
    io.close(file)

    local data = json.decode(contents)
    return data or {}
end

--- Saves the data table to the disk.
-- @param data The table to save.
local function saveData(data)
    local file = io.open(filePath, "w")
    if not file then
        print("Error: Could not open file for writing: " .. filePath)
        return
    end

    local contents = json.encode(data)
    file:write(contents)
    io.close(file)
end

--- Loads the best survival time.
-- @return Best time in milliseconds.
function M.loadBestTime()
    local data = loadData()
    return data.bestTime or 0
end

--- Saves the best survival time if it's better than the current one.
-- @param newTime The survival time in milliseconds.
-- @return true if a new best was saved, false otherwise.
function M.saveBestTime(newTime)
    local currentBest = M.loadBestTime()
    if newTime > currentBest then
        local data = loadData()
        data.bestTime = newTime
        saveData(data)
        return true
    end
    return false
end

return M
