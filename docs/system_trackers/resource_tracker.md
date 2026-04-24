# Resource System Tracker

## Current Status
Scrap Kill Reward Slice Started

## Current Design Summary
The vertical slice uses two resources:

- scrap: earned during a run from wave enemy kills and spent during that same run
- essence: earned from survival and milestones, then spent in the hub between runs

Gold, materials, crystals, herbs, and complex resource families are backlog.

## Implemented
- Some older resource collection and reward foundations exist
- Existing progression resources may be repurposed into essence if that is the simplest path
- Wave enemies now award server-authoritative scrap on death during gate pressure
- Scrap reward amounts vary by enemy kind, with a small wave-index bonus

## In Progress
- Connecting scrap income to turret upgrade spending
- Simplifying resource direction around scrap and essence

## Blockers / Problems
- Runtime may still expose older iron, crystal, pylon, or material assumptions
- Essence is not yet clearly generated from survival duration and milestones

## Must Have
- Server-authoritative scrap total during a run
- Scrap awarded automatically on enemy death
- Scrap not stored between runs
- Scrap spent on turret upgrades or limited extra turrets
- Server-authoritative essence reward total
- Essence generated from survival duration and milestones
- About 70% essence kept when the base is destroyed

## Should Have
- Clear UI for current scrap
- Clear UI for earned essence
- Clear feedback when scrap is spent
- Clear run-end reward summary

## Could Have
- Bonus essence for reaching later milestone bands
- Small essence streak or first-time milestone bonus after the base loop is fun

## Won't Have (for now)
- Gold
- Iron, wood, herbs, crystals, or other material economies
- Manual resource pickup
- Crafting webs
- Multiple resource families

## Open Questions
- What scrap income rate makes turret upgrades feel necessary but not spammy?
- What essence payout makes failed runs motivating without becoming grindy?
- Should scrap be team-shared in co-op for the MVP?

## Recent Decisions
- Scrap is the only in-run resource for the vertical slice
- Essence is the only between-run progression resource for the vertical slice
- Manual pickup and additional materials are deferred

## Next Recommended Task
Playtest scrap income against the first turret upgrade cost, then tune rewards and costs until the upgrade arrives during pressure.
