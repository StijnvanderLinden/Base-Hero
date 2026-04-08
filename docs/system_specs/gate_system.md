# Gate System Specification

## Purpose
The Gate System provides persistent biome expedition zones that players revisit to gather resources, discover pylons, and fuel long-term progression through pylon channeling.

Gates should feel different from main base raids:
- more exploratory
- more layered
- more about finding and securing tactical footholds
- more about deciding how greedy to be with an active pylon channel
- less about one-time all-in defense

Gates are one of the main engines of progression for the main base.

---

## Design Goals
- Create replayable expedition spaces with persistence
- Preserve exploration, gathering, and hidden reward discovery inside the overworld gate space
- Make pylon channeling the primary gate gameplay loop once a foothold is secured
- Reward deeper pushes and later channel phases more than safe early exits
- Feed tactical and long-term resources back into the main base without collapsing them into one currency
- Stay readable in 3D multiplayer

---

## Core Fantasy
Players enter a dangerous biome through a gate, explore hostile overworld space, secure pylons as footholds, and decide how long they can hold an escalating channeling event before cashing out or failing.

The key emotional loop is:
- enter
- scout
- gather
- discover a pylon
- build a foothold
- start channeling
- survive pressure spikes
- push milestone rewards
- decide when to stop
- return stronger next time

---

## Core Loop
1. Enter a persistent gate biome
2. Explore the overworld to gather resources, fight roaming enemies, and discover rewards or pylons
3. Build a small defense footprint around an uncaptured pylon
4. Start the pylon claim event when ready
5. Survive the claim waves and secure the foothold
6. Start a channeling event at the captured pylon
7. Defend the pylon and its essence holder while generated essence accumulates and milestones approach
8. Choose whether to stop after a milestone, push for a better payout, or risk failure
9. Extract or return to base with banked progression rewards and remaining tactical resources

---

## Gate Structure
Each gate is one biome region.

Core rules:
- procedurally generated once
- revisited over multiple runs
- map persistence across visits
- permanent fog-of-war reveal within explored regions
- progress deeper over time instead of clearing everything in one visit

A gate contains:
- multiple depth layers
- pylon foothold objectives
- biome exploration enemies
- local resources and gold pickups
- hidden rewards and side discoveries
- repeatable channeling opportunities tied to captured pylons

Gates are not intended to be fully cleared in one tier.

---

## Layered Progression
Each gate contains multiple layers of escalating danger.

### Outer Layer
- easiest enemies
- starter pylons
- basic resources

### Mid Layer
- stronger enemies
- more complex encounters
- better rewards

### Inner Layer
- high difficulty
- rarer materials
- stronger pylon pressure and better channel payout potential

### Deep Or Core Layer
- extreme difficulty
- elite encounters
- strongest pylon rewards and progression opportunities

Players can attempt to go deeper early, but they are not expected to fully overcome those layers before their current tier supports it.

---

## Pylon Role Inside Gates
Pylons are the main foothold objectives inside gates.

Pylons define:
- safe local control
- defensive coverage area
- a repeatable channeling objective
- a place where exploration risk turns into progression rewards

Captured pylons are the bridge between overworld gate traversal and the main gate reward loop.

Early rule:
- early pylons should allow any building type so players can learn the gate loop with minimal rules friction

---

## Overworld Role
The gate overworld is not just tower defense.

The overworld must include:
- exploration
- resource gathering
- enemy encounters
- hidden rewards
- pylon discovery

The pylon channeling event is the main commitment point inside that broader overworld space, not the entire identity of the gate.

---

## Pylon Channeling Flow
At a captured pylon, players may begin a channeling event.

Activation rules:
- the first activation on a pylon is free
- later activations on that same pylon cost gold
- repeat activations should stay viable, but older pylons become less efficient than newly discovered deeper pylons

Channeling flow:
1. claim the pylon first
2. build and repair defenses around the foothold
3. interact at the pylon to begin the channel
4. survive escalating enemy waves while channel progress advances over time
5. defend the physical essence holder that stores generated essence
6. secure milestone rewards at 1/3, 2/3, and 3/3 progress
7. choose whether to stop and survive shutdown or keep pushing into higher danger

---

## Building Rules In Gates
Building in gates is limited.

Core rules:
- only near captured pylons
- small tactical setups only
- not full fortress-scale construction
- early pylons allow walls, turrets, traps, healing, and repair without special restrictions
- the same defenses are reused across repeated channel attempts at that foothold

