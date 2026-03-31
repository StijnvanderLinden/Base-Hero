# Decisions

## Purpose
This document records important project decisions and why they were made.

Use this file to preserve reasoning over time so the project does not repeatedly re-debate the same choices without context.

Record:
- major design decisions
- major technical decisions
- important scope boundaries
- changes in direction with reasoning

---

## Decision Log

### Base-defense focus over open-world survival
Decision:
The game is base-defense focused rather than a full open-world survival sandbox.

Reason:
This keeps the project aligned with its strongest fantasy:
- build meaningful defenses
- survive major raids
- fight alongside structures

It also keeps scope more manageable and supports stronger pacing.

---

### Gates are instanced support missions
Decision:
Gates are instanced missions that support main-base progression.

Reason:
This makes it easier to:
- control pacing
- support co-op
- create strong extraction tension
- keep gates distinct from the main base loop

---

### Host-authoritative multiplayer
Decision:
The multiplayer model is hosted co-op with the host acting as the authoritative server.

Reason:
This fits the project’s intended scale, keeps infrastructure needs lower, and supports the desired co-op structure.

---

### Steam support is planned later, not required early
Decision:
The game should be designed so future Steam integration is smooth, but early prototypes should not depend on Steam-specific implementation.

Reason:
This prevents release-platform concerns from blocking core gameplay prototyping.

---

### Gates should differ from main raids
Decision:
Gates should not be simple copies of main-base raid gameplay.

Reason:
If gates and raids feel too similar, the game risks becoming repetitive.
Gates should feel more reactive, greedy, and temporary, while raids should feel like larger planned tests of long-term preparation.

---

### Gates likely need both defense and outward risk-taking
Decision:
The current likely direction is that gates combine a defendable center with reasons to leave safety for higher-value rewards.

Reason:
This helps gates feel distinct from the main base while preserving the project’s defense identity.

---

### Reward categories should support different kinds of decisions
Decision:
The current design direction includes:
- a main progression resource
- rarer exotic materials
- components for special gear or structures
- possible temporary run-based rewards

Reason:
This creates a better mix of:
- steady progression
- exciting unlocks
- customization
- risk-taking incentives

---

## Rules
Update this file when:
- a major design or technical choice is made
- a meaningful pivot occurs
- the project’s boundaries change

Do not update for:
- small tuning changes
- temporary experiments
- one-off implementation details