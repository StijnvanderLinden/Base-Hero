extends Node

signal wave_changed(wave_index: int, is_breather: bool)
signal raid_finished(success: bool)

@export var enemy_scene: PackedScene
@export var raid_enemy_scene: PackedScene
@export var raid_breaker_enemy_scene: PackedScene
@export var max_enemies: int = 6
@export var spawn_interval: float = 2.8
@export var min_spawn_interval: float = 1.0
@export var spawn_radius: float = 14.0
@export var spawns_per_wave: int = 6
@export var breather_duration: float = 5.0
@export var wave_enemy_bonus: int = 2
@export var spawn_interval_step: float = 0.35
@export var raid_total_waves: int = 3
@export var raid_max_enemies: int = 8
@export var raid_spawn_interval: float = 2.2
@export var raid_spawns_per_wave: int = 8
@export var raid_breather_duration: float = 5.0
@export var raid_wave_enemy_bonus: int = 2
@export var exploration_enemy_base_health: float = 60.0
@export var construct_enemy_base_health: float = 80.0
@export var construct_breaker_base_health: float = 140.0
@export var gate_enemy_health_bonus_per_wave: float = 18.0
@export var raid_enemy_health_bonus_per_wave: float = 0.0

var enemies_root: Node3D
var players_root: Node3D
var objective: Node3D
var _spawn_timer: float = 0.0
var _next_enemy_id: int = 1
var _session_active: bool = false
var _objective_destroyed: bool = false
var _pending_despawns: Dictionary = {}
var _wave_index: int = 1
var _wave_spawned_count: int = 0
var _breather_time_remaining: float = 0.0
var _spawn_center: Vector3 = Vector3.ZERO
var _spawning_paused: bool = false
var _pressure_mode: String = "idle"
var _raid_total_waves_runtime: int = 3
var _raid_max_enemies_runtime: int = 8
var _raid_spawn_interval_runtime: float = 2.2
var _raid_spawns_per_wave_runtime: int = 8
var _raid_breather_duration_runtime: float = 5.0
var _raid_wave_enemy_bonus_runtime: int = 2
var _spawn_point_provider: Node


func set_roots(enemy_root: Node3D, player_root: Node3D) -> void:
	enemies_root = enemy_root
	players_root = player_root


func set_objective(target_objective: Node3D) -> void:
	if objective != null and objective.has_signal("destroyed") and objective.destroyed.is_connected(_on_objective_destroyed):
		objective.destroyed.disconnect(_on_objective_destroyed)
	objective = target_objective
	if objective != null and objective.has_signal("destroyed"):
		objective.destroyed.connect(_on_objective_destroyed)
		_spawn_center = objective.global_position


func set_spawn_center(new_spawn_center: Vector3) -> void:
	_spawn_center = new_spawn_center


func set_spawn_point_provider(provider: Node) -> void:
	_spawn_point_provider = provider


func get_current_objective() -> Node3D:
	return objective


func bind_network_manager(manager: Node) -> void:
	if manager.has_signal("session_changed"):
		manager.session_changed.connect(_on_session_changed)
	if manager.has_signal("peer_registered"):
		manager.peer_registered.connect(_on_peer_registered)


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_update_pending_despawns(delta)

	if not _session_active:
		return
	if not multiplayer.is_server():
		return
	if _pressure_mode == "idle":
		return
	if enemies_root == null or players_root == null:
		return
	if _objective_destroyed:
		return
	if players_root.get_child_count() == 0:
		return
	if _spawning_paused:
		return
	if _breather_time_remaining > 0.0:
		_breather_time_remaining = max(_breather_time_remaining - delta, 0.0)
		if _breather_time_remaining <= 0.0:
			if _should_wait_for_raid_completion():
				_check_for_raid_completion()
				return
			_start_next_wave()
		return
	if _should_wait_for_raid_completion():
		_check_for_raid_completion()
		return

	_spawn_timer += delta
	if _spawn_timer < _current_spawn_interval():
		return
	if enemies_root.get_child_count() >= _current_max_enemies():
		return
	if _wave_spawned_count >= _current_spawns_per_wave():
		_begin_breather()
		return

	_spawn_timer = 0.0
	_spawn_enemy_for_all(_next_enemy_id, _next_spawn_position(_next_enemy_id))
	_next_enemy_id += 1
	_wave_spawned_count += 1
	if _wave_spawned_count >= _current_spawns_per_wave():
		if _should_wait_for_raid_completion():
			_check_for_raid_completion()
			return
		_begin_breather()


