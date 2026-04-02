# Gate System Specification

## Purpose
The Gate System provides repeatable, high-risk missions that players enter to gather resources and progression for the main base.

Gates should feel different from main base raids:
- more reactive
- more opportunistic
- more risky
- less prepared
- more about short-term decisions under pressure

Gates are one of the main engines of progression in the game.

---

## Design Goals
- Create tense, replayable missions
- Reward risk-taking and greed
- Support co-op teamwork
- Feed resources back into the main base
- Feel different from main raid gameplay
- Be scalable and readable in 3D multiplayer

---

## Core Fantasy
Players enter a dangerous world or arena through a gate, deploy or protect a temporary objective, gather rewards under pressure, and decide whether to stay longer for more value or extract before losing too much.

The key emotional loop is:
- stabilize
- push outward
- get greedy
- panic
- extract

---

## Core Loop
1. Enter a gate
2. Use a short preparation phase to build defenses around the temporary objective
3. Survive while the objective gathers resources
4. Enemy pressure scales over time
5. Choose when to stop gathering and start extraction
6. Interact with the objective to begin extraction
7. Survive the extraction countdown
8. Return with rewards for main-base progression

---

## Gate Structure
A gate is an instanced mission.

A gate contains:
- a defendable central objective
- enemy spawn pressure
- resource opportunities
- optional exploration or side objectives
- an extraction flow

A gate is not intended to be a fully open-world sandbox.

---

## Temporary Objective
The temporary objective is the center of the gate run.

Possible versions:
- drill
- portable core
- extractor
- signal beacon

Current intended direction:
- a drill or temporary core that must survive while rewards are gathered

### Design Role
The temporary objective:
- anchors player attention
- creates a fallback safe zone
- gives enemies a consistent target
- supports the base-defense identity of the game
- acts as the interaction point that begins extraction

### First Prototype Rule
For the first gate prototype, players get a short prep phase after entering the gate.

During prep:
- players may build defenses around the temporary objective
- enemies have not started spawning yet

After prep ends:
- enemy pressure begins
- players can no longer place new defenses
- the temporary objective passively gathers the run reward

---

## Gate Layout Direction
Current likely direction:
- procedural gate maps with a defendable center area
- surrounding points of interest
- players temporarily leave safety to secure rewards or opportunities

This is intended to create a hybrid of:
- defense
- movement
- risk-taking
- map awareness

### Points of Interest may include:
- treasure nodes
- rare material deposits
- elite enemies
- temporary buffs
- side objectives
- milestone encounters

---

## Resource Categories
Gate runs should provide multiple reward types with different purposes.

### 1. Core Resource
Examples:
- gold
- energy
- scrap

Purpose:
- main base progression
- wall upgrades
- turret upgrades
- build radius growth
- town hall/core upgrades

Design rule:
- this is the primary reliable reward from gates

---

### 2. Exotic Materials
Examples:
- crystals
- rare ore
- volatile essence
- biome materials

Purpose:
- unlock fun gear
- unlock special weapons
- unlock turret or trap variants
- enable more unusual builds

Design rule:
- these should feel exciting and worth taking risks for

---

### 3. Components
Examples:
- targeting modules
- reinforced plating
- cooling systems
- power cores

Purpose:
- structure modifications
- special turret behavior
- traps and engineering upgrades

Design rule:
- components should support customization, not just raw progression

---

### 4. Temporary Run Rewards
Examples:
- temporary buffs
- short-term augments
- bonus drop effects
- stronger turrets for the current run only

Purpose:
- make each run feel different
- create memorable moments
- support on-the-fly adaptation

---

## Reward Distribution
Rewards should come from multiple sources.

Possible sources:
- passive objective generation
- milestone bar thresholds
- side objectives
- elite enemy kills
- treasure caches
- biome-specific nodes
- boss rewards
- successful extraction bonus

### Current Direction
The first confirmed prototype direction is:
- the temporary objective generates the core reward over time
- staying longer under rising pressure yields more reward
- the first prototype does not require an external reward node before extraction

---

## Milestone System
A milestone bar may fill during the run.

Possible sources of progress:
- time survived
- resource generated
- enemies defeated
- side objectives completed

At certain thresholds:
- bonus rewards are granted
- difficulty may escalate
- elite pressure may increase
- the player may unlock a stronger extraction payout

This system encourages:
- “just one more milestone”
- push-your-luck gameplay
- visible progression within a single run

---

## Difficulty Scaling
Enemy pressure should scale over time.

Possible scaling methods:
- spawn count
- enemy composition
- elite frequency
- enemy aggression
- spawn directions
- siege/flying pressure
- event triggers

Design rule:
- scaling should increase tension without turning into unreadable chaos

---

## Extraction
Players can attempt to leave with their rewards.

### Extraction Flow
1. player interacts with the temporary objective
2. objective stops generating new resources immediately
3. extraction countdown begins
4. players must survive until extraction completes
5. rewards are secured

### Intended Feel
Extraction should feel:
- urgent
- exciting
- dangerous
- rewarding

### First Prototype Direction
- extraction countdown is 5 seconds
- extraction is triggered at the temporary objective itself
- successful extraction secures the reward gathered so far

---

## Failure States
A gate run may fail by:
- temporary objective destroyed
- team wipe, if that rule is used
- failed extraction under active pressure

### Reward Loss Direction
Not finalized, but likely:
- partial reward loss rather than full wipe

Reason:
- preserves tension without making runs too frustrating

---

## Progress Persistence
Open design direction:
- procedural gate worlds may be revisit-able
- some progression in a gate region may persist

This is not yet finalized.

Possible persistent elements:
- unlocked milestones
- discovered regions
- world threat level
- local resource depletion/recovery
- starting difficulty tier

For the early prototype, this should remain simple.

---

## Biomes
Gates may differ by biome.

Biomes can affect:
- visuals
- enemy composition
- resource types
- hazards
- side objective types

Examples:
- forest
- frost
- lava
- void
- corrupted ruins
- mechanical wasteland

Design rule:
- biome should affect gameplay, not just appearance

---

## Co-op Considerations
Gate runs must work cleanly in co-op.

Requirements:
- shared objective state
- synchronized scaling
- extraction understood by all players
- fair reward presentation
- good readability under pressure

Authority rule:
- all real gate state is server-authoritative

Server handles:
- objective health
- enemy spawns
- milestone progress
- reward generation
- extraction state
- success/failure

---

## Early Prototype Scope
The first playable gate prototype should include:
- one gate map
- one temporary objective
- one enemy type
- time-based pressure scaling
- one main resource
- extraction countdown
- success/failure flow

---

## Future Extensions
Possible future additions:
- persistent gate-region progression
- biome mutators
- elite trigger events
- temporary deployables
- bosses
- special weather or hazards
- branching points of interest