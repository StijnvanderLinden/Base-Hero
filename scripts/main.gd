extends Node3D

@onready var network_manager = $NetworkManager
@onready var enemy_manager = $EnemyManager
@onready var building_manager = $BuildingManager
@onready var cave_manager = $CaveManager
@onready var gate_manager = $GateManager
@onready var research_manager = $ResearchManager
@onready var raid_manager = $RaidManager
@onready var core_objective = $World/CoreObjective
@onready var startup_camera: Camera3D = $World/StartupCamera
@onready var build_grid_overlay: MeshInstance3D = $World/BuildGridOverlay
@onready var address_input: LineEdit = $UI/Panel/VBoxContainer/AddressInput
@onready var port_input: LineEdit = $UI/Panel/VBoxContainer/PortInput
@onready var host_button: Button = $UI/Panel/VBoxContainer/HostButton
@onready var join_button: Button = $UI/Panel/VBoxContainer/JoinButton
@onready var leave_button: Button = $UI/Panel/VBoxContainer/LeaveButton
@onready var gate_button: Button = $UI/Panel/VBoxContainer/GateButton
@onready var restart_button: Button = $UI/Panel/VBoxContainer/RestartButton
@onready var town_hall_upgrade_button: Button = $UI/Panel/VBoxContainer/TownHallUpgradeButton
@onready var core_upgrade_button: Button = $UI/Panel/VBoxContainer/CoreUpgradeButton
@onready var research_basic_button: Button = $UI/Panel/VBoxContainer/ResearchBasicButton
@onready var research_unlock_button: Button = $UI/Panel/VBoxContainer/ResearchUnlockButton
@onready var branch_unlock_button: Button = $UI/Panel/VBoxContainer/BranchUnlockButton
@onready var pylon_radius_upgrade_button: Button = $UI/Panel/VBoxContainer/PylonRadiusUpgradeButton
@onready var pylon_cap_upgrade_button: Button = $UI/Panel/VBoxContainer/PylonCapUpgradeButton
@onready var pylon_efficiency_upgrade_button: Button = $UI/Panel/VBoxContainer/PylonEfficiencyUpgradeButton
@onready var pylon_health_upgrade_button: Button = $UI/Panel/VBoxContainer/PylonHealthUpgradeButton
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

var _latest_run_info_base: String = "Base | Scrap 0 | Iron 0 | Essence 0 | Crystals 0 | Core Lv 0 | Max HP 300"


func _ready() -> void:
	network_manager.set_players_root($World/Players)
	enemy_manager.set_roots($World/Enemies, $World/Players)
	enemy_manager.set_objective(core_objective)
	enemy_manager.bind_network_manager(network_manager)
	building_manager.set_roots($World/Walls, $World/Projectiles, $World/Players, core_objective)
	building_manager.bind_network_manager(network_manager)
	building_manager.set_gate_manager(gate_manager)
	gate_manager.set_roots($World/GateContent, $World/Players, core_objective)
	gate_manager.set_research_manager(research_manager)
	gate_manager.set_cave_manager(cave_manager)
	gate_manager.set_enemy_manager(enemy_manager)
	gate_manager.set_building_manager(building_manager)
	gate_manager.bind_network_manager(network_manager)
	research_manager.bind_network_manager(network_manager)
	raid_manager.set_dependencies(enemy_manager, gate_manager, core_objective)
	raid_manager.bind_network_manager(network_manager)
	core_objective.bind_network_manager(network_manager)
	network_manager.status_changed.connect(_on_status_changed)
	building_manager.status_changed.connect(_on_status_changed)
	gate_manager.status_changed.connect(_on_status_changed)
	research_manager.status_changed.connect(_on_status_changed)
	raid_manager.status_changed.connect(_on_status_changed)
	gate_manager.run_info_changed.connect(_on_run_info_changed)
	gate_manager.gate_state_changed.connect(_on_gate_state_changed)
	gate_manager.progression_changed.connect(_refresh_progression_ui)
	research_manager.progression_changed.connect(_refresh_progression_ui)
	raid_manager.progression_changed.connect(_refresh_progression_ui)
	raid_manager.raid_state_changed.connect(_on_raid_state_changed)
	network_manager.session_changed.connect(_on_session_changed)
	core_objective.destroyed.connect(_on_core_destroyed)
	enemy_manager.wave_changed.connect(_on_wave_changed)

	address_input.text = "127.0.0.1"
	port_input.text = str(network_manager.default_port)
	_on_session_changed(false)
	_on_status_changed("Core defense prototype ready.")
	_on_run_info_changed(_latest_run_info_base)
	_refresh_progression_ui()
	_refresh_scrap_display()
	_refresh_claim_progress_ui()
	_refresh_cave_status_ui()
	_refresh_status_overview()
	_refresh_controls_panel()
	_refresh_interaction_prompt()
	_refresh_build_grid_overlay()


