# Building System Specification

## Purpose
The Building System allows players to place and upgrade defensive structures that protect objectives and shape the battlefield.

This system is central to the game's fortress-defense identity.

---

## Design Goals
- Building should be strategic but not tedious
- Placement should be clear and readable
- Structures should support active combat
- The system should work cleanly in co-op
- Placement and costs must be server-authoritative

---

## Core Fantasy
Players build a fortress that matters.

Building should let players:
- shape enemy paths
- create safety zones
- support combat roles
- improve over time
- feel attached to the base

The base should feel like something players created and defended, not just scenery.

---

## Main Structure Categories
Core categories:
- walls
- turrets
- support structures

Future categories:
- traps
- repair stations
- shield emitters
- utility buildings
- power systems

---

## Walls
Walls are the simplest and most important defensive structure.

### Purpose
- delay enemies
- create choke points
- shape space
- protect critical structures

### Design Goals
- easy to place
- easy to understand
- visually readable in a fight
- meaningful without overcomplicating pathing

Walls should buy time, not solve the whole fight alone.

---

## Turrets
Turrets provide automated offensive support.

### Purpose
- reduce pressure
- help with crowd control or priority targets
- reward good placement

### Design Goals
- useful but not dominant
- readable target behavior
- distinct roles when expanded later
- support player action rather than replace it

Early prototype direction:
- start with one simple turret type

---

## Support Structures
Support structures improve defense quality rather than acting as direct damage tools.

Possible examples:
- repair station
- buff beacon
- ammo or energy relay
- shield generator

These should be introduced later, after walls and turrets work.

---

## Placement Rules
Placement should be predictable.

Possible rules:
- snap placement
- valid/invalid preview
- collision checks
- range restrictions
- no overlap
- terrain restrictions

### Authority Rule
Clients may preview and request placement.

The server decides:
- whether placement is valid
- whether cost is paid
- where final structure is spawned

---

## Economy Relation
Building should connect to progression and resources.

Likely uses:
- core resource for basic upgrades and building
- components or rare materials for advanced structures

For early prototypes:
- use simple costs or free placement if needed for testing

Design rule:
- building cost should create meaningful choices, not busywork

---

## Upgrades
Structures may be upgraded over time.

Possible upgrade directions:
- more health
- more damage
- better range
- special attack behavior
- utility improvements

Important:
- do not overbuild full upgrade trees early

---

## Main Base vs Gates
The system may behave differently in different contexts.

### Main Base
- deeper building system
- more persistent structures
- stronger long-term planning

### Gates
Open question:
- full building
- limited deployables
- temporary defensive placements only

Current likely direction:
- deeper building at main base
- lighter or more temporary defenses in gates

---

## Co-op Considerations
Multiple players should be able to contribute.

Open questions:
- shared resource pool vs individual resources
- who can place or upgrade what
- how repairs work in co-op

Current likely direction:
- co-op-friendly by default
- low friction collaboration

---

## Future Extensions
Possible later additions:
- trap networks
- anti-air structures
- siege counters
- repair interactions
- structure synergies
- upgrade branches
- structure specialization

---

## Early Prototype Scope
The first building prototype should include:
- one wall
- one turret
- basic placement validation
- server-authoritative placement
- simple or no-cost testing mode

Do not build yet unless explicitly requested:
- advanced snap networks
- power-grid simulation
- complex upgrade UI
- dependency chains