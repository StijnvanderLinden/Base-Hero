extends CharacterBody3D

const PLAYER_PROJECTILE_SCENE := preload("res://scenes/player_projectile.tscn")

# How fast the player moves in meters per second.
@export var speed: float = 6.0
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration: float = 24.0
@export var jump_velocity: float = 9.5
@export var mouse_sensitivity: float = 0.0035
@export var min_camera_pitch_degrees: float = -70.0
@export var max_camera_pitch_degrees: float = 50.0
@export var min_camera_distance: float = 2.5
@export var max_camera_distance: float = 8.0
@export var camera_zoom_step: float = 0.5
@export var camera_follow_smoothing: float = 16.0
@export var remote_position_smoothing: float = 14.0
@export var remote_rotation_smoothing: float = 18.0
@export var remote_snap_distance: float = 3.5
@export var max_health: float = 100.0
@export var attack_range: float = 18.0
@export var attack_damage: float = 22.0
@export var attack_cooldown: float = 0.18
@export var projectile_speed: float = 28.0
@export var projectile_hit_radius: float = 0.2
@export var projectile_spawn_forward_offset: float = 0.9
@export var projectile_spawn_height: float = 1.05
@export var attack_visual_duration: float = 0.08
@export var attack_visual_width: float = 0.18
@export var attack_visual_height: float = 0.18
@export var attack_visual_depth: float = 0.9
@export var hit_flash_duration: float = 0.12
var peer_id: int = 1
var spawn_position: Vector3 = Vector3.ZERO
var _input_vector: Vector2 = Vector2.ZERO
var target_velocity: Vector3 = Vector3.ZERO
var current_health: float = 100.0
var _attack_cooldown_remaining: float = 0.0
var _heavy_attack_cooldown_remaining: float = 0.0
var _attack_visual_time_remaining: float = 0.0
var _attack_was_pressed: bool = false
var _heavy_attack_was_pressed: bool = false
var _jump_was_pressed: bool = false
var _build_was_pressed: bool = false
var _interact_was_pressed: bool = false
var _select_wall_was_pressed: bool = false
var _select_turret_was_pressed: bool = false
var _rotate_build_was_pressed: bool = false
var _toggle_build_mode_was_pressed: bool = false
var _hit_flash_time_remaining: float = 0.0
var _base_color: Color = Color.WHITE
var _preview_valid_color: Color = Color(0.28, 0.95, 0.45, 0.45)
var _preview_invalid_color: Color = Color(0.95, 0.3, 0.25, 0.45)
var _preview_valid_text_color: Color = Color(0.72, 1.0, 0.78, 1.0)
var _preview_invalid_text_color: Color = Color(1.0, 0.76, 0.76, 1.0)
var _preview_reticle_valid_color: Color = Color(0.52, 1.0, 0.68, 0.72)
var _preview_reticle_invalid_color: Color = Color(1.0, 0.48, 0.44, 0.72)
var _current_build_type: String = "wall"
var _build_mode_active: bool = false
var _build_hold_active: bool = false
var _build_hold_type: String = "wall"
var _build_hold_anchor_position: Vector3 = Vector3.ZERO
var _build_hold_rotation_y: float = 0.0
var _build_hold_preview_positions: Array = []
var _build_hold_preview_valid: bool = false
var _build_rotation_steps: int = 0
var _wall_preview_mesh: BoxMesh
var _turret_preview_mesh: CylinderMesh
var _build_preview_extra_meshes: Array = []
var _channel_locked: bool = false
var _ui_locked: bool = false
var _camera_pitch: float = 0.0
var _build_reticle_root: Node3D
var _build_reticle_mesh: MeshInstance3D
var _build_reticle_material: StandardMaterial3D
var _current_build_target_position: Vector3 = Vector3.ZERO
var _current_build_preview_position: Vector3 = Vector3.ZERO
var _current_build_preview_rotation_y: float = 0.0
var _current_build_preview_valid: bool = false
var _has_current_build_preview: bool = false
var _wall_segment_active: bool = false
var _wall_segment_anchor_position: Vector3 = Vector3.ZERO
var _wall_segment_preview_positions: Array = []
var _wall_segment_preview_valid: bool = false
var _wall_segment_rotation_y: float = 0.0
var _build_drag_active: bool = false
var _build_drag_last_position: Vector3 = Vector3.ZERO
var _build_drag_axis: Vector3 = Vector3.ZERO
var _build_drag_direction_sign: int = 0
var _build_drag_preview_position: Vector3 = Vector3.ZERO
var _has_build_drag_preview_position: bool = false
var _network_target_position: Vector3 = Vector3.ZERO
var _network_target_velocity: Vector3 = Vector3.ZERO
var _network_target_facing_y: float = 0.0
var _has_network_target: bool = false
var _jump_requested: bool = false
var _next_projectile_id: int = 1
var _attack_visual_root: Node3D
var _attack_visual_mesh: MeshInstance3D
var _attack_visual_material: StandardMaterial3D
var _attack_visual_fire_color: Color = Color(0.52, 0.9, 1.0, 0.46)

@onready var look_pivot: Node3D = $LookPivot
@onready var visual_pivot: Node3D = $VisualPivot
@onready var body_mesh: MeshInstance3D = $VisualPivot/BodyMesh
@onready var camera_pivot: Node3D = $LookPivot/CameraPivot
@onready var spring_arm: SpringArm3D = $LookPivot/CameraPivot/SpringArm3D
@onready var camera: Camera3D = $LookPivot/CameraPivot/SpringArm3D/Camera3D
@onready var label: Label3D = $Label3D
@onready var build_preview_root: Node3D = $BuildPreview
@onready var build_preview_mesh: MeshInstance3D = $BuildPreview/PreviewMesh
@onready var build_preview_label: Label3D = $BuildPreview/PreviewLabel


func setup(player_peer_id: int, start_position: Vector3) -> void:
	peer_id = player_peer_id
	spawn_position = start_position
	name = "Player_%d" % peer_id


func _ready() -> void:
	add_to_group("players")
	global_position = spawn_position
	current_health = max_health
	_network_target_position = global_position
	_network_target_velocity = Vector3.ZERO
	_network_target_facing_y = look_pivot.rotation.y
	_has_network_target = false
	_camera_pitch = deg_to_rad(clamp(-25.0, min_camera_pitch_degrees, max_camera_pitch_degrees))
	_update_camera_pitch()
	spring_arm.spring_length = clamp(spring_arm.spring_length, min_camera_distance, max_camera_distance)
	_update_label()
	_sync_visual_orientation()
	_initialize_attack_visual()
	if _is_local_player():
		build_preview_root.top_level = true
		build_preview_root.visible = true
		_initialize_build_reticle()
		camera_pivot.top_level = true
		camera.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_initialize_preview_meshes()
		_update_camera_anchor(1.0)
		_update_build_preview()
	else:
		build_preview_root.visible = false
		camera.current = false
	_apply_player_color()
	_configure_build_preview_feedback()


