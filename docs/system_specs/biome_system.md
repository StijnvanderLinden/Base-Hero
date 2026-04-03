# Biome System Specification

## Purpose
The Biome System defines how gate regions differ from one another through environment, enemy families, materials, and mechanics.

Biomes are a key part of making gates feel persistent, memorable, and varied.

---

## Design Goals
- Give each gate region a clear identity
- Tie exploration pressure to the biome itself
- Support layered progression through distinct local rules
- Keep the first biome simple and readable
- Expand later biomes through unique mechanics rather than cosmetic swaps only

---

## Core Rule
Biome mechanics are biome-specific, not global.

This means each biome can define:
- local hazards
- exploration pressure
- material identity
- visibility or traversal rules later

The game should not rely on one universal gate gimmick for every region.

---

## Biome Responsibilities
A biome defines:
- environmental look and mood
- exploration enemy families
- local resource identity
- encounter flavor
- later mechanical twists unique to that biome

---

## First Biome Rule
The first biome should be:
- simple
- readable
- low on gimmicks
- easy to understand in co-op

Its job is to prove the persistent gate structure clearly before more advanced biome mechanics are added.

---

## Advanced Biomes
Later biomes may introduce mechanics such as:
- darkness and light pressure
- visibility constraints
- environmental hazards
- movement restrictions
- region-specific interaction rules

These mechanics should be introduced per biome, not assumed globally.

---

## Enemy Relationship
Biomes primarily define exploration enemies.

This means:
- roaming threats should reflect the biome
- ambient encounters should help the region feel alive
- pylon and raid constructs remain a separate system layered on top

---

## Resource Relationship
Biomes may influence:
- which common materials appear
- which rare materials can be earned
- where deeper progression rewards come from

Biome identity should matter for what players want to hunt for and return to.

---

## Co-op Considerations
Biome mechanics must remain readable in co-op.

Requirements:
- clear communication of biome-specific rules
- manageable visual clutter in 3D
- fair navigation and hazard readability for multiple players

---

## Early Prototype Direction
The first biome milestone should include:
- one simple biome region
- one exploration enemy family tied to that biome
- one consistent visual and resource identity
- no heavy gimmick dependency

---

## Future Extensions
Possible future additions:
- biome-specific mutators
- stronger environmental storytelling
- unique traversal rules
- more specialized deep-layer hazards
- biome-linked elite encounters