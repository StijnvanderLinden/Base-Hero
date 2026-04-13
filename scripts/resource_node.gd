extends StaticBody3D

var resource_id: String = ""
var resource_type: String = "iron_ore"
var resource_amount: int = 0
var spawn_position: Vector3 = Vector3.ZERO
var collected: bool = false
var revealed: bool = false

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var label: Label3D = $Label3D


func setup(new_resource_id: String, new_resource_type: String, new_position: Vector3, amount: int, starts_collected: bool = false) -> void:
	resource_id = new_resource_id
	resource_type = new_resource_type
	spawn_position = new_position
	resource_amount = max(amount, 0)
	collected = starts_collected
	name = "Resource_%s" % resource_id


func _ready() -> void:
	add_to_group("resource_nodes")
	if resource_type == "crystal":
		add_to_group("crystal_nodes")
	global_position = spawn_position
	_apply_visual_state()


func can_interact() -> bool:
	if collected:
		return false
	return resource_type == "stone_node" or resource_type == "wood_node" or resource_type == "herb_patch" or resource_type == "crystal"


func collect() -> Dictionary:
	if not can_interact():
		return {}
	set_collected(true)
	return {
		"id": resource_id,
		"type": resource_type,
		"amount": resource_amount,
	}


func set_revealed(active: bool) -> void:
	if resource_type == "crystal":
		revealed = false
		_apply_visual_state()
		return
	revealed = active
	_apply_visual_state()


func set_collected(active: bool) -> void:
	collected = active
	_apply_visual_state()


func get_resource_id() -> String:
	return resource_id


func get_resource_type() -> String:
	return resource_type


func is_collected() -> bool:
	return collected


func get_interaction_text() -> String:
	if collected:
		return ""
	match resource_type:
		"stone_node":
			return "Press E to collect Stone +%d" % resource_amount
		"wood_node":
			return "Press E to collect Wood +%d" % resource_amount
		"herb_patch":
			return "Press E to gather Herbs"
		"crystal":
			return "Press E to secure Crystal"
		_:
			return ""


func _apply_visual_state() -> void:
	visible = not collected
	if collision_shape != null:
		collision_shape.disabled = collected
	if label == null or body_mesh == null:
		return
	var material := body_mesh.material_override as StandardMaterial3D
	if material == null:
		material = StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		body_mesh.material_override = material
	match resource_type:
		"stone_node":
			body_mesh.scale = Vector3(1.15, 0.8, 1.15)
			material.albedo_color = Color(0.72, 0.74, 0.78, 0.95 if revealed else 0.7)
			label.text = "Stone Cache" if revealed else ""
		"wood_node":
			body_mesh.scale = Vector3(0.9, 1.15, 0.9)
			material.albedo_color = Color(0.52, 0.34, 0.2, 0.92 if revealed else 0.55)
			label.text = "Wood Bundle" if revealed else ""
		"herb_patch":
			body_mesh.scale = Vector3(0.75, 0.35, 0.75)
			material.albedo_color = Color(0.22, 0.72, 0.36, 0.85 if revealed else 0.4)
			label.text = "Herb Patch" if revealed else ""
		"cave_site":
			body_mesh.scale = Vector3(1.4, 0.5, 1.0)
			material.albedo_color = Color(0.32, 0.5, 0.78, 0.85 if revealed else 0.35)
			label.text = "Cave Entrance" if revealed else ""
		"treasure_spot":
			body_mesh.scale = Vector3(0.95, 0.55, 0.95)
			material.albedo_color = Color(0.88, 0.67, 0.2, 0.92 if revealed else 0.45)
			label.text = "Treasure Spot" if revealed else ""
		"crystal":
			body_mesh.scale = Vector3(0.85, 1.35, 0.85)
			material.albedo_color = Color(0.48, 0.92, 1.0, 0.96)
			label.text = "Crystal"
		_:
			body_mesh.scale = Vector3.ONE
			material.albedo_color = Color(0.85, 0.85, 0.85, 0.5)
			label.text = ""