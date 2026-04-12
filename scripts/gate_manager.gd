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

var gate_root: Node3D
var players_root: Node3D
var base_objective: Node3D
var enemy_manager: Node
var building_manager: Node
var cave_manager: Node
var network_manager: Node
var research_manager: Node
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
var _pylon_channeling: bool = false
var _placed_pylon_positions: Array[Vector3] = []
var _pylon_upgrades: Dictionary = {
	"base_radius": 0,
	"max_radius": 0,
	"channel_efficiency": 0,
	"health": 0,
}
var _resource_nodes: Dictionary = {}
var _resource_definitions: Array[Dictionary] = []
var _collected_resource_ids: Dictionary = {}
var _collected_crystal_ids: Dictionary = {}


func _ready() -> void:
	add_to_group("gate_manager")
	_resource_definitions = _build_resource_definitions()


func set_roots(new_gate_root: Node3D, new_players_root: Node3D, new_base_objective: Node3D) -> void:
	gate_root = new_gate_root
	players_root = new_players_root
	base_objective = new_base_objective
	if base_objective != null and "max_health" in base_objective:
		_base_core_max_health = base_objective.max_health


func set_enemy_manager(manager: Node) -> void:
	enemy_manager = manager


func set_building_manager(manager: Node) -> void:
	building_manager = manager


func set_research_manager(manager: Node) -> void:
	research_manager = manager


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
	elif _pylon_channeling and _gate_objective != null:
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

	_reset_gate_runtime_state(false)
	_gate_active = true
	spawn_resource_nodes_local()
	_sync_gate_setup.rpc(true)
	_teleport_players_to_gate()
	_stop_enemy_pressure()
	gate_state_changed.emit(true)
	status_changed.emit("Expedition live. Gather iron and crystals, then press E to place the pylon.")
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
	return _gate_active and not _extraction_active and not _pylon_channeling and get_gate_pylon_state() != "damaged"


func is_cave_active() -> bool:
	return _gate_active and _pylon_channeling


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
	if _pylon_channeling:
		_stop_pylon_channel(true)
	_extraction_active = true
	_extraction_remaining = extraction_countdown
	status_changed.emit("Retreat started. Hold out until extraction completes.")
	_broadcast_gate_state()


func get_current_run_reward() -> float:
	return _pending_essence


func get_current_reward_rate() -> float:
	return _current_channel_rate()


func get_gate_pylon_state() -> String:
	if _gate_objective == null:
		return "unplaced"
	if _gate_objective.has_method("get_pylon_state"):
		return _gate_objective.get_pylon_state()
	return "functional"


func get_cave_status_snapshot() -> Dictionary:
	return get_pylon_status_snapshot()


