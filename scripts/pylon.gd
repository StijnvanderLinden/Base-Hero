extends "res://scripts/core_objective.gd"

@export var defense_link_radius: float = 9.5

var pylon_state: String = "functional"
var cave_visual_state: String = "hidden"
var _uncaptured_color: Color = Color(0.42, 0.48, 0.56)
var _damaged_color: Color = Color(0.68, 0.31, 0.16)
var _cave_frame_color: Color = Color(0.24, 0.22, 0.2)
var _cave_sealed_color: Color = Color(0.18, 0.72, 0.86, 0.72)
var _cave_channeling_color: Color = Color(0.96, 0.78, 0.32, 0.82)
var _cave_open_color: Color = Color(0.09, 0.16, 0.2, 0.94)
var _cave_disabled_color: Color = Color(0.62, 0.28, 0.2, 0.78)

@onready var cave_visual_root: Node3D = $CaveVisual
@onready var cave_frame_left: MeshInstance3D = $CaveVisual/FrameLeft
@onready var cave_frame_right: MeshInstance3D = $CaveVisual/FrameRight
@onready var cave_frame_top: MeshInstance3D = $CaveVisual/FrameTop
@onready var cave_threshold: MeshInstance3D = $CaveVisual/Threshold
@onready var cave_barrier: MeshInstance3D = $CaveVisual/Barrier
@onready var cave_opening: MeshInstance3D = $CaveVisual/Opening


func _ready() -> void:
	_base_color = Color(0.96, 0.76, 0.28)
	super._ready()
	remove_from_group("primary_objective")
	add_to_group("pylons")
	refresh_linked_defenses()
	_update_cave_visuals()


func _reset_local_state() -> void:
	pylon_state = "functional"
	cave_visual_state = "hidden"
	super._reset_local_state()
	refresh_linked_defenses()
	_update_cave_visuals()


func restart_match() -> void:
	super.restart_match()
	if _is_server_context():
		_sync_pylon_state.rpc(pylon_state)
		_sync_cave_visual_state.rpc(cave_visual_state)


func apply_synced_state(server_health: float, server_destroyed: bool, server_max_health: float = -1.0) -> void:
	super.apply_synced_state(server_health, server_destroyed, server_max_health)
	refresh_linked_defenses()


func get_pylon_state() -> String:
	return pylon_state


func get_cave_visual_state() -> String:
	return cave_visual_state


func set_pylon_state_runtime(new_state: String) -> void:
	var normalized_state := _normalized_pylon_state(new_state)
	if pylon_state == normalized_state:
		return
	pylon_state = normalized_state
	refresh_linked_defenses()
	_update_visuals()
	if _is_server_context():
		_sync_pylon_state.rpc(pylon_state)


func set_cave_visual_state_runtime(new_state: String) -> void:
	var normalized_state := _normalized_cave_visual_state(new_state)
	if cave_visual_state == normalized_state:
		return
	cave_visual_state = normalized_state
	_update_cave_visuals()
	if _is_server_context():
		_sync_cave_visual_state.rpc(cave_visual_state)


func is_functional() -> bool:
	return pylon_state == "functional"


func refresh_linked_defenses() -> void:
	if not is_inside_tree():
		return
	var defenses_enabled := pylon_state != "damaged"
	for node in get_tree().get_nodes_in_group("defense_structures"):
		if not node is Node3D:
			continue
		if global_position.distance_to(node.global_position) > defense_link_radius:
			continue
		if node.has_method("set_defense_active"):
			node.set_defense_active(defenses_enabled)


func _on_session_changed(in_session: bool) -> void:
	super._on_session_changed(in_session)
	refresh_linked_defenses()
	if _is_server_context() and in_session:
		_sync_pylon_state.rpc(pylon_state)
		_sync_cave_visual_state.rpc(cave_visual_state)


func _on_peer_registered(peer_id: int) -> void:
	super._on_peer_registered(peer_id)
	if not _is_server_context():
		return
	_sync_pylon_state.rpc_id(peer_id, pylon_state)
	_sync_cave_visual_state.rpc_id(peer_id, cave_visual_state)


func _handle_server_destroyed() -> void:
	set_pylon_state_runtime("damaged")
	super._handle_server_destroyed()


