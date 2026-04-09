# Material System Specification

## Purpose
The Material System defines the materials gathered during exploration, how those materials map to pylons, and how they are converted into material-specific essence for progression.

Materials are the bridge between exploration, pylon channeling, and core research.

---

## Design Goals
- Make exploration rewards directly useful for progression
- Give each material family a clear gameplay identity
- Tie pylon activation to matching gathered resources
- Support co-op specialization and shared planning
- Keep the system modular enough for new material families later

---

## Material Categories
The game uses several broad material categories.

### Metals
Examples:
- iron
- silver
- heavier or rarer metal types later

### Gems
Examples:
- fire gems
- lightning gems
- other elemental gem types later

### Special Materials
Examples:
- elite drops
- rare pylon rewards
- unique overworld materials

Special materials are not generic currencies.
They are targeted requirements for stronger progression nodes.

---

## Gathering Sources
Materials are gathered through gameplay exploration.

Typical sources:
- world resource nodes
- enemy drops
- elite enemy drops
- pylon event rewards
- overworld encounters

Gathering rule:
- players must explore to fuel later pylon channels and research progression

---

## Pylon Relationship
Each pylon is tied to one material type.

Rules:
- a pylon consumes only its matching material to begin channeling
- a pylon generates only its matching material essence during channeling
- pylon identity should signal the material family clearly
- players should understand the required material before spending it

This gives materials a clear destination and makes pylon selection part of progression planning.

---

## Ritual Activation
Starting a pylon channel is a ritual activation.

Activation rules:
- the channel cost is paid only in the matching material
- gold is not used to activate pylons
- the exact cost may scale by pylon tier or depth later
- the activation input should remain readable and never collapse into a generic cost pool

---

## Material To Essence Conversion
During channeling, the pylon converts matching material into matching material essence.

Conversion phases:
- Phase 1 converts at the base rate
- Phase 2 converts at about 2.5x
- Phase 3 converts at about 5x

Design intent:
- reward pushing deeper into the event
- reinforce the risk-versus-reward curve
- make the material system feel active instead of passive

---

## Material Essence Capacity
Each material has its own essence storage capacity.

Rules:
- generated material essence is capped by material type
- overflow is lost
- milestone rewards bypass the cap
- per-material capacity should pressure spending without making early progression feel punitive

---

## Special Materials
Special materials support advanced progression.

Sources:
- elite enemies
- pylon events
- overworld encounters

Uses:
- advanced research nodes
- stronger abilities
- high-tier progression unlocks

Special materials should remain exciting and targeted rather than turning into a broad catch-all currency.

---

## Co-op Considerations
The material system should support teamwork.

Desired outcomes:
- players can specialize around different material paths
- the team can share collection priorities
- exploration routes can be chosen based on research goals

Materials should encourage coordination, not isolate players into fully separate games.

---

## Early Scope Boundaries
Do define now:
- the main material categories
- the tie between pylons and specific materials
- material-paid channel activation
- material-to-essence conversion
- special materials for advanced nodes

Do not fully define yet:
- the complete material list for all biomes
- exact drop rates
- exact activation costs per pylon tier
- every late-game cross-material recipe or dependency

This system should stay readable and practical for the first multiplayer-safe prototype.