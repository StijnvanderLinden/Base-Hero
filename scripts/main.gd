extends Node3D

const BASE_OBJECTIVE_INTERACTION_RADIUS := 4.0
const ERA_MANAGER_SCRIPT := preload("res://scripts/era_manager.gd")

@onready var network_manager = $NetworkManager
@onready var enemy_manager = $EnemyManager
@onready var building_manager = $BuildingManager
@onready var cave_manager = $CaveManager
@onready var gate_manager = $GateManager
@onready var world_generator = $WorldGenerator
@onready var research_manager = $ResearchManager
@onready var core_objective = $World/CoreObjective
@onready var startup_camera: Camera3D = $World/StartupCamera
@onready var build_grid_overlay: MeshInstance3D = $World/BuildGridOverlay
@onready var side_menu_dimmer: ColorRect = $UI/SideMenuDimmer
@onready var side_menu_panel: PanelContainer = $UI/Panel
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
@onready var info_menu_button: Button = $UI/Panel/VBoxContainer/InfoMenuButton
@onready var scrap_panel: PanelContainer = $UI/ScrapPanel
@onready var scrap_value_label: Label = $UI/ScrapPanel/HBoxContainer/ScrapValueLabel
@onready var run_panel: PanelContainer = $UI/RunPanel
@onready var status_mode_label: Label = $UI/StatusPanel/VBoxContainer/ModeLabel
@onready var core_health_label: Label = $UI/StatusPanel/VBoxContainer/CoreHealthLabel
@onready var core_health_bar: ProgressBar = $UI/StatusPanel/VBoxContainer/CoreHealthBar
@onready var player_health_label: Label = $UI/StatusPanel/VBoxContainer/PlayerHealthLabel
@onready var player_health_bar: ProgressBar = $UI/StatusPanel/VBoxContainer/PlayerHealthBar
@onready var status_label: Label = $UI/StatusPanel/VBoxContainer/StatusLabel
@onready var status_panel: PanelContainer = $UI/StatusPanel
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
@onready var tooltip_modal: Control = $UI/TooltipModal
@onready var tooltip_title_label: Label = $UI/TooltipModal/Card/MarginContainer/HBoxContainer/Content/TooltipTitleLabel
@onready var tooltip_body_label: Label = $UI/TooltipModal/Card/MarginContainer/HBoxContainer/Content/TooltipBodyLabel
@onready var tooltip_run_button: Button = $UI/TooltipModal/Card/MarginContainer/HBoxContainer/Nav/RunTooltipButton
@onready var tooltip_pylon_button: Button = $UI/TooltipModal/Card/MarginContainer/HBoxContainer/Nav/PylonTooltipButton
@onready var tooltip_status_button: Button = $UI/TooltipModal/Card/MarginContainer/HBoxContainer/Nav/StatusTooltipButton
@onready var tooltip_controls_button: Button = $UI/TooltipModal/Card/MarginContainer/HBoxContainer/Nav/ControlsTooltipButton
@onready var tooltip_close_button: Button = $UI/TooltipModal/Card/MarginContainer/HBoxContainer/Nav/CloseTooltipButton
@onready var action_modal: Control = $UI/ActionModal
@onready var action_title_label: Label = $UI/ActionModal/Card/MarginContainer/VBoxContainer/ActionTitleLabel
@onready var action_body_label: Label = $UI/ActionModal/Card/MarginContainer/VBoxContainer/ActionBodyLabel
@onready var action_buttons_container: VBoxContainer = $UI/ActionModal/Card/MarginContainer/VBoxContainer/ActionScroll/ActionsContainer
@onready var action_close_button: Button = $UI/ActionModal/Card/MarginContainer/VBoxContainer/CloseActionButton

var _latest_run_info_base: String = "Base | Scrap 0 | Stone 0 | Wood 0 | Herbs 0 | Essence 0 | Crystals 0 | Core Lv 0 | Max HP 300"
var _side_menu_open: bool = false
var _tooltip_modal_open: bool = false
var _selected_tooltip_id: String = "run"
var _action_modal_open: bool = false
var _action_modal_kind: String = ""
var era_manager: Node


