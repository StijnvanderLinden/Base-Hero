# Research System Tracker

## Current Status
First Core Research Slice Implemented

## Current Design Summary
- research now spends essence and crystals instead of a single generic currency
- basic nodes are essence-only
- advanced nodes use essence plus crystals
- branch unlocks use crystals as the main gate

## Implemented
- authoritative essence and crystal inventory
- synchronized research node state and level data
- first prototype nodes for a basic upgrade, an advanced unlock, and a branch unlock
- base-side UI buttons for research spending

## In Progress
- tuning costs for the first research nodes against expedition output
- deciding whether research should stay global or split by player later

## Blockers / Problems
- there is no save system for research progression yet
- only three prototype nodes exist in the first slice
- the base-side UI is functional but still minimal

## Must Have
- essence-only basic progression
- crystal-gated unlocks
- essence-plus-crystal advanced nodes
- authoritative spending and synchronization

## Should Have
- richer node presentation and clearer descriptions
- additional branch nodes beyond the first augment examples

## Could Have
- per-player research branches later
- prerequisite chains beyond simple resource checks

## Won’t Have (for now)
- a full tech tree editor
- many branch families at once
- hidden or randomized research rolls

## Open Questions
- which first combat or base stats should basic nodes affect directly
- should crystal-gated branch unlocks remain global for the whole team

## Recent Decisions
- crystals gate unlocks rather than upgrades
- essence remains the repeatable upgrade spend
- augment slot and augment branch are the first crystal-facing examples

## Next Recommended Task
Attach concrete gameplay effects to the first research nodes.