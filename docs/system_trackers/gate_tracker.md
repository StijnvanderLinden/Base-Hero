# Gate System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Gate System.

---

## Current Status
Refocused On First Arena Gate Run

---

## Current Design Summary
The current gate is a small vertical-slice arena.

It should prove:
- quick entry from the hub
- one central base/core
- continuous enemy waves
- escalating milestone pressure
- scrap from enemy kills
- in-run turret upgrades
- essence rewards for repeat progression

Persistent biome regions, pylons, caves, POIs, roaming exploration, and deep map progression are backlog.

---

## Implemented
- First gate prototype exists in the shared multiplayer scene
- Server-authoritative enemy spawning foundations exist
- Core objective and failure foundations exist
- Some older gate/pylon runtime surfaces still exist and may be repurposed or removed

---

## In Progress
- Aligning runtime language and behavior with the arena survival MVP
- Replacing pylon/exploration assumptions with wave, milestone, scrap, and essence assumptions

---

## Blockers / Problems
- Current runtime and docs may still contain pylon-era assumptions
- The gate is not yet a clean small arena MVP
- Milestone pressure bands are not fully implemented
- Scrap and essence are not yet the clear gate reward contract

---

## Must Have
- One small gate arena
- One central base/core
- Server-authoritative enemy waves
- Early pressure
- Five milestone pressure bands
- Base destruction ends the run
- Return to hub after run end

---

## Should Have
- Clear milestone UI feedback
- Readable spawn lanes
- Fast restart into another run
- Co-op-safe pressure scaling

---

## Could Have
- Manual extraction or run exit after the base-destruction loop is fun
- Arena variants after the first arena is worth replaying

---

## Won't Have (for now)
- Persistent gate worlds
- Pylons as the main loop
- POIs
- Caves
- Deep roaming exploration
- Fog-of-war reveal
- Large biome progression

---

## Open Questions
- How long should the first successful survival run last?
- How quickly should milestones arrive?
- Should manual extraction exist in the MVP or wait until base-failure repeat flow feels good?

---

## Recent Decisions
- The first gate is an arena survival run, not a persistent exploration region
- Scrap and essence replace broader material and pylon reward complexity for the MVP
- Exploration systems are deferred until the survival-defense loop is fun

---

## Next Recommended Task
Turn the live gate prototype into a clean arena run:
- start pressure quickly
- show milestone progress
- end cleanly on base destruction
- return to hub with earned essence
