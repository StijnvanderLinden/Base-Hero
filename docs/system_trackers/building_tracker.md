# Building System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Building System.

---

## Current Status
Wall And Turret Prototype Implemented

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
- One server-authoritative turret placement prototype
- Grid-snapped wall placement validation on the server
- Local valid/invalid structure placement preview for the active player
- Preview wall orientation now matches the final placed wall
- Players can rotate build preview orientation and final wall/turret placement during a live session
- Preview now shows explicit valid/blocked readability text
- Players can switch between wall and turret building during a live session
- Shared scrap costs now gate wall and turret placement with server-side refusal feedback
- Players can repair damaged walls and turrets with the normal interact input when standing nearby
- Wall health and destruction
- Turret health, target scanning, and server-spawned bullet projectiles that hit enemies
- Wall replication to connected clients and late joiners
- Turret replication to connected clients and late joiners
- Enemies can now attack nearby placed defenses before reaching the core

---

## In Progress
- Clarifying how building differs between main base and gates
- Tuning first wall placement spacing, build distance, and first cost values
- Tuning repair cost, repair amount, and interaction radius for early defense maintenance
- Tuning turret range, bullet speed, rate of fire, and placement spacing
- Deciding how freeform the first placement loop should remain before adding stronger snapping or more advanced ghost presentation

---

## Blockers / Problems
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
- The first turret should be a straightforward auto-fire defense, not a complex upgrade tree or ability platform

---

## Next Recommended Task
Extend the first building loop:
- validate wall and turret building in multiplayer sessions
- decide whether turret placement should share the same budget as walls or use separate costs later
- improve the placement preview presentation further if needed
- decide whether resources stay free in testing or become constrained next