func _ready() -> void:
	add_to_group("main_root")
	era_manager = ERA_MANAGER_SCRIPT.new()
	era_manager.name = "EraManager"
	add_child(era_manager)
	network_manager.set_players_root($World/Players)
	enemy_manager.set_roots($World/Enemies, $World/Players)
	enemy_manager.set_objective(core_objective)
	enemy_manager.bind_network_manager(network_manager)
	enemy_manager.set_era_manager(era_manager)
	enemy_manager.set_gate_manager(gate_manager)
	world_generator.set_dependencies($World, $World/GateFloor)
	world_generator.bind_network_manager(network_manager)
	building_manager.set_roots($World/Walls, $World/Projectiles, $World/Players, core_objective)
	building_manager.bind_network_manager(network_manager)
	building_manager.set_gate_manager(gate_manager)
	building_manager.set_research_manager(research_manager)
	building_manager.set_era_manager(era_manager)
	gate_manager.set_roots($World/GateContent, $World/Players, core_objective)
	gate_manager.set_world_generator(world_generator)
	gate_manager.set_research_manager(research_manager)
	gate_manager.set_cave_manager(cave_manager)
	gate_manager.set_enemy_manager(enemy_manager)
	gate_manager.set_building_manager(building_manager)
	gate_manager.set_era_manager(era_manager)
	gate_manager.bind_network_manager(network_manager)
	research_manager.bind_network_manager(network_manager)
	research_manager.set_era_manager(era_manager)
	core_objective.bind_network_manager(network_manager)
	network_manager.status_changed.connect(_on_status_changed)
	building_manager.status_changed.connect(_on_status_changed)
	gate_manager.status_changed.connect(_on_status_changed)
	research_manager.status_changed.connect(_on_status_changed)
	gate_manager.run_info_changed.connect(_on_run_info_changed)
	gate_manager.gate_state_changed.connect(_on_gate_state_changed)
	gate_manager.progression_changed.connect(_refresh_progression_ui)
	research_manager.progression_changed.connect(_refresh_progression_ui)
	network_manager.session_changed.connect(_on_session_changed)
	era_manager.era_changed.connect(_on_era_changed)
	core_objective.destroyed.connect(_on_core_destroyed)
	enemy_manager.wave_changed.connect(_on_wave_changed)
	info_menu_button.pressed.connect(_on_info_menu_pressed)
	tooltip_run_button.pressed.connect(func() -> void: _show_tooltip("run"))
	tooltip_pylon_button.pressed.connect(func() -> void: _show_tooltip("pylon"))
	tooltip_status_button.pressed.connect(func() -> void: _show_tooltip("status"))
	tooltip_controls_button.pressed.connect(func() -> void: _show_tooltip("controls"))
	tooltip_close_button.pressed.connect(_close_tooltip_modal)
	action_close_button.pressed.connect(_close_action_modal)

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
	_configure_side_menu_buttons()
	_hide_legacy_info_panels()
	_set_side_menu_open(false)
	_set_tooltip_modal_open(false)
	_set_action_modal_open(false, "")


func _process(_delta: float) -> void:
	_refresh_status_overview()
	_refresh_controls_panel()
	_refresh_interaction_prompt()
	_refresh_build_grid_overlay()
	if _tooltip_modal_open:
		_refresh_tooltip_modal()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		if not _tooltip_modal_open and not _action_modal_open:
			_set_side_menu_open(not _side_menu_open)
			get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not _tooltip_modal_open and not _action_modal_open:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if _action_modal_open:
			_close_action_modal()
		else:
			_close_tooltip_modal()
		get_viewport().set_input_as_handled()


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


func _on_era_changed(_era_id: String) -> void:
	_refresh_progression_ui()
	_refresh_tooltip_modal()


func _on_town_hall_upgrade_pressed() -> void:
	_show_action_modal("hub")


func _on_restart_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.restart_match()
	cave_manager.clear_all_runtime_state()
	building_manager.restart_match()
	enemy_manager.force_restart()
	core_objective.restart_match()
	network_manager.restart_match()
	restart_button.disabled = false
	status_label.text = "Hub idle. Configure a run layout or enter the selected era."
	_refresh_progression_ui()


func _on_core_upgrade_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.purchase_core_upgrade()
	_refresh_progression_ui()


func _on_research_basic_pressed() -> void:
	if not multiplayer.is_server():
		return
	var visible_nodes := _visible_research_node_ids()
	if visible_nodes.size() > 0:
		research_manager.purchase_node(visible_nodes[0])
	_refresh_progression_ui()


func _on_research_unlock_pressed() -> void:
	if not multiplayer.is_server():
		return
	var visible_nodes := _visible_research_node_ids()
	if visible_nodes.size() > 1:
		research_manager.purchase_node(visible_nodes[1])
	_refresh_progression_ui()


