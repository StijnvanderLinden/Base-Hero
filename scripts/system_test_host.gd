extends Node

@onready var title_label: Label = $Overlay/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var summary_label: Label = $Overlay/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/SummaryLabel
@onready var content_root: Node = $ContentRoot


func _ready() -> void:
	var suite := SystemTestRegistry.current_suite
	if suite == null:
		SystemTestRegistry.return_to_picker()
		return

	title_label.text = suite.title
	summary_label.text = suite.summary
	_load_suite_content(suite)


func _load_suite_content(suite: SystemTestSuiteDefinition) -> void:
	var scene := load(suite.scene_path) as PackedScene
	if scene == null:
		push_error("Failed to load test suite scene: %s" % suite.scene_path)
		return
	var instance := scene.instantiate()
	content_root.add_child(instance)


func _on_back_button_pressed() -> void:
	SystemTestRegistry.return_to_picker()


func _on_reload_button_pressed() -> void:
	SystemTestRegistry.reload_current_suite()
