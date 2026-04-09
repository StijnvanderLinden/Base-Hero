# Pylon System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Pylon System.

---

## Current Status
Design Refactor Confirmed, Material Ritual Refactor Needed

---

## Current Design Summary
Pylons are foothold objectives inside gates and the center of the repeatable channeling loop.

Current confirmed direction:
- pylons have uncaptured, functional, channeling, and shutdown states
- every pylon is tied to one specific material type
- channeling costs only the matching material for that pylon
- gold remains for building structures and does not start channels
- early pylons allow any building type around the foothold
- existing nearby defenses are reused across repeated channel attempts
- each pylon has one fixed base modifier that is active on every channel run there
- repeated full clears on a pylon add shared global modifiers in a fixed order for later runs on that same pylon
- the first successful clear on a pylon uses only its base modifier as the learning run
- modifier escalation caps at one base modifier plus three global modifiers
- generated matching material essence is stored in a physical holder object during active runs
- milestone rewards are always safe while generated matching material essence remains vulnerable
- failure resets the pylon loop without forcing structure rebuilds
- later pylon variants may apply debuffs such as build restrictions, no heal or repair rules, or heavier elite pressure

---

## Implemented
- Pylons exist as a documented gate objective direction
- Limited building around pylons is part of the current gate direction
- First runtime pylon foothold now exists in the gate prototype
- Pylons now begin uncaptured and are manually claimed by starting a claim channel at the pylon
- Claim completion now depends on clearing finite construct waves rather than waiting out a timer alone
- Pylon-specific modifier direction is now documented as a fixed-base plus shared-global system
- Material-specific ritual activation and conversion are now documented as the current pylon direction

---

## In Progress
- Replacing the old cave-facing activation flow with the finalized channeling loop
- Defining the first material essence holder behavior and milestone thresholds
- Defining the first shutdown sequence and failure reset behavior
- Defining how each pylon stores completion count and applies the correct modifier stage on later channel runs
- Defining the first pylon material mapping and ritual activation costs

---

## Blockers / Problems
- Current runtime still reflects older cave-oriented pylon behavior and naming
- Material essence holder visuals, warning feedback, and loss rules are not implemented yet
- Shutdown behavior is not implemented yet
- The runtime does not yet validate matching material costs to start channels
- The runtime does not yet track per-pylon completion state for modifier escalation
- No first-pass base modifier set or shared global sequence has been implemented yet
- Exploration materials are not yet linked to pylon activation or conversion outcomes

---

## Must Have
- Captured or functional pylon state
- Repeatable channel activation from a pylon
- Fixed material identity per pylon
- Matching material ritual cost for channel starts
- One fixed base modifier per pylon
- Shared global modifier order used by all pylons
- Per-pylon modifier progression capped at three global modifiers
- Material essence holder risk object
- Milestone rewards with safe banking
- Shutdown phase
- Defense reuse without rebuild friction

---

## Should Have
- Clear pylon-state readability in world presentation
- Safe-zone benefits linked to pylon state
- Better feedback for holder threat and milestone completion
- Travel unlock behavior tied to pylon state
- Clear communication of pylon material type and ritual cost before a run starts
- Clear communication of active base and global modifiers before a run starts
- Modifier combinations that create distinct tactical identities without overcomplicating the event

---

## Could Have
- Pylon-specific upgrades
- Different pylon archetypes
- Stronger pylon area buffs
- Biome-specific channel modifiers
- Specific base modifier families such as walls-only, turrets-only, or traps-only rule sets
- Material-specific presentation differences between pylon families

---

## Won’t Have (for now)
- Deep pylon upgrade trees
- Many different pylon objective types at once
- Large UI-heavy management layers for pylons early on
- Permanent pylon loss on failure
- Gold-funded channel activation

---

## Open Questions
- What is the first material-cost curve for channel starts across early pylons?
- How visible should holder danger be from a distance?
- How much durability should the holder have relative to pylon defenses?
- When should older pylon efficiency drop enough to push players toward deeper ones?
- Which first base modifiers are readable enough to anchor the initial pylon set?
- What data structure should own per-pylon completion counts for multiplayer-safe progression tracking?
- How should pylon material type be surfaced in-world before players commit resources?

---

## Recent Decisions
- Pylon channeling replaces caves as the main gate reward activity
- Every pylon is tied to one specific material type
- Pylon channeling costs only matching material and not gold
- Early pylons allow unrestricted building to teach the core loop clearly
- Material essence holder destruction only removes unbanked generated matching essence
- Failure resets the pylon loop and auto-repairs defenses rather than demanding rebuilds
- Every pylon now has one fixed base modifier
- Shared global modifiers progress in a fixed order and are not chosen manually by players
- Repeated full clears on a pylon increase its modifier stage up to three global modifiers

---

## Next Recommended Task
Implement the first material-aware pylon runtime slice:
- assign one material type to the first test pylon
- validate matching material cost on the authoritative side before channel start
- add per-pylon completion tracking on the server
- define the first shared global modifier sequence with three stages
- convert matching material into matching material essence during channel phases