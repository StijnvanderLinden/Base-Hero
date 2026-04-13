extends Node

const STONE_AGE_PATH := "res://resources/eras/stone_age.tres"
const BRONZE_AGE_PLACEHOLDER_PATH := "res://resources/eras/bronze_age_placeholder.tres"

signal era_changed(era_id: String)
signal era_unlocked(era_id: String)

var _era_lookup: Dictionary = {}
var _unlocked_era_ids: Array[String] = ["stone_age"]
var _current_era_id: String = "stone_age"
var _active_gate_era_id: String = "stone_age"
var _enemy_scene_cache: Dictionary = {}


func _ready() -> void:
	add_to_group("era_manager")
	_register_era(_load_era_resource(STONE_AGE_PATH, _build_stone_age_fallback()))
	_register_era(_load_era_resource(BRONZE_AGE_PLACEHOLDER_PATH, _build_bronze_age_placeholder_fallback()))
	if not _era_lookup.has(_current_era_id) and not _era_lookup.is_empty():
		_current_era_id = String(_era_lookup.keys()[0])
		_active_gate_era_id = _current_era_id


func get_current_era_id() -> String:
	return _current_era_id


func get_active_gate_era_id() -> String:
	return _active_gate_era_id


func get_current_era_data() -> EraData:
	return get_era_data(_current_era_id)


func get_active_gate_era_data() -> EraData:
	return get_era_data(_active_gate_era_id)


func get_era_data(era_id: String) -> EraData:
	if not _era_lookup.has(era_id):
		return null
	var data: EraData = _era_lookup[era_id]
	return data


func get_unlocked_era_ids() -> Array[String]:
	return _unlocked_era_ids.duplicate()


func get_default_gate_era_id() -> String:
	if _unlocked_era_ids.is_empty():
		return _current_era_id
	return _unlocked_era_ids[0]


func can_enter_era(era_id: String) -> bool:
	return _unlocked_era_ids.has(era_id)


func unlock_era(era_id: String) -> bool:
	if era_id == "" or not _era_lookup.has(era_id):
		return false
	if _unlocked_era_ids.has(era_id):
		return false
	_unlocked_era_ids.append(era_id)
	era_unlocked.emit(era_id)
	return true


func set_active_gate_era(era_id: String) -> bool:
	if not can_enter_era(era_id):
		return false
	_active_gate_era_id = era_id
	if _current_era_id != era_id:
		_current_era_id = era_id
		era_changed.emit(era_id)
	return true


func get_enemy_scene(enemy_kind: String) -> PackedScene:
	if _enemy_scene_cache.has(enemy_kind):
		return _enemy_scene_cache[enemy_kind]
	var era_data := get_active_gate_era_data()
	if era_data == null:
		return null
	var enemy_definition: Dictionary = era_data.enemy_catalog.get(enemy_kind, {})
	var scene_path := String(enemy_definition.get("scene_path", ""))
	if scene_path == "":
		return null
	var scene := load(scene_path) as PackedScene
	if scene != null:
		_enemy_scene_cache[enemy_kind] = scene
	return scene


func get_structure_definition(structure_key: String) -> Dictionary:
	var era_data := get_active_gate_era_data()
	if era_data == null:
		return {}
	return (era_data.structure_catalog.get(structure_key, {}) as Dictionary).duplicate(true)


func get_research_definitions() -> Dictionary:
	var era_data := get_current_era_data()
	if era_data == null:
		return {}
	return era_data.research_definitions.duplicate(true)


func get_research_node_order() -> Array[String]:
	var era_data := get_current_era_data()
	if era_data == null:
		return []
	return era_data.research_node_order.duplicate(true)


func get_combat_data() -> Dictionary:
	var era_data := get_current_era_data()
	if era_data == null:
		return {}
	return era_data.player_combat_data.duplicate(true)


func get_wave_definitions() -> Array[Dictionary]:
	var era_data := get_active_gate_era_data()
	if era_data == null:
		return []
	return era_data.wave_definitions.duplicate(true)


func get_resource_nodes() -> Array[Dictionary]:
	var era_data := get_active_gate_era_data()
	if era_data == null:
		return []
	return era_data.resource_nodes.duplicate(true)


func get_material_ids() -> Array[String]:
	var era_data := get_current_era_data()
	if era_data == null:
		return []
	return era_data.material_set.duplicate(true)


func get_channel_costs() -> Dictionary:
	var era_data := get_active_gate_era_data()
	if era_data == null:
		return {}
	return era_data.channel_costs.duplicate(true)


func get_visual_theme_data() -> Dictionary:
	var era_data := get_active_gate_era_data()
	if era_data == null:
		return {}
	return era_data.visual_theme_data.duplicate(true)


