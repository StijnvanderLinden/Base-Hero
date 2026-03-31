# GDD and Documentation Update Rules

## Purpose
This document defines when each major documentation file should be updated.

Its job is to prevent:
- clutter
- contradiction
- over-documenting polish
- mixing ideas with confirmed truth

Use this as the routing logic for documentation updates.

---

## Core Principle
Not every change belongs everywhere.

Different files serve different jobs.

The assistant should update the smallest correct set of files needed for a given change.

---

## Update `gdd.md` when:
Update the GDD only when a change affects the high-level truth of what the game is.

Examples:
- a major new game mode becomes official
- the core gameplay loop changes
- progression direction changes significantly
- the role of gates or raids changes significantly
- a major project pillar changes
- a major reward/progression category becomes part of the confirmed game direction

Do not update the GDD for:
- implementation steps
- temporary experiments
- polish
- value tuning
- local system details that belong in specs or trackers

---

## Update `game_design.md` when:
Update this file when:
- project-wide system relationships change
- the relationship between gates, raids, combat, building, and progression changes
- a cross-system design concern becomes clearer
- important project-wide gameplay risks or design themes change

Do not use this file for:
- low-level implementation progress
- one system’s detailed mechanics if that belongs in a system spec
- polish notes

---

## Update `system_specs/*` when:
Update a system spec when:
- a system’s intended mechanics change
- a system’s boundaries become clearer
- new confirmed rules are added to that system
- a major system design choice is accepted

Examples:
- extraction now works differently
- a reward category is officially part of the gate system
- building in gates is confirmed to be limited deployables only
- a new enemy role becomes a real part of the intended design

Do not update a system spec for:
- ordinary implementation progress
- temporary experimentation
- tuning values
- polish-only adjustments

---

## Update `system_trackers/*` when:
Update a system tracker when:
- something in that system is implemented
- a blocker appears
- priorities change
- open questions change
- the recommended next task changes
- MoSCoW priorities change
- a system is paused, resumed, or reworked

System trackers are the correct place for:
- implementation state
- blockers
- what is next
- what changed in priority
- what still needs confirmation

---

## Update `current_state.md` when:
Update this file when:
- a project-wide milestone is reached
- the current development phase changes
- a major implementation dependency is completed
- the overall project focus shifts

Do not update this file for:
- small implementation details
- local tracker-level changes
- polish tweaks

---

## Update `backlog.md` when:
Update the backlog when:
- a new idea appears
- a brainstorm produces possibilities not yet committed
- a risky or uncertain feature deserves remembering
- an idea should be stored without becoming official design truth

Do not move backlog items into specs or GDD until they are confirmed.

---

## Update `decisions.md` when:
Update this file when:
- a major design or technical decision is made
- a meaningful pivot becomes official
- a scope boundary is explicitly chosen
- a recurring question is resolved in a lasting way

Each decision should include:
- what was decided
- why it was decided

---

## Update `tech_debt.md` when:
Update this file when:
- a shortcut is knowingly accepted
- an implementation weakness is intentionally left for later
- a design/implementation mismatch is tolerated for now
- a system is “good enough for prototype” but not really correct long-term

Do not use tech debt for:
- feature wishes
- vague dislikes
- polish ideas

---

## Do Not Update Any Major Docs For:
These changes should usually stay out of major documentation:

- camera distance tweaks
- animation timing tweaks
- movement feel tuning
- small balance numbers
- VFX or audio polish
- one-off scene cleanup
- “make this snappier” refinements
- ordinary editor iteration

These are implementation refinements, not project-memory updates.

---

## Standard Documentation Flow for New Ideas
When the user presents a new idea, the default flow should be:

1. classify it
2. add it to backlog or a tracker if it is still a proposal
3. ask whether it should become official design
4. if confirmed, update the relevant spec(s)
5. if it changes major project truth, also update the GDD
6. if it affects priority, update tracker/current state/development plan as needed

This prevents design truth from being rewritten by every brainstorm.

---

## Standard Documentation Flow for Implementation Work
When implementation work is completed:

1. update the relevant system tracker
2. update `current_state.md` if project-wide status changed
3. update `tech_debt.md` if a shortcut or incomplete solution was intentionally used
4. update `decisions.md` only if an important lasting choice was made during implementation

This keeps implementation history clean and useful.

---

## Final Rule
The goal of the documentation system is:
- preserve memory
- reduce confusion
- support iteration
- keep AI aligned over long development cycles

If unsure where something belongs:
prefer tracker or backlog first,
then promote to higher-truth docs only after confirmation.