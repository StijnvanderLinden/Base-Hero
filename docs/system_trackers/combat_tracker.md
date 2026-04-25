# Combat System Tracker

## Current Status
Melee / Ranged Weapon Slice Started

## Current Design Summary
Combat supports active defense during the gate arena.

Players should matter beside turrets. The MVP now uses two simple weapon modes:
- melee horizontal arc slash
- ranged projectile

## Implemented
- Basic player attack foundation exists
- Enemy health and death foundation exists
- Players can switch between melee and ranged with a keybind
- Melee primary attack now performs a server-authoritative horizontal arc slash
- Melee heavy attack performs a stronger slash
- Ranged attacks still use the existing projectile path

## In Progress
- Making melee hits feel satisfying against wave pressure
- Tuning combat around wave pressure and scrap income

## Blockers / Problems
- Combat feel is still placeholder-heavy

## Must Have
- Melee primary arc slash
- Ranged projectile mode
- Weapon switch keybind
- Server-authoritative damage
- Clear enemy hit/death feedback
- Player death with about 20-second respawn

## Should Have
- Generous hit validation
- Readable crowd combat
- Feedback that makes active defense satisfying

## Could Have
- Optional basic weapon upgrade from hub
- Better slash visuals, sound, hit stop, or screen feedback

## Won't Have (for now)
- Many weapon families
- Complex augment trees
- Class systems

## Open Questions
- Does melee feel good enough to make survival active?
- Is the weapon switch useful during pressure?

## Recent Decisions
- Combat should prioritize satisfying melee feel before adding more systems

## Next Recommended Task
Playtest melee slash feel against early wave pressure, then improve hit feedback before adding new systems.
