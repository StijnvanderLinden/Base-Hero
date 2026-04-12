# World Generation System Tracker

## Current Status
First Runtime Slice Implemented

## Current Design Summary
- each expedition now generates one finite terrain playspace
- the terrain uses gentle height variation with occasional mountains
- hard world boundaries keep the run contained
- pylon placement validates against terrain slope and world bounds
- placing a pylon creates a flat circular build zone
- enemy spawning can use an outer ring around that pylon zone

## Implemented
- dedicated world generation runtime with synchronized expedition seed state
- finite terrain mesh generation with collision
- boundary blockers around the generated world
- terrain height sampling and projection helpers
- pylon placement validation against bounds and slope
- circular build zone creation with a flat foundation surface
- enemy spawn position sampling outside the build zone
- gate and building runtime hooks for terrain/build-zone-aware placement

## In Progress
- tuning terrain amplitude for combat readability
- tuning build radius versus spawn ring spacing
- verifying multiplayer sync timing for generated-world-dependent local presentation

## Blockers / Problems
- the first terrain slice has no biome-specific variation yet
- resource placement currently uses fixed descriptor layouts projected onto generated terrain
- the generated foundation is functional but still visually placeholder

## Must Have
- finite expedition terrain
- world bounds and blockers
- terrain-aware pylon placement
- pylon-linked build zone creation
- enemy spawn support outside the build zone
- server-authoritative validation for placement and spawning

## Should Have
- stronger visual readability for world edges
- clearer build-zone presentation in moment-to-moment combat
- better tuning for flatter usable terrain pockets

## Could Have
- biome-driven terrain presets
- point-of-interest placement on generated terrain
- more varied boundary treatments by biome

## Won’t Have (for now)
- infinite world generation
- destructible terrain
- fully procedural biome population
- underground terrain layers

## Open Questions
- how large should the first expedition terrain be relative to player count
- how strict should pylon slope validation be before placement feels frustrating
- should later pylons create different build-zone shapes or only larger radii

## Recent Decisions
- expeditions use finite generated terrain rather than a flat temporary floor
- pylon placement creates a flat defense foundation automatically
- gate building is constrained to the pylon build zone during expeditions
- enemy spawn pressure should approach from outside the foundation ring

## Next Recommended Task
Run multiplayer tuning on the first world slice:
- test pylon placement on a range of generated slopes
- verify build-zone readability while under attack
- tune spawn ring distances so enemies enter from readable angles without feeling too distant
