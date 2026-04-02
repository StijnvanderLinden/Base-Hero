extends StaticBody3D

var is_collected: bool = false
var _reward_amount: int = 0

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var label: Label3D = $Label3D


func _ready() -> void:
	_update_visuals()


func set_collected(collected: bool, reward_amount: int) -> void:
	is_collected = collected
	_reward_amount = reward_amount
	_update_visuals()


func _update_visuals() -> void:
	if body_mesh == null or label == null:
		return
	var material := StandardMaterial3D.new()
	if is_collected:
		material.albedo_color = Color(0.24, 0.24, 0.26)
		label.text = "Cache Empty"
	else:
		material.albedo_color = Color(0.95, 0.76, 0.26)
		label.text = "Scrap Cache +%d" % _reward_amount
	body_mesh.material_override = material
