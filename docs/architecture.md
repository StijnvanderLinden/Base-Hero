# Architecture Document

## Purpose
This document defines the technical structure and responsibilities of the project at a high level.

Use this file for:
- system responsibilities
- ownership boundaries
- architectural rules
- scene/system relationship guidance

This file should describe the intended technical truth of the project, not temporary polish-level implementation details.

---

## Architectural Goals
The architecture should aim to be:

- server-authoritative
- readable
- beginner-friendly
- modular enough to grow
- simple enough to maintain
- adaptable to future Steam session flow

Avoid overengineering.
Prefer practical scene-based structure over heavy abstraction.

---

## High-Level Model

### Host / Server
The host acts as the authoritative server.

The server is responsible for:
- authoritative game state
- validating gameplay actions
- spawning shared entities
- simulating enemy behavior
- resolving shared combat outcomes
- deciding rewards, progression, and success/failure

### Clients
Clients are responsible for:
- gathering local input
- sending requests/intents to the host
- presenting visuals and local feedback
- showing synchronized world state

Clients are not trusted for shared gameplay truth.

---

## Core Authority Rules

### Server-authoritative systems
The server must own and validate:
- objectives and core health
- enemy spawning
- enemy AI
- enemy target selection
- damage and death outcomes
- structure placement validity
- reward generation
- extraction state
- wave/raid progression
- gate success/failure
- progression unlocks

### Client-originated actions
Clients may originate:
- movement input
- attack requests
- interaction requests
- build requests
- extraction requests
- UI actions
- camera and local presentation state

### Critical rule
Client-originated actions are requests, not truth.

---

## Architectural Priorities
The architecture should prioritize:

1. Correct authority boundaries
2. Clear scene and system ownership
3. Simple growth path from prototype to fuller game
4. Separation between gameplay logic and session/network bootstrap logic
5. Maintainability for a solo developer using AI assistance

---

## Recommended Scene Structure
A practical high-level scene structure is:

```text
Main
├── NetworkManager
├── CaveManager
├── World
│   ├── Players
│   ├── Enemies
│   ├── Projectiles
│   ├── Structures
│   ├── Objectives
│   └── Environment
└── UI
```

---

## System Ownership

### GateManager
Owns:
- pylon claim flow
- cave barrier state at the entrance
- outside pressure around the pylon
- repair and recovery flow
- expedition success or failure at the overworld layer

GateManager should not own:
- procedural cave layout generation
- cave room graph building
- interior encounter placement
- cave reward layout
- cave travel implementation details

### CaveManager
Owns the future cave-generation boundary.

Its job is to:
- accept a cave request from the overworld layer
- prepare or generate cave content from that request
- expose spawn points, exit points, and reward anchors
- track whether a cave is prepared, active, collapsed, or cleared

Its job is not to:
- decide whether a pylon may be claimed
- decide whether the barrier should open
- own repair logic
- own overworld enemy pressure

---

## Future Cave Boundary

The current pylon and gate loop should only depend on a narrow cave interface.

Expected input to future cave generation:
- pylon identifier
- entrance position
- biome identifier
- depth tier
- seed
- active player count

Expected output from future cave generation:
- cave identifier
- cave root or descriptor
- player spawn points
- exit anchor
- reward anchor
- current cave state

This keeps the current overworld prototype compatible with a later procedurally generated cave system without forcing GateManager to understand cave internals.