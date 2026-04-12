# Crystal System Specification

## Purpose
The Crystal System defines the universal crystal resource used to gate research unlocks and branch access.

Crystals are intentionally separate from essence.

---

## Core Rules
- crystals are one universal resource type
- crystals are finite per map
- each crystal can be collected only once
- collected crystals are removed permanently for the current session
- crystals are counted globally for research spending

---

## Crystal Entities
Crystals exist as world pickups during expeditions.

Entity rules:
- crystals are placed at fixed or procedural world positions
- players collect them by interacting in the world
- collection is server-authoritative
- once collected, the crystal node is removed and cannot be collected again

---

## Tracking Rules
Pylons do not reveal exact crystal locations.

Instead, the pylon reports:
- how many crystals remain inside its current influence radius

This preserves exploration tension while still letting pylon growth inform route planning.

---

## Inventory Rules
Crystal inventory is global.

Current prototype rules:
- crystals are stored in one shared count
- crystal spending happens through research unlocks
- crystal collection persists across expeditions within the same session

---

## Integration With Pylons
The pylon uses influence radius to count nearby uncollected crystals.

Rules:
- pylon influence counts crystals in range
- pylon influence does not spawn crystal markers
- pylon UI communicates only the remaining count in area

---

## Integration With Research
Crystals unlock higher-value progression.

Current node usage:
- advanced nodes can require essence and crystals
- branch unlocks can require crystals only
- crystals are not used to place or upgrade pylons