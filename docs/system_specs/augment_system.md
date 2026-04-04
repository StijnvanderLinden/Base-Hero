# Augment System Specification

## Purpose
The Augment System defines how the active weapon gains gameplay-changing behavior through slotted modifications, capacity limits, removal rules, and fusion upgrades.

The augment system must:
- encourage experimentation
- create strong synergies
- support long-term weapon growth
- avoid becoming only a flat stat system

---

## Design Goals
- Let players build a clear weapon identity
- Encourage interesting combinations rather than isolated stat stacking
- Scale into later horde combat without needing many separate weapons
- Give co-op players reasons to specialize differently
- Keep individual augments simple enough to understand quickly

---

## Core Concept
Augments modify how the player’s active weapon behaves.

They do not replace the weapon.
They reshape it.

Each augment uses slot cost.
Each weapon has limited augment capacity.

The player creates a build by fitting synergistic augments into the available capacity budget.

---

## Slot Capacity System
Weapons have limited augment slot capacity.

Rules:
- each augment has a slot cost from 1 to 5
- total equipped cost cannot exceed weapon capacity
- capacity increases through progression

Design purpose:
- force tradeoffs between breadth and specialization
- prevent every augment from being stacked at once
- make progression feel meaningful when capacity increases

---

## Augment Philosophy
Augments should change gameplay behavior, not only numbers.

Primary focus areas:
- projectile behavior
- AoE behavior
- chaining or spread behavior
- melee pattern changes
- utility effects
- active ability additions where appropriate

Design rule:
- each augment should be understandable on its own
- the strongest outcomes should come from combining augments that interact well together

---

## Starter Augment List
The first defined augment set is:

1. Extra Projectile
2. Extended Range
3. Cleave
4. Pierce
5. Bounce
6. Elemental Infusion
7. On-Hit Explosion
8. Whirlwind
9. Attack Speed Boost
10. Pull Effect

These should be treated as the first stable design set, not a complete final catalog.

---

## Starter Augment Directions

### Extra Projectile
- increases projectile count or split output
- best used for ranged or magic patterns

### Extended Range
- pushes melee reach, projectile lifespan, or effective cast distance
- increases safety and area control indirectly

### Cleave
- broadens melee hit coverage or nearby secondary hit behavior
- supports front-line crowd control

### Pierce
- lets attacks continue through targets or weak barriers
- improves lane pressure and grouped-target efficiency

### Bounce
- redirects attacks to secondary targets or surfaces
- improves multi-target coverage in crowded fights

### Elemental Infusion
- adds or changes elemental behavior tied to the weapon’s active material identity
- should create interaction hooks rather than only damage gain

### On-Hit Explosion
- adds localized burst payoff on confirmed hits
- improves clustered-target damage and setup potential

### Whirlwind
- grants an active spinning melee or close-range burst behavior
- should feel more like a new action than a passive stat buff

### Attack Speed Boost
- increases action frequency or firing cadence
- should materially change rhythm, not only marginal DPS math

### Pull Effect
- groups enemies slightly toward impact or hit center
- supports AoE setups, control, and combo play

---

## Suggested Starter Slot Costs
Early design direction for slot budgeting:
- Extra Projectile: 3
- Extended Range: 1
- Cleave: 2
- Pierce: 2
- Bounce: 3
- Elemental Infusion: 2
- On-Hit Explosion: 4
- Whirlwind: 5
- Attack Speed Boost: 2
- Pull Effect: 3

These costs are starting design values, not locked balance numbers.

---

## Synergy Philosophy
The system should reward combinations such as:
- Extra Projectile + Pierce for lane pressure
- Pull Effect + On-Hit Explosion for grouped burst
- Cleave + Attack Speed Boost for sustained melee control
- Bounce + Elemental Infusion for chain-based elemental coverage

The goal is to make the player feel like they are engineering a weapon behavior package rather than simply equipping stronger stats.

---

## Removal System
Players may remove augments from the active weapon.

Rules:
- removal requires a resource cost
- removal outcome is not fully fixed yet
- current valid design options are:
  - augment is destroyed on removal
  - augment is returned with penalty

Design intent:
- allow experimentation
- avoid harsh permanent punishment
- preserve enough friction that choices still matter

Current direction:
- keep both return models open until the economy and progression context are clearer

---

## Fusion System
Augments can be upgraded through fusion.

Fusion rules:
- 3 × Level 1 becomes 1 × Level 2
- 3 × Level 2 becomes 1 × Level 3

Fusion should not only increase numbers.
It must introduce new behavior.

---

## Fusion Behavior Philosophy
Higher-tier augments should evolve behavior patterns.

Examples:
- Extra Projectile gains spread pattern shaping or smarter distribution
- On-Hit Explosion gains chain explosions or secondary blasts
- Pull Effect gains stronger grouping or wider capture radius
- Bounce gains additional logic such as prioritized redirection or repeated chaining

Design goal:
- keep low-tier augments relevant as ingredients
- make higher-tier augments feel qualitatively different, not just stronger

---

## Progression Hooks
Augments connect to progression through:
- increased slot capacity
- access to higher augment tiers
- fusion unlocks
- material and augment combinations becoming more meaningful at higher progression stages

The augment system should give players long-term goals without requiring many full weapon replacements.

---

## Co-op Goals
Augments should help different players specialize.

Examples of co-op differentiation:
- one player focuses on grouping and control
- one player focuses on projectile spread and ranged coverage
- one player focuses on melee crowd clearing or burst

The system should support complementary weapon identities inside the same team.

---

## Early Scope Boundaries
Do define now:
- slot-cost system
- starter augment list
- starter slot-cost direction
- removal rules
- fusion rules
- behavior-first augment philosophy

Do not fully define yet:
- full drop tables
- full economy balance for augment acquisition
- exact tier-3 behavior for every augment
- large augment catalogs beyond the starter set

The first implementation slice should stay modular, readable, and expandable.