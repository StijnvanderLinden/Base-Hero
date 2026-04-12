# Raid System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Raid System.

---

## Current Status
First Prototype Implemented

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
- First town hall upgrade trigger button and channeling flow
- Player-triggered raid start tied to town hall upgrades
- Finite raid wave package at the main base
- Raid success now completes the town hall upgrade level
- Raid failure now interrupts the upgrade without removing gathered materials
- Base enemy pressure is now idle by default outside active raids
- Raids now use a first dedicated construct swarm unit rather than the generic exploration enemy
- Raids now mix in a first heavy construct breaker role on later waves to increase structure pressure

---

## In Progress
- Validating raid pacing and wave counts in multiplayer sessions
- Tuning the swarm-to-breaker mix so later raid waves stay readable

---

## Blockers / Problems
- Town hall upgrades currently use scrap only as the placeholder required material
- Raid messaging and consequences are still minimal

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
Validate and extend the first raid slice:
- test the raid trigger and no-idle-spawn rule in multiplayer sessions
- validate breaker pacing and building pressure in multiplayer sessions
- improve raid messaging and base-damage consequences
- add a more explicit town hall upgrade presentation when useful