# Enemy System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Enemy System.

---

## Current Status
Prototype Implemented

---

## Current Design Summary
Enemies are the main pressure source in the game. They must be readable in groups, role-based, and threatening to both objectives and defenses.

The system should support:
- gates
- main raids
- large battles
- co-op readability

Current role direction:
- melee runner
- tank
- ranged
- flying
- siege
- elite
- boss

---

## Implemented
- Server-spawned basic melee enemy prototype
- Server-authoritative enemy movement replication
- Enemy health, death, and late-join replication
- Enemies now target the shared core objective by default
- Readable overhead enemy health bars
- Enemy hit flash and short death feedback before despawn
- Enemies can attack nearby wall structures before reaching the core

---

## In Progress
- Tuning spawn pressure and enemy count pacing
- Deciding when enemies should switch from objective pressure to player pressure
- Evaluating pathing and readability around the core objective
- Improving enemy presentation beyond placeholder flash/death feedback

---

## Blockers / Problems
- No pathing/navigation solution tested beyond direct pursuit
- No player-count scaling direction finalized
- No performance strategy tested for larger swarms
- No second enemy role validated yet

---

## Must Have
- One basic melee enemy
- Move to an objective
- Damage the objective
- Enemy health and death
- Server-authoritative enemy state

---

## Should Have
- One tank/bruiser enemy
- Clear target-priority moments
- Better wave composition scaling
- Distinct role readability

---

## Could Have
- flying enemy
- ranged enemy
- elite triggers
- biome-specific enemy variants
- siege enemy early tests

---

## Won’t Have (for now)
- many subtle enemy subtypes
- complex behavior trees
- advanced faction interactions
- heavy simulation systems
- too many enemy roles at once

---

## Open Questions
- How often should enemies target players versus structures?
- What is the first useful second enemy type after melee?
- How quickly should composition variety increase?
- How much enemy scaling should come from count vs role mix?
- What is the visual strategy for keeping swarms readable in 3D?

---

## Recent Decisions
- Enemies should reinforce the defense fantasy, not distract from it
- Role clarity matters more than enemy count fantasy early on
- Readability is more important than maximum complexity in the prototype stage
- The first prototype enemy should pressure the core objective before any more advanced target switching is added

---

## Next Recommended Task
Tune and validate the first enemy defense loop:
- confirm core targeting works in multiplayer
- test spawn pacing around the objective
- add stronger death and impact presentation
- decide the first useful second enemy type