func _on_branch_unlock_pressed() -> void:
	if not multiplayer.is_server():
		return
	var visible_nodes := _visible_research_node_ids()
	if visible_nodes.size() > 2:
		research_manager.purchase_node(visible_nodes[2])
	_refresh_progression_ui()


func _on_pylon_radius_upgrade_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.purchase_run_upgrade("base_radius")
	_refresh_progression_ui()


func _on_pylon_cap_upgrade_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.purchase_run_upgrade("max_radius")
	_refresh_progression_ui()


func _on_pylon_efficiency_upgrade_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.purchase_run_upgrade("channel_efficiency")
	_refresh_progression_ui()


func _on_pylon_health_upgrade_pressed() -> void:
	if not multiplayer.is_server():
		return
	gate_manager.purchase_run_upgrade("health")
	_refresh_progression_ui()


func _on_info_menu_pressed() -> void:
	_set_side_menu_open(false)
	_show_tooltip(_selected_tooltip_id)


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
	_refresh_tooltip_modal()


func _on_session_changed(in_session: bool) -> void:
	host_button.disabled = in_session
	join_button.disabled = in_session
	leave_button.disabled = not in_session
	restart_button.disabled = not in_session or not multiplayer.is_server()
	address_input.editable = not in_session
	port_input.editable = not in_session
	if not in_session:
		_set_action_modal_open(false, "")
		_set_tooltip_modal_open(false)
		_set_side_menu_open(false)
		cave_manager.clear_all_runtime_state()
		startup_camera.current = true
		_latest_run_info_base = "Base | Scrap 0 | Stone 0 | Wood 0 | Herbs 0 | Essence 0 | Crystals 0 | Core Lv 0 | Max HP 300"
		run_info_label.text = _compose_run_info(_latest_run_info_base)
	else:
		status_label.text = "Hub idle. Start an era run when ready."
	_refresh_claim_progress_ui()
	_refresh_cave_status_ui()
	_refresh_progression_ui()
	_refresh_scrap_display()
	_refresh_status_overview()
	_refresh_controls_panel()
	_refresh_build_grid_overlay()
	_refresh_tooltip_modal()


func _on_core_destroyed() -> void:
	status_label.text = "Core destroyed. Press Restart Session to rerun the defense test."


func _on_wave_changed(wave_index: int, is_breather: bool) -> void:
	if gate_manager.is_gate_active():
		_refresh_claim_progress_ui()
		_refresh_cave_status_ui()
		if enemy_manager.get_pressure_mode() == "gate":
			if is_breather:
				status_label.text = "Stone Age wave %d cleared. Short breather before the next push." % wave_index
				return
			status_label.text = "Stone Age wave %d live. Keep the core standing through the pressure." % wave_index
			return
	if gate_manager.is_gate_active():
		return
	if not network_manager.multiplayer.multiplayer_peer:
		return
	if enemy_manager.get_pressure_mode() == "idle":
		return
	if is_breather:
		status_label.text = "Wave %d cleared. Breather before next push." % wave_index
		return
	status_label.text = "Wave %d live. LMB attacks, SPACE jumps, Q toggles build, R rotates." % wave_index


func _on_gate_state_changed(is_active: bool) -> void:
	if is_active:
		gate_button.text = "Leave Run"
		_refresh_claim_progress_ui()
		_refresh_cave_status_ui()
		_refresh_progression_ui()
		return
	gate_button.text = "Start Era Run"
	_refresh_claim_progress_ui()
	_refresh_cave_status_ui()
	_refresh_progression_ui()
	_refresh_status_overview()
	_refresh_controls_panel()


func _refresh_progression_ui() -> void:
	var has_session := network_manager.multiplayer.multiplayer_peer != null
	var is_host := has_session and multiplayer.is_server()
	var gate_active = gate_manager.is_gate_active()
	var next_cost = gate_manager.get_next_core_upgrade_cost()
	var next_level = gate_manager.get_core_upgrade_level() + 1
	var selected_era_name := _selected_era_name()
	if gate_active:
		gate_button.text = "Extracting..." if gate_manager.is_extraction_active() else "Leave Run"
		gate_button.disabled = not is_host or not gate_manager.can_return_to_base()
	else:
		gate_button.text = "Enter %s" % selected_era_name
		gate_button.disabled = not is_host
	town_hall_upgrade_button.text = "Hub Console"
	town_hall_upgrade_button.disabled = true
	core_upgrade_button.text = "Upgrade Core to Lv %d (%d Scrap)" % [next_level, next_cost]
	core_upgrade_button.disabled = not is_host or not gate_manager.can_purchase_core_upgrade()
	_refresh_research_buttons(is_host, has_session, gate_active)
	_refresh_pylon_upgrade_buttons(is_host)
	_configure_side_menu_buttons()
	run_info_label.text = _compose_run_info(_latest_run_info_base)
	_refresh_scrap_display()