func _process(delta: float) -> void:
	if _is_local_player():
		_update_camera_anchor(delta)
		_update_build_preview()
	elif not multiplayer.is_server():
		_update_remote_visual_state(delta)
	else:
		_sync_visual_orientation()

	if _hit_flash_time_remaining <= 0.0:
		_update_attack_visual(delta)
		return
	_hit_flash_time_remaining = max(_hit_flash_time_remaining - delta, 0.0)
	_update_body_visuals()
	_update_attack_visual(delta)


func _physics_process(delta: float) -> void:
	var movement_locked := _channel_locked
	var action_locked := _channel_locked or _ui_locked
	if _is_local_player() and not _ui_locked:
		_update_build_selection()

	_attack_cooldown_remaining = max(_attack_cooldown_remaining - delta, 0.0)
	_heavy_attack_cooldown_remaining = max(_heavy_attack_cooldown_remaining - delta, 0.0)
	var attack_pressed := _consume_attack_pressed()
	var heavy_attack_pressed := _consume_heavy_attack_pressed()
	var jump_pressed := _consume_jump_pressed()
	var build_held := _is_build_input_held()
	var build_pressed := build_held and not _build_was_pressed
	var build_released := not build_held and _build_was_pressed
	_build_was_pressed = build_held
	var interact_pressed := _consume_interact_pressed()

	if multiplayer.is_server():
		if _is_local_player():
			_input_vector = Vector2.ZERO if movement_locked else _read_input_vector()
			if jump_pressed and not movement_locked:
				_request_server_jump()
			if attack_pressed and not action_locked:
				_perform_server_attack()
			if heavy_attack_pressed and not action_locked:
				_perform_server_heavy_attack()
			if build_pressed and not action_locked and _build_mode_active:
				if _current_build_type == "wall":
					_handle_wall_segment_click_server()
				else:
					_begin_build_hold()
			if build_released and _build_hold_active:
				_confirm_build_hold_server()
			if interact_pressed and not action_locked:
				if _handle_local_ui_interaction():
					_simulate_movement(delta)
					_sync_state.rpc(global_position, velocity, look_pivot.rotation.y)
					return
				_perform_server_interact()
		_simulate_movement(delta)
		_sync_state.rpc(global_position, velocity, look_pivot.rotation.y)
		return

	if _is_local_player():
		var submitted_input := Vector2.ZERO if movement_locked else _read_input_vector()
		_submit_input.rpc_id(1, submitted_input, look_pivot.rotation.y)
		if jump_pressed and not movement_locked:
			_request_jump.rpc_id(1)
		if attack_pressed and not action_locked:
			_request_attack.rpc_id(1)
		if heavy_attack_pressed and not action_locked:
			_request_heavy_attack.rpc_id(1)
		if build_pressed and not action_locked and _build_mode_active:
			if _current_build_type == "wall":
				_handle_wall_segment_click_remote()
			else:
				_begin_build_hold()
		if build_released and _build_hold_active:
			_confirm_build_hold_remote()
		if interact_pressed and not action_locked:
			if _handle_local_ui_interaction():
				return
			_request_interact.rpc_id(1)


func _simulate_movement(delta: float) -> void:
	var direction := look_pivot.basis * Vector3(_input_vector.x, 0.0, _input_vector.y)
	direction.y = 0.0
	if _channel_locked:
		direction = Vector3.ZERO

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	var should_jump := _jump_requested and not _channel_locked
	_jump_requested = false

	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
	else:
		target_velocity.y = jump_velocity if should_jump else 0.0

	velocity = target_velocity
	move_and_slide()
	target_velocity = velocity
	_sync_visual_orientation()


func _read_input_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_back")


func _unhandled_input(event: InputEvent) -> void:
	if not _is_local_player():
		return
	if _ui_locked:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_adjust_camera_zoom(-camera_zoom_step)
			get_viewport().set_input_as_handled()
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_adjust_camera_zoom(camera_zoom_step)
			get_viewport().set_input_as_handled()
			return
		if event.button_index == MOUSE_BUTTON_RIGHT and _cancel_wall_segment():
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_viewport().set_input_as_handled()
			return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_viewport().set_input_as_handled()
		return
	if _channel_locked:
		return
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		_apply_mouse_look(event.relative)
		get_viewport().set_input_as_handled()


func _apply_mouse_look(relative: Vector2) -> void:
	look_pivot.rotation.y -= relative.x * mouse_sensitivity
	_camera_pitch = clamp(
		_camera_pitch - relative.y * mouse_sensitivity,
		deg_to_rad(min_camera_pitch_degrees),
		deg_to_rad(max_camera_pitch_degrees)
	)
	_update_camera_pitch()
	_sync_visual_orientation()


func _update_camera_pitch() -> void:
	camera_pivot.rotation.x = _camera_pitch


func _adjust_camera_zoom(delta_length: float) -> void:
	spring_arm.spring_length = clamp(
		spring_arm.spring_length + delta_length,
		min_camera_distance,
		max_camera_distance
	)


func _update_camera_anchor(delta: float) -> void:
	var target_position := global_position + Vector3(0.0, 1.5, 0.0)
	var target_rotation := Vector3(_camera_pitch, look_pivot.global_rotation.y, 0.0)
	if delta >= 1.0:
		camera_pivot.global_position = target_position
		camera_pivot.global_rotation = target_rotation
		return
	camera_pivot.global_position = target_position
	camera_pivot.global_rotation = target_rotation


func _initialize_attack_visual() -> void:
	if _attack_visual_root != null:
		return
	_attack_visual_root = Node3D.new()
	_attack_visual_root.name = "AttackVisual"
	_attack_visual_root.visible = false
	visual_pivot.add_child(_attack_visual_root)

	_attack_visual_mesh = MeshInstance3D.new()
	_attack_visual_mesh.name = "AttackVisualMesh"
	var slash_mesh := BoxMesh.new()
	slash_mesh.size = Vector3(attack_visual_width, attack_visual_height, attack_visual_depth)
	_attack_visual_mesh.mesh = slash_mesh
	_attack_visual_mesh.position = Vector3(0.0, projectile_spawn_height, -(projectile_spawn_forward_offset + attack_visual_depth * 0.5))
	_attack_visual_material = StandardMaterial3D.new()
	_attack_visual_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_attack_visual_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_attack_visual_material.albedo_color = _attack_visual_fire_color
	_attack_visual_mesh.material_override = _attack_visual_material
	_attack_visual_root.add_child(_attack_visual_mesh)


