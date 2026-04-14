extends Node

@onready var title_label: Label = $Overlay/TopBanner/MarginContainer/VBoxContainer/TitleLabel
@onready var content_root: Node = $ContentRoot


func _ready() -> void:
	var suite := SystemTestRegistry.current_suite
	if suite == null:
		SystemTestRegistry.return_to_picker()
		return

	title_label.text = suite.title
	_load_suite_content(suite)


func _load_suite_content(suite: SystemTestSuiteDefinition) -> void:
	var scene := load(suite.scene_path) as PackedScene
	if scene == null:
		push_error("Failed to load test suite scene: %s" % suite.scene_path)
		return
	var instance := scene.instantiate()
	content_root.add_child(instance)
