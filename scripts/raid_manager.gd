extends Node

signal status_changed(message: String)
signal progression_changed()
signal raid_state_changed(is_active: bool)

@export var town_hall_upgrade_channel_duration: float = 3.0
@export var town_hall_upgrade_base_cost: int = 60
@export var town_hall_upgrade_cost_step: int = 40
@export var raid_wave_count_base: int = 3
@export var raid_max_enemies_base: int = 8
@export var raid_spawns_per_wave_base: int = 8
@export var raid_spawn_interval_base: float = 2.2
@export var raid_wave_enemy_bonus_base: int = 2
@export var raid_breather_duration: float = 5.0

var enemy_manager: Node
var gate_manager: Node
var base_objective: Node3D
var network_manager: Node
var _session_active: bool = false
var _raid_active: bool = false
var _upgrade_channeling: bool = false
var _channel_remaining: float = 0.0
var _sync_timer: float = 0.0
var _town_hall_level: int = 0
var _pending_upgrade_cost: int = 0
var _raid_total_waves_current: int = 0


func set_dependencies(new_enemy_manager: Node, new_gate_manager: Node, new_base_objective: Node3D) -> void:
	enemy_manager = new_enemy_manager
	gate_manager = new_gate_manager
	base_objective = new_base_objective
	if enemy_manager != null and enemy_manager.has_signal("raid_finished") and not enemy_manager.raid_finished.is_connected(_on_raid_finished):
		enemy_manager.raid_finished.connect(_on_raid_finished)


func bind_network_manager(manager: Node) -> void:
	network_manager = manager
	if manager.has_signal("session_changed"):
		manager.session_changed.connect(_on_session_changed)
	if manager.has_signal("peer_registered"):
		manager.peer_registered.connect(_on_peer_registered)


func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	if not _session_active:
		return
	if not _upgrade_channeling:
		return
	_channel_remaining = max(_channel_remaining - delta, 0.0)
	_sync_timer += delta
	if _sync_timer >= 0.2:
		_sync_timer = 0.0
		_broadcast_state()
	if _channel_remaining <= 0.0:
		_start_raid()


func get_town_hall_level() -> int:
	return _town_hall_level


func get_next_town_hall_upgrade_cost() -> int:
	return town_hall_upgrade_base_cost + (_town_hall_level * town_hall_upgrade_cost_step)


func is_raid_active() -> bool:
	return _raid_active


func is_upgrade_channeling() -> bool:
	return _upgrade_channeling


func is_progression_locked() -> bool:
	return _raid_active or _upgrade_channeling


func get_channel_time_remaining() -> float:
	return _channel_remaining


func get_raid_total_waves() -> int:
	return _raid_total_waves_current


func get_run_info_suffix() -> String:
	if _upgrade_channeling:
		return " | Town Hall Lv %d | Upgrade %0.1fs" % [_town_hall_level, _channel_remaining]
	if _raid_active:
		var current_wave = enemy_manager.get_wave_index() if enemy_manager != null and enemy_manager.has_method("get_wave_index") else 1
		return " | Town Hall Lv %d | Raid %d/%d" % [_town_hall_level, current_wave, max(_raid_total_waves_current, 1)]
	return " | Town Hall Lv %d | Next Town Hall %d Scrap" % [_town_hall_level, get_next_town_hall_upgrade_cost()]


func can_start_town_hall_upgrade() -> bool:
	if not multiplayer.is_server():
		return false
	if not _session_active:
		return false
	if _raid_active or _upgrade_channeling:
		return false
	if gate_manager != null and gate_manager.has_method("is_gate_active") and gate_manager.is_gate_active():
		return false
	if gate_manager != null and gate_manager.has_method("can_afford_scrap"):
		return gate_manager.can_afford_scrap(get_next_town_hall_upgrade_cost())
	return false


func start_town_hall_upgrade() -> void:
	if not multiplayer.is_server():
		return
	if not _session_active:
		status_changed.emit("Start a session before beginning a town hall upgrade.")
		return
	if gate_manager != null and gate_manager.has_method("is_gate_active") and gate_manager.is_gate_active():
		status_changed.emit("Return from the gate before starting a town hall upgrade.")
		return
	if _raid_active or _upgrade_channeling:
		status_changed.emit("A town hall upgrade is already in progress.")
		return
	var upgrade_cost := get_next_town_hall_upgrade_cost()
	if gate_manager == null or not gate_manager.has_method("can_afford_scrap") or not gate_manager.can_afford_scrap(upgrade_cost):
		status_changed.emit("Need %d scrap before starting the next town hall upgrade." % upgrade_cost)
		return
	_pending_upgrade_cost = upgrade_cost
	_upgrade_channeling = true
	_channel_remaining = town_hall_upgrade_channel_duration
	_sync_timer = 0.0
	status_changed.emit("Town Hall upgrade channeling started. Hold the base. Raid incoming.")
	_broadcast_state()


