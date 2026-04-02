extends Node3D

var bullet_id: int = 0
var move_direction: Vector3 = Vector3.FORWARD
var damage: float = 0.0
var move_speed: float = 15.0
var hit_radius: float = 0.22
var lifetime_remaining: float = 1.2
var authoritative: bool = false
var owner_turret: Node

@onready var body_mesh: MeshInstance3D = $BodyMesh


func setup(new_bullet_id: int, start_position: Vector3, direction: Vector3, bullet_damage: float, bullet_speed: float, bullet_lifetime: float, bullet_hit_radius: float, is_authoritative: bool, turret_owner: Node) -> void:
	bullet_id = new_bullet_id
	global_position = start_position
	move_direction = direction.normalized()
	damage = bullet_damage
	move_speed = bullet_speed
	lifetime_remaining = bullet_lifetime
	hit_radius = bullet_hit_radius
	authoritative = is_authoritative
	owner_turret = turret_owner


func _ready() -> void:
	if move_direction.length_squared() > 0.001:
		look_at(global_position + move_direction, Vector3.UP)


func _physics_process(delta: float) -> void:
	if move_direction.length_squared() <= 0.001:
		_finish_bullet()
		return

	var previous_position := global_position
	global_position += move_direction * move_speed * delta
	lifetime_remaining -= delta
	if lifetime_remaining <= 0.0:
		_finish_bullet()
		return

	if not authoritative:
		return

	var enemy_hit := _first_enemy_hit(previous_position, global_position)
	if enemy_hit == null:
		return
	if enemy_hit.has_method("apply_server_damage"):
		enemy_hit.apply_server_damage(damage)
	_finish_bullet()


func _first_enemy_hit(start_position: Vector3, end_position: Vector3) -> CharacterBody3D:
	for node in get_tree().get_nodes_in_group("enemies"):
		if not node is CharacterBody3D:
			continue
		if node.has_method("is_alive") and not node.is_alive():
			continue
		var enemy_center = node.global_position + Vector3(0.0, 0.9, 0.0)
		var enemy_radius := hit_radius
		if node.has_method("get_hit_radius"):
			enemy_radius += node.get_hit_radius()
		if _distance_to_segment(enemy_center, start_position, end_position) <= enemy_radius:
			return node
	return null


func _distance_to_segment(point: Vector3, segment_start: Vector3, segment_end: Vector3) -> float:
	var segment := segment_end - segment_start
	var segment_length_squared := segment.length_squared()
	if segment_length_squared <= 0.0001:
		return point.distance_to(segment_start)
	var point_factor = clamp((point - segment_start).dot(segment) / segment_length_squared, 0.0, 1.0)
	var closest_point = segment_start + segment * point_factor
	return point.distance_to(closest_point)


func _finish_bullet() -> void:
	if authoritative and owner_turret != null and owner_turret.has_method("notify_bullet_finished"):
		owner_turret.notify_bullet_finished(bullet_id)
		return
	queue_free()
