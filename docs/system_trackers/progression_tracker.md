# Progression System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Progression System.

---

## Current Status
Refocused On Simple Essence-Based Hub Unlocks

---

## Current Design Summary
Progression for the vertical slice is intentionally small.

Players earn essence from runs, then spend it in the hub to unlock:
- turret types
- turret upgrade branches
- base capacity
- optional basic player weapon upgrades

The goal is not depth yet. The goal is to make the next run feel stronger and more promising.

---

## Implemented
- Gate rewards already feed back into base-side progression in a basic runtime form
- Core upgrade and research scaffolding exists and may be simplified
- Era-driven research definitions exist at runtime

---

## In Progress
- Simplifying progression from broader research/material plans into essence-based hub unlocks
- Identifying which existing unlocks best support the first turret-focused loop

---

## Blockers / Problems
- Existing progression docs and runtime may still reference crystals, material essence, pylon rewards, or broader trees
- Hub unlocks are not yet focused around turret branches and base capacity
- Essence retention on base destruction is not yet implemented as the vertical-slice failure rule

---

## Must Have
- Essence earned from survival duration
- Essence scaled by milestone progress
- About 70% essence kept when the base is destroyed
- Simple hub spending
- At least one turret upgrade branch unlock
- At least one base capacity unlock or turret type unlock

---

## Should Have
- Locked branches visible but unavailable during runs
- Clear next-unlock costs
- Fast first unlock pacing
- Optional simple player weapon upgrade if turret-only progression does not sell the fantasy

---

## Could Have
- Multiple turret branches after the first loop works
- Small permanent player survivability upgrade
- Milestone first-clear bonuses

---

## Won't Have (for now)
- Deep research trees
- Material-specific trees
- Special material gates
- Multiple eras worth of progression
- Complex augment webs
- Long grind loops

---

## Open Questions
- What is the first unlock that most clearly makes the next run feel better?
- How many runs should the first hub unlock take?
- Should base capacity or turret type unlock come first?

---

## Recent Decisions
- Essence is the only between-run progression resource for the MVP
- Hub unlocks should be simple and directly improve the next run
- Deep progression is deferred until the one-more-run loop is fun

---

## Next Recommended Task
Define the first three essence unlocks and connect at least one to an in-run turret upgrade branch.
