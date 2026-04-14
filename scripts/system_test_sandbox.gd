extends Node3D

const SUITE_BUILDING_LAB := "building_lab"
const SUITE_COMBAT_ARENA := "combat_arena"
const SUITE_ENEMY_PRESSURE := "enemy_pressure"

@onready var network_manager = $NetworkManager
@onready var enemy_manager = $EnemyManager
@onready var building_manager = $BuildingManager
@onready var era_manager = $EraManager
@onready var core_objective = $World/CoreObjective
@onready var menu_dimmer: ColorRect = $UI/MenuDimmer
@onready var menu_panel: PanelContainer = $UI/PanelContainer
@onready var menu_hint_label: Label = $UI/MenuHintLabel
@onready var status_label: Label = $UI/PanelContainer/MarginContainer/VBoxContainer/StatusLabel
@onready var wave_label: Label = $UI/PanelContainer/MarginContainer/VBoxContainer/WaveLabel
@onready var objective_label: Label = $UI/PanelContainer/MarginContainer/VBoxContainer/ObjectiveLabel
@onready var controls_label: Label = $UI/PanelContainer/MarginContainer/VBoxContainer/ControlsLabel
@onready var back_button: Button = $UI/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/BackButton
@onready var reload_button: Button = $UI/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/ReloadButton
@onready var spawn_enemy_button: Button = $UI/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/SpawnEnemyButton
@onready var start_raid_button: Button = $UI/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/StartRaidButton
@onready var start_gate_button: Button = $UI/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/StartGateButton
@onready var pause_button: Button = $UI/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/PauseButton
@onready var clear_button: Button = $UI/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/ClearEnemiesButton
@onready var reset_button: Button = $UI/PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/ResetButton
@onready var players_root: Node3D = $World/Players
@onready var enemies_root: Node3D = $World/Enemies
@onready var walls_root: Node3D = $World/Walls
@onready var projectiles_root: Node3D = $World/Projectiles
@onready var enemy_spawn_marker: Marker3D = $World/EnemySpawn

var _manual_enemy_id: int = 1000
var _suite_profile: Dictionary = {}
var _suite_id: String = ""
var _menu_open: bool = false


func _ready() -> void:
	add_to_group("main_root")
	_suite_id = _current_suite_id()
	_suite_profile = _build_suite_profile(_suite_id)
	_configure_runtime()
	_wire_signals()
	_apply_suite_profile()
	_status("Suite ready. Hosting local sandbox session.")
	var host_error = network_manager.host_game(network_manager.default_port)
	if host_error != OK:
		_status("Failed to host local sandbox on port %d." % network_manager.default_port)
	_set_menu_open(false)
	_refresh_runtime_labels()


func _process(_delta: float) -> void:
	_refresh_runtime_labels()


func handle_local_interaction(_peer_id: int) -> bool:
	return false


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB:
			_set_menu_open(not _menu_open)
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_ESCAPE and _menu_open:
			_set_menu_open(false)
			get_viewport().set_input_as_handled()


func _configure_runtime() -> void:
	network_manager.set_players_root(players_root)
	building_manager.set_roots(walls_root, projectiles_root, players_root, core_objective)
	building_manager.bind_network_manager(network_manager)
	enemy_manager.set_roots(enemies_root, players_root)
	enemy_manager.set_objective(core_objective)
	enemy_manager.bind_network_manager(network_manager)
	enemy_manager.set_era_manager(era_manager)


