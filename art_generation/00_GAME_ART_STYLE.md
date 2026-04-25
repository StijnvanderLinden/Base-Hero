# Game Art Style

## Purpose

This document defines the shared visual direction for 3D low-poly assets in the project. Use it before generating or revising any Blender model.

The goal is a readable, stylized base-defense game with chunky engineered props, clear gameplay silhouettes, and a strong handcrafted mechanical identity.

## Core Identity

- Genre: 3D action base-defense
- Camera: medium-distance gameplay camera
- Priority: readability during combat
- Style: stylized low-poly
- Feel: toy-like, engineered, chunky, tactical
- Inspiration: Lock's Quest, stylized tower defense games, handcrafted defense contraptions

## Visual Pillars

- Engineer-tech fantasy, not futuristic sci-fi
- Chunky silhouettes over fine detail
- Mechanical construction with visible function
- Simple, expressive forms
- Base-defense readability from a distance
- Strong contrast between player, base defenses, enemies, and resources

## Shape Language

- Use large primary shapes first.
- Use exaggerated proportions.
- Prefer thick, sturdy silhouettes.
- Keep small details minimal and purposeful.
- Make function readable from shape alone.
- Use blocky, beveled geometry instead of smooth realism.

## Material Direction

Use simple, flat, readable materials:

- Wood: warm, sturdy, carved, plank-like
- Stone: chunky, chipped, blocky, muted
- Metal: hammered, simple, dark or brass-toned
- Energy: blue glowing cores, crystals, lenses, charge points
- Leather/rope: used for bindings, grips, straps, wrap bands

Avoid:

- Realistic PBR complexity
- High-frequency texture detail
- Photorealistic wear
- Tiny scratches, bolts, or surface noise
- Sleek sci-fi panels
- Excessive emissive effects

## Color Direction

Use readable, simple palettes:

- Base/player technology: warm wood, brass, stone, muted metal, blue energy accents
- Enemies: darker metal, red/orange threat accents, harsher angular shapes
- Resources: distinct material colors with clear silhouettes
- Interactable objects: stronger contrast or clear accent points

Do not make assets visually uniform. Important gameplay categories should be distinguishable by color, silhouette, and material grouping.

## Readability Rules

- Asset role must be understandable at medium camera distance.
- Avoid thin parts that disappear in motion.
- Do not rely on tiny details to communicate function.
- Make front-facing gameplay silhouettes clear.
- Use distinct height, width, and profile differences between asset roles.
- Use blue glow only where it communicates power, energy, interaction, or tech.

## What To Avoid

- Photorealism
- High-poly sculpted detail
- Micro-detail
- Overly complex geometry
- Sleek futuristic sci-fi designs
- Random primitive stacking
- Floating or disconnected parts
- Generic fantasy props without engineered function
- Thin silhouettes with unclear gameplay role

## AI Generation Reminder

When generating assets with Blender:

- Start with blockout.
- Match silhouette first.
- Keep parts named and editable.
- Align and center every asset.
- Preserve clear object structure.
- Export clean `.glb` assets for Godot.
