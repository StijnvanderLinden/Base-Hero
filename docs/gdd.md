# Game Design Document (GDD)

## High Concept
This project is a 3D co-op base defense action game centered on a main base, player-triggered raids, and persistent gate expeditions that feed long-term progression.

The game combines:
- active player combat
- objective defense
- base building
- intentional raid escalation
- persistent gate exploration
- co-op progression

The game is not intended to be a generic open-world survival sandbox.
Its identity is built around meaningful defense, escalating pressure, and progression through gate expeditions, town hall upgrades, and large raids.

---

## Core Player Fantasy
Players should feel like:
- defenders of a meaningful fortress
- fighters who actively save collapsing situations
- builders who improve a base over time
- explorers pushing deeper into dangerous gate biomes
- players choosing when they are ready to trigger the next major raid

---

## Core Gameplay Loop
The main gameplay loop is:

1. Prepare and upgrade the main base
2. Enter a persistent gate biome
3. Explore, capture pylons, and gather materials
4. Return to the main base with resources and unlock options
5. Start a town hall upgrade when ready
6. Defend the base during the triggered major raid
7. Complete the upgrade and unlock the next tier if successful
8. Rebuild, improve, and push deeper into gates for the next checkpoint

This loop is the central structure that all major systems should support.

---

## Main Game Modes

### Main Base
The main base is the long-term defensive home of the player group.

It is:
- the center of the broader progression loop
- the place where long-term building matters most
- the location of major raids
- the anchor of emotional and strategic investment

At the main base, players:
- build and improve defenses
- unlock stronger weapons and structures
- prepare town hall upgrades
- choose when to trigger raid checkpoints

### Gate Expeditions
Gate expeditions are persistent biome regions that players revisit over time.

Gate expeditions are designed to be:
- layered
- replayable
- more exploratory than raids
- more reactive than prepared
- strongly centered on risk-versus-reward decisions

A gate region includes:
- multiple depth layers
- pylon objectives
- biome-specific enemies and mechanics
- resources and rare materials
- safe footholds earned through progress

Gate expeditions are not intended to replace raids. They support raid progression and provide the exploration and resource-gathering side of the loop.

---

## Main Base Gameplay
The main base should be a meaningful place, not just a storage hub.

It should matter as:
- an objective
- a strategic defense space
- a progression anchor
- a visual representation of player investment

The main base includes:
- a central town hall or main core
- walls
- turrets
- support structures later
- upgrade-dependent tech progression

Major raids are the main test of everything the players have prepared.

---

## Town Hall Upgrades And Raids
Raids are not automatic.

Raids only begin when players start upgrading the town hall.

The town hall upgrade flow is:
1. gather required materials from gates
2. start the town hall upgrade through a channeling process
3. trigger a major raid immediately
4. defend the base until the event resolves
5. complete the upgrade and unlock a new tier if successful

If players fail:
- the upgrade does not complete
- the base can be damaged and structures can be destroyed
- players keep their gathered materials
- players rebuild and try again later

These raids are intentional progression checkpoints, not random interruptions.

---

## Gate Gameplay
Gate gameplay should differ from main-base raid gameplay.

Gates should feel:
- more exploratory
- more layered
- more risky when pushing deeper
- more about creating footholds over time
- more about deciding what depth the team can handle

The intended tension of a gate is:
- establish a foothold
- capture pylons under pressure
- drill for rewards at secured positions
- push deeper than feels safe
- return later if the current depth is too dangerous

Players are not expected to fully clear a gate in one tier.
They should revisit the same gate and progress deeper over time.

---

## Pylons And Drills
Pylons are the main objectives inside gates.

Capturing a pylon should:
- trigger a defense event
- spawn engineered construct enemies
- create a safer foothold on success
- reveal local map space
- unlock fast travel or return options
- allow limited local building

Drills are placed at captured pylons.
They:
- trigger escalating waves
- generate increasing rewards
- create a push-your-luck defense loop
- let players choose when to stop

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
- town hall tiers
- structure effectiveness
- base survivability and tech access

A core strategic tension of the game is:
**do we invest in ourselves, or in the base?**

That choice is central to the game’s identity.

---

## Resource Direction
Gate expeditions provide the materials required for progression.

The reward direction includes:

### Core Resource
A dependable progression currency used for repeatable growth.

### Rare Materials
Layer-specific or biome-specific resources used for stronger unlocks and town hall progression.

### Components
Parts used for special defenses, weapon upgrades, or structure variants.

The exact final economy may evolve, but gate rewards should always support meaningful choices and raid readiness.

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

At the main base, building is long-term and central.
Inside gates, building is limited, local, and tied to captured pylons.

---

## Enemies
Enemy design is split into two categories.

### Gate Exploration Enemies
These enemies belong to the biome and pressure players during exploration.

They may include:
- wildlife
- goblins
- corrupted creatures
- biome-specific threats

### Engineered Construct Enemies
These enemies appear in:
- pylon defense events
- main base raids

Constructs should feel:
- organized
- engineered
- fantasy-built rather than sci-fi
- readable in silhouette and role

Construct roles include:
- small swarm units
- shield units
- heavy breakers
- siege units
- elites

---

## Biomes
Gate mechanics are biome-specific, not global.

The first biome should be:
- simple
- readable
- mechanically clean
- low on gimmicks

Later biomes may introduce stronger identity through unique mechanics such as visibility pressure, environmental threats, or traversal constraints.

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
- intentional raid progression
- meaningful gate exploration
- strong co-op defense moments
- satisfying growth in both player power and base power
- readable large-scale encounters
- a clear difference between gate expeditions and main-base raids

---

## Design Boundaries
The project should avoid drifting into:
- generic open-world survival
- fully clearing giant gates in a single pass by default
- automatic raid timers that remove player choice
- deep crafting complexity too early
- excessive inventory management
- passive tower defense with weak player agency
- feature bloat that weakens the core loop

The heart of the game is:
- build
- explore
- trigger the next test
- defend
- upgrade
- push deeper