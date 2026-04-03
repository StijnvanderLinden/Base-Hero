# Pylon System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Pylon System.

---

## Current Status
First Runtime Slice Implemented

---

## Current Design Summary
Pylons are foothold objectives inside gates.

Current confirmed direction:
- pylons have functional and damaged states
- captured pylons can activate caves through resource spend and channeling
- existing nearby defenses are reused for cave expeditions
- damaged pylons disable defenses and safe-zone effects
- repairing pylons is a gameplay event under enemy pressure

---

## Implemented
- Pylons exist as a documented gate objective direction
- Limited building around pylons is part of the current gate direction
- First runtime pylon foothold now exists in the gate prototype
- Pylons now begin uncaptured and are manually claimed by starting a claim channel at the pylon
- Claim completion now depends on clearing finite construct waves rather than waiting out a timer alone
- Pylons now switch between functional and damaged states in runtime
- The live pylon now controls a visible cave barrier that shifts through sealed, channeling, open, and disabled presentation states
- Nearby walls and turrets now go offline when the active pylon is damaged
- Damaged pylons now support a first repair channel plus lighter repair defense event
- Repair channeling now breaks if the channeling player dies or leaves the repair spot, and can be restarted

---

## In Progress
- Defining activation and repair behavior for the first milestone

---

## Blockers / Problems
- Damaged pylons do not yet have a repair interaction or persistent reclaim flow
- Cave presentation exists, but there is still no separate cave travel or interior space yet
- Repair event failure does not yet have extra consequences beyond remaining damaged

---

## Must Have
- Captured or functional pylon state
- Damaged pylon state
- Cave activation from a pylon
- Defense activation and deactivation rules
- Repair loop under enemy pressure

---

## Should Have
- Clear pylon-state readability in world presentation
- Safe-zone benefits linked to pylon state
- Better feedback for activation, failure, and repair
- Travel unlock behavior tied to pylon state

---

## Could Have
- Pylon-specific upgrades
- Different pylon archetypes
- Stronger pylon area buffs
- Multi-stage repair or reclaim variants

---

## Won’t Have (for now)
- Deep pylon upgrade trees
- Many different pylon objective types at once
- Large UI-heavy management layers for pylons early on
- Permanent pylon loss on failure

---

## Open Questions
- What exact resource should activate a cave at a pylon?
- How visible should the damaged state be from a distance?
- How much enemy attention should repair events draw?
- Should repair fully restore the area immediately or restore it in one clean step?

---

## Recent Decisions
- Caves are activated from pylons, not found randomly
- Existing pylon defenses are reused for cave events
- Failure damages pylons instead of removing player resources
- Repairing pylons is a gameplay event with enemy pressure

---

## Next Recommended Task
Implement the next pylon milestone:
- connect the visible cave entrance to actual cave travel or transition logic
- add stronger repair-event failure consequences if needed
- keep damaged-pylon readability clear during multiplayer play
- decide what persists between failed expeditions and later returns