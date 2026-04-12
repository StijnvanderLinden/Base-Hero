extends "res://scripts/core_objective.gd"

@export var defense_link_radius: float = 9.5
@export var default_base_radius: float = 20.0
@export var default_max_radius: float = 80.0

var pylon_state: String = "functional"
var pylon_level: int = 1
var influence_radius: float = 20.0
var max_radius: float = 80.0
var current_channel_progress: float = 0.0
var is_channeling: bool = false
var channel_efficiency: float = 1.0
var _uncaptured_color: Color = Color(0.42, 0.48, 0.56)
var _damaged_color: Color = Color(0.68, 0.31, 0.16)
var _channeling_color: Color = Color(0.96, 0.78, 0.32)
var _influence_ring_color: Color = Color(0.18, 0.72, 0.86, 0.18)
var _influence_ring_edge_color: Color = Color(0.22, 0.88, 1.0, 0.45)
var _influence_ring_mesh: MeshInstance3D


func _ready() -> void:
	_base_color = Color(0.96, 0.76, 0.28)
	super._ready()
	remove_from_group("primary_objective")
	add_to_group("pylons")
	influence_radius = max(default_base_radius, 1.0)
	max_radius = max(default_max_radius, influence_radius)
	_ensure_influence_ring()
	refresh_linked_defenses()
	_update_runtime_visuals()


func _reset_local_state() -> void:
	pylon_state = "functional"
	pylon_level = 1
	influence_radius = max(default_base_radius, 1.0)
	max_radius = max(default_max_radius, influence_radius)
	current_channel_progress = 0.0
	is_channeling = false
	channel_efficiency = 1.0
	super._reset_local_state()
	refresh_linked_defenses()
	_update_runtime_visuals()


func restart_match() -> void:
	super.restart_match()
	if _is_server_context():
		_sync_runtime_state.rpc(pylon_state, pylon_level, default_base_radius, influence_radius, max_radius, current_channel_progress, is_channeling, channel_efficiency)


func apply_synced_state(server_health: float, server_destroyed: bool, server_max_health: float = -1.0) -> void:
	super.apply_synced_state(server_health, server_destroyed, server_max_health)
	refresh_linked_defenses()
	_update_runtime_visuals()


func get_pylon_state() -> String:
	return pylon_state


func get_level() -> int:
	return pylon_level


func get_influence_radius() -> float:
	return influence_radius


func get_max_radius() -> float:
	return max_radius


func get_current_channel_progress() -> float:
	return current_channel_progress


func is_channeling_active() -> bool:
	return is_channeling


func set_runtime_progress(new_level: int, base_radius: float, new_influence_radius: float, new_max_radius: float, channel_progress: float, channeling: bool, efficiency: float) -> void:
	pylon_level = max(new_level, 1)
	default_base_radius = max(base_radius, 1.0)
	influence_radius = clamp(new_influence_radius, default_base_radius, max(new_max_radius, default_base_radius))
	max_radius = max(new_max_radius, influence_radius)
	current_channel_progress = max(channel_progress, 0.0)
	is_channeling = channeling
	channel_efficiency = max(efficiency, 0.1)
	_update_visuals()
	if _is_server_context():
		_sync_runtime_state.rpc(pylon_state, pylon_level, default_base_radius, influence_radius, max_radius, current_channel_progress, is_channeling, channel_efficiency)


func set_pylon_state_runtime(new_state: String) -> void:
	var normalized_state := _normalized_pylon_state(new_state)
	if pylon_state == normalized_state:
		return
	pylon_state = normalized_state
	refresh_linked_defenses()
	_update_visuals()
	if _is_server_context():
		_sync_runtime_state.rpc(pylon_state, pylon_level, default_base_radius, influence_radius, max_radius, current_channel_progress, is_channeling, channel_efficiency)


func set_cave_visual_state_runtime(new_state: String) -> void:
	_update_runtime_visuals()


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
		_sync_runtime_state.rpc(pylon_state, pylon_level, default_base_radius, influence_radius, max_radius, current_channel_progress, is_channeling, channel_efficiency)


