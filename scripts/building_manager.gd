extends Node

signal status_changed(message: String)

@export var wall_scene: PackedScene
@export var turret_scene: PackedScene
@export var turret_bullet_scene: PackedScene
@export var grid_size: float = 2.0
@export var placement_distance: float = 6.5
@export var min_placement_distance: float = 1.5
@export var max_walls: int = 20
@export var max_turrets: int = 6
@export var wall_cost: int = 4
@export var turret_cost: int = 12
@export var repair_interaction_radius: float = 3.0
@export var wall_repair_amount: float = 80.0
@export var turret_repair_amount: float = 60.0
@export var wall_repair_cost: int = 2
@export var turret_repair_cost: int = 4
@export var wall_spacing: float = 2.0
@export var turret_spacing: float = 2.4
@export var wall_chain_spacing: float = 2.0
@export var wall_snap_assist_radius: float = 1.2
@export var turret_anchor_spacing: float = 3.0
@export var turret_snap_assist_radius: float = 1.4
@export var core_clear_radius: float = 3.5
@export var floor_limit: float = 18.0

var structures_root: Node3D
var projectiles_root: Node3D
var players_root: Node3D
var core_objective: Node3D
var gate_manager: Node
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


func set_gate_manager(manager: Node) -> void:
	gate_manager = manager


func get_wall_preview_for_peer(peer_id: int) -> Dictionary:
	return get_build_preview_for_peer(peer_id, "wall")


func get_build_preview_for_peer(peer_id: int, structure_type: String) -> Dictionary:
	structure_type = _normalized_structure_type(structure_type)
	if not _session_active:
		return {"visible": false, "valid": false, "position": Vector3.ZERO, "rotation_y": 0.0}

	var player_node = _player_node(peer_id)
	if player_node == null:
		return {"visible": false, "valid": false, "position": Vector3.ZERO, "rotation_y": 0.0}
	var requested_transform := _default_build_transform_for_player(player_node, structure_type)
	return get_build_preview_from_request(
		peer_id,
		structure_type,
		requested_transform.get("position", Vector3.ZERO),
		float(requested_transform.get("rotation_y", _build_rotation_for_player(player_node)))
	)


func get_build_preview_from_request(peer_id: int, structure_type: String, desired_position: Vector3, desired_rotation_y: float, lock_wall_line: bool = false, preserve_requested_position: bool = false) -> Dictionary:
	structure_type = _normalized_structure_type(structure_type)
	if not _session_active:
		return {"visible": false, "valid": false, "position": Vector3.ZERO, "rotation_y": 0.0}

	var player_node = _player_node(peer_id)
	if player_node == null:
		return {"visible": false, "valid": false, "position": Vector3.ZERO, "rotation_y": 0.0}

	var resolved_transform := _resolved_build_transform(player_node, structure_type, desired_position, desired_rotation_y, lock_wall_line, preserve_requested_position)
	var structure_position: Vector3 = resolved_transform.get("position", Vector3.ZERO)
	var structure_rotation_y: float = float(resolved_transform.get("rotation_y", desired_rotation_y))
	var snap_assisted := bool(resolved_transform.get("snap_assisted", false))
	var snap_kind := String(resolved_transform.get("snap_kind", ""))
	var can_build_now := _is_building_allowed()
	var cost := _cost_for_type(structure_type)
	var can_afford := _can_afford_structure(structure_type)
	var is_valid_position := _is_valid_structure_position(structure_type, structure_position)
	return {
		"visible": true,
		"valid": can_build_now and can_afford and is_valid_position,
		"position": structure_position,
		"positions": [structure_position],
		"rotation_y": structure_rotation_y,
		"type": structure_type,
		"cost": cost,
		"total_cost": cost,
		"count": 1,
		"snap_assisted": snap_assisted,
		"snap_kind": snap_kind,
		"status_text": _preview_status_text(structure_type, can_build_now, can_afford, is_valid_position, snap_kind),
	}


