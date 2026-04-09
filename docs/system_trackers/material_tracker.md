# Material System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Material System.

---

## Current Status
Design Confirmed, First Runtime Slice Not Started

---

## Current Design Summary
Materials now drive exploration rewards, pylon activation, and long-term progression.

Current confirmed direction:
- materials are gathered during exploration
- each pylon is tied to one material type
- pylon channeling costs only the matching material
- pylon channeling converts matching material into matching material essence over time
- each material has its own essence storage capacity
- special materials gate advanced research nodes
- the system should support co-op specialization and coordinated collection

---

## Implemented
- The material-driven progression direction is now documented as confirmed design truth

---

## In Progress
- Defining the first playable material families
- Defining the first pylon-to-material mappings
- Defining the first special-material sources and uses

---

## Blockers / Problems
- No dedicated material system specification existed before this refactor
- Runtime gathering, pylon activation, and research spending are not yet linked through one resource model
- Per-material capacity handling is not implemented yet
- Special-material distribution is not yet defined

---

## Must Have
- Exploration materials such as metals and gems
- Matching-material pylon activation
- Material-to-essence conversion during channeling
- Per-material essence capacities
- Special materials for advanced progression
- Clear mapping from materials to core research trees

---

## Should Have
- Clear world presentation for material families
- Readable pylon signaling for required materials
- Reward feedback that shows material conversion clearly during channeling
- Co-op-safe sharing and spending rules

---

## Could Have
- Biome-specific material variants
- Material-specific audiovisual feedback during conversion
- Secondary uses for surplus materials later in development

---

## Won’t Have (for now)
- Generic universal essence as a catch-all progression resource
- Gold-funded pylon activation
- Large crafting-web complexity in the first prototype
- A complete final material list for all biomes

---

## Open Questions
- Which material families should appear in the first playable gate slice?
- How should raw material gathering rates compare between common and rare materials?
- Which special materials should be tied to elite enemies versus pylon completions?
- How should material conversion feedback be presented in the HUD and in-world?

---

## Recent Decisions
- Generic essence is removed in favor of material-based essence conversion
- Pylons are tied to specific materials
- Channeling costs only matching material and not gold
- Materials convert into matching material essence through channeling
- Special materials gate advanced progression

---

## Next Recommended Task
Define the first prototype material package:
- choose the initial common materials
- choose the first special materials
- assign materials to the first pylons
- define how material input becomes essence output across the three channel phases