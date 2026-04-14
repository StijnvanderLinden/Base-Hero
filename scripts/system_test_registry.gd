extends Node

const SUITES_DIRECTORY := "res://resources/test_suites"
const PICKER_SCENE_PATH := "res://scenes/system_test_picker.tscn"
const HOST_SCENE_PATH := "res://scenes/system_test_host.tscn"

var current_suite: SystemTestSuiteDefinition


func list_suites() -> Array[SystemTestSuiteDefinition]:
	var suites: Array[SystemTestSuiteDefinition] = []
	var directory := DirAccess.open(SUITES_DIRECTORY)
	if directory == null:
		return suites

	directory.list_dir_begin()
	while true:
		var entry := directory.get_next()
		if entry == "":
			break
		if directory.current_is_dir():
			continue
		if not entry.ends_with(".tres"):
			continue
		var resource_path := "%s/%s" % [SUITES_DIRECTORY, entry]
		var suite_resource := load(resource_path)
		if suite_resource is SystemTestSuiteDefinition:
			suites.append(suite_resource)
	directory.list_dir_end()
	suites.sort_custom(func(a: SystemTestSuiteDefinition, b: SystemTestSuiteDefinition) -> bool:
		return a.title.naturalnocasecmp_to(b.title) < 0
	)
	return suites


func get_suite_by_id(suite_id: String) -> SystemTestSuiteDefinition:
	for suite in list_suites():
		if suite.suite_id == suite_id:
			return suite
	return null


func launch_suite(suite: SystemTestSuiteDefinition) -> void:
	if suite == null or suite.scene_path == "":
		return
	current_suite = suite
	get_tree().change_scene_to_file(HOST_SCENE_PATH)


func reload_current_suite() -> void:
	if current_suite == null:
		return_to_picker()
		return
	get_tree().change_scene_to_file(HOST_SCENE_PATH)


func return_to_picker() -> void:
	current_suite = null
	get_tree().change_scene_to_file(PICKER_SCENE_PATH)
