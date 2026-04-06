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
@onready var scrap_panel: PanelContainer = $UI/ScrapPanel
@onready var scrap_value_label: Label = $UI/ScrapPanel/HBoxContainer/ScrapValueLabel
@onready var status_mode_label: Label = $UI/StatusPanel/VBoxContainer/ModeLabel
@onready var core_health_label: Label = $UI/StatusPanel/VBoxContainer/CoreHealthLabel
@onready var core_health_bar: ProgressBar = $UI/StatusPanel/VBoxContainer/CoreHealthBar
@onready var player_health_label: Label = $UI/StatusPanel/VBoxContainer/PlayerHealthLabel
@onready var player_health_bar: ProgressBar = $UI/StatusPanel/VBoxContainer/PlayerHealthBar
@onready var status_label: Label = $UI/StatusPanel/VBoxContainer/StatusLabel
@onready var run_info_label: Label = $UI/RunPanel/VBoxContainer/RunInfoLabel
@onready var cave_panel: PanelContainer = $UI/CavePanel
@onready var cave_state_value_label: Label = $UI/CavePanel/VBoxContainer/CaveStateValueLabel
@onready var cave_pressure_value_label: Label = $UI/CavePanel/VBoxContainer/CavePressureValueLabel
@onready var cave_reward_value_label: Label = $UI/CavePanel/VBoxContainer/CaveRewardValueLabel
@onready var cave_detail_label: Label = $UI/CavePanel/VBoxContainer/CaveDetailValueLabel
@onready var claim_panel: PanelContainer = $UI/ClaimPanel
@onready var claim_progress_label: Label = $UI/ClaimPanel/VBoxContainer/ClaimProgressLabel
@onready var claim_progress_bar: ProgressBar = $UI/ClaimPanel/VBoxContainer/ClaimProgressBar
@onready var interaction_prompt_panel: PanelContainer = $UI/InteractionPromptPanel
@onready var interaction_prompt_label: Label = $UI/InteractionPromptPanel/InteractionPromptLabel
@onready var controls_panel: PanelContainer = $UI/ControlsPanel
@onready var controls_context_label: Label = $UI/ControlsPanel/VBoxContainer/ControlsContextLabel
@onready var controls_body_label: Label = $UI/ControlsPanel/VBoxContainer/ControlsBodyLabel

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
	_refresh_scrap_display()
	_refresh_claim_progress_ui()
	_refresh_cave_status_ui()
	_refresh_status_overview()
	_refresh_controls_panel()
	_refresh_interaction_prompt()


func _process(_delta: float) -> void:
	_refresh_status_overview()
	_refresh_controls_panel()
	_refresh_interaction_prompt()


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
	if gate_manager.is_gate_active():
		gate_manager.request_return_to_base()
		_refresh_progression_ui()
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
	_refresh_claim_progress_ui()
	_refresh_cave_status_ui()
	_refresh_progression_ui()
	_refresh_scrap_display()
	_refresh_status_overview()
	_refresh_controls_panel()
	_refresh_interaction_prompt()


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
	_refresh_claim_progress_ui()
	_refresh_cave_status_ui()
	_refresh_progression_ui()
	_refresh_scrap_display()
	_refresh_status_overview()
	_refresh_controls_panel()


func _on_core_destroyed() -> void:
	if raid_manager.is_raid_active():
		return
	status_label.text = "Core destroyed. Press Restart Session to rerun the defense test."


func _on_wave_changed(wave_index: int, is_breather: bool) -> void:
	if gate_manager.is_gate_active():
		_refresh_claim_progress_ui()
		_refresh_cave_status_ui()
		if enemy_manager.get_pressure_mode() == "gate":
			if is_breather:
				status_label.text = "Gate pressure wave %d cleared. Short breather while the cave state holds." % wave_index
				return
			status_label.text = "Gate pressure wave %d live. Keep the pylon up or close the cave." % wave_index
			return
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
	status_label.text = "Wave %d live. Space attacks, Q toggles build, LMB places, R rotates." % wave_index


