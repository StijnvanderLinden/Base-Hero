# Biome System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Biome System.

---

## Current Status
Design Confirmed, Not Implemented

---

## Current Design Summary
Biomes define the identity of persistent gate regions.

Current confirmed direction:
- biome mechanics are biome-specific
- the first biome should stay simple and readable
- later biomes can introduce stronger local mechanics
- exploration enemies should reflect the biome

---

## Implemented
- No dedicated biome system is implemented yet
- The current gate prototype does not yet differentiate regions by biome mechanics

---

## In Progress
- Defining the first biome at a high level
- Separating biome identity from the generic gate prototype

---

## Blockers / Problems
- No persistent gate region exists yet
- No biome-specific exploration enemy family exists yet
- No biome-specific hazards or material identity are implemented yet

---

## Must Have
- One simple biome region
- One exploration enemy family tied to that biome
- One clear biome visual and material identity
- Readable biome rules in co-op

---

## Should Have
- One biome-specific hazard or pressure element later
- Distinct deeper-layer reward identity
- Better biome-to-biome differentiation plan

---

## Could Have
- Weather systems
- Traversal-specific rules
- Visibility modifiers
- Biome mutators
- Unique deep-layer events

---

## Won’t Have (for now)
- Many complex biome gimmicks at once
- Heavy environmental simulation
- Large biome catalogs before the first one works
- Globalized biome rules that flatten region identity

---

## Open Questions
- What should the first biome actually be?
- What is the minimum biome identity needed for the first persistent gate milestone?
- Which biome mechanics are strong enough to matter without harming readability?
- How much resource identity should be biome-specific early on?

---

## Next Recommended Task
Define and implement the first biome slice:
- choose the first biome theme
- define one exploration enemy family for it
- define its basic materials and region identity
- keep mechanics simple and readable