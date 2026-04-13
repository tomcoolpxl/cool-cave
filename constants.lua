-- constants.lua
local M = {}

-- Screen reference
M.SCREEN_W = 960
M.SCREEN_H = 540

-- Player Kinematics
M.RISE_ACC = -0.8      -- Upward acceleration (negative Y)
M.FALL_ACC = 0.6       -- Downward acceleration (positive Y)
M.MAX_VY_UP = -12      -- Maximum upward velocity
M.MAX_VY_DOWN = 10     -- Maximum downward velocity
M.FIXED_DT = 1/60      -- Fixed timestep for physics

-- Player Visuals
M.AVATAR_W = 40
M.AVATAR_H = 20
M.PLAYER_X = 150       -- Fixed horizontal position of the player
M.AVATAR_COLOR = { 1, 1, 1 } -- White avatar

-- Cave Generation & Scrolling
M.DEFAULT_SEED = 20250101
M.SCROLL_SPEED = 200   -- Pixels per second
M.CHUNK_SIZE = 20      -- Number of slices per chunk
M.MIN_GAP = 180        -- Minimum vertical gap in the cave
M.MAX_STEP = 15        -- Maximum change in wall Y per slice
M.CENTER_DRIFT_MAX = 100 -- Max drift from center of screen
M.SLICE_WIDTH = 20     -- Width of each cave slice

-- Validation & Logic
M.VALIDATION_MARGIN = 20 -- Safety shrink for reachability simulation
M.MAX_GEN_RETRIES = 5    -- Max retries before fallback chunk
M.FALLBACK_GAP = 250     -- Gap for the fallback safe chunk

-- Trail Rendering
M.TRAIL_LENGTH = 50
M.TRAIL_BLOCK_SIZE = 8
M.TRAIL_COLOR = { 0.8, 0.8, 0.8, 0.5 } -- Semitransparent gray
M.TRAIL_SPACING = 5      -- Frames between trail samples (if not every frame)

-- Colors
M.WALL_COLOR = { 0.4, 0.4, 0.4 } -- Retro gray blocks
M.BG_COLOR = { 0.1, 0.1, 0.1 }   -- Dark background

-- Audio
M.AUDIO_ENABLED = true

return M
