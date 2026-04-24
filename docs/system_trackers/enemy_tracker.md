# Enemy System Tracker

## Current Status
Refocused On Wave Pressure

## Current Design Summary
Enemies exist to pressure the central base/core during the arena run.

The MVP needs:
- one basic melee enemy
- one heavier pressure enemy
- server-authoritative spawning, damage, death, and scrap awards
- milestone scaling

## Implemented
- Basic enemy spawning and movement foundations exist
- Enemy health and death foundations exist
- Gate-pressure enemy deaths now notify the enemy manager and award scrap through the gate manager

## In Progress
- Aligning enemy pressure with the new milestone survival loop

## Blockers / Problems
- Old enemy docs and code may reference exploration, pylons, or raids

## Must Have
- Early wave pressure
- Enemy attacks against base/core
- Scrap awarded on death
- Milestone-based pressure increases

## Should Have
- Readable enemy silhouettes
- Clear stronger-enemy introduction

## Could Have
- One additional pressure unit after the first loop feels good

## Won't Have (for now)
- Complex enemy variants
- Biome enemy families
- Raid-only enemy families
- Bosses
- Flying or ranged squads

## Open Questions
- How soon should the heavy enemy appear?
- How much scrap should each enemy grant?

## Recent Decisions
- Enemy scope is reduced to wave pressure for the MVP

## Next Recommended Task
Tune the first two enemy types around early pressure, time-to-kill, and scrap income.
