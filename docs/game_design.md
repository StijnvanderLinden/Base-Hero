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
The game is currently centered on five major gameplay pillars:

- main-base preparation
- gate exploration
- pylon defense events
- raids
- progression choices

These systems feed into one larger structure centered on:
- building a stronger base
- exploring deeper into persistent gate regions
- choosing when to trigger town hall upgrades
- surviving the resulting raid checkpoints

---

## Main Base vs Gate Relationship

### Main Base
The main base is:
- more permanent
- more strategic
- more build-heavy
- more about long-term investment

The main base is where:
- structure planning matters most
- town hall progression happens
- upgrades pay off over time
- raids become the main progression test

### Gates
Gates are:
- persistent biome zones
- revisited over multiple runs
- more exploratory than raids
- more about layered risk over time
- where players gather the materials needed to push progression forward

Gates should create a different rhythm from raids.
They should not feel like a copy of the same gameplay loop.

---

## Core Relationship Map

### Gate
Gate expeditions provide:
- exploration pressure
- layered depth progression
- pylon capture opportunities
- resource acquisition
- biome-specific encounters

### Pylon
Pylons are the key foothold objective inside gates.

Pylon capture should:
- trigger a mini defense event
- spawn engineered construct enemies
- unlock a safer local foothold on success
- reveal map space
- unlock local travel conveniences
- enable limited nearby building

### Drill
Drills are deployed at captured pylons.

Drills should:
- trigger escalating waves
- generate increasing rewards
- create a controlled risk-versus-reward defense loop
- let players choose when to stop or extract

### Town Hall Upgrade
The town hall upgrade is the player-controlled progression trigger.

It should:
- require gathered materials from gates
- use a channeling or activation process
- trigger a major raid
- become the main gate between tech tiers

### Raid
Raids are the main progression checkpoints.

They should:
- test the current state of the base
- use full construct armies rather than exploration creatures
- determine whether the next town hall tier unlocks
- expose weakness without causing overly punishing progression loss

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
- town hall upgrades
- structural improvements
- better raid readiness

This tension should be present often enough to shape player identity and strategy.

---

## Failure And Recovery Direction

### Gate Failure
Gate failure should cost:
- time
- local momentum
- possibly run rewards

Gate failure should not erase all long-term progress casually.

### Raid Failure
Raid failure should:
- stop the current town hall upgrade from completing
- leave the base damaged
- destroy structures when overwhelmed
- force rebuilding and retrying
- preserve gathered materials so failure is not catastrophic

This keeps raids meaningful without making failure overly punishing.

---

## Enemy Relationship Direction
Enemy design is split into two broad categories.

### Exploration Enemies
These belong to the biome.
They create environmental pressure, roaming danger, and exploration identity.

### Engineered Constructs
These are organized enemies used in:
- pylon defense events
- main raids

This split is important because it makes gate exploration feel distinct from deliberate defense events.

---

## Biome Direction
Biome mechanics are biome-specific, not universal.

The first biome should:
- stay simple
- stay readable
- avoid heavy gimmicks
- establish the persistent gate structure clearly

Later biomes should add stronger identity through mechanics unique to that biome rather than a single global gate ruleset.

---

## Building Direction
Building rules should differ by context.

### Main Base Building
- broadest building freedom
- long-term layouts
- core identity of the defense game

### Gate Building
- limited
- local to captured pylons
- tactical rather than fortress-scale

This keeps the base as the true center of the game while still allowing meaningful local setup in gates.

---

## Gameplay Feel Goals
Across all systems, the game should feel:
- readable
- punchy
- cooperative
- tense
- scalable
- intentional rather than chaotic

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
- strong save-the-base moments
- shared exploration pressure
- shared strategic progression decisions

It should be easy for players to naturally drift into different tendencies, such as:
- frontline defender
- builder or repair-focused player
- crowd-clear specialist
- elite killer
- exploration scout

These roles should emerge from gameplay, not require hard class systems early.

---

## Content Scaling Direction
The game is expected to grow through:
- new gate biomes
- deeper pylon and drill variations
- additional construct roles
- new exploration enemy families
- new structures
- new weapons
- new raid patterns

However, content should only expand after the core loops are proven fun.

---

## Early Prototype Focus
The early playable target should focus on proving:
- multiplayer foundation
- defendable objectives
- enemy pressure
- basic combat
- basic structure interaction
- the first gate loop
- the first player-triggered raid loop

The prototype should avoid:
- too many systems at once
- deep progression trees too early
- excessive UI complexity
- too many resource types early
- overcomplicated building rules

---

## Design Risks To Watch
Potential project risks include:
- gates feeling too temporary instead of persistent
- raids feeling like automatic timers rather than chosen checkpoints
- combat becoming visually messy in co-op
- building becoming too fiddly in gates
- too many resource types diluting decision-making
- enemy counts becoming unreadable in 3D

These should be actively watched during prototyping.