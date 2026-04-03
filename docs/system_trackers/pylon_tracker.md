# Pylon System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Pylon System.

---

## Current Status
Design Confirmed, Not Implemented

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

---

## In Progress
- Defining the first functional versus damaged pylon state machine
- Defining activation and repair behavior for the first milestone

---

## Blockers / Problems
- No pylon runtime system exists yet
- No functional versus damaged pylon state is implemented yet
- No defense activation or deactivation behavior tied to pylon state exists yet
- No repair event is implemented yet

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
Implement the first pylon slice:
- create one pylon state machine
- implement cave activation channeling at a captured pylon
- disable nearby defenses when damaged
- implement one repair-under-pressure recovery event