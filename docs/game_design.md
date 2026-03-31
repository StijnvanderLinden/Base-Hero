# Detailed Game Design

## Purpose
This document supports the GDD by describing the project’s systems at a higher level than implementation, but in more detail than the high-level GDD.

Use this file for:
- cross-system design relationships
- current design direction
- project-wide gameplay structure
- system interaction notes

Use the system specs for deep per-system detail.

---

## Current Design Direction
The game is currently centered on four major gameplay pillars:

- gates
- combat
- building
- enemies

These systems feed into one larger progression structure centered on:
- preparing a base
- entering gates for rewards
- surviving raids
- choosing upgrades carefully

---

## Main Base vs Gate Relationship

### Main Base
The main base is:
- more prepared
- more permanent
- more strategic
- more about long-term investment

The main base is where:
- structure planning matters most
- upgrades pay off over time
- major raids create progression checkpoints

### Gates
Gates are:
- more reactive
- more dangerous
- more temporary
- more greedy
- more about short-term decisions under pressure

Gates should create a different rhythm from main raids.
They should not feel like a copy of the same gameplay loop.

---

## Progression Tension
One of the game’s key design tensions is the split between:

### Personal power
Examples:
- stronger weapons
- augments
- mobility upgrades
- combat utility

### Base power
Examples:
- walls
- turret strength
- base systems
- structural improvements
- larger defended area

This tension should be present often enough to shape player identity and strategy.

---

## Reward Structure Direction
Rewards should support multiple kinds of decisions.

### Reliable progression rewards
These are dependable and form the backbone of longer-term improvement.

Examples:
- gold
- energy
- salvage
- basic progression currency

### Exciting special rewards
These are rarer and more build-defining.

Examples:
- exotic materials
- rare components
- unique part drops
- unlock materials for unusual weapons or structures

### Run-specific rewards
These increase run variety and create memorable moments.

Examples:
- temporary buffs
- temporary augments
- temporary economy modifiers

---

## Gameplay Feel Goals
Across all systems, the game should feel:
- readable
- punchy
- cooperative
- tense
- scalable
- not overly cluttered

This matters especially because the game is:
- 3D
- multiplayer
- enemy-dense
- structure-heavy

Too much visual noise or system complexity will reduce the game’s strengths.

---

## Co-op Design Goals
Co-op should feel meaningful and additive.

The game should support:
- teamwork without requiring rigid classes
- role preference without forcing role lock-in
- strong “save the run” moments
- shared defense pressure
- shared strategic decisions

It should be easy for players to naturally drift into different tendencies, such as:
- frontline defender
- builder/repair-focused player
- crowd-clear specialist
- elite or boss target killer

These roles should emerge from gameplay, not require hard class systems early.

---

## Content Scaling Direction
The game is expected to grow through:
- new enemy roles
- new gate biomes
- new structures
- new weapons
- new augments
- new raid patterns
- new objectives or side events

However, content should only expand after the core loops are proven fun.

---

## Early Prototype Focus
The early prototype should focus on proving:
- multiplayer foundation
- defendable objectives
- enemy pressure
- basic combat
- basic structure interaction
- first gate extraction loop

The prototype should avoid:
- too many systems at once
- deep progression trees
- advanced UI requirements
- too many resource types early
- overcomplicated building rules

---

## Design Risks to Watch
Potential project risks include:
- gates feeling too similar to raids
- combat feeling visually messy in co-op
- building becoming too fiddly
- too many resource types diluting decision-making
- enemy counts becoming unreadable in 3D
- progression complexity expanding before the core loop is proven

These should be actively watched during prototyping.

---

## Current Open Design Themes
Current major themes being explored:
- hybrid gate structure: defense plus outward reward-seeking
- reward categories that support both steady progression and exciting unlocks
- procedural or semi-procedural gate spaces
- distinction between persistent main-base investment and temporary gate pressure

The exact details will continue to evolve, but these are the current design directions that should guide further work.