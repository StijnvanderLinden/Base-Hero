# Material System Specification

## Purpose
The Material System is intentionally deferred for the vertical slice.

The MVP uses only:
- scrap during runs
- essence between runs

Gold, wood, stone, herbs, crystals, iron, material families, and material-specific trees are backlog until the core loop is fun.

---

## Current MVP Resources

### Scrap
Scrap is the in-run resource.

Rules:
- dropped only by wave enemies
- automatically collected on enemy kill
- spent during the current run
- not stored between runs

Uses:
- turret upgrades
- limited extra turret placement

### Essence
Essence is the between-run progression resource.

Rules:
- generated over time during a run
- scales with survival duration and milestones
- spent in the hub
- about 70% is kept when the base is destroyed

Uses:
- turret type unlocks
- turret upgrade branch unlocks
- base capacity
- optional player weapon upgrades

---

## Deferred Material Direction
Later, the game may add:
- gold
- wood
- stone
- herbs
- metals
- gems
- special materials
- material discovery
- material-specific research trees

These ideas are not current design truth for implementation.

---

## Scope Rules
For the vertical slice:
- do not add manual resource pickup
- do not add gathering nodes
- do not add crafting webs
- do not add material-specific upgrade trees
- do not add multiple resource families

Only add a material system after scrap, essence, and the core survival loop are fun.
