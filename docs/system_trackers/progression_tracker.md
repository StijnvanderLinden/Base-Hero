# Progression System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Progression System.

---

## Current Status
Design Refactor Confirmed, Runtime Alignment Needed

---

## Current Design Summary
Progression now centers on the pylon channeling loop and the split between tactical and long-term resources.

Current confirmed direction:
- gold is a tactical resource spent on building defenses and on repeat pylon activations
- essence is the main progression resource earned from channeling milestones and generated during active channeling
- milestone rewards are always safe and bypass essence capacity
- generated essence is stored separately, capped by capacity, and can be lost before it is banked
- research points arrive at the second milestone and support broader unlock pacing
- final channel completion grants a major reward such as an augment or a permanent unlock

---

## Implemented
- Gate rewards already feed back into base-side progression in a basic runtime form
- Core upgrade progression already exists in the live prototype
- Augment and weapon progression direction is already documented at a high level

---

## In Progress
- Replacing the old cave-oriented reward framing with milestone-based pylon channeling rewards
- Defining the first essence capacity rules for the multiplayer-safe prototype
- Defining how research points and major pylon rewards feed the existing player and base progression paths

---

## Blockers / Problems
- Runtime still uses older gate reward language and does not yet expose dedicated essence, research point, or capacity systems
- The split between immediately banked milestone rewards and vulnerable generated essence is not implemented yet
- Repeat pylon activation costs are not yet tied into a broader gold economy flow

---

## Must Have
- Gold as a tactical resource for defenses and repeat channel starts
- Essence as the primary progression resource
- Essence capacity that caps only generated essence
- Safe milestone banking at 1/3, 2/3, and 3/3
- Research point rewards at the second milestone
- Major reward payouts at full channel completion

---

## Should Have
- Clear UI feedback for banked essence versus vulnerable generated essence
- Progression sinks that create meaningful spend decisions after each gate run
- Unlock pacing that makes newer pylons more attractive than farming older ones forever
- Shared co-op readability for milestone rewards and reward ownership rules

---

## Could Have
- Additional progression branches that spend research points in different ways
- Multiple major reward tables based on biome or pylon tier
- Limited meta upgrades that increase essence capacity in controlled steps
- Milestone-specific bonus modifiers tied to gate depth or biome identity

---

## Won’t Have (for now)
- Infinite uncapped essence storage
- Gold functioning as the main long-term progression currency
- Complex tech-tree presentation before the core loop is playable
- Heavy economy micromanagement layers during the first multiplayer-safe prototype

---

## Open Questions
- What is the first prototype essence capacity value that creates pressure without feeling overly punitive?
- How should research points split between player-focused and base-focused unlocks in the first pass?
- Which major reward pool should be used first: augments, unlock tokens, or a hybrid?
- How quickly should repeat activation gold costs scale across reused pylons?

---

## Recent Decisions
- Progression is now fed primarily by pylon channeling rather than cave expeditions
- Gold is a tactical spend resource and essence is a progression resource
- Milestone rewards are always safe and bypass capacity limits
- Generated essence is capped and remains at risk until banked or extracted safely

---

## Next Recommended Task
Define the first runtime reward contract for gates:
- add explicit gold, essence, research point, and major reward outputs to the active gate loop
- separate banked rewards from vulnerable generated essence in the HUD and save flow
- choose the first concrete spend sinks for research points and major rewards