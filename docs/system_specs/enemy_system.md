# Enemy System Specification

## Purpose
The Enemy System defines the hostile forces that pressure players in gate exploration, pylon defense events, and main base raids.

Enemies are the primary pressure source and must support large-scale, readable 3D encounters.

---

## Design Goals
- Enemies must be readable in groups
- Roles should be tactically distinct
- Enemy pressure should reinforce the defense fantasy
- Exploration and raid enemies should feel meaningfully different
- The system must work in co-op and at scale
- Enemy state must be server-authoritative

---

## Core Split
Enemy design is split into two categories.

### 1. Gate Exploration Enemies
These enemies are found while exploring gates.

They are:
- biome-driven
- more natural or local to the region
- part of traversal and exploration pressure

Examples are not locked, but may include:
- wildlife
- goblins
- corrupted creatures
- biome-specific monsters

### 2. Engineered Construct Enemies
These enemies are used in:
- pylon defense events
- main base raids

They are:
- organized
- deliberate
- built for assault or defense pressure
- visually more structured than exploration enemies

This split is a core rule of the system.

---

## Construct Design Philosophy
Construct enemies should feel fantasy-engineered rather than sci-fi.

They may be built from:
- wood
- stone
- metal

They are powered by magical cores and should prioritize:
- low-poly readability
- strong silhouettes
- clear gameplay roles

---

## Enemy Design Principles
Every enemy should have:
- a clear role
- clear threat pattern
- readable silhouette or behavior
- understandable counterplay

Avoid:
- too many subtle variants early
- visually confusing enemy behavior
- designs that become unreadable in groups

---

## Exploration Enemy Direction
Exploration enemies should create:
- biome identity
- roaming danger
- unpredictability
- pressure while moving through a space

They do not need to behave like organized siege forces.

---

## Construct Roles
Construct visuals are not locked, but their gameplay roles are.

### Small Units
Purpose:
- fast swarm pressure
- fill the frontline attack role

Traits:
- quick movement
- low durability
- simple group threat

### Shield Units
Purpose:
- protect other constructs
- slow direct damage races

Traits:
- defensive posture
- damage blocking or absorption
- formation value

### Heavy Units
Purpose:
- break walls
- force focused fire
- create line-collapse pressure

Traits:
- slow movement
- high health
- strong structure damage

### Siege Units
Purpose:
- pressure structures from range
- punish static defense setups

Traits:
- ranged attacks
- structure-focused threat
- high priority target value

### Elite Units
Purpose:
- create threat spikes
- break routine
- demand teamwork and attention

Traits:
- rare appearance
- special abilities
- high threat presence

---

## Usage Rules
Exploration enemies are used for:
- gate traversal
- ambient biome pressure
- local encounters while moving through layers

Construct enemies are used for:
- pylon capture defense events
- drills when applicable
- full-scale base raids

Pylons should usually use smaller or medium construct encounters.
Raids should escalate to full construct armies with broader role mixes.

---

## Targeting Behavior
Enemies may target:
- pylons
- drills
- main base core or town hall
- walls
- turrets
- players in some situations

Design rule:
- targeting should reinforce the defense fantasy
- exploration enemies may feel looser or more opportunistic
- construct enemies should feel more organized and objective-driven

---

## Pressure And Scaling
Enemy pressure can scale via:
- count
- composition
- elite frequency
- role combinations
- spawn direction variety
- special raid waves

Design rule:
- increase tactical complexity, not just raw stat inflation

---

## Server Authority
The server is responsible for:
- spawning enemies
- AI decisions
- health
- damage dealt
- target decisions
- death resolution

Clients may:
- display enemy state
- show local effects
- request attacks against enemies through combat systems

Clients must not:
- decide enemy death
- decide enemy damage
- spawn enemies

---

## Co-op Considerations
Enemy pressure must stay fair and readable in co-op.

Design goals:
- multiple players should have meaningful roles
- threat priority should stay understandable
- fights should remain readable with many enemies
- exploration and raid encounters should each have a clear rhythm

Open balance question:
- exact scaling by player count is not finalized

---

## Early Prototype Direction
Early prototype focus should include:
- one simple exploration enemy family for the first biome
- one basic construct unit for pylon and raid pressure
- clean distinction between ambient exploration pressure and organized event pressure

---

## Future Extensions
Possible later additions:
- more exploration families per biome
- more construct roles and combinations
- support enemies
- summoners
- boss constructs
- biome-specific mutations
- special raid-only enemy mixes