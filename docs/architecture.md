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
├── World
│   ├── Players
│   ├── Enemies
│   ├── Projectiles
│   ├── Structures
│   ├── Objectives
│   └── Environment
└── UI