func _refresh_research_buttons(is_host: bool, has_session: bool, gate_active: bool) -> void:
	var visible_nodes := _visible_research_node_ids()
	var node_a := visible_nodes[0] if visible_nodes.size() > 0 else ""
	var node_b := visible_nodes[1] if visible_nodes.size() > 1 else ""
	var node_c := visible_nodes[2] if visible_nodes.size() > 2 else ""
	var state_a = research_manager.get_node_state(node_a) if node_a != "" else {}
	var state_b = research_manager.get_node_state(node_b) if node_b != "" else {}
	var state_c = research_manager.get_node_state(node_c) if node_c != "" else {}
	research_basic_button.text = _research_button_text(state_a, _research_action_verb(state_a))
	research_unlock_button.text = _research_button_text(state_b, _research_action_verb(state_b))
	branch_unlock_button.text = _research_button_text(state_c, _research_action_verb(state_c))
	research_basic_button.disabled = node_a == "" or not has_session or not is_host or gate_active or not research_manager.can_purchase_node(node_a)
	research_unlock_button.disabled = node_b == "" or not has_session or not is_host or gate_active or not research_manager.can_purchase_node(node_b)
	branch_unlock_button.disabled = node_c == "" or not has_session or not is_host or gate_active or not research_manager.can_purchase_node(node_c)
	research_basic_button.visible = false
	research_unlock_button.visible = false
	branch_unlock_button.visible = false


func _refresh_pylon_upgrade_buttons(is_host: bool) -> void:
	pylon_radius_upgrade_button.text = "Upgrade Base Radius (%d Essence)" % gate_manager._pylon_upgrade_cost("base_radius")
	pylon_cap_upgrade_button.text = "Upgrade Radius Cap (%d Essence)" % gate_manager._pylon_upgrade_cost("max_radius")
	pylon_efficiency_upgrade_button.text = "Upgrade Channel Efficiency (%d Essence)" % gate_manager._pylon_upgrade_cost("channel_efficiency")
	pylon_health_upgrade_button.text = "Upgrade Core Integrity (%d Essence)" % gate_manager._pylon_upgrade_cost("health")
	pylon_radius_upgrade_button.disabled = not is_host or not gate_manager.can_purchase_run_upgrade("base_radius")
	pylon_cap_upgrade_button.disabled = not is_host or not gate_manager.can_purchase_run_upgrade("max_radius")
	pylon_efficiency_upgrade_button.disabled = not is_host or not gate_manager.can_purchase_run_upgrade("channel_efficiency")
	pylon_health_upgrade_button.disabled = not is_host or not gate_manager.can_purchase_run_upgrade("health")
	pylon_radius_upgrade_button.visible = false
	pylon_cap_upgrade_button.visible = false
	pylon_efficiency_upgrade_button.visible = false
	pylon_health_upgrade_button.visible = false


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


func _visible_research_node_ids() -> Array[String]:
	if research_manager == null or not research_manager.has_method("get_visible_node_ids"):
		return []
	return research_manager.get_visible_node_ids()


func _research_action_verb(node_state: Dictionary) -> String:
	var node_type := String(node_state.get("type", "research"))
	if node_type == "structure" or node_type == "branch" or node_type == "core":
		return "Unlock"
	return "Upgrade"


func _compose_run_info(base_message: String) -> String:
	return base_message


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
	var snapshot = gate_manager.get_channel_status_snapshot()
	var visible = gate_manager.is_gate_active() and bool(snapshot.get("channel_active", false)) and not _tooltip_modal_open
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
	var snapshot = gate_manager.get_channel_status_snapshot()
	var visible := bool(snapshot.get("visible", false))
	cave_panel.visible = false
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
	var stone_revealed := int(snapshot.get("stone_revealed", snapshot.get("ore_revealed", 0)))
	var wood_revealed := int(snapshot.get("wood_revealed", 0))
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
	cave_state_value_label.text = "%s | Channel Tier %d%s" % [state_label, int(snapshot.get("pylon_level", 1)), timer_label]
	cave_pressure_value_label.text = "Influence %d/%d | Crystals in range %d" % [influence_radius, max_radius, crystals_remaining]
	cave_reward_value_label.text = "Reveal Stone %d | Wood %d | Herbs %d | Treasure %d | +%0.1f/s | Pending %d" % [stone_revealed, wood_revealed, herbs_revealed, treasure_revealed, reward_rate, pending_essence]
	cave_detail_label.text = detail_label
	_refresh_tooltip_modal()


