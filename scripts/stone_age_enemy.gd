extends "res://scripts/enemy.gd"

@export var enemy_kind_id: String = "stone_caveman"
@export var label_prefix: String = "CV"
@export var display_name: String = "Caveman"
@export var enemy_color: Color = Color(0.63, 0.51, 0.35)
@export var charge_enabled: bool = false
@export var charge_speed_multiplier: float = 2.0
@export var charge_damage_multiplier: float = 1.35
@export var charge_cooldown: float = 4.5
@export var charge_duration: float = 0.8
@export var charge_trigger_range: float = 7.5

var _charge_cooldown_remaining: float = 0.0
var _charge_time_remaining: float = 0.0
var _charge_direction: Vector3 = Vector3.ZERO


func _ready() -> void:
	_base_color = enemy_color
	super._ready()


func _process(delta: float) -> void:
	_charge_cooldown_remaining = max(_charge_cooldown_remaining - delta, 0.0)
	if _charge_time_remaining > 0.0:
		_charge_time_remaining = max(_charge_time_remaining - delta, 0.0)
	super._process(delta)


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	if _is_dying:
		velocity = Vector3.ZERO
		return
	if _apply_knockback_motion(delta):
		return

	var objective = _current_objective()
	if objective == null:
		velocity = Vector3.ZERO
		_sync_state.rpc(global_position, velocity, rotation.y)
		return

	var movement_target = _current_movement_target(objective)
	var attack_target = _current_attack_target(objective)
	var use_charge := charge_enabled and attack_target != null and _can_start_charge(attack_target)
	if use_charge:
		_begin_charge(attack_target)

	var direction := _movement_direction_to_target(movement_target)
	var active_speed := move_speed
	var active_damage := damage_per_second
	if _charge_time_remaining > 0.0:
		direction = _charge_direction
		active_speed *= charge_speed_multiplier
		active_damage *= charge_damage_multiplier
	velocity.x = direction.x * active_speed
	velocity.z = direction.z * active_speed
	if direction.length_squared() > 0.001:
		rotation.y = atan2(direction.x, direction.z)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()

	if attack_target != null and attack_target.has_method("apply_server_damage") and _is_target_in_attack_range(attack_target):
		attack_target.apply_server_damage(active_damage * delta)

	_sync_state.rpc(global_position, velocity, rotation.y)


func get_enemy_scene_kind() -> String:
	return enemy_kind_id


func _update_label() -> void:
	label.text = "%s HP:%d" % [label_prefix, int(round(current_health))]


func _movement_direction_to_target(target: Node3D) -> Vector3:
	if target == null:
		return Vector3.ZERO
	var to_target := target.global_position - global_position
	var planar := Vector3(to_target.x, 0.0, to_target.z)
	if planar.length_squared() <= 0.001:
		return Vector3.ZERO
	return planar.normalized()


func _can_start_charge(target: Node3D) -> bool:
	if _charge_time_remaining > 0.0 or _charge_cooldown_remaining > 0.0:
		return false
	var planar_self := Vector2(global_position.x, global_position.z)
	var planar_target := Vector2(target.global_position.x, target.global_position.z)
	var target_distance := planar_self.distance_to(planar_target)
	return target_distance >= attack_range * 1.5 and target_distance <= charge_trigger_range


func _begin_charge(target: Node3D) -> void:
	_charge_direction = _movement_direction_to_target(target)
	if _charge_direction.length_squared() <= 0.001:
		return
	_charge_time_remaining = charge_duration
	_charge_cooldown_remaining = charge_cooldown


func _on_server_knockback_applied() -> void:
	_charge_time_remaining = 0.0
	_charge_direction = Vector3.ZERO
