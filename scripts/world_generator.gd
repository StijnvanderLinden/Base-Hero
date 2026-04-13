extends Node3D

signal world_generated()
signal build_zone_changed()

@export var world_center: Vector3 = Vector3(64.0, 0.0, 0.0)
@export var world_width: float = 112.0
@export var world_length: float = 112.0
@export var terrain_resolution_x: int = 56
@export var terrain_resolution_z: int = 56
@export var base_height_scale: float = 3.6
@export var hill_height_scale: float = 2.4
@export var mountain_height_scale: float = 12.0
@export var broad_noise_frequency: float = 0.018
@export var hill_noise_frequency: float = 0.05
@export var mountain_noise_frequency: float = 0.01
@export var mountain_frequency: float = 0.2
@export var edge_wall_height: float = 18.0
@export var edge_wall_thickness: float = 4.0
@export var pylon_max_placement_slope: float = 1.4
@export var build_zone_surface_thickness: float = 0.3
@export var build_zone_platform_height_offset: float = 0.45
@export var build_zone_visual_offset: float = 0.08

var world_root: Node3D
var gate_floor: StaticBody3D
var network_manager: Node

var _terrain_root: Node3D
var _terrain_body: StaticBody3D
var _boundary_root: Node3D
var _build_zone_root: Node3D

var _world_active: bool = false
var _current_seed: int = 0
var _base_sample_rows: Array = []
var _sample_rows: Array = []
var _sample_count_x: int = 0
var _sample_count_z: int = 0
var _cell_size_x: float = 1.0
var _cell_size_z: float = 1.0
var _build_zone: Dictionary = {}


func set_dependencies(new_world_root: Node3D, new_gate_floor: StaticBody3D) -> void:
	world_root = new_world_root
	gate_floor = new_gate_floor
	_ensure_runtime_roots()


func bind_network_manager(manager: Node) -> void:
	network_manager = manager
	if manager.has_signal("session_changed"):
		manager.session_changed.connect(_on_session_changed)
	if manager.has_signal("peer_registered"):
		manager.peer_registered.connect(_on_peer_registered)


func generate_world(seed_value: int) -> void:
	if world_root == null:
		return
	_world_active = true
	_current_seed = seed_value if seed_value != 0 else int(Time.get_unix_time_from_system())
	_rebuild_world_local()
	_set_gate_floor_active(false)
	if multiplayer.is_server():
		_sync_world_state.rpc(_world_active, _current_seed)
	world_generated.emit()


func clear_world() -> void:
	_world_active = false
	_current_seed = 0
	_clear_build_zone_local()
	_clear_world_local()
	_set_gate_floor_active(true)
	if multiplayer.is_server():
		_sync_build_zone_state.rpc(false, {})
		_sync_world_state.rpc(false, 0)


func has_active_world() -> bool:
	return _world_active


func is_within_world_bounds(world_position: Vector3, margin: float = 0.0) -> bool:
	var half_width = max(world_width * 0.5 - margin, 0.0)
	var half_length = max(world_length * 0.5 - margin, 0.0)
	return absf(world_position.x - world_center.x) <= half_width and absf(world_position.z - world_center.z) <= half_length


func sample_height(world_position: Vector3) -> float:
	return _sample_height_from_rows(_sample_rows, world_position)


func _sample_height_from_rows(rows: Array, world_position: Vector3) -> float:
	if rows.is_empty():
		return world_center.y
	var local_x = clamp(world_position.x - (world_center.x - world_width * 0.5), 0.0, world_width)
	var local_z = clamp(world_position.z - (world_center.z - world_length * 0.5), 0.0, world_length)
	var grid_x = clamp(local_x / max(_cell_size_x, 0.001), 0.0, float(_sample_count_x - 1))
	var grid_z = clamp(local_z / max(_cell_size_z, 0.001), 0.0, float(_sample_count_z - 1))
	var x0 := int(floor(grid_x))
	var z0 := int(floor(grid_z))
	var x1 = min(x0 + 1, _sample_count_x - 1)
	var z1 = min(z0 + 1, _sample_count_z - 1)
	var tx = grid_x - float(x0)
	var tz = grid_z - float(z0)
	var h00 := _height_from_rows(rows, x0, z0)
	var h10 := _height_from_rows(rows, x1, z0)
	var h01 := _height_from_rows(rows, x0, z1)
	var h11 := _height_from_rows(rows, x1, z1)
	var hx0 := lerpf(h00, h10, tx)
	var hx1 := lerpf(h01, h11, tx)
	return lerpf(hx0, hx1, tz)