func _get_port() -> int:
	var parsed_port := int(port_input.text)
	if parsed_port <= 0:
		parsed_port = network_manager.default_port
		port_input.text = str(parsed_port)
	return parsed_port


func _refresh_status_overview() -> void:
	var has_session := network_manager.multiplayer.multiplayer_peer != null
	status_panel.visible = false
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
	controls_panel.visible = false
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
	if gate_manager.is_gate_active():
		if gate_manager.is_extraction_active():
			return "Mode: Extraction"
		if gate_manager.get_run_base_state() == "unplaced":
			return "Mode: Run Setup"
		if gate_manager.get_run_base_state() == "damaged":
			return "Mode: Core Lost"
		if bool(gate_manager.get_channel_status_snapshot().get("channel_active", false)):
			return "Mode: Core Channeling"
		if gate_manager.is_extraction_active():
			return "Mode: Extraction"
		return "Mode: Core Ready"
	if player != null and player.has_method("is_build_mode_active") and player.is_build_mode_active():
		return "Mode: Base Building"
	return "Mode: Hub"


func _controls_hint_text(player: Node) -> String:
	if player != null and player.has_method("is_channel_locked") and player.is_channel_locked():
		return "Movement limited while channeling. Stay in range and press E when the objective asks for it."

	var hints: Array[String] = []
	var weapon_mode := "melee"
	if player != null and player.has_method("get_weapon_mode"):
		weapon_mode = String(player.get_weapon_mode())
	hints.append("LMB %s" % ("slash" if weapon_mode == "melee" else "shoot"))
	hints.append("RMB heavy")
	hints.append("F switch weapon")
	hints.append("SPACE jump")
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

	if gate_manager.is_gate_active() and gate_manager.get_run_base_state() == "unplaced":
		hints.append("E activate run base")
	if gate_manager.is_gate_active() and gate_manager.get_run_base_state() != "unplaced":
		hints.append("E open core console")
	if not gate_manager.is_gate_active():
		hints.append("E hub console")
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
	hints.append("TAB menu")
	return " | ".join(hints)


func _refresh_build_grid_overlay() -> void:
	if build_grid_overlay == null:
		return
	var player := _local_player_node()
	var has_session := network_manager.multiplayer.multiplayer_peer != null
	var show_overlay := false
	if has_session and player != null and player.has_method("is_build_mode_active"):
		show_overlay = player.is_build_mode_active()
	if _is_any_overlay_open():
		show_overlay = false
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
			var active_area_size = building_manager.get_active_build_area_size()
			if active_area_size is Vector2:
				area_size = max(active_area_size.x, active_area_size.y)
			else:
				area_size = float(active_area_size)
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
	if not has_session or _is_any_overlay_open():
		interaction_prompt_panel.visible = false
		return
	var prompt: Dictionary = {"visible": false, "text": ""}
	if building_manager != null and building_manager.has_method("get_repair_prompt_for_peer"):
		prompt = building_manager.get_repair_prompt_for_peer(multiplayer.get_unique_id())
	if not bool(prompt.get("visible", false)) and gate_manager != null and gate_manager.has_method("get_interaction_prompt_for_peer"):
		prompt = gate_manager.get_interaction_prompt_for_peer(multiplayer.get_unique_id())
	if not bool(prompt.get("visible", false)):
		prompt = _get_base_interaction_prompt(multiplayer.get_unique_id())
	interaction_prompt_panel.visible = bool(prompt.get("visible", false))
	interaction_prompt_label.text = String(prompt.get("text", ""))


func _configure_side_menu_buttons() -> void:
	town_hall_upgrade_button.visible = false
	core_upgrade_button.visible = false
	research_basic_button.visible = false
	research_unlock_button.visible = false
	branch_unlock_button.visible = false
	pylon_radius_upgrade_button.visible = false
	pylon_cap_upgrade_button.visible = false
	pylon_efficiency_upgrade_button.visible = false
	pylon_health_upgrade_button.visible = false
	info_menu_button.visible = true


func _hide_legacy_info_panels() -> void:
	run_panel.visible = false
	cave_panel.visible = false
	status_panel.visible = false
	controls_panel.visible = false


