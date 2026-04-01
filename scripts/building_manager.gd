extends Node

signal status_changed(message: String)

@export var wall_scene: PackedScene
@export var grid_size: float = 2.0
@export var placement_distance: float = 3.0
@export var max_walls: int = 20
@export var wall_spacing: float = 1.8
@export var core_clear_radius: float = 3.5
@export var floor_limit: float = 18.0

var walls_root: Node3D
var players_root: Node3D
var core_objective: Node3D
var _session_active: bool = false
var _next_wall_id: int = 1


func _ready() -> void:
	add_to_group("building_manager")


func set_roots(new_walls_root: Node3D, new_players_root: Node3D, new_core_objective: Node3D) -> void:
	walls_root = new_walls_root
	players_root = new_players_root
	core_objective = new_core_objective


func bind_network_manager(manager: Node) -> void:
	if manager.has_signal("session_changed"):
		manager.session_changed.connect(_on_session_changed)
	if manager.has_signal("peer_registered"):
		manager.peer_registered.connect(_on_peer_registered)


func get_wall_preview_for_peer(peer_id: int) -> Dictionary:
	if not _session_active:
		return {"visible": false, "valid": false, "position": Vector3.ZERO, "rotation_y": 0.0}

	var player_node = _player_node(peer_id)
	if player_node == null:
		return {"visible": false, "valid": false, "position": Vector3.ZERO, "rotation_y": 0.0}

	var wall_position := _build_position_for_player(player_node)
	var wall_rotation_y := _build_rotation_for_player(player_node)
	return {
		"visible": true,
		"valid": _is_valid_wall_position(wall_position),
		"position": wall_position,
		"rotation_y": wall_rotation_y,
	}


func request_wall_placement(peer_id: int) -> bool:
	if not multiplayer.is_server():
		return false
	if not _session_active:
		status_changed.emit("Start a session before building.")
		return false
	if walls_root == null or players_root == null:
		return false
	if walls_root.get_child_count() >= max_walls:
		status_changed.emit("Wall limit reached.")
		return false

	var player_node = _player_node(peer_id)
	if player_node == null:
		return false

	var wall_position := _build_position_for_player(player_node)
	var wall_rotation_y := _build_rotation_for_player(player_node)
	if not _is_valid_wall_position(wall_position):
		status_changed.emit("Invalid wall placement.")
		return false

	_spawn_wall_for_all(_next_wall_id, wall_position, wall_rotation_y)
	status_changed.emit("Wall placed.")
	_next_wall_id += 1
	return true


func despawn_wall_for_all(wall_id: int) -> void:
	_remove_wall_local(wall_id)
	if multiplayer.is_server():
		_remove_wall_remote.rpc(wall_id)


func _on_session_changed(in_session: bool) -> void:
	_session_active = in_session
	if in_session:
		return
	_next_wall_id = 1
	_clear_walls_local()


func _on_peer_registered(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	if walls_root == null:
		return

	for wall in walls_root.get_children():
		if not wall.has_method("get_wall_id") or not wall.has_method("get_current_health") or not wall.has_method("get_spawn_rotation_y"):
			continue
		_spawn_wall_remote.rpc_id(peer_id, wall.get_wall_id(), wall.global_position, wall.get_spawn_rotation_y(), wall.get_current_health())


func _spawn_wall_for_all(wall_id: int, wall_position: Vector3, wall_rotation_y: float) -> void:
	_spawn_wall_local(wall_id, wall_position, wall_rotation_y)
	if multiplayer.is_server() and walls_root != null:
		var node_name := _wall_name(wall_id)
		if walls_root.has_node(node_name):
			var wall = walls_root.get_node(node_name)
			if wall.has_method("get_current_health"):
				_spawn_wall_remote.rpc(wall_id, wall_position, wall_rotation_y, wall.get_current_health())


func _spawn_wall_local(wall_id: int, wall_position: Vector3, wall_rotation_y: float, start_health: float = -1.0) -> void:
	if walls_root == null or wall_scene == null:
		return

	var node_name := _wall_name(wall_id)
	if walls_root.has_node(node_name):
		return

	var wall = wall_scene.instantiate()
	wall.name = node_name
	if wall.has_method("setup"):
		wall.setup(wall_id, wall_position, wall_rotation_y, start_health)
	if wall.has_method("set_manager"):
		wall.set_manager(self)
	walls_root.add_child(wall)


func _remove_wall_local(wall_id: int) -> void:
	if walls_root == null:
		return
	var node_name := _wall_name(wall_id)
	if not walls_root.has_node(node_name):
		return
	walls_root.get_node(node_name).queue_free()


func _clear_walls_local() -> void:
	if walls_root == null:
		return
	for child in walls_root.get_children():
		child.queue_free()


func _player_node(peer_id: int) -> Node3D:
	if players_root == null:
		return null
	var node_name := "Player_%d" % peer_id
	if not players_root.has_node(node_name):
		return null
	return players_root.get_node(node_name)


func _build_position_for_player(player_node: Node3D) -> Vector3:
	var forward := Vector3(sin(player_node.rotation.y), 0.0, cos(player_node.rotation.y))
	if forward.length_squared() <= 0.001:
		forward = Vector3.FORWARD
	var target_position := player_node.global_position + forward.normalized() * placement_distance
	target_position.x = round(target_position.x / grid_size) * grid_size
	target_position.z = round(target_position.z / grid_size) * grid_size
	target_position.y = 0.75
	return target_position


func _build_rotation_for_player(player_node: Node3D) -> float:
	var quarter_turn := PI * 0.5
	return snappedf(player_node.rotation.y, quarter_turn)


func _is_valid_wall_position(wall_position: Vector3) -> bool:
	if absf(wall_position.x) > floor_limit or absf(wall_position.z) > floor_limit:
		return false
	if core_objective != null and wall_position.distance_to(core_objective.global_position) < core_clear_radius:
		return false
	if walls_root == null:
		return false

	for wall in walls_root.get_children():
		if wall_position.distance_to(wall.global_position) < wall_spacing:
			return false
	return true


func _wall_name(wall_id: int) -> String:
	return "Wall_%d" % wall_id


@rpc("authority", "call_remote", "reliable")
func _spawn_wall_remote(wall_id: int, wall_position: Vector3, wall_rotation_y: float, start_health: float = -1.0) -> void:
	_spawn_wall_local(wall_id, wall_position, wall_rotation_y, start_health)


@rpc("authority", "call_remote", "reliable")
func _remove_wall_remote(wall_id: int) -> void:
	_remove_wall_local(wall_id)