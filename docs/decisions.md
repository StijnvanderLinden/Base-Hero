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

### Cave system removed in favor of pylon channeling
Decision:
The cave system was removed and replaced with pylon channeling as the primary gate reward loop.

Reason:
The cave direction added too much structural complexity for the current prototype, split focus away from the overworld gate space, and created more implementation burden than value for the first multiplayer-safe slice.

---

### Pylon channeling is the primary gate gameplay loop
Decision:
Captured pylons now drive the main gate loop through repeatable channeling events rather than cave expeditions.

Reason:
This keeps pylons central to gate progression, preserves exploration in the overworld, and creates a cleaner defend-push-cash-out loop that is easier to prototype and read in co-op.

---

### Pylons are tied to specific materials
Decision:
Each pylon is tied to one specific material family, such as a metal or gem type.

Reason:
This gives pylons a clearer identity, creates progression paths per material, and supports co-op specialization instead of treating all pylons as identical currency sources.

---

### Pylon channeling costs matching material, not gold
Decision:
Starting a pylon channel requires only the material that matches that pylon's identity.

Reason:
This makes exploration directly fuel progression, reinforces material importance, and keeps gold focused on structure-building rather than progression rituals.

---

### Generic essence is replaced by material-based essence
Decision:
The game no longer uses one universal essence resource. Pylon channeling converts gathered materials into matching material-specific essence instead.

Reason:
This creates stronger ties between exploration, pylon identity, and progression while avoiding a flat universal currency that weakens material specialization.

---

### Milestone rewards are always safe
Decision:
Rewards earned at 1/3, 2/3, and 3/3 channel milestones are banked immediately and cannot be lost.

Reason:
This lets players feel steady progress even when they fail later, reduces frustration, and supports the intended push-your-luck structure without making it too punitive.

---

### Material essence has per-material capacity limits
Decision:
Each material has its own essence capacity, and overflow is lost.

Reason:
This prevents hoarding, encourages spending within specific material paths, and keeps conversion-based progression moving instead of allowing passive stockpiling.

---

### Shutdown phase creates the final cash-out tension
Decision:
Stopping a channel triggers a 15 second shutdown where generated essence stops increasing but remains vulnerable.

Reason:
This prevents instant safe exits, creates one final defensive spike before payout, and makes the stop decision carry real tension instead of functioning like a free reset.

---

### Material essence holder introduces reward risk
Decision:
Generated matching material essence is stored in a physical holder object that can be destroyed during a channel.

Reason:
This creates a clear risk object for players to defend, adds readable tension to the battlefield, and separates safe milestone rewards from vulnerable generated rewards in a concrete way.

---

### Gold is for structures, material essence is for progression
Decision:
Gold is used for building structures, while progression is driven by materials, material-specific essence, and special materials.

Reason:
This keeps short-term tactical building decisions separate from long-term growth and avoids overloading gold with too many jobs.

---

### Every pylon has one fixed base modifier
Decision:
Each pylon uses one fixed base modifier that is always active on that pylon's channel runs.

Reason:
This gives each pylon a stable tactical identity, keeps location-based mastery meaningful, and avoids needing a large random modifier pool to make pylons feel different.

---

### Global modifiers are shared and not manually selected
Decision:
All pylons use one shared global modifier sequence, and players do not manually choose which modifiers are active.

Reason:
This prevents dominant player-selected challenge setups, keeps balancing under tighter control, and reduces decision overload during repeated runs.

---

### Pylon modifier escalation is tracked per pylon
Decision:
Repeated successful full clears increase modifier difficulty only for that specific pylon, not for all pylons globally.

Reason:
This preserves each pylon as its own mastery ladder, lets players learn one location at a time, and keeps progression readable instead of globally flattening pylon difficulty.

---

### The first pylon clear is a base-modifier-only learning run
Decision:
The first successful clear on a pylon uses only that pylon's fixed base modifier, with global modifiers added only on later runs.

Reason:
This creates a cleaner onboarding run, teaches the pylon's core identity before extra complexity is added, and makes later escalation feel earned instead of abrupt.

---

### Global modifier order is designed as a progression curve
Decision:
The shared global sequence is ordered so the first modifier is simple, the second adds meaningful challenge, and the third creates a mastery-level pressure spike.

Reason:
This makes repeated clears feel like a structured progression ladder rather than a flat list of interchangeable difficulty toggles.

---

### Full pylon completion rewards scale with modifier count
Decision:
Completion reward quality increases based on how many modifiers were active on the successful run.

Reason:
This keeps revisiting and mastering a pylon rewarding, aligns payout with challenge, and supports repeated clears as a meaningful progression path rather than simple repetition.

---

### Materials are converted into essence through channeling
Decision:
Pylon channeling converts the matching input material into matching material essence over time, with higher phases increasing the conversion rate.

Reason:
This ties progression rewards directly to successful defense, strengthens the risk-versus-reward curve inside the event, and makes pushing deeper through a channel materially valuable.

---

### Core research is unified per material
Decision:
Each material unlocks one unified research tree on the player core that can include weapons, armor, abilities, and passive bonuses.

Reason:
This keeps progression readable, supports strong specialization identities, and avoids splitting related growth into too many disconnected systems.

---

### Exploration is required to fuel progression
Decision:
Players must gather materials during exploration before they can fuel pylon channeling and advance research.

Reason:
This keeps exploration meaningfully connected to progression, prevents passive progression without field play, and supports co-op coordination around material priorities.

---

### All health bars use a screen-space overlay
Decision:
Any health bar added to a world entity should be drawn by the shared screen-space UI overlay rather than as a 3D mesh in the world.

Reason:
This keeps combat readability consistent in 3D and co-op, avoids camera-facing and parent-rotation issues, and gives every entity one stable presentation path for future health bars.

---

### Player uses a single evolving weapon instead of multiple weapons
Decision:
The player uses one evolving weapon platform rather than collecting and swapping between many active weapons.

Reason:
This supports stronger weapon identity, keeps progression tied to player build expression instead of loot churn, and fits the game’s return-to-base loop where players improve themselves between runs.

---

### Weapon materials are applied directly through slots
Decision:
Weapon materials are inserted directly into the active weapon’s material slot rather than manually forging weapon shapes.

Reason:
This keeps the system readable, prevents weapon crafting complexity from overwhelming the prototype, and lets progression unlock stronger material tiers without replacing the whole weapon.

---

### Augments define weapon behavior, not just raw stats
Decision:
Augments are primarily behavior-changing modifiers rather than simple numerical bonuses.

Reason:
This creates stronger build identity, produces more interesting synergies, and helps players feel that their weapon evolves in meaningful ways instead of only becoming numerically larger.

---

### Augments are removable at a cost
Decision:
Players may remove augments by paying a resource cost.

Reason:
This allows experimentation without locking players into early mistakes forever while still preserving enough friction that loadout choices matter.

---

### Augments can be fused into higher tiers
Decision:
Augments can be fused from Level 1 to Level 2 and from Level 2 to Level 3 using three lower-tier copies.

Reason:
This gives long-term value to lower-tier augments, creates a steady progression ladder, and prevents early augment drops from becoming dead loot too quickly.

---

### Fusion must add new behavior, not only stronger numbers
Decision:
Higher-tier fused augments must introduce new behavior patterns instead of acting as pure stat upgrades.

Reason:
This keeps fusion exciting, preserves the system’s behavior-first design, and ensures long-term progression changes how a weapon plays rather than only how hard it hits.

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