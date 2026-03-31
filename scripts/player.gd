extends CharacterBody3D

@export var move_speed: float = 6.0
@export var gravity: float = 24.0
@export var max_health: float = 100.0
@export var attack_range: float = 2.4
@export var attack_damage: float = 34.0
@export var attack_cooldown: float = 0.45

var peer_id: int = 1
var spawn_position: Vector3 = Vector3.ZERO
var _input_vector: Vector2 = Vector2.ZERO
var current_health: float = 100.0
var _attack_cooldown_remaining: float = 0.0
var _attack_was_pressed: bool = false

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var label: Label3D = $Label3D
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
	_update_health_bar()
	camera.current = _is_local_player()
	_apply_player_color()


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
	material.albedo_color = Color.from_hsv(hue, 0.75, 0.95)
	body_mesh.material_override = material


func apply_server_damage(amount: float) -> void:
	if not multiplayer.is_server():
		return
	if amount <= 0.0:
		return

	current_health = max(current_health - amount, 0.0)
	_sync_health.rpc(current_health)
	_update_label()
	_update_health_bar()
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
