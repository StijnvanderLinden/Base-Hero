# Core System Specification

## Purpose
The Core System defines the player-attached progression device that stores materials, stores material-specific essence, and unlocks unified research trees.

The core is the player's portable progression anchor between gate runs and base-side planning.

---

## Design Goals
- Make the core the central interface for player progression
- Unify weapons, armor, abilities, and passives inside one research structure per material
- Store progression resources in a readable way
- Support co-op specialization without isolating players from shared collection
- Keep the system modular and scalable for later materials and advanced nodes

---

## Core Role
The core is attached to the player body and acts as that player's progression device.

The core stores:
- gathered materials
- banked material essence
- unlocked research nodes
- progress toward advanced material paths

The core does not act as a generic currency wallet.
It is a structured research device tied to material progression.

---

## Storage Behavior
The core holds two main resource layers.

### Material Storage
Raw materials are gathered during exploration.

Examples:
- iron
- silver
- fire gems
- lightning gems
- elite or rare materials

Material storage rules:
- raw materials are used to activate matching pylons
- rare materials are reserved for advanced research requirements
- storage should remain readable by material family

### Material Essence Storage
Material essence is the refined progression output created by pylon channeling.

Storage rules:
- material essence is tracked separately for each material type
- each material type has its own capacity
- milestone rewards bypass capacity when banked
- generated essence from a live channel remains vulnerable until safely secured

---

## Unified Material Trees
Each material unlocks one unified research tree.

Each tree can include:
- weapons
- armor
- abilities
- passive bonuses

Design intent:
- keep a material's combat identity coherent
- let one resource path support multiple kinds of player growth
- avoid scattering progression across too many disconnected menus or systems

Example directions:
- Iron Tree supports melee weapons, armor plating, and defensive passives
- Fire Tree supports fire abilities, burn effects, and offensive bonuses
- Lightning Tree supports mobility, chaining effects, and burst utility

---

## Research Unlock Rules
Research nodes are unlocked through matching resources.

Rules:
- basic nodes use matching material essence
- advanced nodes may also require special materials
- unlocks should stay tied to the identity of that material tree
- research should support both vertical specialization and eventual breadth across multiple materials

The core should make it obvious which materials are needed for the next desired unlock.

---

## Research Categories
The core unifies several growth categories in one place.

### Weapons
- unlock new weapon paths or weapon functions tied to a material identity

### Armor
- unlock protection, resistance, or survivability upgrades tied to a material identity

### Abilities
- unlock active abilities or ability upgrades tied to a material identity

### Passives
- unlock persistent bonuses that reinforce a material specialization

These categories should feel connected rather than like unrelated trees that merely share a resource.

---

## Special Material Integration
Rare or elite materials are used to gate stronger research nodes.

Sources may include:
- elite enemies
- pylon completion rewards
- overworld encounters

Role:
- unlock stronger endpoints
- gate advanced abilities
- distinguish ordinary progression from high-value advancement

---

## Co-op Considerations
The core system must support specialization inside a team.

Desired outcomes:
- one player can focus on iron progression
- another player can focus on fire progression
- the group can coordinate which materials to prioritize during exploration

Authority rule:
- research unlock validation, resource spending, and node ownership are server-authoritative

---

## Early Scope Boundaries
Do define now:
- core storage of materials and material essence
- one unified tree per material
- the inclusion of weapons, armor, abilities, and passives in those trees
- special-material gates for advanced nodes

Do not fully define yet:
- the full UI layout of all trees
- every node in every material tree
- exact resource costs per node
- every interaction between core progression and future base facilities

This system should stay readable and prototype-friendly before expanding into a large research graph.