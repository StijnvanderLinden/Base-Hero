# Cave System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Cave System.

---

## Current Status
First Activation And Entrance Slice Implemented

---

## Current Design Summary
Caves are activated from captured pylons and create a split between outside defense and inside exploration.

Current confirmed direction:
- cave activation starts from a captured pylon through resource spend and channeling
- a magical barrier disappears to reveal the entrance
- enemies pressure the pylon outside while players explore inside
- passive gain exists but is secondary to exploration rewards
- failure collapses the cave and forces the player out
- players keep all collected loot on failure

---

## Implemented
- Cave expeditions are defined as part of the current gate direction
- First cave activation flow now exists on the live pylon objective
- Cave activation now spends stored scrap and channels at the pylon before the cave opens
- A visible cave barrier and entrance presentation now appears at claimed pylons and changes state as the cave opens or disables
- Cave-open state now increases passive gate reward rate to mark the outside-versus-inside pressure phase
- Cave activation is now gated behind a claimed-pylon event rather than the initial gate start alone

---

## In Progress
- Defining the first outside-versus-inside pressure loop
- Defining the first forced-exit failure behavior
- Replacing the visible cave entrance placeholder with actual cave travel and interior content

---

## Blockers / Problems
- No forced exit on cave failure exists yet
- No cave-specific reward structure is implemented yet
- Cave entrance presentation now exists, but cave-open state is still not a separate interior space
- Cave failure now disables the pylon and starts repair, but it still does not move players out of a separate cave space because that space does not exist yet

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
- connect the visible cave entrance to one simple cave transition or travel behavior
- implement one deeper reward objective inside the cave
- implement one forced-exit collapse behavior on failure
- decide how players transition into and out of the first cave space