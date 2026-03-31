# Tech Debt

## Purpose
This document tracks known shortcuts, weak spots, incomplete solutions, and intentionally deferred technical or implementation problems.

It is not a wishlist.
It is not a design brainstorm file.
It is a memory file for “this is not good enough long-term, but acceptable for now.”

---

## Usage Rules
Add entries when:
- something is intentionally hacked or simplified
- a system is known to be incomplete
- a temporary approach is acceptable now but should be improved later
- a design/implementation mismatch is knowingly tolerated for prototyping

Do not add:
- random feature ideas
- polish wishes
- vague complaints
- things that are simply unstarted unless that unstarted state creates future risk

Keep entries:
- short
- specific
- actionable later

---

## Current Known Tech Debt

### Documentation Overlap
Some project-wide documentation may overlap in purpose at a high level.

Current examples:
- `gdd.md`
- `game_design.md`
- `system_specs/*`

This is acceptable for now because it improves clarity during early design, but later cleanup may be needed once the systems are more stable and grounded in implementation.

---

### Multiplayer Not Yet Proven in Code
The architecture and multiplayer model are clearly defined, but not yet proven by real implementation.

Debt:
- actual multiplayer foundation still needs verification
- authority rules are documented but not enforced in code
- future system decisions may need adjustment once real implementation exists

---

### Steam-Ready Separation Is Conceptual
The project intends to stay adaptable to future Steam session flow, but this is currently a design principle rather than a tested implementation boundary.

Debt:
- gameplay/session separation still needs to be proven in actual code structure

---

### Gate Persistence Direction Is Unresolved
There is active design discussion around whether gate worlds or gate progression should persist across visits.

Debt:
- this uncertainty may affect architecture and save design later
- should remain intentionally unresolved until the core gate loop is proven

---

### Resource Model Is Not Final
The reward/resource model is directionally strong but still not finalized in implementation detail.

Debt:
- exact resource categories and their uses may change
- inventory/presentation implications remain undefined
- balancing implications remain unknown

---

### Building-in-Gates Rules Are Unresolved
The difference between building at the main base and building inside gates is not fully finalized.

Debt:
- this affects gate pacing
- this affects resource spending logic
- this affects structure design and placement rules

---

### Enemy Scale Strategy Is Not Yet Tested
The design wants large enemy pressure in 3D co-op, but the actual technical and gameplay limits are not yet known.

Debt:
- readability strategy is conceptual only
- performance strategy is not yet validated
- actual swarm scale should not be assumed until tested

---

### Combat Feel Pipeline Is Undefined
Combat design is directionally clear, but the practical implementation of:
- hit feedback
- attack feel
- responsiveness
- visual clarity in co-op

is not yet proven.

Debt:
- this may require multiple iterations once combat exists

---

## Future Resolved Items
Move resolved items here later if helpful.

### Resolved
- none recorded yet