func project_to_terrain(world_position: Vector3, vertical_offset: float = 0.0) -> Vector3:
	var projected := world_position
	projected.y = sample_height(world_position) + vertical_offset
	return projected


func get_spawn_position_with_offset(offset: Vector3) -> Vector3:
	var target := world_center + Vector3(offset.x, 0.0, offset.z)
	return project_to_terrain(target, 0.6)


func is_valid_pylon_position(world_position: Vector3, clearance_radius: float) -> bool:
	if not _world_active:
		return false
	if not is_within_world_bounds(world_position, clearance_radius + 2.0):
		return false
	var center_height := sample_height(world_position)
	var sample_factors := [-1.0, -0.5, 0.0, 0.5, 1.0]
	for x_factor in sample_factors:
		for z_factor in sample_factors:
			if is_zero_approx(x_factor) and is_zero_approx(z_factor):
				continue
			var sample_position := world_position + Vector3(clearance_radius * x_factor, 0.0, clearance_radius * z_factor)
			if not is_within_world_bounds(sample_position, 1.0):
				return false
			if absf(sample_height(sample_position) - center_height) > pylon_max_placement_slope:
				return false
	return true


func create_or_update_build_zone(center: Vector3, build_radius: float, flatten_radius: float, spawn_min_radius: float, spawn_max_radius: float) -> Dictionary:
	var safe_build_radius = max(build_radius, 1.0)
	var safe_spawn_min_radius = max(spawn_min_radius, safe_build_radius + 1.0)
	var safe_spawn_max_radius = max(spawn_max_radius, safe_spawn_min_radius + 1.0)
	var slope_width = max(flatten_radius - safe_build_radius, 2.0)
	var safe_slope_half_extent = safe_spawn_max_radius + slope_width
	var foundation_height = _average_height_for_rows(_base_sample_rows, center, safe_build_radius) + build_zone_platform_height_offset
	_build_zone = {
		"center": Vector3(center.x, 0.0, center.z),
		"build_radius": safe_build_radius,
		"platform_half_extent": safe_spawn_max_radius,
		"flatten_radius": safe_slope_half_extent,
		"slope_half_extent": safe_slope_half_extent,
		"spawn_min_radius": safe_spawn_min_radius,
		"spawn_max_radius": safe_spawn_max_radius,
		"foundation_height": foundation_height,
	}
	_apply_build_zone_to_heightmap()
	_rebuild_terrain_local()
	_rebuild_build_zone_local()
	if multiplayer.is_server():
		_sync_build_zone_state.rpc(true, _build_zone.duplicate(true))
	build_zone_changed.emit()
	return _build_zone.duplicate(true)


func clear_build_zone() -> void:
	_build_zone = {}
	_restore_base_heightmap()
	_rebuild_terrain_local()
	_clear_build_zone_local()
	if multiplayer.is_server():
		_sync_build_zone_state.rpc(false, {})
	build_zone_changed.emit()


func has_build_zone() -> bool:
	return not _build_zone.is_empty()


func get_build_zone_center() -> Vector3:
	if _build_zone.is_empty():
		return world_center
	var center: Vector3 = _build_zone.get("center", world_center)
	return Vector3(center.x, get_build_zone_surface_y(), center.z)


func get_build_zone_radius() -> float:
	return float(_build_zone.get("build_radius", 0.0))


