# Core System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Core System.

---

## Current Status
Design Confirmed, First Research Structure Not Started

---

## Current Design Summary
The player core now acts as the progression device that stores materials, stores material-specific essence, and unlocks unified research trees.

Current confirmed direction:
- the core is attached to the player body
- the core stores raw materials and material essence
- each material unlocks one unified research tree
- each tree can include weapons, armor, abilities, and passive bonuses
- advanced nodes can require special materials
- research spending and unlock validation must remain server-authoritative

---

## Implemented
- Core progression direction exists at a high level in the project
- The unified material-tree direction is now documented as confirmed design truth

---

## In Progress
- Defining the first material trees for the prototype
- Defining which categories of unlocks appear first in the core
- Defining how the core stores per-material essence capacity and progression state

---

## Blockers / Problems
- No dedicated core system specification existed before this refactor
- The runtime does not yet expose unified material research trees
- Resource storage, research unlock flow, and node ownership are not yet modeled together
- Special-material requirements for advanced nodes are not yet defined

---

## Must Have
- Core storage for raw materials
- Core storage for per-material essence
- One unified research tree per material
- Weapons, armor, abilities, and passives inside the research model
- Server-authoritative validation for research spending and unlocks
- Special-material gates for advanced nodes

---

## Should Have
- Clear communication of which resources are needed for the next unlock
- A readable prototype UI structure for material trees
- Strong identity differences between early material trees
- Co-op-safe handling of shared collection versus individual research ownership

---

## Could Have
- Respec or reroute options later in development
- Core presentation upgrades tied to progression depth
- Cross-material synthesis nodes later in development

---

## Won’t Have (for now)
- A massive full research graph on day one
- Generic universal progression currencies in the core
- Heavy UI complexity before the basic loop is playable
- Deep respec systems in the first prototype

---

## Open Questions
- Which two or three material trees should be in the first prototype?
- Which unlock category should come first in each tree: weapons, armor, abilities, or passives?
- How much of the core should be shared versus player-specific in co-op?
- What is the first acceptable level of UI complexity for browsing a material tree?

---

## Recent Decisions
- The core stores materials and material-specific essence
- Core research is unified per material tree
- Material trees include weapons, armor, abilities, and passives
- Advanced nodes can require special materials

---

## Next Recommended Task
Define the first playable core research slice:
- choose the initial material trees
- choose one early unlock path for each tree
- define per-material storage and spending rules on the authoritative side
- map pylon rewards into core research inputs