func _on_gate_state_changed(is_active: bool) -> void:
	if is_active:
		gate_button.text = "Return to Base"
		_refresh_claim_progress_ui()
		_refresh_cave_status_ui()
		_refresh_progression_ui()
		return
	gate_button.text = "Start Gate Run"
	_refresh_claim_progress_ui()
	_refresh_cave_status_ui()
	_refresh_progression_ui()
	_refresh_status_overview()
	_refresh_controls_panel()


func _on_raid_state_changed(is_active: bool) -> void:
	if is_active:
		town_hall_upgrade_button.text = "Raid In Progress"
	else:
		town_hall_upgrade_button.text = "Start Town Hall Upgrade"
	run_info_label.text = _compose_run_info(_latest_run_info_base)
	_refresh_claim_progress_ui()
	_refresh_cave_status_ui()
	_refresh_progression_ui()
	_refresh_status_overview()
	_refresh_controls_panel()


func _refresh_progression_ui() -> void:
	var has_session := network_manager.multiplayer.multiplayer_peer != null
	var is_host := has_session and multiplayer.is_server()
	var progression_locked = raid_manager.is_progression_locked()
	var next_cost = gate_manager.get_next_core_upgrade_cost()
	var next_level = gate_manager.get_core_upgrade_level() + 1
	var next_town_hall_cost = raid_manager.get_next_town_hall_upgrade_cost()
	var next_town_hall_level = raid_manager.get_town_hall_level() + 1
	if gate_manager.is_gate_active():
		gate_button.text = "Returning..." if gate_manager.is_extraction_active() else "Return to Base"
		gate_button.disabled = not is_host or not gate_manager.can_return_to_base()
	else:
		gate_button.text = "Start Gate Run"
		gate_button.disabled = not is_host or progression_locked
	town_hall_upgrade_button.text = "Upgrade Town Hall to Lv %d (%d Scrap)" % [next_town_hall_level, next_town_hall_cost]
	town_hall_upgrade_button.disabled = not is_host or not raid_manager.can_start_town_hall_upgrade()
	core_upgrade_button.text = "Upgrade Core to Lv %d (%d Scrap)" % [next_level, next_cost]
	core_upgrade_button.disabled = not is_host or progression_locked or not gate_manager.can_purchase_core_upgrade()
	run_info_label.text = _compose_run_info(_latest_run_info_base)
	_refresh_scrap_display()


func _compose_run_info(base_message: String) -> String:
	return "%s%s" % [base_message, raid_manager.get_run_info_suffix()]


func _refresh_scrap_display() -> void:
	if scrap_panel == null:
		return
	var has_session := network_manager.multiplayer.multiplayer_peer != null
	scrap_panel.visible = has_session
	if not has_session:
		scrap_value_label.text = "0"
		return
	var scrap_amount := 0
	if gate_manager != null and gate_manager.has_method("get_stored_scrap"):
		scrap_amount = int(gate_manager.get_stored_scrap())
	scrap_value_label.text = str(scrap_amount)


func _refresh_claim_progress_ui() -> void:
	if claim_panel == null:
		return
	var snapshot = gate_manager.get_cave_status_snapshot()
	var claim_channel_remaining := float(snapshot.get("claim_channel_remaining", 0.0))
	var claim_event_active := bool(snapshot.get("claim_event_active", false))
	var visible = gate_manager.is_gate_active() and (claim_channel_remaining > 0.0 or claim_event_active)
	claim_panel.visible = visible
	if not visible:
		claim_progress_label.text = ""
		claim_progress_bar.value = 0.0
		return
	if claim_channel_remaining > 0.0:
		var channel_ratio = clamp(float(snapshot.get("claim_progress_ratio", 0.0)), 0.0, 1.0)
		claim_progress_label.text = "Pylon Claim Channel %0.1fs" % claim_channel_remaining
		claim_progress_bar.value = channel_ratio * 100.0
		return

	var total_waves = max(int(snapshot.get("claim_total_waves", 1)), 1)
	var wave_index = enemy_manager.get_wave_index()
	var completed_waves = max(wave_index - 1, 0)
	var wave_progress := 0.0
	var spawns_per_wave = max(enemy_manager.get_current_spawns_per_wave_count(), 1)
	var spawned_count = clamp(enemy_manager.get_wave_spawned_count(), 0, spawns_per_wave)
	var active_enemy_count = max(enemy_manager.get_active_enemy_count(), 0)
	var defeated_count = clamp(spawned_count - active_enemy_count, 0, spawns_per_wave)
	if enemy_manager.is_in_breather():
		completed_waves = min(wave_index, total_waves)
		wave_progress = 0.0
	else:
		var spawn_ratio := float(spawned_count) / float(spawns_per_wave)
		var defeat_ratio := float(defeated_count) / float(spawns_per_wave)
		wave_progress = clamp((spawn_ratio * 0.35) + (defeat_ratio * 0.65), 0.0, 1.0)
	completed_waves = clamp(completed_waves, 0, total_waves)
	var overall_ratio = clamp((float(completed_waves) + wave_progress) / float(total_waves), 0.0, 1.0)
	claim_progress_label.text = "Claim Waves %d/%d Cleared" % [completed_waves, total_waves]
	claim_progress_bar.value = overall_ratio * 100.0


