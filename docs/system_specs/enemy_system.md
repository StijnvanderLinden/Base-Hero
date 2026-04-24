# Enemy System Specification

## Purpose
The Enemy System creates pressure during the vertical-slice gate run.

Enemies should make the player defend the base actively, earn scrap through combat, and feel milestone escalation over time.

---

## MVP Enemy Goals
- Spawn from waves
- Threaten the central base/core
- Be readable in 3D
- Die from server-authoritative player and turret damage
- Award scrap automatically on death
- Scale with milestone pressure

---

## First Enemy Set

### Basic Melee Enemy
- low health
- medium speed
- attacks base/core or nearby player
- teaches the core loop

### Heavy Melee Enemy
- higher health
- slower speed
- higher structure pressure
- appears after early pressure is established

Additional enemy families are backlog.

---

## Milestone Scaling
Milestones should adjust:
- spawn rate
- enemy health or damage
- enemy mix
- pressure on the base

Scaling should be visible and readable.

---

## Authority Rule
The server handles:
- spawning
- target selection
- movement validity
- damage
- death
- scrap awards

---

## Deferred
Do not build complex enemy variants, biome enemy families, raid-only enemies, flying units, ranged squads, elite systems, or bosses until the core loop is fun.
