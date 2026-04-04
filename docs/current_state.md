# Current State

## Purpose
This document tracks the overall current implementation state of the project.

It should answer:
- what is already implemented
- what is partially implemented
- what is not implemented
- what the current focus is

This is the project-wide implementation snapshot.

For system-specific implementation detail, use the system trackers.

---

## Project Status
Early Multiplayer Prototype

The project now has a working multiplayer gameplay prototype with shared players, a defendable core objective, basic enemies, and basic combat. The implementation is still placeholder-heavy, but the first server-authoritative loop exists in-project.

---

## Implemented
### Documentation
- high-level GDD created
- detailed design support documents created
- architecture and networking direction documented
- system specs created for core gameplay systems
- system trackers created for core gameplay systems
- documentation workflow and update rules defined

### Prototype Gameplay
- host/join flow using ENet
- synchronized player spawning and movement
- server-authoritative enemy spawning and enemy movement replication
- server-authoritative core objective with replicated health and destroyed state
- basic player attack, enemy health, enemy death, and player/enemy health bars
- first server-authoritative wall and turret placement prototype with replicated defense structures, structure health, and turret bullet projectiles
- simple wave pacing with breather windows and in-session host restart flow for gate and raid pressure testing
- first confirmed gate prototype with build-first pylon setup, manual claim channeling, finite claim waves, cave activation, and extraction
- shared session scrap storage plus a first base-side spend target that upgrades core max health
- first town hall raid prototype with player-triggered upgrade channeling, finite raid waves, and no main-base enemy spawning outside active raids
- first runtime pylon slice with functional versus damaged state and nearby defense deactivation
- first cave activation slice with a sustained pylon channel that opens and closes the cave entrance
- first visible cave barrier and entrance presentation on the live pylon objective
- first cave-manager integration slice where claimed pylons prepare a cave descriptor and opened barriers mark that cave active
- first sustained cave-open pressure slice where enemy pressure keeps ramping while the cave remains open
- first damaged-pylon repair slice with a locked repair channel and lighter repair waves
- repair channel interruption on player death or movement, with restartable repair attempts

### Design Direction
- core game identity is defined
- multiplayer direction is defined
- gate/main-base relationship is defined at a high level
- primary systems have initial specifications

---

## Partially Implemented
- the smallest multiplayer-safe defense loop exists, but it still uses placeholder visuals and placeholder combat feel
- enemy behavior currently uses direct pursuit and objective pressure only, even though pacing now ramps by wave
- restart flow exists for repeated testing, but full match recovery/results flow is not implemented
- building now has wall and turret prototypes plus local preview feedback, but costs and repair/upgrades are not implemented yet
- gate flow now uses a first pylon foothold instead of the old drill objective, now supports manual claim waves, visible cave barrier states, sustained cave-open pressure, and a first repair loop, but real cave generation, deeper objectives, and revisit persistence are not implemented yet
- raid flow now exists in first prototype form and now uses a first dedicated construct swarm unit, but broader construct role variety is not implemented yet

---

## Not Yet Implemented
- progression systems
- broader progression systems beyond the first core upgrade

---

## Current Project Focus
The current focus is:
**Phase 7: Main Raid Prototype plus first pylon foothold integration**

That means the next practical targets are:
- validate that no enemies spawn at the base outside active raids
- validate town hall upgrade channeling and raid success/failure in multiplayer sessions
- validate the first construct raid unit and add the next construct role after it
- add a visible cave entrance and forced cave-exit behavior to the new pylon foothold loop

---

## Current Risks
- project scope is large
- many systems are still conceptual
- it will be important not to overbuild late systems before the prototype loop is working
- gates must remain distinct from main raids
- documentation must stay clean as ideas evolve

---

## What To Update Here
Update this file when:
- a new project-wide milestone is implemented
- a phase meaningfully changes
- overall project focus changes
- implementation reaches a new stage that future work depends on

Do not update this file for:
- small polish changes
- one-off tuning
- minor scene cleanup
- system details that belong only in trackers