func _show_tooltip(tooltip_id: String) -> void:
	_selected_tooltip_id = tooltip_id
	_set_side_menu_open(false)
	_set_action_modal_open(false, "")
	_set_tooltip_modal_open(true)
	_refresh_tooltip_modal()


func _close_tooltip_modal() -> void:
	_set_tooltip_modal_open(false)


func _set_tooltip_modal_open(active: bool) -> void:
	_tooltip_modal_open = active
	tooltip_modal.visible = active
	_hide_legacy_info_panels()
	_refresh_overlay_input_state()
	if active:
		_refresh_tooltip_modal()


func _set_local_player_ui_locked(active: bool) -> void:
	var player := _local_player_node()
	if player != null and player.has_method("set_ui_locked"):
		player.set_ui_locked(active)


func _set_side_menu_open(active: bool) -> void:
	_side_menu_open = active
	side_menu_panel.visible = active
	side_menu_dimmer.visible = active
	if not active:
		get_viewport().gui_release_focus()
	if active:
		_set_tooltip_modal_open(false)
		_set_action_modal_open(false, "")
	_refresh_overlay_input_state()


func _show_action_modal(kind: String) -> void:
	_set_side_menu_open(false)
	_set_tooltip_modal_open(false)
	_set_action_modal_open(true, kind)


func _close_action_modal() -> void:
	_set_action_modal_open(false, "")


func _set_action_modal_open(active: bool, kind: String) -> void:
	_action_modal_open = active
	_action_modal_kind = kind
	action_modal.visible = active
	_refresh_overlay_input_state()
	if active:
		_refresh_action_modal()


func _is_any_overlay_open() -> bool:
	return _side_menu_open or _tooltip_modal_open or _action_modal_open


func _refresh_overlay_input_state() -> void:
	_set_local_player_ui_locked(_is_any_overlay_open())
	var has_session := network_manager.multiplayer.multiplayer_peer != null
	if _is_any_overlay_open() or not has_session or _local_player_node() == null:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_refresh_claim_progress_ui()
	_refresh_interaction_prompt()
	_refresh_build_grid_overlay()


func handle_local_interaction(peer_id: int) -> bool:
	if _is_any_overlay_open():
		return false
	if building_manager != null and building_manager.has_method("get_repair_prompt_for_peer"):
		var structure_prompt: Dictionary = building_manager.get_repair_prompt_for_peer(peer_id)
		if bool(structure_prompt.get("visible", false)):
			return false
	if gate_manager != null and gate_manager.has_method("can_open_core_console_for_peer") and gate_manager.can_open_core_console_for_peer(peer_id):
		_show_action_modal("core")
		return true
	if _can_open_hub_console_for_peer(peer_id):
		_show_action_modal("hub")
		return true
	return false


func _can_open_hub_console_for_peer(peer_id: int) -> bool:
	if network_manager.multiplayer.multiplayer_peer == null:
		return false
	if gate_manager.is_gate_active():
		return false
	if core_objective == null:
		return false
	var player := _local_player_node()
	if player == null or int(player.get("peer_id")) != peer_id:
		return false
	return player.global_position.distance_to(core_objective.global_position) <= BASE_OBJECTIVE_INTERACTION_RADIUS


func _get_base_interaction_prompt(peer_id: int) -> Dictionary:
	if _can_open_hub_console_for_peer(peer_id):
		return {"visible": true, "text": "Press E to open hub console"}
	return {"visible": false, "text": ""}


func _refresh_tooltip_modal() -> void:
	if tooltip_modal == null or not _tooltip_modal_open:
		return
	tooltip_run_button.disabled = _selected_tooltip_id == "run"
	tooltip_pylon_button.disabled = _selected_tooltip_id == "pylon"
	tooltip_status_button.disabled = _selected_tooltip_id == "status"
	tooltip_controls_button.disabled = _selected_tooltip_id == "controls"
	match _selected_tooltip_id:
		"pylon":
			tooltip_title_label.text = "Channel Status"
			tooltip_body_label.text = _tooltip_pylon_text()
		"status":
			tooltip_title_label.text = "Status"
			tooltip_body_label.text = _tooltip_status_text()
		"controls":
			tooltip_title_label.text = "Controls"
			tooltip_body_label.text = _tooltip_controls_text()
		_:
			tooltip_title_label.text = "Run Summary"
			tooltip_body_label.text = _tooltip_run_text()


func _tooltip_run_text() -> String:
	return run_info_label.text


