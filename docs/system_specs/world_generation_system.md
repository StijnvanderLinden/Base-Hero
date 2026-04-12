# World Generation System Specification

## Purpose
The World Generation System creates the finite expedition playspace used during gate runs.

It is responsible for:
- generating a bounded terrain area for each expedition
- providing readable hills and occasional mountains
- defining hard world edges
- supporting terrain sampling for placement, spawning, and movement
- staying deterministic enough for multiplayer synchronization

---

## Design Goals
- keep each expedition readable in 3D co-op
- create variation without becoming a sandbox survival world
- provide enough terrain shape to make pylon placement matter
- keep generated spaces finite and easy to reason about
- support server-authoritative placement and spawn validation

---

## World Shape
Each expedition generates one finite world area.

Rules:
- the world has a fixed center and bounded width and length
- the playable area is limited by hard boundary blockers
- the terrain is built from a heightmap mesh
- the gate floor is hidden while the generated world is active

This is not an infinite terrain system.

---

## Terrain Rules
The first terrain slice uses layered noise.

Target shape:
- mostly gentle rolling hills
- occasional steeper mountain regions
- enough flatter pockets for pylon placement
- no extreme vertical chaos that hurts combat readability

Terrain generation provides:
- render mesh
- collision
- sampled height queries for runtime systems

---

## Determinism And Sync
The host generates the world seed and remains authoritative.

Authority rules:
- the server decides the active world seed
- clients receive synchronized world state
- pylon placement and spawn logic must validate against the generated terrain on the server

The generated world should stay transport-independent and not depend on one networking backend.

---

## Bounds
The world is intentionally finite.

Bounds rules:
- the terrain stays inside a fixed rectangular world area
- hard blockers stop players and enemies from leaving the playspace
- pylon placement cannot happen too close to the outer boundary
- spawn selection must stay inside bounds

---

## Runtime Helpers
The world generation system must expose helpers for:
- checking whether a point is within world bounds
- sampling terrain height
- projecting points onto terrain
- validating pylon placement slope and clearance
- creating and maintaining a pylon build zone
- providing enemy spawn positions outside the build zone

---

## Early Prototype Scope
The first world generation slice includes:
- one generated terrain mesh per expedition
- one synchronized world seed per run
- one bounded world size
- one build zone tied to the placed pylon
- terrain-aware pylon placement and enemy spawn support

Do not include yet:
- biome-specific terrain rules
- caves or underground layers
- POI generation logic
- destructible terrain
- path-carving systems
