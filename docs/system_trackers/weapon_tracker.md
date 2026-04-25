# Weapon System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Weapon System.

---

## Current Status
Melee / Ranged MVP Slice Started

---

## Current Design Summary
The vertical slice needs two simple weapon modes so the player can actively defend the base at close range or distance.

Weapon families, material slots, and deep weapon evolution are backlog.

---

## Implemented
- Basic player attack foundation exists
- A prototype ranged weapon slice may exist in runtime
- Melee mode exists as a horizontal arc slash
- Ranged mode uses the existing projectile attack
- Players can switch modes with a keybind

---

## In Progress
- Tuning melee feel for arena survival

---

## Blockers / Problems
- Weapon complexity can distract from validating the turret/base loop

---

## Must Have
- Melee primary arc slash
- Ranged projectile attack
- Weapon switch input
- Server-authoritative damage
- Clear hit feedback

---

## Should Have
- Optional basic hub weapon upgrade if needed

---

## Could Have
- A second attack only after the first attack and turret loop feel good

---

## Won't Have (for now)
- Multiple weapon families
- Material slots
- Weapon crafting
- Deep augment sockets

---

## Open Questions
- Does melee feel satisfying enough to carry the action loop?
- Does the MVP need a player weapon upgrade, or are turret/base upgrades enough?

---

## Recent Decisions
- Weapon scope is reduced to two simple modes for MVP: melee and ranged

---

## Next Recommended Task
Playtest melee slash timing, range, arc, and feedback against early enemy waves.