func _tooltip_pylon_text() -> String:
	var sections: Array[String] = []
	if cave_state_value_label.text != "":
		sections.append("State\n%s" % cave_state_value_label.text)
	if cave_pressure_value_label.text != "":
		sections.append("Influence\n%s" % cave_pressure_value_label.text)
	if cave_reward_value_label.text != "":
		sections.append("Tracking\n%s" % cave_reward_value_label.text)
	if cave_detail_label.text != "":
		sections.append("Detail\n%s" % cave_detail_label.text)
	if sections.is_empty():
		return "No active channel information right now."
	return "\n\n".join(sections)


func _tooltip_status_text() -> String:
	return "Mode\n%s\n\nCore\n%s\n\nPlayer\n%s\n\nState\n%s" % [status_mode_label.text, core_health_label.text, player_health_label.text, status_label.text]


func _tooltip_controls_text() -> String:
	return "%s\n\n%s" % [controls_context_label.text, controls_body_label.text]


func _refresh_action_modal() -> void:
	if not _action_modal_open or action_modal == null:
		return
	for child in action_buttons_container.get_children():
		action_buttons_container.remove_child(child)
		child.queue_free()
	match _action_modal_kind:
		"hub":
			action_title_label.text = "Hub Console"
			action_body_label.text = _hub_console_text()
			_add_action_button(
				"Select Next Era: %s" % _selected_era_name(),
				Callable(self, "_action_cycle_era"),
				not multiplayer.is_server()
			)
			_add_action_button(
				"Save %s Layout" % _selected_era_name(),
				Callable(self, "_action_save_active_era_layout"),
				not multiplayer.is_server()
			)
			_add_action_button(
				"Load %s Layout" % _selected_era_name(),
				Callable(self, "_action_load_active_era_layout"),
				not (multiplayer.is_server() and _has_saved_layout_for_selected_era())
			)
			_add_action_button(
				"Enter %s" % _selected_era_name(),
				Callable(self, "_action_start_selected_era_run"),
				not (multiplayer.is_server() and not gate_manager.is_gate_active())
			)
		"core":
			action_title_label.text = "Core Console"
			action_body_label.text = _pylon_modal_text()
			var pylon_snapshot = gate_manager.get_channel_status_snapshot()
			var pylon_action_text := "Stop Channel" if bool(pylon_snapshot.get("channel_active", false)) else "Start Channel"
			_add_action_button(
				pylon_action_text,
				Callable(self, "_action_toggle_pylon_channel"),
				gate_manager.get_run_base_state() == "damaged"
			)
			_add_action_button(
				pylon_radius_upgrade_button.text,
				Callable(self, "_action_upgrade_pylon_radius"),
				pylon_radius_upgrade_button.disabled
			)
			_add_action_button(
				pylon_cap_upgrade_button.text,
				Callable(self, "_action_upgrade_pylon_cap"),
				pylon_cap_upgrade_button.disabled
			)
			_add_action_button(
				pylon_efficiency_upgrade_button.text,
				Callable(self, "_action_upgrade_pylon_efficiency"),
				pylon_efficiency_upgrade_button.disabled
			)
			_add_action_button(
				pylon_health_upgrade_button.text,
				Callable(self, "_action_upgrade_pylon_health"),
				pylon_health_upgrade_button.disabled
			)
			for node_id in _visible_research_node_ids():
				var node_state = research_manager.get_node_state(node_id)
				_add_action_button(
					_research_button_text(node_state, _research_action_verb(node_state)),
					Callable(self, "_action_purchase_research").bind(node_id),
					not (multiplayer.is_server() and research_manager.can_purchase_node(node_id))
				)
		_:
			action_title_label.text = "Actions"
			action_body_label.text = "No actions available."
	if action_buttons_container.get_child_count() == 0:
		_add_action_button("No Actions Available", Callable(), true)


func _hub_console_text() -> String:
	var lines: Array[String] = []
	lines.append("Selected Era: %s" % _selected_era_name())
	lines.append("Saved Layout Pieces: %d" % _selected_era_layout_count())
	lines.append("")
	lines.append("Build near the hub core to configure this era's starting defense layout.")
	lines.append("Save that layout here, then enter the run to spawn it around the run base.")
	return "\n".join(lines)


func _pylon_modal_text() -> String:
	var snapshot = gate_manager.get_channel_status_snapshot()
	var lines: Array[String] = []
	lines.append(String(snapshot.get("state_label", "Core")))
	lines.append(String(snapshot.get("detail_label", "")))
	lines.append("Radius %d / %d" % [int(round(float(snapshot.get("influence_radius", 0.0)))), int(round(float(snapshot.get("max_radius", 0.0))))])
	lines.append("Pending Essence %d" % int(floor(float(snapshot.get("current_reward", 0.0)))))
	return "\n".join(lines)


