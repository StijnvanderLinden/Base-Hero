# Structure System Tracker

## Current Status
Stone Age Structure Slice Implemented

## Current Design Summary
The current structure slice keeps the existing two-slot build flow while the active era defines which wall and turret variants are live.

Stone Age currently supports:
- Wooden Wall
- Reinforced Wall unlock
- Thrower Turret
- Improved Thrower unlock

## Implemented
- era-driven wall and turret scene selection exists
- era-driven structure cost definitions exist
- Wooden Wall is the live starter wall
- Reinforced Wall is unlocked through Stone Age research
- Thrower Turret is the live starter turret
- Improved Thrower is unlocked through Stone Age research
- gate build placement still runs through the existing server-authoritative validation path

## In Progress
- tuning Stone Age material costs
- tuning upgraded structure stat values
- validating readability of upgraded variants during gate pressure

## Blockers / Problems
- spike trap is not implemented yet
- structure repair still uses the older scrap-side repair path
- there is not yet a dedicated structure-upgrade presentation layer beyond research unlocks

## Must Have
- simple wall progression
- simple turret progression
- server-authoritative placement
- readable upgrade path in the first era

## Should Have
- clearer upgraded-structure presentation
- per-era support structures later
- tighter structure-repair alignment with era materials later

## Could Have
- spike trap later
- trap families later
- more turret archetypes per era later

## Won’t Have (for now)
- deep structure tech trees
- large catalog breadth in Era 1
- complex support-structure dependency chains

## Open Questions
- should later eras replace existing wall/turret families or add branches beside them?
- should structure repair migrate fully off scrap in a later refactor?
- when should traps enter the live structure set?

## Recent Decisions
- the first era keeps the existing two-button build flow
- upgraded wall and turret variants are unlocked through research rather than a larger build menu
- Stone Age structure complexity stays deliberately low

## Next Recommended Task
Playtest Stone Age wall and turret pacing under the four-wave pylon channel and adjust costs and health values from real runtime results.