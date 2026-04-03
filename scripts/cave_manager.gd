extends Node

signal cave_prepared(cave_id: int, descriptor: Dictionary)
signal cave_entered(cave_id: int, peer_ids: Array[int])
signal cave_collapsed(cave_id: int, reason: String)
signal cave_cleared(cave_id: int)

var _next_cave_id: int = 1
var _prepared_caves: Dictionary = {}
var _active_cave_id: int = 0


func build_request(pylon_id: String, entrance_position: Vector3, depth_tier: int, seed_value: int, biome_id: String, active_player_count: int) -> Dictionary:
	return {
		"pylon_id": pylon_id,
		"entrance_position": entrance_position,
		"depth_tier": max(depth_tier, 1),
		"seed": seed_value,
		"biome_id": biome_id,
		"player_count": max(active_player_count, 1)
	}


func prepare_cave(request: Dictionary) -> Dictionary:
	var cave_id := _next_cave_id
	_next_cave_id += 1
	var entrance_position: Vector3 = request.get("entrance_position", Vector3.ZERO)
	var descriptor := {
		"cave_id": cave_id,
		"state": "prepared",
		"request": request.duplicate(true),
		"entrance_position": entrance_position,
		"player_spawn_points": [entrance_position],
		"exit_anchor": entrance_position,
		"reward_anchor": entrance_position + Vector3(0.0, 0.0, -12.0)
	}
	_prepared_caves[cave_id] = descriptor
	cave_prepared.emit(cave_id, descriptor.duplicate(true))
	return descriptor.duplicate(true)


func enter_prepared_cave(cave_id: int, peer_ids: Array[int]) -> Dictionary:
	if not _prepared_caves.has(cave_id):
		return {}
	var descriptor: Dictionary = _prepared_caves[cave_id]
	descriptor["state"] = "active"
	descriptor["active_peer_ids"] = peer_ids.duplicate()
	_prepared_caves[cave_id] = descriptor
	_active_cave_id = cave_id
	cave_entered.emit(cave_id, peer_ids.duplicate())
	return descriptor.duplicate(true)


func collapse_cave(cave_id: int, reason: String = "failed") -> void:
	if not _prepared_caves.has(cave_id):
		return
	var descriptor: Dictionary = _prepared_caves[cave_id]
	descriptor["state"] = "collapsed"
	_prepared_caves[cave_id] = descriptor
	if _active_cave_id == cave_id:
		_active_cave_id = 0
	cave_collapsed.emit(cave_id, reason)


func clear_cave(cave_id: int) -> void:
	if not _prepared_caves.has(cave_id):
		return
	var descriptor: Dictionary = _prepared_caves[cave_id]
	descriptor["state"] = "cleared"
	_prepared_caves[cave_id] = descriptor
	if _active_cave_id == cave_id:
		_active_cave_id = 0
	cave_cleared.emit(cave_id)


func get_cave_descriptor(cave_id: int) -> Dictionary:
	if not _prepared_caves.has(cave_id):
		return {}
	return (_prepared_caves[cave_id] as Dictionary).duplicate(true)


func get_active_cave_id() -> int:
	return _active_cave_id


func clear_all_runtime_state() -> void:
	_prepared_caves.clear()
	_active_cave_id = 0
	_next_cave_id = 1