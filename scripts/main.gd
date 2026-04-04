extends Node3D

@onready var network_manager = $NetworkManager
@onready var enemy_manager = $EnemyManager
@onready var building_manager = $BuildingManager
@onready var cave_manager = $CaveManager
@onready var gate_manager = $GateManager
@onready var raid_manager = $RaidManager
@onready var core_objective = $World/CoreObjective
@onready var startup_camera: Camera3D = $World/StartupCamera
@onready var address_input: LineEdit = $UI/Panel/VBoxContainer/AddressInput
@onready var port_input: LineEdit = $UI/Panel/VBoxContainer/PortInput
@onready var host_button: Button = $UI/Panel/VBoxContainer/HostButton
@onready var join_button: Button = $UI/Panel/VBoxContainer/JoinButton
@onready var leave_button: Button = $UI/Panel/VBoxContainer/LeaveButton
@onready var gate_button: Button = $UI/Panel/VBoxContainer/GateButton
@onready var restart_button: Button = $UI/Panel/VBoxContainer/RestartButton
@onready var town_hall_upgrade_button: Button = $UI/Panel/VBoxContainer/TownHallUpgradeButton
@onready var core_upgrade_button: Button = $UI/Panel/VBoxContainer/CoreUpgradeButton
@onready var status_label: Label = $UI/Panel/VBoxContainer/StatusLabel
@onready var run_info_label: Label = $UI/Panel/VBoxContainer/RunInfoLabel

var _latest_run_info_base: String = "Base | Stored Scrap 0 | Core Lv 0 | Max HP 300"


func _ready() -> void:
	network_manager.set_players_root($World/Players)
	enemy_manager.set_roots($World/Enemies, $World/Players)
	enemy_manager.set_objective(core_objective)
	enemy_manager.bind_network_manager(network_manager)
	building_manager.set_roots($World/Walls, $World/Projectiles, $World/Players, core_objective)
	building_manager.bind_network_manager(network_manager)
	building_manager.set_gate_manager(gate_manager)
	gate_manager.set_roots($World/GateContent, $World/Players, core_objective)
	gate_manager.set_cave_manager(cave_manager)
	gate_manager.set_enemy_manager(enemy_manager)
	gate_manager.set_building_manager(building_manager)
	gate_manager.bind_network_manager(network_manager)
	raid_manager.set_dependencies(enemy_manager, gate_manager, core_objective)
	raid_manager.bind_network_manager(network_manager)
	core_objective.bind_network_manager(network_manager)
	network_manager.status_changed.connect(_on_status_changed)
	building_manager.status_changed.connect(_on_status_changed)
	gate_manager.status_changed.connect(_on_status_changed)
	raid_manager.status_changed.connect(_on_status_changed)
	gate_manager.run_info_changed.connect(_on_run_info_changed)
	gate_manager.gate_state_changed.connect(_on_gate_state_changed)
	gate_manager.progression_changed.connect(_refresh_progression_ui)
	raid_manager.progression_changed.connect(_refresh_progression_ui)
	raid_manager.raid_state_changed.connect(_on_raid_state_changed)
	network_manager.session_changed.connect(_on_session_changed)
	core_objective.destroyed.connect(_on_core_destroyed)
	enemy_manager.wave_changed.connect(_on_wave_changed)

	address_input.text = "127.0.0.1"
	port_input.text = str(network_manager.default_port)
	_on_session_changed(false)
	_on_status_changed("Core defense prototype ready.")
	_on_run_info_changed("Base | Stored Scrap 0 | Core Lv 0 | Max HP 300")
	_refresh_progression_ui()


func _on_host_pressed() -> void:
	network_manager.host_game(_get_port())


func _on_join_pressed() -> void:
	network_manager.join_game(address_input.text.strip_edges(), _get_port())


func _on_leave_pressed() -> void:
	network_manager.leave_game()
	startup_camera.current = true


func _on_gate_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.start_gate_run()


func _on_town_hall_upgrade_pressed() -> void:
	if not multiplayer.is_server():
		return
	raid_manager.start_town_hall_upgrade()
	_refresh_progression_ui()