func get_wall_line_preview_from_request(peer_id: int, anchor_position: Vector3, desired_position: Vector3, desired_rotation_y: float) -> Dictionary:
	if not _session_active:
		return {"visible": false, "valid": false, "positions": []}
	var player_node = _player_node(peer_id)
	if player_node == null:
		return {"visible": false, "valid": false, "positions": []}
	var anchor_transform := _resolved_build_transform(player_node, "wall", anchor_position, desired_rotation_y, true, true)
	var start_position: Vector3 = anchor_transform.get("position", Vector3.ZERO)
	var rotation_y := _wall_line_rotation_y(start_position, desired_position, float(anchor_transform.get("rotation_y", desired_rotation_y)))
	var line_positions := _wall_line_positions(start_position, desired_position, rotation_y)
	var count := line_positions.size()
	var total_cost := _total_cost_for_type("wall", count)
	var can_build_now := _is_building_allowed()
	var can_afford := _can_afford_total_cost(total_cost)
	var within_limit := _can_place_count_of_type("wall", count)
	var is_valid := _are_structure_positions_valid("wall", line_positions)
	var status_text := _preview_status_text("wall", can_build_now and within_limit, can_afford, is_valid, "chain")
	if not within_limit:
		status_text = "LIMIT"
	return {
		"visible": true,
		"valid": can_build_now and can_afford and within_limit and is_valid,
		"position": start_position,
		"positions": line_positions,
		"rotation_y": rotation_y,
		"type": "wall",
		"cost": _cost_for_type("wall"),
		"total_cost": total_cost,
		"count": count,
		"snap_assisted": count > 1,
		"snap_kind": "chain",
		"status_text": status_text,
	}


func request_wall_placement(peer_id: int) -> bool:
	return request_structure_placement(peer_id, "wall")


func request_turret_placement(peer_id: int) -> bool:
	return request_structure_placement(peer_id, "turret")


func request_structure_placement(peer_id: int, structure_type: String, desired_position: Vector3 = Vector3.ZERO, desired_rotation_y: float = 0.0, use_requested_transform: bool = false, lock_wall_line: bool = false, preserve_requested_position: bool = false) -> bool:
	structure_type = _normalized_structure_type(structure_type)
	if not multiplayer.is_server():
		return false
	if not _session_active:
		status_changed.emit("Start a session before building.")
		return false
	if structures_root == null or players_root == null:
		return false
	if not _is_building_allowed():
		status_changed.emit("Building is currently locked.")
		return false
	if not _can_place_more_of_type(structure_type):
		status_changed.emit("%s limit reached." % _structure_display_name(structure_type))
		return false
	if not _can_afford_structure(structure_type):
		status_changed.emit(_insufficient_scrap_message(structure_type))
		return false

	var player_node = _player_node(peer_id)
	if player_node == null:
		return false

	var resolved_transform := _default_build_transform_for_player(player_node, structure_type)
	if use_requested_transform:
		resolved_transform = _resolved_build_transform(player_node, structure_type, desired_position, desired_rotation_y, lock_wall_line, preserve_requested_position)
	var structure_position: Vector3 = resolved_transform.get("position", Vector3.ZERO)
	var structure_rotation_y: float = float(resolved_transform.get("rotation_y", _build_rotation_for_player(player_node)))
	if not _is_valid_structure_position(structure_type, structure_position):
		status_changed.emit("Invalid %s placement." % structure_type)
		return false
	if not _spend_structure_cost(structure_type):
		status_changed.emit(_insufficient_scrap_message(structure_type))
		return false

	var structure_id := _next_structure_id(structure_type)
	_spawn_structure_for_all(structure_type, structure_id, structure_position, structure_rotation_y)
	status_changed.emit(_placement_success_message(structure_type))
	_increment_structure_id(structure_type)
	return true


