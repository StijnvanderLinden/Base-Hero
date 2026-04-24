# Building System Specification

## Purpose
The Building System supports active base defense during the vertical slice.

For the MVP, building is not a broad construction sandbox. It is a small set of turret decisions made under pressure.

---

## Design Goals
- Make the base matter
- Make players fight alongside defenses
- Keep defense decisions readable
- Make scrap spending feel impactful
- Preserve server authority
- Avoid setup friction before the run becomes fun

---

## Starter Base
Each run starts with a pre-configured starter base.

The starter base contains:
- one central base/core
- fixed-strength walls
- level 1 turrets
- limited capacity for extra turrets
- clear enemy approach lanes

The base should survive early pressure but should not be able to survive without active player help.

---

## Walls
Walls are fixed strength for the vertical slice.

Purpose:
- delay enemies
- shape readable lanes
- protect the core briefly

Rules:
- no wall upgrades in the MVP
- no wall progression in the MVP

---

## Turrets
Turrets are the primary structure focus.

Rules:
- start at level 1 every run
- upgrade using scrap during the run
- can have locked advanced branches based on hub unlocks
- should support player combat rather than replace it

Good upgrade directions:
- faster fire rate
- longer range
- area attack
- single-target burst
- transformation into a hub-unlocked advanced type

Upgrades should be felt immediately.

---

## Limited Extra Turrets
Players may place a limited number of additional turrets during a run if the MVP needs more tactical decision-making.

Rules:
- paid with scrap
- capacity-limited
- server-authoritative placement validation
- no broad freeform base construction

---

## Authority Rule
Clients may preview and request placement or upgrades.

The server decides:
- whether placement is valid
- whether the player/team can pay the cost
- whether an upgrade is unlocked
- where final structures are spawned
- final turret behavior and damage

---

## Co-op Considerations
Open questions:
- should scrap be shared by the whole team?
- can any player spend team scrap?
- should turret upgrade choices require confirmation later?

For the MVP, use the simplest co-op-friendly rule that keeps the run moving.

---

## Scope Boundaries
Do build now:
- preset base
- fixed walls
- level 1 turrets
- scrap-paid turret upgrades
- limited extra turret placement if needed

Do not build yet:
- freeform base building outside the preset layout
- wall upgrades
- deep trap catalog
- power-grid simulation
- structure dependency chains
- complex component sockets
- large building UI