func restart_match() -> void:
	if not multiplayer.is_server():
		return
	var was_active := _raid_active or _upgrade_channeling
	_upgrade_channeling = false
	_raid_active = false
	_channel_remaining = 0.0
	_pending_upgrade_cost = 0
	_raid_total_waves_current = 0
	_sync_timer = 0.0
	if enemy_manager != null and enemy_manager.has_method("stop_pressure"):
		enemy_manager.stop_pressure(true)
	if was_active:
		status_changed.emit("Town Hall upgrade attempt cancelled.")
	_broadcast_state()


func _on_session_changed(in_session: bool) -> void:
	_session_active = in_session
	if in_session:
		_broadcast_state()
		return
	_upgrade_channeling = false
	_raid_active = false
	_channel_remaining = 0.0
	_pending_upgrade_cost = 0
	_raid_total_waves_current = 0
	_town_hall_level = 0
	_sync_timer = 0.0
	if multiplayer.is_server() and enemy_manager != null and enemy_manager.has_method("stop_pressure"):
		enemy_manager.stop_pressure(true)
	_broadcast_state()


func _on_peer_registered(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	_sync_state.rpc_id(peer_id, _raid_active, _upgrade_channeling, _channel_remaining, _town_hall_level, _pending_upgrade_cost, _raid_total_waves_current)


func _start_raid() -> void:
	if not multiplayer.is_server():
		return
	_upgrade_channeling = false
	_raid_active = true
	_sync_timer = 0.0
	_raid_total_waves_current = raid_wave_count_base + _town_hall_level
	var max_enemies_for_raid := raid_max_enemies_base + (_town_hall_level * 2)
	var spawns_per_wave_for_raid := raid_spawns_per_wave_base + (_town_hall_level * 2)
	var spawn_interval_for_raid = max(raid_spawn_interval_base - (float(_town_hall_level) * 0.15), 1.0)
	var wave_bonus_for_raid = raid_wave_enemy_bonus_base + min(_town_hall_level, 2)
	if enemy_manager != null and enemy_manager.has_method("start_raid_pressure") and base_objective != null:
		enemy_manager.start_raid_pressure(base_objective, base_objective.global_position, _raid_total_waves_current, max_enemies_for_raid, spawns_per_wave_for_raid, spawn_interval_for_raid, wave_bonus_for_raid, raid_breather_duration)
	status_changed.emit("Town Hall upgrade triggered a raid. Defend the base until the upgrade completes.")
	_broadcast_state()


func _on_raid_finished(success: bool) -> void:
	if not multiplayer.is_server():
		return
	if not _raid_active:
		return
	_raid_active = false
	if success:
		if gate_manager != null and gate_manager.has_method("consume_scrap") and gate_manager.consume_scrap(_pending_upgrade_cost):
			_town_hall_level += 1
		status_changed.emit("Raid survived. Town Hall upgraded to level %d." % _town_hall_level)
	else:
		status_changed.emit("Raid failed. Town Hall upgrade interrupted. Materials were kept.")
	_pending_upgrade_cost = 0
	_raid_total_waves_current = 0
	_broadcast_state()


func _broadcast_state() -> void:
	progression_changed.emit()
	raid_state_changed.emit(_raid_active)
	if multiplayer.is_server():
		_sync_state.rpc(_raid_active, _upgrade_channeling, _channel_remaining, _town_hall_level, _pending_upgrade_cost, _raid_total_waves_current)


@rpc("authority", "call_remote", "unreliable_ordered")
func _sync_state(raid_active: bool, upgrade_channeling: bool, channel_remaining: float, town_hall_level: int, pending_upgrade_cost: int, raid_total_waves_current: int) -> void:
	if multiplayer.is_server():
		return
	_raid_active = raid_active
	_upgrade_channeling = upgrade_channeling
	_channel_remaining = channel_remaining
	_town_hall_level = town_hall_level
	_pending_upgrade_cost = pending_upgrade_cost
	_raid_total_waves_current = raid_total_waves_current
	progression_changed.emit()
	raid_state_changed.emit(_raid_active)