func request_structure_batch_placement(peer_id: int, structure_type: String, desired_positions: Array, desired_rotation_y: float = 0.0) -> bool:
	structure_type = _normalized_structure_type(structure_type)
	if not multiplayer.is_server():
		return false
	if not _session_active:
		status_changed.emit("Start a session before building.")
		return false
	if structures_root == null or players_root == null:
		return false
	if not _is_building_allowed():
		status_changed.emit("Building is currently locked.")
		return false
	var player_node = _player_node(peer_id)
	if player_node == null:
		return false
	var positions := _sanitized_structure_positions(desired_positions, structure_type)
	if positions.is_empty():
		return false
	if not _can_place_count_of_type(structure_type, positions.size()):
		status_changed.emit("%s limit reached." % _structure_display_name(structure_type))
		return false
	var total_cost := _total_cost_for_type(structure_type, positions.size())
	if not _can_afford_total_cost(total_cost):
		status_changed.emit(_insufficient_total_scrap_message(structure_type, positions.size(), total_cost))
		return false
	if not _are_structure_positions_valid(structure_type, positions):
		status_changed.emit("Invalid %s placement." % structure_type)
		return false
	if not _spend_total_structure_cost(total_cost):
		status_changed.emit(_insufficient_total_scrap_message(structure_type, positions.size(), total_cost))
		return false
	var snapped_rotation_y := snappedf(desired_rotation_y, PI * 0.5)
	for position in positions:
		var structure_id := _next_structure_id(structure_type)
		_spawn_structure_for_all(structure_type, structure_id, position, snapped_rotation_y)
		_increment_structure_id(structure_type)
	status_changed.emit(_batch_placement_success_message(structure_type, positions.size(), total_cost))
	return true


func request_structure_repair(peer_id: int) -> bool:
	if not multiplayer.is_server():
		return false
	if not _session_active:
		return false
	var player_node = _player_node(peer_id)
	if player_node == null:
		return false
	var structure = _nearest_repairable_structure(player_node.global_position)
	if structure == null:
		return false
	var structure_type := "wall"
	if structure.has_method("get_structure_kind"):
		structure_type = _normalized_structure_type(structure.get_structure_kind())
	if not _can_afford_repair(structure_type):
		status_changed.emit(_insufficient_repair_scrap_message(structure_type))
		return true
	if not structure.has_method("apply_server_repair"):
		return false
	var repaired_amount := float(structure.apply_server_repair(_repair_amount_for_type(structure_type)))
	if repaired_amount <= 0.0:
		return true
	if not _spend_repair_cost(structure_type):
		return true
	status_changed.emit(_repair_success_message(structure_type, repaired_amount))
	return true


func get_repair_cost_for_type(structure_type: String) -> int:
	return _repair_cost_for_type(structure_type)


func get_repair_prompt_for_peer(peer_id: int) -> Dictionary:
	if not _session_active:
		return {"visible": false, "text": ""}
	var player_node = _player_node(peer_id)
	if player_node == null:
		return {"visible": false, "text": ""}
	var structure = _nearest_repairable_structure(player_node.global_position)
	if structure == null:
		return {"visible": false, "text": ""}
	var structure_type := "wall"
	if structure.has_method("get_structure_kind"):
		structure_type = _normalized_structure_type(structure.get_structure_kind())
	var cost := _repair_cost_for_type(structure_type)
	var text := "Press E to repair %s" % _structure_display_name(structure_type)
	if structure.has_method("get_current_health"):
		text += " (%d/%d HP)" % [int(round(structure.get_current_health())), int(round(_max_health_for_structure(structure)))]
	if cost > 0:
		if _can_afford_repair(structure_type):
			text += " for %d scrap" % cost
		else:
			text = "Need %d scrap to repair %s" % [cost, _structure_display_name(structure_type)]
	return {"visible": true, "text": text}


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
	_refresh_gate_linked_defenses()


func _remove_structure_local(structure_type: String, structure_id: int) -> void:
	structure_type = _normalized_structure_type(structure_type)
	if structures_root == null:
		return
	var node_name := _structure_name(structure_type, structure_id)
	if not structures_root.has_node(node_name):
		return
	structures_root.get_node(node_name).queue_free()
	_refresh_gate_linked_defenses()


