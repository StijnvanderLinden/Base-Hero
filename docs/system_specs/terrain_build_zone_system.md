# Terrain And Build Zone System Specification

## Purpose
This system defines how player-placed pylons create a readable local defense space inside the generated expedition terrain.

It is responsible for:
- validating where a pylon can be placed
- creating a flat build foundation around the pylon
- defining the legal build area for structures during a gate run
- defining the enemy spawn ring outside that build area

---

## Design Goals
- make pylon placement a meaningful commitment
- make gate building predictable under pressure
- avoid awkward structure placement on uneven terrain
- keep the defended area readable in co-op
- give enemy spawns a clear outside-in attack pattern

---

## Pylon Terrain Placement
Pylon placement is terrain-aware.

Rules:
- the pylon must be placed inside generated world bounds
- the terrain around the placement point must be stable enough for a foothold
- the server validates slope and clearance
- one expedition only supports one active placed pylon

The first prototype uses a simple clearance radius and slope test instead of advanced footprint analysis.

---

## Build Zone Foundation
Placing a pylon creates an elevated square foundation platform.

Foundation rules:
- the zone is centered on the pylon
- the buildable interior is a square with a shared raised height
- the platform extends outward into a square enemy approach ring
- the platform then slopes down on all sides to reconnect with the surrounding terrain
- the visible and collidable build surface is flattened to a shared height across the full platform top
- building during the expedition is only legal inside the inner build square
- structure placement projects onto this build surface rather than raw terrain

The purpose of the foundation is consistency, not realism.

---

## Build Placement Rules
During a gate run:
- structures must be placed inside the active inner build square
- snapped XZ placement still applies
- final Y position is projected onto the build surface
- structures on the outer enemy ring or on the slope are invalid even if the raw terrain is clear

At the main base, the existing base-building rules still apply separately.

---

## Enemy Spawn Ring
Enemy attack pressure uses a square spawn ring around the pylon platform.

Rules:
- enemies spawn outside the inner build square
- enemies spawn within configurable minimum and maximum square ring extents
- the square spawn ring sits on the same raised platform top as the build area
- the terrain only slopes back down after the outer edge of the spawn ring
- spawned positions must remain inside world bounds
- spawn positions project to terrain height

This keeps attacks readable and avoids enemies appearing inside the defended footprint.

---

## Readability Rules
The terrain and build zone system should preserve readability.

That means:
- no tiny unusable build pockets
- no large vertical offsets inside the build zone
- no z-fighting or jitter between build-zone visuals and the terrain surface
- no enemy spawns directly on top of the foundation
- no hidden legality rules beyond visible bounds, terrain, and spacing

---

## Early Prototype Scope
The first slice includes:
- elevated square pylon platform generation
- flat platform top with sloped terrain transition on all sides
- gate-only build validation against the inner square build area
- terrain-projected enemy spawn positions in a square outer ring

Do not include yet:
- multiple build sub-zones
- terrain deformation by the player
- dynamic foundation damage
- terrain-specific structure restrictions by biome
