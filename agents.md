# agents.md

## Purpose
Defines how the assistant behaves and manages project knowledge.

Always read this first.

---

## Source of Truth Priority

1. gdd.md → what the game IS
2. system_specs → system truth
3. game_design.md → supporting design
4. architecture.md → technical truth
5. networking.md → multiplayer rules
6. system_trackers → system state
7. current_state.md → project state
8. development_plan.md → roadmap
9. backlog.md → ideas
10. decisions.md → history

---

## Project Summary
3D co-op base defense action game in Godot 4.

---

## Core Loop
Prepare → Gate → Extract → Upgrade → Raid

---

## Multiplayer Rules
Server authoritative.

Clients:
- send input

Server:
- decides all gameplay

---

## Steam Rule
Keep gameplay independent of networking backend.

---

## Development Phase
Early prototype.

---

# 🔥 DOCUMENT MANAGEMENT RULES

## Step 1: Classify User Input

- Idea
- Design Change
- Implementation
- Refinement

---

## Step 2: Route It

| Type | File |
|------|------|
| Idea | backlog.md |
| System design | system_specs |
| Confirmed design | game_design.md |
| Core game change | gdd.md |
| Implementation progress | system_trackers |
| Project state | current_state.md |
| Decision | decisions.md |

---

## Step 3: Ask Before Updating

Never update core docs without confirmation.

---

# 🎮 SYSTEM TRACKER RULES

Each major system has:

- system_specs → design
- system_trackers → state

Trackers MUST include:

- Current Status
- Implemented
- In Progress
- Must Have
- Should Have
- Could Have
- Won’t Have (for now)
- Open Questions
- Next Task

---

# 🧠 IMPLEMENTATION VS DOCUMENTATION

## DO NOT DOCUMENT
- animation tweaks
- camera tuning
- movement feel
- small balancing
- polish

## DO DOCUMENT
- gameplay systems
- mechanics
- architecture changes
- progression
- multiplayer rules

---

# 🧱 GODOT RULES

Assistant can:
- create scenes
- write scripts
- set up nodes
- create animations

Prefer:
- simple
- practical
- editable values

---

## Behavior
- small steps
- no overengineering
- ask when unsure

---

## Goal
Playable multiplayer prototype first