func _update_attack_visual(delta: float) -> void:
	if _attack_visual_root == null:
		return
	if _attack_visual_time_remaining <= 0.0:
		_attack_visual_root.visible = false
		return
	_attack_visual_time_remaining = max(_attack_visual_time_remaining - delta, 0.0)
	if _attack_visual_time_remaining <= 0.0:
		_attack_visual_root.visible = false
		return
	var ratio := 1.0
	if attack_visual_duration > 0.0:
		ratio = clamp(_attack_visual_time_remaining / attack_visual_duration, 0.0, 1.0)
	_attack_visual_root.visible = true
	_attack_visual_root.scale = Vector3(0.9 + (1.0 - ratio) * 0.2, 0.9 + (1.0 - ratio) * 0.2, 0.55 + (1.0 - ratio) * 0.35)
	_attack_visual_mesh.position = Vector3(0.0, projectile_spawn_height, -(projectile_spawn_forward_offset + attack_visual_depth * 0.5))
	if _attack_visual_material != null:
		var color := _attack_visual_fire_color
		color.a = _attack_visual_fire_color.a * ratio
		_attack_visual_material.albedo_color = color


func _start_attack_feedback() -> void:
	if _attack_visual_root == null:
		return
	_attack_visual_time_remaining = attack_visual_duration
	_attack_visual_root.visible = true
	_attack_visual_root.scale = Vector3.ONE
	_attack_visual_mesh.position = Vector3(0.0, projectile_spawn_height, -(projectile_spawn_forward_offset + attack_visual_depth * 0.5))
	if _attack_visual_material != null:
		_attack_visual_material.albedo_color = _attack_visual_fire_color


func _update_remote_visual_state(delta: float) -> void:
	if _is_local_player() or not _has_network_target:
		return
	var distance_to_target := global_position.distance_to(_network_target_position)
	if distance_to_target >= remote_snap_distance:
		global_position = _network_target_position
		velocity = _network_target_velocity
		look_pivot.rotation.y = _network_target_facing_y
		_sync_visual_orientation()
		return
	var position_weight = clamp(remote_position_smoothing * delta, 0.0, 1.0)
	var rotation_weight = clamp(remote_rotation_smoothing * delta, 0.0, 1.0)
	global_position = global_position.lerp(_network_target_position, position_weight)
	velocity = _network_target_velocity
	look_pivot.rotation.y = lerp_angle(look_pivot.rotation.y, _network_target_facing_y, rotation_weight)
	_sync_visual_orientation()


func _sync_visual_orientation() -> void:
	visual_pivot.rotation.y = look_pivot.rotation.y


func _consume_attack_pressed() -> bool:
	if _build_mode_active:
		_attack_was_pressed = false
		return false
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		_attack_was_pressed = false
		return false
	var is_pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var just_pressed := is_pressed and not _attack_was_pressed
	_attack_was_pressed = is_pressed
	return just_pressed


func _consume_heavy_attack_pressed() -> bool:
	if _build_mode_active:
		_heavy_attack_was_pressed = false
		return false
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		_heavy_attack_was_pressed = false
		return false
	var is_pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	var just_pressed := is_pressed and not _heavy_attack_was_pressed
	_heavy_attack_was_pressed = is_pressed
	return just_pressed


func _consume_jump_pressed() -> bool:
	var is_pressed := Input.is_key_pressed(KEY_SPACE)
	var just_pressed := is_pressed and not _jump_was_pressed
	_jump_was_pressed = is_pressed
	return just_pressed


func _consume_build_pressed() -> bool:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return false
	var is_pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var just_pressed := is_pressed and not _build_was_pressed
	_build_was_pressed = is_pressed
	return just_pressed


func _is_build_input_held() -> bool:
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return false
	return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)


func _consume_interact_pressed() -> bool:
	var is_pressed := Input.is_key_pressed(KEY_E)
	var just_pressed := is_pressed and not _interact_was_pressed
	_interact_was_pressed = is_pressed
	return just_pressed


func _consume_select_wall_pressed() -> bool:
	var is_pressed := Input.is_key_pressed(KEY_1)
	var just_pressed := is_pressed and not _select_wall_was_pressed
	_select_wall_was_pressed = is_pressed
	return just_pressed


func _consume_select_turret_pressed() -> bool:
	var is_pressed := Input.is_key_pressed(KEY_2)
	var just_pressed := is_pressed and not _select_turret_was_pressed
	_select_turret_was_pressed = is_pressed
	return just_pressed


func _consume_rotate_build_pressed() -> bool:
	var is_pressed := Input.is_key_pressed(KEY_R)
	var just_pressed := is_pressed and not _rotate_build_was_pressed
	_rotate_build_was_pressed = is_pressed
	return just_pressed


func _consume_toggle_build_mode_pressed() -> bool:
	var is_pressed := Input.is_key_pressed(KEY_Q)
	var just_pressed := is_pressed and not _toggle_build_mode_was_pressed
	_toggle_build_mode_was_pressed = is_pressed
	return just_pressed


func _is_local_player() -> bool:
	return multiplayer.get_unique_id() == peer_id


func is_build_mode_active() -> bool:
	return _build_mode_active


func is_wall_segment_active() -> bool:
	return _wall_segment_active and _current_build_type == "wall"


func get_current_build_type() -> String:
	return _current_build_type


func is_channel_locked() -> bool:
	return _channel_locked


func is_ui_locked() -> bool:
	return _ui_locked


func get_build_forward_vector() -> Vector3:
	var forward := -look_pivot.global_basis.z
	forward.y = 0.0
	if forward.length_squared() <= 0.001:
		return Vector3.FORWARD
	return forward.normalized()


func get_build_rotation_y() -> float:
	var quarter_turn := PI * 0.5
	return snappedf(look_pivot.rotation.y + float(_build_rotation_steps) * quarter_turn, quarter_turn)


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
	_start_hit_flash()
	_play_hit_feedback.rpc()
	if current_health <= 0.0:
		_server_respawn()


func _server_respawn() -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	target_velocity = Vector3.ZERO
	_jump_requested = false
	look_pivot.rotation = Vector3.ZERO
	visual_pivot.rotation = Vector3.ZERO
	_build_rotation_steps = 0
	_camera_pitch = deg_to_rad(clamp(-25.0, min_camera_pitch_degrees, max_camera_pitch_degrees))
	_update_camera_pitch()
	current_health = max_health
	_hit_flash_time_remaining = 0.0
	var gate_manager = _gate_manager()
	if gate_manager != null and gate_manager.has_method("notify_player_respawn"):
		gate_manager.notify_player_respawn(peer_id)
	_sync_state.rpc(global_position, velocity, look_pivot.rotation.y)
	_sync_health.rpc(current_health)
	_update_label()
	_update_body_visuals()


func reset_for_match() -> void:
	if not multiplayer.is_server():
		return
	_input_vector = Vector2.ZERO
	target_velocity = Vector3.ZERO
	_jump_requested = false
	_attack_cooldown_remaining = 0.0
	_heavy_attack_cooldown_remaining = 0.0
	_server_respawn()


func notify_projectile_finished(projectile_id: int) -> void:
	if not multiplayer.is_server():
		return
	_remove_projectile_local(projectile_id)
	_remove_projectile_remote.rpc(projectile_id)


func _attack_direction() -> Vector3:
	var direction := -look_pivot.global_basis.z
	direction.y = 0.0
	if direction.length_squared() <= 0.001:
		return Vector3.ZERO
	return direction.normalized()