func _on_session_changed(in_session: bool) -> void:
	_session_active = in_session
	_reset_pressure_state()
	_spawning_paused = true
	_pressure_mode = "idle"
	if not in_session:
		_next_enemy_id = 1
		_clear_enemies_local()


func _on_objective_destroyed() -> void:
	_objective_destroyed = true
	if multiplayer.is_server() and _pressure_mode == "raid":
		stop_pressure(true)
		raid_finished.emit(false)


func _on_peer_registered(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	if enemies_root == null:
		return

	for enemy in enemies_root.get_children():
		if enemy.has_method("is_alive") and not enemy.is_alive():
			continue
		if not enemy.has_method("get_enemy_id") or not enemy.has_method("get_current_health"):
			continue
		var enemy_kind := "exploration"
		if enemy.has_method("get_enemy_scene_kind"):
			enemy_kind = enemy.get_enemy_scene_kind()
		_spawn_enemy_remote.rpc_id(peer_id, enemy.get_enemy_id(), enemy.global_position, enemy.get_current_health(), enemy_kind)


func _spawn_enemy_for_all(enemy_id: int, spawn_position: Vector3) -> void:
	var enemy_kind := _enemy_kind_for_current_pressure()
	var start_health := _current_enemy_start_health(enemy_kind)
	_spawn_enemy_local(enemy_id, spawn_position, start_health, enemy_kind)
	if multiplayer.is_server():
		var node_name := _enemy_name(enemy_id)
		if enemies_root != null and enemies_root.has_node(node_name):
			var enemy = enemies_root.get_node(node_name)
			if enemy.has_method("get_current_health"):
				_spawn_enemy_remote.rpc(enemy_id, spawn_position, enemy.get_current_health(), enemy_kind)


func _spawn_enemy_local(enemy_id: int, spawn_position: Vector3, start_health: float = -1.0, enemy_kind: String = "exploration") -> void:
	var spawn_scene := _scene_for_enemy_kind(enemy_kind)
	if enemies_root == null or spawn_scene == null:
		return

	var node_name := _enemy_name(enemy_id)
	if enemies_root.has_node(node_name):
		return
	_pending_despawns.erase(enemy_id)

	var enemy = spawn_scene.instantiate()
	enemy.name = node_name
	if enemy.has_method("setup"):
		enemy.setup(enemy_id, spawn_position, start_health)
	if enemy.has_method("set_manager"):
		enemy.set_manager(self)
	enemies_root.add_child(enemy)


func schedule_enemy_despawn(enemy_id: int, delay: float) -> void:
	if not multiplayer.is_server():
		return
	if _pending_despawns.has(enemy_id):
		return
	_pending_despawns[enemy_id] = max(delay, 0.0)


func despawn_enemy_for_all(enemy_id: int) -> void:
	_remove_enemy_local(enemy_id)
	if multiplayer.is_server():
		_remove_enemy_remote.rpc(enemy_id)


func _remove_enemy_local(enemy_id: int) -> void:
	if enemies_root == null:
		return

	var node_name := _enemy_name(enemy_id)
	if not enemies_root.has_node(node_name):
		return

	_pending_despawns.erase(enemy_id)
	enemies_root.get_node(node_name).queue_free()


func _clear_enemies_local() -> void:
	if enemies_root == null:
		return

	_pending_despawns.clear()
	for child in enemies_root.get_children():
		child.queue_free()


func _enemy_name(enemy_id: int) -> String:
	return "Enemy_%d" % enemy_id


func _enemy_kind_for_current_pressure() -> String:
	if _pressure_mode == "raid":
		return _raid_enemy_kind_for_current_spawn()
	return "exploration"


func _raid_enemy_kind_for_current_spawn() -> String:
	if _wave_index <= 1:
		return "construct"
	var spawn_number := _wave_spawned_count + 1
	var cadence := 4
	if _wave_index >= 3:
		cadence = 3
	if spawn_number % cadence == 0:
		return "construct_breaker"
	return "construct"


func _scene_for_enemy_kind(enemy_kind: String) -> PackedScene:
	if enemy_kind == "construct_breaker" and raid_breaker_enemy_scene != null:
		return raid_breaker_enemy_scene
	if enemy_kind == "construct" and raid_enemy_scene != null:
		return raid_enemy_scene
	return enemy_scene


func _current_enemy_start_health(enemy_kind: String) -> float:
	var base_health := exploration_enemy_base_health
	if enemy_kind == "construct":
		base_health = construct_enemy_base_health
	elif enemy_kind == "construct_breaker":
		base_health = construct_breaker_base_health
	var wave_bonus := gate_enemy_health_bonus_per_wave if _pressure_mode == "gate" else raid_enemy_health_bonus_per_wave
	return max(base_health + float(max(_wave_index - 1, 0)) * wave_bonus, 1.0)


func get_wave_index() -> int:
	return _wave_index


func get_wave_spawned_count() -> int:
	return _wave_spawned_count


func get_current_spawns_per_wave_count() -> int:
	return _current_spawns_per_wave()


func get_active_enemy_count() -> int:
	if enemies_root == null:
		return 0
	return enemies_root.get_child_count()


func get_pressure_mode() -> String:
	return _pressure_mode


func is_raid_active() -> bool:
	return _pressure_mode == "raid"


func is_in_breather() -> bool:
	return _breather_time_remaining > 0.0


func set_spawning_paused(paused: bool) -> void:
	_spawning_paused = paused
	if paused:
		_spawn_timer = 0.0


func start_gate_pressure(target_objective: Node3D, spawn_center: Vector3, paused_for_prep: bool = true) -> void:
	if not multiplayer.is_server():
		return
	set_objective(target_objective)
	set_spawn_center(spawn_center)
	_pressure_mode = "gate"
	_reset_pressure_state()
	_spawning_paused = paused_for_prep
	_clear_enemies_local()
	_clear_all_enemies_remote.rpc()
	wave_changed.emit(_wave_index, false)


func start_raid_pressure(target_objective: Node3D, spawn_center: Vector3, total_waves: int, max_enemies_override: int, spawns_per_wave_override: int, spawn_interval_override: float, wave_enemy_bonus_override: int, breather_duration_override: float) -> void:
	if not multiplayer.is_server():
		return
	set_objective(target_objective)
	set_spawn_center(spawn_center)
	_pressure_mode = "raid"
	_raid_total_waves_runtime = max(total_waves, 1)
	_raid_max_enemies_runtime = max(max_enemies_override, 1)
	_raid_spawns_per_wave_runtime = max(spawns_per_wave_override, 1)
	_raid_spawn_interval_runtime = max(spawn_interval_override, 0.2)
	_raid_wave_enemy_bonus_runtime = max(wave_enemy_bonus_override, 0)
	_raid_breather_duration_runtime = max(breather_duration_override, 0.0)
	_reset_pressure_state()
	_spawning_paused = false
	_clear_enemies_local()
	_clear_all_enemies_remote.rpc()
	wave_changed.emit(_wave_index, false)


func stop_pressure(clear_enemies: bool = true) -> void:
	if not multiplayer.is_server():
		return
	_pressure_mode = "idle"
	_reset_pressure_state()
	_spawning_paused = true
	if clear_enemies:
		_clear_enemies_local()
		_clear_all_enemies_remote.rpc()


func get_breather_time_remaining() -> float:
	return _breather_time_remaining


func force_restart() -> void:
	if not multiplayer.is_server():
		return
	_pressure_mode = "idle"
	_next_enemy_id = 1
	_reset_pressure_state()
	_spawning_paused = true
	_clear_enemies_local()
	_clear_all_enemies_remote.rpc()


func _next_spawn_position(enemy_id: int) -> Vector3:
	if _spawn_point_provider != null and _spawn_point_provider.has_method("get_enemy_spawn_position"):
		return _spawn_point_provider.get_enemy_spawn_position(enemy_id)
	var angle := float(enemy_id) * 0.9
	return _spawn_center + Vector3(cos(angle) * spawn_radius, 0.6, sin(angle) * spawn_radius)


func _current_max_enemies() -> int:
	if _pressure_mode == "raid":
		return _raid_max_enemies_runtime + max(_wave_index - 1, 0) * _raid_wave_enemy_bonus_runtime
	return max_enemies + max(_wave_index - 1, 0) * wave_enemy_bonus


func _current_spawn_interval() -> float:
	if _pressure_mode == "raid":
		return max(_raid_spawn_interval_runtime - float(max(_wave_index - 1, 0)) * spawn_interval_step, min_spawn_interval)
	return max(spawn_interval - float(max(_wave_index - 1, 0)) * spawn_interval_step, min_spawn_interval)


func _current_spawns_per_wave() -> int:
	if _pressure_mode == "raid":
		return _raid_spawns_per_wave_runtime
	return spawns_per_wave


func _begin_breather() -> void:
	if _breather_time_remaining > 0.0:
		return
	_breather_time_remaining = _raid_breather_duration_runtime if _pressure_mode == "raid" else breather_duration
	_spawn_timer = 0.0
	wave_changed.emit(_wave_index, true)


func _start_next_wave() -> void:
	_wave_index += 1
	_wave_spawned_count = 0
	_spawn_timer = 0.0
	wave_changed.emit(_wave_index, false)


func _update_pending_despawns(delta: float) -> void:
	if _pending_despawns.is_empty():
		_check_for_raid_completion()
		return

	var to_remove: Array[int] = []
	for enemy_id in _pending_despawns.keys():
		var time_remaining: float = _pending_despawns[enemy_id]
		time_remaining = max(time_remaining - delta, 0.0)
		_pending_despawns[enemy_id] = time_remaining
		if time_remaining <= 0.0:
			to_remove.append(enemy_id)

	for enemy_id in to_remove:
		despawn_enemy_for_all(enemy_id)

	_check_for_raid_completion()


func _reset_pressure_state() -> void:
	_spawn_timer = 0.0
	_objective_destroyed = false
	_pending_despawns.clear()
	_wave_index = 1
	_wave_spawned_count = 0
	_breather_time_remaining = 0.0


func _should_wait_for_raid_completion() -> bool:
	return _pressure_mode == "raid" and _wave_index >= _raid_total_waves_runtime and _wave_spawned_count >= _current_spawns_per_wave()


func _check_for_raid_completion() -> void:
	if not multiplayer.is_server():
		return
	if _pressure_mode != "raid":
		return
	if not _should_wait_for_raid_completion():
		return
	if enemies_root != null and enemies_root.get_child_count() > 0:
		return
	stop_pressure(false)
	raid_finished.emit(true)


@rpc("authority", "call_remote", "reliable")
func _spawn_enemy_remote(enemy_id: int, spawn_position: Vector3, start_health: float = -1.0, enemy_kind: String = "exploration") -> void:
	_spawn_enemy_local(enemy_id, spawn_position, start_health, enemy_kind)


@rpc("authority", "call_remote", "reliable")
func _remove_enemy_remote(enemy_id: int) -> void:
	_remove_enemy_local(enemy_id)


@rpc("authority", "call_remote", "reliable")
func _clear_all_enemies_remote() -> void:
	_clear_enemies_local()
