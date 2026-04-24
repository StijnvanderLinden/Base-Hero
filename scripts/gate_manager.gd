extends Node

const RESOURCE_NODE_SCENE := preload("res://scenes/resource_node.tscn")

signal status_changed(message: String)
signal run_info_changed(message: String)
signal gate_state_changed(is_active: bool)
signal progression_changed()

@export var gate_objective_scene: PackedScene
@export var gate_center: Vector3 = Vector3(64.0, 0.6, 0.0)
@export var gate_objective_max_health: float = 240.0
@export var extraction_countdown: float = 5.0
@export var objective_interaction_radius: float = 3.0
@export var resource_interaction_radius: float = 2.5
@export var player_spawn_spacing: float = 3.0
@export var starting_scrap: int = 100
@export var starter_material_amount: int = 300
@export var core_upgrade_base_cost: int = 25
@export var core_upgrade_cost_step: int = 15
@export var core_upgrade_health_bonus: float = 100.0
@export var pylon_place_distance: float = 6.5
@export var pylon_min_spacing: float = 20.0
@export var pylon_floor_half_extent: float = 18.0
@export var pylon_base_radius: float = 20.0
@export var pylon_base_max_radius: float = 80.0
@export var pylon_channel_material_cost: int = 20
@export var pylon_advanced_channel_essence_cost: int = 300
@export var pylon_essence_rate: float = 7.5
@export var pylon_channel_stage_seconds: float = 30.0
@export var pylon_health_upgrade_bonus: float = 80.0
@export var pylon_radius_upgrade_step: float = 6.0
@export var pylon_max_radius_upgrade_step: float = 10.0
@export var pylon_efficiency_upgrade_step: float = 0.2
@export var pylon_build_radius: float = 12.0
@export var pylon_flatten_radius: float = 14.0
@export var pylon_resource_clearance_radius: float = 14.0
@export var enemy_spawn_min_radius: float = 18.0
@export var enemy_spawn_max_radius: float = 26.0
@export var scattered_stone_node_count: int = 18
@export var scattered_wood_node_count: int = 18
@export var scattered_herb_patch_count: int = 24
@export var resource_scatter_min_radius: float = 20.0
@export var resource_scatter_max_radius: float = 96.0
@export var resource_scatter_jitter: float = 7.5

var gate_root: Node3D
var players_root: Node3D
var base_objective: Node3D
var enemy_manager: Node
var building_manager: Node
var cave_manager: Node
var network_manager: Node
var research_manager: Node
var world_generator: Node
var era_manager: Node
var _session_active: bool = false
var _gate_active: bool = false
var _extraction_active: bool = false
var _extraction_remaining: float = 0.0
var _sync_timer: float = 0.0
var _gate_objective: Node3D
var _base_core_max_health: float = 300.0
var _core_upgrade_level: int = 0
var _stored_scrap: int = 0
var _stored_materials: Dictionary = {"iron": 0}
var _pending_essence: float = 0.0
var _channel_elapsed: float = 0.0
var _channel_active: bool = false
var _run_base_positions: Array[Vector3] = []
var _run_base_upgrades: Dictionary = {
	"base_radius": 0,
	"max_radius": 0,
	"channel_efficiency": 0,
	"health": 0,
}
var _resource_nodes: Dictionary = {}
var _resource_definitions: Array[Dictionary] = []
var _collected_resource_ids: Dictionary = {}
var _collected_crystal_ids: Dictionary = {}
var _current_era_id: String = "stone_age"


func _ready() -> void:
	add_to_group("gate_manager")
	_refresh_era_runtime_data()


func set_roots(new_gate_root: Node3D, new_players_root: Node3D, new_base_objective: Node3D) -> void:
	gate_root = new_gate_root
	players_root = new_players_root
	base_objective = new_base_objective
	if base_objective != null and "max_health" in base_objective:
		_base_core_max_health = base_objective.max_health


func set_enemy_manager(manager: Node) -> void:
	if enemy_manager != null and enemy_manager.has_signal("gate_pressure_finished") and enemy_manager.gate_pressure_finished.is_connected(_on_gate_pressure_finished):
		enemy_manager.gate_pressure_finished.disconnect(_on_gate_pressure_finished)
	enemy_manager = manager
	if enemy_manager != null and enemy_manager.has_signal("gate_pressure_finished"):
		enemy_manager.gate_pressure_finished.connect(_on_gate_pressure_finished)


func set_building_manager(manager: Node) -> void:
	building_manager = manager


func set_research_manager(manager: Node) -> void:
	research_manager = manager


func set_era_manager(manager: Node) -> void:
	era_manager = manager
	_refresh_era_runtime_data()


func set_world_generator(generator: Node) -> void:
	world_generator = generator


func set_cave_manager(manager: Node) -> void:
	cave_manager = manager


func bind_network_manager(manager: Node) -> void:
	network_manager = manager
	if manager.has_signal("session_changed"):
		manager.session_changed.connect(_on_session_changed)
	if manager.has_signal("peer_registered"):
		manager.peer_registered.connect(_on_peer_registered)


func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	if not _gate_active:
		return
	if _extraction_active:
		_extraction_remaining = max(_extraction_remaining - delta, 0.0)
		if _extraction_remaining <= 0.0:
			_finish_gate(true)
			return
	elif _channel_active and _gate_objective != null:
		_channel_elapsed += delta
		_pending_essence += _current_channel_rate() * delta
		_apply_channel_growth()

	_sync_timer += delta
	if _sync_timer >= 0.2:
		_sync_timer = 0.0
		_update_resource_reveal_states()
		_broadcast_gate_state()


func start_gate_run() -> void:
	if not multiplayer.is_server():
		return
	if not _session_active:
		return
	if _gate_active:
		return
	if gate_root == null or players_root == null or gate_objective_scene == null:
		return
	if era_manager != null and era_manager.has_method("get_active_gate_era_id"):
		_current_era_id = String(era_manager.get_active_gate_era_id())
		if era_manager.has_method("set_active_gate_era"):
			era_manager.set_active_gate_era(_current_era_id)
	_refresh_era_runtime_data()

	_reset_gate_runtime_state(false)
	if world_generator != null and world_generator.has_method("generate_world"):
		world_generator.generate_world(int(Time.get_unix_time_from_system()) + randi())
	_gate_active = true
	_activate_run_base_at(_gate_spawn_center())
	_spawn_saved_run_base_layout()
	spawn_resource_nodes_local()
	_sync_gate_setup.rpc(true)
	_teleport_players_to_gate()
	_stop_enemy_pressure()
	gate_state_changed.emit(true)
	status_changed.emit("%s live. The run base is active. Gather materials, return to the core, and press E to start channeling." % get_current_era_name())
	_emit_run_info()
	_broadcast_gate_state()


func restart_match() -> void:
	if not multiplayer.is_server():
		return
	_clear_gate_mode(false)
	_stop_enemy_pressure()
	_sync_gate_setup.rpc(false)
	_emit_run_info()
	_broadcast_gate_state()


func is_gate_active() -> bool:
	return _gate_active


func is_build_phase_active() -> bool:
	return _gate_active and not _extraction_active and not _channel_active and get_gate_pylon_state() != "damaged"


func is_cave_active() -> bool:
	return _gate_active and _channel_active


func is_cave_activation_channeling() -> bool:
	return false


func is_repair_channeling() -> bool:
	return false


func is_extraction_active() -> bool:
	return _gate_active and _extraction_active


func can_return_to_base() -> bool:
	if not _gate_active:
		return false
	return not _extraction_active


func request_return_to_base() -> void:
	if not multiplayer.is_server():
		return
	if not _gate_active:
		return
	if _extraction_active:
		status_changed.emit("Return to base is already in progress.")
		return
	if _channel_active:
		_stop_core_channel(true)
	_extraction_active = true
	_extraction_remaining = extraction_countdown
	status_changed.emit("Retreat started. Hold out until extraction completes.")
	_broadcast_gate_state()