Design reason:
- keeps the main base as the center of large-scale building
- preserves gate readability
- makes pylon capture meaningfully change the local space
- keeps repeat attempts focused on tactical preparation rather than full rebuild friction

Later pylon variants may introduce debuffs that change how a foothold can be defended, such as:
- no healing or repair during the event
- walls-only building
- turrets-only building
- traps-only building
- heavier elite pressure

These variants should make later pylons feel mechanically distinct while preserving the same core channeling loop.

---

## Milestones And Rewards
Channeling is divided into three milestone segments:
- 1/3
- 2/3
- 3/3

Reward rules:
- 1/3 grants a large essence reward that is banked immediately
- 2/3 grants more banked essence plus one research point
- 3/3 grants a major reward such as an augment or permanent unlock
- milestone rewards are always safe and cannot be lost

Generated essence between milestones is not automatically safe.
It remains vulnerable while stored in the essence holder or during shutdown.

---

## Essence Generation And Capacity
Generated essence increases over time while a channel is active.

Phase scaling:
- Phase 1 uses the base generation rate
- Phase 2 increases generation to about 2.5x the base rate
- Phase 3 increases generation to about 5x the base rate

Capacity rules:
- only generated essence is capped by essence capacity
- excess generated essence beyond capacity is lost
- milestone rewards bypass capacity and are always banked safely

This keeps risk-taking valuable without allowing infinite hoarding.

---

## Difficulty Scaling
Each channel milestone increases danger.

Scaling rules:
- enemy difficulty spikes at each milestone
- spawn rate increases at each milestone
- later phases should force more manual intervention from players even if defenses are strong

Final phase behavior:
- the last phase enters an enrage state
- spawns become rapid
- elite enemies appear
- the channel should feel chaotic and unstable before completion

---

## Essence Holder Risk
During channeling, generated essence is stored in a physical holder object near the pylon.

If the holder is destroyed:
- all unbanked generated essence is lost
- milestone rewards remain safe

Required feedback:
- holder glow intensity increases with stored essence
- visible damage state appears as the holder degrades
- warning indicators communicate imminent loss risk

---

## Stop Channel And Shutdown
Players may stop a channel voluntarily.

When they stop:
- a 15 second shutdown begins
- enemies continue attacking
- generated essence is locked and stops increasing
- locked generated essence can still be lost if the holder is destroyed before shutdown completes

Shutdown should create a final tension spike instead of functioning like an instant safe cash-out.

---

## Failure And Recovery In Gates
Failure occurs when the channel collapses before a safe exit, typically because the pylon defense breaks or the essence holder is destroyed at the wrong time.

On failure:
- the pylon resets to its reusable foothold state
- all linked defenses are automatically repaired for the next attempt
- unbanked generated essence is lost
- any gold spent to start the run is lost

Failure does not remove structures, inventory, or milestone rewards.
The setback is tactical tempo loss, not rebuild punishment.

---

## Persistence
Persistent gate progression may include:
- revealed map areas
- captured pylons
- unlocked travel points
- known routes and resource locations
- gate-specific world state later

Pylon reuse is expected, but newer and deeper pylons should gradually offer better efficiency than older ones.

This persistence is part of the core gate identity, not a side feature.

---

## Biomes
Each gate is tied to a biome.

Biome affects:
- visuals
- exploration enemy families
- local hazards
- material types
- hidden reward structure
- later mechanic identity

Biome mechanics are biome-specific, not global.

The first biome should stay simple and readable.
Later biomes may introduce stronger mechanics, such as environmental visibility pressure or traversal-specific constraints.

---

## Co-op Considerations
Gate expeditions must work cleanly in co-op.

Requirements:
- shared pylon state
- synchronized channel and shutdown state
- clear holder risk readability
- fair reward presentation
- good navigation clarity under pressure

Authority rule:
- all gate state is server-authoritative

Server handles:
- pylon capture state
- channel activation costs and validation
- enemy spawns
- holder health and destruction
- milestone completion
- generated essence values and capacity overflow
- success and failure outcomes

---

## Early Prototype Direction
The early playable gate direction should prove:
- one persistent gate biome
- one basic pylon capture flow
- one basic pylon channeling flow from a captured pylon
- one essence holder risk object
- one shutdown phase
- one basic exploration enemy family
- construct enemies for pylon pressure

---

## Future Extensions
Possible future additions:
- biome-specific holder rules or modifiers
- elite milestone variants
- pylon mutators that change risk-reward behavior
- pylon debuffs that constrain building or support options on specific footholds
- stronger local progression systems
- special hazards or weather