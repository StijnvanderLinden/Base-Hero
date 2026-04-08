# Pylon System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Pylon System.

---

## Current Status
Design Refactor Confirmed, Runtime Alignment Needed

---

## Current Design Summary
Pylons are foothold objectives inside gates and the center of the repeatable channeling loop.

Current confirmed direction:
- pylons have uncaptured, functional, channeling, and shutdown states
- the first activation on a pylon is free
- repeat activations on that same pylon cost gold
- early pylons allow any building type around the foothold
- existing nearby defenses are reused across repeated channel attempts
- generated essence is stored in a physical holder object during active runs
- milestone rewards are always safe while generated essence remains vulnerable
- failure resets the pylon loop without forcing structure rebuilds
- later pylon variants may apply debuffs such as build restrictions, no heal or repair rules, or heavier elite pressure

---

## Implemented
- Pylons exist as a documented gate objective direction
- Limited building around pylons is part of the current gate direction
- First runtime pylon foothold now exists in the gate prototype
- Pylons now begin uncaptured and are manually claimed by starting a claim channel at the pylon
- Claim completion now depends on clearing finite construct waves rather than waiting out a timer alone

---

## In Progress
- Replacing the old cave-facing activation flow with the finalized channeling loop
- Defining the first essence holder behavior and milestone thresholds
- Defining the first shutdown sequence and failure reset behavior

---

## Blockers / Problems
- Current runtime still reflects older cave-oriented pylon behavior and naming
- Essence holder visuals, warning feedback, and loss rules are not implemented yet
- Shutdown behavior is not implemented yet
- Repeat activation gold costs and efficiency falloff are not implemented yet

---

## Must Have
- Captured or functional pylon state
- Repeatable channel activation from a pylon
- First activation free rule
- Repeat activation gold cost rule
- Essence holder risk object
- Milestone rewards with safe banking
- Shutdown phase
- Defense reuse without rebuild friction

---

## Should Have
- Clear pylon-state readability in world presentation
- Safe-zone benefits linked to pylon state
- Better feedback for holder threat and milestone completion
- Travel unlock behavior tied to pylon state
- Debuff variants that create distinct tactical identities for later pylons

---

## Could Have
- Pylon-specific upgrades
- Different pylon archetypes
- Stronger pylon area buffs
- Biome-specific channel modifiers
- Specific build-restriction pylons such as walls-only, turrets-only, or traps-only events

---

## Won’t Have (for now)
- Deep pylon upgrade trees
- Many different pylon objective types at once
- Large UI-heavy management layers for pylons early on
- Permanent pylon loss on failure

---

## Open Questions
- What exact gold cost curve should repeat activations use?
- How visible should holder danger be from a distance?
- How much durability should the holder have relative to pylon defenses?
- When should older pylon efficiency drop enough to push players toward deeper ones?

---

## Recent Decisions
- Pylon channeling replaces caves as the main gate reward activity
- First pylon activation is free to support learning and scouting
- Repeat pylon activations cost gold
- Early pylons allow unrestricted building to teach the core loop clearly
- Essence holder destruction only removes unbanked generated essence
- Failure resets the pylon loop and auto-repairs defenses rather than demanding rebuilds

---

## Next Recommended Task
Implement the first pylon channel runtime slice:
- add one essence holder object with health, visuals, and warning feedback
- replace the old cave state machine with milestone and shutdown states
- apply first-free and repeat-gold activation rules on the server