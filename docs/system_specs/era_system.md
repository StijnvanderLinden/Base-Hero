# Era System Specification

## Purpose
The Era System defines the self-contained content packages that gates load at runtime.

Each era owns:
- enemy lineups
- buildable structure variants
- material nodes
- simple augment availability
- research node availability
- visual direction data

The first implementation slice is Era 1: Stone Age.

---

## Design Goals
- keep gate content modular and easy to extend
- avoid hardcoding gate logic per era
- let one era provide a complete playable slice
- keep server-authoritative runtime decisions separate from presentation
- support later era unlocks without rewriting gate, enemy, or research managers

---

## Core Data Model
Each era is represented by EraData.

Required fields:
- era_id
- display_name
- description
- enemy_set
- structure_set
- material_set
- augment_pool
- unlock_requirements
- visual_theme_data

Current runtime EraData also carries:
- enemy catalog scene references by enemy id
- structure catalog scene references and unlock variants
- research node definitions and order
- gate resource node definitions
- pylon channel costs
- wave definitions
- player combat data
- pylon rule data

---

## Runtime Architecture
EraManager owns the registered eras and exposes the active gate era to runtime systems.

Current responsibilities:
- register eras
- track unlocked eras
- track the active gate era
- provide the active era data to gate, enemy, building, and research systems
- resolve enemy scenes from era data

The current prototype loads Stone Age as the default unlocked era and keeps Bronze Age as a locked placeholder.

---

## Gate Integration
Starting a gate run selects the current unlocked era through EraManager.

The gate runtime then pulls era-owned data for:
- resource spawns
- pylon channel costs
- wave definitions
- run labels and theme context

For the first slice:
- only Stone Age is enterable
- later eras remain placeholders
- gate selection UI is deferred

---

## Enemy Integration
EnemyManager reads the active era wave plan and enemy catalog.

This keeps gate pressure data-driven:
- wave count
- spawn mix
- spawn cadence
- max live enemies
- final-wave boss composition

Raid construct pressure remains separate from the era slice for now.

---

## Structure Integration
BuildingManager keeps the existing wall and turret build flow, but the underlying scenes and material costs come from the active era.

That means an era may define:
- base wall/turret variants
- upgraded variants unlocked by research
- per-structure material costs
- display names tied to that era

---

## Research Integration
ResearchManager reads era-defined research nodes instead of relying on a fixed prototype table.

Era-owned research currently supports:
- structure unlocks
- augment unlocks
- simple stat modifiers
- branch unlocks

This keeps the first era focused while allowing later eras to expose different node sets.

---

## Expansion Plan
To add a new era later:
1. create a new EraData resource
2. add enemy scenes and structure scenes for that era
3. define research nodes, resource spawns, and wave definitions in the data
4. register the era in EraManager
5. add unlock requirements and gate selection later

No gate-manager rewrite should be required.