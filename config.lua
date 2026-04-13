-- config.lua
-- Defines the content coordinate space used by all rendering.
-- 960x540 landscape, letterBox scaling, 60 FPS.
--
-- All gameplay geometry (player position, cave gap, slice width) is
-- expressed in these content units. Do not change this after Phase 1
-- without updating every constant that depends on it.

application = {
    content = {
        width  = 960,
        height = 540,
        scale  = "letterBox",
        fps    = 60,
    },
}