func _refresh_cave_status_ui() -> void:
	if cave_panel == null:
		return
	var snapshot = gate_manager.get_cave_status_snapshot()
	var visible := bool(snapshot.get("visible", false))
	cave_panel.visible = visible
	if not visible:
		cave_state_value_label.text = ""
		cave_pressure_value_label.text = ""
		cave_reward_value_label.text = ""
		cave_detail_label.text = ""
		return

	var state_label := String(snapshot.get("state_label", "Locked"))
	var detail_label := String(snapshot.get("detail_label", ""))
	var reward_rate := float(snapshot.get("reward_rate", 0.0))
	var current_reward := int(floor(float(snapshot.get("current_reward", 0.0))))
	var cave_id := int(snapshot.get("cave_id", 0))
	var pressure_mode = enemy_manager.get_pressure_mode()
	var wave_index = enemy_manager.get_wave_index()
	var pressure_label := "Pressure Idle"
	if pressure_mode == "gate":
		pressure_label = "Pressure Wave %d" % wave_index
		if enemy_manager.is_in_breather():
			pressure_label += " | Breather %0.1fs" % enemy_manager.get_breather_time_remaining()
	elif pressure_mode == "raid":
		pressure_label = "Repair Wave %d" % wave_index
		if enemy_manager.is_in_breather():
			pressure_label += " | Breather %0.1fs" % enemy_manager.get_breather_time_remaining()

	var timer_label := ""
	if bool(snapshot.get("cave_active", false)):
		timer_label = " | Toggle with E"
	elif float(snapshot.get("cave_activation_remaining", 0.0)) > 0.0:
		timer_label = " | Opens in %0.1fs" % float(snapshot.get("cave_activation_remaining", 0.0))
	elif float(snapshot.get("claim_channel_remaining", 0.0)) > 0.0:
		timer_label = " | Claim in %0.1fs" % float(snapshot.get("claim_channel_remaining", 0.0))
	elif float(snapshot.get("repair_channel_remaining", 0.0)) > 0.0:
		timer_label = " | Repair in %0.1fs" % float(snapshot.get("repair_channel_remaining", 0.0))
	elif bool(snapshot.get("extraction_active", false)):
		timer_label = " | Extract %0.1fs" % float(snapshot.get("extraction_remaining", 0.0))

	var cave_suffix := ""
	if cave_id > 0:
		cave_suffix = " | Cave %d" % cave_id

	cave_state_value_label.text = "%s%s%s" % [state_label, cave_suffix, timer_label]
	cave_pressure_value_label.text = pressure_label
	cave_reward_value_label.text = "Gain +%0.1f/s | Bank %d" % [reward_rate, current_reward]
	cave_detail_label.text = detail_label


func _get_port() -> int:
	var parsed_port := int(port_input.text)
	if parsed_port <= 0:
		parsed_port = network_manager.default_port
		port_input.text = str(parsed_port)
	return parsed_port


