# Weapon System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Weapon System.

---

## Current Status
Design Confirmed, Runtime Not Implemented

---

## Current Design Summary
The player uses one evolving weapon platform rather than collecting many active weapons.

Current confirmed direction:
- the player chooses a weapon type family
- the weapon evolves through a material slot and augment slots
- weapon identity grows through progression rather than replacement
- forge-style progression unlocks stronger material tiers

---

## Implemented
- Design direction for a single evolving weapon platform is now documented
- Weapon type abstraction is now defined for melee, ranged, and magic families
- Material slot behavior and progression hooks are now specified

---

## In Progress
- Defining how the first runtime weapon presentation should appear in prototype combat
- Clarifying when weapon type choice becomes available in progression
- Deciding the first implementation slice for material application and visuals

---

## Blockers / Problems
- No runtime weapon-selection or weapon-configuration system exists yet
- Combat still uses placeholder player attack behavior rather than a lasting weapon platform
- Material slot behavior is defined in design only, not implemented in code
- No forge or material-tier unlock runtime exists yet

---

## Must Have
- One active weapon platform rule
- Weapon family abstraction for melee, ranged, and magic
- Direct material slot application
- Progression hooks for material tier unlocks
- Clear separation between weapon identity and combat resolution

---

## Should Have
- Clear visual differences per material family
- First runtime weapon-selection interface
- Strong relation between weapon type and augment synergy
- Clean forge-side unlock path for material tiers

---

## Could Have
- Alternate stance or sub-mode per weapon family
- Cosmetic-only weapon visual variants
- Material-specific idle or impact presentation
- Later weapon mastery hooks

---

## Won’t Have (for now)
- large weapon inventory loot system
- many swappable weapon drops per run
- manual weapon-shape forging
- broad weapon catalog expansion before the first runtime slice works

---

## Open Questions
- Which weapon family should be implemented first in runtime: melee, ranged, or magic?
- Should weapon type choice happen immediately or unlock through progression?
- How much of weapon appearance should come from materials versus weapon family?
- Should material insertion be reversible freely or require base-side handling?
- How early should forge upgrades unlock higher material tiers?

---

## Recent Decisions
- The player uses one evolving weapon instead of juggling many active weapons
- Weapon growth should come from materials, augments, and progression hooks
- Material application is direct through slots rather than manual weapon-shape forging
- The first defined weapon families are melee, ranged, and magic only

---

## Next Recommended Task
Define the first runtime weapon implementation slice:
- decide the first weapon family to support in code
- define the minimal runtime data structure for weapon family plus material slot
- wire that first weapon platform into the existing combat prototype without redefining combat itself