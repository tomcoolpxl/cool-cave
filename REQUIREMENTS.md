Agreed. The trail is a core mechanic here, and the deterministic cave generation plus feasibility check should be explicit requirements, not an afterthought.

Below is a revised, implementation-oriented requirements document for **CoolCave**.

# CoolCave requirements

## Project summary

**CoolCave** is a simple one-input survival game built in **Solar2D** and exported for **HTML5** and **Android**.

The player controls a **small flat rectangle** that stays near the left side of the screen while the cave scrolls from right to left. Holding input makes the avatar rise. Releasing input makes it fall. The motion should feel **slightly floaty**, not instant or twitchy.

The visual style should be **modern blocky retro**:

* simple geometric shapes
* limited palette
* clean pixel-like silhouettes
* readable, high-contrast cave walls
* a visible trailing path behind the player

The player score is based on **survival time only**. There is one default game mode. No obstacles in MVP.

The cave must feel random, but it must also be:

* **deterministic**, so the same seed produces the same cave every time
* **validated before use**, so generated terrain is actually flyable

## Core gameplay requirements

### Player avatar

* The avatar shall initially be a **small flat horizontal rectangle**.
* The avatar shall remain at a mostly fixed horizontal screen position during gameplay.
* The avatar shall move vertically according to player input and gravity-like falling.
* The avatar shall not rotate in MVP.
* The avatar shall be clearly distinguishable from cave walls and trail.

### Player movement

* Input model shall be **press/hold to rise, release to fall**.
* Rising shall be produced by upward acceleration or thrust.
* Falling shall be produced by downward acceleration.
* Motion shall feel **slightly floaty**, meaning:

  * the avatar should not change velocity too abruptly
  * there should be a small sense of inertia
  * control should still remain responsive enough for precision play
* The movement model shall be deterministic under the same frame timing assumptions and seed.

### Trail

* The avatar shall leave behind a visible **trail** during gameplay.
* The trail is a required gameplay visual, not optional polish.
* The trail shall visually communicate the recent path of motion.
* The trail shall scroll with the world and gradually disappear as it exits the screen.
* For MVP, the trail may be rendered as:

  * a sequence of line segments, or
  * a sequence of small rectangular or square samples
* The trail shall be lightweight enough to avoid performance issues on Android and HTML5.
* The trail does not need collision in MVP.
* The trail should visually match the blocky retro art style.

## World and camera requirements

* The cave shall scroll continuously from right to left.
* The player shall appear stationary in x except for minor visual effects if later added.
* Gameplay shall be supported in **both portrait and landscape**.
* Layout and scaling must adapt so the same core gameplay works in both orientations.
* The game should define separate tunable values for portrait and landscape where needed, especially:

  * visible playfield width
  * visible playfield height
  * scroll speed
  * cave gap size
  * trail length on screen

## Game flow requirements

### Start flow

* The game shall open on a title screen.
* One tap or click shall start a new run.
* The first run and every restart must begin with the same default seed behavior unless changed by config.

### Gameplay loop

* The player survives by staying inside the cave.
* The cave scrolls endlessly.
* Score increases as elapsed survival time increases.
* Difficulty may increase over time, but MVP may begin with fixed difficulty until the base game is stable.

### Failure

* The run ends immediately if the avatar collides with:

  * the top cave wall
  * the bottom cave wall
* On failure:

  * movement stops
  * current score is shown
  * best score is shown
  * restart is available with one tap

## Scoring requirements

* Score shall be based on **time survived only**.
* Time shall be measured consistently and displayed in a simple readable form.
* Recommended display for MVP:

  * internal value in milliseconds or seconds with fractions
  * displayed as either whole seconds or one decimal place
* Best score shall persist locally on device.
* Best score must persist across app restarts.

## Cave generation requirements

This section is central.

### Design intent

The cave should feel random to the player, but it must be reproducible and fair.

### Deterministic generation

* Cave generation shall be **seeded**.
* The same seed and generation parameters must produce the same cave layout every time.
* The default game mode shall use a fixed seed for development and testing unless a runtime option changes it.
* The generation system shall support switching later to:

  * fixed seed runs
  * daily seed runs
  * random seed runs

### Cave representation

* The cave shall be defined by a **top wall** and a **bottom wall**.
* The cave geometry shall be generated as a sequence of vertical slices or segments.
* Each slice shall define at minimum:

  * x position
  * top boundary y
  * bottom boundary y
