extends Control

@export var tracked_groups: Array[StringName] = [&"objectives", &"players", &"enemies", &"structures"]
@export var bar_size: Vector2 = Vector2(72.0, 8.0)
@export var vertical_gap: float = 10.0
@export var screen_margin: float = 32.0
@export var max_visible_distance: float = 40.0

var _bars: Dictionary = {}


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		_hide_all_bars()
		return

	var active_ids := {}
	for source in _collect_sources():
		var source_id := source.get_instance_id()
		active_ids[source_id] = true
		_update_bar(source, camera)

	_cleanup_missing_bars(active_ids)


func _collect_sources() -> Array[Node3D]:
	var results: Array[Node3D] = []
	var seen := {}
	for group_name in tracked_groups:
		for node in get_tree().get_nodes_in_group(group_name):
			if not node is Node3D:
				continue
			var source := node as Node3D
			var source_id := source.get_instance_id()
			if seen.has(source_id):
				continue
			if not _is_valid_health_source(source):
				continue
			seen[source_id] = true
			results.append(source)
	return results


func _is_valid_health_source(source: Node3D) -> bool:
	return source.get("current_health") != null and source.get("max_health") != null


func _update_bar(source: Node3D, camera: Camera3D) -> void:
	var current_health := float(source.get("current_health"))
	var max_health_value = max(float(source.get("max_health")), 1.0)
	var bar := _get_or_create_bar(source.get_instance_id())

	if current_health <= 0.0:
		bar.visible = false
		return

	var anchor_position := _anchor_world_position(source)
	if camera.is_position_behind(anchor_position):
		bar.visible = false
		return

	var distance := camera.global_position.distance_to(anchor_position)
	if distance > max_visible_distance:
		bar.visible = false
		return

	var screen_position := camera.unproject_position(anchor_position)
	var viewport_rect := get_viewport_rect()
	if screen_position.x < -screen_margin or screen_position.x > viewport_rect.size.x + screen_margin:
		bar.visible = false
		return
	if screen_position.y < -screen_margin or screen_position.y > viewport_rect.size.y + screen_margin:
		bar.visible = false
		return

	var health_ratio = clamp(current_health / max_health_value, 0.0, 1.0)
	var distance_scale = clamp(1.15 - (distance / max_visible_distance) * 0.45, 0.7, 1.15)
	bar.scale = Vector2.ONE * distance_scale
	bar.position = screen_position + Vector2(-bar_size.x * 0.5 * distance_scale, -vertical_gap - bar_size.y * distance_scale)
	bar.visible = true

	var background := bar.get_node("Background") as ColorRect
	var fill := bar.get_node("Background/Fill") as ColorRect
	background.size = bar_size
	fill.size = Vector2(bar_size.x * health_ratio, bar_size.y)
	fill.color = _fill_color(health_ratio)


func _anchor_world_position(source: Node3D) -> Vector3:
	var label_node := source.get_node_or_null("Label3D") as Node3D
	if label_node != null:
		return label_node.global_position + Vector3(0.0, 0.18, 0.0)
	return source.global_position + Vector3(0.0, 1.8, 0.0)


func _get_or_create_bar(source_id: int) -> Control:
	if _bars.has(source_id):
		var existing := _bars[source_id] as Control
		if is_instance_valid(existing):
			return existing

	var bar := Control.new()
	bar.name = "HealthBar_%d" % source_id
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.visible = false
	bar.size = bar_size
	bar.pivot_offset = bar_size * 0.5

	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.08, 0.08, 0.09, 0.78)
	background.position = Vector2.ZERO
	background.size = bar_size
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var fill := ColorRect.new()
	fill.name = "Fill"
	fill.color = Color(0.25, 0.9, 0.36, 0.94)
	fill.position = Vector2.ZERO
	fill.size = bar_size
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE

	background.add_child(fill)
	bar.add_child(background)
	add_child(bar)
	_bars[source_id] = bar
	return bar


func _cleanup_missing_bars(active_ids: Dictionary) -> void:
	for source_id in _bars.keys():
		if active_ids.has(source_id):
			continue
		var bar := _bars[source_id] as Control
		if is_instance_valid(bar):
			bar.queue_free()
		_bars.erase(source_id)
func _hide_all_bars() -> void:
	for bar in _bars.values():
		if is_instance_valid(bar):
			(bar as Control).visible = false


func _fill_color(health_ratio: float) -> Color:
	if health_ratio <= 0.3:
		return Color(0.94, 0.27, 0.22, 0.94)
	if health_ratio <= 0.65:
		return Color(0.94, 0.74, 0.24, 0.94)
	return Color(0.25, 0.9, 0.36, 0.94)
