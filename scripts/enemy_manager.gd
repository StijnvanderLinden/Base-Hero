extends Node

signal wave_changed(wave_index: int, is_breather: bool)

@export var enemy_scene: PackedScene
@export var max_enemies: int = 6
@export var spawn_interval: float = 3.0
@export var min_spawn_interval: float = 1.0
@export var spawn_radius: float = 14.0
@export var spawns_per_wave: int = 6
@export var breather_duration: float = 6.0
@export var wave_enemy_bonus: int = 1
@export var spawn_interval_step: float = 0.3

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
			_start_next_wave()
		return

	_spawn_timer += delta
	if _spawn_timer < _current_spawn_interval():
		return
	if enemies_root.get_child_count() >= _current_max_enemies():
		return
	if _wave_spawned_count >= spawns_per_wave:
		_begin_breather()
		return

	_spawn_timer = 0.0
	_spawn_enemy_for_all(_next_enemy_id, _next_spawn_position(_next_enemy_id))
	_next_enemy_id += 1
	_wave_spawned_count += 1
	if _wave_spawned_count >= spawns_per_wave:
		_begin_breather()


func _on_session_changed(in_session: bool) -> void:
	_session_active = in_session
	_spawn_timer = 0.0
	_objective_destroyed = false
	_pending_despawns.clear()
	_wave_index = 1
	_wave_spawned_count = 0
	_breather_time_remaining = 0.0
	wave_changed.emit(_wave_index, false)
	if not in_session:
		_next_enemy_id = 1
		_clear_enemies_local()


func _on_objective_destroyed() -> void:
	_objective_destroyed = true


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
		_spawn_enemy_remote.rpc_id(peer_id, enemy.get_enemy_id(), enemy.global_position, enemy.get_current_health())


func _spawn_enemy_for_all(enemy_id: int, spawn_position: Vector3) -> void:
	_spawn_enemy_local(enemy_id, spawn_position)
	if multiplayer.is_server():
		var node_name := _enemy_name(enemy_id)
		if enemies_root != null and enemies_root.has_node(node_name):
			var enemy = enemies_root.get_node(node_name)
			if enemy.has_method("get_current_health"):
				_spawn_enemy_remote.rpc(enemy_id, spawn_position, enemy.get_current_health())


func _spawn_enemy_local(enemy_id: int, spawn_position: Vector3, start_health: float = -1.0) -> void:
	if enemies_root == null or enemy_scene == null:
		return

	var node_name := _enemy_name(enemy_id)
	if enemies_root.has_node(node_name):
		return
	_pending_despawns.erase(enemy_id)

	var enemy = enemy_scene.instantiate()
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


func get_wave_index() -> int:
	return _wave_index


func is_in_breather() -> bool:
	return _breather_time_remaining > 0.0


func set_spawning_paused(paused: bool) -> void:
	_spawning_paused = paused
	if paused:
		_spawn_timer = 0.0


func get_breather_time_remaining() -> float:
	return _breather_time_remaining


func force_restart() -> void:
	if not multiplayer.is_server():
		return
	_next_enemy_id = 1
	_spawn_timer = 0.0
	_objective_destroyed = false
	_wave_index = 1
	_wave_spawned_count = 0
	_breather_time_remaining = 0.0
	_pending_despawns.clear()
	_clear_enemies_local()
	_clear_all_enemies_remote.rpc()
	wave_changed.emit(_wave_index, false)


func _next_spawn_position(enemy_id: int) -> Vector3:
	var angle := float(enemy_id) * 0.9
	return _spawn_center + Vector3(cos(angle) * spawn_radius, 0.6, sin(angle) * spawn_radius)


func _current_max_enemies() -> int:
	return max_enemies + max(_wave_index - 1, 0) * wave_enemy_bonus


func _current_spawn_interval() -> float:
	return max(spawn_interval - float(max(_wave_index - 1, 0)) * spawn_interval_step, min_spawn_interval)


func _begin_breather() -> void:
	if _breather_time_remaining > 0.0:
		return
	_breather_time_remaining = breather_duration
	_spawn_timer = 0.0
	wave_changed.emit(_wave_index, true)


func _start_next_wave() -> void:
	_wave_index += 1
	_wave_spawned_count = 0
	_spawn_timer = 0.0
	wave_changed.emit(_wave_index, false)


func _update_pending_despawns(delta: float) -> void:
	if _pending_despawns.is_empty():
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


@rpc("authority", "call_remote", "reliable")
func _spawn_enemy_remote(enemy_id: int, spawn_position: Vector3, start_health: float = -1.0) -> void:
	_spawn_enemy_local(enemy_id, spawn_position, start_health)


@rpc("authority", "call_remote", "reliable")
func _remove_enemy_remote(enemy_id: int) -> void:
	_remove_enemy_local(enemy_id)


@rpc("authority", "call_remote", "reliable")
func _clear_all_enemies_remote() -> void:
	_clear_enemies_local()