func get_current_run_reward() -> float:
	return _pending_essence


func get_current_reward_rate() -> float:
	return _current_channel_rate()


func get_gate_pylon_state() -> String:
	return get_run_base_state()


func get_run_base_state() -> String:
	if _gate_objective == null:
		return "unplaced"
	if _gate_objective.has_method("get_pylon_state"):
		return _gate_objective.get_pylon_state()
	return "functional"


func get_cave_status_snapshot() -> Dictionary:
	return get_channel_status_snapshot()


func get_channel_status_snapshot() -> Dictionary:
	return get_pylon_status_snapshot()


func get_pylon_status_snapshot() -> Dictionary:
	var pylon_state := get_run_base_state()
	var visible := _gate_active
	var state_label := "Core Ready"
	var detail_label := "Return gathered materials here and interact to start or stop channeling."
	if pylon_state == "functional" and _channel_active:
		state_label = "Channeling"
		detail_label = "Defend the core while primary resource builds and the safe zone expands."
	elif pylon_state == "functional":
		state_label = "Core Ready"
		detail_label = "Interact with the core to start or stop channeling."
	elif pylon_state == "damaged":
		state_label = "Core Lost"
		detail_label = "The channel collapsed. Extract if you can or regroup on the next run."
	var reveal_counts := _revealed_resource_counts()
	return {
		"visible": visible,
		"state_label": state_label,
		"detail_label": detail_label,
		"pylon_state": pylon_state,
		"reward_rate": _current_channel_rate(),
		"current_reward": _pending_essence,
		"channel_active": _channel_active,
		"channel_elapsed": _channel_elapsed,
		"channel_progress_ratio": clamp(_channel_elapsed / max(pylon_channel_stage_seconds * 2.0, 0.001), 0.0, 1.0),
		"influence_radius": _current_run_base_influence_radius(),
		"max_radius": _current_run_base_radius_cap(),
		"crystals_remaining": _crystals_remaining_in_radius(),
		"ore_revealed": int(reveal_counts.get("stone_node", 0)),
		"stone_revealed": int(reveal_counts.get("stone_node", 0)),
		"wood_revealed": int(reveal_counts.get("wood_node", 0)),
		"herbs_revealed": int(reveal_counts.get("herb_patch", 0)),
		"caves_revealed": int(reveal_counts.get("cave_site", 0)),
		"treasure_revealed": int(reveal_counts.get("treasure_spot", 0)),
		"extraction_active": _extraction_active,
		"extraction_remaining": _extraction_remaining,
		"pylon_level": _current_run_base_level(),
	}


func get_gate_center() -> Vector3:
	return gate_center


func get_active_objective_position() -> Vector3:
	if _gate_active and _gate_objective != null:
		return _gate_objective.global_position
	if base_objective != null:
		return base_objective.global_position
	return gate_center


func get_stored_scrap() -> int:
	return _stored_scrap


func can_afford_scrap(amount: int) -> bool:
	return _stored_scrap >= max(amount, 0)


func consume_scrap(amount: int) -> bool:
	if not multiplayer.is_server():
		return false
	var safe_amount = max(amount, 0)
	if _stored_scrap < safe_amount:
		return false
	_stored_scrap -= safe_amount
	_broadcast_gate_state()
	return true


func add_scrap(amount: int, reason: String = "") -> void:
	if not multiplayer.is_server():
		return
	var safe_amount = max(amount, 0)
	if safe_amount <= 0:
		return
	_stored_scrap += safe_amount
	if reason == "":
		status_changed.emit("+%d scrap. Stored: %d." % [safe_amount, _stored_scrap])
	else:
		status_changed.emit("%s: +%d scrap. Stored: %d." % [reason, safe_amount, _stored_scrap])
	_broadcast_gate_state()


func get_core_upgrade_level() -> int:
	return _core_upgrade_level


func get_next_core_upgrade_cost() -> int:
	return core_upgrade_base_cost + (_core_upgrade_level * core_upgrade_cost_step)


func get_current_base_core_max_health() -> float:
	return _base_core_max_health + (float(_core_upgrade_level) * core_upgrade_health_bonus)


func can_purchase_core_upgrade() -> bool:
	if not multiplayer.is_server():
		return false
	if not _session_active or _gate_active:
		return false
	return _stored_scrap >= get_next_core_upgrade_cost()


func purchase_core_upgrade() -> void:
	if not multiplayer.is_server():
		return
	if not _session_active:
		status_changed.emit("Start a session before buying upgrades.")
		return
	if _gate_active:
		status_changed.emit("Core upgrades can only be bought while back at base.")
		return
	var upgrade_cost := get_next_core_upgrade_cost()
	if _stored_scrap < upgrade_cost:
		status_changed.emit("Need %d scrap for the next core upgrade. Stored: %d." % [upgrade_cost, _stored_scrap])
		return
	_stored_scrap -= upgrade_cost
	_core_upgrade_level += 1
	_apply_progression_to_base_objective(true)
	status_changed.emit("Core upgraded to level %d. Max health is now %d." % [_core_upgrade_level, int(round(get_current_base_core_max_health()))])
	_broadcast_gate_state()


func _on_session_changed(in_session: bool) -> void:
	_session_active = in_session
	if in_session:
		_apply_progression_to_base_objective(false)
		_emit_run_info()
		progression_changed.emit()
		return
	_clear_gate_mode(false)
	_reset_progression_state()
	_emit_run_info()
	progression_changed.emit()