func get_build_zone_surface_y() -> float:
	return float(_build_zone.get("foundation_height", world_center.y))


func is_position_in_build_zone(world_position: Vector3, margin: float = 0.0) -> bool:
	if _build_zone.is_empty():
		return false
	var center: Vector3 = _build_zone.get("center", world_center)
	var build_half_extent = max(float(_build_zone.get("build_radius", 0.0)) - margin, 0.0)
	return _is_inside_square_extent(center, world_position, build_half_extent)


func project_to_build_surface(world_position: Vector3, vertical_offset: float = 0.0) -> Vector3:
	var projected := world_position
	projected.y = get_build_zone_surface_y() + vertical_offset
	return projected


func get_enemy_spawn_position(target_center: Vector3, enemy_id: int) -> Vector3:
	var min_radius := float(_build_zone.get("spawn_min_radius", 14.0))
	var max_radius := float(_build_zone.get("spawn_max_radius", 22.0))
	var rng_seed = max(_current_seed + enemy_id * 31, 1)
	for attempt in range(18):
		var side_index := int(posmod(rng_seed + attempt * 17, 4))
		var depth_ratio := fmod(float(rng_seed + attempt * 53), 997.0) / 997.0
		var edge_ratio := fmod(float(rng_seed * 13 + attempt * 71), 2048.0) / 2048.0
		var candidate := target_center + _square_ring_local_position(min_radius, max_radius, side_index, depth_ratio, edge_ratio)
		if not is_within_world_bounds(candidate, 1.0):
			continue
		if is_position_in_build_zone(candidate, -0.5):
			continue
		return project_to_terrain(candidate, 0.6)
	return project_to_terrain(target_center + Vector3(max_radius, 0.0, 0.0), 0.6)


func _on_session_changed(in_session: bool) -> void:
	if in_session:
		return
	clear_world()


func _on_peer_registered(peer_id: int) -> void:
	if not multiplayer.is_server() or not _world_active:
		return
	_sync_world_state.rpc_id(peer_id, _world_active, _current_seed)
	if not _build_zone.is_empty():
		_sync_build_zone_state.rpc_id(peer_id, true, _build_zone.duplicate(true))


func _ensure_runtime_roots() -> void:
	if world_root == null:
		return
	if _terrain_root == null:
		_terrain_root = Node3D.new()
		_terrain_root.name = "GeneratedTerrain"
		world_root.add_child(_terrain_root)
	if _boundary_root == null:
		_boundary_root = Node3D.new()
		_boundary_root.name = "WorldBoundaries"
		world_root.add_child(_boundary_root)
	if _build_zone_root == null:
		_build_zone_root = Node3D.new()
		_build_zone_root.name = "BuildZoneRuntime"
		world_root.add_child(_build_zone_root)


func _rebuild_world_local() -> void:
	_ensure_runtime_roots()
	_clear_world_local()
	_sample_count_x = max(terrain_resolution_x, 2)
	_sample_count_z = max(terrain_resolution_z, 2)
	_cell_size_x = world_width / float(_sample_count_x - 1)
	_cell_size_z = world_length / float(_sample_count_z - 1)
	_build_heightmap()
	_build_terrain_mesh()
	_build_boundaries()


func _clear_world_local() -> void:
	_base_sample_rows.clear()
	_sample_rows.clear()
	if _terrain_root != null:
		for child in _terrain_root.get_children():
			child.queue_free()
	if _boundary_root != null:
		for child in _boundary_root.get_children():
			child.queue_free()
	_terrain_body = null