func get_pylon_data() -> Dictionary:
	var era_data := get_active_gate_era_data()
	if era_data == null:
		return {}
	return era_data.pylon_data.duplicate(true)


func _register_era(data: EraData) -> void:
	if data == null or data.era_id == "":
		return
	_era_lookup[data.era_id] = data


func _load_era_resource(resource_path: String, fallback_data: EraData) -> EraData:
	var loaded_resource := load(resource_path)
	if loaded_resource is EraData:
		return loaded_resource
	return fallback_data


func _build_stone_age_fallback() -> EraData:
	var data := EraData.new()
	data.era_id = "stone_age"
	data.display_name = "Era 1: Stone Age"
	data.description = "Primitive gate expedition focused on wood, stone, simple augments, and short pylon defense runs."
	data.enemy_set = ["stone_caveman", "stone_brute", "stone_beast", "stone_mech"]
	data.structure_set = ["wooden_wall", "reinforced_wall", "thrower_turret", "improved_thrower_turret"]
	data.material_set = ["stone", "wood", "herbs"]
	data.augment_pool = ["stone_damage", "stone_attack_speed", "stone_range", "stone_pulse"]
	data.unlock_requirements = {"next_era_placeholder": {"research_nodes": PackedStringArray(["stone_branch"])}}
	data.visual_theme_data = {
		"accent_color": Color(0.807843, 0.666667, 0.431373, 1.0),
		"description": "Wood, rope, bone, and rough stone silhouettes.",
		"fog_color": Color(0.384314, 0.333333, 0.258824, 1.0),
		"ground_color": Color(0.321569, 0.27451, 0.188235, 1.0),
	}
	data.enemy_catalog = {
		"stone_caveman": {"display_name": "Caveman", "scene_path": "res://scenes/stone_age_caveman.tscn", "start_health": 80.0},
		"stone_brute": {"display_name": "Brute", "scene_path": "res://scenes/stone_age_brute.tscn", "start_health": 180.0},
		"stone_beast": {"display_name": "Beast", "scene_path": "res://scenes/stone_age_beast.tscn", "start_health": 130.0},
		"stone_mech": {"display_name": "Stone Mech", "scene_path": "res://scenes/stone_age_mech.tscn", "start_health": 420.0},
	}
	data.structure_catalog = {
		"wall": {
			"base": {"costs": {"stone": 4, "wood": 2}, "display_name": "Wooden Wall", "scene_path": "res://scenes/wooden_wall.tscn"},
			"unlocked_variant_feature": "reinforced_wall",
			"upgraded": {"costs": {"stone": 7, "wood": 3}, "display_name": "Reinforced Wall", "scene_path": "res://scenes/reinforced_wall.tscn"},
		},
		"turret": {
			"base": {"costs": {"stone": 8, "wood": 4}, "display_name": "Thrower Turret", "scene_path": "res://scenes/thrower_turret.tscn"},
			"unlocked_variant_feature": "improved_thrower",
			"upgraded": {"costs": {"stone": 12, "wood": 6}, "display_name": "Improved Thrower", "scene_path": "res://scenes/improved_thrower_turret.tscn"},
		},
	}
	data.research_definitions = {
		"stone_reinforced_wall": {"base_essence_cost": 130, "crystal_cost": 1, "display_name": "Reinforced Wall", "essence_cost_step": 0, "max_level": 1, "repeatable": false, "type": "structure", "unlocks": PackedStringArray(["reinforced_wall"]), "visible_in_action_modal": true},
		"stone_thrower_upgrade": {"base_essence_cost": 150, "crystal_cost": 1, "display_name": "Improved Thrower", "essence_cost_step": 0, "max_level": 1, "repeatable": false, "type": "structure", "unlocks": PackedStringArray(["improved_thrower"]), "visible_in_action_modal": true},
		"stone_augment_slot": {"base_essence_cost": 120, "crystal_cost": 1, "display_name": "First Augment Slot", "essence_cost_step": 0, "max_level": 1, "repeatable": false, "type": "core", "unlocks": PackedStringArray(["augment_slot"]), "visible_in_action_modal": true},
		"stone_branch": {"base_essence_cost": 80, "crystal_cost": 1, "display_name": "Stone Age Branch", "essence_cost_step": 0, "max_level": 1, "repeatable": false, "type": "branch", "unlocks": PackedStringArray(["augment_branch"]), "visible_in_action_modal": true},
		"stone_damage": {"base_essence_cost": 110, "crystal_cost": 0, "display_name": "Sharpened Strikes", "essence_cost_step": 80, "max_level": 2, "repeatable": true, "requires": PackedStringArray(["stone_augment_slot"]), "stat_effects": {"damage_multiplier": 0.15}, "type": "augment", "visible_in_action_modal": true},
		"stone_attack_speed": {"base_essence_cost": 90, "crystal_cost": 0, "display_name": "Faster Swings", "essence_cost_step": 70, "max_level": 2, "repeatable": true, "requires": PackedStringArray(["stone_augment_slot"]), "stat_effects": {"attack_speed_multiplier": 0.14}, "type": "augment", "visible_in_action_modal": true},
		"stone_range": {"base_essence_cost": 90, "crystal_cost": 0, "display_name": "Long Reach", "essence_cost_step": 70, "max_level": 2, "repeatable": true, "requires": PackedStringArray(["stone_augment_slot"]), "stat_effects": {"range_bonus": 2.4}, "type": "augment", "visible_in_action_modal": true},
		"stone_pulse": {"base_essence_cost": 140, "crystal_cost": 1, "display_name": "Bone Pulse", "essence_cost_step": 0, "max_level": 1, "repeatable": false, "requires": PackedStringArray(["stone_branch"]), "stat_effects": {"aoe_radius": 1.3}, "type": "augment", "visible_in_action_modal": true},
	}
	data.research_node_order = ["stone_reinforced_wall", "stone_thrower_upgrade", "stone_augment_slot", "stone_branch", "stone_damage", "stone_attack_speed", "stone_range", "stone_pulse"]
	data.resource_nodes = [
		{"amount": 18, "id": "stone_1", "position": Vector3(-10, 0, 8), "type": "stone_node"},
		{"amount": 16, "id": "stone_2", "position": Vector3(11, 0, -6), "type": "stone_node"},
		{"amount": 12, "id": "stone_3", "position": Vector3(-13, 0, -10), "type": "stone_node"},
		{"amount": 10, "id": "wood_1", "position": Vector3(8, 0, 11), "type": "wood_node"},
		{"amount": 10, "id": "wood_2", "position": Vector3(-15, 0, 2), "type": "wood_node"},
		{"amount": 0, "id": "herb_1", "position": Vector3(15, 0, -12), "type": "herb_patch"},
		{"amount": 1, "id": "crystal_1", "position": Vector3(17, 0, 4), "type": "crystal"},
		{"amount": 1, "id": "crystal_2", "position": Vector3(-16, 0, -5), "type": "crystal"},
		{"amount": 1, "id": "crystal_3", "position": Vector3(4, 0, 15), "type": "crystal"},
	]
	data.channel_costs = {"stone": 10, "wood": 6}
	data.wave_definitions = [
		{"breather_duration": 4.0, "enemy_sequence": PackedStringArray(["stone_caveman", "stone_caveman", "stone_caveman", "stone_caveman", "stone_caveman", "stone_caveman"]), "max_enemies": 4, "spawn_interval": 1.5, "spawns_per_wave": 6},
		{"breather_duration": 4.5, "enemy_sequence": PackedStringArray(["stone_caveman", "stone_caveman", "stone_brute", "stone_caveman", "stone_brute", "stone_caveman"]), "max_enemies": 5, "spawn_interval": 1.4, "spawns_per_wave": 6},
		{"breather_duration": 5.0, "enemy_sequence": PackedStringArray(["stone_caveman", "stone_brute", "stone_beast", "stone_caveman", "stone_brute", "stone_beast", "stone_caveman"]), "max_enemies": 6, "spawn_interval": 1.25, "spawns_per_wave": 7},
		{"breather_duration": 0.0, "enemy_sequence": PackedStringArray(["stone_mech", "stone_brute", "stone_caveman"]), "max_enemies": 3, "spawn_interval": 2.1, "spawns_per_wave": 3},
	]
	data.player_combat_data = {
		"aoe_damage_multiplier": 0.7,
		"basic_attack": {"cooldown": 0.26, "damage": 24.0, "projectile_scale": 0.9, "range": 9.5, "speed": 24.0},
		"heavy_attack": {"cooldown": 0.8, "damage": 42.0, "projectile_scale": 1.25, "range": 10.5, "speed": 21.0},
		"weapon_name": "Stone Staff",
	}
	data.pylon_data = {"allowed_pylon_count": 1, "channel_summary": "Consumes raw stone and wood to generate essence.", "crystal_tracking": true}
	return data


func _build_bronze_age_placeholder_fallback() -> EraData:
	var data := EraData.new()
	data.era_id = "bronze_age"
	data.display_name = "Era 2: Bronze Age"
	data.description = "Locked placeholder for the next era."
	data.unlock_requirements = {"requires_era": "stone_age", "requires_placeholder": true}
	data.visual_theme_data = {"status": "placeholder"}
	return data
