extends Node3D

@onready var network_manager = $NetworkManager
@onready var enemy_manager = $EnemyManager
@onready var building_manager = $BuildingManager
@onready var gate_manager = $GateManager
@onready var core_objective = $World/CoreObjective
@onready var startup_camera: Camera3D = $World/StartupCamera
@onready var address_input: LineEdit = $UI/Panel/VBoxContainer/AddressInput
@onready var port_input: LineEdit = $UI/Panel/VBoxContainer/PortInput
@onready var host_button: Button = $UI/Panel/VBoxContainer/HostButton
@onready var join_button: Button = $UI/Panel/VBoxContainer/JoinButton
@onready var leave_button: Button = $UI/Panel/VBoxContainer/LeaveButton
@onready var gate_button: Button = $UI/Panel/VBoxContainer/GateButton
@onready var restart_button: Button = $UI/Panel/VBoxContainer/RestartButton
@onready var status_label: Label = $UI/Panel/VBoxContainer/StatusLabel
@onready var run_info_label: Label = $UI/Panel/VBoxContainer/RunInfoLabel


func _ready() -> void:
	network_manager.set_players_root($World/Players)
	enemy_manager.set_roots($World/Enemies, $World/Players)
	enemy_manager.set_objective(core_objective)
	enemy_manager.bind_network_manager(network_manager)
	building_manager.set_roots($World/Walls, $World/Projectiles, $World/Players, core_objective)
	building_manager.bind_network_manager(network_manager)
	gate_manager.set_roots($World/GateContent, $World/Players, core_objective)
	gate_manager.set_enemy_manager(enemy_manager)
	gate_manager.bind_network_manager(network_manager)
	core_objective.bind_network_manager(network_manager)
	network_manager.status_changed.connect(_on_status_changed)
	building_manager.status_changed.connect(_on_status_changed)
	gate_manager.status_changed.connect(_on_status_changed)
	gate_manager.run_info_changed.connect(_on_run_info_changed)
	gate_manager.gate_state_changed.connect(_on_gate_state_changed)
	network_manager.session_changed.connect(_on_session_changed)
	core_objective.destroyed.connect(_on_core_destroyed)
	enemy_manager.wave_changed.connect(_on_wave_changed)

	address_input.text = "127.0.0.1"
	port_input.text = str(network_manager.default_port)
	_on_session_changed(false)
	_on_status_changed("Core defense prototype ready.")
	_on_run_info_changed("Base | Stored Scrap 0")


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


func _on_restart_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.restart_match()
	building_manager.restart_match()
	enemy_manager.force_restart()
	core_objective.restart_match()
	network_manager.restart_match()
	restart_button.disabled = false
	status_label.text = "Wave 1 live. Space attacks, 1/2 select build, Q places."


func _on_status_changed(message: String) -> void:
	status_label.text = message


func _on_run_info_changed(message: String) -> void:
	run_info_label.text = message


func _on_session_changed(in_session: bool) -> void:
	host_button.disabled = in_session
	join_button.disabled = in_session
	leave_button.disabled = not in_session
	gate_button.disabled = not in_session or not multiplayer.is_server() or gate_manager.is_gate_active()
	restart_button.disabled = not in_session or not multiplayer.is_server()
	address_input.editable = not in_session
	port_input.editable = not in_session
	if not in_session:
		startup_camera.current = true
		run_info_label.text = "Base | Stored Scrap 0"
	else:
		status_label.text = "Wave 1 live. Space attacks, 1/2 select build, Q places."


func _on_core_destroyed() -> void:
	status_label.text = "Core destroyed. Press Restart Session to rerun the defense test."


func _on_wave_changed(wave_index: int, is_breather: bool) -> void:
	if not network_manager.multiplayer.multiplayer_peer:
		return
	if is_breather:
		status_label.text = "Wave %d cleared. Breather before next push." % wave_index
		return
	status_label.text = "Wave %d live. Space attacks, 1/2 select build, Q places." % wave_index


func _on_gate_state_changed(is_active: bool) -> void:
	gate_button.disabled = not network_manager.multiplayer.multiplayer_peer or not multiplayer.is_server() or is_active
	if is_active:
		gate_button.text = "Gate Active"
		return
	gate_button.text = "Start Gate Run"


func _get_port() -> int:
	var parsed_port := int(port_input.text)
	if parsed_port <= 0:
		parsed_port = network_manager.default_port
		port_input.text = str(parsed_port)
	return parsed_port
