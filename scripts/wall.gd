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
var _health_bar_local_offset: Vector3 = Vector3.ZERO

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var label: Label3D = $Label3D
@onready var health_bar_root: Node3D = $HealthBar
@onready var health_bar_fill: MeshInstance3D = $HealthBar/Fill


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
	global_position = spawn_position
	rotation.y = spawn_rotation_y
	_health_bar_local_offset = health_bar_root.position
	health_bar_root.top_level = true
	_update_health_bar_anchor()
	_update_label()
	_update_health_bar()
	_apply_wall_color()


func _process(delta: float) -> void:
	_update_health_bar_anchor()
	if _hit_flash_time_remaining <= 0.0:
		return
	_hit_flash_time_remaining = max(_hit_flash_time_remaining - delta, 0.0)
	_update_body_visuals()


func get_wall_id() -> int:
	return wall_id


func get_current_health() -> float:
	return current_health


func get_spawn_rotation_y() -> float:
	return spawn_rotation_y


func get_hit_radius() -> float:
	return 0.95


func can_be_targeted() -> bool:
	return current_health > 0.0


func apply_server_damage(amount: float) -> void:
	if not multiplayer.is_server():
		return
	if amount <= 0.0 or current_health <= 0.0:
		return

	current_health = max(current_health - amount, 0.0)
	_sync_health.rpc(current_health)
	_update_label()
	_update_health_bar()
	_start_hit_flash()
	_play_hit_feedback.rpc()
	if current_health <= 0.0 and wall_manager != null and wall_manager.has_method("despawn_wall_for_all"):
		wall_manager.despawn_wall_for_all(wall_id)


func _apply_wall_color() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = _base_color
	body_mesh.material_override = material
	_update_body_visuals()


func _update_label() -> void:
	label.text = "Wall HP:%d" % int(round(current_health))


func _update_health_bar() -> void:
	var health_ratio = clamp(current_health / max_health, 0.0, 1.0)
	health_bar_fill.scale.x = max(health_ratio, 0.001)
	health_bar_fill.position.x = (health_ratio - 1.0) * 0.5


func _update_health_bar_anchor() -> void:
	health_bar_root.global_position = global_position + _health_bar_local_offset
	health_bar_root.global_rotation = Vector3.ZERO


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
	material.albedo_color = _base_color


@rpc("authority", "call_remote", "reliable")
func _sync_health(server_health: float) -> void:
	if multiplayer.is_server():
		return
	current_health = server_health
	_update_label()
	_update_health_bar()


@rpc("authority", "call_remote", "reliable")
func _play_hit_feedback() -> void:
	if multiplayer.is_server():
		return
	_start_hit_flash()