func _projectiles_root() -> Node3D:
	var manager := _building_manager()
	if manager != null and manager.has_method("get_projectiles_root"):
		return manager.get_projectiles_root()
	return null


func _projectile_lifetime(projectile_range: float, runtime_speed: float) -> float:
	return projectile_range / max(runtime_speed, 0.001)


func _spawn_projectile_local(projectile_id: int, start_position: Vector3, direction: Vector3, runtime_damage: float, runtime_speed: float, lifetime: float, runtime_hit_radius: float, aoe_radius: float, visual_scale: float, is_authoritative: bool) -> void:
	var projectiles_root := _projectiles_root()
	if projectiles_root == null or PLAYER_PROJECTILE_SCENE == null:
		return
	var node_name := _projectile_name(projectile_id)
	if projectiles_root.has_node(node_name):
		return
	var projectile = PLAYER_PROJECTILE_SCENE.instantiate()
	projectile.name = node_name
	if projectile.has_method("setup"):
		projectile.setup(
			projectile_id,
			start_position,
			direction,
			runtime_damage,
			runtime_speed,
			lifetime,
			runtime_hit_radius,
			aoe_radius,
			visual_scale,
			is_authoritative,
			self
		)
	projectiles_root.add_child(projectile)


func _remove_projectile_local(projectile_id: int) -> void:
	var projectiles_root := _projectiles_root()
	if projectiles_root == null:
		return
	var node_name := _projectile_name(projectile_id)
	if not projectiles_root.has_node(node_name):
		return
	projectiles_root.get_node(node_name).queue_free()


func _projectile_name(projectile_id: int) -> String:
	return "PlayerProjectile_%d_%d" % [peer_id, projectile_id]


func teleport_to_position(target_position: Vector3, facing_y: float = 0.0, refill_health: bool = true) -> void:
	if not multiplayer.is_server():
		return
	global_position = target_position
	velocity = Vector3.ZERO
	target_velocity = Vector3.ZERO
	_jump_requested = false
	look_pivot.rotation.y = facing_y
	_sync_visual_orientation()
	if refill_health:
		current_health = max_health
		_sync_health.rpc(current_health)
		_update_label()
	_sync_state.rpc(global_position, velocity, look_pivot.rotation.y)


func set_channel_locked(active: bool) -> void:
	if not multiplayer.is_server():
		return
	_apply_channel_lock(active)
	_sync_channel_lock.rpc(active)


func set_ui_locked(active: bool) -> void:
	_apply_ui_lock(active)


func _apply_channel_lock(active: bool) -> void:
	_channel_locked = active
	if active:
		_input_vector = Vector2.ZERO
		_jump_requested = false
		target_velocity = Vector3.ZERO
		velocity.x = 0.0
		velocity.z = 0.0


func _apply_ui_lock(active: bool) -> void:
	_ui_locked = active
	if active:
		_jump_requested = false


func _request_server_jump() -> void:
	if not multiplayer.is_server():
		return
	_jump_requested = true


func _update_label() -> void:
	label.text = "P%d HP:%d" % [peer_id, int(round(current_health))]


func _update_build_preview() -> void:
	if not _build_mode_active:
		build_preview_root.visible = false
		_current_build_preview_valid = false
		_has_current_build_preview = false
		_build_hold_preview_valid = false
		_build_hold_preview_positions = []
		_set_build_reticle_visible(false)
		_update_extra_preview_meshes([], 0.0)
		return
	var manager = _building_manager()
	if manager == null or not manager.has_method("get_build_preview_for_peer"):
		build_preview_root.visible = false
		_current_build_preview_valid = false
		_has_current_build_preview = false
		_build_hold_preview_valid = false
		_build_hold_preview_positions = []
		_set_build_reticle_visible(false)
		_update_extra_preview_meshes([], 0.0)
		return

	var preview: Dictionary
	if _is_local_player() and _wall_segment_active and _current_build_type == "wall" and manager.has_method("get_wall_line_preview_from_request"):
		var wall_request := _local_build_request()
		_current_build_target_position = wall_request.get("position", global_position)
		preview = manager.get_wall_line_preview_from_request(
			peer_id,
			_wall_segment_anchor_position,
			_current_build_target_position,
			float(wall_request.get("rotation_y", get_build_rotation_y()))
		)
	elif _is_local_player() and _build_hold_active and manager.has_method("get_build_preview_from_request"):
		preview = manager.get_build_preview_from_request(
			peer_id,
			_build_hold_type,
			_build_hold_anchor_position,
			_build_hold_rotation_y,
			_build_hold_type == "wall",
			true
		)
	elif _is_local_player() and manager.has_method("get_build_preview_from_request"):
		var local_request := _local_build_request()
		_current_build_target_position = local_request.get("position", global_position)
		preview = manager.get_build_preview_from_request(
			peer_id,
			_current_build_type,
			_current_build_target_position,
			float(local_request.get("rotation_y", get_build_rotation_y())),
			_build_drag_active and _current_build_type == "wall"
		)
	else:
		preview = manager.get_build_preview_for_peer(peer_id, _current_build_type)
	if not preview.get("visible", false):
		build_preview_root.visible = false
		_current_build_preview_valid = false
		_has_current_build_preview = false
		_build_hold_preview_valid = false
		_build_hold_preview_positions = []
		_set_build_reticle_visible(false)
		_update_extra_preview_meshes([], 0.0)
		return

	var preview_positions: Array = preview.get("positions", [_current_build_preview_position])
	build_preview_root.visible = true
	_current_build_preview_position = preview.get("position", global_position)
	_current_build_preview_rotation_y = float(preview.get("rotation_y", 0.0))
	_current_build_preview_valid = bool(preview.get("valid", false))
	_has_current_build_preview = true
	if _wall_segment_active:
		_wall_segment_preview_valid = _current_build_preview_valid
		_wall_segment_preview_positions = preview_positions
		_wall_segment_rotation_y = _current_build_preview_rotation_y
	elif _build_hold_active:
		_build_hold_preview_valid = _current_build_preview_valid
		_build_hold_preview_positions = preview_positions
	_update_build_reticle(_current_build_target_position, bool(preview.get("valid", false)))
	_configure_build_preview_feedback(
		preview.get("valid", false),
		preview.get("type", _current_build_type),
		int(preview.get("total_cost", preview.get("cost", 0))),
		int(preview.get("count", 1)),
		_wall_preview_status_text(preview)
	)
	_apply_preview_positions(preview_positions, _current_build_preview_rotation_y)


func _wall_preview_status_text(preview: Dictionary) -> String:
	var status_text := String(preview.get("status_text", "VALID"))
	if not (_wall_segment_active and _current_build_type == "wall"):
		return status_text
	if bool(preview.get("valid", false)):
		return "SELECT END"
	return "END BLOCKED"


