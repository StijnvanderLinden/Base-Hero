# Decisions

## Purpose
This document records important project decisions and why they were made.

Use this file to preserve reasoning over time so the project does not repeatedly re-debate the same choices without context.

Record:
- major design decisions
- major technical decisions
- important scope boundaries
- changes in direction with reasoning

---

## Decision Log

### April 2026 focused vertical-slice refocus
Decision:
The project's most important goal is now to prove a focused playable loop:

**Main Hub -> Gate Run -> Survive -> Repeat**

The vertical slice should include only what is necessary to make that loop fun:
- simple hub progression
- one small gate arena
- one central base/core
- wave enemies
- automatic scrap from enemy kills
- in-run turret upgrades and limited extra turret placement
- essence earned from survival and milestones
- essence spent in the hub
- base destruction as run failure
- player respawn after death

Reason:
The project needs to validate fun before adding complexity. If the base loop is not fun, broader systems will not fix it. The intended proof is that the player feels stronger after hub upgrades, survives longer in the run, and wants one more attempt.

---

### Broad exploration and era systems are backlog
Decision:
POIs, caves, roaming exploration, gold, complex material systems, multiple worlds or eras, material-specific trees, deep meta-progression, complex enemy variants, and freeform base building outside the preset layout are deferred.

Reason:
These may be good future systems, but they are highly susceptible to change until the core loop is validated. Building them now would slow iteration and risk hiding problems in the survival-defense loop.

---

### Scrap is the core in-run resource
Decision:
Scrap is dropped only by wave enemies, collected automatically on kill, spent during the current run, and not stored between runs.

Reason:
Scrap directly connects active combat to survival decisions. It avoids pickup friction and keeps the player focused on defending, killing, and upgrading under pressure.

---

### Essence is the core between-run progression resource
Decision:
Essence is generated over time during a run, scales with survival duration and milestones, and is spent in the hub. If the base is destroyed, the player keeps about 70% of earned essence.

Reason:
Essence gives failed runs forward motion without removing the sting of failure. It supports the fantasy that each attempt makes the next run more promising.

---

### Turret upgrades must be impactful
Decision:
Turret upgrades should create clear behavior changes such as faster fire rate, longer range, area attacks, burst attacks, or transformation into unlocked advanced types.

Reason:
Small percentage increases are hard to feel during a frantic 3D defense run. The vertical slice needs obvious upgrade feedback so scrap spending feels exciting and necessary.

---

### Walls are fixed strength for the vertical slice
Decision:
Walls are not upgraded in the MVP.

Reason:
The first survival loop should focus on active combat, turret decisions, and pressure readability. Wall upgrade layers can wait until the core loop is proven.

---

### Base-defense focus over open-world survival
Decision:
The game is base-defense focused rather than a full open-world survival sandbox.

Reason:
This keeps the project aligned with its strongest fantasy:
- defend meaningful objectives
- fight alongside defenses
- make tactical survival decisions

It also keeps scope more manageable and supports stronger pacing.

---

### Host-authoritative multiplayer
Decision:
The multiplayer model is hosted co-op with the host acting as the authoritative server.

Reason:
This fits the project's intended scale, keeps infrastructure needs lower, and supports the desired co-op structure.

---

### Steam support is planned later, not required early
Decision:
The game should be designed so future Steam integration is smooth, but early prototypes should not depend on Steam-specific implementation.

Reason:
This prevents release-platform concerns from blocking core gameplay prototyping.

---

### All health bars use a screen-space overlay
Decision:
Any health bar added to a world entity should be drawn by the shared screen-space UI overlay rather than as a 3D mesh in the world.

Reason:
This keeps combat readability consistent in 3D and co-op, avoids camera-facing and parent-rotation issues, and gives every entity one stable presentation path for future health bars.

---

## Rules
Update this file when:
- a major design or technical choice is made
- a meaningful pivot occurs
- the project's boundaries change

Do not update for:
- small tuning changes
- temporary experiments
- one-off implementation details