func _clear_structures_local() -> void:
	if structures_root == null:
		return
	for child in structures_root.get_children():
		child.queue_free()
	_refresh_gate_linked_defenses()


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


func _nearest_repairable_structure(origin: Vector3) -> Node3D:
	if structures_root == null:
		return null
	var best_structure: Node3D = null
	var best_distance := repair_interaction_radius * repair_interaction_radius
	for structure in structures_root.get_children():
		if not structure is Node3D:
			continue
		if not structure.has_method("can_be_repaired") or not structure.can_be_repaired():
			continue
		var distance := origin.distance_squared_to(structure.global_position)
		if distance <= best_distance:
			best_distance = distance
			best_structure = structure
	return best_structure


func _build_position_for_player(player_node: Node3D, structure_type: String) -> Vector3:
	return _default_build_transform_for_player(player_node, structure_type).get("position", Vector3.ZERO)


func _build_rotation_for_player(player_node: Node3D) -> float:
	if player_node.has_method("get_build_rotation_y"):
		return player_node.get_build_rotation_y()
	var quarter_turn := PI * 0.5
	return snappedf(player_node.rotation.y, quarter_turn)


func get_max_placement_distance() -> float:
	return max(placement_distance, 0.0)


func get_min_placement_distance() -> float:
	return max(min_placement_distance, 0.0)


func get_grid_size() -> float:
	return max(grid_size, 0.001)


func get_active_build_area_center() -> Vector3:
	return _active_area_center()


func get_active_build_area_size() -> float:
	return max(floor_limit * 2.0, get_grid_size())


func get_wall_drag_step() -> float:
	return max(wall_chain_spacing, grid_size)


func _is_valid_structure_position(structure_type: String, structure_position: Vector3) -> bool:
	return _is_structure_position_available(structure_type, structure_position)


func _is_building_allowed() -> bool:
	if gate_manager == null:
		return true
	if gate_manager.has_method("is_gate_active") and gate_manager.is_gate_active():
		if gate_manager.has_method("is_build_phase_active"):
			return gate_manager.is_build_phase_active()
		return false
	return true


func _active_area_center() -> Vector3:
	if gate_manager != null and gate_manager.has_method("is_gate_active") and gate_manager.is_gate_active():
		if gate_manager.has_method("get_gate_center"):
			return gate_manager.get_gate_center()
	return Vector3.ZERO


func _active_objective_position() -> Vector3:
	if gate_manager != null and gate_manager.has_method("get_active_objective_position"):
		return gate_manager.get_active_objective_position()
	if core_objective != null:
		return core_objective.global_position
	return Vector3.ZERO


func _can_place_more_of_type(structure_type: String) -> bool:
	if structures_root == null:
		return false
	return _count_structures_of_type(structure_type) < _max_count_for_type(structure_type)


func _can_place_count_of_type(structure_type: String, amount: int) -> bool:
	if structures_root == null:
		return false
	return _count_structures_of_type(structure_type) + max(amount, 0) <= _max_count_for_type(structure_type)


func _count_structures_of_type(structure_type: String) -> int:
	if structures_root == null:
		return 0
	var area_center := _active_area_center()
	var count := 0
	for structure in structures_root.get_children():
		if structure.has_method("get_structure_kind") and structure.get_structure_kind() == structure_type:
			if absf(structure.global_position.x - area_center.x) <= floor_limit and absf(structure.global_position.z - area_center.z) <= floor_limit:
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


func _cost_for_type(structure_type: String) -> int:
	structure_type = _normalized_structure_type(structure_type)
	match structure_type:
		"turret":
			return max(turret_cost, 0)
		_:
			return max(wall_cost, 0)


func _total_cost_for_type(structure_type: String, amount: int) -> int:
	return _cost_for_type(structure_type) * max(amount, 0)


func _can_afford_structure(structure_type: String) -> bool:
	var cost := _cost_for_type(structure_type)
	if cost <= 0:
		return true
	if gate_manager == null or not gate_manager.has_method("can_afford_scrap"):
		return true
	return gate_manager.can_afford_scrap(cost)


