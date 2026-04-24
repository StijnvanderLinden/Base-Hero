# Progression System Specification

## Purpose
The Progression System defines how players become stronger between gate runs during the vertical slice.

Current progression is intentionally simple:
- earn essence during a run
- keep most of it even on failure
- spend it in the hub
- enter the next run stronger

---

## Design Goals
- Support the fantasy of "I got stronger in the hub"
- Make failed runs still feel useful
- Keep unlocks obvious and fast enough for iteration
- Improve survival in the next run
- Avoid deep progression complexity before the core loop is fun

---

## Core Progression Loop
1. Start a gate run
2. Survive waves
3. Reach milestone pressure bands
4. Generate essence
5. Lose the base or end the run through the prototype flow
6. Keep earned essence, with about 70% kept on base destruction
7. Spend essence in the hub
8. Unlock options that help the next run

---

## Essence
Essence is the only between-run progression resource for the vertical slice.

Sources:
- survival duration
- milestone progress

Failure rule:
- base destroyed means the run ends
- the player keeps about 70% of earned essence

Essence should make the next attempt feel reachable and exciting.

---

## Hub Unlocks
Essence may unlock:
- turret types
- turret upgrade branches
- base capacity
- optional basic player weapon upgrades

The first unlocks should be small in count but large in feel.

Good first unlock examples:
- unlock a turret burst branch
- unlock an area attack branch
- increase extra turret capacity by one
- unlock a basic player weapon improvement

---

## Locked Upgrade Visibility
Locked branches may be visible during a run but unavailable.

Presentation examples:
- lock icon
- question mark
- disabled upgrade branch

Purpose:
- show players what hub progression can unlock
- create desire for the next run

---

## Player Power Versus Base Power
Progression should preserve a simple strategic tension:
- improve the player
- improve the base

For the vertical slice, base power should be the stronger focus because the loop is built around defending a central objective.

---

## Scope Boundaries
Do define now:
- essence earning
- essence retention on failure
- first hub unlocks
- direct links from hub unlocks to in-run turret decisions

Do not build yet:
- deep research trees
- material-specific trees
- special material requirements
- multiple era progression
- long grind loops
- complex build specializations
