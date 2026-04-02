extends StaticBody3D

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var label: Label3D = $Label3D

var _is_active: bool = false
var _countdown_remaining: float = 0.0


func _ready() -> void:
	_update_visuals()


func set_extraction_state(is_active: bool, countdown_remaining: float) -> void:
	_is_active = is_active
	_countdown_remaining = countdown_remaining
	_update_visuals()


func _update_visuals() -> void:
	if body_mesh == null or label == null:
		return
	var material := StandardMaterial3D.new()
	if _is_active:
		material.albedo_color = Color(0.95, 0.42, 0.24, 0.8)
		label.text = "Extracting %0.1fs" % _countdown_remaining
	else:
		material.albedo_color = Color(0.26, 0.88, 0.68, 0.7)
		label.text = "Extraction Zone"
	body_mesh.material_override = material
