# Enemy System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Enemy System.

---

## Current Status
First Enemy Split Started

---

## Current Design Summary
Enemy design is now split into two categories:
- gate exploration enemies tied to biomes
- engineered construct enemies used for pylons and raids

The system should support:
- exploration pressure
- pylon defense events
- main raids
- co-op readability

Construct role direction:
- small swarm units
- shield units
- heavy breakers
- siege units
- elites

---

## Implemented
- Server-spawned basic enemy prototype exists
- Server-authoritative enemy movement replication exists
- Enemy health, death, and late-join replication exist
- Enemies can target objectives and nearby structures in the current prototype
- Readable overhead enemy health bars exist
- Basic wave pressure foundation exists
- Raids now use a first dedicated construct swarm unit instead of the generic exploration enemy

---

## In Progress
- Splitting the runtime enemy design into exploration enemies versus constructs
- Defining the next useful construct role beyond the first swarm unit
- Defining the first biome exploration enemy family

---

## Blockers / Problems
- No biome exploration family exists yet
- No shield, heavy, siege, or elite construct role is implemented yet
- No performance strategy tested for larger raid armies yet

---

## Must Have
- One exploration enemy family for the first biome
- One basic construct unit for pylons and raids
- Clear distinction between exploration pressure and defense-event pressure
- Server-authoritative enemy state
- Readable threat roles

---

## Should Have
- Shield construct
- Heavy construct
- Siege construct
- Better wave composition scaling
- Stronger role readability in groups

---

## Could Have
- Elite construct early tests
- More biome-specific enemy variants
- Ranged exploration enemies
- Flying exploration enemies
- Boss constructs later

---

## Won’t Have (for now)
- many subtle enemy subtypes
- complex behavior trees
- advanced faction interactions
- heavy simulation systems
- too many enemy roles at once

---

## Open Questions
- What is the first biome exploration enemy family?
- What is the first construct role after the current basic attacker?
- When should shield and siege roles enter the raid loop?
- How much enemy scaling should come from count versus role mix?
- What is the visual strategy for keeping layered encounters readable in 3D?

---

## Recent Decisions
- Enemy design is split between exploration enemies and constructs
- Construct enemies are used for pylon defense events and raids
- Exploration enemies should feel biome-driven rather than army-like
- Readability matters more than maximum complexity early on
- The first construct implementation should be a small swarm unit before adding shield, heavy, or siege roles

---

## Next Recommended Task
Implement the first enemy split:
- define one first-biome exploration enemy family
- add the second construct role after the swarm unit
- keep behavior readable and strongly role-driven
- validate both types in multiplayer