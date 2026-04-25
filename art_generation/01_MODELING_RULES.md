# Modeling Rules

## Purpose

This document defines the modeling standards for AI-assisted Blender asset generation. Use it for all generated or revised models.

## Core Principles

- Clean structure over detail.
- Blockout first, detail later.
- Use low-poly geometry.
- Keep models human-editable.
- Make silhouettes readable from gameplay camera distance.
- Keep everything aligned, centered, and named.
- Avoid messy, excessive, or accidental geometry.

## Blockout Phase

Every model starts with a blockout.

Blockout requirements:

- Use simple primitives or clean custom meshes.
- Match the main silhouette before adding detail.
- Use front view for width and shape.
- Use side view for depth and thickness when references exist.
- Do not add small detail until the main shape reads correctly.
- Keep all major components separate and named.

## Low-Poly Constraints

- Use the fewest polygons needed to communicate the object.
- Prefer 6-16 sided cylinders depending on asset size.
- Use bevels sparingly on hard edges.
- Avoid subdivision surfaces unless explicitly needed.
- Avoid dense curves, sculpted detail, or smooth high-poly forms.
- Use flat or lightly weighted normals for clean stylized shading.

## Topology Rules

- Meshes should be clean and easy to edit.
- Avoid non-manifold geometry.
- Avoid loose accidental vertices or hidden duplicate geometry.
- Avoid paper-thin pieces unless they are intentionally stylized and readable.
- Keep intersecting geometry acceptable only when used deliberately to create connected construction.
- Do not leave visible gaps between parts that should be physically connected.

## Object Structure

Use separate named objects for major parts.

Examples:

- `Blade`
- `Guard`
- `Grip`
- `Pommel`
- `Base`
- `Barrel`
- `Core`
- `Support`
- `Frame`
- `Panel`

For compound assets, create a single parent root object:

- `Sword_StoneAge_Root`
- `Turret_FastShooter_Root`
- `Wall_WoodReinforced_Root`

Children should remain editable.

## Naming Conventions

Use clear PascalCase or readable underscore names.

Recommended:

- `Blade`
- `Crossguard`
- `GripWrap_01`
- `EnergyCore`
- `CannonBarrel`
- `WallPost_Left`

Avoid:

- `Cube.001`
- `Cylinder.004`
- `Object`
- `Mesh`
- `Thing`

## Scale Guidelines

Use Godot-friendly metric scale.

Approximate gameplay scale:

- Player height: about 1.8m
- One floor tile/module: about 2m
- Wall segment width: about 2m
- Small prop: 0.3m-1m
- Handheld weapon: 0.6m-1.5m depending on type
- Turret footprint: 1.5m-2.5m

Always keep scale consistent across related assets.

## Alignment

- Center assets on `X = 0` and `Y = 0` unless intentionally offset.
- Use the `Z` axis as vertical in Blender.
- Align symmetrical objects around the centerline.
- Keep forward direction consistent for gameplay use.
- No floating parts unless the object is intentionally magical or hovering.

## Pivot And Origin Rules

Set origins based on how the object will be used.

- Static props: origin at base center.
- Modular walls: origin at bottom center of module.
- Turrets: origin at footprint center, on ground.
- Rotating turret heads: separate pivot at rotation point.
- Weapons: origin at grip/hand position or logical swing pivot.
- Pickups: origin at visual center or ground contact point.
- Traps: origin at center of floor footprint.

## Symmetry Usage

Use mirror modifiers when helpful:

- Blades
- Shields
- Character bodies
- Enemy bodies
- Turret frames
- Wall modules

Apply or preserve modifiers based on editability needs. For exported `.glb`, ensure final geometry exports correctly.

## Bevel Rules

Use bevels to improve stylized readability.

- Bevel major hard edges.
- Keep bevel segment count low, usually 1.
- Avoid tiny bevels that add polygons without visible benefit.
- Apply bevels consistently across similar materials.

## Shading Rules

- Prefer flat shading for low-poly style.
- Use weighted normals only when it improves readability.
- Avoid overly smooth surfaces.
- Do not use realistic texture maps as a substitute for good silhouette.

## Materials

Use simple material slots:

- `Wood`
- `Stone`
- `Metal`
- `Brass`
- `Leather`
- `EnergyBlue`
- `EnemyAccent`

Materials should be easy to replace in Godot.

## AI To Blender Asset Pipeline

When generating assets from references:

- Provide front and side views when possible.
- Use orthographic perspective.
- Keep poses neutral and consistent.
- Use plain backgrounds.
- Make silhouettes clearly readable.

Generation flow:

1. Create blockout.
2. Check silhouette and proportions.
3. Add required structural components.
4. Add simple bevels and readable materials.
5. Verify all intended connected parts touch or overlap.
6. Name objects clearly.
7. Apply transforms.
8. Export `.glb`.

## Iteration Rules

When modifying an existing model:

- Do not rebuild from scratch unless requested.
- Adjust only the specified parts.
- Preserve naming and hierarchy.
- Preserve scale and pivot.
- Keep proportions consistent unless the request changes them.

## Avoid

- Floating geometry
- Random primitive stacking
- Misaligned parts
- Overly detailed meshes
- Non-manifold geometry
- Unnamed parts
- Unapplied transforms
- Generic silhouettes