func _can_afford_total_cost(cost: int) -> bool:
	if cost <= 0:
		return true
	if gate_manager == null or not gate_manager.has_method("can_afford_scrap"):
		return true
	return gate_manager.can_afford_scrap(cost)


func _spend_structure_cost(structure_type: String) -> bool:
	var cost := _cost_for_type(structure_type)
	if cost <= 0:
		return true
	if gate_manager == null or not gate_manager.has_method("consume_scrap"):
		return true
	return gate_manager.consume_scrap(cost)


func _spend_total_structure_cost(cost: int) -> bool:
	if cost <= 0:
		return true
	if gate_manager == null or not gate_manager.has_method("consume_scrap"):
		return true
	return gate_manager.consume_scrap(cost)


func _current_stored_scrap() -> int:
	if gate_manager == null or not gate_manager.has_method("get_stored_scrap"):
		return 0
	return int(gate_manager.get_stored_scrap())


func _max_health_for_structure(structure: Node) -> float:
	if structure == null:
		return 0.0
	if "max_health" in structure:
		return float(structure.max_health)
	return 0.0


func _insufficient_scrap_message(structure_type: String) -> String:
	var cost := _cost_for_type(structure_type)
	return "Need %d scrap for %s. Stored: %d." % [cost, _structure_display_name(structure_type).to_lower(), _current_stored_scrap()]


func _insufficient_total_scrap_message(structure_type: String, count: int, total_cost: int) -> String:
	return "Need %d scrap for %d %ss. Stored: %d." % [total_cost, count, _structure_display_name(structure_type).to_lower(), _current_stored_scrap()]


func _placement_success_message(structure_type: String) -> String:
	var cost := _cost_for_type(structure_type)
	if cost <= 0:
		return "%s placed." % _structure_display_name(structure_type)
	return "%s placed for %d scrap. Stored: %d." % [_structure_display_name(structure_type), cost, _current_stored_scrap()]


func _batch_placement_success_message(structure_type: String, count: int, total_cost: int) -> String:
	if total_cost <= 0:
		return "%d %ss placed." % [count, _structure_display_name(structure_type)]
	return "%d %ss placed for %d scrap. Stored: %d." % [count, _structure_display_name(structure_type), total_cost, _current_stored_scrap()]


func _preview_status_text(structure_type: String, can_build_now: bool, can_afford: bool, is_valid_position: bool, snap_kind: String = "") -> String:
	var cost := _cost_for_type(structure_type)
	if not can_build_now:
		return "LOCKED"
	if not can_afford:
		return "NO SCRAP"
	if not is_valid_position:
		return "BLOCKED"
	if snap_kind == "corner":
		return "CORNER"
	if snap_kind == "chain":
		return "SNAP"
	if snap_kind == "anchor":
		return "ANCHOR"
	if cost <= 0:
		return "FREE"
	return "%d SCRAP" % cost


func _default_build_transform_for_player(player_node: Node3D, structure_type: String) -> Dictionary:
	var forward := Vector3.ZERO
	if player_node.has_method("get_build_forward_vector"):
		forward = player_node.get_build_forward_vector()
	else:
		forward = -player_node.global_basis.z
	if forward.length_squared() <= 0.001:
		forward = Vector3.FORWARD
	var target_position := player_node.global_position + forward.normalized() * placement_distance
	return _resolved_build_transform(player_node, structure_type, target_position, _build_rotation_for_player(player_node))


