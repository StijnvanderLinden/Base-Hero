# Combat System Specification

## Purpose
The Combat System defines how players fight enemies and support defense during gates and main raids.

Combat must feel:
- responsive
- readable
- impactful
- scalable in co-op
- compatible with many enemies on screen

---

## Design Goals
- Players should feel active, not passive
- Combat should support the base-defense fantasy
- Weapons should create distinct playstyles
- Combat should remain understandable in large battles
- The system must be server-authoritative

---

## Core Fantasy
The player is not just building a fortress. The player is fighting inside the fortress, responding to threats, saving weak points, and helping the defense hold under pressure.

The combat role of the player is:
- crisis response
- priority target removal
- direct damage
- mobility under pressure
- support for structures and teammates

---

## Combat Role in the Game
Combat must work together with building and enemy pressure.

Players should:
- protect the core
- cover for weak defenses
- kill dangerous elites
- deal with flying or breakthrough threats
- create clutch survival moments

Combat should not completely replace structures, and structures should not completely replace combat.

---

## Combat Structure
Combat includes:
- player attacks
- enemy health
- damage application
- death resolution
- hit feedback
- future augments and special effects

---

## Weapon Philosophy
Weapons should create identity.

Possible weapon categories:
- rifle
- shotgun
- sword
- launcher
- beam weapon
- support/control tool

### Design goals for weapons
- clear role
- satisfying feel
- room for upgrades
- readable behavior in multiplayer

---

## Augment Philosophy
Weapons can be changed by augments.

Example augment directions:
- +1 projectile
- projectile pierce
- chain effect
- splash damage
- melee swings launch projectiles
- burn / slow / stun interactions
- on-kill or on-hit bonuses

### Design rule
Augments should feel exciting and transformative, not just tiny stat bumps.

---

## Combat Feel Goals
Combat should feel:
- sharp
- immediate
- reactive
- punchy
- readable

Avoid:
- floaty timing
- unclear hit confirmation
- too much visual clutter
- effects that hide enemy threats

---

## Attack Types
Possible attack types:
- hitscan
- projectile
- melee arc
- area burst
- placed support effect

For prototype simplicity:
- start with one straightforward attack type

---

## Damage Model
The server is authoritative for:
- final attack resolution
- enemy health changes
- death
- objective damage interactions
- reward outcomes tied to combat

Clients may:
- request attacks
- show local anticipation
- play effects
- present feedback

Clients must not:
- decide final damage
- decide enemy death
- award loot or rewards

---

## Hit Feedback
Combat needs good feedback.

Examples:
- enemy flash
- hit spark
- small knock reaction
- sound effect
- damage number later if useful
- death effect

Design rule:
- even prototype combat should feel readable when a hit connects

---

## Enemy Death
Enemy deaths should:
- be clear
- feel satisfying
- support large-scale readability

Different enemy classes may later need:
- stronger death effects
- armor break cues
- elite death cues

---

## Friendly Fire
Current default:
- no friendly fire between players
- no accidental allied structure damage unless explicitly designed later

This keeps co-op cleaner and more approachable.

---

## Co-op Considerations
Combat must remain readable with multiple players.

Requirements:
- all peers see consistent outcomes
- enemy deaths are synchronized
- large effect stacks do not obscure gameplay
- weapon roles can complement each other

Design goal:
- co-op should feel collaborative, not visually overwhelming

---

## Future Extensions
Possible future additions:
- active abilities
- ultimates
- support weapons
- status effects
- repair or shield tools
- combo interactions between players
- weapon-specific skill trees

---

## Early Prototype Scope
First combat prototype should include:
- one player weapon
- one attack type
- one enemy health system
- server-authoritative damage
- basic hit and death feedback

Do not build yet unless explicitly requested:
- full augment trees
- ammo economy
- deep status systems
- combo chains
- multiple weapon classes at once