* Adjacent slices shall connect smoothly enough to avoid visually broken terrain.

### Visual style of cave

* Cave walls shall be rendered in a **blocky retro** style.
* Walls do not need to look organic.
* Jagged, stepped, tile-like, or chunked edges are acceptable and preferred over smooth curves.
* The cave should still read clearly as a continuous passage.

### Randomness constraints

* Cave wall changes shall appear random but remain within bounded limits.
* The generator shall not produce sudden wall movements larger than configured per-step limits.
* The cave gap shall never go below a configured minimum.
* The cave should contain variety in:

  * vertical drift
  * local narrowing and widening
  * ceiling/floor shape changes

## Feasibility and fairness requirements

This is the missing piece you called out, and it should be explicit.

### Pre-validation requirement

* The game shall **not draw or commit cave wall segments until they have passed a feasibility check**.
* Newly generated cave sections must be validated before being appended to the active playfield.

### Feasibility goal

The validation must ensure that a player using the defined movement model could, in principle, pass through the new cave section.

This is not just "gap is wide enough". It must account for movement limits.

### Minimum feasibility checks

At minimum, the system shall verify:

* the cave gap is above the hard minimum
* the vertical change in safe passage from one slice to the next is not beyond what the avatar can track
* the section is traversable under the current:

  * rise acceleration
  * fall acceleration
  * max vertical speed, if capped
  * horizontal scroll speed

### Recommended validation model

For MVP, use a **discrete reachability simulation** rather than a naive geometry rule.

Recommended method:

1. Represent the cave ahead as a sequence of slices.
2. For each slice, compute the set of avatar vertical states that can survive that slice.
3. Advance those states forward using the same movement equations as actual gameplay:

   * holding input
   * releasing input
4. Discard states that collide with cave walls.
5. If at least one valid state path survives through the candidate section, that section is feasible.
6. If no path survives, reject that candidate section and generate a replacement.

This gives a much more trustworthy guarantee than checking only gap width or slope.

### Validation window

* The generator shall validate a **forward chunk** of cave before accepting it.
* Recommended MVP chunk size:

  * enough for roughly 1 to 3 seconds of gameplay ahead
* Validation may happen per chunk rather than per single column if that is simpler.

### Safety margin

* Feasibility validation should include a small safety margin so the cave is not only mathematically possible but also reasonably playable.
* The safety margin may be applied by:

  * shrinking the usable gap during validation, or
  * slightly expanding the avatar hitbox during validation

### Fallback behavior

If a generated chunk fails validation:

* it shall be discarded
* a new candidate chunk shall be generated
* this shall repeat until a feasible chunk is found

The generator must avoid infinite loops. Therefore:

* there shall be a max retry count
* if retries exceed the limit, the generator shall fall back to a safer known-valid chunk pattern

## Difficulty requirements

For MVP:

* there shall be a **single difficulty mode**
* the game should aim for fair, readable, gradually demanding play

Recommended MVP approach:

* start with a fixed base difficulty
* optionally introduce only a mild ramp later after the base game is stable

Difficulty parameters shall be configurable:

* scroll speed
* rise acceleration
* fall acceleration
* max upward speed
* max downward speed
* minimum cave gap
* cave wall step limit
* validation safety margin
* visible look-ahead chunk size

## Input requirements

* The game shall support:

  * touch input on Android
  * mouse input for HTML5
* Any active press in the gameplay area shall count as "rise"
* No press shall count as "fall"
* Multi-touch gestures are not required
* Keyboard support in HTML5 is optional for debugging and may map:

  * space = rise
  * mouse button = rise

## Platform requirements

### Android

* Must run smoothly on typical Android devices supported by Solar2D.
* Touch input must feel responsive and stable.

### HTML5

* Must run in browser through Solar2D HTML5 export.
* Mouse press/release input must match touch behavior as closely as possible.
* The game should handle browser resize or fixed-canvas scaling predictably.

## Orientation requirements

You selected **both**, so this needs to be defined carefully.

* The game shall support both **portrait** and **landscape** layouts.
* The core mechanics shall remain identical in both.
* The implementation may use:

  * one adaptive scene layout, or
  * two tuned layout presets sharing the same gameplay code
* Portrait and landscape may use different tuned values for:

  * cave width in time-to-cross terms
  * trail length
  * HUD placement
  * cave chunk generation length