func _on_restart_pressed() -> void:
	if not multiplayer.is_server():
		return
	raid_manager.restart_match()
	gate_manager.restart_match()
	cave_manager.clear_all_runtime_state()
	building_manager.restart_match()
	enemy_manager.force_restart()
	core_objective.restart_match()
	network_manager.restart_match()
	restart_button.disabled = false
	status_label.text = "Base idle. Start a gate run or begin a town hall upgrade."
	_refresh_progression_ui()


func _on_core_upgrade_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.purchase_core_upgrade()
	_refresh_progression_ui()


func _on_status_changed(message: String) -> void:
	status_label.text = message


func _on_run_info_changed(message: String) -> void:
	_latest_run_info_base = message
	run_info_label.text = _compose_run_info(message)
	_refresh_progression_ui()


func _on_session_changed(in_session: bool) -> void:
	host_button.disabled = in_session
	join_button.disabled = in_session
	leave_button.disabled = not in_session
	restart_button.disabled = not in_session or not multiplayer.is_server()
	address_input.editable = not in_session
	port_input.editable = not in_session
	if not in_session:
		cave_manager.clear_all_runtime_state()
		startup_camera.current = true
		_latest_run_info_base = "Base | Stored Scrap 0 | Core Lv 0 | Max HP 300"
		run_info_label.text = _compose_run_info(_latest_run_info_base)
	else:
		status_label.text = "Base idle. Start a gate run or begin a town hall upgrade."
	_refresh_progression_ui()


func _on_core_destroyed() -> void:
	if raid_manager.is_raid_active():
		return
	status_label.text = "Core destroyed. Press Restart Session to rerun the defense test."


func _on_wave_changed(wave_index: int, is_breather: bool) -> void:
	if gate_manager.is_gate_active():
		return
	if not network_manager.multiplayer.multiplayer_peer:
		return
	if raid_manager.is_raid_active():
		if is_breather:
			status_label.text = "Raid wave %d cleared. Brace for the next assault." % wave_index
			return
		status_label.text = "Raid wave %d live. Defend the Town Hall upgrade." % wave_index
		return
	if raid_manager.is_upgrade_channeling():
		return
	if enemy_manager.get_pressure_mode() == "idle":
		return
	if is_breather:
		status_label.text = "Wave %d cleared. Breather before next push." % wave_index
		return
	status_label.text = "Wave %d live. Space attacks, 1/2 select build, Q places." % wave_index


func _on_gate_state_changed(is_active: bool) -> void:
	if is_active:
		gate_button.text = "Gate Active"
		_refresh_progression_ui()
		return
	gate_button.text = "Start Gate Run"
	_refresh_progression_ui()


func _on_raid_state_changed(is_active: bool) -> void:
	if is_active:
		town_hall_upgrade_button.text = "Raid In Progress"
	else:
		town_hall_upgrade_button.text = "Start Town Hall Upgrade"
	run_info_label.text = _compose_run_info(_latest_run_info_base)
	_refresh_progression_ui()


func _refresh_progression_ui() -> void:
	var has_session := network_manager.multiplayer.multiplayer_peer != null
	var is_host := has_session and multiplayer.is_server()
	var progression_locked = raid_manager.is_progression_locked()
	var next_cost = gate_manager.get_next_core_upgrade_cost()
	var next_level = gate_manager.get_core_upgrade_level() + 1
	var next_town_hall_cost = raid_manager.get_next_town_hall_upgrade_cost()
	var next_town_hall_level = raid_manager.get_town_hall_level() + 1
	gate_button.disabled = not is_host or gate_manager.is_gate_active() or progression_locked
	town_hall_upgrade_button.text = "Upgrade Town Hall to Lv %d (%d Scrap)" % [next_town_hall_level, next_town_hall_cost]
	town_hall_upgrade_button.disabled = not is_host or not raid_manager.can_start_town_hall_upgrade()
	core_upgrade_button.text = "Upgrade Core to Lv %d (%d Scrap)" % [next_level, next_cost]
	core_upgrade_button.disabled = not is_host or progression_locked or not gate_manager.can_purchase_core_upgrade()
	run_info_label.text = _compose_run_info(_latest_run_info_base)


func _compose_run_info(base_message: String) -> String:
	return "%s%s" % [base_message, raid_manager.get_run_info_suffix()]


func _get_port() -> int:
	var parsed_port := int(port_input.text)
	if parsed_port <= 0:
		parsed_port = network_manager.default_port
		port_input.text = str(parsed_port)
	return parsed_port
