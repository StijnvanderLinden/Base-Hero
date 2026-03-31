# Enemy System Specification

## Purpose
The Enemy System defines the hostile forces that attack the main base and gate objectives.

Enemies are the primary source of pressure and must support large-scale, readable 3D encounters.

---

## Design Goals
- Enemies must be readable in groups
- Roles should be tactically distinct
- Enemy pressure should support the base-defense fantasy
- The system must work in co-op and at scale
- Enemy state must be server-authoritative

---

## Core Fantasy
Enemies are not just targets. They are the force that tests the players’ planning, reactions, and teamwork.

The enemy system should create:
- pressure
- panic
- priority decisions
- breakthrough moments
- escalation

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

## Core Enemy Roles
Target role categories:
- melee runner
- tank / bruiser
- ranged attacker
- flying unit
- siege unit
- elite
- boss

Not all are needed in the first prototype.

---

## Melee Runner
### Purpose
- basic pressure unit
- fills crowd role
- attacks objectives or front lines

### Traits
- low health
- straightforward movement
- simple attack behavior

This should be the first prototype enemy.

---

## Tank / Bruiser
### Purpose
- absorbs fire
- pressures walls and defenses
- creates priority target decisions

### Traits
- high health
- slower movement
- strong breakthrough pressure

---

## Ranged Attacker
### Purpose
- adds positional threat
- punishes static defense or exposed players

### Traits
- lower durability
- attacks from a distance
- changes encounter texture

---

## Flying Unit
### Purpose
- bypasses walls or chokepoints
- forces players to react differently
- pressures neglected angles

### Traits
- ignores some ground defenses
- often fragile but disruptive

---

## Siege Unit
### Purpose
- threatens structures specifically
- tests fortress design
- creates “drop everything and kill this” moments

### Traits
- strong structure damage
- high priority
- slower or more specialized behavior

---

## Elites
### Purpose
- create threat spikes
- break routine
- reward focus and teamwork

Elites should:
- be identifiable
- do more than just have more HP
- change the feel of a wave

---

## Bosses
### Purpose
- major challenge
- memorable event
- progression or reward anchor

Bosses should:
- change player priorities
- interact with objectives and structures
- feel like a climax, not just a bigger normal enemy

---

## Targeting Behavior
Enemies may target:
- gate objective
- main base core
- walls
- turrets
- players in some situations

Design rule:
- targeting should reinforce the defense fantasy
- enemies should not constantly ignore objectives just to chase players

---

## Pressure and Scaling
Enemy pressure can scale via:
- count
- composition
- elite frequency
- spawn direction variety
- special waves
- boss events

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

Open balance question:
- exact scaling by player count is not finalized

---

## Future Extensions
Possible later additions:
- support enemies
- summoners
- shield enemies
- burrowers
- biome-specific mutations
- corruption events
- special raid-only enemies

---

## Early Prototype Scope
First enemy prototype should include:
- one melee enemy
- movement toward an objective
- simple objective damage
- simple health and death

Second prototype may add:
- one tank enemy
- one flying enemy