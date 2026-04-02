extends Node

signal status_changed(message: String)

@export var wall_scene: PackedScene
@export var turret_scene: PackedScene
@export var turret_bullet_scene: PackedScene
@export var grid_size: float = 2.0
@export var placement_distance: float = 3.0
@export var max_walls: int = 20
@export var max_turrets: int = 6
@export var wall_spacing: float = 1.8
@export var turret_spacing: float = 2.4
@export var core_clear_radius: float = 3.5
@export var floor_limit: float = 18.0

var structures_root: Node3D
var projectiles_root: Node3D
var players_root: Node3D
var core_objective: Node3D
var _session_active: bool = false
var _next_wall_id: int = 1
var _next_turret_id: int = 1


func _ready() -> void:
	add_to_group("building_manager")


func set_roots(new_structures_root: Node3D, new_projectiles_root: Node3D, new_players_root: Node3D, new_core_objective: Node3D) -> void:
	structures_root = new_structures_root
	projectiles_root = new_projectiles_root
	players_root = new_players_root
	core_objective = new_core_objective


func bind_network_manager(manager: Node) -> void:
	if manager.has_signal("session_changed"):
		manager.session_changed.connect(_on_session_changed)
	if manager.has_signal("peer_registered"):
		manager.peer_registered.connect(_on_peer_registered)


func get_wall_preview_for_peer(peer_id: int) -> Dictionary:
	return get_build_preview_for_peer(peer_id, "wall")


func get_build_preview_for_peer(peer_id: int, structure_type: String) -> Dictionary:
	structure_type = _normalized_structure_type(structure_type)
	if not _session_active:
		return {"visible": false, "valid": false, "position": Vector3.ZERO, "rotation_y": 0.0}

	var player_node = _player_node(peer_id)
	if player_node == null:
		return {"visible": false, "valid": false, "position": Vector3.ZERO, "rotation_y": 0.0}

	var structure_position := _build_position_for_player(player_node, structure_type)
	var structure_rotation_y := _build_rotation_for_player(player_node)
	return {
		"visible": true,
		"valid": _is_valid_structure_position(structure_type, structure_position),
		"position": structure_position,
		"rotation_y": structure_rotation_y,
		"type": structure_type,
	}


func request_wall_placement(peer_id: int) -> bool:
	return request_structure_placement(peer_id, "wall")


func request_turret_placement(peer_id: int) -> bool:
	return request_structure_placement(peer_id, "turret")


func request_structure_placement(peer_id: int, structure_type: String) -> bool:
	structure_type = _normalized_structure_type(structure_type)
	if not multiplayer.is_server():
		return false
	if not _session_active:
		status_changed.emit("Start a session before building.")
		return false
	if structures_root == null or players_root == null:
		return false
	if not _can_place_more_of_type(structure_type):
		status_changed.emit("%s limit reached." % _structure_display_name(structure_type))
		return false

	var player_node = _player_node(peer_id)
	if player_node == null:
		return false

	var structure_position := _build_position_for_player(player_node, structure_type)
	var structure_rotation_y := _build_rotation_for_player(player_node)
	if not _is_valid_structure_position(structure_type, structure_position):
		status_changed.emit("Invalid %s placement." % structure_type)
		return false

	var structure_id := _next_structure_id(structure_type)
	_spawn_structure_for_all(structure_type, structure_id, structure_position, structure_rotation_y)
	status_changed.emit("%s placed." % _structure_display_name(structure_type))
	_increment_structure_id(structure_type)
	return true


func despawn_wall_for_all(wall_id: int) -> void:
	despawn_structure_for_all("wall", wall_id)


func despawn_turret_for_all(turret_id: int) -> void:
	despawn_structure_for_all("turret", turret_id)


func despawn_structure_for_all(structure_type: String, structure_id: int) -> void:
	structure_type = _normalized_structure_type(structure_type)
	_remove_structure_local(structure_type, structure_id)
	if multiplayer.is_server():
		_remove_structure_remote.rpc(structure_type, structure_id)


func _on_session_changed(in_session: bool) -> void:
	_session_active = in_session
	if in_session:
		return
	_next_wall_id = 1
	_next_turret_id = 1
	_clear_structures_local()
	_clear_projectiles_local()


func restart_match() -> void:
	if not multiplayer.is_server():
		return
	_next_wall_id = 1
	_next_turret_id = 1
	_clear_structures_local()
	_clear_projectiles_local()
	_clear_all_structures_remote.rpc()


