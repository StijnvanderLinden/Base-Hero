# Game Design Document (GDD)

## High Concept
This project is a 3D co-op base defense action game where players defend a central base against major raids and enter dangerous gate missions to gather the resources needed to survive and progress.

The game combines:
- active player combat
- objective defense
- base building
- risk-versus-reward extraction gameplay
- co-op progression

The game is not intended to be a generic open-world survival sandbox.
Its identity is built around meaningful defense, escalating pressure, and progression through raids and gate runs.

---

## Core Player Fantasy
Players should feel like:
- defenders of a meaningful fortress
- fighters who actively save collapsing situations
- co-op survivors pushing their luck in dangerous missions
- builders who improve a base over time
- players making meaningful choices between personal power and base power

---

## Core Gameplay Loop
The main gameplay loop is:

1. Prepare and upgrade the main base
2. Enter a gate run
3. Defend a temporary objective while under pressure
4. Secure resources and high-value rewards
5. Decide when to extract
6. Return to the main base
7. Invest rewards into player power or base power
8. Survive the next major raid
9. Unlock the next stage of progression

This loop is the central structure that all major systems should support.

---

## Main Game Modes

### Main Base
The main base is the long-term defensive home of the player group.

It is:
- the central objective of the broader progression loop
- the place where long-term building matters
- the location of major raids
- the anchor of emotional and strategic investment

At the main base, players:
- upgrade defenses
- build and improve structures
- prepare for raids
- invest resources into progression

---

### Gate Runs
Gate runs are instanced missions that players enter to gather resources and pursue higher-risk rewards.

Gate runs are designed to be:
- tense
- replayable
- more reactive than main raids
- more opportunistic than prepared
- strongly centered on risk-versus-reward decisions

A gate run includes:
- a temporary objective such as a drill or portable core
- enemy pressure that scales over time
- external opportunities for higher-value rewards
- an extraction decision

Gate runs are not intended to replace main raids. They support main-raid progression and provide a different gameplay rhythm.

---

## Main Base Gameplay
The main base should be a meaningful place, not just a storage hub.

It should matter as:
- an objective
- a strategic defense space
- a progression anchor
- a visual representation of player investment

The main base may include:
- a central core or town hall
- walls
- turrets
- support structures
- future utility or power systems

Major raids test everything the players have prepared.

---

## Gate Gameplay
Gate gameplay should differ from main-base raid gameplay.

Gates should feel:
- more temporary
- more dangerous
- more greedy
- more reactive
- more about deciding when to leave

The intended tension of a gate is:
- defend the central temporary objective
- leave safety to claim better rewards
- survive increasing pressure
- decide when greed becomes too dangerous

---

## Extraction
Extraction is one of the defining mechanics of gate runs.

Players should be able to:
- attempt to leave the gate voluntarily
- trigger an extraction countdown
- survive a dangerous final pressure window
- secure rewards if successful

Extraction should create:
- urgency
- panic
- clutch moments
- “one more push” decision making

---

## Progression
Progression is split between two major targets:

### Player Power
Players may improve:
- weapons
- augments
- abilities
- personal combat options
- mobility or survivability tools

### Base Power
Players may improve:
- walls
- turrets
- support systems
- build radius
- core/town hall tiers
- structure effectiveness

A core strategic tension of the game is:
**do we invest in ourselves, or in the base?**

That choice is central to the game’s identity.

---

## Resource Direction
Gate runs provide rewards that support progression.

The current reward direction includes:

### Core Resource
A main currency used for dependable progression.
Possible uses:
- wall upgrades
- turret upgrades
- build-radius growth
- town hall/core upgrades

### Exotic Materials
Rare or unusual materials used for:
- fun weapons
- special gear
- unusual defense unlocks
- turret/trap variants

### Components
Engineering-like parts used for:
- structure modifications
- special turret behavior
- advanced trap or support systems

### Temporary Run Rewards
Run-only rewards that make a specific gate run more exciting or more survivable.

The exact final resource model may evolve, but rewards should always support meaningful choices and encourage risk-taking.

---

## Combat
Combat is active and player-driven.

Players are not passive defenders. They should:
- respond to dangerous moments
- kill priority threats
- save weakened defenses
- cover against enemies that bypass structures
- create clutch turns in battle

Combat should work with base defenses, not replace them.

---

## Building
Building is one of the project’s core pillars.

Players should be able to shape the battlefield through:
- walls
- turrets
- support structures later

Building should feel:
- strategic
- readable
- impactful
- cooperative

The game should preserve the fantasy of building something worth defending.

---

## Enemies
Enemies are the force that creates pressure and tests player preparation.

Enemy encounters should support:
- role clarity
- tactical priority
- scaling pressure
- readability in co-op and 3D

Enemy roles may eventually include:
- melee attackers
- tanks
- ranged units
- flying units
- siege threats
- elites
- bosses

---

## Raids
Major raids are the progression milestones of the game.

A major raid should feel like:
- a test of the current base
- a climax of the current progression stage
- the moment where preparation is paid off or exposed as weak

Raids are expected to include:
- larger enemy pressure
- more structured defense needs
- stronger threat compositions
- bosses or climactic encounters

---

## Multiplayer
The game is fundamentally co-op.

Multiplayer should support:
- shared pressure
- teamwork
- role flexibility
- collaborative defense
- cooperative survival moments

The intended multiplayer model is:
- one player hosts
- the host acts as the authoritative server
- other players join as clients

The game should eventually support online co-op smoothly, with future Steam integration in mind.

---

## Design Goals
The game should aim for:
- intense defense gameplay
- meaningful choices
- strong co-op moments
- memorable panic-and-recovery moments
- satisfying progression
- a clear difference between gate runs and main-base raids
- systems that stay readable in large 3D encounters

---

## Design Boundaries
The project should avoid drifting into:
- generic open-world survival
- deep crafting complexity too early
- excessive inventory management
- passive tower defense with weak player agency
- feature bloat that weakens the core loop

The heart of the game is:
- defend
- fight
- risk more
- extract
- upgrade
- survive the next raid