func _refresh_status_overview() -> void:
	var has_session := network_manager.multiplayer.multiplayer_peer != null
	if not has_session:
		status_mode_label.text = "Offline"
		core_health_label.text = "Core: 300 / 300"
		core_health_bar.value = 100.0
		player_health_label.text = "Player: Not connected"
		player_health_bar.value = 0.0
		return

	var core_current := 0.0
	var core_maximum := 1.0
	if core_objective != null and core_objective.has_method("get_current_health"):
		core_current = float(core_objective.get_current_health())
		core_maximum = max(float(core_objective.max_health), 1.0)
	core_health_label.text = "Core: %d / %d" % [int(round(core_current)), int(round(core_maximum))]
	core_health_bar.value = clamp((core_current / core_maximum) * 100.0, 0.0, 100.0)

	var player := _local_player_node()
	if player == null:
		player_health_label.text = "Player: Spawning"
		player_health_bar.value = 0.0
		status_mode_label.text = _current_mode_label(null)
		return

	var player_current := float(player.current_health)
	var player_maximum = max(float(player.max_health), 1.0)
	player_health_label.text = "Player: %d / %d" % [int(round(player_current)), int(round(player_maximum))]
	player_health_bar.value = clamp((player_current / player_maximum) * 100.0, 0.0, 100.0)
	status_mode_label.text = _current_mode_label(player)


func _refresh_controls_panel() -> void:
	if controls_panel == null:
		return
	var has_session := network_manager.multiplayer.multiplayer_peer != null
	controls_panel.visible = has_session
	if not has_session:
		return
	var player := _local_player_node()
	controls_context_label.text = _current_mode_label(player)
	controls_body_label.text = _controls_hint_text(player)


func _local_player_node() -> Node:
	var local_peer_id := multiplayer.get_unique_id()
	for node in get_tree().get_nodes_in_group("players"):
		if node == null:
			continue
		if int(node.get("peer_id")) == local_peer_id:
			return node
	return null


func _current_mode_label(player: Node) -> String:
	if raid_manager.is_raid_active():
		return "Mode: Raid Defense"
	if raid_manager.is_upgrade_channeling():
		return "Mode: Town Hall Upgrade"
	if gate_manager.is_gate_active():
		if gate_manager.is_build_phase_active():
			return "Mode: Gate Build Phase"
		if gate_manager.is_extraction_active():
			return "Mode: Extraction"
		if gate_manager.is_cave_activation_channeling():
			return "Mode: Cave Activation"
		if gate_manager.is_repair_channeling():
			return "Mode: Pylon Repair"
		return "Mode: Gate Pressure"
	if player != null and player.has_method("is_build_mode_active") and player.is_build_mode_active():
		return "Mode: Base Building"
	return "Mode: Base Defense"


func _controls_hint_text(player: Node) -> String:
	if player != null and player.has_method("is_channel_locked") and player.is_channel_locked():
		return "Movement limited while channeling. Stay in range and press E when the objective asks for it."

	var hints: Array[String] = []
	hints.append("LMB attack")
	hints.append("E interact")
	hints.append("1 wall")
	hints.append("2 turret")

	var build_active := false
	var build_type := "wall"
	if player != null and player.has_method("is_build_mode_active"):
		build_active = player.is_build_mode_active()
	if player != null and player.has_method("get_current_build_type"):
		build_type = String(player.get_current_build_type()).capitalize()

	if build_active:
		hints.append("Q exit build")
		hints.append("R rotate")
		hints.append("Build: %s" % build_type)
		return " | ".join(hints) + " | LMB place"

	hints.append("Q enter build")
	return " | ".join(hints)


func _refresh_interaction_prompt() -> void:
	if interaction_prompt_panel == null:
		return
	var has_session := network_manager.multiplayer.multiplayer_peer != null
	if not has_session:
		interaction_prompt_panel.visible = false
		return
	var prompt: Dictionary = {"visible": false, "text": ""}
	if building_manager != null and building_manager.has_method("get_repair_prompt_for_peer"):
		prompt = building_manager.get_repair_prompt_for_peer(multiplayer.get_unique_id())
	interaction_prompt_panel.visible = bool(prompt.get("visible", false))
	interaction_prompt_label.text = String(prompt.get("text", ""))
