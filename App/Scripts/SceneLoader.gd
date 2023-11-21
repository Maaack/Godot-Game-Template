extends Node

signal scene_loaded

var loading_screen = preload("res://App/Scenes/LoadingScreen/LoadingScreen.tscn")
var scene_to_load : String
var loaded_resource : Resource

func reload_current_scene() -> void:
	get_tree().reload_current_scene()

func load_scene(path : String, in_background : bool = false) -> void:
	if path == null or path.is_empty():
		print("no path given to load")
		return
	if scene_to_load != path:
		scene_to_load = path
		ResourceLoader.load_threaded_request(scene_to_load)
	else:
		call_deferred("emit_signal", "scene_loaded")
		return
	get_tree().paused = false
	if in_background:
		set_process(true)
		return
	var err = get_tree().change_scene_to_packed(loading_screen)
	if err:
		print("failed to load loading screen: %d" % err)
		get_tree().quit()

func get_status():
	if scene_to_load == null or scene_to_load == "":
		return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	return ResourceLoader.load_threaded_get_status(scene_to_load)

func get_progress():
	if scene_to_load == null or scene_to_load == "":
		return
	var progress_array : Array = []
	ResourceLoader.load_threaded_get_status(scene_to_load, progress_array)
	return progress_array.pop_back()

func get_resource():
	if scene_to_load == null or scene_to_load == "":
		return ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
	var current_loaded_resource = ResourceLoader.load_threaded_get(scene_to_load)
	if current_loaded_resource != null:
		loaded_resource = current_loaded_resource
	return loaded_resource

func _process(delta):
	var status = get_status()
	match(status):
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			emit_signal("scene_loaded")
			set_process(false)
