extends Node

signal progression_changed()
signal status_changed(message: String)

const RESEARCH_DEFINITIONS := {
	"field_tools": {
		"display_name": "Field Tools",
		"type": "basic",
		"max_level": 3,
		"base_essence_cost": 250,
		"essence_cost_step": 175,
		"crystal_cost": 0,
		"repeatable": true,
	},
	"augment_slot": {
		"display_name": "Augment Slot",
		"type": "advanced",
		"max_level": 1,
		"base_essence_cost": 10000,
		"essence_cost_step": 0,
		"crystal_cost": 3,
		"repeatable": false,
	},
	"augment_branch": {
		"display_name": "Augment Branch",
		"type": "branch",
		"max_level": 1,
		"base_essence_cost": 0,
		"essence_cost_step": 0,
		"crystal_cost": 5,
		"repeatable": false,
	},
}

var network_manager: Node
var _session_active: bool = false
var _essence: int = 0
var _crystals: int = 0
var _node_states: Dictionary = {}


func _ready() -> void:
	_reset_state()


func bind_network_manager(manager: Node) -> void:
	network_manager = manager
	if manager.has_signal("session_changed"):
		manager.session_changed.connect(_on_session_changed)
	if manager.has_signal("peer_registered"):
		manager.peer_registered.connect(_on_peer_registered)


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


func get_node_state(node_id: String) -> Dictionary:
	if not RESEARCH_DEFINITIONS.has(node_id):
		return {}
	var state: Dictionary = _node_states.get(node_id, {}).duplicate(true)
	var definition: Dictionary = RESEARCH_DEFINITIONS[node_id]
	state["id"] = node_id
	state["display_name"] = definition.get("display_name", node_id.capitalize())
	state["type"] = definition.get("type", "basic")
	state["essence_cost"] = get_purchase_cost(node_id).get("essence", 0)
	state["crystal_cost"] = get_purchase_cost(node_id).get("crystals", 0)
	state["max_level"] = definition.get("max_level", 1)
	return state


func get_purchase_cost(node_id: String) -> Dictionary:
	if not RESEARCH_DEFINITIONS.has(node_id):
		return {"essence": 0, "crystals": 0}
	var definition: Dictionary = RESEARCH_DEFINITIONS[node_id]
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
	if not RESEARCH_DEFINITIONS.has(node_id):
		return false
	var definition: Dictionary = RESEARCH_DEFINITIONS[node_id]
	var state: Dictionary = _node_states.get(node_id, {})
	var current_level := int(state.get("level", 0))
	if current_level >= int(definition.get("max_level", 1)):
		return false
	var costs := get_purchase_cost(node_id)
	return _essence >= int(costs.get("essence", 0)) and _crystals >= int(costs.get("crystals", 0))


func purchase_node(node_id: String) -> bool:
	if not multiplayer.is_server():
		return false
	if not _session_active:
		status_changed.emit("Start a session before purchasing research.")
		return false
	if not RESEARCH_DEFINITIONS.has(node_id):
		return false
	if not can_purchase_node(node_id):
		var costs := get_purchase_cost(node_id)
		status_changed.emit("Need %d essence and %d crystals for %s." % [int(costs.get("essence", 0)), int(costs.get("crystals", 0)), String(RESEARCH_DEFINITIONS[node_id].get("display_name", node_id))])
		return false
	var costs := get_purchase_cost(node_id)
	_essence -= int(costs.get("essence", 0))
	_crystals -= int(costs.get("crystals", 0))
	var state: Dictionary = _node_states.get(node_id, {})
	state["level"] = int(state.get("level", 0)) + 1
	state["unlocked"] = true
	_node_states[node_id] = state
	status_changed.emit("Research completed: %s." % String(RESEARCH_DEFINITIONS[node_id].get("display_name", node_id)))
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
	_sync_state.rpc_id(peer_id, _essence, _crystals, _node_states.duplicate(true))


func _reset_state() -> void:
	_essence = 0
	_crystals = 0
	_node_states = {
		"field_tools": {"level": 0, "unlocked": true},
		"augment_slot": {"level": 0, "unlocked": false},
		"augment_branch": {"level": 0, "unlocked": false},
	}


func _broadcast_state() -> void:
	progression_changed.emit()
	if multiplayer.is_server():
		_sync_state.rpc(_essence, _crystals, _node_states.duplicate(true))


@rpc("authority", "call_remote", "reliable")
func _sync_state(essence: int, crystals: int, node_states: Dictionary) -> void:
	if multiplayer.is_server():
		return
	_essence = max(essence, 0)
	_crystals = max(crystals, 0)
	_node_states = node_states.duplicate(true)
	progression_changed.emit()
