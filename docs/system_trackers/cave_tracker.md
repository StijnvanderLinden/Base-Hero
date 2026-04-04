# Cave System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Cave System.

---

## Current Status
First Activation And Entrance Slice Implemented

---

## Current Design Summary
Cave entrances already exist in the gate world, and pylons control whether their barrier is sealed or opened for expedition play.

Current confirmed direction:
- the cave itself is already present in the world before activation
- a magical barrier blocks the entrance until players start the cave channel at the pylon
- enemies pressure the pylon outside while players explore inside
- passive gain exists but is secondary to exploration rewards
- failure collapses the cave and forces the player out
- players keep all collected loot on failure

---

## Implemented
- Cave expeditions are defined as part of the current gate direction
- First cave activation flow now exists on the live pylon objective
- Cave activation now starts from a claimed pylon and toggles the cave barrier open or closed through interaction at the pylon
- A visible cave entrance and barrier presentation now exists through the whole live gate run and changes state as the barrier opens or disables
- Cave-open state now increases passive gate reward rate to mark the outside-versus-inside pressure phase
- Cave activation is now gated behind a claimed-pylon event rather than the initial gate start alone
- A first `cave_manager.gd` stub now defines the future request, prepare, enter, collapse, and clear API boundary for procedural caves
- The live gate flow now prepares a cave descriptor on pylon claim and marks it active when the barrier opens
- Keeping the cave open now keeps outside enemy pressure active and ramps spawn count and health over time

---

## In Progress
- Defining the first outside-versus-inside pressure loop
- Defining the first forced-exit failure behavior
- Replacing the sustained open-door prototype with actual cave travel and interior content
- Defining how the future procedural cave generator will fulfill the cave manager request data

---

## Blockers / Problems
- No forced exit on cave failure exists yet
- No cave-specific reward structure is implemented yet
- Cave entrance presentation and sustained outside pressure now exist, but cave-open state is still not a real generated cave scene
- The live prototype currently has no interior cave travel or deeper reward target behind the opened barrier yet

---

## Must Have
- Cave activation from a captured pylon
- Barrier removal or entrance reveal
- Outside pressure while the cave is active
- Main rewards deeper inside the cave
- Forced exit on failure

---

## Should Have
- Better cave reward escalation by depth
- Clear UI or world feedback for cave active state
- Distinct final reward point such as a boss or chest
- Clear voluntary exit behavior

---

## Could Have
- Branching cave paths
- Cave bosses
- Cave shortcuts
- Biome-specific cave hazards
- Multiple interior reward endpoints

---

## Won’t Have (for now)
- Separate defense-building inside caves
- Hard fail timers for cave expeditions
- Inventory loss on cave failure
- Overly expensive or overly long cave recovery flow

---

## Open Questions
- What is the minimum cave layout needed for the first milestone?
- How deep should the first cave go before the final reward?
- How much passive resource gain is enough to matter without rewarding idling?
- Should one player be able to stay outside while another explores inside in the first version?

---

## Recent Decisions
- Cave expeditions are activated from captured pylons
- Existing defenses outside the pylon are reused for cave events
- Passive gain exists but is secondary to exploration
- Failure collapses the cave and forces the player out
- Players retain all collected loot on failure

---

## Next Recommended Task
Implement the next cave milestone:
- connect the opened barrier to one first real cave interior or travel slice
- implement one forced-exit collapse behavior on failure
- replace the sustained open-door placeholder with a real generated cave space behind the same cave manager boundary
- decide how players transition into and out of the first cave space