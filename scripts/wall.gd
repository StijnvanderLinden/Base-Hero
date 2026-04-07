extends StaticBody3D

@export var max_health: float = 180.0
@export var hit_flash_duration: float = 0.12

var wall_id: int = 0
var spawn_position: Vector3 = Vector3.ZERO
var spawn_rotation_y: float = 0.0
var current_health: float = 180.0
var wall_manager: Node
var _hit_flash_time_remaining: float = 0.0
var _base_color: Color = Color(0.74, 0.75, 0.8)
var _damaged_color: Color = Color(0.95, 0.56, 0.42)
var _inactive_color: Color = Color(0.35, 0.37, 0.42)
var _defense_active: bool = true

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var label: Label3D = $Label3D


func setup(new_wall_id: int, start_position: Vector3, start_rotation_y: float, start_health: float = -1.0) -> void:
	wall_id = new_wall_id
	spawn_position = start_position
	spawn_rotation_y = start_rotation_y
	current_health = max_health if start_health < 0.0 else start_health
	name = "Wall_%d" % wall_id


func set_manager(manager: Node) -> void:
	wall_manager = manager


func _ready() -> void:
	add_to_group("structures")
	add_to_group("blocking_structures")
	add_to_group("defense_structures")
	global_position = spawn_position
	rotation.y = spawn_rotation_y
	_update_label()
	_apply_wall_color()


func _process(delta: float) -> void:
	if _hit_flash_time_remaining <= 0.0:
		return
	_hit_flash_time_remaining = max(_hit_flash_time_remaining - delta, 0.0)
	_update_body_visuals()


func get_wall_id() -> int:
	return wall_id


func get_structure_kind() -> String:
	return "wall"


func get_structure_id() -> int:
	return wall_id


func get_current_health() -> float:
	return current_health


func can_be_repaired() -> bool:
	return current_health > 0.0 and current_health < max_health


func get_spawn_rotation_y() -> float:
	return spawn_rotation_y


func get_hit_radius() -> float:
	return 1.35


func can_be_targeted() -> bool:
	return current_health > 0.0 and _defense_active


func set_defense_active(active: bool) -> void:
	_defense_active = active
	if collision_shape != null:
		collision_shape.disabled = not active or current_health <= 0.0
	_update_label()
	_update_body_visuals()


func is_defense_active() -> bool:
	return _defense_active


func apply_server_damage(amount: float) -> void:
	if not multiplayer.is_server():
		return
	if amount <= 0.0 or current_health <= 0.0:
		return

	current_health = max(current_health - amount, 0.0)
	_sync_health.rpc(current_health)
	_update_label()
	_start_hit_flash()
	_play_hit_feedback.rpc()
	if current_health <= 0.0 and wall_manager != null and wall_manager.has_method("despawn_wall_for_all"):
		wall_manager.despawn_wall_for_all(wall_id)


func apply_server_repair(amount: float) -> float:
	if not multiplayer.is_server():
		return 0.0
	if amount <= 0.0 or current_health <= 0.0 or current_health >= max_health:
		return 0.0
	var previous_health := current_health
	current_health = min(current_health + amount, max_health)
	_sync_health.rpc(current_health)
	_update_label()
	_start_hit_flash()
	_play_hit_feedback.rpc()
	return current_health - previous_health


func _apply_wall_color() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = _base_color
	body_mesh.material_override = material
	_update_body_visuals()


func _update_label() -> void:
	if current_health <= 0.0:
		label.text = "Wall Destroyed"
		return
	if not _defense_active:
		label.text = "Wall Offline"
		return
	if can_be_repaired():
		var repair_cost := _repair_cost()
		if repair_cost > 0:
			label.text = "Wall HP:%d | E Repair (%d)" % [int(round(current_health)), repair_cost]
			return
		label.text = "Wall HP:%d | E Repair" % int(round(current_health))
		return
	label.text = "Wall HP:%d" % int(round(current_health))


func _start_hit_flash() -> void:
	_hit_flash_time_remaining = hit_flash_duration
	_update_body_visuals()


func _update_body_visuals() -> void:
	if body_mesh.material_override == null:
		return
	var material := body_mesh.material_override as StandardMaterial3D
	if material == null:
		return
	if _hit_flash_time_remaining > 0.0:
		material.albedo_color = Color(1.0, 1.0, 1.0)
		return
	if not _defense_active:
		material.albedo_color = _inactive_color
		return
	var health_ratio = clamp(current_health / max(max_health, 0.001), 0.0, 1.0)
	material.albedo_color = _damaged_color.lerp(_base_color, health_ratio)


func _repair_cost() -> int:
	if wall_manager == null or not wall_manager.has_method("get_repair_cost_for_type"):
		return 0
	return int(wall_manager.get_repair_cost_for_type("wall"))


@rpc("authority", "call_remote", "reliable")
func _sync_health(server_health: float) -> void:
	if multiplayer.is_server():
		return
	current_health = server_health
	_update_label()


@rpc("authority", "call_remote", "reliable")
func _play_hit_feedback() -> void:
	if multiplayer.is_server():
		return
	_start_hit_flash()
