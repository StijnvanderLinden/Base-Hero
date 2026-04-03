# Raid System Specification

## Purpose
The Raid System defines the major base-defense events that act as intentional progression checkpoints.

Raids are the main test of player preparation, base strength, and team coordination.

---

## Design Goals
- Make raids player-triggered rather than automatic
- Use raids as the main progression checkpoint for town hall growth
- Test both combat strength and base construction
- Keep failure meaningful without making it overly punishing
- Preserve the main base as the emotional center of the game

---

## Core Rule
Raids do not happen automatically.

Raids only happen when players start upgrading the town hall.

This makes raids intentional progression checkpoints rather than background timers.

---

## Town Hall Upgrade Flow
1. Players gather required materials from gates
2. Players begin a town hall upgrade through a channeling or activation process
3. Starting the upgrade triggers a major raid
4. Players defend the base during the raid
5. If successful, the town hall upgrade completes and a new tech tier unlocks
6. If failed, the upgrade does not complete and players must rebuild and retry later

---

## Design Intent
Raids should be:
- intentional
- high-pressure
- a main test of power
- the moment where previous upgrades are validated

Players should choose when they are ready to trigger the next raid.

---

## Enemy Rule
Raids use engineered construct enemies.

Raid forces should feel:
- organized
- escalating
- built for assaulting defenses
- more structured than exploration enemies

---

## Success State
A successful raid should:
- complete the active town hall upgrade
- unlock the next progression tier
- preserve the base as the center of advancement
- create a strong sense of earned momentum

---

## Failure State
Raid failure should:
- stop the upgrade from completing
- damage the base
- allow structures to be destroyed
- require rebuilding and retrying
- preserve gathered materials from gate expeditions

Failure should be painful, but not catastrophic.

---

## Pressure Structure
Raids should scale through:
- stronger enemy compositions
- construct role variety
- larger assault waves
- stronger wall-breaking and siege threats
- elite units later

The goal is to test preparedness, not just overwhelm through raw numbers alone.

---

## Co-op Considerations
Raids must work cleanly in co-op.

Requirements:
- shared objective state
- synchronized raid phase state
- readable threat roles in large encounters
- clear win and loss resolution

Authority rule:
- raid start, enemy spawning, objective health, and outcome are server-authoritative

---

## Early Prototype Direction
The first raid prototype should include:
- one player-triggered raid start tied to a town hall upgrade action
- one heavier construct wave package than normal defense testing
- clear raid success and failure resolution
- town hall upgrade completion on success only

---

## Future Extensions
Possible future additions:
- multi-phase raids
- elite-led raid waves
- siege patterns based on town hall tier
- raid-specific boss encounters
- stronger rebuild and repair loops