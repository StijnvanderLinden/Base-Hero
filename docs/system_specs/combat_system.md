# Combat System Specification

## Purpose
The Combat System lets players actively defend the base during the vertical-slice gate run.

Combat must make players feel necessary beside turrets.

---

## MVP Goals
- two simple weapon modes: melee and ranged
- keybind weapon switching between melee and ranged
- melee primary attack as a horizontal arc slash
- ranged primary attack as a simple projectile
- server-authoritative damage
- readable enemy hit and death feedback
- generous hit validation
- player death with delayed respawn at the base
- enough combat feel that survival is active, not passive tower defense

---

## Melee Direction
The melee weapon is the first combat-feel priority.

The primary melee hit should:
- be a horizontal arc slash
- hit enemies in front of the player
- feel broad and forgiving
- produce immediate hit feedback
- work well against small groups

This is more important than adding extra systems while combat feels boring.

---

## Ranged Direction
The ranged weapon remains a simple projectile mode.

It exists to:
- let players contribute at distance
- give a clear contrast with melee
- keep the first weapon-switching slice simple

---

## Player Death
If a player dies:
- they respawn at the base after about 20 seconds
- the run continues unless the base/core is destroyed

---

## Authority Rule
The server decides:
- attack validity
- damage
- enemy death
- player death
- respawn timing

Clients request attacks and show presentation.

---

## Deferred
Do not build many weapon families, deep augment systems, class roles, or complex ability kits until the melee/ranged feel is fun.