* The game should not distort shapes when switching orientation.
* The visible safe area must be respected.

## UI requirements

### Title screen

Must show:

* game title: **CoolCave**
* start prompt
* best survival time

Optional:

* orientation note if needed during development
* sound toggle
* debug seed display in dev builds

### HUD

Must show:

* current survival time

HUD must:

* stay readable
* avoid blocking the cave
* work in both portrait and landscape

### Game over screen

Must show:

* current time
* best time
* restart prompt

## Save data requirements

The game shall save locally:

* best survival time
* sound enabled/disabled setting
* optionally last used seed for debugging in development builds

## Art requirements

### Visual style

* The look shall be **modern blocky retro**
* Avoid detailed textures
* Use simple flat fills and clean edges
* Prefer a small controlled palette
* Maintain strong foreground/background contrast

### Avatar

* Flat rectangle for MVP
* Small and readable
* No animation required beyond movement and trail

### Trail

* Blocky, geometric, readable
* Should visually reinforce motion arc
* Should not become noisy or overly long

### Cave

* Blocky walls
* Clear passage boundaries
* Good readability at gameplay speed

## Audio requirements

MVP audio may include:

* start sound
* collision sound
* optional subtle loop or ambient tone

Audio is secondary to gameplay and may be deferred until controls and generation are stable.

## Technical architecture requirements for Solar2D

Since you have nothing yet, start clean and modular.

Recommended modules:

* `main.lua`
* `config.lua`
* `scenes/menu.lua`
* `scenes/game.lua`
* `systems/player.lua`
* `systems/trail.lua`
* `systems/cave_generator.lua`
* `systems/cave_validator.lua`
* `systems/collision.lua`
* `systems/score.lua`
* `systems/save.lua`
* `util/math_utils.lua`
* `util/random.lua`

### Architecture responsibilities

**player.lua**

* player state
* vertical physics
* input response
* rectangle rendering or render sync

**trail.lua**

* record recent player positions
* render trail efficiently
* remove off-screen samples

**cave_generator.lua**

* seeded generation
* chunk creation
* deterministic wall data

**cave_validator.lua**

* reachability / survivability checks
* candidate acceptance or rejection

**collision.lua**

* real-time collision checks against active cave slices

**save.lua**

* persistent local storage

## Performance requirements

* Target stable 60 FPS where feasible.
* Avoid excessive object creation every frame.
* Reuse display objects where possible.
* Avoid rebuilding full cave geometry unnecessarily.
* Trail rendering must be bounded and efficient.
* Cave slices that move off-screen shall be recycled or discarded cleanly.

## MVP scope

MVP includes:

* title screen
* game over screen
* touch and mouse hold/release controls
* flat rectangular avatar
* visible trail
* endless scrolling cave
* deterministic seeded cave generation
* cave feasibility validation before use
* collision detection
* time-based score
* persistent best score
* support for portrait and landscape
* export path for Android and HTML5

MVP excludes:

* obstacles
* multiple game modes
* random seed selection UI
* online leaderboard
* power-ups
* skins
* achievements

# Concrete implementation rules

These should guide the first version.

## Movement rules

Use a simple vertical kinematics model:

* position `y`
* velocity `vy`
* upward acceleration when held
* downward acceleration when released
* optional velocity clamps

This is better than directly setting position because:

* it gives the slightly floaty feel you asked for
* it is easy to simulate in the validator too

## Cave generation rules

Generate cave in chunks:

* each chunk contains a fixed number of vertical slices
* each slice advances left at scroll speed
* each slice stores top and bottom bounds

Generation should use:

* a seeded RNG
* bounded step changes
* controlled gap values
* optionally a drifting centerline and independent local perturbations

## Validation rules

Before adding a chunk:

* generate candidate chunk from RNG
* run feasibility simulation on that candidate
* accept only if survivable
* otherwise regenerate

The validator must use the same:

* timestep assumptions
* movement model
* avatar size / effective hitbox
* scroll speed

as gameplay, otherwise the guarantee is meaningless.

# Things that still need decisions

There are only a few decisions left before this can become a full build plan with parameter defaults:

* Do you want the **same fixed seed forever** yes
* Do you want **portrait and landscape available simultaneously**, start with landscape only for mvp
* the shouyld trail be: a chain of small blocks
