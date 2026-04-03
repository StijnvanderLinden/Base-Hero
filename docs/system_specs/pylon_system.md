# Pylon System Specification

## Purpose
The Pylon System defines foothold objectives inside gates, their activation behavior, their damaged state, and the repair loop that restores local control.

Pylons are the anchor point between overworld defense and cave expeditions.

---

## Design Goals
- Make pylons the key controllable gate objective
- Reuse existing defenses around pylons rather than creating a separate cave build loop
- Make failure meaningful through loss of safety and control
- Make recovery a gameplay event rather than a simple reset button
- Keep the system readable in co-op

---

## Core Role
A pylon is a local foothold.

A functional pylon provides:
- local control
- an area where defenses can matter
- access to cave expeditions
- a recovery anchor if the area is lost later

---

## Pylon States

### Uncaptured
- hostile or neutral
- not safe
- cave expedition cannot be activated
- local defenses are not part of the player foothold yet

### Functional
- captured and under player control
- cave expedition can be activated
- nearby defenses are active
- safe-zone effects may apply

### Damaged
- expedition failure consequence state
- defenses are inactive
- turrets do not function
- safe-zone effects are disabled
- the area becomes hostile again until repaired

---

## Capture Flow
Players capture a pylon by channeling at it.

Capture flow:
1. start channeling
2. trigger a defense event
3. survive construct enemy pressure
4. complete the capture
5. unlock local foothold benefits

Failure during capture does not permanently remove the pylon.
Players can regroup and try again later.

---

## Cave Activation Flow
Only a functional pylon can activate a cave expedition.

Activation flow:
1. spend the required resource at the pylon
2. begin channeling
3. remove the magical barrier blocking the cave entrance
4. activate the cave expedition state
5. begin external enemy pressure on the pylon

The cave is not found randomly.
It is intentionally activated from the pylon.

---

## Defense Interaction
Pylon defenses are reused for cave expeditions.

Core rule:
- players do not build a new defense setup inside the cave
- players rely on the existing defenses already placed around the pylon

This means cave activation is a commitment to defend the foothold that already exists.

---

## Damaged State Consequences
When a pylon becomes damaged:
- all linked defenses become inactive
- turrets stop functioning
- safe-zone effects are disabled
- the area is no longer under reliable player control

This is intended to feel like a meaningful setback without erasing the player’s broader progress.

---

## Repair System
Damaged pylons can be restored through repair.

Repair rules:
- requires a modest resource cost
- requires time spent repairing at the pylon
- draws enemy attention during the repair event
- must not be overly slow or overly expensive

During repair:
- enemies attack the player
- the player must defend manually
- inactive defenses do not automatically carry the event

On success:
- the pylon returns to functional state
- defenses become active again
- safe-zone benefits return
- cave activation becomes available again

---

## Failure Design Intent
Failure at a pylon should punish through:
- loss of control
- loss of a safe local foothold
- interrupted cave progress
- recovery effort under pressure

Failure should not punish through:
- major inventory loss
- rebuilding every defense from scratch
- excessive reset friction

---

## Co-op Considerations
Pylon state must be clear to all players.

Requirements:
- visible state readability for uncaptured, functional, and damaged pylons
- synchronized activation and repair state
- clear communication of active or inactive defenses
- readable enemy pressure during repair and expedition states

Authority rule:
- pylon state, activation, damage, repair, and defense activation are server-authoritative

---

## Early Prototype Direction
The first pylon milestone should prove:
- one captured state
- one damaged state
- one cave activation flow
- one repair event under enemy pressure
- one simple defense-active versus defense-inactive rule set

---

## Future Extensions
Possible future additions:
- pylon-specific upgrades
- stronger safe-zone benefits
- different pylon archetypes
- multiple cave branches tied to the same pylon
- pylon-linked fast travel improvements