func _process(_delta: float) -> void:
	_refresh_status_overview()
	_refresh_controls_panel()
	_refresh_interaction_prompt()
	_refresh_build_grid_overlay()


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


func _on_research_basic_pressed() -> void:
	if not multiplayer.is_server():
		return
	research_manager.purchase_node("field_tools")
	_refresh_progression_ui()


func _on_research_unlock_pressed() -> void:
	if not multiplayer.is_server():
		return
	research_manager.purchase_node("augment_slot")
	_refresh_progression_ui()


func _on_branch_unlock_pressed() -> void:
	if not multiplayer.is_server():
		return
	research_manager.purchase_node("augment_branch")
	_refresh_progression_ui()


func _on_pylon_radius_upgrade_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.purchase_pylon_upgrade("base_radius")
	_refresh_progression_ui()


func _on_pylon_cap_upgrade_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.purchase_pylon_upgrade("max_radius")
	_refresh_progression_ui()


func _on_pylon_efficiency_upgrade_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.purchase_pylon_upgrade("channel_efficiency")
	_refresh_progression_ui()


func _on_pylon_health_upgrade_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.purchase_pylon_upgrade("health")
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
	_refresh_build_grid_overlay()
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
		_latest_run_info_base = "Base | Scrap 0 | Iron 0 | Essence 0 | Crystals 0 | Core Lv 0 | Max HP 300"
		run_info_label.text = _compose_run_info(_latest_run_info_base)
	else:
		status_label.text = "Base idle. Start a gate run or begin a town hall upgrade."
	_refresh_claim_progress_ui()
	_refresh_cave_status_ui()
	_refresh_progression_ui()
	_refresh_scrap_display()
	_refresh_status_overview()
	_refresh_controls_panel()
	_refresh_build_grid_overlay()


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
	var gate_active = gate_manager.is_gate_active()
	var next_cost = gate_manager.get_next_core_upgrade_cost()
	var next_level = gate_manager.get_core_upgrade_level() + 1
	var next_town_hall_cost = raid_manager.get_next_town_hall_upgrade_cost()
	var next_town_hall_level = raid_manager.get_town_hall_level() + 1
	if gate_active:
		gate_button.text = "Returning..." if gate_manager.is_extraction_active() else "Return to Base"
		gate_button.disabled = not is_host or not gate_manager.can_return_to_base()
	else:
		gate_button.text = "Start Gate Run"
		gate_button.disabled = not is_host or progression_locked
	town_hall_upgrade_button.text = "Upgrade Town Hall to Lv %d (%d Scrap)" % [next_town_hall_level, next_town_hall_cost]
	town_hall_upgrade_button.disabled = not is_host or not raid_manager.can_start_town_hall_upgrade()
	core_upgrade_button.text = "Upgrade Core to Lv %d (%d Scrap)" % [next_level, next_cost]
	core_upgrade_button.disabled = not is_host or progression_locked or not gate_manager.can_purchase_core_upgrade()
	_refresh_research_buttons(is_host, has_session, gate_active)
	_refresh_pylon_upgrade_buttons(is_host)
	run_info_label.text = _compose_run_info(_latest_run_info_base)
	_refresh_scrap_display()


