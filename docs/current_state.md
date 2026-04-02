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
- simple wave pacing with breather windows and in-session host restart flow for repeated defense testing
- first confirmed gate prototype with prep-phase building, a temporary drill objective, passive scrap gain, and drill-triggered five-second extraction

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
- gate flow now follows the confirmed prep/build/extract rule set, but rewards are not connected to progression and gate content variety is still minimal

---

## Not Yet Implemented
- raid prototype
- progression systems

---

## Current Project Focus
The current focus is:
**Phase 5: First Gate Prototype, built on the multiplayer-safe defense foundation**

That means the next practical targets are:
- validate gate prep building and extraction interaction in multiplayer
- decide whether the first gate loop needs an external side reward at all
- connect gate rewards into a first upgrade or persistence path
- keep the base-defense foundation stable while gate flow grows

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