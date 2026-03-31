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

### Design Direction
- core game identity is defined
- multiplayer direction is defined
- gate/main-base relationship is defined at a high level
- primary systems have initial specifications

---

## Partially Implemented
- the smallest multiplayer-safe defense loop exists, but it still uses placeholder visuals and placeholder combat feel
- enemy behavior currently uses direct pursuit and objective pressure only
- lose-state messaging exists, but full match restart/recovery flow is not implemented
- building, gate flow, raid flow, and progression are still not connected to the prototype loop

---

## Not Yet Implemented
- building system
- gate prototype
- raid prototype
- progression systems

---

## Current Project Focus
The current focus is:
**Phase 2: Basic Objective Defense, with early enemy/combat validation**

That means the next practical targets are:
- stabilize the shared core-defense loop
- improve enemy pressure around the core
- improve combat feedback and readability
- prepare the prototype for first building interactions

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