func _resolved_build_transform(player_node: Node3D, structure_type: String, desired_position: Vector3, desired_rotation_y: float, lock_wall_line: bool = false, preserve_requested_position: bool = false) -> Dictionary:
	var resolved_rotation_y := snappedf(desired_rotation_y, PI * 0.5)
	if preserve_requested_position:
		var anchored_position := _snap_position_to_grid(desired_position, structure_type)
		anchored_position.y = _build_height_for_type(structure_type)
		return {
			"position": anchored_position,
			"rotation_y": resolved_rotation_y,
			"snap_assisted": false,
			"snap_kind": "",
		}
	var player_origin := player_node.global_position
	var planar_offset := desired_position - player_origin
	planar_offset.y = 0.0
	if planar_offset.length_squared() <= 0.001:
		var fallback_forward := Vector3.FORWARD
		if player_node.has_method("get_build_forward_vector"):
			fallback_forward = player_node.get_build_forward_vector()
		planar_offset = fallback_forward.normalized() * placement_distance
	var planar_distance := planar_offset.length()
	var clamped_distance = clamp(planar_distance, min_placement_distance, placement_distance)
	var clamped_direction := planar_offset.normalized()
	var clamped_position = player_origin + clamped_direction * clamped_distance
	var snapped_position := _snap_position_to_grid(clamped_position, structure_type)
	var snap_assisted := false
	var snap_kind := ""
	if structure_type == "wall":
		var chain_snap := _wall_chain_snap(snapped_position, lock_wall_line)
		if bool(chain_snap.get("found", false)):
			snapped_position = chain_snap.get("position", snapped_position)
			snap_assisted = true
			snap_kind = String(chain_snap.get("kind", "chain"))
			resolved_rotation_y = float(chain_snap.get("rotation_y", resolved_rotation_y))
	elif structure_type == "turret":
		var turret_anchor := _turret_anchor_snap(snapped_position)
		if bool(turret_anchor.get("found", false)):
			snapped_position = turret_anchor.get("position", snapped_position)
			snap_assisted = true
			snap_kind = String(turret_anchor.get("kind", "anchor"))
			resolved_rotation_y = float(turret_anchor.get("rotation_y", resolved_rotation_y))
	snapped_position.y = _build_height_for_type(structure_type)
	return {
		"position": snapped_position,
		"rotation_y": resolved_rotation_y,
		"snap_assisted": snap_assisted,
		"snap_kind": snap_kind,
	}


func _snap_position_to_grid(world_position: Vector3, structure_type: String) -> Vector3:
	var snapped_position := world_position
	snapped_position.x = round(snapped_position.x / grid_size) * grid_size
	snapped_position.z = round(snapped_position.z / grid_size) * grid_size
	snapped_position.y = _build_height_for_type(structure_type)
	return snapped_position


func _wall_chain_snap(desired_position: Vector3, straight_only: bool = false) -> Dictionary:
	if structures_root == null:
		return {"found": false, "position": desired_position}
	var best_distance := wall_snap_assist_radius
	var best_position := desired_position
	var best_rotation_y := 0.0
	var best_kind := "chain"
	var found := false
	for structure in structures_root.get_children():
		if not structure.has_method("get_structure_kind"):
			continue
		if structure.get_structure_kind() != "wall":
			continue
		var rotation_y = structure.rotation.y
		if structure.has_method("get_spawn_rotation_y"):
			rotation_y = structure.get_spawn_rotation_y()
		var basis := Basis.from_euler(Vector3(0.0, rotation_y, 0.0))
		var candidates := [
			{"direction": basis.x, "rotation_y": snappedf(rotation_y, PI * 0.5), "kind": "chain"},
			{"direction": -basis.x, "rotation_y": snappedf(rotation_y, PI * 0.5), "kind": "chain"},
		]
		if not straight_only:
			candidates.append({"direction": basis.z, "rotation_y": snappedf(rotation_y + PI * 0.5, PI * 0.5), "kind": "corner"})
			candidates.append({"direction": -basis.z, "rotation_y": snappedf(rotation_y + PI * 0.5, PI * 0.5), "kind": "corner"})
		for candidate_data in candidates:
			var direction: Vector3 = candidate_data.get("direction", Vector3.ZERO)
			var candidate := _snap_position_to_grid(structure.global_position + direction.normalized() * wall_chain_spacing, "wall")
			var distance := candidate.distance_to(desired_position)
			if distance > wall_snap_assist_radius or distance >= best_distance:
				continue
			best_distance = distance
			best_position = candidate
			best_rotation_y = float(candidate_data.get("rotation_y", rotation_y))
			best_kind = String(candidate_data.get("kind", "chain"))
			found = true
	return {"found": found, "position": best_position, "rotation_y": best_rotation_y, "kind": best_kind}


