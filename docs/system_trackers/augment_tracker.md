# Augment System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Augment System.

---

## Current Status
Design Confirmed, Runtime Not Implemented

---

## Current Design Summary
Augments reshape the player’s single active weapon through slot-cost budgeting, synergy-focused combinations, removable customization, and behavior-changing fusion tiers.

Current confirmed direction:
- augments use slot cost
- the weapon has limited capacity
- capacity increases through progression
- augments should change behavior, not only numbers
- fusion upgrades augments into higher tiers with new behavior

---

## Implemented
- Starter augment set is now explicitly defined in design
- Slot-cost budgeting rules are now documented
- Removal rules are now documented as a costed, experimentation-friendly system
- Fusion rules and behavior-first fusion philosophy are now documented

---

## In Progress
- Deciding which starter augments should appear in the first implementation slice
- Clarifying the first resource flow for augment acquisition and removal
- Deciding whether removal should destroy augments or return them with penalty in the first live economy

---

## Blockers / Problems
- No runtime augment inventory or loadout system exists yet
- No augment slot-capacity runtime exists yet
- No fusion runtime exists yet
- The removal economy is not fixed because the broader resource economy is still evolving

---

## Must Have
- Slot-cost system
- Capacity limit system
- Starter augment set
- Behavior-first augment philosophy
- Removal at a cost
- Fusion from Level 1 to Level 3 tiers

---

## Should Have
- Clear UI for augment slot budgeting
- Readable synergy preview or equip feedback
- One first implementation slice that proves augments can change gameplay behavior
- Fusion preview that shows behavior changes, not only stat increases

---

## Could Have
- Later augment categories by theme
- co-op synergy recommendations
- augment rarity or sourcing layers
- augment-specific visuals or audio cues

---

## Won’t Have (for now)
- giant augment catalog at prototype stage
- complex stat-stack spreadsheets as the main progression layer
- permanent punishment for experimentation
- fusion that only increases numbers with no behavior change

---

## Open Questions
- Which starter augments belong in the first playable slice?
- Should the first removal rule destroy augments or return them with penalty?
- How early should fusion become available?
- How visible should augment synergy information be in UI?
- How much augment depth is appropriate before the core weapon runtime is stable?

---

## Recent Decisions
- Augments define gameplay behavior, not just stats
- Augments are constrained by slot cost and capacity
- Augments can be removed at a cost to support experimentation
- Augments can be fused into higher tiers
- Fusion must add new behavior instead of only scaling numbers

---

## Next Recommended Task
Define the first runtime augment slice:
- choose a small starter set for first implementation
- define runtime slot-capacity data on the active weapon
- implement one fusion example that clearly changes behavior instead of only values