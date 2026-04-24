# Current State

## Purpose
This document tracks the overall implementation state after the vertical-slice refocus.

It should answer:
- what is already usable
- what is placeholder-heavy
- what is intentionally deferred
- what the current focus is

For system-specific detail, use the system trackers.

---

## Project Status
Early Multiplayer Prototype Refocused On Vertical Slice

The project has a working server-authoritative multiplayer foundation, shared players, a defendable core, basic enemies, basic combat, and prototype defense structures.

The current design target is now narrower:

**Main Hub -> Gate Run -> Survive -> Repeat**

The goal is to prove the fun of one small arena-style gate run with scrap, turret upgrades, essence progression, and fast repetition before adding exploration or broader era systems.

---

## Implemented

### Documentation
- core docs now prioritize the focused vertical slice
- Stone Age now describes the first arena-style MVP rather than a broader era/exploration slice
- deferred systems are routed to backlog

### Prototype Gameplay Foundation
- host/join flow using ENet
- synchronized player spawning and movement
- server-authoritative enemy spawning and movement replication
- server-authoritative core objective with replicated health and destroyed state
- basic player attack, enemy health, enemy death, and player/enemy health bars
- wall and turret prototypes with replicated placement and projectile behavior
- gate-pressure enemy deaths now award scrap automatically
- turrets can now be upgraded with scrap through the existing interaction flow
- in-session restart flow for repeated multiplayer testing
- system test picker with isolated sandbox suites

### Reusable Systems Worth Keeping
- core objective health and failure handling
- enemy pressure spawning and wave pacing foundations
- building and defense structure foundations
- era data and era manager foundations, if kept lightweight
- research and unlock scaffolding, if simplified into essence-based hub unlocks

---

## Partially Implemented
- the smallest multiplayer-safe defense loop exists, but the run is not yet the final MVP loop
- turrets now have a first scrap-paid upgrade, but it still needs playtesting and tuning as the core survival sink
- enemy spawning exists, but needs vertical-slice milestone escalation
- progression scaffolding exists, but needs simplification around essence
- some runtime and docs still contain legacy assumptions from broader gate, pylon, era, material, or raid directions

---

## Not Yet Implemented
- simple hub progression loop for essence spending
- limited additional turret placement paid with scrap
- five milestone pressure bands
- essence generation based on survival and milestones
- 70% essence retention on base destruction
- 20-second player respawn at base
- locked turret upgrade branches shown but unavailable until hub unlocks

---

## Intentionally Deprioritized Or Removed
- POIs and cave exploration
- roaming material gathering
- gold and complex material economies
- multiple worlds or eras
- material-specific research trees
- deep meta-progression
- complex enemy variants
- freeform base building outside the preset layout
- pylon-first gate progression
- town-hall-upgrade-driven major raids as the main progression test

---

## Current Project Focus
The current focus is:

**Focused Vertical Slice: Hub Progression, Gate Arena, Scrap Upgrades, Essence Repeat Loop**

The next practical targets are:
- make one run arena start quickly
- create early wave pressure
- award scrap automatically on enemy kill
- spend scrap on impactful turret upgrades
- generate essence from survival and milestones
- end the run cleanly when the base is destroyed
- return to the hub and spend essence

---

## Current Risks
- old exploration, material, era, pylon, or raid assumptions may distract from the MVP
- turret upgrades may feel too small if they are only percentage bumps
- early waves may feel idle if pressure starts too slowly
- scrap may feel optional instead of necessary
- essence may feel grindy if rewards are too small or unlocks are too incremental
- the base may become too strong and make players passive

---

## What To Update Here
Update this file when:
- a new project-wide milestone is implemented
- the prototype loop meaningfully changes
- legacy systems are fully retired from the runtime
- the project focus moves to the next validated slice

Do not update this file for:
- small feel tuning
- visual polish only
- minor scene cleanup
- system details that belong only in trackers
