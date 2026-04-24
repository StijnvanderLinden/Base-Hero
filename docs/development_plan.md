# Development Plan

## Purpose
This document defines the current roadmap for proving the focused vertical slice.

The roadmap should answer:
- what should be built next
- what should deliberately wait
- how to keep the project focused on fun before complexity

---

## Development Philosophy
Build the smallest repeatable loop that can become fun.

Always prefer:
- playable over elegant
- fast iteration over broad systems
- impactful choices over large feature lists
- one good run loop over many unfinished systems

If the loop is not fun, improve the loop before adding systems.

---

## Current Strategic Goal
The current goal is to prove:

**Main Hub -> Gate Run -> Survive -> Repeat**

That means proving:
- the player can start from the hub
- the player can enter one small gate arena
- a central base/core can be defended
- wave enemies create early and escalating pressure
- enemies drop scrap automatically on kill
- scrap upgrades turrets during the run
- essence is earned from survival and milestones
- essence is spent in the hub for meaningful unlocks
- each run makes the next run feel more promising

---

## Phase 1: Multiplayer Foundation
### Goal
Keep a working host/client foundation.

### Tasks
- host flow
- join flow
- peer connection
- player spawning
- player ownership
- basic synchronized movement

### Success Condition
Two players can connect and move in the same shared world.

---

## Phase 2: Defendable Base
### Goal
Create the central objective for the run.

### Tasks
- central base/core
- objective health
- objective damage
- objective destruction handling
- objective state synchronized and server-owned

### Success Condition
Players can protect a shared base/core that can be damaged and destroyed.

---

## Phase 3: Enemy Waves
### Goal
Create early pressure.

### Tasks
- server-spawned wave enemies
- movement toward the base/core
- enemy damage to the base/core
- basic escalation over time
- synchronized enemy state

### Success Condition
Players immediately understand that the base is under threat.

---

## Phase 4: Basic Combat
### Goal
Let players actively defend.

### Tasks
- one player weapon
- one primary attack
- enemy health
- server-authoritative damage
- enemy death

### Success Condition
Players can defeat enemies in multiplayer with correct authority handling.

---

## Phase 5: Scrap Loop
### Goal
Make enemy kills feed survival decisions.

### Tasks
- scrap awarded automatically on enemy death
- server-authoritative scrap totals
- scrap UI
- spend scrap during the run

### Success Condition
Killing enemies gives immediate resources that matter during the same run.

---

## Phase 6: Turret Upgrade Loop
### Goal
Make scrap spending feel impactful.

### Tasks
- level 1 starter turrets
- upgrade interaction
- faster fire rate upgrade
- range or burst upgrade
- limited additional turret placement
- locked branch display for hub-locked upgrades

### Success Condition
Spending scrap clearly improves survival in a way the player can feel.

---

## Phase 7: Milestone Pressure
### Goal
Make the run escalate.

### Tasks
- five milestone bands
- enemy strength increases
- spawn rate increases
- essence gain increases
- milestone UI feedback

### Success Condition
The player can feel the run moving from early pressure toward endgame pressure.

---

## Phase 8: Essence And Failure
### Goal
Create repeatable progression between runs.

### Tasks
- essence generated over time
- milestone-based essence scaling
- base destruction ends the run
- player keeps about 70% essence on failure
- return to hub after failure

### Success Condition
Even a failed run gives enough progress to make trying again feel worthwhile.

---

## Phase 9: Simple Hub Unlocks
### Goal
Let players get stronger between runs.

### Tasks
- hub unlock menu or small hub station
- spend essence
- unlock turret types
- unlock turret upgrade branches
- unlock base capacity
- optional basic player weapon upgrade

### Success Condition
The player can spend run rewards and feel stronger in the next gate run.

---

## Phase 10: Feel Iteration
### Goal
Make the core loop fun before adding scope.

### Tasks
- tune wave timing
- tune scrap income and upgrade costs
- tune essence income
- tune turret impact
- tune base durability
- improve combat feedback
- improve run restart speed

### Success Condition
The player wants one more run.

---

## Intentionally Delayed Work
Do not prioritize these until the loop is proven fun:
- POIs
- caves
- deep map exploration
- roaming resource gathering
- gold
- material-specific economies
- multiple worlds or eras
- deep research trees
- complex enemy variants
- freeform base building outside the preset layout
- Steam-specific implementation

---

## Roadmap Rules
When deciding what to work on next:
- do not add systems to compensate for an unfun loop
- do not add resources until scrap and essence feel good
- do not add exploration until the arena survival loop works
- do not add more eras until Stone Age is worth replaying
- keep multiplayer authority intact

---

## Current Priority
The current immediate priority is:

**Focused Vertical Slice: Hub Progression, Gate Arena, Scrap Upgrades, Essence Repeat Loop**
