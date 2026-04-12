# Pylon System Specification

## Purpose
The Pylon System defines the player-placed outpost used during expeditions.

The pylon is the local anchor for:
- building a foothold
- defending a channeling event
- converting gathered material into essence
- expanding area influence
- surfacing crystal pressure without revealing crystal positions

---

## Design Goals
- make pylon placement a deliberate expedition commitment
- keep the first implementation readable and multiplayer-safe
- let players gather first, place later, then defend the pylon under pressure
- use radius growth as the main visible reward during channeling
- keep pylon upgrades simple and fully essence-driven

---

## Placement Rules
Players place a pylon during an expedition.

Initial rules:
- only one player-placed pylon is allowed
- placement must happen on valid terrain inside the expedition floor
- placement cannot be too close to an existing pylon position
- placement is server-authoritative

Placement data stored on the runtime pylon:
- world position
- level
- influence radius
- max radius
- current channel progress
- is channeling

---

## Pylon States

### Unplaced
- no local influence exists yet
- the team can still gather materials and crystals
- players are prompted to place the pylon

### Ready
- the pylon exists and is stable
- nearby defenses can be built around it
- channeling can be started by interacting with the pylon

### Channeling
- the pylon converts gathered material into essence over time
- influence radius expands while the event remains active
- enemy pressure keeps escalating while the pylon is defended

### Damaged
- the pylon was destroyed during channeling
- unbanked essence is lost
- linked defenses go offline
- the current run can still retreat, but the pylon is no longer usable that run

---

## Channeling Rules
Channeling is the core pylon interaction.

Activation rules:
- the player starts channeling by interacting with the pylon
- the start cost uses raw material input such as iron
- advanced channeling tiers can also require essence
- activation and cost validation are server-authoritative

Runtime rules:
- enemies spawn in escalating waves while channeling is active
- difficulty rises over time rather than through a separate modifier picker
- the pylon must survive for the channel to keep progressing

---

## Radius Expansion
Influence radius grows while channeling continues.

Current prototype target:
- starts at 20 units
- reaches about 40 units after 30 seconds
- reaches about 80 units after 60 seconds

Expansion rules:
- the live radius cannot exceed the pylon's current max radius
- radius growth is visible in-world and used for nearby detection logic
- if the pylon is destroyed, the live radius collapses back to the stable base state

---

## Essence Conversion
Channeling converts expedition material input into essence over time.

Current rules:
- iron is the first raw material input
- essence gain ramps upward over time with the channel stage
- unbanked essence is only secured when the player stops channeling successfully
- destroyed pylons drop all unbanked essence from that active channel

---

## Channel End Conditions
Channeling ends when:
- the player stops manually
- the pylon is destroyed
- the team retreats from the expedition

On a successful manual stop:
- accumulated essence is banked
- the pylon receives a permanent max-radius increase based on channel performance

On failure:
- accumulated unbanked essence is lost
- the pylon enters a damaged state for the rest of the run

---

## Influence System
The pylon's influence radius drives local expedition awareness.

Within influence radius the prototype reveals counts or highlights for:
- ore nodes
- herb patches
- cave entrances
- treasure spots

Crystal rule:
- crystals are never revealed as exact map markers by pylon influence
- the pylon only shows how many crystals remain within its current radius

---

## Pylon Upgrades
Pylon upgrades are an essence sink.

Current upgrade tracks:
- base radius
- max radius
- channel efficiency
- pylon HP

Upgrade rules:
- upgrades use essence only
- upgrades are server-authoritative
- upgrades modify the active runtime pylon and future channels in the current session

---

## Co-op And Authority Rules
- clients may request placement, interaction, and channel stops
- the server validates placement, spends resources, starts waves, grants essence, and applies upgrades
- pylon state, health, radius, and channel progress must remain synchronized for all peers

Authority rule:
- pylon state, material cost validation, holder health, milestone rewards, and failure outcomes are server-authoritative

---

## Early Prototype Direction
The first pylon milestone should prove:
- one captured state
- one repeatable channel activation flow using matching material costs
- one material essence holder risk object
- one shutdown phase
- one simple defense reuse rule set
- one fixed base modifier per pylon with room for later shared global modifier escalation

---

## Future Extensions
Possible future additions:
- pylon-specific upgrades
- stronger safe-zone benefits
- different pylon archetypes
- biome-specific holder modifiers
- pylon debuff variants that change build permissions or combat rules during the event
- pylon-linked fast travel improvements