func _refresh_research_buttons(is_host: bool, has_session: bool, gate_active: bool) -> void:
	var field_tools = research_manager.get_node_state("field_tools")
	var augment_slot = research_manager.get_node_state("augment_slot")
	var augment_branch = research_manager.get_node_state("augment_branch")
	research_basic_button.text = _research_button_text(field_tools, "Upgrade")
	research_unlock_button.text = _research_button_text(augment_slot, "Unlock")
	branch_unlock_button.text = _research_button_text(augment_branch, "Unlock")
	research_basic_button.disabled = not has_session or not is_host or gate_active or not research_manager.can_purchase_node("field_tools")
	research_unlock_button.disabled = not has_session or not is_host or gate_active or not research_manager.can_purchase_node("augment_slot")
	branch_unlock_button.disabled = not has_session or not is_host or gate_active or not research_manager.can_purchase_node("augment_branch")


func _refresh_pylon_upgrade_buttons(is_host: bool) -> void:
	pylon_radius_upgrade_button.text = "Upgrade Base Radius (%d Essence)" % gate_manager._pylon_upgrade_cost("base_radius")
	pylon_cap_upgrade_button.text = "Upgrade Radius Cap (%d Essence)" % gate_manager._pylon_upgrade_cost("max_radius")
	pylon_efficiency_upgrade_button.text = "Upgrade Channel Efficiency (%d Essence)" % gate_manager._pylon_upgrade_cost("channel_efficiency")
	pylon_health_upgrade_button.text = "Upgrade Pylon Integrity (%d Essence)" % gate_manager._pylon_upgrade_cost("health")
	pylon_radius_upgrade_button.disabled = not is_host or not gate_manager.can_purchase_pylon_upgrade("base_radius")
	pylon_cap_upgrade_button.disabled = not is_host or not gate_manager.can_purchase_pylon_upgrade("max_radius")
	pylon_efficiency_upgrade_button.disabled = not is_host or not gate_manager.can_purchase_pylon_upgrade("channel_efficiency")
	pylon_health_upgrade_button.disabled = not is_host or not gate_manager.can_purchase_pylon_upgrade("health")


