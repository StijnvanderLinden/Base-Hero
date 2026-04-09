# Pylon Modifier System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Pylon Modifier System.

---

## Current Status
Design Confirmed, First Runtime Slice Not Started

---

## Current Design Summary
The pylon modifier system now uses one fixed base modifier per pylon plus one shared global modifier sequence used by all pylons.

Current confirmed direction:
- each pylon has one fixed base modifier that is always active on channel runs there
- global modifiers are shared across every pylon and applied in one fixed order
- players do not manually choose modifiers
- modifier progression is tracked per pylon based on successful full clears
- the first successful clear on a pylon uses only its base modifier
- later successful clears unlock up to three global modifiers for future runs on that pylon
- reward quality at full completion increases with modifier count

---

## Implemented
- Modifier system design truth is now documented
- Integration boundaries with the pylon and progression systems are now documented

---

## In Progress
- Defining the first base modifier candidates for initial pylons
- Defining the first three shared global modifiers in escalation order
- Defining the first reward-tier mapping for modifier counts and material families

---

## Blockers / Problems
- No runtime data model exists yet for per-pylon modifier progression
- No first-pass modifier definitions have been committed to implementation
- Reward generation does not yet consume modifier count or modifier stage
- Reward generation does not yet account for pylon material type
- UI and world presentation do not yet communicate active modifier layers

---

## Must Have
- One fixed base modifier per pylon
- One shared global modifier sequence for all pylons
- No manual player modifier selection
- Per-pylon completion tracking for modifier escalation
- Maximum of three global modifiers on top of the base modifier
- Completion reward tiers that scale with active modifier count

---

## Should Have
- Readable pre-run communication of active modifiers
- Modifier definitions that stay understandable in co-op combat
- Reward preview language that explains the benefit of higher modifier tiers
- Authoritative server-side application of modifier stages and reward tiers
- Modifier presentation that can sit beside pylon material identity without clutter

---

## Could Have
- Biome-themed presentation for different base modifier families
- Small audiovisual cues that announce when a new modifier stage has unlocked on a pylon
- Analytics or debug hooks for comparing modifier completion rates during prototype testing

---

## Won’t Have (for now)
- Random modifier drafting
- Player-driven modifier selection menus
- Large procedural modifier pools
- More than three shared global modifiers in the first ladder

---

## Open Questions
- Which first three shared global modifiers best form the learning-to-mastery curve?
- How should modifier stage be surfaced in-world versus in UI?
- Should base modifiers be authored directly on pylons or referenced through a shared data table?
- How should completion reward tiers differ between material essence payouts, special materials, and advanced unlock packages?

---

## Recent Decisions
- Every pylon has one fixed base modifier
- Global modifiers are shared across all pylons
- Players do not choose modifiers manually
- Modifier difficulty increases through repeated successful clears on that same pylon
- The first run uses only the base modifier as onboarding
- Completion rewards scale with modifier count

---

## Next Recommended Task
Implement the first end-to-end modifier test path:
- create one data definition for a pylon base modifier
- create the first three shared global modifiers in fixed order
- store per-pylon completion count on the authoritative side
- drive full-completion reward tier selection from active modifier count and pylon material family