func _build_heightmap() -> void:
	_base_sample_rows.clear()
	var broad_noise := FastNoiseLite.new()
	broad_noise.seed = _current_seed
	broad_noise.frequency = broad_noise_frequency
	broad_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	var hill_noise := FastNoiseLite.new()
	hill_noise.seed = _current_seed + 101
	hill_noise.frequency = hill_noise_frequency
	hill_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	var mountain_noise := FastNoiseLite.new()
	mountain_noise.seed = _current_seed + 207
	mountain_noise.frequency = mountain_noise_frequency
	mountain_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	for z_index in range(_sample_count_z):
		var row := PackedFloat32Array()
		row.resize(_sample_count_x)
		for x_index in range(_sample_count_x):
			var local_x := -world_width * 0.5 + float(x_index) * _cell_size_x
			var local_z := -world_length * 0.5 + float(z_index) * _cell_size_z
			var broad := broad_noise.get_noise_2d(local_x, local_z) * base_height_scale
			var hills := hill_noise.get_noise_2d(local_x, local_z) * hill_height_scale
			var mountain_mask := (mountain_noise.get_noise_2d(local_x, local_z) + 1.0) * 0.5
			var mountain_threshold = clamp(1.0 - mountain_frequency, 0.55, 0.95)
			var mountains := 0.0
			if mountain_mask > mountain_threshold:
				var normalized = (mountain_mask - mountain_threshold) / max(1.0 - mountain_threshold, 0.001)
				mountains = pow(normalized, 2.2) * mountain_height_scale
			row[x_index] = world_center.y + broad * 0.45 + hills * 0.55 + mountains
		_base_sample_rows.append(row)
	_sample_rows = _duplicate_height_rows(_base_sample_rows)
	_apply_build_zone_to_heightmap()


func _build_terrain_mesh() -> void:
	_terrain_body = StaticBody3D.new()
	_terrain_body.name = "TerrainBody"
	_terrain_root.add_child(_terrain_body)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "TerrainMesh"
	_terrain_body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	collision.name = "TerrainCollision"
	_terrain_body.add_child(collision)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z_index in range(_sample_count_z - 1):
		for x_index in range(_sample_count_x - 1):
			var v00 := _vertex_at(x_index, z_index)
			var v10 := _vertex_at(x_index + 1, z_index)
			var v01 := _vertex_at(x_index, z_index + 1)
			var v11 := _vertex_at(x_index + 1, z_index + 1)
			var uv00 := Vector2(float(x_index) / float(_sample_count_x - 1), float(z_index) / float(_sample_count_z - 1))
			var uv10 := Vector2(float(x_index + 1) / float(_sample_count_x - 1), float(z_index) / float(_sample_count_z - 1))
			var uv01 := Vector2(float(x_index) / float(_sample_count_x - 1), float(z_index + 1) / float(_sample_count_z - 1))
			var uv11 := Vector2(float(x_index + 1) / float(_sample_count_x - 1), float(z_index + 1) / float(_sample_count_z - 1))
			surface.set_uv(uv00)
			surface.add_vertex(v00)
			surface.set_uv(uv10)
			surface.add_vertex(v10)
			surface.set_uv(uv01)
			surface.add_vertex(v01)
			surface.set_uv(uv10)
			surface.add_vertex(v10)
			surface.set_uv(uv11)
			surface.add_vertex(v11)
			surface.set_uv(uv01)
			surface.add_vertex(v01)
	surface.generate_normals()
	var mesh := surface.commit()
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.32, 0.44, 0.28)
	material.roughness = 1.0
	mesh_instance.material_override = material
	var terrain_shape := mesh.create_trimesh_shape()
	if terrain_shape is ConcavePolygonShape3D:
		terrain_shape.backface_collision = true
	collision.shape = terrain_shape


func _build_boundaries() -> void:
	var half_width := world_width * 0.5
	var half_length := world_length * 0.5
	var wall_y := world_center.y + edge_wall_height * 0.5
	_create_boundary_wall("NorthBoundary", Vector3(world_center.x, wall_y, world_center.z - half_length - edge_wall_thickness * 0.5), Vector3(world_width + edge_wall_thickness * 2.0, edge_wall_height, edge_wall_thickness))
	_create_boundary_wall("SouthBoundary", Vector3(world_center.x, wall_y, world_center.z + half_length + edge_wall_thickness * 0.5), Vector3(world_width + edge_wall_thickness * 2.0, edge_wall_height, edge_wall_thickness))
	_create_boundary_wall("WestBoundary", Vector3(world_center.x - half_width - edge_wall_thickness * 0.5, wall_y, world_center.z), Vector3(edge_wall_thickness, edge_wall_height, world_length))
	_create_boundary_wall("EastBoundary", Vector3(world_center.x + half_width + edge_wall_thickness * 0.5, wall_y, world_center.z), Vector3(edge_wall_thickness, edge_wall_height, world_length))


