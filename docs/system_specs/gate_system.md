# Gate System Specification

## Purpose
The Gate System provides the repeatable action run for the vertical slice.

Current gate identity:
- small arena
- central base/core
- continuous enemy waves
- escalating pressure
- scrap-driven in-run turret decisions
- essence rewards for hub progression

Persistent exploration gates, pylons, caves, POIs, and deep biome progression are backlog until the first arena loop is fun.

---

## Design Goals
- Start pressure quickly
- Keep the base readable and important
- Make players fight alongside defenses
- Make enemy kills feed survival through scrap
- Make longer survival feed progression through essence
- Support co-op with server-authoritative state
- Keep the run fast enough to repeat

---

## Core Fantasy
Players enter a dangerous gate arena, defend a central base, kill enemies for scrap, upgrade turrets under pressure, survive longer than last time, and return to the hub with essence.

The emotional loop is:
- start run
- pressure begins
- kill enemies
- spend scrap
- survive a little longer
- earn essence
- unlock something
- try again

---

## Core Loop
1. Enter the gate run from the hub
2. Spawn near the preset base/core
3. Waves begin quickly
4. Enemies attack the base and pressure players
5. Killed wave enemies award scrap automatically
6. Players spend scrap on turret upgrades or limited extra turrets
7. Milestones increase pressure and essence gain
8. Player death causes a delayed respawn at the base
9. Base destruction ends the run
10. Earned essence returns to the hub progression flow

---

## Gate Arena Structure
The first gate run is one small arena.

It contains:
- one central base/core
- fixed-strength walls
- starting level 1 turrets
- limited extra turret positions or placement capacity
- clear enemy approach lanes
- enough movement room for player combat

The arena should not require exploration before the action starts.

---

## Waves
Enemy waves are continuous or near-continuous.

Rules:
- enemies are spawned by the server/host
- enemies target the base/core or relevant defenses/players
- pressure starts early
- difficulty increases over time

The first implementation can use a small enemy set.

---

## Milestones
Run progression is split into five pressure bands:
- 1/5: early
- 2/5: mid
- 3/5: high pressure
- 4/5: extreme
- 5/5: endgame

Milestones increase:
- enemy strength
- spawn rate
- pressure on the base
- essence gain

Milestones should be readable to players.

---

## Scrap Rewards
Scrap is awarded automatically when wave enemies die.

Rules:
- no manual pickup
- no storage between runs
- server-authoritative award
- spent only during the current run

Uses:
- turret upgrades
- limited additional turret placement

---

## Essence Rewards
Essence is generated during the run.

Rules:
- generated over time
- scales with survival duration
- increases with milestone progress
- about 70% is kept if the base is destroyed
- spent in the hub

Essence is the reason failed runs still feel useful.

---

## Failure
Player death:
- respawn at the base after about 20 seconds
- does not end the run

Base destruction:
- ends the run immediately
- returns players to the hub or run-end summary
- grants the retained essence amount

---

## Co-op And Authority
Gate state is server-authoritative.

The server handles:
- enemy spawns
- enemy AI
- damage
- enemy death
- scrap awards
- essence awards
- milestone state
- turret upgrade validation
- base health
- run success or failure

Clients request actions and show feedback.

---

## Explicit Backlog
Do not build these for the vertical slice:
- persistent gate worlds
- pylon capture or pylon channeling as the main loop
- caves
- POIs
- fog-of-war reveal
- roaming material gathering
- layered biome depth
- deep exploration rewards
- manual extraction pressure spikes

These may return later after the arena survival loop is fun.