func _wall_line_positions(anchor_position: Vector3, desired_position: Vector3, rotation_y: float) -> Array:
	var positions: Array = []
	var line_rotation_y := _wall_line_rotation_y(anchor_position, desired_position, rotation_y)
	var drag_axis := _drag_axis_from_rotation(line_rotation_y)
	var step := get_wall_drag_step()
	var offset := desired_position - anchor_position
	offset.y = 0.0
	var projected := offset.dot(drag_axis)
	var direction_sign := 1.0 if projected >= 0.0 else -1.0
	var extra_count := int(floor((absf(projected) / max(step, 0.001)) + 0.5))
	for index in range(extra_count + 1):
		var position := anchor_position + drag_axis * step * float(index) * direction_sign
		position = _snap_position_to_grid(position, "wall")
		positions.append(position)
	return positions


func _wall_line_rotation_y(anchor_position: Vector3, desired_position: Vector3, fallback_rotation_y: float) -> float:
	var offset := desired_position - anchor_position
	offset.y = 0.0
	if offset.length_squared() <= 0.001:
		return snappedf(fallback_rotation_y, PI * 0.5)
	if absf(offset.x) >= absf(offset.z):
		return 0.0
	return PI * 0.5


func _drag_axis_from_rotation(rotation_y: float) -> Vector3:
	var snapped_rotation := snappedf(rotation_y, PI * 0.5)
	var quarter_turns := posmod(int(round(snapped_rotation / (PI * 0.5))), 4)
	if quarter_turns % 2 == 0:
		return Vector3.RIGHT
	return Vector3.FORWARD


func _sanitized_structure_positions(desired_positions: Array, structure_type: String) -> Array:
	var sanitized: Array = []
	var seen := {}
	for raw_position in desired_positions:
		if not raw_position is Vector3:
			continue
		var position := _snap_position_to_grid(raw_position, structure_type)
		var key := "%0.2f|%0.2f|%0.2f" % [position.x, position.y, position.z]
		if seen.has(key):
			continue
		seen[key] = true
		sanitized.append(position)
	return sanitized


func _are_structure_positions_valid(structure_type: String, positions: Array) -> bool:
	var planned: Array = []
	for position in positions:
		if not position is Vector3:
			return false
		if not _is_structure_position_available(structure_type, position, planned):
			return false
		planned.append(position)
	return true


func _is_structure_position_available(structure_type: String, structure_position: Vector3, planned_positions: Array = []) -> bool:
	var area_center := _active_area_center()
	if absf(structure_position.x - area_center.x) > floor_limit or absf(structure_position.z - area_center.z) > floor_limit:
		return false
	if structure_position.distance_to(_active_objective_position()) < core_clear_radius:
		return false
	if structures_root == null:
		return false
	if _is_player_occupying_structure_cell(structure_type, structure_position):
		return false
	var minimum_spacing := _spacing_for_type(structure_type)
	for structure in structures_root.get_children():
		if structure_position.distance_to(structure.global_position) < minimum_spacing:
			return false
	for planned_position in planned_positions:
		if structure_position.distance_to(planned_position) < minimum_spacing:
			return false
	return true


func _is_player_occupying_structure_cell(structure_type: String, structure_position: Vector3) -> bool:
	if players_root == null:
		return false
	var snapped_target := _snap_position_to_grid(structure_position, structure_type)
	var half_cell := get_grid_size() * 0.5
	for player in players_root.get_children():
		if not player is Node3D:
			continue
		if player.has_method("can_be_targeted") and not player.can_be_targeted():
			continue
		var player_position: Vector3 = player.global_position
		var player_radius := 0.75
		if player.has_method("get_hit_radius"):
			player_radius = float(player.get_hit_radius())
		var dx = max(absf(player_position.x - snapped_target.x) - half_cell, 0.0)
		var dz = max(absf(player_position.z - snapped_target.z) - half_cell, 0.0)
		if dx * dx + dz * dz < player_radius * player_radius:
			return true
	return false


