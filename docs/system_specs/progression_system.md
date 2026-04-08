# Progression System Specification

## Purpose
The Progression System defines how long-term player and base growth unlocks stronger options without breaking the game’s core loop.

Progression must:
- reinforce the return-to-base loop
- support both player power and base power
- give gates meaningful reward value through pylon channeling
- unlock deeper build expression over time

---

## Design Goals
- Preserve the base as the progression anchor
- Keep gold and essence in clearly different roles
- Let players improve themselves as well as the base
- Make pylon milestones and deeper gate pushes feed future build potential
- Avoid overwhelming the early prototype with too many systems at once

---

## Core Progression Structure
Progression is split between:
- tactical run economy
- long-term progression economy

Tactical run economy uses gold for:
- building defenses
- starting repeat pylon channel attempts

Long-term progression economy uses pylon rewards for:
- banked essence
- research points
- major rewards such as augments or unlocks

Base progression improves:
- core durability
- town hall tiering
- material unlock infrastructure such as forge advancement later

Player progression improves:
- active weapon expression
- augment capacity
- access to stronger material tiers
- access to higher-tier fused augments

---

## Gold Versus Essence
Gold is a tactical resource.

Gold is spent on:
- building defenses in a run
- starting a channel after the first free activation on a pylon

Essence is a progression resource.

Essence is earned through:
- safe milestone rewards during channeling
- vulnerable generated essence accumulated while a channel remains active

Design rule:
- gold should pressure short-term tactical choices
- essence should drive long-term progression decisions

---

## Milestone Rewards
Channeling milestones define the most reliable progression payouts.

Reward structure:
- 1/3 grants a large banked essence reward
- 2/3 grants more banked essence plus one research point
- 3/3 grants a major reward such as an augment or unlock

Milestone rules:
- milestone rewards are always safe
- milestone rewards are banked immediately
- milestone rewards bypass essence capacity

This keeps progress feeling meaningful even when a run ends badly.

---

## Generated Essence And Capacity
Generated essence accumulates over time during active channeling.

Scaling:
- Phase 1 uses the base rate
- Phase 2 increases generation to about 2.5x
- Phase 3 increases generation to about 5x

Capacity rules:
- stored essence is capped by essence capacity
- overflow is lost
- only generated essence is subject to the cap

Generated essence remains a risk-bearing resource until it is secured through shutdown completion or another safe banking rule defined by the runtime.

---

## Research Points
Research points are milestone rewards tied to deeper pylon commitment.

Current role:
- unlock broader progression options than raw essence alone
- pace new systems, upgrades, or unlock branches
- reward pushing beyond the first safe milestone

Research points should feel rarer and more strategic than essence.

---

## Major Rewards
Full channel completion grants a major reward.

Possible major rewards include:
- augments
- permanent unlocks
- access tokens for stronger future options

Major rewards should create visible spikes in build expression rather than acting as simple numeric payouts.

---

## Weapon Progression Hooks
The modular weapon system should connect to progression through:
- weapon type choice or unlock order
- increased augment slot capacity
- higher material tier access
- improved access to fusion tiers or fusion facilities
- major reward unlocks earned from full pylon channels

The player should feel that returning to base with rewards directly expands how the active weapon can evolve.

---

## Material Progression
Material progression should be tied to forge or equivalent base-side unlocks.

Rules:
- materials are slotted directly into the weapon system
- players do not manually craft weapon shapes from those materials
- stronger or more specialized materials unlock through progression

This keeps progression focused on expanding options rather than replacing the entire weapon.

---

## Augment Progression
Augment progression should include:
- greater slot capacity
- stronger augment tiers through fusion
- broader access to synergistic combinations
- full-channel rewards that meaningfully change build options

The player’s build identity should become more complex over time because the system allows more meaningful combinations, not because the player is forced to abandon the old weapon.

---

## Base Versus Player Investment
Progression choices should create tension between:
- improving the main base
- improving the player’s weapon platform

This supports the game’s central loop:
- bring resources home
- choose whether to strengthen the base or the player
- prepare for harder gates and raids

Research points and major rewards should widen the available choice space, while essence should remain the steady resource that funds core upgrades.

---

## Co-op Progression Goals
Progression should support team diversity.

Desirable outcomes:
- one player invests into melee control identity
- one player invests into ranged pressure identity
- one player invests into elemental or utility identity

The progression system should support complementary builds instead of flattening all players into the same strongest option.

---

## Early Scope Boundaries
Do define now:
- progression hooks for gold, essence, research points, and major rewards
- base-versus-player investment tension
- essence capacity as a pacing lever
- the distinction between safe milestone rewards and vulnerable generated essence

Do not fully define yet:
- full progression tree structure
- exact economy values
- exact unlock order per tier
- every base building tied to progression

This system should remain a high-level progression truth document until the first implementation slice is requested.