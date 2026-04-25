# Export Rules For Godot

## Purpose

This document defines how Blender assets should be prepared and exported for Godot.

## Export Format

- Export as `.glb`.
- Use binary GLTF for simple asset handling.
- Keep one asset per file unless it is intentionally a small set.

Recommended folder:

- `assets/`
- `assets/weapons/`
- `assets/buildings/`
- `assets/enemies/`
- `assets/props/`

## Scale

- Use metric scale.
- Blender unit scale should correspond to Godot meters.
- Keep related assets consistent.
- Verify player-relative size before finalizing.

## Transforms

Before export:

- Apply location if the asset should sit at origin.
- Apply rotation.
- Apply scale.
- Ensure no accidental negative scale unless intentionally used and applied.
- Ensure child transforms are clean enough to edit later.

## Origin Placement

Set origins logically:

- Walls: bottom center
- Turrets: ground footprint center
- Turret head: rotation center
- Weapons: grip or swing pivot
- Enemies: ground center
- Props: ground center or visual center depending on use
- UI 3D props: interaction/pivot center

## Orientation

- Use `Z` as vertical.
- Keep the asset centered on `X = 0`, `Y = 0`.
- Keep forward direction consistent for the asset type.
- Weapons should align along a predictable axis and be easy to attach to a hand or pivot.

## Naming

File names should describe type and role.

Examples:

- `wall_wood_reinforced.glb`
- `turret_fast_shooter.glb`
- `trap_spike_plate.glb`
- `enemy_bruiser_mech.glb`
- `weapon_stone_sword.glb`

Object names inside Blender should remain meaningful after import.

## Materials

Use simple material names:

- `Wood`
- `Stone`
- `Metal`
- `Brass`
- `Leather`
- `EnergyBlue`
- `EnemyRed`

Avoid:

- Procedural shader complexity
- Heavy texture dependencies
- Unnamed material slots
- Dozens of materials on one simple asset

## Mesh Cleanliness

Before export, verify:

- No floating pieces unless intentional.
- No accidental hidden objects.
- No unused reference planes.
- No extra cameras or lights unless requested.
- No excessive polygon count.
- No loose vertices.
- All visible connected parts touch or overlap cleanly.

## Godot Import Expectations

Assets should be usable immediately after import:

- Correct scale
- Correct orientation
- Correct pivot
- Clear hierarchy
- Readable materials
- No required post-import cleanup

## Collision

Do not generate detailed collision meshes by default.

For gameplay assets:

- Use simple box/capsule/cylinder collision in Godot.
- Add custom collision only if requested.
- Keep visual mesh and collision mesh separate when collision is generated.

## LOD And Optimization

For the prototype:

- Prioritize clean readable assets over LOD systems.
- Keep low-poly geometry naturally cheap.
- Avoid dense decorative geometry.

## Export Checklist

- Asset matches style guide.
- Major parts are named.
- Transforms are applied.
- Scale is correct.
- Origin is logical.
- Materials are simple.
- Mesh is clean.
- `.glb` exported to the correct project folder.
- Godot scene loads without import errors.
