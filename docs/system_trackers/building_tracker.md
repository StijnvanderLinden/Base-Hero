# Building System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Building System.

---

## Current Status
First Scrap-Paid Turret Upgrade Implemented

---

## Current Design Summary
For the vertical slice, building means fighting alongside a preset base.

The run starts with:
- one central base/core
- fixed-strength walls
- level 1 turrets
- limited capacity for extra turrets

During a run, players spend scrap to:
- upgrade turrets
- place limited additional turrets

Freeform base building outside the preset layout is backlog.

---

## Implemented
- One server-authoritative wall placement prototype
- One server-authoritative turret placement prototype
- Server-side placement validation foundations
- Local valid/invalid placement preview foundations
- Wall health and destruction
- Turret health, target scanning, and server-spawned bullet projectiles that hit enemies
- Wall and turret replication to connected clients and late joiners
- Enemies can attack nearby placed defenses before reaching the core
- Shared scrap costs already exist in some prototype building flow and may be repurposed
- Healthy turrets can now be upgraded through the existing E interaction prompt
- The first turret upgrade improves fire rate, range, damage, and visual color
- Turret upgrade requests and scrap spending are server-authoritative

---

## In Progress
- Tuning scrap cost and impact for the first turret upgrade
- Shifting from broad building placement toward preset base plus limited turret decisions

---

## Blockers / Problems
- Existing placement systems may support more freeform building than the MVP needs
- Walls may still imply upgrade or construction depth that is out of scope for the vertical slice

---

## Must Have
- Preset starter base layout
- Fixed-strength walls
- Level 1 turrets at run start
- Server-authoritative turret upgrade requests
- Scrap cost for turret upgrades
- At least one impactful turret upgrade
- Limited additional turret placement

---

## Should Have
- Locked upgrade branch display
- Clear upgrade feedback
- Turret range or targeting readability
- Co-op-safe shared spending rules

---

## Could Have
- Turret transformation into advanced unlocked type
- Repair interaction if the base loop needs it after turret upgrades feel good

---

## Won't Have (for now)
- Wall upgrades
- Freeform base construction outside the preset layout
- Deep trap catalog
- Power-grid simulation
- Large structure dependency trees
- Complex component sockets

---

## Open Questions
- Should scrap be shared across the team?
- How many extra turrets should be allowed in the first arena?
- Which first turret upgrade feels most impactful: fire rate, range, area damage, or burst?

---

## Recent Decisions
- Walls are fixed strength for the MVP
- Turrets start at level 1 every run
- Scrap spending should focus on turret upgrades and limited additional turrets
- Building complexity is deferred until the survival loop is fun

---

## Next Recommended Task
Playtest whether the first turret upgrade is obvious enough under wave pressure, then tune fire rate, range, damage, and cost.