func _create_boundary_wall(node_name: String, wall_position: Vector3, wall_size: Vector3) -> void:
	var wall_body := StaticBody3D.new()
	wall_body.name = node_name
	wall_body.position = wall_position
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = wall_size
	collision.shape = shape
	wall_body.add_child(collision)
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = wall_size
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.23, 0.24)
	material.roughness = 1.0
	mesh_instance.material_override = material
	wall_body.add_child(mesh_instance)
	_boundary_root.add_child(wall_body)


func _rebuild_terrain_local() -> void:
	if _terrain_root == null:
		return
	for child in _terrain_root.get_children():
		child.queue_free()
	_terrain_body = null
	if _sample_rows.is_empty():
		return
	_build_terrain_mesh()


func _rebuild_build_zone_local() -> void:
	_clear_build_zone_local()
	if _build_zone.is_empty() or _build_zone_root == null:
		return
	var center: Vector3 = _build_zone.get("center", world_center)
	var build_radius := float(_build_zone.get("build_radius", 8.0))
	var spawn_min_radius := float(_build_zone.get("spawn_min_radius", build_radius + 2.0))
	var spawn_max_radius := float(_build_zone.get("spawn_max_radius", spawn_min_radius + 2.0))
	var foundation_height := float(_build_zone.get("foundation_height", world_center.y))
	var platform_body := StaticBody3D.new()
	platform_body.name = "BuildZonePlatformBody"
	platform_body.position = Vector3(center.x, foundation_height - build_zone_surface_thickness * 0.5, center.z)
	var platform_collision := CollisionShape3D.new()
	platform_collision.name = "PlatformCollision"
	var platform_shape := BoxShape3D.new()
	platform_shape.size = Vector3(spawn_max_radius * 2.0, build_zone_surface_thickness, spawn_max_radius * 2.0)
	platform_collision.shape = platform_shape
	platform_body.add_child(platform_collision)
	_build_zone_root.add_child(platform_body)
	var platform_root := Node3D.new()
	platform_root.name = "BuildZonePlatform"
	platform_root.position = Vector3(center.x, foundation_height + build_zone_visual_offset, center.z)
	_build_zone_root.add_child(platform_root)
	_create_square_panel(platform_root, "PlatformTop", Vector2(spawn_max_radius * 2.0, spawn_max_radius * 2.0), 0.0, Color(0.42, 0.48, 0.38, 0.84))
	_create_square_ring(platform_root, "SpawnRing", spawn_min_radius, spawn_max_radius, build_zone_surface_thickness * 0.18, Color(0.74, 0.38, 0.28, 0.28))
	_create_square_panel(platform_root, "BuildArea", Vector2(build_radius * 2.0, build_radius * 2.0), build_zone_surface_thickness * 0.3, Color(0.22, 0.74, 0.84, 0.2))
	_create_square_outline(platform_root, "BuildOutline", build_radius, 0.22, build_zone_surface_thickness * 0.42, Color(0.2, 0.9, 0.98, 0.78))
	_create_square_outline(platform_root, "SpawnOutline", spawn_max_radius, 0.16, build_zone_surface_thickness * 0.48, Color(0.92, 0.54, 0.34, 0.44))


func _clear_build_zone_local() -> void:
	if _build_zone_root == null:
		return
	for child in _build_zone_root.get_children():
		child.queue_free()