func _add_action_button(text: String, action: Callable, disabled: bool) -> void:
	var button := Button.new()
	button.text = text
	button.disabled = disabled
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if action.is_valid() and not disabled:
		button.pressed.connect(action)
	action_buttons_container.add_child(button)


func _action_cycle_era() -> void:
	if multiplayer.is_server() and era_manager != null and era_manager.has_method("cycle_active_gate_era"):
		era_manager.cycle_active_gate_era(1)
		status_label.text = "Selected era: %s." % _selected_era_name()
	_refresh_action_modal()


func _action_save_active_era_layout() -> void:
	if not multiplayer.is_server():
		return
	if building_manager == null or era_manager == null or core_objective == null:
		return
	if not building_manager.has_method("capture_layout_snapshot") or not era_manager.has_method("save_run_base_layout"):
		return
	var layout = building_manager.capture_layout_snapshot(core_objective.global_position, _hub_layout_radius())
	era_manager.save_run_base_layout(layout)
	status_label.text = "Saved %d layout pieces for %s." % [layout.size(), _selected_era_name()]
	_refresh_action_modal()


func _action_load_active_era_layout() -> void:
	if not multiplayer.is_server():
		return
	if building_manager == null or era_manager == null or core_objective == null:
		return
	if not building_manager.has_method("apply_layout_snapshot") or not era_manager.has_method("get_saved_run_base_layout"):
		return
	var layout = era_manager.get_saved_run_base_layout()
	building_manager.apply_layout_snapshot(layout, core_objective.global_position, _hub_layout_radius())
	status_label.text = "Loaded %d layout pieces for %s." % [layout.size(), _selected_era_name()]
	_refresh_action_modal()


func _action_start_selected_era_run() -> void:
	if multiplayer.is_server():
		_on_gate_pressed()
	_close_action_modal()


func _action_toggle_pylon_channel() -> void:
	if gate_manager.has_method("request_local_objective_interaction"):
		gate_manager.request_local_objective_interaction(multiplayer.get_unique_id())
	_close_action_modal()


func _action_upgrade_pylon_radius() -> void:
	_on_pylon_radius_upgrade_pressed()
	_refresh_action_modal()


func _action_upgrade_pylon_cap() -> void:
	_on_pylon_cap_upgrade_pressed()
	_refresh_action_modal()


func _action_upgrade_pylon_efficiency() -> void:
	_on_pylon_efficiency_upgrade_pressed()
	_refresh_action_modal()


func _action_upgrade_pylon_health() -> void:
	_on_pylon_health_upgrade_pressed()
	_refresh_action_modal()


func _selected_era_name() -> String:
	if era_manager != null and era_manager.has_method("get_active_gate_era_display_name"):
		return String(era_manager.get_active_gate_era_display_name())
	return "Stone Age"


func _selected_era_layout_count() -> int:
	if era_manager == null or not era_manager.has_method("get_saved_run_base_layout"):
		return 0
	return era_manager.get_saved_run_base_layout().size()


func _has_saved_layout_for_selected_era() -> bool:
	if era_manager == null or not era_manager.has_method("has_saved_run_base_layout"):
		return false
	return bool(era_manager.has_saved_run_base_layout())


func _hub_layout_radius() -> float:
	if building_manager != null and building_manager.has_method("get_active_build_area_size"):
		return max(float(building_manager.get_active_build_area_size()) * 0.5, 1.0)
	return 18.0


func _action_purchase_field_tools() -> void:
	var visible_nodes := _visible_research_node_ids()
	if visible_nodes.size() > 0:
		_action_purchase_research(visible_nodes[0])
	_refresh_action_modal()


func _action_purchase_augment_slot() -> void:
	var visible_nodes := _visible_research_node_ids()
	if visible_nodes.size() > 1:
		_action_purchase_research(visible_nodes[1])
	_refresh_action_modal()


func _action_purchase_augment_branch() -> void:
	var visible_nodes := _visible_research_node_ids()
	if visible_nodes.size() > 2:
		_action_purchase_research(visible_nodes[2])
	_refresh_action_modal()


func _action_purchase_research(node_id: String) -> void:
	if node_id == "":
		return
	if multiplayer.is_server():
		research_manager.purchase_node(node_id)
	_refresh_action_modal()