func _on_peer_registered(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	if structures_root == null:
		return

	for structure in structures_root.get_children():
		if not structure.has_method("get_structure_kind") or not structure.has_method("get_structure_id"):
			continue
		if not structure.has_method("get_current_health") or not structure.has_method("get_spawn_rotation_y"):
			continue
		_spawn_structure_remote.rpc_id(
			peer_id,
			structure.get_structure_kind(),
			structure.get_structure_id(),
			structure.global_position,
			structure.get_spawn_rotation_y(),
			structure.get_current_health()
		)


func _spawn_structure_for_all(structure_type: String, structure_id: int, structure_position: Vector3, structure_rotation_y: float) -> void:
	structure_type = _normalized_structure_type(structure_type)
	_spawn_structure_local(structure_type, structure_id, structure_position, structure_rotation_y)
	if multiplayer.is_server() and structures_root != null:
		var node_name := _structure_name(structure_type, structure_id)
		if structures_root.has_node(node_name):
			var structure = structures_root.get_node(node_name)
			if structure.has_method("get_current_health"):
				_spawn_structure_remote.rpc(
					structure_type,
					structure_id,
					structure_position,
					structure_rotation_y,
					structure.get_current_health()
				)


func _spawn_structure_local(structure_type: String, structure_id: int, structure_position: Vector3, structure_rotation_y: float, start_health: float = -1.0) -> void:
	structure_type = _normalized_structure_type(structure_type)
	if structures_root == null:
		return
	var structure_scene := _scene_for_type(structure_type)
	if structure_scene == null:
		return

	var node_name := _structure_name(structure_type, structure_id)
	if structures_root.has_node(node_name):
		return

	var structure = structure_scene.instantiate()
	structure.name = node_name
	if structure.has_method("setup"):
		structure.setup(structure_id, structure_position, structure_rotation_y, start_health)
	if structure.has_method("set_manager"):
		structure.set_manager(self)
	if structure.has_method("configure_projectiles"):
		structure.configure_projectiles(projectiles_root, turret_bullet_scene)
	structures_root.add_child(structure)


func _remove_structure_local(structure_type: String, structure_id: int) -> void:
	structure_type = _normalized_structure_type(structure_type)
	if structures_root == null:
		return
	var node_name := _structure_name(structure_type, structure_id)
	if not structures_root.has_node(node_name):
		return
	structures_root.get_node(node_name).queue_free()


func _clear_structures_local() -> void:
	if structures_root == null:
		return
	for child in structures_root.get_children():
		child.queue_free()


func _clear_projectiles_local() -> void:
	if projectiles_root == null:
		return
	for child in projectiles_root.get_children():
		child.queue_free()


func _player_node(peer_id: int) -> Node3D:
	if players_root == null:
		return null
	var node_name := "Player_%d" % peer_id
	if not players_root.has_node(node_name):
		return null
	return players_root.get_node(node_name)


func _build_position_for_player(player_node: Node3D, structure_type: String) -> Vector3:
	var forward := Vector3(sin(player_node.rotation.y), 0.0, cos(player_node.rotation.y))
	if forward.length_squared() <= 0.001:
		forward = Vector3.FORWARD
	var target_position := player_node.global_position + forward.normalized() * placement_distance
	target_position.x = round(target_position.x / grid_size) * grid_size
	target_position.z = round(target_position.z / grid_size) * grid_size
	target_position.y = _build_height_for_type(structure_type)
	return target_position


func _build_rotation_for_player(player_node: Node3D) -> float:
	var quarter_turn := PI * 0.5
	return snappedf(player_node.rotation.y, quarter_turn)


func _is_valid_structure_position(structure_type: String, structure_position: Vector3) -> bool:
	if absf(structure_position.x) > floor_limit or absf(structure_position.z) > floor_limit:
		return false
	if core_objective != null and structure_position.distance_to(core_objective.global_position) < core_clear_radius:
		return false
	if structures_root == null:
		return false

	var minimum_spacing := _spacing_for_type(structure_type)
	for structure in structures_root.get_children():
		if structure_position.distance_to(structure.global_position) < minimum_spacing:
			return false
	return true


func _can_place_more_of_type(structure_type: String) -> bool:
	if structures_root == null:
		return false
	return _count_structures_of_type(structure_type) < _max_count_for_type(structure_type)


func _count_structures_of_type(structure_type: String) -> int:
	if structures_root == null:
		return 0
	var count := 0
	for structure in structures_root.get_children():
		if structure.has_method("get_structure_kind") and structure.get_structure_kind() == structure_type:
			count += 1
	return count


func _max_count_for_type(structure_type: String) -> int:
	structure_type = _normalized_structure_type(structure_type)
	match structure_type:
		"turret":
			return max_turrets
		_:
			return max_walls


func _spacing_for_type(structure_type: String) -> float:
	structure_type = _normalized_structure_type(structure_type)
	match structure_type:
		"turret":
			return turret_spacing
		_:
			return wall_spacing


func _build_height_for_type(structure_type: String) -> float:
	structure_type = _normalized_structure_type(structure_type)
	match structure_type:
		"turret":
			return 0.9
		_:
			return 0.75


func _next_structure_id(structure_type: String) -> int:
	structure_type = _normalized_structure_type(structure_type)
	match structure_type:
		"turret":
			return _next_turret_id
		_:
			return _next_wall_id


func _increment_structure_id(structure_type: String) -> void:
	structure_type = _normalized_structure_type(structure_type)
	match structure_type:
		"turret":
			_next_turret_id += 1
		_:
			_next_wall_id += 1


func _scene_for_type(structure_type: String) -> PackedScene:
	structure_type = _normalized_structure_type(structure_type)
	match structure_type:
		"turret":
			return turret_scene
		_:
			return wall_scene


func _structure_name(structure_type: String, structure_id: int) -> String:
	structure_type = _normalized_structure_type(structure_type)
	match structure_type:
		"turret":
			return "Turret_%d" % structure_id
		_:
			return "Wall_%d" % structure_id


func _structure_display_name(structure_type: String) -> String:
	structure_type = _normalized_structure_type(structure_type)
	return structure_type.capitalize()


func get_projectiles_root() -> Node3D:
	return projectiles_root


func get_turret_bullet_scene() -> PackedScene:
	return turret_bullet_scene


func _normalized_structure_type(structure_type: String) -> String:
	if structure_type == "turret":
		return structure_type
	return "wall"


@rpc("authority", "call_remote", "reliable")
func _spawn_structure_remote(structure_type: String, structure_id: int, structure_position: Vector3, structure_rotation_y: float, start_health: float = -1.0) -> void:
	_spawn_structure_local(structure_type, structure_id, structure_position, structure_rotation_y, start_health)


@rpc("authority", "call_remote", "reliable")
func _remove_structure_remote(structure_type: String, structure_id: int) -> void:
	_remove_structure_local(structure_type, structure_id)


@rpc("authority", "call_remote", "reliable")
func _clear_all_structures_remote() -> void:
	_clear_structures_local()
	_clear_projectiles_local()