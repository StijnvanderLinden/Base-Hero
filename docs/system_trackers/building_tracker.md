# Building System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Building System.

---

## Current Status
Wall Prototype Implemented

---

## Current Design Summary
Building is one of the core identities of the game. Players create defensive layouts that shape enemy pressure and support combat.

The system should be:
- strategic
- readable
- co-op friendly
- easy enough to use under pressure

Main structure categories:
- walls
- turrets
- support structures later

---

## Implemented
- One server-authoritative wall placement prototype
- Grid-snapped wall placement validation on the server
- Local valid/invalid wall placement preview for the active player
- Preview wall orientation now matches the final placed wall
- Preview now shows explicit valid/blocked readability text
- Wall health and destruction
- Wall replication to connected clients and late joiners
- Enemies can now attack nearby placed walls before reaching the core

---

## In Progress
- Clarifying how building differs between main base and gates
- Tuning first wall placement spacing and build distance
- Deciding how freeform the first placement loop should remain before adding stronger snapping or more advanced ghost presentation

---

## Blockers / Problems
- No turret prototype yet
- No final decision on shared resources vs individual building permissions
- Building in gates is not yet finalized

---

## Must Have
- One wall type
- One turret type
- Server-authoritative placement validation
- Clear valid/invalid placement behavior
- Basic structure health
- Building tied to objective defense

---

## Should Have
- Upgrades for walls or turrets
- Cost system tied to progression resource
- Co-op-friendly shared building interaction
- Distinct difference between base building and gate building

---

## Could Have
- limited gate deployables
- repair interactions
- support structures
- specialized anti-air or anti-siege defenses
- structure behavior modifiers through components

---

## Won’t Have (for now)
- power-grid simulation
- large structure dependency trees
- highly complex snapping networks
- deep upgrade UI
- large trap catalog

---

## Open Questions
- Should placement be grid-based, snap-based, or more freeform?
- How much building is allowed during gates?
- How much should walls shape pathing in the early version?
- Are resources fully shared across players in co-op?
- Should repair be a separate mechanic or part of upgrades/support later?

---

## Recent Decisions
- Building is a core pillar, not optional flavor
- Walls and turrets are the first two important structure types
- Building should support combat rather than replace combat
- The first building step should be one simple wall with server-validated placement before adding turrets

---

## Next Recommended Task
Extend the first building loop:
- validate the wall in multiplayer sessions
- build the first turret prototype
- improve the placement preview presentation further if needed
- decide whether resources stay free in testing or become constrained next