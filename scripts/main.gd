extends Node3D

@onready var network_manager = $NetworkManager
@onready var enemy_manager = $EnemyManager
@onready var core_objective = $World/CoreObjective
@onready var startup_camera: Camera3D = $World/StartupCamera
@onready var address_input: LineEdit = $UI/Panel/VBoxContainer/AddressInput
@onready var port_input: LineEdit = $UI/Panel/VBoxContainer/PortInput
@onready var host_button: Button = $UI/Panel/VBoxContainer/HostButton
@onready var join_button: Button = $UI/Panel/VBoxContainer/JoinButton
@onready var leave_button: Button = $UI/Panel/VBoxContainer/LeaveButton
@onready var status_label: Label = $UI/Panel/VBoxContainer/StatusLabel


func _ready() -> void:
	network_manager.set_players_root($World/Players)
	enemy_manager.set_roots($World/Enemies, $World/Players)
	enemy_manager.set_objective(core_objective)
	enemy_manager.bind_network_manager(network_manager)
	core_objective.bind_network_manager(network_manager)
	network_manager.status_changed.connect(_on_status_changed)
	network_manager.session_changed.connect(_on_session_changed)
	core_objective.destroyed.connect(_on_core_destroyed)

	address_input.text = "127.0.0.1"
	port_input.text = str(network_manager.default_port)
	_on_session_changed(false)
	_on_status_changed("Core defense prototype ready.")


func _on_host_pressed() -> void:
	network_manager.host_game(_get_port())


func _on_join_pressed() -> void:
	network_manager.join_game(address_input.text.strip_edges(), _get_port())


func _on_leave_pressed() -> void:
	network_manager.leave_game()
	startup_camera.current = true


func _on_status_changed(message: String) -> void:
	status_label.text = message


func _on_session_changed(in_session: bool) -> void:
	host_button.disabled = in_session
	join_button.disabled = in_session
	leave_button.disabled = not in_session
	address_input.editable = not in_session
	port_input.editable = not in_session
	if not in_session:
		startup_camera.current = true
	else:
		status_label.text = "Defend the core."


func _on_core_destroyed() -> void:
	status_label.text = "Core destroyed. Session lost."


func _get_port() -> int:
	var parsed_port := int(port_input.text)
	if parsed_port <= 0:
		parsed_port = network_manager.default_port
		port_input.text = str(parsed_port)
	return parsed_port
