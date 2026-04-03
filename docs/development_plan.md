# Development Plan

## Purpose
This document defines the project roadmap at a high level.

It should answer:
- what phase the project is in
- what should be built next
- what should deliberately wait
- how to avoid overbuilding too early

This is a practical roadmap, not a wish list.

---

## Development Philosophy
Build the game in small, testable, multiplayer-safe steps.

At every stage:
- the game should still run
- the game should still be testable
- the next step should be clear
- the current work should support the real game direction

Always prefer:
- a small working loop
over
- a large unfinished system

---

## Current Strategic Goal
The current strategic goal is to create a working multiplayer-safe prototype of the core game loop.

That means proving:
- players can connect
- players can share a world
- players can defend a meaningful objective
- players can fight enemies
- gate-style pressure and extraction can become fun
- base-defense gameplay can be built on a stable foundation

---

## Phase 1: Multiplayer Foundation
### Goal
Create a working host/client foundation.

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

## Phase 2: Basic Objective Defense
### Goal
Create the smallest defendable objective loop.

### Tasks
- defendable core/objective
- objective health
- objective damage
- objective destruction handling
- objective state synchronized and server-owned

### Success Condition
Players can protect a shared objective that can be damaged and destroyed.

---

## Phase 3: Enemy Prototype
### Goal
Introduce enemy pressure.

### Tasks
- server-spawned enemy
- movement toward objective
- enemy damage to objective
- synchronized enemy state

### Success Condition
Players see the same enemy pressure attacking the same objective.

---

## Phase 4: Basic Combat
### Goal
Let players fight back.

### Tasks
- one player weapon
- one attack type
- enemy health
- server-authoritative damage
- enemy death

### Success Condition
Players can defeat enemies in multiplayer with correct authority handling.

---

## Phase 5: First Gate Prototype
### Goal
Prove the gate loop at a small scale.

### Tasks
- gate scene or gate mode
- temporary objective
- enemy scaling over time
- one reward type
- extraction countdown
- gate success/failure resolution

### Success Condition
Players can enter a gate, defend under pressure, extract, and gain rewards.

---

## Phase 6: First Building Prototype
### Goal
Prove fortress-building interaction.

### Tasks
- place one wall
- place one turret
- server-authoritative placement validation
- enemies interact meaningfully with structures

### Success Condition
Players can shape a minimal defense space with structures that matter.

---

## Phase 7: Main Raid Prototype
### Goal
Connect preparation and payoff.

### Tasks
- basic raid flow
- wave progression
- larger attack
- raid success/failure
- simple boss or raid climax if useful

### Success Condition
Players can prepare and then face a larger meaningful assault.

---

## Phase 8: Progression Prototype
### Goal
Make gate rewards and raid preparation meaningfully connect.

### Tasks
- core resource loop
- at least one special material or component
- player upgrade path
- base upgrade path
- link rewards to new defensive or combat options

### Success Condition
The loop of gate → upgrade → survive next raid feels meaningful.

---

## Phase 9: Expansion and Variety
### Goal
Increase variety after the core loop is proven.

### Possible Tasks
- additional enemy roles
- additional structures
- more weapons
- more augments
- gate biome variation
- milestone reward system
- elites and bosses
- stronger co-op identity through differentiated roles

### Success Condition
The game becomes deeper without losing clarity or identity.

---

## Intentionally Delayed Work
Do not prioritize these early unless explicitly needed:

- deep crafting
- large inventory systems
- advanced procedural generation
- heavy persistence systems
- elaborate UI polish
- lots of content at once
- Steam integration specifics
- optimization before real bottlenecks are known

---

## Roadmap Rules
When deciding what to work on next:

- do not skip directly to late systems
- do not pile too many new systems into one phase
- keep multiplayer testable as often as possible
- confirm the fun of each layer before expanding the next layer
- preserve system clarity and documentation as the project evolves

---

## Current Priority
The current immediate priority is:
**Phase 7: Main Raid Prototype**

That means no major detours unless they directly stabilize the shared core-defense loop and its server-authoritative foundation.