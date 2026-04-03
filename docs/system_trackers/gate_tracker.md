# Gate System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Gate System.

---

## Current Status
Direction Updated, Cave Expedition Structure Confirmed

---

## Current Design Summary
Gates are persistent biome expedition zones with layered depth progression.

Current confirmed direction:
- each gate is one biome region
- the map persists between runs
- fog of war reveal persists
- players revisit the same gate over time
- pylons are the key foothold objectives
- captured pylons activate caves through channeling and resource spend
- cave expeditions create an outside-defense versus inside-exploration split
- failure damages pylons and creates a repair loop instead of removing player resources
- building in gates is limited and local to pylons

---

## Implemented
- First gate prototype exists in the shared multiplayer scene
- Gate reward flow already feeds back into base progression in a basic way
- High-level persistent gate concept is documented
- The live gate foothold now uses a first pylon runtime objective instead of the old drill objective
- The live gate now starts in a build phase and only begins claim pressure when players manually channel the pylon
- The live claim event now finishes only after all finite claim waves are cleared
- Nearby gate defenses now deactivate when that pylon is damaged
- The live pylon now supports the first cave activation flow through scrap spend and channeling
- The live pylon now shows a first visible cave barrier and entrance state during claimed, channeling, open, and disabled phases
- The live gate now supports a first damaged-pylon repair loop with a locked repair channel and lighter repair waves

---

## In Progress
- Reframing the current prototype from temporary pylon-defense survival to pylon-activated cave expeditions
- Defining the first real outside-versus-inside gameplay loop beyond the new cave-open state
- Defining the minimum persistent state for pylons, caves, and recovery

---

## Blockers / Problems
- Current prototype is still closer to a temporary pylon-defense survival loop than a cave expedition loop
- Cave travel and forced exit are still not implemented yet
- Persistent map reveal and gate revisit state are not implemented yet
- Building rules near captured pylons are not implemented yet
- Exploration enemy families are not yet separated from all construct event pressure in runtime

---

## Must Have
- One persistent gate biome
- Layered depth progression
- Pylon capture events
- Cave activation from captured pylons
- Outside-defense versus inside-exploration gameplay
- Damaged pylon and repair loop
- Return and revisit flow

---

## Should Have
- Fast travel between unlocked pylons
- Persistent fog-of-war reveal
- Rare materials from deeper cave layers
- Clear depth-based reward improvement
- Strong distinction between overworld gate pressure and cave reward flow

---

## Could Have
- Local gate threat states
- Biome hazards beyond combat
- Multiple cave branches from a single foothold
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
- What is the minimum persistent state for the first true cave milestone?
- Should damaged pylons remain visible as reclaimable footholds or fully revert to neutral control?
- How much manual defense is expected outside while one player explores inside?
- When should deeper cave layers start requiring new town hall tiers?
- How much travel convenience should unlock per repaired or functional pylon?

---

## Recent Decisions
- Gates are layered progression zones, not one-off missions
- Pylons are the main foothold objectives inside gates
- Caves are activated from captured pylons rather than discovered randomly
- Cave failure damages pylons and triggers recovery gameplay rather than removing player resources
- Existing pylon defenses are reused for cave events rather than rebuilding inside caves

---

## Next Recommended Task
Define and implement the first true cave gate slice:
- connect the visible cave entrance to actual cave travel
- implement one simple forced-exit failure flow
- implement one first interior reward objective