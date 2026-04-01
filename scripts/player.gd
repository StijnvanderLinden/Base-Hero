extends CharacterBody3D

@export var move_speed: float = 6.0
@export var gravity: float = 24.0
@export var max_health: float = 100.0
@export var attack_range: float = 2.4
@export var attack_damage: float = 34.0
@export var attack_cooldown: float = 0.45
@export var hit_flash_duration: float = 0.12

var peer_id: int = 1
var spawn_position: Vector3 = Vector3.ZERO
var _input_vector: Vector2 = Vector2.ZERO
var current_health: float = 100.0
var _attack_cooldown_remaining: float = 0.0
var _attack_was_pressed: bool = false
var _hit_flash_time_remaining: float = 0.0
var _base_color: Color = Color.WHITE
var _health_bar_local_offset: Vector3 = Vector3.ZERO

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var label: Label3D = $Label3D
@onready var health_bar_root: Node3D = $HealthBar
@onready var health_bar_fill: MeshInstance3D = $HealthBar/Fill


func setup(player_peer_id: int, start_position: Vector3) -> void:
	peer_id = player_peer_id
	spawn_position = start_position
	name = "Player_%d" % peer_id


func _ready() -> void:
	add_to_group("players")
	global_position = spawn_position
	current_health = max_health
	_update_label()
	_health_bar_local_offset = health_bar_root.position
	health_bar_root.top_level = true
	_update_health_bar_anchor()
	_update_health_bar()
	if _is_local_player():
		camera_pivot.top_level = true
		camera.current = true
		_update_camera_anchor()
	else:
		camera.current = false
	_apply_player_color()


func _process(delta: float) -> void:
	_update_health_bar_anchor()

	if _is_local_player():
		_update_camera_anchor()

	if _hit_flash_time_remaining <= 0.0:
		return
	_hit_flash_time_remaining = max(_hit_flash_time_remaining - delta, 0.0)
	_update_body_visuals()


func _physics_process(delta: float) -> void:
	_attack_cooldown_remaining = max(_attack_cooldown_remaining - delta, 0.0)
	var attack_pressed := _consume_attack_pressed()

	if multiplayer.is_server():
		if _is_local_player():
			_input_vector = _read_input_vector()
			if attack_pressed:
				_perform_server_attack()
		_simulate_movement(delta)
		_sync_state.rpc(global_position, velocity, rotation.y)
		return

	if _is_local_player():
		_submit_input.rpc_id(1, _read_input_vector())
		if attack_pressed:
			_request_attack.rpc_id(1)


func _simulate_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var direction := Vector3(_input_vector.x, 0.0, _input_vector.y)
	if direction.length_squared() > 1.0:
		direction = direction.normalized()

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	if direction.length_squared() > 0.001:
		rotation.y = atan2(direction.x, direction.z)

	move_and_slide()


func _read_input_vector() -> Vector2:
	var input := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input.y += 1.0
	return input.normalized()


func _consume_attack_pressed() -> bool:
	var is_pressed := Input.is_key_pressed(KEY_SPACE)
	var just_pressed := is_pressed and not _attack_was_pressed
	_attack_was_pressed = is_pressed
	return just_pressed


func _is_local_player() -> bool:
	return multiplayer.get_unique_id() == peer_id


func can_be_targeted() -> bool:
	return current_health > 0.0


func get_hit_radius() -> float:
	return 0.75


func _apply_player_color() -> void:
	var material := StandardMaterial3D.new()
	var hue := float((peer_id * 57) % 360) / 360.0
	_base_color = Color.from_hsv(hue, 0.75, 0.95)
	material.albedo_color = _base_color
	body_mesh.material_override = material
	_update_body_visuals()


func apply_server_damage(amount: float) -> void:
	if not multiplayer.is_server():
		return
	if amount <= 0.0:
		return

	current_health = max(current_health - amount, 0.0)
	_sync_health.rpc(current_health)
	_update_label()
	_update_health_bar()
	_start_hit_flash()
	_play_hit_feedback.rpc()
	if current_health <= 0.0:
		_server_respawn()


func _server_respawn() -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	current_health = max_health
	_sync_state.rpc(global_position, velocity, rotation.y)
	_sync_health.rpc(current_health)
	_update_label()
	_update_health_bar()


func _update_label() -> void:
	label.text = "P%d HP:%d" % [peer_id, int(round(current_health))]


func _update_health_bar() -> void:
	var health_ratio = clamp(current_health / max_health, 0.0, 1.0)
	health_bar_fill.scale.x = max(health_ratio, 0.001)
	health_bar_fill.position.x = (health_ratio - 1.0) * 0.5


func _update_health_bar_anchor() -> void:
	health_bar_root.global_position = global_position + _health_bar_local_offset
	health_bar_root.global_rotation = Vector3.ZERO


func _update_camera_anchor() -> void:
	camera_pivot.global_position = global_position + Vector3(0.0, 1.5, 0.0)
	camera_pivot.global_rotation = Vector3.ZERO


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


func _perform_server_attack() -> void:
	if not multiplayer.is_server():
		return
	if _attack_cooldown_remaining > 0.0:
		return

	_attack_cooldown_remaining = attack_cooldown
	var target = _nearest_enemy_in_range()
	if target == null:
		return
	if target.has_method("apply_server_damage"):
		target.apply_server_damage(attack_damage)


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


@rpc("any_peer", "call_remote", "unreliable_ordered")
func _submit_input(new_input: Vector2) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_input_vector = new_input


@rpc("any_peer", "call_remote", "reliable")
func _request_attack() -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_perform_server_attack()


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


@rpc("authority", "call_remote", "reliable")
func _play_hit_feedback() -> void:
	if multiplayer.is_server():
		return
	_start_hit_flash()
