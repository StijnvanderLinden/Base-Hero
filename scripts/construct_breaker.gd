extends "res://scripts/construct_enemy.gd"


func _ready() -> void:
	_base_color = Color(0.49, 0.52, 0.58)
	super._ready()


func get_enemy_scene_kind() -> String:
	return "construct_breaker"


func _current_movement_target(objective: Node3D) -> Node3D:
	var structure_target = _nearest_structure_target(structure_notice_range + 2.0)
	if structure_target != null:
		return structure_target
	return objective


func _current_attack_target(objective: Node3D) -> Node3D:
	var structure_target = _nearest_structure_target(attack_range + 1.8)
	if structure_target != null and _is_target_in_attack_range(structure_target):
		return structure_target
	if objective.has_method("can_be_targeted") and not objective.can_be_targeted():
		return null
	if _is_target_in_attack_range(objective):
		return objective
	var player_target = _nearest_player_in_attack_range()
	if player_target != null:
		return player_target
	return null


func _update_label() -> void:
	label.text = "B%d HP:%d" % [enemy_id, int(round(current_health))]


func _begin_death_feedback() -> void:
	_is_dying = true
	_death_time_remaining = death_feedback_duration
	velocity = Vector3.ZERO
	label.text = "B%d Down" % enemy_id
	_update_body_visuals()