# Gate System Specification

## Purpose
The Gate System provides persistent biome expedition zones that players revisit to gather resources, unlock footholds, and progress deeper over time.

Gates should feel different from main base raids:
- more exploratory
- more layered
- more about holding partially secured territory
- more about balancing external defense with internal cave progress
- less about one-time all-in defense

Gates are one of the main engines of progression for the main base.

---

## Design Goals
- Create replayable expedition spaces with persistence
- Reward deeper pushes rather than passive waiting
- Support co-op pressure split between overworld defense and cave exploration
- Feed resources and rare materials back into the main base
- Make failure meaningful through loss of control rather than inventory punishment
- Stay readable in 3D multiplayer

---

## Core Fantasy
Players enter a dangerous biome through a gate, capture pylons to create footholds, activate caves from those pylons, and then choose how much attention to give to defending the outside versus pushing deeper inside.

The key emotional loop is:
- enter
- scout
- secure a pylon
- activate a cave
- defend the outside pressure
- push deeper inside
- recover from setbacks and reclaim control
- return stronger next time

---

## Core Loop
1. Enter a persistent gate biome
2. Build a small defense footprint around an uncaptured pylon
3. Start the pylon claim channel when ready
4. Survive the claim waves and secure the foothold
5. Unlock the cave from the claimed pylon
6. Spend resources at the captured pylon to activate a cave expedition
7. Defend the pylon outside while exploring deeper inside the cave
8. Repair disabled pylons after failed cave attempts
9. Extract or return to base with progress and rewards

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
- pylon foothold objectives
- biome exploration enemies
- cave entrances tied to pylons
- local resources and rare materials
- recovery loops after failure

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
- more demanding pylon and cave pressure

### Deep Or Core Layer
- extreme difficulty
- elite encounters
- strongest cave rewards and progression opportunities

Players can attempt to go deeper early, but they are not expected to fully overcome those layers before their current tier supports it.

---

## Pylon Role Inside Gates
Pylons are the main foothold objectives inside gates.

Pylons define:
- safe local control
- defensive coverage area
- cave expedition access points
- recovery anchors after failure

Captured pylons are the bridge between overworld gate traversal and cave progression.

---

## Overworld Versus Cave Roles

### Overworld Gate Space
The overworld around a captured pylon is where:
- existing defenses are placed and reused
- claim and repair defense events happen
- enemies pressure the pylon during cave expeditions
- players may fight manually to stabilize the area
- repair and recovery gameplay happens after failure

### Cave Space
The cave is where:
- players push deeper for the main rewards
- enemies, encounters, and loot escalate by depth
- rare materials and final rewards are found

The design intent is that the cave produces the primary rewards, while the outside pylon area remains the defensive pressure point.

---

## Cave Activation Flow
At a captured pylon, players may begin a sustained channel that opens the cave entrance.

Activation flow:
1. claim the pylon first
2. interact again at the pylon to start the cave channel
3. open the magical barrier at the cave entrance
4. keep outside enemy pressure active and escalating while the cave stays open
5. interact again to stop the channel and close the cave entrance

The player does not build a new defense setup inside the cave.
The player relies on the existing defenses already placed around the pylon.

Before cave activation, the pylon must first be claimed through its own finite wave event.

---

## Building Rules In Gates
Building in gates is limited.

Core rules:
- only near captured pylons
- small tactical setups only
- not full fortress-scale construction
- cave expeditions reuse those existing defenses rather than allowing a second build phase inside the cave

Design reason:
- keeps the main base as the center of large-scale building
- preserves gate readability
- makes pylon capture meaningfully change the local space
- makes cave activation feel like committing an already-built foothold to pressure

---

## Rewards
Gate rewards should support longer-term progression.

Gate regions provide:
- a dependable progression resource
- rarer materials from deeper layers
- biome-specific materials
- components or special rewards later

During cave expeditions:
- the pylon generates passive resource gain only while the cave is actively open
- that passive gain ramps upward with the same outside pressure waves that escalate enemy danger
- deeper cave exploration provides the primary rewards
- final rewards should come from deeper encounters, chests, bosses, or equivalent payoff points

In the current prototype slice:
- the cave primarily acts as a sustained open-door pressure state
- enemy pressure keeps ramping while the cave remains open
- no real interior cave content exists yet

Design rule:
- passive gain must never outperform exploration rewards
- players should be incentivized to go deeper rather than wait outside
- leaving the cave open longer should feel greedier because both rewards and danger keep climbing together

---

## Failure And Recovery In Gates
Failure occurs when the pylon or linked expedition core is destroyed during an active cave expedition.

On failure:
- the cave collapses
- the barrier closes immediately
- the pylon becomes damaged

This failure does not remove player loot or inventory.
The consequence is loss of local control and safety.

---

## Damaged Pylon Consequences
When a pylon is damaged:
- all linked defenses become inactive
- turrets do not function
- safe-zone effects are disabled
- the area becomes hostile again

The pylon is not permanently lost, but the team loses control of that foothold until it is repaired.

Repair starts with a locked repair channel and then a lighter defense event.

---

## Persistence
Persistent gate progression may include:
- revealed map areas
- captured pylons
- damaged versus functional pylon state
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
- cave feel and encounter identity
- later mechanic identity

Biome mechanics are biome-specific, not global.

The first biome should stay simple and readable.
Later biomes may introduce stronger mechanics, such as environmental visibility pressure or traversal-specific constraints.

---

## Co-op Considerations
Gate expeditions must work cleanly in co-op.

Requirements:
- shared pylon state
- synchronized cave activation state
- clear outside-versus-inside pressure readability
- fair reward presentation
- good navigation clarity under pressure

Authority rule:
- all gate state is server-authoritative

Server handles:
- pylon capture state
- cave activation state
- damaged versus repaired pylon state
- enemy spawns
- map progression
- passive resource generation
- success and failure outcomes

---

## Early Prototype Direction
The early playable gate direction should prove:
- one persistent gate biome
- one basic pylon capture flow
- one cave activation flow from a captured pylon
- one simple outside-defense versus inside-exploration tension loop
- one damaged-pylon recovery loop
- one basic exploration enemy family
- construct enemies for pylon pressure

---

## Future Extensions
Possible future additions:
- multiple cave branches from a single foothold
- more layered cave events
- elite deep-layer encounters
- biome mutators
- gate-specific world-state changes
- stronger local progression systems
- special hazards or weather