extends StaticBody3D

signal destroyed

@export var max_health: float = 300.0

var current_health: float = 300.0
var is_destroyed: bool = false
var _hit_flash_time_remaining: float = 0.0
var _base_color: Color = Color(0.35, 0.8, 1.0)

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var label: Label3D = $Label3D
@onready var health_bar_fill: MeshInstance3D = $HealthBar/Fill


func _ready() -> void:
	add_to_group("objectives")
	add_to_group("primary_objective")
	_apply_default_material()
	_reset_local_state()


func _process(delta: float) -> void:
	if _hit_flash_time_remaining <= 0.0:
		return
	_hit_flash_time_remaining = max(_hit_flash_time_remaining - delta, 0.0)
	_update_body_visuals()


func bind_network_manager(manager: Node) -> void:
	if manager.has_signal("session_changed"):
		manager.session_changed.connect(_on_session_changed)
	if manager.has_signal("peer_registered"):
		manager.peer_registered.connect(_on_peer_registered)


func apply_server_damage(amount: float) -> void:
	if not multiplayer.is_server():
		return
	if amount <= 0.0 or is_destroyed:
		return

	current_health = max(current_health - amount, 0.0)
	_update_visuals()
	_start_hit_flash()
	_play_hit_feedback.rpc()
	_sync_state.rpc(current_health, is_destroyed)
	if current_health <= 0.0:
		_handle_server_destroyed()


func can_be_targeted() -> bool:
	return not is_destroyed


func get_current_health() -> float:
	return current_health


func get_hit_radius() -> float:
	return 1.1


func _on_session_changed(in_session: bool) -> void:
	if multiplayer.is_server() and in_session:
		_reset_local_state()
		_sync_state.rpc(current_health, is_destroyed)
	if not in_session:
		_reset_local_state()


func _on_peer_registered(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	_sync_state.rpc_id(peer_id, current_health, is_destroyed)


func _handle_server_destroyed() -> void:
	is_destroyed = true
	_update_visuals()
	_sync_state.rpc(current_health, is_destroyed)
	destroyed.emit()


func _reset_local_state() -> void:
	current_health = max_health
	is_destroyed = false
	_update_visuals()


func _update_visuals() -> void:
	label.text = "Core HP:%d" % int(round(current_health))
	var health_ratio = clamp(current_health / max_health, 0.0, 1.0)
	health_bar_fill.scale.x = max(health_ratio, 0.001)
	health_bar_fill.position.x = (health_ratio - 1.0) * 0.5
	if is_destroyed:
		label.text = "Core Destroyed"
		_apply_destroyed_material()
	else:
		_update_body_visuals()


func _apply_default_material() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = _base_color
	body_mesh.material_override = material


func _apply_destroyed_material() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.22, 0.22, 0.24)
	body_mesh.material_override = material


func _start_hit_flash() -> void:
	_hit_flash_time_remaining = 0.12
	_update_body_visuals()


func _update_body_visuals() -> void:
	if body_mesh.material_override == null:
		return
	var material := body_mesh.material_override as StandardMaterial3D
	if material == null:
		return
	if is_destroyed:
		material.albedo_color = Color(0.22, 0.22, 0.24)
		return
	if _hit_flash_time_remaining > 0.0:
		material.albedo_color = Color(1.0, 1.0, 1.0)
		return
	material.albedo_color = _base_color


@rpc("authority", "call_remote", "reliable")
func _sync_state(server_health: float, server_destroyed: bool) -> void:
	var was_destroyed := is_destroyed
	current_health = server_health
	is_destroyed = server_destroyed
	_update_visuals()
	if not was_destroyed and is_destroyed:
		destroyed.emit()


@rpc("authority", "call_remote", "reliable")
func _play_hit_feedback() -> void:
	if multiplayer.is_server():
		return
	_start_hit_flash()
