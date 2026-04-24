# Core System Specification

## Purpose
The Core System defines the central base objective for the vertical slice.

The core is the thing players defend. If it is destroyed, the run ends immediately.

---

## MVP Role
The core should:
- sit at the center of the starter base
- have server-authoritative health
- receive damage from enemies
- communicate danger clearly
- end the run when destroyed
- anchor player respawn after death

---

## Failure Rule
When the core/base is destroyed:
- the run ends immediately
- players return to the hub or run-end summary
- players keep about 70% of earned essence

---

## Authority Rule
The server decides:
- core health
- incoming damage
- destruction state
- run failure
- essence retained on failure

---

## Deferred
Do not use the core for deep research trees, material storage, pylon conversion, or multi-resource management in the vertical slice.