func _configure_build_preview_feedback(is_valid: bool = true, structure_type: String = "wall", total_cost: int = 0, count: int = 1, status_text: String = "VALID") -> void:
	_apply_preview_shape(structure_type)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = _preview_valid_color if is_valid else _preview_invalid_color
	build_preview_mesh.material_override = material
	if _build_reticle_material != null:
		_build_reticle_material.albedo_color = _preview_reticle_valid_color if is_valid else _preview_reticle_invalid_color
	var cost_text := "FREE" if total_cost <= 0 else "%d" % total_cost
	var build_text := _build_type_label(structure_type)
	if count > 1:
		build_text = "%s x%d" % [build_text, count]
	build_preview_label.text = "%s %s | %s" % [build_text, cost_text, status_text]
	build_preview_label.modulate = _preview_valid_text_color if is_valid else _preview_invalid_text_color
	_update_extra_preview_styles(material)


func _initialize_build_reticle() -> void:
	if _build_reticle_root != null:
		return
	_build_reticle_root = Node3D.new()
	_build_reticle_root.name = "BuildReticle"
	_build_reticle_root.top_level = true
	_build_reticle_root.visible = false
	add_child(_build_reticle_root)

	_build_reticle_mesh = MeshInstance3D.new()
	_build_reticle_mesh.name = "BuildReticleMesh"
	var reticle_mesh := CylinderMesh.new()
	reticle_mesh.top_radius = 0.42
	reticle_mesh.bottom_radius = 0.42
	reticle_mesh.height = 0.04
	_build_reticle_mesh.mesh = reticle_mesh
	_build_reticle_material = StandardMaterial3D.new()
	_build_reticle_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_build_reticle_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_build_reticle_material.albedo_color = _preview_reticle_valid_color
	_build_reticle_mesh.material_override = _build_reticle_material
	_build_reticle_root.add_child(_build_reticle_mesh)


func _update_build_reticle(target_position: Vector3, is_valid: bool) -> void:
	if _build_reticle_root == null:
		return
	_build_reticle_root.visible = _build_mode_active and _is_local_player()
	_build_reticle_root.global_position = Vector3(target_position.x, 0.03, target_position.z)
	if _build_reticle_material != null:
		_build_reticle_material.albedo_color = _preview_reticle_valid_color if is_valid else _preview_reticle_invalid_color


func _set_build_reticle_visible(is_visible: bool) -> void:
	if _build_reticle_root == null:
		return
	_build_reticle_root.visible = is_visible


func _apply_preview_positions(positions: Array, rotation_y: float) -> void:
	if positions.is_empty():
		build_preview_root.visible = false
		_update_extra_preview_meshes([], rotation_y)
		return
	var first_position: Vector3 = positions[0]
	build_preview_root.global_position = first_position
	build_preview_root.global_rotation = Vector3(0.0, rotation_y, 0.0)
	_update_extra_preview_meshes(positions, rotation_y)


func _update_extra_preview_meshes(positions: Array, rotation_y: float) -> void:
	var extra_count = max(positions.size() - 1, 0)
	_ensure_extra_preview_mesh_count(extra_count)
	if extra_count <= 0:
		for mesh_node in _build_preview_extra_meshes:
			mesh_node.visible = false
		return
	var basis_inverse := Basis.from_euler(Vector3(0.0, rotation_y, 0.0)).inverse()
	var first_position: Vector3 = positions[0]
	for index in range(_build_preview_extra_meshes.size()):
		var mesh_node: MeshInstance3D = _build_preview_extra_meshes[index]
		var preview_index := index + 1
		if preview_index >= positions.size():
			mesh_node.visible = false
			continue
		mesh_node.visible = true
		mesh_node.position = build_preview_mesh.position + (basis_inverse * (positions[preview_index] - first_position))
		mesh_node.rotation = build_preview_mesh.rotation


func _ensure_extra_preview_mesh_count(count: int) -> void:
	while _build_preview_extra_meshes.size() < count:
		var mesh_node := MeshInstance3D.new()
		mesh_node.name = "PreviewMeshExtra_%d" % _build_preview_extra_meshes.size()
		build_preview_root.add_child(mesh_node)
		_build_preview_extra_meshes.append(mesh_node)
	for index in range(_build_preview_extra_meshes.size()):
		_build_preview_extra_meshes[index].visible = index < count


func _update_extra_preview_styles(source_material: Material) -> void:
	for mesh_node in _build_preview_extra_meshes:
		mesh_node.mesh = build_preview_mesh.mesh
		mesh_node.material_override = source_material


func _begin_build_hold() -> void:
	if not _has_current_build_preview or not _current_build_preview_valid:
		return
	_build_hold_active = true
	_build_hold_type = _current_build_type
	_build_hold_anchor_position = _current_build_preview_position
	_build_hold_rotation_y = _current_build_preview_rotation_y
	_build_hold_preview_positions = [_current_build_preview_position]
	_build_hold_preview_valid = true
	_reset_build_drag_state()


func _reset_build_hold_state() -> void:
	_build_hold_active = false
	_build_hold_type = _current_build_type
	_build_hold_anchor_position = Vector3.ZERO
	_build_hold_rotation_y = 0.0
	_build_hold_preview_positions = []
	_build_hold_preview_valid = false


func _begin_wall_segment() -> void:
	if not _has_current_build_preview or not _current_build_preview_valid:
		return
	_wall_segment_active = true
	_wall_segment_anchor_position = _current_build_preview_position
	_wall_segment_preview_positions = [_current_build_preview_position]
	_wall_segment_preview_valid = true
	_wall_segment_rotation_y = _current_build_preview_rotation_y


func _reset_wall_segment_state() -> void:
	_wall_segment_active = false
	_wall_segment_anchor_position = Vector3.ZERO
	_wall_segment_preview_positions = []
	_wall_segment_preview_valid = false
	_wall_segment_rotation_y = 0.0


func _cancel_wall_segment() -> bool:
	if not (_build_mode_active and _wall_segment_active and _current_build_type == "wall"):
		return false
	_reset_wall_segment_state()
	if _is_local_player():
		_update_build_preview()
	return true


func _handle_wall_segment_click_server() -> void:
	if _current_build_type != "wall":
		return
	if not _wall_segment_active:
		_begin_wall_segment()
		return
	_confirm_wall_segment_server()


func _handle_wall_segment_click_remote() -> void:
	if _current_build_type != "wall":
		return
	if not _wall_segment_active:
		_begin_wall_segment()
		return
	_confirm_wall_segment_remote()


func _confirm_wall_segment_server() -> void:
	if not _wall_segment_active:
		return
	if not _wall_segment_preview_valid or _wall_segment_preview_positions.is_empty():
		return
	var manager = _building_manager()
	if manager == null:
		return
	if manager.has_method("request_structure_batch_placement"):
		manager.request_structure_batch_placement(peer_id, "wall", _wall_segment_preview_positions, _wall_segment_rotation_y)
		_reset_wall_segment_state()


func _confirm_wall_segment_remote() -> void:
	if not _wall_segment_active:
		return
	if not _wall_segment_preview_valid or _wall_segment_preview_positions.is_empty():
		return
	_request_build_batch.rpc_id(1, "wall", _wall_segment_preview_positions, _wall_segment_rotation_y)
	_reset_wall_segment_state()