func _set_gate_floor_active(active: bool) -> void:
	if gate_floor == null:
		return
	for child in gate_floor.get_children():
		if child is MeshInstance3D:
			child.visible = active
		elif child is CollisionShape3D:
			child.disabled = not active


func _average_height_around(center: Vector3, sample_radius: float) -> float:
	return _average_height_for_rows(_sample_rows, center, sample_radius)


func _average_height_for_rows(rows: Array, center: Vector3, sample_radius: float) -> float:
	var total := _sample_height_from_rows(rows, center)
	var count := 1.0
	for step in range(8):
		var angle := float(step) * TAU / 8.0
		var position := center + Vector3(cos(angle), 0.0, sin(angle)) * sample_radius * 0.7
		total += _sample_height_from_rows(rows, position)
		count += 1.0
	return total / count


func _vertex_at(x_index: int, z_index: int) -> Vector3:
	var x := world_center.x - world_width * 0.5 + float(x_index) * _cell_size_x
	var z := world_center.z - world_length * 0.5 + float(z_index) * _cell_size_z
	return Vector3(x, _height_from_grid(x_index, z_index), z)


func _height_from_grid(x_index: int, z_index: int) -> float:
	return _height_from_rows(_sample_rows, x_index, z_index)


func _height_from_rows(rows: Array, x_index: int, z_index: int) -> float:
	if rows.is_empty():
		return world_center.y
	var row: PackedFloat32Array = rows[z_index]
	return row[x_index]


func _duplicate_height_rows(source_rows: Array) -> Array:
	var duplicate_rows: Array = []
	for row_variant in source_rows:
		var source_row: PackedFloat32Array = row_variant
		duplicate_rows.append(source_row.duplicate())
	return duplicate_rows


func _restore_base_heightmap() -> void:
	if _base_sample_rows.is_empty():
		_sample_rows.clear()
		return
	_sample_rows = _duplicate_height_rows(_base_sample_rows)


func _apply_build_zone_to_heightmap() -> void:
	if _base_sample_rows.is_empty():
		return
	_restore_base_heightmap()
	if _build_zone.is_empty():
		return
	var center: Vector3 = _build_zone.get("center", world_center)
	var build_radius := float(_build_zone.get("build_radius", 0.0))
	var platform_half_extent := float(_build_zone.get("platform_half_extent", float(_build_zone.get("spawn_max_radius", build_radius))))
	var flatten_radius = max(float(_build_zone.get("slope_half_extent", _build_zone.get("flatten_radius", platform_half_extent))), platform_half_extent)
	var foundation_height := float(_build_zone.get("foundation_height", world_center.y))
	var transition_width = max(flatten_radius - platform_half_extent, 0.001)
	for z_index in range(_sample_count_z):
		var row: PackedFloat32Array = _sample_rows[z_index]
		for x_index in range(_sample_count_x):
			var world_x := world_center.x - world_width * 0.5 + float(x_index) * _cell_size_x
			var world_z := world_center.z - world_length * 0.5 + float(z_index) * _cell_size_z
			var distance = max(absf(world_x - center.x), absf(world_z - center.z))
			if distance > flatten_radius:
				continue
			if distance <= platform_half_extent:
				row[x_index] = foundation_height
				continue
			var base_height := _height_from_rows(_base_sample_rows, x_index, z_index)
			var ratio = clamp((distance - platform_half_extent) / transition_width, 0.0, 1.0)
			var eased_ratio = ratio * ratio * (3.0 - 2.0 * ratio)
			row[x_index] = lerpf(foundation_height, base_height, eased_ratio)


func _is_inside_square_extent(center: Vector3, world_position: Vector3, half_extent: float) -> bool:
	return absf(world_position.x - center.x) <= half_extent and absf(world_position.z - center.z) <= half_extent


