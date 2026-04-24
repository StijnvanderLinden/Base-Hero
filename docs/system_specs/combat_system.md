# Combat System Specification

## Purpose
The Combat System lets players actively defend the base during the vertical-slice gate run.

Combat must make players feel necessary beside turrets.

---

## MVP Goals
- one primary player attack
- server-authoritative damage
- readable enemy hit and death feedback
- generous hit validation
- player death with delayed respawn at the base
- enough combat feel that survival is active, not passive tower defense

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
Do not build many weapon families, deep augment systems, class roles, or complex ability kits until the core loop is fun.
