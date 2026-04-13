# Enemy System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Enemy System.

---

## Current Status
Stone Age Enemy Family Implemented For The First Era Slice

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
- Era-driven gate wave definitions now exist
- Stone Age now has a full first exploration enemy family:
	- Caveman
	- Brute
	- Beast
	- Stone Mech mini boss
- Beast now uses a simple charge behavior for pressure spikes
- Final Stone Age pylon wave now resolves through a defined boss finish instead of endless generic pressure
- Raids still keep their existing construct swarm and breaker roles

---

## In Progress
- Tuning Stone Age wave cadence, health values, and boss pressure
- Keeping the split between era exploration enemies and raid constructs readable in mixed project state

---

## Blockers / Problems
- No shield, siege, or elite construct role is implemented yet
- Stone Age enemy visuals still use simple prototype scene geometry
- No performance strategy tested for larger mixed armies yet

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
- The first era uses a self-contained Stone Age enemy family instead of generic exploration placeholders
- Stone Age gate pressure is wave-defined and boss-capped rather than open-ended in the first slice

---

## Next Recommended Task
Validate the Stone Age family in multiplayer:
- tune Caveman, Brute, Beast, and Stone Mech pacing
- confirm the final-wave completion feel during pylon channeling
- keep raid constructs separate from era exploration pressure
- use that validation to define the next construct role after the current breaker