func _square_ring_local_position(min_half_extent: float, max_half_extent: float, side_index: int, depth_ratio: float, edge_ratio: float) -> Vector3:
	var depth = lerpf(min_half_extent, max_half_extent, clamp(depth_ratio, 0.0, 1.0))
	var edge = lerpf(-max_half_extent, max_half_extent, clamp(edge_ratio, 0.0, 1.0))
	match posmod(side_index, 4):
		0:
			return Vector3(edge, 0.0, -depth)
		1:
			return Vector3(depth, 0.0, edge)
		2:
			return Vector3(edge, 0.0, depth)
		_:
			return Vector3(-depth, 0.0, edge)


func _create_square_panel(parent: Node3D, node_name: String, panel_size: Vector2, y_offset: float, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = Vector3(0.0, y_offset, 0.0)
	var panel_mesh := BoxMesh.new()
	panel_mesh.size = Vector3(panel_size.x, max(build_zone_surface_thickness * 0.18, 0.04), panel_size.y)
	mesh_instance.mesh = panel_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)


func _create_square_ring(parent: Node3D, node_name: String, inner_half_extent: float, outer_half_extent: float, y_offset: float, color: Color) -> void:
	var ring_root := Node3D.new()
	ring_root.name = node_name
	parent.add_child(ring_root)
	var band_width = max(outer_half_extent - inner_half_extent, 0.2)
	_create_square_panel(ring_root, "North", Vector2(outer_half_extent * 2.0, band_width), y_offset, color)
	ring_root.get_node("North").position.z = -(inner_half_extent + outer_half_extent) * 0.5
	_create_square_panel(ring_root, "South", Vector2(outer_half_extent * 2.0, band_width), y_offset, color)
	ring_root.get_node("South").position.z = (inner_half_extent + outer_half_extent) * 0.5
	_create_square_panel(ring_root, "East", Vector2(band_width, inner_half_extent * 2.0), y_offset, color)
	ring_root.get_node("East").position.x = (inner_half_extent + outer_half_extent) * 0.5
	_create_square_panel(ring_root, "West", Vector2(band_width, inner_half_extent * 2.0), y_offset, color)
	ring_root.get_node("West").position.x = -(inner_half_extent + outer_half_extent) * 0.5


func _create_square_outline(parent: Node3D, node_name: String, half_extent: float, line_width: float, y_offset: float, color: Color) -> void:
	var outline_root := Node3D.new()
	outline_root.name = node_name
	parent.add_child(outline_root)
	_create_square_panel(outline_root, "North", Vector2(half_extent * 2.0 + line_width * 2.0, line_width), y_offset, color)
	outline_root.get_node("North").position.z = -half_extent
	_create_square_panel(outline_root, "South", Vector2(half_extent * 2.0 + line_width * 2.0, line_width), y_offset, color)
	outline_root.get_node("South").position.z = half_extent
	_create_square_panel(outline_root, "East", Vector2(line_width, half_extent * 2.0), y_offset, color)
	outline_root.get_node("East").position.x = half_extent
	_create_square_panel(outline_root, "West", Vector2(line_width, half_extent * 2.0), y_offset, color)
	outline_root.get_node("West").position.x = -half_extent


@rpc("authority", "call_remote", "reliable")
func _sync_world_state(active: bool, seed_value: int) -> void:
	if multiplayer.is_server():
		return
	if not active:
		_world_active = false
		_current_seed = 0
		_clear_build_zone_local()
		_clear_world_local()
		_set_gate_floor_active(true)
		return
	_world_active = true
	_current_seed = seed_value
	_rebuild_world_local()
	_set_gate_floor_active(false)
	world_generated.emit()


@rpc("authority", "call_remote", "reliable")
func _sync_build_zone_state(active: bool, build_zone_state: Dictionary) -> void:
	if multiplayer.is_server():
		return
	if not active:
		_build_zone = {}
		_restore_base_heightmap()
		_rebuild_terrain_local()
		_clear_build_zone_local()
		build_zone_changed.emit()
		return
	_build_zone = build_zone_state.duplicate(true)
	_apply_build_zone_to_heightmap()
	_rebuild_terrain_local()
	_rebuild_build_zone_local()
	build_zone_changed.emit()
