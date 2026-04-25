extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var result_path := "res://headless_smoke_result.txt"
	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_write_result(result_path, "FAILED: could not load main scene")
		push_error("Failed to load res://scenes/main.tscn")
		quit(1)
		return

	var instance := scene.instantiate()
	root.add_child(instance)
	await process_frame
	await physics_frame
	_write_result(result_path, "OK: main scene instantiated and processed")
	print("HEADLESS_SMOKE_OK")
	quit(0)


func _write_result(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_line(text)
	file.close()
