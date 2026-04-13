extends Resource

class_name EraData

@export var era_id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var enemy_set: Array[String] = []
@export var structure_set: Array[String] = []
@export var material_set: Array[String] = []
@export var augment_pool: Array[String] = []
@export var unlock_requirements: Dictionary = {}
@export var visual_theme_data: Dictionary = {}
@export var enemy_catalog: Dictionary = {}
@export var structure_catalog: Dictionary = {}
@export var research_definitions: Dictionary = {}
@export var research_node_order: Array[String] = []
@export var resource_nodes: Array[Dictionary] = []
@export var channel_costs: Dictionary = {}
@export var wave_definitions: Array[Dictionary] = []
@export var player_combat_data: Dictionary = {}
@export var pylon_data: Dictionary = {}


func duplicate_runtime() -> EraData:
	var runtime_copy := EraData.new()
	runtime_copy.era_id = era_id
	runtime_copy.display_name = display_name
	runtime_copy.description = description
	runtime_copy.enemy_set = enemy_set.duplicate(true)
	runtime_copy.structure_set = structure_set.duplicate(true)
	runtime_copy.material_set = material_set.duplicate(true)
	runtime_copy.augment_pool = augment_pool.duplicate(true)
	runtime_copy.unlock_requirements = unlock_requirements.duplicate(true)
	runtime_copy.visual_theme_data = visual_theme_data.duplicate(true)
	runtime_copy.enemy_catalog = enemy_catalog.duplicate(true)
	runtime_copy.structure_catalog = structure_catalog.duplicate(true)
	runtime_copy.research_definitions = research_definitions.duplicate(true)
	runtime_copy.research_node_order = research_node_order.duplicate(true)
	runtime_copy.resource_nodes = resource_nodes.duplicate(true)
	runtime_copy.channel_costs = channel_costs.duplicate(true)
	runtime_copy.wave_definitions = wave_definitions.duplicate(true)
	runtime_copy.player_combat_data = player_combat_data.duplicate(true)
	runtime_copy.pylon_data = pylon_data.duplicate(true)
	return runtime_copy