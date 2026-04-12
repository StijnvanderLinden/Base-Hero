# Resource System Tracker

## Current Status
First Expedition Resource Slice Implemented

## Current Design Summary
- iron is the first gathered raw material
- iron fuels pylon channel starts
- crystals are a separate universal progression resource
- resource signals inside pylon influence are counted and highlighted without full map reveal

## Implemented
- authoritative iron collection from expedition resource nodes
- authoritative crystal collection from expedition pickups
- fixed expedition resource placements for iron, herbs, cave entrances, treasure spots, and crystals
- pylon-range counting for crystals remaining in area

## In Progress
- tuning iron distribution against the first pylon channel costs
- deciding which non-iron resource signals become interactive next

## Blockers / Problems
- non-iron signal nodes are reveal targets only in the first slice
- there is no persistence layer beyond the current session

## Must Have
- raw material pickups for channel starts
- finite crystal pickups
- server-authoritative collection
- crystal count remaining in pylon radius

## Should Have
- more distinct marker visuals per resource family
- broader resource spending beyond iron and crystals

## Could Have
- procedural placement later
- rare treasure pickups that convert into scrap or special resources

## Won’t Have (for now)
- multiple crystal types
- a full crafting web
- world-generation driven distribution logic

## Open Questions
- should herbs or treasure become spendable in the next pass
- should iron respawn between expeditions or remain depleted per map

## Recent Decisions
- crystals remain universal
- crystal tracking is count-only through pylon influence
- iron is the first channel material

## Next Recommended Task
Decide the next interactable expedition resource after iron.