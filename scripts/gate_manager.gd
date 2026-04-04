extends Node

const CAVE_REWARD_SCENE := preload("res://scenes/gate_reward_node.tscn")

signal status_changed(message: String)
signal run_info_changed(message: String)
signal gate_state_changed(is_active: bool)
signal progression_changed()

@export var gate_objective_scene: PackedScene
@export var gate_center: Vector3 = Vector3(64.0, 0.6, 0.0)
@export var gate_objective_max_health: float = 220.0
@export var prep_duration: float = 15.0
@export var pylon_claim_channel_time: float = 3.0
@export var pylon_claim_wave_count: int = 3
@export var pylon_claim_max_enemies: int = 6
@export var pylon_claim_spawns_per_wave: int = 6
@export var pylon_claim_spawn_interval: float = 2.1
@export var pylon_claim_wave_enemy_bonus: int = 1
@export var pylon_claim_breather_duration: float = 4.0
@export var passive_reward_per_second: float = 1.2
@export var cave_passive_reward_per_second: float = 2.0
@export var extraction_countdown: float = 5.0
@export var objective_interaction_radius: float = 3.0
@export var cave_activation_cost: int = 12
@export var cave_activation_channel_time: float = 4.0
@export var cave_reward_amount: int = 18
@export var pylon_repair_channel_time: float = 4.0
@export var pylon_repair_wave_count: int = 2
@export var pylon_repair_max_enemies: int = 4
@export var pylon_repair_spawns_per_wave: int = 4
@export var pylon_repair_spawn_interval: float = 3.0
@export var pylon_repair_wave_enemy_bonus: int = 0
@export var pylon_repair_breather_duration: float = 5.0
@export var pylon_repair_break_distance: float = 0.75
@export var player_spawn_spacing: float = 3.0
@export var core_upgrade_base_cost: int = 25
@export var core_upgrade_cost_step: int = 15
@export var core_upgrade_health_bonus: float = 100.0

var gate_root: Node3D
var players_root: Node3D
var base_objective: Node3D
var enemy_manager: Node
var building_manager: Node
var cave_manager: Node
var network_manager: Node
var _session_active: bool = false
var _gate_active: bool = false
var _prep_active: bool = false
var _claim_channeling: bool = false
var _claim_channel_remaining: float = 0.0
var _claim_event_active: bool = false
var _extraction_active: bool = false
var _current_reward: float = 0.0
var _stored_scrap: int = 0
var _prep_remaining: float = 0.0
var _extraction_remaining: float = 0.0
var _cave_activation_remaining: float = 0.0
var _repair_channel_remaining: float = 0.0
var _sync_timer: float = 0.0
var _gate_objective: Node3D
var _base_core_max_health: float = 300.0
var _core_upgrade_level: int = 0
var _cave_spawned: bool = false
var _cave_active: bool = false
var _cave_activation_channeling: bool = false
var _repair_channeling: bool = false
var _repair_event_active: bool = false
var _repair_channel_peer_id: int = 0
var _repair_channel_origin: Vector3 = Vector3.ZERO
var _prepared_cave_id: int = 0
var _prepared_cave_descriptor: Dictionary = {}
var _players_in_cave: Array[int] = []
var _cave_reward_collected: bool = false
var _cave_reward_node: Node3D


func _ready() -> void:
	add_to_group("gate_manager")


func set_roots(new_gate_root: Node3D, new_players_root: Node3D, new_base_objective: Node3D) -> void:
	gate_root = new_gate_root
	players_root = new_players_root
	base_objective = new_base_objective
	if base_objective != null and "max_health" in base_objective:
		_base_core_max_health = base_objective.max_health


func set_enemy_manager(manager: Node) -> void:
	enemy_manager = manager
	if enemy_manager != null and enemy_manager.has_signal("raid_finished") and not enemy_manager.raid_finished.is_connected(_on_gate_pressure_finished):
		enemy_manager.raid_finished.connect(_on_gate_pressure_finished)


