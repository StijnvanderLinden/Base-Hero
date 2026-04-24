# Era 1: Stone Age Specification

## Purpose
Stone Age is the first playable vertical slice.

It exists to prove the smallest fun loop:

**Main Hub -> Gate Run -> Survive -> Repeat**

Stone Age should not prove multiple eras, deep exploration, material trees, or complex world progression. Those ideas are backlog until this loop is fun.

---

## Theme
Stone Age is primitive, readable, and low complexity.

Visual direction:
- wood
- stone
- rope
- bone
- broad combat space
- clear enemy silhouettes
- simple turret and wall shapes

The era should feel like a clean action-defense arena, not a survival sandbox.

---

## Vertical Slice Run Structure
The first Stone Age gate run is a small arena.

Rules:
- the player enters from the main hub
- the run starts quickly
- the central base/core is already present
- the starter base layout is pre-configured
- enemies spawn in escalating waves
- the player survives as long as possible
- the run ends when the base is destroyed or the player exits through the prototype flow

Procedural maps, caves, POIs, and roaming material gathering are not required for this slice.

---

## Main Hub Progression
Stone Age hub progression should be simple.

The hub may unlock:
- turret types
- turret upgrade branches
- base capacity
- optional basic player weapon upgrades

Hub progression spends essence earned from runs.

The hub should make the next run feel more promising without becoming a complex management layer.

---

## Starter Base
Stone Age starts with one preset base layout.

The starter base contains:
- one central core
- fixed-strength walls
- a few level 1 turret positions
- limited room for additional turrets
- readable enemy approach lanes

The base should be:
- strong enough to survive early waves
- weak enough that the player must actively fight
- readable in 3D and co-op

Walls are not upgraded in the vertical slice.

---

## Turrets
Turrets start at level 1 every run.

During a run, the player spends scrap to:
- upgrade existing turrets
- place a limited number of additional turrets

Upgrade examples:
- faster fire rate
- longer range
- area attack
- single-target burst
- transformation into an unlocked advanced type

Advanced transformations should only be available if unlocked in the hub.

Locked branches may be shown as locked or unknown so the player understands future progression.

---

## Scrap
Scrap is the Stone Age in-run resource.

Source:
- dropped only by wave enemies
- automatically collected on kill

Uses:
- turret upgrades
- limited extra turret placement

Rules:
- no manual pickup
- not stored between runs
- required for survival

Scrap should make moment-to-moment survival decisions feel urgent.

---

## Essence
Essence is the Stone Age between-run progression resource.

Source:
- generated over time during a run
- increased by milestone progress
- scales with survival duration

Uses:
- hub unlocks
- turret types
- upgrade branches
- base capacity
- optional weapon upgrades

Failure:
- if the base is destroyed, the player keeps about 70% of earned essence

Essence should make even failed runs feel like useful progress.

---

## Enemy Set
The vertical slice should start with a small enemy set.

### Caveman
- basic melee pressure unit
- low health
- medium movement speed
- attacks the base/core or nearby player

### Brute
- heavy melee pressure unit
- high health
- slow movement
- high structure pressure

Additional enemy variants such as beasts, mini-bosses, ranged units, or complex elites are backlog until the core loop is fun.

---

## Wave And Milestone Progression
Stone Age uses continuous wave pressure.

Milestones:
- 1/5: early
- 2/5: mid
- 3/5: high pressure
- 4/5: extreme
- 5/5: endgame

Each milestone should increase:
- spawn rate
- enemy strength
- pressure on the base
- essence gain

Early pressure should begin quickly. No long idle start.

---

## Player Combat
Stone Age uses one basic weapon profile for the vertical slice.

Current direction:
- one primary attack
- generous hit validation
- clear hit feedback
- readable crowd combat

Optional early upgrade:
- basic player weapon improvement from the hub

Combat should make players feel active and necessary beside the defenses.

---

## Success Criteria
Stone Age succeeds when the player wants one more run because:
- the hub unlock made them stronger
- the run became more intense over time
- scrap upgrades mattered during survival
- essence made failure tolerable
- the next run feels reachable and exciting

If this is not true, iterate on the Stone Age loop before adding more systems.

---

## Explicit Backlog For Stone Age
Do not build these into the vertical slice yet:
- POIs
- caves
- deep arena exploration
- roaming material gathering
- gold
- wood/stone/herb economy loops
- complex research trees
- multiple Stone Age maps
- freeform base construction
- large enemy roster
- advanced bosses
- material-specific turret trees
