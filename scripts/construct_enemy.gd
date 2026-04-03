extends "res://scripts/enemy.gd"


func _ready() -> void:
	_base_color = Color(0.61, 0.66, 0.76)
	super._ready()


func get_enemy_scene_kind() -> String:
	return "construct"


func _update_label() -> void:
	label.text = "C%d HP:%d" % [enemy_id, int(round(current_health))]


func _begin_death_feedback() -> void:
	_is_dying = true
	_death_time_remaining = death_feedback_duration
	velocity = Vector3.ZERO
	label.text = "C%d Down" % enemy_id
	_update_body_visuals()