func _confirm_build_hold_server() -> void:
	if not _build_hold_active:
		return
	if not _build_hold_preview_valid or _build_hold_preview_positions.is_empty():
		_reset_build_hold_state()
		return
	var manager = _building_manager()
	if manager == null:
		_reset_build_hold_state()
		return
	if _build_hold_type == "wall" and _build_hold_preview_positions.size() > 1 and manager.has_method("request_structure_batch_placement"):
		manager.request_structure_batch_placement(peer_id, "wall", _build_hold_preview_positions, _build_hold_rotation_y)
	elif manager.has_method("request_structure_placement"):
		manager.request_structure_placement(peer_id, _build_hold_type, _build_hold_anchor_position, _build_hold_rotation_y, true, _build_hold_type == "wall", true)
	_reset_build_hold_state()


func _confirm_build_hold_remote() -> void:
	if not _build_hold_active:
		return
	if not _build_hold_preview_valid or _build_hold_preview_positions.is_empty():
		_reset_build_hold_state()
		return
	if _build_hold_type == "wall" and _build_hold_preview_positions.size() > 1:
		_request_build_batch.rpc_id(1, "wall", _build_hold_preview_positions, _build_hold_rotation_y)
	else:
		_request_build.rpc_id(1, _build_hold_type, _build_hold_anchor_position, _build_hold_rotation_y)
	_reset_build_hold_state()


func _should_drag_place_wall() -> bool:
	if _current_build_type != "wall":
		return false
	if not _has_current_build_preview or not _current_build_preview_valid:
		return false
	if not _build_drag_active:
		return false
	return _build_drag_last_position.distance_to(_current_build_preview_position) > 0.1


func _mark_drag_build_request() -> void:
	if _current_build_type != "wall":
		return
	if not _has_current_build_preview:
		return
	_build_drag_active = true
	_build_drag_last_position = _current_build_preview_position
	if _build_drag_axis.length_squared() <= 0.001:
		_build_drag_axis = _drag_axis_from_rotation(_current_build_preview_rotation_y)
	_has_build_drag_preview_position = false
	_build_drag_preview_position = Vector3.ZERO


func _reset_build_drag_state() -> void:
	_build_drag_active = false
	_build_drag_last_position = Vector3.ZERO
	_build_drag_axis = Vector3.ZERO
	_build_drag_direction_sign = 0
	_build_drag_preview_position = Vector3.ZERO
	_has_build_drag_preview_position = false

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
	var combat_profile := _current_combat_profile()
	var basic_attack: Dictionary = combat_profile.get("basic_attack", {})
	_attack_cooldown_remaining = float(basic_attack.get("cooldown", attack_cooldown))
	_spawn_attack_projectile(
		float(basic_attack.get("damage", attack_damage)),
		float(basic_attack.get("speed", projectile_speed)),
		float(basic_attack.get("range", attack_range)),
		projectile_hit_radius,
		float(combat_profile.get("aoe_radius", 0.0)),
		float(basic_attack.get("projectile_scale", 1.0))
	)


func _perform_server_heavy_attack() -> void:
	if not multiplayer.is_server():
		return
	if _heavy_attack_cooldown_remaining > 0.0:
		return
	var combat_profile := _current_combat_profile()
	var heavy_attack: Dictionary = combat_profile.get("heavy_attack", {})
	_heavy_attack_cooldown_remaining = float(heavy_attack.get("cooldown", max(attack_cooldown * 3.0, 0.6)))
	_spawn_attack_projectile(
		float(heavy_attack.get("damage", attack_damage * 1.75)),
		float(heavy_attack.get("speed", projectile_speed * 0.9)),
		float(heavy_attack.get("range", attack_range * 1.1)),
		projectile_hit_radius * 1.35,
		float(combat_profile.get("aoe_radius", 0.0)) * 1.25,
		float(heavy_attack.get("projectile_scale", 1.2))
	)


func _spawn_attack_projectile(runtime_damage: float, runtime_speed: float, runtime_range: float, runtime_hit_radius: float, aoe_radius: float, visual_scale: float) -> void:
	var projectiles_root := _projectiles_root()
	if projectiles_root == null:
		return
	var direction := _attack_direction()
	if direction.length_squared() <= 0.001:
		return
	_start_attack_feedback()
	_play_attack_feedback.rpc()
	var spawn_position := global_position + Vector3(0.0, projectile_spawn_height, 0.0) + direction * projectile_spawn_forward_offset
	var projectile_id := _next_projectile_id
	_next_projectile_id += 1
	var lifetime := _projectile_lifetime(runtime_range, runtime_speed)
	_spawn_projectile_local(projectile_id, spawn_position, direction, runtime_damage, runtime_speed, lifetime, runtime_hit_radius, aoe_radius, visual_scale, true)
	_spawn_projectile_remote.rpc(projectile_id, spawn_position, direction, runtime_damage, runtime_speed, lifetime, runtime_hit_radius, aoe_radius, visual_scale)


func _perform_server_wall_build() -> void:
	if not multiplayer.is_server():
		return
	if not _build_mode_active:
		return
	if not _has_current_build_preview:
		return
	var manager = _building_manager()
	if manager == null:
		return
	if manager.has_method("request_structure_placement"):
		manager.request_structure_placement(peer_id, _current_build_type, _current_build_preview_position, _current_build_preview_rotation_y, true, _build_drag_active and _current_build_type == "wall")
		_mark_drag_build_request()


func _perform_server_build() -> void:
	_perform_server_wall_build()


func _perform_server_interact() -> void:
	if not multiplayer.is_server():
		return
	var building_manager = _building_manager()
	if building_manager != null and building_manager.has_method("request_structure_repair"):
		if building_manager.request_structure_repair(peer_id):
			return
	var manager = _gate_manager()
	if manager == null:
		return
	if manager.has_method("request_objective_interaction"):
		manager.request_objective_interaction(peer_id)


func _update_build_selection() -> void:
	if _consume_select_wall_pressed():
		_set_build_type("wall")
	if _consume_select_turret_pressed():
		_set_build_type("turret")
	if _consume_rotate_build_pressed():
		_rotate_build_clockwise()
	if _consume_toggle_build_mode_pressed():
		_toggle_build_mode_active()


func _set_build_type(new_build_type: String) -> void:
	new_build_type = _normalized_build_type(new_build_type)
	if _current_build_type == new_build_type and _build_mode_active:
		return
	_reset_build_hold_state()
	_reset_wall_segment_state()
	_reset_build_drag_state()
	_current_build_type = new_build_type
	_build_mode_active = true
	if _is_local_player():
		_update_build_preview()
	if multiplayer.is_server():
		return
	_sync_build_mode_state.rpc_id(1, _current_build_type, _build_mode_active)


