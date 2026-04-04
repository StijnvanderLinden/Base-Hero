# Weapon System Specification

## Purpose
The Weapon System defines how the player fights through a single evolving weapon rather than a growing inventory of separate weapons.

The system must:
- build long-term weapon identity
- stay readable in co-op combat
- connect cleanly to progression
- remain modular enough for later expansion
- avoid forcing players into constant weapon replacement

---

## Design Goals
- Give each player one durable weapon identity
- Support meaningful build differences through materials and augments
- Keep weapon growth compatible with horde-scale combat
- Preserve readability in 3D co-op battles
- Keep the system simple enough for early prototype implementation

---

## Core Concept
The player does not collect multiple active weapons.

Instead, the player chooses one weapon type and evolves it over time through:
- a material slot
- augment slots
- progression-based capacity and unlocks

The weapon should feel like a long-term player-owned platform rather than disposable loot.

---

## Weapon Identity Philosophy
Weapons should create identity through:
- base weapon type
- inserted material
- chosen augment package
- progression unlocks that expand build options

The intended result is:
- one player may become a cleaving melee pressure fighter
- one player may become a chaining ranged controller
- one player may become an elemental utility caster

The system should encourage build diversity without requiring a large weapon inventory.

---

## Weapon Type Abstraction
The system supports three top-level weapon type families at first:

### Melee
- close-range direct hits
- examples later may include sword, mace, or similar forms
- material slot category: metal

### Ranged
- distance-based projectile or shot delivery
- examples later may include bow or gun families
- material slot category depends on weapon subtype:
  - bow uses arrow type
  - gun uses ammo type

### Magic
- staff-based or focus-based casting behavior
- material slot category: gem or element

Important early rule:
- define structure for these families now
- do not expand into a large weapon list yet

---

## Single Weapon Rule
The player equips one active weapon platform at a time.

This means:
- progression improves the active weapon instead of replacing it
- loadout identity comes from customization, not from carrying many weapon drops
- build decisions should feel persistent and intentional

This system should not turn into a loot treadmill of constantly swapping entire weapons.

---

## Material Slot System
Each weapon has one primary material slot that changes the behavior of the active weapon.

Material slot categories:
- melee weapon uses metal
- bow uses arrow type
- gun uses ammo type
- staff uses gem or element

Material application is direct.

Players do not manually forge weapon shapes out of materials.
Instead, the chosen material modifies the weapon platform already in use.

---

## Material Behavior
Inserting a material automatically changes:
- damage type
- visual appearance
- basic modifiers

Examples of modifier directions:
- heavier metal may improve stagger or armor damage
- elemental gem may convert the weapon to fire, frost, or arc behavior
- alternate arrow or ammo type may change penetration, spread, or utility

Material behavior should remain readable and straightforward.

Materials should define a foundation for the weapon, while augments provide more transformative behavior.

---

## Material Tier Progression
Higher-tier materials are not available immediately.

Material access should be gated through forge or progression upgrades.

Progression hooks include:
- unlocking higher material tiers
- unlocking additional damage-type options
- increasing flexibility of what the player can insert into the active weapon

The forge should unlock stronger or more specialized material choices, not require manual weapon-shape crafting.

---

## Weapon Progression Hooks
The weapon system should integrate with broader player progression through:
- weapon type choice or unlock timing
- material tier unlocks
- augment slot capacity increases
- unlocks for higher augment tiers through fusion access

The system should support both:
- player-power progression at base
- run-based or mission-earned resources feeding long-term weapon evolution later

---

## Relationship To Combat
The weapon system defines how the player expresses combat identity.

It should not redefine the combat system itself.

Combat remains responsible for:
- attack resolution
- damage application
- hit feedback
- server-authoritative outcomes

The weapon system is responsible for:
- weapon type identity
- material behavior
- augment slot structure
- progression hooks for customization

---

## Co-op Design Goals
The weapon system should support co-op build diversity.

Desired outcomes:
- one player can specialize in front-line melee pressure
- one player can specialize in ranged control or utility
- one player can specialize in elemental or AoE behavior

The system should create complementary roles without requiring a class lock.

---

## Early Scope Boundaries
Do define now:
- one active weapon platform rule
- weapon type families
- material slot logic
- progression hooks
- connection to augment slots

Do not fully define yet:
- a long weapon list
- detailed per-material tables
- exact late-game balance numbers
- full animation or presentation rules for every weapon family

The first prototype should stay modular and expandable.