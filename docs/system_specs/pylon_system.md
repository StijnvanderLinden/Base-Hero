# Pylon System Specification

## Purpose
The Pylon System defines foothold objectives inside gates, their claim behavior, their material identity, and the repeatable channeling loop that converts gathered materials into material-specific essence.

Pylons are the anchor point between exploration, defense events, and core research progression.

---

## Design Goals
- Make pylons the key controllable gate objective
- Give each pylon a clear material identity
- Require exploration to fuel channeling attempts
- Reuse existing defenses around pylons across repeated channel attempts
- Create clear risk around converted rewards without forcing full rebuilds after failure
- Keep the system readable in co-op
- Give each pylon a stable gameplay identity through a fixed base modifier
- Turn repeated full clears into a readable mastery ladder for that specific pylon

---

## Core Role
A pylon is a local foothold tied to one material type.

A functional pylon provides:
- local control
- an area where defenses can matter
- a repeatable channeling objective
- a material conversion site for one specific progression path
- a stable anchor for exploration and extraction routing

Early rule:
- pylons initially allow any building type around the foothold so players can learn the core loop without extra restrictions

---

## Pylon Material Identity
Each pylon is tied to one material type.

Examples:
- Iron Pylon
- Silver Pylon
- Fire Gem Pylon
- Lightning Gem Pylon

Material identity rules:
- the pylon's material type is fixed
- the material type is visible before players start a channel
- that material type determines the ritual activation cost
- that material type determines which material essence is generated during channeling
- that material type determines which core research tree the run feeds most directly

This gives pylons distinct value and supports player specialization around different material paths.

---

## Pylon States

### Uncaptured
- hostile or neutral
- not yet claimed
- full channeling cannot begin
- players may build defenses around it before starting the claim event

### Functional
- captured and under player control
- channeling can begin
- nearby defenses are active
- safe-zone effects may apply

### Channeling
- a defense event is active
- enemies spawn in escalating waves
- matching material is being converted into matching material essence over time
- generated material essence is stored in the linked holder
- milestone rewards unlock as progress advances

### Shutdown
- triggered when players stop channeling voluntarily
- generated material essence is locked and no longer increases
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
- every channel activation costs only the pylon's matching material
- gold is not used to start a pylon channel
- the activation cost never uses a universal progression currency
- modifier progression does not change the material identity of the pylon
- repeat use is allowed as long as the team can supply the matching material

Design intent:
- make exploration required before channeling
- reinforce the identity and value of gathered materials
- keep gold focused on building structures rather than funding progression rituals

---

## Pylon Modifier Structure
Each pylon channel run uses a layered modifier structure.

Modifier layers:
- every pylon has one fixed base modifier
- the base modifier is unique to that pylon and is active on every channel run there
- all pylons also reference one shared global modifier sequence
- players do not choose modifiers manually

Design intent:
- preserve a clear identity for each pylon
- keep replay difficulty structured instead of player-optimized
- reduce decision overload during repeated runs

Base modifier examples may include:
- enemy stat pressure
- structure restrictions
- combat emphasis changes
- build restrictions

The exact modifier list should remain limited and deliberately staged rather than expanding into a large random pool early.

---

## Repeated Completion Modifier Progression
Modifier progression is tracked per pylon.

Progression rule:
- a pylon completion means a full successful 3/3 channel clear on that pylon
- the first successful clear happens with only that pylon's base modifier active
- the next channel run on that same pylon adds global modifier 1
- after the next successful clear on that same pylon, the next run adds global modifier 2
- after the next successful clear on that same pylon, the next run adds global modifier 3
- the maximum active set is one base modifier plus three global modifiers

Important boundaries:
- modifier progression is not shared across all pylons at once
- clearing one pylon does not advance another pylon's modifier state
- the shared global modifier order stays the same across every pylon
- the first run acts as the learning run for that pylon because only the base modifier is active

This creates a mastery ladder where players first learn the local rules of a pylon and then face predictable layered pressure on later clears.

---

## Channeling Flow
Activation flow:
1. claim the pylon first
2. prepare defenses around the foothold
3. spend the pylon's matching material to begin the channel ritual
4. defend against escalating enemy waves while conversion progresses over time
5. protect the material essence holder from destruction
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
- 1/3 grants a banked payout of the pylon's matching material essence
- 2/3 grants more banked matching material essence and may award special materials on eligible pylons
- 3/3 grants a completion reward package whose quality scales with the active modifier count on that run

Rule:
- milestone rewards are always safe and cannot be lost
- milestone rewards bypass the matching material essence cap
- reward quality at full completion scales with the active modifier count on that run

---

## Material Essence Holder
Generated material essence is stored in a physical holder object linked to the pylon during channeling.

Holder rules:
- it stores only the vulnerable generated essence from the active run
- it only stores the matching material essence for that pylon
- milestone rewards do not depend on holder survival once earned
- if the holder is destroyed, only unbanked generated material essence is lost

Required feedback:
- glow intensity that reflects stored value
- visible damage states
- warning indicators when the holder is under threat

---

## Material Conversion And Capacity
Matching material is converted into matching material essence while the channel is active.

Scaling:
- Phase 1 uses the base conversion rate
- Phase 2 increases conversion to about 2.5x
- Phase 3 increases conversion to about 5x

Capacity rules:
- each material has its own essence storage capacity
- only generated material essence is capped
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
- repeated successful clears on the same pylon also raise difficulty by adding the next modifier from the shared global sequence

The system should force players and defenses to work together instead of letting either one fully trivialize later phases.

---

## Shutdown Phase
Players may stop the channel voluntarily.

Shutdown rules:
- a 15 second shutdown begins immediately
- generated material essence is locked and stops increasing
- enemies continue attacking during shutdown
- locked material essence can still be lost if the holder is destroyed before shutdown completes

Shutdown is the cash-out tension spike for a successful stop decision.

---

## Failure Behavior
If the channel fails:
- the pylon resets to its reusable foothold state
- all linked defenses are automatically repaired
- the team loses unbanked generated material essence
- the team loses the material spent to start that run

Failure does not punish through:
- rebuilding structures from scratch
- inventory loss beyond the committed ritual material and vulnerable generated essence
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
- clear communication of pylon material type and ritual cost
- synchronized activation, milestone, and shutdown state
- clear communication of material essence holder risk
- readable enemy pressure during each channel phase

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