func _toggle_build_mode_active() -> void:
	if _cancel_wall_segment():
		return
	_reset_build_hold_state()
	_reset_wall_segment_state()
	_reset_build_drag_state()
	_build_mode_active = not _build_mode_active
	if _is_local_player():
		_update_build_preview()
	if multiplayer.is_server():
		return
	_sync_build_mode_state.rpc_id(1, _current_build_type, _build_mode_active)


func _rotate_build_clockwise() -> void:
	_build_rotation_steps = posmod(_build_rotation_steps + 1, 4)
	if _is_local_player() and _build_mode_active:
		_update_build_preview()
	if multiplayer.is_server():
		return
	_request_build_rotation.rpc_id(1, _build_rotation_steps)


func _initialize_preview_meshes() -> void:
	if _wall_preview_mesh == null:
		_wall_preview_mesh = BoxMesh.new()
		_wall_preview_mesh.size = Vector3(2.0, 1.6, 2.0)
	if _turret_preview_mesh == null:
		_turret_preview_mesh = CylinderMesh.new()
		_turret_preview_mesh.top_radius = 0.6
		_turret_preview_mesh.bottom_radius = 0.72
		_turret_preview_mesh.height = 1.8


func _apply_preview_shape(structure_type: String) -> void:
	if _wall_preview_mesh == null or _turret_preview_mesh == null:
		_initialize_preview_meshes()
	if structure_type == "turret":
		build_preview_mesh.mesh = _turret_preview_mesh
		build_preview_mesh.position = Vector3(0.0, 0.9, 0.0)
		build_preview_label.position = Vector3(0.0, 2.35, 0.0)
		return
	build_preview_mesh.mesh = _wall_preview_mesh
	build_preview_mesh.position = Vector3(0.0, 0.8, 0.0)
	build_preview_label.position = Vector3(0.0, 1.95, 0.0)


func _build_type_label(structure_type: String) -> String:
	structure_type = _normalized_build_type(structure_type)
	return structure_type.to_upper()


func _normalized_build_type(structure_type: String) -> String:
	if structure_type == "turret":
		return structure_type
	return "wall"


func _building_manager() -> Node:
	var managers = get_tree().get_nodes_in_group("building_manager")
	if managers.is_empty():
		return null
	return managers[0]


func _main_root() -> Node:
	var roots = get_tree().get_nodes_in_group("main_root")
	if roots.is_empty():
		return null
	return roots[0]


func _gate_manager() -> Node:
	var managers = get_tree().get_nodes_in_group("gate_manager")
	if managers.is_empty():
		return null
	return managers[0]


func _research_manager() -> Node:
	var managers = get_tree().get_nodes_in_group("ResearchManager")
	if managers.is_empty():
		managers = get_tree().get_nodes_in_group("research_manager")
	if managers.is_empty():
		return get_node_or_null("/root/Main/ResearchManager")
	return managers[0]


func _era_manager() -> Node:
	var managers = get_tree().get_nodes_in_group("era_manager")
	if managers.is_empty():
		return null
	return managers[0]


func _current_combat_profile() -> Dictionary:
	var basic_attack := {
		"damage": attack_damage,
		"cooldown": attack_cooldown,
		"speed": projectile_speed,
		"range": attack_range,
		"projectile_scale": 1.0,
	}
	var heavy_attack := {
		"damage": attack_damage * 1.75,
		"cooldown": max(attack_cooldown * 3.0, 0.6),
		"speed": projectile_speed * 0.9,
		"range": attack_range * 1.1,
		"projectile_scale": 1.2,
	}
	var profile := {
		"basic_attack": basic_attack,
		"heavy_attack": heavy_attack,
		"aoe_radius": 0.0,
	}
	var runtime_era_manager := _era_manager()
	if runtime_era_manager != null and runtime_era_manager.has_method("get_combat_data"):
		var combat_data: Dictionary = runtime_era_manager.get_combat_data()
		profile["basic_attack"] = (combat_data.get("basic_attack", basic_attack) as Dictionary).duplicate(true)
		profile["heavy_attack"] = (combat_data.get("heavy_attack", heavy_attack) as Dictionary).duplicate(true)
		profile["aoe_radius"] = float(combat_data.get("aoe_radius", 0.0))
	var runtime_research_manager := _research_manager()
	if runtime_research_manager == null:
		return profile
	var damage_bonus := 1.0 + float(runtime_research_manager.get_stat_total("damage_multiplier"))
	var speed_bonus := 1.0 + float(runtime_research_manager.get_stat_total("attack_speed_multiplier"))
	var range_bonus := float(runtime_research_manager.get_stat_total("range_bonus"))
	profile["aoe_radius"] = float(profile.get("aoe_radius", 0.0)) + float(runtime_research_manager.get_stat_total("aoe_radius"))
	var runtime_basic: Dictionary = profile.get("basic_attack", {}).duplicate(true)
	runtime_basic["damage"] = float(runtime_basic.get("damage", attack_damage)) * damage_bonus
	runtime_basic["cooldown"] = max(float(runtime_basic.get("cooldown", attack_cooldown)) / max(speed_bonus, 0.1), 0.08)
	runtime_basic["range"] = float(runtime_basic.get("range", attack_range)) + range_bonus
	profile["basic_attack"] = runtime_basic
	var runtime_heavy: Dictionary = profile.get("heavy_attack", {}).duplicate(true)
	runtime_heavy["damage"] = float(runtime_heavy.get("damage", attack_damage * 1.75)) * damage_bonus
	runtime_heavy["cooldown"] = max(float(runtime_heavy.get("cooldown", attack_cooldown * 3.0)) / max(speed_bonus, 0.1), 0.18)
	runtime_heavy["range"] = float(runtime_heavy.get("range", attack_range * 1.1)) + range_bonus
	profile["heavy_attack"] = runtime_heavy
	return profile


func _handle_local_ui_interaction() -> bool:
	if not _is_local_player():
		return false
	var root = _main_root()
	if root != null and root.has_method("handle_local_interaction"):
		return bool(root.handle_local_interaction(peer_id))
	return false


func _local_build_request() -> Dictionary:
	var rotation_y := get_build_rotation_y()
	var forward := get_build_forward_vector()
	var fallback_position := global_position + forward * 3.0
	var manager = _building_manager()
	if manager != null and manager.has_method("get_max_placement_distance"):
		fallback_position = global_position + forward * float(manager.get_max_placement_distance())
	if camera == null:
		return {"position": fallback_position, "rotation_y": rotation_y}
	var viewport_rect := get_viewport().get_visible_rect()
	var screen_center := viewport_rect.size * 0.5
	var ray_origin := camera.project_ray_origin(screen_center)
	var ray_direction := camera.project_ray_normal(screen_center).normalized()
	var hit_position := fallback_position
	if absf(ray_direction.y) > 0.001:
		var ray_distance := -ray_origin.y / ray_direction.y
		if ray_distance > 0.0:
			hit_position = ray_origin + ray_direction * ray_distance
	if not (_build_hold_active and _build_hold_type == "wall"):
		hit_position = _clamp_local_build_target(hit_position)
	return {"position": hit_position, "rotation_y": rotation_y}


