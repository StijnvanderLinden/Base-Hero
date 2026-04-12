# Core Research Specification

## Purpose
Core Research defines the long-term unlock layer that spends banked essence and universal crystals.

The research layer sits at base-side progression and is fed by expedition returns.

---

## Core Rules
Research uses two progression resources:
- essence for upgrades
- crystals for unlocks and branch access

Gold and expedition-building resources do not unlock research.

---

## Node Types

### Basic Nodes
- use essence only
- support repeatable upgrades or straightforward stat growth
- are intended to be the most common research spend

### Advanced Nodes
- use essence plus crystals
- gate stronger progression steps
- represent higher commitment unlocks

### Major Unlocks
- use crystals as the primary gate
- unlock branches, augment slots, or other progression lanes
- are intentionally sparse and meaningful

---

## Current Prototype Nodes
- Field Tools: basic node, essence only, repeatable upgrade
- Augment Slot: advanced node, 10,000 essence plus 3 crystals
- Augment Branch: major unlock, 5 crystals

---

## Resource Flow
The current intended flow is:
1. gather raw materials and crystals during expeditions
2. place a pylon
3. channel materials into essence
4. retreat to base with banked essence and global crystal count
5. spend essence and crystals on research nodes

---

## Authority Rules
- clients may request research purchases
- the server validates costs and unlock conditions
- essence and crystal spending is authoritative
- unlocked states and node levels are synchronized to all peers