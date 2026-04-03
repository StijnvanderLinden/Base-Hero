# Raid System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Raid System.

---

## Current Status
Design Confirmed, Not Implemented

---

## Current Design Summary
Raids are intentional major defense events triggered by starting a town hall upgrade.

Current confirmed direction:
- raids are not automatic
- raids only begin through town hall upgrade channeling
- raids are the main progression checkpoints
- success completes the upgrade and unlocks a new tier
- failure damages the base but does not remove gathered materials

---

## Implemented
- No dedicated raid system is implemented yet
- The project has a basic defense loop that can serve as a foundation for raids
- The main base, combat, enemy pressure, and structures already exist as prerequisites

---

## In Progress
- Defining the first town hall upgrade trigger flow
- Defining the smallest successful first raid prototype

---

## Blockers / Problems
- No town hall upgrade system exists yet
- No raid-specific state machine exists yet
- No construct-only raid composition exists yet
- Raid success and failure resolution are not implemented yet

---

## Must Have
- Town hall upgrade trigger
- Player-triggered raid start
- Construct raid wave package
- Clear success and failure resolution
- Upgrade completion only on success

---

## Should Have
- Better raid messaging and readability
- Distinct raid pacing from normal defense testing
- Base damage and rebuild consequences
- Tier unlock feedback

---

## Could Have
- Multi-phase raids
- Elite-led raid pushes
- Raid-specific bosses
- Special raid mutators
- Tier-specific raid compositions

---

## Won’t Have (for now)
- Fully automatic raid scheduling
- Deep narrative raid event chains
- Many raid objective types at once
- Complex raid preparation UI before the first loop works

---

## Open Questions
- What is the minimum town hall interaction needed for the first prototype?
- How long should the first raid last?
- How much rebuilding burden should failure create?
- When should siege and elite construct roles enter the raid lineup?

---

## Next Recommended Task
Implement the first raid slice:
- add a town hall upgrade trigger
- start one construct raid package from that trigger
- resolve success by completing the upgrade
- resolve failure by stopping the upgrade and leaving the base damaged