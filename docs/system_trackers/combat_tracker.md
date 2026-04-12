# Combat System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Combat System.

---

## Current Status
Ranged Prototype Started

---

## Current Design Summary
Combat is active, player-driven, and works alongside base defense. Players fight directly, respond to threats, and eventually shape playstyle through weapons and augments.

The combat system should be:
- readable
- responsive
- impactful
- scalable in co-op

---

## Implemented
- One basic player rifle-style projectile attack on the prototype input stack
- Server-authoritative attack requests and damage resolution
- Enemy health and death handling wired into combat flow
- Player and enemy overhead health bars for readability
- Player and core hit flash feedback for clearer incoming damage
- Turrets now use server-owned projectile bullets instead of instant hits
- Player projectiles are now spawned authoritatively and replicated to clients
- Player attacks now show synchronized muzzle-flash feedback

---

## In Progress
- Clarifying how strongly combat vs structures should carry defense moments
- Defining the first proper weapon presentation beyond the prototype flash feedback
- Tuning the first rifle-style projectile feel for gates and raids
- Evaluating whether turret bullets are readable enough in larger waves

---

## Blockers / Problems

- No weapon-specific animation or presentation layer yet
- Combat is functional but still very placeholder in feel
- There is still no audio or enemy-side impact effect beyond hit flash

---

## Must Have
- One basic weapon
- One attack type
- Server-authoritative damage
- Enemy death handling
- Basic hit feedback
- Clear relation between combat and objective defense

---

## Should Have
- One or two distinct weapon archetypes
- Early augment hooks in code structure
- Better hit feedback
- Basic elite target-priority support
- Distinct combat role during gates vs raids

---

## Could Have
- Temporary run-based augments
- support weapon/tool
- status effects
- melee/ranged combo interactions
- simple active ability

---

## Won’t Have (for now)
- deep combo systems
- large augment trees
- complex ammo economy
- elaborate status stacking
- class system

---

## Open Questions
- What is the first weapon: rifle, shotgun, sword, or something else?
- Should the first prototype use projectiles or hitscan?
- How much mobility should be built into combat early?
- How much of the fun should come from augments versus base weapon feel?
- Should combat include repair/support actions later?

---

## Recent Decisions
- Combat should support defenses, not replace them
- Players should feel active and important during major pressure moments
- The system should stay simple at first and expand later through augments
- The first combat prototype can stay minimal as long as server authority and readability are correct
- The first durable weapon test now pivots toward a rifle-style projectile instead of melee

---

## Next Recommended Task
Improve combat feedback and clarity:
- tune rifle projectile speed, range, and cadence during gate and raid pressure
- add enemy-side impact feedback tied to player attacks
- decide whether this first ranged slice should stay projectile-based or move to hitscan later
- confirm combat supports defending the core instead of replacing it