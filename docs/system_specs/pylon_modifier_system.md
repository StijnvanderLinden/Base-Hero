# Pylon Modifier System Specification

## Purpose
The Pylon Modifier System defines how pylon-specific challenge identity and repeat-clear difficulty escalation are applied without requiring manual player selection.

This system supports the pylon channeling loop by making each pylon readable on the first run and steadily harder on later successful clears.

It must remain compatible with material-based ritual activation and matching material essence rewards.

---

## Design Goals
- Give every pylon a clear local identity
- Make the first run understandable and low-overhead
- Scale repeated clears through a predictable mastery ladder
- Prevent dominant modifier-picking strategies
- Keep modifier balance readable and modular
- Increase reward value as challenge rises

---

## Core Structure
Every pylon channel run can include:
- one fixed base modifier tied to that pylon
- up to three global modifiers drawn from one shared ordered sequence

Core rules:
- the base modifier is always active on that pylon's channel runs
- the base modifier is unique to that pylon
- global modifiers are shared across all pylons
- global modifiers are not random and are not chosen by players
- global modifiers unlock in a fixed progression order
- modifier progression is tracked separately for each pylon

---

## Base Modifiers
Each pylon has one fixed base modifier.

Base modifier rules:
- it defines the baseline identity of that pylon
- it is active every time players run that pylon
- it should be understandable on its own during the first clear
- it should change tactics without making the pylon unreadable

Suitable base modifier categories include:
- enemy stat adjustments
- structure restrictions
- combat emphasis shifts
- build permission restrictions

Base modifiers should push players toward different solutions per location without requiring a large bespoke ruleset for every pylon.

---

## Global Modifier Sequence
There is one shared global modifier sequence for the whole game.

Sequence rules:
- every pylon uses the same global modifier order
- modifier 1 is the first added modifier on repeat progression
- modifier 2 is added after another successful clear on that same pylon
- modifier 3 is added after the next successful clear on that same pylon
- no modifiers beyond the third global modifier are active in the current design

Player-facing rule:
- players do not manually select which modifiers are active

Design intent:
- prevent players from always selecting the safest or strongest reward setup
- keep balance easier to control
- make replay structure predictable across co-op sessions

---

## Per-Pylon Progression Logic
Modifier escalation is tracked per pylon based on successful full clears.

Progression ladder:
1. First successful clear on a pylon: base modifier only
2. Next run on that same pylon: base modifier plus global modifier 1
3. After the next successful clear: base modifier plus global modifiers 1 and 2
4. After the next successful clear: base modifier plus global modifiers 1, 2, and 3

Maximum active set:
- one base modifier
- three global modifiers

Important boundaries:
- progression on one pylon does not advance any other pylon
- shared global order does not mean shared completion state
- the first run acts as onboarding for that pylon because only the base modifier is present

---

## Reward Scaling Logic
Rewards scale with the number of active modifiers.

During channel:
- keep the existing milestone reward structure such as matching material essence, special materials, and already-defined milestone rewards
- modifier scaling should improve payout value without replacing those core rewards

On full completion:
- base modifier only grants the basic completion reward tier
- base modifier plus one global modifier grants an improved completion reward tier
- base modifier plus two global modifiers grants a rare reward tier
- base modifier plus three global modifiers grants the highest reward tier in the current ladder

Reward scaling should increase quality, rarity, or value rather than simply adding larger raw numbers everywhere.

---

## Modifier Order Rules
The shared global sequence must be arranged as a progression curve.

Guidelines:
- modifier 1 should be simple and easy to understand
- modifier 2 should add a meaningful second layer of challenge
- modifier 3 should create serious pressure suitable for mastery runs

The sequence should be designed to stack cleanly with many different base modifiers.

---

## Balancing Rules
Balancing priorities:
- keep modifiers readable in active co-op combat
- avoid stacking too many hidden rules at once
- ensure base modifiers preserve pylon identity even at maximum escalation
- ensure the reward step between modifier counts feels worth revisiting a pylon
- keep the modifier list small and maintainable early

The system should favor predictable combinations over wide randomization.

---

## Integration Notes
This system must integrate cleanly with the existing pylon loop.

Do not change:
- the current pylon channeling structure
- the material-only ritual activation rule
- the milestone reward safety rule
- unrelated raid system behavior

The modifier system should remain modular so pylon rules, rewards, and progression tracking can evolve without rewriting the core channel state machine.