func set_building_manager(manager: Node) -> void:
	building_manager = manager


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
	if _gate_objective == null:
		return

	if _claim_channeling:
		_claim_channel_remaining = max(_claim_channel_remaining - delta, 0.0)
		if _claim_channel_remaining <= 0.0:
			_begin_claim_event()
	elif _repair_channeling:
		if not _is_repair_channel_stable():
			_cancel_repair_channel()
			return
		_repair_channel_remaining = max(_repair_channel_remaining - delta, 0.0)
		if _repair_channel_remaining <= 0.0:
			_begin_repair_event()
	elif _cave_activation_channeling:
		_cave_activation_remaining = max(_cave_activation_remaining - delta, 0.0)
		if _cave_activation_remaining <= 0.0:
			_finish_cave_activation()
	elif not _prep_active and not _claim_event_active and not _repair_event_active and not _extraction_active:
		_current_reward += _current_passive_reward_rate() * delta
	elif _extraction_active:
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
	_spawn_gate_content_local()
	_set_pylon_runtime_state("uncaptured")
	_sync_gate_setup.rpc(true)
	_teleport_players_to_gate()
	_stop_enemy_pressure()
	gate_state_changed.emit(true)
	status_changed.emit("Gate ready. Build around the pylon, then interact with it to begin the claim event.")
	_emit_run_info()
	_broadcast_gate_state()


func restart_match() -> void:
	if not multiplayer.is_server():
		return
	_set_player_channel_lock(_repair_channel_peer_id, false)
	_clear_gate_mode(false)
	_stop_enemy_pressure()
	_sync_gate_setup.rpc(false)
	_emit_run_info()
	_broadcast_gate_state()


func is_gate_active() -> bool:
	return _gate_active


func is_build_phase_active() -> bool:
	return _gate_active and _prep_active and not _claim_channeling


func is_cave_active() -> bool:
	return _gate_active and _cave_active


func is_cave_activation_channeling() -> bool:
	return _gate_active and _cave_activation_channeling


func is_repair_channeling() -> bool:
	return _gate_active and _repair_channeling


func get_current_run_reward() -> float:
	return _current_reward


func get_current_reward_rate() -> float:
	return _current_passive_reward_rate()


func get_gate_pylon_state() -> String:
	if _gate_objective != null and _gate_objective.has_method("get_pylon_state"):
		return _gate_objective.get_pylon_state()
	if _cave_spawned:
		return "functional"
	return "uncaptured"


func get_cave_status_snapshot() -> Dictionary:
	var pylon_state := get_gate_pylon_state()
	var state_label := "Locked"
	var detail_label := "Claim the pylon to unlock cave control."
	var cave_panel_visible := _gate_active and (_cave_spawned or pylon_state == "damaged")
	if _claim_channeling:
		state_label = "Claiming"
		detail_label = "Secure the pylon before the claim channel breaks."
	elif _claim_event_active:
		state_label = "Claim Waves"
		detail_label = "Hold off the construct waves to secure the pylon."
	elif pylon_state == "damaged":
		state_label = "Disabled"
		detail_label = "Repair the pylon to restore cave control."
	elif _repair_channeling:
		state_label = "Repairing"
		detail_label = "Hold position until the repair event starts."
	elif _repair_event_active:
		state_label = "Repair Defense"
		detail_label = "Survive the lighter repair waves to restore the pylon."
	elif _cave_activation_channeling:
		state_label = "Opening"
		detail_label = "Channel the pylon to open the cave entrance."
	elif _cave_active:
		state_label = "Open"
		detail_label = "Keep the cave open to raise pressure and reward gain."
	elif _cave_spawned:
		state_label = "Ready"
		detail_label = "Interact with the pylon to open or close the cave."

	return {
		"visible": cave_panel_visible,
		"state_label": state_label,
		"detail_label": detail_label,
		"pylon_state": pylon_state,
		"cave_id": _prepared_cave_id,
		"reward_rate": _current_passive_reward_rate(),
		"current_reward": _current_reward,
		"claim_channel_remaining": _claim_channel_remaining,
		"claim_event_active": _claim_event_active,
		"claim_total_waves": pylon_claim_wave_count,
		"cave_activation_remaining": _cave_activation_remaining,
		"cave_active": _cave_active,
		"repair_channel_remaining": _repair_channel_remaining,
		"repair_channeling": _repair_channeling,
		"repair_event_active": _repair_event_active,
		"claim_progress_ratio": 1.0 - (_claim_channel_remaining / max(pylon_claim_channel_time, 0.001)) if _claim_channeling else 0.0,
		"claim_channel_duration": pylon_claim_channel_time,
		"extraction_active": _extraction_active,
		"extraction_remaining": _extraction_remaining
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
	_set_player_channel_lock(_repair_channel_peer_id, false)
	_clear_gate_mode(false)
	_reset_progression_state()
	_emit_run_info()
	progression_changed.emit()


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
		_claim_channeling,
		_claim_channel_remaining,
		_claim_event_active,
		_cave_active,
		_cave_spawned,
		_cave_activation_channeling,
		_cave_activation_remaining,
		_repair_channeling,
		_repair_channel_remaining,
		_repair_event_active,
		_prepared_cave_id,
		_cave_reward_collected,
		_stored_scrap,
		_core_upgrade_level,
		_gate_objective.get_current_health() if _gate_objective != null and _gate_objective.has_method("get_current_health") else gate_objective_max_health,
		_gate_objective.is_currently_destroyed() if _gate_objective != null and _gate_objective.has_method("is_currently_destroyed") else false,
		_gate_objective.get_pylon_state() if _gate_objective != null and _gate_objective.has_method("get_pylon_state") else "functional"
	)
	if _gate_active:
		call_deferred("_teleport_peer_to_gate", peer_id)


