extends Node3D

var projectile_id: int = 0
var move_direction: Vector3 = Vector3.FORWARD
var damage: float = 0.0
var move_speed: float = 28.0
var hit_radius: float = 0.2
var lifetime_remaining: float = 0.7
var aoe_radius: float = 0.0
var visual_scale: float = 1.0
var authoritative: bool = false
var owner_player: Node


func setup(new_projectile_id: int, start_position: Vector3, direction: Vector3, projectile_damage: float, projectile_speed: float, projectile_lifetime: float, projectile_hit_radius: float, splash_radius: float, projectile_visual_scale: float, is_authoritative: bool, player_owner: Node) -> void:
	projectile_id = new_projectile_id
	global_position = start_position
	move_direction = direction.normalized()
	damage = projectile_damage
	move_speed = projectile_speed
	lifetime_remaining = projectile_lifetime
	hit_radius = projectile_hit_radius
	aoe_radius = max(splash_radius, 0.0)
	visual_scale = max(projectile_visual_scale, 0.25)
	authoritative = is_authoritative
	owner_player = player_owner


func _ready() -> void:
	scale = Vector3.ONE * visual_scale
	if move_direction.length_squared() > 0.001:
		look_at(global_position + move_direction, Vector3.UP)


func _physics_process(delta: float) -> void:
	if move_direction.length_squared() <= 0.001:
		_finish_projectile()
		return

	var previous_position := global_position
	global_position += move_direction * move_speed * delta
	lifetime_remaining -= delta
	if lifetime_remaining <= 0.0:
		_finish_projectile()
		return

	if not authoritative:
		return

	var enemy_hit := _first_enemy_hit(previous_position, global_position)
	if enemy_hit == null:
		return
	if enemy_hit.has_method("apply_server_damage"):
		enemy_hit.apply_server_damage(damage)
	if aoe_radius > 0.0:
		_apply_splash_damage(enemy_hit)
	_finish_projectile()


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


func _apply_splash_damage(primary_enemy: CharacterBody3D) -> void:
	for node in get_tree().get_nodes_in_group("enemies"):
		if not node is CharacterBody3D or node == primary_enemy:
			continue
		if node.has_method("is_alive") and not node.is_alive():
			continue
		if global_position.distance_to(node.global_position) > aoe_radius:
			continue
		if node.has_method("apply_server_damage"):
			node.apply_server_damage(damage * 0.7)


func _finish_projectile() -> void:
	if authoritative and owner_player != null and owner_player.has_method("notify_projectile_finished"):
		owner_player.notify_projectile_finished(projectile_id)
		return
	queue_free()
