# Progression System Specification

## Purpose
The Progression System defines how long-term player and base growth is driven by gathered materials, material-specific essence conversion, and unified core research trees.

Progression must:
- reinforce the return-to-base loop
- support both player power and base power
- give gates meaningful reward value through material-specific pylon channeling
- unlock deeper build expression over time without relying on generic currencies

---

## Design Goals
- Preserve the base as the progression anchor
- Keep gold limited to structure-building decisions
- Make exploration materials the entry point to progression
- Convert pylon success into material-specific research value
- Let players improve weapons, armor, abilities, and passives through one unified core path per material
- Turn repeated pylon clears into a structured mastery ladder with escalating reward tiers
- Avoid overwhelming the early prototype with too many systems at once

---

## Core Progression Structure
Progression is split between:
- tactical run economy
- long-term material progression

Tactical run economy uses gold for:
- building defenses
- repairing or supporting structure play if other systems allow it

Long-term material progression uses gathered and converted resources for:
- raw materials gathered during exploration
- banked material-specific essence produced by pylon channeling
- rare or elite materials used by advanced research nodes
- completion reward packages tied to pylon mastery

Base progression improves:
- core durability and function
- access to additional material trees
- infrastructure that supports broader crafting or research later

Player progression improves:
- weapon options
- armor paths
- abilities
- passive bonuses

---

## Gold Versus Material Progression
Gold is a tactical resource.

Gold is spent on:
- building defenses in a run
- other structure-side tactical choices when defined by runtime systems

Gold is not spent on:
- starting pylon channels
- unlocking long-term research

Materials and material essence drive progression.

Progression is fueled by:
- metals, gems, and other exploration materials
- matching material spent to activate pylons
- matching material essence generated during active channeling
- special materials used by advanced research nodes

Design rule:
- gold should pressure short-term tactical choices
- material gathering and conversion should drive long-term progression decisions

---

## Exploration To Conversion Loop
The progression loop is:
1. explore and gather materials
2. locate a pylon tied to one of those materials
3. spend the matching material to start the channel ritual
4. defend the pylon while that material is converted into matching material essence
5. bank the resulting essence and completion rewards into core research
6. repeat to deepen specialization or broaden into new material trees

This makes exploration a direct prerequisite for progression instead of a side economy.

---

## Pylon Conversion Rewards
Channeling milestones define the most reliable progression payouts.

Reward structure:
- 1/3 grants a safe banked payout of matching material essence
- 2/3 grants more banked matching material essence and may add special material rewards on eligible pylons
- 3/3 grants a completion reward package whose quality scales with active modifier count

Milestone rules:
- milestone rewards are always safe
- milestone rewards are banked immediately
- milestone rewards bypass the matching material essence cap

This keeps progress feeling meaningful even when a run ends badly.

---

## Material Essence Conversion And Capacity
Material essence accumulates over time during active channeling.

Scaling:
- Phase 1 uses the base conversion rate
- Phase 2 increases conversion to about 2.5x
- Phase 3 increases conversion to about 5x

Capacity rules:
- each material has its own essence storage capacity
- stored essence is capped per material type
- overflow is lost
- only generated matching material essence is subject to the cap

Generated material essence remains a risk-bearing resource until it is secured through shutdown completion or another safe banking rule defined by the runtime.

---

## Unified Core Research
The player's core stores materials and material essence and uses them to unlock unified research trees.

Each material unlocks one research tree that can include:
- weapons
- armor
- abilities
- passive bonuses

Research rule:
- progression is no longer driven by one universal essence pool
- research costs are paid using matching material essence and, for advanced nodes, special materials
- different material trees should support different combat identities and team roles

---

## Special Materials
Special materials are rare progression resources.

Sources may include:
- elite enemies
- pylon events
- overworld encounters

Role:
- gate advanced research nodes
- unlock stronger abilities or upgrades
- add excitement to higher-risk content without becoming a generic universal currency

---

## Repeated Pylon Clear Progression
Repeated pylon clears are a progression ladder, not just a farm loop.

Rules:
- each pylon tracks its own completion-based modifier escalation
- the first successful clear on a pylon is a learning run with only that pylon's base modifier active
- later successful clears unlock additional shared global modifiers for future runs on that same pylon
- players do not manually choose modifiers, which keeps the ladder predictable and easier to balance

Progression intent:
- teach a pylon on the first clear
- reward mastery on later clears
- provide a clear reason to revisit a pylon beyond its first completion
- improve completion reward quality as modifier count rises

---

## Base Versus Player Investment
Progression choices should create tension between:
- improving the main base
- improving the player's personal core research paths

This supports the game’s central loop:
- bring resources home
- choose whether to strengthen the base or the player
- prepare for harder gates and raids

Material essence should fund steady research growth, while special materials should unlock stronger or more specialized endpoints.

---

## Co-op Progression Goals
Progression should support team diversity.

Desirable outcomes:
- one player invests into an iron-focused defensive build
- one player invests into a fire-focused offensive build
- one player invests into a lightning or utility-focused support build

The progression system should support complementary builds instead of flattening all players into the same strongest option.

---

## Early Scope Boundaries
Do define now:
- progression hooks for materials, material essence, special materials, and completion rewards
- base-versus-player investment tension
- per-material essence capacity as a pacing lever
- the distinction between safe milestone rewards and vulnerable generated material essence
- modifier-count-based reward tier scaling for repeated pylon clears
- unified material research trees on the player core

Do not fully define yet:
- the full set of research nodes for every material
- exact economy values
- exact unlock order per tree
- every base building tied to material progression

This system should remain a high-level progression truth document until the first implementation slice is requested.