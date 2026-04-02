# Gate System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Gate System.

---

## Current Status
First Prototype Implemented

---

## Current Design Summary
Gates are instanced, high-risk missions that players repeatedly enter for rewards that support the main base.

Current likely direction:
- procedural or semi-procedural gate maps
- a defendable temporary objective at the center
- enemy pressure increases over time
- players move outward for higher-value rewards
- extraction is a core tension mechanic
- gates should feel different from main raids

---

## Implemented
- First gate mode prototype in the shared multiplayer scene
- Temporary defendable drill objective for gate runs
- One passive scrap reward plus one external scrap cache away from the safe center
- Extraction zone with countdown and success/failure return flow back to base
- Gate runs now reuse the shared enemy pressure loop against a temporary objective
- High-level gate concept documented
- Resource direction discussed at a design level

---

## In Progress
- Deciding final gate structure direction
- Deciding exact relationship between survival, exploration, and milestone rewards
- Defining what rewards players seek in gates beyond the first scrap prototype

---

## Blockers / Problems
- Persistent progression inside gate worlds is not finalized
- Exact failure penalty is not finalized
- Exact balance between central defense and exploration is not finalized
- Difference between gates and main raids must stay clear
- Gate building permissions inside runs are not defined yet

---

## Must Have
- Instanced gate mission structure
- Temporary objective to defend
- Time-based or pressure-based escalation
- Extraction countdown
- One reliable core resource
- Clear success/failure flow
- Clear reason to leave the safe center temporarily

---

## Should Have
- Milestone reward system
- Rare materials from side objectives or exploration
- Components for structures and traps
- Distinct biome identity
- Optional elite or mini-boss pressure
- Better difference from main raid gameplay

---

## Could Have
- Procedural gate-world persistence
- Revisit-able gate regions with saved progress
- Unlockable starting threshold/milestone choice
- Local gate progression state
- Gate-specific mutators
- Special environmental events

---

## Won’t Have (for now)
- Full open-world gate sandbox
- Deep procedural simulation
- Large narrative gate event chains
- Multiple major objective types at once
- Complex economy with too many resource types

---

## Open Questions
- Are gates primarily survival arenas, exploration spaces, or a hybrid?
- How much progression inside a gate world should persist?
- Does the player begin with a small base kit in gates?
- Is milestone progress tied to time, kills, generated resources, or all three?
- Should failed extraction lose everything or only some rewards?
- Should players be able to choose a previously reached milestone tier as a starting point?

---

## Recent Decisions
- Gates should not feel too similar to main raids
- Gates likely need both defense and outward risk-taking
- Reward structure should include a main progression currency plus rarer special materials/components
- The first gate slice should stay in the existing scene and prove the loop before any separate map pipeline is built

---

## Next Recommended Task
Expand the first gate slice:
- decide whether players can build during gates
- add one stronger external reward or side objective
- add a clearer post-run results state
- decide how gate rewards connect into upgrades