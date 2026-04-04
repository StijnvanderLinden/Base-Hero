# Cave System Specification

## Purpose
The Cave System defines the interior expedition layer activated from captured pylons.

Caves are where the main rewards of a pylon expedition are earned.

---

## Design Goals
- Make caves an intentional extension of captured pylons
- Create a pressure split between defending outside and exploring inside
- Make deeper exploration more rewarding than staying outside
- Use failure and forced exit to create tension without inventory punishment
- Keep cave expeditions readable in co-op

---

## Core Role
A cave expedition begins from a captured pylon and represents the interior reward path linked to that foothold.

The cave is where players:
- explore deeper into a hostile interior space
- find rarer materials and better rewards
- face stronger encounters as they descend
- decide how much risk to take versus returning to defend outside

---

## Activation
A cave is activated from a captured pylon.

Activation flow:
1. claim the pylon first
2. interact again at the pylon to begin the cave channel
3. open the magical barrier at the cave entrance while the channel remains active
4. keep the cave open for as long as the team can hold the outside pressure
5. interact again to stop the channel and close the barrier

The cave is not randomly discovered as a separate event.
It is opened deliberately through the pylon.

---

## Outside Versus Inside Gameplay

### Outside The Cave
While the cave is active:
- enemies continuously attack the pylon or linked expedition core
- existing defenses around the pylon fight automatically if the pylon is functional
- the player may stay outside and defend manually
- enemy pressure should keep ramping while the cave stays open

### Inside The Cave
While the cave is active:
- the player explores deeper into the cave
- enemies, resources, and rewards escalate by depth
- progression toward major rewards happens inside, not outside

The core tension is balancing outside defense with inside exploration.

---

## Resource System

### Passive Gain
While the cave is active:
- the pylon generates a small amount of resources over time

This passive gain exists to reward holding the foothold, but it is not the primary reward source.

### Primary Rewards
The primary rewards come from:
- deeper exploration
- rare materials
- final rewards such as boss drops, chests, or equivalent payoff points

Design rule:
- passive gain must never outperform exploration rewards
- players should be pushed deeper instead of rewarded for waiting outside

---

## Failure Behavior
Failure occurs when the pylon or linked expedition core is destroyed during an active cave expedition.

On failure:
- the cave collapses
- the barrier closes immediately
- the linked pylon becomes damaged

Players retain all collected loot and resources.
The punishment is loss of safety and area control, not inventory loss.

---

## Exit Behavior
Cave expeditions should support deliberate exit behavior in addition to forced failure exit.

Expected exit directions:
- return voluntarily after pushing deep enough
- leave to help defend the outside pressure
- be forcibly removed if the expedition fails

Exit behavior should preserve clarity about whether the pylon remained functional or became damaged.

---

## Defense Relationship
Caves do not have a separate inside defense-building phase.

Core rule:
- the player uses the defenses already placed around the pylon outside
- no new defense setup is created inside the cave for the expedition itself

This keeps the system focused on pressure balancing rather than doubling the build loop.

---

## Repair Relationship
If a cave expedition fails and damages the pylon:
- the cave cannot be safely reactivated immediately
- the pylon must be repaired first
- repair happens under enemy pressure and without the help of active defenses

This creates a recovery gameplay loop after failure.

---

## Co-op Considerations
Cave expeditions must remain readable in co-op.

Requirements:
- clear expedition active state
- clear outside-pressure feedback
- readable forced-exit behavior on failure
- synchronized pylon and cave state across all players

Authority rule:
- cave activation, collapse, reward state, forced exit, and failure are server-authoritative

---

## Early Prototype Direction
The first cave milestone should prove:
- one cave entrance activated from a pylon
- one clear sustained cave-open pressure loop outside the pylon
- one passive resource gain rule
- readable cave-open versus cave-closed world presentation
- one failure behavior where the cave closes when the pylon falls

---

## Future Extensions
Possible future additions:
- deeper branching caves
- cave-specific bosses
- biome-specific cave hazards
- multiple reward endpoints
- cave shortcuts unlocked over time