func _clamp_local_build_target(target_position: Vector3) -> Vector3:
	var manager = _building_manager()
	var max_distance := 6.5
	var min_distance := 1.5
	if manager != null and manager.has_method("get_max_placement_distance"):
		max_distance = float(manager.get_max_placement_distance())
	if manager != null and manager.has_method("get_min_placement_distance"):
		min_distance = float(manager.get_min_placement_distance())
	var planar_offset := target_position - global_position
	planar_offset.y = 0.0
	if planar_offset.length_squared() <= 0.001:
		planar_offset = get_build_forward_vector() * max_distance
	var direction := planar_offset.normalized()
	var distance = clamp(planar_offset.length(), min_distance, max_distance)
	return global_position + direction * distance


func _preferred_wall_drag_request(target_position: Vector3, rotation_y: float) -> Dictionary:
	if not _build_drag_active:
		return {"position": target_position, "rotation_y": rotation_y}
	var offset := target_position - _build_drag_last_position
	offset.y = 0.0
	var axis_x := Vector3.RIGHT
	var axis_z := Vector3.FORWARD
	if _build_drag_axis.length_squared() <= 0.001:
		_build_drag_axis = _drag_axis_from_rotation(_current_build_preview_rotation_y)
	var drag_axis := _build_drag_axis.normalized()
	var step := 2.0
	var manager = _building_manager()
	if manager != null and manager.has_method("get_wall_drag_step"):
		step = float(manager.get_wall_drag_step())
	var projected := offset.dot(drag_axis)
	if _build_drag_direction_sign == 0:
		if absf(projected) < step * 0.5:
			if _has_build_drag_preview_position:
				return {"position": _build_drag_preview_position, "rotation_y": _rotation_for_drag_axis()}
			return {"position": _build_drag_last_position, "rotation_y": rotation_y}
		_build_drag_direction_sign = 1 if projected >= 0.0 else -1
	if projected * float(_build_drag_direction_sign) < step * 0.5:
		if _has_build_drag_preview_position:
			return {"position": _build_drag_preview_position, "rotation_y": _rotation_for_drag_axis()}
		return {"position": _build_drag_last_position, "rotation_y": rotation_y}

	var preferred_position := _build_drag_last_position + drag_axis * step * float(_build_drag_direction_sign)
	preferred_position.y = target_position.y
	var preferred_rotation_y := _rotation_for_drag_axis()
	_build_drag_preview_position = preferred_position
	_has_build_drag_preview_position = true
	return {"position": preferred_position, "rotation_y": preferred_rotation_y}


func _rotation_for_drag_axis() -> float:
	if _build_drag_axis == Vector3.RIGHT:
		return 0.0
	return PI * 0.5


func _drag_axis_from_rotation(rotation_y: float) -> Vector3:
	var snapped_rotation := snappedf(rotation_y, PI * 0.5)
	var quarter_turns := posmod(int(round(snapped_rotation / (PI * 0.5))), 4)
	if quarter_turns % 2 == 0:
		return Vector3.RIGHT
	return Vector3.FORWARD


@rpc("any_peer", "call_remote", "unreliable_ordered")
func _submit_input(new_input: Vector2, facing_y: float) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_input_vector = new_input
	look_pivot.rotation.y = facing_y
	_sync_visual_orientation()


@rpc("any_peer", "call_remote", "reliable")
func _request_attack() -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_perform_server_attack()


@rpc("any_peer", "call_remote", "reliable")
func _request_heavy_attack() -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_perform_server_heavy_attack()


@rpc("any_peer", "call_remote", "reliable")
func _request_jump() -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_request_server_jump()


@rpc("any_peer", "call_remote", "reliable")
func _request_build(structure_type: String, desired_position: Vector3, desired_rotation_y: float) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_current_build_type = _normalized_build_type(structure_type)
	_build_mode_active = true
	var manager = _building_manager()
	if manager != null and manager.has_method("request_structure_placement"):
		manager.request_structure_placement(peer_id, _current_build_type, desired_position, desired_rotation_y, true, _build_drag_active and _current_build_type == "wall", true)


@rpc("any_peer", "call_remote", "reliable")
func _request_build_batch(structure_type: String, desired_positions: Array, desired_rotation_y: float) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_current_build_type = _normalized_build_type(structure_type)
	_build_mode_active = true
	var manager = _building_manager()
	if manager != null and manager.has_method("request_structure_batch_placement"):
		manager.request_structure_batch_placement(peer_id, _current_build_type, desired_positions, desired_rotation_y)


@rpc("any_peer", "call_remote", "reliable")
func _request_build_rotation(rotation_steps: int) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_build_rotation_steps = posmod(rotation_steps, 4)


@rpc("any_peer", "call_remote", "reliable")
func _sync_build_mode_state(structure_type: String, is_active: bool) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_current_build_type = _normalized_build_type(structure_type)
	_build_mode_active = is_active


@rpc("any_peer", "call_remote", "reliable")
func _request_interact() -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != peer_id:
		return
	_perform_server_interact()


@rpc("authority", "call_remote", "unreliable_ordered")
func _sync_state(server_position: Vector3, server_velocity: Vector3, facing_y: float) -> void:
	if multiplayer.is_server():
		return
	if _is_local_player():
		global_position = server_position
		velocity = server_velocity
		return
	_network_target_position = server_position
	_network_target_velocity = server_velocity
	_network_target_facing_y = facing_y
	if not _has_network_target:
		global_position = server_position
		velocity = server_velocity
		look_pivot.rotation.y = facing_y
		_sync_visual_orientation()
		_has_network_target = true


@rpc("authority", "call_remote", "reliable")
func _sync_health(server_health: float) -> void:
	if multiplayer.is_server():
		return
	current_health = server_health
	_update_label()


@rpc("authority", "call_remote", "reliable")
func _sync_channel_lock(active: bool) -> void:
	if multiplayer.is_server():
		return
	_apply_channel_lock(active)


@rpc("authority", "call_remote", "reliable")
func _play_hit_feedback() -> void:
	if multiplayer.is_server():
		return
	_start_hit_flash()


@rpc("authority", "call_remote", "reliable")
func _play_attack_feedback() -> void:
	if multiplayer.is_server():
		return
	_start_attack_feedback()


@rpc("authority", "call_remote", "reliable")
func _spawn_projectile_remote(projectile_id: int, start_position: Vector3, direction: Vector3, runtime_damage: float, runtime_speed: float, lifetime: float, runtime_hit_radius: float, aoe_radius: float, visual_scale: float) -> void:
	if multiplayer.is_server():
		return
	_spawn_projectile_local(projectile_id, start_position, direction, runtime_damage, runtime_speed, lifetime, runtime_hit_radius, aoe_radius, visual_scale, false)


@rpc("authority", "call_remote", "reliable")
func _remove_projectile_remote(projectile_id: int) -> void:
	if multiplayer.is_server():
		return
	_remove_projectile_local(projectile_id)
