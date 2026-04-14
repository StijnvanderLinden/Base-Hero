extends Control

@onready var suites_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/SuitesContainer
@onready var empty_state_label: Label = $MarginContainer/VBoxContainer/EmptyStateLabel


func _ready() -> void:
	_populate_suite_list()


func _populate_suite_list() -> void:
	for child in suites_container.get_children():
		child.queue_free()

	var suites := SystemTestRegistry.list_suites()
	empty_state_label.visible = suites.is_empty()
	for suite in suites:
		suites_container.add_child(_build_suite_card(suite))


func _build_suite_card(suite: SystemTestSuiteDefinition) -> Control:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	card.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	margin.add_child(layout)

	var title_label := Label.new()
	title_label.text = suite.title
	title_label.add_theme_font_size_override("font_size", 20)
	layout.add_child(title_label)

	var summary_label := Label.new()
	summary_label.text = suite.summary
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(summary_label)

	if not suite.tags.is_empty():
		var tags_label := Label.new()
		tags_label.text = "Tags: %s" % ", ".join(PackedStringArray(suite.tags))
		tags_label.modulate = Color(0.74, 0.82, 0.9)
		layout.add_child(tags_label)

	var launch_button := Button.new()
	launch_button.text = "Launch"
	launch_button.pressed.connect(func() -> void:
		SystemTestRegistry.launch_suite(suite)
	)
	layout.add_child(launch_button)

	return card
