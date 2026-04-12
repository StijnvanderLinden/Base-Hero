# Pylon System Tracker

## Current Status
First Runtime Slice Implemented

## Current Design Summary
- players place one pylon during an expedition
- placement now validates against generated expedition terrain rather than a flat gate floor
- placing the pylon creates a flat circular build zone around the pylon
- the placed pylon channels iron into essence over time
- the pylon influence radius expands while channeling continues
- nearby resource signals are revealed through radius checks
- the pylon reports crystal counts in range without revealing crystal positions
- pylon upgrades spend essence on base radius, max radius, efficiency, and HP

## Implemented
- authoritative pylon placement during expeditions
- terrain-aware pylon placement validation against world bounds and slope
- automatic build-zone foundation creation when the pylon is placed
- authoritative pylon interaction flow through the existing player interact path
- runtime pylon state fields for level, influence radius, max radius, channel progress, and channeling state
- channel-time radius growth from the base radius toward the current max radius
- escalating enemy pressure while the pylon is channeling
- manual stop behavior that banks essence and increases max radius
- damaged pylon state when the pylon is destroyed mid-channel
- first-pass pylon upgrade buttons and costs

## In Progress
- tuning the first channel cost and essence gain curve
- tuning pylon build-zone radius versus combat pressure distance
- tuning pylon upgrade costs against the new essence flow
- deciding whether destroyed pylons should be repairable in-run or remain lost for that run

## Blockers / Problems
- the prototype still has no true fog-of-war rendering layer
- current reveal logic uses signal markers and counts rather than a full map system
- pylon upgrade data is session-scoped and not yet saved persistently
- the build zone still uses placeholder visuals rather than a finished pylon foundation look

## Must Have
- valid terrain placement checks
- automatic build zone tied to the active pylon
- one-pylon limit
- escalating channel enemy pressure
- radius growth during channeling
- authoritative essence banking
- pylon upgrade hooks for radius, cap, efficiency, and HP

## Should Have
- stronger in-world feedback for radius thresholds
- stronger visual readability for the pylon build zone edge
- explicit destroyed-pylon recovery rules
- clearer build-area and pylon-area overlap feedback

## Could Have
- multi-pylon placement limits later in progression
- pylon-specific visuals by material family
- deeper pylon event variants beyond the first channel loop

## Won’t Have (for now)
- multiple active pylons in the first slice
- player-chosen channel modifier decks
- deep pylon management UI trees

## Open Questions
- should manual stop trigger a short shutdown holdout or bank immediately
- how much permanent radius growth should a strong channel grant
- should later pylon levels consume essence on every channel or only advanced channels

## Recent Decisions
- the first runtime slice uses a player-placed pylon instead of a pre-claimed gate objective
- iron is the first raw material input for channel activation
- crystal positions stay hidden from pylon reveal logic
- essence is banked only on successful manual stop or retreat
- the placed pylon now defines the expedition build zone and enemy approach ring

## Next Recommended Task
Add a dedicated in-world channel feedback pass:
- stronger radius threshold effects
- stronger build-zone foundation presentation around the pylon
- clearer damaged-state recovery decision
- optional shutdown phase if the current immediate bank is too forgiving