func _turret_anchor_snap(desired_position: Vector3) -> Dictionary:
	if structures_root == null:
		return {"found": false, "position": desired_position}
	var best_distance := turret_snap_assist_radius
	var best_position := desired_position
	var best_rotation_y := 0.0
	var found := false
	for structure in structures_root.get_children():
		if not structure.has_method("get_structure_kind"):
			continue
		if structure.get_structure_kind() != "wall":
			continue
		var rotation_y = structure.rotation.y
		if structure.has_method("get_spawn_rotation_y"):
			rotation_y = structure.get_spawn_rotation_y()
		var basis := Basis.from_euler(Vector3(0.0, rotation_y, 0.0))
		var candidates := [
			{"direction": basis.z, "rotation_y": snappedf(rotation_y, PI * 0.5)},
			{"direction": -basis.z, "rotation_y": snappedf(rotation_y + PI, PI * 0.5)},
			{"direction": basis.x, "rotation_y": snappedf(rotation_y + PI * 0.5, PI * 0.5)},
			{"direction": -basis.x, "rotation_y": snappedf(rotation_y - PI * 0.5, PI * 0.5)},
		]
		for candidate_data in candidates:
			var direction: Vector3 = candidate_data.get("direction", Vector3.ZERO)
			var candidate := _snap_position_to_grid(structure.global_position + direction.normalized() * turret_anchor_spacing, "turret")
			var distance := candidate.distance_to(desired_position)
			if distance > turret_snap_assist_radius or distance >= best_distance:
				continue
			best_distance = distance
			best_position = candidate
			best_rotation_y = float(candidate_data.get("rotation_y", rotation_y))
			found = true
	return {"found": found, "position": best_position, "rotation_y": best_rotation_y, "kind": "anchor"}


func _repair_amount_for_type(structure_type: String) -> float:
	structure_type = _normalized_structure_type(structure_type)
	match structure_type:
		"turret":
			return max(turret_repair_amount, 0.0)
		_:
			return max(wall_repair_amount, 0.0)


func _repair_cost_for_type(structure_type: String) -> int:
	structure_type = _normalized_structure_type(structure_type)
	match structure_type:
		"turret":
			return max(turret_repair_cost, 0)
		_:
			return max(wall_repair_cost, 0)


func _can_afford_repair(structure_type: String) -> bool:
	var cost := _repair_cost_for_type(structure_type)
	if cost <= 0:
		return true
	if gate_manager == null or not gate_manager.has_method("can_afford_scrap"):
		return true
	return gate_manager.can_afford_scrap(cost)


func _spend_repair_cost(structure_type: String) -> bool:
	var cost := _repair_cost_for_type(structure_type)
	if cost <= 0:
		return true
	if gate_manager == null or not gate_manager.has_method("consume_scrap"):
		return true
	return gate_manager.consume_scrap(cost)


func _insufficient_repair_scrap_message(structure_type: String) -> String:
	var cost := _repair_cost_for_type(structure_type)
	return "Need %d scrap to repair %s. Stored: %d." % [cost, _structure_display_name(structure_type).to_lower(), _current_stored_scrap()]


func _repair_success_message(structure_type: String, repaired_amount: float) -> String:
	var cost := _repair_cost_for_type(structure_type)
	if cost <= 0:
		return "%s repaired for %d HP." % [_structure_display_name(structure_type), int(round(repaired_amount))]
	return "%s repaired for %d HP at %d scrap. Stored: %d." % [_structure_display_name(structure_type), int(round(repaired_amount)), cost, _current_stored_scrap()]


func get_projectiles_root() -> Node3D:
	return projectiles_root


func get_turret_bullet_scene() -> PackedScene:
	return turret_bullet_scene


func _refresh_gate_linked_defenses() -> void:
	if gate_manager == null:
		return
	if gate_manager.has_method("refresh_gate_pylon_defenses"):
		gate_manager.refresh_gate_pylon_defenses()


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
