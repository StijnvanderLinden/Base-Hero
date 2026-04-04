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

### Raids are player-triggered through town hall upgrades
Decision:
Major raids only begin when players start a town hall upgrade.

Reason:
This makes raids intentional progression checkpoints instead of random interruptions.
It lets players decide when they are ready for the next big test and keeps the base at the center of the game.

---

### Gates are persistent layered progression zones
Decision:
Each gate is a persistent biome region with multiple depth layers that players revisit over time.

Reason:
This creates a stronger long-term exploration structure, gives gate progress a sense of place, and prevents gates from feeling like disposable one-off arenas.

---

### Gates are not expected to be fully cleared in one tier
Decision:
Players are not expected to fully clear a gate in a single progression tier.

Reason:
This preserves long-term goals inside a gate, supports depth-based progression, and allows players to push too far early without breaking the intended pacing.

---

### Gate progression is depth-based
Decision:
Progression inside gates is primarily about pushing deeper through outer, mid, inner, and deep layers.

Reason:
This creates readable escalation, clear expectations for revisit value, and a strong structure for biome rewards and pylon difficulty.

---

### Biome mechanics are biome-specific
Decision:
Gate mechanics should be driven by individual biome rules rather than a single global gimmick set.

Reason:
This keeps biomes distinct, prevents repetitive gate design, and allows later biomes to introduce stronger identity without overcomplicating the first one.

---

### Enemy system is split between exploration enemies and constructs
Decision:
Enemy design is split into two categories:
- exploration enemies used in gate traversal and biome pressure
- engineered construct enemies used in pylon defense events and main raids

Reason:
This keeps exploration pressure and organized defense events distinct, strengthens biome identity, and gives raids a more deliberate and readable enemy language.

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

### Caves are activated from pylons, not found randomly
Decision:
Cave expeditions begin from captured pylons through intentional activation rather than random cave discovery.

Reason:
This keeps pylons central to gate progression, makes footholds matter mechanically, and ties cave access directly to player-controlled progression rather than scattered randomness.

---

### Pylon defenses are reused for cave events
Decision:
Players use the existing defenses around a captured pylon during cave expeditions instead of building a new defense setup inside the cave.

Reason:
This keeps the system readable, avoids duplicating the build loop, and makes preparing a foothold around the pylon a meaningful commitment before entering the cave.

---

### Failure damages pylons instead of removing player resources
Decision:
If a cave expedition fails, the pylon becomes damaged and local control is lost rather than removing player inventory or loot.

Reason:
This creates a meaningful setback through loss of safety and control without making failure feel overly punishing or discouraging experimentation.

---

### Players retain collected loot on cave failure
Decision:
Players keep the resources and loot they already collected if a cave expedition fails.

Reason:
This preserves player momentum, prevents frustration from hard wipe punishment, and makes the recovery loop focus on reclaiming the foothold rather than replacing lost inventory.

---

### Repairing pylons is a gameplay event with enemy pressure
Decision:
Repairing a damaged pylon requires time, modest resources, and defending against enemy pressure while local defenses remain inactive.

Reason:
This turns recovery into active gameplay, preserves tension after failure, and avoids a flat or purely administrative repair action.

---

### Passive resource gain is secondary to cave exploration
Decision:
Active caves may generate a small passive resource gain at the pylon, but the primary rewards must come from going deeper into the cave.

Reason:
This keeps players incentivized to explore, prevents idle outside play from becoming optimal, and maintains the intended risk-versus-reward tension of cave expeditions.

---

### All health bars use a screen-space overlay
Decision:
Any health bar added to a world entity should be drawn by the shared screen-space UI overlay rather than as a 3D mesh in the world.

Reason:
This keeps combat readability consistent in 3D and co-op, avoids camera-facing and parent-rotation issues, and gives every entity one stable presentation path for future health bars.

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