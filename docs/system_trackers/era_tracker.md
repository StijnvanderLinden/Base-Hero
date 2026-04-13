# Era System Tracker

## Current Status
Era System Implemented With Stone Age As The First Playable Slice

## Current Design Summary
The Era System now packages gate content into data-driven EraData resources consumed by a central EraManager.

The first live era slice defines:
- enemy lineup
- structure variants
- material nodes
- research availability
- augment availability
- wave definitions

Only Stone Age is unlocked. Bronze Age remains a placeholder.

## Implemented
- EraData resource class exists
- EraManager exists and tracks unlocked/current gate era
- gate runs now select an active era
- Stone Age era resource defines enemies, structures, materials, augments, research, and waves
- a locked placeholder exists for the next era
- gate, enemy, building, and research managers now read era data

## In Progress
- later era unlock flow is still placeholder only
- gate-selection UI is not implemented yet
- visual-theme application is still limited to data placeholders and text context

## Blockers / Problems
- later eras do not have playable content yet
- no dedicated gate-selection UI exists yet
- era-specific environment art application is still thin in runtime presentation

## Must Have
- era-owned content bundles
- data-driven gate era selection
- one fully playable first era
- clean room for future era expansion

## Should Have
- gate-selection UI
- clearer era-based environment presentation
- progression-based era unlock validation in runtime UI

## Could Have
- era-specific modifier pools later
- era-specific pylon visuals later
- era-based music and ambient swaps later

## Won’t Have (for now)
- multiple fully playable eras at once
- deep cross-era dependency chains
- complex era-selection UX before the first slice is stable

## Open Questions
- when should the second era unlock in the broader progression loop?
- how much of an era should be shared across gates versus tied to a specific gate instance?
- how much era visual theming should be applied by runtime systems versus authored scenes?

## Recent Decisions
- gates now load self-contained era content packages
- the era system is resource-driven rather than hardcoded per manager
- only Stone Age is fully implemented in the first pass
- future eras stay as placeholders until explicitly developed

## Next Recommended Task
Validate the Stone Age slice in multiplayer and then add the first era unlock contract for the next placeholder era.