func _on_peer_registered(peer_id: int) -> void:
	super._on_peer_registered(peer_id)
	if not _is_server_context():
		return
	_sync_runtime_state.rpc_id(peer_id, pylon_state, pylon_level, default_base_radius, influence_radius, max_radius, current_channel_progress, is_channeling, channel_efficiency)


func _handle_server_destroyed() -> void:
	set_pylon_state_runtime("damaged")
	is_channeling = false
	super._handle_server_destroyed()


func restore_runtime_state(new_state: String = "functional") -> void:
	is_destroyed = false
	current_health = max_health
	_hit_flash_time_remaining = 0.0
	current_channel_progress = 0.0
	is_channeling = false
	set_pylon_state_runtime(new_state)
	_update_visuals()
	if _is_server_context():
		_sync_state.rpc(current_health, is_destroyed, max_health)


func _update_visuals() -> void:
	if label == null:
		return
	var state_text := "Ready"
	if pylon_state == "uncaptured":
		state_text = "Unstable"
	elif pylon_state == "damaged":
		state_text = "Shattered"
	elif is_channeling:
		state_text = "Channeling"
	label.text = "%s | %s | R:%d/%d | HP:%d" % [display_name, state_text, int(round(influence_radius)), int(round(max_radius)), int(round(current_health))]
	_update_body_visuals()
	_update_runtime_visuals()


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
	if is_channeling:
		material.albedo_color = _channeling_color
		return
	if _hit_flash_time_remaining > 0.0:
		material.albedo_color = Color(1.0, 1.0, 1.0)
		return
	material.albedo_color = _base_color


func _update_runtime_visuals() -> void:
	_ensure_influence_ring()
	if _influence_ring_mesh == null:
		return
	_influence_ring_mesh.visible = pylon_state != "damaged"
	var cylinder := _influence_ring_mesh.mesh as CylinderMesh
	if cylinder != null:
		cylinder.top_radius = max(influence_radius, 0.1)
		cylinder.bottom_radius = max(influence_radius, 0.1)
	var material := _influence_ring_mesh.material_override as StandardMaterial3D
	if material == null:
		material = StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		_influence_ring_mesh.material_override = material
	material.albedo_color = _influence_ring_edge_color if is_channeling else _influence_ring_color
	material.emission_enabled = true
	material.emission = _influence_ring_edge_color if is_channeling else _influence_ring_color
	material.emission_energy_multiplier = 1.0 if is_channeling else 0.45


func _ensure_influence_ring() -> void:
	if _influence_ring_mesh != null:
		return
	_influence_ring_mesh = MeshInstance3D.new()
	_influence_ring_mesh.name = "InfluenceRing"
	var ring_mesh := CylinderMesh.new()
	ring_mesh.height = 0.08
	ring_mesh.top_radius = influence_radius
	ring_mesh.bottom_radius = influence_radius
	_influence_ring_mesh.mesh = ring_mesh
	_influence_ring_mesh.position = Vector3(0.0, 0.04, 0.0)
	add_child(_influence_ring_mesh)


@rpc("authority", "call_remote", "reliable")
func _sync_runtime_state(server_pylon_state: String, server_level: int, server_base_radius: float, server_influence_radius: float, server_max_radius: float, server_channel_progress: float, server_channeling: bool, server_efficiency: float) -> void:
	pylon_state = _normalized_pylon_state(server_pylon_state)
	pylon_level = max(server_level, 1)
	default_base_radius = max(server_base_radius, 1.0)
	influence_radius = max(server_influence_radius, default_base_radius)
	max_radius = max(server_max_radius, influence_radius)
	current_channel_progress = max(server_channel_progress, 0.0)
	is_channeling = server_channeling
	channel_efficiency = max(server_efficiency, 0.1)
	refresh_linked_defenses()
	_update_visuals()


func _normalized_pylon_state(new_state: String) -> String:
	match new_state:
		"uncaptured", "damaged", "functional":
			return new_state
		_:
			return "functional"