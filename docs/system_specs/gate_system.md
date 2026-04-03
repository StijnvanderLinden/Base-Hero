# Gate System Specification

## Purpose
The Gate System provides persistent biome expedition zones that players revisit to gather resources, unlock footholds, and progress deeper over time.

Gates should feel different from main base raids:
- more exploratory
- more layered
- more opportunistic
- more about long-term depth progress
- less about one-time all-in defense

Gates are one of the main engines of progression for the main base.

---

## Design Goals
- Create replayable expedition spaces with persistence
- Reward risk-taking and deeper pushes
- Support co-op exploration and defense moments
- Feed resources and materials back into the main base
- Feel structurally different from raid gameplay
- Stay readable in 3D multiplayer

---

## Core Fantasy
Players enter a dangerous biome through a gate, push into deeper layers, capture pylons under pressure, establish footholds, and return later to go farther than before.

The key emotional loop is:
- enter
- scout
- secure ground
- survive a defense event
- extract with progress
- return stronger
- push deeper next time

---

## Core Loop
1. Enter a persistent gate biome
2. Explore the current reachable layer
3. Fight biome enemies while locating pylons and resources
4. Channel and defend a pylon capture event
5. Secure the area and unlock a foothold
6. Optionally deploy drills at captured pylons for escalating defense rewards
7. Extract or return to base
8. Re-enter later and progress deeper into the same gate

---

## Gate Structure
Each gate is one biome region.

Core rules:
- procedurally generated once
- revisited over multiple runs
- map persistence across visits
- permanent fog-of-war reveal within explored regions
- progress deeper over time instead of clearing everything in one visit

A gate contains:
- multiple depth layers
- pylon objectives
- biome exploration enemies
- local resources and rare materials
- footholds earned through capture success

Gates are not intended to be fully cleared in one tier.

---

## Layered Progression
Each gate contains multiple layers of escalating danger.

### Outer Layer
- easiest enemies
- starter pylons
- basic resources

### Mid Layer
- stronger enemies
- more complex encounters
- better rewards

### Inner Layer
- high difficulty
- rarer materials
- more demanding pylon events

### Deep Or Core Layer
- extreme difficulty
- elite encounters
- strongest resource and progression opportunities

Players can attempt to go deeper early, but they are not expected to fully overcome those layers before their current tier supports it.

---

## Pylon System
Pylons are the main objectives inside gates.

### Activation
Players begin a capture by channeling at a pylon.
This starts a defense event.

### Defense Event Rule
Pylon defense events spawn engineered construct enemies.

This is important because pylon events are organized defense moments, not just ambient biome pressure.

### Success
Capturing a pylon should:
- secure the local area
- reveal the surrounding map region
- unlock fast travel to that pylon
- unlock teleport or return access back to base
- allow limited building near that pylon

### Failure
Failure should end the event without permanently removing the pylon from the gate.
Players can regroup and try again later.

---

## Drill System
Drills are placed at captured pylons.

Drills:
- trigger escalating waves
- generate increasing rewards
- create a localized push-your-luck defense loop
- let players choose when to stop

Drills are not the same as pylon capture.
Pylon capture creates the foothold.
Drills exploit the foothold for rewards.

---

## Building Rules In Gates
Building in gates is limited.

Core rules:
- only near captured pylons
- small tactical setups only
- not full fortress-scale construction

Design reason:
- keeps the main base as the center of large-scale building
- preserves gate readability
- makes pylon capture meaningfully change the local space

---

## Rewards
Gate rewards should support longer-term progression.

Gate regions provide:
- a dependable progression resource
- rarer materials from deeper layers
- biome-specific materials
- components or special rewards later

Reward quality should generally improve with:
- gate depth
- pylon difficulty
- drill risk

---

## Persistence
Persistent gate progression may include:
- revealed map areas
- captured pylons
- unlocked travel points
- known routes and resource locations
- gate-specific world state later

This persistence is part of the core gate identity, not a side feature.

---

## Biomes
Each gate is tied to a biome.

Biome affects:
- visuals
- exploration enemy families
- local hazards
- material types
- later mechanic identity

Biome mechanics are biome-specific, not global.

The first biome should stay simple and readable.
Later biomes may introduce stronger mechanics, such as environmental visibility pressure or traversal-specific constraints.

---

## Co-op Considerations
Gate expeditions must work cleanly in co-op.

Requirements:
- shared pylon state
- synchronized map progress
- clear capture and drill event readability
- fair reward presentation
- good navigation clarity under pressure

Authority rule:
- all gate state is server-authoritative

Server handles:
- pylon capture state
- drill state
- enemy spawns
- map progression
- reward generation
- success and failure outcomes

---

## Early Prototype Direction
The early playable gate direction should prove:
- one persistent gate biome
- one basic pylon capture flow
- one limited drill reward loop
- one simple depth structure
- one basic exploration enemy family
- construct enemies for defense events

---

## Future Extensions
Possible future additions:
- more layered gate events
- elite deep-layer encounters
- biome mutators
- gate-specific world-state changes
- stronger local progression systems
- special hazards or weather