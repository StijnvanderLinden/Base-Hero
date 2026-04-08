# Gate System Tracker

## Purpose
Tracks implementation state, priorities, open questions, and design evolution for the Gate System.

---

## Current Status
Design Refactor Confirmed, Runtime Alignment Needed

---

## Current Design Summary
Gates are persistent biome expedition zones with layered depth progression and pylon channeling as the main repeatable reward loop.

Current confirmed direction:
- each gate is one biome region
- the map persists between runs
- fog of war reveal persists
- players revisit the same gate over time
- pylons are the key foothold objectives
- the overworld must still support exploration, gathering, enemy encounters, hidden rewards, and pylon discovery
- captured pylons unlock repeatable channeling events rather than cave expeditions
- early pylons allow unrestricted building so the core loop stays easy to learn
- milestone rewards are safe while generated essence remains at risk
- failure resets the run without forcing structure rebuilds
- building in gates is limited and local to pylons
- later pylons may apply event debuffs such as build restrictions, no healing or repair, or heavier elite pressure

---

## Implemented
- First gate prototype exists in the shared multiplayer scene
- Gate reward flow already feeds back into base progression in a basic way
- High-level persistent gate concept is documented
- The live gate foothold now uses a first pylon runtime objective instead of the old drill objective
- The live gate now starts in a build phase and only begins claim pressure when players manually channel the pylon
- The live claim event now finishes only after all finite claim waves are cleared

---

## In Progress
- Replacing the old cave-centered gate direction with the finalized pylon channeling loop
- Defining the first milestone, shutdown, and essence holder runtime contract
- Defining how repeat pylon efficiency drops as players move toward newer pylons

---

## Blockers / Problems
- Current runtime still reflects an older cave-oriented prototype and needs system alignment
- Essence holder risk, shutdown, and safe milestone banking are not implemented yet
- Persistent map reveal and gate revisit state are not implemented yet
- Building rules near captured pylons are not fully implemented yet
- Exploration enemy families are not yet separated from all construct event pressure in runtime

---

## Must Have
- One persistent gate biome
- Layered depth progression
- Pylon capture events
- Pylon channeling from captured pylons
- Exploration, gathering, enemy encounters, hidden rewards, and pylon discovery in the overworld
- Essence holder risk
- Shutdown phase
- Return and revisit flow

---

## Should Have
- Fast travel between unlocked pylons
- Persistent fog-of-war reveal
- Clear efficiency gains for newer deeper pylons
- Clear distinction between tactical gold income and progression rewards
- Strong readability for milestone spikes and enrage pacing
- Clear communication of pylon-specific debuffs before players commit to the event

---

## Could Have
- Local gate threat states
- Biome hazards beyond combat
- Elite milestone variants
- Gate-specific mutators
- Hidden side objectives tied to overworld exploration
- Special pylon variants with walls-only, turrets-only, traps-only, or no-repair rules

---

## Won’t Have (for now)
- Full open-world sandbox behavior
- Fully clearable gate completion in one early tier
- Many simultaneous gate objective types
- Deep procedural simulation of gate worlds
- Complex economy layers tied to gates too early

---

## Open Questions
- What is the minimum first-pass essence holder behavior needed for the prototype?
- How quickly should repeat activation cost and older-pylon efficiency falloff scale?
- How much gold should players expect to earn from one average gate loop?
- When should deeper pylons start requiring stronger town hall progression to feel efficient?

---

## Recent Decisions
- Cave expeditions were removed from the gate loop in favor of pylon channeling
- Pylon channeling is the primary gate gameplay loop after a foothold is secured
- First pylon activation is free and repeat activations cost gold
- Early pylons allow any building type, while later pylons may add debuffs or build restrictions
- Milestone rewards are always safe while generated essence remains vulnerable
- Shutdown adds the final tension spike before a successful cash-out

---

## Next Recommended Task
Align the live gate prototype to the new loop:
- replace the old cave-oriented runtime language with channel, milestone, shutdown, and holder language
- define the first banked-versus-vulnerable reward flow in HUD and game state
- implement one reusable pylon run with milestone spikes and a 15 second shutdown