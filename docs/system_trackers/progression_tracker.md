# Progression System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Progression System.

---

## Current Status
Design Refactor Confirmed, Material Progression Refactor Needed

---

## Current Design Summary
Progression now centers on the pylon channeling loop and the split between tactical and long-term resources.

Current confirmed direction:
- gold is a tactical resource used only for building structures
- progression is fueled by gathered materials, material essence, and special materials
- pylons convert matching material into matching material essence during active channeling
- milestone rewards are always safe and bypass per-material essence capacity
- advanced research nodes are gated by special materials rather than generic currencies
- repeated pylon clears form a progression ladder through per-pylon modifier escalation
- full completion reward quality scales with the number of active modifiers on that run
- players do not manually choose pylon modifiers, keeping progression pacing structured
- core research is unified per material tree across weapons, armor, abilities, and passives

---

## Implemented
- Gate rewards already feed back into base-side progression in a basic runtime form
- Core upgrade progression already exists in the live prototype
- Augment and weapon progression direction is already documented at a high level
- Modifier-scaled pylon reward progression is now documented as confirmed design truth
- Material-based channeling and core research direction are now documented as confirmed design truth

---

## In Progress
- Replacing the old cave-oriented reward framing with milestone-based pylon channeling rewards
- Defining the first per-material essence capacity rules for the multiplayer-safe prototype
- Defining how material essence and special materials feed the existing player and base progression paths
- Defining how modifier count changes full-completion reward quality without replacing milestone payouts
- Defining the first unified material research trees on the player core

---

## Blockers / Problems
- Runtime still uses older gate reward language and does not yet expose dedicated material essence, special material, or per-material capacity systems
- The split between immediately banked milestone rewards and vulnerable generated material essence is not implemented yet
- Exploration materials are not yet linked to pylon ritual costs
- Runtime reward tables do not yet account for modifier-count-based completion tiers
- The core does not yet expose unified material research trees

---

## Must Have
- Gold as a tactical resource for building structures only
- Material gathering as the primary progression input
- Per-material essence capacity that caps only generated matching essence
- Safe milestone banking at 1/3, 2/3, and 3/3
- Unified core research trees per material
- Special materials for advanced research nodes
- Modifier-count-based completion reward tiers for repeated pylon mastery

---

## Should Have
- Clear UI feedback for banked material essence versus vulnerable generated material essence
- Progression sinks that create meaningful spend decisions after each gate run
- Unlock pacing that makes newer pylons more attractive than farming older ones forever
- Shared co-op readability for milestone rewards and reward ownership rules
- Clear reward previewing so teams understand why a higher-modifier clear is worth attempting
- Clear communication of which materials feed which research trees

---

## Could Have
- Multiple reward tables based on biome or pylon tier
- Limited upgrades that increase specific material essence capacities in controlled steps
- Milestone-specific bonus modifiers tied to gate depth or biome identity
- Cosmetic or presentation upgrades tied to mastering higher modifier tiers on a pylon
- Cross-material research nodes that require two specializations later in development

---

## Won’t Have (for now)
- Infinite uncapped material essence storage
- Gold functioning as the main long-term progression currency
- Generic universal essence as the main progression resource
- Heavy economy micromanagement layers during the first multiplayer-safe prototype

---

## Open Questions
- What is the first prototype per-material essence capacity value that creates pressure without feeling overly punitive?
- Which material trees should be available in the first playable slice?
- Which advanced nodes should require special materials in the first pass?
- How should completion reward packages differ between material families?
- How large should the reward jump be between modifier tiers to stay motivating without invalidating deeper content?

---

## Recent Decisions
- Progression is now fed primarily by pylon channeling rather than cave expeditions
- Generic essence is removed in favor of material-based essence conversion
- Gold remains a tactical structure resource and no longer starts pylon channels
- Milestone rewards are always safe and bypass per-material capacity limits
- Generated material essence is capped and remains at risk until banked or extracted safely
- Repeated pylon clears now function as a structured mastery ladder
- Full completion rewards scale with active modifier count rather than player-selected challenge settings
- Core research is unified per material tree

---

## Next Recommended Task
Define the first material-aware progression contract:
- choose the first two or three material trees for the prototype
- map matching material input to matching material essence output per pylon phase
- keep milestone payouts stable across modifier tiers
- expose modifier count and material type to reward generation on the authoritative side