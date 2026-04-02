extends StaticBody3D

@export var max_health: float = 120.0
@export var attack_range: float = 8.0
@export var attack_damage: float = 16.0
@export var attack_cooldown: float = 0.4
@export var projectile_speed: float = 15.0
@export var projectile_lifetime: float = 1.2
@export var projectile_hit_radius: float = 0.22
@export var hit_flash_duration: float = 0.12

var turret_id: int = 0
var spawn_position: Vector3 = Vector3.ZERO
var spawn_rotation_y: float = 0.0
var current_health: float = 120.0
var turret_manager: Node
var projectiles_root: Node3D
var projectile_scene: PackedScene
var _attack_cooldown_remaining: float = 0.0
var _hit_flash_time_remaining: float = 0.0
var _base_color: Color = Color(0.89, 0.78, 0.31)
var _health_bar_local_offset: Vector3 = Vector3.ZERO
var _health_bar_width: float = 1.0
var _next_bullet_id: int = 1

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var label: Label3D = $Label3D
@onready var health_bar_root: Node3D = $HealthBar
@onready var health_bar_fill: MeshInstance3D = $HealthBar/Fill


func setup(new_turret_id: int, start_position: Vector3, start_rotation_y: float, start_health: float = -1.0) -> void:
	turret_id = new_turret_id
	spawn_position = start_position
	spawn_rotation_y = start_rotation_y
	current_health = max_health if start_health < 0.0 else start_health
	name = "Turret_%d" % turret_id


func set_manager(manager: Node) -> void:
	turret_manager = manager


func configure_projectiles(new_projectiles_root: Node3D, new_projectile_scene: PackedScene) -> void:
	projectiles_root = new_projectiles_root
	projectile_scene = new_projectile_scene


func _ready() -> void:
	add_to_group("structures")
	add_to_group("blocking_structures")
	add_to_group("defense_structures")
	global_position = spawn_position
	rotation.y = spawn_rotation_y
	_health_bar_local_offset = health_bar_root.position
	health_bar_root.top_level = true
	_update_health_bar_anchor()
	_update_label()
	_update_health_bar()
	_apply_turret_color()


func _process(delta: float) -> void:
	_update_health_bar_anchor()
	if _hit_flash_time_remaining <= 0.0:
		return
	_hit_flash_time_remaining = max(_hit_flash_time_remaining - delta, 0.0)
	_update_body_visuals()


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	if current_health <= 0.0:
		return

	_attack_cooldown_remaining = max(_attack_cooldown_remaining - delta, 0.0)
	var target := _nearest_enemy_in_range()
	if target == null:
		_sync_state.rpc(rotation.y)
		return

	var to_target := target.global_position - global_position
	var planar := Vector3(to_target.x, 0.0, to_target.z)
	if planar.length_squared() > 0.001:
		rotation.y = atan2(planar.x, planar.z)

	if _attack_cooldown_remaining <= 0.0:
		_attack_cooldown_remaining = attack_cooldown
		_fire_bullet(target)

	_sync_state.rpc(rotation.y)


func get_structure_kind() -> String:
	return "turret"


func get_structure_id() -> int:
	return turret_id


func get_current_health() -> float:
	return current_health


func get_spawn_rotation_y() -> float:
	return spawn_rotation_y


func get_hit_radius() -> float:
	return 0.85


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
	if current_health <= 0.0 and turret_manager != null and turret_manager.has_method("despawn_turret_for_all"):
		turret_manager.despawn_turret_for_all(turret_id)


func notify_bullet_finished(bullet_id: int) -> void:
	if not multiplayer.is_server():
		return
	_remove_bullet_local(bullet_id)
	_remove_bullet_remote.rpc(bullet_id)


func _nearest_enemy_in_range() -> CharacterBody3D:
	var best_enemy: CharacterBody3D = null
	var best_distance := attack_range * attack_range
	for node in get_tree().get_nodes_in_group("enemies"):
		if not node is CharacterBody3D:
			continue
		if node.has_method("is_alive") and not node.is_alive():
			continue
		var distance := global_position.distance_squared_to(node.global_position)
		if distance <= best_distance:
			best_distance = distance
			best_enemy = node
	return best_enemy


func _fire_bullet(target: CharacterBody3D) -> void:
	if projectile_scene == null or projectiles_root == null or target == null:
		return

	var spawn_position := global_position + Vector3(0.0, 1.05, 0.0)
	var target_position := target.global_position + Vector3(0.0, 0.9, 0.0)
	var direction := (target_position - spawn_position).normalized()
	if direction.length_squared() <= 0.001:
		return

	var bullet_id := _next_bullet_id
	_next_bullet_id += 1
	_spawn_bullet_local(bullet_id, spawn_position, direction, true)
	_spawn_bullet_remote.rpc(bullet_id, spawn_position, direction)


func _spawn_bullet_local(bullet_id: int, start_position: Vector3, direction: Vector3, is_authoritative: bool) -> void:
	if projectile_scene == null or projectiles_root == null:
		return
	var node_name := _bullet_name(bullet_id)
	if projectiles_root.has_node(node_name):
		return
	var bullet = projectile_scene.instantiate()
	bullet.name = node_name
	if bullet.has_method("setup"):
		bullet.setup(
			bullet_id,
			start_position,
			direction,
			attack_damage,
			projectile_speed,
			projectile_lifetime,
			projectile_hit_radius,
			is_authoritative,
			self
		)
	projectiles_root.add_child(bullet)


func _remove_bullet_local(bullet_id: int) -> void:
	if projectiles_root == null:
		return
	var node_name := _bullet_name(bullet_id)
	if not projectiles_root.has_node(node_name):
		return
	projectiles_root.get_node(node_name).queue_free()


func _bullet_name(bullet_id: int) -> String:
	return "TurretBullet_%d_%d" % [turret_id, bullet_id]


func _apply_turret_color() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = _base_color
	body_mesh.material_override = material
	_update_body_visuals()


func _update_label() -> void:
	label.text = "Turret HP:%d" % int(round(current_health))


func _update_health_bar() -> void:
	var health_ratio = clamp(current_health / max_health, 0.0, 1.0)
	health_bar_fill.scale.x = max(health_ratio, 0.001)
	health_bar_fill.position.x = (_health_bar_width * (health_ratio - 1.0)) * 0.5


func _update_health_bar_anchor() -> void:
	var current_transform := health_bar_root.global_transform
	current_transform.origin = global_position + _health_bar_local_offset
	var active_camera := get_viewport().get_camera_3d()
	if active_camera != null:
		current_transform.basis = active_camera.global_transform.basis
	health_bar_root.global_transform = current_transform


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


@rpc("authority", "call_remote", "unreliable_ordered")
func _sync_state(facing_y: float) -> void:
	if multiplayer.is_server():
		return
	rotation.y = facing_y


@rpc("authority", "call_remote", "reliable")
func _spawn_bullet_remote(bullet_id: int, start_position: Vector3, direction: Vector3) -> void:
	if multiplayer.is_server():
		return
	_spawn_bullet_local(bullet_id, start_position, direction, false)


@rpc("authority", "call_remote", "reliable")
func _remove_bullet_remote(bullet_id: int) -> void:
	if multiplayer.is_server():
		return
	_remove_bullet_local(bullet_id)


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