func get_pylon_status_snapshot() -> Dictionary:
	var pylon_state := get_gate_pylon_state()
	var visible := _gate_active
	var state_label := "Searching"
	var detail_label := "Collect iron and place a pylon to begin channeling."
	if pylon_state == "functional" and _pylon_channeling:
		state_label = "Channeling"
		detail_label = "Defend the pylon while essence builds and the radius expands."
	elif pylon_state == "functional":
		state_label = "Ready"
		detail_label = "Interact with the pylon to start or stop channeling."
	elif pylon_state == "damaged":
		state_label = "Shattered"
		detail_label = "The channel collapsed. Retreat or place a new pylon on the next run."
	var reveal_counts := _revealed_resource_counts()
	return {
		"visible": visible,
		"state_label": state_label,
		"detail_label": detail_label,
		"pylon_state": pylon_state,
		"reward_rate": _current_channel_rate(),
		"current_reward": _pending_essence,
		"channel_active": _pylon_channeling,
		"channel_elapsed": _channel_elapsed,
		"channel_progress_ratio": clamp(_channel_elapsed / max(pylon_channel_stage_seconds * 2.0, 0.001), 0.0, 1.0),
		"influence_radius": _current_pylon_influence_radius(),
		"max_radius": _current_pylon_radius_cap(),
		"crystals_remaining": _crystals_remaining_in_radius(),
		"ore_revealed": int(reveal_counts.get("iron_ore", 0)),
		"herbs_revealed": int(reveal_counts.get("herb_patch", 0)),
		"caves_revealed": int(reveal_counts.get("cave_site", 0)),
		"treasure_revealed": int(reveal_counts.get("treasure_spot", 0)),
		"extraction_active": _extraction_active,
		"extraction_remaining": _extraction_remaining,
		"pylon_level": _current_pylon_level(),
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
		_try_place_pylon(peer_id, player)
		return
	if player.global_position.distance_to(_gate_objective.global_position) > objective_interaction_radius:
		return
	if get_gate_pylon_state() == "damaged":
		status_changed.emit("The pylon is shattered. Return to base and regroup.")
		return
	if _pylon_channeling:
		_stop_pylon_channel(true)
		return
	_start_pylon_channel()


func get_material_amount(material_id: String) -> int:
	return int(_stored_materials.get(material_id, 0))


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
		if _is_valid_pylon_position(placement):
			return {"visible": true, "text": "Press E to place pylon"}
		return {"visible": true, "text": "Move to open ground to place the pylon"}
	if player.global_position.distance_to(_gate_objective.global_position) > objective_interaction_radius:
		return {"visible": false, "text": ""}
	if get_gate_pylon_state() == "damaged":
		return {"visible": true, "text": "Pylon shattered. Retreat to base."}
	if _pylon_channeling:
		return {"visible": true, "text": "Press E to stop channeling | Essence %d | Radius %d" % [int(floor(_pending_essence)), int(round(_current_pylon_influence_radius()))]}
	var costs := _current_channel_start_costs()
	var prompt_text := "Press E to start channeling (%d iron" % int(costs.get("iron", 0))
	if int(costs.get("essence", 0)) > 0:
		prompt_text += ", %d essence" % int(costs.get("essence", 0))
	prompt_text += ") | %d crystals in range" % _crystals_remaining_in_radius()
	return {"visible": true, "text": prompt_text}


func can_purchase_pylon_upgrade(upgrade_type: String) -> bool:
	if not multiplayer.is_server():
		return false
	if not _gate_active or _gate_objective == null or _pylon_channeling:
		return false
	if research_manager == null or not research_manager.has_method("can_afford_essence"):
		return false
	return research_manager.can_afford_essence(_pylon_upgrade_cost(upgrade_type))


func purchase_pylon_upgrade(upgrade_type: String) -> bool:
	if not multiplayer.is_server():
		return false
	if not _gate_active:
		status_changed.emit("Start an expedition before upgrading the pylon.")
		return false
	if _gate_objective == null:
		status_changed.emit("Place a pylon before buying pylon upgrades.")
		return false
	if _pylon_channeling:
		status_changed.emit("Stop channeling before upgrading the pylon.")
		return false
	var upgrade_cost := _pylon_upgrade_cost(upgrade_type)
	if research_manager == null or not research_manager.has_method("consume_essence") or not research_manager.consume_essence(upgrade_cost):
		status_changed.emit("Need %d essence for that pylon upgrade." % upgrade_cost)
		return false
	_pylon_upgrades[upgrade_type] = int(_pylon_upgrades.get(upgrade_type, 0)) + 1
	_apply_pylon_upgrade_runtime(true)
	status_changed.emit("Pylon upgraded: %s." % _upgrade_display_name(upgrade_type))
	_broadcast_gate_state()
	return true
	_broadcast_gate_state()


func _teleport_players_to_gate() -> void:
	if players_root == null:
		return
	var player_index := 0
	for player in players_root.get_children():
		if not player is Node3D:
			continue
		if not player.has_method("teleport_to_position"):
			continue
		var row := int(player_index / 2)
		var column := player_index % 2
		var offset := Vector3((float(column) * player_spawn_spacing) - (player_spawn_spacing * 0.5), 0.0, 4.0 + float(row) * player_spawn_spacing)
		player.teleport_to_position(gate_center + offset, PI, true)
		player_index += 1


func _finish_gate(success: bool) -> void:
	if not multiplayer.is_server():
		return
	if _pylon_channeling:
		_stop_pylon_channel(true)
	_clear_gate_mode(false)
	_sync_gate_setup.rpc(false)
	if network_manager != null and network_manager.has_method("restart_match"):
		network_manager.restart_match()
	_stop_enemy_pressure()
	if success:
		status_changed.emit("Expedition extracted. Iron %d | Essence %d | Crystals %d." % [get_material_amount("iron"), research_manager.get_essence() if research_manager != null and research_manager.has_method("get_essence") else 0, research_manager.get_crystal_count() if research_manager != null and research_manager.has_method("get_crystal_count") else 0])
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
	_stop_pylon_channel(false, true)
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
	player.teleport_to_position(gate_center + offset, PI, true)


func _set_enemy_pressure_to_gate() -> void:
	if enemy_manager == null:
		return
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
		_gate_objective.configure_objective("Pylon", gate_objective_max_health)
	if _gate_objective.has_method("bind_network_manager") and network_manager != null:
		_gate_objective.bind_network_manager(network_manager)
	gate_root.add_child(_gate_objective)
	_apply_pylon_upgrade_runtime(false)
	refresh_gate_pylon_defenses()
	if multiplayer.is_server() and _gate_objective.has_signal("destroyed"):
		_gate_objective.destroyed.connect(_on_gate_objective_destroyed)


func refresh_gate_pylon_defenses() -> void:
	if _gate_objective == null:
		return
	if _gate_objective.has_method("refresh_linked_defenses"):
		_gate_objective.refresh_linked_defenses()


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
	_pylon_channeling = false
	_sync_timer = 0.0
	_collected_resource_ids.clear()
	_placed_pylon_positions.clear()
	if reset_scrap:
		_stored_scrap = max(starting_scrap, 0)
	_clear_gate_content_local()
	gate_state_changed.emit(false)
	progression_changed.emit()


func _reset_gate_runtime_state(reset_materials: bool) -> void:
	_gate_active = false
	_extraction_active = false
	_pending_essence = 0.0
	_channel_elapsed = 0.0
	_pylon_channeling = false
	_extraction_remaining = 0.0
	_sync_timer = 0.0
	_collected_resource_ids.clear()
	_placed_pylon_positions.clear()
	if reset_materials:
		_stored_materials["iron"] = 0


func _emit_run_info() -> void:
	if _gate_active:
		var phase_text := "Explore"
		if _gate_objective == null:
			phase_text = "Find Ground"
		elif _pylon_channeling:
			phase_text = "Channel %0.1fs" % _channel_elapsed
		elif get_gate_pylon_state() == "damaged":
			phase_text = "Pylon Lost"
		else:
			phase_text = "Pylon Ready"
		if _extraction_active:
			phase_text = "Extract %0.1fs" % _extraction_remaining
		var essence_total = research_manager.get_essence() if research_manager != null and research_manager.has_method("get_essence") else 0
		var crystal_total = research_manager.get_crystal_count() if research_manager != null and research_manager.has_method("get_crystal_count") else 0
		run_info_changed.emit("Expedition | Phase %s | Iron %d | Pending Essence %d | Essence %d | Crystals %d | Core Lv %d" % [phase_text, get_material_amount("iron"), int(floor(_pending_essence)), essence_total, crystal_total, _core_upgrade_level])
		return
	var base_essence = research_manager.get_essence() if research_manager != null and research_manager.has_method("get_essence") else 0
	var base_crystals = research_manager.get_crystal_count() if research_manager != null and research_manager.has_method("get_crystal_count") else 0
	run_info_changed.emit("Base | Scrap %d | Iron %d | Essence %d | Crystals %d | Core Lv %d | Max HP %d" % [_stored_scrap, get_material_amount("iron"), base_essence, base_crystals, _core_upgrade_level, int(round(get_current_base_core_max_health()))])


func _current_channel_rate() -> float:
	if not _pylon_channeling:
		return 0.0
	return pylon_essence_rate * _current_pylon_efficiency() * _current_channel_stage_multiplier()


func _broadcast_gate_state() -> void:
	_emit_run_info()
	progression_changed.emit()
	_sync_gate_state.rpc(_state_snapshot())


@rpc("authority", "call_remote", "reliable")
func _sync_gate_setup(active: bool) -> void:
	if multiplayer.is_server():
		return
	if active:
		spawn_resource_nodes_local()
		return
	_clear_gate_content_local()


@rpc("authority", "call_remote", "unreliable_ordered")
func _sync_gate_state(snapshot: Dictionary) -> void:
	if multiplayer.is_server():
		return
	_gate_active = bool(snapshot.get("gate_active", false))
	_extraction_active = bool(snapshot.get("extraction_active", false))
	_extraction_remaining = float(snapshot.get("extraction_remaining", 0.0))
	_pending_essence = float(snapshot.get("pending_essence", 0.0))
	_channel_elapsed = float(snapshot.get("channel_elapsed", 0.0))
	_pylon_channeling = bool(snapshot.get("pylon_channeling", false))
	_stored_scrap = int(snapshot.get("stored_scrap", 0))
	_stored_materials = (snapshot.get("stored_materials", {"iron": 0}) as Dictionary).duplicate(true)
	_core_upgrade_level = int(snapshot.get("core_upgrade_level", 0))
	_pylon_upgrades = (snapshot.get("pylon_upgrades", _pylon_upgrades) as Dictionary).duplicate(true)
	_collected_resource_ids.clear()
	for resource_id in snapshot.get("collected_resource_ids", []):
		_collected_resource_ids[String(resource_id)] = true
	_collected_crystal_ids.clear()
	for crystal_id in snapshot.get("collected_crystal_ids", []):
		_collected_crystal_ids[String(crystal_id)] = true
	if _gate_active and _resource_nodes.is_empty():
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
				_gate_objective.set_runtime_progress(int(snapshot.get("pylon_level", 1)), float(snapshot.get("base_radius", pylon_base_radius)), float(snapshot.get("influence_radius", pylon_base_radius)), float(snapshot.get("max_radius", pylon_base_max_radius)), _channel_elapsed, _pylon_channeling, float(snapshot.get("channel_efficiency", 1.0)))
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
	_stored_materials = {"iron": 0}
	_core_upgrade_level = 0
	_collected_crystal_ids.clear()
	_pylon_upgrades = {
		"base_radius": 0,
		"max_radius": 0,
		"channel_efficiency": 0,
		"health": 0,
	}
	_apply_progression_to_base_objective(false)


func _set_pylon_runtime_state(new_state: String) -> void:
	if _gate_objective == null:
		return
	if _gate_objective.has_method("set_pylon_state_runtime"):
		_gate_objective.set_pylon_state_runtime(new_state)


func _restore_pylon_runtime_state(new_state: String) -> void:
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
		_gate_objective.set_runtime_progress(_current_pylon_level(), _current_pylon_base_radius(), _current_pylon_influence_radius(), _current_pylon_radius_cap(), _channel_elapsed, _pylon_channeling, _current_pylon_efficiency())



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
		resource_node.setup(resource_id, String(descriptor.get("type", "iron_ore")), descriptor.get("position", gate_center), int(descriptor.get("amount", 0)), _collected_crystal_ids.has(resource_id) if String(descriptor.get("type", "")) == "crystal" else _collected_resource_ids.has(resource_id))
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
		if resource_type == "iron_ore":
			_stored_materials["iron"] = get_material_amount("iron") + amount
			_collected_resource_ids[String(resource_id)] = true
			status_changed.emit("Iron secured: +%d. Stored iron: %d." % [amount, get_material_amount("iron")])
		elif resource_type == "crystal":
			_collected_crystal_ids[String(resource_id)] = true
			if research_manager != null and research_manager.has_method("add_crystals"):
				research_manager.add_crystals(1)
			status_changed.emit("Crystal secured by P%d. Total crystals: %d." % [peer_id, research_manager.get_crystal_count() if research_manager != null and research_manager.has_method("get_crystal_count") else 0])
		_update_resource_reveal_states()
		_broadcast_gate_state()
		return true
	return false


func _try_place_pylon(peer_id: int, player: Node3D) -> bool:
	if _gate_objective != null:
		return false
	var placement_position := _placement_position_for_player(player)
	if not _is_valid_pylon_position(placement_position):
		status_changed.emit("Find open terrain inside the expedition floor before placing the pylon.")
		return false
	_spawn_gate_content_local()
	_gate_objective.global_position = placement_position
	_placed_pylon_positions.append(placement_position)
	_apply_pylon_upgrade_runtime(false)
	_update_resource_reveal_states()
	status_changed.emit("Pylon placed. Build around it, then interact to begin channeling.")
	_broadcast_gate_state()
	return true


func _placement_position_for_player(player: Node3D) -> Vector3:
	var forward := Vector3.FORWARD
	if player.has_method("get_build_forward_vector"):
		forward = player.get_build_forward_vector()
	var position := player.global_position + forward * pylon_place_distance
	position.y = gate_center.y
	return position


func _is_valid_pylon_position(position: Vector3) -> bool:
	if absf(position.x - gate_center.x) > pylon_floor_half_extent:
		return false
	if absf(position.z - gate_center.z) > pylon_floor_half_extent:
		return false
	for existing_position in _placed_pylon_positions:
		if position.distance_to(existing_position) < pylon_min_spacing:
			return false
	return true


func _start_pylon_channel() -> void:
	if _gate_objective == null:
		return
	var costs := _current_channel_start_costs()
	var iron_cost := int(costs.get("iron", 0))
	var essence_cost := int(costs.get("essence", 0))
	if get_material_amount("iron") < iron_cost:
		status_changed.emit("Need %d iron before channeling this pylon." % iron_cost)
		return
	if essence_cost > 0 and (research_manager == null or not research_manager.has_method("consume_essence") or not research_manager.consume_essence(essence_cost)):
		status_changed.emit("Need %d essence before advanced channeling can begin." % essence_cost)
		return
	_stored_materials["iron"] = max(get_material_amount("iron") - iron_cost, 0)
	_pending_essence = 0.0
	_channel_elapsed = 0.0
	_pylon_channeling = true
	_set_pylon_runtime_state("functional")
	_apply_channel_growth()
	_set_enemy_pressure_to_gate()
	status_changed.emit("Channeling started. Hold the pylon while essence and influence build.")
	_broadcast_gate_state()


func _stop_pylon_channel(manual_stop: bool, collapsed: bool = false) -> void:
	if not _pylon_channeling:
		return
	_pylon_channeling = false
	_stop_enemy_pressure()
	if collapsed:
		_pending_essence = 0.0
		_channel_elapsed = 0.0
		_set_pylon_runtime_state("damaged")
		_apply_channel_growth(true)
		_broadcast_gate_state()
		return
	var banked_essence := int(floor(_pending_essence))
	if banked_essence > 0 and research_manager != null and research_manager.has_method("add_essence"):
		research_manager.add_essence(banked_essence)
	var radius_bonus := _permanent_radius_bonus_from_channel()
	if radius_bonus > 0:
		_pylon_upgrades["max_radius"] = int(_pylon_upgrades.get("max_radius", 0))
		if _gate_objective != null and _gate_objective.has_method("set_runtime_progress"):
			_gate_objective.set_runtime_progress(_current_pylon_level(), _current_pylon_base_radius(), min(_current_pylon_influence_radius(), _current_pylon_radius_cap() + radius_bonus), _current_pylon_radius_cap() + radius_bonus, 0.0, false, _current_pylon_efficiency())
	_pending_essence = 0.0
	_channel_elapsed = 0.0
	_apply_channel_growth()
	status_changed.emit("Channel stabilized. Banked %d essence. Pylon radius cap increased by %d." % [banked_essence, radius_bonus])
	_broadcast_gate_state()


func _apply_channel_growth(force_base_radius: bool = false) -> void:
	if _gate_objective == null:
		return
	var influence_radius := _current_pylon_base_radius() if force_base_radius else _target_channel_radius()
	if _gate_objective.has_method("set_runtime_progress"):
		_gate_objective.set_runtime_progress(_current_pylon_level(), _current_pylon_base_radius(), influence_radius, _current_pylon_radius_cap(), _channel_elapsed, _pylon_channeling, _current_pylon_efficiency())
	if _gate_objective.has_method("set_pylon_state_runtime") and get_gate_pylon_state() != "damaged":
		_gate_objective.set_pylon_state_runtime("functional")
	_update_resource_reveal_states()


func _target_channel_radius() -> float:
	var base_radius := _current_pylon_base_radius()
	var radius_cap := _current_pylon_radius_cap()
	if not _pylon_channeling:
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
	return {
		"iron": pylon_channel_material_cost + int(_pylon_upgrades.get("channel_efficiency", 0)) * 2,
		"essence": pylon_advanced_channel_essence_cost if _current_pylon_level() >= 3 else 0,
	}


func _current_pylon_level() -> int:
	var total_upgrades := 0
	for value in _pylon_upgrades.values():
		total_upgrades += int(value)
	return 1 + total_upgrades


func _current_pylon_base_radius() -> float:
	return pylon_base_radius + float(int(_pylon_upgrades.get("base_radius", 0))) * pylon_radius_upgrade_step


func _current_pylon_radius_cap() -> float:
	return pylon_base_max_radius + float(int(_pylon_upgrades.get("max_radius", 0))) * pylon_max_radius_upgrade_step


func _current_pylon_influence_radius() -> float:
	if _gate_objective != null and _gate_objective.has_method("get_influence_radius"):
		return _gate_objective.get_influence_radius()
	return _current_pylon_base_radius()


func _current_pylon_efficiency() -> float:
	return 1.0 + float(int(_pylon_upgrades.get("channel_efficiency", 0))) * pylon_efficiency_upgrade_step


func _current_pylon_max_health() -> float:
	return gate_objective_max_health + float(int(_pylon_upgrades.get("health", 0))) * pylon_health_upgrade_bonus


func _apply_pylon_upgrade_runtime(add_delta_to_current: bool) -> void:
	if _gate_objective == null:
		return
	if _gate_objective.has_method("set_max_health_runtime"):
		_gate_objective.set_max_health_runtime(_current_pylon_max_health(), add_delta_to_current)
	_apply_gate_objective_runtime_visuals()


func _pylon_upgrade_cost(upgrade_type: String) -> int:
	var level := int(_pylon_upgrades.get(upgrade_type, 0))
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
		{"id": "iron_1", "type": "iron_ore", "position": gate_center + Vector3(-10.0, 0.0, 8.0), "amount": 18},
		{"id": "iron_2", "type": "iron_ore", "position": gate_center + Vector3(9.0, 0.0, -7.0), "amount": 20},
		{"id": "iron_3", "type": "iron_ore", "position": gate_center + Vector3(-12.0, 0.0, -11.0), "amount": 16},
		{"id": "herb_1", "type": "herb_patch", "position": gate_center + Vector3(11.0, 0.0, 10.0), "amount": 0},
		{"id": "cave_1", "type": "cave_site", "position": gate_center + Vector3(-15.0, 0.0, 2.0), "amount": 0},
		{"id": "treasure_1", "type": "treasure_spot", "position": gate_center + Vector3(15.0, 0.0, -12.0), "amount": 0},
		{"id": "crystal_1", "type": "crystal", "position": gate_center + Vector3(17.0, 0.0, 4.0), "amount": 1},
		{"id": "crystal_2", "type": "crystal", "position": gate_center + Vector3(-16.0, 0.0, -5.0), "amount": 1},
		{"id": "crystal_3", "type": "crystal", "position": gate_center + Vector3(4.0, 0.0, 15.0), "amount": 1},
	]


