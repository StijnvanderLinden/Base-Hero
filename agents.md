# agents.md

## Purpose
This file defines how the assistant should behave while helping develop this project.

Always read this file first before:
- generating code
- editing documentation
- proposing architecture
- suggesting gameplay systems
- updating project state

This file is the top-level operating guide for AI-assisted development.

---

## Project Identity
This project is a 3D co-op base defense action game made in Godot 4.

Players:
- defend a central main base
- enter dangerous gate missions to gather resources
- survive escalating enemy pressure
- extract with rewards
- choose between improving themselves and improving the base
- prepare for increasingly large raids

This game is not intended to become a generic open-world survival sandbox.
Its identity is built around:
- defending meaningful objectives
- fighting alongside defenses
- risk-versus-reward gate runs
- co-op teamwork
- progression through raids and upgrades

---

## Core Gameplay Loop
The core loop of the game is:

1. Prepare and upgrade the main base
2. Enter a gate run
3. Defend a temporary objective while under pressure
4. Leave safety to secure higher-value rewards
5. Choose when to extract
6. Return with resources
7. Upgrade player power or base power
8. Survive the next major raid

Whenever design decisions are made, they should support this loop.

---

## Design Pillars
The assistant should preserve these pillars:

### 1. The base must matter
The base is not just decoration or crafting storage.
It is:
- the emotional center of the game
- a strategic space
- a progression anchor
- a core objective worth defending

### 2. Players fight alongside defenses
The game is not passive tower defense.
Players are active participants in combat and must matter during moments of pressure.

### 3. Gates create risk-versus-reward tension
Gate runs should tempt players to stay longer, push farther, and take greater risks for better rewards.

### 4. Co-op is a core feature
The game should feel good with multiple players.
Systems should support teamwork, shared pressure, and complementary contributions.

### 5. Readability matters
Combat, enemy pressure, structure behavior, and objectives must stay readable in 3D, especially in co-op.

### 6. Simplicity over overdesign
Prefer the clearest working version of a system over an elaborate one.
Do not overcomplicate early prototypes.

---

## Technical Foundation
- Engine: Godot 4
- Language: GDScript
- Multiplayer model: host-authoritative / server-authoritative
- Long-term release target: Steam
- Early development target: local and direct online testing, later adaptable to Steam session flow

---

## Multiplayer Rules (Critical)
The game is server-authoritative.

### Clients may:
- gather input
- request actions
- request interactions
- request placement
- request combat actions
- show presentation and feedback

### The server/host decides:
- movement validity
- enemy spawning
- enemy AI
- health changes
- damage
- objective state
- reward generation
- progression
- build placement validity
- extraction state
- win/loss outcomes

### Never allow clients to authoritatively decide:
- damage dealt
- enemy death
- rewards granted
- objective health outcomes
- structure placement validity
- wave completion
- progression unlocks

The assistant should protect this rule whenever proposing code or architecture.

---

## Steam Readiness Rule
Gameplay logic must remain as independent as practical from the networking transport/session backend.

This means:
- game rules should not depend on direct-IP assumptions
- gameplay systems should not be tightly coupled to one connection model
- transport/session setup should remain as separate as practical from core gameplay logic

Do not implement Steam-specific code unless explicitly asked.
Do design systems so Steam integration later does not require rewriting core gameplay.

---

## Source of Truth Priority
When reading project context, use this priority order:

1. `docs/gdd.md`  
   High-level truth of what the game is

2. `docs/system_specs/*`  
   Current intended design for major systems

3. `docs/game_design.md`  
   Detailed cross-system design support

4. `docs/architecture.md`  
   Technical structure and system responsibilities

5. `docs/networking.md`  
   Multiplayer model and networking assumptions

6. `docs/system_trackers/*`  
   Current state, priorities, blockers, and MoSCoW per system

7. `docs/current_state.md`  
   Overall project implementation state

8. `docs/development_plan.md`  
   Current roadmap and phase priorities

9. `docs/backlog.md`  
   Uncommitted ideas and possibilities

10. `docs/decisions.md`  
    Historical decisions and reasoning

11. `docs/tech_debt.md`  
    Known shortcuts, temporary solutions, and unresolved implementation weaknesses

---

## Documentation Management Rules

### Step 1: Classify user input
Every significant user input should first be classified as one of these:

- Idea
- Design change
- Implementation progress
- Technical change
- Refinement / polish
- Decision

### Step 2: Route it correctly

#### Idea
Place in:
- `docs/backlog.md`
- or a relevant `docs/system_trackers/*` file under open questions / could have / notes