func _wire_signals() -> void:
	network_manager.status_changed.connect(_status)
	enemy_manager.wave_changed.connect(_on_wave_changed)
	enemy_manager.raid_finished.connect(func(success: bool) -> void:
		_status("Raid finished: %s." % ("success" if success else "failed"))
	)
	enemy_manager.gate_pressure_finished.connect(func(cleared: bool) -> void:
		_status("Gate pressure finished: %s." % ("cleared" if cleared else "stopped"))
	)
	core_objective.destroyed.connect(func() -> void:
		_status("Objective destroyed. Use Reset Session to restart the sandbox.")
	)
	back_button.pressed.connect(_on_back_pressed)
	reload_button.pressed.connect(_on_reload_pressed)
	spawn_enemy_button.pressed.connect(_on_spawn_enemy_pressed)
	start_raid_button.pressed.connect(_on_start_raid_pressed)
	start_gate_button.pressed.connect(_on_start_gate_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	reset_button.pressed.connect(_on_reset_pressed)


func _apply_suite_profile() -> void:
	controls_label.text = String(_suite_profile.get("controls", ""))
	spawn_enemy_button.visible = bool(_suite_profile.get("show_spawn_enemy", true))
	start_raid_button.visible = bool(_suite_profile.get("show_start_raid", true))
	start_gate_button.visible = bool(_suite_profile.get("show_start_gate", true))
	pause_button.visible = bool(_suite_profile.get("show_pause", true))
	clear_button.visible = bool(_suite_profile.get("show_clear", true))
	if bool(_suite_profile.get("free_building", false)):
		building_manager.wall_cost = 0
		building_manager.turret_cost = 0
		building_manager.wall_repair_cost = 0
		building_manager.turret_repair_cost = 0
	if int(_suite_profile.get("max_walls", 0)) > 0:
		building_manager.max_walls = int(_suite_profile.get("max_walls", building_manager.max_walls))
	if int(_suite_profile.get("max_turrets", 0)) > 0:
		building_manager.max_turrets = int(_suite_profile.get("max_turrets", building_manager.max_turrets))
	if bool(_suite_profile.get("auto_start_raid", false)):
		call_deferred("_start_configured_raid")


func _build_suite_profile(suite_id: String) -> Dictionary:
	match suite_id:
		SUITE_BUILDING_LAB:
			return {
				"controls": "Esc releases the mouse. Q toggles build mode, 1 selects walls, 2 selects turrets, R rotates, left click places, and E repairs. Use Spawn Enemy to test turret fire and repair loops.",
				"free_building": true,
				"show_spawn_enemy": true,
				"show_start_raid": false,
				"show_start_gate": false,
				"show_pause": false,
				"show_clear": true,
				"max_walls": 48,
				"max_turrets": 16,
			}
		SUITE_ENEMY_PRESSURE:
			return {
				"controls": "Esc releases the mouse. Use Start Raid for fixed raid waves or Start Gate for era-driven gate pressure. Build defenses first if you want to test enemy pathing against structures.",
				"free_building": true,
				"show_spawn_enemy": false,
				"show_start_raid": true,
				"show_start_gate": true,
				"show_pause": true,
				"show_clear": true,
				"max_walls": 48,
				"max_turrets": 16,
			}
		_:
			return {
				"controls": "Esc releases the mouse. Left click attacks, right click uses the heavy shot. Use Spawn Enemy to create a close-range duel without the rest of the game running.",
				"free_building": true,
				"show_spawn_enemy": true,
				"show_start_raid": false,
				"show_start_gate": false,
				"show_pause": false,
				"show_clear": true,
			}


func _current_suite_id() -> String:
	if SystemTestRegistry.current_suite == null:
		return ""
	return SystemTestRegistry.current_suite.suite_id


func _on_back_pressed() -> void:
	SystemTestRegistry.return_to_picker()


func _on_reload_pressed() -> void:
	SystemTestRegistry.reload_current_suite()


func _on_spawn_enemy_pressed() -> void:
	_spawn_manual_enemy(String(_suite_profile.get("manual_enemy_kind", "stone_caveman")))


func _on_start_raid_pressed() -> void:
	_start_configured_raid()


func _on_start_gate_pressed() -> void:
	if not multiplayer.is_server():
		return
	enemy_manager.start_gate_pressure(core_objective, core_objective.global_position, false)
	enemy_manager.set_spawning_paused(false)
	_status("Gate pressure started.")


func _on_pause_pressed() -> void:
	if not multiplayer.is_server():
		return
	if enemy_manager.get_pressure_mode() == "idle":
		_status("Start raid or gate pressure first.")
		return
	var paused := not _is_spawning_paused()
	enemy_manager.set_spawning_paused(paused)
	pause_button.text = "Resume Spawns" if paused else "Pause Spawns"
	_status("Spawning %s." % ("paused" if paused else "resumed"))


func _on_clear_pressed() -> void:
	if not multiplayer.is_server():
		return
	enemy_manager.stop_pressure(true)
	pause_button.text = "Pause Spawns"
	_status("All active enemies cleared.")


func _on_reset_pressed() -> void:
	if not multiplayer.is_server():
		return
	enemy_manager.force_restart()
	building_manager.restart_match()
	core_objective.restart_match()
	network_manager.restart_match()
	pause_button.text = "Pause Spawns"
	_status("Sandbox reset.")


func _start_configured_raid() -> void:
	if not multiplayer.is_server():
		return
	enemy_manager.start_raid_pressure(core_objective, core_objective.global_position, 3, 8, 6, 1.2, 2, 4.0)
	pause_button.text = "Pause Spawns"
	_status("Raid pressure started.")


func _spawn_manual_enemy(enemy_kind: String) -> void:
	if not multiplayer.is_server():
		return
	var enemy_scene = era_manager.get_enemy_scene(enemy_kind)
	if enemy_scene == null:
		enemy_scene = enemy_manager.enemy_scene
	if enemy_scene == null:
		_status("No enemy scene available for %s." % enemy_kind)
		return
	var enemy = enemy_scene.instantiate()
	enemy.name = "Enemy_%d" % _manual_enemy_id
	if enemy.has_method("setup"):
		enemy.setup(_manual_enemy_id, enemy_spawn_marker.global_position)
	if enemy.has_method("set_manager"):
		enemy.set_manager(enemy_manager)
	enemies_root.add_child(enemy)
	_manual_enemy_id += 1
	_status("Spawned %s." % enemy_kind)


func _on_wave_changed(wave_index: int, is_breather: bool) -> void:
	var phase := "breather" if is_breather else "active"
	_status("Wave %d %s." % [wave_index, phase])


func _status(message: String) -> void:
	status_label.text = message


func _refresh_runtime_labels() -> void:
	var pressure_mode = enemy_manager.get_pressure_mode().capitalize()
	if pressure_mode == "Idle":
		pressure_mode = "Idle"
	wave_label.text = "Pressure: %s | Enemies: %d" % [pressure_mode, enemies_root.get_child_count()]
	objective_label.text = "Objective HP: %d / %d" % [int(round(core_objective.get_current_health())), int(round(core_objective.max_health))]


func _is_spawning_paused() -> bool:
	return pause_button.text == "Resume Spawns"


func _set_menu_open(open: bool) -> void:
	_menu_open = open
	menu_panel.visible = open
	menu_dimmer.visible = open
	var player := _local_player()
	if player != null and player.has_method("set_ui_locked"):
		player.set_ui_locked(open)
	if open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _local_player() -> Node:
	var local_peer_id := multiplayer.get_unique_id()
	var node_name := "Player_%d" % local_peer_id
	if not players_root.has_node(node_name):
		return null
	return players_root.get_node(node_name)