func request_objective_interaction(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	if not _gate_active or _extraction_active:
		return
	if _gate_objective == null or players_root == null:
		return
	var node_name := "Player_%d" % peer_id
	if not players_root.has_node(node_name):
		return
	var player = players_root.get_node(node_name)
	if not player is Node3D:
		return
	var pylon_state := "functional"
	if _gate_objective.has_method("get_pylon_state"):
		pylon_state = _gate_objective.get_pylon_state()
	if player.global_position.distance_to(_gate_objective.global_position) > objective_interaction_radius:
		return
	if _repair_channeling or _repair_event_active:
		status_changed.emit("Pylon repair is already in progress.")
		return
	if pylon_state == "damaged":
		_start_repair_channel(peer_id)
		return
	if pylon_state == "functional":
		if _cave_active:
			_stop_cave_channel(true)
			return
		_start_cave_channel()
		return
	if _prep_active:
		if _claim_channeling:
			status_changed.emit("Pylon claim is already channeling.")
			return
		_claim_channeling = true
		_claim_channel_remaining = pylon_claim_channel_time
		status_changed.emit("Pylon claim started. Construct waves are about to arrive.")
		_broadcast_gate_state()
		return
	if _claim_event_active:
		status_changed.emit("Claim waves are already active around the pylon.")
		return
	if not _cave_spawned:
		status_changed.emit("Claim the pylon before trying to open the cave.")
		return


func _begin_claim_event() -> void:
	if not multiplayer.is_server():
		return
	_claim_channeling = false
	_claim_channel_remaining = 0.0
	_claim_event_active = true
	_prep_active = false
	if enemy_manager != null and enemy_manager.has_method("start_raid_pressure"):
		enemy_manager.start_raid_pressure(_gate_objective, gate_center, pylon_claim_wave_count, pylon_claim_max_enemies, pylon_claim_spawns_per_wave, pylon_claim_spawn_interval, pylon_claim_wave_enemy_bonus, pylon_claim_breather_duration)
	status_changed.emit("Claim waves started. Clear every wave to secure the pylon.")
	_broadcast_gate_state()


func _complete_claim_event() -> void:
	_claim_event_active = false
	_prep_active = false
	_set_pylon_runtime_state("functional")
	_cave_spawned = true
	_prepare_gate_cave()
	_stop_enemy_pressure()
	status_changed.emit("Pylon claimed. Interact again to open the cave and keep the channel going as long as the team can hold it.")
	_broadcast_gate_state()


func _handle_claim_failure() -> void:
	_claim_event_active = false
	_claim_channeling = false
	_claim_channel_remaining = 0.0
	_prep_active = true
	_stop_enemy_pressure()
	_restore_pylon_runtime_state("uncaptured")
	status_changed.emit("Pylon claim failed. The foothold reset, but your defenses remain. Interact to try again.")
	_broadcast_gate_state()


func _finish_cave_activation() -> void:
	_start_cave_channel()


func _start_repair_channel(peer_id: int) -> void:
	if _repair_channeling or _repair_event_active:
		return
	_repair_channeling = true
	_repair_channel_remaining = pylon_repair_channel_time
	_repair_channel_peer_id = peer_id
	var player = _player_node(peer_id)
	if player != null:
		_repair_channel_origin = player.global_position
	else:
		_repair_channel_origin = Vector3.ZERO
	_set_player_channel_lock(peer_id, true)
	status_changed.emit("Repair started. The channeling player is locked in until the repair event begins.")
	_broadcast_gate_state()


func _begin_repair_event() -> void:
	if not multiplayer.is_server():
		return
	_repair_channeling = false
	_repair_channel_remaining = 0.0
	_set_player_channel_lock(_repair_channel_peer_id, false)
	_repair_channel_peer_id = 0
	_repair_channel_origin = Vector3.ZERO
	_repair_event_active = true
	if enemy_manager != null and enemy_manager.has_method("start_raid_pressure"):
		enemy_manager.start_raid_pressure(_gate_objective, gate_center, pylon_repair_wave_count, pylon_repair_max_enemies, pylon_repair_spawns_per_wave, pylon_repair_spawn_interval, pylon_repair_wave_enemy_bonus, pylon_repair_breather_duration)
	status_changed.emit("Repair enemies incoming. Survive the lighter repair waves to restore the pylon.")
	_broadcast_gate_state()


func _complete_repair_event() -> void:
	_repair_event_active = false
	_restore_pylon_runtime_state("functional")
	_prepare_gate_cave()
	_stop_enemy_pressure()
	status_changed.emit("Pylon repaired. Defenses are back online and local enemy pressure has stopped.")
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
	var cave_was_active := _cave_active or _cave_activation_channeling
	if success:
		_clear_prepared_cave_state(true)
	elif cave_was_active:
		_collapse_prepared_cave("gate_failed")
	else:
		_clear_prepared_cave_state(true)
	_set_player_channel_lock(_repair_channel_peer_id, false)
	_clear_gate_mode(false)
	_sync_gate_setup.rpc(false)
	if network_manager != null and network_manager.has_method("restart_match"):
		network_manager.restart_match()
	_stop_enemy_pressure()
	if success:
		status_changed.emit("Gate extracted successfully. Scrap secured: %d. Total scrap: %d." % [run_reward, _stored_scrap])
	else:
		if cave_was_active:
			status_changed.emit("Gate failed. The cave collapsed and the pylon foothold was disabled.")
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
	if _claim_event_active:
		_handle_claim_failure()
		return
	if _cave_active or _cave_activation_channeling:
		_handle_cave_failure()
		return
	_finish_gate(false)


func _handle_cave_failure() -> void:
	_collapse_prepared_cave("pylon_failed")
	_cave_active = false
	_cave_activation_channeling = false
	_cave_activation_remaining = 0.0
	_extraction_active = false
	_extraction_remaining = 0.0
	_stop_enemy_pressure()
	status_changed.emit("The cave closed when the pylon fell. The pylon is now disabled and all nearby defenses are offline until repaired.")
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
		enemy_manager.start_gate_pressure(_gate_objective, gate_center, false)
		return
	if enemy_manager.has_method("set_objective") and _gate_objective != null:
		enemy_manager.set_objective(_gate_objective)
	if enemy_manager.has_method("set_spawn_center"):
		enemy_manager.set_spawn_center(gate_center)
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
	_clear_gate_content_local()
	_gate_objective = gate_objective_scene.instantiate()
	_gate_objective.name = "GateObjective"
	if _gate_objective.has_method("configure_objective"):
		_gate_objective.configure_objective("Pylon", gate_objective_max_health)
	if _gate_objective.has_method("bind_network_manager") and network_manager != null:
		_gate_objective.bind_network_manager(network_manager)
	gate_root.add_child(_gate_objective)
	_gate_objective.global_position = gate_center
	_apply_gate_objective_runtime_visuals()
	refresh_gate_pylon_defenses()
	if multiplayer.is_server() and _gate_objective.has_signal("destroyed"):
		_gate_objective.destroyed.connect(_on_gate_objective_destroyed)


func refresh_gate_pylon_defenses() -> void:
	if _gate_objective == null:
		return
	if _gate_objective.has_method("refresh_linked_defenses"):
		_gate_objective.refresh_linked_defenses()


func _clear_gate_content_local() -> void:
	if _gate_objective != null:
		_gate_objective.queue_free()
	_gate_objective = null


func _clear_gate_mode(reset_scrap: bool) -> void:
	_gate_active = false
	_prep_active = false
	_claim_channeling = false
	_claim_channel_remaining = 0.0
	_claim_event_active = false
	_extraction_active = false
	_current_reward = 0.0
	_prep_remaining = 0.0
	_extraction_remaining = 0.0
	_cave_activation_remaining = 0.0
	_repair_channel_remaining = 0.0
	_sync_timer = 0.0
	_cave_spawned = false
	_cave_active = false
	_cave_activation_channeling = false
	_repair_channeling = false
	_repair_event_active = false
	_repair_channel_peer_id = 0
	_repair_channel_origin = Vector3.ZERO
	_prepared_cave_id = 0
	_prepared_cave_descriptor = {}
	if reset_scrap:
		_stored_scrap = 0
	_clear_gate_content_local()
	gate_state_changed.emit(false)
	progression_changed.emit()


func _reset_gate_runtime_state() -> void:
	_gate_active = false
	_prep_active = false
	_claim_channeling = false
	_claim_channel_remaining = 0.0
	_claim_event_active = false
	_extraction_active = false
	_current_reward = 0.0
	_prep_remaining = prep_duration
	_extraction_remaining = 0.0
	_cave_activation_remaining = 0.0
	_repair_channel_remaining = 0.0
	_sync_timer = 0.0
	_cave_spawned = false
	_cave_active = false
	_cave_activation_channeling = false
	_repair_channeling = false
	_repair_event_active = false
	_repair_channel_peer_id = 0
	_repair_channel_origin = Vector3.ZERO
	_prepared_cave_id = 0
	_prepared_cave_descriptor = {}


func _emit_run_info() -> void:
	if _gate_active:
		var phase_text := "Build" if _prep_active else "Idle"
		if _claim_channeling:
			phase_text = "Claim Channel %0.1fs" % _claim_channel_remaining
		elif _claim_event_active:
			phase_text = "Claim Waves"
		elif _repair_channeling:
			phase_text = "Repair Channel %0.1fs" % _repair_channel_remaining
		elif _repair_event_active:
			phase_text = "Repair Defense"
		elif _cave_activation_channeling:
			phase_text = "Cave Channel %0.1fs" % _cave_activation_remaining
		elif _cave_active:
			phase_text = "Cave Open"
		elif _cave_spawned:
			phase_text = "Claimed"
		if _extraction_active:
			phase_text = "Extract %0.1fs" % _extraction_remaining
		var reward_text := int(floor(_current_reward))
		var cave_text := " | Cave %d" % _prepared_cave_id if _prepared_cave_id > 0 else ""
		run_info_changed.emit("Gate | Phase %s | Scrap %d | Stored %d | Core Lv %d%s" % [phase_text, reward_text, _stored_scrap, _core_upgrade_level, cave_text])
		return
	run_info_changed.emit("Base | Stored Scrap %d | Core Lv %d | Max HP %d" % [_stored_scrap, _core_upgrade_level, int(round(get_current_base_core_max_health()))])


func _current_passive_reward_rate() -> float:
	if _cave_active:
		return cave_passive_reward_per_second
	if _cave_spawned:
		return passive_reward_per_second
	return 0.0


func _broadcast_gate_state() -> void:
	_emit_run_info()
	var objective_health := gate_objective_max_health
	var objective_destroyed := false
	var pylon_state := "functional"
	_apply_gate_objective_runtime_visuals()
	if _gate_objective != null and _gate_objective.has_method("get_current_health"):
		objective_health = _gate_objective.get_current_health()
	if _gate_objective != null and _gate_objective.has_method("is_currently_destroyed"):
		objective_destroyed = _gate_objective.is_currently_destroyed()
	if _gate_objective != null and _gate_objective.has_method("get_pylon_state"):
		pylon_state = _gate_objective.get_pylon_state()
	progression_changed.emit()
	_sync_gate_state.rpc(_gate_active, _prep_active, _prep_remaining, _current_reward, _extraction_active, _extraction_remaining, _claim_channeling, _claim_channel_remaining, _claim_event_active, _cave_active, _cave_spawned, _cave_activation_channeling, _cave_activation_remaining, _repair_channeling, _repair_channel_remaining, _repair_event_active, _prepared_cave_id, false, _stored_scrap, _core_upgrade_level, objective_health, objective_destroyed, pylon_state)


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
func _sync_gate_state(gate_active: bool, prep_active: bool, prep_remaining: float, current_reward: float, extraction_active: bool, extraction_remaining: float, claim_channeling: bool, claim_channel_remaining: float, claim_event_active: bool, cave_active: bool, cave_spawned: bool, cave_activation_channeling: bool, cave_activation_remaining: float, repair_channeling: bool, repair_channel_remaining: float, repair_event_active: bool, prepared_cave_id: int, cave_reward_collected: bool, stored_scrap: int, core_upgrade_level: int, objective_health: float, objective_destroyed: bool, pylon_state: String) -> void:
	if multiplayer.is_server():
		return
	_gate_active = gate_active
	_prep_active = prep_active
	_prep_remaining = prep_remaining
	_current_reward = current_reward
	_extraction_active = extraction_active
	_extraction_remaining = extraction_remaining
	_claim_channeling = claim_channeling
	_claim_channel_remaining = claim_channel_remaining
	_claim_event_active = claim_event_active
	_cave_active = cave_active
	_cave_spawned = cave_spawned
	_cave_activation_channeling = cave_activation_channeling
	_cave_activation_remaining = cave_activation_remaining
	_repair_channeling = repair_channeling
	_repair_channel_remaining = repair_channel_remaining
	_repair_event_active = repair_event_active
	_prepared_cave_id = prepared_cave_id
	_stored_scrap = stored_scrap
	_core_upgrade_level = core_upgrade_level
	if gate_active and _gate_objective == null:
		_spawn_gate_content_local()
	if not gate_active:
		_clear_gate_content_local()
	if _gate_objective != null and _gate_objective.has_method("apply_synced_state"):
		_gate_objective.apply_synced_state(objective_health, objective_destroyed)
	if _gate_objective != null and _gate_objective.has_method("set_pylon_state_runtime"):
		_gate_objective.set_pylon_state_runtime(pylon_state)
	_apply_gate_objective_runtime_visuals()
	gate_state_changed.emit(_gate_active)
	progression_changed.emit()
	_emit_run_info()


func _apply_progression_to_base_objective(add_upgrade_bonus: bool) -> void:
	if base_objective == null:
		return
	if base_objective.has_method("set_max_health_runtime"):
		base_objective.set_max_health_runtime(get_current_base_core_max_health(), add_upgrade_bonus)


func _reset_progression_state() -> void:
	_stored_scrap = 0
	_core_upgrade_level = 0
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
	if _gate_objective.has_method("set_cave_visual_state_runtime"):
		_gate_objective.set_cave_visual_state_runtime(_current_cave_visual_state())


func _current_cave_visual_state() -> String:
	if not _gate_active:
		return "hidden"
	if _gate_objective != null and _gate_objective.has_method("get_pylon_state") and _gate_objective.get_pylon_state() == "damaged":
		return "disabled"
	if _cave_active:
		return "open"
	if _cave_activation_channeling:
		return "channeling"
	return "sealed"


func _prepare_gate_cave() -> void:
	if not multiplayer.is_server():
		return
	if _prepared_cave_id > 0:
		return
	if cave_manager == null or not cave_manager.has_method("build_request") or not cave_manager.has_method("prepare_cave"):
		return
	var request = cave_manager.build_request(_current_pylon_id(), _current_cave_entrance_position(), 1, _current_cave_seed(), "gate_cavern", _active_player_count())
	var descriptor: Dictionary = cave_manager.prepare_cave(request)
	_prepared_cave_id = int(descriptor.get("cave_id", 0))
	_prepared_cave_descriptor = descriptor.duplicate(true)


func _enter_prepared_cave() -> void:
	if not multiplayer.is_server():
		return
	if _prepared_cave_id <= 0:
		return
	if cave_manager == null or not cave_manager.has_method("enter_prepared_cave"):
		return
	_prepared_cave_descriptor = cave_manager.enter_prepared_cave(_prepared_cave_id, _active_gate_peer_ids())


func _collapse_prepared_cave(reason: String) -> void:
	if not multiplayer.is_server():
		return
	if _prepared_cave_id <= 0:
		return
	if cave_manager != null and cave_manager.has_method("collapse_cave"):
		cave_manager.collapse_cave(_prepared_cave_id, reason)
	_prepared_cave_descriptor["state"] = "collapsed"


func _clear_prepared_cave_state(clear_runtime: bool) -> void:
	if clear_runtime and cave_manager != null and _prepared_cave_id > 0 and cave_manager.has_method("clear_cave"):
		cave_manager.clear_cave(_prepared_cave_id)
	_prepared_cave_id = 0
	_prepared_cave_descriptor = {}


func _current_pylon_id() -> String:
	return "gate_pylon_%d_%d_%d" % [int(round(gate_center.x)), int(round(gate_center.y)), int(round(gate_center.z))]


func _current_cave_seed() -> int:
	return hash(_current_pylon_id())


func _current_cave_entrance_position() -> Vector3:
	if _gate_objective == null:
		return gate_center + Vector3(0.0, 1.1, -3.3)
	return _gate_objective.global_position + Vector3(0.0, 1.1, -3.3)


func _active_player_count() -> int:
	return _active_gate_peer_ids().size()


func _active_gate_peer_ids() -> Array[int]:
	var peer_ids: Array[int] = []
	if players_root == null:
		return peer_ids
	for player in players_root.get_children():
		if not player is Node3D:
			continue
		if not "peer_id" in player:
			continue
		peer_ids.append(int(player.peer_id))
	return peer_ids


func _start_cave_channel() -> void:
	if not multiplayer.is_server():
		return
	if not _cave_spawned:
		status_changed.emit("Claim the pylon before trying to open the cave.")
		return
	if _prepared_cave_id <= 0:
		_prepare_gate_cave()
	_cave_activation_channeling = false
	_cave_activation_remaining = 0.0
	_cave_active = true
	_set_enemy_pressure_to_gate()
	status_changed.emit("Cave opened. Enemy pressure will keep ramping while the pylon channel stays active. Interact again to close it.")
	_broadcast_gate_state()


func _stop_cave_channel(manual_stop: bool) -> void:
	if not multiplayer.is_server():
		return
	if not _cave_active and not _cave_activation_channeling:
		return
	_cave_active = false
	_cave_activation_channeling = false
	_cave_activation_remaining = 0.0
	_stop_enemy_pressure()
	if manual_stop:
		status_changed.emit("Cave closed. Enemy pressure has stopped and the barrier sealed again.")
	_broadcast_gate_state()


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


func _is_repair_channel_stable() -> bool:
	var player = _player_node(_repair_channel_peer_id)
	if player == null:
		return false
	return player.global_position.distance_to(_repair_channel_origin) <= pylon_repair_break_distance


func _cancel_repair_channel() -> void:
	_set_player_channel_lock(_repair_channel_peer_id, false)
	_repair_channeling = false
	_repair_channel_remaining = 0.0
	_repair_channel_peer_id = 0
	_repair_channel_origin = Vector3.ZERO
	status_changed.emit("Repair channel broken. Return to the pylon and interact again to continue repairing.")
	_broadcast_gate_state()


func _on_gate_pressure_finished(success: bool) -> void:
	if not multiplayer.is_server():
		return
	if _claim_event_active:
		if success:
			_complete_claim_event()
		else:
			_handle_claim_failure()
		return
	if _repair_event_active:
		if success:
			_complete_repair_event()
		return
