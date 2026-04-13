extends Node

signal progression_changed()
signal status_changed(message: String)

var network_manager: Node
var era_manager: Node
var _session_active: bool = false
var _essence: int = 0
var _crystals: int = 0
var _node_states: Dictionary = {}
var _feature_unlocks: Dictionary = {}


func _ready() -> void:
	add_to_group("research_manager")
	_reset_state()


func bind_network_manager(manager: Node) -> void:
	network_manager = manager
	if manager.has_signal("session_changed"):
		manager.session_changed.connect(_on_session_changed)
	if manager.has_signal("peer_registered"):
		manager.peer_registered.connect(_on_peer_registered)


func set_era_manager(manager: Node) -> void:
	era_manager = manager
	_reset_state()
	_broadcast_state()


func get_essence() -> int:
	return _essence


func get_crystal_count() -> int:
	return _crystals


func add_essence(amount: int) -> void:
	if not multiplayer.is_server():
		return
	if amount <= 0:
		return
	_essence += amount
	_broadcast_state()


func add_crystals(amount: int) -> void:
	if not multiplayer.is_server():
		return
	if amount <= 0:
		return
	_crystals += amount
	_broadcast_state()


func can_afford_essence(amount: int) -> bool:
	return _essence >= max(amount, 0)


func consume_essence(amount: int) -> bool:
	if not multiplayer.is_server():
		return false
	var safe_amount = max(amount, 0)
	if _essence < safe_amount:
		return false
	_essence -= safe_amount
	_broadcast_state()
	return true


func has_feature(feature_id: String) -> bool:
	return bool(_feature_unlocks.get(feature_id, false))


func get_visible_node_ids() -> Array[String]:
	var visible_nodes: Array[String] = []
	for node_id in _definition_order():
		var definition: Dictionary = _definitions().get(node_id, {})
		if bool(definition.get("visible_in_action_modal", true)):
			visible_nodes.append(node_id)
	return visible_nodes


func get_stat_total(stat_key: String) -> float:
	var total := 0.0
	for node_id in _definitions().keys():
		var definition: Dictionary = _definitions().get(node_id, {})
		var effect_map: Dictionary = definition.get("stat_effects", {})
		if effect_map.is_empty() or not effect_map.has(stat_key):
			continue
		var level := int((_node_states.get(node_id, {}) as Dictionary).get("level", 0))
		if level <= 0:
			continue
		total += float(effect_map.get(stat_key, 0.0)) * float(level)
	return total


func get_node_state(node_id: String) -> Dictionary:
	if not _definitions().has(node_id):
		return {}
	var state: Dictionary = _node_states.get(node_id, {}).duplicate(true)
	var definition: Dictionary = _definitions()[node_id]
	state["id"] = node_id
	state["display_name"] = definition.get("display_name", node_id.capitalize())
	state["type"] = definition.get("type", "basic")
	state["essence_cost"] = get_purchase_cost(node_id).get("essence", 0)
	state["crystal_cost"] = get_purchase_cost(node_id).get("crystals", 0)
	state["max_level"] = definition.get("max_level", 1)
	state["requirements_met"] = _requirements_met(definition)
	return state


func get_purchase_cost(node_id: String) -> Dictionary:
	if not _definitions().has(node_id):
		return {"essence": 0, "crystals": 0}
	var definition: Dictionary = _definitions()[node_id]
	var state: Dictionary = _node_states.get(node_id, {})
	var current_level := int(state.get("level", 0))
	if current_level >= int(definition.get("max_level", 1)):
		return {"essence": 0, "crystals": 0}
	var essence_cost := int(definition.get("base_essence_cost", 0)) + current_level * int(definition.get("essence_cost_step", 0))
	var crystal_cost := int(definition.get("crystal_cost", 0))
	return {"essence": max(essence_cost, 0), "crystals": max(crystal_cost, 0)}


func can_purchase_node(node_id: String) -> bool:
	if not multiplayer.is_server():
		return false
	if not _session_active:
		return false
	if not _definitions().has(node_id):
		return false
	var definition: Dictionary = _definitions()[node_id]
	var state: Dictionary = _node_states.get(node_id, {})
	var current_level := int(state.get("level", 0))
	if current_level >= int(definition.get("max_level", 1)):
		return false
	if not _requirements_met(definition):
		return false
	var costs := get_purchase_cost(node_id)
	return _essence >= int(costs.get("essence", 0)) and _crystals >= int(costs.get("crystals", 0))


func purchase_node(node_id: String) -> bool:
	if not multiplayer.is_server():
		return false
	if not _session_active:
		status_changed.emit("Start a session before purchasing research.")
		return false
	if not _definitions().has(node_id):
		return false
	if not can_purchase_node(node_id):
		var costs := get_purchase_cost(node_id)
		status_changed.emit("Need %d essence and %d crystals for %s." % [int(costs.get("essence", 0)), int(costs.get("crystals", 0)), String(_definitions()[node_id].get("display_name", node_id))])
		return false
	var costs := get_purchase_cost(node_id)
	_essence -= int(costs.get("essence", 0))
	_crystals -= int(costs.get("crystals", 0))
	var state: Dictionary = _node_states.get(node_id, {})
	state["level"] = int(state.get("level", 0)) + 1
	state["unlocked"] = true
	_node_states[node_id] = state
	_apply_definition_unlocks(_definitions()[node_id])
	status_changed.emit("Research completed: %s." % String(_definitions()[node_id].get("display_name", node_id)))
	_broadcast_state()
	return true


func _on_session_changed(in_session: bool) -> void:
	_session_active = in_session
	if in_session:
		_broadcast_state()
		return
	_reset_state()
	_broadcast_state()


func _on_peer_registered(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	_sync_state.rpc_id(peer_id, _essence, _crystals, _node_states.duplicate(true), _feature_unlocks.duplicate(true))


func _reset_state() -> void:
	_essence = 0
	_crystals = 0
	_node_states.clear()
	_feature_unlocks.clear()
	for node_id in _definitions().keys():
		_node_states[node_id] = {"level": 0, "unlocked": false}


func _broadcast_state() -> void:
	progression_changed.emit()
	if multiplayer.is_server():
		_sync_state.rpc(_essence, _crystals, _node_states.duplicate(true), _feature_unlocks.duplicate(true))


@rpc("authority", "call_remote", "reliable")
func _sync_state(essence: int, crystals: int, node_states: Dictionary, feature_unlocks: Dictionary) -> void:
	if multiplayer.is_server():
		return
	_essence = max(essence, 0)
	_crystals = max(crystals, 0)
	_node_states = node_states.duplicate(true)
	_feature_unlocks = feature_unlocks.duplicate(true)
	progression_changed.emit()


func _definitions() -> Dictionary:
	if era_manager != null and era_manager.has_method("get_research_definitions"):
		return era_manager.get_research_definitions()
	return {}


func _definition_order() -> Array[String]:
	if era_manager != null and era_manager.has_method("get_research_node_order"):
		return era_manager.get_research_node_order()
	return []


func _requirements_met(definition: Dictionary) -> bool:
	var requirements: Array = definition.get("requires", [])
	for requirement in requirements:
		if not _requirement_is_met(String(requirement)):
			return false
	return true


func _requirement_is_met(requirement_id: String) -> bool:
	if requirement_id == "":
		return true
	if has_feature(requirement_id):
		return true
	var node_state: Dictionary = _node_states.get(requirement_id, {})
	return int(node_state.get("level", 0)) > 0


func _apply_definition_unlocks(definition: Dictionary) -> void:
	for feature_id in definition.get("unlocks", []):
		_feature_unlocks[String(feature_id)] = true
