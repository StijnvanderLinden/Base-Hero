# Game Design Document (GDD)

## High Concept
This project is a 3D co-op action base-defense game about getting stronger in a simple hub, entering a dangerous gate arena, defending a central base under escalating pressure, earning progression, and wanting to try one more run.

The current project priority is a focused playable vertical slice:

**Main Hub -> Gate Run -> Survive -> Repeat**

Everything outside that loop is backlog until the core loop is proven fun.

---

## Core Player Fantasy
Players should feel:
- "I got stronger in the hub"
- "I can survive longer in the run"
- "I want to try again"

The game succeeds when the player wants one more run.

---

## Core Gameplay Loop
The vertical-slice loop is:

1. Start in the main hub
2. Unlock or choose simple turret upgrades
3. Enter a gate run
4. Defend the central base/core
5. Kill wave enemies for scrap
6. Spend scrap during the run on turret upgrades or limited extra turrets
7. Survive as long as possible while pressure escalates
8. Earn essence based on survival time and milestones
9. Return to the hub
10. Spend essence on new turret types, upgrade branches, base capacity, or a simple player weapon upgrade
11. Repeat

This loop is the project's design center until it is fun.

---

## Core Design Principle
Validate fun before adding complexity.

If the core loop is not fun:
- do not add new systems
- do not add broad content
- fix the base loop

The project should favor:
- playable over elegant
- clear over clever
- impactful upgrades over small stat tuning
- fast repetition over long setup

---

## Main Game Spaces

### Main Hub
The hub is the simple between-run progression space.

It may be a menu or a small playable area. It does not need NPCs, complex UI, deep research trees, or a large town simulation for the vertical slice.

Hub progression can unlock:
- turret types
- turret upgrade branches
- base capacity
- optional basic player weapon upgrades

The hub's job is to make the player feel stronger before the next run.

### Gate Run
The first gate run is a small arena, not an exploration map.

It contains:
- one central base/core
- a starter base layout
- level 1 turrets at run start
- fixed-strength walls
- enemy wave pressure
- scrap earned from enemy kills
- milestone-based escalation

The run's job is to test whether upgrades, pressure, and survival create the "one more run" feeling.

---

## Scrap
Scrap is the core in-run resource.

Rules:
- dropped only by wave enemies
- automatically collected on enemy kill
- spent during the run
- not stored between runs
- required to keep the base defense alive

Scrap can be spent on:
- upgrading existing turrets
- placing a limited number of extra turrets

There is no manual pickup for the vertical slice.

---

## Essence
Essence is the core between-run progression resource.

Rules:
- generated over time during a run
- scales with survival duration and milestone progress
- spent in the main hub
- retained at about 70% when the base is destroyed

Essence unlocks long-term options such as:
- turret types
- upgrade branches
- base capacity
- optional simple player weapon upgrades

Essence exists to create the feeling that each run makes the next run more promising.

---

## Base And Turrets
The first run uses a pre-configured starter base.

The starter base should:
- survive early waves
- create pressure quickly
- not play the game for the player
- be readable in 3D and co-op

Turrets:
- start at level 1 every run
- upgrade with scrap during the run
- should receive impactful upgrades rather than tiny percentage bumps

Good upgrade directions:
- faster fire rate
- longer range
- area attacks
- single-target burst
- transformation into an unlocked advanced type

Locked upgrade branches may be visible but unavailable with a lock or question mark.

Walls are fixed strength for the vertical slice and are not upgraded.

---

## Wave And Milestone Pressure
The gate run uses continuous enemy pressure that escalates over time.

Milestones divide run progression into five pressure bands:
- 1/5: early
- 2/5: mid
- 3/5: high pressure
- 4/5: extreme
- 5/5: endgame

Milestones should increase:
- enemy strength
- spawn rate
- pressure on the base
- essence gain

Early pressure must exist. The player should not be waiting around for the game to begin.

---

## Death And Failure
Player death:
- respawn after about 20 seconds at the base
- does not end the run by itself

Base destruction:
- ends the run immediately
- returns the player to the hub
- keeps about 70% of earned essence

Failure should sting, but still make the next run feel worth attempting.

---

## Multiplayer
The game is fundamentally co-op and host-authoritative.

Clients may request actions and show presentation.
The host/server decides enemy spawning, damage, death, rewards, base state, progression, and run outcomes.

The vertical slice should remain multiplayer-safe even while simple.

---

## Prototype Scope
The vertical slice should prove only:
- simple hub progression
- one small gate arena
- one central defendable base/core
- enemy waves with escalating pressure
- automatic scrap from wave enemy kills
- turret upgrades and limited extra turret placement using scrap
- essence earned from survival and milestones
- base destruction failure and player respawn
- repeatable hub-to-run loop

Everything else waits until this loop is fun.

---

## Explicit Backlog
Do not build these for the vertical slice:
- POIs
- caves
- deep map exploration
- roaming resource gathering
- gold
- complex material systems
- multiple worlds or eras
- material-specific research trees
- deep meta-progression
- complex enemy variants
- base building outside the preset layout

These are valid future ideas, but they must not compete with the first fun loop.

---

## Design Boundaries
The project should avoid:
- generic open-world survival drift
- passive or AFK tower defense
- grind loops
- idle waiting before pressure begins
- small unnoticeable upgrades
- unnecessary resource complexity
- systems that delay proving the core loop

The heart of the current game is:
- unlock options in the hub
- make survival decisions in the run
- earn enough progress to try again stronger