func _research_button_text(node_state: Dictionary, action_verb: String) -> String:
	if node_state.is_empty():
		return "Research Unavailable"
	var display_name := String(node_state.get("display_name", "Research"))
	var level := int(node_state.get("level", 0))
	var max_level := int(node_state.get("max_level", 1))
	if level >= max_level:
		return "%s Maxed" % display_name
	var essence_cost := int(node_state.get("essence_cost", 0))
	var crystal_cost := int(node_state.get("crystal_cost", 0))
	var cost_parts: Array[String] = []
	if essence_cost > 0:
		cost_parts.append("%d Essence" % essence_cost)
	if crystal_cost > 0:
		cost_parts.append("%d Crystals" % crystal_cost)
	if cost_parts.is_empty():
		cost_parts.append("Free")
	return "%s %s (%s)" % [action_verb, display_name, " + ".join(cost_parts)]


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
	var visible = gate_manager.is_gate_active() and bool(snapshot.get("channel_active", false))
	claim_panel.visible = visible
	if not visible:
		claim_progress_label.text = ""
		claim_progress_bar.value = 0.0
		return
	var elapsed := float(snapshot.get("channel_elapsed", 0.0))
	var current_radius := int(round(float(snapshot.get("influence_radius", 0.0))))
	var max_radius := int(round(float(snapshot.get("max_radius", 0.0))))
	claim_progress_label.text = "Channel %0.1fs | Radius %d/%d" % [elapsed, current_radius, max_radius]
	claim_progress_bar.value = clamp(float(snapshot.get("channel_progress_ratio", 0.0)), 0.0, 1.0) * 100.0


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
	var influence_radius := int(round(float(snapshot.get("influence_radius", 0.0))))
	var max_radius := int(round(float(snapshot.get("max_radius", 0.0))))
	var crystals_remaining := int(snapshot.get("crystals_remaining", 0))
	var ore_revealed := int(snapshot.get("ore_revealed", 0))
	var herbs_revealed := int(snapshot.get("herbs_revealed", 0))
	var caves_revealed := int(snapshot.get("caves_revealed", 0))
	var treasure_revealed := int(snapshot.get("treasure_revealed", 0))
	var pending_essence := int(floor(float(snapshot.get("current_reward", 0.0))))
	var reward_rate := float(snapshot.get("reward_rate", 0.0))
	var timer_label := ""
	if bool(snapshot.get("channel_active", false)):
		timer_label = " | Stop with E"
	elif bool(snapshot.get("extraction_active", false)):
		timer_label = " | Extract %0.1fs" % float(snapshot.get("extraction_remaining", 0.0))
	cave_state_value_label.text = "%s | Pylon Lv %d%s" % [state_label, int(snapshot.get("pylon_level", 1)), timer_label]
	cave_pressure_value_label.text = "Influence %d/%d | Crystals in range %d" % [influence_radius, max_radius, crystals_remaining]
	cave_reward_value_label.text = "Reveal Ore %d | Herbs %d | Caves %d | Treasure %d | +%0.1f/s | Pending %d" % [ore_revealed, herbs_revealed, caves_revealed, treasure_revealed, reward_rate, pending_essence]
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
		if gate_manager.is_extraction_active():
			return "Mode: Extraction"
		if gate_manager.get_gate_pylon_state() == "unplaced":
			return "Mode: Expedition Search"
		if gate_manager.get_gate_pylon_state() == "damaged":
			return "Mode: Pylon Lost"
		if bool(gate_manager.get_pylon_status_snapshot().get("channel_active", false)):
			return "Mode: Pylon Channeling"
		if gate_manager.is_extraction_active():
			return "Mode: Extraction"
		return "Mode: Pylon Setup"
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
	var wall_segment_active := false
	if player != null and player.has_method("is_build_mode_active"):
		build_active = player.is_build_mode_active()
	if player != null and player.has_method("get_current_build_type"):
		build_type = String(player.get_current_build_type()).capitalize()
	if player != null and player.has_method("is_wall_segment_active"):
		wall_segment_active = player.is_wall_segment_active()

	if gate_manager.is_gate_active() and gate_manager.get_gate_pylon_state() == "unplaced":
		hints.append("Place pylon with E")
	if gate_manager.is_gate_active() and bool(gate_manager.get_pylon_status_snapshot().get("channel_active", false)):
		hints.append("E stop channel")
	if build_active:
		if wall_segment_active:
			hints.append("Q cancel wall")
			hints.append("RMB cancel")
		else:
			hints.append("Q exit build")
		hints.append("R rotate")
		hints.append("Build: %s" % build_type)
		if wall_segment_active:
			return " | ".join(hints) + " | LMB confirm end"
		if build_type == "Wall":
			return " | ".join(hints) + " | LMB set start"
		return " | ".join(hints) + " | LMB place"

	hints.append("Q enter build")
	return " | ".join(hints)


func _refresh_build_grid_overlay() -> void:
	if build_grid_overlay == null:
		return
	var player := _local_player_node()
	var has_session := network_manager.multiplayer.multiplayer_peer != null
	var show_overlay := false
	if has_session and player != null and player.has_method("is_build_mode_active"):
		show_overlay = player.is_build_mode_active()
	build_grid_overlay.visible = show_overlay
	if not show_overlay:
		return
	var area_center := Vector3.ZERO
	var area_size := 36.0
	var grid_size := 2.0
	if building_manager != null:
		if building_manager.has_method("get_active_build_area_center"):
			area_center = building_manager.get_active_build_area_center()
		if building_manager.has_method("get_active_build_area_size"):
			area_size = float(building_manager.get_active_build_area_size())
		if building_manager.has_method("get_grid_size"):
			grid_size = float(building_manager.get_grid_size())
	build_grid_overlay.global_position = Vector3(area_center.x, 0.56, area_center.z)
	build_grid_overlay.scale = Vector3(area_size, 1.0, area_size)
	var material := build_grid_overlay.get_active_material(0) as ShaderMaterial
	if material != null:
		material.set_shader_parameter("cells_per_side", max(area_size / max(grid_size, 0.001), 1.0))


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
	if not bool(prompt.get("visible", false)) and gate_manager != null and gate_manager.has_method("get_interaction_prompt_for_peer"):
		prompt = gate_manager.get_interaction_prompt_for_peer(multiplayer.get_unique_id())
	interaction_prompt_panel.visible = bool(prompt.get("visible", false))
	interaction_prompt_label.text = String(prompt.get("text", ""))