func restore_runtime_state(new_state: String = "functional") -> void:
	is_destroyed = false
	current_health = max_health
	_hit_flash_time_remaining = 0.0
	set_pylon_state_runtime(new_state)
	_update_visuals()
	if _is_server_context():
		_sync_state.rpc(current_health, is_destroyed, max_health)


func _update_visuals() -> void:
	if label == null or health_bar_fill == null:
		return
	var health_ratio = clamp(current_health / max_health, 0.0, 1.0)
	if pylon_state == "uncaptured":
		health_ratio = 0.0
		label.text = "%s Claiming" % display_name
		_update_body_visuals()
	elif pylon_state == "damaged":
		health_ratio = 0.0
		label.text = "%s Damaged" % display_name
	else:
		label.text = "%s HP:%d" % [display_name, int(round(current_health))]
		_update_body_visuals()
	health_bar_fill.scale.x = max(health_ratio, 0.001)
	health_bar_fill.position.x = (_health_bar_width * (health_ratio - 1.0)) * 0.5
	if pylon_state == "damaged":
		var material := StandardMaterial3D.new()
		material.albedo_color = _damaged_color
		body_mesh.material_override = material
	_update_cave_visuals()


func _update_body_visuals() -> void:
	if body_mesh.material_override == null:
		return
	var material := body_mesh.material_override as StandardMaterial3D
	if material == null:
		return
	if pylon_state == "uncaptured":
		material.albedo_color = _uncaptured_color
		return
	if pylon_state == "damaged":
		material.albedo_color = _damaged_color
		return
	if _hit_flash_time_remaining > 0.0:
		material.albedo_color = Color(1.0, 1.0, 1.0)
		return
	material.albedo_color = _base_color


func _update_cave_visuals() -> void:
	if cave_visual_root == null:
		return
	var show_cave := cave_visual_state != "hidden"
	cave_visual_root.visible = show_cave
	if not show_cave:
		return
	_set_mesh_material(cave_frame_left, _cave_frame_color)
	_set_mesh_material(cave_frame_right, _cave_frame_color)
	_set_mesh_material(cave_frame_top, _cave_frame_color)
	_set_mesh_material(cave_threshold, _cave_frame_color)
	match cave_visual_state:
		"sealed":
			cave_barrier.visible = true
			cave_opening.visible = false
			_set_mesh_material(cave_barrier, _cave_sealed_color, true, 0.65)
		"channeling":
			cave_barrier.visible = true
			cave_opening.visible = false
			_set_mesh_material(cave_barrier, _cave_channeling_color, true, 1.25)
		"open":
			cave_barrier.visible = false
			cave_opening.visible = true
			_set_mesh_material(cave_opening, _cave_open_color, true, 0.35)
		"disabled":
			cave_barrier.visible = true
			cave_opening.visible = false
			_set_mesh_material(cave_barrier, _cave_disabled_color, true, 0.45)
		_:
			cave_barrier.visible = false
			cave_opening.visible = false


func _set_mesh_material(mesh_instance: MeshInstance3D, color: Color, use_emission: bool = false, emission_energy: float = 0.0) -> void:
	if mesh_instance == null:
		return
	var material := mesh_instance.material_override as StandardMaterial3D
	if material == null:
		material = StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mesh_instance.material_override = material
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if color.a < 0.99 else BaseMaterial3D.TRANSPARENCY_DISABLED
	material.emission_enabled = use_emission
	material.emission = color
	material.emission_energy_multiplier = emission_energy


@rpc("authority", "call_remote", "reliable")
func _sync_pylon_state(server_pylon_state: String) -> void:
	pylon_state = _normalized_pylon_state(server_pylon_state)
	refresh_linked_defenses()
	_update_visuals()


@rpc("authority", "call_remote", "reliable")
func _sync_cave_visual_state(server_cave_visual_state: String) -> void:
	cave_visual_state = _normalized_cave_visual_state(server_cave_visual_state)
	_update_cave_visuals()


func _normalized_pylon_state(new_state: String) -> String:
	match new_state:
		"uncaptured", "damaged", "functional":
			return new_state
		_:
			return "functional"


func _normalized_cave_visual_state(new_state: String) -> String:
	match new_state:
		"hidden", "sealed", "channeling", "open", "disabled":
			return new_state
		_:
			return "hidden"