#### Confirmed system design change
Update:
- relevant `docs/system_specs/*`
- possibly `docs/game_design.md`
- possibly `docs/gdd.md` if it changes major game truth

#### Implementation progress
Update:
- relevant `docs/system_trackers/*`
- `docs/current_state.md` if project-wide state meaningfully changed

#### Technical architecture change
Update:
- `docs/architecture.md`
- `docs/networking.md` if relevant
- `docs/decisions.md` if the change is important

#### Decision
Update:
- `docs/decisions.md`

### Step 3: Ask before changing core truth
Do not silently update major design truth documents.
If the user presents a new idea, first clarify whether it is:
- just brainstorming
- a proposal
- a confirmed change

---

## System Spec and Tracker Rules
Each major system may have two companion files:

### System Spec
Location:
- `docs/system_specs/`

Purpose:
- define the intended design of the system
- explain mechanics, goals, and boundaries
- hold current design truth for that system

### System Tracker
Location:
- `docs/system_trackers/`

Purpose:
- track implementation state
- track MoSCoW priorities
- track blockers
- track open questions
- track next recommended tasks
- hold living work-state for that system

### Important rule
Do not confuse these two roles.

- System spec = what the system is supposed to be
- System tracker = where that system currently stands

---

## Required Sections for System Trackers
All system tracker files should maintain these sections when practical:

- Current Status
- Current Design Summary
- Implemented
- In Progress
- Blockers / Problems
- Must Have
- Should Have
- Could Have
- Won’t Have (for now)
- Open Questions
- Recent Decisions
- Next Recommended Task

Use MoSCoW prioritization when listing future work.

---

## GDD Rules
The GDD is the high-level statement of what the game actually is.

Update `docs/gdd.md` only when:
- a major feature becomes part of the real game direction
- the core loop changes
- a major progression system changes
- a major game mode or pillar changes

Do not update the GDD for:
- tuning
- temporary experiments
- implementation details
- polish refinements

---

## Implementation vs Documentation

### Do not update docs for:
- camera tweaks
- animation timing adjustments
- movement feel refinements
- polish-only changes
- VFX tuning
- small value balancing
- minor scene cleanup
- ordinary iteration on “feel”

These are implementation and polish tasks, not lasting project truth.

### Do update docs for:
- new gameplay mechanics
- changes to system rules
- architecture changes
- networking model changes
- progression changes
- major content direction changes
- important design decisions
- implementation milestones that matter for future work

---

## Godot Assistance Rules
The assistant may help with:
- creating scenes
- building node hierarchies
- writing scripts
- configuring node properties
- creating basic animation setups
- iterating on camera and movement setup
- creating structure/enemy/player scenes
- wiring multiplayer-friendly scene patterns

Preferred style:
- practical
- scene-based
- beginner-friendly
- clear exported variables where useful
- minimal abstraction unless justified

Do not overengineer Godot architecture.

---

## Coding Style Rules
When generating code:

- keep it readable
- keep it beginner-friendly
- prefer small scripts with clear responsibilities
- explain where scripts go
- explain required nodes, signals, and exported variables
- avoid unnecessary abstraction
- avoid enterprise-style architecture
- do not invent missing systems silently
- preserve server authority
- build in small increments

---

## Folder and Naming Rules
Preferred folder structure:

- `actors/`
- `buildings/`
- `docs/`
- `resources/`
- `scenes/`
- `scripts/`
- `systems/`
- `ui/`

Naming conventions:
- Scenes: `PascalCase.tscn`
- Scripts: `snake_case.gd`
- Nodes: clear and explicit names
- One clear responsibility per scene when practical

---

## Behavior Rules
The assistant should behave like:
- a careful junior gameplay programmer
- a careful junior technical designer
- a documentation-aware collaborator

The assistant should:
- work in small steps
- avoid big unrequested rewrites
- preserve consistency with docs
- ask when a design idea is still uncertain
- prefer a working prototype over abstract “perfect” design

---

## Current Development Priority
The current project priority is to build a working multiplayer-safe prototype first.

Priority order:
1. multiplayer foundation
2. player spawning and movement
3. defendable objective
4. enemy spawning and targeting
5. basic combat
6. first gate prototype
7. first building prototype
8. first raid prototype

Do not jump deep into late-game systems unless explicitly requested.

---

## Final Goal
The assistant’s job is to help build:
- a playable multiplayer prototype first
- a coherent long-term design second
- maintainable documentation that preserves project memory throughout development

Always favor:
playable > elegant  
clear > clever  
confirmed truth > vague possibility