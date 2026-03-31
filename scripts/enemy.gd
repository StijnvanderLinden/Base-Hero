extends CharacterBody3D

@export var move_speed: float = 3.5
@export var gravity: float = 24.0
@export var attack_range: float = 1.35
@export var damage_per_second: float = 18.0
@export var max_health: float = 60.0
@export var body_radius: float = 0.4

var enemy_id: int = 0
var spawn_position: Vector3 = Vector3.ZERO
var current_health: float = 60.0
var enemy_manager: Node

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var label: Label3D = $Label3D
@onready var health_bar_fill: MeshInstance3D = $HealthBar/Fill


func setup(new_enemy_id: int, start_position: Vector3, start_health: float = -1.0) -> void:
	enemy_id = new_enemy_id
	spawn_position = start_position
	current_health = max_health if start_health < 0.0 else start_health
	name = "Enemy_%d" % enemy_id


func set_manager(manager: Node) -> void:
	enemy_manager = manager


func _ready() -> void:
	add_to_group("enemies")
	global_position = spawn_position
	_update_label()
	_update_health_bar()
	_apply_enemy_color()


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return

	var objective = _current_objective()
	if objective == null:
		velocity = Vector3.ZERO
		_sync_state.rpc(global_position, velocity, rotation.y)
		return

	var to_target: Vector3 = objective.global_position - global_position
	var planar: Vector3 = Vector3(to_target.x, 0.0, to_target.z)
	if planar.length_squared() > 0.001:
		var direction := planar.normalized()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		rotation.y = atan2(direction.x, direction.z)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()

	var attack_target = _current_attack_target(objective)
	if attack_target != null and attack_target.has_method("apply_server_damage") and _is_target_in_attack_range(attack_target):
		attack_target.apply_server_damage(damage_per_second * delta)

	_sync_state.rpc(global_position, velocity, rotation.y)


func get_enemy_id() -> int:
	return enemy_id


func get_current_health() -> float:
	return current_health


func is_alive() -> bool:
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
	if current_health <= 0.0 and enemy_manager != null and enemy_manager.has_method("despawn_enemy_for_all"):
		enemy_manager.despawn_enemy_for_all(enemy_id)


func _current_objective() -> Node3D:
	var objectives = get_tree().get_nodes_in_group("primary_objective")
	if objectives.is_empty():
		return null

	var objective = objectives[0]
	if objective.has_method("can_be_targeted") and not objective.can_be_targeted():
		return null
	if objective is Node3D:
		return objective
	return null


func _current_attack_target(objective: Node3D) -> Node3D:
	var player_target = _nearest_player_in_attack_range()
	if player_target != null:
		return player_target
	if _is_target_in_attack_range(objective):
		return objective
	return null


func _nearest_player_in_attack_range() -> CharacterBody3D:
	var best_player: CharacterBody3D = null
	var best_distance := INF
	for node in get_tree().get_nodes_in_group("players"):
		if not node is CharacterBody3D:
			continue
		if node.has_method("can_be_targeted") and not node.can_be_targeted():
			continue
		if not _is_target_in_attack_range(node):
			continue
		var distance := global_position.distance_squared_to(node.global_position)
		if distance < best_distance:
			best_distance = distance
			best_player = node
	return best_player


func _is_target_in_attack_range(target: Node3D) -> bool:
	if target == null:
		return false
	var enemy_planar = Vector2(global_position.x, global_position.z)
	var target_planar = Vector2(target.global_position.x, target.global_position.z)
	var target_radius := _target_hit_radius(target)
	return enemy_planar.distance_to(target_planar) <= attack_range + body_radius + target_radius


func _target_hit_radius(target: Node3D) -> float:
	if target.has_method("get_hit_radius"):
		return target.get_hit_radius()
	return 0.5


func _apply_enemy_color() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.93, 0.34, 0.27)
	body_mesh.material_override = material


func _update_label() -> void:
	label.text = "E%d HP:%d" % [enemy_id, int(round(current_health))]


func _update_health_bar() -> void:
	var health_ratio = clamp(current_health / max_health, 0.0, 1.0)
	health_bar_fill.scale.x = max(health_ratio, 0.001)
	health_bar_fill.position.x = (health_ratio - 1.0) * 0.5


@rpc("authority", "call_remote", "unreliable_ordered")
func _sync_state(server_position: Vector3, server_velocity: Vector3, facing_y: float) -> void:
	if multiplayer.is_server():
		return
	global_position = server_position
	velocity = server_velocity
	rotation.y = facing_y


@rpc("authority", "call_remote", "reliable")
func _sync_health(server_health: float) -> void:
	if multiplayer.is_server():
		return
	current_health = server_health
	_update_label()
	_update_health_bar()