func _update_resource_reveal_states() -> void:
	var reveal_radius := 0.0
	var reveal_center := gate_center
	if _gate_objective != null and get_gate_pylon_state() != "damaged":
		reveal_center = _gate_objective.global_position
		reveal_radius = _current_pylon_influence_radius()
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
		"iron_ore": 0,
		"herb_patch": 0,
		"cave_site": 0,
		"treasure_spot": 0,
	}
	if _gate_objective == null or get_gate_pylon_state() == "damaged":
		return counts
	var center := _gate_objective.global_position
	var radius := _current_pylon_influence_radius()
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
	var radius := _current_pylon_influence_radius()
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
		"gate_active": _gate_active,
		"extraction_active": _extraction_active,
		"extraction_remaining": _extraction_remaining,
		"pending_essence": _pending_essence,
		"channel_elapsed": _channel_elapsed,
		"pylon_channeling": _pylon_channeling,
		"stored_scrap": _stored_scrap,
		"stored_materials": _stored_materials.duplicate(true),
		"core_upgrade_level": _core_upgrade_level,
		"pylon_upgrades": _pylon_upgrades.duplicate(true),
		"collected_resource_ids": _collected_resource_ids.keys(),
		"collected_crystal_ids": _collected_crystal_ids.keys(),
		"pylon_present": _gate_objective != null,
		"pylon_state": get_gate_pylon_state(),
		"pylon_position": _gate_objective.global_position if _gate_objective != null else gate_center,
		"objective_health": _gate_objective.get_current_health() if _gate_objective != null and _gate_objective.has_method("get_current_health") else gate_objective_max_health,
		"objective_destroyed": _gate_objective.is_currently_destroyed() if _gate_objective != null and _gate_objective.has_method("is_currently_destroyed") else false,
		"objective_max_health": _current_pylon_max_health(),
		"pylon_level": _current_pylon_level(),
		"base_radius": _current_pylon_base_radius(),
		"influence_radius": _current_pylon_influence_radius(),
		"max_radius": _current_pylon_radius_cap(),
		"channel_efficiency": _current_pylon_efficiency(),
	}
	return snapshot


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