func _on_peer_registered(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	_sync_gate_setup.rpc_id(peer_id, _gate_active)
	_sync_gate_state.rpc_id(peer_id, _state_snapshot())
	if _gate_active:
		call_deferred("_teleport_peer_to_gate", peer_id)


func request_objective_interaction(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	if not _gate_active or _extraction_active:
		return
	if players_root == null:
		return
	var node_name := "Player_%d" % peer_id
	if not players_root.has_node(node_name):
		return
	var player = players_root.get_node(node_name)
	if not player is Node3D:
		return
	if _try_collect_resource(peer_id, player):
		return
	if _gate_objective == null:
		_try_activate_run_base(peer_id, player)
		return
	if player.global_position.distance_to(_gate_objective.global_position) > objective_interaction_radius:
		return
	if get_gate_pylon_state() == "damaged":
		status_changed.emit("The pylon is shattered. Return to base and regroup.")
		return
	if _channel_active:
		_stop_core_channel(true)
		return
	_start_core_channel()


func request_local_objective_interaction(peer_id: int) -> void:
	if multiplayer.is_server():
		request_objective_interaction(peer_id)
		return
	_request_objective_interaction_rpc.rpc_id(1)


func can_open_pylon_menu_for_peer(peer_id: int) -> bool:
	return can_open_core_console_for_peer(peer_id)


func can_open_core_console_for_peer(peer_id: int) -> bool:
	if not _gate_active or _gate_objective == null:
		return false
	var player := _player_node(peer_id)
	if player == null:
		return false
	return player.global_position.distance_to(_gate_objective.global_position) <= objective_interaction_radius


func get_material_amount(material_id: String) -> int:
	return int(_stored_materials.get(material_id, 0))


@rpc("any_peer", "call_remote", "reliable")
func _request_objective_interaction_rpc() -> void:
	if not multiplayer.is_server():
		return
	request_objective_interaction(multiplayer.get_remote_sender_id())


func get_interaction_prompt_for_peer(peer_id: int) -> Dictionary:
	if not _gate_active:
		return {"visible": false, "text": ""}
	var player := _player_node(peer_id)
	if player == null:
		return {"visible": false, "text": ""}
	for resource_node in _resource_nodes.values():
		if resource_node == null:
			continue
		if not resource_node.has_method("can_interact") or not resource_node.can_interact():
			continue
		if player.global_position.distance_to(resource_node.global_position) > resource_interaction_radius:
			continue
		return {"visible": true, "text": resource_node.get_interaction_text()}
	if _gate_objective == null:
		var placement := _placement_position_for_player(player)
		if _has_blocking_resources_near_run_base(placement):
			return {"visible": true, "text": "Clear stone, wood, and herbs from the pylon area"}
		if _is_valid_run_base_position(placement):
			return {"visible": true, "text": "Press E to place pylon"}
		return {"visible": true, "text": "Move to open ground to place the pylon"}
	if player.global_position.distance_to(_gate_objective.global_position) > objective_interaction_radius:
		return {"visible": false, "text": ""}
	if get_gate_pylon_state() == "damaged":
		return {"visible": true, "text": "Press E to open the shattered core console"}
	var costs := _current_channel_start_costs()
	var prompt_text := "Press E to open core console | Start channel (%s) | %d crystals in range" % [format_costs(costs), _crystals_remaining_in_radius()]
	if _channel_active:
		prompt_text = "Press E to open core console | Stop channel | Essence %d | Radius %d" % [int(floor(_pending_essence)), int(round(_current_run_base_influence_radius()))]
	return {"visible": true, "text": prompt_text}


func can_purchase_pylon_upgrade(upgrade_type: String) -> bool:
	return can_purchase_run_upgrade(upgrade_type)


func can_purchase_run_upgrade(upgrade_type: String) -> bool:
	if not multiplayer.is_server():
		return false
	if not _gate_active or _gate_objective == null or _channel_active:
		return false
	if research_manager == null or not research_manager.has_method("can_afford_essence"):
		return false
	return research_manager.can_afford_essence(_pylon_upgrade_cost(upgrade_type))


func purchase_pylon_upgrade(upgrade_type: String) -> bool:
	return purchase_run_upgrade(upgrade_type)


func purchase_run_upgrade(upgrade_type: String) -> bool:
	if not multiplayer.is_server():
		return false
	if not _gate_active:
		status_changed.emit("Start a run before upgrading the core defenses.")
		return false
	if _gate_objective == null:
		status_changed.emit("Activate the run base before buying core upgrades.")
		return false
	if _channel_active:
		status_changed.emit("Stop channeling before upgrading the run base.")
		return false
	var upgrade_cost := _pylon_upgrade_cost(upgrade_type)
	if research_manager == null or not research_manager.has_method("consume_essence") or not research_manager.consume_essence(upgrade_cost):
		status_changed.emit("Need %d essence for that run-base upgrade." % upgrade_cost)
		return false
	_run_base_upgrades[upgrade_type] = int(_run_base_upgrades.get(upgrade_type, 0)) + 1
	_apply_run_base_upgrade_runtime(true)
	status_changed.emit("Run base upgraded: %s." % _upgrade_display_name(upgrade_type))
	_broadcast_gate_state()
	return true
	_broadcast_gate_state()


func _teleport_players_to_gate() -> void:
	if players_root == null:
		return
	var spawn_center := _gate_spawn_center()
	var player_index := 0
	for player in players_root.get_children():
		if not player is Node3D:
			continue
		if not player.has_method("teleport_to_position"):
			continue
		var row := int(player_index / 2)
		var column := player_index % 2
		var offset := Vector3((float(column) * player_spawn_spacing) - (player_spawn_spacing * 0.5), 0.0, 4.0 + float(row) * player_spawn_spacing)
		var spawn_position := spawn_center + offset
		spawn_position = _project_to_terrain(spawn_position, 1.2)
		player.teleport_to_position(spawn_position, PI, true)
		player_index += 1


func _finish_gate(success: bool) -> void:
	if not multiplayer.is_server():
		return
	if _channel_active:
		_stop_core_channel(true)
	_clear_gate_mode(false)
	_sync_gate_setup.rpc(false)
	if network_manager != null and network_manager.has_method("restart_match"):
		network_manager.restart_match()
	_stop_enemy_pressure()
	if success:
		status_changed.emit("Expedition extracted. %s | Essence %d | Crystals %d." % [_material_summary(), research_manager.get_essence() if research_manager != null and research_manager.has_method("get_essence") else 0, research_manager.get_crystal_count() if research_manager != null and research_manager.has_method("get_crystal_count") else 0])
	else:
		status_changed.emit("Expedition failed. Unbanked channel essence was lost.")
	gate_state_changed.emit(false)
	_emit_run_info()
	_broadcast_gate_state()


func _on_gate_objective_destroyed() -> void:
	if not multiplayer.is_server():
		return
	if not _gate_active:
		return
	_stop_core_channel(false, true)
	_stop_enemy_pressure()
	status_changed.emit("The pylon collapsed. Unbanked essence was lost and the influence field shrank.")
	_broadcast_gate_state()


func _teleport_peer_to_gate(peer_id: int) -> void:
	if players_root == null:
		return
	var node_name := "Player_%d" % peer_id
	if not players_root.has_node(node_name):
		return
	var player = players_root.get_node(node_name)
	if not player.has_method("teleport_to_position"):
		return
	var peer_slot := 0
	if network_manager != null and "registered_peers" in network_manager:
		peer_slot = max(network_manager.registered_peers.find(peer_id), 0)
	var row := int(peer_slot / 2)
	var column := peer_slot % 2
	var offset := Vector3((float(column) * player_spawn_spacing) - (player_spawn_spacing * 0.5), 0.0, 4.0 + float(row) * player_spawn_spacing)
	var spawn_position := _project_to_terrain(_gate_spawn_center() + offset, 1.2)
	player.teleport_to_position(spawn_position, PI, true)


func _set_enemy_pressure_to_gate() -> void:
	if enemy_manager == null:
		return
	if enemy_manager.has_method("set_spawn_point_provider"):
		enemy_manager.set_spawn_point_provider(self)
	if enemy_manager.has_method("start_gate_pressure") and _gate_objective != null:
		enemy_manager.start_gate_pressure(_gate_objective, _gate_objective.global_position, false)
		return
	if enemy_manager.has_method("set_objective") and _gate_objective != null:
		enemy_manager.set_objective(_gate_objective)
	if enemy_manager.has_method("set_spawn_center"):
		enemy_manager.set_spawn_center(_gate_objective.global_position if _gate_objective != null else gate_center)
	if enemy_manager.has_method("force_restart"):
		enemy_manager.force_restart()
	if enemy_manager.has_method("set_spawning_paused"):
		enemy_manager.set_spawning_paused(false)


func _stop_enemy_pressure() -> void:
	if enemy_manager == null:
		return
	if enemy_manager.has_method("set_spawn_point_provider"):
		enemy_manager.set_spawn_point_provider(null)
	if enemy_manager.has_method("set_objective") and base_objective != null:
		enemy_manager.set_objective(base_objective)
	if enemy_manager.has_method("set_spawn_center") and base_objective != null:
		enemy_manager.set_spawn_center(base_objective.global_position)
	if enemy_manager.has_method("stop_pressure"):
		enemy_manager.stop_pressure(true)
		return
	if enemy_manager.has_method("force_restart"):
		enemy_manager.force_restart()
	if enemy_manager.has_method("set_spawning_paused"):
		enemy_manager.set_spawning_paused(true)


func _spawn_gate_content_local() -> void:
	_clear_gate_content_local(false)
	_gate_objective = gate_objective_scene.instantiate()
	_gate_objective.name = "GateObjective"
	if _gate_objective.has_method("configure_objective"):
		_gate_objective.configure_objective("Core", gate_objective_max_health)
	if _gate_objective.has_method("bind_network_manager") and network_manager != null:
		_gate_objective.bind_network_manager(network_manager)
	gate_root.add_child(_gate_objective)
	_apply_run_base_upgrade_runtime(false)
	refresh_gate_pylon_defenses()
	if multiplayer.is_server() and _gate_objective.has_signal("destroyed"):
		_gate_objective.destroyed.connect(_on_gate_objective_destroyed)


func _activate_run_base_at(position: Vector3) -> void:
	if _gate_objective != null:
		return
	_spawn_gate_content_local()
	var final_position := position
	if world_generator != null and world_generator.has_method("create_or_update_build_zone"):
		world_generator.create_or_update_build_zone(position, pylon_build_radius, pylon_flatten_radius, enemy_spawn_min_radius, enemy_spawn_max_radius)
		if world_generator.has_method("project_to_build_surface"):
			final_position = world_generator.project_to_build_surface(position, 0.0)
	_gate_objective.global_position = final_position
	_run_base_positions.append(final_position)
	_apply_run_base_upgrade_runtime(false)
	_update_resource_reveal_states()


func refresh_gate_pylon_defenses() -> void:
	refresh_run_base_defenses()


func refresh_run_base_defenses() -> void:
	if _gate_objective == null:
		return
	if _gate_objective.has_method("refresh_linked_defenses"):
		_gate_objective.refresh_linked_defenses()


func _spawn_saved_run_base_layout() -> void:
	if not multiplayer.is_server():
		return
	if _gate_objective == null:
		return
	if building_manager == null or not building_manager.has_method("apply_layout_snapshot"):
		return
	if era_manager == null or not era_manager.has_method("get_saved_run_base_layout"):
		return
	var layout = era_manager.get_saved_run_base_layout(_current_era_id)
	if layout.is_empty():
		return
	building_manager.apply_layout_snapshot(layout, _gate_objective.global_position, pylon_base_radius)


func _clear_gate_content_local(clear_resources: bool = true) -> void:
	if _gate_objective != null:
		_gate_objective.queue_free()
	_gate_objective = null
	if clear_resources:
		for resource_node in _resource_nodes.values():
			if resource_node != null:
				resource_node.queue_free()
		_resource_nodes.clear()


func _clear_gate_mode(reset_scrap: bool) -> void:
	_gate_active = false
	_extraction_active = false
	_extraction_remaining = 0.0
	_pending_essence = 0.0
	_channel_elapsed = 0.0
	_channel_active = false
	_sync_timer = 0.0
	_collected_resource_ids.clear()
	_run_base_positions.clear()
	if reset_scrap:
		_stored_scrap = max(starting_scrap, 0)
		_reset_material_inventory()
	_clear_gate_content_local()
	if world_generator != null and world_generator.has_method("clear_world"):
		world_generator.clear_world()
	gate_state_changed.emit(false)
	progression_changed.emit()


func _reset_gate_runtime_state(reset_materials: bool) -> void:
	_gate_active = false
	_extraction_active = false
	_pending_essence = 0.0
	_channel_elapsed = 0.0
	_channel_active = false
	_extraction_remaining = 0.0
	_sync_timer = 0.0
	_collected_resource_ids.clear()
	_run_base_positions.clear()
	if reset_materials:
		_reset_material_inventory()


func _emit_run_info() -> void:
	if _gate_active:
		var phase_text := "Explore"
		if _gate_objective == null:
			phase_text = "Deploy Base"
		elif _channel_active:
			phase_text = "Channel %0.1fs" % _channel_elapsed
		elif get_gate_pylon_state() == "damaged":
			phase_text = "Core Lost"
		else:
			phase_text = "Core Ready"
		if _extraction_active:
			phase_text = "Extract %0.1fs" % _extraction_remaining
		var essence_total = research_manager.get_essence() if research_manager != null and research_manager.has_method("get_essence") else 0
		var crystal_total = research_manager.get_crystal_count() if research_manager != null and research_manager.has_method("get_crystal_count") else 0
		run_info_changed.emit("%s | Phase %s | %s | Pending Essence %d | Essence %d | Crystals %d | Core Lv %d" % [get_current_era_name(), phase_text, _material_summary(), int(floor(_pending_essence)), essence_total, crystal_total, _core_upgrade_level])
		return
	var base_essence = research_manager.get_essence() if research_manager != null and research_manager.has_method("get_essence") else 0
	var base_crystals = research_manager.get_crystal_count() if research_manager != null and research_manager.has_method("get_crystal_count") else 0
	run_info_changed.emit("Base | Scrap %d | %s | Essence %d | Crystals %d | Core Lv %d | Max HP %d" % [_stored_scrap, _material_summary(), base_essence, base_crystals, _core_upgrade_level, int(round(get_current_base_core_max_health()))])


func _current_channel_rate() -> float:
	if not _channel_active:
		return 0.0
	return pylon_essence_rate * _current_run_base_efficiency() * _current_channel_stage_multiplier()


func _broadcast_gate_state() -> void:
	_emit_run_info()
	progression_changed.emit()
	_sync_gate_state.rpc(_state_snapshot())


@rpc("authority", "call_remote", "reliable")
func _sync_gate_setup(active: bool) -> void:
	if multiplayer.is_server():
		return
	if active:
		return
	_clear_gate_content_local()


@rpc("authority", "call_remote", "unreliable_ordered")
func _sync_gate_state(snapshot: Dictionary) -> void:
	if multiplayer.is_server():
		return
	var synced_era_id := String(snapshot.get("current_era_id", _current_era_id))
	var era_changed := synced_era_id != _current_era_id
	_current_era_id = synced_era_id
	if era_manager != null and era_manager.has_method("set_active_gate_era"):
		era_manager.set_active_gate_era(_current_era_id)
	if era_changed:
		_refresh_era_runtime_data()
	_gate_active = bool(snapshot.get("gate_active", false))
	_extraction_active = bool(snapshot.get("extraction_active", false))
	_extraction_remaining = float(snapshot.get("extraction_remaining", 0.0))
	_pending_essence = float(snapshot.get("pending_essence", 0.0))
	_channel_elapsed = float(snapshot.get("channel_elapsed", 0.0))
	_channel_active = bool(snapshot.get("pylon_channeling", false))
	_stored_scrap = int(snapshot.get("stored_scrap", 0))
	_stored_materials = (snapshot.get("stored_materials", _stored_materials) as Dictionary).duplicate(true)
	_core_upgrade_level = int(snapshot.get("core_upgrade_level", 0))
	_run_base_upgrades = (snapshot.get("pylon_upgrades", _run_base_upgrades) as Dictionary).duplicate(true)
	_collected_resource_ids.clear()
	for resource_id in snapshot.get("collected_resource_ids", []):
		_collected_resource_ids[String(resource_id)] = true
	_collected_crystal_ids.clear()
	for crystal_id in snapshot.get("collected_crystal_ids", []):
		_collected_crystal_ids[String(crystal_id)] = true
	if _gate_active and (_resource_nodes.is_empty() or era_changed):
		_clear_gate_content_local()
		spawn_resource_nodes_local()
	if not _gate_active:
		_clear_gate_content_local()
	elif bool(snapshot.get("pylon_present", false)):
		var pylon_position: Vector3 = snapshot.get("pylon_position", gate_center)
		if _gate_objective == null:
			_spawn_gate_content_local()
		if _gate_objective != null:
			_gate_objective.global_position = pylon_position
			if _gate_objective.has_method("apply_synced_state"):
				_gate_objective.apply_synced_state(float(snapshot.get("objective_health", gate_objective_max_health)), bool(snapshot.get("objective_destroyed", false)), float(snapshot.get("objective_max_health", gate_objective_max_health)))
			if _gate_objective.has_method("set_runtime_progress"):
				_gate_objective.set_runtime_progress(int(snapshot.get("pylon_level", 1)), float(snapshot.get("base_radius", pylon_base_radius)), float(snapshot.get("influence_radius", pylon_base_radius)), float(snapshot.get("max_radius", pylon_base_max_radius)), _channel_elapsed, _channel_active, float(snapshot.get("channel_efficiency", 1.0)))
			if _gate_objective.has_method("set_pylon_state_runtime"):
				_gate_objective.set_pylon_state_runtime(String(snapshot.get("pylon_state", "functional")))
	else:
		if _gate_objective != null:
			_clear_gate_content_local(false)
	_update_resource_reveal_states()
	gate_state_changed.emit(_gate_active)
	progression_changed.emit()
	_emit_run_info()


func _apply_progression_to_base_objective(add_upgrade_bonus: bool) -> void:
	if base_objective == null:
		return
	if base_objective.has_method("set_max_health_runtime"):
		base_objective.set_max_health_runtime(get_current_base_core_max_health(), add_upgrade_bonus)


func _reset_progression_state() -> void:
	_stored_scrap = max(starting_scrap, 0)
	_reset_material_inventory()
	_core_upgrade_level = 0
	_collected_crystal_ids.clear()
	_run_base_upgrades = {
		"base_radius": 0,
		"max_radius": 0,
		"channel_efficiency": 0,
		"health": 0,
	}
	_apply_progression_to_base_objective(false)


func _set_run_base_runtime_state(new_state: String) -> void:
	if _gate_objective == null:
		return
	if _gate_objective.has_method("set_pylon_state_runtime"):
		_gate_objective.set_pylon_state_runtime(new_state)


func _restore_run_base_runtime_state(new_state: String) -> void:
	if _gate_objective == null:
		return
	if _gate_objective.has_method("restore_runtime_state"):
		_gate_objective.restore_runtime_state(new_state)
		return
	if _gate_objective.has_method("set_pylon_state_runtime"):
		_gate_objective.set_pylon_state_runtime(new_state)


func _apply_gate_objective_runtime_visuals() -> void:
	if _gate_objective == null:
		return
	if _gate_objective.has_method("set_runtime_progress"):
		_gate_objective.set_runtime_progress(_current_run_base_level(), _current_run_base_radius(), _current_run_base_influence_radius(), _current_run_base_radius_cap(), _channel_elapsed, _channel_active, _current_run_base_efficiency())



func spawn_resource_nodes_local() -> void:
	if gate_root == null:
		return
	if not _resource_nodes.is_empty():
		for resource_node in _resource_nodes.values():
			if resource_node != null:
				resource_node.queue_free()
		_resource_nodes.clear()
	for descriptor in _resource_definitions:
		var resource_id := String(descriptor.get("id", ""))
		var resource_node = RESOURCE_NODE_SCENE.instantiate()
		resource_node.name = "Resource_%s" % resource_id
		var resource_position := _resource_descriptor_world_position(descriptor)
		resource_position = _project_to_terrain(resource_position, 0.35)
		resource_node.setup(resource_id, String(descriptor.get("type", "iron_ore")), resource_position, int(descriptor.get("amount", 0)), _collected_crystal_ids.has(resource_id) if String(descriptor.get("type", "")) == "crystal" else _collected_resource_ids.has(resource_id))
		gate_root.add_child(resource_node)
		_resource_nodes[resource_id] = resource_node
	_update_resource_reveal_states()


func _try_collect_resource(peer_id: int, player: Node3D) -> bool:
	for resource_id in _resource_nodes.keys():
		var resource_node = _resource_nodes[resource_id]
		if resource_node == null or not resource_node.has_method("can_interact") or not resource_node.can_interact():
			continue
		if player.global_position.distance_to(resource_node.global_position) > resource_interaction_radius:
			continue
		var collected = resource_node.collect()
		if collected.is_empty():
			return false
		var resource_type := String(collected.get("type", ""))
		var amount := int(collected.get("amount", 0))
		if resource_type == "stone_node":
			_stored_materials["stone"] = get_material_amount("stone") + amount
			_collected_resource_ids[String(resource_id)] = true
			status_changed.emit("Stone secured: +%d. Stored stone: %d." % [amount, get_material_amount("stone")])
		elif resource_type == "wood_node":
			_stored_materials["wood"] = get_material_amount("wood") + amount
			_collected_resource_ids[String(resource_id)] = true
			status_changed.emit("Wood secured: +%d. Stored wood: %d." % [amount, get_material_amount("wood")])
		elif resource_type == "herb_patch":
			_stored_materials["herbs"] = get_material_amount("herbs") + max(amount, 1)
			_collected_resource_ids[String(resource_id)] = true
			status_changed.emit("Herbs gathered. Stored herbs: %d." % get_material_amount("herbs"))
		elif resource_type == "crystal":
			_collected_crystal_ids[String(resource_id)] = true
			if research_manager != null and research_manager.has_method("add_crystals"):
				research_manager.add_crystals(1)
			status_changed.emit("Crystal secured by P%d. Total crystals: %d." % [peer_id, research_manager.get_crystal_count() if research_manager != null and research_manager.has_method("get_crystal_count") else 0])
		_update_resource_reveal_states()
		_broadcast_gate_state()
		return true
	return false


func _try_activate_run_base(peer_id: int, player: Node3D) -> bool:
	if _gate_objective != null:
		return false
	var placement_position := _placement_position_for_player(player)
	if not _is_valid_run_base_position(placement_position):
		if _has_blocking_resources_near_run_base(placement_position):
			status_changed.emit("Clear nearby stone, wood, and herbs before placing the pylon.")
		else:
			status_changed.emit("Find stable terrain with enough open space before placing the pylon.")
		return false
	_activate_run_base_at(placement_position)
	_snap_players_to_new_platform(placement_position)
	status_changed.emit("Run base activated. Build around the core, then interact to begin channeling.")
	_broadcast_gate_state()
	return true


func _placement_position_for_player(player: Node3D) -> Vector3:
	var forward := Vector3.FORWARD
	if player.has_method("get_build_forward_vector"):
		forward = player.get_build_forward_vector()
	var position := player.global_position + forward * pylon_place_distance
	return _project_to_terrain(position, 0.0)


func _is_valid_run_base_position(position: Vector3) -> bool:
	var required_half_extent := _run_base_slope_half_extent()
	if world_generator != null and world_generator.has_method("is_valid_pylon_position"):
		if not world_generator.is_valid_pylon_position(position, required_half_extent):
			return false
	else:
		if absf(position.x - gate_center.x) > pylon_floor_half_extent - required_half_extent:
			return false
		if absf(position.z - gate_center.z) > pylon_floor_half_extent - required_half_extent:
			return false
	for existing_position in _run_base_positions:
		if position.distance_to(existing_position) < pylon_min_spacing:
			return false
	if _has_blocking_resources_near_run_base(position):
		return false
	return true


func _has_blocking_resources_near_run_base(position: Vector3) -> bool:
	var clearance_radius = max(pylon_resource_clearance_radius, pylon_build_radius)
	for resource_node in _resource_nodes.values():
		if resource_node == null or not resource_node.has_method("is_collected") or resource_node.is_collected():
			continue
		var resource_type := String(resource_node.get_resource_type())
		if resource_type != "stone_node" and resource_type != "wood_node" and resource_type != "herb_patch":
			continue
		var planar_offset = resource_node.global_position - position
		planar_offset.y = 0.0
		if planar_offset.length() <= clearance_radius:
			return true
	return false


func _run_base_platform_half_extent() -> float:
	return max(enemy_spawn_max_radius, pylon_build_radius + 1.0)


func _run_base_slope_half_extent() -> float:
	var slope_width = max(pylon_flatten_radius - pylon_build_radius, 2.0)
	return _run_base_platform_half_extent() + slope_width


func _snap_players_to_new_platform(platform_center: Vector3) -> void:
	if players_root == null:
		return
	if world_generator == null or not world_generator.has_method("project_to_build_surface"):
		return
	var platform_half_extent := _run_base_platform_half_extent()
	for node in players_root.get_children():
		if not node is Node3D:
			continue
		var player_node := node as Node3D
		if absf(player_node.global_position.x - platform_center.x) > platform_half_extent:
			continue
		if absf(player_node.global_position.z - platform_center.z) > platform_half_extent:
			continue
		var lifted_position: Vector3 = world_generator.project_to_build_surface(player_node.global_position, 0.0)
		if lifted_position.y <= player_node.global_position.y + 0.05:
			continue
		if player_node.has_method("teleport_to_position"):
			player_node.teleport_to_position(lifted_position, player_node.rotation.y, false)
		else:
			player_node.global_position = lifted_position


func get_active_build_area_center() -> Vector3:
	if _gate_objective != null:
		return _gate_objective.global_position
	return _gate_spawn_center()


func get_active_build_area_size() -> Vector2:
	return Vector2(pylon_build_radius * 2.0, pylon_build_radius * 2.0)


func project_structure_position(world_position: Vector3, vertical_offset: float = 0.0) -> Vector3:
	if world_generator != null and world_generator.has_method("project_to_build_surface"):
		return world_generator.project_to_build_surface(world_position, vertical_offset)
	return _project_to_terrain(world_position, vertical_offset)


func is_position_in_build_zone(world_position: Vector3, margin: float = 0.0) -> bool:
	if world_generator != null and world_generator.has_method("is_position_in_build_zone"):
		return world_generator.is_position_in_build_zone(world_position, margin)
	if _gate_objective == null:
		return false
	var half_extent = max(pylon_build_radius - margin, 0.0)
	return absf(world_position.x - _gate_objective.global_position.x) <= half_extent and absf(world_position.z - _gate_objective.global_position.z) <= half_extent


func get_enemy_spawn_position(enemy_id: int) -> Vector3:
	if world_generator != null and world_generator.has_method("get_enemy_spawn_position"):
		return world_generator.get_enemy_spawn_position(get_active_build_area_center(), enemy_id)
	var max_half_extent = max(enemy_spawn_max_radius, enemy_spawn_min_radius + 1.0)
	var min_half_extent = max(enemy_spawn_min_radius, pylon_build_radius + 1.0)
	var side_index := posmod(enemy_id, 4)
	var edge_ratio := fmod(float(enemy_id * 37), 127.0) / 127.0
	var depth_ratio := fmod(float(enemy_id * 19), 113.0) / 113.0
	var depth = lerpf(min_half_extent, max_half_extent, depth_ratio)
	var edge = lerpf(-max_half_extent, max_half_extent, edge_ratio)
	var local_offset := Vector3.ZERO
	match side_index:
		0:
			local_offset = Vector3(edge, 0.0, -depth)
		1:
			local_offset = Vector3(depth, 0.0, edge)
		2:
			local_offset = Vector3(edge, 0.0, depth)
		_:
			local_offset = Vector3(-depth, 0.0, edge)
	return _project_to_terrain(get_active_build_area_center() + local_offset, 0.6)


func _project_to_terrain(world_position: Vector3, vertical_offset: float = 0.0) -> Vector3:
	if world_generator != null and world_generator.has_method("project_to_terrain"):
		return world_generator.project_to_terrain(world_position, vertical_offset)
	var projected := world_position
	projected.y = gate_center.y + vertical_offset
	return projected


func _gate_spawn_center() -> Vector3:
	if world_generator != null and "world_center" in world_generator:
		return world_generator.world_center
	return gate_center


func _start_core_channel() -> void:
	if _gate_objective == null:
		return
	var costs := _current_channel_start_costs()
	if not can_afford_costs(costs):
		status_changed.emit("Need %s before starting the core channel." % format_costs(costs))
		return
	consume_costs(costs)
	_pending_essence = 0.0
	_channel_elapsed = 0.0
	_channel_active = true
	_set_run_base_runtime_state("functional")
	_apply_channel_growth()
	_set_enemy_pressure_to_gate()
	status_changed.emit("Channeling started. Hold the core while primary resource and pressure build.")
	_broadcast_gate_state()


func _stop_core_channel(manual_stop: bool, collapsed: bool = false) -> void:
	if not _channel_active:
		return
	_channel_active = false
	_stop_enemy_pressure()
	if collapsed:
		_pending_essence = 0.0
		_channel_elapsed = 0.0
		_set_run_base_runtime_state("damaged")
		_apply_channel_growth(true)
		_broadcast_gate_state()
		return
	var banked_essence := int(floor(_pending_essence))
	if banked_essence > 0 and research_manager != null and research_manager.has_method("add_essence"):
		research_manager.add_essence(banked_essence)
	var radius_bonus := _permanent_radius_bonus_from_channel()
	if radius_bonus > 0:
		_run_base_upgrades["max_radius"] = int(_run_base_upgrades.get("max_radius", 0))
		if _gate_objective != null and _gate_objective.has_method("set_runtime_progress"):
			_gate_objective.set_runtime_progress(_current_run_base_level(), _current_run_base_radius(), min(_current_run_base_influence_radius(), _current_run_base_radius_cap() + radius_bonus), _current_run_base_radius_cap() + radius_bonus, 0.0, false, _current_run_base_efficiency())
	_pending_essence = 0.0
	_channel_elapsed = 0.0
	_apply_channel_growth()
	status_changed.emit("Channel stabilized. Banked %d essence. Pylon radius cap increased by %d." % [banked_essence, radius_bonus])
	_broadcast_gate_state()


func _apply_channel_growth(force_base_radius: bool = false) -> void:
	if _gate_objective == null:
		return
	var influence_radius := _current_run_base_radius() if force_base_radius else _target_channel_radius()
	if _gate_objective.has_method("set_runtime_progress"):
		_gate_objective.set_runtime_progress(_current_run_base_level(), _current_run_base_radius(), influence_radius, _current_run_base_radius_cap(), _channel_elapsed, _channel_active, _current_run_base_efficiency())
	if _gate_objective.has_method("set_pylon_state_runtime") and get_gate_pylon_state() != "damaged":
		_gate_objective.set_pylon_state_runtime("functional")
	_update_resource_reveal_states()


func _target_channel_radius() -> float:
	var base_radius := _current_run_base_radius()
	var radius_cap := _current_run_base_radius_cap()
	if not _channel_active:
		return min(base_radius, radius_cap)
	if _channel_elapsed <= pylon_channel_stage_seconds:
		return lerpf(base_radius, min(base_radius * 2.0, radius_cap), clamp(_channel_elapsed / max(pylon_channel_stage_seconds, 0.001), 0.0, 1.0))
	if _channel_elapsed <= pylon_channel_stage_seconds * 2.0:
		var stage_progress = (_channel_elapsed - pylon_channel_stage_seconds) / max(pylon_channel_stage_seconds, 0.001)
		return lerpf(min(base_radius * 2.0, radius_cap), min(base_radius * 4.0, radius_cap), clamp(stage_progress, 0.0, 1.0))
	return radius_cap


func _current_channel_stage_multiplier() -> float:
	if _channel_elapsed >= pylon_channel_stage_seconds * 2.0:
		return 4.0
	if _channel_elapsed >= pylon_channel_stage_seconds:
		return 2.0
	return 1.0


func _permanent_radius_bonus_from_channel() -> float:
	if _channel_elapsed >= pylon_channel_stage_seconds * 2.0:
		return 12.0
	if _channel_elapsed >= pylon_channel_stage_seconds:
		return 6.0
	if _channel_elapsed >= pylon_channel_stage_seconds * 0.5:
		return 3.0
	return 0.0


func _current_channel_start_costs() -> Dictionary:
	var runtime_costs := {"stone": max(int(round(float(pylon_channel_material_cost) * 0.5)), 1), "wood": max(int(round(float(pylon_channel_material_cost) * 0.3)), 1)}
	if era_manager != null and era_manager.has_method("get_channel_costs"):
		runtime_costs = era_manager.get_channel_costs()
	return runtime_costs


func _current_run_base_level() -> int:
	var total_upgrades := 0
	for value in _run_base_upgrades.values():
		total_upgrades += int(value)
	return 1 + total_upgrades


func _current_run_base_radius() -> float:
	return pylon_base_radius + float(int(_run_base_upgrades.get("base_radius", 0))) * pylon_radius_upgrade_step


func _current_run_base_radius_cap() -> float:
	return pylon_base_max_radius + float(int(_run_base_upgrades.get("max_radius", 0))) * pylon_max_radius_upgrade_step


func _current_run_base_influence_radius() -> float:
	if _gate_objective != null and _gate_objective.has_method("get_influence_radius"):
		return _gate_objective.get_influence_radius()
	return _current_run_base_radius()


func _current_run_base_efficiency() -> float:
	return 1.0 + float(int(_run_base_upgrades.get("channel_efficiency", 0))) * pylon_efficiency_upgrade_step


func _current_run_base_max_health() -> float:
	return gate_objective_max_health + float(int(_run_base_upgrades.get("health", 0))) * pylon_health_upgrade_bonus


func _apply_run_base_upgrade_runtime(add_delta_to_current: bool) -> void:
	if _gate_objective == null:
		return
	if _gate_objective.has_method("set_max_health_runtime"):
		_gate_objective.set_max_health_runtime(_current_run_base_max_health(), add_delta_to_current)
	_apply_gate_objective_runtime_visuals()


func _pylon_upgrade_cost(upgrade_type: String) -> int:
	var level := int(_run_base_upgrades.get(upgrade_type, 0))
	match upgrade_type:
		"base_radius":
			return 180 + level * 90
		"max_radius":
			return 240 + level * 120
		"channel_efficiency":
			return 260 + level * 140
		"health":
			return 200 + level * 100
		_:
			return 999999


func _upgrade_display_name(upgrade_type: String) -> String:
	match upgrade_type:
		"base_radius":
			return "Base Radius"
		"max_radius":
			return "Radius Cap"
		"channel_efficiency":
			return "Channel Efficiency"
		"health":
			return "Pylon Integrity"
		_:
			return upgrade_type.capitalize()


func _build_resource_definitions() -> Array[Dictionary]:
	return [
		{"id": "stone_1", "type": "stone_node", "position": Vector3(-10.0, 0.0, 8.0), "amount": 18},
		{"id": "stone_2", "type": "stone_node", "position": Vector3(9.0, 0.0, -7.0), "amount": 16},
		{"id": "stone_3", "type": "stone_node", "position": Vector3(-12.0, 0.0, -11.0), "amount": 14},
		{"id": "wood_1", "type": "wood_node", "position": Vector3(11.0, 0.0, 10.0), "amount": 10},
		{"id": "wood_2", "type": "wood_node", "position": Vector3(-15.0, 0.0, 2.0), "amount": 10},
		{"id": "herb_1", "type": "herb_patch", "position": Vector3(13.0, 0.0, 12.0), "amount": 1},
		{"id": "treasure_1", "type": "treasure_spot", "position": Vector3(15.0, 0.0, -12.0), "amount": 0},
		{"id": "crystal_1", "type": "crystal", "position": Vector3(17.0, 0.0, 4.0), "amount": 1},
		{"id": "crystal_2", "type": "crystal", "position": Vector3(-16.0, 0.0, -5.0), "amount": 1},
		{"id": "crystal_3", "type": "crystal", "position": Vector3(4.0, 0.0, 15.0), "amount": 1},
	]


func _build_scattered_resource_definitions(base_descriptors: Array[Dictionary]) -> Array[Dictionary]:
	var scattered: Array[Dictionary] = []
	var grouped_templates := {
		"stone_node": [],
		"wood_node": [],
		"herb_patch": [],
	}
	for descriptor in base_descriptors:
		var descriptor_copy: Dictionary = descriptor.duplicate(true)
		var resource_type := String(descriptor_copy.get("type", ""))
		descriptor_copy["world_position"] = _resource_descriptor_world_position(descriptor_copy)
		if grouped_templates.has(resource_type):
			grouped_templates[resource_type].append(descriptor_copy)
			continue
		scattered.append(descriptor_copy)
	scattered.append_array(_build_scattered_descriptors_for_type("stone_node", grouped_templates.get("stone_node", []), max(scattered_stone_node_count, 0), 0.25))
	scattered.append_array(_build_scattered_descriptors_for_type("wood_node", grouped_templates.get("wood_node", []), max(scattered_wood_node_count, 0), 2.1))
	scattered.append_array(_build_scattered_descriptors_for_type("herb_patch", grouped_templates.get("herb_patch", []), max(scattered_herb_patch_count, 0), 4.2))
	return scattered


func _build_scattered_descriptors_for_type(resource_type: String, templates: Array, total_count: int, angle_offset: float) -> Array[Dictionary]:
	var descriptors: Array[Dictionary] = []
	if templates.is_empty() or total_count <= 0:
		return descriptors
	for index in range(total_count):
		var template: Dictionary = (templates[index % templates.size()] as Dictionary).duplicate(true)
		template["id"] = "%s_%d" % [_resource_type_id_prefix(resource_type), index + 1]
		template["world_position"] = _scatter_resource_world_position(resource_type, index, total_count, angle_offset)
		template["amount"] = _scattered_resource_amount(resource_type, int(template.get("amount", 0)), index)
		descriptors.append(template)
	return descriptors


func _resource_type_id_prefix(resource_type: String) -> String:
	match resource_type:
		"stone_node":
			return "stone"
		"wood_node":
			return "wood"
		"herb_patch":
			return "herb"
		_:
			return resource_type.to_lower()


func _scattered_resource_amount(resource_type: String, template_amount: int, index: int) -> int:
	match resource_type:
		"stone_node":
			return max(template_amount + ((index % 4) - 1) * 2, 10)
		"wood_node":
			return max(template_amount + ((index % 3) - 1) * 2, 8)
		"herb_patch":
			return max(template_amount, 1)
		_:
			return max(template_amount, 0)


func _scatter_resource_world_position(resource_type: String, index: int, total_count: int, angle_offset: float) -> Vector3:
	var safe_total = max(total_count - 1, 1)
	var ratio := pow(float(index) / float(safe_total), 0.85)
	var min_radius = max(resource_scatter_min_radius, max(pylon_resource_clearance_radius, pylon_build_radius) + 6.0)
	var max_radius = max(min(resource_scatter_max_radius, _resource_world_max_radius()), min_radius + 4.0)
	var radius := lerpf(min_radius, max_radius, ratio)
	var jitter_phase := float(index + 1)
	if resource_type == "wood_node":
		jitter_phase *= 1.17
	elif resource_type == "herb_patch":
		jitter_phase *= 1.31
	var jitter := sin(jitter_phase + angle_offset) * resource_scatter_jitter
	var angle := float(index + 1) * 2.39996323 + angle_offset
	var candidate := gate_center + Vector3(cos(angle) * (radius + jitter), 0.0, sin(angle) * (radius + jitter))
	return _constrain_resource_world_position(candidate, 6.0)


func _resource_world_max_radius() -> float:
	var half_extents := _resource_world_half_extents(6.0)
	return max(min(half_extents.x, half_extents.y), resource_scatter_min_radius + 8.0)


func _resource_world_half_extents(margin: float = 0.0) -> Vector2:
	var half_width = max(pylon_floor_half_extent * 3.0 - margin, resource_scatter_min_radius + 4.0)
	var half_length = max(pylon_floor_half_extent * 3.0 - margin, resource_scatter_min_radius + 4.0)
	if world_generator != null:
		half_width = max(float(world_generator.get("world_width")) * 0.5 - margin, resource_scatter_min_radius + 4.0)
		half_length = max(float(world_generator.get("world_length")) * 0.5 - margin, resource_scatter_min_radius + 4.0)
	return Vector2(half_width, half_length)


func _constrain_resource_world_position(position: Vector3, margin: float = 0.0) -> Vector3:
	var half_extents := _resource_world_half_extents(margin)
	return Vector3(
		clampf(position.x, gate_center.x - half_extents.x, gate_center.x + half_extents.x),
		position.y,
		clampf(position.z, gate_center.z - half_extents.y, gate_center.z + half_extents.y)
	)


func _resource_descriptor_world_position(descriptor: Dictionary) -> Vector3:
	if descriptor.has("world_position"):
		return descriptor.get("world_position", gate_center)
	var local_position: Vector3 = descriptor.get("position", Vector3.ZERO)
	if descriptor.has("position_is_world") and bool(descriptor.get("position_is_world", false)):
		return local_position
	return gate_center + local_position


func _update_resource_reveal_states() -> void:
	var reveal_radius := 0.0
	var reveal_center := gate_center
	if _gate_objective != null and get_gate_pylon_state() != "damaged":
		reveal_center = _gate_objective.global_position
		reveal_radius = _current_run_base_influence_radius()
	for resource_node in _resource_nodes.values():
		if resource_node == null or not resource_node.has_method("set_revealed"):
			continue
		if resource_node.get_resource_type() == "crystal":
			resource_node.set_revealed(false)
			continue
		var is_revealed := _gate_objective != null and reveal_center.distance_to(resource_node.global_position) <= reveal_radius
		resource_node.set_revealed(is_revealed)


func _revealed_resource_counts() -> Dictionary:
	var counts := {
		"stone_node": 0,
		"wood_node": 0,
		"herb_patch": 0,
		"cave_site": 0,
		"treasure_spot": 0,
	}
	if _gate_objective == null or get_gate_pylon_state() == "damaged":
		return counts
	var center := _gate_objective.global_position
	var radius := _current_run_base_influence_radius()
	for resource_node in _resource_nodes.values():
		if resource_node == null or resource_node.is_collected():
			continue
		var resource_type := String(resource_node.get_resource_type())
		if resource_type == "crystal":
			continue
		if center.distance_to(resource_node.global_position) > radius:
			continue
		counts[resource_type] = int(counts.get(resource_type, 0)) + 1
	return counts


func _crystals_remaining_in_radius() -> int:
	if _gate_objective == null or get_gate_pylon_state() == "damaged":
		return 0
	var remaining := 0
	var center := _gate_objective.global_position
	var radius := _current_run_base_influence_radius()
	for resource_node in _resource_nodes.values():
		if resource_node == null or resource_node.is_collected():
			continue
		if resource_node.get_resource_type() != "crystal":
			continue
		if center.distance_to(resource_node.global_position) <= radius:
			remaining += 1
	return remaining


func _state_snapshot() -> Dictionary:
	var snapshot := {
		"current_era_id": _current_era_id,
		"gate_active": _gate_active,
		"extraction_active": _extraction_active,
		"extraction_remaining": _extraction_remaining,
		"pending_essence": _pending_essence,
		"channel_elapsed": _channel_elapsed,
		"pylon_channeling": _channel_active,
		"stored_scrap": _stored_scrap,
		"stored_materials": _stored_materials.duplicate(true),
		"core_upgrade_level": _core_upgrade_level,
		"pylon_upgrades": _run_base_upgrades.duplicate(true),
		"collected_resource_ids": _collected_resource_ids.keys(),
		"collected_crystal_ids": _collected_crystal_ids.keys(),
		"pylon_present": _gate_objective != null,
		"pylon_state": get_gate_pylon_state(),
		"pylon_position": _gate_objective.global_position if _gate_objective != null else gate_center,
		"objective_health": _gate_objective.get_current_health() if _gate_objective != null and _gate_objective.has_method("get_current_health") else gate_objective_max_health,
		"objective_destroyed": _gate_objective.is_currently_destroyed() if _gate_objective != null and _gate_objective.has_method("is_currently_destroyed") else false,
		"objective_max_health": _current_run_base_max_health(),
		"pylon_level": _current_run_base_level(),
		"base_radius": _current_run_base_radius(),
		"influence_radius": _current_run_base_influence_radius(),
		"max_radius": _current_run_base_radius_cap(),
		"channel_efficiency": _current_run_base_efficiency(),
	}
	return snapshot


func get_current_era_name() -> String:
	if era_manager != null and era_manager.has_method("get_active_gate_era_data"):
		var data = era_manager.get_active_gate_era_data()
		if data != null:
			return String(data.display_name)
	return "Stone Age"


func get_material_display_name(material_id: String) -> String:
	match material_id:
		"stone":
			return "Stone"
		"wood":
			return "Wood"
		"herbs":
			return "Herbs"
		"iron":
			return "Iron"
		"scrap":
			return "Scrap"
		_:
			return material_id.capitalize()


func can_afford_costs(costs: Dictionary) -> bool:
	for material_id in costs.keys():
		var amount := int(costs.get(material_id, 0))
		if amount <= 0:
			continue
		if String(material_id) == "scrap":
			if not can_afford_scrap(amount):
				return false
			continue
		if get_material_amount(String(material_id)) < amount:
			return false
	return true


func consume_costs(costs: Dictionary) -> bool:
	if not multiplayer.is_server():
		return false
	if not can_afford_costs(costs):
		return false
	for material_id in costs.keys():
		var amount := int(costs.get(material_id, 0))
		if amount <= 0:
			continue
		if String(material_id) == "scrap":
			consume_scrap(amount)
			continue
		var material_key := String(material_id)
		_stored_materials[material_key] = max(get_material_amount(material_key) - amount, 0)
	_broadcast_gate_state()
	return true


func format_costs(costs: Dictionary) -> String:
	var parts: Array[String] = []
	for material_id in costs.keys():
		var amount := int(costs.get(material_id, 0))
		if amount <= 0:
			continue
		parts.append("%d %s" % [amount, get_material_display_name(String(material_id))])
	if parts.is_empty():
		return "Free"
	return ", ".join(parts)


func get_material_ids() -> Array[String]:
	if era_manager != null and era_manager.has_method("get_material_ids"):
		return era_manager.get_material_ids()
	return ["stone", "wood", "herbs"]


func _reset_material_inventory() -> void:
	_stored_materials.clear()
	for material_id in get_material_ids():
		_stored_materials[String(material_id)] = max(starter_material_amount, 0)


func _material_summary() -> String:
	var parts: Array[String] = []
	for material_id in get_material_ids():
		parts.append("%s %d" % [get_material_display_name(String(material_id)), get_material_amount(String(material_id))])
	return " | ".join(parts)


func _refresh_era_runtime_data() -> void:
	if era_manager != null and era_manager.has_method("get_active_gate_era_id"):
		_current_era_id = String(era_manager.get_active_gate_era_id())
	if era_manager != null and era_manager.has_method("get_resource_nodes"):
		_resource_definitions = _build_scattered_resource_definitions(era_manager.get_resource_nodes())
	else:
		_resource_definitions = _build_scattered_resource_definitions(_build_resource_definitions())
	if _stored_materials.is_empty():
		_reset_material_inventory()


func _on_gate_pressure_finished(cleared: bool) -> void:
	if not multiplayer.is_server() or not cleared:
		return
	if not _channel_active:
		return
	status_changed.emit("Final Stone Age wave cleared. Essence banked and the pylon steadied.")
	_stop_core_channel(true)


func _set_player_channel_lock(peer_id: int, active: bool) -> void:
	if peer_id <= 0 or players_root == null:
		return
	var player = _player_node(peer_id)
	if player == null:
		return
	if player.has_method("set_channel_locked"):
		player.set_channel_locked(active)


func _player_node(peer_id: int) -> Node3D:
	if players_root == null or peer_id <= 0:
		return null
	var node_name := "Player_%d" % peer_id
	if not players_root.has_node(node_name):
		return null
	var player = players_root.get_node(node_name)
	if player is Node3D:
		return player
	return null
