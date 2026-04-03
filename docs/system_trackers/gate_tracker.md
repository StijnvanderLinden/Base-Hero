# Gate System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Gate System.

---

## Current Status
Direction Updated, First Prototype Partially Aligned

---

## Current Design Summary
Gates are now persistent biome expedition zones with layered depth progression.

Current confirmed direction:
- each gate is one biome region
- the map persists between runs
- fog of war reveal persists
- players revisit the same gate over time
- pylons are the key progression objectives
- captured pylons create footholds
- drills are placed at captured pylons for escalating reward defense loops
- building in gates is limited and local to pylons

---

## Implemented
- First gate prototype exists in the shared multiplayer scene
- Temporary drill objective and extraction flow are implemented in prototype form
- Gate reward flow already feeds back into base progression in a basic way
- A short build-then-defend prototype loop exists for testing
- High-level gate concept is documented

---

## In Progress
- Reframing the current prototype from temporary survival run to persistent gate expedition structure
- Defining how pylon capture, drills, and extraction fit together in the first real gate version
- Defining what persistent map state must exist in the first gate milestone

---

## Blockers / Problems
- Current prototype is still closer to a temporary survival drill than a persistent layered gate
- Pylon capture flow is not implemented yet
- Persistent map reveal and gate revisit state are not implemented yet
- Building rules near captured pylons are not implemented yet
- Exploration enemy families are not separated from construct event enemies in runtime yet

---

## Must Have
- One persistent gate biome
- Layered depth progression
- Pylon capture events
- Construct enemies for pylon defense
- Limited building near captured pylons
- Drill reward loop at secured pylons
- Return and revisit flow

---

## Should Have
- Fast travel between unlocked pylons
- Persistent fog-of-war reveal
- Rare materials from deeper layers
- Clear depth-based reward improvement
- A stronger distinction between exploration flow and defense events

---

## Could Have
- Local gate threat states
- Biome hazards beyond combat
- More than one drill type
- Layer-specific elite encounters
- Gate-specific mutators

---

## Won’t Have (for now)
- Full open-world sandbox behavior
- Fully clearable gate completion in one early tier
- Many simultaneous gate objective types
- Deep procedural simulation of gate worlds
- Complex economy layers tied to gates too early

---

## Open Questions
- What is the minimum persistent state for the first real gate milestone?
- Should captured pylons stay permanently safe or just easier to reclaim?
- How long should drill defense loops last before players usually stop?
- When should deeper layers start requiring new town hall tiers?
- How much gate travel convenience should unlock per captured pylon?

---

## Recent Decisions
- Gates are layered progression zones, not one-off missions
- Gates are not expected to be fully cleared in one tier
- Pylons are the main gate objectives
- Pylon defense events use engineered construct enemies
- Drills are placed at captured pylons rather than being the sole gate objective
- Building in gates is limited and local rather than fortress-scale

---

## Next Recommended Task
Define and implement the first true persistent gate slice:
- replace the current temporary-run framing with a single persistent gate region
- implement one pylon capture event
- implement one simple local reveal or foothold unlock
- split gate exploration enemies from construct event enemies