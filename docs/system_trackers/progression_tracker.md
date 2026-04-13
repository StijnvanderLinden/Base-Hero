# Progression System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Progression System.

---

## Current Status
Stone Age Progression Slice Implemented On Top Of The Pylon Loop

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
- Era-driven research definitions now exist at runtime
- Stone Age now has a live first progression slice:
	- Reinforced Wall unlock
	- Improved Thrower unlock
	- first augment slot unlock
	- first branch unlock
	- simple damage, attack-speed, range, and optional AoE augment nodes
- Stone Age crystal spending is now intentionally small and focused

---

## In Progress
- Tuning Stone Age essence and crystal costs for fast unlock pacing
- Aligning the live Stone Age slice with the broader long-term material-specific progression plan
- Defining how later eras should widen the research set without overloading the early UI

---

## Blockers / Problems
- Runtime still uses one shared essence pool rather than per-material stored essence
- The split between safe milestone rewards and vulnerable generated essence is still simplified in runtime
- full modifier-count reward scaling is not implemented yet
- the Stone Age slice is intentionally narrower than the long-term progression specification

---

## Must Have
- Gold as a tactical resource for building structures only
- Material gathering as the primary progression input
- Fast first-era progression pacing
- first augment slot and branch unlock path
- first simple combat augment set
- first structure upgrade unlocks

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
- Stone Age uses a deliberately small, fast unlock set instead of a broad tree
- structure upgrades and first augments are available inside Era 1
- complex augment interactions are deferred until later eras
- the first era keeps crystal spending minimal and focused

---

## Next Recommended Task
Playtest the Stone Age unlock cadence and then decide how much of the broader per-material essence plan should move from documentation into runtime for the next progression pass.