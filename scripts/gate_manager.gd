extends Node

signal status_changed(message: String)
signal run_info_changed(message: String)
signal gate_state_changed(is_active: bool)

@export var gate_objective_scene: PackedScene
@export var gate_center: Vector3 = Vector3(64.0, 0.6, 0.0)
@export var gate_objective_max_health: float = 220.0
@export var prep_duration: float = 15.0
@export var passive_reward_per_second: float = 1.2
@export var extraction_countdown: float = 5.0
@export var objective_interaction_radius: float = 3.0
@export var player_spawn_spacing: float = 3.0

var gate_root: Node3D
var players_root: Node3D
var base_objective: Node3D
var enemy_manager: Node
var building_manager: Node
var network_manager: Node
var _session_active: bool = false
var _gate_active: bool = false
var _prep_active: bool = false
var _extraction_active: bool = false
var _current_reward: float = 0.0
var _stored_scrap: int = 0
var _prep_remaining: float = 0.0
var _extraction_remaining: float = 0.0
var _sync_timer: float = 0.0
var _gate_objective: Node3D


func _ready() -> void:
	add_to_group("gate_manager")


func set_roots(new_gate_root: Node3D, new_players_root: Node3D, new_base_objective: Node3D) -> void:
	gate_root = new_gate_root
	players_root = new_players_root
	base_objective = new_base_objective


func set_enemy_manager(manager: Node) -> void:
	enemy_manager = manager


func set_building_manager(manager: Node) -> void:
	building_manager = manager


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
	if _gate_objective == null:
		return

	if _prep_active:
		_prep_remaining = max(_prep_remaining - delta, 0.0)
		if _prep_remaining <= 0.0:
			_start_combat_phase()
	else:
		if not _extraction_active:
			_current_reward += passive_reward_per_second * delta
		else:
			_extraction_remaining = max(_extraction_remaining - delta, 0.0)
			if _extraction_remaining <= 0.0:
				_finish_gate(true)
				return

	_sync_timer += delta
	if _sync_timer >= 0.2:
		_sync_timer = 0.0
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

	_reset_gate_runtime_state()
	_gate_active = true
	_prep_active = true
	_prep_remaining = prep_duration
	_spawn_gate_content_local()
	_sync_gate_setup.rpc(true)
	_teleport_players_to_gate()
	if enemy_manager != null and enemy_manager.has_method("set_spawning_paused"):
		enemy_manager.set_spawning_paused(true)
	_set_enemy_pressure_to_gate()
	gate_state_changed.emit(true)
	status_changed.emit("Gate prep started. Build around the drill before the waves begin.")
	_emit_run_info()
	_broadcast_gate_state()


func restart_match() -> void:
	if not multiplayer.is_server():
		return
	_clear_gate_mode(false)
	_set_enemy_pressure_to_base()
	_sync_gate_setup.rpc(false)
	_emit_run_info()
	_broadcast_gate_state()


func is_gate_active() -> bool:
	return _gate_active


func is_build_phase_active() -> bool:
	return _gate_active and _prep_active


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


func _on_session_changed(in_session: bool) -> void:
	_session_active = in_session
	if in_session:
		_emit_run_info()
		return
	_clear_gate_mode(true)
	_emit_run_info()


