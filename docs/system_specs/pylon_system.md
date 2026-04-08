# Pylon System Specification

## Purpose
The Pylon System defines foothold objectives inside gates, their claim behavior, the repeatable channeling loop they unlock, and the risk object that stores generated essence during active runs.

Pylons are the anchor point between gate exploration and the main gate reward loop.

---

## Design Goals
- Make pylons the key controllable gate objective
- Reuse existing defenses around pylons across repeated channel attempts
- Make the first activation approachable and repeat activations meaningfully costly
- Create clear risk around generated rewards without forcing full rebuilds after failure
- Keep the system readable in co-op

---

## Core Role
A pylon is a local foothold.

A functional pylon provides:
- local control
- an area where defenses can matter
- a repeatable channeling objective
- a stable anchor for exploration and extraction routing

Early rule:
- pylons initially allow any building type around the foothold so players can learn the core loop without extra restrictions

---

## Pylon States

### Uncaptured
- hostile or neutral
- not yet claimed
- channeling cannot begin
- players may build defenses around it before starting the claim event

### Functional
- captured and under player control
- channeling can begin
- nearby defenses are active
- safe-zone effects may apply

### Channeling
- a defense event is active
- enemies spawn in escalating waves
- generated essence is stored in the linked essence holder
- milestone rewards unlock as progress advances

### Shutdown
- triggered when players stop channeling voluntarily
- generated essence is locked and no longer increases
- enemies continue attacking for 15 seconds
- the stored essence is still vulnerable until shutdown completes

---

## Capture Flow
Players capture a pylon by channeling at it.

Capture flow:
1. build defenses around the pylon before committing
2. start the claim channel at the pylon
3. trigger a finite construct-wave defense event
4. clear all claim waves
5. complete the capture and unlock the local foothold

Failure during capture does not permanently remove the pylon.
Players can regroup and try again later.

---

## Channel Activation Rules
Only a functional pylon can start a channeling event.

Activation rules:
- the first activation on a pylon is free
- every later activation on that same pylon costs gold
- repeat use is allowed, but reward efficiency should drop relative to newly discovered deeper pylons

Design intent:
- remove fear of trying a newly found pylon
- keep repeat use meaningful inside the gold economy

---

## Channeling Flow
Activation flow:
1. claim the pylon first
2. prepare defenses around the foothold
3. interact at the pylon to begin the channel
4. defend against escalating enemy waves while progress advances over time
5. protect the essence holder from destruction
6. reach 1/3, 2/3, and 3/3 milestones for progressively stronger rewards
7. choose whether to stop and survive shutdown or push deeper into danger

The player does not rebuild the foothold between ordinary retries.
The same nearby defenses remain part of the tactical setup.

---

## Milestone Structure
Channeling is divided into three segments:
- 1/3
- 2/3
- 3/3

Rewards:
- 1/3 grants a large banked essence payout
- 2/3 grants more banked essence plus one research point
- 3/3 grants a major reward such as an augment or unlock

Rule:
- milestone rewards are always safe and cannot be lost

---

## Essence Holder
Generated essence is stored in a physical holder object linked to the pylon during channeling.

Holder rules:
- it stores only the vulnerable generated essence from the active run
- milestone rewards do not depend on holder survival once earned
- if the holder is destroyed, only unbanked generated essence is lost

Required feedback:
- glow intensity that reflects stored value
- visible damage states
- warning indicators when the holder is under threat

---

## Essence Generation And Capacity
Generated essence increases over time while the channel is active.

Scaling:
- Phase 1 uses the base rate
- Phase 2 increases generation to about 2.5x
- Phase 3 increases generation to about 5x

Capacity rules:
- only generated essence is capped
- overflow is lost
- milestone rewards bypass capacity completely

This keeps greed attractive without allowing infinite stockpiling from one safe foothold.

---

## Difficulty Scaling
Each milestone raises the pressure.

Scaling rules:
- enemy difficulty spikes at each milestone
- spawn rate increases at each milestone
- the final phase enters an enrage state with rapid spawns and elite enemies

The system should force players and defenses to work together instead of letting either one fully trivialize later phases.

---

## Shutdown Phase
Players may stop the channel voluntarily.

Shutdown rules:
- a 15 second shutdown begins immediately
- generated essence is locked and stops increasing
- enemies continue attacking during shutdown
- locked essence can still be lost if the holder is destroyed before shutdown completes

Shutdown is the cash-out tension spike for a successful stop decision.

---

## Failure Behavior
If the channel fails:
- the pylon resets to its reusable foothold state
- all linked defenses are automatically repaired
- the team loses unbanked generated essence
- the team loses any gold spent to start that run

Failure does not punish through:
- rebuilding structures from scratch
- inventory loss
- loss of already banked milestone rewards

---

## Defense Interaction
Pylon defenses are reused across claim, channel, and repeat runs.

Core rule:
- players build a small tactical setup around the pylon
- early pylons allow walls, turrets, traps, healing, and repair without pylon-specific restrictions
- that setup carries repeated attempts without requiring full reconstruction

This makes pylon preparation a meaningful commitment while keeping failure friction manageable.

Later pylon variants may apply debuffs or build restrictions during the event, such as:
- disabling healing or repair during the channel
- allowing only walls
- allowing only turrets
- allowing only traps
- increasing elite enemy presence

These debuffs should create distinct tactical problems, not arbitrary punishment.

---

## Co-op Considerations
Pylon state must be clear to all players.

Requirements:
- visible state readability for uncaptured, functional, channeling, and shutdown states
- synchronized activation, milestone, and shutdown state
- clear communication of essence holder risk
- readable enemy pressure during each channel phase

Authority rule:
- pylon state, activation cost validation, holder health, milestone rewards, and failure outcomes are server-authoritative

---

## Early Prototype Direction
The first pylon milestone should prove:
- one captured state
- one repeatable channel activation flow
- one essence holder risk object
- one shutdown phase
- one simple defense reuse rule set

---

## Future Extensions
Possible future additions:
- pylon-specific upgrades
- stronger safe-zone benefits
- different pylon archetypes
- biome-specific holder modifiers
- pylon debuff variants that change build permissions or combat rules during the event
- pylon-linked fast travel improvements