# Base-Hero

## System Test Suites
The project now boots into a system test picker instead of directly into the full game.

Use it to:
- launch the full integrated prototype when you want the normal loop
- launch isolated sandboxes for combat, building, or enemy pressure
- add new focused suites without cloning the full main scene

To add a new suite:
1. Create a scene for the system slice you want to test.
2. Create a `.tres` file in `res://resources/test_suites` using `res://scripts/system_test_suite_definition.gd`.
3. Point the resource `scene_path` at your new scene.
4. Relaunch the picker or use the host scene reload button.

The picker discovers suites automatically by scanning `res://resources/test_suites`.