func _on_peer_registered(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	_sync_gate_setup.rpc_id(peer_id, _gate_active)
	_sync_gate_state.rpc_id(
		peer_id,
		_gate_active,
		_prep_active,
		_prep_remaining,
		_current_reward,
		_extraction_active,
		_extraction_remaining,
		_stored_scrap,
		_gate_objective.get_current_health() if _gate_objective != null and _gate_objective.has_method("get_current_health") else gate_objective_max_health,
		_gate_objective.is_currently_destroyed() if _gate_objective != null and _gate_objective.has_method("is_currently_destroyed") else false
	)
	if _gate_active:
		call_deferred("_teleport_peer_to_gate", peer_id)


func request_objective_interaction(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	if not _gate_active or _prep_active or _extraction_active:
		return
	if _gate_objective == null or players_root == null:
		return
	var node_name := "Player_%d" % peer_id
	if not players_root.has_node(node_name):
		return
	var player = players_root.get_node(node_name)
	if not player is Node3D:
		return
	if player.global_position.distance_to(_gate_objective.global_position) > objective_interaction_radius:
		return
	_extraction_active = true
	_extraction_remaining = extraction_countdown
	status_changed.emit("Extraction started at the drill. Resource gathering has stopped.")
	_broadcast_gate_state()


func _start_combat_phase() -> void:
	_prep_active = false
	_prep_remaining = 0.0
	if enemy_manager != null and enemy_manager.has_method("set_spawning_paused"):
		enemy_manager.set_spawning_paused(false)
	status_changed.emit("Gate combat started. Building is locked until the run ends.")
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
	var run_reward := int(floor(_current_reward)) if success else 0
	if success:
		_stored_scrap += run_reward
	_clear_gate_mode(false)
	_sync_gate_setup.rpc(false)
	if network_manager != null and network_manager.has_method("restart_match"):
		network_manager.restart_match()
	_set_enemy_pressure_to_base()
	if success:
		status_changed.emit("Gate extracted successfully. Scrap secured: %d. Total scrap: %d." % [run_reward, _stored_scrap])
	else:
		status_changed.emit("Gate failed. Returned to base with no scrap secured.")
	gate_state_changed.emit(false)
	_emit_run_info()
	_broadcast_gate_state()


func _on_gate_objective_destroyed() -> void:
	if not multiplayer.is_server():
		return
	if not _gate_active:
		return
	_finish_gate(false)


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
	if enemy_manager.has_method("set_objective") and _gate_objective != null:
		enemy_manager.set_objective(_gate_objective)
	if enemy_manager.has_method("set_spawn_center"):
		enemy_manager.set_spawn_center(gate_center)
	if enemy_manager.has_method("force_restart"):
		enemy_manager.force_restart()
	if enemy_manager.has_method("set_spawning_paused"):
		enemy_manager.set_spawning_paused(_prep_active)


func _set_enemy_pressure_to_base() -> void:
	if enemy_manager == null:
		return
	if enemy_manager.has_method("set_objective") and base_objective != null:
		enemy_manager.set_objective(base_objective)
	if enemy_manager.has_method("set_spawn_center") and base_objective != null:
		enemy_manager.set_spawn_center(base_objective.global_position)
	if enemy_manager.has_method("force_restart"):
		enemy_manager.force_restart()
	if enemy_manager.has_method("set_spawning_paused"):
		enemy_manager.set_spawning_paused(false)


func _spawn_gate_content_local() -> void:
	_clear_gate_content_local()
	_gate_objective = gate_objective_scene.instantiate()
	_gate_objective.name = "GateObjective"
	if _gate_objective.has_method("configure_objective"):
		_gate_objective.configure_objective("Drill", gate_objective_max_health)
	if _gate_objective.has_method("bind_network_manager") and network_manager != null:
		_gate_objective.bind_network_manager(network_manager)
	gate_root.add_child(_gate_objective)
	_gate_objective.global_position = gate_center
	if multiplayer.is_server() and _gate_objective.has_signal("destroyed"):
		_gate_objective.destroyed.connect(_on_gate_objective_destroyed)


func _clear_gate_content_local() -> void:
	if _gate_objective != null:
		_gate_objective.queue_free()
	_gate_objective = null


func _clear_gate_mode(reset_scrap: bool) -> void:
	_gate_active = false
	_prep_active = false
	_extraction_active = false
	_current_reward = 0.0
	_prep_remaining = 0.0
	_extraction_remaining = 0.0
	_sync_timer = 0.0
	if reset_scrap:
		_stored_scrap = 0
	_clear_gate_content_local()
	gate_state_changed.emit(false)


func _reset_gate_runtime_state() -> void:
	_gate_active = false
	_prep_active = false
	_extraction_active = false
	_current_reward = 0.0
	_prep_remaining = prep_duration
	_extraction_remaining = 0.0
	_sync_timer = 0.0


func _emit_run_info() -> void:
	if _gate_active:
		var phase_text := "Prep %0.1fs" % _prep_remaining if _prep_active else "Combat"
		if _extraction_active:
			phase_text = "Extract %0.1fs" % _extraction_remaining
		var reward_text := int(floor(_current_reward))
		run_info_changed.emit("Gate | Phase %s | Scrap %d | Stored %d" % [phase_text, reward_text, _stored_scrap])
		return
	run_info_changed.emit("Base | Stored Scrap %d" % _stored_scrap)


func _broadcast_gate_state() -> void:
	_emit_run_info()
	var objective_health := gate_objective_max_health
	var objective_destroyed := false
	if _gate_objective != null and _gate_objective.has_method("get_current_health"):
		objective_health = _gate_objective.get_current_health()
	if _gate_objective != null and _gate_objective.has_method("is_currently_destroyed"):
		objective_destroyed = _gate_objective.is_currently_destroyed()
	_sync_gate_state.rpc(_gate_active, _prep_active, _prep_remaining, _current_reward, _extraction_active, _extraction_remaining, _stored_scrap, objective_health, objective_destroyed)


@rpc("authority", "call_remote", "reliable")
func _sync_gate_setup(active: bool) -> void:
	if multiplayer.is_server():
		return
	if active:
		if _gate_objective == null:
			_spawn_gate_content_local()
		return
	_clear_gate_content_local()


@rpc("authority", "call_remote", "unreliable_ordered")
func _sync_gate_state(gate_active: bool, prep_active: bool, prep_remaining: float, current_reward: float, extraction_active: bool, extraction_remaining: float, stored_scrap: int, objective_health: float, objective_destroyed: bool) -> void:
	if multiplayer.is_server():
		return
	_gate_active = gate_active
	_prep_active = prep_active
	_prep_remaining = prep_remaining
	_current_reward = current_reward
	_extraction_active = extraction_active
	_extraction_remaining = extraction_remaining
	_stored_scrap = stored_scrap
	if gate_active and _gate_objective == null:
		_spawn_gate_content_local()
	if not gate_active:
		_clear_gate_content_local()
	if _gate_objective != null and _gate_objective.has_method("apply_synced_state"):
		_gate_objective.apply_synced_state(objective_health, objective_destroyed)
	gate_state_changed.emit(_gate_active)
	_emit_run_info()