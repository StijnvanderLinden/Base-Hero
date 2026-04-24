# Detailed Game Design

## Purpose
This document explains how the confirmed vertical-slice loop works across systems.

The current target is deliberately narrow:

**Main Hub -> Gate Run -> Survive -> Repeat**

Use this file for cross-system design relationships. Use system specs and trackers for deeper implementation detail.

---

## Current Design Direction
The project is currently centered on four working pieces:

- simple hub progression
- one arena-style gate run
- active base defense with turrets
- repeatable survival progression

The intended player read is:
- I unlocked something in the hub
- I survived longer in the run
- I earned essence
- I want to try again

---

## Hub vs Run Relationship

### Hub
The hub is the low-pressure progression space.

For the vertical slice, the hub can be a simple menu or compact space.

The hub handles:
- spending essence
- unlocking turret types
- unlocking turret upgrade branches
- increasing base capacity
- optionally upgrading the basic player weapon

The hub should be quick. It should not become a town simulation before the run loop is fun.

### Gate Run
The gate run is the high-pressure action space.

For the vertical slice, it is:
- one small arena
- one central base/core
- one preset starter base
- continuous wave pressure
- in-run scrap spending
- survival milestones

The run starts quickly and tests whether combat, defenses, and escalation feel good.

---

## Resource Relationship

### Scrap
Scrap is an in-run survival resource.

Rules:
- only wave enemies drop scrap
- scrap is automatically collected on kill
- scrap is not stored between runs
- scrap is spent during the current run

Scrap supports:
- turret upgrades
- limited additional turret placement

Scrap must matter because it keeps the defense alive under pressure.

### Essence
Essence is the between-run progression resource.

Rules:
- generated over time during a run
- improved by reaching milestones
- kept at about 70% if the base is destroyed
- spent in the hub

Essence supports:
- turret type unlocks
- turret upgrade branch unlocks
- base capacity
- optional player weapon upgrades

---

## Base Relationship
The base is the defended objective and the center of the run.

For the vertical slice:
- the base starts pre-configured
- walls have fixed strength
- turrets start at level 1 every run
- the layout is strong enough for early waves
- the layout is not strong enough to play without the player

Players should fight alongside the base, not watch it play by itself.

---

## Turret Upgrade Direction
Turret upgrades should be obvious and impactful.

Good upgrade types:
- faster firing
- longer range
- area damage
- burst damage
- transformation into a new unlocked turret type

Avoid tiny upgrades that only shift numbers slightly.

Locked advanced upgrades may be visible but unavailable so hub progression feels desirable.

---

## Wave And Milestone Direction
The wave system is the main pressure driver.

It should:
- spawn enemies continuously
- increase spawn rate over time
- increase enemy strength over time
- force active defense from early in the run

Milestones split a run into five pressure bands:
- 1/5: early
- 2/5: mid
- 3/5: high pressure
- 4/5: extreme
- 5/5: endgame

Each milestone should make both danger and rewards feel higher.

---

## Death And Failure
Player death should create a temporary loss of control, not immediate run failure.

Rules:
- dead players respawn at the base after about 20 seconds
- base destruction ends the run immediately
- base destruction returns the player to the hub with about 70% of earned essence

The run should be repeatable even when failed.

---

## Multiplayer Direction
The vertical slice must preserve server authority.

The server/host decides:
- enemy spawning
- enemy AI
- damage
- enemy death
- scrap awards
- essence awards
- turret placement validity
- turret upgrades
- base health
- run failure

Clients request actions and show feedback.

---

## Delayed Systems
These ideas may be useful later, but they are not part of the vertical slice:

- POIs
- caves
- roaming exploration
- gold
- material-specific trees
- deep research
- multiple worlds or eras
- complex enemy families
- freeform base building outside the preset layout

Only promote these after the core loop already creates the one-more-run feeling.

---

## Design Risks To Watch
Current risks:
- the base becomes too passive and plays for the player
- early waves are too slow or idle
- scrap spending feels optional instead of necessary
- essence rewards feel grindy instead of motivating
- turret upgrades feel like small stat bumps
- old exploration or era systems distract from the MVP

When in doubt, test the run loop before adding systems.
